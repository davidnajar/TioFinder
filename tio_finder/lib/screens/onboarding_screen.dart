import 'package:flutter/material.dart';
import '../services/storage_service.dart';

/// Pantalla d'onboarding que s'ensenya la primera vegada que s'obre l'app
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final storage = StorageService();
    await storage.init();
    await storage.setOnboardingCompleted();
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Indicadors de pàgina
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index
                          ? Colors.greenAccent
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
            
            // Contingut de les pàgines
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildWelcomePage(),
                  _buildSecretMenuPage(),
                  _buildTionsExplanationPage(),
                  _buildFakeTionsPage(),
                ],
              ),
            ),
            
            // Botons de navegació
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botó Enrere
                  if (_currentPage > 0)
                    TextButton(
                      onPressed: _previousPage,
                      child: Text(
                        'ENRERE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 80),
                  
                  // Botó Següent/Començar
                  ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage < _totalPages - 1 ? 'SEGÜENT' : 'COMENÇAR',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return _buildPage(
      icon: Icons.radar,
      iconColor: Colors.greenAccent,
      title: 'Benvingut a Tió Finder!',
      description:
          'L\'aplicació per buscar tions amagats utilitzant un radar estil Dragon Ball.\n\n'
          'Amaga els teus tions i troba\'ls amb el radar!',
      emoji: '🪵',
    );
  }

  Widget _buildSecretMenuPage() {
    return _buildPage(
      icon: Icons.lock_open,
      iconColor: Colors.orange,
      title: 'Menú Secret',
      description:
          'Per accedir al menú d\'amagar tions:\n\n'
          '👆 Toca 10 vegades sobre el títol "TIÓ FINDER" a la pantalla principal\n\n'
          'Aquest menú secret et permet amagar tions a la teva ubicació actual o en qualsevol punt del mapa.',
      emoji: '🤫',
    );
  }

  Widget _buildTionsExplanationPage() {
    return _buildPage(
      icon: Icons.forest,
      iconColor: Colors.green,
      title: 'Com es guarden els tions?',
      description:
          'Els tions que amaguis es guarden automàticament al teu dispositiu.\n\n'
          '💾 Les coordenades GPS es desen localment\n\n'
          '📍 Pots veure tots els teus tions guardats al menú secret\n\n'
          '🎯 Utilitza el radar per trobar-los més tard',
      emoji: '💚',
    );
  }

  Widget _buildFakeTionsPage() {
    return _buildPage(
      icon: Icons.psychology,
      iconColor: Colors.purple,
      title: 'Fake Tions i Zones',
      description:
          '🟡 Fake Tions: Pistes falses que apareixen al radar per fer més interessant la cerca.\n\n'
          '📍 Zones de fake tions: Pots definir àrees específiques on es generaran fake tions automàticament.\n\n'
          '⚙️ Configura-ho tot des del menú secret!',
      emoji: '🎭',
    );
  }

  Widget _buildPage({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required String emoji,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Emoji gran
          Text(
            emoji,
            style: const TextStyle(fontSize: 80),
          ),
          const SizedBox(height: 32),
          
          // Icona
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: iconColor.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // Títol
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          
          // Descripció
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
