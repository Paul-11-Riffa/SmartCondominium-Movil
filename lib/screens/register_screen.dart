import 'package:flutter/material.dart';
import 'package:movil/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final Function onRegister;
  
  const RegisterScreen({Key? key, required this.onRegister}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  String _sexo = '';
  
  bool _isLoading = false;
  String? _errorMessage;

  void _nextPage() {
    if (_validateCurrentPage()) {
      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage++;
        });
      }
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage--;
      });
    }
  }

  bool _validateCurrentPage() {
    setState(() {
      _errorMessage = null;
    });

    switch (_currentPage) {
      case 0:
        if (_nombreController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Nombre es obligatorio';
          });
          return false;
        }
        if (_apellidoController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Apellido es obligatorio';
          });
          return false;
        }
        break;
      case 1:
        if (_correoController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Correo es obligatorio';
          });
          return false;
        }
        if (!_correoController.text.contains('@')) {
          setState(() {
            _errorMessage = 'Correo no válido';
          });
          return false;
        }
        if (_contrasenaController.text.length < 8) {
          setState(() {
            _errorMessage = 'Contraseña debe tener al menos 8 caracteres';
          });
          return false;
        }
        break;
      case 2:
        if (_telefonoController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Teléfono es obligatorio';
          });
          return false;
        }
        if (_sexo.isEmpty) {
          setState(() {
            _errorMessage = 'Seleccione un sexo';
          });
          return false;
        }
        break;
    }
    return true;
  }

  void _register() async {
    if (!_validateCurrentPage()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await AuthService.register(
      _nombreController.text.trim(),
      _apellidoController.text.trim(),
      _correoController.text.trim(),
      _contrasenaController.text,
      _sexo,
      _telefonoController.text,
    );

    if (result != null) {
      if (result['success']) {
        // Mostrar mensaje de éxito y volver al login
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Registro exitoso! Ahora puedes iniciar sesión.'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRegister(result['user']);
      } else {
        setState(() {
          _errorMessage = result['message'];
        });
      }
    } else {
      setState(() {
        _errorMessage = 'Error de conexión con el servidor';
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartCondominium'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Indicador de pasos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepIndicator(0),
                const SizedBox(width: 10),
                _buildStepIndicator(1),
                const SizedBox(width: 10),
                _buildStepIndicator(2),
              ],
            ),
            const SizedBox(height: 20),
            // Mensaje de error si existe
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ],
            // Contenido del formulario
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  // Página 1: Nombre y apellido
                  _buildPage1(),
                  // Página 2: Correo y contraseña
                  _buildPage2(),
                  // Página 3: Teléfono y sexo
                  _buildPage3(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Botones de navegación
            _buildNavigationButtons(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: _currentPage >= index ? Colors.blue : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: _currentPage >= index ? Colors.white : Colors.grey[700],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildPage1() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage2() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Credenciales',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _correoController,
              decoration: const InputDecoration(
                labelText: 'Correo Electrónico',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contrasenaController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage3() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contacto y Sexo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _telefonoController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const Text('Sexo'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Masculino'),
                    value: 'M',
                    groupValue: _sexo,
                    onChanged: (value) {
                      setState(() {
                        _sexo = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Femenino'),
                    value: 'F',
                    groupValue: _sexo,
                    onChanged: (value) {
                      setState(() {
                        _sexo = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentPage > 0)
          Expanded(
            child: ElevatedButton(
              onPressed: _prevPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('Atrás'),
            ),
          )
        else
          const Spacer(),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: _currentPage == 2 ? _register : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentPage == 2 ? Colors.green : Colors.blue,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : Text(_currentPage == 2 ? 'Registrarse' : 'Siguiente'),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}