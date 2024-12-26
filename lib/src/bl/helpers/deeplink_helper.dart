import 'dart:ui';

import 'package:led_picker/src/bl/api/led_api.dart';

class DeeplinkHelper {
  static void parseDeeplink(String url, LedApi? ledApi) {
    if (ledApi == null) {
      return;
    }

    if (url.isEmpty) {
      return;
    }

    final changeType = url.split("://")[1].split("/")[0];

    Map<String, dynamic> queryParameters = {};

    url.split("://")[1].split("/?")[1].split("&").forEach((e) {
      final split = e.split("=");
      queryParameters[split[0]] = split[1];
    });

    switch (changeType) {
      case "color":
        final color = Color(int.parse(queryParameters["color"]!));
        ledApi.setColor(color);
        break;
      case "turnOn":
        final color = Color(int.parse(queryParameters["color"]!));
        ledApi.turnOn(color);
        break;
      case "turnOff":
        ledApi.turnOff();
        break;
      case "programm":
        final programm = int.parse(queryParameters["programm"]!);
        final speed = int.parse(queryParameters["speed"]!);
        ledApi.setProgramm(programm, speed);
        break;
      default:
        break;
    }
  }
}
