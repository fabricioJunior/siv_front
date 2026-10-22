import 'package:comercial/presentation.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc_test.dart';
import 'package:core/empresas_portas.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';
import 'package:financeiro/use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pessoas/domain/usecases/recuperar_cliente_nao_cadastrado.dart';

class _Pedido implements CriarPedido {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ItemPedido implements AdicionarItemPedido {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _SalvarOrcamento implements SalvarOrcamento {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _CarregarOrcamento implements CarregarOrcamento {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ExcluirOrcamento implements ExcluirOrcamento {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Caixa implements RecuperarCaixaAberto {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Balanco implements ObterBalancoEmAndamentoUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Reenviar implements ReenviarEmailDocumentoFiscal {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Reprocessar implements ReprocessarDocumentoFiscal {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _Salvar implements SalvarListaDeProdutosCompartilhada {
  int chamadas = 0;

  @override
  Future<ListaDeProdutosCompartilhada> call({
    required ListaDeProdutosCompartilhada listaCompartilhada,
    required List<ProdutoCompartilhado> produtos,
  }) async {
    chamadas++;
    return listaCompartilhada;
  }
}

class _Sessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _ExigeCliente implements PortaVerificarExigeClienteNaVenda {
  @override
  Future<bool> call({required int empresaId}) async => false;
}

class _Limite implements PortaDescontoMaximoVendedor {
  final double percentual;

  _Limite(this.percentual);

  @override
  Future<double> call({required int empresaId}) async => percentual;
}

class _NaoCadastrado implements RecuperarClienteNaoCadastrado {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  final cliente = SelectData(id: 1, nome: 'Cliente', data: const {});
  final vendedor = SelectData(id: 2, nome: 'Ana', data: const {});
  final tabela = SelectData(id: 3, nome: 'Atacado', data: const {});
  final leitura = VendaState(
    step: VendaStep.leitura,
    clienteSelecionado: cliente,
    vendedorSelecionado: vendedor,
    tabelaDePrecoSelecionada: tabela,
  );
  const itens = [
    {'produtoId': 1, 'quantidade': 2, 'valorUnitario': 50.0},
  ];

  late _Salvar salvar;

  VendaBloc criar({double limite = 0}) {
    salvar = _Salvar();
    return VendaBloc(
      salvar,
      _Pedido(),
      _ItemPedido(),
      _SalvarOrcamento(),
      _CarregarOrcamento(),
      _ExcluirOrcamento(),
      _Caixa(),
      _Balanco(),
      _Sessao(),
      _NaoCadastrado(),
      VerificarExigeClienteNaVenda(_ExigeCliente()),
      RecuperarDescontoMaximoVendedor(_Limite(limite)),
      _Reenviar(),
      _Reprocessar(),
    );
  }

  group('Itens → Pagamento → Itens', () {
    blocTest<VendaBloc, VendaState>(
      'F9 na leitura abre o pagamento; Esc volta aos itens descartando o hash',
      build: criar,
      seed: () => leitura.copyWith(listaCompartilhadaHash: 'h'),
      act: (b) async {
        b.add(const VendaPagamentoSolicitado(subtotal: 100));
        await b.stream.firstWhere((s) => s.step == VendaStep.pagamento);
        b.add(const VendaPagamentoVoltou());
      },
      verify: (b) {
        expect(b.state.step, VendaStep.leitura);
        expect(b.state.listaCompartilhadaHash, isNull);
        expect(b.state.vendedorSelecionado, vendedor);
      },
    );

    blocTest<VendaBloc, VendaState>(
      'sem vendedor não passa da leitura e avisa uma vez',
      build: criar,
      seed: () => VendaState(
        step: VendaStep.leitura,
        clienteSelecionado: cliente,
        tabelaDePrecoSelecionada: tabela,
      ),
      act: (b) => b.add(const VendaPagamentoSolicitado(subtotal: 100)),
      expect: () => [
        isA<VendaState>()
            .having((s) => s.step, 'step', VendaStep.leitura)
            .having((s) => s.erro, 'erro', contains('vendedor')),
      ],
    );

    blocTest<VendaBloc, VendaState>(
      'desconto que ficou maior que o subtotal (itens removidos) barra o F9',
      build: criar,
      seed: () => leitura.copyWith(descontoRascunho: 80),
      act: (b) => b.add(const VendaPagamentoSolicitado(subtotal: 50)),
      expect: () => [
        isA<VendaState>()
            .having((s) => s.step, 'step', VendaStep.leitura)
            .having((s) => s.erro, 'erro', contains('subtotal')),
      ],
    );
  });

  group('F4 desconto', () {
    blocTest<VendaBloc, VendaState>(
      'valor dentro do limite do vendedor é aplicado',
      build: () => criar(limite: 10),
      seed: () => leitura,
      act: (b) =>
          b.add(const VendaDescontoAlterado(texto: '10,00', subtotal: 100)),
      expect: () => [
        isA<VendaState>()
            .having((s) => s.descontoRascunho, 'desconto', 10)
            .having((s) => s.erroDesconto, 'erro', isNull)
            .having((s) => s.descontoContador, 'contador', 1),
      ],
    );

    blocTest<VendaBloc, VendaState>(
      'percentual vira valor sobre o subtotal',
      build: criar,
      seed: () => leitura,
      act: (b) =>
          b.add(const VendaDescontoAlterado(texto: '12,5%', subtotal: 200)),
      expect: () => [
        isA<VendaState>().having((s) => s.descontoRascunho, 'desconto', 25),
      ],
    );

    blocTest<VendaBloc, VendaState>(
      'acima do DESCONTO_MAXIMO_VENDEDOR é recusado e mantém o desconto anterior',
      build: () => criar(limite: 10),
      seed: () => leitura.copyWith(descontoRascunho: 5),
      act: (b) =>
          b.add(const VendaDescontoAlterado(texto: '11', subtotal: 100)),
      expect: () => [
        isA<VendaState>()
            .having((s) => s.descontoRascunho, 'desconto', 5)
            .having((s) => s.erroDesconto, 'erro', contains('limite de 10%')),
      ],
    );

    blocTest<VendaBloc, VendaState>(
      'limite 0 = sem limite; vazio remove o desconto',
      build: criar,
      seed: () => leitura.copyWith(descontoRascunho: 5),
      act: (b) async {
        b.add(const VendaDescontoAlterado(texto: '90', subtotal: 100));
        await b.stream.first;
        b.add(const VendaDescontoAlterado(texto: '', subtotal: 100));
      },
      expect: () => [
        isA<VendaState>().having((s) => s.descontoRascunho, 'desconto', 90),
        isA<VendaState>().having((s) => s.descontoRascunho, 'desconto', 0),
      ],
    );
  });

  group('confirmação do pagamento', () {
    blocTest<VendaBloc, VendaState>(
      'retry após falha total reaproveita a lista e sobe o contador',
      build: criar,
      seed: () => leitura.copyWith(step: VendaStep.pagamento),
      act: (b) async {
        b.add(const VendaFinalizarSolicitada(
          itens: itens,
          formasDePagamentoRealizadas: [],
        ));
        await b.stream.firstWhere((s) => s.finalizacaoContador == 1);
        b.add(const VendaFinalizarSolicitada(
          itens: itens,
          formasDePagamentoRealizadas: [],
        ));
        await b.stream.firstWhere((s) => s.finalizacaoContador == 2);
      },
      verify: (b) {
        expect(salvar.chamadas, 1);
        expect(b.state.step, VendaStep.pagamento);
        expect(b.state.listaCompartilhadaHash, isNotNull);
      },
    );
  });

  group('nova venda e nota', () {
    blocTest<VendaBloc, VendaState>(
      'Nova venda volta à leitura mantendo vendedor e tabela',
      build: criar,
      seed: () => leitura.copyWith(
        step: VendaStep.pagamento,
        descontoRascunho: 10,
        listaCompartilhadaHash: 'h',
        finalizacaoContador: 3,
      ),
      act: (b) => b.add(const VendaNovaVendaSolicitada()),
      verify: (b) {
        expect(b.state.step, VendaStep.leitura);
        expect(b.state.vendedorSelecionado, vendedor);
        expect(b.state.tabelaDePrecoSelecionada, tabela);
        expect(b.state.descontoRascunho, 0);
        expect(b.state.listaCompartilhadaHash, isNull);
        expect(b.state.finalizacaoContador, 0);
      },
    );
  });
}
