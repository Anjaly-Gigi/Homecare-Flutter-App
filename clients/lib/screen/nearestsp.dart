import 'package:flutter/material.dart';
import 'package:clients/main.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart'; // Updated import statement

class Nearestsp extends StatefulWidget {
  const Nearestsp({super.key});

  @override
  State<Nearestsp> createState() => _NearestspState();
}

class _NearestspState extends State<Nearestsp> {
  bool isLoading = true;
  List<Map<String, dynamic>> serviceProviders = [];
  Position? _currentPosition;
  final Distance distance = Distance();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) => fetchServiceProviders());
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }
      
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> fetchServiceProviders() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase.from('tbl_sp').select();
      print("Current Location: $_currentPosition");
      List<Map<String, dynamic>> providersWithDistance = response.map((sp) {
        double spLat = sp['sp_location']['latitude']?.toDouble() ?? 0.0;
        double spLong = sp['sp_location']['longitude']?.toDouble() ?? 0.0;
        
        double calculatedDistance = _currentPosition != null
            ? distance(
                LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                LatLng(spLat, spLong),
              ) / 1000 // Convert to kilometers
            : 0.0;

        return {
          ...sp,
          'distance': calculatedDistance,
        };
      }).toList();

      providersWithDistance.sort((a, b) => 
        a['distance'].compareTo(b['distance']));

      setState(() {
        serviceProviders = providersWithDistance;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Error fetching service providers: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearest Service Providers'),
        backgroundColor: const Color(0xFFFF6F61),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : serviceProviders.isEmpty
              ? const Center(child: Text('No service providers found'))
              : ListView.builder(
                  itemCount: serviceProviders.length,
                  itemBuilder: (context, index) {
                    final sp = serviceProviders[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        height: 150,
                        width: double.infinity,
                        child: ListTile(
                          title: Text(
                            sp['sp_name'] ?? 'Unnamed Provider',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sp['sp_address'] ?? 'No Address Provided'),
                              Text(
                                'Distance: ${(sp['distance'] as double).toStringAsFixed(2)} km',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            print('Selected Provider: ${sp['sp_name']}');
                          },
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}