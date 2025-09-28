
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:movil/models/factura.dart';
import 'package:movil/services/financial_service.dart';
import 'package:path_provider/path_provider.dart';
// Note: You might need to add the open_file package to pubspec.yaml
// import 'package:open_file/open_file.dart';

class FacturasHistoryScreen extends StatefulWidget {
  @override
  _FacturasHistoryScreenState createState() => _FacturasHistoryScreenState();
}

class _FacturasHistoryScreenState extends State<FacturasHistoryScreen> {
  late Future<List<Factura>> _facturasFuture;

  @override
  void initState() {
    super.initState();
    _loadFacturas();
  }

  void _loadFacturas() {
    setState(() {
      _facturasFuture = FinancialService.getFacturas();
    });
  }

  Future<void> _downloadAndOpenFile(int facturaId, BuildContext context) async {
    try {
      final Uint8List? fileBytes = await FinancialService.downloadComprobante(facturaId);
      if (fileBytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se pudo descargar el comprobante.')));
        return;
      }

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/comprobante_$facturaId.pdf';
      final file = File(filePath);
      await file.writeAsBytes(fileBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF guardado en $filePath'),
          action: SnackBarAction(
            label: 'Abrir',
            onPressed: () {
              // OpenFile.open(filePath);
            },
          ),
        ),
      );

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al procesar el archivo: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historial de Facturas'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadFacturas();
        },
        child: FutureBuilder<List<Factura>>(
          future: _facturasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay facturas disponibles.'));
            }

            final facturas = snapshot.data!;

            return ListView.builder(
              itemCount: facturas.length,
              itemBuilder: (context, index) {
                final factura = facturas[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Factura #${factura.id}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        Text('Fecha: ${factura.fecha ?? 'N/A'}'),
                        SizedBox(height: 4),
                        Text('Descripción: ${factura.descripcionPago ?? 'N/A'}'),
                        SizedBox(height: 4),
                        Text('Estado: ${factura.estado ?? 'N/A'}', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: factura.id != null ? () => _downloadAndOpenFile(factura.id!, context) : null,
                            icon: Icon(Icons.download_rounded),
                            label: Text('Descargar PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
