import 'package:flutter/material.dart';
import 'package:noor/features/quran/widgets/bookmarks_sheet.dart';

class BookmarksDialog extends StatelessWidget {
  const BookmarksDialog({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pop();
      showBookmarksSheet(context);
    });
    return const SizedBox.shrink();
  }
}
