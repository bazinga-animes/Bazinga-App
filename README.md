# Bazinga Animes — Android e iPhone

Aplicativo Flutter que abre https://bazingaanimes.blogspot.com/ em uma WebView.

## Como compilar

Instale Flutter e Android Studio (Android); para iOS, use um Mac com Xcode.

Na pasta deste projeto, execute:

```bash
flutter create --platforms=android,ios --project-name bazinga_animes .
flutter pub get
flutter run
```

Para gerar o APK Android:

```bash
flutter build apk --release
```

O APK ficará em `build/app/outputs/flutter-apk/app-release.apk`.

Para iOS, em um Mac:

```bash
flutter build ios --release
```

Configure a equipe de assinatura (Signing Team) no Xcode para instalar em iPhone ou distribuir. A publicação na App Store requer conformidade com as diretrizes da Apple; um app que apenas reproduz um website pode ser rejeitado.

## Configuração importante

- Ajuste o nome exibido, ícone e identificadores de pacote nos projetos Android e iOS gerados.
- Android precisa da permissão `android.permission.INTERNET` em `android/app/src/main/AndroidManifest.xml`, dentro de `<manifest>`:
  `<uses-permission android:name="android.permission.INTERNET" />`
- Alguns provedores de login, pagamentos e vídeo podem não funcionar em WebView e precisar de integração específica. Teste no dispositivo real.
- Links externos abrem no navegador padrão. Ajuste a política de navegação em `lib/main.dart` caso algum link do próprio site deva permanecer dentro do app.
- A página depende de internet.

## Limitações

Este ZIP é um **projeto-fonte**, não um APK ou IPA compilado. O ambiente de criação não tem Flutter, Android SDK ou Xcode instalados, portanto não foi possível compilar nem testar nos aparelhos.
