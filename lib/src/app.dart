import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'widgets/screens/connection_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routes: {
          '/': (context) => const ConnectionScreen(),
        },
        initialRoute: '/',
      );
}
