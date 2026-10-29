import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ErrandMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String locationName;

  const ErrandMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.locationName,
  });

  @override
  State<ErrandMapScreen> createState() => _ErrandMapScreenState();
}

class _ErrandMapScreenState extends State<ErrandMapScreen> {
  @override
  Widget build(BuildContext context) {
    // The coordinates of the errand
    final LatLng errandLocation = LatLng(widget.latitude, widget.longitude);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.locationName),
        backgroundColor: const Color(0xFF1B2A5E),
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(initialCenter: errandLocation, initialZoom: 16.0),
        children: [
          // This loads the free OpenStreetMap tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName:
                'com.example.myapp', // Identifies your app to OSM [citation:15]
          ),
          // This puts the red pin on the map
          MarkerLayer(
            markers: [
              Marker(
                point: errandLocation,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
