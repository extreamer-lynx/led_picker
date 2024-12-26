import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import '../components/scan_result_tile.dart';
import 'main_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  late final StreamSubscription<BluetoothAdapterState>
      bluetoothAdapterStateSubscription;
  late final StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  String initialDeepLink = "";

  bool? isBluetoothSupported;
  bool _isScanning = false;
  BluetoothAdapterState? _bluetoothAdapterState;

  @override
  void initState() {
    AppLinks().getInitialLinkString().then((uri) {
      if (uri != null) {
        initialDeepLink = uri;
      }
    });

    FlutterBluePlus.isSupported.then((bool supported) {
      setState(() {
        isBluetoothSupported = supported;
      });
    });

    bluetoothAdapterStateSubscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      setState(() {
        _bluetoothAdapterState = state;
      });
      if (state == BluetoothAdapterState.on) {
        FlutterBluePlus.startScan(
            timeout: const Duration(seconds: 15),
            withServices: [Guid("1812"), Guid("180F")]);
      }
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    bluetoothAdapterStateSubscription.cancel();
    _isScanningSubscription.cancel();
    _scanResultsSubscription.cancel();
    super.dispose();
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withServices: [
          Guid("1812"),
          Guid("180F")
        ], // match any of the specified services
      );
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  bool get isAllOk =>
      isBluetoothSupported == true &&
      _bluetoothAdapterState == BluetoothAdapterState.on;

  bool get isAdapterLoad =>
      _bluetoothAdapterState == null && isBluetoothSupported == null;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: isAllOk
            ? AppBar(
                title: const Text("select_device"),
              )
            : null,
        body: isAllOk == false
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    if (isBluetoothSupported == false)
                      const Text("doesnt_support_bluetooth"),
                    if (_bluetoothAdapterState == BluetoothAdapterState.off)
                      const Text("turn_on_bluetooth"),
                    if (_bluetoothAdapterState ==
                        BluetoothAdapterState.unavailable)
                      const Text("bluetooth_unavailable"),
                    if (Platform.isAndroid)
                      TextButton(
                          onPressed: () {
                            FlutterBluePlus.turnOn();
                          },
                          child: const Text("turn_on")),
                    if (isAdapterLoad) const CircularProgressIndicator(),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: onRefresh,
                child: StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Error: ${snapshot.error}"),
                          ],
                        ),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.waiting ||
                        snapshot.data == null ||
                        snapshot.data!.isEmpty) {
                      return const Center(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                        ],
                      ));
                    }

                    if (initialDeepLink.isNotEmpty &&
                        snapshot.data!.length > 1) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MainScreen(result: snapshot.data!.first),
                        ),
                      );
                    }

                    return ListView(
                      children: snapshot.data!
                          .map(
                            (result) => ScanResultTile(
                              result: result,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        MainScreen(result: result),
                                  ),
                                );
                              },
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
      );
}
