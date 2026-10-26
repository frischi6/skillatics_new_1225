import 'package:flutter/material.dart';
import 'package:skillatics/helper.dart';
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
      backgroundColor: Color.fromRGBO(15, 15, 36, 1),
      appBar: AppBar(
        toolbarHeight: 140.0,
        title: const Text(
          'Brain Training\nSkillatics',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 32,
            color: Color.fromRGBO(188, 250, 0, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(15, 15, 36, 1),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0), // Höhe der Linie
          child: Container(
            // color: Color.fromRGBO(188, 250, 0, 1), // Farbe der Linie
            height: 2.0, // Dicke der Linie
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 120),
            // Erster Button: Kognition
            CustomGlowButton(
              title: 'Kognition',
              subtitle: 'Kognitives Training',
              icon: Icons.psychology,
              glowColor: const Color(0xFF00E5FF),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyHomePage(
                      title: AppHelper.getDefaultKognitiv('title'),
                      currentCountry: AppHelper.getDefaultKognitiv(
                        'currentCountry',
                      ),
                      listSelectedColors: AppHelper.getDefaultKognitiv(
                        'listSelectedColors',
                      ),
                      listSelectedArrowsPerColor: AppHelper.getDefaultKognitiv(
                        'listSelectedArrowsPerColor',
                      ),
                      listSelectedNumbersPerColor: AppHelper.getDefaultKognitiv(
                        'listSelectedNumbersPerColor',
                      ),
                      listSelectedShapesPerColor: AppHelper.getDefaultKognitiv(
                        'listSelectedShapesPerColor',
                      ),
                      listSelectedAlphabetlettersPerColor:
                          AppHelper.getDefaultKognitiv(
                            'listSelectedAlphabetlettersPerColor',
                          ),
                      listSelectedBackgroundcolors:
                          AppHelper.getDefaultKognitiv(
                            'listSelectedBackgroundcolors',
                          ),
                      listSelectedStroopcolors: AppHelper.getDefaultKognitiv(
                        'listSelectedStroopcolors',
                      ),
                      anzColorsOnPage: AppHelper.getDefaultKognitiv(
                        'anzColorsOnPage',
                      ),
                      secChangeColor: AppHelper.getDefaultKognitiv(
                        'secChangeColor',
                      ),
                      secLengthRound: AppHelper.getDefaultKognitiv(
                        'secLengthRound',
                      ),
                      secLengthRest: AppHelper.getDefaultKognitiv(
                        'secLengthRest',
                      ),
                      anzRounds: AppHelper.getDefaultKognitiv('anzRounds'),
                      isElemProSeiteEinmalig: AppHelper.getDefaultKognitiv(
                        'isElemProSeiteEinmalig',
                      ),
                      nr_individual: AppHelper.getDefaultKognitiv(
                        'nr_individual',
                      ),
                      nr_from: AppHelper.getDefaultKognitiv('nr_from'),
                      nr_to: AppHelper.getDefaultKognitiv('nr_to'),
                      nr_skip: AppHelper.getDefaultKognitiv('nr_skip'),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 26),
            // Zweiter Button: Optodrum -> öffnet Page2
            CustomGlowButton(
              title: 'Optodrum',
              subtitle: 'Blickverfolgung (NEU)',
              icon: Icons.visibility,
              glowColor: Colors.pinkAccent, // Neon-Cyan/Blau
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuOptodrum(
                      title: AppHelper.getDefaultOptodrum('title'),
                      currentCountry: AppHelper.getDefaultOptodrum(
                        'currentCountry',
                      ),
                      listSelectedArrowsPerColor: AppHelper.getDefaultOptodrum(
                        'listSelectedArrowsPerColor',
                      ),
                      listSelectedNumbersPerColor: AppHelper.getDefaultOptodrum(
                        'listSelectedNumbersPerColor',
                      ),
                      listSelectedShapesPerColor: AppHelper.getDefaultOptodrum(
                        'listSelectedShapesPerColor',
                      ),
                      listSelectedAlphabetlettersPerColor:
                          AppHelper.getDefaultOptodrum(
                            'listSelectedAlphabetlettersPerColor',
                          ),
                      listSelectedBackgroundcolors:
                          AppHelper.getDefaultOptodrum(
                            'listSelectedBackgroundcolors',
                          ),
                      listSelectedStroopcolors: AppHelper.getDefaultOptodrum(
                        'listSelectedStroopcolors',
                      ),
                      secLengthRound: AppHelper.getDefaultOptodrum(
                        'secLengthRound',
                      ),
                      secLengthRest: AppHelper.getDefaultOptodrum(
                        'secLengthRest',
                      ),
                      anzRounds: AppHelper.getDefaultOptodrum('anzRounds'),
                      nr_individual: AppHelper.getDefaultOptodrum(
                        'nr_individual',
                      ),
                      nr_from: AppHelper.getDefaultOptodrum('nr_from'),
                      nr_to: AppHelper.getDefaultOptodrum('nr_to'),
                      nr_skip: AppHelper.getDefaultOptodrum('nr_skip'),
                      speedlevel: AppHelper.getDefaultOptodrum('speedlevel'),
                      secChangeBackgrcolor: AppHelper.getDefaultOptodrum(
                        'secChangeBackgrcolor',
                      ),
                      moveDirection: AppHelper.getDefaultOptodrum(
                        'moveDirection',
                      ),
                      gleicheNacheinanderOk: AppHelper.getDefaultOptodrum(
                        'gleicheNacheinanderOk',
                      ),
                    ),
                  ),
                );
              },
            ),
            Spacer(),
            SizedBox(
              height: 47,
              child: TextButton(
                onPressed: () => AppHelper.showSkillaticsInfos(context),
                child: Image.asset(
                  'assets/skillatics_neon_ausgeschnitten.png',
                  height: 50, // Feste Höhe für das Bild (optional)
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

///Als Class damit nicht zweimal derselbe Code für die beiden Buttons geschrieben werden muss
///Generiert Button mit Glow-Effekt (erstellt von Gemini)
class CustomGlowButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color glowColor;
  final VoidCallback onTap;

  const CustomGlowButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.glowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF161B1F),
          borderRadius: BorderRadius.circular(35),
          border: Border.all(
            color: glowColor.withValues(alpha: 0.7),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: glowColor.withValues(alpha: 0.35),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: glowColor, size: 36),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: glowColor == const Color(0xFF76FF03)
                          ? const Color(0xFFB9FF66)
                          : glowColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[400], fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70, size: 26),
          ],
        ),
      ),
    );
  }
}
