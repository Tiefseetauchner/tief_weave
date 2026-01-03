import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/block/rules/block_rule.dart';
import 'package:tief_weave/parser/inline/inline_parser.dart';
import 'package:tief_weave/parser/inline/rules/emphasis_rule.dart';
import 'package:tief_weave/parser/inline/rules/plain_text_rule.dart';
import 'package:tief_weave/parser/inline/rules/strong_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class HeadingRule extends BlockRule {
  const HeadingRule();

  static const rules = [StrongRule(), EmphasisRule(), PlainTextRule()];

  @override
  bool process(TokenStream tokenStream, List<Block> result) {
    final mark = tokenStream.mark();

    tokenStream.skipTokens<Space>();

    if (!tokenStream.expect<Hash>()) {
      tokenStream.reset(mark);
      return false;
    }

    final level = tokenStream.skipTokens<Hash>();

    result.add(
      Heading(
        level,
        InlineParser(rules, [LineBreak()], (_) => false).parse(tokenStream),
      ),
    );

    return true;
  }
}
