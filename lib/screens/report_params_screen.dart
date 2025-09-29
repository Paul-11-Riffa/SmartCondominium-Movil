import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movil/screens/report_display_screen.dart'; // Se importará más adelante

class ReportParamsScreen extends StatefulWidget {
  final String reportType;

  const ReportParamsScreen({Key? key, required this.reportType}) : super(key: key);

  @override
  _ReportParamsScreenState createState() => _ReportParamsScreenState();
}

class _ReportParamsScreenState extends State<ReportParamsScreen> {
  DateTime? _startDate;
  DateTime? _endDate;

  String get _pageTitle {
    switch (widget.reportType) {
      case 'areas_comunes':
        return 'Reporte de Áreas Comunes';
      case 'bitacora':
        return 'Reporte de Bitácora';
      default:
        return 'Generar Reporte';
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020), 
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _generateReport() {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, seleccione fecha de inicio y fin.')),
      );
      return;
    }
    if (_startDate!.isAfter(_endDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha de inicio no puede ser posterior a la fecha de fin.')),
      );
      return;
    }

    print('Generando reporte: ${widget.reportType} desde $_startDate hasta $_endDate');
    
    // Lógica de navegación futura a la pantalla que mostrará los datos
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDisplayScreen(
          reportType: widget.reportType,
          startDate: _startDate!,
          endDate: _endDate!,
        ),
      ),
    );
    
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Seleccione el rango de fechas para el reporte.',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            
            // Selector de Fecha de Inicio
            Text('Fecha de Inicio', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _startDate == null ? 'No seleccionada' : formatter.format(_startDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Selector de Fecha de Fin
            Text('Fecha de Fin', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectDate(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _endDate == null ? 'No seleccionada' : formatter.format(_endDate!),
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.blueAccent),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Botón para generar el reporte
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.bar_chart),
                label: const Text('Generar Reporte'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  )
                ),
                onPressed: _generateReport,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
