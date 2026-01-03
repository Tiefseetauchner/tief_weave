import 'package:flutter_test/flutter_test.dart';
import 'package:tief_weave/ast/markdown_ast.dart';
import 'package:tief_weave/parser/markdown_ast_builder.dart';
import 'package:tief_weave/token/token.dart';

List<Token> _withEof(List<Token> tokens) => [...tokens, EndOfFile()];

void _expectInlineList(
  List<Inline> actual,
  List<Inline> expected, {
  String? context,
}) {
  expect(
    actual.length,
    expected.length,
    reason: '${context ?? 'Inline list'} length mismatch.',
  );

  for (var i = 0; i < expected.length; i++) {
    _expectInline(actual[i], expected[i], context: '${context ?? 'Inline'} $i');
  }
}

void _expectInline(Inline actual, Inline expected, {String? context}) {
  expect(
    actual.runtimeType,
    expected.runtimeType,
    reason: '${context ?? 'Inline'} type mismatch.',
  );

  if (actual is PlainText && expected is PlainText) {
    expect(
      actual.text,
      expected.text,
      reason: '${context ?? 'Inline'} text mismatch.',
    );
    return;
  }

  if (actual is Emphasis && expected is Emphasis) {
    _expectInlineList(actual.children, expected.children, context: context);
    return;
  }

  if (actual is Strong && expected is Strong) {
    _expectInlineList(actual.children, expected.children, context: context);
    return;
  }

  fail('${context ?? 'Inline'} has an unsupported type.');
}

void _expectBlockList(List<Block> actual, List<Block> expected) {
  expect(actual.length, expected.length, reason: 'Block count mismatch.');

  for (var i = 0; i < expected.length; i++) {
    _expectBlock(actual[i], expected[i], context: 'Block $i');
  }
}

void _expectBlock(Block actual, Block expected, {String? context}) {
  expect(
    actual.runtimeType,
    expected.runtimeType,
    reason: '${context ?? 'Block'} type mismatch.',
  );

  if (actual is Paragraph && expected is Paragraph) {
    _expectInlineList(actual.inlines, expected.inlines, context: context);
    return;
  }

  if (actual is Heading && expected is Heading) {
    expect(
      actual.level,
      expected.level,
      reason: '${context ?? 'Block'} heading level mismatch.',
    );
    _expectInlineList(actual.inlines, expected.inlines, context: context);
    return;
  }

  fail('${context ?? 'Block'} has an unsupported type.');
}

void _expectAst(MarkdownAst actual, List<Block> expectedBlocks) {
  _expectBlockList(actual.document.blocks, expectedBlocks);
}

void main() {
  group('MarkdownAstBuilder', () {
    test('throws without EndOfFile token', () {
      expect(
        () => MarkdownAstBuilder().build([Word('Missing')]),
        throwsArgumentError,
      );
    });

    test('builds empty tree', () {
      final ast = MarkdownAstBuilder().build([EndOfFile()]);

      _expectAst(ast, const []);
    });

    test('builds paragraph with plain text', () {
      final ast = MarkdownAstBuilder().build(
        _withEof([Word('Hello'), Space(), Word('world')]),
      );

      _expectAst(ast, const [
        Paragraph([PlainText('Hello world')]),
      ]);
    });

    test('builds multiple paragraphs separated by a blank line', () {
      final ast = MarkdownAstBuilder().build(
        _withEof([Word('First'), LineBreak(), LineBreak(), Word('Second')]),
      );

      _expectAst(ast, const [
        Paragraph([PlainText('First')]),
        Paragraph([PlainText('Second')]),
      ]);
    });

    test('builds a level-1 heading from a leading hash', () {
      final ast = MarkdownAstBuilder().build(
        _withEof([Hash(), Space(), Word('Title'), LineBreak()]),
      );

      _expectAst(ast, const [
        Heading(1, [PlainText('Title')]),
      ]);
    });

    test('builds a level-2 heading from two leading hashes', () {
      final ast = MarkdownAstBuilder().build(
        _withEof([Hash(), Hash(), Space(), Word('Subtitle')]),
      );

      _expectAst(ast, const [
        Heading(2, [PlainText('Subtitle')]),
      ]);
    });

    test('builds a level-2 heading from two leading hashes with emphasis', () {
      final ast = MarkdownAstBuilder().build(
        _withEof([
          Hash(),
          Hash(),
          Space(),
          Word('Subtitle'),
          Asterisk(),
          Word("Emphasized"),
          Asterisk(),
        ]),
      );

      _expectAst(ast, const [
        Heading(2, [
          PlainText('Subtitle'),
          Emphasis([PlainText("Emphasized")]),
        ]),
      ]);
    });

    test('builds emphasis inlines from single asterisks', () {
      final ast = MarkdownAstBuilder().build(
        _withEof([Asterisk(), Word('emph'), Asterisk()]),
      );

      _expectAst(ast, const [
        Paragraph([
          Emphasis([PlainText('emph')]),
        ]),
      ]);
    });

    test('builds strong inlines from double asterisks', () {
      final ast = MarkdownAstBuilder().build(
        _withEof([
          Asterisk(),
          Asterisk(),
          Word('bold'),
          Asterisk(),
          Asterisk(),
        ]),
      );

      _expectAst(ast, const [
        Paragraph([
          Strong([PlainText('bold')]),
        ]),
      ]);
    });
  });
}
