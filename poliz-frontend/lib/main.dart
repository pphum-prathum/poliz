import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'login_page.dart';
import 'emergency_alert_page.dart';

void main() => runApp(const GoodPolizApp());

class GoodPolizApp extends StatelessWidget {
  const GoodPolizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoodPoliz – Incident Importance Ranking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0F172A), // slate-900-ish
        useMaterial3: true,
      ),
      home: const LoginPage(),
      // home: const IncidentHomePage(),
    );
  }
}

class Incident {
  final String id;
  final String type;
  final String place;
  final DateTime time;
  final String notes;

  // =========================================================
  // ✨ NEW: รับค่า Score และ RankLevel ที่คำนวณจาก Backend โดยตรง
  // =========================================================
  final int score;
  final String rankLevel;

  // ✨ พิกัดสำหรับแสดงบนแผนที่ (optional)
  final double? latitude;
  final double? longitude;

  Incident({
    required this.id,
    required this.type,
    required this.place,
    required this.time,
    required this.notes,
    required this.score,
    required this.rankLevel,
    this.latitude,
    this.longitude,
  });

  // Helper method for API call: แปลง Incident เป็น JSON Map ที่ Backend ต้องการ
  Map<String, dynamic> toJson() {
    // ไม่ต้องส่ง score และ rankLevel เพราะ Backend จะคำนวณเอง
    return {
      'type': type,
      'place': place,
      // ส่ง Local Time (ที่ผู้ใช้เลือก) ในรูปแบบ ISO 8601 String
      'time': time.toIso8601String(),
      'notes': notes,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Logic การแปลง JSON จาก Backend
  factory Incident.fromJson(Map<String, dynamic> json) {
    // Spring Boot ส่งกลับมาเป็น Local Date Time String
    DateTime parsedTime = DateTime.parse(json['time'] as String);

    return Incident(
      id: json['id']?.toString() ?? 'N/A',
      type: json['type'] as String,
      place: json['place'] as String,
      time: parsedTime,
      notes: json['notes'] as String,
      // รับค่าใหม่จาก Backend ที่คำนวณแล้ว
      score: json['score'] as int? ?? 0,
      rankLevel: json['rankLevel'] as String? ?? 'LOW',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Incident copyWith({
    String? id,
    String? type,
    String? place,
    DateTime? time,
    String? notes,
    int? score,
    String? rankLevel,
    double? latitude,
    double? longitude,
  }) {
    return Incident(
      id: id ?? this.id,
      type: type ?? this.type,
      place: place ?? this.place,
      time: time ?? this.time,
      notes: notes ?? this.notes,
      score: score ?? this.score,
      rankLevel: rankLevel ?? this.rankLevel,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

class RankBand {
  final String level;
  final Color color;
  final int score;

  const RankBand(this.level, this.color, this.score);
}

class IncidentHomePage extends StatefulWidget {
  const IncidentHomePage({super.key});

  @override
  State<IncidentHomePage> createState() => _IncidentHomePageState();
}

class _IncidentHomePageState extends State<IncidentHomePage> {
  // กำหนด Base URL ของ Spring Boot Backend
  static const String _hostIp = 'localhost';
  static const String _hostPort = '8080';
  static const String _baseUrl = 'http://$_hostIp:$_hostPort/api/v1/events';

  final List<Incident> _incidents = [];

  // สถานะสำหรับ Notification Badge (ตัวเลขสีแดง)
  int _newAlertCount = 0;

  // Cached rankings (id -> score) ถูกแทนที่ด้วย incident.score โดยตรง
  final Map<String, int> _ranked = {};
  DateTime? _lastRun;

  // Controls
  final _placeCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _searchCtrl = TextEditingController();
  // NEW: latitude / longitude inputs
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  String _type = 'Traffic Accident';
  DateTime _pickedTime = DateTime.now();

  final _types = const <String>[
    'Traffic Accident',
    'Medical Emergency',
    'Fire',
    'Armed Robbery',
    'Violent Crime',
    'Disturbance',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    _getNewAlertCount();
  }

  @override
  void dispose() {
    _placeCtrl.dispose();
    _notesCtrl.dispose();
    _searchCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
    super.dispose();
  }

  // --- API Functions ---

  // 1. ดึงรายการเหตุการณ์ทั้งหมดจาก Backend
  Future<void> _loadIncidents() async {
    try {
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        setState(() {
          _incidents
            ..clear()
            ..addAll(
              jsonList
                  .map((json) => Incident.fromJson(json as Map<String, dynamic>))
                  .toList(),
            );
          _applyRanking();
        });
      } else {
        debugPrint('Failed to load incidents. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error loading incidents: $e');
    }
  }

  // 2. ดึงจำนวนแจ้งเตือนใหม่ (isNew = true) จาก Backend
  Future<void> _getNewAlertCount() async {
    try {
      final response =
      await http.get(Uri.parse('$_baseUrl/new/count'));

      if (response.statusCode == 200) {
        final count = int.tryParse(response.body) ?? 0;
        setState(() {
          _newAlertCount = count;
        });
      } else {
        debugPrint('Failed to get new incident count. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting new incident count: $e');
    }
  }

  // 3. Mark all as read (ใช้เมื่อเข้า Alerts page)
  Future<void> markAllAsRead() async {
    try {
      final response =
      await http.post(Uri.parse('$_baseUrl/mark-as-read'));
      if (response.statusCode == 204) {
        await _getNewAlertCount();
      } else {
        debugPrint('Failed to mark all as read. Status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  // -------------------------------------------------------------
  // Helpers for ranking view
  // -------------------------------------------------------------

  List<Incident> _viewIncidents() {
    final query = _searchCtrl.text.trim().toLowerCase();
    if (query.isEmpty) {
      return _sortedByScore(_incidents);
    }
    final filtered = _incidents.where((i) {
      final text =
      '${i.id} ${i.type} ${i.place} ${i.notes}'.toLowerCase();
      return text.contains(query);
    }).toList();
    return _sortedByScore(filtered);
  }

  List<Incident> _sortedByScore(List<Incident> list) {
    list.sort((a, b) => b.score.compareTo(a.score));
    return list;
  }

  RankBand _rankBand(Incident i) {
    final score = i.score;
    final rankLevel = i.rankLevel;
    Color color;
    switch (rankLevel) {
      case 'CRITICAL':
        color = Colors.red.shade700;
        break;
      case 'HIGH':
        color = Colors.orange.shade700;
        break;
      case 'MEDIUM':
        color = Colors.amber.shade700;
        break;
      case 'LOW':
      default:
        color = Colors.green.shade600;
        break;
    }
    return RankBand(rankLevel, color, score);
  }
  // -------------------------------------------------------------

  void _applyRanking() {
    _ranked
      ..clear();
    for (final i in _incidents) {
      // แคชคะแนนที่คำนวณจาก Backend
      _ranked[i.id] = i.score;
    }
    _lastRun = DateTime.now();
    setState(() {});
  }

  // -------------------------------------------------------------
  // UI interactions
  // -------------------------------------------------------------

  String _fmtDateTime(DateTime t) {
    // ใช้ t โดยตรงเพราะเป็นเวลา Local ที่ถูกต้อง
    final local = t;
    final y = local.year.toString().padLeft(4, '0');
    final m = local.month.toString().padLeft(2, '0');
    final d = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  String _newId() {
    final r = Random();
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(8, (_) => chars[r.nextInt(chars.length)]).join();
  }

  double? _parseDoubleOrNull(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed);
  }

  Future<void> _pickDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _pickedTime,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (date == null) return;

    final timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickedTime),
    );
    if (timeOfDay == null) return;

    setState(() {
      _pickedTime = DateTime(
        date.year,
        date.month,
        date.day,
        timeOfDay.hour,
        timeOfDay.minute,
      );
    });
  }

  void _applySearch() {
    setState(() {});
  }

  void _clearSearch() {
    _searchCtrl.clear();
    _applySearch();
  }

  // -------------------------------------------------------------
  // Add & Rank
  // -------------------------------------------------------------

  // ฟังก์ชันนี้ไม่ใส่ AI ใน Flutter แล้ว แต่จะส่ง Incident ทั้งก้อนให้ Backend
  // จากนั้น Backend จะคำนวณ Heuristic Score และ Rank ให้ แล้วตอบกลับมา
  // ส่วน Flutter เพียงแค่ refresh list ใหม่ ไม่ต้องคำนวณเอง
  void _addIncident() async {
    if (_placeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Place is required')
        ),
      );
      return;
    }

    // NEW: parse coordinate inputs (optional)
    final lat = _parseDoubleOrNull(_latCtrl.text);
    final lng = _parseDoubleOrNull(_lngCtrl.text);

    // 1. สร้าง Incident Object ที่จะส่งไป Backend
    final newIncident = Incident(
      id: _newId(), // ID นี้จะถูก Backend ทิ้งไป แต่เราเก็บไว้ใน Flutter ก่อน
      type: _type,
      place: _placeCtrl.text.trim(),
      // ถูกต้อง: _pickedTime เป็น Local Time อยู่แล้ว ปล่อยให้ toJson() จัดการแปลงเป็น Local time string เอง
      time: _pickedTime,
      notes: _notesCtrl.text.trim(),
      // ค่า score / rankLevel ให้ Backend เป็นคนคำนวณ ไม่ต้องส่งจากฝั่งนี้
      score: 0,
      rankLevel: 'LOW',
      latitude: lat,
      longitude: lng,
    );

    try {
      // เรียก Backend ผ่าน HTTP POST
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newIncident.toJson()), // ใช้ toJson() ที่เราสร้าง
      );

      if (response.statusCode == 200) {
        // สำเร็จ: Backend บันทึกข้อมูลแล้ว
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incident added successfully!')),
        );

        // โหลดข้อมูลทั้งหมดจาก Backend ใหม่ เพื่อให้ List อัปเดต
        _loadIncidents();

        // ดึงจำนวนแจ้งเตือนใหม่ เพื่ออัปเดต Badge ทันที
        _getNewAlertCount();

        // ล้างฟอร์ม
        _placeCtrl.clear();
        _notesCtrl.clear();
        _latCtrl.clear();
        _lngCtrl.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add incident. Status: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection Error: $e')),
      );
    }

    // ล้างฟอร์มและอัปเดต UI (setState ถูกเรียกใน _loadIncidents แล้ว)
    setState(() {});
  }

  // -------------------------------------------------------------
  // Build
  // -------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final list = _viewIncidents();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident Importance Ranking'),
        actions: [
          if (_lastRun != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  'Last updated: ${_fmtDateTime(_lastRun!)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // แสดงแบบ 2 คอลัมน์เมื่อหน้าจอกว้าง
          final wide = constraints.maxWidth >= 900;
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ListView(
                    padding: const EdgeInsets.all(12.0),
                    children: [
                      _buildListCard(list),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 2,
                  child: ListView(
                    padding: const EdgeInsets.all(12.0),
                    children: [
                      _buildFormCard(context),
                      const SizedBox(height: 12),
                      _buildHelpCard(),
                    ],
                  ),
                ),
              ],
            );
          } else {
            return ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                _buildListCard(list),
                const SizedBox(height: 12),
                _buildFormCard(context),
                const SizedBox(height: 12),
                _buildHelpCard(),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildListCard(List<Incident> list) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Header + search (fixed to be responsive)
            Row(
              children: [
                const Icon(Icons.emergency_outlined),
                const SizedBox(width: 5),
                // Title takes less room
                const Expanded(
                  flex: 1,
                  child: Text(
                    'Incident List',
                    style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                // Search gets more room
                Expanded(
                  flex: 2,
                  child: TextField(
                    key: const ValueKey('searchField'),
                    controller: _searchCtrl,
                    onChanged: (_) => _applySearch(),
                    decoration: const InputDecoration(
                      hintText: 'Search by id, type, place, notes…',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Clear search',
                  onPressed: _clearSearch,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),

            if (list.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'No incidents found (or Backend disconnected).',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            else
              SizedBox(
                height: 360,
                child: ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    return _buildIncidentTile(list[index]);
                  },
                ),
              ),

            const SizedBox(height: 8),

            // Footer status
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Loaded: ${list.length} incidents',
                    style:
                    const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                TextButton.icon(
                  onPressed: _loadIncidents,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentTile(Incident i) {
    final band = _rankBand(i);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: band.color,
          foregroundColor: Colors.white,
          child: Text(
            band.score.toString(),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${i.type} @ ${i.place}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _fmtDateTime(i.time),
              style: const TextStyle(fontSize: 12),
            ),
            if (i.notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                i.notes,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: Text(
          band.level,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: band.color,
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    // ... (ส่วนโค้ด Form Card เดิม) ...
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              children: const [
                Icon(Icons.add_circle_outline),
                SizedBox(width: 8),
                Text(
                  'Add New Incident',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('typeDropdown'),
              value: _type,
              items: _types
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _type = v ?? _type),
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('placeField'),
              controller: _placeCtrl,
              decoration: const InputDecoration(
                labelText: 'Place',
                hintText: 'e.g., Rama IX Rd, near Central Plaza',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            // NEW: Latitude (optional)
            TextField(
              key: const ValueKey('latitudeField'),
              controller: _latCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 13.7563',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            // NEW: Longitude (optional)
            TextField(
              key: const ValueKey('longtitudeField'),
              controller: _lngCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., 100.5018',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Time',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    child: Text(_fmtDateTime(_pickedTime)),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  key: const ValueKey('datetimePicker'),
                  onPressed: () => _pickDateTime(context),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Pick'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              key: const ValueKey('notesField'),
              controller: _notesCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                hintText:
                'Details that help AI judge severity (e.g., weapon, injuries, fire, number of people)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: const [
                      Icon(Icons.error_outline, size: 16),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Importance is backend-estimated. Always verify on dispatch.',
                          style:
                          TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  key: const ValueKey('submitIncident'),
                  onPressed: _addIncident,
                  icon: const Icon(Icons.star_border),
                  label: const Text('Add & Rank'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: const [
            Row(
              children: [
                Icon(Icons.menu_book_outlined),
                SizedBox(width: 8),
                Text(
                  'How it works',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('1) Add incident with type, place, time, notes.'),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '2) AI computes an importance score (0–100) and a level (LOW / MEDIUM / HIGH / CRITICAL).',
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('3) List is sorted with highest priority on top.'),
            ),
            SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This is a front-end demo. Data is now saved to and loaded from your Spring Boot backend.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}