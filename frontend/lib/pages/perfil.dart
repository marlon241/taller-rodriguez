import 'package:flutter/material.dart';
import 'package:frontend/services/session_service.dart';
import 'package:frontend/widgets/navigation/sidebar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> with SingleTickerProviderStateMixin {
  late Map<String, dynamic> _userData;

  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  late TextEditingController _nombreController;
  late TextEditingController _telefonoController;

  bool _isEditing = false;
  bool _isUploadingImage = false;

  // Para web usamos bytes en lugar de File
  XFile? _pickedFile;

  late AnimationController _editBtnController;
  late Animation<double> _editBtnScale;

  // Colores rojo del tema
  static const Color kRed = Color(0xFFE53935);
  static const Color kRedDark = Color(0xFFB71C1C);
  static const Color kRedLight = Color(0xFFEF5350);

  @override
  void initState() {
    super.initState();
    _userData = SessionService.currentUser ?? {};
    _nombreController = TextEditingController(text: _userData['nombre'] ?? '');
    _telefonoController = TextEditingController(text: _userData['telefono'] ?? '');

    _editBtnController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _editBtnScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _editBtnController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _editBtnController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  // ==================== SUBIR IMAGEN (compatible Web) ====================
  Future<void> _pickAndUploadImage() async {
  final picker = ImagePicker();
  final picked = await picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: 40,      // ⬇️ antes era 80
    maxWidth: 300,         // ⬇️ máximo 300px de ancho
    maxHeight: 300,        // ⬇️ máximo 300px de alto
  );
  if (picked == null) return;

  setState(() => _isUploadingImage = true);

  try {
    final bytes = await picked.readAsBytes();
    final userId = _userData['id'].toString();
    final path = 'avatars/$userId.jpg';

    await Supabase.instance.client.storage
        .from('avatars')
        .uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );

    final publicUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(path);

    await Supabase.instance.client
        .from('empleados')
        .update({'foto_url': publicUrl})
        .eq('id', _userData['id']);

    _userData['foto_url'] = publicUrl;
    SessionService.iniciar(_userData);

    setState(() {
      _pickedFile = picked;
      _isUploadingImage = false;
    });

    _showMessage('✅ Foto actualizada', Colors.green);
  } catch (e) {
    setState(() => _isUploadingImage = false);
    _showMessage('Error al subir imagen: $e', Colors.red);
    await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
      Navigator.pushReplacementNamed(context, '/perfil');
}
  }
}

  // ==================== CAMBIAR CONTRASEÑA ====================
  Future<void> _cambiarContrasena() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      _showMessage('Completa todos los campos', Colors.red);
      return;
    }
    if (newPass != confirm) {
      _showMessage('Las nuevas contraseñas no coinciden', Colors.red);
      return;
    }
    if (newPass.length < 6) {
      _showMessage('Mínimo 6 caracteres', Colors.red);
      return;
    }

    try {
      await Supabase.instance.client
          .from('empleados')
          .update({'contrasena': newPass})
          .eq('id', _userData['id']);

      _showMessage('✅ Contraseña cambiada', Colors.green);
      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    } catch (e) {
      _showMessage('Error al cambiar contraseña', Colors.red);
    }
  }

  // ==================== ACTUALIZAR DATOS ====================
  Future<void> _actualizarDatos() async {
    try {
      await Supabase.instance.client
          .from('empleados')
          .update({
            'nombre': _nombreController.text.trim(),
            'telefono': _telefonoController.text.trim(),
          })
          .eq('id', _userData['id']);

      _userData['nombre'] = _nombreController.text.trim();
      _userData['telefono'] = _telefonoController.text.trim();
      SessionService.iniciar(_userData);

      _showMessage('✅ Datos actualizados', Colors.green);
      setState(() => _isEditing = false);
    } catch (e) {
      _showMessage('Error al actualizar', Colors.red);
    }
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // ==================== CAMPO DE TEXTO ====================
  Widget _buildField(String label, TextEditingController controller, {bool editable = false}) {
    final canEdit = editable && _isEditing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: canEdit ? kRed : const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: !canEdit,
          style: TextStyle(
            fontSize: 15,
            color: canEdit ? Colors.black87 : Colors.black54,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: canEdit ? Colors.white : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: canEdit ? kRed : Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: canEdit ? kRedLight : Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: kRed, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ==================== BOTÓN EDITAR LLAMATIVO ====================
  Widget _buildEditButton() {
    return GestureDetector(
      onTapDown: (_) => _editBtnController.forward(),
      onTapUp: (_) {
        _editBtnController.reverse();
        if (_isEditing) {
          _actualizarDatos();
        } else {
          setState(() => _isEditing = true);
        }
      },
      onTapCancel: () => _editBtnController.reverse(),
      child: ScaleTransition(
        scale: _editBtnScale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            gradient: _isEditing
                ? const LinearGradient(
                    colors: [Color(0xFF43A047), Color(0xFF2E7D32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [kRed, kRedDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (_isEditing ? const Color(0xFF43A047) : kRed).withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isEditing ? Icons.check_circle_outline : Icons.edit_outlined,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _isEditing ? 'Guardar Cambios' : 'Editar Perfil',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== AVATAR EDITABLE ====================
  Widget _buildAvatar() {
    return FutureBuilder<Widget>(
      future: _buildAvatarImage(),
      builder: (context, snapshot) {
        return GestureDetector(
          onTap: _pickAndUploadImage,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: kRed.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: snapshot.data ??
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey[200],
                      child: const Icon(Icons.person, size: 70, color: Colors.white),
                    ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [kRed, kRedDark],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: _isUploadingImage
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Widget> _buildAvatarImage() async {
    if (_pickedFile != null) {
      final bytes = await _pickedFile!.readAsBytes();
      return CircleAvatar(
        radius: 65,
        backgroundImage: MemoryImage(bytes),
      );
    }

    final fotoUrl = _userData['foto_url'];
    if (fotoUrl != null && (fotoUrl as String).isNotEmpty) {
      return CircleAvatar(
        radius: 65,
        backgroundImage: NetworkImage(fotoUrl),
      );
    }

    return CircleAvatar(
      radius: 65,
      backgroundColor: Colors.grey[200],
      child: const Icon(Icons.person, size: 70, color: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWide = MediaQuery.of(context).size.width > 1000;

    return Scaffold(
      drawer: isWide ? null : const SidebarDrawerContent(),
      appBar: isWide ? null : AppBar(title: const Text('Perfil')),
      body: Row(
        children: [
          const Sidebar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isWide)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'Perfil',
                        style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold, fontFamily: 'Itim'),
                      ),
                    ),
                  const SizedBox(height: 30),

                  Center(child: _buildAvatar()),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Toca la foto para cambiarla',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        // Botón editar
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildEditButton(),
                        ),
                        const SizedBox(height: 24),

                        // Fila 1: Nombre (editable) | DUI (solo lectura)
                        Row(children: [
                          Expanded(child: _buildField('Nombre', _nombreController, editable: true)),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildField(
                              'DUI',
                              TextEditingController(text: _userData['dui'] ?? ''),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Fila 2: Teléfono (editable) | Fecha Contratación (solo lectura)
                        Row(children: [
                          Expanded(child: _buildField('Teléfono', _telefonoController, editable: true)),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildField(
                              'Fecha Contratación',
                              TextEditingController(text: _userData['fecha_contratacion'] ?? ''),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Fila 3: Sueldo | Porcentaje (solo lectura)
                        Row(children: [
                          Expanded(
                            child: _buildField(
                              'Sueldo Base',
                              TextEditingController(text: '\$${_userData['sueldo_base'] ?? 0}'),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _buildField(
                              'Porcentaje',
                              TextEditingController(text: '${_userData['porcentaje_ganancia'] ?? 0}%'),
                            ),
                          ),
                        ]),

                        const SizedBox(height: 40),
                        const Divider(),
                        const SizedBox(height: 20),

                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Cambiar Contraseña',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Contraseñas siempre editables
                        _buildField('Contraseña Actual', _oldPasswordController, editable: true),
                        const SizedBox(height: 14),
                        _buildField('Nueva Contraseña', _newPasswordController, editable: true),
                        const SizedBox(height: 14),
                        _buildField('Confirmar Nueva Contraseña', _confirmPasswordController, editable: true),

                        const SizedBox(height: 24),

                        // Botón cambiar contraseña
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [kRed, kRedDark],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: kRed.withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _cambiarContrasena,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Cambiar Contraseña',
                                style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Cerrar sesión
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () {
                              SessionService.cerrar();
                              Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                            },
                            icon: const Icon(Icons.logout, color: kRedDark, size: 18),
                            label: const Text(
                              'Cerrar Sesión',
                              style: TextStyle(color: kRedDark, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                      
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}