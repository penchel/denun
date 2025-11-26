import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../domain/Denuncia.dart';
import '../services/denuncia_service.dart';

import '../services/user_service.dart';
import '../domain/Usuario.dart';

class DenunciasPage extends StatefulWidget {
  const DenunciasPage({super.key});

  @override
  State<DenunciasPage> createState() => _DenunciasPageState();
}

class _DenunciasPageState extends State<DenunciasPage> {
  // Filtros
  String? _filtroStatus;
  String? _filtroPrioridade;
  String _textoBusca = '';

  final DenunciaService _denunciaService = DenunciaService();
  final UserService _userService = UserService();
  Usuario? _usuario;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final usuario = await _userService.buscarUsuarioPorId(user.uid);
      if (mounted) {
        setState(() {
          _usuario = usuario;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Denuncia> _filtrarDenuncias(List<Denuncia> denuncias) {
    return denuncias.where((d) {
      bool passaStatus =
          _filtroStatus == null || d.statusAtual.name == _filtroStatus;
      bool passaPrioridade =
          _filtroPrioridade == null || d.prioridade.name == _filtroPrioridade;
      bool passaBusca =
          _textoBusca.isEmpty ||
          d.titulo.toLowerCase().contains(_textoBusca.toLowerCase()) ||
          d.descricao.toLowerCase().contains(_textoBusca.toLowerCase()) ||
          (d.endereco?.toLowerCase().contains(_textoBusca.toLowerCase()) ??
              false);
      return passaStatus && passaPrioridade && passaBusca;
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'novo':
        return Colors.blue.shade700;
      case 'emAnalise':
        return Colors.orange.shade800;
      case 'emAtendimento':
        return Colors.purple.shade700;
      case 'concluida':
        return Colors.green.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getPrioridadeColor(String prioridade) {
    switch (prioridade) {
      case 'baixa':
        return Colors.grey.shade600;
      case 'media':
        return Colors.amber.shade800;
      case 'alta':
        return Colors.red.shade800;
      default:
        return Colors.grey.shade600;
    }
  }

  String _getStatusTexto(String status) {
    switch (status) {
      case 'novo':
        return 'Novo';
      case 'emAnalise':
        return 'Em Análise';
      case 'emAtendimento':
        return 'Em Atendimento';
      case 'concluida':
        return 'Concluída';
      default:
        return status;
    }
  }

  String _getPrioridadeTexto(String prioridade) {
    switch (prioridade) {
      case 'baixa':
        return 'Baixa';
      case 'media':
        return 'Média';
      case 'alta':
        return 'Alta';
      default:
        return prioridade;
    }
  }

  void _mostrarFiltros() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtros',
                    style: GoogleFonts.montserrat(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Status',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Todos'),
                        selected: _filtroStatus == null,
                        onSelected: (selected) {
                          setState(() => _filtroStatus = null);
                          setModalState(() {});
                        },
                      ),
                      ...StatusDenuncia.values.map(
                        (status) => FilterChip(
                          label: Text(_getStatusTexto(status.name)),
                          selected: _filtroStatus == status.name,
                          onSelected: (selected) {
                            setState(
                              () =>
                                  _filtroStatus = selected ? status.name : null,
                            );
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Prioridade',
                    style: GoogleFonts.montserrat(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Todas'),
                        selected: _filtroPrioridade == null,
                        onSelected: (selected) {
                          setState(() => _filtroPrioridade = null);
                          setModalState(() {});
                        },
                      ),
                      ...Prioridade.values.map(
                        (p) => FilterChip(
                          label: Text(_getPrioridadeTexto(p.name)),
                          selected: _filtroPrioridade == p.name,
                          onSelected: (selected) {
                            setState(
                              () =>
                                  _filtroPrioridade = selected ? p.name : null,
                            );
                            setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Aplicar Filtros',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _criarDenuncia() {
    // Navega para o mapa onde o usuário pode criar uma denúncia
    // Por enquanto, mostra um diálogo informativo
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Criar Denúncia',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Para criar uma nova denúncia, vá até a tela do Mapa e selecione a localização.',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Entendi',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _alterarStatus(
    Denuncia denuncia,
    StatusDenuncia novoStatus,
  ) async {
    bool sucesso = await _denunciaService.atualizarStatus(
      denuncia.idDenuncia,
      novoStatus,
    );

    if (mounted) {
      Navigator.pop(context); // Fecha o diálogo de detalhes
      if (sucesso) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status atualizado para ${_getStatusTexto(novoStatus.name)}',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao atualizar status',
              style: GoogleFonts.montserrat(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmarExclusao(Denuncia denuncia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Excluir Denúncia',
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta denúncia? Esta ação não pode ser desfeita.',
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
              Navigator.pop(context); // Fecha confirmação
              Navigator.pop(context); // Fecha detalhes

              bool sucesso = await _denunciaService.deletarDenuncia(
                denuncia.idDenuncia,
              );

              if (mounted) {
                if (sucesso) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Denúncia excluída com sucesso',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Erro ao excluir denúncia',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Excluir',
              style: GoogleFonts.montserrat(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _verDetalhes(Denuncia denuncia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Expanded(
              child: Text(
                denuncia.titulo,
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
            ),
            if (_usuario?.papel == PapelUsuario.admin)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _confirmarExclusao(denuncia),
                tooltip: 'Excluir Denúncia',
              ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (denuncia.arquivos.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Image.network(
                      denuncia.arquivos.first.urlArquivo,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                denuncia.descricao,
                style: GoogleFonts.montserrat(height: 1.5),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailRow(
                Icons.location_on,
                denuncia.endereco ?? 'Endereço não informado',
              ),
              _buildDetailRow(
                Icons.calendar_today,
                '${denuncia.dataCriacao.day.toString().padLeft(2, '0')}/${denuncia.dataCriacao.month.toString().padLeft(2, '0')}/${denuncia.dataCriacao.year}',
              ),
              _buildDetailRow(
                Icons.flag,
                'Status: ${_getStatusTexto(denuncia.statusAtual.name)}',
              ),
              _buildDetailRow(
                Icons.priority_high,
                'Prioridade: ${_getPrioridadeTexto(denuncia.prioridade.name)}',
              ),

              // Seção de Ações para Agente/Admin
              if (_usuario?.papel == PapelUsuario.agente ||
                  _usuario?.papel == PapelUsuario.admin) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Alterar Status',
                  style: GoogleFonts.montserrat(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<StatusDenuncia>(
                  value: denuncia.statusAtual,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: StatusDenuncia.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(
                        _getStatusTexto(status.name),
                        style: GoogleFonts.montserrat(),
                      ),
                    );
                  }).toList(),
                  onChanged: (novoStatus) {
                    if (novoStatus != null &&
                        novoStatus != denuncia.statusAtual) {
                      _alterarStatus(denuncia, novoStatus);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fechar',
              style: GoogleFonts.montserrat(
                color: const Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Determina se deve filtrar por autor (apenas Cidadão vê só as suas)
    String? autorIdFiltro;
    if (_usuario?.papel == PapelUsuario.cidadao) {
      autorIdFiltro = FirebaseAuth.instance.currentUser?.uid;
    }
    // Se for Admin ou Agente, autorIdFiltro fica null (vê todas)

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _usuario?.papel == PapelUsuario.cidadao
              ? 'Minhas Denúncias'
              : 'Painel de Denúncias',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _mostrarFiltros,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: _criarDenuncia,
            tooltip: 'Nova denúncia',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) => setState(() => _textoBusca = value),
              decoration: InputDecoration(
                hintText: 'Buscar por título, descrição ou endereço...',
                hintStyle: GoogleFonts.montserrat(color: Colors.grey),
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

          // Lista de denúncias com StreamBuilder
          Expanded(
            child: StreamBuilder<List<Denuncia>>(
              stream: _denunciaService.streamDenuncias(autorId: autorIdFiltro),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erro ao carregar denúncias',
                          style: GoogleFonts.montserrat(fontSize: 16),
                        ),
                        Text(
                          snapshot.error.toString(),
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final denuncias = snapshot.data ?? [];
                final denunciasFiltradas = _filtrarDenuncias(denuncias);

                if (denunciasFiltradas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            denuncias.isEmpty
                                ? Icons.inbox_outlined
                                : Icons.search_off,
                            size: 80,
                            color: const Color(0xFF1E3A8A).withOpacity(0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            denuncias.isEmpty
                                ? 'Nenhuma denúncia cadastrada'
                                : 'Nenhuma denúncia encontrada',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            denuncias.isEmpty
                                ? 'Faça sua primeira denúncia para ajudar a melhorar a cidade!'
                                : 'Tente ajustar os filtros ou termos de busca',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: denunciasFiltradas.length,
                  itemBuilder: (context, index) {
                    final denuncia = denunciasFiltradas[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        onTap: () => _verDetalhes(denuncia),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (denuncia.arquivos.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: Image.network(
                                        denuncia.arquivos.first.urlArquivo,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Container(
                                                color: Colors.grey[200],
                                                child: const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              );
                                            },
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                Container(
                                                  color: Colors.grey[200],
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    color: Colors.grey[400],
                                                    size: 50,
                                                  ),
                                                ),
                                      ),
                                    ),
                                  ),
                                ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      denuncia.titulo,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF1E3A8A),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getPrioridadeColor(
                                        denuncia.prioridade.name,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      _getPrioridadeTexto(
                                        denuncia.prioridade.name,
                                      ),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: _getPrioridadeColor(
                                          denuncia.prioridade.name,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                denuncia.descricao,
                                style: GoogleFonts.montserrat(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                        denuncia.statusAtual.name,
                                      ).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      _getStatusTexto(
                                        denuncia.statusAtual.name,
                                      ),
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: _getStatusColor(
                                          denuncia.statusAtual.name,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${denuncia.dataCriacao.day.toString().padLeft(2, '0')}/${denuncia.dataCriacao.month.toString().padLeft(2, '0')}',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
