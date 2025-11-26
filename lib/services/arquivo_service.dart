import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/Arquivo.dart';

class ArquivoService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String _bucket = 'denuncias'; // Pasta base no Storage

  /// Faz upload de um arquivo e retorna a URL
  Future<String?> uploadArquivo({
    required XFile arquivo,
    required String denunciaId,
    required TipoArquivo tipo,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('❌ Usuário não autenticado');
        return null;
      }

      // Gera ID único para o arquivo
      final uuid = const Uuid();
      final arquivoId = uuid.v4();

      // Determina extensão do arquivo
      final extensao = arquivo.name.split('.').last;

      // Determina tipo de arquivo para o caminho
      String tipoPasta = 'outros';
      switch (tipo) {
        case TipoArquivo.foto:
          tipoPasta = 'fotos';
          break;
        case TipoArquivo.video:
          tipoPasta = 'videos';
          break;
        case TipoArquivo.audio:
          tipoPasta = 'audios';
          break;
        case TipoArquivo.outro:
          tipoPasta = 'outros';
          break;
      }

      // Caminho no Storage: denuncias/{denunciaId}/{tipo}/{arquivoId}.{ext}
      final caminho = '$_bucket/$denunciaId/$tipoPasta/$arquivoId.$extensao';

      // Faz upload usando bytes (funciona na Web e Mobile)
      final ref = _storage.ref().child(caminho);
      final bytes = await arquivo.readAsBytes();
      final metadata = SettableMetadata(contentType: arquivo.mimeType);

      final uploadTask = ref.putData(bytes, metadata);

      // Aguarda conclusão
      final snapshot = await uploadTask;

      // Obtém URL de download
      final url = await snapshot.ref.getDownloadURL();

      print('✅ Arquivo enviado com sucesso: $url');
      return url;
    } catch (e) {
      print('❌ Erro ao fazer upload do arquivo: $e');
      return null;
    }
  }

  /// Faz upload de múltiplos arquivos
  Future<List<String>> uploadMultiplosArquivos({
    required List<XFile> arquivos,
    required String denunciaId,
    required TipoArquivo tipo,
  }) async {
    List<String> urls = [];

    for (var arquivo in arquivos) {
      final url = await uploadArquivo(
        arquivo: arquivo,
        denunciaId: denunciaId,
        tipo: tipo,
      );

      if (url != null) {
        urls.add(url);
      }
    }

    return urls;
  }

  /// Deleta um arquivo do Storage
  Future<bool> deletarArquivo(String urlArquivo) async {
    try {
      // Extrai o caminho da URL
      final ref = _storage.refFromURL(urlArquivo);
      await ref.delete();

      print('✅ Arquivo deletado: $urlArquivo');
      return true;
    } catch (e) {
      print('❌ Erro ao deletar arquivo: $e');
      return false;
    }
  }

  /// Determina o tipo de arquivo baseado na extensão
  static TipoArquivo determinarTipo(String caminhoArquivo) {
    final extensao = caminhoArquivo.split('.').last.toLowerCase();

    // Fotos
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'].contains(extensao)) {
      return TipoArquivo.foto;
    }

    // Vídeos
    if (['mp4', 'mov', 'avi', 'mkv', 'webm', '3gp'].contains(extensao)) {
      return TipoArquivo.video;
    }

    // Áudios
    if (['mp3', 'wav', 'aac', 'ogg', 'm4a', 'flac'].contains(extensao)) {
      return TipoArquivo.audio;
    }

    return TipoArquivo.outro;
  }
}
