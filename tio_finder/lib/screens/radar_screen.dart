import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

/// Pantalla del radar per buscar tiós
class RadarScreen extends StatefulWidget {
  const RadarScreen({super.key});

  @override
  State<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends State<RadarScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RadarProvider>();
      provider.init();
      
      // Configurar callback per quan es trobi un tió
      provider.onTioFoundCallback = (tio) {
        _showFoundDialog();
      };
    });
  }

  void _showFoundDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            const Text(
              'HAS TROBAT UN TIÓ!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.greenAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Caga tió, caga torrons!',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Continuar',
                style: TextStyle(fontWeight: FontWeight.bold),
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
      backgroundColor: const Color(0xFF0A0A15),
      appBar: AppBar(
        title: const Text('Radar'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<RadarProvider>(
        builder: (context, provider, child) {
          if (!provider.isInitialized) {
            if (provider.errorMessage != null) {
              return _buildError(provider.errorMessage!);
            }
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.greenAccent),
                  SizedBox(height: 24),
                  Text(
                    'Inicialitzant radar...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Info superior
                    _buildInfoBar(provider),
                    const SizedBox(height: 32),
                    
                    // Indicador de fine search mode
                    if (provider.isFineSearchMode)
                      _buildFineSearchIndicator(provider),
                    
                    // Radar
                    RadarWidget(
                      targets: provider.polarTargets,
                      size: MediaQuery.of(context).size.width - 48,
                      isFineSearchMode: provider.isFineSearchMode,
                    ),
                    const SizedBox(height: 32),
                    
                    // Estadístiques
                    _buildStats(provider),
                  ],
                ),
              ),
              
              // Botó "Tió trobat" quan hi ha un tió pendent
              if (provider.pendingFoundTio != null)
                Positioned(
                  bottom: 24,
                  left: 24,
                  right: 24,
                  child: _buildFoundButton(provider),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFineSearchIndicator(RadarProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.greenAccent.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.greenAccent, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.zoom_in, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 8),
          Text(
            'Mode cerca fina (${provider.effectiveRadarRadius.toStringAsFixed(0)}m)',
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoundButton(RadarProvider provider) {
    return ElevatedButton(
      onPressed: () {
        provider.confirmFoundTio();
        _showFoundDialog();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🎄',
            style: TextStyle(fontSize: 24),
          ),
          SizedBox(width: 12),
          Text(
            'TIÓ TROBAT!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 12),
          Text(
            '🎄',
            style: TextStyle(fontSize: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Tornar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBar(RadarProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            icon: Icons.explore,
            label: 'Direcció',
            value: '${provider.currentHeading.toStringAsFixed(0)}°',
          ),
          _buildInfoItem(
            icon: Icons.my_location,
            label: 'Precisió',
            value: provider.currentPosition != null
                ? '${provider.currentPosition!.accuracy.toStringAsFixed(0)}m'
                : '-',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.greenAccent, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(RadarProvider provider) {
    final realTios = provider.allTargets
        .where((t) => t.type.name == 'realTio' && !t.found)
        .length;
    final foundTios = provider.allTargets
        .where((t) => t.type.name == 'realTio' && t.found)
        .length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            label: 'Tiós pendents',
            value: realTios.toString(),
            color: Colors.greenAccent,
          ),
          _buildStatItem(
            label: 'Tiós trobats',
            value: foundTios.toString(),
            color: Colors.grey,
          ),
          _buildStatItem(
            label: 'Total objectius',
            value: provider.allTargets.length.toString(),
            color: Colors.white54,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
