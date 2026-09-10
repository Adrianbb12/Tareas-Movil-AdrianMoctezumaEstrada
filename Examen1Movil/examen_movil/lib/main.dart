import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const colorPrincipal = Color(0xFF4B3F72);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reserva de Viaje',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colorPrincipal,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFFF9F2),
        appBarTheme: const AppBarTheme(
          backgroundColor: colorPrincipal,
          foregroundColor: Colors.white,
          centerTitle: false,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFE9E1D8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: colorPrincipal, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorPrincipal,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: colorPrincipal,
            minimumSize: const Size(0, 52),
            side: const BorderSide(
              color: colorPrincipal,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      home: const PantallaReserva(),
    );
  }
}

class PantallaReserva extends StatefulWidget {
  const PantallaReserva({super.key});

  @override
  State<PantallaReserva> createState() => _PantallaReservaState();
}

class _PantallaReservaState extends State<PantallaReserva> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController correoController = TextEditingController();

  String destinoSeleccionado = '';
  String transporteSeleccionado = 'Avión';

  bool hotelSeleccionado = false;
  bool tourSeleccionado = false;
  bool seguroSeleccionado = false;
  bool notificaciones = false;

  double presupuesto = 3000;
  DateTime? fechaSeleccionada;

  final double precioHotel = 1200;
  final double precioTour = 600;
  final double precioSeguro = 400;

  void mostrarSnackBar(String mensaje) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );
  }

  void limpiarDatos() {
    setState(() {
      nombreController.clear();
      correoController.clear();
      destinoSeleccionado = '';
      transporteSeleccionado = 'Avión';
      hotelSeleccionado = false;
      tourSeleccionado = false;
      seguroSeleccionado = false;
      notificaciones = false;
      presupuesto = 3000;
      fechaSeleccionada = null;
    });

    mostrarSnackBar('Todos los datos fueron limpiados');
  }

  Future<void> seleccionarFecha() async {
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4B3F72),
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        fechaSeleccionada = fecha;
      });
      mostrarSnackBar('Fecha del viaje seleccionada');
    }
  }

  bool correoValido(String correo) {
    return RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(correo);
  }

  void mostrarAlerta(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(titulo),
          content: Text(mensaje),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  bool validarDatos() {
    final nombreVacio = nombreController.text.trim().isEmpty;
    final correo = correoController.text.trim();
    final correoInvalido = correo.isEmpty || !correoValido(correo);
    final fechaFaltante = fechaSeleccionada == null;

    if (nombreVacio || correoInvalido || fechaFaltante) {
      mostrarAlerta(
        'Falta información',
        'Verifica los datos de tu reserva. Puede faltar el nombre, el correo puede no ser válido o puede que no hayas seleccionado una fecha.',
      );
      return false;
    }

    return true;
  }

  double calcularTotal() {
    double total = presupuesto;

    if (hotelSeleccionado) {
      total += precioHotel;
    }

    if (tourSeleccionado) {
      total += precioTour;
    }

    if (seguroSeleccionado) {
      total += precioSeguro;
    }

    return total;
  }

  List<String> obtenerExtras() {
    final List<String> extras = [];

    if (hotelSeleccionado) {
      extras.add('Hotel incluido (+ \$1200)');
    }

    if (tourSeleccionado) {
      extras.add('Tour guiado (+ \$600)');
    }

    if (seguroSeleccionado) {
      extras.add('Seguro de viaje (+ \$400)');
    }

    return extras;
  }

  String obtenerFechaTexto() {
    if (fechaSeleccionada == null) {
      return 'No seleccionada';
    }

    return '${fechaSeleccionada!.day.toString().padLeft(2, '0')}/'
        '${fechaSeleccionada!.month.toString().padLeft(2, '0')}/'
        '${fechaSeleccionada!.year}';
  }

  void mostrarResumen() {
    final String extrasTexto = obtenerExtras().isEmpty
        ? 'Ninguno'
        : obtenerExtras().join('\n');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.visibility, color: Color(0xFF4B3F72)),
              SizedBox(width: 10),
              Text('Resumen'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _datoResumen(
                  Icons.person,
                  'Nombre',
                  nombreController.text.isEmpty
                      ? 'No ingresado'
                      : nombreController.text,
                ),
                _datoResumen(
                  Icons.email,
                  'Correo',
                  correoController.text.isEmpty
                      ? 'No ingresado'
                      : correoController.text,
                ),
                _datoResumen(
                  Icons.location_on,
                  'Destino',
                  destinoSeleccionado.isEmpty
                      ? 'No seleccionado'
                      : destinoSeleccionado,
                ),
                _datoResumen(
                  Icons.directions_transit,
                  'Transporte',
                  transporteSeleccionado,
                ),
                _datoResumen(
                  Icons.star,
                  'Extras',
                  extrasTexto,
                ),
                _datoResumen(
                  Icons.notifications,
                  'Notificaciones',
                  notificaciones ? 'Activadas' : 'Desactivadas',
                ),
                _datoResumen(
                  Icons.payments,
                  'Presupuesto',
                  '\$${presupuesto.toStringAsFixed(0)}',
                ),
                _datoResumen(
                  Icons.calendar_month,
                  'Fecha',
                  obtenerFechaTexto(),
                ),
                const Divider(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Precio total',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      '\$${calcularTotal().toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: Color(0xFF4B3F72),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _datoResumen(
    IconData icono,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icono,
            size: 21,
            color: const Color(0xFF4B3F72),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$titulo: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: valor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void seleccionarDestino(String destino) {
    setState(() {
      destinoSeleccionado = destino;
    });
    mostrarSnackBar('Destino seleccionado: $destino');
  }

  void confirmarReserva() {
    if (!validarDatos()) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PantallaBoleto(
          nombre: nombreController.text,
          correo: correoController.text,
          destino: destinoSeleccionado.isEmpty
              ? 'No seleccionado'
              : destinoSeleccionado,
          transporte: transporteSeleccionado,
          extras: obtenerExtras(),
          notificaciones: notificaciones,
          precioTotal: calcularTotal(),
          fecha: obtenerFechaTexto(),
        ),
      ),
    );
  }

  Widget encabezadoSeccion({
    required String numero,
    required String titulo,
    required String subtitulo,
    required IconData icono,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icono,
            color: color,
            size: 25,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sección $numero - $titulo',
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitulo,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget tarjetaSeccion({
    required Widget child,
    Color color = Colors.white,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }

  Widget tarjetaDestino({
    required String titulo,
    required IconData icono,
    required Color color,
    required bool seleccionado,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 112,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: seleccionado
                ? color.withValues(alpha: 0.18)
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: seleccionado
                  ? color
                  : const Color(0xFFE7DDD4),
              width: seleccionado ? 2.2 : 1,
            ),
            boxShadow: seleccionado
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.14),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                color: color,
                size: 35,
              ),
              const SizedBox(height: 8),
              Text(
                titulo,
                style: TextStyle(
                  color: seleccionado ? color : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              if (seleccionado)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Icon(
                    Icons.check_circle,
                    color: color,
                    size: 16,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tarjetaExtra({
    required String titulo,
    required String precio,
    required IconData icono,
    required bool seleccionado,
    required Color color,
    required ValueChanged<bool?> onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: seleccionado
            ? color.withValues(alpha: 0.12)
            : Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: seleccionado
              ? color.withValues(alpha: 0.45)
              : const Color(0xFFE7DDD4),
        ),
      ),
      child: CheckboxListTile(
        value: seleccionado,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        activeColor: color,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 4,
        ),
        secondary: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: seleccionado
                ? color.withValues(alpha: 0.16)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icono,
            color: seleccionado ? color : Colors.grey.shade600,
          ),
        ),
        title: Text(
          titulo,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          precio,
          style: TextStyle(
            color: seleccionado ? color : Colors.grey.shade600,
            fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reserva de Viaje',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined),
            tooltip: 'Limpiar datos',
            onPressed: limpiarDatos,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tarjetaSeccion(
              color: const Color(0xFFF4EEF9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  encabezadoSeccion(
                    numero: '1',
                    titulo: 'Información general',
                    subtitulo: 'Completa tu reserva paso a paso',
                    icono: Icons.info_outline,
                    color: const Color(0xFF4B3F72),
                  ),
                  const Divider(height: 28),
                  const Text(
                    'Llena tus datos, elige destino y confirma tu viaje.',
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            tarjetaSeccion(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  encabezadoSeccion(
                    numero: '2',
                    titulo: 'Datos del viajero',
                    subtitulo: '¿Quién se va de viaje?',
                    icono: Icons.person_outline,
                    color: const Color(0xFF7A9E3A),
                  ),
                  const Divider(height: 28),
                  TextField(
                    controller: nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre completo',
                      hintText: 'Ej: Ana García',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: correoController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      hintText: 'Ej: ana@correo.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            tarjetaSeccion(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  encabezadoSeccion(
                    numero: '3',
                    titulo: 'Destino y transporte',
                    subtitulo: 'Elige tu aventura',
                    icono: Icons.explore_outlined,
                    color: const Color(0xFFE76F51),
                  ),
                  const Divider(height: 28),
                  const Text(
                    'Selecciona tu destino',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      tarjetaDestino(
                        titulo: 'Playa',
                        icono: Icons.beach_access,
                        color: const Color(0xFF2A9D8F),
                        seleccionado: destinoSeleccionado == 'Playa',
                        onTap: () => seleccionarDestino('Playa'),
                      ),
                      tarjetaDestino(
                        titulo: 'Ciudad',
                        icono: Icons.location_city,
                        color: const Color(0xFFE76F51),
                        seleccionado: destinoSeleccionado == 'Ciudad',
                        onTap: () => seleccionarDestino('Ciudad'),
                      ),
                      tarjetaDestino(
                        titulo: 'Montaña',
                        icono: Icons.landscape,
                        color: const Color(0xFF7A9E3A),
                        seleccionado: destinoSeleccionado == 'Montaña',
                        onTap: () => seleccionarDestino('Montaña'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Transporte',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: transporteSeleccionado,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.directions_transit,
                        color: Color(0xFFE76F51),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Avión',
                        child: Text('Avión'),
                      ),
                      DropdownMenuItem(
                        value: 'Autobús',
                        child: Text('Autobús'),
                      ),
                      DropdownMenuItem(
                        value: 'Tren',
                        child: Text('Tren'),
                      ),
                      DropdownMenuItem(
                        value: 'Barco',
                        child: Text('Barco'),
                      ),
                    ],
                    onChanged: (String? nuevoValor) {
                      if (nuevoValor != null) {
                        setState(() {
                          transporteSeleccionado = nuevoValor;
                        });
                        mostrarSnackBar(
                          'Transporte seleccionado: $nuevoValor',
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            tarjetaSeccion(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  encabezadoSeccion(
                    numero: '4',
                    titulo: 'Extras y preferencias',
                    subtitulo: 'Personaliza tu experiencia',
                    icono: Icons.tune,
                    color: const Color(0xFF7B61A8),
                  ),
                  const Divider(height: 28),
                  tarjetaExtra(
                    titulo: 'Hotel incluido',
                    precio: '+ \$1200',
                    icono: Icons.hotel,
                    color: const Color(0xFF9B72CF),
                    seleccionado: hotelSeleccionado,
                    onChanged: (valor) {
                      setState(() {
                        hotelSeleccionado = valor ?? false;
                      });
                      mostrarSnackBar(
                        hotelSeleccionado
                            ? 'Hotel incluido'
                            : 'Hotel eliminado',
                      );
                    },
                  ),
                  tarjetaExtra(
                    titulo: 'Tour guiado',
                    precio: '+ \$600',
                    icono: Icons.tour,
                    color: const Color(0xFFF4A261),
                    seleccionado: tourSeleccionado,
                    onChanged: (valor) {
                      setState(() {
                        tourSeleccionado = valor ?? false;
                      });
                      mostrarSnackBar(
                        tourSeleccionado
                            ? 'Tour guiado incluido'
                            : 'Tour guiado eliminado',
                      );
                    },
                  ),
                  tarjetaExtra(
                    titulo: 'Seguro de viaje',
                    precio: '+ \$400',
                    icono: Icons.health_and_safety,
                    color: const Color(0xFFC06C84),
                    seleccionado: seguroSeleccionado,
                    onChanged: (valor) {
                      setState(() {
                        seguroSeleccionado = valor ?? false;
                      });
                      mostrarSnackBar(
                        seguroSeleccionado
                            ? 'Seguro de viaje incluido'
                            : 'Seguro de viaje eliminado',
                      );
                    },
                  ),
                  const SizedBox(height: 4),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    decoration: BoxDecoration(
                      color: notificaciones
                          ? const Color(0xFFF3E8F8)
                          : const Color(0xFFF8F3EE),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: SwitchListTile(
                      value: notificaciones,
                      title: const Text(
                        'Recibir notificaciones',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        notificaciones
                            ? 'Activadas'
                            : 'Desactivadas',
                        style: TextStyle(
                          color: notificaciones
                              ? const Color(0xFF7B61A8)
                              : Colors.grey.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      secondary: Icon(
                        notificaciones
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: const Color(0xFF7B61A8),
                      ),
                      activeColor: const Color(0xFF7B61A8),
                      onChanged: (bool valor) {
                        setState(() {
                          notificaciones = valor;
                        });
                        mostrarSnackBar(
                          notificaciones
                              ? 'Notificaciones activadas'
                              : 'Notificaciones desactivadas',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFF1EAF7),
                          Color(0xFFE8F4F1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Presupuesto:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7B61A8),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '\$${presupuesto.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Slider(
                          value: presupuesto,
                          min: 500,
                          max: 10000,
                          divisions: 20,
                          label: '\$${presupuesto.toStringAsFixed(0)}',
                          activeColor: const Color(0xFF7B61A8),
                          onChanged: (double valor) {
                            setState(() {
                              presupuesto = valor;
                            });
                          },
                        ),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('\$500'),
                            Text('\$10,000'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: seleccionarFecha,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7F0),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFFE4D5E9),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1E3D8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.calendar_month,
                              color: Color(0xFF7B61A8),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha del viaje',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  fechaSeleccionada == null
                                      ? 'Toca para elegir fecha'
                                      : obtenerFechaTexto(),
                                  style: TextStyle(
                                    color: fechaSeleccionada == null
                                        ? Colors.grey.shade600
                                        : const Color(0xFF7B61A8),
                                    fontWeight: fechaSeleccionada == null
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 18,
                            color: Color(0xFF7B61A8),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            tarjetaSeccion(
              color: const Color(0xFFF6F0E9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  encabezadoSeccion(
                    numero: '5',
                    titulo: 'Confirmar',
                    subtitulo: 'Revisa tus datos antes de despegar',
                    icono: Icons.check_circle_outline,
                    color: const Color(0xFF4B3F72),
                  ),
                  const Divider(height: 28),
                  const Text(
                    'Tu reserva está casi lista. Revisa el resumen o confirma para generar tu boleto.',
                    style: TextStyle(
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: mostrarResumen,
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Ver Resumen'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: confirmarReserva,
                          icon: const Icon(Icons.flight_takeoff),
                          label: const Text('Confirmar'),
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

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    super.dispose();
  }
}

class PantallaBoleto extends StatelessWidget {
  final String nombre;
  final String correo;
  final String destino;
  final String transporte;
  final List<String> extras;
  final bool notificaciones;
  final double precioTotal;
  final String fecha;

  const PantallaBoleto({
    super.key,
    required this.nombre,
    required this.correo,
    required this.destino,
    required this.transporte,
    required this.extras,
    required this.notificaciones,
    required this.precioTotal,
    required this.fecha,
  });

  Widget datoBoleto({
    required IconData icono,
    required String titulo,
    required String valor,
    Color color = const Color(0xFF4B3F72),
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAF5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icono,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mi Boleto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(
                      22,
                      24,
                      22,
                      22,
                    ),
                    decoration: const BoxDecoration(
                      color: Color(0xFF4B3F72),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(26),
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.confirmation_number_outlined,
                          color: Colors.white,
                          size: 55,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'MI BOLETO DE VIAJE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Reserva confirmada',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        datoBoleto(
                          icono: Icons.person,
                          titulo: 'Viajero',
                          valor: nombre,
                        ),
                        datoBoleto(
                          icono: Icons.email,
                          titulo: 'Correo',
                          valor: correo,
                          color: const Color(0xFF7A9E3A),
                        ),
                        datoBoleto(
                          icono: Icons.location_on,
                          titulo: 'Destino',
                          valor: destino,
                          color: const Color(0xFFE76F51),
                        ),
                        datoBoleto(
                          icono: Icons.directions_transit,
                          titulo: 'Medio de transporte',
                          valor: transporte,
                          color: const Color(0xFF2A9D8F),
                        ),
                        datoBoleto(
                          icono: Icons.calendar_month,
                          titulo: 'Fecha del viaje',
                          valor: fecha,
                          color: const Color(0xFF7B61A8),
                        ),
                        datoBoleto(
                          icono: Icons.star,
                          titulo: 'Extras seleccionados',
                          valor: extras.isEmpty
                              ? 'No seleccionaste extras'
                              : extras.join('\n'),
                          color: const Color(0xFFF4A261),
                        ),
                        datoBoleto(
                          icono: Icons.notifications,
                          titulo: 'Notificaciones',
                          valor: notificaciones
                              ? 'Activadas'
                              : 'Desactivadas',
                          color: const Color(0xFF7B61A8),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                            horizontal: 20,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4EEF9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                'PRECIO TOTAL',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF5C536D),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '\$${precioTotal.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF4B3F72),
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Regresar a editar el boleto'),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
