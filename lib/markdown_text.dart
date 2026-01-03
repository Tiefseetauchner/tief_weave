import 'package:flutter/widgets.dart';
import 'package:tief_weave/markdown_ast.dart';

class MarkdownText extends StatelessWidget {
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

  const MarkdownText(
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
  });

  @override
  Widget build(BuildContext context) {
    final builtTree = _buildWidgetTreeFromAst(ast);

    return Column(
      mainAxisAlignment: _mainAxisAlignmentFromTextAlign(textAlign),
      spacing: 1.35,
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
    }
  }

  MainAxisAlignment _mainAxisAlignmentFromTextAlign(TextAlign? textAlign) {
    switch (textAlign) {
      case TextAlign.center:
        return MainAxisAlignment.center;
      case TextAlign.end:
      case TextAlign.right:
        return MainAxisAlignment.end;
      case TextAlign.start:
      case TextAlign.left:
      case TextAlign.justify:
      case null:
        return MainAxisAlignment.start;
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

  Widget _renderInlines(
    List<Inline> inlines, {
    TextScaler? scaler,
    TextStyle? overrideStyle,
  }) {
    return Text.rich(
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
            const TextStyle(decoration: TextDecoration.underline);
        return TextSpan(
          style: nextStyle,
          children: _renderInlineSpans(children, nextStyle),
        );
    }
  }
}
