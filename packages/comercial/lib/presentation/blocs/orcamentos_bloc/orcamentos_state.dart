part of 'orcamentos_bloc.dart';

enum OrcamentosStatus { inicial, carregando, carregado, erro }

class OrcamentosState extends Equatable {
  final OrcamentosStatus status;
  final List<OrcamentoLocal> orcamentos;
  final String? erro;

  const OrcamentosState({
    this.status = OrcamentosStatus.inicial,
    this.orcamentos = const [],
    this.erro,
  });

  OrcamentosState copyWith({
    OrcamentosStatus? status,
    List<OrcamentoLocal>? orcamentos,
    Object? erro = _sentinela,
  }) {
    return OrcamentosState(
      status: status ?? this.status,
      orcamentos: orcamentos ?? this.orcamentos,
      erro: identical(erro, _sentinela) ? this.erro : erro as String?,
    );
  }

  @override
  List<Object?> get props => [status, orcamentos, erro];
}

const Object _sentinela = Object();
