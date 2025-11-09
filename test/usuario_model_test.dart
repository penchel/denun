import 'package:flutter_test/flutter_test.dart';
import 'package:denun/domain/Usuario.dart';

void main() {
  group('Usuario (Domínio)', () {
    test('Cria usuário válido', () {
      final u = Usuario(
        idUsuario: 'u1',
        nome: 'André Penchel',
        email: 'andre@teste.com',
        cpf: '12345678900',
        senhaHash: 'hash123',
        papel: PapelUsuario.cidadao,
      );
      expect(u.nome, 'André Penchel');
      expect(u.email, 'andre@teste.com');
      expect(u.papel, PapelUsuario.cidadao);
    });

    test('E-mail inválido lança FormatException', () {
      expect(
        () => Usuario(
          idUsuario: 'u2',
          nome: 'Teste',
          email: 'email_invalido',
          cpf: '000',
          senhaHash: 'hash',
          papel: PapelUsuario.agente,
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
