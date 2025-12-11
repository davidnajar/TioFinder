import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Pantalla d'estadístiques del joc
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;
  
  int _totalFound = 0;
  double _totalDistance = 0.0;
  int? _fastestTime;
  int _totalTios = 0;
  int _foundTios = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    await _storage.init();
    
    final found = await _storage.getTotalTiosFound();
    final distance = await _storage.getTotalDistanceWalked();
    final fastest = await _storage.getFastestFindTime();
    final allTios = await _storage.getAllTios();
    final foundTios = allTios.where((t) => t.found).length;
    
    setState(() {
      _totalFound = found;
      _totalDistance = distance;
      _fastestTime = fastest;
      _totalTios = allTios.length;
      _foundTios = foundTios;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('📊 Estadístiques'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Títol
                    const Text(
                      'Els teus rècords',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Continua buscant tions!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Estadístiques principals
                    _buildStatCard(
                      icon: Icons.emoji_events,
                      label: 'Tions trobats',
                      value: _totalFound.toString(),
                      color: Colors.greenAccent,
                      emoji: '🏆',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStatCard(
                      icon: Icons.directions_walk,
                      label: 'Distància recorreguda',
                      value: _formatDistance(_totalDistance),
                      color: Colors.blueAccent,
                      emoji: '🚶',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStatCard(
                      icon: Icons.timer,
                      label: 'Rècord de temps',
                      value: _fastestTime != null 
                          ? _formatTime(_fastestTime!)
                          : 'Encara no',
                      color: Colors.orangeAccent,
                      emoji: '⚡',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildStatCard(
                      icon: Icons.inventory,
                      label: 'Tions actuals',
                      value: '$_foundTios / $_totalTios trobats',
                      color: Colors.purpleAccent,
                      emoji: '🪵',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Missatge motivacional
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.greenAccent.withValues(alpha: 0.2),
                            Colors.blueAccent.withValues(alpha: 0.2),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.greenAccent.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '💪',
                            style: TextStyle(fontSize: 48),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _getMotivationalMessage(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required String emoji,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Emoji i icona
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
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
                    fontSize: 24,
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

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(2)} km';
    }
  }

  String _formatTime(int seconds) {
    if (seconds < 60) {
      return '$seconds seg';
    } else if (seconds < 3600) {
      final mins = seconds ~/ 60;
      final secs = seconds % 60;
      return '$mins min $secs seg';
    } else {
      final hours = seconds ~/ 3600;
      final mins = (seconds % 3600) ~/ 60;
      return '$hours h $mins min';
    }
  }

  String _getMotivationalMessage() {
    if (_totalFound == 0) {
      return 'Comença la teva aventura! Troba el teu primer tió!';
    } else if (_totalFound < 5) {
      return 'Bon començament! Continua cercant més tions!';
    } else if (_totalFound < 10) {
      return 'Molt bé! Ja ets un expert buscador de tions!';
    } else if (_totalFound < 20) {
      return 'Increïble! Ets un mestre del radar de tions!';
    } else {
      return 'Llegendari! Ets el millor caçador de tions! 🌟';
    }
  }
}
