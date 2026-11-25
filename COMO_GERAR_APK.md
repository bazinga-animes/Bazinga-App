# Bazinga Animes — AdMob integrado (modo de teste)

Projeto Flutter que abre https://bazingaanimes.blogspot.com/ em uma WebView e exibe um banner nativo do Google AdMob na parte inferior do aplicativo.

## O que foi integrado

- Plugin oficial `google_mobile_ads`.
- Inicialização do SDK antes de abrir o app.
- Banner AdMob nativo abaixo da WebView (não cobre o conteúdo do site).
- IDs oficiais de teste do Google para Android e iOS.
- O app continua funcionando se o anúncio não carregar.
- O workflow do GitHub Actions configura o App ID de teste do AdMob no Android e gera o APK.

Os anúncios que já existem no Blogger continuam independentes. Este banner é exibido pelo aplicativo, fora da página web.

## Gerar APK no GitHub

1. Envie o conteúdo deste ZIP ao repositório GitHub, substituindo os arquivos correspondentes.
2. Confirme o envio (Commit changes).
3. Abra Actions e execute `Gerar APK Bazinga Animes`.
4. Quando a execução terminar com sucesso, baixe o Artifact `Bazinga-Animes-APK-AdMob-Teste`.
5. Extraia o ZIP do Artifact e instale o APK em um Android.

## Importante: IDs de teste

Este projeto usa IDs de demonstração oficiais do Google:
- App ID Android: `ca-app-pub-3940256099942544~3347511713`
- Banner Android: `ca-app-pub-3940256099942544/6300978111`
- Banner iOS: `ca-app-pub-3940256099942544/2934735716`

Eles são somente para desenvolvimento/teste e não geram receita. Não clique em anúncios de produção para testar. A documentação do Google recomenda anúncios de teste para evitar atividade inválida.

## Ativar anúncios reais depois

Antes de publicar/monetizar, crie no AdMob:
- Um aplicativo Android e copie o App ID (formato `ca-app-pub-...~...`).
- Um bloco de anúncio Banner para Android e copie o ID (formato `ca-app-pub-.../...`).
- Se for publicar para iOS, crie também o app iOS e seu App ID e bloco de banner iOS.

Depois:
1. No workflow `.github/workflows/android-apk.yml`, troque o App ID de teste pelo App ID Android real.
2. Em `lib/main.dart`, substitua `_androidBannerTestId` pelo ID de banner Android real.
3. Para iOS, em `ios/Runner/Info.plist`, adicione `GADApplicationIdentifier` com o App ID iOS real; substitua `_iosBannerTestId` pelo ID de banner iOS real.
4. Gere e teste uma nova compilação.

**Não envie IDs de blocos reais para teste de desenvolvimento**; use sempre os IDs de teste até validar a integração.

## iPhone / iOS

O workflow incluído gera apenas APK Android. Para iOS, em um Mac com Xcode:
```bash
flutter create --platforms=ios --project-name bazinga_animes --org com.bazingaanimes .
flutter pub get
```
Adicione ao `ios/Runner/Info.plist`, dentro do `<dict>`:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
```
Esse é o App ID de teste iOS. Para publicação, substitua pelo App ID da sua conta AdMob iOS. Compile/assine com Xcode.

## Observações

- A integração adiciona um banner nativo do app. Os anúncios que já aparecem no Blogger não são removidos.
- A aprovação e a veiculação de anúncios reais dependem da análise e das políticas do AdMob, bem como da configuração da conta e do app.
- Um app que é essencialmente um WebView pode ter questões de qualidade/revisão em lojas e redes de anúncios; integração técnica não garante aprovação nem receita.
- O projeto ainda precisa ser compilado e testado em aparelhos reais. O ambiente desta edição não executa Flutter/Android SDK/Xcode.
