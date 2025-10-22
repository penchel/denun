import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/navbar.dart';
import 'map.dart';
import 'perfil.dart';
import 'denuncias.dart';
class WelcomePage extends StatefulWidget {
  final String nomeUsuario;

  const WelcomePage({super.key, required this.nomeUsuario});

  @override
  HomePageState createState() => HomePageState();


  
}


class HomePageState extends State<WelcomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    MapPage(),
    DenunciasPage(),
    PerfilPage()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}