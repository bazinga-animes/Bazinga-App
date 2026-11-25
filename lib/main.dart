import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  runApp(const BazingaApp());
}

class BazingaApp extends StatelessWidget {
  const BazingaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bazinga Animes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const BazingaHome(),
      );
}

class BazingaHome extends StatefulWidget {
  const BazingaHome({super.key});

  @override
  State<BazingaHome> createState() => _BazingaHomeState();
}

class _BazingaHomeState extends State<BazingaHome> {
  static final Uri home = Uri.parse('https://bazingaanimes.blogspot.com/');

  // IDs oficiais de teste do Google. Substituir pelos IDs da sua conta
  // somente depois de testar a integração.
  static const String _androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';

  String get _bannerAdUnitId =>
      Platform.isIOS ? _iosBannerTestId : _androidBannerTestId;

  late final WebViewController controller;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  int progress = 0;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    _loadBanner();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101014))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (value) {
          if (mounted) setState(() => progress = value);
        },
        onPageStarted: (_) {
          if (mounted) setState(() => failed = false);
        },
        onWebResourceError: (error) {
          if (error.isForMainFrame == true && mounted) {
            setState(() => failed = true);
          }
        },
        onNavigationRequest: (request) async {
          final uri = Uri.tryParse(request.url);
          if (uri == null) return NavigationDecision.prevent;
          if (uri.scheme != 'https' && uri.scheme != 'http') {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          final host = uri.host.toLowerCase();
          if (host != 'bazingaanimes.blogspot.com' &&
              host != 'accounts.google.com' &&
              !host.endsWith('.blogger.com') &&
              host != 'blogger.com') {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ))
      ..loadRequest(home);
  }

  void _loadBanner() {
    final ad = BannerAd(
      adUnitId: _bannerAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          setState(() {
            _bannerAd = ad as BannerAd;
            _bannerLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          // O app continua funcionando normalmente se não houver anúncio.
        },
      ),
    );
    ad.load();
  }

  Future<void> back() async {
    if (await controller.canGoBack()) {
      await controller.goBack();
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) back();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF101014),
          body: SafeArea(
            child: Column(children: [
              if (progress < 100)
                LinearProgressIndicator(
                  value: progress / 100,
                  minHeight: 2,
                ),
              Expanded(
                child: failed
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Não foi possível carregar o Bazinga Animes.',
                            ),
                            const SizedBox(height: 12),
                            FilledButton(
                              onPressed: () => controller.loadRequest(home),
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      )
                    : WebViewWidget(controller: controller),
              ),
            ]),
          ),
          // Banner nativo do AdMob fica fora da WebView, sem cobrir o site.
          bottomNavigationBar: _bannerLoaded && _bannerAd != null
              ? SafeArea(
                  top: false,
                  child: SizedBox(
                    width: _bannerAd!.size.width.toDouble(),
                    height: _bannerAd!.size.height.toDouble(),
                    child: AdWidget(ad: _bannerAd!),
                  ),
                )
              : null,
        ),
      );
}
