import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/style_guide.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Centro aproximado de la región de las Altas Montañas (Orizaba / Córdoba)
  final LatLng _initialCenter = const LatLng(18.8654, -97.0864);
  final double _initialZoom = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mapa', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
          minZoom: 8.0,
          maxZoom: 18.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.smartur.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: _initialCenter,
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: SmarturStyle.pink,
                  size: 44,
                ),
              ),
              Marker(
                point: const LatLng(18.8496, -97.1036), // Orizaba Centro
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: SmarturStyle.purple,
                  size: 44,
                ),
              ),
               Marker(
                point: const LatLng(18.8841, -96.9242), // Córdoba Centro
                width: 50,
                height: 50,
                child: const Icon(
                  Icons.location_on,
                  color: SmarturStyle.blue,
                  size: 44,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
