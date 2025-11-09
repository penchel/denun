import 'package:flutter_test/flutter_test.dart';
import 'package:denun/domain/Denuncia.dart';
import 'package:denun/domain/Arquivo.dart';

void main() {
  group('Denuncia (Domínio)', () {
    test('Cria denúncia e altera status/prioridade', () {
      final d = Denuncia(
        idDenuncia: 'd1',
        titulo: 'Buraco na rua',
        descricao: 'Av. Central',
        localizacao: Localizacao(latitude: -19.9, longitude: -43.9),
        autorId: 'u123',
      );

      expect(d.statusAtual, StatusDenuncia.novo);
      expect(d.prioridade, Prioridade.baixa);


      d.setStatus(StatusDenuncia.emAnalise);
      d.setPrioridade(Prioridade.alta);
      expect(d.statusAtual, StatusDenuncia.emAnalise);
      expect(d.prioridade, Prioridade.alta);

      d.adicionarArquivo(Arquivo(
        idArquivo: 'a1',
        urlArquivo: 'http://exemplo',
        tipo: TipoArquivo.foto,
      ));
      expect(d.arquivos.length, 1);
    });
  });
}
