import 'package:flutter/material.dart';
import 'menuPage.dart';
import 'menuOptodrum.dart';

class StartingPage extends StatelessWidget {
  StartingPage({super.key});

  //Benötigte Parameter für Randomcolor-Modus
  int anzColorsOnPage = 2;
  int secChangeColor = 5;
  int secLengthRound = 210; //=roundDisplayedSec+roundDisplayedMin in sekunden
  int secLengthRest = 90; //=restDisplayedSec+restDisplayedMin in sekunden
  int anzRounds = 5;
  bool isElemProSeiteEinmalig = false;
  bool isStroopActive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skillatics')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Randomcolor-Modus
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      title: 'Kognition',
                      currentCountry:
                          "GB", //aktuelle Flagge die oben rechts erscheint
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
                      listSelectedStroopcolors:
                          [], //per default stroop nicht aktiv
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
                  ),
                );
              },
              child: const Text('Kognition'),
            ),

            //Flying-Modus
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuOptodrum(
                      title: 'Optodrum',
                      currentCountry:
                          "GB", //aktuelle Flagge die oben rechts erscheint
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
                      listSelectedStroopcolors:
                          [], //per default stroop nicht aktiv
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
                      speedlevel: 5,
                    ),
                  ),
                );
              },
              child: const Text('Optodrum'),
            ),
          ],
        ),
      ),
    );
  }
}
