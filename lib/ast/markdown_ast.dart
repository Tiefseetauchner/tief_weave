import 'package:collection/collection.dart';

class MarkdownAst {
  final Document document;

  const MarkdownAst(this.document);

  const MarkdownAst.empty() : document = const Document.empty();

  @override
  bool operator ==(Object other) =>
      other is MarkdownAst && document == other.document;

  @override
  int get hashCode => document.hashCode;
}

class Document {
  final List<Block> blocks;

  const Document(this.blocks);

  const Document.empty() : blocks = const [];

  @override
  bool operator ==(Object other) =>
      other is Document && const ListEquality().equals(blocks, other.blocks);

  @override
  int get hashCode => const ListEquality().hash(blocks);
}

sealed class Block {
  const Block();
}

class Paragraph extends Block {
  final List<Inline> inlines;

  const Paragraph(this.inlines);

  @override
  bool operator ==(Object other) =>
      other is Paragraph && const ListEquality().equals(inlines, other.inlines);

  @override
  int get hashCode => const ListEquality().hash(inlines);
}

class Heading extends Block {
  final int level;
  final List<Inline> inlines;

  const Heading(this.level, this.inlines);

  @override
  bool operator ==(Object other) =>
      other is Heading &&
      level == other.level &&
      const ListEquality().equals(inlines, other.inlines);

  @override
  int get hashCode => Object.hash(level, const ListEquality().hash(inlines));
}

class Hrule extends Block {
  const Hrule();

  @override
  bool operator ==(Object other) => other is Hrule;

  @override
  int get hashCode => (Hrule).hashCode;
}

sealed class Inline {
  const Inline();
}

class PlainText extends Inline {
  final String text;

  const PlainText(this.text);

  @override
  bool operator ==(Object other) => other is PlainText && text == other.text;

  @override
  int get hashCode => text.hashCode;
}

class Emphasis extends Inline {
  final List<Inline> children;

  const Emphasis(this.children);

  @override
  bool operator ==(Object other) =>
      other is Emphasis &&
      const ListEquality().equals(children, other.children);

  @override
  int get hashCode => const ListEquality().hash(children);
}

class Strong extends Inline {
  final List<Inline> children;

  const Strong(this.children);

  @override
  bool operator ==(Object other) =>
      other is Strong && const ListEquality().equals(children, other.children);

  @override
  int get hashCode => const ListEquality().hash(children);
}

class Underline extends Inline {
  final List<Inline> children;

  const Underline(this.children);

  @override
  bool operator ==(Object other) =>
      other is Underline &&
      const ListEquality().equals(children, other.children);

  @override
  int get hashCode => const ListEquality().hash(children);
}
