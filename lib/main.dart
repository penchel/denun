import 'package:flutter/material.dart';
import 'screen/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializa o Firebase UMA VEZ antes de rodar o app
  // Usa try-catch para evitar erro se já foi inicializado automaticamente (Android)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Se já foi inicializado (pode acontecer automaticamente pelo Android), ignora o erro
    // Verifica se é erro de duplicação pela mensagem
    final errorMessage = e.toString().toLowerCase();
    if (errorMessage.contains('duplicate-app') ||
        errorMessage.contains('already exists')) {
      // Firebase já está inicializado, tudo certo! Continua normalmente
    } else {
      // Outro tipo de erro, relança para não esconder problemas reais
      rethrow;
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Denun',
      theme: ThemeData(primarySwatch: Colors.blue),
      // ✅ Firebase já foi inicializado no main(), então podemos ir direto para HomePage
      home: const HomePage(),
    );
  }
}
