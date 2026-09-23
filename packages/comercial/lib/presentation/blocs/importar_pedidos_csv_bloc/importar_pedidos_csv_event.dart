part of 'importar_pedidos_csv_bloc.dart';

abstract class ImportarPedidosCsvEvent {}

class ImportarPedidosTabelaAlterada extends ImportarPedidosCsvEvent {
  final int tabelaDePrecoId;

  ImportarPedidosTabelaAlterada({required this.tabelaDePrecoId});
}

// Abre o seletor de arquivos e já atualiza o state com o path escolhido.
class ImportarPedidosArquivoSelecionado extends ImportarPedidosCsvEvent {}

class ImportarPedidosBaixouTemplate extends ImportarPedidosCsvEvent {}

class ImportarPedidosEnviou extends ImportarPedidosCsvEvent {}
