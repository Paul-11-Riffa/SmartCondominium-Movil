import 'package:flutter/material.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/models/propiedad.dart';

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({Key? key}) : super(key: key);

  @override
  _PropertiesScreenState createState() => _PropertiesScreenState();
}

class _PropertiesScreenState extends State<PropertiesScreen> {
  List<Propiedad> _properties = [];
  bool _isLoading = false;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.get('propiedades?include_residents=true');
    
    if (response != null && response['results'] != null) {
      setState(() {
        _properties = (response['results'] as List)
            .map((json) => Propiedad.fromJson(json))
            .toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<Propiedad> _getFilteredProperties() {
    if (_searchTerm.isEmpty) return _properties;
    
    return _properties.where((property) {
      final lowerSearchTerm = _searchTerm.toLowerCase();
      return (property.nroCasa ?? '').toLowerCase().contains(lowerSearchTerm) ||
          (property.descripcion ?? '').toLowerCase().contains(lowerSearchTerm) ||
          (property.propietarioActual != null 
              ? (property.propietarioActual['nombre'] ?? '').toLowerCase().contains(lowerSearchTerm)
              : false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _getFilteredProperties();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Propiedades'),
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
                    hintText: 'Buscar propiedades...',
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
                  'Lista de Propiedades',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${filteredProperties.length} propiedades',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredProperties.isEmpty)
              const Center(
                child: Text('No se encontraron propiedades'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: filteredProperties.length,
                  itemBuilder: (context, index) {
                    final property = filteredProperties[index];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.home, color: Colors.white),
                        ),
                        title: Text(
                          'Casa ${property.nroCasa ?? "N/A"}${property.piso != null ? ", Piso ${property.piso}" : ""}',
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(property.descripcion ?? 'Sin descripción'),
                            if (property.propietarioActual != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Residente: ${property.propietarioActual['nombre'] ?? "N/A"} ${property.propietarioActual['apellido'] ?? ""}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: property.estado != null ? 
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: property.estado == 'activo' ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              property.estado!,
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