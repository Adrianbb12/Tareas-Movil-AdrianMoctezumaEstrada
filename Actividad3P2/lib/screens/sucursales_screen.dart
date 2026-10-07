import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sucursal.dart';

class SucursalesScreen extends StatefulWidget {
  const SucursalesScreen({super.key});

  @override
  State<SucursalesScreen> createState() =>
      _SucursalesScreenState();
}

class _SucursalesScreenState
    extends State<SucursalesScreen> {
  final MapController mapController =
      MapController();

  final LatLng centroSanLuisPotosi =
      const LatLng(
    22.1528,
    -100.9769,
  );

  List<Sucursal> sucursales = [];

  LatLng? ubicacionUsuario;

  bool cargando = true;
  bool obteniendoUbicacion = false;

  @override
  void initState() {
    super.initState();
    cargarSucursales();
  }

  Future<void> cargarSucursales() async {
    try {
      final respuesta = await Supabase
          .instance.client
          .from('sucursales')
          .select()
          .eq('activa', true);

      final lista = (respuesta as List)
          .map(
            (sucursal) =>
                Sucursal.fromMap(
              sucursal,
            ),
          )
          .toList();

      if (!mounted) return;

      setState(() {
        sucursales = lista;
        cargando = false;
      });

      obtenerUbicacion();
    } catch (error) {
      if (!mounted) return;

      setState(() {
        cargando = false;
      });

      mostrarMensaje(
        'Error',
        'No se pudieron cargar las sucursales.',
      );
    }
  }

  Future<void> obtenerUbicacion() async {
    setState(() {
      obteniendoUbicacion = true;
    });

    try {
      bool servicioActivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        mostrarMensaje(
          'Ubicación desactivada',
          'Activa la ubicación de tu dispositivo.',
        );
        return;
      }

      LocationPermission permiso =
          await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso =
            await Geolocator.requestPermission();
      }

      if (permiso ==
              LocationPermission.denied ||
          permiso ==
              LocationPermission.deniedForever) {
        mostrarMensaje(
          'Permiso de ubicación',
          'No se concedió permiso para obtener tu ubicación.',
        );
        return;
      }

      final posicion =
          await Geolocator.getCurrentPosition();

      if (!mounted) return;

      setState(() {
        ubicacionUsuario = LatLng(
          posicion.latitude,
          posicion.longitude,
        );
      });

      ordenarSucursalesPorDistancia();
    } catch (error) {
      if (!mounted) return;

      mostrarMensaje(
        'Ubicación',
        'No fue posible obtener tu ubicación.',
      );
    } finally {
      if (mounted) {
        setState(() {
          obteniendoUbicacion = false;
        });
      }
    }
  }

  void ordenarSucursalesPorDistancia() {
    if (ubicacionUsuario == null) {
      return;
    }

    const distancia = Distance();

    sucursales.sort((a, b) {
      final distanciaA =
          distancia.as(
        LengthUnit.Meter,
        ubicacionUsuario!,
        LatLng(
          a.latitud,
          a.longitud,
        ),
      );

      final distanciaB =
          distancia.as(
        LengthUnit.Meter,
        ubicacionUsuario!,
        LatLng(
          b.latitud,
          b.longitud,
        ),
      );

      return distanciaA.compareTo(
        distanciaB,
      );
    });

    if (mounted) {
      setState(() {});
    }
  }

  String obtenerDistancia(
    Sucursal sucursal,
  ) {
    if (ubicacionUsuario == null) {
      return '';
    }

    const distancia = Distance();

    final metros = distancia.as(
      LengthUnit.Meter,
      ubicacionUsuario!,
      LatLng(
        sucursal.latitud,
        sucursal.longitud,
      ),
    );

    if (metros >= 1000) {
      return '${(metros / 1000).toStringAsFixed(1)} km';
    }

    return '${metros.round()} m';
  }

  void centrarEnUsuario() {
    if (ubicacionUsuario == null) {
      obtenerUbicacion();
      return;
    }

    mapController.move(
      ubicacionUsuario!,
      14,
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
        title: const Text(
          'Sucursales 📍',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFF47745),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: 320,
                  child: FlutterMap(
                    mapController:
                        mapController,
                    options: MapOptions(
                      initialCenter:
                          centroSanLuisPotosi,
                      initialZoom: 13,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.pizzalicious',
                      ),

                      MarkerLayer(
                        markers: [
                          ...sucursales.map(
                            (sucursal) {
                              return Marker(
                                point: LatLng(
                                  sucursal.latitud,
                                  sucursal.longitud,
                                ),
                                width: 50,
                                height: 50,
                                child: const Icon(
                                  Icons.location_on,
                                  color:
                                      Color(
                                    0xFFE53935,
                                  ),
                                  size: 42,
                                ),
                              );
                            },
                          ),

                          if (ubicacionUsuario !=
                              null)
                            Marker(
                              point:
                                  ubicacionUsuario!,
                              width: 50,
                              height: 50,
                              child:
                                  const Icon(
                                Icons.my_location,
                                color:
                                    Colors.blue,
                                size: 30,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding:
                      const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Sucursales cercanas',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(
                              0xFF4A2C20,
                            ),
                          ),
                        ),
                      ),

                      if (obteniendoUbicacion)
                        const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color:
                                Color(
                              0xFFF47745,
                            ),
                          ),
                        ),

                      IconButton(
                        onPressed:
                            centrarEnUsuario,
                        icon: const Icon(
                          Icons.my_location,
                          color:
                              Color(
                            0xFFF47745,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: sucursales.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay sucursales disponibles.',
                          ),
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 15,
                          ),
                          itemCount:
                              sucursales.length,
                          itemBuilder:
                              (context, index) {
                            final sucursal =
                                sucursales[
                                    index];

                            return Container(
                              margin:
                                  const EdgeInsets
                                      .only(
                                bottom: 12,
                              ),
                              padding:
                                  const EdgeInsets
                                      .all(15),
                              decoration:
                                  BoxDecoration(
                                color:
                                    Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  18,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withOpacity(
                                      0.06,
                                    ),
                                    blurRadius: 6,
                                    offset:
                                        const Offset(
                                      0,
                                      3,
                                    ),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration:
                                        BoxDecoration(
                                      color:
                                          const Color(
                                        0xFFFFE4C4,
                                      ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        15,
                                      ),
                                    ),
                                    child:
                                        const Icon(
                                      Icons
                                          .local_pizza,
                                      color:
                                          Color(
                                        0xFFF47745,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    width: 12,
                                  ),

                                  Expanded(
                                    child:
                                        Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          sucursal
                                              .nombre,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                17,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color:
                                                Color(
                                              0xFF4A2C20,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(
                                          height: 4,
                                        ),

                                        Text(
                                          sucursal
                                              .direccion,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                13,
                                            color:
                                                Color(
                                              0xFF8A6655,
                                            ),
                                          ),
                                        ),

                                        if (sucursal
                                                .telefono !=
                                            null &&
                                            sucursal
                                                .telefono!
                                                .isNotEmpty)
                                          Text(
                                            sucursal
                                                .telefono!,
                                            style:
                                                const TextStyle(
                                              fontSize:
                                                  12,
                                              color:
                                                  Color(
                                                0xFF8A6655,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                  if (obtenerDistancia(
                                          sucursal)
                                      .isNotEmpty)
                                    Text(
                                      obtenerDistancia(
                                        sucursal,
                                      ),
                                      style:
                                          const TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                        color:
                                            Color(
                                          0xFFE85D4A,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}