import 'package:core/remote_data_sourcers.dart';
import 'package:financeiro/data/remote/dtos/despesa_dto.dart';
import 'package:financeiro/domain/data/remote/i_despesas_remote_data_source.dart';
import 'package:financeiro/domain/models/despesa.dart';

class DespesasRemoteDataSource extends RemoteDataSourceBase
    implements IDespesasRemoteDataSource {
  DespesasRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/despesas';

  @override
  Future<Despesa> criarDespesa(Despesa despesa) async {
    final response = await post(body: DespesaDto.fromModel(despesa).toCreateJson());
    return DespesaDto.fromJson(response.body as Map<String, dynamic>);
  }

  @override
  Future<List<Despesa>> recuperarDespesas({
    required int empresaId,
    int? categoriaId,
    StatusDespesa? status,
    DateTime? dataInicial,
    DateTime? dataFinal,
    bool? recorrente,
    String? grupoParcelamentoId,
  }) async {
    final response = await get(
      queryParameters: {
        'empresaId': empresaId.toString(),
        if (categoriaId != null) 'categoriaId': categoriaId.toString(),
        if (status != null) 'status': status.value,
        if (dataInicial != null)
          'dataInicial': dataInicial.toIso8601String(),
        if (dataFinal != null) 'dataFinal': dataFinal.toIso8601String(),
        if (recorrente != null) 'recorrente': recorrente.toString(),
        if (grupoParcelamentoId != null)
          'grupoParcelamentoId': grupoParcelamentoId,
      },
    );

    return (response.body as List<dynamic>)
        .map((json) => DespesaDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
