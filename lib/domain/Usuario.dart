enum PapelUsuario { cidadao, agente, admin }

class Usuario {
  String? idUsuario;
  String _nome;
  String _email;
  String? _cpf; // pode ser nulo
  String _senhaHash; // senha armazenada com hash
  PapelUsuario _papel;
  bool _emailConfirmado;

  Usuario({
    this.idUsuario,
    required String nome,
    required String email,
    String? cpf, // opcional
    required String senhaHash,
    PapelUsuario papel = PapelUsuario.cidadao,
    bool emailConfirmado = false,
  })  : _nome = nome,
        _email = email,
        _cpf = cpf,
        _senhaHash = senhaHash,
        _papel = papel,
        _emailConfirmado = emailConfirmado {
    // 🔒 validação de formato de e-mail
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      throw FormatException('E-mail inválido: $email');
    }
  }

  // Getters
  String get nome => _nome;
  String get email => _email;
  String? get cpf => _cpf;
  String get senhaHash => _senhaHash;
  PapelUsuario get papel => _papel;
  bool get emailConfirmado => _emailConfirmado;

  // Setters
  void setNome(String novoNome) {
    if (novoNome.isNotEmpty) _nome = novoNome;
  }

  void setEmail(String novoEmail) {
    if (RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(novoEmail)) {
      _email = novoEmail;
    } else {
      throw FormatException('E-mail inválido: $novoEmail');
    }
  }

  void setSenhaHash(String novoHash) {
    if (novoHash.isNotEmpty) _senhaHash = novoHash;
  }

  void setPapel(PapelUsuario novoPapel) {
    _papel = novoPapel;
  }

  void confirmarEmail() {
    _emailConfirmado = true;
  }

  // Serialização para Firestore
  Map<String, dynamic> toJson() => {
        "idUsuario": idUsuario,
        "nome": _nome,
        "email": _email,
        "cpf": _cpf,
        "senhaHash": _senhaHash,
        "papel": _papel.name,
        "emailConfirmado": _emailConfirmado,
      };

  factory Usuario.fromJson(Map<String, dynamic> json) => Usuario(
        idUsuario: json["idUsuario"],
        nome: json["nome"],
        email: json["email"],
        cpf: json["cpf"],
        senhaHash: json["senhaHash"],
        papel: PapelUsuario.values.firstWhere(
          (p) => p.name == json["papel"],
          orElse: () => PapelUsuario.cidadao,
        ),
        emailConfirmado: json["emailConfirmado"] ?? false,
      );
}
