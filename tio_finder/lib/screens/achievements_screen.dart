import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/storage_service.dart';

/// Pantalla d'assoliments/fites
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final StorageService _storage = StorageService();
  bool _isLoading = true;

  int _tiosFound = 0;
  double _distanceWalked = 0.0;
  int? _fastestTime;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _storage.init();

    final found = await _storage.getTotalTiosFound();
    final distance = await _storage.getTotalDistanceWalked();
    final fastest = await _storage.getFastestFindTime();

    setState(() {
      _tiosFound = found;
      _distanceWalked = distance;
      _fastestTime = fastest;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = Achievements.all.where((achievement) {
      return achievement.isUnlocked(
        tiosFound: _tiosFound,
        distanceWalked: _distanceWalked,
        fastestTime: _fastestTime,
      );
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('🏅 Assoliments'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent),
            )
          : SafeArea(
              child: Column(
                children: [
                  // Resum
                  Container(
                    margin: const EdgeInsets.all(24),
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
                          '🏆',
                          style: TextStyle(fontSize: 48),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Assoliments',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$unlockedCount / ${Achievements.all.length} desbloqueats',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: unlockedCount / Achievements.all.length,
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.greenAccent,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),

                  // Llista d'assoliments
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: Achievements.all.length,
                      itemBuilder: (context, index) {
                        final achievement = Achievements.all[index];
                        final isUnlocked = achievement.isUnlocked(
                          tiosFound: _tiosFound,
                          distanceWalked: _distanceWalked,
                          fastestTime: _fastestTime,
                        );
                        final progress = achievement.getProgress(
                          tiosFound: _tiosFound,
                          distanceWalked: _distanceWalked,
                          fastestTime: _fastestTime,
                        );

                        return _buildAchievementCard(
                          achievement: achievement,
                          isUnlocked: isUnlocked,
                          progress: progress,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAchievementCard({
    required Achievement achievement,
    required bool isUnlocked,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.greenAccent.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? Colors.greenAccent.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Emoji/icona
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? Colors.greenAccent.withValues(alpha: 0.2)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                isUnlocked ? achievement.emoji : '🔒',
                style: TextStyle(
                  fontSize: 32,
                  color: isUnlocked ? null : Colors.white.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Informació
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.name,
                  style: TextStyle(
                    color: isUnlocked ? Colors.greenAccent : Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                if (!isUnlocked) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${(progress * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      LinearProgressIndicator(
                        value: progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.greenAccent.withValues(alpha: 0.6),
                        ),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Estat
          if (isUnlocked)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: Colors.black,
                size: 20,
              ),
            ),
        ],
      ),
    );
  }
}
