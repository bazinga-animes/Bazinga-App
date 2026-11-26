import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Mostra a interface imediatamente. Uma falha no SDK de anúncios não deve
  // impedir o aplicativo de abrir.
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFF0000),
            brightness: Brightness.dark,
          ),
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

  // IDs oficiais de teste do Google. Trocar somente pelos IDs da conta do dono.
  static const String _androidBannerTestId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _iosBannerTestId =
      'ca-app-pub-3940256099942544/2934735716';

  String get _bannerAdUnitId =>
      Platform.isIOS ? _iosBannerTestId : _androidBannerTestId;

  late final WebViewController controller;
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;
  bool _pageFailed = false;
  bool _adsInitialized = false;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _createWebView();
    // Só inicia o AdMob depois que a tela já abriu e o site começou a carregar.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(seconds: 3), _initializeAdsSafely);
    });
  }

  // O Blogger redireciona para o domínio do país (ex.: .blogspot.com.br).
  // Todos eles precisam abrir dentro do aplicativo.
  static final RegExp _blogHost =
      RegExp(r'^bazingaanimes\.blogspot\.[a-z]{2,3}(\.[a-z]{2})?$');

  static bool _isInternalHost(String host) =>
      _blogHost.hasMatch(host) ||
      host == 'accounts.google.com' ||
      host == 'blogger.com' ||
      host.endsWith('.blogger.com');

  void _createWebView() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101014))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) {
            if (mounted) setState(() => _progress = value);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _pageFailed = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _pageFailed = true);
            }
          },
          onNavigationRequest: (request) async {
            // Quadros internos da página (iframes, comentários, vídeos, etc.)
            // sempre carregam dentro do app.
            if (!request.isMainFrame) return NavigationDecision.navigate;

            final uri = Uri.tryParse(request.url);
            if (uri == null) return NavigationDecision.prevent;

            if (uri.scheme == 'about' ||
                uri.scheme == 'data' ||
                uri.scheme == 'blob' ||
                uri.scheme == 'javascript') {
              return NavigationDecision.navigate;
            }

            if (uri.scheme != 'https' && uri.scheme != 'http') {
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
              return NavigationDecision.prevent;
            }

            if (!_isInternalHost(uri.host.toLowerCase())) {
              try {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              } catch (_) {}
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(home);
  }

  Future<void> _initializeAdsSafely() async {
    try {
      await MobileAds.instance.initialize();
      _adsInitialized = true;
      if (mounted) _loadBanner();
    } catch (_) {
      // O site continua disponível mesmo se o AdMob não inicializar.
    }
  }

  void _loadBanner() {
    if (!_adsInitialized || !mounted || _bannerAd != null) return;
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
          // Falha de anúncio não fecha nem bloqueia o aplicativo.
        },
      ),
    );
    ad.load();
  }

  Future<void> _goBack() async {
    try {
      if (await controller.canGoBack()) {
        await controller.goBack();
      } else {
        await SystemNavigator.pop();
      }
    } catch (_) {
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
          if (!didPop) _goBack();
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF101014),
          body: SafeArea(
            child: Column(
              children: [
                if (_progress < 100)
                  LinearProgressIndicator(
                    value: _progress / 100,
                    minHeight: 2,
                  ),
                Expanded(
                  child: _pageFailed
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'Não foi possível carregar o Bazinga Animes.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: () {
                                    setState(() => _pageFailed = false);
                                    controller.loadRequest(home);
                                  },
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        )
                      : WebViewWidget(controller: controller),
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
                    child: Center(child: AdWidget(ad: _bannerAd!)),
                  ),
                )
              : null,
        ),
      );
}
