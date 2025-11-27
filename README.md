# 📱 **Denun – Sistema de Denúncias Urbanas**

**Denun** é um aplicativo multiplataforma desenvolvido em **Flutter**, integrado aos serviços do **Firebase**, projetado para facilitar o registro de problemas urbanos por cidadãos.  
A ferramenta permite enviar denúncias com descrição, localização e mídia (fotos/vídeos) diretamente para a base de dados, tornando o processo mais simples, rápido e transparente.

---

## 🎯 **Objetivo do Sistema**

Permitir que moradores reportem problemas da cidade — **buracos, lixo, iluminação, vandalismo**, entre outros — e que as informações sejam registradas de forma **estrutururada, segura e acessível**.

---

## 📂 **Conteúdo do Repositório**

Este repositório contém todos os artefatos exigidos pela disciplina, organizados nos seguintes diretórios:

### ✔️ **Código-fonte completo**
Local:
```
/lib
/test
/android
/ios
```

### ✔️ **Scripts de banco de dados**
Embora o projeto utilize Firebase (NoSQL), foram incluídos scripts de estruturação e exemplo para referência acadêmica.  
Local:
```
/scripts_de_banco
```

### ✔️ **Testes automatizados**
Local:
```
/test
```
Inclui testes de widgets e lógica, seguindo a estrutura do Flutter Test.

### ✔️ **Protótipo da interface (prints das telas)**
Local:
```
/prints_telas
```

### ✔️ **Slides da apresentação**
Local:
```
/slides
```

### ✔️ **Vídeo (Apresentação + Demonstração)**  
🔗 **YouTube:** https://www.youtube.com/watch?v=M40SuySAsrM


---

## 🚀 **Funcionalidades Implementadas / Planejadas**

- Login e cadastro de usuários via **Firebase Auth**
- Registro de denúncias com:
  - Título  
  - Descrição  
  - Localização  
  - Upload de fotos/vídeos (**Firebase Storage**)
- Listagem de denúncias
- Atualização em tempo real (**Cloud Firestore**)
- Navegação entre telas (fluxo completo do app)
- Protótipo visual em `/prints_telas`
- Testes automatizados básicos

---

## 🛠️ **Tecnologias Utilizadas**

- **Flutter (Dart)** – Aplicativo mobile
- **Firebase Auth** – Autenticação
- **Cloud Firestore** – Banco NoSQL
- **Firebase Storage** – Upload de mídia
- **GitHub Actions** (se aplicável) – CI/CD
- **VS Code / Android Studio**

---

## ▶️ **Como Rodar o Projeto**

### 1. Instalar dependências
```
flutter pub get
```

### 2. Executar no dispositivo ou emulador
```
flutter run
```

### 3. Configuração do Firebase  
Certifique-se de possuir os arquivos:

```
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

🔥 Por motivos de segurança, **esses arquivos não estão no repositório**.  
Você deve gerar os seus no **Firebase Console**.

---

## 🧪 **Como Rodar os Testes**
```
flutter test
```

---

## 🤝 **Contribuição**

Contribuições são bem-vindas via **Pull Request**.  
Sugestões ou melhorias podem ser abertas como **Issues** no repositório.
