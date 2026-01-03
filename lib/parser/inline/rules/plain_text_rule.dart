import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline/rules/inline_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class PlainTextRule extends InlineRule {
  const PlainTextRule();

  @override
  bool process(
    TokenStream tokenStream,
    List<Inline> result,
    List<Token> terminator,
  ) {
    if (tokenStream.expectTypesEqual(terminator)) {
      return false;
    }

    var token = tokenStream.read();

    if (token.isType<LineBreak>()) {
      result.add(PlainText(" "));
    } else {
      result.add(PlainText(token.content));
    }

    return true;
  }
}
