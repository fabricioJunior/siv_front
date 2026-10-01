part of 'importar_vendas_csv_bloc.dart';

abstract class ImportarVendasCsvEvent {}

class ImportarVendasTabelaAlterada extends ImportarVendasCsvEvent {
  final int tabelaDePrecoId;

  ImportarVendasTabelaAlterada({required this.tabelaDePrecoId});
}

class ImportarVendasFuncionarioAlterado extends ImportarVendasCsvEvent {
  final int funcionarioId;

  ImportarVendasFuncionarioAlterado({required this.funcionarioId});
}

// Abre o seletor de arquivos e já atualiza o state com o path escolhido.
class ImportarVendasArquivoSelecionado extends ImportarVendasCsvEvent {}

class ImportarVendasBaixouTemplate extends ImportarVendasCsvEvent {}

class ImportarVendasEnviou extends ImportarVendasCsvEvent {}
