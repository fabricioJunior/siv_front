import 'dart:typed_data';

import 'package:comunicados/domain/data/repositorios/i_comunicado_repository.dart';
import 'package:comunicados/domain/models/models.dart';
import 'package:comunicados/presentation.dart';
import 'package:comunicados/use_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeComunicadoRepository implements IComunicadoRepository {
  final List<Comunicado> itens;

  _FakeComunicadoRepository(this.itens);

  @override
  Future<({List<Comunicado> items, int total})> listarComunicados({
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) async {
    final filtrados = status == null
        ? itens
        : itens.where((c) => c.status == status).toList();
    return (items: filtrados, total: filtrados.length);
  }

  @override
  Future<int> contarDestinatarios(FiltroDestinatarioComunicado filtro) =>
      throw UnimplementedError();

  @override
  Future<Comunicado> buscarComunicado(int id) => throw UnimplementedError();

  @override
  Future<Comunicado> criar({
    required String assunto,
    required String corpoHtml,
    bool? modoHtmlAvancado,
    required FiltroDestinatarioComunicado filtro,
  }) =>
      throw UnimplementedError();

  @override
  Future<String> enviarImagem(Uint8List bytes, String fileName) =>
      throw UnimplementedError();

  @override
  Future<({List<ComunicadoDestinatario> items, int total})>
  listarDestinatarios(
    int comunicadoId, {
    String? status,
    int pagina = 1,
    int itemsPorPagina = 20,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<PreviewDestinatarioComunicado>> previewDestinatarios(
    FiltroDestinatarioComunicado filtro, {
    int limit = 20,
  }) =>
      throw UnimplementedError();

  @override
  Future<ComunicadoDestinatario> reenviarDestinatario(
    int comunicadoId,
    int destinatarioId,
  ) =>
      throw UnimplementedError();
}

Comunicado _comunicado(int id, String status) => Comunicado(
  id: id,
  empresaId: 1,
  assunto: 'Assunto $id',
  corpoHtml: '<p>oi</p>',
  modoHtmlAvancado: false,
  totalDestinatarios: 10,
  status: status,
  criadoPor: 1,
  criadoEm: DateTime(2026, 1, 1),
  atualizadoEm: DateTime(2026, 1, 1),
);

void main() {
  blocTest<ComunicadosBloc, ComunicadosState>(
    'carrega comunicados e atualiza total/step para sucesso',
    build: () => ComunicadosBloc(
      ListarComunicados(
        repository: _FakeComunicadoRepository([
          _comunicado(1, 'enviado'),
          _comunicado(2, 'erro'),
        ]),
      ),
    ),
    act: (bloc) => bloc.add(ComunicadosCarregar()),
    expect: () => [
      predicate<ComunicadosState>((s) => s.step == ComunicadosStep.carregando),
      predicate<ComunicadosState>(
        (s) => s.step == ComunicadosStep.sucesso && s.total == 2 && s.items.length == 2,
      ),
    ],
  );

  blocTest<ComunicadosBloc, ComunicadosState>(
    'filtra por status quando informado',
    build: () => ComunicadosBloc(
      ListarComunicados(
        repository: _FakeComunicadoRepository([
          _comunicado(1, 'enviado'),
          _comunicado(2, 'erro'),
        ]),
      ),
    ),
    act: (bloc) => bloc.add(ComunicadosCarregar(status: 'erro')),
    expect: () => [
      predicate<ComunicadosState>((s) => s.step == ComunicadosStep.carregando),
      predicate<ComunicadosState>(
        (s) =>
            s.step == ComunicadosStep.sucesso &&
            s.total == 1 &&
            s.items.single.status == 'erro',
      ),
    ],
  );
}
