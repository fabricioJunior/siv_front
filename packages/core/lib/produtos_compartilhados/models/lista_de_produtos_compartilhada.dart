import 'package:core/equals.dart';
import 'package:uuid/uuid.dart';

class ListaDeProdutosCompartilhada extends Equatable {
  final String hash;
  final int? idLista;
  final OrigemCompartilhadaTipo origem;
  final DateTime criadaEm;
  final DateTime atualizadaEm;
  final int? funcionarioId;
  final int? tabelaPrecoId;
  final bool? processada;

  const ListaDeProdutosCompartilhada({
    required this.hash,
    this.idLista,
    required this.origem,
    required this.criadaEm,
    required this.atualizadaEm,
    this.funcionarioId,
    this.tabelaPrecoId,
    this.processada,
  });

  ListaDeProdutosCompartilhada copyWith({
    String? hash,
    int? idLista,
    OrigemCompartilhadaTipo? origem,
    DateTime? criadaEm,
    DateTime? atualizadaEm,
    int? funcionarioId,
    int? tabelaPrecoId,
    bool? processada,
  }) {
    return ListaDeProdutosCompartilhada(
      hash: hash ?? this.hash,
      idLista: idLista ?? this.idLista,
      origem: origem ?? this.origem,
      criadaEm: criadaEm ?? this.criadaEm,
      atualizadaEm: atualizadaEm ?? this.atualizadaEm,
      funcionarioId: funcionarioId ?? this.funcionarioId,
      tabelaPrecoId: tabelaPrecoId ?? this.tabelaPrecoId,
      processada: processada ?? this.processada,
    );
  }

  factory ListaDeProdutosCompartilhada.criar({
    int? id,
    required OrigemCompartilhadaTipo origem,
    DateTime? criadaEm,
    DateTime? atualizadaEm,
    int? funcionarioId,
    int? tabelaPrecoId,
  }) {
    final agora = DateTime.now();
    return ListaDeProdutosCompartilhada(
      hash: const Uuid().v4(),
      idLista: id,
      origem: origem,
      criadaEm: criadaEm ?? agora,
      atualizadaEm: atualizadaEm ?? agora,
      funcionarioId: funcionarioId,
      tabelaPrecoId: tabelaPrecoId,
    );
  }

  @override
  List<Object?> get props => [
        origem,
        criadaEm,
        atualizadaEm,
        hash,
        idLista,
        funcionarioId,
        tabelaPrecoId,
      ];
}

enum OrigemCompartilhadaTipo {
  romenioEntradaDeProdutos,
  romenioSaidaDeProdutos,
}
