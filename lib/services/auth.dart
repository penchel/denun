import 'package:firebase_auth/firebase_auth.dart';

Future<User?> criarUsuario(Map<String, dynamic> dic) async {
  String email = dic['email'];
  String senha = dic['senhaHash'];
  try {
    // Tenta logar com o Firebase
    UserCredential cred = await FirebaseAuth.instance
    .createUserWithEmailAndPassword(email: email, password: senha);
    // cred.user contém o usuário autenticado
    print("Usuário logado com sucesso: ${cred.user!.email}");
    return cred.user;
  } on FirebaseAuthException catch (e) {
    print("Erro ao autenticar: ${e.code} - ${e.message}");
    return null;
  }
}


Future<User?> entrarUsuario(String email, String senha) async {
  try {
    // Tenta autenticar o usuário no Firebase
    UserCredential cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha);

    print("✅ Login bem-sucedido: ${cred.user!.email}");
    return cred.user;
  } on FirebaseAuthException catch (e) {
    // Tratamento de erros mais informativo
    switch (e.code) {
      case 'user-not-found':
        print("❌ Usuário não encontrado para o e-mail informado.");
        break;
      case 'wrong-password':
        print("❌ Senha incorreta.");
        break;
      case 'invalid-email':
        print("❌ E-mail inválido.");
        break;
      case 'user-disabled':
        print("❌ Conta desativada.");
        break;
      default:
        print("❌ Erro inesperado: ${e.code} - ${e.message}");
    }
    return null;
  } catch (e) {
    print("❌ Erro inesperado: $e");
    return null;
  }
}