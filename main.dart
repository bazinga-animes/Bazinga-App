import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  late final WebViewController controller;
  int progress = 0;
  bool failed = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF101014))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (value) { if (mounted) setState(() => progress = value); },
        onPageStarted: (_) { if (mounted) setState(() => failed = false); },
        onWebResourceError: (error) {
          if (error.isForMainFrame == true && mounted) setState(() => failed = true);
        },
        onNavigationRequest: (request) async {
          final uri = Uri.tryParse(request.url);
          if (uri == null) return NavigationDecision.prevent;
          if (uri.scheme != 'https' && uri.scheme != 'http') {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            return NavigationDecision.prevent;
          }
          // Open non-Blogger destinations in the default browser.
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

  Future<void> back() async {
    if (await controller.canGoBack()) {
      await controller.goBack();
    } else {
      await SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) { if (!didPop) back(); },
    child: Scaffold(
      backgroundColor: const Color(0xFF101014),
      body: SafeArea(
        child: Column(children: [
          if (progress < 100) LinearProgressIndicator(value: progress / 100, minHeight: 2),
          Expanded(child: failed
            ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Não foi possível carregar o Bazinga Animes.'),
                const SizedBox(height: 12),
                FilledButton(onPressed: () => controller.loadRequest(home), child: const Text('Tentar novamente')),
              ]))
            : WebViewWidget(controller: controller)),
        ]),
      ),
    ),
  );
}
