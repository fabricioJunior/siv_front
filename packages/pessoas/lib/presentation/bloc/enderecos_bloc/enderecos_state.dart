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
    super.state, {
    required List<Endereco> super.enderecos,
  }) : super.fromLastState();
}

class EnderecosCarregarFalha extends EnderecosState {
  EnderecosCarregarFalha.fromLastState(super.state) : super.fromLastState();
}

class EnderecosCriarEmProgresso extends EnderecosState {
  EnderecosCriarEmProgresso.fromLastState(super.state) : super.fromLastState();
}

class EnderecosCriarSucesso extends EnderecosState {
  EnderecosCriarSucesso.fromLastState(
    super.state, {
    required List<Endereco> super.enderecos,
  }) : super.fromLastState();
}

class EnderecosCriarFalha extends EnderecosState {
  EnderecosCriarFalha.fromLastState(super.state) : super.fromLastState();
}

class EnderecosSalvarEmProgresso extends EnderecosState {
  EnderecosSalvarEmProgresso.fromLastState(super.state) : super.fromLastState();
}

class EnderecosSalvarSucesso extends EnderecosState {
  EnderecosSalvarSucesso.fromLastState(
    super.state, {
    required List<Endereco> super.enderecos,
  }) : super.fromLastState();
}

class EnderecosSalvarFalha extends EnderecosState {
  EnderecosSalvarFalha.fromLastState(super.state) : super.fromLastState();
}

class EnderecosExcluirEmProgresso extends EnderecosState {
  EnderecosExcluirEmProgresso.fromLastState(super.state)
      : super.fromLastState();
}

class EnderecosExcluirSucesso extends EnderecosState {
  EnderecosExcluirSucesso.fromLastState(
    super.state, {
    required List<Endereco> super.enderecos,
  }) : super.fromLastState();
}

class EnderecosExcluirFalha extends EnderecosState {
  EnderecosExcluirFalha.fromLastState(super.state) : super.fromLastState();
}
