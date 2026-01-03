import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline/inline_parser.dart';
import 'package:tief_weave/parser/inline/rules/emphasis_rule.dart';
import 'package:tief_weave/parser/inline/rules/plain_text_rule.dart';
import 'package:tief_weave/parser/inline/rules/inline_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class UnderlineRule extends InlineRule {
  const UnderlineRule();

  @override
  bool process(
    TokenStream tokenStream,
    List<Inline> result,
    List<Token> terminator,
  ) {
    if (!tokenStream.expectTypesEqual([Underscore(), Underscore()])) {
      return false;
    }

    final mark = tokenStream.mark();

    tokenStream.readMany(2);

    final inlineParser = InlineParser(
      [EmphasisRule(), PlainTextRule()],
      terminator,
      (innerStream) =>
          innerStream.expectTypesEqual([Underscore(), Underscore()]),
    );

    final innerResult = inlineParser.parse(tokenStream);

    if (!tokenStream.expectTypesEqual([Underscore(), Underscore()])) {
      tokenStream.reset(mark);
      return false;
    }

    tokenStream.readMany(2);

    result.add(Underline(innerResult));

    return true;
  }
}
