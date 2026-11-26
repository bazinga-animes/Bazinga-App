import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  late final WebViewController _controller;
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
        ),
      );
}
