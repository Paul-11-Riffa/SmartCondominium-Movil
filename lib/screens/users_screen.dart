import 'package:flutter/material.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/services/admin_user_service.dart';
import 'package:movil/models/usuario.dart';
import 'package:movil/screens/admin_user_form_screen.dart';
import 'package:movil/widgets/user_edit_modal.dart';
import 'package:movil/widgets/user_create_modal.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({Key? key}) : super(key: key);

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Usuario> _users = [];
  bool _isLoading = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.get('usuarios');
    
    if (response != null && response['results'] != null) {
      setState(() {
        _users = (response['results'] as List)
            .map((json) => Usuario.fromJson(json))
            .toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Usuario> _getFilteredUsers() {
    if (_searchTerm.isEmpty) return _users;
    
    return _users.where((user) {
      final lowerSearchTerm = _searchTerm.toLowerCase();
      return user.nombre.toLowerCase().contains(lowerSearchTerm) ||
          user.apellido.toLowerCase().contains(lowerSearchTerm) ||
          user.correo.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  // Mostrar modal para añadir usuario
  Future<void> _showCreateUserModal() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserCreateModal(
          onUserCreated: () {
            _loadUsers(); // Recargar la lista cuando se cree
          },
        );
      },
    );
  }

  // Mostrar modal para editar usuario
  Future<void> _showEditUserModal(Usuario user) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return UserEditModal(
          usuario: user,
          onUserUpdated: () {
            _loadUsers(); // Recargar la lista cuando se actualice
          },
        );
      },
    );
  }

  // Confirmar y eliminar usuario
  Future<void> _confirmDeleteUser(Usuario user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar al usuario "${user.nombre} ${user.apellido}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      _deleteUser(user);
    }
  }

  // Eliminar usuario
  Future<void> _deleteUser(Usuario user) async {
    final success = await AdminUserService.deleteUser(user.codigo!);
    
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Usuario eliminado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      _loadUsers(); // Recargar la lista
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al eliminar usuario'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserModal,
        backgroundColor: Colors.purple.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Añadir Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de búsqueda
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Buscar usuarios...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchTerm = value;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Título y contador
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lista de Usuarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade700,
                  ),
                ),
                Text(
                  '${filteredUsers.length} usuarios',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredUsers.isEmpty)
              const Center(
                child: Text('No se encontraron usuarios'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.purple.shade100,
                          child: Icon(
                            Icons.person,
                            color: Colors.purple.shade700,
                          ),
                        ),
                        title: Text(
                          '${user.nombre} ${user.apellido}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.correo),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: user.estado == 'activo' ? Colors.green : Colors.red,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    user.estado ?? 'activo',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Botón de editar
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.blue.shade600,
                                size: 20,
                              ),
                              onPressed: () => _showEditUserModal(user),
                              tooltip: 'Editar usuario',
                            ),
                            // Botón de eliminar
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.red.shade600,
                                size: 20,
                              ),
                              onPressed: () => _confirmDeleteUser(user),
                              tooltip: 'Eliminar usuario',
                            ),
                          ],
                        ),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}