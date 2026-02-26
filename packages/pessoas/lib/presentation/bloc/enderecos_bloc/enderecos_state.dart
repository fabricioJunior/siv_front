part of 'enderecos_bloc.dart';

abstract class EnderecosState extends Equatable {
  final int? idPessoa;
  final List<Endereco> enderecos;

  const EnderecosState({this.idPessoa, this.enderecos = const []});

  EnderecosState.fromLastState(
    EnderecosState state, {
    int? idPessoa,
    List<Endereco>? enderecos,
  })  : idPessoa = idPessoa ?? state.idPessoa,
        enderecos = enderecos ?? state.enderecos;

  @override
  List<Object?> get props => [idPessoa, enderecos];
}

class EnderecosInicial extends EnderecosState {
  const EnderecosInicial({super.idPessoa, super.enderecos});
}

class EnderecosCarregarEmProgresso extends EnderecosState {
  EnderecosCarregarEmProgresso.fromLastState(
    super.state, {
    super.idPessoa,
    super.enderecos,
  }) : super.fromLastState();
}

class EnderecosCarregarSucesso extends EnderecosState {
  EnderecosCarregarSucesso.fromLastState(
    EnderecosState state, {
    required List<Endereco> enderecos,
  }) : super.fromLastState(state, enderecos: enderecos);
}

class EnderecosCarregarFalha extends EnderecosState {
  EnderecosCarregarFalha.fromLastState(EnderecosState state)
      : super.fromLastState(state);
}

class EnderecosCriarEmProgresso extends EnderecosState {
  EnderecosCriarEmProgresso.fromLastState(EnderecosState state)
      : super.fromLastState(state);
}

class EnderecosCriarSucesso extends EnderecosState {
  EnderecosCriarSucesso.fromLastState(
    EnderecosState state, {
    required List<Endereco> enderecos,
  }) : super.fromLastState(state, enderecos: enderecos);
}

class EnderecosCriarFalha extends EnderecosState {
  EnderecosCriarFalha.fromLastState(EnderecosState state)
      : super.fromLastState(state);
}

class EnderecosSalvarEmProgresso extends EnderecosState {
  EnderecosSalvarEmProgresso.fromLastState(EnderecosState state)
      : super.fromLastState(state);
}

class EnderecosSalvarSucesso extends EnderecosState {
  EnderecosSalvarSucesso.fromLastState(
    EnderecosState state, {
    required List<Endereco> enderecos,
  }) : super.fromLastState(state, enderecos: enderecos);
}

class EnderecosSalvarFalha extends EnderecosState {
  EnderecosSalvarFalha.fromLastState(EnderecosState state)
      : super.fromLastState(state);
}

class EnderecosExcluirEmProgresso extends EnderecosState {
  EnderecosExcluirEmProgresso.fromLastState(EnderecosState state)
      : super.fromLastState(state);
}

class EnderecosExcluirSucesso extends EnderecosState {
  EnderecosExcluirSucesso.fromLastState(
    EnderecosState state, {
    required List<Endereco> enderecos,
  }) : super.fromLastState(state, enderecos: enderecos);
}

class EnderecosExcluirFalha extends EnderecosState {
  EnderecosExcluirFalha.fromLastState(EnderecosState state)
      : super.fromLastState(state);
}
