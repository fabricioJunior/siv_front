import 'package:comercial/use_cases.dart';
import 'package:core/empresas_portas.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/sessao.dart';
import 'package:estoque/domain/usecases/balanco_usecases.dart';
import 'package:financeiro/use_cases.dart';
import 'package:pessoas/domain/usecases/recuperar_cliente_nao_cadastrado.dart';

class FakePedido implements CriarPedido {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeItemPedido implements AdicionarItemPedido {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeSalvarOrcamento implements SalvarOrcamento {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeCarregarOrcamento implements CarregarOrcamento {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeExcluirOrcamento implements ExcluirOrcamento {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeCaixa implements RecuperarCaixaAberto {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeBalanco implements ObterBalancoEmAndamentoUseCase {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeReenviar implements ReenviarEmailDocumentoFiscal {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeReprocessar implements ReprocessarDocumentoFiscal {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeSalvar implements SalvarListaDeProdutosCompartilhada {
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

class FakeSessao implements IAcessoGlobalSessao {
  @override
  int? get empresaIdDaSessao => 1;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeExigeCliente implements PortaVerificarExigeClienteNaVenda {
  @override
  Future<bool> call({required int empresaId}) async => false;
}

class FakeLimite implements PortaDescontoMaximoVendedor {
  final double percentual;

  FakeLimite(this.percentual);

  @override
  Future<double> call({required int empresaId}) async => percentual;
}

class FakeNaoCadastrado implements RecuperarClienteNaoCadastrado {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

