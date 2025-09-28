
import 'package:flutter/material.dart';
import 'package:movil/services/visitante_service.dart';
import 'package:movil/services/propiedad_service.dart';
import 'package:intl/intl.dart'; // For date formatting

class AddVisitanteScreen extends StatefulWidget {
  @override
  _AddVisitanteScreenState createState() => _AddVisitanteScreenState();
}

class _AddVisitanteScreenState extends State<AddVisitanteScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _carnetController = TextEditingController();
  final _motivoController = TextEditingController();

  DateTime? _fechaIni;
  DateTime? _fechaFin;

  bool _isSaving = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _fechaIni = picked;
        } else {
          _fechaFin = picked;
        }
      });
    }
  }

  Future<void> _saveVisitante() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaIni == null || _fechaFin == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, complete todos los campos, incluyendo fechas.')),
        );
        return;
      }

      setState(() { _isSaving = true; });

      try {
        // Obtener la propiedad activa del usuario
        final propiedadId = await PropiedadService.getMiPropiedadActiva();
        
        final visitanteData = {
          'nombre': _nombreController.text,
          'apellido': _apellidoController.text,
          'carnet': _carnetController.text,
          'motivo_visita': _motivoController.text,
          'fecha_ini': DateFormat('yyyy-MM-dd').format(_fechaIni!),
          'fecha_fin': DateFormat('yyyy-MM-dd').format(_fechaFin!),
          'codigo_propiedad': propiedadId,
        };

        await VisitanteService.addVisitante(visitanteData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Visitante agregado con éxito')),
        );
        Navigator.of(context).pop(true); // Return true to indicate success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar visitante: $e')),
        );
      } finally {
        setState(() { _isSaving = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
    );

    return Scaffold(
      appBar: AppBar(title: Text('Registrar Visitante')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildSectionTitle(context, 'Información del Visitante'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _nombreController,
                    decoration: inputDecoration.copyWith(hintText: 'Nombre'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _apellidoController,
                    decoration: inputDecoration.copyWith(hintText: 'Apellido'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 12),
                  TextFormField(
                    controller: _carnetController,
                    decoration: inputDecoration.copyWith(hintText: 'Carnet de Identidad'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle(context, 'Detalles de la Visita'),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _motivoController,
                    decoration: inputDecoration.copyWith(hintText: 'Motivo de la Visita'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 20),
                  _buildSectionTitle(context, 'Periodo de la Visita'),
                  SizedBox(height: 8),
                  _buildDatePickerField(
                    context,
                    label: 'Fecha de Inicio',
                    date: _fechaIni,
                    onTap: () => _selectDate(context, true),
                  ),
                  SizedBox(height: 12),
                  _buildDatePickerField(
                    context,
                    label: 'Fecha de Fin',
                    date: _fechaFin,
                    onTap: () => _selectDate(context, false),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveVisitante,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: Text('Guardar Visitante', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
          if (_isSaving)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildDatePickerField(BuildContext context, {required String label, required DateTime? date, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: InputDecorator(
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey.shade200,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? DateFormat('yyyy-MM-dd').format(date) : label,
              style: TextStyle(color: date != null ? Colors.black : Colors.grey.shade600, fontSize: 16),
            ),
            Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
          ],
        ),
      ),
    );
  }
}
