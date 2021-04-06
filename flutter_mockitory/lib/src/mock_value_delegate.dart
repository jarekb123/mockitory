import 'package:flutter/material.dart';
import 'package:mockitory/mockitory.dart';

abstract class MockValueDelegate<T> {
  const MockValueDelegate();

  Widget buildMockValueWidget(
    BuildContext context,
    T value,
    ValueChanged<MockValue<T>> onChanged,
  );

  /// Checks if delegate can render widget for generic type [T]
  bool handlesValue(dynamic value) => value is T;
}
