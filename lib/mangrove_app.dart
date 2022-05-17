import 'package:flutter/material.dart';
import 'package:mangrove_classification/landing_page.dart';
import 'package:mangrove_classification/map_page.dart';
import 'package:page_transition/page_transition.dart';

class MangroveApp extends StatelessWidget {
  const MangroveApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mangrove Detection App',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case "/map_page":
            return PageTransition(
              child: const MapPage(),
              type: PageTransitionType.leftToRight,
            );
          default:
            return PageTransition(
              child: const LandingPage(),
              type: PageTransitionType.leftToRight,
            );
        }
      },
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
              titleTextStyle: const TextStyle(
                color: Colors.black,
              ),
              backgroundColor: Colors.grey.shade100,
              iconTheme: const IconThemeData(
                color: Colors.black,
              ))),
      home: const LandingPage(),
    );
  }
}
