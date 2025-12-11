/// Model per a fites/assoliments del joc
class Achievement {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int requiredCount;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.requiredCount,
    required this.type,
  });

  /// Comprova si l'assoliment s'ha desbloquejat segons els valors actuals
  bool isUnlocked({
    int? tiosFound,
    double? distanceWalked,
    int? fastestTime,
  }) {
    switch (type) {
      case AchievementType.tiosFound:
        return (tiosFound ?? 0) >= requiredCount;
      case AchievementType.distanceWalked:
        return (distanceWalked ?? 0) >= requiredCount;
      case AchievementType.fastestTime:
        if (fastestTime == null) return false;
        return fastestTime <= requiredCount;
    }
  }

  /// Obté el progrés actual (0.0 a 1.0)
  double getProgress({
    int? tiosFound,
    double? distanceWalked,
    int? fastestTime,
  }) {
    switch (type) {
      case AchievementType.tiosFound:
        return ((tiosFound ?? 0) / requiredCount).clamp(0.0, 1.0);
      case AchievementType.distanceWalked:
        return ((distanceWalked ?? 0) / requiredCount).clamp(0.0, 1.0);
      case AchievementType.fastestTime:
        if (fastestTime == null) return 0.0;
        // Per al temps, mostrar progrés basat en temps actual vs requerit
        // Si ja s'ha assolit, retornar 1.0
        if (fastestTime <= requiredCount) return 1.0;
        // Si no, mostrar un progrés parcial basat en el temps màxim raonable (3x el requerit)
        final maxTime = requiredCount * 3;
        return (1.0 - ((fastestTime - requiredCount) / (maxTime - requiredCount))).clamp(0.0, 1.0);
    }
  }
}

enum AchievementType {
  tiosFound,
  distanceWalked,
  fastestTime,
}

/// Llista d'assoliments disponibles
class Achievements {
  static const List<Achievement> all = [
    // Assoliments de tions trobats
    Achievement(
      id: 'first_tio',
      name: 'Primer Tió',
      description: 'Troba el teu primer tió',
      emoji: '🌱',
      requiredCount: 1,
      type: AchievementType.tiosFound,
    ),
    Achievement(
      id: 'tio_explorer',
      name: 'Explorador de Tions',
      description: 'Troba 5 tions',
      emoji: '🧭',
      requiredCount: 5,
      type: AchievementType.tiosFound,
    ),
    Achievement(
      id: 'tio_hunter',
      name: 'Caçador de Tions',
      description: 'Troba 10 tions',
      emoji: '🎯',
      requiredCount: 10,
      type: AchievementType.tiosFound,
    ),
    Achievement(
      id: 'tio_master',
      name: 'Mestre dels Tions',
      description: 'Troba 25 tions',
      emoji: '🏆',
      requiredCount: 25,
      type: AchievementType.tiosFound,
    ),
    Achievement(
      id: 'tio_legend',
      name: 'Llegenda dels Tions',
      description: 'Troba 50 tions',
      emoji: '👑',
      requiredCount: 50,
      type: AchievementType.tiosFound,
    ),

    // Assoliments de distància
    Achievement(
      id: 'first_steps',
      name: 'Primers Passos',
      description: 'Camina 1 km',
      emoji: '👣',
      requiredCount: 1000,
      type: AchievementType.distanceWalked,
    ),
    Achievement(
      id: 'walker',
      name: 'Caminant',
      description: 'Camina 5 km',
      emoji: '🚶',
      requiredCount: 5000,
      type: AchievementType.distanceWalked,
    ),
    Achievement(
      id: 'hiker',
      name: 'Excursionista',
      description: 'Camina 10 km',
      emoji: '🥾',
      requiredCount: 10000,
      type: AchievementType.distanceWalked,
    ),
    Achievement(
      id: 'marathon',
      name: 'Maratonià',
      description: 'Camina 42 km',
      emoji: '🏃',
      requiredCount: 42000,
      type: AchievementType.distanceWalked,
    ),

    // Assoliments de velocitat
    Achievement(
      id: 'speed_seeker',
      name: 'Buscador Ràpid',
      description: 'Troba un tió en menys de 5 minuts',
      emoji: '⚡',
      requiredCount: 300, // 5 minuts en segons
      type: AchievementType.fastestTime,
    ),
    Achievement(
      id: 'speed_master',
      name: 'Mestre de Velocitat',
      description: 'Troba un tió en menys de 2 minuts',
      emoji: '💨',
      requiredCount: 120, // 2 minuts en segons
      type: AchievementType.fastestTime,
    ),
    Achievement(
      id: 'lightning_fast',
      name: 'Llampec',
      description: 'Troba un tió en menys de 1 minut',
      emoji: '⚡️',
      requiredCount: 60, // 1 minut en segons
      type: AchievementType.fastestTime,
    ),
  ];
}
