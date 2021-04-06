import 'package:flutter/material.dart';
import 'package:mockitory/mockitory.dart';

import 'default_mock_value_delegates.dart';
import 'mock_value_delegate.dart';

class MockitoryPage extends StatefulWidget {
  const MockitoryPage({
    Key key,
    @required this.mockitory,
    this.customDelegates = const [],
  }) : super(key: key);

  final Mockitory mockitory;
  final List<MockValueDelegate> customDelegates;

  @override
  _MockitoryPageState createState() => _MockitoryPageState();
}

class _MockitoryPageState extends State<MockitoryPage> {
  List<String> get _names => widget.mockitory.mockValues.keys.toList();

  GlobalKey<FormState> _formKey;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.mockitory.runtimeType}'),
        actions: [
          FlatButton(
            onPressed: () => _formKey.currentState.save(),
            child: Text(
              'Save all',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView.separated(
          itemCount: _names.length,
          separatorBuilder: (_, __) => Divider(),
          itemBuilder: (context, index) {
            return StreamBuilder<MockValue>(
              stream: widget.mockitory.observeMockValueUpdates(_names[index]),
              initialData: widget.mockitory.mockValues[_names[index]],
              builder: (context, snapshot) {
                return MockValueListTile(
                  name: _names[index],
                  mockValue: snapshot.data,
                  onSaved: (mockValue) =>
                      widget.mockitory.updateValue(_names[index], mockValue),
                  delegates: [
                    ...widget.customDelegates,
                    ...defaultMockValueDelegates,
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class MockValueListTile extends StatefulWidget {
  const MockValueListTile({
    Key key,
    @required this.name,
    @required this.mockValue,
    @required this.onSaved,
    this.delegates = const [],
  }) : super(key: key);

  final String name;
  final MockValue mockValue;
  final ValueChanged<MockValue> onSaved;
  final List<MockValueDelegate> delegates;

  @override
  _MockValueListTileState createState() => _MockValueListTileState();
}

class _MockValueListTileState extends State<MockValueListTile> {
  GlobalKey<FormFieldState<MockValue>> _formKey;
  int _errorIndex;

  List<Object> errors = [
    Exception(),
    ArgumentError(),
  ];

  @override
  void initState() {
    super.initState();
    _errorIndex = errors.indexWhere((error) =>
            widget.mockValue?.error?.runtimeType == error.runtimeType) +
        1;

    _formKey = GlobalKey();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: widget.mockValue.hasError ? Icon(Icons.error) : null,
      title: Row(
        children: [
          Text(widget.name),
          SizedBox(width: 16),
          Expanded(
            child: MockValueWidgetFactory(
              fieldKey: _formKey,
              mockValue: widget.mockValue,
              onSaved: (value) => widget.onSaved(value.copyWith(
                  error: _errorIndex == 0 ? null : errors[_errorIndex - 1])),
              delegates: widget.delegates,
            ),
          ),
        ],
      ), // custom type builder
      children: [
        _ErrorDropdown(
          index: _errorIndex,
          itemsCount: errors.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Text('No Error');
            }
            return Text(errors[index - 1].runtimeType.toString());
          },
          onChanged: (index) {
            setState(() {
              _errorIndex = index;
            });
          },
        ),
      ],
    );
  }
}

class _ErrorDropdown extends StatelessWidget {
  const _ErrorDropdown({
    Key key,
    @required this.index,
    @required this.onChanged,
    this.itemsCount = 0,
    this.itemBuilder,
  }) : super(key: key);

  final int index;
  final ValueChanged<int> onChanged;
  final IndexedWidgetBuilder itemBuilder;
  final int itemsCount;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Row(
        children: [
          Text('Throws error:'),
          SizedBox(width: 16),
          DropdownButton<int>(
            value: index,
            items: [
              for (int i = 0; i < itemsCount; i++)
                DropdownMenuItem(
                  child: itemBuilder(context, i),
                  value: i,
                )
            ],
            onChanged: (index) => onChanged(index),
          )
        ],
      ),
    );
  }
}

class MockValueWidgetFactory extends StatefulWidget {
  const MockValueWidgetFactory({
    Key key,
    @required this.mockValue,
    this.onSaved,
    this.fieldKey,
    @required this.delegates,
  }) : super(key: key);

  final GlobalKey<FormFieldState<MockValue>> fieldKey;
  final MockValue mockValue;
  final ValueChanged<MockValue> onSaved;
  final List<MockValueDelegate> delegates;

  @override
  _MockValueWidgetFactoryState createState() => _MockValueWidgetFactoryState();
}

class _MockValueWidgetFactoryState extends State<MockValueWidgetFactory> {
  @override
  Widget build(BuildContext context) {
    return FormField<MockValue>(
      key: widget.fieldKey,
      initialValue: widget.mockValue,
      onSaved: (newValue) {
        widget.onSaved(widget.fieldKey.currentState.value);
      },
      builder: (state) {
        final delegate = widget.delegates.firstWhere(
          (delegate) {
            return delegate.handlesValue(widget.mockValue.value);
          },
          orElse: () => null,
        );

        if (delegate != null) {
          return delegate.buildMockValueWidget(
            context,
            widget.fieldKey.currentState.value.value,
            (mockValue) {
              widget.fieldKey.currentState.didChange(mockValue);
            },
          );
        } else {
          return Text(widget.mockValue.value.toString());
        }
      },
    );
  }
}
