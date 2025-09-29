import 'package:flutter/material.dart';
import 'package:movil/services/admin_user_service.dart';
import 'package:movil/models/usuario.dart';

class AdminUserFormScreen extends StatefulWidget {
  final Usuario? usuario; // null para crear, objeto para editar
  
  const AdminUserFormScreen({Key? key, this.usuario}) : super(key: key);

  @override
  _AdminUserFormScreenState createState() => _AdminUserFormScreenState();
}

class _AdminUserFormScreenState extends State<AdminUserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();
  
  List<Map<String, dynamic>> _roles = [];
  int? _selectedRoleId;
  String _selectedEstado = 'activo';
  bool _isLoading = false;
  bool _isLoadingRoles = true;

  bool get _isEditing => widget.usuario != null;

  @override
  void initState() {
    super.initState();
    _loadRoles();
    if (_isEditing) {
      print('DEBUG: Iniciando edición. Usuario: ${widget.usuario}');
      print('DEBUG: Nombre: ${widget.usuario?.nombre}, Apellido: ${widget.usuario?.apellido}, Correo: ${widget.usuario?.correo}');
      _populateFields();
    }
  }

  void _populateFields() {
    final user = widget.usuario!;
    
    // Asegurar que nunca haya valores null en campos String
    _nombreController.text = user.nombre.isEmpty ? '' : user.nombre;
    _apellidoController.text = user.apellido.isEmpty ? '' : user.apellido;
    _correoController.text = user.correo.isEmpty ? '' : user.correo;
    
    _selectedRoleId = user.tipoRol;
    _selectedEstado = user.estado ?? 'activo';
    
    print('DEBUG: Campos poblados - Nombre: ${_nombreController.text}, Apellido: ${_apellidoController.text}, Correo: ${_correoController.text}');
  }

  Future<void> _loadRoles() async {
    final roles = await AdminUserService.getRoles();
    setState(() {
      _roles = roles;
      _isLoadingRoles = false;
      // Si estamos editando y no tenemos rol seleccionado, usar el del usuario
      if (_isEditing && _selectedRoleId == null && widget.usuario!.tipoRol != null) {
        _selectedRoleId = widget.usuario!.tipoRol;
      }
      // Si no estamos editando, seleccionar el primer rol por defecto
      if (!_isEditing && roles.isNotEmpty) {
        _selectedRoleId = roles.first['id'];
      }
    });
  }

  Future<void> _saveUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor selecciona un rol'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Map<String, dynamic>? result;

    if (_isEditing) {
      // Actualizar usuario existente
      result = await AdminUserService.updateUser(
        userId: widget.usuario!.codigo!,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        tipoRol: _selectedRoleId!,
        estado: _selectedEstado,
        password: _passwordController.text.isNotEmpty 
            ? _passwordController.text 
            : null,
      );
    } else {
      // Crear nuevo usuario
      if (_passwordController.text.isEmpty) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('La contraseña es requerida para nuevos usuarios'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      result = await AdminUserService.createUser(
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        password: _passwordController.text,
        tipoRol: _selectedRoleId!,
        estado: _selectedEstado,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing 
              ? 'Usuario actualizado exitosamente' 
              : 'Usuario creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true); // Retornar true para indicar éxito
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing 
              ? 'Error al actualizar usuario' 
              : 'Error al crear usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Usuario' : 'Añadir Usuario'),
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveUser,
            ),
        ],
      ),
      body: _isLoadingRoles
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Encabezado
                    Card(
                      color: Colors.purple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(
                              _isEditing ? Icons.edit : Icons.person_add,
                              color: Colors.purple.shade700,
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isEditing ? 'Editar Usuario' : 'Nuevo Usuario',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                  Text(
                                    _isEditing 
                                        ? 'Modifica la información del usuario'
                                        : 'Completa la información del nuevo usuario',
                                    style: TextStyle(
                                      color: Colors.purple.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Información Personal
                    Text(
                      'Información Personal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre *',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Apellido
                    TextFormField(
                      controller: _apellidoController,
                      decoration: InputDecoration(
                        labelText: 'Apellido *',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El apellido es requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Correo
                    TextFormField(
                      controller: _correoController,
                      decoration: InputDecoration(
                        labelText: 'Correo Electrónico *',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El correo es requerido';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Ingresa un correo válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Configuración de Cuenta
                    Text(
                      'Configuración de Cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contraseña
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: _isEditing 
                            ? 'Nueva Contraseña (opcional)' 
                            : 'Contraseña *',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        helperText: _isEditing 
                            ? 'Déjalo vacío para mantener la contraseña actual'
                            : null,
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (!_isEditing && (value == null || value.isEmpty)) {
                          return 'La contraseña es requerida para nuevos usuarios';
                        }
                        if (value != null && value.isNotEmpty && value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Rol
                    DropdownButtonFormField<int>(
                      value: _selectedRoleId,
                      decoration: InputDecoration(
                        labelText: 'Rol *',
                        prefixIcon: const Icon(Icons.admin_panel_settings),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _roles.map((role) {
                        return DropdownMenuItem<int>(
                          value: role['id'],
                          child: Text(role['nombre']),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRoleId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecciona un rol';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Estado
                    DropdownButtonFormField<String>(
                      value: _selectedEstado,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: const Icon(Icons.toggle_on),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'activo',
                          child: Text('Activo'),
                        ),
                        DropdownMenuItem(
                          value: 'inactivo',
                          child: Text('Inactivo'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedEstado = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    // Botón de guardar
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              _isEditing ? 'Actualizar Usuario' : 'Crear Usuario',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}