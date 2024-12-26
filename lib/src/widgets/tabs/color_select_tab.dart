import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:led_picker/src/bl/api/led_api.dart';
import 'package:provider/provider.dart';

import '../components/beautiful_toggle_button.dart';

class ColorSelectTab extends StatefulWidget {
  const ColorSelectTab({super.key});

  @override
  State<ColorSelectTab> createState() => _ColorSelectTabState();
}

class _ColorSelectTabState extends State<ColorSelectTab> {
  Color selectedColor = Colors.white;
  LedApi? ledApi;

  @override
  void initState() {
    ledApi = context.read<LedApi>();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            BeautifulToggleButton(
              onTap: (value) {
                if (!value) {
                  ledApi!.turnOff();
                } else {
                  ledApi!.turnOn(selectedColor);
                }
              },
            ),
            ColorPicker(
              pickersEnabled: const {
                ColorPickerType.primary: false,
                ColorPickerType.accent: false,
                ColorPickerType.bw: false,
                ColorPickerType.custom: true,
                ColorPickerType.wheel: true,
              },
              onColorChanged: (Color value) {},
              onColorChangeEnd: (value) {
                selectedColor = value;
                ledApi!.setColor(value);
              },
            ),
          ],
        ),
      );
}
