import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movil/services/ai_detection_service.dart';
import 'package:camera/camera.dart';

class PlateDetectionScreen extends StatefulWidget {
  const PlateDetectionScreen({Key? key}) : super(key: key);

  @override
  _PlateDetectionScreenState createState() => _PlateDetectionScreenState();
}

class _PlateDetectionScreenState extends State<PlateDetectionScreen> {
  bool _isDetecting = false;
  String? _resultMessage;
  String? _detectedPlate;

  Future<void> _takePictureForDetection() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image != null) {
      setState(() {
        _isDetecting = true;
        _resultMessage = null;
        _detectedPlate = null;
      });

      final result = await AIDetectionService.detectPlate(image.path, 'Estacionamiento', 'entrada');
      
      setState(() {
        _isDetecting = false;
        
        if (result != null) {
          String? plate = result['plate'] as String?;
          bool? isAuthorized = result['is_authorized'] as bool?;
          double confidence = ((result['confidence'] as num?) ?? 0.0).toDouble();
          
          if (plate != null && plate.isNotEmpty) {
            _detectedPlate = plate;
            if (isAuthorized == true) {
              _resultMessage = 'Vehículo autorizado: $plate (Confianza: ${(confidence * 100).toStringAsFixed(1)}%)';
            } else {
              _resultMessage = 'Vehículo no autorizado: $plate (Confianza: ${(confidence * 100).toStringAsFixed(1)}%)';
            }
          } else {
            _resultMessage = 'No se detectó ninguna placa. Inténtelo de nuevo.';
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
        title: const Text('Detección de Placas'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Detección de Placas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tome una foto para detectar placas de vehículos autorizados en el condominio.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _isDetecting ? null : _takePictureForDetection,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Tomar Foto y Detectar Placa'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          backgroundColor: Colors.orange,
                        ),
                      ),
                    ),
                    if (_isDetecting) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                    if (_detectedPlate != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Placa Detectada',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              _detectedPlate!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_resultMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _resultMessage!.contains('autorizado') ? Colors.green[50] : Colors.red[50],
                          border: Border.all(
                            color: _resultMessage!.contains('autorizado') ? Colors.green : Colors.red,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _resultMessage!,
                          style: TextStyle(
                            color: _resultMessage!.contains('autorizado') ? Colors.green[700] : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Información adicional
            const Text(
              'Información',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 2,
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Esta función permite detectar placas de vehículos para controlar el acceso al estacionamiento del condominio. Los vehículos autorizados tendrán acceso automático.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}