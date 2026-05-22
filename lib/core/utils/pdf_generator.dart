import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/user_model.dart';

class CoachingPdfGenerator {
  static Future<File> generateClientReport(UserModel user) async {
    final pdf = pw.Document();
    final meta = user.metabolicProfile;
    final purple = PdfColor.fromHex('#6C63FF');
    final red = PdfColor.fromHex('#FF6B6B');
    final orange = PdfColor.fromHex('#FFA726');
    final blue = PdfColor.fromHex('#42A5F5');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [purple, red],
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RAPPORT DE COACHING',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.SizedBox(height: 8),
                pw.Text('Date : ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: const pw.TextStyle(color: PdfColors.grey, fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 25),
          _sectionTitle('INFORMATIONS CLIENT', purple),
          pw.SizedBox(height: 10),
          _infoRow('Nom', '${user.firstName} ${user.lastName}'),
          _infoRow('Email', user.email),
          _infoRow('Genre', user.gender == 'male' ? 'Homme' : 'Femme'),
          pw.SizedBox(height: 20),
          _sectionTitle('MENSURATIONS', purple),
          pw.SizedBox(height: 10),
          if (user.heightCm != null) _infoRow('Taille', '${user.heightCm} cm'),
          if (user.currentWeightKg != null) _infoRow('Poids', '${user.currentWeightKg} kg'),
          if (user.waistCm != null) _infoRow('Tour de taille', '${user.waistCm} cm'),
          if (user.hipCm != null) _infoRow('Tour de hanches', '${user.hipCm} cm'),
          if (user.bodyFatPercentage != null && user.bodyFatPercentage! > 0)
            _infoRow('Masse grasse', '${user.bodyFatPercentage}%'),
          pw.SizedBox(height: 20),
          if (meta != null) ...[
            _sectionTitle('ANALYSE MÉTABOLIQUE', purple),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(children: [
                _metabolicRow('BMR', '${meta['bmr']?.round()} kcal', purple),
                _metabolicRow('TDEE', '${meta['tdee']?.round()} kcal', purple),
                _metabolicRow('Objectif', '${meta['targetCalories']} kcal', purple),
                _metabolicRow('Type', '${meta['bodyType']}', purple),
              ]),
            ),
            pw.SizedBox(height: 20),
            _sectionTitle('PLAN NUTRITIONNEL', purple),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(children: [
                _macroRow('Protéines', '${meta['proteinGrams']}g', red),
                pw.SizedBox(height: 8),
                _macroRow('Glucides', '${meta['carbsGrams']}g', orange),
                pw.SizedBox(height: 8),
                _macroRow('Lipides', '${meta['fatGrams']}g', blue),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 8),
                _infoRow('💧 Eau recommandée', '${meta['waterIntakeLiters']?.toStringAsFixed(1)} L'),
              ]),
            ),
          ],
          pw.SizedBox(height: 30),
          pw.Center(
            child: pw.Text('Généré par Coach App - Pour usage professionnel',
              style: pw.TextStyle(color: PdfColors.grey, fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/rapport_${user.firstName}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _sectionTitle(String title, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color, width: 2)),
      ),
      child: pw.Text(title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: color)),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static pw.Widget _metabolicRow(String label, String value, PdfColor color) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _macroRow(String label, String value, PdfColor color) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 14)),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}
