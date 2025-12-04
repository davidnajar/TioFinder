import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';
import 'map_picker_screen.dart';

/// Pantalla per amagar tiós
class HideTioScreen extends StatefulWidget {
  const HideTioScreen({super.key});

  @override
  State<HideTioScreen> createState() => _HideTioScreenState();
}

class _HideTioScreenState extends State<HideTioScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HideTioProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Amagar Tió'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 'delete_all') {
                _showDeleteAllDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_all',
                child: Text('Eliminar tots'),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<HideTioProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (!provider.hasLocationPermission) {
            return _buildPermissionError(provider);
          }

          return Column(
            children: [
              // Botó per amagar tió
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: _buildHideButton(provider),
              ),
              
              // Configuració de Fake Tions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: _buildFakeTionsSettings(provider),
              ),
              
              // Missatges
              if (provider.errorMessage != null)
                _buildMessage(provider.errorMessage!, Colors.red),
              if (provider.successMessage != null)
                _buildMessage(provider.successMessage!, Colors.green),
              
              // Llista de tiós
              Expanded(
                child: _buildTiosList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPermissionError(HideTioProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_off,
              size: 64,
              color: Colors.orange,
            ),
            const SizedBox(height: 24),
            const Text(
              'Cal permís de localització',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Per amagar tiós necessitem accedir a la teva ubicació.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => provider.init(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHideButton(HideTioProvider provider) {
    return Column(
      children: [
        // Botó principal per amagar a la ubicació actual
        GestureDetector(
          onTap: provider.isLoading
              ? null
              : () async {
                  provider.clearMessages();
                  await provider.saveCurrentLocationAsTio();
                },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.withValues(alpha: 0.4),
                  Colors.orange.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.orange.withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.add_location_alt,
                  size: 40,
                  color: Colors.orange,
                ),
                const SizedBox(height: 12),
                const Text(
                  'AMAGAR TIÓ AQUÍ',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Guardar a la ubicació actual',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Botó secundari per obrir el mapa
        GestureDetector(
          onTap: provider.isLoading ? null : () => _openMapPicker(provider),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.green.withValues(alpha: 0.3),
                  Colors.green.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map,
                  size: 24,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                const Text(
                  'TRIAR AL MAPA',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openMapPicker(HideTioProvider provider) async {
    // Obtenir la posició actual per centrar el mapa
    final currentPos = await provider.getCurrentPosition();
    if (currentPos == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No s\'ha pogut obtenir la ubicació actual'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;

    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          mode: MapPickerMode.tioLocation,
          initialLat: currentPos?.lat ?? 41.3851,
          initialLng: currentPos?.lng ?? 2.1734,
        ),
      ),
    );

    if (result != null && mounted) {
      provider.clearMessages();
      await provider.saveTioAtLocation(result.lat, result.lng);
    }
  }

  Widget _buildMessage(String message, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(
            color == Colors.red ? Icons.error : Icons.check_circle,
            color: color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFakeTionsSettings(HideTioProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.settings,
                color: Colors.purple,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Configuració Fake Tions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const Spacer(),
              // Botó per resetejar
              GestureDetector(
                onTap: () => provider.resetFakeTionsSettings(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Reset',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Nombre de fake tions
          _buildSettingRow(
            label: 'Quantitat',
            value: provider.fakeTionsCount?.toString() ?? 'Aleatori (8-15)',
            onDecrease: () {
              final current = provider.fakeTionsCount ?? 10;
              if (current > 0) {
                provider.setFakeTionsCount(current - 1);
              }
            },
            onIncrease: () {
              final current = provider.fakeTionsCount ?? 10;
              if (current < 30) {
                provider.setFakeTionsCount(current + 1);
              }
            },
          ),
          const SizedBox(height: 12),
          
          // Radi de la zona
          _buildSettingRow(
            label: 'Zona (m)',
            value: '${provider.fakeTionsZoneRadius.toInt()}',
            onDecrease: () {
              if (provider.fakeTionsZoneRadius > 50) {
                provider.setFakeTionsZoneRadius(provider.fakeTionsZoneRadius - 50);
              }
            },
            onIncrease: () {
              if (provider.fakeTionsZoneRadius < 500) {
                provider.setFakeTionsZoneRadius(provider.fakeTionsZoneRadius + 50);
              }
            },
          ),
          const SizedBox(height: 12),
          
          // Botó per seleccionar zona al mapa
          _buildZoneMapButton(provider),
          
          const SizedBox(height: 8),
          Text(
            provider.hasFakeTionsZoneCenter
                ? 'Zona personalitzada configurada'
                : 'Zona centrada a la ubicació de l\'usuari',
            style: TextStyle(
              fontSize: 11,
              color: provider.hasFakeTionsZoneCenter 
                  ? Colors.purple.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.5),
              fontStyle: provider.hasFakeTionsZoneCenter ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneMapButton(HideTioProvider provider) {
    return GestureDetector(
      onTap: () => _openZoneMapPicker(provider),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: provider.hasFakeTionsZoneCenter
              ? Colors.purple.withValues(alpha: 0.3)
              : Colors.purple.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.purple.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              provider.hasFakeTionsZoneCenter ? Icons.edit_location_alt : Icons.map,
              color: Colors.purple,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              provider.hasFakeTionsZoneCenter
                  ? 'EDITAR ZONA AL MAPA'
                  : 'SELECCIONAR ZONA AL MAPA',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openZoneMapPicker(HideTioProvider provider) async {
    // Utilitzar el centre configurat o la posició actual
    double initialLat;
    double initialLng;
    
    if (provider.hasFakeTionsZoneCenter) {
      initialLat = provider.fakeTionsZoneCenter!.lat;
      initialLng = provider.fakeTionsZoneCenter!.lng;
    } else {
      final currentPos = await provider.getCurrentPosition();
      if (currentPos == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No s\'ha pogut obtenir la ubicació actual'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      initialLat = currentPos?.lat ?? 41.3851;
      initialLng = currentPos?.lng ?? 2.1734;
    }

    if (!mounted) return;

    final result = await Navigator.push<MapPickerResult>(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerScreen(
          mode: MapPickerMode.fakeTionsZone,
          initialLat: initialLat,
          initialLng: initialLng,
          initialRadius: provider.fakeTionsZoneRadius,
        ),
      ),
    );

    if (result != null && mounted) {
      await provider.setFakeTionsZone(result.lat, result.lng, result.radius ?? 300.0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zona de fake tions configurada!'),
          backgroundColor: Colors.purple,
        ),
      );
    }
  }

  Widget _buildSettingRow({
    required String label,
    required String value,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        Row(
          children: [
            _buildControlButton(Icons.remove, onDecrease),
            Container(
              width: 80,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            _buildControlButton(Icons.add, onIncrease),
          ],
        ),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.purple.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.purple,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildTiosList(HideTioProvider provider) {
    if (provider.savedTios.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Encara no has amagat cap tió',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: provider.savedTios.length,
      itemBuilder: (context, index) {
        final tio = provider.savedTios[index];
        return _buildTioCard(tio, provider);
      },
    );
  }

  Widget _buildTioCard(RadarTarget tio, HideTioProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tio.found
              ? Colors.grey.withValues(alpha: 0.3)
              : Colors.greenAccent.withValues(alpha: 0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: tio.found
                ? Colors.grey.withValues(alpha: 0.3)
                : Colors.greenAccent.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            tio.found ? Icons.check : Icons.forest,
            color: tio.found ? Colors.grey : Colors.greenAccent,
          ),
        ),
        title: Text(
          tio.found ? 'Tió trobat!' : 'Tió amagat',
          style: TextStyle(
            color: tio.found ? Colors.grey : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${tio.lat.toStringAsFixed(6)}, ${tio.lng.toStringAsFixed(6)}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => _showDeleteDialog(tio, provider),
        ),
      ),
    );
  }

  void _showDeleteDialog(RadarTarget tio, HideTioProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Eliminar tió?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Segur que vols eliminar aquest tió?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteTio(tio.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDialog() {
    final provider = context.read<HideTioProvider>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        title: const Text(
          'Eliminar tots els tiós?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Aquesta acció no es pot desfer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel·lar'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAllTios();
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar tots',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
