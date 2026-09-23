part of 'importar_estoque_csv_bloc.dart';

abstract class ImportarEstoqueCsvEvent {}

// Abre o seletor de arquivos e já atualiza o state com o path escolhido.
class ImportarEstoqueArquivoSelecionado extends ImportarEstoqueCsvEvent {}

class ImportarEstoqueBaixouTemplate extends ImportarEstoqueCsvEvent {}

class ImportarEstoqueEnviou extends ImportarEstoqueCsvEvent {}
