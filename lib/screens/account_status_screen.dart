import 'package:flutter/material.dart';
import 'package:movil/services/financial_service.dart';
import 'package:movil/models/pago.dart';
import 'package:movil/models/multa.dart';

class AccountStatusScreen extends StatefulWidget {
  const AccountStatusScreen({Key? key}) : super(key: key);

  @override
  _AccountStatusScreenState createState() => _AccountStatusScreenState();
}

class _AccountStatusScreenState extends State<AccountStatusScreen> {
  bool _isLoading = false;
  String _selectedMonth = '';
  Map<String, dynamic>? _accountData;

  @override
  void initState() {
    super.initState();
    _loadCurrentMonthAccount();
  }

  Future<void> _loadCurrentMonthAccount() async {
    _loadAccountData('');
  }

  Future<void> _loadAccountData(String? month) async {
    setState(() {
      _isLoading = true;
      _selectedMonth = month ?? '';
    });

    final response = await FinancialService.getEstadoCuenta(mes: month);
    
    if (response != null) {
      setState(() {
        _accountData = response;
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
        title: const Text('Estado de Cuenta'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de mes
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Seleccionar Mes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedMonth.isEmpty ? null : _selectedMonth,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Mes',
                      ),
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: const Text('Mes Actual'),
                        ),
                        for (int year = 2023; year <= 2025; year++)
                          for (int month = 1; month <= 12; month++)
                            DropdownMenuItem(
                              value: '$year-${month.toString().padLeft(2, '0')}',
                              child: Text('$year-${month.toString().padLeft(2, '0')}'),
                            ),
                      ],
                      onChanged: (value) {
                        _loadAccountData(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_accountData == null)
              const Center(child: Text('No se pudo cargar el estado de cuenta'))
            else ...[
              // Información de la cuenta
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Resumen de Cuenta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow('Mes:', _accountData!['mes']),
                      _buildInfoRow('Propiedades:', _getPropertiesString(_accountData!['propiedades'])),
                      _buildInfoRow('Cargos:', '\$${_accountData!['totales']['cargos']}'),
                      _buildInfoRow('Pagos:', '\$${_accountData!['totales']['pagos']}'),
                      const Divider(),
                      _buildInfoRow('Saldo:', '\$${_accountData!['totales']['saldo']}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Cargos
              const Text(
                'Cargos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildChargesList(),
              
              // Pagos
              const SizedBox(height: 16),
              const Text(
                'Pagos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildPaymentsList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _getPropertiesString(dynamic properties) {
    if (properties is List) {
      return properties.join(', ');
    }
    return properties?.toString() ?? 'N/A';
  }

  Widget _buildChargesList() {
    final cargos = _accountData!['cargos'] as List?;
    if (cargos == null || cargos.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No hay cargos para este período'),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(), // Para que funcione dentro del ListView principal
        itemCount: cargos.length,
        itemBuilder: (context, index) {
          final cargo = cargos[index];
          return Card(
            child: ListTile(
              title: Text(cargo['descripcion'] ?? 'Cargo'),
              subtitle: Text(cargo['tipo'] ?? 'Tipo no especificado'),
              trailing: Text(
                '\$${cargo['monto']?.toStringAsFixed(2) ?? '0.00'}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentsList() {
    // Mostrar pagos como lista vacía si no hay datos
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No hay pagos registrados para este período'),
      ),
    );
  }
}