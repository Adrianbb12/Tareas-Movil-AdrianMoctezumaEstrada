import 'package:flutter/material.dart';

import '../models/producto.dart';

class CarritoScreen extends StatefulWidget {
  final List<Producto> carrito;

  const CarritoScreen({
    super.key,
    required this.carrito,
  });

  @override
  State<CarritoScreen> createState() =>
      _CarritoScreenState();
}

class _CarritoScreenState
    extends State<CarritoScreen> {
  late List<Producto> carrito;

  @override
  void initState() {
    super.initState();

    carrito = List<Producto>.from(
      widget.carrito,
    );
  }

  double get total {
    return carrito.fold(
      0,
      (suma, producto) =>
          suma + producto.precio,
    );
  }

  void eliminarProducto(int index) {
    setState(() {
      carrito.removeAt(index);
    });
  }

  void pagar() {
    if (carrito.isEmpty) {
      mostrarMensaje(
        'Carrito vacío',
        'Agrega algún producto antes de pagar.',
      );
      return;
    }

    mostrarMensaje(
      'Pedido',
      'El sistema de pago se agregará próximamente.',
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
          'Mi carrito 🛒',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: carrito.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  const Text(
                    '🍕',
                    style: TextStyle(
                      fontSize: 80,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Tu carrito está vacío',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2C20),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Agrega algo delicioso.',
                    style: TextStyle(
                      color: Color(0xFF8A6655),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(18),
              itemCount: carrito.length,
              itemBuilder: (context, index) {
                final producto = carrito[index];

                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 15,
                  ),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.07),
                        blurRadius: 7,
                        offset:
                            const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFFFFE4C4,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            18,
                          ),
                        ),
                        alignment:
                            Alignment.center,
                        child: Text(
                          producto.imagen,
                          style:
                              const TextStyle(
                            fontSize: 38,
                          ),
                        ),
                      ),

                      const SizedBox(width: 15),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              producto.nombre,
                              style:
                                  const TextStyle(
                                fontSize: 17,
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
                              height: 5,
                            ),

                            Text(
                              '\$${producto.precio.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(
                                color:
                                    Color(
                                  0xFFE85D4A,
                                ),
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          eliminarProducto(
                            index,
                          );
                        },
                        icon: const Icon(
                          Icons.delete_outline,
                          color:
                              Color(0xFFE85D4A),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

      bottomNavigationBar: carrito.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color:
                                  Color(
                                0xFF8A6655,
                              ),
                            ),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style:
                                const TextStyle(
                              fontSize: 24,
                              fontWeight:
                                  FontWeight
                                      .bold,
                              color:
                                  Color(
                                0xFF4A2C20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: pagar,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFF47745,
                          ),
                          foregroundColor:
                              Colors.white,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              25,
                            ),
                          ),
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal: 30,
                          ),
                        ),
                        child: const Text(
                          'Pagar',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}