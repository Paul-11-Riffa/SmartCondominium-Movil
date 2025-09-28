import 'package:flutter/material.dart';
import 'package:movil/models/pago.dart';
import 'package:movil/services/admin_pago_service.dart';

class AdminCuotasServiciosScreen extends StatefulWidget {
  @override
  _AdminCuotasServiciosScreenState createState() => _AdminCuotasServiciosScreenState();
}

class _AdminCuotasServiciosScreenState extends State<AdminCuotasServiciosScreen> {
  late Future<List<Pago>> _pagosFuture;
  final _searchController = TextEditingController();
  List<Pago> _allPagos = [];
  List<Pago> _filteredPagos = [];

  @override
  void initState() {
    super.initState();
    _loadPagos();
  }

  void _loadPagos() {
    setState(() {
      _pagosFuture = AdminPagoService.getAllPagos();
    });
  }

  void _filterPagos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPagos = _allPagos;
      } else {
        _filteredPagos = _allPagos.where((pago) {
          final searchLower = query.toLowerCase();
          return (pago.descripcion?.toLowerCase().contains(searchLower) ?? false) ||
                 (pago.tipo?.toLowerCase().contains(searchLower) ?? false);
        }).toList();
      }
    });
  }

  void _showAddPagoDialog() {
    final _descripcionController = TextEditingController();
    final _montoController = TextEditingController();
    String _selectedTipo = 'Servicio';

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
              child: Icon(Icons.add_business, color: Colors.blue.shade600),
            ),
            SizedBox(width: 12),
            Text('Agregar Cuota/Servicio'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'Servicio', child: Text('Servicio')),
                  DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                  DropdownMenuItem(value: 'Extraordinaria', child: Text('Extraordinaria')),
                  DropdownMenuItem(value: 'Cuota', child: Text('Cuota')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _selectedTipo = value;
                  }
                },
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
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _montoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto (Bs.)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
              if (_descripcionController.text.isNotEmpty && _montoController.text.isNotEmpty) {
                try {
                  final nuevoPago = {
                    'tipo': _selectedTipo,
                    'descripcion': _descripcionController.text,
                    'monto': double.tryParse(_montoController.text) ?? 0.0,
                  };

                  await AdminPagoService.createPago(nuevoPago);
                  Navigator.pop(context);
                  _loadPagos();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cuota/Servicio creado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al crear cuota/servicio: $e'),
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
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }

  void _showEditPagoDialog(Pago pago) {
    final _descripcionController = TextEditingController(text: pago.descripcion);
    final _montoController = TextEditingController(text: pago.monto?.toString() ?? '');
    String _selectedTipo = pago.tipo ?? 'Servicio';

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
              child: Icon(Icons.edit, color: Colors.green.shade600),
            ),
            SizedBox(width: 12),
            Text('Editar Cuota/Servicio'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'Servicio', child: Text('Servicio')),
                  DropdownMenuItem(value: 'Mantenimiento', child: Text('Mantenimiento')),
                  DropdownMenuItem(value: 'Extraordinaria', child: Text('Extraordinaria')),
                  DropdownMenuItem(value: 'Cuota', child: Text('Cuota')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _selectedTipo = value;
                  }
                },
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
                maxLines: 2,
              ),
              SizedBox(height: 16),
              TextField(
                controller: _montoController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Monto (Bs.)',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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
              if (_descripcionController.text.isNotEmpty && _montoController.text.isNotEmpty && pago.id != null) {
                try {
                  final pagoActualizado = {
                    'tipo': _selectedTipo,
                    'descripcion': _descripcionController.text,
                    'monto': double.tryParse(_montoController.text) ?? 0.0,
                  };

                  await AdminPagoService.updatePago(pago.id!, pagoActualizado);
                  Navigator.pop(context);
                  _loadPagos();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cuota/Servicio actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar cuota/servicio: $e'),
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
            child: Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Pago pago) {
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
            Text('Eliminar Cuota/Servicio'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${pago.descripcion}"?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (pago.id != null) {
                try {
                  await AdminPagoService.deletePago(pago.id!);
                  Navigator.pop(context);
                  _loadPagos();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cuota/Servicio eliminado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar cuota/servicio: $e'),
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

  IconData _getIconForTipo(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'servicio':
        return Icons.build;
      case 'mantenimiento':
        return Icons.handyman;
      case 'extraordinaria':
        return Icons.star;
      case 'cuota':
        return Icons.payment;
      default:
        return Icons.attach_money;
    }
  }

  Color _getColorForTipo(String? tipo) {
    switch (tipo?.toLowerCase()) {
      case 'servicio':
        return Colors.blue.shade600;
      case 'mantenimiento':
        return Colors.orange.shade600;
      case 'extraordinaria':
        return Colors.purple.shade600;
      case 'cuota':
        return Colors.green.shade600;
      default:
        return Colors.grey.shade600;
    }
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
                      Colors.blue.shade400,
                      Colors.green.shade500,
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
                                Icons.account_balance_wallet,
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
                                    'Cuotas y Servicios',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Configura cuotas y servicios',
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
                        onChanged: _filterPagos,
                        decoration: InputDecoration(
                          hintText: 'Buscar cuotas y servicios...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Lista de pagos/servicios
                    FutureBuilder<List<Pago>>(
                      future: _pagosFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cargando cuotas y servicios...',
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
                                    'Error al cargar cuotas y servicios',
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
                                    onPressed: _loadPagos,
                                    icon: Icon(Icons.refresh),
                                    label: Text('Reintentar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
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
                                    child: Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey.shade400),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'No hay cuotas o servicios configurados',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Agrega la primera cuota o servicio',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _showAddPagoDialog,
                                    icon: Icon(Icons.add),
                                    label: Text('Agregar primera cuota/servicio'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue,
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
                        if (_allPagos.isEmpty) {
                          _allPagos = snapshot.data!;
                          _filteredPagos = _allPagos;
                        }

                        final pagosAMostrar = _searchController.text.isNotEmpty 
                            ? _filteredPagos 
                            : snapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: pagosAMostrar.length,
                          itemBuilder: (context, index) {
                            final pago = pagosAMostrar[index];
                            
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
                                        color: _getColorForTipo(pago.tipo).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: _getColorForTipo(pago.tipo).withOpacity(0.3),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        _getIconForTipo(pago.tipo),
                                        color: _getColorForTipo(pago.tipo),
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
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: _getColorForTipo(pago.tipo).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  pago.tipoDisplay,
                                                  style: TextStyle(
                                                    color: _getColorForTipo(pago.tipo),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            pago.descripcion ?? 'Sin descripción',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          Container(
                                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              pago.montoDisplay,
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
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
                                              Icon(Icons.edit, color: Colors.green.shade400),
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
                                          _showEditPagoDialog(pago);
                                        } else if (value == 'delete') {
                                          _showDeleteDialog(pago);
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
        onPressed: _showAddPagoDialog,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        tooltip: 'Agregar Cuota/Servicio',
        elevation: 8,
      ),
    );
  }
}