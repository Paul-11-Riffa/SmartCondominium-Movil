import 'package:flutter/material.dart';
import 'package:movil/services/auth_service.dart';
import 'package:movil/screens/facial_recognition_screen.dart';
import 'package:movil/screens/plate_detection_screen.dart';
import 'package:movil/screens/security_reports_screen.dart';
import 'package:movil/screens/account_status_screen.dart';
import 'package:movil/screens/users_screen.dart';
import 'package:movil/screens/properties_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCondominium'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Text('Mi Perfil'),
                onTap: () {
                  // TODO: Implementar pantalla de perfil
                },
              ),
              PopupMenuItem(
                child: const Text('Cerrar Sesión'),
                onTap: () async {
                  await AuthService.logout();
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          )
        ],
      ),
      body: FutureBuilder(
        future: AuthService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          var usuario = snapshot.data;
          return Column(
            children: [
              // Bienvenida
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bienvenido/a',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      '${usuario?.nombre ?? 'Usuario'} ${usuario?.apellido ?? ''}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Opciones del dashboard
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardCard(
                        context,
                        'Reconocimiento Facial',
                        Icons.face,
                        Colors.blue,
                        FacialRecognitionScreen(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Detección de Placas',
                        Icons.car_rental,
                        Colors.orange,
                        PlateDetectionScreen(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Reportes de Seguridad',
                        Icons.security,
                        Colors.red,
                        SecurityReportsScreen(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Estado de Cuenta',
                        Icons.account_balance_wallet,
                        Colors.green,
                        AccountStatusScreen(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Usuarios',
                        Icons.people,
                        Colors.purple,
                        UsersScreen(),
                      ),
                      _buildDashboardCard(
                        context,
                        'Propiedades',
                        Icons.home,
                        Colors.teal,
                        PropertiesScreen(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return Card(
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}