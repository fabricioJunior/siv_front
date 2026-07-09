import 'package:core/equals.dart';
import 'package:core/produtos_compartilhados.dart';

class OrcamentoLocal extends Equatable {
  final String hash;
  final DateTime criadoEm;
  final DateTime atualizadoEm;
  final int? clienteId;
  final String? clienteNome;
  final int? funcionarioId;
  final String? funcionarioNome;
  final int? tabelaPrecoId;
  final String? tabelaPrecoNome;
  final List<ProdutoCompartilhado> itens;

  const OrcamentoLocal({
    required this.hash,
    required this.criadoEm,
    required this.atualizadoEm,
    this.clienteId,
    this.clienteNome,
    this.funcionarioId,
    this.funcionarioNome,
    this.tabelaPrecoId,
    this.tabelaPrecoNome,
    required this.itens,
  });

  double get valorTotal => itens.fold(
        0.0,
        (soma, item) => soma + (item.valorUnitario * item.quantidade),
      );

  int get quantidadeTotal =>
      itens.fold(0, (soma, item) => soma + item.quantidade);

  factory OrcamentoLocal.criar({
    String? hash,
    int? clienteId,
    String? clienteNome,
    int? funcionarioId,
    String? funcionarioNome,
    int? tabelaPrecoId,
    String? tabelaPrecoNome,
    required List<ProdutoCompartilhado> itens,
  }) {
    final agora = DateTime.now();
    return OrcamentoLocal(
      hash: hash ?? 'orcamento-${agora.microsecondsSinceEpoch}',
      criadoEm: agora,
      atualizadoEm: agora,
      clienteId: clienteId,
      clienteNome: clienteNome,
      funcionarioId: funcionarioId,
      funcionarioNome: funcionarioNome,
      tabelaPrecoId: tabelaPrecoId,
      tabelaPrecoNome: tabelaPrecoNome,
      itens: itens,
    );
  }

  OrcamentoLocal copyWith({List<ProdutoCompartilhado>? itens}) {
    return OrcamentoLocal(
      hash: hash,
      criadoEm: criadoEm,
      atualizadoEm: DateTime.now(),
      clienteId: clienteId,
      clienteNome: clienteNome,
      funcionarioId: funcionarioId,
      funcionarioNome: funcionarioNome,
      tabelaPrecoId: tabelaPrecoId,
      tabelaPrecoNome: tabelaPrecoNome,
      itens: itens ?? this.itens,
    );
  }

  @override
  List<Object?> get props => [
        hash,
        criadoEm,
        atualizadoEm,
        clienteId,
        clienteNome,
        funcionarioId,
        funcionarioNome,
        tabelaPrecoId,
        tabelaPrecoNome,
        itens,
      ];
}
