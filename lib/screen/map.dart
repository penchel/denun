import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/Denuncia.dart';
import '../domain/Arquivo.dart';
import '../services/denuncia_service.dart';
import '../services/arquivo_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final DenunciaService _denunciaService = DenunciaService();
  final ArquivoService _arquivoService = ArquivoService();
  final ImagePicker _imagePicker = ImagePicker();

  // Coordenadas iniciais — exemplo: Belo Horizonte
  final LatLng _center = const LatLng(-19.9245, -43.9352);
  
  // Marcador selecionado
  LatLng? _selectedPosition;
  Marker? _selectedMarker;
  Set<Marker> _markers = {};

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedPosition = position;
      
      // Remove marcador anterior
      _markers.clear();
      
      // Adiciona novo marcador
      _selectedMarker = Marker(
        markerId: const MarkerId('selected'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(
          title: 'Localização selecionada',
          snippet: 'Toque no botão para criar denúncia',
        ),
      );
      
      _markers.add(_selectedMarker!);
    });
    
    // Mostra diálogo para criar denúncia
    _mostrarDialogoCriarDenuncia(position);
  }

  void _mostrarDialogoCriarDenuncia(LatLng position) {
    final tituloController = TextEditingController();
    final descricaoController = TextEditingController();
    final enderecoController = TextEditingController();
    Prioridade prioridadeSelecionada = Prioridade.baixa;
    List<File> arquivosSelecionados = [];
    bool salvando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            'Nova Denúncia',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Localização: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
                  style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tituloController,
                  decoration: InputDecoration(
                    labelText: 'Título *',
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.title),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descricaoController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Descrição *',
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: enderecoController,
                  decoration: InputDecoration(
                    labelText: 'Endereço (opcional)',
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<Prioridade>(
                  value: prioridadeSelecionada,
                  decoration: InputDecoration(
                    labelText: 'Prioridade',
                    labelStyle: GoogleFonts.montserrat(),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.priority_high),
                  ),
                  items: Prioridade.values.map((p) {
                    String texto = p.name;
                    if (p == Prioridade.baixa) texto = 'Baixa';
                    if (p == Prioridade.media) texto = 'Média';
                    if (p == Prioridade.alta) texto = 'Alta';
                    return DropdownMenuItem(
                      value: p,
                      child: Text(texto),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => prioridadeSelecionada = value);
                    }
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: salvando ? null : () async {
                          final image = await _imagePicker.pickImage(source: ImageSource.camera);
                          if (image != null) {
                            setDialogState(() => arquivosSelecionados.add(File(image.path)));
                          }
                        },
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Foto'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: salvando ? null : () async {
                          final image = await _imagePicker.pickImage(source: ImageSource.gallery);
                          if (image != null) {
                            setDialogState(() => arquivosSelecionados.add(File(image.path)));
                          }
                        },
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Galeria'),
                      ),
                    ),
                  ],
                ),
                if (arquivosSelecionados.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${arquivosSelecionados.length} arquivo(s) selecionado(s)',
                    style: GoogleFonts.montserrat(fontSize: 12, color: Colors.green),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: salvando ? null : () {
                Navigator.pop(context);
                setState(() {
                  _selectedPosition = null;
                  _markers.clear();
                });
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.montserrat(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: salvando ? null : () async {
                if (tituloController.text.isEmpty || descricaoController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Preencha título e descrição',
                        style: GoogleFonts.montserrat(),
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                setDialogState(() => salvando = true);

                try {
                  User? user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    throw Exception('Usuário não autenticado');
                  }

                  // Cria ID único para a denúncia
                  final uuid = const Uuid();
                  final denunciaId = uuid.v4();

                  // Faz upload dos arquivos
                  List<String> urlsArquivos = [];
                  for (var arquivo in arquivosSelecionados) {
                    final tipo = ArquivoService.determinarTipo(arquivo.path);
                    final url = await _arquivoService.uploadArquivo(
                      arquivo: arquivo,
                      denunciaId: denunciaId,
                      tipo: tipo,
                    );
                    if (url != null) {
                      urlsArquivos.add(url);
                    }
                  }

                  // Cria objetos Arquivo
                  final arquivos = urlsArquivos.map((url) {
                    final tipo = ArquivoService.determinarTipo(url);
                    return Arquivo(
                      idArquivo: uuid.v4(),
                      urlArquivo: url,
                      tipo: tipo,
                    );
                  }).toList();

                  // Cria a denúncia
                  final denuncia = Denuncia(
                    idDenuncia: denunciaId,
                    titulo: tituloController.text,
                    descricao: descricaoController.text,
                    endereco: enderecoController.text.isEmpty ? null : enderecoController.text,
                    localizacao: Localizacao(
                      latitude: position.latitude,
                      longitude: position.longitude,
                    ),
                    autorId: user.uid,
                    prioridade: prioridadeSelecionada,
                    arquivos: arquivos,
                  );

                  // Salva no Firestore
                  final sucesso = await _denunciaService.criarDenuncia(denuncia);

                  if (context.mounted) {
                    Navigator.pop(context);
                    
                    if (sucesso != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Denúncia criada com sucesso!',
                            style: GoogleFonts.montserrat(),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      
                      // Limpa seleção
                      setState(() {
                        _selectedPosition = null;
                        _markers.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Erro ao criar denúncia',
                            style: GoogleFonts.montserrat(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Erro: ${e.toString()}',
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: salvando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Criar',
                      style: GoogleFonts.montserrat(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Mapa de Denúncias',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            onTap: _onMapTap,
            initialCameraPosition: CameraPosition(
              target: _center,
              zoom: 13.0,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            markers: _markers,
          ),
          if (_selectedPosition != null)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Localização selecionada',
                        style: GoogleFonts.montserrat(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Toque no mapa para selecionar outra localização',
                        style: GoogleFonts.montserrat(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
