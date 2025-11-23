import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class TexText extends StatelessWidget {
  final String text;
  final TextStyle? style;

  const TexText(this.text, {super.key, this.style});

  @override
  Widget build(BuildContext context) {
    // Default text style if none is provided
    final defaultStyle = style ?? const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Inter');

    // 1. Split the text by the '$' delimiter
    // Example: "Let $f(x)$ be..." -> ["Let ", "f(x)", " be..."]
    final List<String> parts = text.split(r'$');
    
    List<InlineSpan> spans = [];

    for (int i = 0; i < parts.length; i++) {
      if (i % 2 == 0) {
        // 2. Even parts are normal text (e.g., "Let ", " be...")
        if (parts[i].isNotEmpty) {
          spans.add(TextSpan(text: parts[i], style: defaultStyle));
        }
      } else {
        // 3. Odd parts are Math/LaTeX (e.g., "f(x)")
        if (parts[i].isNotEmpty) {
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Math.tex(
              parts[i],
              textStyle: defaultStyle,
              // mathStyle: MathStyle.text, // Optional: enforces inline style
            ),
          ));
        }
      }
    }

    // 4. Return a RichText that combines both types gracefully
    return RichText(
      text: TextSpan(children: spans),
    );
  }
}