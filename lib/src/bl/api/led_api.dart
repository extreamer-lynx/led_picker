import 'dart:ui';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class LedApi {
  final BluetoothCharacteristic characteristic;

  LedApi({required this.characteristic});

  Future<void> setColor(Color color) async {
    // Convert color to bytes
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    // Command structure (example): 0x69960502RRGGBB
    final command = [0x69, 0x96, 0x05, 0x02, red, green, blue, color.alpha];
    await characteristic.write(command, withoutResponse: true);
  }

  Future<void> turnOff() async {
    // Command structure (example): 0x6996020100
    final command = [0x69, 0x96, 0x02, 0x01, 0x00];
    await characteristic.write(command, withoutResponse: true);
  }

  Future<void> turnOn(Color color) async {
    // Command structure (example): 0x6996020101
    final red = color.red;
    final green = color.green;
    final blue = color.blue;

    final command = [
      0x69,
      0x96,
      0x02,
      0x01,
      0x01,
      red,
      green,
      blue,
      color.alpha
    ];
    await characteristic.write(command, withoutResponse: true);
  }

  Future<void> setProgramm(int program, int speed) async {
    // Command structure (example): 0x699603040906
    final command = [
      0x69,
      0x96,
      0x03,
      program >= 11 ? 0x04 : 0x03,
      program >= 11 ? program - 11 : program,
      speed
    ];
    await characteristic.write(command, withoutResponse: true);
  }
}
