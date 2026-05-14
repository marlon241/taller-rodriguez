import 'package:flutter/material.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';

class ClientesPage extends StatefulWidget{
  const ClientesPage ({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Sidebar(),
    );
  }
}