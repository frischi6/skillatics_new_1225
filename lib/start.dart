import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart'; // 1. IAP-Paket importieren
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skillatics/helper.dart';
import 'menuPage.dart';
import 'menuOptodrum.dart';

class StartingPage extends StatefulWidget {
  const StartingPage({super.key});

  @override
  State<StartingPage> createState() => _StartingPageState();
}

class _StartingPageState extends State<StartingPage> {
  // IAP Variablen & Instanzen
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  bool _isOptodrumUnlocked = false; // Standardmässig gesperrt
  bool _isLoadingProduct = true;
  ProductDetails? _optodrumProduct;

  // Produkt-ID aus der Google Play Console / App Store Connect
  static const String _kOptodrumProductId = 'optodrum_unlock';

  // Schlüssel für die lokale Speicherung der Freischaltung
  static const String _kPrefUnlocked = 'optodrum_unlocked';

  @override
  void initState() {
    super.initState();
    _loadCachedUnlock();

    // Listener ZUERST registrieren, bevor irgendetwas gekauft/wiederhergestellt wird
    _purchaseSub = _inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdate,
      onError: (e) => _showSnack('Fehler beim Kauf: $e'),
    );

    _initializeIAP();
  }

  @override
  void dispose() {
    _purchaseSub?.cancel();
    super.dispose();
  }

  // Gespeicherten Freischalt-Status laden (funktioniert auch offline)
  Future<void> _loadCachedUnlock() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(
      () => _isOptodrumUnlocked = prefs.getBool(_kPrefUnlocked) ?? false,
    );
  }

  // Freischalt-Status speichern und UI aktualisieren
  Future<void> _setUnlocked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kPrefUnlocked, value);
    if (!mounted) return;
    setState(() => _isOptodrumUnlocked = value);
  }

  Future<void> _initializeIAP() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      if (mounted) setState(() => _isLoadingProduct = false);
      return;
    }

    // Produktdetails (Preis etc.) aus den Stores laden
    final ProductDetailsResponse response = await _inAppPurchase
        .queryProductDetails({_kOptodrumProductId});

    if (response.productDetails.isNotEmpty && mounted) {
      _optodrumProduct = response.productDetails.first;
    }

    // Nur Android automatisch wiederherstellen; auf iOS läuft das über den Button
    // (sonst erscheint bei jedem App-Start ein Apple-ID-Login-Fenster)
    if (Platform.isAndroid) {
      await _inAppPurchase.restorePurchases();
    }

    if (mounted) setState(() => _isLoadingProduct = false);
  }

  // Wird aufgerufen, wenn sich der Kaufstatus ändert
  Future<void> _onPurchaseUpdate(List<PurchaseDetails> list) async {
    for (final p in list) {
      if (p.productID == _kOptodrumProductId) {
        switch (p.status) {
          case PurchaseStatus.purchased:
          case PurchaseStatus.restored:
            // Kauf war erfolgreich -> Feature freischalten!
            await _setUnlocked(true);
            break;
          case PurchaseStatus.error:
            _showSnack('Kauf fehlgeschlagen. Bitte erneut versuchen.');
            break;
          case PurchaseStatus.pending:
          case PurchaseStatus.canceled:
            break;
        }
      }

      // Für JEDE Transaktion abschliessen, nicht nur bei Erfolg (Pflicht!)
      if (p.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(p);
      }
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  // Den Bezahlvorgang für den Einmalkauf starten
  void _buyOptodrum() {
    if (_optodrumProduct == null) {
      _showSnack('Produktinformationen konnten nicht geladen werden.');
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: _optodrumProduct!,
    );
    // Da es ein dauerhafter Feature-Unlock ist, nutzen wir buyNonConsumable
    _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Klick-Logik für den Optodrum-Button
  void _handleOptodrumTap(BuildContext context) {
    if (_isOptodrumUnlocked) {
      // Wenn bereits gekauft -> Direkt in das Menu springen
      _openOptodrum(context);
    } else {
      // Wenn noch nicht gekauft -> Kauf-Dialog anzeigen
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF161B1F),
          title: const Text(
            'Optodrum freischalten',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Schalte das erweiterte Feature "Optodrum" für einmalig ${_optodrumProduct?.price ?? '10.-'} frei.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Abbrechen',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _inAppPurchase.restorePurchases();
              },
              child: const Text(
                'Käufe wiederherstellen',
                style: TextStyle(color: Colors.white70),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
              ),
              onPressed: () {
                Navigator.pop(context);
                _buyOptodrum();
              },
              child: const Text(
                'Jetzt kaufen',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }
  }

  void _openOptodrum(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuOptodrum(
          title: AppHelper.getDefaultOptodrum('title'),
          currentCountry: AppHelper.getDefaultOptodrum('currentCountry'),
          listSelectedArrowsPerColor: AppHelper.getDefaultOptodrum(
            'listSelectedArrowsPerColor',
          ),
          listSelectedNumbersPerColor: AppHelper.getDefaultOptodrum(
            'listSelectedNumbersPerColor',
          ),
          listSelectedShapesPerColor: AppHelper.getDefaultOptodrum(
            'listSelectedShapesPerColor',
          ),
          listSelectedAlphabetlettersPerColor: AppHelper.getDefaultOptodrum(
            'listSelectedAlphabetlettersPerColor',
          ),
          listSelectedBackgroundcolors: AppHelper.getDefaultOptodrum(
            'listSelectedBackgroundcolors',
          ),
          listSelectedStroopcolors: AppHelper.getDefaultOptodrum(
            'listSelectedStroopcolors',
          ),
          secLengthRound: AppHelper.getDefaultOptodrum('secLengthRound'),
          secLengthRest: AppHelper.getDefaultOptodrum('secLengthRest'),
          anzRounds: AppHelper.getDefaultOptodrum('anzRounds'),
          nr_individual: AppHelper.getDefaultOptodrum('nr_individual'),
          nr_from: AppHelper.getDefaultOptodrum('nr_from'),
          nr_to: AppHelper.getDefaultOptodrum('nr_to'),
          nr_skip: AppHelper.getDefaultOptodrum('nr_skip'),
          speedlevel: AppHelper.getDefaultOptodrum('speedlevel'),
          secChangeBackgrcolor: AppHelper.getDefaultOptodrum(
            'secChangeBackgrcolor',
          ),
          moveDirection: AppHelper.getDefaultOptodrum('moveDirection'),
          gleicheNacheinanderOk: AppHelper.getDefaultOptodrum(
            'gleicheNacheinanderOk',
          ),
          metronomAktiv: AppHelper.getDefaultOptodrum('metronomAktiv'),
          metronomBPM: AppHelper.getDefaultOptodrum('metronomBPM'),
        ),
      ),
    );
  }

  // Parameter für Randomcolor-Modus
  final int anzColorsOnPage = 2;
  final int secChangeColor = 5;
  final int secLengthRound = 210;
  final int secLengthRest = 90;
  final int anzRounds = 5;
  final bool isElemProSeiteEinmalig = false;
  final bool isStroopActive = false;

  @override
  Widget build(BuildContext context) {
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    return Scaffold(
      backgroundColor: const Color.fromRGBO(15, 15, 36, 1),
      appBar: AppBar(
        toolbarHeight: isPortrait ? 140.0 : 80.0,
        title: Text(
          'Brain Training\nSkillatics',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isPortrait ? 32 : 24,
            color: const Color.fromRGBO(188, 250, 0, 1),
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(15, 15, 36, 1),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(height: 2.0),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: isPortrait
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: isPortrait ? 40 : 10),
                        // Erster Button: Kognition (bleibt unverändert)
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
                                  listSelectedColors:
                                      AppHelper.getDefaultKognitiv(
                                        'listSelectedColors',
                                      ),
                                  listSelectedArrowsPerColor:
                                      AppHelper.getDefaultKognitiv(
                                        'listSelectedArrowsPerColor',
                                      ),
                                  listSelectedNumbersPerColor:
                                      AppHelper.getDefaultKognitiv(
                                        'listSelectedNumbersPerColor',
                                      ),
                                  listSelectedShapesPerColor:
                                      AppHelper.getDefaultKognitiv(
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
                                  listSelectedStroopcolors:
                                      AppHelper.getDefaultKognitiv(
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
                                  anzRounds: AppHelper.getDefaultKognitiv(
                                    'anzRounds',
                                  ),
                                  isElemProSeiteEinmalig:
                                      AppHelper.getDefaultKognitiv(
                                        'isElemProSeiteEinmalig',
                                      ),
                                  nr_individual: AppHelper.getDefaultKognitiv(
                                    'nr_individual',
                                  ),
                                  nr_from: AppHelper.getDefaultKognitiv(
                                    'nr_from',
                                  ),
                                  nr_to: AppHelper.getDefaultKognitiv('nr_to'),
                                  nr_skip: AppHelper.getDefaultKognitiv(
                                    'nr_skip',
                                  ),
                                  metronomAktiv: AppHelper.getDefaultKognitiv(
                                    'metronomAktiv',
                                  ),
                                  metronomBPM: AppHelper.getDefaultKognitiv(
                                    'metronomBPM',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 26),
                        // Zweiter Button: Optodrum (Dynamisch mit Schloss oder freigeschaltet)
                        CustomGlowButton(
                          title: 'Optodrum',
                          subtitle: _isLoadingProduct
                              ? 'Lade Status...'
                              : (_isOptodrumUnlocked
                                    ? 'Blickverfolgung (Freigeschaltet)'
                                    : 'Blickverfolgung (NEU, ${_optodrumProduct?.price ?? "10.-"})'),
                          icon: Icons.visibility,
                          glowColor: _isOptodrumUnlocked
                              ? Colors.pinkAccent
                              : Colors.grey,
                          onTap: () => _handleOptodrumTap(context),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: isPortrait ? 20.0 : 16.0,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 47,
                          child: TextButton(
                            onPressed: () =>
                                AppHelper.showSkillaticsInfos(context),
                            child: Image.asset(
                              'assets/skillatics_neon_ausgeschnitten.png',
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Generiert Button mit Glow-Effekt
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
