import 'package:flutter/material.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/models/usuario.dart';

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
      return user.nombre!.toLowerCase().contains(lowerSearchTerm) ||
          user.apellido!.toLowerCase().contains(lowerSearchTerm) ||
          user.correo!.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = _getFilteredUsers();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
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
                const Text(
                  'Lista de Usuarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
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
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text('${user.nombre} ${user.apellido}'),
                        subtitle: Text(user.correo ?? ''),
                        trailing: user.estado != null ? 
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: user.estado == 'activo' ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              user.estado!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ) : null,
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