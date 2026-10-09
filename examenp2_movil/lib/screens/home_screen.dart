import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/favorite_place.dart';
import '../services/place_repository.dart';
import '../widgets/places_map.dart';
import 'place_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _query = '';
  String _category = 'Todas';
  LatLng? _myPosition;
  FavoritePlace? _selectedPlace;
  late Future<List<FavoritePlace>> _places;
  PlaceRepository get _repo => PlaceRepository(Supabase.instance.client);

  @override
  void initState() { super.initState(); _places = _repo.list(); }
  void _reload() => setState(() { _places = _repo.list(); });

  Future<void> _add() async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const PlaceFormScreen()));
    if (changed == true) _reload();
  }

  Future<void> _edit(FavoritePlace place) async {
    final changed = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => PlaceFormScreen(place: place)));
    if (changed == true) _reload();
  }

  Future<void> _delete(FavoritePlace place) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(
      title: const Text('Eliminar lugar'),
      content: Text('¿Quieres eliminar “${place.name}” de tus lugares favoritos?'),
      actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar'))],
    ));
    if (confirmed != true || !mounted) return;
    try { await _repo.delete(place); _reload(); }
    catch (_) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo eliminar. Revisa tu conexión.'))); }
  }

  Future<void> _locate() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activa la ubicación del dispositivo para mostrarte en el mapa.')));
        return;
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Permite el acceso a la ubicación para mostrar tu posición.')));
        return;
      }
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)));
      if (mounted) setState(() => _myPosition = LatLng(position.latitude, position.longitude));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo obtener la ubicación.')));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Mis lugares', style: TextStyle(fontWeight: FontWeight.w800)),
        Text(_tab == 0 ? '' : '', style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
      actions: [IconButton(tooltip: 'Cerrar sesión', onPressed: () => Supabase.instance.client.auth.signOut(), icon: const Icon(Icons.logout))],
    ),
    body: FutureBuilder<List<FavoritePlace>>(
      future: _places,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        if (snapshot.hasError) return _errorView();
        final places = snapshot.data ?? const <FavoritePlace>[];
        if (_tab == 1) return _mapView(places);
        return _listView(places);
      },
    ),
    floatingActionButton: _tab == 0
    ? FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Agregar lugar'),
      )
    : null,

    bottomNavigationBar: NavigationBar(selectedIndex: _tab,
      onDestinationSelected: (value) => setState(() => _tab = value),
      destinations: const [NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Mis lugares'),
        NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: 'Mapa')]),
  );

  Widget _errorView() => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Icon(Icons.cloud_off_outlined, size: 48), const SizedBox(height: 12),
    const Text('No se pudieron cargar tus lugares. Revisa tu internet e inténtalo de nuevo.', textAlign: TextAlign.center),
    const SizedBox(height: 12), FilledButton(onPressed: _reload, child: const Text('Reintentar')),
  ])));

  Widget _listView(List<FavoritePlace> all) {
    final options = ['Todas', ...{...all.map((p) => p.category)}];
    final filtered = all.where((p) => p.name.toLowerCase().contains(_query.toLowerCase()) &&
      (_category == 'Todas' || p.category == _category)).toList();
    return Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 10), child: TextField(
        onChanged: (value) => setState(() => _query = value),
        decoration: const InputDecoration(hintText: 'Busca un lugar...', prefixIcon: Icon(Icons.search)))),
      SizedBox(height: 44, child: ListView.separated(scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) => ChoiceChip(label: Text(options[i]), selected: _category == options[i],
          onSelected: (_) => setState(() => _category = options[i])))),
      Padding(padding: const EdgeInsets.fromLTRB(18, 14, 18, 8), child: Row(children: [
        Text('${filtered.length} ${filtered.length == 1 ? 'lugar guardado' : 'lugares guardados'}', style: const TextStyle(fontWeight: FontWeight.w700)),
        const Spacer(), IconButton(tooltip: 'Actualizar', onPressed: _reload, icon: const Icon(Icons.refresh))])),
      Expanded(child: filtered.isEmpty ? _empty(all.isEmpty) : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), itemCount: filtered.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, i) => _placeCard(filtered[i]))),
    ]);
  }

  Widget _empty(bool noPlaces) => Center(child: Padding(padding: const EdgeInsets.all(30), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(noPlaces ? Icons.add_location_alt_outlined : Icons.search_off, size: 54, color: Theme.of(context).colorScheme.primary),
    const SizedBox(height: 14), Text(noPlaces ? 'Empieza con un lugar especial' : 'No encontramos coincidencias', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    const SizedBox(height: 6), Text(noPlaces ? 'Guarda tu primer sitio y márcalo en el mapa.' : 'Prueba otro nombre o categoría.', textAlign: TextAlign.center),
  ])));

  Widget _placeCard(FavoritePlace place) => Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    if (place.photoPath != null) ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SizedBox(height: 155, width: double.infinity, child: _PlacePhoto(path: place.photoPath!))),
    Padding(padding: const EdgeInsets.fromLTRB(16, 14, 8, 12), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(place.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18)),
        const SizedBox(height: 5), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(20)),
          child: Text(place.category, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w600))),
        if (place.description.isNotEmpty) ...[const SizedBox(height: 8), Text(place.description, maxLines: 3, overflow: TextOverflow.ellipsis)],
        const SizedBox(height: 8), Text('Ubicación exacta guardada en el mapa', style: TextStyle(fontSize: 11, color: Colors.black54)),
      ])),
      PopupMenuButton<String>(onSelected: (value) => value == 'edit' ? _edit(place) : _delete(place), itemBuilder: (_) => const [
        PopupMenuItem(value: 'edit', child: Text('Editar')), PopupMenuItem(value: 'delete', child: Text('Eliminar'))]),
    ])),
  ]));

  Widget _mapView(List<FavoritePlace> places) => Stack(children: [
  PlacesMap(
    key: ValueKey(_myPosition),
    places: places,
    currentPosition: _myPosition,
    selected: _selectedPlace == null
        ? null
        : LatLng(
            _selectedPlace!.latitude,
            _selectedPlace!.longitude,
          ),
    onPlaceTap: (place) {
      setState(() => _selectedPlace = place);
    },
  ),

  Positioned(
  left: 16,
  top: 16,
  child: FloatingActionButton.extended(
    onPressed: _add,
    icon: const Icon(Icons.add_location_alt_outlined),
    label: const Text('Agregar lugar'),
  ),
),

  Positioned(
    right: 16,
    top: 16,
    child: FloatingActionButton.small(
      heroTag: 'my-location',
      tooltip: 'Mi ubicación',
      onPressed: _locate,
      child: const Icon(Icons.my_location),
    ),
  ),

  if (_selectedPlace != null)
    Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedPlace!.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedPlace!.description.isEmpty
                          ? 'Sin descripción'
                          : _selectedPlace!.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Editar lugar',
                onPressed: () => _edit(_selectedPlace!),
                icon: const Icon(Icons.edit_outlined),
              ),
              IconButton(
                tooltip: 'Cerrar tarjeta',
                onPressed: () => setState(() => _selectedPlace = null),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      ),
    ),

  if (places.isEmpty)
    const Positioned(
      left: 16,
      right: 74,
      top: 16,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Agrega lugares y aparecerán aquí como pines.'),
        ),
      ),
    ),
]);
}

class _PlacePhoto extends StatelessWidget {
  const _PlacePhoto({required this.path});
  final String path;
  @override
  Widget build(BuildContext context) => FutureBuilder<String?>(
    future: PlaceRepository(Supabase.instance.client).signedPhotoUrl(path),
    builder: (context, snapshot) => snapshot.data == null
      ? ColoredBox(color: Theme.of(context).colorScheme.primaryContainer, child: const Center(child: Icon(Icons.photo_outlined)))
      : Image.network(snapshot.data!, fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => ColoredBox(color: Theme.of(context).colorScheme.primaryContainer, child: const Center(child: Icon(Icons.broken_image_outlined)))),
  );
}
