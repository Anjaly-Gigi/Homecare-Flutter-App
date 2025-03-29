import 'package:clients/main.dart';
import 'package:clients/screen/spprofile.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class SkillScreen extends StatefulWidget {
  final int skillId;
  const SkillScreen({super.key, required this.skillId});

  @override
  State<SkillScreen> createState() => _SkillScreenState();
}

class _SkillScreenState extends State<SkillScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> spList = [];
  Position? _currentPosition;
  final Distance distance = Distance();
  int? _selectedRadius = 2; // Set default radius to 2km

  @override
  void initState() {
    super.initState();
    _getCurrentLocation().then((_) => fetchData(widget.skillId));
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

  Future<void> fetchData(int skillId) async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('tbl_spskills')
          .select('''
            sp_id,
            tbl_sp!inner(*)
          ''')
          .eq('skill_id', skillId);

      List<Map<String, dynamic>> providersWithDistance = 
          (response as List).map((item) {
            final sp = item['tbl_sp'] as Map<String, dynamic>;
            double spLat = sp['sp_location']?['latitude']?.toDouble() ?? 0.0;
            double spLong = sp['sp_location']?['longitude']?.toDouble() ?? 0.0;
            
            double calculatedDistance = _currentPosition != null
                ? distance(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    LatLng(spLat, spLong),
                  ) / 1000
                : 0.0;

            return {
              ...sp,
              'distance': calculatedDistance,
            };
          }).toList();

      // Apply radius filter
      if (_selectedRadius != null) {
        providersWithDistance = providersWithDistance.where((sp) {
          if (_selectedRadius == 11) return sp['distance'] > 10;
          return sp['distance'] <= _selectedRadius!;
        }).toList();
      }

      // Sort by distance
      providersWithDistance.sort((a, b) => a['distance'].compareTo(b['distance']));

      setState(() {
        spList = providersWithDistance;
        isLoading = false;
      });
    } catch (e) {
      print("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Service Painters'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for painters...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('2 km'),
                    selected: _selectedRadius == 2,
                    onSelected: (selected) {
                      setState(() => _selectedRadius = selected ? 2 : null);
                      fetchData(widget.skillId);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('5 km'),
                    selected: _selectedRadius == 5,
                    onSelected: (selected) {
                      setState(() => _selectedRadius = selected ? 5 : null);
                      fetchData(widget.skillId);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('10 km'),
                    selected: _selectedRadius == 10,
                    onSelected: (selected) {
                      setState(() => _selectedRadius = selected ? 10 : null);
                      fetchData(widget.skillId);
                    },
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('>10 km'),
                    selected: _selectedRadius == 11,
                    onSelected: (selected) {
                      setState(() => _selectedRadius = selected ? 11 : null);
                      fetchData(widget.skillId);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : spList.isEmpty
                      ? const Center(child: Text('No painters found within 2km'))
                      : ListView.builder(
                          itemCount: spList.length,
                          itemBuilder: (context, index) {
                            return PainterCard(painter: spList[index]);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class PainterCard extends StatefulWidget {
  final Map<String, dynamic> painter;

  const PainterCard({super.key, required this.painter});

  @override
  State<PainterCard> createState() => _PainterCardState();
}

class _PainterCardState extends State<PainterCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ServiceProviderProfile(spId: widget.painter['id'])),
        );
      },
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.painter['sp_photo'] ?? "https://via.placeholder.com/150",
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.painter['sp_name'] ?? "",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Distance: ${(widget.painter['distance'] as double).toStringAsFixed(2)} km',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}