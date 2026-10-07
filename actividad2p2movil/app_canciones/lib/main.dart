import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://bwtcvgjfqxlpmrwqkduz.supabase.co',
    publishableKey: 'sb_publishable_YwKS4qROOE7tZDDNht2bPQ_HCjfn0am',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mis canciones',
      theme: ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF100D0B),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFFFF8A3D),
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF100D0B),
    foregroundColor: Colors.white,
  ),
),
      home: const MyHomePage(title: 'Mis canciones'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> _canciones = [];
  bool _cargando = true;
  bool _soloFavoritas = false;
  String _busqueda = '';
  String _orden = 'titulo';

  @override
  void initState() {
    super.initState();
    _cargarCanciones();
  }

  Future<void> _cargarCanciones() async {
    setState(() => _cargando = true);

    try {
      final datos = await supabase.from('canciones').select();

      if (!mounted) return;

      setState(() {
        _canciones = List<Map<String, dynamic>>.from(datos);
        _cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() => _cargando = false);
      _mostrarMensaje('Error al cargar canciones: $error');
    }
  }

  List<Map<String, dynamic>> get _cancionesVisibles {
    final consulta = _busqueda.trim().toLowerCase();

    final resultado = _canciones.where((cancion) {
      final coincideBusqueda = consulta.isEmpty ||
          [
            cancion['titulo'],
            cancion['artista'],
            cancion['album'],
          ].any(
            (valor) => (valor ?? '').toString().toLowerCase().contains(consulta),
          );

      final esFavorita = cancion['favorita'] == true;

      return coincideBusqueda && (!_soloFavoritas || esFavorita);
    }).toList();

    resultado.sort((a, b) {
      if (_orden == 'created_at') {
        final fechaA = DateTime.tryParse(a['created_at']?.toString() ?? '');
        final fechaB = DateTime.tryParse(b['created_at']?.toString() ?? '');

        if (fechaA == null) return 1;
        if (fechaB == null) return -1;
        return fechaB.compareTo(fechaA);
      }

      if (_orden == 'anio') {
        final anioA = int.tryParse(a['anio']?.toString() ?? '') ?? 0;
        final anioB = int.tryParse(b['anio']?.toString() ?? '') ?? 0;
        return anioA.compareTo(anioB);
      }

      final valorA = (a[_orden] ?? '').toString().toLowerCase();
      final valorB = (b[_orden] ?? '').toString().toLowerCase();
      return valorA.compareTo(valorB);
    });

    return resultado;
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  Future<void> _agregarCancion() async {
    final tituloController = TextEditingController();
    final artistaController = TextEditingController();
    final albumController = TextEditingController();
    final anioController = TextEditingController();
    final duracionController = TextEditingController();

    final datos = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar canción'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tituloController,
                decoration: const InputDecoration(labelText: 'Título *'),
              ),
              TextField(
                controller: artistaController,
                decoration: const InputDecoration(labelText: 'Artista *'),
              ),
              TextField(
                controller: albumController,
                decoration: const InputDecoration(labelText: 'Álbum'),
              ),
              TextField(
                controller: anioController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Año'),
              ),
              TextField(
                controller: duracionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duración en segundos',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final titulo = tituloController.text.trim();
              final artista = artistaController.text.trim();

              if (titulo.isEmpty || artista.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Título y artista son obligatorios.'),
                  ),
                );
                return;
              }

              final anioTexto = anioController.text.trim();
              final duracionTexto = duracionController.text.trim();
              final anio = int.tryParse(anioTexto);
              final duracion = int.tryParse(duracionTexto);

              if ((anioTexto.isNotEmpty && anio == null) ||
                  (duracionTexto.isNotEmpty && duracion == null)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Año y duración deben ser números.'),
                  ),
                );
                return;
              }

              Navigator.pop(context, {
                'titulo': titulo,
                'artista': artista,
                'album': albumController.text.trim().isEmpty
                    ? null
                    : albumController.text.trim(),
                'anio': anio,
                'duracion_seg': duracion,
                'favorita': false,
              });
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    tituloController.dispose();
    artistaController.dispose();
    albumController.dispose();
    anioController.dispose();
    duracionController.dispose();

    if (datos == null) return;

    try {
      await supabase.from('canciones').insert(datos);
      await _cargarCanciones();

      if (mounted) _mostrarMensaje('Canción agregada.');
    } catch (error) {
      if (mounted) _mostrarMensaje('Error al agregar canción: $error');
    }
  }

  Future<void> _eliminarCancion(Map<String, dynamic> cancion) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text('¿Quieres eliminar "${cancion['titulo']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await supabase
          .from('canciones')
          .delete()
          .eq('id', cancion['id']);

      await _cargarCanciones();

      if (mounted) _mostrarMensaje('Canción eliminada.');
    } catch (error) {
      if (mounted) _mostrarMensaje('Error al eliminar canción: $error');
    }
  }

  String _duracion(dynamic valor) {
    final segundos = int.tryParse(valor?.toString() ?? '');
    if (segundos == null) return '';

    final minutos = segundos ~/ 60;
    final resto = segundos % 60;
    return '$minutos:${resto.toString().padLeft(2, '0')}';
  }

Widget _tarjetaCancion(Map<String, dynamic> cancion, int indice) {
  final colores = [
    const Color(0xFF593523),
    const Color(0xFF5A3A2A),
    const Color(0xFF44332D),
    const Color(0xFF50372D),
  ];

  final colorPortada = colores[indice % colores.length];
  final duracion = _duracion(cancion['duracion_seg']);
  final album = cancion['album']?.toString();

  final detalles = [
    if (album != null && album.isNotEmpty) album,
    if (cancion['anio'] != null) cancion['anio'].toString(),
    if (duracion.isNotEmpty) duracion,
  ].join(' · ');

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF1C1714),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withOpacity(0.06)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: colorPortada,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              cancion['favorita'] == true
                  ? Icons.favorite_rounded
                  : Icons.music_note_rounded,
              color: const Color(0xFFC5F36A),
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cancion['titulo']?.toString() ?? 'Sin título',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  cancion['artista']?.toString() ?? 'Artista desconocido',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB4BDB3),
                    fontSize: 13,
                  ),
                ),
                if (detalles.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    detalles,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF818B81),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Eliminar canción',
            onPressed: () => _eliminarCancion(cancion),
            icon: const Icon(Icons.delete_outline_rounded),
            color: const Color(0xFFADB5AA),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final canciones = _cancionesVisibles;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            tooltip: 'Actualizar lista',
            onPressed: _cargarCanciones,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar canción, artista o álbum',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (texto) {
                setState(() => _busqueda = texto);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _orden,
                    items: const [
                      DropdownMenuItem(
                        value: 'titulo',
                        child: Text('Título (A–Z)'),
                      ),
                      DropdownMenuItem(
                        value: 'artista',
                        child: Text('Artista (A–Z)'),
                      ),
                      DropdownMenuItem(
                        value: 'album',
                        child: Text('Álbum (A–Z)'),
                      ),
                      DropdownMenuItem(
                        value: 'anio',
                        child: Text('Año'),
                      ),
                      DropdownMenuItem(
                        value: 'created_at',
                        child: Text('Más recientes'),
                      ),
                    ],
                    onChanged: (valor) {
                      if (valor != null) {
                        setState(() => _orden = valor);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('Favoritas'),
                  selected: _soloFavoritas,
                  onSelected: (valor) {
                    setState(() => _soloFavoritas = valor);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _cargando
                ? const Center(child: CircularProgressIndicator())
                : canciones.isEmpty
                    ? const Center(
                        child: Text('No se encontraron canciones.'),
                      )
                    : ListView.builder(
                        itemCount: canciones.length,
                        itemBuilder: (context, indice) {
                          final cancion = canciones[indice];
                          final album = cancion['album']?.toString();
                          final anio = cancion['anio']?.toString();
                          final duracion = _duracion(cancion['duracion_seg']);

                          final detalles = [
                            if (album != null && album.isNotEmpty) album,
                            if (anio != null && anio.isNotEmpty) anio,
                            if (duracion.isNotEmpty) duracion,
                          ].join(' • ');

                          return ListTile(
                            leading: Icon(
                              cancion['favorita'] == true
                                  ? Icons.favorite
                                  : Icons.music_note,
                              color: cancion['favorita'] == true
                                  ? Colors.red
                                  : null,
                            ),
                            title: Text(cancion['titulo']?.toString() ?? ''),
                            subtitle: Text(
                              detalles.isEmpty
                                  ? cancion['artista']?.toString() ?? ''
                                  : '${cancion['artista'] ?? ''} • $detalles',
                            ),
                            trailing: IconButton(
                              tooltip: 'Eliminar',
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _eliminarCancion(cancion),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _agregarCancion,
        tooltip: 'Agregar canción',
        child: const Icon(Icons.add),
      ),
    );
  }
}