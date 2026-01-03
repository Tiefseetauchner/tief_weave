abstract class Token {
  final String content;

  @override
  String toString() {
    return content;
  }

  bool isType<T>([T? param]) {
    if (param != null) return runtimeType == param.runtimeType;

    return runtimeType == T;
  }

  Token(this.content);
}

class Hash extends Token {
  Hash() : super("#");
}

class Asterisk extends Token {
  Asterisk() : super("*");
}

class Underscore extends Token {
  Underscore() : super("_");
}

class Dash extends Token {
  Dash() : super("-");
}

class Equals extends Token {
  Equals() : super("=");
}

class Space extends Token {
  Space() : super(" ");
}

class LineBreak extends Token {
  LineBreak() : super("\n");
}

class Word extends Token {
  Word(super.content);
}

class EndOfFile extends Token {
  EndOfFile() : super("EOF");
}
