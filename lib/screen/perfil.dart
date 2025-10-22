import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  User? _firebaseUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  void _carregarUsuario() async {
    setState(() => _isLoading = true);

    // Pega o usuário autenticado do Firebase Auth
    _firebaseUser = FirebaseAuth.instance.currentUser;

    setState(() => _isLoading = false);
  }

  String _getEmailUsername() {
    if (_firebaseUser?.email == null) return 'Usuário';
    return _firebaseUser!.email!.split('@')[0];
  }

  void _editarPerfil() {
    showDialog(
      context: context,
      builder: (context) {
        final nomeController = TextEditingController(
          text: _firebaseUser?.displayName ?? _getEmailUsername(),
        );
        
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Editar Nome de Exibição',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(
                  labelText: 'Nome',
                  labelStyle: GoogleFonts.montserrat(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.isNotEmpty && _firebaseUser != null) {
                  try {
                    await _firebaseUser!.updateDisplayName(nomeController.text);
                    await _firebaseUser!.reload();
                    
                    Navigator.pop(context);
                    _carregarUsuario(); // Recarrega os dados
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Nome atualizado com sucesso!',
                          style: GoogleFonts.montserrat(),
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erro ao atualizar nome',
                          style: GoogleFonts.montserrat(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Salvar',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _alterarSenha() {
    showDialog(
      context: context,
      builder: (context) {
        final senhaAtualController = TextEditingController();
        final novaSenhaController = TextEditingController();
        final confirmarSenhaController = TextEditingController();
        
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Alterar Senha',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: senhaAtualController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Senha Atual',
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: novaSenhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Nova Senha',
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmarSenhaController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Nova Senha',
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (novaSenhaController.text != confirmarSenhaController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'As senhas não conferem!',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                if (novaSenhaController.text.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'A senha deve ter no mínimo 6 caracteres!',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  // Reautentica o usuário
                  AuthCredential credential = EmailAuthProvider.credential(
                    email: _firebaseUser!.email!,
                    password: senhaAtualController.text,
                  );
                  await _firebaseUser!.reauthenticateWithCredential(credential);
                  
                  // Altera a senha
                  await _firebaseUser!.updatePassword(novaSenhaController.text);
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Senha alterada com sucesso!',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } on FirebaseAuthException catch (e) {
                  String mensagem = 'Erro ao alterar senha';
                  if (e.code == 'wrong-password') {
                    mensagem = 'Senha atual incorreta';
                  } else if (e.code == 'weak-password') {
                    mensagem = 'Senha muito fraca';
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(mensagem, style: GoogleFonts.montserrat()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Alterar',
                style: GoogleFonts.montserrat(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _reenviarVerificacao() async {
    if (_firebaseUser != null && !_firebaseUser!.emailVerified) {
      try {
        await _firebaseUser!.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'E-mail de verificação enviado!',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao enviar e-mail',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _sair() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Sair da Conta',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja sair da sua conta?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.montserrat(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Sair',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String titulo,
    required VoidCallback onTap,
    Color? iconColor,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (iconColor ?? const Color(0xFF1E3A8A)).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: iconColor ?? const Color(0xFF1E3A8A),
              size: 24,
            ),
          ),
          title: Text(
            titulo,
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Divider(color: Colors.grey[300], height: 1),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF1E3A8A),
          ),
        ),
      );
    }

    if (_firebaseUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Perfil',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 80,
                  color: const Color(0xFF1E3A8A),
                ),
                const SizedBox(height: 16),
                Text(
                  'Não autenticado',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Faça login para acessar seu perfil',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Fazer Login',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    String nomeExibicao = _firebaseUser!.displayName ?? _getEmailUsername();
    DateTime? dataCriacao = _firebaseUser!.metadata.creationTime;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: _editarPerfil,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header com informações do usuário
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  children: [
                    // Avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 50,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nome
                    Text(
                      nomeExibicao,
                      style: GoogleFonts.montserrat(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Email
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _firebaseUser!.emailVerified 
                              ? Icons.verified 
                              : Icons.mail_outline,
                          size: 16,
                          color: _firebaseUser!.emailVerified 
                              ? Colors.greenAccent 
                              : Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _firebaseUser!.email ?? '',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    
                    // Botão para reenviar verificação
                    if (!_firebaseUser!.emailVerified) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: _reenviarVerificacao,
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Text(
                          'Verificar e-mail',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 12),

                    // Tag de cidadão
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Cidadão',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Informações adicionais
            if (dataCriacao != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Membro desde',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${dataCriacao.day.toString().padLeft(2, '0')}/${dataCriacao.month.toString().padLeft(2, '0')}/${dataCriacao.year}',
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Menu de opções
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.lock_outline,
                    titulo: 'Alterar Senha',
                    onTap: _alterarSenha,
                  ),
                  _buildMenuItem(
                    icon: Icons.refresh,
                    titulo: 'Recarregar Perfil',
                    onTap: () async {
                      await _firebaseUser!.reload();
                      _carregarUsuario();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Perfil atualizado!',
                            style: GoogleFonts.montserrat(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    titulo: 'Ajuda e Suporte',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Em desenvolvimento',
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    titulo: 'Sobre o App',
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: Text(
                            'Denun',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Versão 1.0.0',
                                style: GoogleFonts.montserrat(),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'App de denúncias cidadãs para melhorar a cidade.',
                                style: GoogleFonts.montserrat(fontSize: 12),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Fechar',
                                style: GoogleFonts.montserrat(
                                  color: const Color(0xFF1E3A8A),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.logout,
                    titulo: 'Sair da Conta',
                    onTap: _sair,
                    iconColor: Colors.red,
                    showDivider: false,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // UID do usuário
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.fingerprint, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ID: ${_firebaseUser!.uid.substring(0, 8)}...',
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Versão do app
            Text(
              'Versão 1.0.0',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}