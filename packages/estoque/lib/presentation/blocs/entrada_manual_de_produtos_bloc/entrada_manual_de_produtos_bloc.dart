import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/seletores.dart';

part 'entrada_manual_de_produtos_event.dart';
part 'entrada_manual_de_produtos_state.dart';

class EntradaManualDeProdutosBloc
    extends Bloc<EntradaManualDeProdutosEvent, EntradaManualDeProdutosState> {
  EntradaManualDeProdutosBloc() : super(const EntradaManualDeProdutosState()) {
    on<EntradaManualFuncionarioSelecionado>(_onFuncionarioSelecionado);
    on<EntradaManualTabelaDePrecoSelecionada>(_onTabelaDePrecoSelecionada);
    on<EntradaManualLeituraSolicitada>(_onLeituraSolicitada);
    on<EntradaManualEdicaoSolicitada>(_onEdicaoSolicitada);
    on<EntradaManualSalvarSolicitado>(_onSalvarSolicitado);
  }

  FutureOr<void> _onFuncionarioSelecionado(
    EntradaManualFuncionarioSelecionado event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    emit(
      state.copyWith(
        funcionarioSelecionado: event.funcionarioSelecionado,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onTabelaDePrecoSelecionada(
    EntradaManualTabelaDePrecoSelecionada event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    emit(
      state.copyWith(
        tabelaDePrecoSelecionada: event.tabelaDePrecoSelecionada,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onLeituraSolicitada(
    EntradaManualLeituraSolicitada event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    final erro = _validarSelecoes();
    if (erro != null) {
      emit(state.copyWith(erro: erro));
    } else {
      emit(
        state.copyWith(step: EntradaManualDeProdutosStep.leitura, erro: null),
      );
    }
  }

  FutureOr<void> _onEdicaoSolicitada(
    EntradaManualEdicaoSolicitada event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) {
    emit(
      state.copyWith(
        step: EntradaManualDeProdutosStep.configuracao,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvarSolicitado(
    EntradaManualSalvarSolicitado event,
    Emitter<EntradaManualDeProdutosState> emit,
  ) async {
    // TODO(fabriciojunior): implementar o salvamento dos produtos lidos
    // e a criação do romaneio.
  }

  String? _validarSelecoes() {
    if (state.funcionarioSelecionado == null) {
      return 'Selecione um funcionário para continuar.';
    }

    if (state.tabelaDePrecoSelecionada == null) {
      return 'Selecione uma tabela de preço para continuar.';
    }

    return null;
  }
}
