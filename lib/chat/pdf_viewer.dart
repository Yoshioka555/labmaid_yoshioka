import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

class PdfViewScreen extends StatefulWidget {
  final String pdfData;
  final String pdfName;

  const PdfViewScreen({Key? key, required this.pdfData, required this.pdfName}) : super(key:key);

  @override
  _PdfViewScreenState createState() => _PdfViewScreenState();
}

class _PdfViewScreenState extends State<PdfViewScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = const Center(child: CircularProgressIndicator());
    if (widget.pdfData != '') {
      child = PdfPreview(
        build: (format) => base64Decode(widget.pdfData),
      );
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          widget.pdfName,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        centerTitle: false,
        elevation: 0.0,
      ),
      body: child,
    );
  }
}