import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // kIsWeb

import 'package:shared_preferences/shared_preferences.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/entries_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/ledger_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    debugPrint('Initializing Firebase...');
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully.');
  } catch (e, stack) {
    debugPrint('Firebase initialize error: $e\n$stack');
  }

  try {
    debugPrint('Loading SharedPreferences...');
    final prefs = await SharedPreferences.getInstance();
    final useDarkMode = prefs.getBool('useDarkMode') ?? false;
    final language = prefs.getString('language') ?? 'ja';
    debugPrint(
        'SharedPreferences loaded: useDarkMode=$useDarkMode, language=$language');

    debugPrint('Loading LedgerProvider entries...');
    final ledgerProvider = LedgerProvider();
    await ledgerProvider.loadEntries();
    debugPrint('LedgerProvider entries loaded.');

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ledgerProvider),
        ],
        child: MyApp(
          useDarkMode: useDarkMode,
          language: language,
        ),
      ),
    );
  } catch (e, stack) {
    debugPrint('App init error: $e\n$stack');
  }
}

class MyApp extends StatelessWidget {
  final bool useDarkMode;
  final String language;

  const MyApp({
    super.key,
    required this.useDarkMode,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint(
        'Building MyApp with useDarkMode=$useDarkMode, language=$language');
    return MaterialApp(
      title: 'PaperToTrust',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: useDarkMode ? Brightness.dark : Brightness.light,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', ''),
        Locale('en', ''),
      ],
      locale: Locale(language),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const EntriesScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list),
            label: '記録',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
      ),
    );
  }
}
