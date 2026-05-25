import 'package:core/impressoras/impressao/item_de_impressao.dart';
import 'package:core/impressoras/printers/i_printers_service.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'impressao_progress_state.dart';

class ImpressaoProgressCubit extends Cubit<ImpressaoProgressState> {
  final IPrintersService _printersService;
  final List<ItemDeImpressao> _itens;

  ImpressaoProgressCubit({
    required IPrintersService printersService,
    required List<ItemDeImpressao> itens,
  })  : _printersService = printersService,
        _itens = itens,
        super(const ImpressaoProgressState()) {
    carregarImpressoras();
  }

  void carregarImpressoras() {
    emit(
      state.copyWith(
        status: ImpressaoProgressStatus.carregandoImpressoras,
        impressoraSelecionada: () => null,
        mensagemErro: () => null,
      ),
    );

    try {
      final impressoras = _printersService.getAvailablePrinters();
      emit(
        state.copyWith(
          status: ImpressaoProgressStatus.aguardandoConfirmacao,
          impressoras: impressoras,
          totalEtiquetas: _itens.length,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ImpressaoProgressStatus.erro,
          mensagemErro: () => 'Falha ao listar impressoras disponiveis.',
        ),
      );
    }
  }

  void selecionarImpressora(Impressora impressora) {
    emit(state.copyWith(impressoraSelecionada: () => impressora));
  }

  Future<void> confirmarImpressao() async {
    final impressora = state.impressoraSelecionada;
    if (impressora == null) return;

    emit(
      state.copyWith(
        status: ImpressaoProgressStatus.imprimindo,
        progressoAtual: 0,
        totalEtiquetas: _itens.length,
        descricaoAtual:
            _itens.isNotEmpty ? () => _itens.first.descricao : () => null,
        mensagemErro: () => null,
      ),
    );

    for (var i = 0; i < _itens.length; i++) {
      final item = _itens[i];

      try {
        final ok = await _printersService.printZpl(impressora, item.zpl);
        if (!ok) {
          emit(
            state.copyWith(
              status: ImpressaoProgressStatus.erro,
              mensagemErro: () =>
                  'Falha ao imprimir "${item.descricao}". Impressao interrompida.',
            ),
          );
          return;
        }
      } catch (_) {
        emit(
          state.copyWith(
            status: ImpressaoProgressStatus.erro,
            mensagemErro: () =>
                'Erro inesperado ao imprimir "${item.descricao}". Impressao interrompida.',
          ),
        );
        return;
      }

      final proximo = i + 1;
      emit(
        state.copyWith(
          progressoAtual: proximo,
          descricaoAtual: proximo < _itens.length
              ? () => _itens[proximo].descricao
              : () => null,
        ),
      );
    }

    emit(state.copyWith(status: ImpressaoProgressStatus.sucesso));
  }
}
