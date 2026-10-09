import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorite_place.dart';
import '../services/place_repository.dart';
import '../widgets/places_map.dart';

const categories = ['Comida', 'Estudio', 'Diversión', 'Compras', 'Paseo', 'Personal', 'Otro'];

class PlaceFormScreen extends StatefulWidget {
  const PlaceFormScreen({super.key, this.place});
  final FavoritePlace? place;
  @override
  State<PlaceFormScreen> createState() => _PlaceFormScreenState();
}

class _PlaceFormScreenState extends State<PlaceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _picker = ImagePicker();
  String _category = categories.first;
  LatLng? _point;
  XFile? _photo;
  Uint8List? _photoBytes;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final p = widget.place;
    if (p != null) {
      _name.text = p.name; _description.text = p.description; _category = p.category;
      _point = LatLng(p.latitude, p.longitude);
    }
  }

  Future<void> _pickPhoto() async {
    final file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 85, maxWidth: 1800);
    if (file == null) return;
    final bytes = await file.readAsBytes();
    if (mounted) setState(() { _photo = file; _photoBytes = bytes; });
  }

  Future<void> _selectPoint() async {
    final point = await Navigator.of(context).push<LatLng>(MaterialPageRoute(
      builder: (_) => MapPickerScreen(initial: _point)));
    if (point != null) setState(() => _point = point);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_point == null) { setState(() => _error = 'Toca el mapa y marca la ubicación exacta.'); return; }
    setState(() { _busy = true; _error = null; });
    try {
      final repo = PlaceRepository(Supabase.instance.client);
      String? photoPath = widget.place?.photoPath;
      Uint8List? bytes = _photoBytes;
      String fileName = _photo?.name ?? '';
      if (bytes == null && _photo == null && widget.place == null && _name.text.trim().toLowerCase() == 'juan gallo') {
        final data = await rootBundle.load('assets/juan_gallo.png');
        bytes = data.buffer.asUint8List(); fileName = 'juan_gallo.png';
      }
      if (bytes != null) photoPath = await repo.uploadPhoto(bytes, fileName);
      await repo.save(id: widget.place?.id, name: _name.text, category: _category,
        description: _description.text, latitude: _point!.latitude, longitude: _point!.longitude,
        photoPath: photoPath);
      if (mounted) Navigator.of(context).pop(true);
    } on StorageException catch (e) {
      setState(() => _error = 'No se pudo guardar la foto: ${e.message}');
    } on PostgrestException catch (e) {
      setState(() => _error = 'No se pudo guardar el lugar: ${e.message}');
    } catch (_) {
      setState(() => _error = 'Ocurrió un error. Revisa tu conexión e inténtalo otra vez.');
    } finally { if (mounted) setState(() => _busy = false); }
  }

  @override
  void dispose() { _name.dispose(); _description.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final oldPhoto = widget.place?.photoPath;
    return Scaffold(
      appBar: AppBar(title: Text(widget.place == null ? 'Agregar lugar' : 'Editar lugar')),
      body: SafeArea(child: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
        GestureDetector(onTap: _pickPhoto, child: Container(height: 190,
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(18)),
          clipBehavior: Clip.antiAlias,
          child: _photoBytes != null ? Image.memory(_photoBytes!, fit: BoxFit.cover)
            : _photo != null ? const Center(child: CircularProgressIndicator())
            : oldPhoto != null ? _StoredPhoto(path: oldPhoto)
            : widget.place == null && _name.text.trim().toLowerCase() == 'juan gallo'
              ? Image.asset('assets/juan_gallo.png', fit: BoxFit.cover)
              : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_outlined, size: 34), SizedBox(height: 8), Text('Agregar foto del lugar')]),
        )),
        const SizedBox(height: 18),
        TextFormField(controller: _name, textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Nombre del lugar', prefixIcon: Icon(Icons.place_outlined)),
          onChanged: (_) => setState(() {}), validator: (v) => v == null || v.trim().isEmpty ? 'Escribe un nombre' : null),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(initialValue: _category, decoration: const InputDecoration(labelText: 'Categoría', prefixIcon: Icon(Icons.category_outlined)),
          items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
          onChanged: (value) { if (value != null) setState(() => _category = value); }),
        const SizedBox(height: 14),
        TextFormField(controller: _description, minLines: 2, maxLines: 4,
          decoration: const InputDecoration(labelText: '¿Por qué te gusta?', alignLabelWithHint: true, prefixIcon: Icon(Icons.favorite_border)),),
        const SizedBox(height: 18),
        OutlinedButton.icon(onPressed: _selectPoint,
          icon: const Icon(Icons.map_outlined), label: Text(_point == null ? 'Marcar ubicación exacta en el mapa' : 'Cambiar ubicación del mapa')),
        if (_point != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(
          '${_point!.latitude.toStringAsFixed(6)}, ${_point!.longitude.toStringAsFixed(6)}',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant))),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 20),
        FilledButton.icon(onPressed: _busy ? null : _save,
          icon: _busy ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
          label: Text(_busy ? 'Guardando…' : 'Guardar lugar')),
      ]))),
    );
  }
}

class _StoredPhoto extends StatelessWidget {
  const _StoredPhoto({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: PlaceRepository(Supabase.instance.client).signedPhotoUrl(path),
    builder: (context, snapshot) => snapshot.data == null
      ? const Center(child: Icon(Icons.photo_outlined, size: 42))
      : Image.network(snapshot.data!, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.broken_image_outlined, size: 42))),
  );
}

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key, this.initial});
  final LatLng? initial;
  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? _point;
  @override
  void initState() { super.initState(); _point = widget.initial; }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Elige el punto exacto')),
    body: Stack(children: [
      PlacesMap(places: const [], selected: _point, onMapTap: (point) => setState(() => _point = point)),
      Positioned(top: 14, left: 14, right: 14, child: Card(child: Padding(padding: const EdgeInsets.all(14), child:
        const Text('Acerca el mapa y toca el punto donde está el lugar.', textAlign: TextAlign.center)))),
      Positioned(left: 16, right: 16, bottom: 20, child: FilledButton.icon(
        onPressed: _point == null ? null : () => Navigator.of(context).pop(_point),
        icon: const Icon(Icons.check), label: const Padding(padding: EdgeInsets.all(13), child: Text('Usar esta ubicación')))),
    ]),
  );
}
