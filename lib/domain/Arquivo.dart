enum TipoArquivo { foto, video, audio, outro }

class Arquivo {
  final String idArquivo;
  final String urlArquivo;
  final TipoArquivo tipo;
  final DateTime dataUpload;

  Arquivo({
    required this.idArquivo,
    required this.urlArquivo,
    required this.tipo,
    DateTime? dataUpload,
  }) : dataUpload = dataUpload ?? DateTime.now();

  // Serialização
  Map<String, dynamic> toJson() => {
        "idArquivo": idArquivo,
        "urlArquivo": urlArquivo,
        "tipo": tipo.name,
        "dataUpload": dataUpload.toIso8601String(),
      };

  factory Arquivo.fromJson(Map<String, dynamic> json) => Arquivo(
        idArquivo: json["idArquivo"],
        urlArquivo: json["urlArquivo"],
        tipo: TipoArquivo.values.firstWhere(
          (t) => t.name == json["tipo"],
          orElse: () => TipoArquivo.outro,
        ),
        dataUpload: DateTime.parse(json["dataUpload"]),
      );
}
