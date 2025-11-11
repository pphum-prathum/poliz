import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../performance_summary.dart';

/// Builds a PDF bytes buffer for the current performance summary.
/// Use with printing.layoutPdf(...) to preview/save/share.
Future<Uint8List> buildPerformanceReportPdf(
    PerformanceSummary s, {
      required String periodLabel,
    }) async {
  final doc = pw.Document();

  // Convenience
  final m = s.messaging;
  final r = s.incidents.byRankLevel;

  pw.Widget kpi(String title, String value) => pw.Container(
    padding: const pw.EdgeInsets.all(10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300, width: 1),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
            )),
        pw.SizedBox(height: 4),
        pw.Text(value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            )),
      ],
    ),
  );

  pw.Widget rankBar(String label, int value, int max) {
    final factor = (max <= 0) ? 0.0 : (value / max).clamp(0, 1).toDouble();
    const totalWidth = 400.0; // Adjust if you want wider/narrower bars

    return pw.Column(children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text('$value',
              style: pw.TextStyle(
                fontSize: 12,
                color: PdfColors.blue800,
                fontWeight: pw.FontWeight.bold,
              )),
        ],
      ),
      pw.SizedBox(height: 4),
      pw.Stack(children: [
        pw.Container(
          width: totalWidth,
          height: 8,
          decoration: pw.BoxDecoration(
            color: PdfColors.grey300,
            borderRadius: pw.BorderRadius.circular(4),
          ),
        ),
        pw.Container(
          width: totalWidth * factor,
          height: 8,
          decoration: pw.BoxDecoration(
            color: PdfColors.blue700,
            borderRadius: pw.BorderRadius.circular(4),
          ),
        ),
      ]),
    ]);
  }

  final maxRank = [r.critical, r.high, r.medium, r.low].fold<int>(0, (p, e) => e > p ? e : p);

  doc.addPage(
    pw.MultiPage(
      pageTheme: pw.PageTheme(
        margin: const pw.EdgeInsets.all(36),
        theme: pw.ThemeData.withFont(
          base: pw.Font.helvetica(),
          bold: pw.Font.helveticaBold(),
        ),
      ),
      header: (c) => pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('GoodPoliz — Performance Report',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
          pw.Text(periodLabel, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
      build: (context) => [
        // Range & officer
        pw.SizedBox(height: 8),
        pw.Text(
          'Range: ${s.range.from} → ${s.range.to}${s.officer != null ? " — Officer: ${s.officer}" : ""}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),

        // KPIs
        pw.Text('Summary', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            kpi('Conversations', '${m.conversations}'),
            kpi('Messages Sent', '${m.messagesSent}'),
            kpi('Messages Received', '${m.messagesReceived}'),
            kpi('Active Days', '${m.activeDays}'),
          ],
        ),

        pw.SizedBox(height: 20),

        // Rank distribution
        pw.Text('Incident Rank Distribution',
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 10),
        rankBar('CRITICAL', r.critical, maxRank),
        pw.SizedBox(height: 10),
        rankBar('HIGH', r.high, maxRank),
        pw.SizedBox(height: 10),
        rankBar('MEDIUM', r.medium, maxRank),
        pw.SizedBox(height: 10),
        rankBar('LOW', r.low, maxRank),

        pw.SizedBox(height: 24),
        pw.Divider(),
        pw.SizedBox(height: 6),
        pw.Text(
          'Generated ${DateTime.now().toIso8601String()}',
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
        ),
      ],
    ),
  );

  return doc.save();
}