import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movil/services/ai_detection_service.dart';
import 'package:movil/models/perfil_facial.dart';
import 'package:camera/camera.dart';

class FacialRecognitionScreen extends StatefulWidget {
  const FacialRecognitionScreen({Key? key}) : super(key: key);

  @override
  _FacialRecognitionScreenState createState() => _FacialRecognitionScreenState();
}

class _FacialRecognitionScreenState extends State<FacialRecognitionScreen> {
  List<PerfilFacial> _profiles = [];
  bool _isLoading = false;
  bool _isRecognizing = false;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
    });

    final profiles = await AIDetectionService.listFaceProfiles();
    if (profiles != null) {
      setState(() {
        _profiles = profiles;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _takePictureForRecognition() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _isRecognizing = true;
        _resultMessage = null;
      });

      final result = await AIDetectionService.recognizeFace(image.path, 'Principal');
      
      setState(() {
        _isRecognizing = false;
        
        if (result != null) {
          bool isResident = result['is_resident'] ?? false;
          String name = result['user_name'] ?? 'Desconocido';
          double confidence = result['confidence']?.toDouble() ?? 0.0;
          
          if (isResident) {
            _resultMessage = '¡Bienvenido, $name! (Confianza: ${(confidence * 100).toStringAsFixed(1)}%)';
          } else {
            _resultMessage = 'Persona no identificada (Confianza: ${(confidence * 100).toStringAsFixed(1)}%)';
          }
        } else {
          _resultMessage = 'Error al procesar la imagen. Inténtelo de nuevo.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reconocimiento Facial'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Botón para reconocimiento facial
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Reconocimiento Facial',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tome una foto para reconocer rostros autorizados en el condominio.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isRecognizing ? null : _takePictureForRecognition,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tomar Foto y Reconocer'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ),
                    if (_isRecognizing) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                    if (_resultMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _resultMessage!.contains('Bienvenido') ? Colors.green[50] : Colors.red[50],
                          border: Border.all(
                            color: _resultMessage!.contains('Bienvenido') ? Colors.green : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _resultMessage!,
                          style: TextStyle(
                            color: _resultMessage!.contains('Bienvenido') ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Perfiles faciales registrados
            const Text(
              'Perfiles Faciales Registrados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_profiles.isEmpty)
              const Center(
                child: Text('No hay perfiles faciales registrados'),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _profiles.length,
                  itemBuilder: (context, index) {
                    final profile = _profiles[index];
                    return Card(
                      elevation: 2,
                      child: ListTile(
                        leading: CircleAvatar(
                          child: profile.imageUrl != null && profile.imageUrl!.isNotEmpty
                              ? Image.network(profile.imageUrl!, fit: BoxFit.cover)
                              : const Icon(Icons.person),
                        ),
                        title: Text(profile.userName ?? 'Usuario Desconocido'),
                        subtitle: Text(profile.userEmail ?? ''),
                        isThreeLine: false,
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