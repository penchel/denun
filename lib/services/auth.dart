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
