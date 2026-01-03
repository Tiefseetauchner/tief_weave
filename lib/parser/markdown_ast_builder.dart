import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/block/block_parser.dart';
import 'package:tief_weave/parser/block/rules/heading_rule.dart';
import 'package:tief_weave/parser/block/rules/hrule_rule.dart';
import 'package:tief_weave/parser/block/rules/paragraph_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class MarkdownAstBuilder {
  static const rules = [HruleRule(), HeadingRule(), ParagraphRule()];

  MarkdownAst build(List<Token> content) {
    if (content.last is! EndOfFile) {
      throw ArgumentError("Cannot build an AST without EndOfFile.");
    }

    final tokenStream = TokenStream(content);
    final blocks = BlockParser(rules).parse(tokenStream);

    final document = Document(blocks);
    return MarkdownAst(document);
  }
}
