import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/block_parser.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class MarkdownAstBuilder {
  MarkdownAst build(List<Token> content) {
    if (content.last is! EndOfFile) {
      throw ArgumentError("Cannot build an AST without EndOfFile.");
    }

    final blockParserDecider = BlockParserDecider();

    final blocks = <Block>[];
    final tokenStream = TokenStream(content);

    while (true) {
      if (tokenStream.peek().isType<EndOfFile>()) {
        break;
      }

      tokenStream.skipTokens<LineBreak>();

      // NOTE: We're at the start of a new block if we reach this
      //       Thus, we can assert the block type by token type
      final peeked = tokenStream.peekPastSpaces();

      final blockParser = blockParserDecider.getParser(peeked);
      final block = blockParser.parse(tokenStream);
      blocks.add(block);
    }

    final document = Document(blocks);
    return MarkdownAst(document);
  }
}
