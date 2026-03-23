import 'package:bloc/bloc.dart';
import 'package:core/imagens.dart';
import 'package:produtos/domain/use_cases/criar_referencia_midia.dart';
import 'package:produtos/domain/use_cases/excluir_referencia_midia.dart';
import 'package:produtos/domain/use_cases/recuperar_referencia_midias.dart';
import 'package:produtos/models.dart';
part 'referencia_midias_event.dart';
part 'referencia_midias_state.dart';

class ReferenciaMidiasBloc
    extends Bloc<ReferenciaMidiasEvent, ReferenciaMidiasState> {
  final RecuperarReferenciaMidias _recuperarMidias;
  final CriarReferenciaMidia _criarReferenciaMidia;
  final ExcluirReferenciaMidia _excluirReferenciaMidia;

  ReferenciaMidiasBloc(
    this._recuperarMidias,
    this._criarReferenciaMidia,
    this._excluirReferenciaMidia,
  ) : super(ReferenciaMidiasInicial()) {
    on<CarregarMidiasReferencia>(_onCarregarMidias);
    on<AdicionarMidiaReferencia>(_onAdicionarMidia);
    on<RemoverMidiaReferencia>(_onRemoverMidia);
  }

  Future<void> _onCarregarMidias(
    CarregarMidiasReferencia event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    emit(ReferenciaMidiasCarregando());
    try {
      final midias = await _recuperarMidias.call(event.referenciaId);
      emit(ReferenciaMidiasCarregado(midias));
    } catch (e, s) {
      emit(ReferenciaMidiasErro('Erro ao carregar mídias'));
      addError(e, s);
    }
  }

  Future<void> _onAdicionarMidia(
    AdicionarMidiaReferencia event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    final midiasList = state is ReferenciaMidiasCarregado
        ? (state as ReferenciaMidiasCarregado).midias
        : <ReferenciaMidia>[];
    emit(ReferenciaMidiasCarregando());
    try {
      for (final imagem in event.midias) {
        if (imagem.path == null) continue;
        await _criarReferenciaMidia.call(
          filePath: imagem.path!,
          referenciaId: event.referenciaId,
          ePrincipal: midiasList.isEmpty,
          ePublica: true,
          tipo: TipoReferenciaMidia.imagem,
          field: imagem.field ?? 'midia',
          descricao: imagem.descricao,
        );
      }
      add(CarregarMidiasReferencia(event.referenciaId));
    } catch (e, s) {
      emit(ReferenciaMidiasErro('Erro ao adicionar mídia'));
      addError(e, s);
    }
  }

  Future<void> _onRemoverMidia(
    RemoverMidiaReferencia event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    emit(ReferenciaMidiasCarregando());
    try {
      await _excluirReferenciaMidia.call(
        referenciaId: event.referenciaId,
        id: event.midiaId,
      );
      add(CarregarMidiasReferencia(event.referenciaId));
    } catch (e, s) {
      emit(ReferenciaMidiasErro('Erro ao remover mídia'));
      addError(e, s);
    }
  }
}
