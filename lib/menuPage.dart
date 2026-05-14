import 'dart:async'; //damit Timer gebraucht werden kann
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:get/get.dart';
import 'package:skillatics_new_1225/custom_icons_icons.dart';
import 'package:skillatics_new_1225/stroop_icons.dart';
//import 'package:rate_my_app/rate_my_app.dart';
import 'package:skillatics_new_1225/trainingPage.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:flutter/gestures.dart'; //damit Action nach Klick auf Einstellungen zurücksetzen möglich

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
    required this.currentCountry,
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
    required this.isElemProSeiteEinmalig,
    required this.isStroopActive,
    required this.nr_individual,
    required this.nr_from,
    required this.nr_to,
    required this.nr_skip,
  }) : super(key: key);

  final String title;
  String currentCountry;
  var listSelectedColors;
  var listSelectedArrowsPerColor;
  var listSelectedNumbers;
  var listSelectedShapes;
  var listSelectedAlphabetletters;
  var listSelectedBackgroundcolors;
  int anzColorsOnPage;
  int secChangeColor;
  int secLengthRound;
  int secLengthRest;
  int anzRounds;
  bool isElemProSeiteEinmalig;
  bool isStroopActive;
  String nr_individual, nr_from, nr_to, nr_skip;

  @override
  _MyHomePageState createState() => _MyHomePageState(); //ruft automatisch initState() auf
}

class _MyHomePageState extends State<MyHomePage> {
  String hexxcode = '0xff';
  int theHexCode = 0;
  String textFehlermeldung = '';
  bool isGerman = true;
  String currentCountry = "GB"; //flagge die aktuell oben rechts angezeigt wird
  String keyString = '1';
  int keyInt = 1;

  String nr_from = '';
  String nr_to = '';
  String nr_individual = '';
  String nr_skip = '';
  bool isNrOutOfRange = false;
  bool isElemProSeiteEinmalig = false;
  bool isStroopActive = false;

  //Variabeln für Einstellungen, siehe Skizze, werden an Page2 übergeben
  //werden eingentlich von main.dart übergeben, müssen hier aber einfach auch noch initialisiert werden, Werte werden aber überschrieben
  int anzColorsOnPage = 2;
  int secChangeColor = 5;
  int secLengthRound = 210; //=roundDisplayedSec+roundDisplayedMin in sekunden
  int secLengthRest = 90; //=restDisplayedSec+restDisplayedMin in sekunden
  int anzRounds = 5;

  //Werte, die in applescroll angezeigt werden aber nicht so an Page2 übergeben werden können weil Min und Sec gemischt
  int roundDisplayedSec = 30;
  int roundDisplayedMin = 3;
  int restDisplayedSec = 30;
  int restDisplayedMin = 1;

  //Checkboxen, mit allen gewünschten Farben
  //nach jedem (ab-)wählen einer farbe/zahl/etc. des users werden alle selektieren elemente in das jeweilige array gespeichert
  var selectedColors = [];
  var selectedArrows = []; //arrowdirection, nicht an trainingpage übergeben
  var selectedArrowcolors =
      []; //pfeile sollten nicht nur schwarz sondern auch in anderen farben angezeigt werden können, nicht an trainingpage übergeben
  var selectedArrowsPerColor =
      []; //wird an trainingspage übergeben mit ein item pro kombination pfeil & farbe im format arrowdirection_arrowcolor

  var selectedNumbers =
      []; //String, wird aber nicht so initialisiert weil sonst =[] nicht mehr geht und das machts unnötig kompliziert
  var selectedShapes = [];
  var selectedAlphabetletters = [];
  var selectedBackgroundcolors = [];

  //beinhaltet hex-werte von allen selected items: hex-wert der gewählten farbe oder bei zahlen/formen/etc immer hex-wert fefefe-> so wird in trainingpage erkannt dass ein icon angezeigt werden muss
  var selectedItems = [];

  //Array in dem alle 7 Farben, die auch als Backgroundcolor ausgewählt werden können, als Zahlcode drin sind. Die stroopTexticons werden in der trainingPage random mit diesen Farben eingefärbt
  var stroopTextcolor = [];
  //Array mit den 7 Farben als ausgeschriebener Text, die in der Trainingspage als Icon hinzugefügt und eingefärbt werden
  var stroopTexticons = [];

  //Controller für Multiselect Alphabetletter damit alle items aufs mal (ab-)gewählt werden können
  final MultiSelectController<dynamic> _controllerAlphabetLetter =
      MultiSelectController(deSelectPerpetualSelectedItems: true);

  //Pop-Up in dem User nach Bewertung/Rezession schreiben gefragt wird
  /* final RateMyApp rateMyApp = RateMyApp(
    minDays: 0,
    minLaunches: 0,
    remindDays: 9,
    remindLaunches: 4,
    //googlePlayIdentifier: https://www.youtube.com/watch?v=aoq5VDku2Bc
    //appStoreIdentifier: diese hat man noch nicht wenn noch nicht in store
  );*/

  /// erzeugt Emoji mit Flagge mit entsprechendem Wert currentCountry
  String countryFlag() {
    //https://stackoverflow.com/questions/56999448/display-country-flag-character-in-flutter
    int flagOffset = 0x1F1E6;
    int asciiOffset = 0x41;

    int firstChar = currentCountry.codeUnitAt(0) - asciiOffset + flagOffset;
    int secondChar = currentCountry.codeUnitAt(1) - asciiOffset + flagOffset;

    String emoji =
        String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
    return emoji;
  }

  void changeKey() {
    keyInt++;
    keyString = keyInt.toString();
  }

  //Wechsel auf Seite 2 mit den angezeigten Farben
  void _changeToPage2() {
    organizeElementsColors();
    organizeBackgroundcolor();
    organizeStroop();

    //überprüft, ob Werte gültig sind
    if (isNrOutOfRange) {
      setState(() {
        textFehlermeldung = 'fehlerNrOutOfRange'.tr;
      });
    } else if (selectedArrows.length > 0 && selectedArrowsPerColor.length < 1) {
      setState(() {
        textFehlermeldung = 'fehlerArrowsNoColor'.tr;
      });
    } else if (selectedItems.isEmpty && isStroopActive == false) {
      setState(() {
        textFehlermeldung = 'fehlerColorsNull'.tr;
      });
    } else if (isElemProSeiteEinmalig &&
        selectedItems.length + stroopTexticons.length < anzColorsOnPage) {
      setState(() {
        textFehlermeldung = 'fehlerColorsAnzElemEinmal'.tr;
      });
    } else if (selectedItems.length == 1 &&
        isStroopActive == false &&
        anzColorsOnPage > 1) {
      setState(() {
        textFehlermeldung = 'fehlerColorsAnz'.tr;
      });
    } else if (secLengthRound <= 0) {
      setState(() {
        textFehlermeldung = 'fehlerDurchgangNull'.tr;
      });
    } else if (secChangeColor > secLengthRound) {
      setState(() {
        textFehlermeldung = 'fehlerWechselDurchlauf'.tr;
      });
    } else if (secLengthRest <= 0) {
      setState(() {
        textFehlermeldung = 'fehlerPauseNull'.tr;
      });
    } else {
      //Wechsel möglich
      showDialog(context: context, builder: (_) => alertDialogCD());

      Timer(const Duration(seconds: 3), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RandomColorPage2(
              listSelectedColors: selectedItems,
              listSelectedArrowsPerColor: selectedArrowsPerColor,
              listSelectedNumbers: selectedNumbers,
              listSelectedShapes: selectedShapes,
              listSelectedAlphabetletters: selectedAlphabetletters,
              listSelectedBackgroundcolors: selectedBackgroundcolors,
              anzColorsOnPage: anzColorsOnPage,
              secChangeColor: secChangeColor,
              secLengthRound: secLengthRound,
              secLengthRest: secLengthRest,
              anzRounds: anzRounds,
              currentCountry: currentCountry,
              isElemProSeiteEinmalig: isElemProSeiteEinmalig,
              isStroopActive: isStroopActive,
              listStroopText: stroopTexticons,
              listStroopTextcolors: stroopTextcolor,
              nr_individual: nr_individual,
              nr_from: nr_from,
              nr_to: nr_to,
              nr_skip: nr_skip,
            ),
          ),
        );
      });
    }
  }

  //Kann der übergebene String in ein int geparst werden?
  bool isNumeric(String string_value) {
    try {
      int.parse(string_value);
    } catch (e) {
      return false;
    }
    return true;
  }

  //Liste mit selektierten Zahlen zusammenstellen anhand der 3 Eingabeoptionen (einzelne Zahlen,
  //  von-bis, ohne einzelne Zahlen), damit diese nachher an Trainingspage übergeben  werden kann
  bool organizeArrayNumbers() {
    var splitted_individual, splitted_skip = [];
    int nr_from_int, nr_to_int = 0;
    selectedNumbers = []; //Zahlen-Liste leeren
    isNrOutOfRange = false; //Fehlermeldung zurücksetzen

    //Zahlen von "von-bis" zur Zahlen-Liste hinzufügen
    if (isNumeric(nr_from) && isNumeric(nr_to)) {
      nr_from_int = int.parse(nr_from);
      nr_to_int = int.parse(nr_to);
      //Nur Zahlen von 0-50 erlaubt
      if (nr_to_int > 50 || nr_from_int < 0) {
        isNrOutOfRange = true;
        return false;
      }
      for (int counter = nr_from_int; counter <= nr_to_int; counter++) {
        selectedNumbers.add(counter.toString());
      }
    }

    //Einzeln notierte Zahlen zur Zahlen-Liste hinzufügen
    if (nr_individual.length > 0) {
      splitted_individual = nr_individual.split(',');
      for (int i = 0; i < splitted_individual.length; i++) {
        if (isNumeric(splitted_individual[i])) {
          //Nur Zahlen von 0-50 erlaubt
          if (int.parse(splitted_individual[i]) > 50 ||
              int.parse(splitted_individual[i]) < 0) {
            isNrOutOfRange = true;
            return false;
          }
          selectedNumbers.add(splitted_individual[i]);
        } else {
          isNrOutOfRange = true;
          return false;
        }
      }
    }

    //Zahlen aus Feld "Ohne" aus Zahlen-Liste entfernen
    if (nr_skip.length > 0) {
      splitted_skip = nr_skip.split(',');
      for (int i = 0; i < splitted_skip.length; i++) {
        if (isNumeric(splitted_skip[i])) {
          for (int j = 0; j < selectedNumbers.length; j++) {
            if (selectedNumbers[j] == splitted_skip[i]) {
              selectedNumbers.removeAt(j);
            }
          }
        }
      }
    }

    selectedNumbers = selectedNumbers.toSet().toList(); //Duplikate entfernen

    return true;
  }

  ///Füllt das Array selectedArrowsPerColor ab anhand der selektierten arrowdirections und arrowfarben im Format arrowdirection_arrowcolor
  void organizeArrowcolors() {
    selectedArrowsPerColor = [];

    for (int i = 0; i < selectedArrows.length; i++) {
      for (int j = 0; j < selectedArrowcolors.length; j++) {
        selectedArrowsPerColor.add(
          selectedArrows[i] + '_' + selectedArrowcolors[j],
        );
      }
    }
  }

  /// Initializes selectedItems[] and sets correct color for arrows in selectedcolors that there are only hex and no strings like 'north' etc
  void organizeElementsColors() {
    if (!organizeArrayNumbers()) {
      return; //Fehleingabe bei Zahlen (Out of Range)
    }
    organizeArrowcolors();

    selectedItems = []; //Array leeren
    selectedItems =
        selectedColors +
        selectedNumbers +
        selectedArrowsPerColor +
        selectedShapes +
        selectedAlphabetletters;
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i].length != 6) {
        //length 6 sind hexwerte von colors-> restliche itemnamen von zb shapes dürfen nicht einen namen haben der 6 ziffern lang ist!
        selectedItems[i] =
            'fefefe'; //weisser hintergrund aber nicht ffffff damit später erkennbar dass dort arrows angezeigt werden müssen
      } //else ist bereits ein hexcode in selectedColors und kein arrow
    }
  }

  ///Ordnet das Array selectedBackgroundcolors
  void organizeBackgroundcolor() {
    //wenn nur Weiss ausgewählt ist, soll das Array geleert werden, somit wird auf der Trainingpage
    //  das Backgroundcolor-Array ignoriert, denn der Hintergrund von Icons ist per Default sowieso weiss (fefefe)
    if ((selectedBackgroundcolors.length == 1) &&
        (selectedBackgroundcolors[0] == int.parse('0xffffffff'))) {
      selectedBackgroundcolors = [];
    }
  }

  void organizeStroop() {
    if (isStroopActive) {
      stroopTextcolor = [
        //farbcodes übernommen aus buildBackgroundColorselect
        4294967295, //weiss: hex ffffff mit opacity 100%, berechnung: int.parse('0xffffffff')
        4283716692, //schwarz/grau
        4294311680, //gelb
        3439263744, //rot
        3435157247, //violett
        2566959854, //blau
        1711336960, //grün
      ];

      stroopTextcolor = [
        //farbcodes sind nicht die gleichen wie in buildBackgroundColorselect, damit auch die gleichen farben bei schrift und hintergrund in kombination vorkommen können
        4293192685, //weiss: hex ffe4ebed mit opacity 100%, berechnung: int.parse('0xffe4ebed')
        4278190080, //schwarz
        4294631476, //gelb
        4294901760, //rot
        4284874913, //violett
        4278190219, //blau
        4284661515, //grün
      ];

      if (isGerman) {
        stroopTexticons = [
          'stroop_weiss',
          'stroop_schwarz',
          'stroop_gelb',
          'stroop_rot',
          'stroop_violett',
          'stroop_blau',
          'stroop_gruen',
        ];
      } else {
        stroopTexticons = [
          'stroop_white',
          'stroop_black',
          'stroop_yellow',
          'stroop_red',
          'stroop_violet',
          'stroop_blue',
          'stroop_green',
        ];
      }

      //selectedItems darf nicht leer sein, falls nur Stroop selektiert ist, dann hier Default-Wert mitgeben
      if (selectedItems.length == 0) {
        selectedItems.add("fefefe");
        selectedItems.add("fefefe");
        selectedItems.add("fefefe");
        selectedItems.add("fefefe");
        selectedItems.add("fefefe");
        selectedItems.add("fefefe");
        selectedItems.add("fefefe");
      }
    } else {
      //else auch abfangen damit Arrays leer wenn Stroop-Häkchen im Nachhinein abgewählt wird
      stroopTextcolor = [];
      stroopTexticons = [];
    }
  }

  //Funktion wird nur benötigt wenn von Trainingpage zurück auf Menupage kommt
  //Es wird kein Array mit nur den Farben an die Menupage übergeben sondern nur selectedItems, das alle Farben + für jedes Icon ein fefefe enthält
  //Um auf der Trainingpage wieder ein sauberes Array selectedColors zu haben, müssen aus selectedItems alle fefefe-Werte entfernt werden.
  void initializeSelectedColors(attrSelectedItems) {
    selectedColors = []; //Array leeren
    for (int i = 0; i < attrSelectedItems.length; i++) {
      if (attrSelectedItems[i] != 'fefefe') {
        selectedColors.add(attrSelectedItems[i]);
      }
    }
  }

  ///Selektierte Pfeilrichtungen und Pfeilfarben sind im Übergabearray von trainingPage im Format arrowdirection_arrowcolor abgespeichert
  ///Funktion nimmt die Strings auseinander und füllt sie in Arrays selectedArrows und selectedArrowcolors ab
  ///Ist das Gegenstück von organizeArrowcolors()
  void initializeArrowdirectionsArrowcolors(listArrowdirectionsArrowcolors) {
    selectedArrows = [];
    selectedArrowcolors = [];
    var tempSubstrings = [];

    for (int i = 0; i < listArrowdirectionsArrowcolors.length; i++) {
      tempSubstrings = listArrowdirectionsArrowcolors[i].split('_');
      if (tempSubstrings[0] != '') {
        //leere Strings nicht dem Array shinzufügen
        selectedArrows.add(tempSubstrings[0]);
      }
      if (tempSubstrings[1] != '') {
        //leere Strings nicht dem Array hinzufügen
        selectedArrowcolors.add(tempSubstrings[1]);
      }
      tempSubstrings = [];
    }

    selectedArrows = selectedArrows.toSet().toList();
    selectedArrowcolors = selectedArrowcolors.toSet().toList();
  }

  /// Returnt einen AlertDialog, damit der User Zeit hat auf Position zu gehen
  Widget alertDialogCD() {
    return AlertDialog(
      content: Center(heightFactor: 1.2, child: Text('bereit'.tr)),
    );
  }

  void _showSkillaticsInfos() {
    showDialog(context: context, builder: (_) => skillaticsDialog());
  }

  Widget skillaticsDialog() {
    return const AlertDialog(
      content: SizedBox(
        child: Center(
          child: Column(
            children: [
              Text('\nSkillatics Neuroathletik\n'),
              Text('+41 79 663 48 52'),
              Text('info@skillatics.ch'),
              Text('www.skillatics.ch'),
            ],
          ),
        ),
        height: 140,
      ),
    );
  }

  /// returnt ein MultiSelectContainer, in dem alle Farben ausgewählt werden können
  MultiSelectContainer buildColorselect() {
    return MultiSelectContainer(
      key: Key(
        keyString,
      ), //https://jelenaaa.medium.com/how-to-force-widget-to-redraw-in-flutter-2eec703bc024
      //UniqueKey(), //damit Unterschied in Widget entdeckt wird und somit Widget rebuild wird
      prefix: MultiSelectPrefix(
        selectedPrefix: const Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(Icons.check, color: Colors.white, size: 14),
        ),
      ),
      items: [
        MultiSelectCard(
          value:
              'f5ff00', //HEX-Code der Farbe, muss zwingend 6-stellig sein (siehe organizeArrowsColors)
          label: 'Gelb'.tr,
          selected: selectedItems.contains('f5ff00'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 'ff931f',
          label: 'Orange'.tr,
          selected: selectedItems.contains('ff931f'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 'ff0000',
          label: 'Rot'.tr,
          selected: selectedItems.contains('ff0000'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 'f500ab',
          label: 'Pink'.tr,
          selected: selectedItems.contains('f500ab'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.pink.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '6600a1',
          label: 'Violett'.tr,
          selected: selectedItems.contains('6600a1'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 102, 0, 161).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 102, 0, 161),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '00b2ee',
          label: 'Hellblau'.tr,
          selected: selectedItems.contains('00b2ee'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '00008b',
          label: 'Dunkelblau'.tr,
          selected: selectedItems.contains('00008b'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 00, 0, 139).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 00, 0, 139),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '00ee00',
          label: 'Hellgrün'.tr,
          selected: selectedItems.contains('00ee00'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.lightGreen.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '006400',
          label: 'Dunkelgrün'.tr,
          selected: selectedItems.contains('006400'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 100, 0).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 100, 0),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '00868b',
          label: 'Türkis'.tr,
          selected: selectedItems.contains('00868b'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 134, 139).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 134, 139),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 'a8a8a8',
          label: 'Grau'.tr,
          selected: selectedItems.contains('a8a8a8'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 168, 168, 168).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 168, 168, 168),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '000000',
          label: 'Schwarz'.tr,
          selected: selectedItems.contains('000000'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textStyles: const MultiSelectItemTextStyles(
            selectedTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        MultiSelectCard(
          value: 'bd9b16',
          label: 'Gold'.tr,
          selected: selectedItems.contains('bd9b16'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 189, 155, 22).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 189, 155, 22),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 'ffffff',
          label: 'Weiss'.tr,
          selected: selectedItems.contains('ffffff'),
          textStyles: const MultiSelectItemTextStyles(
            selectedTextStyle: TextStyle(color: Colors.black),
          ),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 203, 203, 203).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(),
            ),
          ),
          prefix: MultiSelectPrefix(
            selectedPrefix: const Padding(
              padding: EdgeInsets.only(right: 5),
              child: Icon(Icons.check, color: Colors.black, size: 14),
            ),
          ),
        ),
      ],
      onChange: (allSelectedItems, selectedItem) {
        selectedColors = allSelectedItems;
      },
    );
  }

  /// returnt ein MultiSelectContainer, in dem alle Pfeile ausgewählt werden können
  MultiSelectContainer buildArrowselect() {
    return MultiSelectContainer(
      key: Key(
        keyString,
      ), //https://jelenaaa.medium.com/how-to-force-widget-to-redraw-in-flutter-2eec703bc024
      //UniqueKey(), //damit Unterschied in Widget entdeckt wird und somit Widget rebuild wird
      prefix: MultiSelectPrefix(
        selectedPrefix: const Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(Icons.check, color: Colors.black, size: 14),
        ),
      ),
      itemsDecoration: MultiSelectDecorations(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(),
        ),
      ),

      items: [
        MultiSelectCard(
          value: 'north',
          child: const Icon(Icons.north),
          selected: selectedArrows.contains('north'),
        ),
        MultiSelectCard(
          value: 'east',
          child: const Icon(Icons.east),
          selected: selectedArrows.contains('east'),
        ),
        MultiSelectCard(
          value: 'south',
          child: const Icon(Icons.south),
          selected: selectedArrows.contains('south'),
        ),
        MultiSelectCard(
          value: 'west',
          child: const Icon(Icons.west),
          selected: selectedArrows.contains('west'),
        ),
        MultiSelectCard(
          value: 'northwest',
          child: const Icon(Icons.north_west),
          selected: selectedArrows.contains('northwest'),
        ),
        MultiSelectCard(
          value: 'northeast',
          child: const Icon(Icons.north_east),
          selected: selectedArrows.contains('northeast'),
        ),
        MultiSelectCard(
          value: 'southeast',
          child: const Icon(Icons.south_east),
          selected: selectedArrows.contains('southeast'),
        ),
        MultiSelectCard(
          value: 'southwest',
          child: const Icon(Icons.south_west),
          selected: selectedArrows.contains('southwest'),
        ),
      ],
      onChange: (allSelectedItems, selectedItem) {
        selectedArrows = allSelectedItems;
      },
    );
  }

  MultiSelectContainer buildArrowColorselect() {
    return MultiSelectContainer(
      key: Key(
        keyString,
      ), //https://jelenaaa.medium.com/how-to-force-widget-to-redraw-in-flutter-2eec703bc024
      //UniqueKey(), //damit Unterschied in Widget entdeckt wird und somit Widget rebuild wird
      prefix: MultiSelectPrefix(
        selectedPrefix: const Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(Icons.check, color: Colors.white, size: 14),
        ),
      ),
      items: [
        MultiSelectCard(
          value:
              '4278190080', //hex 000000, schwarz, berechnung: int.parse('0xff000000')
          label: '',
          selected: selectedArrowcolors.contains('4278190080'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textStyles: const MultiSelectItemTextStyles(
            selectedTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        MultiSelectCard(
          value: '4293444664', //hex e8c438, gelb
          label: '',
          selected: selectedArrowcolors.contains('4293444664'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '4294901760', //hex ff0000, red
          label: '',
          selected: selectedArrowcolors.contains('4294901760'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '4290795263', //hex c056ff, violett
          label: '',
          selected: selectedArrowcolors.contains('4290795263'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 102, 0, 161).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 102, 0, 161),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '4278235886', //hex 00b2ee, blue
          label: '',
          selected: selectedArrowcolors.contains('4278235886'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: '4278251008', //hex 00ee00, green
          label: '',
          selected: selectedArrowcolors.contains('4278251008'),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.lightGreen.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
      onChange: (allSelectedItems, selectedItem) {
        selectedArrowcolors = allSelectedItems;
      },
    );
  }

  /// returnt ein MultiSelectContainer, in dem alle Formen ausgewählt werden können
  MultiSelectContainer buildShapeselect() {
    return MultiSelectContainer(
      key: Key(
        keyString,
      ), //https://jelenaaa.medium.com/how-to-force-widget-to-redraw-in-flutter-2eec703bc024
      //UniqueKey(), //damit Unterschied in Widget entdeckt wird und somit Widget rebuild wird
      prefix: MultiSelectPrefix(
        selectedPrefix: const Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(Icons.check, color: Colors.black, size: 14),
        ),
      ),
      itemsDecoration: MultiSelectDecorations(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(),
        ),
      ),
      itemsPadding: EdgeInsets.fromLTRB(0, 0, 4, 0),
      items: [
        MultiSelectCard(
          value: 'triangle',
          child: const Icon(CustomIcons.triangle_empty),
          selected: selectedShapes.contains('triangle'),
        ),
        MultiSelectCard(
          value:
              'quadrat', //muss deutsch sein weil square 6 buchstaben lang ist und länge 6 ist für color reserviert (hex-werte haben länge 6)-> entscheidend für organizeArrowsColors
          child: const Icon(CustomIcons.square_empty),
          selected: selectedShapes.contains('quadrat'),
        ),
        MultiSelectCard(
          value:
              'kreis', //muss deutsch sein weil circle 6 buchstaben lang ist und länge 6 ist für color reserviert (hex-werte haben länge 6)-> entscheidend für organizeArrowsColors
          child: const Icon(CustomIcons.circle_empty),
          selected: selectedShapes.contains('kreis'),
        ),
      ],
      onChange: (allSelectedItems, selectedItem) {
        selectedShapes = allSelectedItems;
      },
    );
  }

  /// returnt ein MultiSelectContainer, in dem alle Nummern ausgewählt werden können
  MultiSelectContainer buildAlphabetselect() {
    var alphabetlist = []; //Liste mit allen Grossbuchstaben A-Z
    alphabetlist = List.generate(
      26,
      (index) => (String.fromCharCode(index + 65)),
    ); //generates list with whole alphabet A-Z

    return MultiSelectContainer(
      controller: _controllerAlphabetLetter,
      key: Key(
        keyString,
      ), //https://jelenaaa.medium.com/how-to-force-widget-to-redraw-in-flutter-2eec703bc024
      //UniqueKey(), //damit Unterschied in Widget entdeckt wird und somit Widget rebuild wird
      prefix: MultiSelectPrefix(
        selectedPrefix: const Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(Icons.check, color: Colors.black, size: 14),
        ),
      ),
      textStyles: const MultiSelectTextStyles(
        textStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        selectedTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      itemsDecoration: MultiSelectDecorations(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(),
        ),
      ),
      items: [
        for (int i = 0; i < alphabetlist.length; i++)
          MultiSelectCard(
            value: 'letter' + alphabetlist[i],
            label: alphabetlist[i],
            selected: selectedAlphabetletters.contains(
              'letter' + alphabetlist[i],
            ),
          ),
      ],
      onChange: (allSelectedItems, selectedItem) {
        selectedAlphabetletters = allSelectedItems;
      },
    );
  }

  /// returnt ein MultiSelectContainer, in dem Hintergrundfarben für die Icons ausgewählt werden können
  MultiSelectContainer buildBackgroundColorselect() {
    return MultiSelectContainer(
      key: Key(
        keyString,
      ), //https://jelenaaa.medium.com/how-to-force-widget-to-redraw-in-flutter-2eec703bc024
      //UniqueKey(), //damit Unterschied in Widget entdeckt wird und somit Widget rebuild wird
      prefix: MultiSelectPrefix(
        selectedPrefix: const Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(
            Icons.check,
            color: Color.fromRGBO(
              233,
              233,
              233,
              1,
            ), //lightgrey damit unterscheidbar bei weiss
            size: 14,
          ),
        ),
      ),
      items: [
        MultiSelectCard(
          value:
              4294967295, //hex ffffff mit opacity 100%, weiss, berechnung: int.parse('0xffffffff')
          label: '',
          selected: selectedBackgroundcolors.contains(4294967295),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Color.fromRGBO(233, 233, 233, 1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.6)),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.withOpacity(0.6)),
            ),
          ),
          textStyles: const MultiSelectItemTextStyles(
            selectedTextStyle: TextStyle(color: Colors.black),
          ),
        ),
        MultiSelectCard(
          value:
              4283716692, //hex 545454, schwarz/grau damit kontrast erkennbar, berechnung: int.parse('0xff545454')
          label: '',
          selected: selectedBackgroundcolors.contains(4283716692),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          textStyles: const MultiSelectItemTextStyles(
            selectedTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        MultiSelectCard(
          value:
              4294311680, //hex f5ff00 mit opacity 100%-> 0xFF, gelb, berechnung: int.parse('0xFFf5ff00')
          label: '',
          selected: selectedBackgroundcolors.contains(4294311680),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.yellow.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.yellow,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value:
              3439263744, //hex ff0000 mit opacity 80%-> 0xCC, red, berechnung: int.parse('0xCCff0000'), https://gist.github.com/lopspower/03fb1cc0ac9f32ef38f4
          label: '',
          selected: selectedBackgroundcolors.contains(3439263744),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 3435157247, //hex c056ff mit opacity 80%, violett
          label: '',
          selected: selectedBackgroundcolors.contains(3435157247),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 102, 0, 161).withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: const Color.fromARGB(255, 102, 0, 161),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 2566959854, //hex 00b2ee mit opacity 60%->0x99, blue
          label: '',
          selected: selectedBackgroundcolors.contains(2566959854),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightBlue,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        MultiSelectCard(
          value: 1711336960, //hex 00ee00 mit opacity 40%->0x66, green
          label: '',
          selected: selectedBackgroundcolors.contains(1711336960),
          decorations: MultiSelectItemDecorations(
            decoration: BoxDecoration(
              color: Colors.lightGreen.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.lightGreen,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
      onChange: (allSelectedItems, selectedItem) {
        selectedBackgroundcolors = allSelectedItems;
      },
    );
  }

  @override
  void initState() {
    currentCountry = widget.currentCountry;
    selectedItems = widget.listSelectedColors;
    selectedArrowsPerColor = widget.listSelectedArrowsPerColor;
    selectedNumbers = widget.listSelectedNumbers;
    selectedShapes = widget.listSelectedShapes;
    selectedAlphabetletters = widget.listSelectedAlphabetletters;
    selectedBackgroundcolors = widget.listSelectedBackgroundcolors;
    anzColorsOnPage = widget.anzColorsOnPage;
    secChangeColor = widget.secChangeColor;
    secLengthRound = widget.secLengthRound;
    secLengthRest = widget.secLengthRest;
    anzRounds = widget.anzRounds;
    isElemProSeiteEinmalig = widget.isElemProSeiteEinmalig;
    isStroopActive = widget.isStroopActive;
    nr_individual = widget.nr_individual;
    nr_from = widget.nr_from;
    nr_to = widget.nr_to;
    nr_skip = widget.nr_skip;

    initializeSelectedColors(
      selectedItems,
    ); //selectedColors = selectedItems ohne fefefe-Werte
    initializeArrowdirectionsArrowcolors(
      selectedArrowsPerColor,
    ); //array mit arrowdirection_arrowcolor aufteilen in array mit arrowdirections und array mit arrowcolors

    //dauer durchlauf & pause setzen
    roundDisplayedSec = secLengthRound % 60;
    roundDisplayedMin = (secLengthRound / 60).floor();
    restDisplayedSec = secLengthRest % 60;
    restDisplayedMin = (secLengthRest / 60).floor();

    //Boolean isGerman anhand von übergebenem Argument currentCountry setzen
    if (currentCountry == 'GB') {
      isGerman = true;
    } else {
      isGerman = false;
    }
    super.initState();
    //nach diesem aufruf wird automatisch build() ausgeführt
  }

  // This method is rerun every time setState is called
  @override
  Widget build(BuildContext context) {
    /*rateMyApp.init().then((_) {
      if (rateMyApp.shouldOpenDialog) {
        rateMyApp.showRateDialog(
          context,
          title: 'bewertenTitel'.tr,
          message: 'bewertenText'.tr,
          rateButton: 'bewertenJetzt'.tr,
          noButton: 'bewertenNein'.tr,
          laterButton: 'bewertenSpaeter'.tr,
          onDismissed: () =>
              rateMyApp.callEvent(RateMyAppEventType.laterButtonPressed),
        );
      }
    });*/

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(188, 250, 0, 1),
        actions: [
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                Color.fromRGBO(188, 250, 0, 1),
              ),
            ),
            onPressed: () {
              if (isGerman) {
                Get.updateLocale(Locale('en', 'US'));
                isGerman = false;
                this.currentCountry = "DE";
              } else {
                //is English
                Get.updateLocale(Locale('de', 'DE'));
                isGerman = true;
                this.currentCountry = "GB";
              }
              changeKey();
            },
            child: Text(countryFlag(), style: TextStyle(fontSize: 20)),
          ),
        ],
        automaticallyImplyLeading: false, //damit kein zurück-Pfeil oben links
      ),
      body: SingleChildScrollView(
        child: //damit scrollable wenn content grösser ist als bildschirmgrösses
        Padding(
          padding: EdgeInsets.only(left: 5, right: 5, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //Checkbox - Mit welchen Farben trainieren
              //SizedBox(height: 20,),
              Text('selItems'.tr, style: TextStyle(fontSize: 15)),
              SizedBox(height: 18),
              Text('farben'.tr, style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(),
                child: buildColorselect(),
              ),
              SizedBox(height: 25),
              Text(
                'buchstaben'.tr,
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    child: Text('selectAll'.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade700),
                    ),
                    autofocus: false,
                    onPressed: () {
                      selectedAlphabetletters = _controllerAlphabetLetter
                          .selectAll();
                    },
                    onLongPress: () {
                      selectedAlphabetletters = _controllerAlphabetLetter
                          .selectAll();
                    },
                  ),
                  SizedBox(width: 5),
                  TextButton(
                    child: Text('deselectAll'.tr),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: BorderSide(color: Colors.grey.shade700),
                    ),
                    autofocus: false,
                    onPressed: () {
                      _controllerAlphabetLetter.deselectAll();
                      selectedAlphabetletters.clear();
                    },
                    onLongPress: () {
                      _controllerAlphabetLetter.deselectAll();
                      selectedAlphabetletters.clear();
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(),
                child: buildAlphabetselect(),
              ),
              SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'zahlen'.tr,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                  SizedBox(width: 3),
                ],
              ),

              SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('einzelneZahlen'.tr),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    //height: 28,
                    child: TextFormField(
                      initialValue: nr_individual,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'zB'.tr + ' 10,20,30',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                      onChanged: (value) {
                        nr_individual = value;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('von'.tr),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    //height: 28,
                    child: TextFormField(
                      initialValue: nr_from,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'zB'.tr + ' 1',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                      onChanged: (value) {
                        nr_from = value;
                      },
                    ),
                  ),
                  SizedBox(width: 10),
                  Text('bis'.tr),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.15,
                    //height: 28,
                    child: TextFormField(
                      initialValue: nr_to,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'zB'.tr + ' 8',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                      onChanged: (value) {
                        nr_to = value;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ohne'.tr),
                  SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    //height: 28,
                    child: TextFormField(
                      initialValue: nr_skip,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'zB'.tr + ' 2,4',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 4,
                        ),
                      ),
                      onChanged: (value) {
                        nr_skip = value;
                      },
                    ),
                  ),
                ],
              ),

              SizedBox(height: 25),
              Text('pfeile'.tr, style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(),
                child: buildArrowselect(),
              ),
              SizedBox(height: 20),
              ConstrainedBox(
                constraints: BoxConstraints(),
                child: buildArrowColorselect(),
              ),
              SizedBox(height: 25),
              Text('formen'.tr, style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(),
                child: buildShapeselect(),
              ),
              SizedBox(height: 25),
              Text(
                'background'.tr + ' Icons',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
              SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(),
                child: buildBackgroundColorselect(),
              ),
              SizedBox(height: 25),
              Text('Stroop', style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Transform.scale(
                  //Transform damit Grösse Checkbox angepasst werden kann
                  scale: 0.9,
                  child: Checkbox(
                    value: isStroopActive,
                    onChanged: (value) => setState(
                      () => isStroopActive =
                          value ??= //wenn value null dann per default false nehmen
                              false,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Divider(
                color: Colors.black,
                height: 15,
                indent: 30,
                endIndent: 30,
              ),
              //Dropdown - wie viele Farben aufs Mal angezeigt werden
              SizedBox(height: 12),
              Text('selAnzElem'.tr, style: TextStyle(fontSize: 15)),
              NumberPicker(
                value: anzColorsOnPage,
                minValue: 1,
                maxValue: 12,
                step: 1,
                itemHeight: 30,
                selectedTextStyle: TextStyle(fontSize: 22),
                textStyle: TextStyle(fontSize: 13),
                onChanged: (value) => setState(() => anzColorsOnPage = value),
              ),
              SizedBox(height: 10),

              //Checkbox - ob jedes Element pro Seite nur einmal vorkommen darf oder nicht
              //  Bsp.: 1,3,5,7 ausgewählt, 3 Elem pro Mal anzeigen-> Anzeige 1-3-1 nicht erlaubt wenn Checkbox aktiviert
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Transform.scale(
                  //Transform damit Grösse Checkbox angepasst werden kann
                  scale: 0.7,
                  child: CheckboxListTile(
                    //Unterschied zu Checkbox(): Mit ..ListTile() kann Text mitgegeben werden
                    value: isElemProSeiteEinmalig,
                    onChanged: (value) => setState(
                      () => isElemProSeiteEinmalig =
                          value ??= //wenn value null dann per default false nehmen
                              false,
                    ), //setState damit neu geladen wird und Checkbox dann angewählt ist
                    title: Text(
                      'selElemEinmalig'.tr,
                      style: TextStyle(fontSize: 18), //size 18 weil in scale
                    ),
                    controlAffinity: ListTileControlAffinity
                        .leading, //Checkbox links von Text
                  ),
                ),
              ),

              SizedBox(height: 12),

              Divider(
                color: Colors.black,
                height: 15,
                indent: 30,
                endIndent: 30,
              ),

              //Applescroll - Farbwechsel nach wie vielen Sekunden
              SizedBox(height: 12),
              Text('selWechselSek'.tr, style: TextStyle(fontSize: 15)),
              NumberPicker(
                value: secChangeColor,
                minValue: 1,
                maxValue: 59,
                step: 1,
                itemHeight: 30,
                selectedTextStyle: TextStyle(fontSize: 22),
                textStyle: TextStyle(fontSize: 13),
                onChanged: (value) => setState(() => secChangeColor = value),
              ),
              SizedBox(height: 12),

              Divider(
                color: Colors.black,
                height: 15,
                indent: 30,
                endIndent: 30,
              ),

              //Applescroll - Dauer eines Durchlaufs
              SizedBox(height: 12),
              Text('selDurchlauf'.tr, style: TextStyle(fontSize: 15)),
              SizedBox(height: 18), //Für Abstand
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      NumberPicker(
                        value: roundDisplayedMin,
                        minValue: 0,
                        maxValue: 59,
                        step: 1,
                        itemHeight: 30,
                        selectedTextStyle: TextStyle(fontSize: 22),
                        textStyle: TextStyle(fontSize: 13),
                        onChanged: (value) => setState(() {
                          roundDisplayedMin = value;
                          secLengthRound =
                              roundDisplayedSec + roundDisplayedMin * 60;
                        }),
                      ),
                    ],
                  ),
                  Text('min'.tr),
                  Column(
                    children: [
                      NumberPicker(
                        value: roundDisplayedSec,
                        minValue: 0,
                        maxValue: 59,
                        step: 1,
                        itemHeight: 30,
                        selectedTextStyle: TextStyle(fontSize: 22),
                        textStyle: TextStyle(fontSize: 13),
                        onChanged: (value) => setState(() {
                          roundDisplayedSec = value;
                          secLengthRound =
                              roundDisplayedSec + roundDisplayedMin * 60;
                        }),
                      ),
                    ],
                  ),
                  Text('sek'.tr),
                ],
              ),
              SizedBox(height: 12),

              Divider(
                color: Colors.black,
                height: 15,
                indent: 30,
                endIndent: 30,
              ),

              //Applescroll - Dauer einer Pause
              SizedBox(height: 12),
              Text('selPause'.tr, style: TextStyle(fontSize: 15)),
              SizedBox(height: 18), //Für Abstand
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      NumberPicker(
                        value: restDisplayedMin,
                        minValue: 0,
                        maxValue: 59,
                        step: 1,
                        itemHeight: 30,
                        selectedTextStyle: TextStyle(fontSize: 22),
                        textStyle: TextStyle(fontSize: 13),
                        onChanged: (value) => setState(() {
                          restDisplayedMin = value;
                          secLengthRest =
                              restDisplayedSec +
                              restDisplayedMin *
                                  60; //als Methode weil 2x vorkommt?
                        }),
                      ),
                    ],
                  ),
                  Text('min'.tr),
                  Column(
                    children: [
                      NumberPicker(
                        value: restDisplayedSec,
                        minValue: 0,
                        maxValue: 59,
                        step: 1,
                        itemHeight: 30,
                        selectedTextStyle: TextStyle(fontSize: 22),
                        textStyle: TextStyle(fontSize: 13),
                        onChanged: (value) => setState(() {
                          restDisplayedSec = value;
                          secLengthRest =
                              restDisplayedSec +
                              restDisplayedMin *
                                  60; //als Methode weil 2x vorkommt?
                        }),
                      ),
                    ],
                  ),
                  Text('sek'.tr),
                ],
              ),
              SizedBox(height: 12),

              Divider(
                color: Colors.black,
                height: 15,
                indent: 30,
                endIndent: 30,
              ),

              //Dropdown - Anzahl Durchgänge
              SizedBox(height: 12),
              Text('selAnzDurchg'.tr, style: TextStyle(fontSize: 15)),
              NumberPicker(
                value: anzRounds,
                minValue: 1,
                maxValue: 99,
                step: 1,
                itemHeight: 30,
                selectedTextStyle: TextStyle(fontSize: 22),
                textStyle: TextStyle(fontSize: 13),
                onChanged: (value) => setState(() => anzRounds = value),
              ),
              SizedBox(height: 12),

              Divider(
                color: Colors.black,
                height: 15,
                indent: 30,
                endIndent: 30,
              ),

              SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Center(
                  child: Text(
                    this.textFehlermeldung + '\n',
                    key: Key(keyString), //funktioniert nicht
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              TextButton(
                child: Text('start'.tr),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: BorderSide(color: Colors.grey.shade700),
                ),
                autofocus: true,
                onPressed: _changeToPage2,
                onLongPress: _changeToPage2,
              ),
              SizedBox(height: 5),
              RichText(
                text: TextSpan(
                  text: 'reset'.tr,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => Navigator.popAndPushNamed(context, '/'),
                ), //Einstellungen MenuPage reseten
              ),
              SizedBox(height: 20),
              SizedBox(
                height: 47,
                child: TextButton(
                  onPressed: _showSkillaticsInfos,
                  child: Image.asset(
                    ('assets/skillatics_schwarzWeiss_transparent.png'),
                  ),
                ),
              ),
              SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
