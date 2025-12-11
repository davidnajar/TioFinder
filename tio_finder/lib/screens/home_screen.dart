import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../models/models.dart';

/// Pantalla principal amb opcions per buscar tions
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _secretTapCount = 0;
  DateTime? _lastTapTime;
  int _totalTiosFound = 0;
  int _unlockedAchievements = 0;
  bool _hasLoadedStats = false;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload stats when returning to this screen
    if (_hasLoadedStats) {
      _loadStats();
    }
  }

  Future<void> _loadStats() async {
    final storage = StorageService();
    await storage.init();
    final total = await storage.getTotalTiosFound();
    final distance = await storage.getTotalDistanceWalked();
    final fastest = await storage.getFastestFindTime();
    
    // Calcular assoliments desbloqueats
    int unlocked = 0;
    for (final achievement in Achievements.all) {
      if (achievement.isUnlocked(
        tiosFound: total,
        distanceWalked: distance,
        fastestTime: fastest,
      )) {
        unlocked++;
      }
    }
    
    setState(() {
      _totalTiosFound = total;
      _unlockedAchievements = unlocked;
      _hasLoadedStats = true;
    });
  }

  void _onTitleTapped(BuildContext context) {
    final now = DateTime.now();

    // Si ha passat massa temps des de l'últim toc, reiniciem el comptador
    if (_lastTapTime == null ||
        now.difference(_lastTapTime!) > const Duration(seconds: 2)) {
      _secretTapCount = 0;
    }

    _lastTapTime = now;
    _secretTapCount++;

    if (_secretTapCount >= 10) {
      _secretTapCount = 0;

      // Navegar al menú ocult d'"amagar tió"
      Navigator.pushNamed(context, '/hide');

      // Opcional: mostrar un petit SnackBar per indicar que és un mode secret
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode AMAGAR TIÓ desbloquejat 🪵'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            tooltip: 'Configuració',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Títol amb Easter Egg
                GestureDetector(
                  onTap: () => _onTitleTapped(context),
                  child: const Text(
                    '🪵 TIÓ FINDER',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Radar de cerca de tions',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 16),
                // Badges amb estadístiques
                if (_totalTiosFound > 0 || _unlockedAchievements > 0)
                  Column(
                    children: [
                      if (_totalTiosFound > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.greenAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.greenAccent.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🏆',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_totalTiosFound tions trobats',
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_totalTiosFound > 0 && _unlockedAchievements > 0)
                        const SizedBox(height: 8),
                      if (_unlockedAchievements > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amberAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.amberAccent.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                '🏅',
                                style: TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$_unlockedAchievements assoliments',
                                style: const TextStyle(
                                  color: Colors.amberAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 48),

                // (Botó amagar tió ocult → eliminat de la UI)

                const SizedBox(height: 24),

                // Botó Radar
                _buildMenuButton(
                  context,
                  icon: Icons.radar,
                  label: 'RADAR',
                  color: Colors.greenAccent,
                  onTap: () => Navigator.pushNamed(context, '/radar'),
                ),

                const SizedBox(height: 24),

                // Botó Estadístiques
                _buildMenuButton(
                  context,
                  icon: Icons.bar_chart,
                  label: 'ESTADÍSTIQUES',
                  color: Colors.blueAccent,
                  onTap: () => Navigator.pushNamed(context, '/statistics'),
                ),

                const SizedBox(height: 24),

                // Botó Assoliments
                _buildMenuButton(
                  context,
                  icon: Icons.emoji_events,
                  label: 'ASSOLIMENTS',
                  color: Colors.amberAccent,
                  onTap: () => Navigator.pushNamed(context, '/achievements'),
                ),

                const SizedBox(height: 80),

                // Llegenda opcional (segueix comentada si no la vols)
                // Container(
                //   padding: const EdgeInsets.all(16),
                //   decoration: BoxDecoration(
                //     color: Colors.white.withValues(alpha: 0.05),
                //     borderRadius: BorderRadius.circular(12),
                //   ),
                //   child: Column(
                //     children: [
                //       _buildLegendItem(
                //         color: Colors.greenAccent,
                //         text: 'Tió real',
                //       ),
                //       const SizedBox(height: 8),
                //       _buildLegendItem(
                //         color: Colors.yellowAccent,
                //         text: 'Pista falsa persistent',
                //       ),
                //       const SizedBox(height: 8),
                //       _buildLegendItem(
                //         color: Colors.redAccent,
                //         text: 'Pista falsa que desapareix',
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
