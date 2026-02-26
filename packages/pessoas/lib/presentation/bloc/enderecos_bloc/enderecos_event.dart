part of 'enderecos_bloc.dart';

abstract class EnderecosEvent extends Equatable {
  const EnderecosEvent();

  @override
  List<Object?> get props => [];
}

class EnderecosIniciou extends EnderecosEvent {
  final int idPessoa;

  const EnderecosIniciou({required this.idPessoa});

  @override
  List<Object?> get props => [idPessoa];
}

class EnderecosCriouNovoEndereco extends EnderecosEvent {
  final Endereco endereco;

  const EnderecosCriouNovoEndereco({required this.endereco});

  @override
  List<Object?> get props => [endereco];
}

class EnderecosAtualizouEndereco extends EnderecosEvent {
  final Endereco endereco;

  const EnderecosAtualizouEndereco({required this.endereco});

  @override
  List<Object?> get props => [endereco];
}

class EnderecosExcluiuEndereco extends EnderecosEvent {
  final int idEndereco;

  const EnderecosExcluiuEndereco({required this.idEndereco});

  @override
  List<Object?> get props => [idEndereco];
}
