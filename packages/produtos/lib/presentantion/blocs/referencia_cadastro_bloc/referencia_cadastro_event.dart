part of 'referencia_cadastro_bloc.dart';

abstract class ReferenciaCadastroEvent extends Equatable {
  const ReferenciaCadastroEvent();

  @override
  List<Object?> get props => [];
}

class ReferenciaCadastroIniciou extends ReferenciaCadastroEvent {
  /// Nome sugerido (ex.: descrição contada). Quando informado, vale no lugar
  /// do nome gerado a partir da categoria/subcategoria.
  final String? nomeInicial;
  ReferenciaCadastroIniciou({this.nomeInicial});

  @override
  List<Object?> get props => [nomeInicial];
}

class ReferenciaCadastroCategoriaSelecionada extends ReferenciaCadastroEvent {
  final Categoria categoria;
  const ReferenciaCadastroCategoriaSelecionada({required this.categoria});

  @override
  List<Object?> get props => [categoria];
}

class ReferenciaCadastroSubCategoriaSelecionada
    extends ReferenciaCadastroEvent {
  final SubCategoria subCategoria;
  const ReferenciaCadastroSubCategoriaSelecionada({required this.subCategoria});

  @override
  List<Object?> get props => [subCategoria];
}

class ReferenciaCadastroNomeAlterado extends ReferenciaCadastroEvent {
  final String nome;
  const ReferenciaCadastroNomeAlterado({required this.nome});

  @override
  List<Object?> get props => [nome];
}

class ReferenciaCadastroGerarNome extends ReferenciaCadastroEvent {}

/// Campos opcionais do passo do nome; só o que vier não-nulo é alterado.
class ReferenciaCadastroOpcionaisAlterados extends ReferenciaCadastroEvent {
  final String? unidadeMedida;
  final String? descricao;
  final String? composicao;
  final String? cuidados;
  const ReferenciaCadastroOpcionaisAlterados({
    this.unidadeMedida,
    this.descricao,
    this.composicao,
    this.cuidados,
  });

  @override
  List<Object?> get props => [unidadeMedida, descricao, composicao, cuidados];
}

class ReferenciaCadastroPrecoAlterado extends ReferenciaCadastroEvent {
  final String preco;
  const ReferenciaCadastroPrecoAlterado({required this.preco});

  @override
  List<Object?> get props => [preco];
}

class ReferenciaCadastroCustoAlterado extends ReferenciaCadastroEvent {
  final String custo;
  const ReferenciaCadastroCustoAlterado({required this.custo});

  @override
  List<Object?> get props => [custo];
}

class ReferenciaCadastroFornecedorAlterado extends ReferenciaCadastroEvent {
  final SelectData? fornecedor;
  const ReferenciaCadastroFornecedorAlterado(this.fornecedor);

  @override
  List<Object?> get props => [fornecedor?.id];
}

class ReferenciaCadastroCodigoFornecedorAlterado
    extends ReferenciaCadastroEvent {
  final String codigo;
  const ReferenciaCadastroCodigoFornecedorAlterado(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

/// "Definir na chegada": cria só a referência, sem nenhuma variação.
class ReferenciaCadastroDefinirNaChegadaAlterado
    extends ReferenciaCadastroEvent {
  final bool definirNaChegada;
  const ReferenciaCadastroDefinirNaChegadaAlterado(this.definirNaChegada);

  @override
  List<Object?> get props => [definirNaChegada];
}

class ReferenciaCadastroQuantidadeEsperadaAlterada
    extends ReferenciaCadastroEvent {
  final String quantidade;
  const ReferenciaCadastroQuantidadeEsperadaAlterada(this.quantidade);

  @override
  List<Object?> get props => [quantidade];
}

class ReferenciaCadastroFotoFornecedorAlterada extends ReferenciaCadastroEvent {
  final Imagem? foto;
  const ReferenciaCadastroFotoFornecedorAlterada(this.foto);

  @override
  List<Object?> get props => [foto?.path, foto?.bytes?.length];
}

class ReferenciaCadastroProximo extends ReferenciaCadastroEvent {}

class ReferenciaCadastroVoltar extends ReferenciaCadastroEvent {}

/// Vai direto a uma etapa já concluída (stepper / resumo clicáveis).
class ReferenciaCadastroIrPara extends ReferenciaCadastroEvent {
  final ReferenciaCadastroStep step;
  const ReferenciaCadastroIrPara(this.step);

  @override
  List<Object?> get props => [step];
}

class ReferenciaCadastroVariacoesConcluidas extends ReferenciaCadastroEvent {}

/// Recomeça o wizard. [manterCategoria] reaproveita categoria/subcategoria
/// ("cadastrar outra em X") e volta direto pro nome.
class ReferenciaCadastroReiniciar extends ReferenciaCadastroEvent {
  final bool manterCategoria;
  const ReferenciaCadastroReiniciar({this.manterCategoria = false});

  @override
  List<Object?> get props => [manterCategoria];
}
