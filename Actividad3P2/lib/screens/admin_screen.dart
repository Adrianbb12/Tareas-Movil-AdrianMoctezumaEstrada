import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/sucursal.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() =>
      _AdminScreenState();
}

class _AdminScreenState
    extends State<AdminScreen> {
  List<Sucursal> sucursales = [];

  bool cargando = true;

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
          .order('id');

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

  Future<void> mostrarFormulario({
    Sucursal? sucursal,
  }) async {
    final nombreController =
        TextEditingController(
      text: sucursal?.nombre ?? '',
    );

    final direccionController =
        TextEditingController(
      text: sucursal?.direccion ?? '',
    );

    final telefonoController =
        TextEditingController(
      text: sucursal?.telefono ?? '',
    );

    final latitudController =
        TextEditingController(
      text: sucursal?.latitud.toString() ?? '',
    );

    final longitudController =
        TextEditingController(
      text: sucursal?.longitud.toString() ?? '',
    );

    bool activa =
        sucursal?.activa ?? true;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder:
              (context, setDialogState) {
            return AlertDialog(
              title: Text(
                sucursal == null
                    ? 'Nueva sucursal'
                    : 'Editar sucursal',
              ),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          nombreController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Nombre',
                      ),
                    ),

                    TextField(
                      controller:
                          direccionController,
                      decoration:
                          const InputDecoration(
                        labelText: 'Dirección',
                      ),
                    ),

                    TextField(
                      controller:
                          telefonoController,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          const InputDecoration(
                        labelText: 'Teléfono',
                      ),
                    ),

                    TextField(
                      controller:
                          latitudController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Latitud',
                      ),
                    ),

                    TextField(
                      controller:
                          longitudController,
                      keyboardType:
                          const TextInputType
                              .numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      decoration:
                          const InputDecoration(
                        labelText: 'Longitud',
                      ),
                    ),

                    const SizedBox(height: 10),

                    SwitchListTile(
                      title:
                          const Text('Sucursal activa'),
                      value: activa,
                      onChanged: (valor) {
                        setDialogState(() {
                          activa = valor;
                        });
                      },
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('Cancelar'),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final nombre =
                        nombreController
                            .text
                            .trim();

                    final direccion =
                        direccionController
                            .text
                            .trim();

                    final telefono =
                        telefonoController
                            .text
                            .trim();

                    final latitud =
                        double.tryParse(
                      latitudController
                          .text
                          .trim(),
                    );

                    final longitud =
                        double.tryParse(
                      longitudController
                          .text
                          .trim(),
                    );

                    if (nombre.isEmpty ||
                        direccion.isEmpty ||
                        latitud == null ||
                        longitud == null) {
                      mostrarMensaje(
                        'Datos incompletos',
                        'Ingresa nombre, dirección, latitud y longitud.',
                      );
                      return;
                    }

                    try {
                      if (sucursal == null) {
                        await Supabase
                            .instance.client
                            .from('sucursales')
                            .insert({
                          'nombre': nombre,
                          'direccion':
                              direccion,
                          'telefono':
                              telefono.isEmpty
                                  ? null
                                  : telefono,
                          'latitud':
                              latitud,
                          'longitud':
                              longitud,
                          'activa': activa,
                        });
                      } else {
                        await Supabase
                            .instance.client
                            .from('sucursales')
                            .update({
                          'nombre': nombre,
                          'direccion':
                              direccion,
                          'telefono':
                              telefono.isEmpty
                                  ? null
                                  : telefono,
                          'latitud':
                              latitud,
                          'longitud':
                              longitud,
                          'activa': activa,
                        }).eq(
                          'id',
                          sucursal.id,
                        );
                      }

                      if (!mounted) return;

                      Navigator.pop(
                        dialogContext,
                      );

                      await cargarSucursales();

                      mostrarMensaje(
                        'Listo',
                        sucursal == null
                            ? 'Sucursal agregada correctamente.'
                            : 'Sucursal actualizada correctamente.',
                      );
                    } catch (error) {
                      mostrarMensaje(
                        'Error',
                        'No se pudo guardar la sucursal.',
                      );
                    }
                  },
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(
                      0xFFF47745,
                    ),
                    foregroundColor:
                        Colors.white,
                  ),
                  child:
                      const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );

    nombreController.dispose();
    direccionController.dispose();
    telefonoController.dispose();
    latitudController.dispose();
    longitudController.dispose();
  }

  Future<void> eliminarSucursal(
    Sucursal sucursal,
  ) async {
    final confirmar =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
              const Text('Eliminar sucursal'),
          content: Text(
            '¿Deseas eliminar ${sucursal.nombre}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFFE85D4A,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Eliminar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) {
      return;
    }

    try {
      await Supabase.instance.client
          .from('sucursales')
          .delete()
          .eq('id', sucursal.id);

      await cargarSucursales();

      if (!mounted) return;

      mostrarMensaje(
        'Listo',
        'Sucursal eliminada correctamente.',
      );
    } catch (error) {
      if (!mounted) return;

      mostrarMensaje(
        'Error',
        'No se pudo eliminar la sucursal.',
      );
    }
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
      backgroundColor:
          const Color(0xFFFFF1DC),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFFF47745),
        foregroundColor: Colors.white,
        title: const Text(
          'Administrar sucursales',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: cargando
          ? const Center(
              child:
                  CircularProgressIndicator(
                color:
                    Color(0xFFF47745),
              ),
            )
          : RefreshIndicator(
              onRefresh:
                  cargarSucursales,
              child:
                  sucursales.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(
                              height: 250,
                            ),
                            Center(
                              child: Text(
                                'No hay sucursales.',
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding:
                              const EdgeInsets
                                  .all(15),
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
                                bottom: 15,
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
                                  20,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors
                                        .black
                                        .withOpacity(
                                      0.07,
                                    ),
                                    blurRadius:
                                        7,
                                    offset:
                                        const Offset(
                                      0,
                                      3,
                                    ),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons
                                            .local_pizza,
                                        color:
                                            Color(
                                          0xFFF47745,
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 10,
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          sucursal
                                              .nombre,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                18,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            color:
                                                Color(
                                              0xFF4A2C20,
                                            ),
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        onPressed:
                                            () {
                                          mostrarFormulario(
                                            sucursal:
                                                sucursal,
                                          );
                                        },
                                        icon:
                                            const Icon(
                                          Icons
                                              .edit_outlined,
                                          color:
                                              Color(
                                            0xFFF47745,
                                          ),
                                        ),
                                      ),

                                      IconButton(
                                        onPressed:
                                            () {
                                          eliminarSucursal(
                                            sucursal,
                                          );
                                        },
                                        icon:
                                            const Icon(
                                          Icons
                                              .delete_outline,
                                          color:
                                              Color(
                                            0xFFE85D4A,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Text(
                                    sucursal
                                        .direccion,
                                    style:
                                        const TextStyle(
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
                                      'Tel: ${sucursal.telefono}',
                                      style:
                                          const TextStyle(
                                        color:
                                            Color(
                                          0xFF8A6655,
                                        ),
                                      ),
                                    ),

                                  const SizedBox(
                                    height: 5,
                                  ),

                                  Text(
                                    'Lat: ${sucursal.latitud}',
                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                      color:
                                          Color(
                                        0xFF8A6655,
                                      ),
                                    ),
                                  ),

                                  Text(
                                    'Long: ${sucursal.longitud}',
                                    style:
                                        const TextStyle(
                                      fontSize: 12,
                                      color:
                                          Color(
                                        0xFF8A6655,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                    height: 8,
                                  ),

                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal:
                                          10,
                                      vertical:
                                          5,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      color: sucursal
                                              .activa
                                          ? Colors
                                              .green
                                              .withOpacity(
                                              0.12,
                                            )
                                          : Colors
                                              .red
                                              .withOpacity(
                                              0.12,
                                            ),
                                      borderRadius:
                                          BorderRadius
                                              .circular(
                                        15,
                                      ),
                                    ),
                                    child:
                                        Text(
                                      sucursal
                                              .activa
                                          ? 'Activa'
                                          : 'Inactiva',
                                      style:
                                          TextStyle(
                                        color: sucursal
                                                .activa
                                            ? Colors
                                                .green
                                            : Colors
                                                .red,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
            ),

      floatingActionButton:
          FloatingActionButton(
        onPressed: () {
          mostrarFormulario();
        },
        backgroundColor:
            const Color(0xFFF47745),
        foregroundColor:
            Colors.white,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}