import 'package:flutter/material.dart';

/// Pantalla d'ajuda i tutorial
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('❓ Ajuda'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            const Text(
              'Com jugar',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            _buildHelpSection(
              emoji: '🪵',
              title: 'Què és un Tió?',
              description:
                  'Un Tió és un tronc de nadal tradicional català. Amaga\'ls i troba\'ls amb el radar!',
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 20),

            _buildHelpSection(
              emoji: '🎯',
              title: 'Com amagar un Tió',
              description:
                  '1. A la pantalla principal, toca 10 vegades el títol "TIÓ FINDER"\n'
                  '2. S\'obrirà el menú secret\n'
                  '3. Tria "Amagar Tió Aquí" o "Amagar al Mapa"\n'
                  '4. Guarda la ubicació',
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 20),

            _buildHelpSection(
              emoji: '📡',
              title: 'Com usar el Radar',
              description:
                  '1. Obre el Radar des del menú principal\n'
                  '2. El punt blanc al centre ets tu\n'
                  '3. Els punts verds són tions reals\n'
                  '4. Els punts grocs/vermells són pistes falses\n'
                  '5. Camina cap als punts per apropar-te',
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 20),

            _buildHelpSection(
              emoji: '🔍',
              title: 'Zoom del Radar',
              description:
                  'Utilitza els botons de zoom per canviar el rang de detecció:\n'
                  '• x1: 300 metres\n'
                  '• x1.5: 200 metres\n'
                  '• x2: 150 metres\n'
                  '• x4: 75 metres\n'
                  '• x6: 50 metres (màxima precisió)',
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 20),

            _buildHelpSection(
              emoji: '📳',
              title: 'Feedback de Proximitat',
              description:
                  'Quan t\'acostes a un Tió real, el dispositiu vibrarà:\n'
                  '• Vibració suau: 25-50 metres\n'
                  '• Vibració mitjana: 10-25 metres\n'
                  '• Vibració forta: menys de 10 metres',
              color: Colors.purpleAccent,
            ),
            const SizedBox(height: 20),

            _buildHelpSection(
              emoji: '🎊',
              title: 'Trobar un Tió',
              description:
                  'Quan estiguis a menys de 5 metres d\'un Tió:\n'
                  '1. Apareixerà un botó "TIÓ TROBAT"\n'
                  '2. Prem el botó per confirmar\n'
                  '3. Celebra! El Tió s\'afegirà a les teves estadístiques',
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 20),

            _buildHelpSection(
              emoji: '🎭',
              title: 'Tipus de Pistes',
              description:
                  '• Verds 🟢: Tions reals (els que has d\'atrapar)\n'
                  '• Grocs 🟡: Pistes falses persistents\n'
                  '• Vermells 🔴: Pistes falses que desapareixen',
              color: Colors.cyanAccent,
            ),
            const SizedBox(height: 20),

            _buildHelpSection(
              emoji: '📊',
              title: 'Estadístiques',
              description:
                  'Segueix el teu progrés a la pantalla d\'estadístiques:\n'
                  '• Tions trobats totals\n'
                  '• Distància recorreguda\n'
                  '• Temps rècord de trobada\n'
                  '• Missatges motivacionals',
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 32),

            // Consells
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text(
                        '💡',
                        style: TextStyle(fontSize: 24),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Consells professionals',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTip('Utilitza zoom alt (x4-x6) quan estiguis molt a prop'),
                  const SizedBox(height: 8),
                  _buildTip('Gira\'t lentament per ubicar millor els objectius'),
                  const SizedBox(height: 8),
                  _buildTip('Les pistes vermelles desapareixen quan t\'hi acostes'),
                  const SizedBox(height: 8),
                  _buildTip('Configura zones de fake tions per més reptes'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpSection({
    required String emoji,
    required String title,
    required String description,
    required Color color,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '•',
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
