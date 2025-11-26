import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geocoding/geocoding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../domain/Denuncia.dart';
import '../domain/Arquivo.dart';
import '../services/denuncia_service.dart';
import '../services/arquivo_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CriarDenunciaPage extends StatefulWidget {
  final LatLng localizacao;

  const CriarDenunciaPage({super.key, required this.localizacao});

  @override
  State<CriarDenunciaPage> createState() => _CriarDenunciaPageState();
}

class _CriarDenunciaPageState extends State<CriarDenunciaPage> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _enderecoController = TextEditingController();

  final DenunciaService _denunciaService = DenunciaService();
  final ArquivoService _arquivoService = ArquivoService();
  final ImagePicker _imagePicker = ImagePicker();

  Prioridade _prioridadeSelecionada = Prioridade.baixa;
  List<XFile> _arquivosSelecionados = [];
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _buscarEndereco();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  // ... (existing imports)

  Future<void> _buscarEndereco() async {
    print(
      '📍 Buscando endereço para: ${widget.localizacao.latitude}, ${widget.localizacao.longitude}',
    );

    // Tenta primeiro com o pacote geocoding
    try {
      await setLocaleIdentifier('pt_BR');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        widget.localizacao.latitude,
        widget.localizacao.longitude,
      );

      if (placemarks.isNotEmpty) {
        _preencherEndereco(placemarks[0]);
        return;
      }
    } catch (e) {
      print('❌ Erro no pacote geocoding: $e');
      print('⚠️ Tentando fallback HTTP...');
    }

    // Fallback HTTP (Debug)
    try {
      final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

      if (apiKey.isEmpty || apiKey == 'COLE_SUA_API_KEY_AQUI') {
        print(
          '⚠️ API Key não configurada no .env. Pule esta etapa se não quiser debugar manualmente.',
        );
        return;
      }

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${widget.localizacao.latitude},${widget.localizacao.longitude}&key=$apiKey&language=pt_BR',
      );

      print('🌐 Request HTTP: $url');
      final response = await http.get(url);
      print('🌐 Response Status: ${response.statusCode}');
      print('🌐 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final results = data['results'] as List;
          if (results.isNotEmpty) {
            final addressComponents = results[0]['address_components'] as List;
            String rua = '';
            String numero = '';
            String bairro = '';
            String cidade = '';

            for (var c in addressComponents) {
              final types = c['types'] as List;
              if (types.contains('route')) rua = c['long_name'];
              if (types.contains('street_number')) numero = c['long_name'];
              if (types.contains('sublocality')) bairro = c['long_name'];
              if (types.contains('administrative_area_level_2'))
                cidade = c['long_name'];
            }

            String endereco = rua;
            if (numero.isNotEmpty) endereco += ', $numero';
            if (bairro.isNotEmpty) endereco += ' - $bairro';
            if (cidade.isNotEmpty) endereco += ' - $cidade';

            if (mounted) {
              setState(() {
                _enderecoController.text = endereco;
              });
            }
          }
        } else {
          print('❌ Erro na API Geocoding: ${data['status']}');
          print('❌ Mensagem: ${data['error_message']}');
        }
      }
    } catch (e) {
      print('❌ Erro no fallback HTTP: $e');
    }
  }

  void _preencherEndereco(Placemark place) {
    String endereco = '';
    if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
      endereco += place.thoroughfare!;
    }
    if (place.subThoroughfare != null && place.subThoroughfare!.isNotEmpty) {
      if (endereco.isNotEmpty) endereco += ', ';
      endereco += place.subThoroughfare!;
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      if (endereco.isNotEmpty) endereco += ' - ';
      endereco += place.subLocality!;
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      if (endereco.isNotEmpty) endereco += ' - ';
      endereco += place.locality!;
    }
    if (mounted) {
      setState(() {
        _enderecoController.text = endereco;
      });
    }
  }

  Future<void> _adicionarFoto(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(source: source);
      if (image != null) {
        setState(() {
          _arquivosSelecionados.add(image);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao selecionar imagem: $e')));
    }
  }

  Future<void> _salvarDenuncia() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Usuário não autenticado');

      print('🚀 Iniciando criação da denúncia...');

      final uuid = const Uuid();
      final denunciaId = uuid.v4();

      // Upload de arquivos
      List<String> urlsArquivos = [];
      for (var arquivo in _arquivosSelecionados) {
        print('📤 Fazendo upload de: ${arquivo.path}');
        final tipo = ArquivoService.determinarTipo(arquivo.name);
        final url = await _arquivoService.uploadArquivo(
          arquivo: arquivo,
          denunciaId: denunciaId,
          tipo: tipo,
        );
        if (url != null) {
          urlsArquivos.add(url);
        }
      }

      final arquivos = urlsArquivos.map((url) {
        final tipo = ArquivoService.determinarTipo(url);
        return Arquivo(idArquivo: uuid.v4(), urlArquivo: url, tipo: tipo);
      }).toList();

      final denuncia = Denuncia(
        idDenuncia: denunciaId,
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        endereco: _enderecoController.text.isEmpty
            ? null
            : _enderecoController.text,
        localizacao: Localizacao(
          latitude: widget.localizacao.latitude,
          longitude: widget.localizacao.longitude,
        ),
        autorId: user.uid,
        prioridade: _prioridadeSelecionada,
        arquivos: arquivos,
      );

      print('💾 Salvando no Firestore...');
      final sucesso = await _denunciaService.criarDenuncia(denuncia);

      if (!mounted) return;

      if (sucesso != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Denúncia criada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retorna true para indicar sucesso
      } else {
        throw Exception('Falha ao salvar no banco de dados');
      }
    } catch (e) {
      print('❌ Erro: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _salvando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Nova Denúncia',
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFF1E3A8A),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Localização Selecionada',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${widget.localizacao.latitude.toStringAsFixed(6)}, ${widget.localizacao.longitude.toStringAsFixed(6)}',
                        style: GoogleFonts.montserrat(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _tituloController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Descrição',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _enderecoController,
                decoration: InputDecoration(
                  labelText: 'Endereço (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.map),
                ),
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<Prioridade>(
                value: _prioridadeSelecionada,
                decoration: InputDecoration(
                  labelText: 'Prioridade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.priority_high),
                ),
                items: Prioridade.values.map((p) {
                  String texto = p.name;
                  if (p == Prioridade.baixa) texto = 'Baixa';
                  if (p == Prioridade.media) texto = 'Média';
                  if (p == Prioridade.alta) texto = 'Alta';
                  return DropdownMenuItem(value: p, child: Text(texto));
                }).toList(),
                onChanged: (value) {
                  if (value != null)
                    setState(() => _prioridadeSelecionada = value);
                },
              ),
              const SizedBox(height: 24),

              Text(
                'Fotos',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _salvando
                          ? null
                          : () => _adicionarFoto(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Câmera'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _salvando
                          ? null
                          : () => _adicionarFoto(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeria'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
              if (_arquivosSelecionados.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _arquivosSelecionados.length,
                    itemBuilder: (context, index) {
                      final arquivo = _arquivosSelecionados[index];
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: kIsWeb
                                  ? Image.network(
                                      arquivo.path,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(arquivo.path),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _arquivosSelecionados.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _salvando ? null : _salvarDenuncia,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _salvando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'CRIAR DENÚNCIA',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
