import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// ============================================================
// APLICACIÓN PRINCIPAL
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro de Preferencias',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// PANTALLA PRINCIPAL
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================================
// ESTADO DE LA PANTALLA
// ============================================================

class _HomeScreenState extends State<HomeScreen> {
  // Datos personales
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _ageController =
      TextEditingController();

  // País seleccionado
  String _selectedCountry = 'Mexico';

  // Género seleccionado
  String _selectedGender = 'Masculino';

  // Intereses seleccionados
  final Set<String> _selectedInterests = {};

  // ==========================================================
  // CONSTRUCCIÓN DE LA INTERFAZ
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --------------------------------------------------------
      // APP BAR
      // --------------------------------------------------------

      appBar: AppBar(
        title: const Text(
          'Registro de Preferencias',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),

      // --------------------------------------------------------
      // CUERPO
      // --------------------------------------------------------

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =================================================
              // SECCIÓN 1 - INFORMACIÓN GENERAL
              // =================================================

              const SectionTitle(
                title: 'Información General',
              ),

              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 32,
                        color: Colors.blue.shade700,
                      ),

                      const SizedBox(width: 12),

                      const Expanded(
                        child: Text(
                          'Completa tus datos personales y selecciona '
                          'tus preferencias para registrar tu información.',
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // SECCIÓN 2 - DATOS PERSONALES
              // =================================================

              const SectionTitle(
                title: 'Datos Personales',
              ),

              const SizedBox(height: 8),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  hintText: 'Escribe tu nombre',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  hintText: 'Escribe tu edad',
                  prefixIcon: Icon(Icons.cake),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // SECCIÓN 3 - DISTRIBUCIÓN EN FILAS
              // =================================================

              const SectionTitle(
                title: 'Distribución en Filas',
              ),

              const SizedBox(height: 8),

              // Fila roja
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Fila Roja',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Fila amarilla
              Container(
                width: double.infinity,
                height: 55,
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Fila Amarilla',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Fila azul
              Container(
                width: double.infinity,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Text(
                    'Fila Azul',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // =================================================
              // SECCIÓN 4 - CUATRO HIJOS EN COLORES
              // =================================================

              const SectionTitle(
                title: 'Cuatro Hijos en Colores',
              ),

              const SizedBox(height: 8),

              Row(
                children: [

                  // Hijo 1
                  Expanded(
                    child: _colorChild(
                      'Hijo 1',
                      Colors.red,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Hijo 2
                  Expanded(
                    child: _colorChild(
                      'Hijo 2',
                      Colors.amber,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Hijo 3
                  Expanded(
                    child: _colorChild(
                      'Hijo 3',
                      Colors.green,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Hijo 4
                  Expanded(
                    child: _colorChild(
                      'Hijo 4',
                      Colors.blue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =================================================
              // SECCIÓN 5 - CONTROLES UI
              // =================================================

              const SectionTitle(
                title: 'Controles UI',
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // GÉNERO
              // ------------------------------------------------

              const Text(
                'Género',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              RadioGroup<String>(
                groupValue: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value!;
                  });
                },
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('Masculino'),
                      value: 'Masculino',
                      contentPadding: EdgeInsets.zero,
                    ),

                    RadioListTile<String>(
                      title: const Text('Femenino'),
                      value: 'Femenino',
                      contentPadding: EdgeInsets.zero,
                    ),

                    RadioListTile<String>(
                      title: const Text('Otro'),
                      value: 'Otro',
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // INTERESES
              // ------------------------------------------------

              const Text(
                'Intereses',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),

              CheckboxListTile(
                title: const Text('Deporte'),
                value: _selectedInterests.contains('Deporte'),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  _updateInterest('Deporte', value);
                },
              ),

              CheckboxListTile(
                title: const Text('Música'),
                value: _selectedInterests.contains('Música'),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  _updateInterest('Música', value);
                },
              ),

              CheckboxListTile(
                title: const Text('Cine'),
                value: _selectedInterests.contains('Cine'),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  _updateInterest('Cine', value);
                },
              ),

              CheckboxListTile(
                title: const Text('Lectura'),
                value: _selectedInterests.contains('Lectura'),
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  _updateInterest('Lectura', value);
                },
              ),

              const SizedBox(height: 8),

              // ------------------------------------------------
              // PAÍS
              // ------------------------------------------------

              DropdownButtonFormField<String>(
                initialValue: _selectedCountry,
                decoration: const InputDecoration(
                  labelText: 'País',
                  prefixIcon: Icon(Icons.public),
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Mexico',
                    child: Text('Mexico'),
                  ),
                  DropdownMenuItem(
                    value: 'Estados Unidos',
                    child: Text('Estados Unidos'),
                  ),
                  DropdownMenuItem(
                    value: 'Canada',
                    child: Text('Canada'),
                  ),
                  DropdownMenuItem(
                    value: 'España',
                    child: Text('España'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value!;
                  });
                },
              ),

              const SizedBox(height: 20),

              // =================================================
              // BOTONES
              // =================================================

              Row(
                children: [

                  // Botón Mostrar Preferencias
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _showPreferences,
                      icon: const Icon(Icons.visibility),
                      label: const Text(
                        'Mostrar Preferencias',
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Botón Guardar Registro
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _saveRecord,
                      icon: const Icon(Icons.save),
                      label: const Text(
                        'Guardar Registro',
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // ========================================================
      // BOTÓN FLOTANTE
      // ========================================================

      floatingActionButton: FloatingActionButton(
        onPressed: _saveRecord,
        child: const Icon(Icons.save),
      ),
    );
  }

  // ============================================================
  // WIDGET PARA LOS CUATRO HIJOS
  // ============================================================

  Widget _colorChild(
    String text,
    Color color,
  ) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTUALIZAR INTERESES
  // ============================================================

  void _updateInterest(
    String interest,
    bool? selected,
  ) {
    setState(() {
      if (selected == true) {
        _selectedInterests.add(interest);
      } else {
        _selectedInterests.remove(interest);
      }
    });
  }

  // ============================================================
  // MOSTRAR PREFERENCIAS
  // ============================================================

  void _showPreferences() {
    final String name =
        _nameController.text.isEmpty
            ? 'No especificado'
            : _nameController.text;

    final String age =
        _ageController.text.isEmpty
            ? 'No especificada'
            : _ageController.text;

    final String interests =
        _selectedInterests.isEmpty
            ? 'Ninguno'
            : _selectedInterests.join(', ');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Mis Preferencias',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text('Nombre: $name'),
                const SizedBox(height: 8),
                Text('Edad: $age'),
                const SizedBox(height: 8),
                Text('Género: $_selectedGender'),
                const SizedBox(height: 8),
                Text('Intereses: $interests'),
                const SizedBox(height: 8),
                Text('País: $_selectedCountry'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // GUARDAR REGISTRO
  // ============================================================

  void _saveRecord() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Registro guardado correctamente',
        ),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================
// TÍTULO DE LAS SECCIONES
// ============================================================

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.08),
        border: Border(
          left: BorderSide(
            color: Colors.blue.shade700,
            width: 5,
          ),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade800,
        ),
      ),
    );
  }
}