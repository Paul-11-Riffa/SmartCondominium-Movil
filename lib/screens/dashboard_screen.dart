import 'package:flutter/material.dart';
import 'package:movil/services/auth_service.dart';
import 'package:movil/screens/facial_recognition_screen.dart';
import 'package:movil/screens/plate_detection_screen.dart';
import 'package:movil/screens/security_reports_screen.dart';
import 'package:movil/screens/account_status_screen.dart';
import 'package:movil/screens/users_screen.dart';
import 'package:movil/screens/admin_unidades_screen.dart';
import 'package:movil/screens/comunicados_screen.dart';
import 'package:movil/screens/admin_multas_screen.dart';
import 'package:movil/screens/admin_cuotas_servicios_screen.dart';
import 'package:movil/screens/areas_comunes_screen.dart';
import 'package:movil/screens/solicitudes_mantenimiento_screen.dart';
import 'package:movil/screens/visitantes_screen.dart';
import 'package:movil/screens/vehiculos_screen.dart';
import 'package:movil/screens/reports_home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  
  // Función para verificar si el usuario es administrador
  bool _isAdmin(dynamic user) {
    if (user == null) return false;
    
    // Lista de emails específicos que son administradores
    if (user.correo != null) {
      String email = user.correo.toString().toLowerCase();
      List<String> adminEmails = [
        'ana.gomez@test.com',
        'admin@test.com',
        'administrador@test.com',
        'supervisor@test.com',
        'gerente@test.com'
      ];
      
      if (adminEmails.contains(email)) return true;
      if (email.contains('admin') || email.contains('administrador') || 
          email.contains('supervisor') || email.contains('gerente')) return true;
    }
    
    // Verificar por rol
    if (user.rol != null) {
      Map<String, dynamic> rol = user.rol;
      if (rol['descripcion'] != null) {
        String roleDescription = rol['descripcion'].toString().toLowerCase().trim();
        List<String> adminRoles = ['administrador', 'admin', 'supervisor', 'gerente', 'director', 'jefe'];
        return adminRoles.contains(roleDescription);
      }
    }
    
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: AuthService.getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          }
          
          var usuario = snapshot.data;
          return CustomScrollView(
            slivers: [
              // App Bar con gradiente
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.teal.shade400,
                          Colors.cyan.shade600,
                          Colors.blue.shade500,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.home,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'SmartCondominium',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Bienvenido/a ${usuario?.nombre ?? 'Usuario'}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                actions: [
                  PopupMenuButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.more_vert, color: Colors.white),
                    ),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.person, color: Colors.teal),
                            SizedBox(width: 8),
                            Text('Mi Perfil'),
                          ],
                        ),
                        onTap: () {
                          // TODO: Implementar pantalla de perfil
                        },
                      ),
                      PopupMenuItem(
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Cerrar Sesión'),
                          ],
                        ),
                        onTap: () async {
                          await AuthService.logout();
                          if (mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(width: 8),
                ],
              ),
              // Contenido principal
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: _buildCategorizedSections(usuario),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Método para construir secciones categorizadas
  List<Widget> _buildCategorizedSections(dynamic usuario) {
    bool isAdmin = _isAdmin(usuario);
    
    return [
      // Sección: Mis Accesos
      _buildSectionHeader('Mis Accesos', Icons.vpn_key, Colors.teal),
      SizedBox(height: 16),
      _buildGridSection([
        _buildModernCard(
          'Mis Visitantes',
          Icons.people,
          Colors.blue,
          VisitantesScreen(),
          'Gestiona tus visitantes',
        ),
        _buildModernCard(
          'Mis Vehículos',
          Icons.directions_car,
          Colors.green,
          VehiculosScreen(),
          'Administra tus vehículos',
        ),
      ]),
      
      SizedBox(height: 32),
      
      // Sección: Servicios
      _buildSectionHeader('Servicios del Condominio', Icons.business, Colors.orange),
      SizedBox(height: 16),
      _buildGridSection([
        _buildModernCard(
          'Reservar Áreas',
          Icons.event_available,
          Colors.cyan,
          AreasComunesScreen(),
          'Reserva áreas comunes',
        ),
        _buildModernCard(
          'Solicitar Mantenimiento',
          Icons.build,
          Colors.amber,
          SolicitudesMantenimientoScreen(),
          'Reporta problemas',
        ),
        _buildModernCard(
          'Comunicados',
          Icons.campaign,
          Colors.deepPurple,
          ComunicadosScreen(),
          'Lee los anuncios',
        ),
        _buildModernCard(
          'Estado de Cuenta',
          Icons.account_balance_wallet,
          Colors.green.shade600,
          AccountStatusScreen(),
          'Revisa tus pagos',
        ),
      ]),
      
      // Secciones de administrador
      if (isAdmin) ...[
        SizedBox(height: 32),
        _buildSectionHeader('Administración', Icons.admin_panel_settings, Colors.red),
        SizedBox(height: 16),
        _buildGridSection([
          _buildModernCard(
            'Gestionar Usuarios',
            Icons.person,
            Colors.indigo,
            UsersScreen(),
            'Administra usuarios',
          ),
          _buildModernCard(
            'Gestionar Unidades',
            Icons.apartment,
            Colors.indigo,
            AdminUnidadesScreen(),
            'Administra unidades habitacionales',
          ),
          _buildModernCard(
            'Gestionar Multas',
            Icons.warning_amber_rounded,
            Colors.redAccent,
            AdminMultasScreen(),
            'Gestiona tipos de multas',
          ),
          _buildModernCard(
            'Cuotas y Servicios',
            Icons.account_balance_wallet,
            Colors.teal,
            AdminCuotasServiciosScreen(),
            'Configura cuotas y servicios',
          ),
          _buildModernCard(
            'Dashboard Financiero',
            Icons.analytics,
            Colors.green,
            AccountStatusScreen(),
            'Análisis financiero',
          ),
          _buildModernCard(
            'Reportes y Estadísticas',
            Icons.bar_chart,
            Colors.brown,
            ReportsHomeScreen(),
            'Genera reportes del sistema',
          ),
        ]),
        
        SizedBox(height: 32),
        _buildSectionHeader('Seguridad IA', Icons.security, Colors.purple),
        SizedBox(height: 16),
        _buildGridSection([
          _buildModernCard(
            'Reconocimiento Facial',
            Icons.face,
            Colors.blue,
            FacialRecognitionScreen(),
            'IA de reconocimiento',
          ),
          _buildModernCard(
            'Detección de Placas',
            Icons.car_rental,
            Colors.orange,
            PlateDetectionScreen(),
            'Detecta vehículos',
          ),
          _buildModernCard(
            'Reportes de Seguridad',
            Icons.shield,
            Colors.red,
            SecurityReportsScreen(),
            'Informes de seguridad',
          ),
        ]),
      ],
      
      SizedBox(height: 32),
    ];
  }

  // Widget para encabezado de sección
  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // Widget para sección de grilla
  Widget _buildGridSection(List<Widget> cards) {
    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.85,
      children: cards,
    );
  }

  // Método para construir una tarjeta moderna
  Widget _buildModernCard(
    String title,
    IconData icon,
    Color color,
    Widget screen,
    String subtitle,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 0,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32.0,
                  color: color,
                ),
              ),
              SizedBox(height: 12.0),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.0,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}