import 'package:chantier_mobile/core/widgets/ltr_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(TextDirection direction, Widget child) => MaterialApp(
  home: Directionality(
    textDirection: direction,
    child: Scaffold(body: SizedBox(width: 300, child: child)),
  ),
);

TextDirection _innerDirection(WidgetTester tester) {
  final context = tester.element(find.text('CH-ECO-UV18'));
  return Directionality.of(context);
}

void main() {
  testWidgets('interface arabe : le code reste ecrit de gauche a droite', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(TextDirection.rtl, const LtrText('CH-ECO-UV18')),
    );

    expect(_innerDirection(tester), TextDirection.ltr);
  });

  testWidgets('interface arabe : aligne a droite comme le reste du texte', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(TextDirection.rtl, const LtrText('CH-ECO-UV18')),
    );

    final text = tester.widget<Text>(find.text('CH-ECO-UV18'));
    expect(text.textAlign, TextAlign.right);
  });

  testWidgets('interface francaise : aligne a gauche', (tester) async {
    await tester.pumpWidget(
      _host(TextDirection.ltr, const LtrText('CH-ECO-UV18')),
    );

    final text = tester.widget<Text>(find.text('CH-ECO-UV18'));
    expect(_innerDirection(tester), TextDirection.ltr);
    expect(text.textAlign, TextAlign.left);
  });

  testWidgets('alignement explicite respecte', (tester) async {
    await tester.pumpWidget(
      _host(
        TextDirection.rtl,
        const LtrText('CH-ECO-UV18', textAlign: TextAlign.center),
      ),
    );

    final text = tester.widget<Text>(find.text('CH-ECO-UV18'));
    expect(text.textAlign, TextAlign.center);
  });
}
