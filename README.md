# Bazinga Animes

WebView de https://bazingaanimes.blogspot.com/ com banner AdMob, confirmação ao sair
e vídeo em tela cheia na horizontal.

O workflow gera `Bazinga-Animes.apk` (release, R8 desligado: necessário para o AdMob não fechar o app).

Intersticial: aparece ao abrir uma nova página, no máximo 1 a cada 5 minutos (constante _interstitialInterval em lib/main.dart). ID real do intersticial: ca-app-pub-7102905249789565/7503495509.
