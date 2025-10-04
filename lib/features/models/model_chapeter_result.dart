import 'package:mangaapp/features/models/model_chapeter.dart';

class ChapterPageResult {
  final List<Chapter> chapters;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  ChapterPageResult({
    required this.chapters,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });
}
