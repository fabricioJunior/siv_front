import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/cor_dto.dart';
import 'package:produtos/data/remote/dtos/estampa_dto.dart';
import 'package:produtos/data/remote/dtos/tamanho_dto.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentantion/blocs/produtos_da_referencia_bloc/produtos_da_referencia_bloc.dart'
    show chaveComboGrade;
import 'package:produtos/presentantion/widgets/grade_quantidade_etiquetas.dart';

void main() {
  final azul = CorDto(id: 9, inativo: false, nome: 'azul bebe');
  final preto = CorDto(id: 13, inativo: false, nome: 'PRETO');
  final t38 = TamanhoDto(id: 5, inativo: false, nome: '38');
  final un = TamanhoDto(id: 14, inativo: false, nome: 'UN');
  final grogu = EstampaDto(id: 3, inativo: false, nome: 'GROGU');

  Produto p(int id, Cor cor, Tamanho tam, [Estampa? est]) => Produto.create(
    id: id,
    referenciaId: 1,
    idExterno: '$id',
    corId: cor.id!,
    tamanhoId: tam.id!,
    estampaId: est?.id,
    cor: cor,
    tamanho: tam,
    estampa: est,
  );

  testWidgets('renderiza linha por cor x estampa, campo só onde o produto existe e propaga a quantidade', (tester) async {
    final produtos = [
      p(1, azul, t38, grogu),
      p(2, azul, un, grogu),
      p(3, preto, un), // PRETO liso: só UN
    ];
    final mapa = {
      for (final x in produtos) chaveComboGrade(x.cor!.id!, x.tamanho!.id!, x.estampaId): x,
    };
    final controllers = <int, TextEditingController>{};
    final alteracoes = <int, int>{};

    await tester.pumpWidget(
      MaterialApp(
        theme: SivTheme.tema,
        home: Scaffold(
          body: SingleChildScrollView(
            child: GradeQuantidadeEtiquetas(
              produtos: produtos,
              tamanhos: [t38, un],
              mapaProduto: mapa,
              quantidades: const {},
              controllerDe: (id, _) => controllers.putIfAbsent(id, TextEditingController.new),
              aoAlterar: (id, q) => alteracoes[id] = q,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('COR'), findsOneWidget);
    expect(find.text('ESTAMPA'), findsOneWidget);
    expect(find.text('GROGU'), findsNWidgets(1)); // uma linha azul bebe · GROGU
    expect(find.text('Liso'), findsOneWidget);
    // 3 produtos = 3 campos; PRETO liso sem tamanho 38 = 1 célula "—"
    expect(find.byType(TextField), findsNWidgets(3));
    expect(find.text('—'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '4');
    expect(alteracoes, {1: 4});
  });
}
