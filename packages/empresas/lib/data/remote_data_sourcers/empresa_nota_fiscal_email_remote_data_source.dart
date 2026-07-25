import 'package:core/remote_data_sourcers.dart';
import 'package:empresas/data/remote_data_sourcers/dtos/empresa_nota_fiscal_email_dto.dart';
import 'package:empresas/domain/data/remote_data_sourcers/i_empresa_nota_fiscal_email_remote_data_source.dart';
import 'package:empresas/domain/entities/empresa_nota_fiscal_email.dart';

class EmpresaNotaFiscalEmailRemoteDataSource extends RemoteDataSourceBase
    implements IEmpresaNotaFiscalEmailRemoteDataSource {
  EmpresaNotaFiscalEmailRemoteDataSource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/empresas/{empresaId}/nota-fiscal-email/configuracao';

  @override
  Future<EmpresaNotaFiscalEmail> recuperarConfiguracao(int empresaId) async {
    final response = await get(
      pathParameters: {'empresaId': empresaId.toString()},
    );

    return EmpresaNotaFiscalEmailDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }

  @override
  Future<EmpresaNotaFiscalEmail> atualizarConfiguracao(
    EmpresaNotaFiscalEmail configuracao,
  ) async {
    final response = await put(
      pathParameters: {'empresaId': configuracao.empresaId.toString()},
      body: configuracao.toDto().toJson(),
    );

    return EmpresaNotaFiscalEmailDto.fromJson(
      response.body as Map<String, dynamic>,
    );
  }
}
