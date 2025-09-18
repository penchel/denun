import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
enum PapelUsuario { cidadao, agente, admin }
class LoginBox extends StatelessWidget {
  const LoginBox({super.key});

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
            "Entrar",
            style: GoogleFonts.montserrat(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A), // Azul branding
            ),
          ),
          const SizedBox(height: 20),

          // Campo de e-mail
          TextField(
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
            decoration: InputDecoration(
              hintText: "CPF",
              prefixIcon: const Icon(Icons.person),
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
                  papel.toString().split('.').last, // mostra só o nome (cidadao, agente, admin)
                ),
              );
            }).toList(),
            onChanged: (PapelUsuario? valor) {
              // Aqui você pode salvar o valor selecionado em uma variável
              debugPrint("Selecionado: $valor");
            },
          ),
          const SizedBox(height: 16),


          // Campo de senha
          TextField(
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

          // Botão
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
              onPressed: () {},
              child: Text(
                "Login",
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Link registrar
          TextButton(
            onPressed: () {},
            child: Text(
              "Registrar-se",
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
