import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/favorite_place.dart';

const sanLuisCenter = LatLng(22.1511, -100.9760);

class PlacesMap extends StatelessWidget {
  const PlacesMap({super.key, required this.places, this.selected,
    this.currentPosition, this.onMapTap, this.onPlaceTap});
  final List<FavoritePlace> places;
  final LatLng? selected;
  final LatLng? currentPosition;
  final ValueChanged<LatLng>? onMapTap;
  final ValueChanged<FavoritePlace>? onPlaceTap;

  @override
  Widget build(BuildContext context) => FlutterMap(
    options: MapOptions(initialCenter: selected ?? currentPosition ?? sanLuisCenter,
      initialZoom: 14, onTap: onMapTap == null ? null : (_, point) => onMapTap!(point)),
    children: [
      TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.examenp2_movil'),
      MarkerLayer(markers: [
        ...places.map((place) => Marker(point: LatLng(place.latitude, place.longitude), width: 48, height: 58,
          child: GestureDetector(onTap: onPlaceTap == null ? null : () => onPlaceTap!(place),
            child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.primary, size: 46)))),
        if (selected != null) Marker(point: selected!, width: 46, height: 54,
          child: Icon(Icons.location_on, color: Theme.of(context).colorScheme.secondary, size: 44)),
        if (currentPosition != null) Marker(point: currentPosition!, width: 24, height: 24,
          child: Container(decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)]))),
      ]),
      SimpleAttributionWidget(source: const Text('© OpenStreetMap contributors')),
    ],
  );
}
