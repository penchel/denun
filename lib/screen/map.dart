import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/Denuncia.dart';
import '../services/denuncia_service.dart';
import 'criar_denuncia.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  final DenunciaService _denunciaService = DenunciaService();

  // Coordenadas iniciais — exemplo: Belo Horizonte
  final LatLng _center = const LatLng(-19.9245, -43.9352);

  // Marcador selecionado
  LatLng? _selectedPosition;
  Marker? _selectedMarker;
  Set<Marker> _markers = {};

  // Estilo do mapa para esconder POIs
  final String _mapStyle = '''
    [
      {
        "featureType": "poi",
        "stylers": [
          { "visibility": "off" }
        ]
      }
    ]
  ''';

  @override
  void initState() {
    super.initState();
    _carregarDenuncias();
  }

  Future<void> _carregarDenuncias() async {
    try {
      final denuncias = await _denunciaService.listarDenuncias();

      setState(() {
        // Mantém o marcador selecionado se existir
        if (_selectedMarker != null) {
          _markers = {_selectedMarker!};
        } else {
          _markers = {};
        }

        // Adiciona marcadores das denúncias
        for (var denuncia in denuncias) {
          _markers.add(
            Marker(
              markerId: MarkerId(denuncia.idDenuncia),
              position: LatLng(
                denuncia.localizacao.latitude,
                denuncia.localizacao.longitude,
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure,
              ),
              infoWindow: InfoWindow(
                title: denuncia.titulo,
                snippet: denuncia.descricao,
              ),
            ),
          );
        }
      });
    } catch (e) {
      print('Erro ao carregar denúncias no mapa: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController.setMapStyle(_mapStyle);
  }

  void _onMapTap(LatLng position) async {
    setState(() {
      _selectedPosition = position;

      // Remove apenas o marcador de seleção anterior, mantendo os outros
      _markers.removeWhere((m) => m.markerId.value == 'selected');

      // Adiciona novo marcador de seleção
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

    // Navega para a página de criação
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CriarDenunciaPage(localizacao: position),
      ),
    );

    // Se criou com sucesso, limpa a seleção e recarrega
    if (result == true) {
      setState(() {
        _selectedPosition = null;
        _selectedMarker = null;
        _markers.removeWhere((m) => m.markerId.value == 'selected');
      });
      _carregarDenuncias();
    }
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
            initialCameraPosition: CameraPosition(target: _center, zoom: 13.0),
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
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
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
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
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
