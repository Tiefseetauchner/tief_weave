import 'package:bidi/bidi.dart';
import 'package:flutter/material.dart';

enum TextDirectionMode { ltr, rtl, auto }

extension TextDirectionConversion on TextDirectionMode {
  TextDirection getTextDirection(int embeddingLevel) {
    switch (this) {
      case TextDirectionMode.ltr:
        return TextDirection.ltr;
      case TextDirectionMode.rtl:
        return TextDirection.rtl;
      case TextDirectionMode.auto:
        return embeddingLevel == 0 ? TextDirection.ltr : TextDirection.rtl;
    }
  }
}

class ParagraphTextDirectionResolver {
  final TextDirectionMode mode;

  const ParagraphTextDirectionResolver({this.mode = TextDirectionMode.auto});

  TextDirection getTextDirection(String text) {
    return mode.getTextDirection(
      _calculateEmbeddingLevel(Normalization.decompose(text.codeUnits)),
    );
  }

  // NOTE (Tiefseetauchner): We're copying thee calculation of embedding level from github.com/olutter/bidi, as it isn't exposed in the library.
  //   This is sensible only because we're operating within Flutter text elements which do UAX #9 themselves. We only need to care about our
  //   paragraphs here.
  //
  // Copyright (c) 2020 Mahdi K. Fard
  // 3.3.1 The Paragraph Level
  // P2 - In each paragraph, find the first character of type L, AL, or R.
  // P3 - If a character is found in P2 and it is of type AL or R, then
  // set the paragraph embedding level to one; otherwise, set it to zero.
  int _calculateEmbeddingLevel(Normalization n) {
    int embeddingLevel = 0;
    for (var c in n.text) {
      final cType = getCharacterType(c);
      if (cType == CharacterType.rtl || cType == CharacterType.al) {
        embeddingLevel = 1;
        break;
      } else if (cType == CharacterType.ltr) {
        break;
      }
    }

    return embeddingLevel;
  }
}
