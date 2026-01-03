import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/block/rules/block_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class BlockParser {
  final List<BlockRule> rules;

  const BlockParser(this.rules);

  List<Block> parse(TokenStream tokenStream) {
    final result = <Block>[];

    while (true) {
      if (tokenStream.expect<EndOfFile>()) {
        break;
      }

      tokenStream.skipTokens<LineBreak>();

      for (final rule in rules) {
        if (rule.process(tokenStream, result)) {
          break;
        }
      }
    }

    return result;
  }
}
