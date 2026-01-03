import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class InlineParser {
  List<Inline> parse(
    TokenStream tokenStream,
    bool Function(TokenStream) hasBlockEnded,
  ) {
    tokenStream.skipTokens<LineBreak>();

    return [];
  }
}
