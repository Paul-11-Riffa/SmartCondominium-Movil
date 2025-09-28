
import 'package:flutter/material.dart';
import 'package:movil/models/area_comun.dart';
import 'package:movil/models/reserva.dart';
import 'package:movil/services/reserva_service.dart';
import 'package:movil/screens/area_comun_detail_screen.dart'; 

class AreasComunesScreen extends StatefulWidget {
  @override
  _AreasComunesScreenState createState() => _AreasComunesScreenState();
}

class _AreasComunesScreenState extends State<AreasComunesScreen> with SingleTickerProviderStateMixin {
  late Future<List<AreaComun>> _areasComunesFuture;
  late Future<List<Reserva>> _reservasFuture;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _areasComunesFuture = ReservaService.getAreasComunes();
      _reservasFuture = ReservaService.getMisReservas();
    });
  }

  String _getNombreArea(int? idArea, List<AreaComun>? areas) {
    if (idArea == null || areas == null) return 'Área no especificada';
    
    try {
      final area = areas.firstWhere((a) => a.id == idArea);
      return area.descripcion ?? 'Área ID: $idArea';
    } catch (e) {
      return 'Área ID: $idArea';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.cyan.shade400,
                        Colors.teal.shade500,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Reservar Áreas',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Gestiona tus reservas de áreas comunes',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(60),
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.cyan,
                    indicatorWeight: 3,
                    labelColor: Colors.cyan.shade700,
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    tabs: [
                      Tab(
                        icon: Icon(Icons.add_circle_outline, size: 24),
                        text: 'Nueva Reserva',
                      ),
                      Tab(
                        icon: Icon(Icons.list_alt, size: 24),
                        text: 'Mis Reservas',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          color: Colors.grey.shade50,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildNuevaReservaTab(),
              _buildMisReservasTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNuevaReservaTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: FutureBuilder<List<AreaComun>>(
        future: _areasComunesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay áreas comunes disponibles.'));
          }

          final areas = snapshot.data!;

          return Column(
            children: [
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.cyan.shade50, Colors.teal.shade50],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.cyan.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.cyan.shade700,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Selecciona un área común para hacer tu reserva',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.cyan.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white,
                              Colors.cyan.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.cyan.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AreaComunDetailScreen(area: area),
                                ),
                              ).then((_) {
                                _loadData();
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.all(20),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.cyan.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _getAreaIcon(area.descripcion),
                                      color: Colors.cyan.shade700,
                                      size: 32,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          area.descripcion ?? 'Sin Descripción',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade800,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people,
                                              size: 16,
                                              color: Colors.grey.shade600,
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              '${area.capacidadMax ?? 'N/A'} personas',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.attach_money,
                                              size: 16,
                                              color: Colors.green.shade600,
                                            ),
                                            Text(
                                              '\$${area.costo?.toStringAsFixed(2) ?? 'N/A'}',
                                              style: TextStyle(
                                                color: Colors.green.shade700,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 12),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade500,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            'Reservar Ahora',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.cyan.shade600,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMisReservasTab() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadData();
      },
      child: FutureBuilder<List<dynamic>>(
        future: Future.wait([_reservasFuture, _areasComunesFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${snapshot.error}'),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final reservas = snapshot.data![0] as List<Reserva>;
          final areas = snapshot.data![1] as List<AreaComun>;

          if (reservas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tienes reservas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Haz tu primera reserva en la pestaña "Nueva Reserva"',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                color: Colors.blue.withOpacity(0.1),
                child: Text(
                  'Tus Solicitudes de Reserva',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blue[800],
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: reservas.length,
                  itemBuilder: (context, index) {
                    final reserva = reservas[index];

                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(15),
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(reserva.estado),
                          child: Icon(
                            _getStatusIcon(reserva.estado),
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          _getNombreArea(reserva.idAreaC, areas),
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 5),
                            Text('Fecha: ${reserva.fecha ?? 'N/A'}'),
                            SizedBox(height: 3),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(reserva.estado),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                reserva.estado ?? 'N/A',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: _canDeleteReserva(reserva.estado) 
                          ? IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _showDeleteConfirmationDialog(reserva),
                            )
                          : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color _getStatusColor(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'rechazada':
      case 'rechazado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? estado) {
    switch (estado?.toLowerCase()) {
      case 'aprobada':
      case 'aprobado':
        return Icons.check_circle;
      case 'pendiente':
        return Icons.schedule;
      case 'rechazada':
      case 'rechazado':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  bool _canDeleteReserva(String? estado) {
    return estado?.toLowerCase() == 'pendiente';
  }

  Future<void> _showDeleteConfirmationDialog(Reserva reserva) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Reserva'),
          content: Text('¿Estás seguro de que deseas eliminar esta reserva pendiente?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteReserva(reserva);
    }
  }

  Future<void> _deleteReserva(Reserva reserva) async {
    try {
      await ReservaService.deleteReserva(reserva.id);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva eliminada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Recargar los datos para reflejar los cambios
      _loadData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la reserva: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Método para obtener el ícono apropiado según el tipo de área
  IconData _getAreaIcon(String? descripcion) {
    if (descripcion == null) return Icons.place;
    
    String desc = descripcion.toLowerCase();
    
    if (desc.contains('piscina')) return Icons.pool;
    if (desc.contains('gimnasio') || desc.contains('gym')) return Icons.fitness_center;
    if (desc.contains('salon') || desc.contains('salón')) return Icons.event;
    if (desc.contains('cancha') || desc.contains('tenis')) return Icons.sports_tennis;
    if (desc.contains('futbol') || desc.contains('fútbol')) return Icons.sports_soccer;
    if (desc.contains('parque') || desc.contains('jardin') || desc.contains('jardín')) return Icons.park;
    if (desc.contains('bbq') || desc.contains('parrilla') || desc.contains('asado')) return Icons.outdoor_grill;
    if (desc.contains('juegos') || desc.contains('niños')) return Icons.child_friendly;
    if (desc.contains('terraza') || desc.contains('rooftop')) return Icons.deck;
    if (desc.contains('biblioteca')) return Icons.library_books;
    if (desc.contains('sala') || desc.contains('reuniones')) return Icons.meeting_room;
    
    return Icons.place; // Ícono por defecto
  }
}
