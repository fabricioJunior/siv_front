import 'package:comercial/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final agora = DateTime(2026, 11, 9, 12);
  EcommerceChaveMcp chave({DateTime? expiraEm, DateTime? revogadaEm}) => EcommerceChaveMcp(
        id: 1,
        nome: 'x',
        chaveMascarada: 'ch-...',
        expiraEm: expiraEm,
        revogadaEm: revogadaEm,
      );

  test('sem expiração nem revogação: ativa', () {
    expect(chave().situacaoEm(agora), SituacaoChaveMcp.ativa);
  });

  test('expiração futura: ativa; passada: expirada', () {
    expect(chave(expiraEm: DateTime(2026, 12, 1)).situacaoEm(agora), SituacaoChaveMcp.ativa);
    expect(chave(expiraEm: DateTime(2026, 8, 31)).situacaoEm(agora), SituacaoChaveMcp.expirada);
  });

  test('revogada vence expirada', () {
    final c = chave(expiraEm: DateTime(2026, 8, 31), revogadaEm: DateTime(2026, 6, 22));
    expect(c.situacaoEm(agora), SituacaoChaveMcp.revogada);
  });
}
