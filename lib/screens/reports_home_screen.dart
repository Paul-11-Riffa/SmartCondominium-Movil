import 'package:flutter/material.dart';
import 'package:movil/screens/report_params_screen.dart'; // Importar la nueva pantalla

class ReportsHomeScreen extends StatelessWidget {
  const ReportsHomeScreen({Key? key}) : super(key: key);

  void _navigateToReportParams(BuildContext context, String reportType) {
    // Lógica de navegación a la pantalla de parámetros
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportParamsScreen(reportType: reportType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generación de Reportes'),
        backgroundColor: Colors.blue[800], // Un color de AppBar adecuado
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Seleccione el reporte que desea generar',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(height: 10),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.pie_chart, color: Colors.blueAccent),
              title: const Text('Uso de Áreas Comunes'),
              subtitle: const Text('Estadísticas de reservas y utilización.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToReportParams(context, 'areas_comunes'),
            ),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ListTile(
              leading: const Icon(Icons.history_edu, color: Colors.greenAccent),
              title: const Text('Bitácora del Sistema'),
              subtitle: const Text('Registro de acciones importantes.'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => _navigateToReportParams(context, 'bitacora'),
            ),
          ),
        ],
      ),
    );
  }
}
