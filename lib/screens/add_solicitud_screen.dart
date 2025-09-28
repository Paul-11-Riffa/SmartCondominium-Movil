
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movil/models/propiedad.dart';
import 'package:movil/services/propiedad_service.dart';
import 'package:movil/services/mantenimiento_service.dart';
import 'package:movil/services/auth_service.dart';

class AddSolicitudScreen extends StatefulWidget {
  @override
  _AddSolicitudScreenState createState() => _AddSolicitudScreenState();
}

class _AddSolicitudScreenState extends State<AddSolicitudScreen> {
  final _formKey = GlobalKey<FormState>();

  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  int? _selectedPropiedadId;
  File? _image;
  final _picker = ImagePicker();

  late Future<List<Propiedad>> _propiedadesFuture;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _propiedadesFuture = PropiedadService.getMisPropiedades();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveSolicitud() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedPropiedadId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor, seleccione una propiedad.')),
        );
        return;
      }

      setState(() { _isSaving = true; });

      try {
        final currentUser = await AuthService.getCurrentUser();
        if (currentUser == null) throw Exception('Usuario no encontrado');

        final solicitudData = {
          'titulo': _tituloController.text,
          'descripcion': _descripcionController.text,
          'codigo_propiedad': _selectedPropiedadId!,
          'codigo_usuario': currentUser.codigo,
          'estado': 'Pendiente',
        };

        // Note: The service call doesn't handle the image upload yet.
        await MantenimientoService.addSolicitud(solicitudData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Solicitud enviada con éxito')),
        );
        Navigator.of(context).pop(true); // Return true for success
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar solicitud: $e')),
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
      appBar: AppBar(title: Text('Nueva Solicitud')),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Título de la Solicitud', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _tituloController,
                    decoration: inputDecoration.copyWith(hintText: 'Ej. Fuga en el grifo de la cocina'),
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 20),
                  Text('Descripción Detallada', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: inputDecoration.copyWith(hintText: 'Describa el problema...'),
                    maxLines: 4,
                    validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
                  ),
                  SizedBox(height: 20),
                  Text('Propiedad Afectada', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  FutureBuilder<List<Propiedad>>(
                    future: _propiedadesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                        return Text('No se pudieron cargar las propiedades.');
                      }
                      return DropdownButtonFormField<int>(
                        value: _selectedPropiedadId,
                        decoration: inputDecoration.copyWith(hintText: 'Seleccione una propiedad'),
                        items: snapshot.data!.map((prop) {
                          return DropdownMenuItem<int>(
                            value: prop.codigo,
                            child: Text('Casa #${prop.nroCasa ?? prop.codigo}'),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedPropiedadId = value),
                        validator: (value) => value == null ? 'Seleccione una propiedad' : null,
                      );
                    },
                  ),
                  SizedBox(height: 20),
                  Text('Adjuntar Foto (Opcional)', style: Theme.of(context).textTheme.titleMedium),
                  SizedBox(height: 8),
                  InkWell(
                    onTap: _pickImage,
                    borderRadius: BorderRadius.circular(12.0),
                    child: Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                      ),
                      child: _image != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, color: Colors.grey.shade600, size: 40),
                                  SizedBox(height: 8),
                                  Text('Toca para seleccionar una imagen', style: TextStyle(color: Colors.grey.shade600)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _saveSolicitud,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: Text('Enviar Solicitud', style: TextStyle(fontSize: 16)),
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
}
