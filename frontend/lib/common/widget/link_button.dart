import 'package:flutter/material.dart';

/// A Button for displaying text that is underlined on hover
class LinkButton extends StatefulWidget {
  /// Constructor for LinkButton
  const LinkButton({
    super.key,
    required this.onPressed,
    required this.text,
    required this.defaultStyle,
    required this.semanticsLabel,
    this.maxLines,
  });

  /// Method called on tap
  final void Function() onPressed;

  /// Text to display in button
  final String text;

  /// Normal un underlined style to display
  final TextStyle defaultStyle;

  /// Label of text
  final String semanticsLabel;

  /// Maximum number of lines
  final int? maxLines;

  /// The widget state
  @override
  LinkButtonState createState() => LinkButtonState();
}

/// State of a Link button
class LinkButtonState extends State<LinkButton> {
  TextStyle? _textStyle;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: widget.onPressed,
        onHover: (hovered) {
          setState(() {
            _textStyle = hovered
                ? widget.defaultStyle
                    .copyWith(decoration: TextDecoration.underline)
                : widget.defaultStyle;
          });
        },
        child: Text(
          widget.text,
          style: _textStyle ?? widget.defaultStyle,
          overflow: TextOverflow.fade,
          semanticsLabel: widget.semanticsLabel,
          maxLines: widget.maxLines,
        ),
      );
}
