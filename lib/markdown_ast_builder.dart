import 'package:tief_weave/markdown_ast.dart';
import 'package:tief_weave/token.dart';

class MarkdownAstBuilder {
  MarkdownAst build(List<Token> content) {
    if (!content.any((token) => token is EndOfFile)) {
      throw ArgumentError("Cannot build an AST without EndOfFile.");
    }

    final cursor = _TokenCursor(content);
    final inlineParser = _InlineParser(cursor);
    final blocks = <Block>[];

    while (!cursor.isAtEnd) {
      _skipBlankLines(cursor);
      if (cursor.isAtEnd) break;

      final headingLevel = _peekHeadingLevel(cursor);
      if (headingLevel > 0) {
        blocks.add(_parseHeading(cursor, inlineParser, headingLevel));
      } else {
        blocks.add(_parseParagraph(cursor, inlineParser));
      }

      _consumeLineBreak(cursor);
    }

    return MarkdownAst(Document(blocks));
  }

  void _skipBlankLines(_TokenCursor cursor) {
    while (cursor.isType<LineBreak>()) {
      cursor.advance();
    }
  }

  int _peekHeadingLevel(_TokenCursor cursor) {
    var level = 0;

    while (cursor.isType<Hash>(level)) {
      level += 1;
    }

    if (level == 0) {
      return 0;
    }

    return cursor.isType<Space>(level) ? level : 0;
  }

  Heading _parseHeading(
    _TokenCursor cursor,
    _InlineParser inlineParser,
    int level,
  ) {
    for (var i = 0; i < level; i++) {
      cursor.advance();
    }

    _consumeSpace(cursor);

    final inlines = inlineParser.parseLine();

    return Heading(level, inlines);
  }

  Paragraph _parseParagraph(_TokenCursor cursor, _InlineParser inlineParser) {
    final inlines = inlineParser.parseLine();

    return Paragraph(inlines);
  }

  void _consumeLineBreak(_TokenCursor cursor) {
    if (cursor.isType<LineBreak>()) {
      cursor.advance();
    }
  }

  void _consumeSpace(_TokenCursor cursor) {
    if (cursor.isType<Space>()) {
      cursor.advance();
    }
  }
}

class _TokenCursor {
  final List<Token> _tokens;
  int _index = 0;

  _TokenCursor(this._tokens);

  bool get isAtEnd => current is EndOfFile;

  Token get current => _tokens[_index];

  bool isType<T extends Token>([int offset = 0]) {
    final token = peek(offset);

    return token is T;
  }

  Token? peek([int offset = 1]) {
    final index = _index + offset;
    if (index < 0 || index >= _tokens.length) {
      return null;
    }

    return _tokens[index];
  }

  Token advance() {
    final token = current;
    if (_index < _tokens.length - 1) {
      _index += 1;
    }

    return token;
  }

  bool hasMatchAhead(
    int startOffset,
    bool Function(Token token, Token? nextToken) matches,
  ) {
    var index = _index + startOffset;

    while (index < _tokens.length) {
      final token = _tokens[index];
      if (token is LineBreak || token is EndOfFile) {
        return false;
      }

      final nextToken =
          index + 1 < _tokens.length ? _tokens[index + 1] : null;

      if (matches(token, nextToken)) {
        return true;
      }

      index += 1;
    }

    return false;
  }
}

class _InlineParser {
  final _TokenCursor _cursor;

  _InlineParser(this._cursor);

  List<Inline> parseLine() {
    return _parseUntil(_isLineTerminator);
  }

  List<Inline> _parseUntil(bool Function(_TokenCursor cursor) shouldStop) {
    final inlines = <Inline>[];
    final buffer = _TextBuffer();

    while (!_cursor.isAtEnd && !shouldStop(_cursor)) {
      final inline = _tryParseInline();
      if (inline == null) {
        buffer.write(_cursor.advance());
        continue;
      }

      buffer.flushTo(inlines);
      inlines.add(inline);
    }

    buffer.flushTo(inlines);
    return inlines;
  }

  Inline? _tryParseInline() {
    if (_cursor.isType<Asterisk>()) {
      final inline = _parseAsteriskInline();
      if (inline != null) {
        return inline;
      }
    }

    if (_cursor.isType<Underscore>()) {
      final inline = _parseUnderline();
      if (inline != null) {
        return inline;
      }
    }

    return null;
  }

  Inline? _parseAsteriskInline() {
    if (_isStrongStart() && _cursor.hasMatchAhead(2, _isStrongMarker)) {
      return _parseStrong();
    }

    if (!_isStrongStart() && _cursor.hasMatchAhead(1, _isEmphasisMarker)) {
      return _parseEmphasis();
    }

    return null;
  }

  Inline? _parseUnderline() {
    if (_cursor.hasMatchAhead(1, _isUnderlineMarker)) {
      return _parseUnderlineInline();
    }

    return null;
  }

  Inline _parseStrong() {
    _cursor.advance();
    _cursor.advance();

    final children = _parseUntil(_isStrongStop);

    _consumeStrongClosing();

    return Strong(children);
  }

  Inline _parseEmphasis() {
    _cursor.advance();

    final children = _parseUntil(_isEmphasisStop);

    _consumeEmphasisClosing();

    return Emphasis(children);
  }

  Inline _parseUnderlineInline() {
    _cursor.advance();

    final children = _parseUntil(_isUnderlineStop);

    _consumeUnderlineClosing();

    return Underline(children);
  }

  bool _isStrongStart() {
    return _cursor.isType<Asterisk>() && _cursor.isType<Asterisk>(1);
  }

  bool _isStrongStop(_TokenCursor cursor) {
    return _isLineTerminator(cursor) || _isStrongClosing(cursor);
  }

  bool _isStrongClosing(_TokenCursor cursor) {
    return cursor.isType<Asterisk>() && cursor.isType<Asterisk>(1);
  }

  void _consumeStrongClosing() {
    if (_isStrongClosing(_cursor)) {
      _cursor.advance();
      _cursor.advance();
    }
  }

  bool _isEmphasisStop(_TokenCursor cursor) {
    return _isLineTerminator(cursor) || _isEmphasisClosing(cursor);
  }

  bool _isEmphasisClosing(_TokenCursor cursor) {
    return cursor.isType<Asterisk>() && !cursor.isType<Asterisk>(1);
  }

  void _consumeEmphasisClosing() {
    if (_isEmphasisClosing(_cursor)) {
      _cursor.advance();
    }
  }

  bool _isUnderlineStop(_TokenCursor cursor) {
    return _isLineTerminator(cursor) || _isUnderlineClosing(cursor);
  }

  bool _isUnderlineClosing(_TokenCursor cursor) {
    return cursor.isType<Underscore>();
  }

  void _consumeUnderlineClosing() {
    if (_isUnderlineClosing(_cursor)) {
      _cursor.advance();
    }
  }

  bool _isStrongMarker(Token token, Token? nextToken) {
    return token is Asterisk && nextToken is Asterisk;
  }

  bool _isEmphasisMarker(Token token, Token? nextToken) {
    return token is Asterisk && nextToken is! Asterisk;
  }

  bool _isUnderlineMarker(Token token, Token? nextToken) {
    return token is Underscore;
  }

  bool _isLineTerminator(_TokenCursor cursor) {
    return cursor.isType<LineBreak>() || cursor.isType<EndOfFile>();
  }
}

class _TextBuffer {
  final StringBuffer _buffer = StringBuffer();

  void write(Token token) {
    _buffer.write(token.content);
  }

  void flushTo(List<Inline> inlines) {
    if (_buffer.isEmpty) {
      return;
    }

    inlines.add(PlainText(_buffer.toString()));
    _buffer.clear();
  }
}
