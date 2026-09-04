import 'dart:ui';

import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/text_direction/paragraph_text_direction_resolver.dart';

class InlineTextDirectionDetector {
  final ParagraphTextDirectionResolver resolver;

  const InlineTextDirectionDetector(this.resolver);

  TextDirection detect(List<Inline> inlines) {
    final buffer = StringBuffer();
    _writeInlines(inlines, buffer);

    return resolver.getTextDirection(buffer.toString());
  }

  void _writeInlines(List<Inline> inlines, StringBuffer buffer) {
    for (final inline in inlines) {
      switch (inline) {
        case PlainText(:final text):
          buffer.write(text);
        case Emphasis(:final children):
        case Strong(:final children):
        case Underline(:final children):
          _writeInlines(children, buffer);
      }
    }
  }
}
