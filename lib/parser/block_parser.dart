import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/inline_parser.dart';
import 'package:tief_weave/parser/token_stream.dart';
import 'package:tief_weave/token/token.dart';

class BlockParserDecider {
  BlockParser getParser(Token token) {
    switch (token.runtimeType) {
      case const (Hash):
        return HeadingParser();
      default:
        return ParagraphParser();
    }
  }
}

sealed class BlockParser<T> {
  T parse(TokenStream tokenStream);
}

class HeadingParser extends BlockParser<Heading> {
  @override
  Heading parse(TokenStream tokenStream) {
    tokenStream.skipTokens<Space>();
    final level = tokenStream.skipTokens<Hash>();

    return Heading(level, InlineParser().parse(tokenStream, _hasBlockEnded));
  }

  bool _hasBlockEnded(TokenStream tokenStream) {
    if (tokenStream.peek().isType<EndOfFile>()) {
      return true;
    }

    return tokenStream.peek().isType<LineBreak>();
  }
}

class ParagraphParser extends BlockParser<Paragraph> {
  @override
  Paragraph parse(TokenStream tokenStream) {
    tokenStream.skipTokens<Space>();

    return Paragraph(InlineParser().parse(tokenStream, _hasBlockEnded));
  }

  bool _hasBlockEnded(TokenStream tokenStream) {
    final current = tokenStream.peek();

    if (current.isType<EndOfFile>()) {
      return true;
    }

    final next = tokenStream.peek(1);

    if (next.isType<EndOfFile>()) {
      return current.isType<LineBreak>();
    }

    return current.isType<LineBreak>() && next.isType<LineBreak>();
  }
}
