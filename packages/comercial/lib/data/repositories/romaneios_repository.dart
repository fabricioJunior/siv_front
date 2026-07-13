import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class RomaneiosRepository implements IRomaneiosRepository {
  final IRomaneiosRemoteDataSource remoteDataSource;
  final IReceberRomaneioNoCaixaRemoteDataSource caixasRemoteDataSource;

  RomaneiosRepository({
    required this.remoteDataSource,
    required this.caixasRemoteDataSource,
  });

  @override
  Future<void> adicionarItemRomaneio(int romaneioId, RomaneioItem item) {
    return remoteDataSource.adicionarItemRomaneio(romaneioId, item);
  }

  @override
  Future<Romaneio> atualizarObservacao(int id, String observacao) {
    return remoteDataSource.atualizarObservacao(id, observacao);
  }

  @override
  Future<Romaneio> atualizarVendedor(int id, int funcionarioId) {
    return remoteDataSource.atualizarVendedor(id, funcionarioId);
  }

  @override
  Future<Romaneio> atualizarRomaneio(Romaneio romaneio) {
    return remoteDataSource.atualizarRomaneio(romaneio);
  }

  @override
  Future<Romaneio> criarRomaneio(Romaneio romaneio) {
    return remoteDataSource.criarRomaneio(romaneio);
  }

  @override
  Future<Romaneio> recuperarRomaneio(int id) {
    return remoteDataSource.recuperarRomaneio(id);
  }

  @override
  Future<List<RomaneioItem>> recuperarItensRomaneio(int romaneioId) {
    return remoteDataSource.recuperarItensRomaneio(romaneioId);
  }

  @override
  Future<List<RomaneioItemDevolvido>> recuperarItensDevolvidosRomaneio(
    int romaneioId,
  ) {
    return remoteDataSource.recuperarItensDevolvidosRomaneio(romaneioId);
  }

  @override
  Future<List<Romaneio>> recuperarRomaneios({
    int page = 1,
    int limit = 50,
    String? searchTerm,
    int? caixaId,
    DateTime? dataHoraInicial,
    DateTime? dataHoraFinal,
    List<TipoOperacao>? operacoes,
  }) {
    return remoteDataSource.recuperarRomaneios(
      page: page,
      limit: limit,
      searchTerm: searchTerm,
      caixaId: caixaId,
      dataHoraInicial: dataHoraInicial,
      dataHoraFinal: dataHoraFinal,
      operacoes: operacoes,
    );
  }

  @override
  Future<void> removerItemRomaneio(int romaneioId, RomaneioItem item) {
    return remoteDataSource.removerItemRomaneio(romaneioId, item);
  }

  @override
  Future<void> receberRomaneioNoCaixa({
    required int caixaId,
    required int romaneioId,
    required List<RomaneioPagamentoRealizado> formasDePagamentoRealizadas,
    List<Map<String, dynamic>> descontosItens = const [],
    bool incluirCpfNaNota = true,
    String cpfNaNota = '',
  }) {
    return caixasRemoteDataSource.receberRomaneio(
      caixaId: caixaId,
      romaneioId: romaneioId,
      formasDePagamentoRealizadas: formasDePagamentoRealizadas,
      descontosItens: descontosItens,
      incluirCpfNaNota: incluirCpfNaNota,
      cpfNaNota: cpfNaNota,
    );
  }
}
