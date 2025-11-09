import 'package:denun/screen/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/Usuario.dart';
import '../services/auth.dart';

final Map<PapelUsuario, String> papelUsuarioToString = {
  PapelUsuario.cidadao: "Cidadão",
  PapelUsuario.agente: "Agente",
  PapelUsuario.admin: "Administrador",
};

// Variável para guardar o papel selecionado
PapelUsuario? papelSelecionado = PapelUsuario.cidadao;

// ignore: must_be_immutable
class RegisterBox extends StatelessWidget {
  RegisterBox({super.key});

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _cpfController = TextEditingController();
  final _nomeController = TextEditingController(); // ← novo campo

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Cadastro",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 20),

          // Campo de nome
          TextField(
            controller: _nomeController,
            decoration: InputDecoration(
              hintText: "Nome completo",
              prefixIcon: const Icon(Icons.badge_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campo de e-mail
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              hintText: "E-mail",
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campo de CPF
          TextField(
            controller: _cpfController,
            decoration: InputDecoration(
              hintText: "CPF",
              prefixIcon: const Icon(Icons.perm_identity_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Campo de papel do usuário
          DropdownButtonFormField<PapelUsuario>(
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.people_outline),
              hintText: "Selecione o papel",
            ),
            items: PapelUsuario.values.map((papel) {
              return DropdownMenuItem(
                value: papel,
                child: Text(
                  papelUsuarioToString[papel] ??
                      papel.toString().split('.').last,
                ),
              );
            }).toList(),
            onChanged: (PapelUsuario? valor) {
              debugPrint("Selecionado: $valor");
              papelSelecionado = valor;
            },
          ),
          const SizedBox(height: 16),

          // Campo de senha
          TextField(
            controller: _senhaController,
            obscureText: true,
            decoration: InputDecoration(
              hintText: "Senha",
              prefixIcon: const Icon(Icons.lock_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botão cadastrar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                // ✅ Firebase já foi inicializado no main(), não precisa inicializar novamente
                debugPrint("Registrando...");
                debugPrint("Nome: ${_nomeController.text}");
                debugPrint("E-mail: ${_emailController.text}");
                debugPrint("CPF: ${_cpfController.text}");
                debugPrint("Senha: ${_senhaController.text}");
                debugPrint("Papel: $papelSelecionado");

                // Prepara os dados para criar o usuário
                Map<String, dynamic> dadosUsuario = {
                  'nome': _nomeController.text,
                  'email': _emailController.text,
                  'cpf': _cpfController.text.isEmpty ? null : _cpfController.text,
                  'senhaHash': _senhaController.text,
                  'papel': (papelSelecionado ?? PapelUsuario.cidadao).name,
                };

                User? user = await criarUsuario(dadosUsuario);
                if (user != null) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WelcomePage(nomeUsuario: _nomeController.text),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Falha na autenticação')),
                  );
                }
              },

              child: Text(
                "Cadastrar",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Link entrar
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Entrar",
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
