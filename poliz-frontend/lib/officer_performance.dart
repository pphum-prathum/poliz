import 'package:flutter/material.dart';
import 'styles/app_theme.dart';
import 'styles/styles.dart';

class OfficerPerformancePage extends StatefulWidget {
  const OfficerPerformancePage({super.key});
  @override
  State<OfficerPerformancePage> createState() => _OfficerPerformancePageState();
}

class _OfficerPerformancePageState extends State<OfficerPerformancePage> {
  final periods = const ['Today', 'This Week', 'Last Week', 'This Month', 'Last Month'];
  String period = 'Last Month';

  final data = const [
    _Perf('Officer Martinez', 47),
    _Perf('Officer Johnson', 42),
    _Perf('Officer Chen', 38),
    _Perf('Officer Williams', 35),
    _Perf('Officer Rodriguez', 31),
    _Perf('Officer Taylor', 28),
  ];

  @override
  Widget build(BuildContext context) {
    final max = data.map((e) => e.cases).reduce((a, b) => a > b ? a : b);

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
            onChanged: (v) => setState(() => period = v ?? period),
          ),
          gap16,
          DarkCard(
            child: Column(
              children: [
                _tableHeader(context),
                const Divider(height: 1, color: AppColors.divider),
                ...data.map(_tableRow),
              ],
            ),
          ),
          gap16,
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Performance Chart'),
                gap12,
                ...data.map((e) => _barRow(e, max)),
              ],
            ),
          ),
          gap16,
          SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.picture_as_pdf_outlined),
              label: const Text('Generate Report'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    child: Row(
      children: [
        Expanded(child: Text('Officer Name', style: Theme.of(context).textTheme.bodyMedium)),
        const SizedBox(width: 12),
        Text('Cases Handled', style: Theme.of(context).textTheme.bodyMedium),
      ],
    ),
  );

  Widget _tableRow(_Perf p) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    child: Row(
      children: [
        Expanded(child: Text(p.name)),
        const SizedBox(width: 12),
        Text('${p.cases}', style: const TextStyle(color: AppColors.sky, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  Widget _barRow(_Perf p, int max) {
    final pct = p.cases / max;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(child: Text(p.short)),
            Text('${p.cases}', style: const TextStyle(color: AppColors.sky, fontWeight: FontWeight.w700)),
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
}

class _Perf {
  final String name;
  final int cases;
  const _Perf(this.name, this.cases);
  String get short => name.split(' ').last;
}