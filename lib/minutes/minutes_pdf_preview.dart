import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';


class MinutesPdfPreview extends StatelessWidget {
  const MinutesPdfPreview(this.minutes, this.title, {super.key});

  final String minutes;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.blue.shade800,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: PdfPreview(
        build: (format) => buildPdf(format, minutes),
      ),
    );
  }

  // PDFファイルを生成
  Future<Uint8List> buildPdf(PdfPageFormat format, String minutes) async {
    final pw.Document doc = pw.Document(version: PdfVersion.pdf_1_5, compress: true);

    // 日本語フォントの読み込み
    final fontData = await rootBundle.load("assets/fonts/NotoSansJP-VariableFont_wght.ttf");
    final ttf = pw.Font.ttf(fontData);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginTop: 10,
          marginBottom: 10,
          marginLeft: 20,
          marginRight: 20,
        ),
        build: (pw.Context context) {
          return [
            // 長いテキストをページ分割する
            pw.Paragraph(
              text: minutes,
              style: pw.TextStyle(
                font: ttf,
                fontSize: 20,
              ),
            ),
          ];
        },
      ),
    );

    return doc.save();
  }

}