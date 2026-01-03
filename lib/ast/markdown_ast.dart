class MarkdownAst {
  final Document document;

  const MarkdownAst(this.document);

  const MarkdownAst.empty() : document = const Document.empty();
}

class Document {
  final List<Block> blocks;

  const Document(this.blocks);

  const Document.empty() : blocks = const [];
}

sealed class Block {
  const Block();
}

class Paragraph extends Block {
  final List<Inline> inlines;

  const Paragraph(this.inlines);
}

class Heading extends Block {
  final int level;
  final List<Inline> inlines;

  const Heading(this.level, this.inlines);
}

class Hrule extends Block {
  const Hrule();
}

sealed class Inline {
  const Inline();
}

class PlainText extends Inline {
  final String text;

  const PlainText(this.text);
}

class Emphasis extends Inline {
  final List<Inline> children;

  const Emphasis(this.children);
}

class Strong extends Inline {
  final List<Inline> children;

  const Strong(this.children);
}

class Underline extends Inline {
  final List<Inline> children;

  const Underline(this.children);
}
