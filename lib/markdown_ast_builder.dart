import 'package:tief_weave/markdown_ast.dart';
import 'package:tief_weave/token.dart';

class MarkdownAstBuilder {
  MarkdownAst build(List<Token> content) {
    if (content.last is! EndOfFile) {
      throw ArgumentError("Cannot build an AST without EndOfFile.");
    }

    final blockParserDecider = _BlockParserDecider();

    final blocks = <Block>[];
    bool reachedEof = false;
    final tokenBuffer = _TokenBuffer(content);

    while (!reachedEof) {
      if (tokenBuffer.peek() != null &&
          tokenBuffer.peek()!.isType<EndOfFile>()) {
        reachedEof = true;
        break;
      }

      // NOTE: We're at the start of a new block if we reach this
      //       Thus, we can assert the block type by token type
      final peeked = tokenBuffer.peekPastSpaces();

      if (peeked == null) {
        throw RangeError("Reached end of tokens without EOF.");
      }

      final blockParser = blockParserDecider.getParser(peeked);
      final block = blockParser.parse(tokenBuffer);
      blocks.add(block);
    }

    final document = Document(blocks);
    return MarkdownAst(document);
  }
}

class _BlockParserDecider {
  _BlockParser getParser(Token token) {
    switch (token.runtimeType) {
      case const (Hash):
        return _HeadingParser();
      default:
        return _ParagraphParser();
    }
  }
}

sealed class _BlockParser<T> {
  T parse(_TokenBuffer tokenBuffer);
}

class _HeadingParser extends _BlockParser<Heading> {
  @override
  Heading parse(_TokenBuffer tokenBuffer) {
    tokenBuffer.skipTokens<Space>();
    final level = tokenBuffer.skipTokens<Hash>();

    return Heading(level, _InlineParser().parse(tokenBuffer, _hasBlockEnded));
  }

  bool _hasBlockEnded(_TokenBuffer tokenBuffer) {
    if (tokenBuffer.peek() == null || tokenBuffer.peek()!.isType<EndOfFile>()) {
      return true;
    }

    return tokenBuffer.peek()!.isType<LineBreak>();
  }
}

class _ParagraphParser extends _BlockParser<Paragraph> {
  @override
  Paragraph parse(_TokenBuffer tokenBuffer) {
    tokenBuffer.skipTokens<Space>();

    return Paragraph(_InlineParser().parse(tokenBuffer, _hasBlockEnded));
  }

  bool _hasBlockEnded(_TokenBuffer tokenBuffer) {
    if (tokenBuffer.peek() == null ||
        tokenBuffer.peek()!.isType<EndOfFile>() ||
        tokenBuffer.peek(1) == null ||
        tokenBuffer.peek(1)!.isType<EndOfFile>()) {
      return true;
    }

    return tokenBuffer.peek()!.isType<LineBreak>() &&
        tokenBuffer.peek(1)!.isType<LineBreak>();
  }
}

class _InlineParser {
  List<Inline> parse(
    _TokenBuffer tokenBuffer,
    bool Function(_TokenBuffer) hasBlockEnded,
  ) {
    final inlines = <Inline>[];

    while (!hasBlockEnded(tokenBuffer)) {
      final token = tokenBuffer.read();

      inlines.add(PlainText(token.content));
    }

    tokenBuffer.skipTokens<LineBreak>();

    return inlines;
  }
}

class _TokenBuffer {
  final List<Token> tokens;
  int _currIndex = 0;

  _TokenBuffer(this.tokens);

  Token? peek([int offset = 0]) {
    if (_currIndex + offset < 0 || _currIndex + offset >= tokens.length) {
      return null;
    }

    return tokens[_currIndex + offset];
  }

  Token? peekPastSpaces() {
    final oldIndex = _currIndex;

    skipTokens<Space>();
    final peeked = peek();

    _currIndex = oldIndex;

    return peeked;
  }

  List<Token?> peekMany([int len = 1, int offset = 0]) {
    final peeked = <Token?>[];

    for (var i = 0; i < len; i++) {
      peeked.add(peek(offset + i));
    }

    return peeked;
  }

  Token read() {
    if (_currIndex >= tokens.length) {
      throw RangeError("Tried to read beyond buffer length.");
    }

    var readToken = tokens[_currIndex];

    _currIndex += 1;

    return readToken;
  }

  List<Token> readMany([int len = 1]) {
    var readTokens = <Token>[];

    for (var i = 0; i < len; i++) {
      readTokens.add(read());
    }

    return readTokens;
  }

  int skipTokens<T>() {
    int skipped = 0;

    while (peek().runtimeType == T) {
      skipped++;
      read();
    }

    return skipped;
  }
}
