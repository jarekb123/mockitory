import 'dart:async';

mixin Mockitory {
  /// Map of named MockValue with initial values. This map never changes.
  Map<String, MockValue> get initialMockValues;

  /// Map of named MockValue objects with updated values.
  Map<String, MockValue> get mockValues =>
      _currentMockValues ??= {...initialMockValues};

  Map<String, MockValue> _currentMockValues;
  final _changesController = StreamController<String>.broadcast();

  void updateValue<T>(String name, MockValue<T> value) {
    if (!mockValues.containsKey(name)) {
      throw MockValueNotRegisteredError();
    } else {
      if (mockValues[name].value is T) {
        _changesController.add(name);
        mockValues[name] = value;
      } else {
        throw ArgumentError(
          'It is not allowed to update MockValue with different '
          'type than previously registered in [initialMockValues] Map',
        );
      }
    }
  }

  T getValue<T>(String name) {
    if (!mockValues.containsKey(name)) {
      throw MockValueNotRegisteredError();
    } else {
      final mockValue = mockValues[name] as MockValue<T>;
      if (mockValue.hasError) {
        throw mockValue.error;
      } else {
        return mockValue.value;
      }
    }
  }

  /// Emits changes of MockValue's value. The difference between [observeMockValueUpdates]
  /// is that [observeValues] emits error if MockValue's error is not null
  Stream<T> observeValues<T>(String name) {
    return observeMockValueUpdates<T>(name).map((mockValue) {
      if (mockValue.error != null && mockValue.error is! _NoError) {
        throw mockValue.error;
      } else {
        return mockValue.value;
      }
    });
  }

  Stream<MockValue<T>> observeMockValueUpdates<T>(String name) async* {
    if (!mockValues.containsKey(name)) {
      throw MockValueNotRegisteredError();
    } else {
      yield* _changesController.stream
          .where((mockValueName) => mockValueName == name)
          .map((name) => mockValues[name]);
    }
  }
}

class MockValue<T> {
  final T value;

  // nullable
  final Object error;

  MockValue(
    this.value, {
    this.error = const _NoError(),
  }) : assert(error != null);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is MockValue<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  bool get hasError => error is! _NoError;

  @override
  String toString() => 'MockValue(value: $value)';

  MockValue<T> copyWith({
    T value,
    Object error,
  }) {
    return MockValue<T>(
      value ?? this.value,
      error: error ?? _NoError(),
    );
  }
}

class _NoError {
  const _NoError();
}

class MockValueNotRegisteredError {
  const MockValueNotRegisteredError();

  @override
  String toString() {
    return 'MockValueNotRegisteredError: It is not allowed to update value that was '
        'not registered in [initialMockValues] Map.';
  }
}
