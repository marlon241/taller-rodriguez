import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Login',
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: Container(
          width: 450,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// ESPACIO PARA EL LOGO
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                image: DecorationImage(
      image: AssetImage('assets/logo_taller.png'), 
      fit: BoxFit.cover,
    ),
  ),
), // Container
                

              const SizedBox(height: 30),

              const Text(
                "Inicio de sesión",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 40),

              /// Usuario
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nombre de usuario",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                decoration: InputDecoration(
                  hintText: "Ingresa tu usuario",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),

              const SizedBox(height: 25),

              /// Contraseña
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Contraseña",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Ingresa tu contraseña",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),

              const SizedBox(height: 35),

              /// Botón
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Iniciar sesión",
                    style: TextStyle(fontSize: 16,
                    color : Colors.white,)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}