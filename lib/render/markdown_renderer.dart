import 'package:flutter/material.dart';
import 'package:tief_weave/ast/markdown_ast.dart';

class MarkdownRendererController extends ChangeNotifier {
  _MarkdownRendererState? _state;

  void _attach(_MarkdownRendererState state) {
    _state = state;
  }

  void _detach(_MarkdownRendererState state) {
    if (_state == state) _state = null;
  }

  void _notifyLayout() => notifyListeners();

  int get blockCount => _state?._blockCount ?? 0;

  double? offsetOf(int blockIndex) => _state?._blockOffset(blockIndex);
}

class MarkdownRenderer extends StatefulWidget {
  final MarkdownAst ast;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  final TextScaler? textScaler;
  final int? maxLines;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;
  final double? width;
  final MarkdownRendererController? controller;

  const MarkdownRenderer(
    this.ast, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.width,
    this.controller,
  });

  @override
  State<MarkdownRenderer> createState() => _MarkdownRendererState();
}

class _MarkdownRendererState extends State<MarkdownRenderer> {
  List<GlobalKey> _blockKeys = const [];

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _syncBlockKeys();
    _scheduleLayoutNotification();
  }

  @override
  void didUpdateWidget(MarkdownRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach(this);
      widget.controller?._attach(this);
    }
    _syncBlockKeys();
    _scheduleLayoutNotification();
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    super.dispose();
  }

  void _syncBlockKeys() {
    final count = widget.ast.document.blocks.length;
    if (_blockKeys.length != count) {
      _blockKeys = List.generate(count, (_) => GlobalKey());
    }
  }

  void _scheduleLayoutNotification() {
    final controller = widget.controller;
    if (controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller._notifyLayout();
    });
  }

  int get _blockCount => widget.ast.document.blocks.length;

  double? _blockOffset(int blockIndex) {
    if (blockIndex < 0 || blockIndex >= _blockKeys.length) return null;

    final root = context.findRenderObject();
    final blockContext = _blockKeys[blockIndex].currentContext;
    if (root is! RenderBox || !root.hasSize || blockContext == null) {
      return null;
    }

    final box = blockContext.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return null;

    return box.localToGlobal(Offset.zero, ancestor: root).dy;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 32,
      mainAxisSize: MainAxisSize.max,
      children: _buildWidgetTreeFromAst(widget.ast),
    );
  }

  List<Widget> _buildWidgetTreeFromAst(MarkdownAst ast) {
    return [
      for (var i = 0; i < ast.document.blocks.length; i++)
        KeyedSubtree(
          key: _blockKeys[i],
          child: _renderBlock(ast.document.blocks[i]),
        ),
    ];
  }

  Widget _renderBlock(Block block) {
    switch (block) {
      case Paragraph(:final inlines):
        return RepaintBoundary(child: _renderParagraph(inlines));
      case Heading(:final level, :final inlines):
        return RepaintBoundary(child: _renderHeadings(level, inlines));
      case Hrule():
        return RepaintBoundary(child: _renderHrule());
    }
  }

  Widget _renderParagraph(List<Inline> inlines) {
    return _renderInlines(inlines);
  }

  Widget _renderHeadings(int headingLevel, List<Inline> inlines) {
    return _renderInlines(
      inlines,
      scaler: TextScaler.linear(2 + headingLevel / -6),
      overrideStyle: TextStyle(fontWeight: FontWeight.bold),
    );
  }

  Widget _renderHrule() {
    return Divider(height: 30, thickness: 3, color: widget.style?.color);
  }

  Widget _renderInlines(
    List<Inline> inlines, {
    TextScaler? scaler,
    TextStyle? overrideStyle,
  }) {
    return SizedBox(
      width: widget.width,
      child: Text.rich(
        TextSpan(
          style: widget.style?.merge(overrideStyle),
          children: _renderInlineSpans(inlines, widget.style),
        ),
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textDirection: widget.textDirection,
        locale: widget.locale,
        softWrap: widget.softWrap,
        overflow: widget.overflow,
        textScaler: scaler ?? widget.textScaler,
        maxLines: widget.maxLines,
        textWidthBasis: widget.textWidthBasis,
        textHeightBehavior: widget.textHeightBehavior,
        selectionColor: widget.selectionColor,
      ),
    );
  }

  List<InlineSpan> _renderInlineSpans(
    List<Inline> inlines,
    TextStyle? baseStyle,
  ) {
    return [for (final inline in inlines) _renderInlineSpan(inline, baseStyle)];
  }

  InlineSpan _renderInlineSpan(Inline inline, TextStyle? baseStyle) {
    switch (inline) {
      case PlainText(:final text):
        return TextSpan(text: text, style: baseStyle);
      case Emphasis(:final children):
        final nextStyle =
            baseStyle?.merge(const TextStyle(fontStyle: FontStyle.italic)) ??
            const TextStyle(fontStyle: FontStyle.italic);
        return TextSpan(
          style: nextStyle,
          children: _renderInlineSpans(children, nextStyle),
        );
      case Strong(:final children):
        final nextStyle =
            baseStyle?.merge(const TextStyle(fontWeight: FontWeight.bold)) ??
            const TextStyle(fontWeight: FontWeight.bold);
        return TextSpan(
          style: nextStyle,
          children: _renderInlineSpans(children, nextStyle),
        );
      case Underline(:final children):
        final nextStyle =
            baseStyle?.merge(
              const TextStyle(decoration: TextDecoration.underline),
            ) ??
            const TextStyle(fontWeight: FontWeight.bold);
        return TextSpan(
          style: nextStyle,
          children: _renderInlineSpans(children, nextStyle),
        );
    }
  }
}
