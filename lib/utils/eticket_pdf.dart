import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/payment_success.dart';

/// Renders the e-ticket PDF for a confirmed (or pending) booking. The
/// platform share sheet picks the destination — Files, AirDrop, email, etc.
Future<Uint8List> buildETicketPdfBytes(PaymentSuccess data) async {
  // Default PDF fonts are Helvetica/ASCII-only and crash on any non-Latin
  // glyph (e.g. Vietnamese diacritics in destination names). Noto Sans
  // covers the full Latin Extended range, Vietnamese, CJK, etc.
  final regular = await PdfGoogleFonts.notoSansRegular();
  final bold = await PdfGoogleFonts.notoSansBold();

  final doc = pw.Document(
    title: 'Tripwise E-Ticket ${data.bookingCode}',
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  doc.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _header(),
          pw.SizedBox(height: 20),
          _divider(),
          pw.SizedBox(height: 16),
          _row('BOOKING ID', data.bookingCode.isEmpty ? '—' : data.bookingCode),
          _row('STATUS', data.statusLabel),
          _row('DESTINATION', data.destination, subtitle: data.destinationSubtitle),
          _row('ARRIVAL', data.arrivalDateLabel),
          if (data.ticket.code.isNotEmpty) _row('E-TICKET', data.ticket.code),
          if (data.displayAmount.isNotEmpty)
            _row('TOTAL', '${data.currency} ${data.displayAmount}'),
          if ((data.emailSentTo ?? '').isNotEmpty)
            _row('EMAILED TO', data.emailSentTo!),
          if (data.items.isNotEmpty) ...[
            pw.SizedBox(height: 16),
            _divider(),
            pw.SizedBox(height: 12),
            pw.Text(
              'ITEMS',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.grey700,
                letterSpacing: 0.6,
              ),
            ),
            pw.SizedBox(height: 8),
            for (final item in data.items) _itemRow(item),
          ],
          pw.SizedBox(height: 24),
          _divider(),
          pw.SizedBox(height: 12),
          pw.Text(
            'Present this ticket at check-in.',
            style: pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Issued by Tripwise',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}

pw.Widget _header() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'TRIPWISE',
        style: pw.TextStyle(
          fontSize: 24,
          fontWeight: pw.FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      pw.SizedBox(height: 2),
      pw.Text(
        'E-Ticket',
        style: pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
      ),
    ],
  );
}

pw.Widget _divider() {
  return pw.Container(height: 1, color: PdfColors.grey300);
}

pw.Widget _row(String label, String value, {String? subtitle}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 110,
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey700,
              letterSpacing: 0.5,
            ),
          ),
        ),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                value,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  subtitle,
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

pw.Widget _itemRow(PaymentSuccessItem item) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 8),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                item.title,
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                item.dateLabel,
                style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
              ),
              if (item.ticketCode.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  'Ticket: ${item.ticketCode}',
                  style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ],
            ],
          ),
        ),
        if (item.displayAmount.isNotEmpty)
          pw.Text(
            item.displayAmount,
            style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
          ),
      ],
    ),
  );
}
