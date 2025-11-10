import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'styles/app_theme.dart';
import 'styles/styles.dart';

class CrimeDashboardPage extends StatefulWidget {
  const CrimeDashboardPage({super.key});

  @override
  State<CrimeDashboardPage> createState() => _CrimeDashboardPageState();
}

class _CrimeDashboardPageState extends State<CrimeDashboardPage> {
  static const String _hostIp = 'localhost';
  static const String _hostPort = '8080';
  static const String _baseUrl =
      'http://$_hostIp:$_hostPort/api/v1/crime-incidents';

  final types = const ['All Types', 'Robbery', 'Accident', 'Violence', 'Arson'];
  String selected = 'All Types';

  // all incidents from backend
  List<_Inc> _allIncidents = [];
  // incidents after filter (for list + map)
  List<_Inc> _visibleIncidents = [];

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchIncidents();
  }

  Future<void> _fetchIncidents() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await http.get(Uri.parse(_baseUrl));

      if (res.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(res.body);
        final all = jsonList.map((e) => _Inc.fromJson(e)).toList();

        setState(() {
          _allIncidents = all;
        });
        _applyFilter(); // recompute visible list
      } else {
        setState(() {
          _error = 'Server error: ${res.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error loading incidents: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _applyFilter() {
    List<_Inc> list;

    if (selected == 'All Types') {
      list = List.of(_allIncidents);
    } else {
      list = _allIncidents.where((i) => i.type == selected).toList();
    }

    setState(() {
      _visibleIncidents = list;
    });
  }

  void _setFilter(String type) {
    setState(() {
      selected = type;
    });
    _applyFilter();
  }

  void _showIncidentDetails(_Inc inc) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // X button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  inc.type,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,     // 👈 visible title
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.place_outlined,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        inc.place,
                        style: const TextStyle(
                          color: AppColors.textSecondary, // 👈 light grey
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      inc.time,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: 6),
                    Text(
                      'Status: ${inc.status}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  inc.description.isEmpty
                      ? 'No description provided.'
                      : inc.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // dynamic counts from backend data
    final robberyCount =
        _allIncidents.where((i) => i.type == 'Robbery').length;
    final accidentCount =
        _allIncidents.where((i) => i.type == 'Accident').length;
    final violenceCount =
        _allIncidents.where((i) => i.type == 'Violence').length;
    final arsonCount =
        _allIncidents.where((i) => i.type == 'Arson').length;

    return Scaffold(
      appBar: AppBar(title: const Text('Crime Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // REAL MAP
          DarkCard(
            child: SizedBox(
              height: 260,
              child: _buildMap(),
            ),
          ),
          gap16,
          const Text('Crime Type Filter',
              style: TextStyle(color: AppColors.textSecondary)),
          gap8,
          DropdownButtonFormField<String>(
            value: selected,
            items: types
                .map(
                  (t) => DropdownMenuItem(
                value: t,
                child: Text(t),
              ),
            )
                .toList(),
            onChanged: (v) {
              _setFilter(v ?? selected);
            },
            decoration: const InputDecoration(hintText: 'All Types'),
          ),
          gap16,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _StatCard(
                count: robberyCount,
                label: 'Robbery',
                color1: 0xFFFF7A45,
                color2: 0xFFFFA940,
                onTap: () => _setFilter('Robbery'),
              ),
              _StatCard(
                count: accidentCount,
                label: 'Accident',
                color1: 0xFFFFB02E,
                color2: 0xFFFFD166,
                onTap: () => _setFilter('Accident'),
              ),
              _StatCard(
                count: violenceCount,
                label: 'Violence',
                color1: 0xFFB06AF7,
                color2: 0xFFDB7DFF,
                onTap: () => _setFilter('Violence'),
              ),
              _StatCard(
                count: arsonCount,
                label: 'Arson',
                color1: 0xFFEF476F,
                color2: 0xFFF78C6B,
                onTap: () => _setFilter('Arson'),
              ),
            ],
          ),
          gap16,
          const SectionTitle('Recent Incidents'),
          gap12,
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent),
              ),
            )
          else if (_visibleIncidents.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'No incidents found.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              )
            else
              ..._visibleIncidents.map(
                    (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _IncidentTile(
                    inc: e,
                    onTap: () => _showIncidentDetails(e),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ---------------- MAP ----------------

  Widget _buildMap() {
    final withCoords = _visibleIncidents
        .where((i) => i.latitude != null && i.longitude != null)
        .toList();

    if (withCoords.isEmpty) {
      return const Center(
        child: Text(
          'No incidents with coordinates to display.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    final center = LatLng(
      withCoords.first.latitude!,
      withCoords.first.longitude!,
    );

    final markers = withCoords
        .map(
          (i) => Marker(
        width: 40,
        height: 40,
        point: LatLng(i.latitude!, i.longitude!),
        child: const Icon(
          Icons.location_on,
          color: AppColors.sky,
          size: 30,
        ),
      ),
    )
        .toList();

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: 12,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.poliz',
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}

// -------------- UI helpers / models --------------

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final int color1, color2;
  final VoidCallback? onTap;

  const _StatCard({
    required this.count,
    required this.label,
    required this.color1,
    required this.color2,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(AppRadii.lg),
      child: Container(
        width: 170,
        height: 96,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(AppRadii.lg),
          color: AppColors.surfaceDark,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(color1).withOpacity(.16),
              Color(color2).withOpacity(.16),
            ],
          ),
          boxShadow: AppShadows.soft,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(.25),
                borderRadius: const BorderRadius.all(AppRadii.pill),
              ),
              child: Text(
                '$count',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

/// model for JSON from backend
class _Inc {
  final String type;
  final String place;
  final String time;
  final String description;
  final String status;
  final double? latitude;
  final double? longitude;

  const _Inc({
    required this.type,
    required this.place,
    required this.time,
    required this.description,
    required this.status,
    this.latitude,
    this.longitude,
  });

  factory _Inc.fromJson(Map<String, dynamic> json) {
    return _Inc(
      type: json['type'] as String,
      place: json['placeName'] as String,
      time: json['timeLabel'] as String,
      description: (json['description'] as String?) ?? '',
      // backend doesn’t have status yet, default to "Ongoing"
      status: (json['status'] as String?) ?? 'Ongoing',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }
}

class _IncidentTile extends StatelessWidget {
  final _Inc inc;
  final VoidCallback? onTap;

  const _IncidentTile({
    required this.inc,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(AppRadii.lg),
      child: DarkCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // first row: type + time
            Row(
              children: [
                Expanded(
                  child: Text(
                    inc.type,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                const Icon(Icons.schedule,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  inc.time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            // second row: icon + place, vertically centered
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.place_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    inc.place,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}