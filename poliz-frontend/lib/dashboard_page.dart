import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'chat_page.dart';
import 'officer_performance.dart';
import 'crime_dashboard_page.dart';
import 'emergency_alert_page.dart';
import 'main.dart' show IncidentHomePage;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  static const String _hostIp = 'localhost';
  static const String _hostPort = '8080';
  static const String _baseUrl = 'http://$_hostIp:$_hostPort/api/v1/events';

  int _newAlertCount = 0;

  @override
  void initState() {
    super.initState();
    _getNewAlertCount();
  }

  Future<void> _getNewAlertCount() async {
    try {
      final res = await http.get(Uri.parse('$_baseUrl/new/count'));
      if (res.statusCode == 200) {
        setState(() {
          _newAlertCount = int.tryParse(res.body) ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching alerts: $e');
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await http.post(Uri.parse('$_baseUrl/mark-as-read'));
      setState(() => _newAlertCount = 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Poliz System',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                tooltip: 'Emergency Alerts',
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  _markAllAsRead();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EmergencyAlertPage()),
                  ).then((_) => _getNewAlertCount());
                },
              ),
              if (_newAlertCount > 0)
                Positioned(
                  right: 4,
                  top: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '$_newAlertCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;
          final cards = [
            _buildDashboardCard(
              icon: Icons.notifications_active,
              title: 'Real-Time Alerts',
              color: Colors.deepOrangeAccent,
              onTap: () {
                _markAllAsRead();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EmergencyAlertPage()),
                );
              },
            ),
            _buildDashboardCard(
              icon: Icons.analytics_outlined,
              title: 'Analytics Report',
              color: Colors.blueAccent,
              onTap: () {
                _markAllAsRead();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OfficerPerformancePage()),
                );
              },
            ),
            _buildDashboardCard(
              icon: Icons.chat_bubble_outline,
              title: 'Secure Chat',
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SecureChatPage()),
                );
              },
            ),
            _buildDashboardCard(
              icon: Icons.map_outlined,
              title: 'Crime Dashboard',
              color: Colors.purpleAccent,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CrimeDashboardPage()),
                );
              },
            ),
            _buildDashboardCard(
              icon: Icons.warning_amber_rounded,
              title: 'AI Incident Ranking',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncidentHomePage()),
                );
              },
            ),
          ];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: isWide
                    ? Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.start,
                  children: cards,
                )
                    : Column(
                  children: cards
                      .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: c,
                  ))
                      .toList(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 240,
      height: 140,
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 36),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openPlaceholder(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: Text(title)),
          body: const Center(child: Text('Coming soon...')),
        ),
      ),
    );
  }
}