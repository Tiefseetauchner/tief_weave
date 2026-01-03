import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline/inline_parser.dart';
import 'package:tief_weave/parser/inline/rules/emphasis_rule.dart';
import 'package:tief_weave/parser/inline/rules/plain_text_rule.dart';
import 'package:tief_weave/parser/inline/rules/strong_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class BlockParserDecider {
  BlockParser getParser(Token token) {
    switch (token.runtimeType) {
      case const (Hash):
        return HeadingParser();
      default:
        return ParagraphParser();
    }
  }
}

sealed class BlockParser<T> {
  T parse(TokenStream tokenStream);
}

class HeadingParser extends BlockParser<Heading> {
  static const rules = [StrongRule(), EmphasisRule(), PlainTextRule()];
  @override
  Heading parse(TokenStream tokenStream) {
    tokenStream.skipTokens<Space>();
    final level = tokenStream.skipTokens<Hash>();

    return Heading(
      level,
      InlineParser(rules, [LineBreak()], (_) => false).parse(tokenStream),
    );
  }
}

class ParagraphParser extends BlockParser<Paragraph> {
  static const rules = [StrongRule(), EmphasisRule(), PlainTextRule()];

  @override
  Paragraph parse(TokenStream tokenStream) {
    tokenStream.skipTokens<Space>();

    return Paragraph(
      InlineParser(rules, [
        LineBreak(),
        LineBreak(),
      ], (_) => false).parse(tokenStream),
    );
  }
}
