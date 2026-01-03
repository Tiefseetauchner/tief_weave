import 'package:tief_weave/token/token.dart';

class TokenStream {
  final Iterable<Token> tokens;
  int _position = 0;

  int mark() {
    return _position;
  }

  void reset(int mark) {
    _position = mark;
  }

  TokenStream(this.tokens);

  Token peek([int offset = 0]) {
    if (_position + offset < 0 || _position + offset >= tokens.length) {
      return EndOfFile();
    }

    return tokens.elementAt(_position + offset);
  }

  Token peekPastTokens<T>() {
    final oldIndex = mark();

    skipTokens<T>();
    final peeked = peek();

    reset(oldIndex);

    return peeked;
  }

  bool testAtOffset(int offset, bool Function(TokenStream) predicate) {
    final targetIndex = _position + offset;

    if (targetIndex < 0 || targetIndex >= tokens.length) {
      return true;
    }

    final oldIndex = _position;
    _position = targetIndex;
    final result = predicate(this);
    _position = oldIndex;

    return result;
  }

  List<Token> peekMany([int len = 1, int offset = 0]) {
    final peeked = <Token>[];

    for (var i = 0; i < len; i++) {
      peeked.add(peek(offset + i));
    }

    return peeked;
  }

  bool expect<T>([int offset = 0]) {
    return peek(offset).isType<T>();
  }

  bool expectTypesEqual(List<Token> tokens) {
    for (var i = 0; i < tokens.length; i++) {
      if (peek(i).runtimeType != tokens[i].runtimeType) return false;
    }

    return true;
  }

  bool expectTypesEqualSkippingSpaces(List<Token> tokens) {
    final oldIndex = mark();

    try {
      for (var i = 0; i < tokens.length; i++) {
        if (read().isType<Space>()) {
          i--;
          continue;
        }

        if (read().runtimeType != tokens[i].runtimeType) {
          return false;
        }
      }
    } finally {
      reset(oldIndex);
    }

    return true;
  }

  Token read() {
    if (_position >= tokens.length) {
      throw RangeError("Tried to read beyond buffer length.");
    }

    var readToken = tokens.elementAt(_position);

    _position += 1;

    return readToken;
  }

  List<Token> readToEnd() {
    if (_position >= tokens.length) {
      throw RangeError("Tried to read beyond buffer length.");
    }

    final readTokens = <Token>[];

    while (_position < tokens.length) {
      readTokens.add(read());
    }

    return readTokens;
  }

  List<Token> readTo(List<Token> terminator) {
    if (_position >= tokens.length) {
      throw RangeError("Tried to read beyond buffer length.");
    }

    final readTokens = <Token>[];

    while (!expectTypesEqual(terminator) && !peek().isType<EndOfFile>()) {
      readTokens.add(read());
    }

    return readTokens;
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
