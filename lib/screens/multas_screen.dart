
import 'package:flutter/material.dart';
import 'package:movil/models/detalle_multa.dart';
import 'package:movil/services/multa_service.dart';

class MultasScreen extends StatefulWidget {
  @override
  _MultasScreenState createState() => _MultasScreenState();
}

class _MultasScreenState extends State<MultasScreen> {
  late Future<List<DetalleMulta>> _multasFuture;

  @override
  void initState() {
    super.initState();
    _loadMultas();
  }

  void _loadMultas() {
    setState(() {
      _multasFuture = MultaService.getMisMultas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Multas'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadMultas();
        },
        child: FutureBuilder<List<DetalleMulta>>(
          future: _multasFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error al cargar multas: ${snapshot.error}'),
                    SizedBox(height: 10),
                    ElevatedButton(onPressed: _loadMultas, child: Text('Reintentar'))
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No tienes multas registradas.'));
            }

            final multas = snapshot.data!;

            return ListView.builder(
              itemCount: multas.length,
              itemBuilder: (context, index) {
                final detalle = multas[index];
                final multaInfo = detalle.multaInfo; // Nested multa object

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          multaInfo?.descripcion ?? 'Descripción no disponible',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 8),
                        Divider(),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Monto:'),
                            Text(
                              '\$${multaInfo?.monto?.toStringAsFixed(2) ?? '0.00'}',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                            ),
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Fecha de Emisión:'),
                            Text(detalle.fechaEmi ?? 'N/A'),
                          ],
                        ),
                        SizedBox(height: 8,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estado:'),
                            Text(
                              multaInfo?.estado ?? 'N/A',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange), 
                            ),
                          ],
                        ),
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
