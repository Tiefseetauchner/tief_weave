import 'package:flutter_test/flutter_test.dart';
import 'package:tief_weave/markdown_parser.dart';
import 'package:tief_weave/token.dart';

class _TokenSpec {
  final Type type;
  final String content;

  const _TokenSpec(this.type, this.content);
}

void _expectTokens(List<Token> actual, List<_TokenSpec> expected) {
  expect(
    actual.length,
    expected.length,
    reason: 'Token count mismatch: $actual',
  );

  for (var i = 0; i < expected.length; i++) {
    expect(
      actual[i].runtimeType,
      expected[i].type,
      reason: 'Token $i type mismatch.',
    );
    expect(
      actual[i].content,
      expected[i].content,
      reason: 'Token $i content mismatch.',
    );
  }
}

void main() {
  group('MarkdownParser', () {
    test('tokenizes words and spaces', () {
      final tokens = MarkdownParser().parse('Hello world');

      _expectTokens(tokens, const [
        _TokenSpec(Word, 'Hello'),
        _TokenSpec(Space, ' '),
        _TokenSpec(Word, 'world'),
        _TokenSpec(EndOfFile, 'EOF'),
      ]);
    });

    test('tokenizes inline markers without surrounding spaces', () {
      final tokens = MarkdownParser().parse('a*b_c-d=1#h');

      _expectTokens(tokens, const [
        _TokenSpec(Word, 'a'),
        _TokenSpec(Asterisk, '*'),
        _TokenSpec(Word, 'b'),
        _TokenSpec(Underscore, '_'),
        _TokenSpec(Word, 'c'),
        _TokenSpec(Dash, '-'),
        _TokenSpec(Word, 'd'),
        _TokenSpec(Equals, '='),
        _TokenSpec(Word, '1'),
        _TokenSpec(Hash, '#'),
        _TokenSpec(Word, 'h'),
        _TokenSpec(EndOfFile, 'EOF'),
      ]);
    });

    test('tokenizes heading marker and following word', () {
      final tokens = MarkdownParser().parse('# Title');

      _expectTokens(tokens, const [
        _TokenSpec(Hash, '#'),
        _TokenSpec(Space, ' '),
        _TokenSpec(Word, 'Title'),
        _TokenSpec(EndOfFile, 'EOF'),
      ]);
    });

    test('tokenizes escaped characters', () {
      final tokens = MarkdownParser().parse('*notEscaped*\\*escaped\\*');

      _expectTokens(tokens, const [
        _TokenSpec(Asterisk, "*"),
        _TokenSpec(Word, "notEscaped"),
        _TokenSpec(Asterisk, "*"),
        _TokenSpec(Word, "*escaped*"),
        _TokenSpec(EndOfFile, 'EOF'),
      ]);
    });

    test('normalizes line endings before tokenizing', () {
      final tokens = MarkdownParser().parse('a\r\nb\rc\nd');

      _expectTokens(tokens, const [
        _TokenSpec(Word, 'a'),
        _TokenSpec(LineBreak, '\n'),
        _TokenSpec(Word, 'b'),
        _TokenSpec(LineBreak, '\n'),
        _TokenSpec(Word, 'c'),
        _TokenSpec(LineBreak, '\n'),
        _TokenSpec(Word, 'd'),
        _TokenSpec(EndOfFile, 'EOF'),
      ]);
    });

    test('escapes line breaks', () {
      final tokens = MarkdownParser().parse('a\\\r\nb\\\rc\\\nd');

      _expectTokens(tokens, const [
        _TokenSpec(Word, 'a\nb\nc\nd'),
        _TokenSpec(EndOfFile, 'EOF'),
      ]);
    });
  });
}
