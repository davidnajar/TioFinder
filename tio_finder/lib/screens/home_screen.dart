import 'package:flutter/material.dart';

/// Pantalla principal amb opcions per amagar o buscar tiós
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Títol
                const Text(
                  '🪵 TIÓ FINDER',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Troba els tiós amagats!',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 80),
                
                // Botó Amagar Tió
                _buildMenuButton(
                  context,
                  icon: Icons.add_location_alt,
                  label: 'AMAGAR TIÓ',
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/hide'),
                ),
                const SizedBox(height: 24),
                
                // Botó Radar
                _buildMenuButton(
                  context,
                  icon: Icons.radar,
                  label: 'RADAR',
                  color: Colors.greenAccent,
                  onTap: () => Navigator.pushNamed(context, '/radar'),
                ),
                const SizedBox(height: 80),
                
                // Instruccions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildLegendItem(
                        color: Colors.greenAccent,
                        text: 'Tió real',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: Colors.yellowAccent,
                        text: 'Pista falsa persistent',
                      ),
                      const SizedBox(height: 8),
                      _buildLegendItem(
                        color: Colors.redAccent,
                        text: 'Pista falsa que desapareix',
                      ),
                    ],
                  ),
                ),
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
