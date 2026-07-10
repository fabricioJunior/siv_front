import 'package:core/equals.dart';
import 'package:uuid/uuid.dart';

class ListaDeProdutosCompartilhada extends Equatable {
  final String hash;
  final int? idLista;
  final OrigemCompartilhadaTipo origem;
  final DateTime criadaEm;
  final DateTime atualizadaEm;
  final int? pessoaId;
  final int? funcionarioId;
  final int? tabelaPrecoId;
  final bool? processada;
  final String? clienteNome;
  final String? funcionarioNome;
  final String? tabelaPrecoNome;

  const ListaDeProdutosCompartilhada({
    required this.hash,
    this.idLista,
    required this.origem,
    required this.criadaEm,
    required this.atualizadaEm,
    this.pessoaId,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.processada,
    this.clienteNome,
    this.funcionarioNome,
    this.tabelaPrecoNome,
  });

  ListaDeProdutosCompartilhada copyWith({
    String? hash,
    int? idLista,
    OrigemCompartilhadaTipo? origem,
    DateTime? criadaEm,
    DateTime? atualizadaEm,
    int? pessoaId,
    int? funcionarioId,
    int? tabelaPrecoId,
    bool? processada,
    String? clienteNome,
    String? funcionarioNome,
    String? tabelaPrecoNome,
  }) {
    return ListaDeProdutosCompartilhada(
      hash: hash ?? this.hash,
      idLista: idLista ?? this.idLista,
      origem: origem ?? this.origem,
      criadaEm: criadaEm ?? this.criadaEm,
      atualizadaEm: atualizadaEm ?? this.atualizadaEm,
      pessoaId: pessoaId ?? this.pessoaId,
      funcionarioId: funcionarioId ?? this.funcionarioId,
      tabelaPrecoId: tabelaPrecoId ?? this.tabelaPrecoId,
      processada: processada ?? this.processada,
      clienteNome: clienteNome ?? this.clienteNome,
      funcionarioNome: funcionarioNome ?? this.funcionarioNome,
      tabelaPrecoNome: tabelaPrecoNome ?? this.tabelaPrecoNome,
    );
  }

  factory ListaDeProdutosCompartilhada.criar({
    int? id,
    required OrigemCompartilhadaTipo origem,
    DateTime? criadaEm,
    DateTime? atualizadaEm,
    int? pessoaId,
    int? funcionarioId,
    int? tabelaPrecoId,
    String? clienteNome,
    String? funcionarioNome,
    String? tabelaPrecoNome,
  }) {
    final agora = DateTime.now();
    return ListaDeProdutosCompartilhada(
      hash: const Uuid().v4(),
      idLista: id,
      origem: origem,
      criadaEm: criadaEm ?? agora,
      atualizadaEm: atualizadaEm ?? agora,
      pessoaId: pessoaId,
      funcionarioId: funcionarioId,
      tabelaPrecoId: tabelaPrecoId,
      clienteNome: clienteNome,
      funcionarioNome: funcionarioNome,
      tabelaPrecoNome: tabelaPrecoNome,
    );
  }

  @override
  List<Object?> get props => [
        origem,
        criadaEm,
        atualizadaEm,
        hash,
        idLista,
        pessoaId,
        funcionarioId,
        tabelaPrecoId,
        clienteNome,
        funcionarioNome,
        tabelaPrecoNome,
      ];
}

enum OrigemCompartilhadaTipo {
  romenioEntradaDeProdutos,
  romenioSaidaDeProdutos,
  venda,
  vendaDevolucao,
  manualEntradaDeProdutos,
  manualSaidaDeProdutos,
  orcamento,
  consignacaoSaida,
  consignacaoDevolucao,
}
