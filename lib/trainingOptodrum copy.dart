//Bewegung Icons von oben links nach unten rechts
import 'package:flutter/material.dart';
import 'package:skillatics/start.dart';
//Enthält Tools zur visuellen Messung (z. B. TextPainter).
import 'package:skillatics/custom_icons_icons.dart';
import 'package:skillatics/stroop_icons.dart';

class TrainingOptodrum extends StatefulWidget {
  const TrainingOptodrum({super.key});
  @override
  State<TrainingOptodrum> createState() => _TrainingOptodrumState();
}

class _TrainingOptodrumState extends State<TrainingOptodrum>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  // =========================
  // Einstellungen
  // =========================
  static const double iconSize = 40;
  // Abstand zwischen den Icons
  static const double iconSpacing = 90;
  // Geschwindigkeit der Bewegung
  static const double speed = 100;
  // =========================
  // Deine TTF-Icons
  // =========================
  final List<IconData> icons = [
    /* Buchstaben: gut */
    CustomIcons.a,
    CustomIcons.b,
    CustomIcons.c,
    CustomIcons.d,
    CustomIcons.e,
    CustomIcons.f,
    /* Numbers: Abstände sind nicht ganz gleichmässig
    NumberIcons.nr_1,
    NumberIcons.nr_2,
    NumberIcons.nr_3,
    NumberIcons.nr_4,
    NumberIcons.nr_46,
    NumberIcons.nr_47,
    NumberIcons.nr_48,
    NumberIcons.nr_49, */
    /* Stroop: Abstände sehr gut! */
    StroopIcons.stroop_weiss,
    StroopIcons.stroop_rot,
    StroopIcons.stroop_gruen,
    StroopIcons.stroop_blau,
    StroopIcons.stroop_violett,

    /* Formen: evtl nur optische Täuschung dass Abstand nicht sauber ist, evtl stimmt er schon */
    CustomIcons.triangle,
    CustomIcons.square,
    CustomIcons.circle,
    /* Pfeile: top */
    Icons.north,
    Icons.north_east,
    Icons.west,
    Icons.south,
    Icons.south_east,
    /*
    Icons.music_note,
    StroopIcons.stroop_weiss,
    NumberIcons.nr_2,
    Icons.rocket_launch,
    Icons.rocket,
    Icons.snowboarding,
    Icons.sports_football,
    Icons.sunny,*/
  ];

  final List<_FlowIcon> _flowIcons = [];
  int _nextIconIndex = 0;
  DateTime? _lastTime;
  double _animationWidth = 0;
  double _animationHeight = 0;
  // =========================
  // Start
  // =========================
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_tick);
    _controller.forward();
  }

  // =========================
  // Neues Icon erzeugen
  // =========================
  void _spawnIcon() {
    final icon = icons[_nextIconIndex];
    final flowIcon = _FlowIcon(
      icon: icon,
      // Startposition oben links
      x: -_getIconWidth(icon),
      y: -iconSize,
      width: _getIconWidth(icon),
    );
    _flowIcons.add(flowIcon);
    _nextIconIndex++;
    if (_nextIconIndex >= icons.length) {
      _nextIconIndex = 0;
    }
  }

  // =========================
  // Prüfen, ob neues Icon
  // erzeugt werden soll
  // =========================
  void _checkForNewIcon() {
    if (_flowIcons.isEmpty) {
      _spawnIcon();
      return;
    }
    final firstIcon = _flowIcons.first;
    // Position entlang der diagonalen Bewegungsrichtung.
    //
    // Je größer x + y wird, desto weiter ist das
    // Icon auf seiner Diagonale gewandert.
    final currentPosition = firstIcon.x + firstIcon.y;
    final iconWidth = firstIcon.width;
    final requiredPosition = -iconWidth + iconSpacing;
    if (currentPosition >= requiredPosition) {
      _spawnIcon();
    }
  }

  // =========================
  // Breite des TTF-Icons
  // =========================
  double _getIconWidth(IconData icon) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontFamily: icon.fontFamily, fontSize: iconSize),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  // =========================
  // Animation
  // =========================
  void _tick() {
    final now = DateTime.now();
    if (_lastTime == null) {
      _lastTime = now;
      return;
    }
    final deltaTime = now.difference(_lastTime!).inMicroseconds / 1000000.0;
    _lastTime = now;
    if (!mounted) return;
    setState(() {
      // Bewegung diagonal:
      //
      //       ↘️
      //      ↘️
      //     ↘️
      //
      // x und y werden gleichzeitig erhöht.
      final movement = speed * deltaTime;
      for (final flowIcon in _flowIcons) {
        flowIcon.x += movement;
        flowIcon.y += movement;
      }
      // Icons entfernen, wenn sie rechts oder unten
      // vollständig aus dem sichtbaren Bereich sind.
      _flowIcons.removeWhere(
        (flowIcon) =>
            flowIcon.x > _animationWidth || flowIcon.y > _animationHeight,
      );
      _checkForNewIcon();
    });
  }

  // =========================
  // Icon entfernen
  // =========================
  void _removeIcon(_FlowIcon flowIcon) {
    if (!mounted) return;
    setState(() {
      _flowIcons.remove(flowIcon);
    });
  }

  // =========================
  // Oberfläche
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diagonal Icon Flow')),
      body: Column(
        children: [
          Expanded(
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
                            height: iconSize,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _removeIcon(flowIcon);
                              },
                              child: Icon(flowIcon.icon, size: iconSize),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
          // =========================
          // Button
          // =========================
          Padding(
            padding: const EdgeInsets.all(24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StartingPage()),
                  );
                },
                child: const Text('Zur nächsten Seite'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ============================================================
// Daten eines fließenden Icons
// ============================================================
class _FlowIcon {
  final IconData icon;
  double x;
  double y;
  final double width;
  _FlowIcon({
    required this.icon,
    required this.x,
    required this.y,
    required this.width,
  });
}
