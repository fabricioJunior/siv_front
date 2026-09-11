import 'dart:async';
import 'dart:typed_data';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;

part 'ecommerce_banners_event.dart';
part 'ecommerce_banners_state.dart';

class EcommerceBannersBloc extends Bloc<EcommerceBannersEvent, EcommerceBannersState> {
  final RecuperarBannersEcommerce _recuperarBannersEcommerce;
  final CriarBannerEcommerce _criarBannerEcommerce;
  final AtualizarBannerEcommerce _atualizarBannerEcommerce;
  final ExcluirBannerEcommerce _excluirBannerEcommerce;

  EcommerceBannersBloc(
    this._recuperarBannersEcommerce,
    this._criarBannerEcommerce,
    this._atualizarBannerEcommerce,
    this._excluirBannerEcommerce,
  ) : super(const EcommerceBannersState()) {
    on<EcommerceBannersIniciou>(_onIniciou);
    on<EcommerceBannerAdicionou>(_onAdicionou);
    on<EcommerceBannerAtivoAlterou>(_onAtivoAlterou);
    on<EcommerceBannerExcluiu>(_onExcluiu);
    on<EcommerceBannerMoveu>(_onMoveu);
  }

  FutureOr<void> _onIniciou(
    EcommerceBannersIniciou event,
    Emitter<EcommerceBannersState> emit,
  ) async {
    try {
      emit(
        state.copyWith(
          step: EcommerceBannersStep.carregando,
          ecommerceId: event.ecommerceId,
        ),
      );
      final banners = await _recuperarBannersEcommerce.call(event.ecommerceId);
      banners.sort((a, b) => a.ordem.compareTo(b.ordem));
      emit(state.copyWith(step: EcommerceBannersStep.carregado, banners: banners));
    } catch (e, s) {
      emit(
        state.copyWith(
          step: EcommerceBannersStep.falha,
          erro: mensagemDeErroApi(e, 'Falha ao carregar banners.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onAdicionou(
    EcommerceBannerAdicionou event,
    Emitter<EcommerceBannersState> emit,
  ) async {
    final ecommerceId = state.ecommerceId;
    if (ecommerceId == null) return;

    emit(state.copyWith(enviando: true, progressoEnvio: 0, erro: ''));
    try {
      await _criarBannerEcommerce.call(
        ecommerceId,
        bytes: event.bytes,
        nomeArquivo: event.nomeArquivo,
        dispositivo: event.dispositivo,
        onProgresso: (enviado, total) => emit(
          state.copyWith(
            enviando: true,
            progressoEnvio: total == 0 ? null : enviado / total,
          ),
        ),
      );
      final banners = await _recuperarBannersEcommerce.call(ecommerceId);
      banners.sort((a, b) => a.ordem.compareTo(b.ordem));
      emit(
        state.copyWith(
          banners: banners,
          enviando: false,
          progressoEnvio: null,
        ),
      );
    } catch (e, s) {
      emit(
        state.copyWith(
          enviando: false,
          progressoEnvio: null,
          erro: mensagemDeErroApi(e, 'Falha ao enviar o banner.'),
        ),
      );
      addError(e, s);
    }
  }

  FutureOr<void> _onAtivoAlterou(
    EcommerceBannerAtivoAlterou event,
    Emitter<EcommerceBannersState> emit,
  ) async {
    final ecommerceId = state.ecommerceId;
    if (ecommerceId == null) return;

    final anteriores = state.banners;
    emit(
      state.copyWith(
        banners: [
          for (final banner in anteriores)
            if (banner.id == event.id) banner.copyWith(ativo: event.ativo) else banner,
        ],
      ),
    );
    try {
      await _atualizarBannerEcommerce.call(ecommerceId, event.id, ativo: event.ativo);
    } catch (e, s) {
      emit(state.copyWith(banners: anteriores, erro: mensagemDeErroApi(e, 'Falha ao atualizar o banner.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onExcluiu(
    EcommerceBannerExcluiu event,
    Emitter<EcommerceBannersState> emit,
  ) async {
    final ecommerceId = state.ecommerceId;
    if (ecommerceId == null) return;

    final anteriores = state.banners;
    emit(
      state.copyWith(
        banners: anteriores.where((banner) => banner.id != event.id).toList(),
      ),
    );
    try {
      await _excluirBannerEcommerce.call(ecommerceId, event.id);
    } catch (e, s) {
      emit(state.copyWith(banners: anteriores, erro: mensagemDeErroApi(e, 'Falha ao excluir o banner.')));
      addError(e, s);
    }
  }

  FutureOr<void> _onMoveu(
    EcommerceBannerMoveu event,
    Emitter<EcommerceBannersState> emit,
  ) async {
    final ecommerceId = state.ecommerceId;
    if (ecommerceId == null) return;

    final banners = List<EcommerceBanner>.from(state.banners);
    final atualIndice = banners.indexWhere((b) => b.id == event.id);
    if (atualIndice == -1) return;
    final atualBanner = banners[atualIndice];

    // Ordem é independente por dispositivo -- vizinho tem que ser do mesmo
    // dispositivo, senão troca ordem entre sequências diferentes.
    final doMesmoDispositivo =
        banners.where((b) => b.dispositivo == atualBanner.dispositivo).toList()
          ..sort((a, b) => a.ordem.compareTo(b.ordem));
    final indice = doMesmoDispositivo.indexWhere((b) => b.id == event.id);
    final indiceVizinho = event.paraCima ? indice - 1 : indice + 1;
    if (indiceVizinho < 0 || indiceVizinho >= doMesmoDispositivo.length) {
      return;
    }

    final atual = doMesmoDispositivo[indice];
    final vizinho = doMesmoDispositivo[indiceVizinho];
    final ordemAtual = atual.ordem;
    final ordemVizinho = vizinho.ordem;

    final atualizados = [
      for (final b in banners)
        if (b.id == atual.id)
          atual.copyWith(ordem: ordemVizinho)
        else if (b.id == vizinho.id)
          vizinho.copyWith(ordem: ordemAtual)
        else
          b,
    ]..sort((a, b) => a.ordem.compareTo(b.ordem));
    emit(state.copyWith(banners: atualizados));

    try {
      await _atualizarBannerEcommerce.call(ecommerceId, atual.id, ordem: ordemVizinho);
      await _atualizarBannerEcommerce.call(ecommerceId, vizinho.id, ordem: ordemAtual);
    } catch (e, s) {
      final banners2 = await _recuperarBannersEcommerce.call(ecommerceId);
      banners2.sort((a, b) => a.ordem.compareTo(b.ordem));
      emit(
        state.copyWith(
          banners: banners2,
          erro: mensagemDeErroApi(e, 'Falha ao reordenar os banners.'),
        ),
      );
      addError(e, s);
    }
  }
}
