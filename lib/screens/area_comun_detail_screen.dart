import 'package:flutter/material.dart';
import 'package:movil/models/area_comun.dart';
import 'package:movil/services/reserva_service.dart';
import 'package:movil/services/auth_service.dart';
import 'package:intl/intl.dart';

class AreaComunDetailScreen extends StatefulWidget {
  final AreaComun area;

  const AreaComunDetailScreen({Key? key, required this.area}) : super(key: key);

  @override
  _AreaComunDetailScreenState createState() => _AreaComunDetailScreenState();
}

class _AreaComunDetailScreenState extends State<AreaComunDetailScreen> {
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _createReservation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = await AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('Usuario no autenticado');
      }

      final reservaData = {
        'codigo_usuario': currentUser.codigo,
        'id_area_c': widget.area.id,
        'fecha': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'estado': 'Pendiente',
      };

      // Usamos el método que existe en el servicio
      await ReservaService.crearReserva(reservaData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reserva creada exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear la reserva: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.area.descripcion ?? 'Detalle de Área'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.area.descripcion ?? 'Sin Descripción',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Capacidad: ${widget.area.capacidadMax ?? 'N/A'} personas'),
            SizedBox(height: 5),
            Text('Costo de reserva: \$${widget.area.costo?.toStringAsFixed(2) ?? 'N/A'}'),
            SizedBox(height: 30),
            Divider(),
            SizedBox(height: 20),
            Text(
              'Seleccionar Fecha para Reserva',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy-MM-dd').format(_selectedDate),
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.calendar_today, color: Colors.teal),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _createReservation,
                icon: _isLoading 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(Icons.event_available),
                label: Text(_isLoading ? 'Creando Reserva...' : 'Crear Reserva'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}