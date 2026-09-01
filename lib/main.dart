import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skillatics_new_1225/TranslationText.dart';
import 'package:skillatics_new_1225/menuPage.dart';

void main() {
  runApp(MyApp());
}

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

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  MaterialColor colorCustom = MaterialColor(0xffbcfa00, color);

  int anzColorsOnPage = 2;
  int secChangeColor = 5;
  int secLengthRound = 210; //=roundDisplayedSec+roundDisplayedMin in sekunden
  int secLengthRest = 90; //=restDisplayedSec+restDisplayedMin in sekunden
  int anzRounds = 5;
  bool isElemProSeiteEinmalig = false;
  bool isStroopActive = false;

  MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
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
      home: MyHomePage(
        title: 'Skillatics',
        currentCountry: "GB", //aktuelle Flagge die oben rechts erscheint
        listSelectedColors: [],
        listSelectedArrowsPerColor: [
          '_4278190080',
        ], //per default schwarze arrowcolor selektiert  aus benutzerfreundlichkeit
        listSelectedNumbersPerColor: [
          '_4278190080',
        ], //per default schwarze numbercolor selektiert aus benutzerfreundlichkeit
        listSelectedShapesPerColor: [
          '_4278190080',
        ], //per default schwarze shapecolor selektiert aus benutzerfreundlichkeit
        listSelectedAlphabetlettersPerColor: [
          '_4278190080',
        ], //per default schwarze alphabetlettercolor selektiert aus benutzerfreundlichkeit
        listSelectedBackgroundcolors: [
          4294967295,
        ], //per default weiss als Hintergrundfarbe selektiert aus Benutzerfreundlichkeit
        listSelectedStroopcolors: [], //per default stroop nicht aktiv
        anzColorsOnPage: anzColorsOnPage,
        secChangeColor: secChangeColor,
        secLengthRound: secLengthRound,
        secLengthRest: secLengthRest,
        anzRounds: anzRounds,
        isElemProSeiteEinmalig: isElemProSeiteEinmalig,
        nr_individual: '',
        nr_from: '',
        nr_to: '',
        nr_skip: '',
      ),
      translations: TranslationText(),
      locale: const Locale('de', 'DE'),
    );
  }
}
