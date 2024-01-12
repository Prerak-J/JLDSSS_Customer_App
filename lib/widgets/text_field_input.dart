import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;
  final Icon icon;
  final int? maxLength;
  final String? prefixText;
  const TextFieldInput({
    super.key,
    required this.textEditingController,
    required this.hintText,
    this.isPass = false,
    required this.textInputType,
    this.icon = const Icon(Icons.text_snippet_outlined),
    this.maxLength,
    this.prefixText,
  });

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder(borderSide: Divider.createBorderSide(context));
    return Container(
      color: Colors.white10,
      child: TextField(
        controller: textEditingController,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: hintText,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          prefixText: prefixText,
          prefixIcon: icon,
          // iconColor: Colors.grey,
          border: inputBorder,
          focusedBorder: inputBorder,
          enabledBorder: inputBorder,
          filled: true,
          contentPadding: const EdgeInsets.all(8),
        ),
        keyboardType: textInputType,
        obscureText: isPass,
      ),
    );
  }
}
