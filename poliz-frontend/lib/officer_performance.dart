import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'styles/app_theme.dart';
import 'styles/styles.dart';
import '/performance_summary.dart';
import 'package:printing/printing.dart';
import '/performance_report.dart';

class OfficerPerformancePage extends StatefulWidget {
  const OfficerPerformancePage({super.key});
  @override
  State<OfficerPerformancePage> createState() => _OfficerPerformancePageState();
}

class _OfficerPerformancePageState extends State<OfficerPerformancePage> {
  final periods = const ['Today', 'This Week', 'Last Week', 'This Month', 'Last Month'];
  String period = 'Last Month';

  Future<PerformanceSummary>? _future;

  static const String _base = 'http://localhost:8080';

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<PerformanceSummary> _fetch() async {
    final range = _toRange(period);
    final uri = Uri.parse('$_base/api/v1/performance/summary').replace(queryParameters: {
      'from': range.$1, // YYYY-MM-DD
      'to': range.$2,   // YYYY-MM-DD
      // add 'officer': 'Pim' if you want per-officer later
    });
    final res = await http.get(uri, headers: {'Accept': 'application/json'});
    if (res.statusCode != 200) {
      throw Exception('Failed to load: ${res.statusCode} ${res.body}');
    }
    return PerformanceSummary.fromJson(json.decode(res.body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Officer Performance')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Time Period', style: TextStyle(color: AppColors.textSecondary)),
          gap8,
          DropdownButtonFormField<String>(
            value: period,
            items: periods.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
            decoration: const InputDecoration(hintText: 'Select period'),
            onChanged: (v) {
              if (v == null) return;
              setState(() {
                period = v;
                _future = _fetch();
              });
            },
          ),
          gap16,
          FutureBuilder<PerformanceSummary>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 64),
                  child: CircularProgressIndicator(),
                ));
              }
              if (snap.hasError) {
                return DarkCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.redAccent)),
                  ),
                );
              }
              final s = snap.data!;
              final m = s.messaging;
              final r = s.incidents.byRankLevel;

              final kpis = [
                _Kpi('Conversations', m.conversations.toString()),
                _Kpi('Messages Sent', m.messagesSent.toString()),
                _Kpi('Messages Received', m.messagesReceived.toString()),
                _Kpi('Active Days', m.activeDays.toString()),
              ];

              final rankMap = {
                'CRITICAL': r.critical,
                'HIGH': r.high,
                'MEDIUM': r.medium,
                'LOW': r.low,
              };
              final maxRank = (rankMap.values.isEmpty) ? 1 : (rankMap.values.reduce((a, b) => a > b ? a : b)).clamp(1, 999999);

              return Column(
                children: [
                  // KPI cards
                  DarkCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Summary', color: Colors.white),
                          gap12,
                          Wrap(
                            spacing: 12, runSpacing: 12,
                            children: kpis.map((k) => _kpiCard(context, k)).toList(),
                          ),
                          gap8,
                          Text('Range: ${s.range.from} → ${s.range.to}', style: const TextStyle(color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                  gap16,
                  // Rank distribution
                  DarkCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SectionTitle('Incident Rank Distribution', color: Colors.white),
                          gap12,
                          ...rankMap.entries.map((e) => _barRow(label: e.key, value: e.value, max: maxRank)),
                        ],
                      ),
                    ),
                  ),
                  gap16,
                  SizedBox(
                    height: 48,
                    child: FilledButton.icon(
                      onPressed: () async {
                        if (!snap.hasData) return;
                        final s = snap.data!;
                        // lazy import to avoid top-level circulars
                        final bytes = await buildPerformanceReportPdf(s, periodLabel: period);
                        await Printing.layoutPdf(onLayout: (_) async => bytes);
                      },
                      icon: const Icon(Icons.picture_as_pdf_outlined),
                      label: const Text('Generate Report'),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ---------------- UI helpers ----------------

  Widget _kpiCard(BuildContext context, _Kpi k) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: const BorderRadius.all(AppRadii.lg),
        boxShadow: AppShadows.soft,
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(k.title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(k.value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }

  Widget _barRow({required String label, required int value, required int max}) {
    final pct = (max == 0) ? 0.0 : (value / max);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(child: Text(label)),
            Text('$value', style: const TextStyle(color: AppColors.sky, fontWeight: FontWeight.w700)),
          ],
        ),
        gap8,
        ClipRRect(
          borderRadius: const BorderRadius.all(AppRadii.pill),
          child: Stack(
            children: [
              Container(height: 10, color: AppColors.stroke),
              FractionallySizedBox(
                widthFactor: pct.clamp(0.0, 1.0),
                child: Container(height: 10, color: AppColors.policeBlue),
              ),
            ],
          ),
        ),
      ]),
    );
  }

  // ---------------- Date helpers ----------------

  /// Returns (from, to) as YYYY-MM-DD in local time.
  (String, String) _toRange(String p) {
    final now = DateTime.now();
    // Helper to format yyyy-MM-dd
    String fmt(DateTime d) {
      String two(int x) => x.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)}';
    }

    // Compute week boundaries (Mon–Sun)
    DateTime startOfWeek(DateTime d) {
      final wd = d.weekday; // Mon=1..Sun=7
      return DateTime(d.year, d.month, d.day).subtract(Duration(days: wd - 1));
    }

    switch (p) {
      case 'Today': {
        final d = DateTime(now.year, now.month, now.day);
        return (fmt(d), fmt(d));
      }
      case 'This Week': {
        final start = startOfWeek(now);
        final end = start.add(const Duration(days: 6));
        return (fmt(start), fmt(end));
      }
      case 'Last Week': {
        final start = startOfWeek(now).subtract(const Duration(days: 7));
        final end = start.add(const Duration(days: 6));
        return (fmt(start), fmt(end));
      }
      case 'This Month': {
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(days: 1));
        return (fmt(start), fmt(end));
      }
      case 'Last Month': {
        final prev = DateTime(now.year, now.month - 1, 1);
        final end = DateTime(now.year, now.month, 1).subtract(const Duration(days: 1));
        return (fmt(prev), fmt(end));
      }
      default: {
        final d = DateTime(now.year, now.month, now.day);
        return (fmt(d), fmt(d));
      }
    }
  }
}

class _Kpi {
  final String title;
  final String value;
  _Kpi(this.title, this.value);
}