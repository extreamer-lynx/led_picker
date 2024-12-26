import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:led_picker/src/bl/api/led_api.dart';
import 'package:provider/provider.dart';

import '../../bl/helpers/deeplink_helper.dart';
import '../tabs/color_select_tab.dart';
import '../tabs/programm_select_tab.dart';

class MainScreen extends StatefulWidget {
  final ScanResult result;
  final String? initialDeepLink;

  const MainScreen({super.key, required this.result, this.initialDeepLink});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  Map<Tab, Widget> tabs = {
    const Tab(icon: Icon(Icons.home)): const ColorSelectTab(),
    const Tab(icon: Icon(Icons.mode)): const ProgrammSelectTab(),
  };

  List<BluetoothService>? bluetoothServiceList;
  late final BluetoothDevice device;
  late final StreamSubscription<Uri> uriSubscription;
  late final StreamSubscription<BluetoothConnectionState> subscription;
  BluetoothConnectionState? connectionState;
  LedApi? ledApi;

  @override
  void initState() {
    device = widget.result.device;
    subscription =
        device.connectionState.listen((BluetoothConnectionState state) async {
      setState(() {
        connectionState = state;
      });

      if (state == BluetoothConnectionState.connected) {
        device.discoverServices().then((value) async {
          var services = value.firstWhere((element) => element.isPrimary);

          if (services.characteristics.isEmpty) {
            moveBack(disconnect: true);
            return;
          }

          var characteristic = services.characteristics
              .firstWhere((element) => !element.isNotifying);

          setState(() {
            ledApi = LedApi(characteristic: characteristic);
          });
        });
      } else if (state == BluetoothConnectionState.disconnected) {
        if (kDebugMode) {
          print(
              "${device.disconnectReason?.code} ${device.disconnectReason?.description}");
        }
        await moveBack();
      }
    });

    device.connect();

    if (widget.initialDeepLink != null) {
      DeeplinkHelper.parseDeeplink(widget.initialDeepLink!, ledApi);
    }

    uriSubscription = AppLinks().uriLinkStream.listen((uri) {
      DeeplinkHelper.parseDeeplink(uri.toString(), ledApi);
    });

    super.initState();
  }

  @override
  void dispose() {
    uriSubscription.cancel();
    subscription.cancel();
    super.dispose();
  }

  Future<void> moveBack({bool disconnect = false}) async {
    if (disconnect) {
      await device.disconnect();
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          appBar: AppBar(
            title: const Text("main_title"),
            bottom: TabBar(
              tabs: tabs.keys.toList(),
            ),
          ),
          body: connectionState == BluetoothConnectionState.connected &&
                  ledApi != null
              ? Provider(
                  create: (_) => ledApi,
                  child: TabBarView(children: tabs.values.toList()),
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await device.connect();
                    },
                    child: const Text("connect"),
                  ),
                ),
        ),
      );
}
