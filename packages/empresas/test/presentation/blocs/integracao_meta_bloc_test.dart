import 'package:core/bloc_test.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';
import 'package:empresas/presentation/blocs/integracao_meta_bloc/integracao_meta_bloc.dart';
import 'package:empresas/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class _Recuperar extends Fake implements RecuperarIntegracaoMeta {
  Future<IntegracaoMeta> Function(int) resposta = (_) async => _config;

  @override
  Future<IntegracaoMeta> call(int empresaId) => resposta(empresaId);
}

class _Salvar extends Fake implements SalvarIntegracaoMeta {
  Future<IntegracaoMeta> Function() resposta = () async => _config;

  @override
  Future<IntegracaoMeta> call(int empresaId, IntegracaoMetaAlteracoes a) =>
      resposta();
}

class _Testar extends Fake implements TestarIntegracaoMeta {
  int chamadas = 0;
  Future<IntegracaoMetaTeste> Function() resposta = () async => _teste;

  @override
  Future<IntegracaoMetaTeste> call(int empresaId) {
    chamadas++;
    return resposta();
  }
}

const _config = IntegracaoMeta(
  empresaId: 1,
  versaoGraphApi: 'v21.0',
  graphApiUrl: 'https://graph.facebook.com',
  businessId: '',
  catalogoId: '',
  pixelId: '',
  ecommerceId: 0,
  urlSite: '',
  marcaPadrao: '',
  moeda: 'BRL',
  accessTokenConfigurado: false,
  capiAccessTokenProprioConfigurado: false,
  capiHabilitada: false,
  capiCodigoTeste: '',
  capiMaxTentativas: 3,
  syncAutoHabilitada: false,
  syncIntervaloMinutos: 60,
  syncTamanhoLote: 500,
  validarImagens: false,
  timeoutMs: 15000,
  maxTentativasApi: 3,
  pendenciasCatalogo: [],
  pendenciasConversoes: [],
);

const _teste = IntegracaoMetaTeste(
  catalogo: IntegracaoMetaTesteItem(ok: true, mensagem: 'ok'),
  pixel: IntegracaoMetaTesteItem(ok: false, mensagem: 'erro'),
);

void main() {
  late _Recuperar recuperar;
  late _Salvar salvar;
  late _Testar testar;
  const alteracoes = IntegracaoMetaAlteracoes(pixelId: '12345');

  setUp(() {
    recuperar = _Recuperar();
    salvar = _Salvar();
    testar = _Testar();
  });

  IntegracaoMetaBloc build() => IntegracaoMetaBloc(recuperar, salvar, testar);

  blocTest<IntegracaoMetaBloc, IntegracaoMetaState>(
    'iniciou carrega configuração',
    build: build,
        act: (b) => b.add(IntegracaoMetaIniciou(1)),
    expect: () => [
      const IntegracaoMetaState(empresaId: 1, carregando: true),
      const IntegracaoMetaState(empresaId: 1, configuracao: _config),
    ],
  );

  blocTest<IntegracaoMetaBloc, IntegracaoMetaState>(
    'iniciou com falha emite erro',
    build: build,
    setUp: () => recuperar.resposta = (_) async => throw Exception('x'),
    act: (b) => b.add(IntegracaoMetaIniciou(1)),
    errors: () => [isA<Exception>()],
    expect: () => [
      const IntegracaoMetaState(empresaId: 1, carregando: true),
      const IntegracaoMetaState(
        empresaId: 1,
        erro: 'Falha ao carregar integração Meta.',
      ),
    ],
  );

  blocTest<IntegracaoMetaBloc, IntegracaoMetaState>(
    'salvar com testarDepois salva e testa',
    build: build,
    seed: () => const IntegracaoMetaState(empresaId: 1),
    act: (b) => b.add(IntegracaoMetaSalvar(alteracoes, testarDepois: true)),
    expect: () => [
      const IntegracaoMetaState(empresaId: 1, salvando: true),
      const IntegracaoMetaState(
        empresaId: 1,
        configuracao: _config,
        salvou: true,
      ),
      const IntegracaoMetaState(
        empresaId: 1,
        configuracao: _config,
        testando: true,
      ),
      const IntegracaoMetaState(
        empresaId: 1,
        configuracao: _config,
        teste: _teste,
      ),
    ],
    verify: (_) => expect(testar.chamadas, 1),
  );

  blocTest<IntegracaoMetaBloc, IntegracaoMetaState>(
    'salvar com falha não testa',
    build: build,
    seed: () => const IntegracaoMetaState(empresaId: 1),
    setUp: () => salvar.resposta = () async => throw Exception('x'),
    act: (b) => b.add(IntegracaoMetaSalvar(alteracoes, testarDepois: true)),
    errors: () => [isA<Exception>()],
    expect: () => [
      const IntegracaoMetaState(empresaId: 1, salvando: true),
      const IntegracaoMetaState(
        empresaId: 1,
        erro: 'Falha ao salvar integração Meta.',
      ),
    ],
    verify: (_) => expect(testar.chamadas, 0),
  );

  blocTest<IntegracaoMetaBloc, IntegracaoMetaState>(
    'testar emite resultado',
    build: build,
    seed: () => const IntegracaoMetaState(empresaId: 1),
    act: (b) => b.add(IntegracaoMetaTestar()),
    expect: () => [
      const IntegracaoMetaState(empresaId: 1, testando: true),
      const IntegracaoMetaState(empresaId: 1, teste: _teste),
    ],
  );
}
