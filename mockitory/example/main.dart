import 'package:mockitory/mockitory.dart';

enum Gender { male, female }

class ExampleMockitory with Mockitory {
  @override
  Map<String, MockValue> get initialMockValues => {
        'boolValue': MockValue<bool>(true),
        'intValue': MockValue<int>(1),
        'doubleValue': MockValue<double>(4.5),
        'gender': MockValue<Gender>(Gender.male),
        'listOfInts': MockValue<List<int>>([0, 1]),
        'dateValue': MockValue(DateTime(2020, 5, 5)),
      };

  Stream<Gender> observeGender() => observeMockValueUpdates<Gender>('gender')
      .map((mockValue) => mockValue.value);
}
