import 'package:flutter/material.dart';
import 'package:mangaapp/features/models/model_chapeter.dart';

class ChapterReaderPage extends StatefulWidget {
  final Chapter chapter;
  final String mangaTitle;
  const ChapterReaderPage({
    super.key,
    required this.chapter,
    required this.mangaTitle,
  });
  @override
  State<ChapterReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ChapterReaderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.mangaTitle)),
      body: Center(child: Text('Reader Page')),
    );
  }
}
