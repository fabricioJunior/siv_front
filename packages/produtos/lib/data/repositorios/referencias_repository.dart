import 'package:produtos/domain/data/remote/i_referencias_remote_data_source.dart';
import 'package:produtos/domain/data/repositorios/i_referencias_repository.dart';
import 'package:produtos/models.dart';

class ReferenciasRepository implements IReferenciasRepository {
  final IReferenciasRemoteDataSource referenciasRemoteDataSource;

  ReferenciasRepository({required this.referenciasRemoteDataSource});

  @override
  Future<Referencia> atualizarReferencia({
    required int id,
    required String nome,
    required int categoriaId,
    int? subCategoriaId,
    String? idExterno,
    String? unidadeMedida,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
  }) {
    return referenciasRemoteDataSource.atualizarReferencia(
      id: id,
      nome: nome,
      categoriaId: categoriaId,
      subCategoriaId: subCategoriaId,
      idExterno: idExterno,
      unidadeMedida: unidadeMedida,
      marcaId: marcaId,
      descricao: descricao,
      composicao: composicao,
      cuidados: cuidados,
    );
  }

  @override
  Future<Referencia> criarReferencia({
    required int id,
    required String nome,
    required int categoriaId,
    int? subCategoriaId,
    String? idExterno,
    String? unidadeMedida,
    int? marcaId,
    String? descricao,
    String? composicao,
    String? cuidados,
  }) {
    return referenciasRemoteDataSource.createReferencia(
      id: id,
      nome: nome,
      categoriaId: categoriaId,
      subCategoriaId: subCategoriaId,
      idExterno: idExterno,
      unidadeMedida: unidadeMedida,
      marcaId: marcaId,
      descricao: descricao,
      composicao: composicao,
      cuidados: cuidados,
    );
  }

  @override
  Future<List<Referencia>> obterReferencias({String? nome, bool? inativo}) {
    return referenciasRemoteDataSource.fetchReferencias(
      nome: nome,
      inativo: inativo,
    );
  }
}
