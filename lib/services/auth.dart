import 'package:firebase_auth/firebase_auth.dart';
import 'user_service.dart';
import '../domain/Usuario.dart';

Future<User?> criarUsuario(Map<String, dynamic> dic) async {
  String email = dic['email'];
  String senha = dic['senhaHash'];
  try {
    // Cria o usuário no Firebase Auth
    UserCredential cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: senha);
    
    // Cria o objeto Usuario com os dados fornecidos
    Usuario novoUsuario = Usuario(
      idUsuario: cred.user!.uid,
      nome: dic['nome'] ?? email.split('@')[0],
      email: email,
      cpf: dic['cpf'],
      senhaHash: senha, // Não será salvo no Firestore
      papel: dic['papel'] != null 
          ? PapelUsuario.values.firstWhere(
              (p) => p.name == dic['papel'],
              orElse: () => PapelUsuario.cidadao,
            )
          : PapelUsuario.cidadao,
      emailConfirmado: cred.user!.emailVerified,
    );

    // Salva os dados do usuário no Firestore
    UserService userService = UserService();
    bool sucesso = await userService.salvarUsuario(novoUsuario, cred.user!.uid);
    
    if (sucesso) {
      print("✅ Usuário criado e dados salvos no Firestore: ${cred.user!.email}");
    } else {
      print("⚠️ Usuário criado no Auth, mas falha ao salvar no Firestore");
    }

    return cred.user;
  } on FirebaseAuthException catch (e) {
    print("❌ Erro ao criar usuário: ${e.code} - ${e.message}");
    return null;
  } catch (e) {
    print("❌ Erro inesperado ao criar usuário: $e");
    return null;
  }
}


Future<User?> entrarUsuario(String email, String senha) async {
  try {
    // Tenta autenticar o usuário no Firebase
    UserCredential cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: senha);

    // Verifica se os dados do usuário existem no Firestore
    // Se não existirem, cria um registro básico (para usuários antigos)
    UserService userService = UserService();
    Usuario? usuarioExistente = await userService.buscarUsuarioPorId(cred.user!.uid);
    
    if (usuarioExistente == null) {
      // Se não existe no Firestore, cria um registro básico
      Usuario usuarioBasico = Usuario(
        idUsuario: cred.user!.uid,
        nome: cred.user!.displayName ?? email.split('@')[0],
        email: email,
        senhaHash: '', // Não salva senha
        papel: PapelUsuario.cidadao,
        emailConfirmado: cred.user!.emailVerified,
      );
      await userService.salvarUsuario(usuarioBasico, cred.user!.uid);
      print("✅ Dados básicos do usuário criados no Firestore");
    }

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