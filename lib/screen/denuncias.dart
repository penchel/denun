import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../domain/Arquivo.dart';
import '../domain/Denuncia.dart';

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

  // Lista de denúncias
  List<Denuncia> _denuncias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarDenuncias();
  }

  Future<void> _carregarDenuncias() async {
    setState(() => _isLoading = true);

    // Simula um carregamento da rede
    await Future.delayed(const Duration(seconds: 1));

    // --- DADOS DE EXEMPLO (MOCK) ---
    // No futuro, aqui será substituido pelos dados do Firestore.
    var uuid = const Uuid();
    final mockData = [
      Denuncia(
        idDenuncia: uuid.v4(),
        titulo: 'Buraco gigante na Av. João César',
        descricao:
            'Existe um buraco perigoso na avenida principal, perto do número 500, que já causou acidentes com motociclistas. A situação é crítica e precisa de reparo urgente.',
        localizacao: Localizacao(latitude: -19.9023, longitude: -44.0321),
        endereco: 'Av. João César de Oliveira, 500 - Contagem/MG',
        autorId: 'user123',
        dataCriacao: DateTime.now().subtract(const Duration(days: 2)),
        statusAtual: StatusDenuncia.novo,
        prioridade: Prioridade.alta,
        arquivos: [
          Arquivo(
              idArquivo: uuid.v4(),
              urlArquivo: 'https://placehold.co/600x400/orange/white?text=Foto+do+Buraco',
              tipo: TipoArquivo.foto)
        ],
      ),
      Denuncia(
        idDenuncia: uuid.v4(),
        titulo: 'Lixo acumulado na praça do bairro Eldorado',
        descricao:
            'A lixeira da praça central está transbordando há mais de uma semana, atraindo animais e causando mau cheiro. Moradores estão reclamando bastante.',
        localizacao: Localizacao(latitude: -19.9245, longitude: -43.9352),
        endereco: 'Praça do Coreto, s/n - Contagem/MG',
        autorId: 'user456',
        dataCriacao: DateTime.now().subtract(const Duration(days: 5)),
        statusAtual: StatusDenuncia.emAnalise,
        prioridade: Prioridade.media,
      ),
      Denuncia(
        idDenuncia: uuid.v4(),
        titulo: 'Poste de luz queimado na Rua das Gaivotas',
        descricao:
            'O poste em frente à padaria está com a luz queimada, deixando a rua muito escura e perigosa durante a noite. Vários assaltos já ocorreram na área.',
        localizacao: Localizacao(latitude: -19.8653, longitude: -43.9634),
        endereco: 'Rua das Gaivotas, 123 - Pampulha, Belo Horizonte/MG',
        autorId: 'user789',
        dataCriacao: DateTime.now().subtract(const Duration(days: 10)),
        statusAtual: StatusDenuncia.concluida,
        prioridade: Prioridade.baixa,
      ),
      Denuncia(
        idDenuncia: uuid.v4(),
        titulo: 'Veículo abandonado há mais de um mês',
        descricao:
            'Carro modelo Fiat Uno, cor branca, está abandonado na rua há mais de um mês, ocupando uma vaga e acumulando sujeira. A placa é HMA-4321.',
        localizacao: Localizacao(latitude: -19.9328, longitude: -43.9298),
        endereco: 'Rua dos Guajajaras, 1100 - Lourdes, Belo Horizonte/MG',
        autorId: 'user101',
        dataCriacao: DateTime.now().subtract(const Duration(days: 35)),
        statusAtual: StatusDenuncia.emAtendimento,
        prioridade: Prioridade.media,
      ),
    ];

    if (mounted) {
      setState(() {
        _denuncias = mockData;
        _isLoading = false;
      });
    }
  }

  List<Denuncia> get _denunciasFiltradas {
    if (_isLoading) return [];
    return _denuncias.where((d) {
      bool passaStatus =
          _filtroStatus == null || d.statusAtual.name == _filtroStatus;
      bool passaPrioridade =
          _filtroPrioridade == null || d.prioridade.name == _filtroPrioridade;
      bool passaBusca = _textoBusca.isEmpty ||
          d.titulo.toLowerCase().contains(_textoBusca.toLowerCase()) ||
          d.descricao.toLowerCase().contains(_textoBusca.toLowerCase()) ||
          (d.endereco?.toLowerCase().contains(_textoBusca.toLowerCase()) ?? false);
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
                      ...StatusDenuncia.values.map((status) => FilterChip(
                            label: Text(_getStatusTexto(status.name)),
                            selected: _filtroStatus == status.name,
                            onSelected: (selected) {
                              setState(() => _filtroStatus = selected ? status.name : null);
                              setModalState(() {});
                            },
                          )),
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
                      ...Prioridade.values.map((p) => FilterChip(
                            label: Text(_getPrioridadeTexto(p.name)),
                            selected: _filtroPrioridade == p.name,
                            onSelected: (selected) {
                              setState(() => _filtroPrioridade = selected ? p.name : null);
                              setModalState(() {});
                            },
                          )),
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

  void _verDetalhes(Denuncia denuncia) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          denuncia.titulo,
          style: GoogleFonts.montserrat(fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A)),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (denuncia.arquivos.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    denuncia.arquivos.first.urlArquivo,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported, size: 50),
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
              _buildDetailRow(Icons.location_on, denuncia.endereco ?? 'Endereço não informado'),
              _buildDetailRow(Icons.calendar_today, '${denuncia.dataCriacao.day.toString().padLeft(2, '0')}/${denuncia.dataCriacao.month.toString().padLeft(2, '0')}/${denuncia.dataCriacao.year}'),
              _buildDetailRow(Icons.flag, 'Status: ${_getStatusTexto(denuncia.statusAtual.name)}'),
              _buildDetailRow(Icons.priority_high, 'Prioridade: ${_getPrioridadeTexto(denuncia.prioridade.name)}'),

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
              style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final denunciasFiltradas = _denunciasFiltradas;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Minhas Denúncias',
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

          // Lista de denúncias
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : denunciasFiltradas.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _denuncias.isEmpty
                                    ? Icons.inbox_outlined
                                    : Icons.search_off,
                                size: 80,
                                color: const Color(0xFF1E3A8A).withOpacity(0.7),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _denuncias.isEmpty
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
                                _denuncias.isEmpty
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
                      )
                    : RefreshIndicator(
                        onRefresh: _carregarDenuncias,
                        child: ListView.builder(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getPrioridadeColor(
                                                      denuncia.prioridade.name)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              _getPrioridadeTexto(
                                                  denuncia.prioridade.name),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w600,
                                                color: _getPrioridadeColor(
                                                    denuncia.prioridade.name),
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
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(denuncia
                                                      .statusAtual.name)
                                                  .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _getStatusTexto(
                                                  denuncia.statusAtual.name),
                                              style: GoogleFonts.montserrat(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: _getStatusColor(
                                                    denuncia.statusAtual.name),
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
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

