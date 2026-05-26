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
      home: const RegistroAdmin(),
    );
  }
}

class RegistroAdmin extends StatelessWidget {
  const RegistroAdmin({super.key});

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
                color: Colors.black.withValues(alpha: 0.15),
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
                  shape: BoxShape.circle,
                image: DecorationImage(
      image: AssetImage('assets/logo_taller.png'), 
      fit: BoxFit.cover,
    ),
  ),
), // Container
                

              const SizedBox(height: 30),

              const Text(
                "Bienvenido, Administrador",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                "Registre sus datos por favor",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 18),

              /// Usuario
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Nombre de usuario",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                decoration: InputDecoration(
                  hintText: "Ingresa tu usuario",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),

              const SizedBox(height: 18),

              /// Contraseña
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Contraseña",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 6),

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
              
              const SizedBox(height: 18),
          
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Confirmar su contraseña",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),

              const SizedBox(height: 6),

              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Confirme su contraseña",
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
                    "Registrar Administrador",
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