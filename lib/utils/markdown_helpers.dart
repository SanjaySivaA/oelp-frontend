// lib/utils/markdown_helpers.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

// Note: We've removed the underscore `_` from the function name to make it public,
// so it can be used in other files.
Widget markdownImageBuilder(Uri uri, String? title, String? alt) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: CachedNetworkImage(
      imageUrl: uri.toString(),
      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, color: Colors.red),
          SizedBox(width: 8),
          Text('Failed to load image'),
        ],
      ),
    ),
  );
}