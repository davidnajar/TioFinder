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
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/hide': (context) => const HideTioScreen(),
          '/radar': (context) => const RadarScreen(),
        },
      ),
    );
  }
}
