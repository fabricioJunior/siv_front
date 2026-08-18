part of 'importar_promocoes_csv_bloc.dart';

abstract class ImportarPromocoesCsvEvent {}

class ImportarPromocoesCampoAlterado extends ImportarPromocoesCsvEvent {
  final String? nome;
  final DateTime? dataInicio;
  final DateTime? dataFim;
  final PromocaoCanal? canal;
  final TipoDesconto? tipoDesconto;
  final String? arquivoPath;
  final String? arquivoNome;

  ImportarPromocoesCampoAlterado({
    this.nome,
    this.dataInicio,
    this.dataFim,
    this.canal,
    this.tipoDesconto,
    this.arquivoPath,
    this.arquivoNome,
  });
}

// Abre o seletor de arquivos e já atualiza o state com o path escolhido.
class ImportarPromocoesArquivoSelecionado extends ImportarPromocoesCsvEvent {}

class ImportarPromocoesBaixouTemplate extends ImportarPromocoesCsvEvent {}

class ImportarPromocoesEnviou extends ImportarPromocoesCsvEvent {}
