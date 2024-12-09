import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import 'settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Step Counter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  // User settings
  double _userWeight = 70.0; // kg
  double _userHeight = 175.0; // cm

  // Active time calculation
  DateTime _startTime = DateTime.now();
  Duration _activeTime = Duration.zero;
  Timer? _activeTimer;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    setState(() {
      _steps = event.steps.toString();
      // Calculate calories burned (very rough estimate)
      // Formula: Calories burned = (MET value * 3.5 * weight in kg) / 200 * minutes of activity
      // MET value for walking: 3.5
      // Assume 1 step = 1 minute of activity (for simplicity)
      // Calories = (3.5 * 3.5 * weight) / 200 * steps
    });
    _startActiveTimer();
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
    if (event.status == 'walking') {
      _startActiveTimer();
    } else {
      _stopActiveTimer();
    }
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print('onPedestrianStatusError: $error');
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 'Step Count not available';
    });
    print('onStepCountError: $error');
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  void _startActiveTimer() {
    if (_activeTimer == null || !_activeTimer!.isActive) {
      _activeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _activeTime += Duration(seconds: 1);
        });
      });
    }
  }

  void _stopActiveTimer() {
    _activeTimer?.cancel();
  }

  void _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SettingsPage()),
    );
    if (result != null) {
      setState(() {
        _userWeight = result['weight'];
        _userHeight = result['height'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final caloriesBurned =
        (3.5 * 3.5 * _userWeight) / 200 * (int.tryParse(_steps) ?? 0);
    final formattedActiveTime =
        DateFormat('HH:mm:ss').format(DateTime(0).add(_activeTime));
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: _navigateToSettings,
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Steps taken: $_steps'),
              Text('Calories burned: ${caloriesBurned.toStringAsFixed(2)}'),
              Text('Active time: $formattedActiveTime'),
            ],
          ),
        ));
  }
}
