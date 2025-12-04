import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Mode de selecció del mapa
enum MapPickerMode {
  /// Seleccionar una ubicació exacta per amagar un tió
  tioLocation,
  /// Seleccionar el centre de la zona per als fake tions
  fakeTionsZone,
}

/// Resultat de la selecció del mapa
class MapPickerResult {
  final double lat;
  final double lng;
  /// Radi de la zona (només per al mode fakeTionsZone)
  final double? radius;

  const MapPickerResult({
    required this.lat,
    required this.lng,
    this.radius,
  });
}

/// Pantalla per seleccionar una ubicació al mapa
class MapPickerScreen extends StatefulWidget {
  final MapPickerMode mode;
  final double initialLat;
  final double initialLng;
  /// Radi inicial per a la zona de fake tions (en metres)
  final double? initialRadius;

  const MapPickerScreen({
    super.key,
    required this.mode,
    required this.initialLat,
    required this.initialLng,
    this.initialRadius,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _selectedLocation;
  late MapController _mapController;
  late double _radius;

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(widget.initialLat, widget.initialLng);
    _mapController = MapController();
    _radius = widget.initialRadius ?? 300.0;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  String get _title {
    switch (widget.mode) {
      case MapPickerMode.tioLocation:
        return 'Selecciona ubicació del Tió';
      case MapPickerMode.fakeTionsZone:
        return 'Selecciona zona Fake Tions';
    }
  }

  String get _subtitle {
    switch (widget.mode) {
      case MapPickerMode.tioLocation:
        return 'Toca el mapa per triar on amagar el tió';
      case MapPickerMode.fakeTionsZone:
        return 'Toca el mapa per triar el centre de la zona';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(_title),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Subtítol informatiu
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.black26,
            child: Text(
              _subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          // Mapa
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation,
                initialZoom: 16.0,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedLocation = point;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.tio_finder.app',
                ),
                // Cercle de la zona (per al mode fakeTionsZone)
                if (widget.mode == MapPickerMode.fakeTionsZone)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: _selectedLocation,
                        radius: _radius,
                        useRadiusInMeter: true,
                        color: Colors.purple.withValues(alpha: 0.2),
                        borderColor: Colors.purple,
                        borderStrokeWidth: 2,
                      ),
                    ],
                  ),
                // Marcador de la ubicació seleccionada
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation,
                      width: 50,
                      height: 50,
                      child: Icon(
                        widget.mode == MapPickerMode.tioLocation
                            ? Icons.forest
                            : Icons.my_location,
                        color: widget.mode == MapPickerMode.tioLocation
                            ? Colors.green
                            : Colors.purple,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Controls inferiors
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Coordenades seleccionades
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            
            // Selector de radi (només per al mode fakeTionsZone)
            if (widget.mode == MapPickerMode.fakeTionsZone) ...[
              const SizedBox(height: 16),
              _buildRadiusSelector(),
            ],
            
            const SizedBox(height: 16),
            
            // Botons d'acció
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Cancel·lar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _confirmSelection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.mode == MapPickerMode.tioLocation
                          ? Colors.green
                          : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.mode == MapPickerMode.tioLocation
                              ? Icons.forest
                              : Icons.check_circle,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.mode == MapPickerMode.tioLocation
                              ? 'Amagar Tió Aquí'
                              : 'Confirmar Zona',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadiusSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Radi de la zona',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            Text(
              '${_radius.toInt()}m',
              style: const TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: Colors.purple,
            inactiveTrackColor: Colors.purple.withValues(alpha: 0.3),
            thumbColor: Colors.purple,
            overlayColor: Colors.purple.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: _radius,
            min: 50,
            max: 500,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _radius = value;
              });
            },
          ),
        ),
      ],
    );
  }

  void _confirmSelection() {
    final result = MapPickerResult(
      lat: _selectedLocation.latitude,
      lng: _selectedLocation.longitude,
      radius: widget.mode == MapPickerMode.fakeTionsZone ? _radius : null,
    );
    Navigator.pop(context, result);
  }
}
