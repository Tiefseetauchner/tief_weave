import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline/rules/inline_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class EmDashRule extends InlineRule {
  const EmDashRule();

  @override
  bool process(
    TokenStream tokenStream,
    List<Inline> result,
    List<Token> terminator,
  ) {
    if (tokenStream.expectTypesEqual(terminator)) {
      return false;
    }

    if (!tokenStream.peekMany(3).every((t) => t.isType<Dash>())) {
      return false;
    }

    result.add(PlainText(String.fromCharCode(8212)));

    tokenStream.readMany(3);

    return true;
  }
}
