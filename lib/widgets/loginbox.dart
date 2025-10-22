import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/register.dart';
import '../services/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:denun/screen/welcome.dart';
class LoginBox extends StatelessWidget {
  LoginBox({super.key});

  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

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
              onPressed: () async {
                User? user = await entrarUsuario(
                  _emailController.text,
                  _senhaController.text,
                );
                if (user != null){
                  // ✅ Login bem-sucedido → vai pra tela de boas-vindas
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          WelcomePage(nomeUsuario: _emailController.text),
                    ),
                  );
                }else{
                  // ❌ Falha → mostra mensagem
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Falha na autenticação')),
                  );
                }
              },
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterPage()),
              );
            },
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
