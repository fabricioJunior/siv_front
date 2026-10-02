import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/domain/data/repositorios/i_referencias_busca_repository.dart';
import 'package:produtos/domain/referencias_filtro.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

import '../../doubles/servidor_referencias.dart';

ItemListaReferencia item(
  int id,
  String nome, {
  int categoriaId = 10,
  String? ncm = '61091000',
  int? peso = 250,
  String? marca,
}) => ItemListaReferencia(
  referencia: fakeReferencia(
    id,
    nome,
    categoriaId: categoriaId,
    categoria: 'Cat $categoriaId',
    ncm: ncm,
    peso: peso,
  ),
  marcaNome: marca,
);

// Repositório controlado pelo teste: cada chamada devolve um Completer, para decidir a ordem das respostas.
class _RepoManual implements IReferenciasBuscaRepository {
  final chamadas = <ChamadaBusca>[];
  final pendentes = <Completer<ReferenciasBuscaResultado>>[];

  @override
  Future<ReferenciasBuscaResultado> buscar({
    String? busca,
    int? categoriaId,
    bool semNcm = false,
    bool semPeso = false,
    String orderBy = 'nome',
    String orderDir = 'ASC',
    int page = 1,
  }) {
    chamadas.add((
      busca: busca,
      categoriaId: categoriaId,
      semNcm: semNcm,
      semPeso: semPeso,
      orderBy: orderBy,
      orderDir: orderDir,
      page: page,
    ));
    final c = Completer<ReferenciasBuscaResultado>();
    pendentes.add(c);
    return c.future;
  }
}

ReferenciasBuscaResultado resultado(
  List<ItemListaReferencia> itens, {
  int total = -1,
  int pagina = 1,
  int paginas = 1,
}) => ReferenciasBuscaResultado(
  items: itens,
  totalItems: total < 0 ? itens.length : total,
  totalPages: paginas,
  currentPage: pagina,
  resumo: const ResumoReferencias(
    semNcm: 2,
    semPeso: 3,
    categorias: [CategoriaDoResumo(id: 10, nome: 'Camisas', total: 5)],
  ),
);

Future<void> pumpEventos() => Future<void>.delayed(Duration.zero);

void main() {
  late ServidorReferenciasFake servidor;
  late ReferenciasListaBloc bloc;

  ReferenciasListaBloc criar(IReferenciasBuscaRepository repo) =>
      ReferenciasListaBloc(BuscarReferencias(repository: repo));

  tearDown(() async => bloc.close());

  group('com servidor falso', () {
    setUp(() {
      servidor = ServidorReferenciasFake([
        item(1, 'Camisa Básica', marca: 'Vale'),
        item(2, 'Camisa Polo', ncm: null),
        item(3, 'Calça Jeans', categoriaId: 20, peso: null),
        item(4, 'Vestido', categoriaId: 30, ncm: null, peso: null),
      ], tamanhoPagina: 2);
      bloc = criar(servidor);
    });

    test(
      'Iniciou: página 1 sem filtro, ordenado por nome, com resumo e marca',
      () async {
        bloc.add(const ReferenciasListaIniciou());
        await bloc.stream.firstWhere(
          (s) => s.etapa == ReferenciasListaEtapa.carregado,
        );

        expect(servidor.chamadas.single, (
          busca: '',
          categoriaId: null,
          semNcm: false,
          semPeso: false,
          orderBy: 'nome',
          orderDir: 'ASC',
          page: 1,
        ));
        expect(bloc.state.itens.map((i) => i.referencia.nome), [
          'Calça Jeans',
          'Camisa Básica',
        ]);
        expect(bloc.state.totalItens, 4);
        expect(
          [bloc.state.paginaAtual, bloc.state.totalPaginas, bloc.state.temMais],
          [1, 2, true],
        );
        expect(bloc.state.resumo.semNcm, 2);
        expect(bloc.state.resumo.categorias.map((c) => c.nome), [
          'Cat 10',
          'Cat 20',
          'Cat 30',
        ]);
      },
    );

    test(
      'Filtrou: manda busca, categoria e pendências ao servidor e volta para a página 1',
      () async {
        bloc.add(const ReferenciasListaIniciou());
        await bloc.stream.firstWhere(
          (s) => s.etapa == ReferenciasListaEtapa.carregado,
        );

        bloc.add(
          const ReferenciasListaFiltrou(
            filtro: ReferenciasFiltro(
              busca: 'camisa',
              categoriaId: 10,
              semNcm: true,
            ),
          ),
        );
        await bloc.stream.firstWhere(
          (s) => !s.atualizando && s.filtro.busca == 'camisa',
        );

        final chamada = servidor.chamadas.last;
        expect(
          [
            chamada.busca,
            chamada.categoriaId,
            chamada.semNcm,
            chamada.semPeso,
            chamada.page,
          ],
          ['camisa', 10, true, false, 1],
        );
        expect(bloc.state.itens.map((i) => i.referencia.nome), ['Camisa Polo']);
        expect(bloc.state.totalItens, 1);
      },
    );

    test(
      'Filtrou durante a busca: a lista anterior fica na tela com "atualizando"',
      () async {
        bloc.add(const ReferenciasListaIniciou());
        await bloc.stream.firstWhere(
          (s) => s.etapa == ReferenciasListaEtapa.carregado,
        );

        bloc.add(
          const ReferenciasListaFiltrou(
            filtro: ReferenciasFiltro(busca: 'vest'),
          ),
        );
        final durante = await bloc.stream.firstWhere((s) => s.atualizando);

        expect(durante.itens, isNotEmpty);
        expect(durante.etapa, ReferenciasListaEtapa.carregado);
      },
    );

    test('ordenação vai para o servidor como campo + direção', () async {
      bloc.add(const ReferenciasListaIniciou());
      await bloc.stream.firstWhere(
        (s) => s.etapa == ReferenciasListaEtapa.carregado,
      );

      for (final (ordenacao, campo, direcao) in [
        (ReferenciasOrdenacao.nomeDesc, 'nome', 'DESC'),
        (ReferenciasOrdenacao.criadoEmAsc, 'criadoEm', 'ASC'),
        (ReferenciasOrdenacao.criadoEmDesc, 'criadoEm', 'DESC'),
        (ReferenciasOrdenacao.atualizadoEmAsc, 'atualizadoEm', 'ASC'),
        (ReferenciasOrdenacao.atualizadoEmDesc, 'atualizadoEm', 'DESC'),
        (ReferenciasOrdenacao.nomeAsc, 'nome', 'ASC'),
      ]) {
        bloc.add(ReferenciasListaFiltrou(ordenacao: ordenacao));
        await bloc.stream.firstWhere(
          (s) => !s.atualizando && s.ordenacao == ordenacao,
        );
        expect(
          [servidor.chamadas.last.orderBy, servidor.chamadas.last.orderDir],
          [campo, direcao],
          reason: '$ordenacao',
        );
      }
    });

    test(
      'CarregouMais: acrescenta a próxima página com o mesmo filtro e para quando acabam as páginas',
      () async {
        bloc.add(const ReferenciasListaIniciou());
        await bloc.stream.firstWhere(
          (s) => s.etapa == ReferenciasListaEtapa.carregado,
        );

        bloc.add(const ReferenciasListaCarregouMais());
        await bloc.stream.firstWhere((s) => s.paginaAtual == 2);

        expect(bloc.state.itens.map((i) => i.referencia.nome), [
          'Calça Jeans',
          'Camisa Básica',
          'Camisa Polo',
          'Vestido',
        ]);
        expect(bloc.state.temMais, isFalse);
        expect(servidor.chamadas.last.page, 2);

        final antes = servidor.chamadas.length;
        bloc.add(const ReferenciasListaCarregouMais());
        await pumpEventos();
        expect(
          servidor.chamadas.length,
          antes,
          reason: 'sem mais páginas não consulta',
        );
      },
    );

    test('Recarregou: volta à página 1 mantendo o filtro', () async {
      bloc.add(
        const ReferenciasListaFiltrou(
          filtro: ReferenciasFiltro(busca: 'camisa'),
        ),
      );
      await bloc.stream.firstWhere(
        (s) => s.etapa == ReferenciasListaEtapa.carregado,
      );

      bloc.add(const ReferenciasListaRecarregou());
      await pumpEventos();
      await pumpEventos();

      expect(servidor.chamadas.length, 2);
      expect(servidor.chamadas.last.busca, 'camisa');
      expect(servidor.chamadas.last.page, 1);
    });

    test(
      'falha do servidor: etapa "falha" e o erro vai para o addError',
      () async {
        servidor.falha = Exception('sem rede');

        bloc.add(const ReferenciasListaIniciou());
        await bloc.stream.firstWhere(
          (s) => s.etapa == ReferenciasListaEtapa.falha,
        );

        expect(bloc.state.itens, isEmpty);
      },
    );
  });

  group('ordem das respostas', () {
    late _RepoManual repo;

    setUp(() {
      repo = _RepoManual();
      bloc = criar(repo);
    });

    test(
      'a última busca vence: resposta atrasada de uma busca antiga é descartada',
      () async {
        bloc.add(
          const ReferenciasListaFiltrou(
            filtro: ReferenciasFiltro(busca: 'cam'),
          ),
        );
        await pumpEventos();
        bloc.add(
          const ReferenciasListaFiltrou(
            filtro: ReferenciasFiltro(busca: 'camisa'),
          ),
        );
        await pumpEventos();
        expect(repo.chamadas.map((c) => c.busca), ['cam', 'camisa']);

        repo.pendentes[1].complete(resultado([item(1, 'Camisa Básica')]));
        await pumpEventos();
        repo.pendentes[0].complete(
          resultado([item(2, 'Camarão'), item(3, 'Camisola')]),
        );
        await pumpEventos();

        expect(bloc.state.itens.map((i) => i.referencia.nome), [
          'Camisa Básica',
        ]);
        expect(bloc.state.filtro.busca, 'camisa');
        expect(bloc.state.atualizando, isFalse);
      },
    );

    test(
      'próxima página que chega depois de o filtro mudar não entra na lista nova',
      () async {
        bloc.add(const ReferenciasListaIniciou());
        await pumpEventos();
        repo.pendentes[0].complete(
          resultado([item(1, 'A')], total: 4, paginas: 2),
        );
        await pumpEventos();

        bloc.add(const ReferenciasListaCarregouMais());
        await pumpEventos();
        bloc.add(
          const ReferenciasListaFiltrou(filtro: ReferenciasFiltro(busca: 'x')),
        );
        await pumpEventos();

        repo.pendentes[2].complete(resultado([item(9, 'Z')]));
        await pumpEventos();
        repo.pendentes[1].complete(
          resultado(
            [item(8, 'Pagina2 antiga')],
            pagina: 2,
            total: 4,
            paginas: 2,
          ),
        );
        await pumpEventos();

        expect(bloc.state.itens.map((i) => i.referencia.nome), ['Z']);
      },
    );

    test(
      'CarregouMais é ignorado enquanto já há uma página vindo ou uma busca em andamento',
      () async {
        bloc.add(const ReferenciasListaIniciou());
        await pumpEventos();
        repo.pendentes[0].complete(
          resultado([item(1, 'A')], total: 4, paginas: 2),
        );
        await pumpEventos();

        bloc.add(const ReferenciasListaCarregouMais());
        bloc.add(const ReferenciasListaCarregouMais());
        await pumpEventos();

        expect(repo.chamadas.where((c) => c.page == 2), hasLength(1));
      },
    );
  });
}
