import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('Persistência (Firestore falso)', () {
    test('Salvar e buscar um usuário na coleção "usuarios"', () async {
      final db = FakeFirebaseFirestore();

      final usuario = {
        'idUsuario': 'u123',
        'nome': 'André Penchel',
        'email': 'andre@teste.com',
        'papel': 'cidadao',
        'emailConfirmado': false,
      };

     
      await db.collection('usuarios').doc(usuario['idUsuario'] as String).set(usuario);

      final snap = await db.collection('usuarios').doc('u123').get();
      expect(snap.exists, true);
      expect(snap.data()!['nome'], 'André Penchel');
      expect(snap.data()!['papel'], 'cidadao');
    });

    test('Criar e buscar denúncia em "denuncias"', () async {
      final db = FakeFirebaseFirestore();

      final denuncia = {
        'idDenuncia': 'd001',
        'titulo': 'Buraco na rua',
        'descricao': 'Av. Central',
        'dataCriacao': DateTime.now().toIso8601String(),
        'localizacao': {'latitude': -19.9, 'longitude': -43.9},
        'statusAtual': 'novo',
        'prioridade': 'media',
        'autorId': 'u123',
        'arquivos': [],
      };

      await db.collection('denuncias').doc(denuncia['idDenuncia'] as String).set(denuncia);

      final doc = await db.collection('denuncias').doc('d001').get();
      expect(doc.exists, true);
      expect(doc.data()!['titulo'], 'Buraco na rua');
      expect(doc.data()!['statusAtual'], 'novo');

      final all = await db.collection('denuncias').get();
      expect(all.docs.length, 1);
    });
  });
}
