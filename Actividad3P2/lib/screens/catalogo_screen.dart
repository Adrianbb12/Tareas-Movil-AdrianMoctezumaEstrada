import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/producto.dart';
import '../widgets/producto_card.dart';
import '../widgets/categoria_card.dart';
import 'carrito_screen.dart';
import 'sucursales_screen.dart';
import 'admin_screen.dart';
import 'login_screen.dart';

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final List<Producto> carrito = [];

  List<Producto> productos = [];

  String categoriaSeleccionada = 'Todos';

  bool cargando = true;
  bool esAdministrador = false;

  final List<Map<String, String>> categorias = [
    {
      'nombre': 'Todos',
      'emoji': '🍕',
    },
    {
      'nombre': 'Pizzas',
      'emoji': '🍕',
    },
    {
      'nombre': 'Acompañamientos',
      'emoji': '🍗',
    },
    {
      'nombre': 'Postres',
      'emoji': '🍫',
    },
    {
      'nombre': 'Bebidas',
      'emoji': '🥤',
    },
    {
      'nombre': 'Dips y salsas',
      'emoji': '🥫',
    },
  ];

  @override
  void initState() {
    super.initState();
    cargarProductos();
    comprobarAdministrador();
  }

  Future<void> cargarProductos() async {
    try {
      final respuesta = await Supabase.instance.client
          .from('productos')
          .select()
          .eq('disponible', true)
          .order('id');

      final lista = (respuesta as List)
          .map(
            (producto) =>
                Producto.fromMap(producto),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        productos = lista;
        cargando = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      mostrarMensaje(
        'Error',
        'No se pudieron cargar los productos.',
      );
    }
  }

  Future<void> comprobarAdministrador() async {
    final usuario = Supabase.instance.client.auth.currentUser;

    if (usuario == null) {
      return;
    }

    try {
      final respuesta = await Supabase.instance.client
          .from('perfiles')
          .select('rol')
          .eq('id', usuario.id)
          .maybeSingle();

      if (!mounted) return;

      setState(() {
        esAdministrador =
            respuesta?['rol'] == 'administrador';
      });
    } catch (error) {
      setState(() {
        esAdministrador = false;
      });
    }
  }

  List<Producto> get productosFiltrados {
    if (categoriaSeleccionada == 'Todos') {
      return productos;
    }

    return productos
        .where(
          (producto) =>
              producto.categoria ==
              categoriaSeleccionada,
        )
        .toList();
  }

  void agregarAlCarrito(Producto producto) {
    setState(() {
      carrito.add(producto);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${producto.nombre} agregado al carrito',
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFF47745),
      ),
    );
  }

  void abrirCarrito() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarritoScreen(
          carrito: carrito,
        ),
      ),
    );
  }

  void abrirSucursales() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SucursalesScreen(),
      ),
    );
  }

  void abrirAdmin() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminScreen(),
      ),
    );
  }

  Future<void> cerrarSesion() async {
    await Supabase.instance.client.auth.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void mostrarMensaje(
    String titulo,
    String mensaje,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF1DC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF47745),
        foregroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Pizzalicious 🍕',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: abrirSucursales,
            icon: const Icon(
              Icons.location_on_outlined,
            ),
          ),

          if (esAdministrador)
            IconButton(
              onPressed: abrirAdmin,
              icon: const Icon(
                Icons.settings_outlined,
              ),
            ),

          Stack(
            children: [
              IconButton(
                onPressed: abrirCarrito,
                icon: const Icon(
                  Icons.shopping_cart_outlined,
                ),
              ),

              if (carrito.isNotEmpty)
                Positioned(
                  right: 5,
                  top: 5,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE85D4A),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${carrito.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          PopupMenuButton<String>(
            onSelected: (valor) {
              if (valor == 'cerrar') {
                cerrarSesion();
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem(
                  value: 'cerrar',
                  child: Text('Cerrar sesión'),
                ),
              ];
            },
          ),
        ],
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF47745),
              ),
            )
          : RefreshIndicator(
              onRefresh: cargarProductos,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    '¿Qué se te antoja? 🍕',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C20),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    'Elige algo delicioso para disfrutar.',
                    style: TextStyle(
                      color: Color(0xFF8A6655),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 58,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: categorias.length,
                      itemBuilder: (context, index) {
                        final categoria =
                            categorias[index];

                        return CategoriaCard(
                          nombre:
                              categoria['nombre']!,
                          emoji:
                              categoria['emoji']!,
                          seleccionada:
                              categoria['nombre'] ==
                                  categoriaSeleccionada,
                          onTap: () {
                            setState(() {
                              categoriaSeleccionada =
                                  categoria['nombre']!;
                            });
                          },
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (productosFiltrados.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 50,
                      ),
                      child: Center(
                        child: Text(
                          'No hay productos disponibles.',
                          style: TextStyle(
                            color: Color(0xFF8A6655),
                          ),
                        ),
                      ),
                    ),

                  ...productosFiltrados.map(
                    (producto) {
                      return ProductoCard(
                        producto: producto,
                        onAgregar: () {
                          agregarAlCarrito(
                            producto,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}