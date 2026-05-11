part of 'pessoas_bloc.dart';

abstract class PessoasState extends Equatable {
  List<Pessoa> get pessoas => [];

  Pessoa? get pessoaSelecionada => null;

  final int pagina;
  final bool carregandoMais;
  final bool temMais;

  const PessoasState({
    this.pagina = 0,
    this.carregandoMais = false,
    this.temMais = true,
  });

  @override
  List<Object?> get props => [pessoas, pagina, carregandoMais, temMais];
}

class PessoasInitial extends PessoasState {
  const PessoasInitial({super.pagina});
}

class PessoasCarregarEmProgresso extends PessoasState {}

class PessoasCarregarSucesso extends PessoasState {
  @override
  final List<Pessoa> pessoas;

  @override
  final Pessoa? pessoaSelecionada;

  const PessoasCarregarSucesso({
    required this.pessoas,
    this.pessoaSelecionada,
    required super.pagina,
    super.carregandoMais,
    super.temMais,
  });

  PessoasCarregarSucesso copyWith({
    List<Pessoa>? pessoas,
    Pessoa? pessoaSelecionada,
    bool limparPessoaSelecionada = false,
    int? pagina,
    bool? carregandoMais,
    bool? temMais,
  }) {
    return PessoasCarregarSucesso(
      pessoas: pessoas ?? this.pessoas,
      pessoaSelecionada: limparPessoaSelecionada
          ? null
          : (pessoaSelecionada ?? this.pessoaSelecionada),
      pagina: pagina ?? this.pagina,
      carregandoMais: carregandoMais ?? this.carregandoMais,
      temMais: temMais ?? this.temMais,
    );
  }
}

class PessoasCarregarFalha extends PessoasState {}
