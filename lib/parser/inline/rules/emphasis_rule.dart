import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline/inline_parser.dart';
import 'package:tief_weave/parser/inline/rules/plain_text_rule.dart';
import 'package:tief_weave/parser/inline/rules/rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class EmphasisRule extends Rule {
  const EmphasisRule();

  @override
  bool process(
    TokenStream tokenStream,
    List<Inline> result,
    List<Token> terminator,
  ) {
    if (!tokenStream.expect<Asterisk>()) return false;

    final mark = tokenStream.mark();

    tokenStream.read();

    final inlineParser = InlineParser(
      [PlainTextRule()],
      terminator,
      (innerStream) => innerStream.expect<Asterisk>(),
    );

    final innerResult = inlineParser.parse(tokenStream);

    if (!tokenStream.expect<Asterisk>()) {
      tokenStream.reset(mark);
      return false;
    }

    tokenStream.read();

    result.add(Emphasis(innerResult));

    return true;
  }
}
