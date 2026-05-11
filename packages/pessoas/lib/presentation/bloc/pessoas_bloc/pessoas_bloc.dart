import 'dart:async';

import 'package:core/bloc.dart';
import 'package:pessoas/domain/models/pessoa.dart';
import 'package:core/equals.dart';
import 'package:pessoas/uses_cases.dart';
part 'pessoas_event.dart';
part 'pessoas_state.dart';

class PessoasBloc extends Bloc<PessoasEvent, PessoasState> {
  final RecuperarPessoas _recuperarPessoas;
  final RecuperarPessoa _recuperarPessoa;
  static const int _itensPorPagina = 8;

  String? _buscaAtual;
  bool? _eClienteAtual;
  bool? _eFornecedorAtual;
  bool? _eFuncionarioAtual;

  PessoasBloc(
    this._recuperarPessoas,
    this._recuperarPessoa,
  ) : super(PessoasInitial()) {
    on<PessoasIniciou>(_onPessoasIniciou);
    on<PessoasCarregouMais>(_onPessoasCarregouMais);
  }

  FutureOr<void> _onPessoasIniciou(
    PessoasIniciou event,
    Emitter<PessoasState> emit,
  ) async {
    try {
      _buscaAtual = event.busca;
      _eClienteAtual = event.eCliente;
      _eFornecedorAtual = event.eFornecedor;
      _eFuncionarioAtual = event.eFuncionario;

      emit(PessoasCarregarEmProgresso());
      var pessoas = await _recuperarPessoas.call(
        pagina: 1,
        busca: event.busca,
        eCliente: event.eCliente,
        eFornecedor: event.eFornecedor,
        eFuncionario: event.eFuncionario,
      );
      final pessoasList = pessoas.toList();
      var pessoaSelecionada = event.idPessoaSelecionada != null
          ? await _recuperarPessoa.call(idPessoa: event.idPessoaSelecionada!)
          : null;
      emit(
        PessoasCarregarSucesso(
          pessoas: pessoasList,
          pessoaSelecionada: pessoaSelecionada,
          pagina: 1,
          temMais: pessoasList.length >= _itensPorPagina,
        ),
      );
    } catch (e, s) {
      emit(PessoasCarregarFalha());
      addError(e, s);
    }
  }

  FutureOr<void> _onPessoasCarregouMais(
    PessoasCarregouMais event,
    Emitter<PessoasState> emit,
  ) async {
    final estadoAtual = state;
    if (estadoAtual is! PessoasCarregarSucesso) return;
    if (estadoAtual.carregandoMais || !estadoAtual.temMais) return;

    emit(estadoAtual.copyWith(carregandoMais: true));

    try {
      final proximaPagina = estadoAtual.pagina + 1;
      final novasPessoas = await _recuperarPessoas.call(
        pagina: proximaPagina,
        busca: _buscaAtual,
        eCliente: _eClienteAtual,
        eFornecedor: _eFornecedorAtual,
        eFuncionario: _eFuncionarioAtual,
      );
      final novasPessoasList = novasPessoas.toList();

      emit(
        estadoAtual.copyWith(
          pessoas: [...estadoAtual.pessoas, ...novasPessoasList],
          pagina: proximaPagina,
          carregandoMais: false,
          temMais: novasPessoasList.length >= _itensPorPagina,
        ),
      );
    } catch (e, s) {
      emit(estadoAtual.copyWith(carregandoMais: false));
      addError(e, s);
    }
  }
}
