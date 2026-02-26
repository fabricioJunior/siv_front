import 'dart:async';

import 'package:core/bloc.dart';
import 'package:core/equals.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart';

part 'enderecos_event.dart';
part 'enderecos_state.dart';

class EnderecosBloc extends Bloc<EnderecosEvent, EnderecosState> {
  final RecuperarEnderecosDaPessoa _recuperarEnderecosDaPessoa;
  final CriarEndereco _criarEndereco;
  final SalvarEndereco _salvarEndereco;
  final ExcluirEndereco _excluirEndereco;

  EnderecosBloc(
    this._recuperarEnderecosDaPessoa,
    this._criarEndereco,
    this._salvarEndereco,
    this._excluirEndereco,
  ) : super(const EnderecosInicial()) {
    on<EnderecosIniciou>(_onIniciou);
    on<EnderecosCriouNovoEndereco>(_onCriouNovoEndereco);
    on<EnderecosAtualizouEndereco>(_onAtualizouEndereco);
    on<EnderecosExcluiuEndereco>(_onExcluiuEndereco);
  }

  FutureOr<void> _onIniciou(
    EnderecosIniciou event,
    Emitter<EnderecosState> emit,
  ) async {
    try {
      emit(EnderecosCarregarEmProgresso.fromLastState(state,
          idPessoa: event.idPessoa));
      final enderecos = await _recuperarEnderecosDaPessoa.call(
        idPessoa: event.idPessoa,
      );
      emit(EnderecosCarregarSucesso.fromLastState(state, enderecos: enderecos));
    } catch (e, s) {
      emit(EnderecosCarregarFalha.fromLastState(state));
      addError(e, s);
    }
  }

  FutureOr<void> _onCriouNovoEndereco(
    EnderecosCriouNovoEndereco event,
    Emitter<EnderecosState> emit,
  ) async {
    final idPessoa = state.idPessoa;
    if (idPessoa == null) return;

    try {
      emit(EnderecosCriarEmProgresso.fromLastState(state));
      final novoEndereco = await _criarEndereco.call(
        idPessoa: idPessoa,
        endereco: event.endereco,
      );
      final atualizados = List<Endereco>.from(state.enderecos)
        ..add(novoEndereco);
      emit(EnderecosCriarSucesso.fromLastState(state, enderecos: atualizados));
    } catch (e, s) {
      emit(EnderecosCriarFalha.fromLastState(state));
      addError(e, s);
    }
  }

  FutureOr<void> _onAtualizouEndereco(
    EnderecosAtualizouEndereco event,
    Emitter<EnderecosState> emit,
  ) async {
    final idPessoa = state.idPessoa;
    if (idPessoa == null) return;

    try {
      emit(EnderecosSalvarEmProgresso.fromLastState(state));
      final enderecoAtualizado = await _salvarEndereco.call(
        idPessoa: idPessoa,
        endereco: event.endereco,
      );

      final atualizados = state.enderecos.map((endereco) {
        if (endereco.id == enderecoAtualizado.id) {
          return enderecoAtualizado;
        }
        return endereco;
      }).toList();

      emit(EnderecosSalvarSucesso.fromLastState(state, enderecos: atualizados));
    } catch (e, s) {
      emit(EnderecosSalvarFalha.fromLastState(state));
      addError(e, s);
    }
  }

  FutureOr<void> _onExcluiuEndereco(
    EnderecosExcluiuEndereco event,
    Emitter<EnderecosState> emit,
  ) async {
    final idPessoa = state.idPessoa;
    if (idPessoa == null) return;

    try {
      emit(EnderecosExcluirEmProgresso.fromLastState(state));
      await _excluirEndereco.call(
          idPessoa: idPessoa, idEndereco: event.idEndereco);
      final atualizados = state.enderecos
          .where((endereco) => endereco.id != event.idEndereco)
          .toList();
      emit(
          EnderecosExcluirSucesso.fromLastState(state, enderecos: atualizados));
    } catch (e, s) {
      emit(EnderecosExcluirFalha.fromLastState(state));
      addError(e, s);
    }
  }
}
