# tief_weave

TiefWeave is a completely oversimplified implementation of a TiefMark renderer.

TiefMark? I just made that up. It's a Markdown derivative that serves one purpose: be used in my teleprompter app.

We're fine. 

## TiefMark Specification

Imagine someone started implementing CommonMark but realised on page 12 that they wanted underlines. So \_Emph\_ is not *Emph*. Other than that, supported are:

- Headings
- Horizontal Rules
- Paragraphs
- Emphasis
- Strong
- Underline

Enjoy.

## Why not use flutter_markdown or similar?

Because styling them is a PITA and I don't care for PITAs. tief_weave integrates like a text field, with alignment and stuff, but also a width for the ultra fancy.

Why? Because that's the usecase I needed.
