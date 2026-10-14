import 'package:flutter/material.dart';
import 'package:skillatics/custom_icons_icons.dart';
import 'package:skillatics/stroop_icons.dart';
import 'start.dart';
import 'directions_optodrum.dart';

class TrainingOptodrum extends StatefulWidget {
  final MovementDirection direction; // Die im Menü gewählte Bewegungsrichtung
  final int speedlevel;

  const TrainingOptodrum({
    super.key,
    required this.direction,
    required this.speedlevel,
  });

  @override
  State<TrainingOptodrum> createState() => _TrainingOptodrumState();
}

class _TrainingOptodrumState extends State<TrainingOptodrum>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const double iconSize = 60; // Grösse aller Icons
  static const double iconSpacing = 30; // Exakter Abstand zwischen den Icons
  static const double speed = 200; // Geschwindigkeit in Pixel pro Sekunde

  final List<IconData> icons = [
    CustomIcons.a,
    CustomIcons.b,
    CustomIcons.c,
    CustomIcons.d,
    CustomIcons.e,
    CustomIcons.f,
    StroopIcons.stroop_weiss,
    StroopIcons.stroop_rot,
    StroopIcons.stroop_gruen,
    StroopIcons.stroop_blau,
    StroopIcons.stroop_violett,
    CustomIcons.triangle,
    CustomIcons.square,
    CustomIcons.circle,
    Icons.north,
    Icons.north_east,
    Icons.west,
    Icons.south,
    Icons.south_east,
  ];

  final List<_FlowIcon> _flowIcons = [];
  int _nextIconIndex = 0;
  DateTime? _lastTime;
  double _animationWidth = 0;
  double _animationHeight = 0;

  @override
  void initState() {
    super.initState();

    // Initialisiert den Animations-Controller für den Endlos-Loop
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 1),
    )..addListener(_tick);

    icons.shuffle();
    _controller.forward();
  }

  /// Gibt den normalisierten Richtungsvektor (vx, vy) für die aktive Richtung zurück
  (double, double) _getVelocityVector() {
    const double invSqrt2 =
        0.70710678118; // 1 / sqrt(2) für diagonale Bewegungen
    switch (widget.direction) {
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

  /// Erzeugt ein neues Icon an der korrekten Startposition basierend auf der Richtung
  void _spawnIcon(double width, double height) {
    final icon = icons[_nextIconIndex];
    final iconWidth = _getIconWidth(icon);

    double startX = 0;
    double startY = 0;

    // Bestimmt den Startpunkt außerhalb des Sichtbereichs je nach Bewegungsrichtung
    switch (widget.direction) {
      case MovementDirection.topLeftToBottomRight:
        startX = -iconWidth;
        startY = -iconSize;
        break;
      case MovementDirection.bottomRightToTopLeft:
        startX = width;
        startY = height;
        break;
      case MovementDirection.topRightToBottomLeft:
        startX = width;
        startY = -iconSize;
        break;
      case MovementDirection.bottomLeftToTopRight:
        startX = -iconWidth;
        startY = height;
        break;
      case MovementDirection.topCenterToBottomCenter:
        startX = (width - iconWidth) / 2;
        startY = -iconSize;
        break;
      case MovementDirection.bottomCenterToTopCenter:
        startX = (width - iconWidth) / 2;
        startY = height;
        break;
      case MovementDirection.leftToRightCenter:
        startX = -iconWidth;
        startY = (height - iconSize) / 2;
        break;
      case MovementDirection.rightToLeftCenter:
        startX = width;
        startY = (height - iconSize) / 2;
        break;
    }

    final flowIcon = _FlowIcon(
      icon: icon,
      x: startX,
      y: startY,
      startX: startX,
      startY: startY,
      width: iconWidth,
    );

    _flowIcons.add(flowIcon);
    _nextIconIndex = (_nextIconIndex + 1) % icons.length;
  }

  /// Prüft, ob das letzte Icon weit genug gewandert ist, um das nächste zu spawnen
  void _checkForNewIcon(double width, double height) {
    if (_flowIcons.isEmpty) {
      _spawnIcon(width, height);
      return;
    }

    final lastIcon = _flowIcons.last;
    final (vx, vy) = _getVelocityVector();

    // Berechnet die exakte Distanz, die das letzte Icon seit dem Start zurückgelegt hat
    final distanceTraveled =
        (lastIcon.x - lastIcon.startX) * vx +
        (lastIcon.y - lastIcon.startY) * vy;

    // Sobald genügend Platz geschaffen wurde, wird das nächste Icon erzeugt
    if (distanceTraveled >= lastIcon.width + iconSpacing) {
      _spawnIcon(width, height);
    }
  }

  /// Prüft, ob ein Icon den sichtbaren Bereich vollständig verlassen hat
  bool _isOutOfBounds(_FlowIcon flowIcon, double width, double height) {
    switch (widget.direction) {
      case MovementDirection.topLeftToBottomRight:
        return flowIcon.x > width || flowIcon.y > height;
      case MovementDirection.bottomRightToTopLeft:
        return flowIcon.x + flowIcon.width < 0 || flowIcon.y + iconSize < 0;
      case MovementDirection.topRightToBottomLeft:
        return flowIcon.x + flowIcon.width < 0 || flowIcon.y > height;
      case MovementDirection.bottomLeftToTopRight:
        return flowIcon.x > width || flowIcon.y + iconSize < 0;
      case MovementDirection.topCenterToBottomCenter:
        return flowIcon.y > height;
      case MovementDirection.bottomCenterToTopCenter:
        return flowIcon.y + iconSize < 0;
      case MovementDirection.leftToRightCenter:
        return flowIcon.x > width;
      case MovementDirection.rightToLeftCenter:
        return flowIcon.x + flowIcon.width < 0;
    }
  }

  /// Berechnet die präzise Breite einer Glyph-Schriftart
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

  /// Steuert die Animationsschleife pro Frame
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
      final (vx, vy) = _getVelocityVector();
      final movement = speed * deltaTime;
      final deltaX = movement * vx;
      final deltaY = movement * vy;

      // Aktualisiert die Position aller aktiven Icons einheitlich
      for (final flowIcon in _flowIcons) {
        flowIcon.x += deltaX;
        flowIcon.y += deltaY;
      }

      // Entfernt Icons, die ausserhalb des Bildschirms sind
      _flowIcons.removeWhere(
        (flowIcon) =>
            _isOutOfBounds(flowIcon, _animationWidth, _animationHeight),
      );

      _checkForNewIcon(_animationWidth, _animationHeight);
    });
  }

  /// Entfernt ein angetipptes Icon manuell
  void _removeIcon(_FlowIcon flowIcon) {
    if (!mounted) return;
    setState(() {
      _flowIcons.remove(flowIcon);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Icon Flow Training')),
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
                              onTap: () => _removeIcon(flowIcon),
                              child: Icon(
                                flowIcon.icon,
                                size: iconSize,
                                color: Colors.green,
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
                child: const Text('Back to Start'),
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

/// Erweitertes Datenmodell zur Speicherung von Start- und aktueller Position
class _FlowIcon {
  final IconData icon;
  double x;
  double y;
  final double startX;
  final double startY;
  final double width;

  _FlowIcon({
    required this.icon,
    required this.x,
    required this.y,
    required this.startX,
    required this.startY,
    required this.width,
  });
}
