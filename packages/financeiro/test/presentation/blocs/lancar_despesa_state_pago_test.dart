import 'package:financeiro/presentation/blocs/lancar_despesa_bloc/lancar_despesa_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = LancarDespesaState(step: LancarDespesaStep.editando);
  final ontem = DateTime.now().subtract(const Duration(days: 1));
  final amanha = DateTime.now().add(const Duration(days: 1));

  test('avulsa retroativa nasce paga; hoje/futura, pendente', () {
    expect(base.copyWith(dataPagamento: ontem).pago, isTrue);
    expect(base.copyWith(dataPagamento: DateTime.now()).pago, isFalse);
    expect(base.copyWith(dataPagamento: amanha).pago, isFalse);
  });

  test('escolha manual vence o automático; só vale pra avulsa', () {
    expect(base.copyWith(dataPagamento: ontem, pagoManual: false).pago, isFalse);
    expect(base.copyWith(dataPagamento: amanha, pagoManual: true).pago, isTrue);
    expect(
      base.copyWith(dataPagamento: ontem, modo: ModoLancamentoDespesa.parcelada).pago,
      isFalse,
    );
  });
}
