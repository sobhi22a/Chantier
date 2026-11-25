import 'package:flutter/widgets.dart';

/// Texte toujours ecrit de gauche a droite, meme dans une interface arabe (RTL).
///
/// Obligatoire pour les codes (`CH-ECO-UV18`, `DEM-001`), dates, montants et cotes
/// (`+3,40 m`) : ils ne doivent jamais etre retournes (CA-014.4, ADR 0008).
/// L'alignement suit le sens de l'interface (a droite en arabe, a gauche en francais).
class LtrText extends StatelessWidget {
  const LtrText(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  final String data;
  final TextStyle? style;

  /// Par defaut : debut de ligne de l'interface environnante.
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  Widget build(BuildContext context) {
    final ambientIsRtl = Directionality.of(context) == TextDirection.rtl;
    final align =
        textAlign ?? (ambientIsRtl ? TextAlign.right : TextAlign.left);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Text(
        data,
        style: style,
        textAlign: align,
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}
