import 'dart:async';

import 'package:flutter/material.dart';
import 'package:led_picker/src/bl/api/led_api.dart';
import 'package:provider/provider.dart';

import '../components/wheel_picker.dart';

class ProgrammSelectTab extends StatefulWidget {
  const ProgrammSelectTab({super.key});

  @override
  State<ProgrammSelectTab> createState() => _ProgrammSelectTabState();
}

class _ProgrammSelectTabState extends State<ProgrammSelectTab> {
  int programm = 0;
  double _currentSpeed = 0;
  late final LedApi ledApi;
  final daysOfWeek = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    "Random",
    "Rainbow",
    "Fire",
    "RainbowCycle",
    "TheaterChase",
    "TheaterChaseRainbow",
    "MeteorRain",
    "MeteorRainRandom",
    "RunningLights",
    "Twinkle",
    "TwinkleRandom",
    "TwinkleFade",
    "TwinkleFadeRandom",
    "Sparkle",
    "Flash",
    "RandomFlash",
    "HyperFlash",
  ];

  final secondsWheel = WheelPickerController(itemCount: 10);
  final textStyle = const TextStyle(fontSize: 32.0, height: 1.5);

  @override
  void initState() {
    ledApi = context.read<LedApi>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Timer.periodic(const Duration(seconds: 1), (_) => secondsWheel.shiftDown());

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('select_programm'),
          SizedBox(
            height: 200,
            width: 200,
            child: WheelPicker(
              itemCount: 23,
              builder: (context, index) => Text(daysOfWeek[index]),
              selectedIndexColor: Colors.orange,
              looping: false,
              onIndexChanged: (index) {
                setState(() {
                  programm = index;
                });
                ledApi.setProgramm(programm, _currentSpeed.toInt());
              },
            ),
          ),
          const SizedBox(height: 20),
          Slider(
            min: 0,
            value: _currentSpeed,
            max: 10,
            label: "brightness",
            onChanged: (double value) {
              setState(() {
                _currentSpeed = value;
              });
              ledApi.setProgramm(programm, _currentSpeed.toInt());
            },
          )
        ],
      ),
    );
  }
}
