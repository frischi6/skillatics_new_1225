import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math'; // Für Random-Generator
import 'package:skillatics/custom_icons_icons.dart';
import 'package:skillatics/main.dart';
import 'package:skillatics/menuOptodrum.dart';
import 'package:skillatics/number_zero_to_fifty_icons.dart';
import 'package:skillatics/stroop__english_icons.dart';
import 'package:skillatics/stroop_icons.dart';
import 'start.dart';

class TrainingOptodrum extends StatefulWidget {
  final List<dynamic> listSelectedArrowsPerColor, listSelectedNumbersPerColor;
  final List<dynamic> listSelectedShapesPerColor,
      listSelectedAlphabetlettersPerColor;

  final int secChangeBackgrcolor;
  final List<dynamic> allItemsByColor;
  final List<dynamic> listStroopText, listStroopTextcolors;
  final List<dynamic> listSelectedBackgroundcolors;
  final int secLengthRound, secLengthRest, anzRounds;
  final String currentCountry;
  final String nr_individual, nr_from, nr_to, nr_skip;
  final String movedirection; // Die im Menü gewählte Bewegungsrichtung
  final int speedlevel;
  final bool gleicheItemsNacheinanderOk;

  const TrainingOptodrum({
    super.key,
    required this.listSelectedArrowsPerColor,
    required this.listSelectedNumbersPerColor,
    required this.listSelectedShapesPerColor,
    required this.listSelectedAlphabetlettersPerColor,
    required this.listSelectedBackgroundcolors,
    required this.secLengthRound,
    required this.secLengthRest,
    required this.anzRounds,
    required this.currentCountry,
    required this.listStroopText,
    required this.listStroopTextcolors,
    required this.nr_individual,
    required this.nr_from,
    required this.nr_to,
    required this.nr_skip,
    required this.movedirection,
    required this.speedlevel,
    required this.secChangeBackgrcolor,
    required this.allItemsByColor,
    required this.gleicheItemsNacheinanderOk,
  });

  @override
  State<TrainingOptodrum> createState() => _TrainingOptodrumState();
}

class _TrainingOptodrumState extends State<TrainingOptodrum>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Random random = Random();

  static const double iconSize =
      60; // Einheitliche Grösse (Höhe) aller Standard-Icons
  static const double iconSpacing = 30; // Exakter Abstand zwischen den Icons
  static double speed =
      75; // Geschwindigkeit in Pixel pro Sekunde, wird anhand des gewählten Speedlevels gesetzt
  int secChangeBackground = 2;
  List<dynamic> itemsByColor = [];
  MovementDirection direction = MovementDirection
      .leftToRightCenter; //Richtung in der sich die Icons bewegen

  List<dynamic> listWithStroopText = [];
  List<dynamic> listWithStroopTextcolors = [];
  List<dynamic> listWithBackgroundcolors = [];
  int currentBackgroundcolor = 0, newBackgroundcolor = 0;
  int lastChangeBackground = 0;
  int currentTimeBackground = 0;

  // Speichert konfigurierte Icon-Daten statt Widgets
  List<_IconConfig> icons = [];

  final List<_FlowIcon> _flowIcons = [];
  int _nextIconIndex = 0, lastIconIndex = 0;
  DateTime? _lastTime;
  double _animationWidth = 0;
  double _animationHeight = 0;
  bool gleicheIconsNacheinanderOk = true;

  bool isBreak = false;
  late Timer _timer;
  int anzRounds2 = 1;
  int secLengthRound2 = 1;
  int secLengthRest2 = 1;
  int currentSecsCD = 0;
  int currentMinsCD = 0;
  int anzRoundsDone = 1;
  int secsLengthRoundCD = 1;
  int minsLengthRoundCD = 1;
  int secsLengthRestCD = 1;
  int minsLengthRestCD = 1;

  double thicknessVerticalDividerFooter = 0.5;
  String rundeSg = 'rundeSg'.tr;
  String rundePl = 'rundePl'.tr;

  @override
  void initState() {
    super.initState();
    initPage();

    //Timer für Zeit-Zähler
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) => setState(() {
        timemanagement();
      }),
    );

    //Controller für die Animation
    // Initialisiert den Animations-Controller für den Endlos-Loop (duration 12h)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(hours: 12),
    )..addListener(_tick);

    _controller.forward(); //Controller starten
  }

  void initPage() {
    secLengthRound2 = widget.secLengthRound;
    secLengthRest2 = widget.secLengthRest;
    anzRounds2 = widget.anzRounds;

    secChangeBackground = widget.secChangeBackgrcolor;
    itemsByColor = widget.allItemsByColor;
    listWithStroopText = widget.listStroopText;
    listWithStroopTextcolors = widget.listStroopTextcolors;
    listWithBackgroundcolors = widget.listSelectedBackgroundcolors;
    currentBackgroundcolor =
        listWithBackgroundcolors[random.nextInt(
          listWithBackgroundcolors.length,
        )];
    gleicheIconsNacheinanderOk = widget.gleicheItemsNacheinanderOk;
    setMovedirection();
    setSpeed();
    init_timevariables();

    generateIconsByColor(itemsByColor);
    icons.shuffle();
  }

  void init_timevariables() {
    isBreak = false;

    minsLengthRoundCD = secLengthRound2 ~/ 60;
    secsLengthRoundCD = secLengthRound2 % 60;
    minsLengthRestCD = secLengthRest2 ~/ 60;
    secsLengthRestCD = secLengthRest2 % 60;

    currentSecsCD = secsLengthRoundCD;
    currentMinsCD = minsLengthRoundCD;

    currentTimeBackground = currentSecsCD + currentMinsCD * 60;
    lastChangeBackground = currentTimeBackground;
  }

  //Wandelt den String der Movementdirection in ein enum
  void setMovedirection() {
    switch (widget.movedirection) {
      case 'east':
        direction = MovementDirection.leftToRightCenter;
      case 'west':
        direction = MovementDirection.rightToLeftCenter;
      case 'north':
        direction = MovementDirection.bottomCenterToTopCenter;
      case 'south':
        direction = MovementDirection.topCenterToBottomCenter;
      case 'northeast':
        direction = MovementDirection.bottomLeftToTopRight;
      case 'northwest':
        direction = MovementDirection.bottomRightToTopLeft;
      case 'southeast':
        direction = MovementDirection.topLeftToBottomRight;
      case 'southwest':
        direction = MovementDirection.topRightToBottomLeft;
    }
  }

  ///Setzt die Geschwindigkeit in Pixel pro Sekunde anhand vom gewählten Speedlevel
  void setSpeed() {
    switch (widget.speedlevel) {
      case 1:
        speed = 75;
      case 2:
        speed = 200;
      case 3:
        speed = 325;
      case 4:
        speed = 450;
      case 5:
        speed = 575;
      case 6:
        speed = 700;
      case 7:
        speed = 825;
      case 8:
        speed = 950;
      case 9:
        speed = 1075;
      case 10:
        speed = 1200;
    }
  }

  /// Gibt den normalisierten Richtungsvektor (vx, vy) für die aktive Richtung zurück.
  /// Im Hochformat bleibt das Original erhalten, im Querformat wird exakt von Ecke zu Ecke angepasst.
  (double, double) _getVelocityVector(double width, double height) {
    const double invSqrt2 =
        0.70710678118; // 1 / sqrt(2) für diagonale Bewegungen im Hochformat

    // Wenn das Gerät im Querformat ist (Breite > Höhe), berechnen wir den Vektor dynamisch für Ecken-zu-Ecke
    if (width > height && width > 0 && height > 0) {
      final double length = sqrt(width * width + height * height);
      final double dx = width / length;
      final double dy = height / length;

      switch (direction) {
        case MovementDirection.topLeftToBottomRight:
          return (dx, dy);
        case MovementDirection.bottomRightToTopLeft:
          return (-dx, -dy);
        case MovementDirection.topRightToBottomLeft:
          return (-dx, dy);
        case MovementDirection.bottomLeftToTopRight:
          return (dx, -dy);
        case MovementDirection.topCenterToBottomCenter:
          return (0.0, 1.0);
        case MovementDirection.bottomCenterToTopCenter:
          return (0.0, -1.0);
        case MovementDirection.leftToRightCenter:
          return (1.0, 0.0);
        case MovementDirection.rightToLeftCenter:
          return (-1.0, 0.0);
      }
    }

    // Unveränderter Standard-Hochformat-Modus
    switch (direction) {
      case MovementDirection.topLeftToBottomRight:
        return (invSqrt2, invSqrt2);
      case MovementDirection.bottomRightToTopLeft:
        return (-invSqrt2, -invSqrt2);
      case MovementDirection.topRightToBottomLeft:
        return (-invSqrt2, invSqrt2);
      case MovementDirection.bottomLeftToTopRight:
        return (invSqrt2, -invSqrt2);
      case MovementDirection.topCenterToBottomCenter:
        return (0.0, 1.0);
      case MovementDirection.bottomCenterToTopCenter:
        return (0.0, -1.0);
      case MovementDirection.leftToRightCenter:
        return (1.0, 0.0);
      case MovementDirection.rightToLeftCenter:
        return (-1.0, 0.0);
    }
  }

  ///Checkt ab ob ein String eine Zahl ist
  ///Return 1: numeric, 0: not numeric
  bool isNumeric(String stringValue) {
    try {
      int.parse(stringValue);
    } catch (e) {
      return false;
    }
    return true;
  }

  int getColorcodeByItemPerColor(itemItemcolor) {
    return int.parse(
      itemItemcolor.substring(
        itemItemcolor.indexOf('_') + 1,
        itemItemcolor.length,
      ),
    );
  }

  void generateIconsByColor(listWithIconsPerColor) {
    for (int i = 0; i < listWithIconsPerColor.length; i++) {
      addIconToList(listWithIconsPerColor[i]);
    }
  }

  ///Berechnet die präzise Breite eines Icons (Glyph) im Verhältnis zur gewünschten Höhe
  double _getIconWidth(IconData iconData, double size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontFamily: iconData.fontFamily,
          package: iconData.fontPackage,
          fontSize: size,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    return textPainter.width;
  }

  ///Hilfsfunktion zum Erstellen und Hinzufügen von Icon-Konfigurationen
  void _addIconConfig(
    IconData iconData,
    Color color,
    double size, {
    bool isStroop = false,
  }) {
    final width = _getIconWidth(iconData, size);
    icons.add(
      _IconConfig(
        iconData: iconData,
        color: color,
        width: width,
        renderSize: size,
        isStroop: isStroop,
      ),
    );
  }

  ///Erstellt die Liste mit allen zu benutzenden Icons (gemäss Menu-Auswahl des Benutzers)
  void addIconToList(icon_color) {
    double sizeIcon = iconSize;
    int anzColorsOnPage2 = 4;
    bool arrowVisible = true;

    if (arrowVisible) {
      if (anzColorsOnPage2 == 4) {
        sizeIcon = 90.0;
      } else if (anzColorsOnPage2 == 3) {
        sizeIcon = 110.0;
      } else if (anzColorsOnPage2 == 2) {
        sizeIcon = 160.0;
      } else if (anzColorsOnPage2 == 1) {
        sizeIcon = 200.0;
      }

      if (isNumeric(icon_color.substring(0, icon_color.indexOf('_')))) {
        addNumberToList(icon_color, sizeIcon);
      } else if (icon_color.contains('northeast_')) {
        _addIconConfig(
          Icons.north_east,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('northwest_')) {
        _addIconConfig(
          Icons.north_west,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('southeast_')) {
        _addIconConfig(
          Icons.south_east,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('southwest_')) {
        _addIconConfig(
          Icons.south_west,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon - 10,
        );
      } else if (icon_color.contains('north_')) {
        _addIconConfig(
          Icons.north,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('east_')) {
        _addIconConfig(
          Icons.east,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('south_')) {
        _addIconConfig(
          Icons.south,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('west_')) {
        _addIconConfig(
          Icons.west,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('triangle_')) {
        _addIconConfig(
          CustomIcons.triangle,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('kreis_')) {
        _addIconConfig(
          CustomIcons.circle,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.contains('quadrat_')) {
        _addIconConfig(
          CustomIcons.square,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon,
        );
      } else if (icon_color.startsWith('letter')) {
        IconData letterIcon;
        switch (icon_color.substring(6, 7).toLowerCase()) {
          case 'a':
            letterIcon = CustomIcons.a;
            break;
          case 'b':
            letterIcon = CustomIcons.b;
            break;
          case 'c':
            letterIcon = CustomIcons.c;
            break;
          case 'd':
            letterIcon = CustomIcons.d;
            break;
          case 'e':
            letterIcon = CustomIcons.e;
            break;
          case 'f':
            letterIcon = CustomIcons.f;
            break;
          case 'g':
            letterIcon = CustomIcons.g;
            break;
          case 'h':
            letterIcon = CustomIcons.h;
            break;
          case 'i':
            letterIcon = CustomIcons.i;
            break;
          case 'j':
            letterIcon = CustomIcons.j;
            break;
          case 'k':
            letterIcon = CustomIcons.k;
            break;
          case 'l':
            letterIcon = CustomIcons.l;
            break;
          case 'm':
            letterIcon = CustomIcons.m;
            break;
          case 'n':
            letterIcon = CustomIcons.n;
            break;
          case 'o':
            letterIcon = CustomIcons.o;
            break;
          case 'p':
            letterIcon = CustomIcons.p;
            break;
          case 'q':
            letterIcon = CustomIcons.q;
            break;
          case 'r':
            letterIcon = CustomIcons.r;
            break;
          case 's':
            letterIcon = CustomIcons.s;
            break;
          case 't':
            letterIcon = CustomIcons.t;
            break;
          case 'u':
            letterIcon = CustomIcons.u;
            break;
          case 'v':
            letterIcon = CustomIcons.v;
            break;
          case 'w':
            letterIcon = CustomIcons.w;
            break;
          case 'x':
            letterIcon = CustomIcons.x;
            break;
          case 'y':
            letterIcon = CustomIcons.y;
            break;
          case 'z':
            letterIcon = CustomIcons.z;
            break;
          default:
            letterIcon = CustomIcons.a;
            break;
        }
        _addIconConfig(
          letterIcon,
          Color(getColorcodeByItemPerColor(icon_color)),
          sizeIcon - 10,
        );
      } else {
        IconData? stroopIcon;
        Color randomStroopColor = Color(
          listWithStroopTextcolors[random.nextInt(
            listWithStroopTextcolors.length,
          )],
        );

        if (icon_color == 'stroop_weiss') {
          stroopIcon = StroopIcons.stroop_weiss;
        } else if (icon_color == 'stroop_schwarz') {
          stroopIcon = StroopIcons.stroop_schwarz;
        } else if (icon_color == 'stroop_gelb') {
          stroopIcon = StroopIcons.stroop_gelb;
        } else if (icon_color == 'stroop_rot') {
          stroopIcon = StroopIcons.stroop_rot;
        } else if (icon_color == 'stroop_violett') {
          stroopIcon = StroopIcons.stroop_violett;
        } else if (icon_color == 'stroop_blau') {
          stroopIcon = StroopIcons.stroop_blau;
        } else if (icon_color == 'stroop_gruen') {
          stroopIcon = StroopIcons.stroop_gruen;
        } else if (icon_color == 'stroop_white') {
          stroopIcon = StroopIcons_English.stroop_white;
        } else if (icon_color == 'stroop_black') {
          stroopIcon = StroopIcons_English.stroop_black;
        } else if (icon_color == 'stroop_yellow') {
          stroopIcon = StroopIcons_English.stroop_yellow;
        } else if (icon_color == 'stroop_red') {
          stroopIcon = StroopIcons_English.stroop_red;
        } else if (icon_color == 'stroop_violet') {
          stroopIcon = StroopIcons_English.stroop_violet;
        } else if (icon_color == 'stroop_blue') {
          stroopIcon = StroopIcons_English.stroop_blue;
        } else if (icon_color == 'stroop_green') {
          stroopIcon = StroopIcons_English.stroop_green;
        }

        if (stroopIcon != null) {
          _addIconConfig(
            stroopIcon,
            randomStroopColor,
            sizeIcon,
            isStroop: true,
          );
        }
      }
    }
  }

  void addNumberToList(String numberNumbercolor, double iconsize) {
    int iconnumber;
    int iconcolor;
    iconnumber = int.parse(
      numberNumbercolor.substring(0, numberNumbercolor.indexOf('_')),
    );
    iconcolor = getColorcodeByItemPerColor(numberNumbercolor);

    IconData? numberIcon;
    switch (iconnumber) {
      case 0:
        numberIcon = NumberIcons.nr_0;
        break;
      case 1:
        numberIcon = NumberIcons.nr_1;
        break;
      case 2:
        numberIcon = NumberIcons.nr_2;
        break;
      case 3:
        numberIcon = NumberIcons.nr_3;
        break;
      case 4:
        numberIcon = NumberIcons.nr_4;
        break;
      case 5:
        numberIcon = NumberIcons.nr_5;
        break;
      case 6:
        numberIcon = NumberIcons.nr_6;
        break;
      case 7:
        numberIcon = NumberIcons.nr_7;
        break;
      case 8:
        numberIcon = NumberIcons.nr_8;
        break;
      case 9:
        numberIcon = NumberIcons.nr_9;
        break;
      case 10:
        numberIcon = NumberIcons.nr_10;
        break;
      case 11:
        numberIcon = NumberIcons.nr_11;
        break;
      case 12:
        numberIcon = NumberIcons.nr_12;
        break;
      case 13:
        numberIcon = NumberIcons.nr_13;
        break;
      case 14:
        numberIcon = NumberIcons.nr_14;
        break;
      case 15:
        numberIcon = NumberIcons.nr_15;
        break;
      case 16:
        numberIcon = NumberIcons.nr_16;
        break;
      case 17:
        numberIcon = NumberIcons.nr_17;
        break;
      case 18:
        numberIcon = NumberIcons.nr_18;
        break;
      case 19:
        numberIcon = NumberIcons.nr_19;
        break;
      case 20:
        numberIcon = NumberIcons.nr_20;
        break;
      case 21:
        numberIcon = NumberIcons.nr_21;
        break;
      case 22:
        numberIcon = NumberIcons.nr_22;
        break;
      case 23:
        numberIcon = NumberIcons.nr_23;
        break;
      case 24:
        numberIcon = NumberIcons.nr_24;
        break;
      case 25:
        numberIcon = NumberIcons.nr_25;
        break;
      case 26:
        numberIcon = NumberIcons.nr_26;
        break;
      case 27:
        numberIcon = NumberIcons.nr_27;
        break;
      case 28:
        numberIcon = NumberIcons.nr_28;
        break;
      case 29:
        numberIcon = NumberIcons.nr_29;
        break;
      case 30:
        numberIcon = NumberIcons.nr_30;
        break;
      case 31:
        numberIcon = NumberIcons.nr_31;
        break;
      case 32:
        numberIcon = NumberIcons.nr_32;
        break;
      case 33:
        numberIcon = NumberIcons.nr_33;
        break;
      case 34:
        numberIcon = NumberIcons.nr_34;
        break;
      case 35:
        numberIcon = NumberIcons.nr_35;
        break;
      case 36:
        numberIcon = NumberIcons.nr_36;
        break;
      case 37:
        numberIcon = NumberIcons.nr_37;
        break;
      case 38:
        numberIcon = NumberIcons.nr_38;
        break;
      case 39:
        numberIcon = NumberIcons.nr_39;
        break;
      case 40:
        numberIcon = NumberIcons.nr_40;
        break;
      case 41:
        numberIcon = NumberIcons.nr_41;
        break;
      case 42:
        numberIcon = NumberIcons.nr_42;
        break;
      case 43:
        numberIcon = NumberIcons.nr_43;
        break;
      case 44:
        numberIcon = NumberIcons.nr_44;
        break;
      case 45:
        numberIcon = NumberIcons.nr_45;
        break;
      case 46:
        numberIcon = NumberIcons.nr_46;
        break;
      case 47:
        numberIcon = NumberIcons.nr_47;
        break;
      case 48:
        numberIcon = NumberIcons.nr_48;
        break;
      case 49:
        numberIcon = NumberIcons.nr_49;
        break;
      case 50:
        numberIcon = NumberIcons.nr_50;
        break;
    }

    if (numberIcon != null) {
      _addIconConfig(numberIcon, Color(iconcolor), iconsize);
    }
  }

  /// Erzeugt ein neues Icon an der korrekten Startposition basierend auf der Richtung
  void _spawnIcon(double width, double height) {
    if (icons.isEmpty) return;

    final iconConfig = icons[_nextIconIndex];
    final iconWidth = iconConfig.width;

    double startX = 0;
    double startY = 0;

    switch (direction) {
      case MovementDirection.topLeftToBottomRight:
        startX = -iconWidth;
        startY = -iconConfig.renderSize;
        break;
      case MovementDirection.bottomRightToTopLeft:
        startX = width;
        startY = height;
        break;
      case MovementDirection.topRightToBottomLeft:
        startX = width;
        startY = -iconConfig.renderSize;
        break;
      case MovementDirection.bottomLeftToTopRight:
        startX = -iconWidth;
        startY = height;
        break;
      case MovementDirection.topCenterToBottomCenter:
        startX = (width - iconWidth) / 2;
        startY = -iconConfig.renderSize;
        break;
      case MovementDirection.bottomCenterToTopCenter:
        startX = (width - iconWidth) / 2;
        startY = height;
        break;
      case MovementDirection.leftToRightCenter:
        startX = -iconWidth;
        startY = (height - iconConfig.renderSize) / 2;
        break;
      case MovementDirection.rightToLeftCenter:
        startX = width;
        startY = (height - iconConfig.renderSize) / 2;
        break;
    }

    final flowIcon = _FlowIcon(
      iconData: iconConfig.iconData,
      color: iconConfig.color,
      renderSize: iconConfig.renderSize,
      width: iconWidth,
      isStroop: iconConfig.isStroop,
      x: startX,
      y: startY,
      startX: startX,
      startY: startY,
    );

    _flowIcons.add(flowIcon);

    //Nächsten Index random generieren
    _nextIconIndex = random.nextInt(icons.length);

    //Option dass nicht dieselben Icons nacheinander angzeiget werden
    if (!gleicheIconsNacheinanderOk) {
      while (lastIconIndex == _nextIconIndex) {
        _nextIconIndex = random.nextInt(icons.length);
      }
    }

    lastIconIndex = _nextIconIndex;
  }

  void _checkForNewIcon(double width, double height) {
    if (_flowIcons.isEmpty) {
      _spawnIcon(width, height);
      return;
    }

    final lastIcon = _flowIcons.last;
    final (vx, vy) = _getVelocityVector(width, height);

    final distanceTraveled =
        (lastIcon.x - lastIcon.startX) * vx +
        (lastIcon.y - lastIcon.startY) * vy;

    final bool isDiagonal =
        direction == MovementDirection.topLeftToBottomRight ||
        direction == MovementDirection.bottomRightToTopLeft ||
        direction == MovementDirection.topRightToBottomLeft ||
        direction == MovementDirection.bottomLeftToTopRight;

    final bool isLandscape = width > height;

    double requiredDistance;
    if (isDiagonal) {
      if (lastIcon.isStroop) {
        final double spacingMultiplier = isLandscape ? 0.7 : 1.0;
        requiredDistance = (lastIcon.width + iconSpacing) * spacingMultiplier;
      } else {
        final double spacingMultiplier = isLandscape ? 0.7 : 1.0;
        requiredDistance =
            (lastIcon.renderSize + iconSpacing) * spacingMultiplier;
      }
    } else {
      requiredDistance = lastIcon.width + iconSpacing;
    }

    if (distanceTraveled >= requiredDistance) {
      _spawnIcon(width, height);
    }
  }

  ///Überprüft ob Icon aus Bildschirm raus ist
  ///Return 1: hat Bildschirm verlassen, 0: befindet sich noch in sichtbarem Bereich
  bool _isOutOfBounds(_FlowIcon flowIcon, double width, double height) {
    switch (direction) {
      case MovementDirection.topLeftToBottomRight:
        return flowIcon.x > width || flowIcon.y > height;
      case MovementDirection.bottomRightToTopLeft:
        return flowIcon.x + flowIcon.width < 0 ||
            flowIcon.y + flowIcon.renderSize < 0;
      case MovementDirection.topRightToBottomLeft:
        return flowIcon.x + flowIcon.width < 0 || flowIcon.y > height;
      case MovementDirection.bottomLeftToTopRight:
        return flowIcon.x > width || flowIcon.y + flowIcon.renderSize < 0;
      case MovementDirection.topCenterToBottomCenter:
        return flowIcon.y > height;
      case MovementDirection.bottomCenterToTopCenter:
        return flowIcon.y + flowIcon.renderSize < 0;
      case MovementDirection.leftToRightCenter:
        return flowIcon.x > width;
      case MovementDirection.rightToLeftCenter:
        return flowIcon.x + flowIcon.width < 0;
    }
  }

  ///Wird durch Animation-Controller ca. 60x pro Sekunde aufgerufen
  ///Alles von der Animation der Icons ist hier drin
  void _tick() {
    final now = DateTime.now();

    if (_lastTime == null) {
      _lastTime = now;
      return;
    }

    final deltaTime = now.difference(_lastTime!).inMicroseconds / 1000000.0;
    _lastTime = now;

    if (!mounted) return;

    // Verhindert das Spawnen/Berechnen mit ungültigen Dimensionen beim ersten Start
    if (_animationWidth == 0 || _animationHeight == 0) return;

    setState(() {
      final (vx, vy) = _getVelocityVector(_animationWidth, _animationHeight);
      final movement = speed * deltaTime;
      final deltaX = movement * vx;
      final deltaY = movement * vy;

      for (final flowIcon in _flowIcons) {
        flowIcon.x += deltaX;
        flowIcon.y += deltaY;
      }

      _flowIcons.removeWhere(
        (flowIcon) =>
            _isOutOfBounds(flowIcon, _animationWidth, _animationHeight),
      );

      _checkForNewIcon(_animationWidth, _animationHeight);
    });
  }

  ///Wird alle 1 Sekunde von timer aufgerufen
  ///Organisiert Zeitanzeige, Wechsel von Rest & Round, Programmende und Wechsel
  ///der Hintergrundfarbe
  void timemanagement() {
    /* Darstellung Zeitbalken und Überprüfung Rest/Round */

    //00:01
    if (currentMinsCD == 0 && currentSecsCD == 1) {
      if (anzRounds2 == anzRoundsDone && isBreak) {
        //programm ganz fertig, messagebox zeigen
        currentSecsCD--;
        _timer.cancel();
        //dispose();
        showDialog(
          context: context,
          builder: (_) => alertDialogFinish(),
          barrierDismissible: false,
        );
        return;
      }

      if (isBreak) {
        //Wechsel von Rest zu Round
        isBreak = false;
        _controller.forward();
        currentMinsCD = minsLengthRoundCD;
        currentSecsCD = secsLengthRoundCD;
        anzRoundsDone++;
      } else {
        //Wechsel von Round zu Rest
        isBreak = true;
        _controller.stop();
        currentMinsCD = minsLengthRestCD;
        currentSecsCD = secsLengthRestCD;
      }
    } else {
      //wenn nicht 00:01 dann einfach runterzählen
      if (currentSecsCD > 0) {
        currentSecsCD--;
      } else {
        currentMinsCD--;
        currentSecsCD = 59;
      }
    }

    /* Überprüfung, ob Hintergrundfarbe geändert werden muss */
    currentTimeBackground = currentSecsCD + currentMinsCD * 60;
    if (listWithBackgroundcolors.length > 1) {
      if (lastChangeBackground - currentTimeBackground == secChangeBackground) {
        do {
          newBackgroundcolor =
              listWithBackgroundcolors[random.nextInt(
                listWithBackgroundcolors.length,
              )];
        } while (newBackgroundcolor == currentBackgroundcolor);

        currentBackgroundcolor = newBackgroundcolor;
        lastChangeBackground = currentTimeBackground;
      }
    }
  }

  ///Entfernt Icon
  void _removeIcon(_FlowIcon flowIcon) {
    //mounted sagt ob Widget aktuell noch zum Tree gehört oder nicht
    if (!mounted) return;
    setState(() {
      _flowIcons.remove(flowIcon);
    });
  }

  //Todo
  void changeToMenupage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuOptodrum(
          title: 'Optodrum',
          currentCountry: widget.currentCountry,
          //listSelectedColors: widget.listSelectedColors,
          listSelectedArrowsPerColor: widget.listSelectedArrowsPerColor,
          listSelectedNumbersPerColor: widget.listSelectedNumbersPerColor,
          listSelectedShapesPerColor: widget.listSelectedShapesPerColor,
          listSelectedAlphabetlettersPerColor:
              widget.listSelectedAlphabetlettersPerColor,
          listSelectedBackgroundcolors: widget.listSelectedBackgroundcolors,
          listSelectedStroopcolors: widget.listStroopTextcolors,
          secLengthRound: widget.secLengthRound,
          secLengthRest: widget.secLengthRest,
          anzRounds: widget.anzRounds,
          nr_individual: widget.nr_individual,
          nr_from: widget.nr_from,
          nr_to: widget.nr_to,
          nr_skip: widget.nr_skip,
          speedlevel: widget.speedlevel,
          secChangeBackgrcolor: secChangeBackground,
          moveDirection: widget.movedirection,
          gleicheNacheinanderOk: widget.gleicheItemsNacheinanderOk,
        ),
      ),
    );
  }

  //todo
  void neustart() {
    initPage();
    //Animation stoppen und auf Startposition (0.0) zurücksetzen
    _controller.reset();
    //Liste der Icons leeren (löscht alle aktuell sichtbaren Icons)
    _flowIcons.clear();
    //Animation erneut starten
    _controller.forward();
  }

  /// Damit Anzeige in Fusszeile korrekt mit 1 Runde bzw >1 Runden
  String getRundeSgPl() {
    if (anzRounds2 == 1) {
      return rundeSg;
    } else {
      return rundePl;
    }
  }

  /// AlertDialog das am Ende der Übung erscheint
  Widget alertDialogFinish() {
    return AlertDialog(
      //ähnlich wie modalWindow
      content: Text('trainingEnde'.tr),
      actions: [
        TextButton(
          onPressed: changeToMenupage,
          child: Text(
            'hauptmenü'.tr,
            style: const TextStyle(color: Color.fromARGB(177, 0, 0, 0)),
          ),
        ),
        TextButton(
          onPressed: changeToMenupage,
          child: Text(
            'neustart'.tr,
            style: const TextStyle(color: Color.fromARGB(177, 0, 0, 0)),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          false, //damit swipe back(ios) bzw. Back Button (android) deaktiviert
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(currentBackgroundcolor),
          body: Column(
            children: [
              if (!isBreak)
                Expanded(
                  flex: 95,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      _animationHeight = constraints.maxHeight;
                      _animationWidth = constraints.maxWidth;

                      return ClipRect(
                        child: Stack(
                          children: [
                            for (final flowIcon in _flowIcons)
                              Positioned(
                                left: flowIcon.x,
                                top: flowIcon.y,
                                child: SizedBox(
                                  width: flowIcon.width,
                                  height: flowIcon.renderSize,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () => _removeIcon(flowIcon),
                                    child: Icon(
                                      flowIcon.iconData,
                                      size: flowIcon.renderSize,
                                      color: flowIcon.color,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              if (isBreak)
                Expanded(
                  flex: 95,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.black),
                    alignment: Alignment.center,
                    //Die Anzeige "Pause" wird im ersten Container gemacht
                    child: Text(
                      'pause'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              //footer
              Expanded(
                flex: 5,
                child: Container(
                  //height: MediaQuery.of(context).size.height * (footerPercentage),
                  width: MediaQuery.of(context).size.width,
                  color: Colors.grey.shade700,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                thicknessVerticalDividerFooter) /
                            4,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '$anzRoundsDone/$anzRounds2 ${getRundeSgPl()}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                thicknessVerticalDividerFooter) /
                            4,
                        child: Center(
                          child: Text(
                            '${currentMinsCD.toString().padLeft(2, '0')}:${currentSecsCD.toString().padLeft(2, '0')}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const VerticalDivider(
                        color: Colors.black,
                        thickness: 0.5,
                        width: 0.5,
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                thicknessVerticalDividerFooter) /
                            4,
                        child: TextButton(
                          autofocus: false,
                          onPressed: changeToMenupage,
                          onLongPress: changeToMenupage,
                          child: Text(
                            'hauptmenü'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                      SizedBox(
                        width:
                            (MediaQuery.of(context).size.width -
                                thicknessVerticalDividerFooter) /
                            4,
                        child: TextButton(
                          autofocus: false,
                          onPressed: neustart,
                          onLongPress: neustart,
                          child: Text(
                            'neustart'.tr,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Konfigurationsklasse für Icons vor dem Spawn
class _IconConfig {
  final IconData iconData;
  final Color color;
  final double width;
  final double renderSize;
  final bool isStroop;

  _IconConfig({
    required this.iconData,
    required this.color,
    required this.width,
    required this.renderSize,
    this.isStroop = false,
  });
}

/// Datenmodell zur Speicherung von Position, Farbe und gelesener Breite im aktiven Flow
class _FlowIcon {
  final IconData iconData;
  final Color color;
  final double renderSize;
  final double width;
  final bool isStroop;
  double x;
  double y;
  final double startX;
  final double startY;

  _FlowIcon({
    required this.iconData,
    required this.color,
    required this.renderSize,
    required this.width,
    required this.isStroop,
    required this.x,
    required this.y,
    required this.startX,
    required this.startY,
  });
}

//Movementdirections der Icons
enum MovementDirection {
  topLeftToBottomRight,
  bottomRightToTopLeft,
  topRightToBottomLeft,
  bottomLeftToTopRight,
  topCenterToBottomCenter,
  bottomCenterToTopCenter,
  leftToRightCenter,
  rightToLeftCenter,
}
