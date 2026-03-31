import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/equals.dart';

part 'romaneio_event.dart';
part 'romaneio_state.dart';

class RomaneioBloc extends Bloc<RomaneioEvent, RomaneioState> {
  final RecuperarRomaneio _recuperarRomaneio;
  final CriarRomaneio _criarRomaneio;
  final AtualizarRomaneio _atualizarRomaneio;
  final AtualizarObservacaoRomaneio _atualizarObservacaoRomaneio;

  RomaneioBloc(
    this._recuperarRomaneio,
    this._criarRomaneio,
    this._atualizarRomaneio,
    this._atualizarObservacaoRomaneio,
  ) : super(const RomaneioState.initial()) {
    on<RomaneioIniciou>(_onIniciou);
    on<RomaneioCampoAlterado>(_onCampoAlterado);
    on<RomaneioSalvou>(_onSalvou);
    on<RomaneioObservacaoAtualizada>(_onObservacaoAtualizada);
  }

  FutureOr<void> _onIniciou(
    RomaneioIniciou event,
    Emitter<RomaneioState> emit,
  ) async {
    try {
      emit(state.copyWith(step: RomaneioStep.carregando, erro: null));

      if (event.idRomaneio != null) {
        final romaneio = await _recuperarRomaneio.call(event.idRomaneio!);
        emit(RomaneioState.fromModel(romaneio));
        return;
      }

      emit(const RomaneioState.initial().copyWith(step: RomaneioStep.editando));
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneioStep.falha, erro: 'Falha ao carregar romaneio.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onCampoAlterado(
    RomaneioCampoAlterado event,
    Emitter<RomaneioState> emit,
  ) {
    emit(
      state.copyWith(
        pessoaId: event.pessoaId,
        funcionarioId: event.funcionarioId,
        tabelaPrecoId: event.tabelaPrecoId,
        operacao: event.operacao,
        observacao: event.observacao,
        step: RomaneioStep.editando,
        erro: null,
      ),
    );
  }

  FutureOr<void> _onSalvou(
    RomaneioSalvou event,
    Emitter<RomaneioState> emit,
  ) async {
    final erro = _validarCadastro(state);
    if (erro != null) {
      emit(state.copyWith(step: RomaneioStep.validacaoInvalida, erro: erro));
      return;
    }

    try {
      emit(state.copyWith(step: RomaneioStep.salvando, erro: null));

      final romaneio = _toModel(state);
      final salvo = state.id == null
          ? await _criarRomaneio.call(romaneio)
          : await _atualizarRomaneio.call(romaneio);

      emit(
        RomaneioState.fromModel(
          salvo,
          step: state.id == null ? RomaneioStep.criado : RomaneioStep.salvo,
        ),
      );
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneioStep.falha, erro: 'Falha ao salvar romaneio.'));
      addError(e, s);
    }
  }

  FutureOr<void> _onObservacaoAtualizada(
    RomaneioObservacaoAtualizada event,
    Emitter<RomaneioState> emit,
  ) async {
    if (state.id == null) return;

    final observacao = (event.observacao ?? state.observacao ?? '').trim();
    if (observacao.isEmpty) {
      emit(
        state.copyWith(
          step: RomaneioStep.validacaoInvalida,
          erro: 'Informe a observacao.',
        ),
      );
      return;
    }

    try {
      emit(state.copyWith(step: RomaneioStep.processando, erro: null));
      final romaneio = await _atualizarObservacaoRomaneio.call(
        state.id!,
        observacao,
      );
      emit(RomaneioState.fromModel(romaneio,
          step: RomaneioStep.observacaoAtualizada));
    } catch (e, s) {
      emit(state.copyWith(
          step: RomaneioStep.falha, erro: 'Falha ao atualizar observacao.'));
      addError(e, s);
    }
  }

  String? _validarCadastro(RomaneioState state) {
    if ((state.pessoaId ?? '').trim().isEmpty ||
        (state.funcionarioId ?? '').trim().isEmpty ||
        (state.tabelaPrecoId ?? '').trim().isEmpty) {
      return 'Preencha os campos obrigatorios.';
    }

    return null;
  }

  Romaneio _toModel(RomaneioState state) {
    return Romaneio.create(
      id: state.id,
      pessoaId: int.tryParse(state.pessoaId ?? ''),
      funcionarioId: int.tryParse(state.funcionarioId ?? ''),
      tabelaPrecoId: int.tryParse(state.tabelaPrecoId ?? ''),
      operacao: state.operacao,
      observacao: state.observacao?.trim(),
      pessoaNome: state.romaneio?.pessoaNome,
      funcionarioNome: state.romaneio?.funcionarioNome,
      modalidade: state.romaneio?.modalidade,
      situacao: state.romaneio?.situacao,
      quantidade: state.romaneio?.quantidade,
      valorBruto: state.romaneio?.valorBruto,
      valorDesconto: state.romaneio?.valorDesconto,
      valorLiquido: state.romaneio?.valorLiquido,
      data: state.romaneio?.data,
      criadoEm: state.romaneio?.criadoEm,
      atualizadoEm: state.romaneio?.atualizadoEm,
    );
  }
}
