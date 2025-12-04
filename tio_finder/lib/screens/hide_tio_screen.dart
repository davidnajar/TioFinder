import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../models/models.dart';

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
    return GestureDetector(
      onTap: provider.isLoading
          ? null
          : () async {
              provider.clearMessages();
              await provider.saveCurrentLocationAsTio();
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 32),
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
              size: 48,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            const Text(
              'AMAGAR TIÓ AQUÍ',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prem per guardar la ubicació actual',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
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
