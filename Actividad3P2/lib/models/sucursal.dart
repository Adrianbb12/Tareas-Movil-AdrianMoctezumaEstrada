class Sucursal {
  final int id;
  final String nombre;
  final String direccion;
  final String? telefono;
  final double latitud;
  final double longitud;
  final bool activa;

  Sucursal({
    required this.id,
    required this.nombre,
    required this.direccion,
    this.telefono,
    required this.latitud,
    required this.longitud,
    required this.activa,
  });

  factory Sucursal.fromMap(Map<String, dynamic> map) {
    return Sucursal(
      id: map['id'],
      nombre: map['nombre'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'],
      latitud: (map['latitud'] as num).toDouble(),
      longitud: (map['longitud'] as num).toDouble(),
      activa: map['activa'] ?? true,
    );
  }
}