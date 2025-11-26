import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ajuda e Suporte',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFaqItem(
            'Como criar uma denúncia?',
            'Selecione o local no mapa, preencha as informações (título, descrição, fotos) e clique em "Criar Denúncia".',
          ),
          _buildFaqItem(
            'Como acompanhar minha denúncia?',
            'Vá para a aba "Denúncias" (ícone de lista no menu inferior). Lá você verá todas as suas denúncias e o status atual de cada uma (Aberta, Em Análise, Em Atendimento, Concluída).',
          ),
          _buildFaqItem(
            'Quem pode ver minhas denúncias?',
            'Apenas você, os Agentes e os Administradores do sistema podem ver os detalhes das suas denúncias. Outros cidadãos não têm acesso aos seus relatórios.',
          ),
          _buildFaqItem(
            'Como alterar minha senha?',
            'No momento, a alteração de senha deve ser solicitada ao suporte técnico ou realizada através da opção "Esqueci minha senha" na tela de login.',
          ),
          const SizedBox(height: 24),
          Text(
            'Ainda precisa de ajuda?',
            style: GoogleFonts.montserrat(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.email, color: Color(0xFF1E3A8A)),
              title: Text(
                'Entre em contato com o suporte',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'suporte@denun.com.br',
                style: GoogleFonts.montserrat(),
              ),
              onTap: () {
                // TODO: Implementar envio de email
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: GoogleFonts.montserrat(fontSize: 14, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
