# Bazinga Animes — AdMob e ícone

Projeto Flutter do aplicativo Bazinga Animes, que abre https://bazingaanimes.blogspot.com/.

## Alterações desta versão
- Inicializa a interface antes do SDK do AdMob para que uma falha de anúncios não impeça a abertura do app.
- Inicialização do AdMob protegida por `try/catch`; o site continua acessível se o SDK falhar.
- Banner oficial de teste do Google, sem IDs reais de monetização.
- Ícone do app baseado na logo fornecida, configurado para Android e iOS.
- Workflow do GitHub Actions gera estrutura Android/iOS e compila APK Android.

## Compilar
O GitHub Actions executa a compilação ao enviar os arquivos para `main` ou manualmente em Actions.

O workflow gera o APK Android. Para gerar IPA de iPhone é necessário executar a compilação iOS em um Mac com Xcode e configurar assinatura Apple.

## Observação de diagnóstico
A alteração reduz causas prováveis de falha na inicialização, especialmente uma falha do SDK de anúncios antes de `runApp`. Se o aplicativo ainda fechar, será necessário obter o erro de execução do Android (Logcat), pois o log de compilação não identifica a exceção que ocorre no aparelho.
