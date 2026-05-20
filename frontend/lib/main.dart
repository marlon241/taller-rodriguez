import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ukmfbinwpqfribeladhk.supabase.co',
    anonKey: 'sb_publishable_gEyPG1zyWhM6lGAsTO3mfw_whu_WU5_',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.adminRegister,
      routes: AppRoutes.routes,
    );
  }
}