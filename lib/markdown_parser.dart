import 'package:tief_weave/token.dart';

class MarkdownParser {
  List<Token> parse(String text) {
    text = _sanitizeText(text);
    final result = <Token>[];
    final buffer = StringBuffer();

    bool nextCharEscaped = false;

    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);

      if (nextCharEscaped) {
        buffer.write(char);
        nextCharEscaped = false;
        continue;
      }

      switch (char) {
        case "\\":
          nextCharEscaped = true;
          break;
        case "#":
          _addWordFromBuffer(result, buffer);
          result.add(Hash());
          break;
        case "*":
          _addWordFromBuffer(result, buffer);
          result.add(Asterisk());
          break;
        case "_":
          _addWordFromBuffer(result, buffer);
          result.add(Underscore());
          break;
        case "=":
          _addWordFromBuffer(result, buffer);
          result.add(Equals());
          break;
        case "-":
          _addWordFromBuffer(result, buffer);
          result.add(Dash());
          break;
        case " ":
          _addWordFromBuffer(result, buffer);
          result.add(Space());
          break;
        case "\n":
          _addWordFromBuffer(result, buffer);
          result.add(LineBreak());
          break;
        default:
          buffer.write(char);
          break;
      }
    }

    if (buffer.isNotEmpty) {
      _addWordFromBuffer(result, buffer);
    }

    result.add(EndOfFile());

    return result;
  }

  String _sanitizeText(String text) {
    text = text.replaceAll("\r\n", "\n");
    text = text.replaceAll("\r", "\n");

    return text;
  }

  void _addWordFromBuffer(List<Token> result, StringBuffer buffer) {
    if (buffer.isEmpty) return;

    final bufferRes = buffer.toString();

    result.add(Word(bufferRes));

    buffer.clear();
  }
}
