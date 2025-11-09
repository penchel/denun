import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/Denuncia.dart';

class DenunciaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'denuncias';

  /// Cria uma nova denúncia no Firestore
  Future<String?> criarDenuncia(Denuncia denuncia) async {
    try {
      // Usa o idDenuncia como ID do documento
      await _firestore
          .collection(_collection)
          .doc(denuncia.idDenuncia)
          .set(denuncia.toJson());

      print('✅ Denúncia criada no Firestore: ${denuncia.idDenuncia}');
      return denuncia.idDenuncia;
    } catch (e) {
      print('❌ Erro ao criar denúncia no Firestore: $e');
      return null;
    }
  }

  /// Busca uma denúncia específica pelo ID
  Future<Denuncia?> buscarDenunciaPorId(String idDenuncia) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(_collection)
          .doc(idDenuncia)
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> dados = doc.data() as Map<String, dynamic>;
        dados['idDenuncia'] = idDenuncia;
        
        // Converte dataCriacao se for Timestamp
        if (dados['dataCriacao'] is Timestamp) {
          dados['dataCriacao'] = (dados['dataCriacao'] as Timestamp).toDate().toIso8601String();
        } else if (dados['dataCriacao'] == null) {
          // Se não tiver data, usa a data atual
          dados['dataCriacao'] = DateTime.now().toIso8601String();
        }
        
        // Converte datas dos arquivos se necessário
        if (dados['arquivos'] != null) {
          for (var arquivo in dados['arquivos']) {
            if (arquivo['dataUpload'] is Timestamp) {
              arquivo['dataUpload'] = (arquivo['dataUpload'] as Timestamp).toDate().toIso8601String();
            }
          }
        }
        
        return Denuncia.fromJson(dados);
      }
      return null;
    } catch (e) {
      print('❌ Erro ao buscar denúncia no Firestore: $e');
      return null;
    }
  }

  /// Lista todas as denúncias (com opção de filtrar por autor)
  Future<List<Denuncia>> listarDenuncias({String? autorId}) async {
    try {
      Query query = _firestore.collection(_collection);
      
      // Se especificar autorId, filtra por autor
      if (autorId != null) {
        query = query.where('autorId', isEqualTo: autorId);
      }
      
      // Ordena por data de criação (mais recentes primeiro)
      query = query.orderBy('dataCriacao', descending: true);
      
      QuerySnapshot snapshot = await query.get();
      
      List<Denuncia> denuncias = [];
      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> dados = doc.data() as Map<String, dynamic>;
          dados['idDenuncia'] = doc.id;
          
          // Converte dataCriacao se for Timestamp
          if (dados['dataCriacao'] is Timestamp) {
            dados['dataCriacao'] = (dados['dataCriacao'] as Timestamp).toDate().toIso8601String();
          } else if (dados['dataCriacao'] == null) {
            dados['dataCriacao'] = DateTime.now().toIso8601String();
          }
          
          // Converte datas dos arquivos se necessário
          if (dados['arquivos'] != null) {
            for (var arquivo in dados['arquivos']) {
              if (arquivo['dataUpload'] is Timestamp) {
                arquivo['dataUpload'] = (arquivo['dataUpload'] as Timestamp).toDate().toIso8601String();
              } else if (arquivo['dataUpload'] == null) {
                arquivo['dataUpload'] = DateTime.now().toIso8601String();
              }
            }
          }
          
          denuncias.add(Denuncia.fromJson(dados));
        } catch (e) {
          print('❌ Erro ao converter denúncia ${doc.id}: $e');
        }
      }
      
      print('✅ ${denuncias.length} denúncias carregadas do Firestore');
      return denuncias;
    } catch (e) {
      print('❌ Erro ao listar denúncias no Firestore: $e');
      return [];
    }
  }

  /// Lista denúncias do usuário atual
  Future<List<Denuncia>> listarMinhasDenuncias() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    return await listarDenuncias(autorId: user.uid);
  }

  /// Atualiza uma denúncia existente
  Future<bool> atualizarDenuncia(String idDenuncia, Map<String, dynamic> dados) async {
    try {
      dados['dataAtualizacao'] = FieldValue.serverTimestamp();
      
      await _firestore
          .collection(_collection)
          .doc(idDenuncia)
          .update(dados);

      print('✅ Denúncia atualizada no Firestore: $idDenuncia');
      return true;
    } catch (e) {
      print('❌ Erro ao atualizar denúncia no Firestore: $e');
      return false;
    }
  }

  /// Atualiza o status de uma denúncia
  Future<bool> atualizarStatus(String idDenuncia, StatusDenuncia novoStatus) async {
    return await atualizarDenuncia(idDenuncia, {
      'statusAtual': novoStatus.name,
    });
  }

  /// Atualiza a prioridade de uma denúncia
  Future<bool> atualizarPrioridade(String idDenuncia, Prioridade novaPrioridade) async {
    return await atualizarDenuncia(idDenuncia, {
      'prioridade': novaPrioridade.name,
    });
  }

  /// Adiciona um arquivo a uma denúncia
  Future<bool> adicionarArquivo(String idDenuncia, Map<String, dynamic> arquivo) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(idDenuncia)
          .update({
        'arquivos': FieldValue.arrayUnion([arquivo]),
      });

      print('✅ Arquivo adicionado à denúncia: $idDenuncia');
      return true;
    } catch (e) {
      print('❌ Erro ao adicionar arquivo à denúncia: $e');
      return false;
    }
  }

  /// Deleta uma denúncia (apenas o autor pode deletar)
  Future<bool> deletarDenuncia(String idDenuncia) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(idDenuncia)
          .delete();

      print('✅ Denúncia deletada do Firestore: $idDenuncia');
      return true;
    } catch (e) {
      print('❌ Erro ao deletar denúncia no Firestore: $e');
      return false;
    }
  }

  /// Stream de denúncias em tempo real (para atualizações automáticas)
  Stream<List<Denuncia>> streamDenuncias({String? autorId}) {
    Query query = _firestore.collection(_collection);
    
    if (autorId != null) {
      query = query.where('autorId', isEqualTo: autorId);
    }
    
    query = query.orderBy('dataCriacao', descending: true);
    
    return query.snapshots().map((snapshot) {
      List<Denuncia> denuncias = [];
      for (var doc in snapshot.docs) {
        try {
          Map<String, dynamic> dados = doc.data() as Map<String, dynamic>;
          dados['idDenuncia'] = doc.id;
          
          // Converte Timestamp para String
          if (dados['dataCriacao'] is Timestamp) {
            dados['dataCriacao'] = (dados['dataCriacao'] as Timestamp).toDate().toIso8601String();
          } else if (dados['dataCriacao'] == null) {
            dados['dataCriacao'] = DateTime.now().toIso8601String();
          }
          
          if (dados['arquivos'] != null) {
            for (var arquivo in dados['arquivos']) {
              if (arquivo['dataUpload'] is Timestamp) {
                arquivo['dataUpload'] = (arquivo['dataUpload'] as Timestamp).toDate().toIso8601String();
              } else if (arquivo['dataUpload'] == null) {
                arquivo['dataUpload'] = DateTime.now().toIso8601String();
              }
            }
          }
          
          denuncias.add(Denuncia.fromJson(dados));
        } catch (e) {
          print('❌ Erro ao converter denúncia ${doc.id}: $e');
        }
      }
      return denuncias;
    });
  }
}

