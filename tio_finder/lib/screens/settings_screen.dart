import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Pantalla de configuració de l'app
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;

  int? _fakeTionsCount;
  double _fakeTionsRadius = 300.0;
  int _radarZoomLevel = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _storage.init();

    final count = await _storage.getFakeTionsCount();
    final radius = await _storage.getFakeTionsZoneRadius();
    final zoom = await _storage.getRadarZoomLevel();

    setState(() {
      _fakeTionsCount = count;
      _fakeTionsRadius = radius;
      _radarZoomLevel = zoom;
      _isLoading = false;
    });
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Reiniciar configuració?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Això restablirà totes les configuracions als valors per defecte.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.resetFakeTionsSettings();
      await _storage.saveRadarZoomLevel(0);
      await _loadSettings();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Configuració restablerta'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> _resetAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '⚠️ Esborrar TOTES les dades?',
          style: TextStyle(color: Colors.redAccent),
        ),
        content: const Text(
          'Això eliminarà TOTS els tions guardats, estadístiques i configuracions. Aquesta acció NO es pot desfer!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel·lar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            child: const Text('Esborrar tot'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _storage.deleteAllTios();
      await _storage.deleteAllFakeTionsZones();
      await _storage.resetFakeTionsSettings();
      await _storage.saveRadarZoomLevel(0);
      await _storage.clearSessionStartTime();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Totes les dades han estat esborrades'),
            backgroundColor: Colors.redAccent,
            duration: Duration(seconds: 3),
          ),
        );
        // Tornar a la pantalla principal
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('⚙️ Configuració'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : SafeArea(
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  const Text(
                    'Configuració del joc',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Secció Radar
                  _buildSectionTitle('Radar'),
                  _buildInfoCard(
                    icon: Icons.zoom_in,
                    title: 'Nivell de zoom per defecte',
                    value: 'x${[1.0, 1.5, 2.0, 4.0, 6.0][_radarZoomLevel]}',
                    color: Colors.orangeAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'El zoom es pot canviar en qualsevol moment des de la pantalla del radar.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Secció Fake Tions
                  _buildSectionTitle('Fake Tions'),
                  _buildInfoCard(
                    icon: Icons.psychology,
                    title: 'Nombre de fake tions',
                    value: _fakeTionsCount?.toString() ?? 'Aleatori',
                    color: Colors.purpleAccent,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoCard(
                    icon: Icons.radio_button_unchecked,
                    title: 'Radi de zona',
                    value: '${_fakeTionsRadius.toStringAsFixed(0)} metres',
                    color: Colors.cyanAccent,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Configura els fake tions des del menú secret (toca 10 vegades el títol).',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Secció Accions
                  _buildSectionTitle('Accions'),
                  _buildActionButton(
                    icon: Icons.help_outline,
                    label: 'Veure ajuda i tutorial',
                    color: Colors.blueAccent,
                    onTap: () => Navigator.pushNamed(context, '/help'),
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.refresh,
                    label: 'Reiniciar configuració',
                    color: Colors.orangeAccent,
                    onTap: _resetSettings,
                  ),
                  const SizedBox(height: 12),
                  _buildActionButton(
                    icon: Icons.delete_forever,
                    label: 'Esborrar totes les dades',
                    color: Colors.redAccent,
                    onTap: _resetAllData,
                  ),
                  const SizedBox(height: 32),

                  // Informació de l'app
                  _buildSectionTitle('Informació'),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '🪵',
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tió Finder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Versió 0.1.0',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Una app per buscar tions amb un radar estil Dragon Ball',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.greenAccent,
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
