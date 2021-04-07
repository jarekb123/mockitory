import 'package:test/test.dart';
import 'package:mockitory/mockitory.dart';

class _CustomError {}

class _TestMockitory with Mockitory {
  @override
  Map<String, MockValue> get initialMockValues => {
        'boolValue': MockValue<bool>(false),
        'stringValue': MockValue<String>('string'),
        'boolValueWithError': MockValue<bool>(true, error: _CustomError()),
      };
}

void main() {
  late _TestMockitory testMockitory;

  setUp(() {
    testMockitory = _TestMockitory();
  });

  test(
    'mockValues initialy returns initialMockValues',
    () {
      expect(testMockitory.mockValues, testMockitory.initialMockValues);
    },
  );

  test(
    'it is not allowed to update value with different type',
    () {
      expect(
        () => testMockitory.updateValue('boolValue', MockValue('string')),
        throwsA(anything),
      );
      expect(
        () => testMockitory.updateValue('stringValue', MockValue(1)),
        throwsA(anything),
      );
    },
  );

  test(
    'observeMockValuesUpdates emits updates of MockValue',
    () async {
      final updates = <MockValue>[];
      testMockitory.observeMockValueUpdates('boolValue').listen(updates.add);
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(true));
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(false));
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(false));
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(true));
      await Future.delayed(Duration.zero);

      expect(updates, [
        MockValue(true),
        MockValue(false),
        MockValue(false),
        MockValue(true),
      ]);
    },
  );

  test(
    'it is not possible to observe not registered MockValue',
    () {
      expect(
        testMockitory.observeMockValueUpdates('unknown'),
        emitsError(isA<MockValueNotRegisteredError>()),
      );
    },
  );
  test(
    'it is not possible to update not registered MockValue',
    () {
      expect(
        () => testMockitory.updateValue('unknown', MockValue('value')),
        throwsA(isA<MockValueNotRegisteredError>()),
      );
    },
  );

  test(
    'if MockValue error is not null, observeValue(name) emits error',
    () async {
      final errors = <Exception>[];
      final values = [];

      testMockitory
          .observeValues<bool>('boolValue')
          .listen(values.add, onError: errors.add);
      await Future.delayed(Duration.zero);

      testMockitory.updateValue(
          'boolValue', MockValue(true, error: Exception()));

      await Future.delayed(Duration(milliseconds: 100));

      expect(errors, isNotEmpty);
      expect(values, isEmpty);
    },
  );

  test(
    'observeValues emits updates of MockValue value',
    () async {
      final updates = <bool>[];
      testMockitory.observeValues<bool>('boolValue').listen(updates.add);
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(true));
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(false));
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(false));
      await Future.delayed(Duration.zero);

      testMockitory.updateValue('boolValue', MockValue(true));
      await Future.delayed(Duration.zero);

      expect(updates, [true, false, false, true]);
    },
  );

  test(
    'getValue returns value of registered MockValue',
    () {
      expect(testMockitory.getValue<bool>('boolValue'), false);
      testMockitory.updateValue('boolValue', MockValue(true));
      expect(testMockitory.getValue<bool>('boolValue'), true);
    },
  );

  test(
    'getValue throws value of registered MockValue.error',
    () {
      expect(
        () => testMockitory.getValue<bool>('boolValueWithError'),
        throwsA(isA<_CustomError>()),
      );
    },
  );
  test(
    'it is not possible to getValue of not registered MockValue',
    () {
      expect(
        () => testMockitory.getValue<bool>('unknown'),
        throwsA(isA<MockValueNotRegisteredError>()),
      );
    },
  );
}
