import 'package:flutter/widgets.dart';
import 'package:tief_weave/markdown_ast.dart';

class Markdown extends StatelessWidget {
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

  const Markdown(
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

    return Stack(children: builtTree);
  }

  List<Widget> _buildWidgetTreeFromAst(MarkdownAst ast) {
    final result = <Widget>[];

    for (final block in ast.document.blocks) {
      result.add(_renderBlock(block));
    }

    return result;
  }

  Widget _renderBlock(Block block) {
    switch (block.runtimeType) {
      case Paragraph _:
        return Text(
          "Paragraph",
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaler: textScaler,
          maxLines: maxLines,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        );
      case Heading _:
        return Text(
          "Heading",
          key: key,
          style: style,
          strutStyle: strutStyle,
          textAlign: textAlign,
          textDirection: textDirection,
          locale: locale,
          softWrap: softWrap,
          overflow: overflow,
          textScaler: textScaler,
          maxLines: maxLines,
          textWidthBasis: textWidthBasis,
          textHeightBehavior: textHeightBehavior,
          selectionColor: selectionColor,
        );
      default:
        throw ArgumentError(
          "Block type '${block.runtimeType}' is not recognized as a renderable element.",
        );
    }
  }
}
