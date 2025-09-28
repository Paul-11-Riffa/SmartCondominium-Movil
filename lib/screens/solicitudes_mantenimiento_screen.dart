
import 'package:flutter/material.dart';
import 'package:movil/models/solicitud_mantenimiento.dart';
import 'package:movil/services/mantenimiento_service.dart';
import 'package:movil/screens/add_solicitud_screen.dart';

class SolicitudesMantenimientoScreen extends StatefulWidget {
  @override
  _SolicitudesMantenimientoScreenState createState() =>
      _SolicitudesMantenimientoScreenState();
}

class _SolicitudesMantenimientoScreenState
    extends State<SolicitudesMantenimientoScreen> {
  late Future<List<SolicitudMantenimiento>> _solicitudesFuture;

  @override
  void initState() {
    super.initState();
    _loadSolicitudes();
  }

  void _loadSolicitudes() {
    setState(() {
      _solicitudesFuture = MantenimientoService.getMisSolicitudes();
    });
  }

  void _navigateAndReload() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddSolicitudScreen()),
    );

    if (result == true) {
      _loadSolicitudes();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Solicitudes de Mantenimiento'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadSolicitudes();
        },
        child: FutureBuilder<List<SolicitudMantenimiento>>(
          future: _solicitudesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No has enviado solicitudes.'));
            }

            final solicitudes = snapshot.data!;

            return ListView.builder(
              itemCount: solicitudes.length,
              itemBuilder: (context, index) {
                final solicitud = solicitudes[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ListTile(
                    title: Text(solicitud.titulo),
                    subtitle: Text('Propiedad: ${solicitud.codigoPropiedad} \nFecha: ${solicitud.fechaSolicitud?.split('T').first ?? 'N/A'}'),
                    trailing: Text(
                      solicitud.estado ?? 'N/A',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(solicitud.estado),
                      ),
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateAndReload,
        child: Icon(Icons.add),
        tooltip: 'Nueva Solicitud',
        backgroundColor: Colors.orange,
      ),
    );
  }

  Color _getStatusColor(String? estado) {
    switch (estado) {
      case 'Pendiente':
        return Colors.orange;
      case 'En Progreso':
        return Colors.blue;
      case 'Completada':
        return Colors.green;
      case 'Cancelada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
