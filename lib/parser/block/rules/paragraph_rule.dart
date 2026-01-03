import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/block/rules/block_rule.dart';
import 'package:tief_weave/parser/inline/inline_parser.dart';
import 'package:tief_weave/parser/inline/rules/emphasis_rule.dart';
import 'package:tief_weave/parser/inline/rules/plain_text_rule.dart';
import 'package:tief_weave/parser/inline/rules/strong_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class ParagraphRule extends BlockRule {
  const ParagraphRule();

  static const rules = [StrongRule(), EmphasisRule(), PlainTextRule()];

  @override
  bool process(TokenStream tokenStream, List<Block> result) {
    result.add(
      Paragraph(
        InlineParser(rules, [
          LineBreak(),
          LineBreak(),
        ], (_) => false).parse(tokenStream),
      ),
    );

    return true;
  }
}
