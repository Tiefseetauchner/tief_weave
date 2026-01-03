import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/block/rules/block_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class HruleRule extends BlockRule {
  const HruleRule();

  @override
  bool process(TokenStream tokenStream, List<Block> result) {
    if (!tokenStream.expectTypesEqual([Dash(), Dash(), Dash()])) return false;

    final mark = tokenStream.mark();

    final lineContents = tokenStream.readTo([LineBreak()]);
    bool spaceHit = false;

    for (final token in lineContents) {
      if (token.isType<Space>()) spaceHit = true;
      if (spaceHit && !token.isType<Space>()) return false;
      if (!spaceHit && !token.isType<Dash>()) return false;
    }

    result.add(Hrule());

    return true;
  }
}
