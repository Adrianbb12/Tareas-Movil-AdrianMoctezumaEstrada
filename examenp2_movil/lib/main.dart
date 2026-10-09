import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

const supabaseUrl = 'https://eapgoxuerdtfcakbwxwv.supabase.co';
const supabasePublishableKey = 'sb_publishable_FmsJfxoZINqeSfIcnk7APg_DT_KnwuB';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty) {
    await Supabase.initialize(url: supabaseUrl, publishableKey: supabasePublishableKey);
  }
  runApp(const MisLugaresApp());
}

class MisLugaresApp extends StatelessWidget {
  const MisLugaresApp({super.key});

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF302A25);
    const terracotta = Color(0xFFA44A36);
    const olive = Color(0xFF68745A);
    const paper = Color(0xFFF7F3EA);
    const surface = Color(0xFFFFFEFA);
    const paleTerracotta = Color(0xFFF1E2D9);
    const paleOlive = Color(0xFFE9EBDD);
    const outline = Color(0xFFE5DDD0);
    final colors = ColorScheme.fromSeed(
      seedColor: terracotta,
      brightness: Brightness.light,
    ).copyWith(
      primary: terracotta,
      onPrimary: surface,
      secondary: olive,
      surface: surface,
      onSurface: ink,
      primaryContainer: paleTerracotta,
      onPrimaryContainer: ink,
      secondaryContainer: paleOlive,
      onSecondaryContainer: ink,
    );
    final baseTextTheme = GoogleFonts.dmSansTextTheme(ThemeData.light().textTheme);
    return MaterialApp(
      title: 'Mis Lugares Favoritos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colors,
        scaffoldBackgroundColor: paper,
        appBarTheme: AppBarTheme(
          backgroundColor: paper,
          foregroundColor: ink,
          titleTextStyle: GoogleFonts.lora(
            color: ink,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        textTheme: baseTextTheme.copyWith(
          headlineLarge: GoogleFonts.lora(textStyle: baseTextTheme.headlineLarge?.copyWith(color: ink, fontWeight: FontWeight.w700)),
          headlineMedium: GoogleFonts.lora(textStyle: baseTextTheme.headlineMedium?.copyWith(color: ink, fontWeight: FontWeight.w700)),
          headlineSmall: GoogleFonts.lora(textStyle: baseTextTheme.headlineSmall?.copyWith(color: ink, fontWeight: FontWeight.w700)),
          titleLarge: GoogleFonts.lora(textStyle: baseTextTheme.titleLarge?.copyWith(color: ink, fontWeight: FontWeight.w700)),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: terracotta,
            foregroundColor: surface,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: terracotta,
            side: const BorderSide(color: terracotta),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: terracotta,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: olive,
          foregroundColor: surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        navigationBarTheme: const NavigationBarThemeData(
          backgroundColor: surface,
          indicatorColor: paleTerracotta,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: ink,
          contentTextStyle: TextStyle(color: surface),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surface,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: outline)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: terracotta, width: 1.5)),
        ),
      ),
      home: supabaseUrl.isEmpty || supabasePublishableKey.isEmpty
          ? const SetupScreen()
          : const AuthGate(),
    );
  }
}

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Padding(padding: const EdgeInsets.all(28), child: Column(
        mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.place_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 18),
          Text('Conecta tu proyecto Supabase', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('Sigue los pasos de README.md: ejecuta supabase/schema.sql y configura la URL y la publishable key con dart-define. No pegues aquí una service_role key.'),
          const SizedBox(height: 18),
          const SelectableText('flutter run --dart-define=SUPABASE_URL=TU_URL --dart-define=SUPABASE_PUBLISHABLE_KEY=TU_PUBLISHABLE_KEY'),
        ],
      )),
    )),
  );
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) => StreamBuilder<AuthState>(
    stream: Supabase.instance.client.auth.onAuthStateChange,
    builder: (context, snapshot) => Supabase.instance.client.auth.currentSession == null
        ? const AuthScreen() : const HomeScreen(),
  );
}
