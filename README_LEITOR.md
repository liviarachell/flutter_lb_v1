# lêBrasil — melhorias do leitor

## O que foi implementado

- Leitor interno para abrir uma obra ao tocar em **Continuar / Ler novamente**.
- Layout de leitura inspirado na referência enviada: título, autor, linha divisória, capítulos com marcador azul e texto centralizado.
- Percentual fixo no canto superior esquerdo, calculado pelo ponto real da rolagem.
- Progresso salvo por livro no dispositivo e refletido nas telas de Home, Suas Leituras e Seu Progresso.
- Modo claro/escuro exclusivo para a tela de leitura.
- Controles `-` e `+` para alterar o tamanho da fonte.
- Botão de voltar no leitor.
- Botão de voltar na tela de cadastro.
- Login somente com **Email + Senha**.
- Cadastro continua solicitando usuário, email, senha e confirmação.
- Alteração de senha com botão **Salvar nova senha**, persistindo a nova senha imediatamente.
- As obras configuradas usam fontes online de acesso público; por isso o primeiro carregamento do texto precisa de internet.

## Dependências novas

No `pubspec.yaml` foram adicionados:

- `http`
- `html`
- `shared_preferences`

Depois de abrir o projeto:

```bash
flutter pub get
flutter run
```

## Internet no Android

O projeto enviado não contém a pasta `android/`. Se o seu projeto Flutter completo não tiver permissão de internet no `AndroidManifest.xml`, adicione dentro de `<manifest>`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Observação sobre as obras

As URLs do leitor apontam para páginas públicas de leitura. Dom Casmurro, O Cortiço, O Primo Basílio e Iracema usam edições disponibilizadas pelo Project Gutenberg; Vidas Secas usa a página de leitura da Literatura Online.

Para uma versão definitiva/offline do TCC, o ideal é colocar os textos autorizados em `assets/books/` e trocar o serviço remoto por leitura local.
