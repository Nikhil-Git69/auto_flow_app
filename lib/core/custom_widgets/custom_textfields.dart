import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustTextfield extends StatefulWidget {
  final TextEditingController controller;
  final bool isPassword;
  final int? maxLines;
  final bool? isRequired;
  final TextInputType? keyboardType;
  final String? labelText;
  final bool readonly;
  final String? initialValue;
  final bool? alignWithLabel;
  final IconData? icon;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? formatter;

  const CustTextfield({
    super.key,
    required this.controller,
    this.initialValue,
    this.isRequired = false,
    this.readonly = false,
    this.isPassword = false,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.labelText,
    this.alignWithLabel,
    this.icon,
    this.validator,
    this.formatter,
  });

  @override
  State<CustTextfield> createState() => _CustTextfieldState();
}

class _CustTextfieldState extends State<CustTextfield> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      initialValue: widget.initialValue,
      inputFormatters: widget.formatter,
      readOnly: widget.readonly,
      validator: widget.validator,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _obscureText,
      maxLines: widget.maxLines,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        errorMaxLines: 1,
        errorStyle: const TextStyle(height: 1),
        alignLabelWithHint: widget.alignWithLabel,
        labelText: widget.labelText,
        labelStyle: TextStyle(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: colorScheme.primary)
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: colorScheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
        filled: true,
        fillColor: colorScheme.surface.withValues(alpha: 0.05),
      ),
      style: TextStyle(color: colorScheme.onSurface),
    );
  }
}
