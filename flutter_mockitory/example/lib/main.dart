import 'package:flutter/material.dart';
import 'package:flutter_mockitory/flutter_mockitory.dart';
import 'package:mockitory_example/example_mockitory.dart';

void main() {
  runApp(MyApp());
}

class CustomBoolMockValueDelegate extends MockValueDelegate<bool> {
  @override
  Widget buildMockValueWidget(BuildContext context, bool value, onChanged) {
    return Checkbox(
      activeColor: Colors.red,
      value: value,
      onChanged: (value) {
        if (value != null) onChanged(MockValue(value));
      },
    );
  }
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ExampleMockitory mockitory1 = ExampleMockitory();
  ExampleMockitory mockitory2 = ExampleMockitory();

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  int _page = 0;

  @override
  void initState() {
    super.initState();
    mockitory1.observeGender().listen((gender) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text('Gender updated: $gender')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      MockitoryPage(
        key: ValueKey(1),
        mockitory: mockitory1,
        customDelegates: [
          CustomBoolMockValueDelegate(),
          ChoicesMockValueDelegate<Gender>([Gender.male, Gender.female]),
          IterableMockValueDelegate([
            [0, 1],
            [0, 2]
          ]),
        ],
      ),
      MockitoryPage(
        key: ValueKey(2),
        mockitory: mockitory2,
      ),
    ];

    return MaterialApp(
      title: 'Mockitory demo',
      home: Scaffold(
        key: _scaffoldKey,
        body: pages[_page],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _page,
          onTap: (value) {
            setState(() => _page = value);
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.ac_unit),
              label: 'Mockitory 1',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_alarm_outlined),
              label: 'Mockitory 2',
            ),
          ],
        ),
      ),
    );
  }
}
