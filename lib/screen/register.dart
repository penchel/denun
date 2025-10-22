import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/registerbox.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: 
        Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1E3A8A), 
                Color(0xFF1E293B), 
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight
            )
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // centraliza verticalmente
              crossAxisAlignment: CrossAxisAlignment.center, // centraliza horizontalmente
              children: [
                Text(
                  'Denun', 
                  style: GoogleFonts.montserrat(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFFFFFFF), 
                  ),
                ),
                SizedBox(height: 32),
                Container(
                  width: 400, // define o tamanho máximo
                  padding: const EdgeInsets.all(16), // espaço interno
                  margin: const EdgeInsets.symmetric(horizontal: 16), // margem externa
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: RegisterBox(),
                ),
              ],
            )
          ),
        ),
    );
  }
}
