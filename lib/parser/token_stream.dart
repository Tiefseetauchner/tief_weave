import 'package:tief_weave/token/token.dart';

class TokenStream {
  final List<Token> tokens;
  int _currIndex = 0;

  TokenStream(this.tokens);

  Token peek([int offset = 0]) {
    if (_currIndex + offset < 0 || _currIndex + offset >= tokens.length) {
      return EndOfFile();
    }

    return tokens[_currIndex + offset];
  }

  Token peekPastSpaces() {
    final oldIndex = _currIndex;

    skipTokens<Space>();
    final peeked = peek();

    _currIndex = oldIndex;

    return peeked;
  }

  bool testAtOffset(int offset, bool Function(TokenStream) predicate) {
    final targetIndex = _currIndex + offset;

    if (targetIndex < 0 || targetIndex >= tokens.length) {
      return true;
    }

    final oldIndex = _currIndex;
    _currIndex = targetIndex;
    final result = predicate(this);
    _currIndex = oldIndex;

    return result;
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
