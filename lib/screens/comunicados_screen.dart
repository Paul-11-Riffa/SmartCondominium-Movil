
import 'package:flutter/material.dart';
import 'package:movil/models/comunicado.dart';
import 'package:movil/services/comunicado_service.dart';

class ComunicadosScreen extends StatefulWidget {
  @override
  _ComunicadosScreenState createState() => _ComunicadosScreenState();
}

class _ComunicadosScreenState extends State<ComunicadosScreen> {
  late Future<List<Comunicado>> _comunicadosFuture;

  @override
  void initState() {
    super.initState();
    _loadComunicados();
  }

  void _loadComunicados() {
    setState(() {
      _comunicadosFuture = ComunicadoService.getComunicados();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comunicados'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _loadComunicados();
        },
        child: FutureBuilder<List<Comunicado>>(
          future: _comunicadosFuture,
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
                      onPressed: _loadComunicados,
                      child: Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No hay comunicados disponibles.'));
            }

            final comunicados = snapshot.data!;

            return ListView.builder(
              itemCount: comunicados.length,
              itemBuilder: (context, index) {
                final comunicado = comunicados[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    title: Text(
                      comunicado.titulo ?? 'Sin Título',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 5),
                        Text(comunicado.contenido ?? 'Sin contenido.'),
                        SizedBox(height: 10),
                        Text(
                          '${comunicado.fecha ?? ''} - ${comunicado.hora ?? ''}',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                    isThreeLine: true,
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
