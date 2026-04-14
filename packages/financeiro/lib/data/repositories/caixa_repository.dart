import 'package:financeiro/domain/data/remote/i_caixa_remote_data_source.dart';
import 'package:financeiro/domain/data/remote/i_extrato_caixa_remote_data_source.dart';
import 'package:financeiro/domain/data/repositories/i_caixa_repository.dart';
import 'package:financeiro/domain/models/caixa.dart';
import 'package:financeiro/domain/models/extrato_caixa.dart';

class CaixaRepository implements ICaixaRepository {
  final ICaixaRemoteDataSource caixaRemoteDataSource;
  final IExtratoCaixaRemoteDataSource extratoCaixaRemoteDataSource;

  CaixaRepository({
    required this.caixaRemoteDataSource,
    required this.extratoCaixaRemoteDataSource,
  });

  @override
  Future<Caixa> abrirCaixa({required int idEmpresa, required int terminalId}) {
    return caixaRemoteDataSource.abrirCaixa(
      idEmpresa: idEmpresa,
      terminalId: terminalId,
    );
  }

  @override
  Future<List<ExtratoCaixa>> buscarExtratoCaixa({required int caixaId}) {
    return extratoCaixaRemoteDataSource.buscarExtratoCaixa(caixaId: caixaId);
  }

  @override
  Future<List<ExtratoCaixa>> buscarExtratoCaixaPorDocumento({
    required int caixaId,
    required String documento,
  }) {
    return extratoCaixaRemoteDataSource.buscarExtratoCaixaPorDocumento(
      caixaId: caixaId,
      documento: documento,
    );
  }

  @override
  Future<Caixa?> recuperarCaixaAberto(
      {required int idEmpresa, required int terminalId}) {
    return caixaRemoteDataSource.recuperarCaixaAberto(
      idEmpresa: idEmpresa,
      terminalId: terminalId,
    );
  }
}
