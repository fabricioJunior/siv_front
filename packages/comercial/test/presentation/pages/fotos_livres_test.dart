import 'package:comercial/domain/models/pedido_entrada.dart';
import 'package:comercial/presentation/pages/pedido_entrada/fotos_livres.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'permissoes_fake.dart';

Widget _w({VoidCallback? onAdicionar}) => MaterialApp(
      theme: SivTheme.tema,
      home: Scaffold(
        body: FotosLivres(
          descricao: 'Vestido Luna',
          fotos: const [
            FotoLivre(id: 9, descricao: 'Vestido Luna', url: 'http://x/a.jpg', origem: 'fornecedor'),
          ],
          onAdicionar: onAdicionar,
        ),
      ),
    );

void main() {
  testWidgets('mostra a foto para qualquer um; "FOTO" só com permissão', (t) async {
    await registrarPermissoes({});
    await t.pumpWidget(_w(onAdicionar: () {}));
    expect(find.byKey(const Key('foto_livre_9')), findsOneWidget);
    expect(find.byKey(const Key('foto_livre_adicionar_Vestido Luna')), findsNothing);

    await registrarPermissoes({'PRDFM015'});
    await t.pumpWidget(_w(onAdicionar: () {}));
    expect(find.byKey(const Key('foto_livre_adicionar_Vestido Luna')), findsOneWidget);
  });

  test('resumo agrupa as fotos pela descrição', () {
    final r = EntradaResumo.fromJson({
      'pedidoId': 1,
      'fotosLivres': [
        {'id': 1, 'descricao': 'A', 'url': 'u1', 'origem': 'chegada'},
        {'id': 2, 'descricao': 'B', 'url': 'u2', 'origem': 'fornecedor'},
      ],
    });
    expect(r.fotosDaDescricao('A').map((f) => f.id), [1]);
  });
}
