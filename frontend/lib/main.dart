import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/services/session_service.dart';
import 'routes/app_routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ukmfbinwpqfribeladhk.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrbWZiaW53cHFmcmliZWxhZGhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg2MDM1MTcsImV4cCI6MjA5NDE3OTUxN30.a12G0hWGAvmZ2bHdtbI3wEvLmShnN6EkfYByHxD879g',
  );

  // Restaurar sesión si existe
  final haySesion = await SessionService.restaurar();

  runApp(MyApp(haySesion: haySesion));
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  final bool haySesion;
  const MyApp({super.key, required this.haySesion});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: haySesion ? AppRoutes.home : AppRoutes.login,
      routes: AppRoutes.routes,
    );
  }
}