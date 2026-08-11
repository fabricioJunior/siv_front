import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart';

part 'ecommerce_configuracao_event.dart';
part 'ecommerce_configuracao_state.dart';

class EcommerceConfiguracaoBloc
    extends Bloc<EcommerceConfiguracaoEvent, EcommerceConfiguracaoState> {
  final RecuperarEcommerce _recuperarEcommerce;
  final SalvarEcommerce _salvarEcommerce;

  EcommerceConfiguracaoBloc(this._recuperarEcommerce, this._salvarEcommerce)
      : super(
          const EcommerceConfiguracaoState(
            step: EcommerceConfiguracaoStep.inicial,
          ),
        ) {
    on<EcommerceConfiguracaoIniciou>(_onIniciou);
    on<EcommerceConfiguracaoEditou>(_onEditou);
    on<EcommerceConfiguracaoSalvou>(_onSalvou);
  }

  FutureOr<void> _onIniciou(
    EcommerceConfiguracaoIniciou event,
    Emitter<EcommerceConfiguracaoState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          step: EcommerceConfiguracaoStep.carregando,
          empresaId: event.empresaId,
        ),
      );

      if (event.ecommerceId != null) {
        final ecommerce = await _recuperarEcommerce.call(event.ecommerceId!);
        emit(EcommerceConfiguracaoState.fromModel(ecommerce));
        return;
      }

      emit(
        EcommerceConfiguracaoState(
          empresaId: event.empresaId,
          step: EcommerceConfiguracaoStep.editando,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(step: EcommerceConfiguracaoStep.falha));
      addError(e, s);
    }
  }

  FutureOr<void> _onEditou(
    EcommerceConfiguracaoEditou event,
    Emitter<EcommerceConfiguracaoState> emit,
  ) {
    emit(
      state.copyWith(
        step: EcommerceConfiguracaoStep.editando,
        titulo: event.titulo,
        subtitulo: event.subtitulo,
        descricao: event.descricao,
        icone: event.icone,
        empresaEstoqueId: event.empresaEstoqueId,
        tabelaDePrecoId: event.tabelaDePrecoId,
        terminalId: event.terminalId,
        formaDePagamentoId: event.formaDePagamentoId,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    EcommerceConfiguracaoSalvou event,
    Emitter<EcommerceConfiguracaoState> emit,
  ) async {
    final empresaId = state.empresaId;
    final titulo = state.titulo?.trim();

    if (empresaId == null || titulo == null || titulo.isEmpty) {
      emit(
        state.copyWith(
          step: EcommerceConfiguracaoStep.falha,
          erro: 'Informe empresa e título.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: EcommerceConfiguracaoStep.carregando));
      final ecommerce = Ecommerce.create(
        id: state.id,
        empresaId: empresaId,
        titulo: titulo,
        subtitulo: state.subtitulo,
        descricao: state.descricao,
        icone: state.icone,
        empresaEstoqueId: state.empresaEstoqueId,
        tabelaDePrecoId: state.tabelaDePrecoId,
        terminalId: state.terminalId,
        formaDePagamentoId: state.formaDePagamentoId,
      );
      final salvo = await _salvarEcommerce.call(ecommerce);
      emit(
        EcommerceConfiguracaoState.fromModel(
          salvo,
          step: state.id == null
              ? EcommerceConfiguracaoStep.criado
              : EcommerceConfiguracaoStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EcommerceConfiguracaoStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao salvar configuração do e-commerce.'),
        ),
      );
      addError(e, s);
    }
  }
}
