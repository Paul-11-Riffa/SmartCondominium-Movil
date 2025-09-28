import 'package:flutter/material.dart';
import 'package:movil/models/propiedad.dart';
import 'package:movil/services/admin_propiedad_service.dart';

class AdminUnidadesScreen extends StatefulWidget {
  @override
  _AdminUnidadesScreenState createState() => _AdminUnidadesScreenState();
}

class _AdminUnidadesScreenState extends State<AdminUnidadesScreen> {
  late Future<List<Propiedad>> _propiedadesFuture;
  final _searchController = TextEditingController();
  List<Propiedad> _allPropiedades = [];
  List<Propiedad> _filteredPropiedades = [];

  @override
  void initState() {
    super.initState();
    _loadPropiedades();
  }

  void _loadPropiedades() {
    setState(() {
      _propiedadesFuture = AdminPropiedadService.getAllPropiedades();
    });
  }

  void _filterPropiedades(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPropiedades = _allPropiedades;
      } else {
        _filteredPropiedades = _allPropiedades.where((propiedad) {
          final searchLower = query.toLowerCase();
          return (propiedad.nroCasa?.toString().toLowerCase().contains(searchLower) ?? false) ||
                 (propiedad.descripcion?.toLowerCase().contains(searchLower) ?? false) ||
                 propiedad.piso.toString().contains(searchLower);
        }).toList();
      }
    });
  }

  void _showAddUnidadDialog() {
    final _nroCasaController = TextEditingController();
    final _pisoController = TextEditingController();
    final _descripcionController = TextEditingController();
    final _tamanoController = TextEditingController();
    String _selectedEstado = 'activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add_home, color: Colors.green.shade600),
            ),
            SizedBox(width: 12),
            Text('Agregar Unidad'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nroCasaController,
                decoration: InputDecoration(
                  labelText: 'Número de Casa/Departamento',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _pisoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Piso',
                  prefixIcon: Icon(Icons.layers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _tamanoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tamaño (m²)',
                  prefixIcon: Icon(Icons.square_foot),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEstado,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.toggle_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _selectedEstado = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nroCasaController.text.isNotEmpty) {
                try {
                  final nuevaPropiedad = {
                    'nro_casa': int.tryParse(_nroCasaController.text) ?? 0,
                    'piso': int.tryParse(_pisoController.text) ?? 1,
                    'descripcion': _descripcionController.text,
                    'tamano_m2': double.tryParse(_tamanoController.text),
                    'estado': _selectedEstado,
                  };

                  await AdminPropiedadService.createPropiedad(nuevaPropiedad);
                  Navigator.pop(context);
                  _loadPropiedades();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unidad creada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear unidad: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditUnidadDialog(Propiedad propiedad) {
    final _nroCasaController = TextEditingController(text: propiedad.nroCasa?.toString() ?? '');
    final _pisoController = TextEditingController(text: propiedad.piso?.toString() ?? '');
    final _descripcionController = TextEditingController(text: propiedad.descripcion);
    final _tamanoController = TextEditingController(text: propiedad.tamanoM2?.toString() ?? '');
    String _selectedEstado = propiedad.estado ?? 'activo';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit, color: Colors.blue.shade600),
            ),
            SizedBox(width: 12),
            Text('Editar Unidad'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nroCasaController,
                decoration: InputDecoration(
                  labelText: 'Número de Casa/Departamento',
                  prefixIcon: Icon(Icons.home),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _pisoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Piso',
                  prefixIcon: Icon(Icons.layers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descripcionController,
                decoration: InputDecoration(
                  labelText: 'Descripción',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _tamanoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Tamaño (m²)',
                  prefixIcon: Icon(Icons.square_foot),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedEstado,
                decoration: InputDecoration(
                  labelText: 'Estado',
                  prefixIcon: Icon(Icons.toggle_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'activo', child: Text('Activo')),
                  DropdownMenuItem(value: 'inactivo', child: Text('Inactivo')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _selectedEstado = value;
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_nroCasaController.text.isNotEmpty && propiedad.codigo != null) {
                try {
                  final propiedadActualizada = {
                    'nro_casa': int.tryParse(_nroCasaController.text) ?? 0,
                    'piso': int.tryParse(_pisoController.text) ?? 1,
                    'descripcion': _descripcionController.text,
                    'tamano_m2': double.tryParse(_tamanoController.text),
                    'estado': _selectedEstado,
                  };

                  await AdminPropiedadService.updatePropiedad(propiedad.codigo!, propiedadActualizada);
                  Navigator.pop(context);
                  _loadPropiedades();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unidad actualizada exitosamente'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar unidad: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Propiedad propiedad) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete, color: Colors.red.shade600),
            ),
            SizedBox(width: 12),
            Text('Eliminar Unidad'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la unidad ${propiedad.nroCasaDisplay}?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (propiedad.codigo != null) {
                try {
                  await AdminPropiedadService.deletePropiedad(propiedad.codigo!);
                  Navigator.pop(context);
                  _loadPropiedades();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Unidad eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar unidad: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar con gradiente
          SliverAppBar(
            expandedHeight: 160.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.indigo.shade400,
                      Colors.purple.shade500,
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.apartment,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Gestión de Unidades',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Administra las unidades habitacionales',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Contenido principal
          SliverToBoxAdapter(
            child: Container(
              color: Colors.grey.shade50,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Barra de búsqueda
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterPropiedades,
                        decoration: InputDecoration(
                          hintText: 'Buscar unidades...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Lista de propiedades
                    FutureBuilder<List<Propiedad>>(
                      future: _propiedadesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cargando unidades...',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Container(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(Icons.error, size: 64, color: Colors.red.shade400),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'Error al cargar unidades',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    '${snapshot.error}',
                                    style: TextStyle(color: Colors.grey.shade600),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _loadPropiedades,
                                    icon: Icon(Icons.refresh),
                                    label: Text('Reintentar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Icon(Icons.apartment, size: 64, color: Colors.grey.shade400),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'No hay unidades registradas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Agrega la primera unidad habitacional',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _showAddUnidadDialog,
                                    icon: Icon(Icons.add),
                                    label: Text('Agregar primera unidad'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.indigo,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Inicializar listas para filtrado
                        if (_allPropiedades.isEmpty) {
                          _allPropiedades = snapshot.data!;
                          _filteredPropiedades = _allPropiedades;
                        }

                        final propiedadesAMostrar = _searchController.text.isNotEmpty 
                            ? _filteredPropiedades 
                            : snapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: propiedadesAMostrar.length,
                          itemBuilder: (context, index) {
                            final propiedad = propiedadesAMostrar[index];
                            
                            return Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 60,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Colors.indigo.shade400,
                                            Colors.purple.shade500,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.home,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                propiedad.nroCasaDisplay,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                              if (propiedad.piso != null) ...[
                                                SizedBox(width: 8),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade200,
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    'Piso ${propiedad.piso}',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          if (propiedad.descripcion != null)
                                            Text(
                                              propiedad.descripcion!,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          SizedBox(height: 8),
                                          Row(
                                            children: [
                                              if (propiedad.tamanoM2 != null) ...[
                                                Icon(Icons.square_foot, size: 16, color: Colors.grey.shade500),
                                                SizedBox(width: 4),
                                                Text(
                                                  '${propiedad.tamanoM2} m²',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                SizedBox(width: 12),
                                              ],
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: propiedad.estado == 'activo' 
                                                      ? Colors.green.shade100 
                                                      : Colors.red.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  propiedad.estado ?? 'N/A',
                                                  style: TextStyle(
                                                    color: propiedad.estado == 'activo' 
                                                        ? Colors.green.shade700 
                                                        : Colors.red.shade700,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    PopupMenuButton(
                                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(Icons.edit, color: Colors.blue.shade400),
                                              SizedBox(width: 8),
                                              Text('Editar'),
                                            ],
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(Icons.delete, color: Colors.red.shade400),
                                              SizedBox(width: 8),
                                              Text(
                                                'Eliminar',
                                                style: TextStyle(color: Colors.red.shade400),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                          _showEditUnidadDialog(propiedad);
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(propiedad);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUnidadDialog,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        tooltip: 'Agregar Unidad',
        elevation: 8,
      ),
    );
  }
}