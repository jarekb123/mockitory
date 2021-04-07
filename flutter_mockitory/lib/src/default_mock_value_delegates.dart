import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mockitory/mockitory.dart';

import '../flutter_mockitory.dart';

final List<MockValueDelegate> defaultMockValueDelegates = [
  BoolMockValueDelegate(),
  StringMockValueDelegate(),
  IntMockValueDelegate(),
  DoubleMockValueDelegate(),
  DateTimeMockValueDelegate(),
];

class BoolMockValueDelegate extends MockValueDelegate<bool> {
  const BoolMockValueDelegate();

  @override
  Widget buildMockValueWidget(BuildContext context, bool value, onChanged) {
    return Checkbox(
      value: value,
      onChanged: (value) {
        if (value != null) {
          onChanged(MockValue(value));
        }
      },
    );
  }
}

abstract class TextFieldMockValueDelegate<T> extends MockValueDelegate<T> {
  const TextFieldMockValueDelegate();

  T parse(String value);

  List<TextInputFormatter> get inputFormatters => [];

  @override
  Widget buildMockValueWidget(BuildContext context, T value, onChanged) {
    return TextFormField(
      initialValue: '$value',
      onChanged: (newValue) => onChanged(MockValue(parse(newValue))),
      inputFormatters: inputFormatters,
    );
  }
}

class StringMockValueDelegate extends TextFieldMockValueDelegate<String> {
  const StringMockValueDelegate();

  @override
  String parse(String value) => value;
}

class IntMockValueDelegate extends TextFieldMockValueDelegate<int> {
  const IntMockValueDelegate();

  @override
  int parse(String value) => int.parse(value);

  @override
  List<TextInputFormatter> get inputFormatters =>
      [FilteringTextInputFormatter.digitsOnly];
}

class DoubleMockValueDelegate extends TextFieldMockValueDelegate<double> {
  const DoubleMockValueDelegate();

  @override
  double parse(String value) => double.parse(value);

  @override
  List<TextInputFormatter> get inputFormatters =>
      [FilteringTextInputFormatter.allow(RegExp(r'^\d+(?:\.\d+|\.)?'))];
}

class ChoicesMockValueDelegate<T> extends MockValueDelegate<T> {
  final List<T> values;

  ChoicesMockValueDelegate(this.values);

  @override
  Widget buildMockValueWidget(BuildContext context, T currentValue, onChanged) {
    return DropdownButton<T>(
      items: values
          .map(
            (value) => DropdownMenuItem(
              child: Text('$value'),
              value: value,
            ),
          )
          .toList(),
      value: currentValue,
      onChanged: (value) {
        if (value != null) onChanged(MockValue(value));
      },
    );
  }
}

class IterableMockValueDelegate<T, I extends Iterable<T>>
    extends MockValueDelegate<I> {
  final List<I> values;

  IterableMockValueDelegate(this.values);

  @override
  Widget buildMockValueWidget(BuildContext context, I value, onChanged) {
    final currentIndex = values
        .indexWhere((element) => listEquals(element.toList(), value.toList()));
    return DropdownButton<int>(
      items: [
        for (int i = 0; i < values.length; i++)
          DropdownMenuItem(child: Text(values[i].toString()), value: i),
      ],
      value: currentIndex,
      onChanged: (index) {
        if (index != null) {
          onChanged(MockValue(values[index]));
        }
      },
    );
  }
}

class DateTimeMockValueDelegate extends MockValueDelegate<DateTime> {
  const DateTimeMockValueDelegate();

  @override
  Widget buildMockValueWidget(BuildContext context, DateTime value, onChanged) {
    return Row(
      children: [
        Text(_formatDate(value)),
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            final chosenDate = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (chosenDate != null) {
              onChanged(MockValue(chosenDate));
            }
          },
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day}';
  }
}
