import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline/rules/inline_rule.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class InlineParser {
  final List<InlineRule> rules;
  final List<Token> terminator;
  final bool Function(TokenStream) shouldTerminate;

  const InlineParser(this.rules, this.terminator, this.shouldTerminate);

  List<Inline> parse(TokenStream tokenStream) {
    tokenStream.skipTokens<LineBreak>();
    final result = <Inline>[];

    while (true) {
      if (shouldTerminate(tokenStream) ||
          tokenStream.expectTypesEqual(terminator) ||
          tokenStream.expect<EndOfFile>()) {
        break;
      }

      for (final rule in rules) {
        if (rule.process(tokenStream, result, terminator)) {
          break;
        }
      }
    }

    return result;
  }
}
