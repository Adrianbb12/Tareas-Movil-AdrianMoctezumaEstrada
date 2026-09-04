import 'package:flutter/material.dart';

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Registro de Preferencias',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const RegistroPreferencias(),
    );
  }
}

class RegistroPreferencias extends StatefulWidget {
  const RegistroPreferencias({super.key});

  @override
  State<RegistroPreferencias> createState() =>
      _RegistroPreferenciasState();
}

class _RegistroPreferenciasState extends State<RegistroPreferencias> {

  // Controladores de los TextField
  final TextEditingController nombreController =
      TextEditingController();

  final TextEditingController edadController =
      TextEditingController();

  // Variable para RadioButton
  String genero = 'Masculino';

  // Variables para CheckBox
  bool deporte = false;
  bool musica = false;
  bool cine = false;
  bool lectura = false;

  // Variable para Dropdown
  String pais = 'México';

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Barra superior
      appBar: AppBar(
        title: const Text(
          'Registro de Preferencias',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // ============================
            // SECCIÓN 1
            // ============================

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Sección 1: Información General',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8),

                  Text(
                    'Completa los siguientes datos personales básicos',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ============================
            // SECCIÓN 2
            // ============================

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border.all(
                  color: Colors.green.shade200,
                ),
                borderRadius: BorderRadius.circular(10),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Row(
                    children: [
                      Icon(
                        Icons.person,
                        color: Colors.green,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Sección 2: Datos Personales',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: nombreController,

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),

                      prefixIcon: Icon(
                        Icons.person,
                      ),

                      hintText: 'Nombre completo',
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: edadController,

                    keyboardType: TextInputType.number,

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),

                      prefixIcon: Icon(
                        Icons.calendar_today,
                      ),

                      hintText: 'Edad',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ============================
            // SECCIÓN 3
            // ============================

            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.orange.shade50,

                border: Border.all(
                  color: Colors.orange.shade200,
                ),

                borderRadius: BorderRadius.circular(10),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [
                      Icon(
                        Icons.view_list,
                        color: Colors.orange,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Sección 3: Distribución en Filas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  crearFilaColor(
                    Colors.red.shade100,
                    Colors.red,
                    'Fila 1 - Color Rojo',
                  ),

                  const SizedBox(height: 8),

                  crearFilaColor(
                    Colors.yellow.shade100,
                    Colors.yellow,
                    'Fila 2 - Color Amarillo',
                  ),

                  const SizedBox(height: 8),

                  crearFilaColor(
                    Colors.blue.shade100,
                    Colors.blue,
                    'Fila 3 - Color Azul',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ============================
            // SECCIÓN 4
            // ============================

            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.purple.shade50,

                border: Border.all(
                  color: Colors.purple.shade200,
                ),

                borderRadius: BorderRadius.circular(10),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [
                      Icon(
                        Icons.grid_on,
                        color: Colors.purple,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Sección 4: Cuatro Hijos en Colores',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      Expanded(
                        child: crearHijo(
                          'Hijo 1',
                          Colors.pink.shade100,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: crearHijo(
                          'Hijo 2',
                          Colors.orange.shade100,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: crearHijo(
                          'Hijo 3',
                          Colors.green.shade100,
                        ),
                      ),

                      const SizedBox(width: 5),

                      Expanded(
                        child: crearHijo(
                          'Hijo 4',
                          Colors.deepPurple.shade100,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ============================
            // SECCIÓN 5
            // ============================

            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.grey.shade100,

                border: Border.all(
                  color: Colors.grey.shade300,
                ),

                borderRadius: BorderRadius.circular(10),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.grey,
                      ),

                      SizedBox(width: 8),

                      Text(
                        'Sección 5: Controles UI',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // GENERO

                  const Text(
                    'Género:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  RadioListTile<String>(
                    title: const Text('Masculino'),
                    value: 'Masculino',
                    groupValue: genero,

                    onChanged: (valor) {
                      setState(() {
                        genero = valor!;
                      });
                    },
                  ),

                  RadioListTile<String>(
                    title: const Text('Femenino'),
                    value: 'Femenino',
                    groupValue: genero,

                    onChanged: (valor) {
                      setState(() {
                        genero = valor!;
                      });
                    },
                  ),

                  RadioListTile<String>(
                    title: const Text('Otro'),
                    value: 'Otro',
                    groupValue: genero,

                    onChanged: (valor) {
                      setState(() {
                        genero = valor!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // INTERESES

                  const Text(
                    'Intereses:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  CheckboxListTile(
                    title: const Text('Deporte'),
                    value: deporte,

                    controlAffinity:
                        ListTileControlAffinity.leading,

                    onChanged: (valor) {
                      setState(() {
                        deporte = valor!;
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('Música'),
                    value: musica,

                    controlAffinity:
                        ListTileControlAffinity.leading,

                    onChanged: (valor) {
                      setState(() {
                        musica = valor!;
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('Cine'),
                    value: cine,

                    controlAffinity:
                        ListTileControlAffinity.leading,

                    onChanged: (valor) {
                      setState(() {
                        cine = valor!;
                      });
                    },
                  ),

                  CheckboxListTile(
                    title: const Text('Lectura'),
                    value: lectura,

                    controlAffinity:
                        ListTileControlAffinity.leading,

                    onChanged: (valor) {
                      setState(() {
                        lectura = valor!;
                      });
                    },
                  ),

                  const SizedBox(height: 10),

                  // PAIS

                  const Text(
                    'País:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: pais,

                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),

                      prefixIcon: Icon(
                        Icons.public,
                      ),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value: 'México',
                        child: Text('México'),
                      ),

                      DropdownMenuItem(
                        value: 'Estados Unidos',
                        child: Text('Estados Unidos'),
                      ),

                      DropdownMenuItem(
                        value: 'Canadá',
                        child: Text('Canadá'),
                      ),

                      DropdownMenuItem(
                        value: 'España',
                        child: Text('España'),
                      ),
                    ],

                    onChanged: (valor) {
                      setState(() {
                        pais = valor!;
                      });
                    },
                  ),

                  const SizedBox(height: 15),

                  // BOTONES

                  Row(
                    children: [

                      Expanded(
                        child: ElevatedButton.icon(

                          onPressed: mostrarPreferencias,

                          icon: const Icon(
                            Icons.visibility,
                          ),

                          label: const Text(
                            'Mostrar Preferencias',
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: ElevatedButton.icon(

                          onPressed: guardarRegistro,

                          icon: const Icon(
                            Icons.check_circle,
                          ),

                          label: const Text(
                            'Guardar Registro',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =================================================
  // MÉTODO PARA CREAR LAS FILAS DE COLORES
  // =================================================

  Widget crearFilaColor(
    Color fondo,
    Color circulo,
    String texto,
  ) {

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: fondo,

        borderRadius: BorderRadius.circular(8),
      ),

      child: Row(
        children: [

          Icon(
            Icons.circle,
            color: circulo,
            size: 18,
          ),

          const SizedBox(width: 8),

          Text(texto),
        ],
      ),
    );
  }

  // =================================================
  // MÉTODO PARA LOS CUATRO HIJOS
  // =================================================

  Widget crearHijo(
    String texto,
    Color color,
  ) {

    return Container(
      height: 55,

      decoration: BoxDecoration(
        color: color,

        borderRadius: BorderRadius.circular(6),
      ),

      child: Center(
        child: Text(texto),
      ),
    );
  }

  // =================================================
  // MOSTRAR PREFERENCIAS
  // =================================================

  void mostrarPreferencias() {

    String intereses = '';

    if (deporte) {
      intereses += 'Deporte ';
    }

    if (musica) {
      intereses += 'Música ';
    }

    if (cine) {
      intereses += 'Cine ';
    }

    if (lectura) {
      intereses += 'Lectura ';
    }

    showDialog(
      context: context,

      builder: (context) {

        return AlertDialog(

          title: const Text(
            'Preferencias',
          ),

          content: Text(
            'Nombre: ${nombreController.text}\n'
            'Edad: ${edadController.text}\n'
            'Género: $genero\n'
            'Intereses: $intereses\n'
            'País: $pais',
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },

              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  // =================================================
  // GUARDAR REGISTRO
  // =================================================

  void guardarRegistro() {

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(
        content: Text(
          'Registro guardado correctamente',
        ),
      ),
    );
  }
}