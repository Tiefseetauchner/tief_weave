import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/token_stream.dart';

abstract class BlockRule {
  const BlockRule();

  bool process(TokenStream tokenStream, List<Block> result);
}
