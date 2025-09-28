import 'package:flutter/material.dart';
import 'package:movil/models/detalle_multa.dart';
import 'package:movil/models/multa.dart';
import 'package:movil/models/propiedad.dart';
import 'package:movil/models/usuario.dart';
import 'package:movil/services/admin_detalle_multa_service.dart';
import 'package:movil/services/auth_service.dart';
import 'package:movil/services/api_service.dart';

class AdminAplicarMultasScreenSimple extends StatefulWidget {
  @override
  _AdminAplicarMultasScreenSimpleState createState() => _AdminAplicarMultasScreenSimpleState();
}

class _AdminAplicarMultasScreenSimpleState extends State<AdminAplicarMultasScreenSimple> {
  late Future<List<DetalleMulta>> _detallesMultaFuture;
  final _searchController = TextEditingController();
  List<DetalleMulta> _allDetalles = [];
  List<DetalleMulta> _filteredDetalles = [];

  @override
  void initState() {
    super.initState();
    // No cargar automáticamente, solo cuando el usuario lo solicite
    _detallesMultaFuture = Future.value([]); // Lista vacía por defecto
  }

  void _loadDetallesMulta() {
    setState(() {
      _detallesMultaFuture = AdminDetalleMultaService.getAllDetallesMulta();
    });
  }

  void _filterDetalles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDetalles = _allDetalles;
      } else {
        _filteredDetalles = _allDetalles.where((detalle) {
          final searchLower = query.toLowerCase();
          return (detalle.propiedadDisplay.toLowerCase().contains(searchLower)) ||
                 (detalle.id?.toString() ?? '').contains(searchLower);
        }).toList();
      }
    });
  }

  void _showAplicarMultaDialog() async {
    // Debug: mostrar información del usuario actual
    Usuario? currentUser = await AuthService.getCurrentUser();
    String? token = await AuthService.getToken();
    print('DEBUG: === INFORMACIÓN DE USUARIO ===');
    print('DEBUG: Usuario actual: ${currentUser?.correo}');
    print('DEBUG: ID Rol del usuario: ${currentUser?.idrol}');
    print('DEBUG: Token presente: ${token != null ? 'SÍ (${token.substring(0, 10)}...)' : 'NO'}');
    print('DEBUG: ===========================');
    
    // Prueba directa de endpoint de multas para debug
    print('DEBUG: Probando endpoint /multas/ directamente...');
    try {
      final testResponse = await ApiService.get('/multas/');
      print('DEBUG: Respuesta de prueba /multas/: $testResponse');
    } catch (e) {
      print('DEBUG: Error en prueba /multas/: $e');
    }
    
    List<Multa> tiposMulta = [];
    List<Propiedad> propiedades = [];
    
    // Mostrar diálogo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos...'),
            ],
          ),
        ),
      ),
    );
    
    try {
      // Cargar datos necesarios para el diálogo
      tiposMulta = await AdminDetalleMultaService.getTiposMulta();
      propiedades = await AdminDetalleMultaService.getPropiedades();
      
      Navigator.pop(context); // Cerrar diálogo de carga
      
      if (tiposMulta.isEmpty || propiedades.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudieron cargar los datos necesarios.\nTipos de multa: ${tiposMulta.length}, Propiedades: ${propiedades.length}'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 5),
          ),
        );
        return;
      } else if (tiposMulta.isNotEmpty && propiedades.isNotEmpty) {
        // Mostrar información si se están usando datos de ejemplo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos cargados: ${tiposMulta.length} tipos de multa, ${propiedades.length} propiedades'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Cerrar diálogo de carga
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar datos: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Propiedad? _selectedPropiedad;
    Multa? _selectedMulta;
    final _fechaEmisionController = TextEditingController(
      text: DateTime.now().toIso8601String().split('T')[0]
    );
    final _fechaLimiteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.add_alert, color: Colors.red.shade600),
              ),
              SizedBox(width: 12),
              Text('Aplicar Nueva Multa'),
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Selector de propiedad
                  DropdownButtonFormField<Propiedad>(
                    value: _selectedPropiedad,
                    decoration: InputDecoration(
                      labelText: 'Aplicar a la Unidad',
                      prefixIcon: Icon(Icons.home),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: Text('Seleccione una unidad...'),
                    items: propiedades.map((propiedad) {
                      return DropdownMenuItem(
                        value: propiedad,
                        child: Text(propiedad.nroCasaDisplay),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedPropiedad = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Selector de tipo de multa
                  DropdownButtonFormField<Multa>(
                    value: _selectedMulta,
                    decoration: InputDecoration(
                      labelText: 'Tipo de Multa',
                      prefixIcon: Icon(Icons.warning),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    hint: Text('Seleccione una multa del catálogo...'),
                    items: tiposMulta.map((multa) {
                      return DropdownMenuItem(
                        value: multa,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              multa.descripcion ?? 'Sin descripción',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Bs. ${multa.monto?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(
                                color: Colors.green.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        _selectedMulta = value;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  // Fecha de emisión
                  TextField(
                    controller: _fechaEmisionController,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Emisión',
                      prefixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now().subtract(Duration(days: 365)),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        _fechaEmisionController.text = date.toIso8601String().split('T')[0];
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  // Fecha límite de pago
                  TextField(
                    controller: _fechaLimiteController,
                    decoration: InputDecoration(
                      labelText: 'Fecha Límite de Pago',
                      prefixIcon: Icon(Icons.event),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    readOnly: true,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(Duration(days: 365)),
                      );
                      if (date != null) {
                        _fechaLimiteController.text = date.toIso8601String().split('T')[0];
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedPropiedad != null && 
                    _selectedMulta != null && 
                    _fechaEmisionController.text.isNotEmpty && 
                    _fechaLimiteController.text.isNotEmpty) {
                  try {
                    final detalleData = {
                      'codigo_propiedad': _selectedPropiedad!.codigo,
                      'id_multa': _selectedMulta!.id,
                      'fecha_emi': _fechaEmisionController.text,
                      'fecha_lim': _fechaLimiteController.text,
                    };

                    await AdminDetalleMultaService.createDetalleMulta(detalleData);
                    Navigator.pop(context);
                    _loadDetallesMulta();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Multa aplicada exitosamente a ${_selectedPropiedad!.nroCasaDisplay}'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al aplicar multa: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Por favor complete todos los campos'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text('Aplicar Multa'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(DetalleMulta detalle) {
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
            Text('Eliminar Multa'),
          ],
        ),
        content: Text(
          '¿Estás seguro de que deseas eliminar la multa ID: ${detalle.id}?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (detalle.id != null) {
                try {
                  await AdminDetalleMultaService.deleteDetalleMulta(detalle.id!);
                  Navigator.pop(context);
                  _loadDetallesMulta();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Multa eliminada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar multa: $e'),
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
                      Colors.red.shade400,
                      Colors.orange.shade500,
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
                                Icons.assignment_late,
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
                                    'Multas Aplicadas',
                                    style: TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Gestiona multas aplicadas a unidades',
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
                        onChanged: _filterDetalles,
                        decoration: InputDecoration(
                          hintText: 'Buscar multas aplicadas...',
                          prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    // Lista de multas aplicadas
                    FutureBuilder<List<DetalleMulta>>(
                      future: _detallesMultaFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Container(
                            height: 400,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Cargando multas aplicadas...',
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
                                    'Error al cargar multas aplicadas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20),
                                    child: Text(
                                      '${snapshot.error}',
                                      style: TextStyle(color: Colors.grey.shade600),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  ElevatedButton.icon(
                                    onPressed: _loadDetallesMulta,
                                    icon: Icon(Icons.refresh),
                                    label: Text('Reintentar'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
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
                                    child: Icon(Icons.assignment_late, size: 64, color: Colors.grey.shade400),
                                  ),
                                  SizedBox(height: 24),
                                  Text(
                                    'Gestión de Multas',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Aplica nuevas multas o ve la lista existente',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _showAplicarMultaDialog,
                                          icon: Icon(Icons.add_alert),
                                          label: Text('Aplicar Multa'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: _loadDetallesMulta,
                                          icon: Icon(Icons.list),
                                          label: Text('Ver Lista'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.symmetric(vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        // Inicializar listas para filtrado
                        if (_allDetalles.isEmpty) {
                          _allDetalles = snapshot.data!;
                          _filteredDetalles = _allDetalles;
                        }

                        final detallesAMostrar = _searchController.text.isNotEmpty 
                            ? _filteredDetalles 
                            : snapshot.data!;

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: detallesAMostrar.length,
                          itemBuilder: (context, index) {
                            final detalle = detallesAMostrar[index];
                            
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
                                        color: detalle.isVencida 
                                            ? Colors.red.shade100 
                                            : Colors.orange.shade100,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: detalle.isVencida 
                                              ? Colors.red.shade300 
                                              : Colors.orange.shade300,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        detalle.isVencida ? Icons.warning : Icons.assignment_late,
                                        color: detalle.isVencida 
                                            ? Colors.red.shade600 
                                            : Colors.orange.shade600,
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
                                                  color: Colors.blue.shade100,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  detalle.propiedadDisplay,
                                                  style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              if (detalle.isVencida)
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.red.shade100,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    'VENCIDA',
                                                    style: TextStyle(
                                                      color: Colors.red.shade700,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            detalle.multaDisplay,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Emisión: ${detalle.fechaEmisionDisplay}',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            'Límite: ${detalle.fechaLimiteDisplay}',
                                            style: TextStyle(
                                              color: detalle.isVencida ? Colors.red.shade600 : Colors.grey.shade600,
                                              fontSize: 12,
                                              fontWeight: detalle.isVencida ? FontWeight.w600 : FontWeight.normal,
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
                                              detalle.montoDisplay,
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
                                        if (value == 'delete') {
                                          _showDeleteDialog(detalle);
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
        onPressed: _showAplicarMultaDialog,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        child: Icon(Icons.add_alert),
        tooltip: 'Aplicar Multa a Unidad',
        elevation: 8,
      ),
    );
  }
}