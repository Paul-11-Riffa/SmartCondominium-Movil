import 'package:flutter/material.dart';
import 'package:movil/services/api_service.dart';
import 'package:movil/models/reporte_seguridad.dart';

class SecurityReportsScreen extends StatefulWidget {
  const SecurityReportsScreen({Key? key}) : super(key: key);

  @override
  _SecurityReportsScreenState createState() => _SecurityReportsScreenState();
}

class _SecurityReportsScreenState extends State<SecurityReportsScreen> {
  List<ReporteSeguridad> _reports = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() {
      _isLoading = true;
    });

    final response = await ApiService.get('reportes-seguridad');
    
    if (response != null && response['results'] != null) {
      setState(() {
        _reports = (response['results'] as List)
            .map((json) => ReporteSeguridad.fromJson(json))
            .toList();
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Color _getAlertColor(String? nivelAlerta) {
    switch (nivelAlerta?.toLowerCase()) {
      case 'bajo':
        return Colors.green;
      case 'medio':
        return Colors.orange;
      case 'alto':
      case 'critico':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Seguridad'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reportes de Seguridad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_reports.isEmpty)
              const Center(
                child: Text('No hay reportes de seguridad'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _reports.length,
                  itemBuilder: (context, index) {
                    final report = _reports[index];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _getAlertColor(report.nivelAlerta),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                report.nivelAlerta ?? 'N/A',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                report.tipoEvento ?? 'Evento',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              report.descripcion ?? 'Sin descripción',
                              style: const TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fecha: ${report.fechaEvento ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        trailing: report.revisado == true
                            ? const Icon(Icons.check_circle, color: Colors.green)
                            : const Icon(Icons.circle, color: Colors.orange),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}