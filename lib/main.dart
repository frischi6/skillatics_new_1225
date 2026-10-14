import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skillatics/start.dart';
import 'TranslationText.dart';

//damit primaryswatch in materialapp themedata customized color haben kann
Map<int, Color> color = {
  50: const Color.fromRGBO(188, 250, 0, .1),
  100: const Color.fromRGBO(188, 250, 0, .2),
  200: const Color.fromRGBO(188, 250, 0, .3),
  300: const Color.fromRGBO(188, 250, 0, .4),
  400: const Color.fromRGBO(188, 250, 0, .5),
  500: const Color.fromRGBO(188, 250, 0, .6),
  600: const Color.fromRGBO(188, 250, 0, .7),
  700: const Color.fromRGBO(188, 250, 0, .8),
  800: const Color.fromRGBO(188, 250, 0, .9),
  900: const Color.fromRGBO(188, 250, 0, 1),
};

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  // This widget is the root of your application.

  //Farbschema für die gesamte App
  MaterialColor colorCustom = MaterialColor(0xffbcfa00, color);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Skillatics',
      theme: ThemeData(
        primarySwatch: colorCustom,
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          primary: colorCustom,
          onPrimary: Colors.black,
          secondary: Colors.black,
          onSecondary: Colors.black,
          surface: Colors.white, // colorCustom,
          onSurface: Colors.black,
          error: Colors.red,
          onError: Colors.black,
        ),
        //unselectedWidgetColor: Colors.black, //noch nötig?
      ),
      translations: TranslationText(),
      locale: const Locale('de', 'DE'),
      home: StartingPage(),
    );
  }
}
