import 'package:flutter/material.dart';
import 'package:movil/models/usuario.dart';
import 'package:movil/services/admin_user_service.dart';

class UserEditModal extends StatefulWidget {
  final Usuario usuario;
  final VoidCallback onUserUpdated;

  const UserEditModal({
    Key? key,
    required this.usuario,
    required this.onUserUpdated,
  }) : super(key: key);

  @override
  _UserEditModalState createState() => _UserEditModalState();
}

class _UserEditModalState extends State<UserEditModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _correoController;
  late TextEditingController _telefonoController;
  
  List<Map<String, dynamic>> _roles = [];
  int? _selectedRoleId;
  String _selectedEstado = 'activo';
  bool _isLoading = false;
  bool _isLoadingRoles = true;

  @override
  void initState() {
    super.initState();
    
    // Inicializar controladores con datos del usuario
    _nombreController = TextEditingController(text: widget.usuario.nombre);
    _apellidoController = TextEditingController(text: widget.usuario.apellido);
    _correoController = TextEditingController(text: widget.usuario.correo);
    _telefonoController = TextEditingController(text: widget.usuario.telefono ?? '');
    
    _selectedRoleId = widget.usuario.tipoRol;
    _selectedEstado = widget.usuario.estado ?? 'activo';
    
    _loadRoles();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  Future<void> _loadRoles() async {
    try {
      final roles = await AdminUserService.getRoles();
      setState(() {
        _roles = roles;
        _isLoadingRoles = false;
      });
    } catch (e) {
      print('Error cargando roles: $e');
      setState(() {
        _isLoadingRoles = false;
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoleId == null) {
      _showErrorSnackBar('Por favor selecciona un rol');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AdminUserService.updateUser(
        userId: widget.usuario.codigo!,
        nombre: _nombreController.text.trim(),
        apellido: _apellidoController.text.trim(),
        correo: _correoController.text.trim(),
        tipoRol: _selectedRoleId!,
        estado: _selectedEstado,
      );

      if (result != null) {
        _showSuccessSnackBar('Usuario actualizado exitosamente');
        widget.onUserUpdated();
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar('Error al actualizar el usuario');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Editar Usuario',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Form
            if (_isLoadingRoles)
              const Center(child: CircularProgressIndicator())
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Nombre y Apellido
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _nombreController,
                                decoration: const InputDecoration(
                                  labelText: 'Nombre',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El nombre es requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _apellidoController,
                                decoration: const InputDecoration(
                                  labelText: 'Apellido',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'El apellido es requerido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Correo y Teléfono
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _correoController,
                                decoration: const InputDecoration(
                                  labelText: 'Correo',
                                  border: OutlineInputBorder(),
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
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _telefonoController,
                                decoration: const InputDecoration(
                                  labelText: 'Teléfono',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Rol y Estado
                        Column(
                          children: [
                            // Rol
                            DropdownButtonFormField<int>(
                              value: _selectedRoleId,
                              decoration: const InputDecoration(
                                labelText: 'Rol',
                                border: OutlineInputBorder(),
                              ),
                              items: _roles.map((rol) {
                                return DropdownMenuItem<int>(
                                  value: rol['id'],
                                  child: Text(
                                    rol['descripcion'] ?? rol['tipo'] ?? rol['nombre'] ?? 'Rol ${rol['id']}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRoleId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Estado
                            DropdownButtonFormField<String>(
                              value: _selectedEstado,
                              decoration: const InputDecoration(
                                labelText: 'Estado',
                                border: OutlineInputBorder(),
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
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 24),
            
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}