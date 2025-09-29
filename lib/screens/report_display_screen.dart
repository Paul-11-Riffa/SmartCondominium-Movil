import 'package:flutter/material.dart';
import 'package:movil/services/report_service.dart';

class ReportDisplayScreen extends StatefulWidget {
  final String reportType;
  final DateTime startDate;
  final DateTime endDate;

  const ReportDisplayScreen({
    Key? key,
    required this.reportType,
    required this.startDate,
    required this.endDate,
  }) : super(key: key);

  @override
  _ReportDisplayScreenState createState() => _ReportDisplayScreenState();
}

class _ReportDisplayScreenState extends State<ReportDisplayScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _reportData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchReportData();
  }

  Future<void> _fetchReportData() async {
    try {
      Map<String, dynamic>? data;
      if (widget.reportType == 'areas_comunes') {
        data = await ReportService.getAreasComunesReport(
          fechaInicio: widget.startDate,
          fechaFin: widget.endDate,
        );
      } else if (widget.reportType == 'bitacora') {
        data = await ReportService.getBitacoraReport(
          fechaInicio: widget.startDate,
          fechaFin: widget.endDate,
        );
      }

      setState(() {
        _reportData = data;
        _isLoading = false;
        if (data == null) {
          _error = 'No se pudieron obtener los datos del reporte.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Ocurrió un error: $e';
        _isLoading = false;
      });
    }
  }

  String get _pageTitle {
    return widget.reportType == 'areas_comunes'
        ? 'Reporte de Áreas Comunes'
        : 'Reporte de Bitácora';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_pageTitle),
        backgroundColor: Colors.blue[800],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_reportData == null) {
      return const Center(child: Text('No hay datos disponibles para este reporte.'));
    }

    // Elige qué widget de visualización usar según el tipo de reporte
    if (widget.reportType == 'areas_comunes') {
      return _buildAreasComunesReport(_reportData!)
    ;} else {
      return _buildBitacoraReport(_reportData!)
    ;
    }
  }

  // Widget para mostrar el reporte de Áreas Comunes
  Widget _buildAreasComunesReport(Map<String, dynamic> data) {
    final List<dynamic> details = data['detalle_por_area'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryCard(
          'Total de Reservas',
          data['total_reservas']?.toString() ?? '0',
          Icons.event_available,
          Colors.blueAccent,
        ),
        const SizedBox(height: 16),
        Text('Detalle por Área', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (details.isEmpty)
          const Text('No se encontraron reservas en el periodo seleccionado.')
        else
          ...details.map((item) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                leading: const Icon(Icons.location_city, color: Colors.teal),
                title: Text(item['id_area_c__descripcion'] ?? 'Área desconocida'),
                trailing: Text(
                  item['cantidad_reservas']?.toString() ?? '0',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  // Widget para mostrar el reporte de Bitácora
  Widget _buildBitacoraReport(Map<String, dynamic> data) {
    final List<dynamic> details = data['detalle'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSummaryCard(
          'Total de Entradas',
          data['total_entradas']?.toString() ?? '0',
          Icons.receipt_long,
          Colors.greenAccent,
        ),
        const SizedBox(height: 16),
        Text('Registro de Actividad', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (details.isEmpty)
          const Text('No se encontraron registros en el periodo seleccionado.')
        else
          ...details.map((item) {
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(item['accion'] ?? 'Acción no registrada'),
                subtitle: Text(
                    '${item['usuario'] ?? 'N/A'} - ${item['fecha'] ?? ''} ${item['hora'] ?? ''}\nIP: ${item['ip'] ?? 'N/A'}'),
                isThreeLine: true,
              ),
            );
          }).toList(),
      ],
    );
  }

  // Widget genérico para una tarjeta de resumen
  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
