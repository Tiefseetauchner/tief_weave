import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

abstract class InlineRule {
  const InlineRule();

  bool process(
    TokenStream tokenStream,
    List<Inline> result,
    List<Token> terminator,
  );
}
