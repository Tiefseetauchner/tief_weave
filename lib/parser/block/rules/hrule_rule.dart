import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/block/rules/block_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class HruleRule extends BlockRule {
  const HruleRule();

  @override
  bool process(TokenStream tokenStream, List<Block> result) {
    final mark = tokenStream.mark();

    final lineChar = tokenStream.peekPastTokens<Space>();

    if (!(lineChar.isType<Dash>() ||
        lineChar.isType<Asterisk>() ||
        lineChar.isType<Underscore>())) {
      tokenStream.reset(mark);
      return false;
    }

    final lineContents = tokenStream.readTo([LineBreak()]);
    int lineCharCount = 0;

    for (final token in lineContents) {
      if (token.isType(lineChar)) {
        lineCharCount++;
      }
      if (!(token.isType(lineChar) || token.isType<Space>())) {
        tokenStream.reset(mark);
        return false;
      }
    }

    if (lineCharCount < 3) {
      tokenStream.reset(mark);
      return false;
    }

    result.add(Hrule());

    return true;
  }
}
