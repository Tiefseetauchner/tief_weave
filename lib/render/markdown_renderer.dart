import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tief_weave/ast/markdown_ast.dart';

class MarkdownRenderer extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final builtTree = _buildWidgetTreeFromAst(ast);

    return Column(
      spacing: 12,
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
        return _renderParagraph(inlines);
      case Heading(:final level, :final inlines):
        return _renderHeadings(level, inlines);
      case Hrule():
        return _renderHrule();
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
    return Divider(height: 30, thickness: 3, color: style?.color);
  }

  Widget _renderInlines(
    List<Inline> inlines, {
    TextScaler? scaler,
    TextStyle? overrideStyle,
  }) {
    return SizedBox(
      width: width,
      child: Text.rich(
        TextSpan(
          style: style?.merge(overrideStyle),
          children: _renderInlineSpans(inlines, style),
        ),
        strutStyle: strutStyle,
        textAlign: textAlign,
        textDirection: textDirection,
        locale: locale,
        softWrap: softWrap,
        overflow: overflow,
        textScaler: scaler ?? textScaler,
        maxLines: maxLines,
        textWidthBasis: textWidthBasis,
        textHeightBehavior: textHeightBehavior,
        selectionColor: selectionColor,
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
