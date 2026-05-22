cat > lib/core/utils/pdf_generator.dart << 'ENDOFFILE'
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/user_model.dart';

class CoachingPdfGenerator {
  static Future<File> generateClientReport(UserModel user) async {
    final pdf = pw.Document();
    final meta = user.metabolicProfile;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(30),
        build: (context) => [
          // En-tête
          pw.Container(
            padding: const pw.EdgeInsets.all(20),
            decoration: pw.BoxDecoration(
              gradient: pw.LinearGradient(
                colors: [PdfColor.fromHex('#6C63FF'), PdfColor.fromHex('#FF6B6B')],
              ),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('RAPPORT DE COACHING',
                  style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
                pw.SizedBox(height: 8),
                pw.Text('Généré le ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: pw.TextStyle(color: PdfColors.white70, fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 25),

          // Informations client
          _sectionTitle('INFORMATIONS CLIENT'),
          pw.SizedBox(height: 10),
          _infoRow('Nom', '${user.firstName} ${user.lastName}'),
          _infoRow('Email', user.email),
          _infoRow('Genre', user.gender == 'male' ? 'Homme' : 'Femme'),
          if (user.experienceLevel != null)
            _infoRow('Expérience', {
              'beginner': 'Débutant', 'intermediate': 'Intermédiaire',
              'advanced': 'Avancé', 'elite': 'Élite'
            }[user.experienceLevel] ?? 'N/A'),
          pw.SizedBox(height: 20),

          // Mensurations
          _sectionTitle('MENSURATIONS'),
          pw.SizedBox(height: 10),
          if (user.heightCm != null) _infoRow('Taille', '${user.heightCm} cm'),
          if (user.currentWeightKg != null) _infoRow('Poids', '${user.currentWeightKg} kg'),
          if (user.waistCm != null) _infoRow('Tour de taille', '${user.waistCm} cm'),
          if (user.hipCm != null) _infoRow('Tour de hanches', '${user.hipCm} cm'),
          if (user.bodyFatPercentage != null && user.bodyFatPercentage! > 0)
            _infoRow('Masse grasse', '${user.bodyFatPercentage}%'),
          pw.SizedBox(height: 20),

          // Métabolisme
          if (meta != null) ...[
            _sectionTitle('ANALYSE MÉTABOLIQUE'),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#F0F0FF'),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(children: [
                _metabolicRow('Métabolisme de base (BMR)', '${meta['bmr']?.round()} kcal'),
                _metabolicRow('Dépense totale (TDEE)', '${meta['tdee']?.round()} kcal'),
                _metabolicRow('Objectif calorique', '${meta['targetCalories']} kcal'),
                _metabolicRow('Type morphologique', '${meta['bodyType']}'),
              ]),
            ),
            pw.SizedBox(height: 20),

            // Macros
            _sectionTitle('PLAN NUTRITIONNEL QUOTIDIEN'),
            pw.SizedBox(height: 10),
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#FFF5F5'),
                borderRadius: pw.BorderRadius.circular(10),
              ),
              child: pw.Column(children: [
                _macroRow('🥩 Protéines', '${meta['proteinGrams']}g', PdfColor.fromHex('#FF6B6B')),
                pw.SizedBox(height: 8),
                _macroRow('🍚 Glucides', '${meta['carbsGrams']}g', PdfColor.fromHex('#FFA726')),
                pw.SizedBox(height: 8),
                _macroRow('🥑 Lipides', '${meta['fatGrams']}g', PdfColor.fromHex('#42A5F5')),
                pw.SizedBox(height: 12),
                pw.Divider(),
                pw.SizedBox(height: 8),
                _infoRow('💧 Eau recommandée', '${meta['waterIntakeLiters']?.toStringAsFixed(1)} L'),
              ]),
            ),
          ],

          pw.SizedBox(height: 30),

          // Pied de page
          pw.Center(
            child: pw.Text('Rapport généré par Coach App - Pour usage professionnel',
              style: pw.TextStyle(color: PdfColors.grey, fontSize: 10, fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/rapport_${user.firstName}_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromHex('#6C63FF'), width: 2)),
      ),
      child: pw.Text(title,
        style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#6C63FF'))),
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

  static pw.Widget _metabolicRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 12)),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14, color: PdfColor.fromHex('#6C63FF'))),
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
            color: PdfColor.fromInt(color.value & 0xFFFFFF | 0x20000000),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: color)),
        ),
      ],
    );
  }
}
ENDOFFILE