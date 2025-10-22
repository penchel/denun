import 'Arquivo.dart';

enum StatusDenuncia { novo, emAnalise, emAtendimento, concluida }
enum Prioridade { baixa, media, alta }

class Localizacao {
  final double latitude;
  final double longitude;

  Localizacao({
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
  };

  factory Localizacao.fromJson(Map<String, dynamic> json) => Localizacao(
        latitude: json["latitude"],
        longitude: json["longitude"],
      );
}

class Denuncia {
  final String idDenuncia; // melhor usar String para compatibilidade com Firestore
  String _titulo;
  String _descricao;
  DateTime _dataCriacao;
  String? endereco; // opcional (ex.: "Av. Brasil, 100")
  Localizacao _localizacao; // coordenadas obrigatórias
  StatusDenuncia _statusAtual;
  Prioridade _prioridade;
  final String autorId; // idUsuario de quem fez a denúncia
  List<Arquivo> _arquivos;

  Denuncia({
    required this.idDenuncia,
    required String titulo,
    required String descricao,
    required Localizacao localizacao,
    this.endereco,
    required this.autorId,
    DateTime? dataCriacao,
    StatusDenuncia statusAtual = StatusDenuncia.novo,
    Prioridade prioridade = Prioridade.baixa,
    List<Arquivo>? arquivos,
  })  : _titulo = titulo,
        _descricao = descricao,
        _localizacao = localizacao,
        _statusAtual = statusAtual,
        _prioridade = prioridade,
        _dataCriacao = dataCriacao ?? DateTime.now(),
        _arquivos = arquivos ?? [];

  // Getters
  String get titulo => _titulo;
  String get descricao => _descricao;
  Localizacao get localizacao => _localizacao;
  DateTime get dataCriacao => _dataCriacao;
  StatusDenuncia get statusAtual => _statusAtual;
  Prioridade get prioridade => _prioridade;
  List<Arquivo> get arquivos => _arquivos;

  // Setters simples
  void setTitulo(String novoTitulo) {
    if (novoTitulo.isNotEmpty) _titulo = novoTitulo;
  }

  void setDescricao(String novaDescricao) {
    if (novaDescricao.isNotEmpty) _descricao = novaDescricao;
  }

  void setLocalizacao(Localizacao novaLocalizacao) {
    _localizacao = novaLocalizacao;
  }

  void setStatus(StatusDenuncia novoStatus) {
    _statusAtual = novoStatus;
  }

  void setPrioridade(Prioridade novaPrioridade) {
    _prioridade = novaPrioridade;
  }

  void adicionarArquivo(Arquivo arquivo) {
    _arquivos.add(arquivo);
  }

  // Serialização para Firestore
  Map<String, dynamic> toJson() => {
        "idDenuncia": idDenuncia,
        "titulo": _titulo,
        "descricao": _descricao,
        "endereco": endereco,
        "localizacao": _localizacao.toJson(),
        "dataCriacao": _dataCriacao.toIso8601String(),
        "statusAtual": _statusAtual.name,
        "prioridade": _prioridade.name,
        "autorId": autorId,
        "arquivos": _arquivos.map((a) => a.toJson()).toList(),
      };

  factory Denuncia.fromJson(Map<String, dynamic> json) => Denuncia(
        idDenuncia: json["idDenuncia"],
        titulo: json["titulo"],
        descricao: json["descricao"],
        endereco: json["endereco"],
        localizacao: Localizacao.fromJson(json["localizacao"]),
        autorId: json["autorId"],
        dataCriacao: DateTime.parse(json["dataCriacao"]),
        statusAtual: StatusDenuncia.values.firstWhere(
          (s) => s.name == json["statusAtual"],
          orElse: () => StatusDenuncia.novo,
        ),
        prioridade: Prioridade.values.firstWhere(
          (p) => p.name == json["prioridade"],
          orElse: () => Prioridade.baixa,
        ),
        arquivos: (json["arquivos"] as List<dynamic>?)
                ?.map((a) => Arquivo.fromJson(a))
                .toList() ??
            [],
      );
}
