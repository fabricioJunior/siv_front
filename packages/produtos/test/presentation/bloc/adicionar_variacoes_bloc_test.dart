import 'package:core/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:produtos/data/remote/dtos/cor_dto.dart';
import 'package:produtos/data/remote/dtos/estampa_dto.dart';
import 'package:produtos/data/remote/dtos/tamanho_dto.dart';
import 'package:produtos/domain/data/repositorios/i_cores_repository.dart';
import 'package:produtos/domain/data/repositorios/i_estampas_repository.dart';
import 'package:produtos/domain/data/repositorios/i_produtos_repository.dart';
import 'package:produtos/domain/data/repositorios/i_tamanhos_repository.dart';
import 'package:produtos/models.dart';
import 'package:produtos/presentation.dart';
import 'package:produtos/use_cases.dart';

class _DummyCoresRepo implements ICoresRepository {
  @override
  Future<Cor> criarCor(String nome) => throw UnimplementedError();
  @override
  Future<Cor> atualizarCor(int id, String nome) => throw UnimplementedError();
  @override
  Future<void> desativarCor(int id) => throw UnimplementedError();
  @override
  Future<Cor?> obterCor(int id) => throw UnimplementedError();
  @override
  Future<List<Cor>> obterCores({String? nome, bool? inativo}) =>
      throw UnimplementedError();
}

class _FakeRecuperarCores extends RecuperarCores {
  final List<Cor> cores;
  _FakeRecuperarCores(this.cores) : super(coresRepository: _DummyCoresRepo());
  @override
  Future<List<Cor>> call({String? nome, bool? inativo}) async => cores;
}

class _DummyTamanhosRepo implements ITamanhosRepository {
  @override
  Future<Tamanho> criarTamanho(String nome) => throw UnimplementedError();
  @override
  Future<Tamanho> atualizarTamanho(int id, String nome) =>
      throw UnimplementedError();
  @override
  Future<void> desativarTamanho(int id) => throw UnimplementedError();
  @override
  Future<Tamanho?> obterTamanho(int id) => throw UnimplementedError();
  @override
  Future<List<Tamanho>> obterTamanhos({String? nome, bool? inativo}) =>
      throw UnimplementedError();
}

class _FakeRecuperarTamanhos extends RecuperarTamanhos {
  final List<Tamanho> tamanhos;
  _FakeRecuperarTamanhos(this.tamanhos)
    : super(tamanhosRepository: _DummyTamanhosRepo());
  @override
  Future<List<Tamanho>> call({String? nome, bool? inativo}) async => tamanhos;
}

class _DummyEstampasRepo implements IEstampasRepository {
  @override
  Future<Estampa> criarEstampa(String nome) => throw UnimplementedError();
  @override
  Future<Estampa> atualizarEstampa(int id, String nome) =>
      throw UnimplementedError();
  @override
  Future<void> desativarEstampa(int id) => throw UnimplementedError();
  @override
  Future<Estampa?> obterEstampa(int id) => throw UnimplementedError();
  @override
  Future<List<Estampa>> obterEstampas({String? nome, bool? inativo}) =>
      throw UnimplementedError();
}

class _FakeRecuperarEstampas extends RecuperarEstampas {
  final List<Estampa> estampas;
  _FakeRecuperarEstampas(this.estampas)
    : super(estampasRepository: _DummyEstampasRepo());
  @override
  Future<List<Estampa>> call({String? nome, bool? inativo}) async => estampas;
}

class _DummyProdutosRepo implements IProdutosRepository {
  @override
  Future<Produto> criarProduto({
    required int referenciaId,
    String? idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
  }) => throw UnimplementedError();
  @override
  Future<List<Produto>> criarProdutos(List<NovoProdutoCombinacao> itens) =>
      throw UnimplementedError();
  @override
  Future<Produto> atualizarProduto({
    required int id,
    required int referenciaId,
    required String idExterno,
    required int corId,
    required int tamanhoId,
    int? estampaId,
  }) => throw UnimplementedError();
  @override
  Future<void> excluirProduto(int id) => throw UnimplementedError();
  @override
  Future<ExclusaoProdutosEmLoteResultado> excluirProdutosEmLote(
    List<int> ids,
  ) => throw UnimplementedError();
  @override
  Future<List<Produto>> obterProdutos({
    String? idExterno,
    int? referenciaId,
    int idCor = 0,
    int idTamanho = 0,
    int? idEstampa,
  }) => throw UnimplementedError();
}

class _FakeCriarProdutosEmLote extends CriarProdutosEmLote {
  List<NovoProdutoCombinacao>? ultimaChamada;
  _FakeCriarProdutosEmLote() : super(produtosRepository: _DummyProdutosRepo());

  @override
  Future<List<Produto>> call(List<NovoProdutoCombinacao> itens) async {
    ultimaChamada = itens;
    return itens
        .map(
          (item) => Produto.create(
            referenciaId: item.referenciaId,
            idExterno: '',
            corId: item.corId,
            tamanhoId: item.tamanhoId,
            estampaId: item.estampaId,
          ),
        )
        .toList();
  }
}

void main() {
  final coresDisponiveis = [
    CorDto(id: 1, nome: 'Preto', inativo: false),
    CorDto(id: 2, nome: 'Azul', inativo: false),
  ];
  final tamanhosDisponiveis = [
    TamanhoDto(id: 1, nome: 'P', inativo: false),
    TamanhoDto(id: 2, nome: 'M', inativo: false),
  ];
  final estampasDisponiveis = [
    EstampaDto(id: 1, nome: 'Floral', inativo: false),
  ];

  AdicionarVariacoesBloc build() => AdicionarVariacoesBloc(
    _FakeRecuperarCores(coresDisponiveis),
    _FakeRecuperarTamanhos(tamanhosDisponiveis),
    _FakeRecuperarEstampas(estampasDisponiveis),
    CriarCodigoDeBarras(),
    _FakeCriarProdutosEmLote(),
  );

  group('AdicionarVariacoesBloc - travamento -', () {
    blocTest<AdicionarVariacoesBloc, AdicionarVariacoesState>(
      'cor já na grade vem marcada e não pode ser desmarcada',
      build: build,
      act: (bloc) async {
        bloc.add(
          AdicionarVariacoesIniciou(
            referenciaId: 1,
            corIdsNaGrade: {1},
            chavesNaGrade: {'1|1|'},
          ),
        );
        await Future<void>.delayed(Duration.zero);
        bloc.add(AdicionarVariacoesCorAlternou(corId: 1));
      },
      verify: (bloc) {
        expect(bloc.state.coresSelecionadas, {1});
        expect(bloc.state.podeDesmarcarCor(1), isFalse);
      },
    );

    blocTest<AdicionarVariacoesBloc, AdicionarVariacoesState>(
      'cor nova pode ser marcada e desmarcada livremente',
      build: build,
      act: (bloc) async {
        bloc.add(AdicionarVariacoesIniciou(referenciaId: 1));
        await Future<void>.delayed(Duration.zero);
        bloc.add(AdicionarVariacoesCorAlternou(corId: 2));
        bloc.add(AdicionarVariacoesCorAlternou(corId: 2));
      },
      verify: (bloc) {
        expect(bloc.state.coresSelecionadas, isEmpty);
        expect(bloc.state.podeDesmarcarCor(2), isTrue);
      },
    );
  });

  group('AdicionarVariacoesBloc - diff rascunho x grade aplicada -', () {
    blocTest<AdicionarVariacoesBloc, AdicionarVariacoesState>(
      'combinações novas = cruzamento do rascunho menos o que já existe na grade',
      build: build,
      act: (bloc) async {
        // Preto/P já existe. Selecionando Preto+Azul x P+M o diff deve
        // excluir só Preto/P.
        bloc.add(
          AdicionarVariacoesIniciou(
            referenciaId: 1,
            corIdsNaGrade: {1},
            tamanhoIdsNaGrade: {1},
            chavesNaGrade: {'1|1|'},
          ),
        );
        await Future<void>.delayed(Duration.zero);
        bloc.add(AdicionarVariacoesCorAlternou(corId: 2));
        bloc.add(AdicionarVariacoesTamanhoAlternou(tamanhoId: 2));
      },
      verify: (bloc) {
        final combinacoes = bloc.state.combinacoesNovas.toSet();
        expect(combinacoes, {
          const ComboDeGrade(corId: 1, tamanhoId: 2, estampaId: null),
          const ComboDeGrade(corId: 2, tamanhoId: 1, estampaId: null),
          const ComboDeGrade(corId: 2, tamanhoId: 2, estampaId: null),
        });
        expect(bloc.state.totalCombinacoesNovas, 3);
      },
    );

    blocTest<AdicionarVariacoesBloc, AdicionarVariacoesState>(
      'confirmar cria só as combinações novas (não repete o que já existe)',
      build: build,
      act: (bloc) async {
        bloc.add(
          AdicionarVariacoesIniciou(
            referenciaId: 1,
            corIdsNaGrade: {1},
            tamanhoIdsNaGrade: {1},
            chavesNaGrade: {'1|1|'},
          ),
        );
        await Future<void>.delayed(Duration.zero);
        bloc.add(AdicionarVariacoesTamanhoAlternou(tamanhoId: 2));
        bloc.add(AdicionarVariacoesConfirmou());
      },
      wait: const Duration(milliseconds: 10),
      verify: (bloc) {
        expect(bloc.state.step, AdicionarVariacoesStep.sucesso);
        expect(bloc.state.criados, hasLength(1));
        expect(bloc.state.criados.first.tamanhoId, 2);
      },
    );
  });
}
