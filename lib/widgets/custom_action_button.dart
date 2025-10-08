// lib/widgets/custom_action_button.dart

import 'package:flutter/material.dart';

// An enum to define the different visual styles our button can have.
enum ButtonType { primary, secondary }

class CustomActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type; // We now pass in a type

  const CustomActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary, // Defaults to primary style
  });

  // Define all the colors in one place
  static const Color primaryColor = Color(0xFF299FE8);
  static const Color primaryHoverColor = Color(0xFF1F6F9D);
  static const Color secondaryColor = Color(0xFFBFBFBF);
  static const Color secondaryHoverColor = Color(0xFF858585);

  @override
  Widget build(BuildContext context) {
    // Determine styles based on the button type
    final Color defaultBackgroundColor;
    final Color hoverBackgroundColor;
    final Color textColor;
    final FontWeight fontWeight;

    switch (type) {
      case ButtonType.secondary:
        defaultBackgroundColor = secondaryColor;
        hoverBackgroundColor = secondaryHoverColor;
        textColor = Colors.black;
        fontWeight = FontWeight.normal; // 'regular' is FontWeight.normal
        break;
      case ButtonType.primary:
      default:
        defaultBackgroundColor = primaryColor;
        hoverBackgroundColor = primaryHoverColor;
        textColor = Colors.white;
        fontWeight = FontWeight.normal; // 'semi-bold' is FontWeight.w600
        break;
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
          (Set<MaterialState> states) {
            if (states.contains(MaterialState.hovered)) {
              return hoverBackgroundColor;
            }
            return defaultBackgroundColor;
          },
        ),
        textStyle: MaterialStateProperty.all<TextStyle>(
          TextStyle(
            fontFamily: 'Inter',
            fontWeight: fontWeight,
            fontSize: 16,
          ),
        ),
        foregroundColor: MaterialStateProperty.all<Color>(textColor),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
        ),
        padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
        minimumSize: MaterialStateProperty.all<Size>(const Size(150, 50)),
        elevation: MaterialStateProperty.all<double>(2),
      ),
      child: Text(text),
    );
  }
}