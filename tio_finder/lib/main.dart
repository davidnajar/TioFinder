import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/screens.dart';
import 'services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TioFinderApp());
}

class TioFinderApp extends StatelessWidget {
  const TioFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HideTioProvider()),
        ChangeNotifierProvider(create: (_) => RadarProvider()),
      ],
      child: MaterialApp(
        title: 'Tió Finder',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const AppInitializer(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/hide': (context) => const HideTioScreen(),
          '/radar': (context) => const RadarScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/statistics': (context) => const StatisticsScreen(),
        },
      ),
    );
  }
}

/// Widget que comprova si s'ha de mostrar l'onboarding
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final storage = StorageService();
    await storage.init();
    final completed = await storage.isOnboardingCompleted();
    
    setState(() {
      _showOnboarding = !completed;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A2E),
        body: Center(
          child: CircularProgressIndicator(color: Colors.greenAccent),
        ),
      );
    }

    if (_showOnboarding) {
      return const OnboardingScreen();
    }

    return const HomeScreen();
  }
}
