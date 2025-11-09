
# 🧪 Testes Automatizados — Projeto Denun

## 🎯 Objetivo
Implementar testes automatizados (unidade e integração) para validar a camada de domínio e a camada de persistência (Firestore) do aplicativo **Denun**.

---

## ⚙️ Frameworks e Ferramentas
- **Linguagem:** Dart / Flutter  
- **Test Runner:** `flutter_test` / `test`  
- **Mocks:** `fake_cloud_firestore`, `firebase_auth_mocks` (opcional)  
- **Outros:** `mockito`, `test`  

---

## 📦 Escopo Coberto
- **Camada de domínio:** classes `Usuario`, `Denuncia` e `Arquivo` — validações e regras de negócio.  
- **Camada de persistência:** serviços `UserService` e `DenunciaService`, testados com um Firestore falso em memória (`FakeFirebaseFirestore`).  
- **Cobertura mínima:** 3–5 testes essenciais executando com `flutter test`.

---

## ▶️ Como Rodar os Testes

1. Adicione as dependências de teste no arquivo **`pubspec.yaml`**:
   ```yaml
   dev_dependencies:
     flutter_test:
       sdk: flutter
     test: ^1.25.0
     mockito: ^5.4.2
     fake_cloud_firestore: ^4.0.0
     firebase_auth_mocks: ^0.15.1
   ```

2. Atualize as dependências:
   ```bash
   flutter pub get
   ```

3. Execute os testes:
   ```bash
   flutter test
   ```

---

## 🧱 Estrutura dos Arquivos de Teste

```
test/
 ├─ usuario_model_test.dart
 ├─ denuncia_model_test.dart
 └─ firestore_services_test.dart
```

---

## 🧩 Exemplos de Casos de Teste (resumo)

| Arquivo | Caso de Teste | Objetivo |
|----------|---------------|----------|
| `usuario_model_test.dart` | Criação válida de usuário | Garantir correta construção e atributos. |
| `usuario_model_test.dart` | E-mail inválido lança exceção | Validar regra de negócio de e-mail. |
| `denuncia_model_test.dart` | Atualizar status e prioridade | Verificar regras de negócio da denúncia. |
| `firestore_services_test.dart` | Salvar e ler usuário (fake) | Validar integração com persistência. |
| `firestore_services_test.dart` | Criar e buscar denúncia (fake) | Validar fluxo essencial na coleção. |

---

## ⚠️ Observações Importantes
- Para testes de Firestore, utilize **`FakeFirebaseFirestore()`** — não requer internet nem inicialização real do Firebase.  
- Para testes de autenticação, use **`MockFirebaseAuth`** do pacote `firebase_auth_mocks`.  
- Durante o desenvolvimento, as regras do Firestore podem estar abertas (`allow read, write: if true;`), mas devem ser reforçadas na produção.

---

## ✅ Resultados Esperados

Comando:
```bash
flutter test
```

Saída esperada:
```
All tests passed!
```

---

## 🔗 Link do Repositório

Adicione aqui o link do seu repositório GitHub:

> [https://github.com/andrepenchel/denun](https://github.com/andrepenchel/denun)
