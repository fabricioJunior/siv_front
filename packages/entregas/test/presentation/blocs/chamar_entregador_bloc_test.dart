import 'package:core/bloc_test.dart';
import 'package:core/sessao.dart';
import 'package:empresas/models.dart';
import 'package:empresas/use_cases.dart';
import 'package:entregas/domain/models/entrega.dart';
import 'package:entregas/presentation.dart';
import 'package:entregas/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeObterSaldoEntrega extends Fake implements ObterSaldoEntrega {
  double saldo = 100;

  @override
  Future<double> call() async => saldo;
}

class _FakeEstimarEntrega extends Fake implements EstimarEntrega {
  Future<EstimativaEntrega> Function()? handler;

  @override
  Future<EstimativaEntrega> call({
    required EnderecoEntrega partida,
    required EnderecoEntrega destino,
    int? categoriaId,
    String? categoriaNome,
    String? data,
    String? hora,
    bool? comRetorno,
  }) =>
      handler!();
}

class _FakeAbrirSolicitacaoEntrega extends Fake
    implements AbrirSolicitacaoEntrega {
  double? ultimoValorEstimado;
  Future<SolicitacaoEntrega> Function()? handler;

  @override
  Future<SolicitacaoEntrega> call({
    required int categoriaId,
    required String categoriaNome,
    String? formaPagamento,
    int? condutorIdentificacao,
    required EnderecoEntrega partida,
    required List<ParadaEntrega> paradas,
    bool? retorno,
    String? data,
    String? hora,
    int? antecedencia,
    double? valorEstimado,
  }) {
    ultimoValorEstimado = valorEstimado;
    return handler!();
  }
}

class _FakeObterRastreioEntrega extends Fake implements ObterRastreioEntrega {
  @override
  Future<List<RastreioEntrega>> call(int id) async => [];
}

class _FakeCancelarSolicitacaoEntrega extends Fake
    implements CancelarSolicitacaoEntrega {
  @override
  Future<SolicitacaoEntrega> call(int id, {int? motivoId}) async {
    throw UnimplementedError();
  }
}

class _FakeEndereco extends Fake implements EnderecoEntrega {}

class _FakeParada extends Fake implements ParadaEntrega {}

class _FakeEstimativa extends Fake implements EstimativaEntrega {
  @override
  double get valor => 25.5;

  @override
  int get tempoEstimadoMinutos => 30;

  @override
  double get distanciaKm => 5;
}

class _FakeSolicitacao extends Fake implements SolicitacaoEntrega {
  @override
  int get id => 1;

  @override
  String get status => 'G';
}

class _FakeRecuperarEmpresa extends Fake implements RecuperarEmpresa {
  Empresa? empresa;

  @override
  Future<Empresa?> call(int idEmpresa) async => empresa;
}

class _FakeAcessoGlobalSessao extends Fake implements IAcessoGlobalSessao {
  @override
  int? empresaIdDaSessao = 1;
}

void main() {
  late _FakeObterSaldoEntrega obterSaldo;
  late _FakeEstimarEntrega estimar;
  late _FakeAbrirSolicitacaoEntrega abrirSolicitacao;
  late _FakeObterRastreioEntrega obterRastreio;
  late _FakeCancelarSolicitacaoEntrega cancelarSolicitacao;
  late _FakeRecuperarEmpresa recuperarEmpresa;
  late _FakeAcessoGlobalSessao acessoGlobalSessao;

  ChamarEntregadorBloc build() => ChamarEntregadorBloc(
        obterSaldo,
        estimar,
        abrirSolicitacao,
        obterRastreio,
        cancelarSolicitacao,
        recuperarEmpresa,
        acessoGlobalSessao,
      );

  setUp(() {
    obterSaldo = _FakeObterSaldoEntrega();
    estimar = _FakeEstimarEntrega();
    abrirSolicitacao = _FakeAbrirSolicitacaoEntrega();
    obterRastreio = _FakeObterRastreioEntrega();
    cancelarSolicitacao = _FakeCancelarSolicitacaoEntrega();
    recuperarEmpresa = _FakeRecuperarEmpresa();
    acessoGlobalSessao = _FakeAcessoGlobalSessao();
  });

  blocTest<ChamarEntregadorBloc, ChamarEntregadorState>(
    'ChamarEntregadorIniciou carrega o saldo da carteira',
    build: build,
    act: (bloc) => bloc.add(ChamarEntregadorIniciou()),
    expect: () => [
      isA<ChamarEntregadorState>().having((s) => s.saldo, 'saldo', 100),
    ],
  );

  blocTest<ChamarEntregadorBloc, ChamarEntregadorState>(
    'ChamarEntregadorIniciou monta a partida a partir do endereço da '
    'empresa quando ela tem coordenadas cadastradas',
    setUp: () {
      recuperarEmpresa.empresa = Empresa.create(
        cnpj: '00000000000191',
        nome: 'Empresa',
        nomeFantasia: 'Empresa',
        logradouro: 'Rua A',
        numero: '10',
        bairro: 'Centro',
        municipio: 'Cidade',
        uf: 'SP',
        latitude: -23.5,
        longitude: -46.6,
      );
    },
    build: build,
    act: (bloc) async {
      bloc.add(ChamarEntregadorIniciou());
      await Future.delayed(Duration.zero);
    },
    wait: const Duration(milliseconds: 10),
    verify: (bloc) {
      expect(bloc.state.partida, isNotNull);
      expect(bloc.state.partida!.lat, -23.5);
      expect(bloc.state.partida!.lng, -46.6);
    },
  );

  blocTest<ChamarEntregadorBloc, ChamarEntregadorState>(
    'ChamarEntregadorIniciou deixa partida nula quando empresa nao tem '
    'coordenadas cadastradas',
    setUp: () {
      recuperarEmpresa.empresa = Empresa.create(
        cnpj: '00000000000191',
        nome: 'Empresa',
        nomeFantasia: 'Empresa',
      );
    },
    build: build,
    act: (bloc) async {
      bloc.add(ChamarEntregadorIniciou());
      await Future.delayed(Duration.zero);
    },
    wait: const Duration(milliseconds: 10),
    verify: (bloc) {
      expect(bloc.state.partida, isNull);
      expect(bloc.state.empresa, isNotNull);
    },
  );

  blocTest<ChamarEntregadorBloc, ChamarEntregadorState>(
    'nao permite chamar entregador sem calcular a estimativa antes',
    build: build,
    verify: (bloc) {
      expect(bloc.state.step, ChamarEntregadorStep.formulario);
      expect(bloc.state.estimativa, isNull);
    },
  );

  blocTest<ChamarEntregadorBloc, ChamarEntregadorState>(
    'apos estimar, chamar usa o valor calculado como valorEstimado',
    setUp: () {
      estimar.handler = () async => _FakeEstimativa();
      abrirSolicitacao.handler = () async => _FakeSolicitacao();
    },
    build: build,
    act: (bloc) async {
      bloc.add(ChamarEntregadorEstimou(
        partida: _FakeEndereco(),
        destino: _FakeEndereco(),
        parada: _FakeParada(),
      ));
      await Future.delayed(Duration.zero);
      bloc.add(ChamarEntregadorChamou());
    },
    wait: const Duration(milliseconds: 10),
    verify: (bloc) {
      expect(bloc.state.step, ChamarEntregadorStep.chamado);
      expect(abrirSolicitacao.ultimoValorEstimado, 25.5);
    },
  );
}
