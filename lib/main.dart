import 'dart:io';

import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const BazingaApp());
}

class BazingaApp extends StatelessWidget {
  const BazingaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Bazinga Animes',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF101014),
          useMaterial3: true,
        ),
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

  // O Blogger redireciona para o domínio do país (ex.: .blogspot.com.br).
  static final RegExp _blogHost =
      RegExp(r'^bazingaanimes\.blogspot\.[a-z]{2,3}(\.[a-z]{2})?$');

  // ID real do banner (usado só no APK release). Em debug usa o ID de TESTE
  // do Google, para evitar cliques acidentais em anúncios reais.
  static const String _realBannerId = 'ca-app-pub-7102905249789565/2731882102';
  static const String _testBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _iosTestBannerId =
      'ca-app-pub-3940256099942544/2934735716';

  String get _bannerId => Platform.isIOS
      ? _iosTestBannerId
      : (kReleaseMode ? _realBannerId : _testBannerId);

  late final WebViewController _controller;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  int _progress = 0;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _failed = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _failed = true);
            }
          },
          onNavigationRequest: (request) {
            // Iframes e recursos da própria página carregam dentro do app.
            if (!request.isMainFrame) return NavigationDecision.navigate;

            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            final host = uri.host.toLowerCase();
            final internal = (uri.scheme == 'https' || uri.scheme == 'http') &&
                (_blogHost.hasMatch(host) ||
                    host == 'accounts.google.com' ||
                    host == 'blogger.com' ||
                    host.endsWith('.blogger.com'));

            if (internal ||
                uri.scheme == 'about' ||
                uri.scheme == 'data' ||
                uri.scheme == 'blob') {
              return NavigationDecision.navigate;
            }

            // Links externos abrem no navegador, sem bloquear a navegação.
            launchUrl(uri, mode: LaunchMode.externalApplication)
                .catchError((_) => false);
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(home);

    // O AdMob só inicia depois que a tela abriu e o site começou a carregar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), _startAds);
    });
  }

  Future<void> _startAds() async {
    try {
      await MobileAds.instance.initialize();
      if (!mounted) return;
      final ad = BannerAd(
        adUnitId: _bannerId,
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
          onAdFailedToLoad: (ad, error) => ad.dispose(),
        ),
      );
      await ad.load();
    } catch (_) {
      // Falha de anúncio nunca deve atrapalhar o site.
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> _onBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _onBack();
        },
        child: Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                if (_progress < 100)
                  LinearProgressIndicator(value: _progress / 100, minHeight: 2),
                Expanded(
                  child: _failed
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Não foi possível carregar o site.'),
                              const SizedBox(height: 12),
                              FilledButton(
                                onPressed: () {
                                  setState(() => _failed = false);
                                  _controller.loadRequest(home);
                                },
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        )
                      : WebViewWidget(controller: _controller),
                ),
              ],
            ),
          ),
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
