import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppHelper {
  // Das ist ein privater Konstruktor. Er verhindert,
  // dass jemand versehentlich 'AppHelper()' im Code aufruft.
  AppHelper._();

  ///Default-Values für Menupage Kognitiv
  static dynamic getDefaultKognitiv(String varname) {
    switch (varname) {
      case 'title':
        return 'Kognition';
      case 'currentCountry':
        return "GB"; //aktuelle Flagge die oben rechts erscheint
      case 'listSelectedColors':
        return [];
      case 'listSelectedArrowsPerColor':
        return [
          '_4278190080',
        ]; //per default schwarze arrowcolor selektiert  aus benutzerfreundlichkeit
      case 'listSelectedNumbersPerColor':
        return [
          '_4278190080',
        ]; //per default schwarze numbercolor selektiert aus benutzerfreundlichkeit
      case 'listSelectedShapesPerColor':
        return [
          '_4278190080',
        ]; //per default schwarze shapecolor selektiert aus benutzerfreundlichkeit
      case 'listSelectedAlphabetlettersPerColor':
        return [
          '_4278190080',
        ]; //per default schwarze alphabetlettercolor selektiert aus benutzerfreundlichkeit
      case 'listSelectedBackgroundcolors':
        return [4294967295];
      case 'listSelectedStroopcolors':
        return [];
      case 'anzColorsOnPage':
        return 2;
      case 'secChangeColor':
        return 5;
      case 'secLengthRound':
        return 210; //=roundDisplayedSec+roundDisplayedMin in sekunden
      case 'secLengthRest':
        return 90; //=restDisplayedSec+restDisplayedMin in sekunden
      case 'anzRounds':
        return 5;
      case 'isElemProSeiteEinmalig':
        return false;
      case 'nr_individual':
        return '';
      case 'nr_from':
        return '';
      case 'nr_to':
        return '';
      case 'nr_skip':
        return '';
    }
  }

  ///Default-Values für Menupage Optodrum
  static dynamic getDefaultOptodrum(String varname) {
    switch (varname) {
      case 'title':
        return 'Optodrum';
      case 'currentCountry':
        return "GB"; // aktuelle Flagge die oben rechts erscheint
      case 'listSelectedArrowsPerColor':
        return [
          '_4278190080',
        ]; // per default schwarze arrowcolor selektiert aus benutzerfreundlichkeit
      case 'listSelectedNumbersPerColor':
        return [
          '_4278190080',
        ]; // per default schwarze numbercolor selektiert aus benutzerfreundlichkeit
      case 'listSelectedShapesPerColor':
        return [
          '_4278190080',
        ]; // per default schwarze shapecolor selektiert aus benutzerfreundlichkeit
      case 'listSelectedAlphabetlettersPerColor':
        return [
          '_4278190080',
        ]; // per default schwarze alphabetlettercolor selektiert aus benutzerfreundlichkeit
      case 'listSelectedBackgroundcolors':
        return [
          4294967295,
        ]; // per default weiss als Hintergrundfarbe selektiert aus Benutzerfreundlichkeit
      case 'listSelectedStroopcolors':
        return []; // per default stroop nicht aktiv
      case 'secLengthRound':
        return 210; //=roundDisplayedSec+roundDisplayedMin in sekunden
      case 'secLengthRest':
        return 90; //=restDisplayedSec+restDisplayedMin in sekunden
      case 'anzRounds':
        return 5;
      case 'nr_individual':
        return '';
      case 'nr_from':
        return '';
      case 'nr_to':
        return '';
      case 'nr_skip':
        return '';
      case 'speedlevel':
        return 5;
      case 'secChangeBackgrcolor':
        return 2;
      case 'moveDirection':
        return 'east';
      case 'gleicheNacheinanderOk':
        return true;
      default:
        return 2;
    }
  }

  /// Erzeugt ein Emoji mit Flagge mit entsprechendem Wert currentCountry
  static String countryFlag(String currentCountry) {
    //https://stackoverflow.com/questions/56999448/display-country-flag-character-in-flutter
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;

    int firstChar = currentCountry.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = currentCountry.codeUnitAt(1) - asciiOffset + flagOffset;

    String emoji =
        String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
    return emoji;
  }

  /// Damit Anzeige in Fusszeile korrekt mit 1 Runde bzw >1 Runden
  static String getRundeSgPl(int anzRounds) {
    if (anzRounds == 1) {
      return 'rundeSg'.tr;
      ;
    } else {
      return 'rundePl'.tr;
    }
  }

  static void showSkillaticsInfos(BuildContext context) {
    showDialog(context: context, builder: (_) => AppHelper.skillaticsDialog());
  }

  static Widget skillaticsDialog() {
    return const AlertDialog(
      content: SizedBox(
        height: 140,
        child: Center(
          child: Column(
            children: [
              Text('\nSkillatics GmbH\n'),
              Text('+41 79 663 48 52'),
              Text('info@skillatics.ch'),
              Text('www.skillatics.ch'),
            ],
          ),
        ),
      ),
    );
  }

  /// AlertDialog das am Ende der Übung erscheint
  static Widget alertDialogFinish(
    BuildContext context,
    VoidCallback onMenupagePressed,
    VoidCallback onNeustartPressed,
  ) {
    return AlertDialog(
      //ähnlich wie modalWindow
      content: Text('trainingEnde'.tr),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Dialog schließen
            onMenupagePressed(); // Übergebene Funktion ausführen
          },
          child: Text(
            'hauptmenü'.tr,
            style: const TextStyle(color: Color.fromARGB(177, 0, 0, 0)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Schließt den Dialog
            onNeustartPressed(); // Startet neu
          },
          child: Text(
            'neustart'.tr,
            style: const TextStyle(color: Color.fromARGB(177, 0, 0, 0)),
          ),
        ),
      ],
    );
  }

  /// Returnt einen AlertDialog, damit der User Zeit hat auf Position zu gehen
  static Widget alertDialogCD() {
    return AlertDialog(
      content: Center(heightFactor: 1.2, child: Text('bereit'.tr)),
    );
  }
}
