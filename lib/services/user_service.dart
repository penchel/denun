import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/Usuario.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'usuarios';

  /// Salva ou atualiza os dados do usuário no Firestore
  Future<bool> salvarUsuario(Usuario usuario, String firebaseUserId) async {
    try {
      // Remove a senhaHash antes de salvar (não devemos armazenar senhas no Firestore)
      Map<String, dynamic> dadosUsuario = usuario.toJson();
      dadosUsuario.remove('senhaHash'); // Remove a senha por segurança
      dadosUsuario['idUsuario'] = firebaseUserId; // Usa o UID do Firebase Auth
      dadosUsuario['dataCriacao'] = FieldValue.serverTimestamp();
      dadosUsuario['dataAtualizacao'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collection)
          .doc(firebaseUserId)
          .set(dadosUsuario, SetOptions(merge: true));

      print('✅ Dados do usuário salvos no Firestore');
      return true;
    } catch (e) {
      print('❌ Erro ao salvar usuário no Firestore: $e');
      return false;
    }
  }

  /// Busca os dados do usuário do Firestore pelo UID do Firebase Auth
  Future<Usuario?> buscarUsuarioPorId(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> dados = doc.data() as Map<String, dynamic>;
        dados['idUsuario'] = userId;
        // Adiciona senhaHash vazia pois não está no Firestore
        dados['senhaHash'] = '';
        return Usuario.fromJson(dados);
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar usuário no Firestore: $e');
      return null;
    }
  }

  /// Atualiza os dados do usuário no Firestore
  Future<bool> atualizarUsuario(String userId, Map<String, dynamic> dados) async {
    try {
      dados['dataAtualizacao'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_collection)
          .doc(userId)
          .update(dados);

      print('✅ Dados do usuário atualizados no Firestore');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar usuário no Firestore: $e');
      return false;
    }
  }

  /// Busca o usuário atual autenticado
  Future<Usuario?> buscarUsuarioAtual() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return await buscarUsuarioPorId(user.uid);
  }
}

