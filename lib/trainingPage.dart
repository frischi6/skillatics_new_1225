import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:skillatics_new_1225/custom_icons_icons.dart';
import 'package:skillatics_new_1225/menuPage.dart';
import 'package:skillatics_new_1225/number_zero_to_fifty_icons.dart';
import 'package:skillatics_new_1225/stroop__english_icons.dart';
import 'package:skillatics_new_1225/stroop_icons.dart';

class RandomColorPage2 extends StatefulWidget {
  RandomColorPage2({
    Key? key,
    required this.listSelectedColors,
    required this.listSelectedArrowsPerColor,
    required this.listSelectedNumbers,
    required this.listSelectedShapes,
    required this.listSelectedAlphabetletters,
    required this.listSelectedBackgroundcolors,
    required this.anzColorsOnPage,
    required this.secChangeColor,
    required this.secLengthRound,
    required this.secLengthRest,
    required this.anzRounds,
    required this.currentCountry,
    required this.isElemProSeiteEinmalig,
    required this.isStroopActive,
    required this.listStroopText,
    required this.listStroopTextcolors,
    required this.nr_individual,
    required this.nr_from,
    required this.nr_to,
    required this.nr_skip,
  }) : super(key: key);

  var listSelectedColors;
  var listSelectedArrowsPerColor;
  var listSelectedNumbers;
  var listSelectedShapes;
  var listSelectedAlphabetletters;
  var listSelectedBackgroundcolors;
  var listStroopText;
  var listStroopTextcolors;
  int anzColorsOnPage;
  int secChangeColor;
  int secLengthRound;
  int secLengthRest;
  int anzRounds;
  bool isElemProSeiteEinmalig;
  bool isStroopActive;
  String currentCountry;
  String
  nr_individual,
  nr_from,
  nr_to,
  nr_skip; //wird in trainingpage.dart nicht gebraucht, aber muss wieder an menupage zurückgegeben werden

  @override
  _RandomColorPage2 createState() => _RandomColorPage2();
}

class _RandomColorPage2 extends State<RandomColorPage2> {
  var start = DateTime.now().millisecondsSinceEpoch;
  var listWithSelectedColors = []; //gefüllt mit ColorsCheckbox-Elemente
  var listWithSelectedHex = []; //gefüllt mit Hex-Werten (int)
  var listHeight4Container = [];
  var listToFillContainersHex = []; //nur Füllwerte

  var listWithSelectedArrowsPerColor = [];
  var listWithSelectedNumbers = [];
  var listWithSelectedShapes = [];
  var listWithSelectedAlphabetletters = [];
  var listWithSelectedIcons =
      []; //beinhaltet listWithSelectedArrows + listWithSelectedNumbers + listWithSelectedShapes + listWithSelectedAlphabetletters
  var listToFillContainersIcon = [];
  var listWithSelectedBackgroundcolors =
      []; //Original mit jeder Backcgroundcolor einmal drin, wie es von Menupage kommt
  var listWithSelectedBackgroundcolorsToFill =
      []; //Aus diesem Array wird das Widget schlussendlich abgefüllt, muss entweder mind so lang sein wie anzColorsOnPage2 oder length=0

  var listIconsNumbers = [];

  var listWithStroopText =
      []; //Array in dem alle 7 Farben, die auch als Backgroundcolor ausgewählt werden können, als ausgeschriebener Text drin sind damit nachher aus ihnen Icons generiert werden können
  var listWithStroopTextcolors =
      []; //Array in dem alle 7 Farben, die auch als Backgroundcolor ausgewählt werden können, als Zahlcode drin sind. Die Stroop-Icons werden nachher random mit diesen Farben eingefärbt
  //-> Falls für Stroop auch der Hintergrund farbig sein soll, können ganz normal im Menu Farben bei "Hintergrundfarbe Icons" gewählt werden

  int anzColorsOnPage2 = 1;
  int secChangeColor2 = 1;
  int secLengthRound2 = 1;
  int secLengthRest2 = 1;
  int anzRounds2 = 1;

  Random random = Random();
  late Timer _timer;
  int anzRoundsDone = 1;
  int secsLengthRoundCD = 1;
  int minsLengthRoundCD = 1;
  int secsLengthRestCD = 1;
  int minsLengthRestCD = 1;
  bool isRest = false;
  var colorRestText = 0xffffffff;
  var restText = '';
  var paddingTopRestText = 0.0;
  var fontsizeRestText = 0.0;

  double sizeIcon = 0;
  double sizeIconStroop = 0;

  String rundeSg = 'rundeSg'.tr;
  String rundePl = 'rundePl'.tr;

  int currentSecsCD = 0;
  int currentMinsCD = 0;

  double footerPercentage = 0.05;
  double bodyPercentage =
      0.95; //1-footerPercentage-> dieser Platz muss aufgeteilt werden um Farben anzuzeigen
  double thicknessVerticalDividerFooter = 0.5;

  int lastRoundFirstColor =
      0; //hält erste farbe der letzten runde fest damit nicht nach change genau gleiche anordnung ist und es so aussieht als würde das programm stocken
  String lastRoundFirstArrowDirection =
      ''; //hält erstes icon der letzten runde fest damit nicht nach change genau gleiche anordnung ist und es so aussieht als würde das programm stocken

  //new 1.12.24
  bool isElemProSeiteEinmalig2 = false;
  int firstHexLastRound = 0;
  var firstItemLastRound;
  var listToFillContainersIconDuplicate = [];
  var listToFillContainersHexDuplicate = [];

  //Stroop, 4.5.26
  bool isStroopActive2 = false;

  @override
  void initState() {
    _initializeSettinvariables();
    _initializeListHeight4Containers();
    _initializeListWithAllHex();
    _initializeListSelectedArrows();
    init_new();
    initOptionEinmalig();
    //organizeRound();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(() {
        //timemanagement();
        timemanagement_new();
      }),
    );

    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      //todo updaten
      onWillPop: (() async =>
          false), //damit swipe back(ios) bzw. Back Button (android) deaktiviert
      child: Scaffold(
        backgroundColor: const Color(0xff000000),
        body: Column(
          children: [
            Container(
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[0]), //noch ersetzen mit 1/"wie viele farben aufs mal anzeigen"
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color:
                    //wenn Icon in Container und Backgroundcolors selektiert
                    //dann Backgroundcolor wählen
                    //sonst wenn kein Icon-> normale Farbe nehmen, wenn keine Backgroundcolor selektiert-> fefefe als Hintergrund nehmen
                    (listToFillContainersHex[0] == int.parse('0xfffefefe')) &&
                        (listWithSelectedBackgroundcolorsToFill.length >= 1)
                    ? Color(listWithSelectedBackgroundcolorsToFill[0])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
              child: FittedBox(
                //FittedBox führt dazu, dass sich die Grösse der Icons dem vorhandenen Platz im parent anpasst
                fit: BoxFit.contain,
                child: restText == ''
                    ? listToFillContainersIcon[0]
                    : Align(
                        alignment: Alignment.center,
                        //Die Anzeige "Pause" wird im ersten Container gemacht
                        child: Text(
                          restText,
                          style: TextStyle(
                            color: Color(colorRestText),
                            fontSize: fontsizeRestText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 1
                    ? listToFillContainersIcon[1]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[1]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                //wenn Icon in Container und Backgroundcolors selektiert
                //dann Backgroundcolor wählen
                //sonst wenn kein Icon-> normale Farbe nehmen, wenn keine Backgroundcolor selektiert-> fefefe als Hintergrund nehmen
                color: listToFillContainersHex.length > 1
                    ? (listToFillContainersHex[1] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  1)
                          ? Color(listWithSelectedBackgroundcolorsToFill[1])
                          : Color(listToFillContainersHex[1])
                    : Color(listToFillContainersHex[0]), //fallback
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 2
                    ? listToFillContainersIcon[2]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[2]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                //wenn Icon in Container und Backgroundcolors selektiert
                //dann Backgroundcolor wählen
                //sonst wenn kein Icon-> normale Farbe nehmen, wenn keine Backgroundcolor selektiert-> fefefe als Hintergrund nehmen
                color: listToFillContainersHex.length > 2
                    ? (listToFillContainersHex[2] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  2)
                          ? Color(listWithSelectedBackgroundcolorsToFill[2])
                          : Color(listToFillContainersHex[2])
                    : Color(listToFillContainersHex[0]), //fallback
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 3
                    ? listToFillContainersIcon[3]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[3]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 3
                    ? (listToFillContainersHex[3] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  3)
                          ? Color(listWithSelectedBackgroundcolorsToFill[3])
                          : Color(listToFillContainersHex[3])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 4
                    ? listToFillContainersIcon[4]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[4]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 4
                    ? (listToFillContainersHex[4] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  4)
                          ? Color(listWithSelectedBackgroundcolorsToFill[4])
                          : Color(listToFillContainersHex[4])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 5
                    ? listToFillContainersIcon[5]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[5]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 5
                    ? (listToFillContainersHex[5] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  5)
                          ? Color(listWithSelectedBackgroundcolorsToFill[5])
                          : Color(listToFillContainersHex[5])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 6
                    ? listToFillContainersIcon[6]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[6]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 6
                    ? (listToFillContainersHex[6] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  6)
                          ? Color(listWithSelectedBackgroundcolorsToFill[6])
                          : Color(listToFillContainersHex[6])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 7
                    ? listToFillContainersIcon[7]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[7]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 7
                    ? (listToFillContainersHex[7] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  7)
                          ? Color(listWithSelectedBackgroundcolorsToFill[7])
                          : Color(listToFillContainersHex[7])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 8
                    ? listToFillContainersIcon[8]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[8]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 8
                    ? (listToFillContainersHex[8] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  8)
                          ? Color(listWithSelectedBackgroundcolorsToFill[8])
                          : Color(listToFillContainersHex[8])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 9
                    ? listToFillContainersIcon[9]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[9]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 9
                    ? (listToFillContainersHex[9] == int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  9)
                          ? Color(listWithSelectedBackgroundcolorsToFill[9])
                          : Color(listToFillContainersHex[9])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 10
                    ? listToFillContainersIcon[10]
                    : listToFillContainersIcon[0],
              ),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[10]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: listToFillContainersHex.length > 10
                    ? (listToFillContainersHex[10] ==
                                  int.parse('0xfffefefe')) &&
                              (listWithSelectedBackgroundcolorsToFill.length >
                                  10)
                          ? Color(listWithSelectedBackgroundcolorsToFill[10])
                          : Color(listToFillContainersHex[10])
                    : Color(listToFillContainersHex[0]),
                border: const Border(bottom: BorderSide(color: Colors.black)),
              ),
            ),
            Container(
              child: FittedBox(
                fit: BoxFit.contain,
                child: listToFillContainersIcon.length > 11
                    ? listToFillContainersIcon[11]
                    : listToFillContainersIcon[0],
              ),
              color: listToFillContainersHex.length > 11
                  ? (listToFillContainersHex[11] == int.parse('0xfffefefe')) &&
                            (listWithSelectedBackgroundcolorsToFill.length > 11)
                        ? Color(listWithSelectedBackgroundcolorsToFill[11])
                        : Color(listToFillContainersHex[11])
                  : Color(listToFillContainersHex[0]),
              height:
                  MediaQuery.of(context).size.height *
                  (listHeight4Container[11]),
              width: MediaQuery.of(context).size.width,
              padding: const EdgeInsets.all(10.0),
            ),

            //footer
            Container(
              height: MediaQuery.of(context).size.height * (footerPercentage),
              width: MediaQuery.of(context).size.width,
              color: Colors.grey.shade700,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        anzRoundsDone.toString() +
                            '/' +
                            anzRounds2.toString() +
                            ' ' +
                            getRundeSgPl(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    width:
                        (MediaQuery.of(context).size.width -
                            thicknessVerticalDividerFooter) /
                        4,
                  ),
                  SizedBox(
                    child: Center(
                      child: Text(
                        currentMinsCD.toString().padLeft(2, '0') +
                            ':' +
                            currentSecsCD.toString().padLeft(2, '0'),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    width:
                        (MediaQuery.of(context).size.width -
                            thicknessVerticalDividerFooter) /
                        4,
                  ),
                  const VerticalDivider(
                    color: Colors.black,
                    thickness: 0.5,
                    width: 0.5,
                  ),
                  SizedBox(
                    child: TextButton(
                      child: Text(
                        'hauptmenü'.tr,
                        style: const TextStyle(color: Colors.black),
                      ),
                      autofocus: false,
                      onPressed: changeToPage1,
                      onLongPress: changeToPage1,
                    ),
                    width:
                        (MediaQuery.of(context).size.width -
                            thicknessVerticalDividerFooter) /
                        4,
                  ),
                  SizedBox(
                    child: TextButton(
                      child: Text(
                        'neustart'.tr,
                        style: const TextStyle(color: Colors.black),
                      ),
                      autofocus: false,
                      onPressed: neustart,
                      onLongPress: neustart,
                    ),
                    width:
                        (MediaQuery.of(context).size.width -
                            thicknessVerticalDividerFooter) /
                        4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Initialisiert die Settingvariablen in Page2 mit den korrekten Werten aus Page1, da diese nicht direkt als lokale Variable gebraucht werden können
  void _initializeSettinvariables() {
    anzColorsOnPage2 = widget.anzColorsOnPage;
    secChangeColor2 = widget.secChangeColor;
    secLengthRound2 = widget.secLengthRound;
    secLengthRest2 = widget.secLengthRest;
    anzRounds2 = widget.anzRounds;

    minsLengthRoundCD = secLengthRound2 ~/ 60;
    secsLengthRoundCD = secLengthRound2 % 60;
    minsLengthRestCD = secLengthRest2 ~/ 60;
    secsLengthRestCD = secLengthRest2 % 60;

    isElemProSeiteEinmalig2 = widget.isElemProSeiteEinmalig;

    isStroopActive2 = widget.isStroopActive;
  }

  //füllt listWithSelectedColors ab aus widget.
  void _initializeListSelectedColors() {
    listWithSelectedColors = widget.listSelectedColors;
  }

  void _initializeListSelectedArrows() {
    listWithSelectedArrowsPerColor = widget.listSelectedArrowsPerColor;
    _initializeListSelectedNumbers();
    _initializeListSelectedShapes();
    _initializeListSelectedAlphabetletters();
    _initializeStroop();
    _initializeListSelectedIcons();
    _initializeListSelectedBackgroundcolors();
  }

  void _initializeListSelectedNumbers() {
    listWithSelectedNumbers = widget.listSelectedNumbers;
    _initializeIconsNumbers();
  }

  //Array abfüllen in dem alle Zahlen als Icons von 0-50 drin erfasst sind
  void _initializeIconsNumbers() {
    var sizeIcon = 60.0; //grundsätzlich alle icons grösse 60
    //bei nur 1-4 anzeigen aufs mal sollten die icons aber ein wenig grösser sein, damit sie besser erkennbar sind im training
    if (anzColorsOnPage2 == 4) {
      sizeIcon = 90.0;
    } else if (anzColorsOnPage2 == 3) {
      sizeIcon = 110.0;
    } else if (anzColorsOnPage2 == 2) {
      sizeIcon = 160.0;
    } else if (anzColorsOnPage2 == 1) {
      sizeIcon = 200.0;
    }
    listIconsNumbers.add(
      Icon(NumberIcons.nr_0, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_1, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_2, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_3, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_4, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_5, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_6, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_7, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_8, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_9, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_10, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_11, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_12, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_13, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_14, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_15, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_16, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_17, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_18, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_19, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_20, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_21, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_22, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_23, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_24, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_25, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_26, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_27, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_28, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_29, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_30, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_31, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_32, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_33, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_34, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_35, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_36, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_37, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_38, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_39, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_40, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_41, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_42, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_43, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_44, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_45, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_46, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_47, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_48, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_49, color: Colors.black, size: sizeIcon - 10),
    );
    listIconsNumbers.add(
      Icon(NumberIcons.nr_50, color: Colors.black, size: sizeIcon - 10),
    );
  }

  void _initializeListSelectedShapes() {
    listWithSelectedShapes = widget.listSelectedShapes;
  }

  void _initializeListSelectedAlphabetletters() {
    listWithSelectedAlphabetletters = widget.listSelectedAlphabetletters;
  }

  void _initializeListSelectedIcons() {
    listWithSelectedIcons =
        listWithSelectedArrowsPerColor +
        listWithSelectedNumbers +
        listWithSelectedShapes +
        listWithSelectedAlphabetletters +
        listWithStroopText;
  }

  void _initializeListSelectedBackgroundcolors() {
    listWithSelectedBackgroundcolors = widget.listSelectedBackgroundcolors;
  }

  void _initializeStroop() {
    listWithStroopText = widget.listStroopText;
    listWithStroopTextcolors = widget.listStroopTextcolors;
  }

  /// füllt listWithSelectedHex mit Hexcodes aus listWithSelectedColors ab
  void _initializeListWithAllHex() {
    listWithSelectedHex.clear();
    _initializeListSelectedColors();
    String hexxcode = '0xff';
    int theHexCode = 0;

    for (String item in listWithSelectedColors) {
      hexxcode =
          '0xff' +
          item; //safr background: hier wird die hintergrundfarbe gesetzt
      theHexCode = (int.parse(hexxcode));
      listWithSelectedHex.add(theHexCode);
    }
  }

  /// initialisiert listHeight4Containers
  /// beinhaltet den Wert, der für die Höhe jedes Containers gebraucht wird
  /// Sollte in diesem Schema eingesetzt werden können height: MediaQuery.of(context).size.height*(listHeight4Containers[0])
  ///
  void _initializeListHeight4Containers() {
    listHeight4Container.clear();
    for (int i = 0; i < 12; i++) {
      if (i < anzColorsOnPage2) {
        listHeight4Container.add(bodyPercentage / anzColorsOnPage2);
      } else {
        listHeight4Container.add(0);
      }
    }
  }

  /// diese methode muss bei einem restart zusätzlich zu den anderen 3 _initialize..-Methoden aufgerufen werden
  /// bringt alle variabeln, die sonst von anfang an schon korrekt initialisiert sind, wieder in ihren anfangszustand
  void _initializeResetVariables() {
    anzRoundsDone = 1;
    isRest = false;
    currentSecsCD = 0;
    currentMinsCD = 0;
  }

  bool isNumeric(String string_value) {
    try {
      int.parse(string_value!);
    } catch (e) {
      return false;
    }
    return true;
  }

  int getColorcodeByArrowPerColor(arrowdirection_arrowcolor) {
    //parameter wird nach diesem format übergeben: arrowdirection_arrowcolor
    //returnt wird arrowcolor
    return int.parse(
      arrowdirection_arrowcolor.substring(
        arrowdirection_arrowcolor.indexOf('_') + 1,
        arrowdirection_arrowcolor.length,
      ),
    );
  }

  /// füllt listToFillContainersIcon mit korrektem icon und farbe inkl ob arrow sichtbar ist oder selbe farbe hat wie hintergrund
  void addToListToFillContainersIcon(index, arrowDirection, arrowVisible) {
    if (index >= listToFillContainersIcon.length) {
      listToFillContainersIcon.add(Icon(Icons.north));
    }

    //4 = 90
    //3 = 110
    //2 = 120
    //1 = 150
    sizeIcon = 60.0; //grundsätzlich alle icons grösse 60
    sizeIconStroop = 70.00;

    if (arrowVisible) {
      //bei nur 1-4 anzeigen aufs mal sollten die icons aber ein wenig grösser sein, damit sie besser erkennbar sind im training
      if (anzColorsOnPage2 == 4) {
        sizeIcon = 90.0;
        sizeIconStroop = 100;
      } else if (anzColorsOnPage2 == 3) {
        sizeIcon = 110.0;
        sizeIconStroop = 90;
      } else if (anzColorsOnPage2 == 2) {
        sizeIcon = 160.0;
        sizeIconStroop = 90;
      } else if (anzColorsOnPage2 == 1) {
        sizeIcon = 200.0;
        sizeIconStroop = 100;
      }

      //idee safr 24.10.24: listSelectedNumbers werdden als zahl in string von menupage übergeben zb '1' oder '23'
      //in ein array wird das icon initialisiert Icon(Icons.north, color: Colors.black, size: sizeIcon);, damit das ganze ausgelagert werden kann und nicht alles
      //  hier in dieser funktion ist
      //hier check if isnumeric(arrowDirection) dann mit index aus array auslesen-> braucht nicht 50 if-statements
      if (isNumeric(arrowDirection)) {
        listToFillContainersIcon[index] =
            listIconsNumbers[int.parse(arrowDirection)];
      } else if (arrowDirection.contains('northeast_')) {
        //arrows werden im format direction_arrowcolor übergeben
        listToFillContainersIcon[index] = Icon(
          Icons.north_east,
          color: Color(
            getColorcodeByArrowPerColor(arrowDirection),
          ), //arrowcolor auslesen
          size: sizeIcon,
        );
      } else if (arrowDirection.contains('northwest_')) {
        listToFillContainersIcon[index] = Icon(
          Icons.north_west,
          color: Color(getColorcodeByArrowPerColor(arrowDirection)),
          size: sizeIcon,
        );
      } else if (arrowDirection.contains('southeast_')) {
        listToFillContainersIcon[index] = Icon(
          Icons.south_east,
          color: Color(getColorcodeByArrowPerColor(arrowDirection)),
          size: sizeIcon,
        );
      } else if (arrowDirection.contains('southwest_')) {
        listToFillContainersIcon[index] = Icon(
          Icons.south_west,
          color: Color(getColorcodeByArrowPerColor(arrowDirection)),
          size: sizeIcon - 10,
        );
      } else if (arrowDirection.contains('north_')) {
        listToFillContainersIcon[index] = Icon(
          Icons.north,
          color: Color(getColorcodeByArrowPerColor(arrowDirection)),
          size: sizeIcon,
        );
      } else if (arrowDirection.contains('east_')) {
        listToFillContainersIcon[index] = Icon(
          Icons.east,
          color: Color(getColorcodeByArrowPerColor(arrowDirection)),
          size: sizeIcon,
        );
      } else if (arrowDirection.contains('south_')) {
        listToFillContainersIcon[index] = Icon(
          Icons.south,
          color: Color(getColorcodeByArrowPerColor(arrowDirection)),
          size: sizeIcon,
        );
      } else if (arrowDirection.contains('west_')) {
        listToFillContainersIcon[index] = Icon(
          Icons.west,
          color: Color(getColorcodeByArrowPerColor(arrowDirection)),
          size: sizeIcon,
        );
      } else if (arrowDirection == 'triangle') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.triangle,
          color: Colors.black,
          size: sizeIcon,
        );
      } else if (arrowDirection == 'kreis') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.circle,
          color: Colors.black,
          size: sizeIcon,
        );
      } else if (arrowDirection == 'quadrat') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.square,
          color: Colors.black,
          size: sizeIcon,
        );
      } else if (arrowDirection == 'letterA') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.a,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterB') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.b,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterC') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.c,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterD') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.d,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterE') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.e,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterF') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.f,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterG') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.g,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterH') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.h,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterI') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.i,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterJ') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.j,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterK') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.k,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterL') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.l,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterM') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.m,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterN') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.n,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterO') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.o,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterP') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.p,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterQ') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.q,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterR') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.r,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterS') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.s,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterT') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.t,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterU') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.u,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterV') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.v,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterW') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.w,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterX') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.x,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterY') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.y,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'letterZ') {
        listToFillContainersIcon[index] = Icon(
          CustomIcons.z,
          color: Colors.black,
          size: sizeIcon - 10,
        );
      } else if (arrowDirection == 'stroop_weiss') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons.stroop_weiss,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
          ),
          width: 90,
          height: 24,
          //size: sizeIconStroop,
        );
      } else if (arrowDirection == 'stroop_schwarz') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons.stroop_schwarz,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop - 30,
          ),
          width: 135,
          height: 24,
        );
      } else if (arrowDirection == 'stroop_gelb') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons.stroop_gelb,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
          ),
          height: 24,
          width: 70,
          //size: sizeIconStroop,
        );
      } else if (arrowDirection == 'stroop_rot') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons.stroop_rot,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 60,
        );
      } else if (arrowDirection == 'stroop_violett') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons.stroop_violett,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop - 10,
          ),
          height: 24,
          width: 100,
        );
      } else if (arrowDirection == 'stroop_blau') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons.stroop_blau,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 70,
        );
      } else if (arrowDirection == 'stroop_gruen') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons.stroop_gruen,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 75,
        );
      } else if (arrowDirection == 'stroop_white') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons_English.stroop_white,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 90,
        );
      } else if (arrowDirection == 'stroop_black') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons_English.stroop_black,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 85,
        );
      } else if (arrowDirection == 'stroop_yellow') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons_English.stroop_yellow,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop - 10,
          ),
          height: 24,
          width: 105,
        );
      } else if (arrowDirection == 'stroop_red') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons_English.stroop_red,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 60,
        );
      } else if (arrowDirection == 'stroop_violet') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons_English.stroop_violet,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop - 5,
          ),
          height: 24,
          width: 90,
        );
      } else if (arrowDirection == 'stroop_blue') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons_English.stroop_blue,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 70,
        );
      } else if (arrowDirection == 'stroop_green') {
        listToFillContainersIcon[index] = SizedBox(
          child: Icon(
            StroopIcons_English.stroop_green,
            color: Color(
              listWithStroopTextcolors[random.nextInt(
                listWithStroopTextcolors.length,
              )],
            ),
            //size: sizeIconStroop,
          ),
          height: 24,
          width: 95,
        );
      }
    } else {
      //arrow should not be visible
      listToFillContainersIcon[index] = Icon(
        Icons.north,
        color: Color(listToFillContainersHex[index]),
      );
    }
  }

  /// AlertDialog das bei Ende von Übung erscheint
  Widget alertDialogFinish() {
    anzRoundsDone--;
    return AlertDialog(
      //ähnlich wie modalWindow
      content: Text('trainingEnde'.tr),
      actions: [
        TextButton(
          onPressed: changeToPage1,
          child: Text(
            'hauptmenü'.tr,
            style: const TextStyle(color: Color.fromARGB(177, 0, 0, 0)),
          ),
        ),
        TextButton(
          onPressed: changeToPage2,
          child: Text(
            'neustart'.tr,
            style: const TextStyle(color: Color.fromARGB(177, 0, 0, 0)),
          ),
        ),
      ],
    );
  }

  /// Damit Anzeige in Fusszeile korrekt mit 1 Runde bzw >1 Runden
  String getRundeSgPl() {
    if (anzRounds2 == 1) {
      return rundeSg;
    } else {
      return rundePl;
    }
  }

  /// Methode, die alle Variablen etc wieder in den anfangszustand bringt, damit page2 nochmals von null aus abgespielt werden kann
  /// timer wird absichtlich nicht verändert da nicht nötig
  /// wird nur für Neustart aus Footer benutzt, an Ende von Training wird changeToPage2 benutzt
  /// todo safr 12.1.25 beide neustarts über gleiche funktion laufen lassen
  void neustart() {
    _initializeSettinvariables();
    _initializeListHeight4Containers();
    _initializeListWithAllHex();
    _initializeListSelectedArrows();
    _initializeResetVariables();
    init_new();
    initOptionEinmalig();
  }

  /// Wechsel von page2 to page1
  void changeToPage1() {
    _timer.cancel();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: 'Skillatics',
          currentCountry: widget.currentCountry,
          listSelectedColors: widget.listSelectedColors,
          listSelectedArrowsPerColor: widget.listSelectedArrowsPerColor,
          listSelectedNumbers: widget.listSelectedNumbers,
          listSelectedShapes: widget.listSelectedShapes,
          listSelectedAlphabetletters: widget.listSelectedAlphabetletters,
          listSelectedBackgroundcolors: widget.listSelectedBackgroundcolors,
          anzColorsOnPage: widget.anzColorsOnPage,
          secChangeColor: widget.secChangeColor,
          secLengthRound: widget.secLengthRound,
          secLengthRest: widget.secLengthRest,
          anzRounds: widget.anzRounds,
          isElemProSeiteEinmalig: widget.isElemProSeiteEinmalig,
          isStroopActive: widget.isStroopActive,
          nr_individual: widget.nr_individual,
          nr_from: widget.nr_from,
          nr_to: widget.nr_to,
          nr_skip: widget.nr_skip,
        ),
      ),
    );
  }

  /// neustart der page2
  /// wird nach alertDialogFinish aufgerufen weil neustart() nicht funktioniert
  void changeToPage2() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RandomColorPage2(
          listSelectedColors: listWithSelectedColors,
          listSelectedArrowsPerColor: listWithSelectedArrowsPerColor,
          listSelectedNumbers: listWithSelectedNumbers,
          listSelectedShapes: listWithSelectedShapes,
          listSelectedAlphabetletters: listWithSelectedAlphabetletters,
          listSelectedBackgroundcolors: listWithSelectedBackgroundcolors,
          anzColorsOnPage: anzColorsOnPage2,
          secChangeColor: secChangeColor2,
          secLengthRound: secLengthRound2,
          secLengthRest: secLengthRest2,
          anzRounds: anzRounds2,
          currentCountry: widget.currentCountry,
          isElemProSeiteEinmalig: isElemProSeiteEinmalig2,
          isStroopActive: isStroopActive2,
          listStroopText: listWithStroopText,
          listStroopTextcolors: listWithStroopTextcolors,
          nr_individual: widget.nr_individual,
          nr_from: widget.nr_from,
          nr_to: widget.nr_to,
          nr_skip: widget.nr_skip,
        ),
      ),
    );
  }

  /* NEW FROM 01.12.24 SARAH FRISCHKNECHT */

  void init_new() {
    isRest = false;
    currentSecsCD = secsLengthRoundCD;
    currentMinsCD = minsLengthRoundCD;

    restText = ''; //damit pfeil gute Position hat
    paddingTopRestText = 0.0; //damit pfeil gute Position hat
    fontsizeRestText = 0.0; //damit pfeil gute Position hat

    listToFillContainersHex.clear();
    listToFillContainersIcon.clear();

    //damit erste Anzeige nicht gleiche Reihenfolge hat wie auf Menupage ausgewählt
    listWithSelectedHex.shuffle();
    listWithSelectedIcons.shuffle();

    //hex-werte von menupage in list schreiben
    for (int ll_i = 0; ll_i < listWithSelectedHex.length; ll_i++) {
      listToFillContainersHex.add(listWithSelectedHex[ll_i]);
    }

    changeRound(true);
  }

  //wird all sekunde von timemanagement aufgerufen
  //return 0 = no action required oder programm fertig, 1 = action required round, 2 = action required rest, 3 = action required round but just changed rest to round
  //hier wird ua. variabel isRest umgestellt / neu gesetzt
  int isActionRequiredItems() {
    //00:01
    if (currentSecsCD == 1 && currentMinsCD == 0) {
      //programm ganz fertig
      if (anzRounds2 == anzRoundsDone && isRest) {
        anzRoundsDone++;
        return 0;
      }

      //oder wechsel von round zu rest oder von rest zu round
      if (isRest) {
        isRest = false;
        anzRoundsDone++;
        return 3;
      } else {
        isRest = true;
        return 2;
      }
    }

    switch (isRest) {
      case false:
        if ((secLengthRound2 - (currentMinsCD * 60 + currentSecsCD - 1)) %
                secChangeColor2 ==
            0) {
          return 1;
        }
      case true:
        return 0;
    }
    return 0; //default
  }

  //sorgt dafür dass die anzeige runde? und zeit im unteren balken korrekt ist
  //wenn programm fertig dann in dieser funktion messagebox aufrufen
  void timerOrganizeVariables() {
    if (currentSecsCD > 1) {
      currentSecsCD--;
    } else {
      //-> currentSecsCD =0 || =1
      switch (currentSecsCD) {
        case 0:
          if (currentMinsCD > 0) {
            currentMinsCD--;
            currentSecsCD = 59;
          } else {
            //sollte eigentlich nicht vorkommen
            //programm beenden / messagebox zeigen
            _timer.cancel();
            showDialog(
              context: context,
              builder: (_) => alertDialogFinish(),
              barrierDismissible: false,
            );
            //Navigator.push(context, MaterialPageRoute(builder: (context) => alertDialog()));
          }

        case 1:
          if (currentMinsCD == 0) {
            currentSecsCD--;

            if (anzRoundsDone > anzRounds2) {
              //programm beenden / messagebox zeigen
              _timer.cancel();
              showDialog(
                context: context,
                builder: (_) => alertDialogFinish(),
                barrierDismissible: false,
              );
              //Navigator.push(context, MaterialPageRoute(builder: (context) => alertDialog()));
            } else if (isRest) {
              //zeit neu setzen für wechsel auf rest
              currentMinsCD = minsLengthRestCD;
              currentSecsCD = secsLengthRestCD;
            } else {
              //variabeln neu setzen für wechsel auf round
              _initializeListHeight4Containers(); //damit nach rest wieder alle Grössen der Container stimmen
              init_new();
              initOptionEinmalig();
            }
          } else {
            currentSecsCD--;
          }
      }
    }
  }

  void changeRound(bool isInitRound) {
    if (!isInitRound) {
      //verhindern dass über seitenwechsel identischen kombinationen vorkommen und es aussieht als würde die app stillstehen
      firstHexLastRound = listToFillContainersHex[0];
      firstItemLastRound = listWithSelectedIcons.length > 1
          ? listWithSelectedIcons[0]
          : listWithSelectedIcons.length == 1 &&
                firstHexLastRound == int.parse('0xfffefefe')
          ? listWithSelectedIcons[0]
          : ''; //abfangen wenn nur color-items ausgewählt
      //safr hier stroop zu listwithselectedicons hinzufügen?
      //endlosloop in do-while verhindern wenn nur 1 icon/farbe ausgewählt
      if (isElemProSeiteEinmalig2 && listToFillContainersHex.length > 1 ||
          !isElemProSeiteEinmalig2 && listToFillContainersHex.length > 2) {
        //verhindern dass gleiches element in erstem container ist wie in seite zuvor damit keine identischen kombinationen nacheinander vorkommen
        do {
          listToFillContainersHex.shuffle();
          listWithSelectedIcons.shuffle();
        } while (listToFillContainersHex[0] != int.parse('0xfffefefe') &&
                listToFillContainersHex[0] == firstHexLastRound ||
            listToFillContainersHex[0] == int.parse('0xfffefefe') &&
                (listWithSelectedIcons.length > 0
                        ? listWithSelectedIcons[0]
                        : '') ==
                    firstItemLastRound);
      }
    }

    //verhindern dass gleiche farbe nacheinander kommt
    int temp;
    for (int i = 0; i < listToFillContainersHex.length - 1; i++) {
      if (listToFillContainersHex[i] == int.parse('0xfffefefe')) {
        //safr background kann hier nocch auf fefefe gegangen werden?
        //betrifft nur farb-elemente
        continue;
      }
      if (listToFillContainersHex[i] == listToFillContainersHex[i + 1]) {
        for (int j = i + 2; j < listToFillContainersHex.length; j++) {
          if (listToFillContainersHex[i] != listToFillContainersHex[j]) {
            temp = listToFillContainersHex[i + 1];
            listToFillContainersHex[i + 1] = listToFillContainersHex[j];
            listToFillContainersHex[j] = temp;
            break;
          }
        }
      }
    }

    //Backgroundcolor der Icons setzen
    if (listWithSelectedBackgroundcolors.length > 0) {
      prepareBackgroundcolors();
    }

    //wegen diesem loop muss listToFillContainersHex/Icon nicht mehr von anfang an deckungsgleich sein, sondern wird hier deckungsgleich gemacht
    //	für jeden eintrag in listToFillContainersHex der ohne icon dargestellt wird sprich nur farbe, wird icon.north in der entsprechenden farbe hinzugefügt
    //		-> bestehendes icon in listToFillContainersIcon[x] wird nicht umgefärbt weil so nun isElemProSeiteEinmalig = true gehandelt werden kann, mit umfärben wäre einmaligkeit nicht gewährleistet

    //icons werden nach jedem seitenwechsel neu gesetzt
    var counter_icons = 0;
    String arrowDirection;

    for (var ll_i = 0; ll_i < listToFillContainersHex.length; ll_i++) {
      if (listToFillContainersHex[ll_i] != int.parse('0xfffefefe')) {
        //safr background kann hier noch auf fefefe gegangen werden?
        //arrow not visible
        addToListToFillContainersIcon(ll_i, null, false);
      } else {
        //arrow visible

        //arrowDirection holen
        if (ll_i == 0) {
          //für ersten container zwingend index 0 nehmen
          arrowDirection = listWithSelectedIcons[0];
        } else {
          if (isElemProSeiteEinmalig2) {
            //wenn element einmalig pro seite dann geordnete reihenfolge von listWithSelectedIcons nehmen via counter_icons
            arrowDirection = listWithSelectedIcons[counter_icons];
          } else {
            //wenn nicht einmalig pro seite dann random nehmen damit auch möglich dass gleiche icons nacheinander kommen
            random = Random();
            arrowDirection =
                listWithSelectedIcons[random.nextInt(
                  listWithSelectedIcons.length,
                )];
          }
        }

        addToListToFillContainersIcon(ll_i, arrowDirection, true);

        //counter_icons ausserhalb von if setzen weil bei ll_i==0 unklar ob counter_icons grösser werden muss oder nicht
        counter_icons < listWithSelectedIcons.length - 1
            ? counter_icons++
            : counter_icons = 0;
      }
    }
  }

  // wird nur bei wechsel von round zu rest aufgerufen
  void changeRest() {
    currentSecsCD = secsLengthRestCD + 1;
    currentMinsCD = minsLengthRestCD;
    for (var i = 0; i < anzColorsOnPage2; i++) {
      listToFillContainersHex[i] = 0xff000000;
      listHeight4Container[i] = 0; //damit Rest angezeigt werden kann
    }
    listHeight4Container[0] =
        bodyPercentage; //damit Rest angezeigt werden kann-> 1. container nimmt 100% ein
    colorRestText = 0xffffffff;
    restText = 'pause'.tr;
    paddingTopRestText = MediaQuery.of(context).size.height / 3;
    fontsizeRestText = 80.0;
    for (int i = 0; i < listToFillContainersHex.length; i++) {
      //damit alle pfeile schwarz und somit nicht sichtbar in pause
      listToFillContainersIcon[i] = const Icon(
        Icons.north,
        color: Colors.black,
      );
    }
  }

  //wird jede sekunde durch timer aufgerufen
  void timemanagement_new() {
    switch (isActionRequiredItems()) {
      case 1:
        //action required, round
        changeRound(false);
      case 2:
        //action required, rest
        changeRest();
      case 3:
        //action required, round, just changed from rest to round
        changeRound(true);
      case 0:
      //no action required oder programm fertig
    }

    timerOrganizeVariables();
  }

  void initOptionEinmalig() {
    // per default ist jedes selektierte element einmal in listToFillContainersIcon bzw. jede selektierte farbe/für jedes selektierte icon ist ein hex-code
    //		in listToFillContainersHex gespeichert. somit kann isElemProSeiteEinmalig = true gewährleistet werden
    //		Wenn isElemProSeiteEinmalig = false ist soll weiterhin die möglichkeit bestehen dass ein element auch mehrmals pro seite vorkommen kann
    // VORAUSSETZUNG ALLG ist: das aaray listToFillContainersHex/Icon muss mindestens eine length() von anzColorsOnPage2 haben, damit das aaray sauber ausgelesen werden kann und kein nullpointer-error entsteht
    //			wenn isElemProSeiteEinmalig = true soll listToFillContainersIcon nur mit den effektiv ausgewählten icons übergeben werden ohne duplikate (damit shuffle durchgeführt werden darf)
    //			wenn isElemProSeiteEinmalig = false soll listToFillContainersIcon mit mind. so vielen icons gefüllt werden wie anzColorsOnPage2 damit mehrere gleiche pro seite mölglich-> genaue ausführung siehe anschliessend mit variabel "vergroessern"

    if (isElemProSeiteEinmalig2 == false) {
      int vergroessern = 2;
      int temp = 0;
      temp = (anzColorsOnPage2 / listToFillContainersHex.length)
          .ceil(); //ceil = nächst grössere ganzzahl wenn kommazahl gibt
      if (temp > 2) {
        vergroessern =
            temp +
            1; //+1 für spezialfall wenn genau 0.5 so viele farben wie anzColorsOnPage2 ausgewählt sind kann es vorkommen dass in den letzten beiden rows die gleiche farbe angezeigt wird, weil nur noch diese 2 zur verfügung stehen
      }
      listToFillContainersIconDuplicate = listToFillContainersIcon;
      listToFillContainersHexDuplicate = listToFillContainersHex;

      for (int ll_count = 1; ll_count < vergroessern; ll_count++) {
        listToFillContainersIcon = [
          ...listToFillContainersIcon,
          ...listToFillContainersIconDuplicate,
        ];
        listToFillContainersHex = [
          ...listToFillContainersHex,
          ...listToFillContainersHexDuplicate,
        ];
      }
    }
  }

  void prepareBackgroundcolors() {
    //listWithSelectedBackgroundcolors: original-Array
    //listWithSelectedBackgroundcolorsToFill: muss entweder mind so lang sein wie anzColorsOnPage2 oder sonst ganz leer
    int lastColorBefore;
    var tempList;

    listWithSelectedBackgroundcolorsToFill = listWithSelectedBackgroundcolors;
    listWithSelectedBackgroundcolorsToFill.shuffle();

    //listWithSelectedBackgroundcolorsToFill muss mind so lang sein wie anzColorsOnPage2
    while (listWithSelectedBackgroundcolorsToFill.length < anzColorsOnPage2) {
      lastColorBefore =
          listWithSelectedBackgroundcolorsToFill[listWithSelectedBackgroundcolorsToFill
                  .length -
              1];
      tempList = listWithSelectedBackgroundcolors;

      //es soll nicht mehrmals dieselbe hintergrundfarbe nacheinander kommen
      //  hier wird auf simple art abgefangen, dass nicht die gleiche kombination von icon und backgroundcolor 2x nacheinander kommt
      //wird nur abgefangen wenn mehr als 1 backgroundcolor ausgewählt ist
      do {
        tempList.shuffle();
      } while (tempList[0] == lastColorBefore && tempList.length > 1);

      //tempList an listWithSelectedBackgroundcolorsToFill anfügen
      listWithSelectedBackgroundcolorsToFill = [
        ...listWithSelectedBackgroundcolorsToFill,
        ...tempList,
      ];
    }
  }
}
