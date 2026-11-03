import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leitor_camera/leitor_camera.dart';

void main() {
  late void Function(String) lerCodigo;
  late void Function(Object, bool) falhar;
  late Future<String?> resultado;

  Future<void> abrir(WidgetTester t) async {
    LeitorCamera.construtorTeste = (_, _, onCodigo, onErro) {
      lerCodigo = onCodigo;
      falhar = onErro;
      return const SizedBox();
    };
    addTearDown(() => LeitorCamera.construtorTeste = null);
    late BuildContext ctx;
    await t.pumpWidget(MaterialApp(
      home: Builder(builder: (c) {
        ctx = c;
        return const SizedBox();
      }),
    ));
    resultado = LeitorCamera.escanear(ctx);
    await t.pump(const Duration(seconds: 1));
  }

  testWidgets('código lido retorna string', (t) async {
    await abrir(t);
    lerCodigo('7891234567895');
    await t.pump(const Duration(seconds: 1));
    expect(await resultado, '7891234567895');
  });

  testWidgets('cancelar retorna null', (t) async {
    await abrir(t);
    Navigator.of(t.element(find.byType(LeitorCameraView, skipOffstage: false))).pop();
    await t.pump(const Duration(seconds: 1));
    expect(await resultado, isNull);
  });

  testWidgets('permissão negada retorna null', (t) async {
    await abrir(t);
    falhar(Exception('negada'), true);
    await t.pump(const Duration(seconds: 1));
    expect(await resultado, isNull);
  });

  testWidgets('erro genérico retorna null', (t) async {
    await abrir(t);
    falhar(Exception('x'), false);
    await t.pump(const Duration(seconds: 1));
    expect(await resultado, isNull);
  });
}
