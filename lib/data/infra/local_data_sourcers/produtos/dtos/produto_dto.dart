import 'package:core/isar_anotacoes.dart';
import 'package:siv_front/data/infra/local_data_sourcers/produtos/models/produto_para_leitor.dart';

part 'produto_dto.g.dart';

@Collection(ignore: {'dados', 'descricao', 'quantidade'})
class ProdutoDto implements IsarDto, ProdutoParaLeitor {
  final int id;
  @override
  final String codigoDeBarras;
  final String nomeReferencia;
  final String nomeCor;
  final String nomeTamanho;

  final int referenciaId;
  final int corId;
  final int tamanhoId;

  final int quantidadeEmEstoque;
  final int empresaId;

  final DateTime? atualizadoEm;

  ProdutoDto({
    required this.id,
    required this.codigoDeBarras,
    required this.nomeReferencia,
    required this.nomeCor,
    required this.nomeTamanho,
    required this.referenciaId,
    required this.corId,
    required this.tamanhoId,
    required this.quantidadeEmEstoque,
    required this.empresaId,
    this.atualizadoEm,
  });

  @override
  Id get dataBaseId => fastHash(codigoDeBarras);

  @override
  @ignore
  Map<String, dynamic> get dados => {
        'id': id,
        'codigoDeBarras': codigoDeBarras,
        'nomeReferencia': nomeReferencia,
        'nomeCor': nomeCor,
        'nomeTamanho': nomeTamanho,
        'referenciaId': referenciaId,
        'corId': corId,
        'tamanhoId': tamanhoId,
        'quantidadeEmEstoque': quantidadeEmEstoque,
        'empresaId': empresaId,
        'atualizadoEm': atualizadoEm?.toIso8601String(),
      };

  @override
  @ignore
  String get descricao => nomeReferencia;
  @override
  @ignore
  int get quantidade => quantidadeEmEstoque;
}
