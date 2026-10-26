# Bazinga Animes — Gerar APK sem instalar programas

Este pacote contém **código-fonte**, não um APK pronto.

1. Entre em https://github.com e crie uma conta (se ainda não tiver).
2. Crie um repositório **privado** chamado `bazinga-animes-app`.
3. Envie os arquivos do projeto para o repositório, incluindo a pasta oculta `.github/workflows/android-apk.yml` (ao extrair o ZIP, habilite a exibição de arquivos ocultos se necessário). Você pode usar `Add file > Upload files` ou Git.
4. Abra a aba **Actions**, selecione **Gerar APK Bazinga Animes** e clique em **Run workflow**.
5. Aguarde o build. Na execução concluída, baixe o artefato **Bazinga-Animes-APK**.
6. Extraia o ZIP do artefato: nele estará `app-release.apk`.
7. Transfira o APK para o Android, abra e autorize a instalação desta origem se solicitado.

Observações:
- GitHub Actions pode pedir que você habilite workflows para o repositório. A compilação requer internet e pode falhar por mudanças de versões; nesse caso, confira os logs em Actions.
- O APK de release gerado dessa maneira usa a assinatura de desenvolvimento padrão do Flutter; para publicar na Play Store, configure uma chave de assinatura própria e um AAB.
- O funcionamento de login, vídeo, Premium e pagamentos precisa ser testado no aparelho. Links externos são abertos fora do app.
- iPhone exige um Mac com Xcode, assinatura Apple e uma compilação iOS separada.
