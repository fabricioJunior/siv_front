part of 'importar_tabela_de_preco_csv_bloc.dart';

abstract class ImportarTabelaDePrecoCsvEvent {}

class ImportarTabelaDePrecoCarregouTabelas
    extends ImportarTabelaDePrecoCsvEvent {}

class ImportarTabelaDePrecoTabelaAlterada
    extends ImportarTabelaDePrecoCsvEvent {
  final int tabelaDePrecoId;

  ImportarTabelaDePrecoTabelaAlterada({required this.tabelaDePrecoId});
}

// Abre o seletor de arquivos e já atualiza o state com o path escolhido.
class ImportarTabelaDePrecoArquivoSelecionado
    extends ImportarTabelaDePrecoCsvEvent {}

class ImportarTabelaDePrecoBaixouTemplate
    extends ImportarTabelaDePrecoCsvEvent {}

class ImportarTabelaDePrecoEnviou extends ImportarTabelaDePrecoCsvEvent {}
