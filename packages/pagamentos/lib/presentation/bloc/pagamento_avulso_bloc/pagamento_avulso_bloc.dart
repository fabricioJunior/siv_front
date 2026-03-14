import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:pagamentos/domain/models/pagamento_avulso.dart';
import 'package:pagamentos/use_cases.dart';

part 'pagamento_avulso_event.dart';
part 'pagamento_avulso_state.dart';

class PagamentoAvulsoBloc
    extends Bloc<PagamentoAvulsoEvent, PagamentoAvulsoState> {
  final CriarPagamentoAvulso criarPagamentoAvulso;
  final CriarIdempotencyKey criarIdempotencyKey;

  PagamentoAvulsoBloc(this.criarPagamentoAvulso, this.criarIdempotencyKey)
      : super(const PagamentoAvulsoState(step: PagamentoAvulsoStep.inicial)) {
    on<PagamentoAvulsoIniciou>(_onIniciou);
    on<PagamentoAvulsoCampoAlterado>(_onCampoAlterado);
    on<PagamentoAvulsoSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    PagamentoAvulsoIniciou event,
    Emitter<PagamentoAvulsoState> emit,
  ) {
    emit(
      state.copyWith(
        provider: 'infinitypay',
        amount: 0,
        idempotencyKey: criarIdempotencyKey.call(),
        step: PagamentoAvulsoStep.editando,
      ),
    );
  }

  FutureOr<void> _onCampoAlterado(
    PagamentoAvulsoCampoAlterado event,
    Emitter<PagamentoAvulsoState> emit,
  ) {
    emit(
      state.copyWith(
        provider: event.provider,
        amount: event.amount,
        description: event.description,
        idempotencyKey: event.idempotencyKey,
        customerNome: event.customerNome,
        customerDocumento: event.customerDocumento,
        customerEmail: event.customerEmail,
        customerTelefone: event.customerTelefone,
        step: PagamentoAvulsoStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    PagamentoAvulsoSalvou event,
    Emitter<PagamentoAvulsoState> emit,
  ) async {
    try {
      final amount = state.amount ?? 0;
      if (amount <= 0) {
        emit(
          state.copyWith(
            step: PagamentoAvulsoStep.validacaoInvalida,
            erro: 'Informe um valor maior que zero.',
          ),
        );
        return;
      }

      if ((state.description ?? '').trim().isEmpty ||
          (state.idempotencyKey ?? '').trim().isEmpty) {
        emit(
          state.copyWith(
            step: PagamentoAvulsoStep.validacaoInvalida,
            erro: 'Preencha todos os campos obrigatórios.',
          ),
        );
        return;
      }

      emit(state.copyWith(step: PagamentoAvulsoStep.salvando, erro: null));

      final pagamento = PagamentoAvulso.create(
        provider: state.provider ?? 'infinitypay',
        amount: amount,
        description: state.description!.trim(),
        idempotencyKey: state.idempotencyKey!.trim(),
        customer: PagamentoAvulsoCustomer.create(
          nome: (state.customerNome ?? '').trim(),
          documento: (state.customerDocumento ?? '').trim(),
          email: (state.customerEmail ?? '').trim(),
          telefone: (state.customerTelefone ?? '').trim(),
        ),
      );

      final response = await criarPagamentoAvulso.call(pagamento);

      emit(
        state.copyWith(
          pagamento: response,
          step: PagamentoAvulsoStep.salvo,
        ),
      );
    } catch (e, s) {
      addError(e, s);
      emit(
        state.copyWith(
          step: PagamentoAvulsoStep.falha,
          erro: 'Falha ao criar pagamento avulso.',
        ),
      );
    }
  }
}
