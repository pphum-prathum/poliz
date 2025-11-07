import 'package:flutter/material.dart';
import 'styles/app_theme.dart';
import 'styles/styles.dart';

class CrimeDashboardPage extends StatefulWidget {
  const CrimeDashboardPage({super.key});

  @override
  State<CrimeDashboardPage> createState() => _CrimeDashboardPageState();
}

class _CrimeDashboardPageState extends State<CrimeDashboardPage> {
  final types = const ['All Types', 'Robbery', 'Accident', 'Violence', 'Arson'];
  String selected = 'All Types';

  @override
  Widget build(BuildContext context) {
    final incidents = const [
      _Inc('Robbery', 'Downtown Plaza', '2h ago'),
      _Inc('Accident', 'Highway 101', '3h ago'),
      _Inc('Violence', 'Park Street', '5h ago'),
      _Inc('Robbery', 'Mall Complex', '6h ago'),
      _Inc('Accident', 'Main Street', '8h ago'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Crime Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Map placeholder
          DarkCard(
            child: SizedBox(
              height: 180,
              child: Stack(
                children: const [
                  Positioned.fill(child: _GridBackdrop()),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_outlined, size: 42, color: AppColors.sky),
                        SizedBox(height: 8),
                        Text('Interactive Map View', style: TextStyle(color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          gap16,
          const Text('Crime Type Filter', style: TextStyle(color: AppColors.textSecondary)),
          gap8,
          DropdownButtonFormField<String>(
            value: selected,
            items: types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => selected = v ?? selected),
            decoration: const InputDecoration(hintText: 'All Types'),
          ),
          gap16,
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _StatCard(count: 12, label: 'Robbery', color1: 0xFFFF7A45, color2: 0xFFFFA940),
              _StatCard(count: 28, label: 'Accident', color1: 0xFFFFB02E, color2: 0xFFFFD166),
              _StatCard(count: 7, label: 'Violence', color1: 0xFFB06AF7, color2: 0xFFDB7DFF),
            ],
          ),
          gap16,
          const SectionTitle('Recent Incidents'),
          gap12,
          ...incidents.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _IncidentTile(e),
              )),
        ],
      ),
    );
  }
}

class _GridBackdrop extends StatelessWidget {
  const _GridBackdrop();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter());
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF15223B);
    for (double x = 0; x < size.width; x += 24) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), p);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), p);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final int color1, color2;
  const _StatCard({required this.count, required this.label, required this.color1, required this.color2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(AppRadii.lg),
        color: AppColors.surfaceDark,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(color1).withOpacity(.16), Color(color2).withOpacity(.16)],
        ),
        boxShadow: AppShadows.soft,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: Colors.black.withOpacity(.25), borderRadius: const BorderRadius.all(AppRadii.pill)),
          child: Text('$count', style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        const Spacer(),
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
      ]),
    );
  }
}

class _Inc {
  final String type, place, time;
  const _Inc(this.type, this.place, this.time);
}

class _IncidentTile extends StatelessWidget {
  final _Inc inc;
  const _IncidentTile(this.inc);

  @override
  Widget build(BuildContext context) {
    return DarkCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            Expanded(child: Text(inc.type, style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.schedule, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(inc.time, style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
        gap6(),
        Row(
          children: const [
            Icon(Icons.place_outlined, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 6),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 22),
          child: Text(inc.place, style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ]),
    );
  }

  SizedBox gap6() => const SizedBox(height: 6);
}