import 'package:core/bloc.dart';
import 'package:core/imagens.dart';
import 'package:core/imagens/cache_imagem_service.dart';
import 'package:produtos/domain/use_cases/atualizar_referencia_midia.dart';
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
  final AtualizarReferenciaMidia _atualizarReferenciaMidia;

  final ICacheImagemService _cacheImagemService;

  ReferenciaMidiasBloc(
    this._recuperarMidias,
    this._criarReferenciaMidia,
    this._excluirReferenciaMidia,
    this._atualizarReferenciaMidia,
    this._cacheImagemService,
  ) : super(ReferenciaMidiasInicial()) {
    on<ReferenciasIniciou>(_onReferenciasIniciou);
    on<ReferenciasMidiaAdicinou>(_onReferenciaMidiaAdicinou);
    on<ReferenciaMidiasRemoveu>(_onReferenciaMidiasRemoveu);
    on<ReferenciaMidiasAtualizou>(_onReferenciaMidiasAtualizou);
  }

  Future<void> _onReferenciasIniciou(
    ReferenciasIniciou event,
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

  Future<void> _onReferenciaMidiaAdicinou(
    ReferenciasMidiaAdicinou event,
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
          cor: event.cor,
          tamanho: event.tamanho,
        );
      }
      add(ReferenciasIniciou(event.referenciaId));
    } catch (e, s) {
      emit(ReferenciaMidiasErro('Erro ao adicionar mídia'));
      addError(e, s);
    }
  }

  Future<void> _onReferenciaMidiasRemoveu(
    ReferenciaMidiasRemoveu event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    emit(ReferenciaMidiasCarregando());
    try {
      await _excluirReferenciaMidia.call(
        referenciaId: event.referenciaId,
        id: event.midiaId,
      );
      add(ReferenciasIniciou(event.referenciaId));
    } catch (e, s) {
      emit(ReferenciaMidiasErro('Erro ao remover mídia'));
      addError(e, s);
    }
  }

  Future<void> _onReferenciaMidiasAtualizou(
    ReferenciaMidiasAtualizou event,
    Emitter<ReferenciaMidiasState> emit,
  ) async {
    emit(ReferenciaMidiasCarregando());
    try {
      await _atualizarReferenciaMidia.call(
        ReferenciaMidia.create(
          id: event.midia.id,
          url: event.midia.url,
          referenciaId: event.referenciaId,
          ePrincipal: event.ePrincipal,
          ePublica: event.ePublica,
          descricao: event.midia.descricao,
        ),
      );
      if (event.ePrincipal) {
        await _cacheImagemService.updateImageInCache(
          event.referenciaId.toString(),
          event.midia.url,
        );
      }

      add(ReferenciasIniciou(event.referenciaId));
    } catch (e, s) {
      emit(ReferenciaMidiasErro('Erro ao atualizar mídia'));
      addError(e, s);
    }
  }
}
