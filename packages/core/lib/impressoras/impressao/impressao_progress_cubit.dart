import 'package:core/impressoras/impressao/item_de_impressao.dart';
import 'package:core/impressoras/printers/i_printers_service.dart';
import 'package:core/impressoras/printers/tipo_impressora.dart';
import 'package:core/impressoras/printers/use_cases/obter_impressora_preferida.dart';
import 'package:core/impressoras/printers/use_cases/salvar_impressora_preferida.dart';
import 'package:core/impressoras/zpl/mescla_etiquetas.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'impressao_progress_state.dart';

class ImpressaoProgressCubit extends Cubit<ImpressaoProgressState> {
  final IPrintersService _printersService;
  final ObterImpressoraPreferida _obterImpressoraPreferida;
  final SalvarImpressoraPreferida _salvarImpressoraPreferida;
  final MesclaEtiquetas _mesclaEtiquetas = MesclaEtiquetas();
  final List<ItemDeImpressao> _itens;
  final int _quantidadeDeVias;

  ImpressaoProgressCubit({
    required IPrintersService printersService,
    required ObterImpressoraPreferida obterImpressoraPreferida,
    required SalvarImpressoraPreferida salvarImpressoraPreferida,
    required List<ItemDeImpressao> itens,
    required int quantidadeDeVias,
  })  : _printersService = printersService,
        _obterImpressoraPreferida = obterImpressoraPreferida,
        _salvarImpressoraPreferida = salvarImpressoraPreferida,
        _itens = itens,
        _quantidadeDeVias = quantidadeDeVias <= 0 ? 1 : quantidadeDeVias,
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
      _selecionarImpressoraPreferida(impressoras);
    } catch (_) {
      emit(
        state.copyWith(
          status: ImpressaoProgressStatus.erro,
          mensagemErro: () => 'Falha ao listar impressoras disponiveis.',
        ),
      );
    }
  }

  // Pre-seleciona a ultima impressora usada (se ainda estiver disponivel na
  // lista atual) assim que a lista de impressoras carrega -- roda apos o
  // emit acima pra nao bloquear a tela enquanto le o arquivo local.
  Future<void> _selecionarImpressoraPreferida(
    List<Impressora> impressoras,
  ) async {
    final nomePreferido =
        await _obterImpressoraPreferida.call(tipo: TipoImpressora.etiqueta);
    if (nomePreferido == null || isClosed) return;

    final impressoraPreferida = impressoras
        .where((impressora) =>
            impressora.name == nomePreferido && impressora.isAvailable)
        .toList();
    if (impressoraPreferida.isEmpty || isClosed) return;
    if (state.status != ImpressaoProgressStatus.aguardandoConfirmacao) return;

    emit(state.copyWith(impressoraSelecionada: () => impressoraPreferida.first));
  }

  void selecionarImpressora(Impressora impressora) {
    emit(state.copyWith(impressoraSelecionada: () => impressora));
    _salvarImpressoraPreferida.call(
      tipo: TipoImpressora.etiqueta,
      nomeImpressora: impressora.name,
    );
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

    var etiquetasMescladas = _mesclaEtiquetas(
      _itens.map((e) => e.zpl).toList(),
      _quantidadeDeVias,
    );

      try {
        final ok = await _printersService.printZpl(impressora, etiquetasMescladas);
        if (!ok) {
          emit(
            state.copyWith(
              status: ImpressaoProgressStatus.erro,
              mensagemErro: () =>
                  'Falha ao imprimir etiquetas. Impressao interrompida.',
            ),
          );
          return;
        }
      } catch (_) {
        emit(
          state.copyWith(
            status: ImpressaoProgressStatus.erro,
            mensagemErro: () =>
                'Erro inesperado ao imprimir etiquetas. Impressao interrompida.',
          ),
        );
        return;
      }

      _salvarImpressoraPreferida.call(
        tipo: TipoImpressora.etiqueta,
        nomeImpressora: impressora.name,
      );

      emit(
        state.copyWith(
          progressoAtual: _itens.length,
          descricaoAtual: () => null,
        ),
      );

    emit(state.copyWith(status: ImpressaoProgressStatus.sucesso));
  }
}
