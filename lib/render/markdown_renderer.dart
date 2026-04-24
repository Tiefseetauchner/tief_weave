import 'package:flutter/material.dart';
import 'package:tief_weave/ast/markdown_ast.dart';

class MarkdownRenderer extends StatefulWidget {
  final MarkdownAst ast;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final double? width;

  const MarkdownRenderer(
    this.ast, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.width,
  });

  @override
  State<MarkdownRenderer> createState() => _MarkdownRendererState();
}

class _MarkdownRendererState extends State<MarkdownRenderer> {
  late List<Widget> builtTree;

  @override
  void initState() {
    builtTree = _buildWidgetTreeFromAst(widget.ast);

    super.initState();
  }

  @override
  void didUpdateWidget(covariant MarkdownRenderer oldWidget) {
    if (widget.ast != oldWidget.ast) {
      builtTree = _buildWidgetTreeFromAst(widget.ast);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      mainAxisSize: MainAxisSize.max,
      children: builtTree,
    );
  }

  List<Widget> _buildWidgetTreeFromAst(MarkdownAst ast) {
    final result = <Widget>[];

    for (final block in ast.document.blocks) {
      result.add(_renderBlock(block));
    }

    return result;
  }

  Widget _renderBlock(Block block) {
    switch (block) {
      case Paragraph(:final inlines):
        return RepaintBoundary(child: _renderParagraph(inlines));
      case Heading(:final level, :final inlines):
        return RepaintBoundary(child: _renderHeadings(level, inlines));
      case Hrule():
        return RepaintBoundary(child: _renderHrule());
    }
  }

  Widget _renderParagraph(List<Inline> inlines) {
    return _renderInlines(inlines);
  }

  Widget _renderHeadings(int headingLevel, List<Inline> inlines) {
    return _renderInlines(
      inlines,
      scaler: TextScaler.linear(2 + headingLevel / -6),
      overrideStyle: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _renderHrule() {
    return Divider(height: 30, thickness: 3, color: widget.style?.color);
  }

  Widget _renderInlines(
    List<Inline> inlines, {
    TextScaler? scaler,
    TextStyle? overrideStyle,
  }) {
    return SizedBox(
      width: widget.width,
      child: Text.rich(
        TextSpan(
          style: widget.style?.merge(overrideStyle),
          children: _renderInlineSpans(inlines, widget.style),
        ),
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        locale: widget.locale,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaler: scaler ?? widget.textScaler,
        maxLines: widget.maxLines,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        selectionColor: widget.selectionColor,
      ),
    );
  }

  List<InlineSpan> _renderInlineSpans(
    List<Inline> inlines,
    TextStyle? baseStyle,
  ) {
    return [for (final inline in inlines) _renderInlineSpan(inline, baseStyle)];
  }

  InlineSpan _renderInlineSpan(Inline inline, TextStyle? baseStyle) {
    switch (inline) {
      case PlainText(:final text):
        return TextSpan(text: text, style: baseStyle);
      case Emphasis(:final children):
        final nextStyle =
            baseStyle?.merge(const TextStyle(fontStyle: FontStyle.italic)) ??
            const TextStyle(fontStyle: FontStyle.italic);
        return TextSpan(
          style: nextStyle,
          children: _renderInlineSpans(children, nextStyle),
        );
      case Strong(:final children):
        final nextStyle =
            baseStyle?.merge(const TextStyle(fontWeight: FontWeight.bold)) ??
            const TextStyle(fontWeight: FontWeight.bold);
        return TextSpan(
          style: nextStyle,
          children: _renderInlineSpans(children, nextStyle),
        );
      case Underline(:final children):
        final nextStyle =
            baseStyle?.merge(
              const TextStyle(decoration: TextDecoration.underline),
            ) ??
            const TextStyle(fontWeight: FontWeight.bold);
        return TextSpan(
          style: nextStyle,
          children: _renderInlineSpans(children, nextStyle),
        );
    }
  }
}
