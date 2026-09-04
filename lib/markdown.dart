import 'package:flutter/widgets.dart';
import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/render/markdown_renderer.dart';
import 'package:tief_weave/parser/markdown_ast_builder.dart';
import 'package:tief_weave/text_direction/paragraph_text_direction_resolver.dart';
import 'package:tief_weave/token/markdown_tokenizer.dart';

export 'package:tief_weave/ast/markdown_ast.dart';
export 'package:tief_weave/parser/markdown_ast_builder.dart';
export 'package:tief_weave/render/markdown_renderer.dart';
export 'package:tief_weave/token/markdown_tokenizer.dart';
export 'package:tief_weave/text_direction/paragraph_text_direction_resolver.dart';

class Markdown extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirectionMode? textDirectionMode;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final double? width;
  final MarkdownRendererController? controller;

  const Markdown(
    this.text, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirectionMode,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.width,
    this.controller,
  });

  @override
  State<Markdown> createState() => _MarkdownState();
}

class _MarkdownState extends State<Markdown> {
  late MarkdownAst ast;

  @override
  void initState() {
    ast = MarkdownAstBuilder().build(MarkdownTokenizer().parse(widget.text));

    super.initState();
  }

  @override
  void didUpdateWidget(covariant Markdown oldWidget) {
    if (widget.text != oldWidget.text) {
      ast = MarkdownAstBuilder().build(MarkdownTokenizer().parse(widget.text));
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownRenderer(
      ast,
      style: widget.style,
      strutStyle: widget.strutStyle,
      textAlign: widget.textAlign,
      textDirectionMode: widget.textDirectionMode,
      locale: widget.locale,
      softWrap: widget.softWrap,
      overflow: widget.overflow,
      textScaler: widget.textScaler,
      maxLines: widget.maxLines,
      textWidthBasis: widget.textWidthBasis,
      textHeightBehavior: widget.textHeightBehavior,
      selectionColor: widget.selectionColor,
      width: widget.width,
      controller: widget.controller,
    );
  }
}
