import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline/inline_parser.dart';
import 'package:tief_weave/parser/inline/rules/emphasis_rule.dart';
import 'package:tief_weave/parser/inline/rules/plain_text_rule.dart';
import 'package:tief_weave/parser/inline/rules/inline_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class StrongRule extends InlineRule {
  const StrongRule();

  @override
  bool process(
    TokenStream tokenStream,
    List<Inline> result,
    List<Token> terminator,
  ) {
    if (!tokenStream.expectTypesEqual([Asterisk(), Asterisk()])) return false;

    final mark = tokenStream.mark();

    tokenStream.readMany(2);

    final inlineParser = InlineParser(
      [EmphasisRule(), PlainTextRule()],
      terminator,
      (innerStream) => innerStream.expectTypesEqual([Asterisk(), Asterisk()]),
    );

    final innerResult = inlineParser.parse(tokenStream);

    if (!tokenStream.expectTypesEqual([Asterisk(), Asterisk()])) {
      tokenStream.reset(mark);
      return false;
    }

    tokenStream.readMany(2);

    result.add(Strong(innerResult));

    return true;
  }
}
