import 'dart:async';

import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:comercial/presentation/pagamento/pagamento_contexto.dart';
import 'package:comercial/presentation/pages/pedido/barra_acao_pedido.dart';
import 'package:comercial/presentation/pages/pedido/etapa_acerto.dart';
import 'package:comercial/presentation/pages/pedido/etapa_conferir.dart';
import 'package:comercial/presentation/pages/pedido/etapa_confirmacao.dart';
import 'package:comercial/presentation/pages/pedido/etapa_retirada.dart';
import 'package:comercial/presentation/pages/pedido/lateral_pedido.dart';
import 'package:comercial/presentation/pages/pedido/mais_acoes_pedido.dart';
import 'package:comercial/presentation/pages/pedido/trilha_pedido_widget.dart';
import 'package:comercial/presentation/pagamento/pagamento_etapa.dart';
import 'package:comercial/presentation/relatorios/pdf/nota_entrega_pdf_exporter.dart';
import 'package:comercial/presentation/widgets/impressao_documento_helper.dart';
import 'package:comercial/use_cases.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/produtos_compartilhados.dart';
import 'package:core/remote_data_sourcers.dart' show mensagemDeErroApi;
import 'package:core/seletores.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/uses_cases.dart' show RecuperarPessoa;
import 'package:pessoas/presentation/widgets/funcionario_seletor.dart';

class PedidoPage extends StatefulWidget {
  final int? idPedido;
  final SeletorWidget? pessoaSeletor;
  final SeletorWidget? funcionarioSeletor;
  final SeletorWidget? tabelaDePrecoSeletor;
  final FormaPagamentoGradeWidget formaPagamentoGrade;

  const PedidoPage({
    super.key,
    this.idPedido,
    this.pessoaSeletor,
    this.funcionarioSeletor,
    this.tabelaDePrecoSeletor,
    required this.formaPagamentoGrade,
  });

  @override
  State<PedidoPage> createState() => _PedidoPageState();
}

class _PedidoPageState extends State<PedidoPage> {
  static const _tipos = [
    'venda',
    'compra',
    'transferencia_saida',
    'transferencia_entrada',
    'taxa_entrega',
  ];

  final _formKey = GlobalKey<FormState>();
  final _pessoaIdController = TextEditingController();
  final _funcionarioIdController = TextEditingController();
  final _tabelaPrecoIdController = TextEditingController();
  final _observacaoController = TextEditingController();
  final _valorTaxaEntregaController = TextEditingController();

  String? _enderecoEntregaResumo;
  bool _criandoPagamento = false;
  String _criandoPagamentoTexto = '';
  // Etapa de pagamento aberta = contexto não nulo. O bloc sobrevive ao Esc.
  PagamentoContexto? _pagamentoContexto;
  PagamentosRealizadosBloc? _pagamentoBloc;
  String? _pagamentoAssinatura;
  bool _confirmandoPagamento = false;
  bool _reenviandoEmailEmbalado = false;
  bool _redirecionou = false;
  String _codigoRetirada = '';
  final Set<int> _retirarJunto = {};
  final Set<int> _acertoMarcados = {};
  bool _abrirDescontoNoPagamento = false;
  int? _pendentesParaId;
  Timer? _polling;
  IdEtapaPedido? _etapaAtual;

  // Mesmo ritmo do enriquecimento da cobrança online no backend.
  static const _intervaloPolling = Duration(seconds: 15);
  final _focoPagina = FocusNode(debugLabel: 'pedido_pagina');
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _polling?.cancel();
    _pagamentoBloc?.close();
    _focoPagina.dispose();
    _pessoaIdController.dispose();
    _funcionarioIdController.dispose();
    _tabelaPrecoIdController.dispose();
    _observacaoController.dispose();
    _valorTaxaEntregaController.dispose();
    super.dispose();
  }

  Future<void> _cancelarPedido(BuildContext context) async {
    final motivoController = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancelar pedido'),
          content: TextField(
            controller: motivoController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Motivo cancelamento'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, motivoController.text.trim()),
              child: const Text('Cancelar pedido'),
            ),
          ],
        );
      },
    );

    if (motivo == null || motivo.isEmpty) return;

    if (!mounted) return;
    context.read<PedidoBloc>().add(PedidoCancelou(motivo));
  }

  Future<void> _reenviarEmailEmbalado(
      BuildContext context, int idPedido) async {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Reenviar código de retirada'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'O e-mail com o código de retirada será enviado pro '
                      'e-mail cadastrado do cliente. Preencha abaixo apenas '
                      'se quiser enviar pra um e-mail diferente.',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail alternativo (opcional)',
                      ),
                      onChanged: (_) => setDialogState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return null;
                        final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                            .hasMatch(value.trim());
                        return valido ? null : 'E-mail inválido';
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (!(formKey.currentState?.validate() ?? false)) return;
                    Navigator.pop(context, true);
                  },
                  child: const Text('Enviar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmou != true) return;

    final email = emailController.text.trim();

    setState(() => _reenviandoEmailEmbalado = true);
    try {
      await sl<ReenviarEmailEmbaladoPedido>()
          .call(idPedido, email: email.isEmpty ? null : email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('E-mail reenviado com sucesso.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagemDeErroApi(e, 'Falha ao reenviar e-mail.')),
        ),
      );
    } finally {
      if (mounted) setState(() => _reenviandoEmailEmbalado = false);
    }
  }

  Future<void> _assumirPedido(BuildContext context) async {
    final bloc = context.read<PedidoBloc>();
    Funcionario? selecionado;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Assumir pedido'),
          content: SizedBox(
            width: 420,
            child: FuncionarioSeletor(
              itemsSelecionadosInicial: const [],
              onFuncionarioChanged: (selecionados) {
                selecionado = selecionados.isEmpty ? null : selecionados.first;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Fechar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Assumir'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || selecionado == null || !mounted) return;
    bloc.add(PedidoAssumiu(selecionado!.id));
  }

  Future<void> _selecionarEnderecoEntrega(BuildContext context) async {
    final pessoaId = int.tryParse(_pessoaIdController.text);
    if (pessoaId == null || pessoaId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe a pessoa antes de selecionar o endereço.'),
        ),
      );
      return;
    }

    final selecionado = await Navigator.of(context).pushNamed(
      '/selecionar_endereco',
      arguments: {
        'idPessoa': pessoaId,
        'titulo': 'Endereço de entrega',
      },
    ) as Map<String, dynamic>?;

    if (selecionado == null || !mounted) return;

    final id = int.tryParse('${selecionado['id']}');
    if (id == null) return;

    final complemento = (selecionado['complemento'] as String? ?? '').trim();
    final resumo =
        '${selecionado['logradouro'] ?? ''}, ${selecionado['numero'] ?? ''}'
        '${complemento.isNotEmpty ? ' - $complemento' : ''}'
        ' - ${selecionado['bairro'] ?? ''}';

    setState(() {
      _enderecoEntregaResumo = resumo;
    });

    context.read<PedidoBloc>().add(
          PedidoEnderecoEntregaAlterado(id, enderecoEntregaResumo: resumo),
        );
  }

  double _valorRestantePagamento(PedidoState state) {
    final somaLancada = state.pagamentos.fold<double>(
      0,
      (soma, pagamento) => soma + (pagamento.valorEsperado ?? 0),
    );
    final restante = state.valorTotalGeral - somaLancada;
    return restante > 0 ? restante : 0;
  }

  // E-mail, CPF e preferência de nota do cliente do pedido; sem cadastro, abre sem eles.
  Future<Pessoa?> _carregarPessoa(int? id) async {
    if (id == null) return null;
    try {
      return await sl<RecuperarPessoa>().call(idPessoa: id);
    } catch (_) {
      return null;
    }
  }

  // Esc fecha a etapa e "Adicionar" reabre com o mesmo bloc; mudou item, desconto,
  // taxa ou pagamento lançado, o resumo do bloc ficou velho e ele é recriado.
  Future<void> _abrirPagamento(BuildContext context) async {
    final state = context.read<PedidoBloc>().state;
    final pessoa = await _carregarPessoa(int.tryParse(state.pessoaId ?? ''));
    if (!mounted) return;

    // Com pagamento lançado os descontos gravados no pedido valem como estão: o resumo parte do
    // preço líquido e não reapura promoção. Sem pagamento, parte do preço cheio e a etapa
    // reapura; o que ela mostrar é o que vai ser gravado (PUT de substituição).
    final travados = state.pagamentos.isNotEmpty;
    final produtosCompartilhados = state.itens
        .where((item) => item.produtoId != null)
        .map(
          (item) => ProdutoCompartilhado.create(
            produtoId: item.produtoId!,
            quantidade: (item.solicitado ?? 1).round(),
            valorUnitario: (item.valorUnitario ?? 0) -
                (travados ? (item.valorUnitDesconto ?? 0) : 0),
            nome: item.referenciaNome ?? '',
            corNome: item.corNome ?? '',
            tamanhoNome: item.tamanhoNome ?? '',
          ),
        )
        .toList(growable: false);

    final contexto = PagamentoContexto.pedido(
      hashLista: 'pedido-${state.id}',
      resumo: PagamentosRealizadosResumo(
        listaCompartilhada: null,
        produtosCompartilhados: produtosCompartilhados,
        quantidadeTotalProdutos: produtosCompartilhados.fold<int>(
          0,
          (soma, produto) => soma + produto.quantidade,
        ),
        valorTotalProdutos: produtosCompartilhados.fold<double>(
          0,
          (soma, p) => soma + p.quantidade * p.valorUnitario,
        ),
      ),
      titulo: 'Pedido #${state.id} · pagamento',
      subtitulo: state.pedido?.pessoaNome,
      descontoInicial: state.pedido?.desconto ?? 0,
      taxaEntregaInicial: state.pedido?.valorTaxaEntrega ?? 0,
      abatimentos: [
        for (final p in state.pagamentos)
          PagamentoAbatimento(
            rotulo: '${state.formasDePagamentoPorId[p.formaDePagamentoId] ?? 'Pagamento'}'
                ' · ${p.confirmadoEm != null ? 'confirmado' : 'aguardando'}',
            valor: p.valorEsperado ?? 0,
          ),
      ],
      descontosTravados: travados,
      pessoaId: pessoa?.id,
      cpfInicial: pessoa?.documento,
      clienteGenerico: pessoa?.generica ?? false,
      emailInicial: pessoa?.email,
      enviarNotaPorEmailInicial: pessoa?.enviarNotaPorEmail ?? false,
    );
    final assinatura = [
      for (final i in state.itens)
        '${i.produtoId}x${i.solicitado}@${i.valorUnitario}-${i.valorUnitDesconto}',
      state.pedido?.desconto,
      state.pedido?.valorTaxaEntrega,
      for (final p in state.pagamentos)
        '${p.id}:${p.valorEsperado}:${p.confirmadoEm != null}',
      pessoa?.id,
    ].join('|');
    if (_pagamentoBloc == null || _pagamentoAssinatura != assinatura) {
      _pagamentoBloc?.close();
      _pagamentoAssinatura = assinatura;
      _pagamentoBloc = contexto.criarBloc();
    }
    setState(() => _pagamentoContexto = contexto);
  }

  void _fecharPagamento() {
    _pagamentoBloc?.close();
    setState(() {
      _pagamentoContexto = null;
      _pagamentoBloc = null;
      _pagamentoAssinatura = null;
      _abrirDescontoNoPagamento = false;
    });
    _focarPagina();
  }

  void _focarPagina() => WidgetsBinding.instance
      .addPostFrameCallback((_) => mounted ? _focoPagina.requestFocus() : null);

  // Ordem: desconto do pedido, promoções/cupom, CPF/e-mail da nota e, por fim, os pagamentos.
  // Cada passo espera o anterior (o id do pagamento é max(id)+1 no backend, ver comentário abaixo).
  // Falha antes de lançar qualquer pagamento reabre a etapa com a mensagem junto do botão; depois
  // de lançar algum, a etapa fecha (reabrir repetiria a linha já lançada) e o erro vai no snackbar.
  Future<void> _confirmarPagamento(
    PedidoBloc bloc,
    Map<String, dynamic> resultado,
  ) async {
    final linhas =
        (resultado['formasDePagamentoRealizadas'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(growable: false);
    final etapa = _pagamentoBloc!;
    final state = bloc.state;
    final travados = state.pagamentos.isNotEmpty;

    void reabrir(String? erro) => etapa.add(
          PagamentosRealizadosReaberto(
            erro: erro ?? 'Falha ao lançar o pagamento.',
          ),
        );
    Future<PedidoState> passo(PedidoEvent evento, Set<PedidoStep> fim) async {
      bloc.add(evento);
      return bloc.stream
          .firstWhere((s) => fim.contains(s.step) || s.step == PedidoStep.falha);
    }

    final linhasValidas = linhas
        .map((linha) => (
              formaDePagamentoId: int.tryParse('${linha['formaDePagamentoId']}'),
              valorBruto: _toDouble(linha['valor']),
              ehDinheiro: linha['ehDinheiro'] == true,
            ))
        .where((linha) =>
            linha.formaDePagamentoId != null && (linha.valorBruto ?? 0) > 0)
        .toList(growable: false);
    if (linhasValidas.isEmpty) {
      reabrir('Informe uma forma e um valor de pagamento.');
      return;
    }

    final cupons = (resultado['cupons'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .toList(growable: false);
    if (!travados && cupons.length > 1) {
      reabrir('O pedido aceita um cupom por vez.');
      return;
    }

    final nomes = (resultado['resumoFormasDePagamento'] as List<dynamic>? ??
            const [])
        .whereType<Map<String, dynamic>>()
        .map((l) => l['nome'])
        .join(', ');
    setState(() {
      _confirmandoPagamento = true;
      _criandoPagamento = true;
      _criandoPagamentoTexto = nomes.isEmpty
          ? 'Criando a forma de pagamento selecionada…'
          : 'Criando a forma de pagamento: $nomes…';
    });
    var lancados = 0;
    try {
      // Desconto vem da própria etapa (mesmo padrão de romaneio_page._irParaPagamento):
      // descontosItens já representa o total FINAL (pré-carregado com o que já existia via
      // descontoInicial), então sempre REESCREVE em vez de somar.
      final descontoTotal = (resultado['descontosItens'] as List<dynamic>? ??
              const [])
          .whereType<Map<String, dynamic>>()
          .fold<double>(0, (soma, item) => soma + (_toDouble(item['valor']) ?? 0));
      if (!travados && descontoTotal != (state.pedido?.desconto ?? 0)) {
        final r = await passo(
          PedidoDescontoAlterado(descontoTotal),
          {PedidoStep.descontoAlterado},
        );
        if (r.step == PedidoStep.falha) return reabrir(r.erro);
      }

      final promocoes = (resultado['descontosPromocao'] as List<dynamic>? ??
              const [])
          .whereType<Map<String, dynamic>>()
          .toList(growable: false);
      if (!travados &&
          (promocoes.isNotEmpty ||
              cupons.isNotEmpty ||
              state.itens.any((i) => (i.valorUnitDesconto ?? 0) > 0))) {
        final r = await passo(
          PedidoDescontosPromocionaisAplicados(
            descontosPromocao: promocoes,
            cupom: cupons.isEmpty ? null : cupons.first,
          ),
          {PedidoStep.descontosPromocionaisAplicados},
        );
        if (r.step == PedidoStep.falha) return reabrir(r.erro);
      }

      final naEntrega = resultado['pagamentoNaEntrega'];
      if (state.modalidadeEntrega == 'entrega' &&
          naEntrega is bool &&
          naEntrega != (state.pedido?.pagamentoNaEntrega ?? false)) {
        final r = await passo(
          PedidoPagamentoNaEntregaAlterado(naEntrega),
          {PedidoStep.pagamentoNaEntregaSalvo},
        );
        if (r.step == PedidoStep.falha) return reabrir(r.erro);
      }

      final incluirCpf = resultado['incluirCpfNaNota'] == true;
      final cpf = resultado['cpfNaNota']?.toString() ?? '';
      final enviarEmail = resultado['enviarNotaPorEmail'] == true;
      final email = resultado['emailNota']?.toString() ?? '';
      final r = await passo(
        PedidoOpcoesFiscaisSalvas(
          incluirCpfNaNota: incluirCpf,
          cpfNaNota: incluirCpf && cpf.isNotEmpty ? cpf : null,
          enviarNotaPorEmail: enviarEmail,
          emailNota: enviarEmail && email.isNotEmpty ? email : null,
        ),
        {PedidoStep.opcoesFiscaisSalvas},
      );
      if (r.step == PedidoStep.falha) return reabrir(r.erro);

      // Troco só pode vir de uma linha em dinheiro -- aplica na primeira
      // encontrada (caso normal é só uma linha de dinheiro por pagamento).
      // Cada linha espera a anterior terminar (mesmo padrão de
      // pedido_itens_leitor_page._confirmarAlteracoes) -- o id do pagamento é gerado no backend via
      // max(id)+1 (ver PedidoPagamentoService.add), então disparar várias PedidoPagamentoAdicionou em
      // paralelo (2+ formas de pagamento na mesma confirmação) fazia os handlers lerem o mesmo max
      // concorrentemente e colidir no insert ("já existe um registro com esse valor").
      var trocoRestante = _toDouble(resultado['valorTroco']) ?? 0;
      for (final linha in linhasValidas) {
        final desconto = linha.ehDinheiro && trocoRestante > 0
            ? (trocoRestante > linha.valorBruto!
                ? linha.valorBruto!
                : trocoRestante)
            : 0.0;
        if (desconto > 0) trocoRestante -= desconto;

        final r = await passo(
          PedidoPagamentoAdicionou(
            formaDePagamentoId: linha.formaDePagamentoId!,
            valorEsperado: linha.valorBruto! - desconto,
            valorParaTroco: desconto > 0 ? linha.valorBruto : null,
          ),
          {PedidoStep.pagamentoAdicionado},
        );
        if (r.step == PedidoStep.falha) {
          if (lancados == 0) return reabrir(r.erro);
          _fecharPagamento();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(r.erro ?? 'Falha ao lançar o pagamento.')),
            );
          }
          return;
        }
        lancados++;
      }
      if (mounted) _fecharPagamento();
    } finally {
      if (mounted) {
        setState(() {
          _confirmandoPagamento = false;
          _criandoPagamento = false;
        });
      }
    }
  }

  Future<void> _removerPagamento(
    BuildContext context,
    PedidoPagamento pagamento,
  ) async {
    final ehOnline = pagamento.tipo == 'controlado';
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remover pagamento'),
          content: Text(
            ehOnline
                ? 'Remover esse pagamento? A cobrança online será cancelada '
                    'e o link deixará de funcionar.'
                : 'Remover esse pagamento?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Remover'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted || pagamento.id == null) return;

    context.read<PedidoBloc>().add(
          PedidoPagamentoRemoveu(pagamentoId: pagamento.id!),
        );
  }

  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  Future<void> _confirmarPagamentoManual(
    BuildContext context,
    PedidoPagamento pagamento,
  ) async {
    final valorController = TextEditingController(
      text: pagamento.valorEsperado?.toStringAsFixed(2).replaceAll('.', ',') ??
          '',
    );

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirmar pagamento'),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration:
                const InputDecoration(labelText: 'Valor confirmado (R\$)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    final valor = _parseValorReais(valorController.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido.')),
      );
      return;
    }

    context.read<PedidoBloc>().add(
          PedidoPagamentoConfirmou(
            pagamentoId: pagamento.id!,
            valorConfirmado: valor,
          ),
        );
  }

  Future<void> _imprimirNotaEntregaDoPedido(
    BuildContext context,
    PedidoState state,
  ) async {
    final enderecoResumo =
        _enderecoEntregaResumo ?? state.enderecoEntregaResumo;
    if (enderecoResumo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o endereço de entrega antes de imprimir.'),
        ),
      );
      return;
    }

    final numeroPedido = state.id ?? widget.idPedido;
    if (numeroPedido == null) return;

    await imprimirDocumentoPdf(
      context,
      titulo: 'Imprimir nota de entrega',
      nomeDocumento: 'Nota de Entrega - Pedido #$numeroPedido',
      gerarBytes: () async {
        final resultado = await NotaEntregaPdfExporter.gerarBytesParaPedido(
          numeroPedido: numeroPedido,
          pessoaNome: state.pedido?.pessoaNome,
          dataPedido: state.pedido?.criadoEm,
          empresaNome: state.pedido?.empresaNome ?? 'Empresa não identificada',
          empresaCnpj: state.pedido?.empresaCnpj,
          enderecoFormatado: enderecoResumo,
          itens: state.itens,
          pagamentos: state.pagamentos,
        );
        return resultado.bytes;
      },
    );
  }

  Future<void> _imprimirNotaConferenciaDoPedido(
    BuildContext context,
    PedidoState state,
  ) async {
    final numeroPedido = state.id ?? widget.idPedido;
    if (numeroPedido == null) return;

    await imprimirDocumentoPdf(
      context,
      titulo: 'Imprimir nota de conferência',
      nomeDocumento: 'Nota de Conferência - Pedido #$numeroPedido',
      gerarBytes: () async {
        final resultado =
            await NotaEntregaPdfExporter.gerarBytesConferenciaParaPedido(
          numeroPedido: numeroPedido,
          pessoaNome: state.pedido?.pessoaNome,
          dataPedido: state.pedido?.criadoEm,
          empresaNome: state.pedido?.empresaNome ?? 'Empresa não identificada',
          empresaCnpj: state.pedido?.empresaCnpj,
          itens: state.itens,
          pagamentos: state.pagamentos,
        );
        return resultado.bytes;
      },
    );
  }

  Future<void> _abrirConverterEmEntrega(BuildContext context) async {
    final bloc = context.read<PedidoBloc>();
    final pessoaId = int.tryParse(_pessoaIdController.text);
    if (pessoaId == null || pessoaId <= 0) return;

    final enderecoSelecionado = await Navigator.of(context).pushNamed(
      '/selecionar_endereco',
      arguments: {
        'idPessoa': pessoaId,
        'titulo': 'Endereço de entrega',
      },
    ) as Map<String, dynamic>?;

    if (enderecoSelecionado == null || !mounted) return;

    final enderecoId = int.tryParse('${enderecoSelecionado['id']}');
    if (enderecoId == null) return;

    final valorController = TextEditingController();
    final confirmou = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Converter em entrega'),
          content: TextField(
            controller: valorController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
                labelText: 'Valor da taxa de entrega (R\$)'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Converter'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    final valor = _parseValorReais(valorController.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido.')),
      );
      return;
    }

    bloc.add(
      PedidoTaxaEntregaCriou(
        valorTaxaEntrega: valor,
        enderecoEntregaId: enderecoId,
      ),
    );
  }

  // Observação/taxa de entrega de um pedido já existente salvam via modal dedicado (PedidoObservacaoSalva/
  // PedidoTaxaEntregaSalva) -- NUNCA via PedidoSalvou, que sempre navega pra fora da tela ao terminar
  // (correto só na criação do pedido). Criar pedido novo (idPedido == null) continua usando o botão
  // "Criar pedido" no AppBar + os campos inline de sempre.
  Future<void> _abrirEditarObservacao(
    BuildContext context,
    PedidoState state,
  ) async {
    final controller = TextEditingController(text: state.observacao ?? '');

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Observação do pedido'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            decoration: const InputDecoration(labelText: 'Observação'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    context
        .read<PedidoBloc>()
        .add(PedidoObservacaoSalva(controller.text.trim()));
  }

  Future<void> _abrirEditarTaxaEntrega(
    BuildContext context,
    PedidoState state,
  ) async {
    final controller =
        TextEditingController(text: state.valorTaxaEntrega ?? '');

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Taxa de entrega'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: const InputDecoration(
              labelText: 'Valor da taxa de entrega (R\$)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );

    if (confirmou != true || !mounted) return;

    final valor = _parseValorReais(controller.text);
    if (valor == null || valor <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe um valor válido.')),
      );
      return;
    }

    context.read<PedidoBloc>().add(
          PedidoTaxaEntregaSalva(valor.toStringAsFixed(2).replaceAll('.', ',')),
        );
  }

  String _valorTaxaEntregaFormatado(PedidoState state) {
    final valor = _parseValorReais(state.valorTaxaEntrega ?? '');
    if (valor == null || valor <= 0) return 'Nenhuma taxa informada.';
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  double? _parseValorReais(String raw) {
    final normalized = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    if (normalized.isEmpty) return null;
    return double.tryParse(normalized);
  }

  String _labelTipo(String tipo) {
    switch (tipo) {
      case 'venda':
        return 'Venda';
      case 'compra':
        return 'Compra';
      case 'transferencia_saida':
        return 'Transferência (saída)';
      case 'transferencia_entrada':
        return 'Transferência (entrada)';
      case 'taxa_entrega':
        return 'Taxa de entrega';
      default:
        return tipo;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PedidoBloc>(
      create: (_) =>
          sl<PedidoBloc>()..add(PedidoIniciou(idPedido: widget.idPedido)),
      child: BlocListener<PedidoBloc, PedidoState>(
        listenWhen: (previous, current) => previous.step != current.step,
        listener: (context, state) {
          if (state.step == PedidoStep.criado ||
              state.step == PedidoStep.salvo) {
            Navigator.of(context).pop(true);
            return;
          }

          if (state.step == PedidoStep.conferido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido conferido com sucesso.')),
            );
            return;
          }

          if (state.step == PedidoStep.faturado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido faturado com sucesso.')),
            );
            return;
          }

          if (state.step == PedidoStep.cancelado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pedido cancelado com sucesso.')),
            );
            return;
          }

          if (state.step == PedidoStep.linkCompartilhamentoObtido) {
            final link = state.linkCompartilhamento;
            if (link != null) {
              Clipboard.setData(ClipboardData(text: link));
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link do pedido copiado.')),
            );
            return;
          }

          if (state.step == PedidoStep.itemAdicionado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Produto adicionado ao pedido.')),
            );
            return;
          }

          if (state.step == PedidoStep.itemRemovido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Item removido do pedido.')),
            );
            return;
          }

          if (state.step == PedidoStep.dadosSalvos) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Dados do pedido atualizados.')),
            );
            return;
          }

          if (state.step == PedidoStep.enderecoEntregaSalvo) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Endereço de entrega salvo.')),
            );
            // Endereço acabou de ser definido -- encadeia direto pro preenchimento da taxa de
            // entrega (só se ainda não tiver uma), em vez de exigir um segundo toque manual no
            // botão "Adicionar" da taxa.
            if ((state.valorTaxaEntrega ?? '').trim().isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _abrirEditarTaxaEntrega(context, state);
              });
            }
            return;
          }

          if (state.step == PedidoStep.descontoAlterado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Desconto aplicado ao pedido.')),
            );
            return;
          }

          if (state.step == PedidoStep.pagamentoAdicionado) {
            setState(() => _criandoPagamento = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pagamento adicionado.')),
            );
            return;
          }

          if (state.step == PedidoStep.pagamentoRemovido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pagamento removido.')),
            );
            return;
          }

          if (state.step == PedidoStep.pagamentoConfirmado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pagamento confirmado.')),
            );
            return;
          }

          if (state.step == PedidoStep.entregadorChamado) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entregador chamado.')),
            );
            return;
          }

          if (state.step == PedidoStep.entregaConfirmada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Entrega confirmada.')),
            );
            return;
          }

          if (state.step == PedidoStep.retiradaConfirmada) {
            _retirarJunto.clear();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Retirada confirmada.')),
            );
            return;
          }

          if (state.step == PedidoStep.retiradaLoteConfirmada) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Retirada dos pedidos selecionados confirmada.'),
              ),
            );
            return;
          }

          if (state.step == PedidoStep.taxaEntregaCriada) {
            final novoId = state.pedidoTaxaEntregaCriadoId;
            if (novoId != null) {
              Navigator.of(context).pushReplacementNamed(
                '/pedido',
                arguments: {'idPedido': novoId},
              );
            }
            return;
          }

          if (state.step == PedidoStep.validacaoInvalida ||
              state.step == PedidoStep.falha) {
            // Durante a confirmação da etapa, _confirmarPagamento mostra o erro (junto do botão).
            if (_confirmandoPagamento) return;
            // Conferência: peça fora do pedido (ou leitura recusada) = erro sonoro, nada soma.
            if (_etapaAtual == IdEtapaPedido.conferir) {
              SystemSound.play(SystemSoundType.alert);
            }
            if (_criandoPagamento) {
              setState(() => _criandoPagamento = false);
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.erro ?? 'Falha ao processar pedido.'),
              ),
            );
          }
        },
        child: BlocListener<PedidoBloc, PedidoState>(
          // Último pagamento confirmado (e entrega concluída, quando houver): fatura sozinho.
          // Se falhar, o F9 "Faturar" continua na etapa com o erro.
          listenWhen: (a, b) =>
              a.pedido != null &&
              !_deveFaturarSozinho(a) &&
              _deveFaturarSozinho(b) &&
              b.step != PedidoStep.processando,
          listener: (context, state) =>
              context.read<PedidoBloc>().add(PedidoFaturou()),
          child: BlocBuilder<PedidoBloc, PedidoState>(
          builder: (context, state) {
            final carregando = state.step == PedidoStep.carregando ||
                state.step == PedidoStep.salvando ||
                state.step == PedidoStep.processando;

            if (state.step != PedidoStep.carregando) {
              _sincronizarControllers(state);
            }

            final contextoPagamento = _pagamentoContexto;
            final scaffold = widget.idPedido == null
                ? _buildScaffoldNovoPedido(context, state, carregando)
                : _buildShell(context, state, carregando);
            return Stack(
              children: [
                scaffold,
                if (contextoPagamento != null)
                  Positioned.fill(
                    child: BlocProvider.value(
                      value: _pagamentoBloc!,
                      child: PagamentoEtapa(
                        contexto: contextoPagamento,
                        formaPagamentoGrade: widget.formaPagamentoGrade,
                        abrirDesconto: _abrirDescontoNoPagamento,
                        onConfirmado: (resultado) => _confirmarPagamento(
                          context.read<PedidoBloc>(),
                          resultado,
                        ),
                        onVoltar: () {
                          if (!_confirmandoPagamento) {
                            setState(() {
                              _pagamentoContexto = null;
                              _abrirDescontoNoPagamento = false;
                            });
                            _focarPagina();
                          }
                        },
                      ),
                    ),
                  ),
                if (_confirmandoPagamento)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.black54,
                      child: Center(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator.adaptive(),
                                const SizedBox(height: 16),
                                Text(_criandoPagamentoTexto),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        ),
      ),
    );
  }

  // ---- Shell (pedido existente): barra superior, trilha, corpo + lateral, barra de ação ----

  Widget _buildScaffoldNovoPedido(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo pedido'),
        actions: [
          if (carregando)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: TextButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    context.read<PedidoBloc>().add(PedidoSalvou());
                  }
                },
                child: const Text('Criar pedido'),
              ),
            ),
        ],
      ),
      body: state.step == PedidoStep.carregando
          ? const Center(child: CircularProgressIndicator.adaptive())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: _buildFormularioPedido(context, state, carregando),
              ),
            ),
    );
  }

  // Itens, desconto, endereço e taxa só editam sem pagamento confirmado nem cobrança online.
  bool _travado(PedidoState s) =>
      s.pagamentos.any((p) => p.confirmadoEm != null || p.tipo == 'controlado');

  bool _editavel(PedidoState s) =>
      s.pedido?.situacao == 'em_andamento' && !_travado(s);

  bool _deveFaturarSozinho(PedidoState s) {
    final p = s.pedido;
    return p != null &&
        (p.tipo == 'venda' || p.tipo == 'taxa_entrega') &&
        p.origem != 'ecommerce' &&
        !p.pagamentoNaEntrega &&
        p.situacao == 'em_andamento' &&
        s.pagamentos.isNotEmpty &&
        s.pagamentos.every((x) => x.confirmadoEm != null) &&
        s.podeFechar;
  }

  ({bool habilitada, String? motivo}) _estadoF9(
    TrilhaPedido trilha,
    PedidoState state,
    bool carregando,
  ) {
    final acao = trilha.acaoPrincipal;
    String? motivo = trilha.motivoDesabilitada;
    if (acao == AcaoPedido.faturar && !state.podeFechar) {
      motivo ??= state.motivoNaoPodeFechar;
    }
    if (acao == AcaoPedido.confirmarRetirada &&
        trilha.exigeCodigoRetirada &&
        _codigoRetirada.length < 4) {
      motivo ??= 'Digite o código de 4 dígitos.';
    }
    if (acao == AcaoPedido.concluirConferencia) {
      final falta = pecasFaltando(state.itens);
      motivo = state.itens.isEmpty
          ? 'Pedido sem itens.'
          : (falta > 0 ? 'Faltam ${falta.toStringAsFixed(0)} peça(s).' : null);
    }
    if (acao == AcaoPedido.fecharAcerto) {
      final falta = EtapaAcerto.faltaDe(state.pagamentos, _acertoMarcados);
      motivo = state.pagamentos.isEmpty
          ? 'Nenhuma forma prevista.'
          : (falta > 0.005 ? 'Faltam ${brl(falta)} a receber.' : null);
    }
    return (habilitada: !carregando && acao != null && motivo == null, motivo: motivo);
  }

  void _executarAcaoPrincipal(
    BuildContext context,
    TrilhaPedido trilha,
    PedidoState state,
  ) {
    final bloc = context.read<PedidoBloc>();
    switch (trilha.acaoPrincipal) {
      case null:
        return;
      case AcaoPedido.assumirPedido:
        _assumirPedido(context);
      case AcaoPedido.concluirConferencia:
        bloc.add(trilha.conferenciaRetroativa
            ? PedidoMarcouConferido()
            : PedidoConferiu());
      case AcaoPedido.irParaPagamento:
      case AcaoPedido.lancarPagamento:
        _abrirPagamento(context);
      case AcaoPedido.faturar:
        bloc.add(PedidoFaturou());
      case AcaoPedido.marcarEmbalado:
        bloc.add(PedidoEmbalou());
      case AcaoPedido.confirmarRetirada:
        bloc.add(PedidoRetirouJunto(
          codigo: trilha.exigeCodigoRetirada ? _codigoRetirada : '',
          pedidoIds: _retirarJunto.toList(),
        ));
      case AcaoPedido.chamarEntregador:
        bloc.add(PedidoEntregadorChamou());
      case AcaoPedido.confirmarEntrega:
        bloc.add(PedidoEntregaConfirmou());
      case AcaoPedido.fecharAcerto:
        bloc.add(PedidoAcertoFechou({
          for (final p in state.pagamentos)
            if (p.confirmadoEm == null && _acertoMarcados.contains(p.id))
              p.id!: p.valorEsperado ?? 0,
        }));
    }
  }

  List<ItemMaisAcao> _itensMaisAcoes(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    final p = state.pedido;
    final retirada = state.modalidadeEntrega == 'retirada';
    final reenviar = retirada &&
        p?.retiradoEm == null &&
        (p?.exigeCodigoRetirada ?? true) &&
        ((p?.origem == 'ecommerce' && p?.conferidoEm != null) ||
            p?.situacaoEntrega == 'embalado');
    return [
      ItemMaisAcao(
        letra: 'I',
        rotulo: 'Imprimir nota de conferência',
        icone: Icons.fact_check_outlined,
        onTap: () => _imprimirNotaConferenciaDoPedido(context, state),
      ),
      if (state.modalidadeEntrega == 'entrega')
        ItemMaisAcao(
          letra: 'N',
          rotulo: 'Imprimir nota de entrega',
          icone: Icons.local_shipping_outlined,
          onTap: () => _imprimirNotaEntregaDoPedido(context, state),
        ),
      if (reenviar && !_reenviandoEmailEmbalado)
        ItemMaisAcao(
          letra: 'E',
          rotulo: 'Reenviar código ao cliente',
          icone: Icons.mail_outline,
          onTap: () => _reenviarEmailEmbalado(context, state.id!),
        ),
      ItemMaisAcao(
        letra: 'L',
        rotulo: 'Copiar link do pedido',
        icone: Icons.share,
        onTap: () => context
            .read<PedidoBloc>()
            .add(PedidoLinkCompartilhamentoSolicitou()),
      ),
      if (p?.romaneioId != null)
        ItemMaisAcao(
          letra: 'R',
          rotulo: 'Ver romaneio',
          icone: Icons.receipt_long_outlined,
          onTap: () => Navigator.of(context).pushNamed(
            '/romaneio',
            arguments: {'idRomaneio': p!.romaneioId, 'permitirEdicao': false},
          ),
        ),
      ItemMaisAcao(
        letra: 'O',
        rotulo: 'Observação',
        icone: Icons.edit_note_outlined,
        onTap: () => _abrirEditarObservacao(context, state),
      ),
      if (retirada && p?.situacao == 'encerrado')
        ItemMaisAcao(
          letra: 'C',
          rotulo: 'Converter em entrega',
          icone: Icons.change_circle_outlined,
          onTap: () => _abrirConverterEmEntrega(context),
        ),
      ItemMaisAcao(
        letra: 'H',
        rotulo: 'Histórico',
        icone: Icons.history,
        onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      if (p?.situacao != 'cancelado')
        ItemMaisAcao(
          rotulo: 'Cancelar pedido',
          icone: Icons.cancel_outlined,
          alerta: true,
          onTap: () => _cancelarPedido(context),
        ),
    ];
  }

  String? _linkCobrancaPendente(PedidoState state) {
    for (final pg in state.pagamentos) {
      if (pg.confirmadoEm != null || pg.tipo != 'controlado') continue;
      final c = pg.cobranca;
      final link = c?.urlPagamentoAvulsoSiteEmpresa ??
          c?.urlDePagamento ??
          c?.chavePixCopiaECola;
      if (link != null) return link;
    }
    return null;
  }

  // Efeitos de tela derivados da etapa atual (fora do build: sem setState).
  void _agendarEfeitos(BuildContext context, PedidoState state, TrilhaPedido trilha) {
    final bloc = context.read<PedidoBloc>();
    final etapa = trilha.atual?.id;
    _etapaAtual = etapa;
    final aguardandoOnline = etapa == IdEtapaPedido.confirmacao &&
        state.pagamentos
            .any((p) => p.confirmadoEm == null && p.tipo == 'controlado');
    if (aguardandoOnline && _polling == null) {
      _polling = Timer.periodic(_intervaloPolling, (_) {
        if (mounted) bloc.add(PedidoRecarregou());
      });
    } else if (!aguardandoOnline && _polling != null) {
      _polling!.cancel();
      _polling = null;
    }
    if (etapa == IdEtapaPedido.retirada && _pendentesParaId != state.id) {
      _pendentesParaId = state.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) bloc.add(PedidoRetiradaPendentesCarregou());
      });
    }
  }

  void _confirmarPagamentoNaLinha(BuildContext context, PedidoPagamento p) {
    if (p.id == null) return;
    context.read<PedidoBloc>().add(PedidoPagamentoConfirmou(
          pagamentoId: p.id!,
          valorConfirmado: p.valorEsperado ?? 0,
        ));
  }

  void _copiarLink(BuildContext context, String link) {
    Clipboard.setData(ClipboardData(text: link));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link da cobrança copiado.')),
    );
  }

  Widget _buildShell(BuildContext context, PedidoState state, bool carregando) {
    final pedido = state.pedido;
    if (pedido == null) {
      return Scaffold(
        body: Center(
          child: state.step == PedidoStep.carregando
              ? const CircularProgressIndicator.adaptive()
              : Text(state.erro ?? 'Pedido não encontrado.'),
        ),
      );
    }

    final trilha = derivarTrilhaPedido(
      pedido,
      state.pagamentos,
      state.itens,
      total: state.valorTotalGeral,
    );
    _agendarEfeitos(context, state, trilha);
    if (trilha.abreEntrada) {
      if (!_redirecionou) {
        _redirecionou = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed(
            '/pedido_entrada',
            arguments: {'pedidoId': state.id},
          );
        });
      }
      return const Scaffold(
        body: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final mobile = MediaQuery.sizeOf(context).width < 900;
    final f9 = _estadoF9(trilha, state, carregando);
    final etapa = trilha.atual?.id;
    final editavel = _editavel(state);

    void principal() {
      if (f9.habilitada) _executarAcaoPrincipal(context, trilha, state);
    }

    void mais() {
      if (!carregando && !trilha.somenteLeitura) {
        abrirMaisAcoes(context, _itensMaisAcoes(context, state, carregando));
      }
    }

    return Actions(
      actions: {
        AcaoPrincipalIntent: CallbackAction<AcaoPrincipalIntent>(
          onInvoke: (_) => principal(),
        ),
        MaisAcoesIntent: CallbackAction<MaisAcoesIntent>(
          onInvoke: (_) => mais(),
        ),
        VoltarPedidoIntent: CallbackAction<VoltarPedidoIntent>(
          onInvoke: (_) => Navigator.of(context).maybePop(),
        ),
        AdicionarProdutoIntent: CallbackAction<AdicionarProdutoIntent>(
          onInvoke: (_) => etapa == IdEtapaPedido.itens && editavel && !carregando
              ? _abrirGerenciarProdutos(context)
              : null,
        ),
        DescontoIntent: CallbackAction<DescontoIntent>(
          onInvoke: (_) {
            if ((etapa == IdEtapaPedido.itens || etapa == IdEtapaPedido.pagamento) &&
                editavel &&
                !carregando) {
              _abrirDescontoNoPagamento = true;
              _abrirPagamento(context);
            }
            return null;
          },
        ),
        AbrirPagamentoIntent: CallbackAction<AbrirPagamentoIntent>(
          onInvoke: (_) => (etapa == IdEtapaPedido.itens ||
                      etapa == IdEtapaPedido.pagamento ||
                      etapa == IdEtapaPedido.acerto) &&
                  !carregando
              ? _abrirPagamento(context)
              : null,
        ),
        ImprimirDocumentoIntent: CallbackAction<ImprimirDocumentoIntent>(
          onInvoke: (_) => state.modalidadeEntrega == 'entrega' &&
                  (etapa == IdEtapaPedido.chamarEntregador ||
                      etapa == IdEtapaPedido.acerto)
              ? _imprimirNotaEntregaDoPedido(context, state)
              : _imprimirNotaConferenciaDoPedido(context, state),
        ),
        CopiarLinkCobrancaIntent: CallbackAction<CopiarLinkCobrancaIntent>(
          onInvoke: (_) {
            final link = _linkCobrancaPendente(state);
            if (link == null) return null;
            Clipboard.setData(ClipboardData(text: link));
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Link da cobrança copiado.')),
            );
            return null;
          },
        ),
      },
      child: Shortcuts(
        shortcuts: atalhosPedido,
        child: Focus(
          focusNode: _focoPagina,
          autofocus: true,
          child: Scaffold(
            key: _scaffoldKey,
            endDrawer: Drawer(
              width: 360,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildTimelineCard(context, state),
                ),
              ),
            ),
            body: Column(
              children: [
                _buildBarraSuperior(context, state, carregando),
                TrilhaPedidoWidget(trilha: trilha),
                Expanded(
                  child: _buildCorpoELateral(
                    context,
                    state,
                    trilha,
                    carregando,
                    editavel,
                    mobile,
                  ),
                ),
                BarraAcaoPedido(
                  acao: trilha.acaoPrincipal,
                  habilitada: f9.habilitada,
                  motivo: f9.motivo,
                  onPrincipal: principal,
                  onMais: mais,
                  mobile: mobile,
                  mostrarMais: !trilha.somenteLeitura,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarraSuperior(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final estilo = textos.rotulo.copyWith(color: cores.textoSobreEscuroTitulo);

    Widget tag(String t) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: cores.textoSobreEscuroTerciario),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Text(t.toUpperCase(), style: estilo.copyWith(fontSize: 11)),
        );

    return Container(
      color: cores.acoEscuro,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              TextButton.icon(
                key: const Key('pedido_voltar'),
                onPressed: () => Navigator.of(context).maybePop(),
                style: TextButton.styleFrom(
                  foregroundColor: cores.textoSobreEscuroTitulo,
                ),
                icon: const Icon(Icons.arrow_back, size: 18),
                label: const Text('Esc'),
              ),
              const SizedBox(width: 8),
              Text(
                'Pedido #${state.id ?? widget.idPedido}',
                style: textos.secao.copyWith(color: cores.textoSobreEscuroTitulo),
              ),
              const SizedBox(width: 12),
              tag(_labelTipo(state.pedido?.tipo ?? 'venda')),
              const SizedBox(width: 6),
              tag(state.modalidadeEntrega == 'entrega' ? 'Entrega' : 'Retirada'),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (state.pedido?.pessoaNome ?? '').toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: textos.apoio.copyWith(color: cores.textoSobreEscuroApoio),
                ),
              ),
              if (carregando)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCorpoELateral(
    BuildContext context,
    PedidoState state,
    TrilhaPedido trilha,
    bool carregando,
    bool editavel,
    bool mobile,
  ) {
    final corpo = _buildCorpoEtapa(context, state, trilha, carregando, editavel);
    final lateral = LateralPedido(
      state: state,
      pagamentoLabel: _labelSituacaoPagamento(state.pedido?.situacaoPagamento),
      travado: _travado(state),
      secoes: [
        _buildDadosVinculadosCard(context, state, carregando),
        if (editavel && !trilha.somenteLeitura)
          _buildEntregaCard(context, state, carregando)
        else
          _buildEntregaLeitura(context, state),
        _buildObservacaoCard(context, state, carregando || trilha.somenteLeitura),
      ],
    );

    if (mobile) {
      return ListView(
        padding: const EdgeInsets.all(12),
        children: [
          corpo,
          const SizedBox(height: 12),
          ExpansionTile(
            title: const Text('Detalhes do pedido'),
            childrenPadding: const EdgeInsets.only(bottom: 12),
            children: [lateral],
          ),
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: corpo,
          ),
        ),
        SizedBox(
          width: 330,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
            child: lateral,
          ),
        ),
      ],
    );
  }

  Widget _buildEntregaLeitura(BuildContext context, PedidoState state) {
    final textos = context.sivTextos;
    final entrega = state.modalidadeEntrega == 'entrega';
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ENTREGA', style: textos.rotulo),
          const SizedBox(height: 6),
          Text(entrega ? 'Entrega' : 'Retirada', style: textos.corpo),
          if (entrega) ...[
            Text(
              _enderecoEntregaResumo ??
                  state.enderecoEntregaResumo ??
                  'Endereço não informado.',
              style: textos.apoio,
            ),
            Text('Taxa: ${_valorTaxaEntregaFormatado(state)}', style: textos.apoio),
          ],
        ],
      ),
    );
  }

  // Corpo por etapa: placeholders que reaproveitam os cards existentes (FP2/FP3 trocam).
  Widget _buildCorpoEtapa(
    BuildContext context,
    PedidoState state,
    TrilhaPedido trilha,
    bool carregando,
    bool editavel,
  ) {
    final textos = context.sivTextos;
    final atual = trilha.atual;
    final etapa = atual?.id;
    final p = state.pedido!;

    String? aviso;
    if (trilha.cancelado) {
      aviso = 'Pedido cancelado${(p.motivoCancelamento ?? '').isEmpty ? '' : ': ${p.motivoCancelamento}'}';
    } else if (trilha.concluida) {
      aviso = 'Pedido concluído.';
    } else if (etapa == IdEtapaPedido.assumir) {
      aviso = 'Assuma o pedido para continuar. Até lá a tela é só leitura.';
    }

    final mostrarPagamentos = state.pagamentos.isNotEmpty ||
        etapa == IdEtapaPedido.pagamento;
    final bloc = context.read<PedidoBloc>();

    final Widget? especifica = switch (etapa) {
      IdEtapaPedido.conferir => EtapaConferir(
          itens: state.itens,
          onLeitura: (c) => bloc.add(
            PedidoItemConferiuPorCodigo(codigoBarras: c, quantidade: 1),
          ),
          onContar: (i) => bloc.add(PedidoItemConferiu(
            produtoId: i.produtoId!,
            sequencia: i.sequencia ?? 1,
            quantidade: 1,
          )),
        ),
      IdEtapaPedido.confirmacao => EtapaConfirmacao(
          pagamentos: state.pagamentos,
          formas: state.formasDePagamentoPorId,
          total: state.valorTotalGeral,
          carregando: carregando,
          onConfirmar: (pg) => _confirmarPagamentoNaLinha(context, pg),
          onTrocarForma: (pg) => _removerPagamento(context, pg),
          onCopiarLink: (l) => _copiarLink(context, l),
        ),
      IdEtapaPedido.acerto => EtapaAcerto(
          pagamentos: state.pagamentos,
          formas: state.formasDePagamentoPorId,
          marcados: _acertoMarcados,
          carregando: carregando,
          onAlternar: (pg) => setState(() {
            if (!_acertoMarcados.remove(pg.id)) _acertoMarcados.add(pg.id!);
          }),
          onAlterarFormas: () => _abrirPagamento(context),
        ),
      IdEtapaPedido.retirada => EtapaRetirada(
          exigeCodigo: trilha.exigeCodigoRetirada,
          pendentes: state.outrosPedidosPendentes,
          marcados: _retirarJunto,
          erro: state.step == PedidoStep.falha ? state.erro : null,
          carregando: carregando,
          onCodigo: (c) => setState(() => _codigoRetirada = c),
          onCompleto: (c) {
            _codigoRetirada = c;
            bloc.add(PedidoRetirouJunto(
              codigo: c,
              pedidoIds: _retirarJunto.toList(),
            ));
          },
          onAlternarJunto: (id) => setState(() {
            if (!_retirarJunto.remove(id)) _retirarJunto.add(id);
          }),
        ),
      IdEtapaPedido.chamarEntregador => _buildChamarEntregador(context, state),
      _ => null,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (atual != null)
          SivCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(atual.titulo.toUpperCase(), style: textos.rotulo),
                      if (aviso != null) Text(aviso, style: textos.apoio),
                    ],
                  ),
                ),
              ],
            ),
          )
        else if (aviso != null)
          SivCard(child: Text(aviso, style: textos.corpo)),
        if (especifica != null) ...[const SizedBox(height: 12), especifica],
        const SizedBox(height: 12),
        _buildItensCard(
          context,
          state,
          carregando,
          editavel: editavel && etapa != IdEtapaPedido.assumir,
        ),
        if (mostrarPagamentos &&
            etapa != IdEtapaPedido.confirmacao &&
            etapa != IdEtapaPedido.acerto) ...[
          const SizedBox(height: 12),
          _buildPagamentosCard(
            context,
            state,
            permitirAdicionar: etapa == IdEtapaPedido.pagamento,
          ),
        ],
      ],
    );
  }

  // Troco que o entregador deve levar (T5) + nota de entrega (Ctrl+P).
  Widget _buildChamarEntregador(BuildContext context, PedidoState state) {
    final textos = context.sivTextos;
    final trocos = [
      for (final pg in state.pagamentos)
        if (pg.confirmadoEm == null && pg.valorParaTroco != null)
          'Troco para ${brl(pg.valorParaTroco!)} → leve '
              '${brl(pg.valorParaTroco! - (pg.valorEsperado ?? 0))}',
    ];
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final t in trocos) Text(t, style: textos.corpo),
          if (trocos.isNotEmpty) const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('imprimir_nota_entrega'),
            onPressed: () => _imprimirNotaEntregaDoPedido(context, state),
            child: const Text('Imprimir nota de entrega · Ctrl+P'),
          ),
        ],
      ),
    );
  }

  Widget _buildFormularioPedido(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCabecalhoPedidoCard(context, state),
        const SizedBox(height: 16),
        _buildDadosVinculadosCard(context, state, carregando),
        const SizedBox(height: 16),
        _buildEntregaCard(context, state, carregando),
        const SizedBox(height: 16),
        _buildObservacaoCard(context, state, carregando),
      ],
    );
  }

  Widget _buildCabecalhoPedidoCard(BuildContext context, PedidoState state) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                child: Text('${state.id ?? widget.idPedido ?? '-'}'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${state.id ?? widget.idPedido ?? 'novo'}',
                      style: textos.secao,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      state.pedido?.situacao?.trim().isNotEmpty == true
                          ? 'Situação: ${state.pedido?.situacao}'
                          : 'Situação: em edição',
                      style: textos.apoio,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildInfoChip(
                context,
                icon: Icons.shopping_bag_outlined,
                label: 'Tipo: ${_labelTipo(state.tipo ?? _tipos.first)}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: cores.hairline)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'TOTAL',
                  style: textos.rotulo,
                ),
                Text(
                  _formatarMoeda(state.valorTotalGeral),
                  style: textos.valor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarMoeda(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  String _labelSituacaoPagamento(String? situacao) {
    switch (situacao) {
      case 'pendente':
        return 'Pendente';
      case 'parcial':
        return 'Parcial';
      case 'pago':
        return 'Pago';
      default:
        return situacao ?? '-';
    }
  }

  Widget _buildDadosVinculadosCard(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    final onlyView = widget.idPedido != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Dados vinculados',
              Icons.badge_outlined,
            ),
            const SizedBox(height: 12),
            if (onlyView) ...[
              _buildInfoLinha(
                context,
                icone: Icons.person_outline,
                titulo: 'Pessoa',
                valor: _valorOuFallback(
                  state.pedido?.pessoaNome?.toUpperCase(),
                  fallback: state.pessoaId?.trim().isNotEmpty == true
                      ? 'Pessoa #${state.pessoaId}'
                      : '-',
                ),
              ),
              const Divider(height: 24),
              _buildInfoLinha(
                context,
                icone: Icons.badge,
                titulo: 'Funcionário',
                valor: _valorOuFallback(
                  state.pedido?.funcionarioNome?.toUpperCase(),
                  fallback: state.funcionarioId?.trim().isNotEmpty == true
                      ? 'Funcionário #${state.funcionarioId}'
                      : '-',
                ),
              ),
              const Divider(height: 24),
              _buildInfoLinha(
                context,
                icone: Icons.sell_outlined,
                titulo: 'Tabela de preço',
                valor: _valorOuFallback(
                  state.pedido?.tabelaPrecoNome,
                  fallback: state.tabelaPrecoId?.trim().isNotEmpty == true
                      ? 'Tabela de preço #${state.tabelaPrecoId}'
                      : '-',
                ),
              ),
            ] else ...[
              if (widget.pessoaSeletor != null)
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.pessoaSeletor!(
                    SeletorData(
                      itemsSelecionadosInicial: _selectDataInicial(
                            idTexto: state.pessoaId,
                            nomeFallback:
                                state.pedido?.pessoaNome?.toUpperCase() ??
                                    'Pessoa selecionada',
                          ) ??
                          const [],
                      onlyView: false,
                      onChanged: (selecionados) => _onCampoAlterado(
                        context,
                        pessoaId: selecionados.isEmpty
                            ? ''
                            : '${selecionados.first.id}',
                      ),
                    ),
                  ),
                )
              else
                _campoNumero(
                  controller: _pessoaIdController,
                  label: 'Pessoa ID',
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    pessoaId: value,
                  ),
                ),
              const SizedBox(height: 12),
              if (widget.funcionarioSeletor != null)
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.funcionarioSeletor!(
                    SeletorData(
                      itemsSelecionadosInicial: _selectDataInicial(
                            idTexto: state.funcionarioId,
                            nomeFallback:
                                state.pedido?.funcionarioNome?.toUpperCase() ??
                                    'Funcionário selecionado',
                          ) ??
                          const [],
                      onlyView: false,
                      onChanged: (selecionados) => _onCampoAlterado(
                        context,
                        funcionarioId: selecionados.isEmpty
                            ? ''
                            : '${selecionados.first.id}',
                      ),
                    ),
                  ),
                )
              else
                _campoNumero(
                  controller: _funcionarioIdController,
                  label: 'Funcionário ID',
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    funcionarioId: value,
                  ),
                ),
              const SizedBox(height: 12),
              if (widget.tabelaDePrecoSeletor != null)
                IgnorePointer(
                  ignoring: carregando,
                  child: widget.tabelaDePrecoSeletor!(
                    SeletorData(
                      itemsSelecionadosInicial: _selectDataInicial(
                        idTexto: state.tabelaPrecoId,
                        nomeFallback: state.pedido?.tabelaPrecoNome ??
                            'Tabela selecionada',
                      ),
                      onlyView: false,
                      onChanged: (selecionados) => _onCampoAlterado(
                        context,
                        tabelaPrecoId: selecionados.isEmpty
                            ? ''
                            : '${selecionados.first.id}',
                      ),
                    ),
                  ),
                )
              else
                _campoNumero(
                  controller: _tabelaPrecoIdController,
                  label: 'Tabela de preço ID',
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    tabelaPrecoId: value,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEntregaCard(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(
              context,
              'Modalidade de entrega',
              Icons.local_shipping_outlined,
            ),
            const SizedBox(height: 12),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'retirada', label: Text('Retirada')),
                ButtonSegment(value: 'entrega', label: Text('Entrega')),
              ],
              selected: {state.modalidadeEntrega},
              onSelectionChanged: carregando
                  ? null
                  : (selecao) => context.read<PedidoBloc>().add(
                        PedidoModalidadeEntregaAlterada(selecao.first),
                      ),
            ),
            if (state.modalidadeEntrega == 'entrega') ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: carregando
                    ? null
                    : () => _selecionarEnderecoEntrega(context),
                icon: const Icon(Icons.location_on_outlined),
                label: Text(
                  state.enderecoEntregaId == null
                      ? 'Selecionar endereço de entrega'
                      : (_enderecoEntregaResumo ??
                          state.enderecoEntregaResumo ??
                          'Endereço #${state.enderecoEntregaId}'),
                ),
              ),
              const SizedBox(height: 12),
              if (widget.idPedido != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _valorTaxaEntregaFormatado(state),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: carregando
                          ? null
                          : () => _abrirEditarTaxaEntrega(context, state),
                      icon: Icon(
                        (state.valorTaxaEntrega ?? '').trim().isEmpty
                            ? Icons.add
                            : Icons.edit_outlined,
                      ),
                      label: Text(
                        (state.valorTaxaEntrega ?? '').trim().isEmpty
                            ? 'Adicionar'
                            : 'Editar',
                      ),
                    ),
                  ],
                )
              else
                TextFormField(
                  controller: _valorTaxaEntregaController,
                  readOnly: carregando,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Valor da taxa de entrega (R\$)',
                  ),
                  onChanged: (value) => _onCampoAlterado(
                    context,
                    valorTaxaEntrega: value,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildObservacaoCard(
    BuildContext context,
    PedidoState state,
    bool carregando,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTituloSecao(
                    context,
                    'Observação',
                    Icons.edit_note_outlined,
                  ),
                ),
                if (widget.idPedido != null)
                  TextButton.icon(
                    onPressed: carregando
                        ? null
                        : () => _abrirEditarObservacao(context, state),
                    icon: Icon(
                      (state.observacao ?? '').trim().isEmpty
                          ? Icons.add
                          : Icons.edit_outlined,
                    ),
                    label: Text(
                      (state.observacao ?? '').trim().isEmpty
                          ? 'Adicionar'
                          : 'Editar',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.idPedido != null)
              Text(
                (state.observacao ?? '').trim().isEmpty
                    ? 'Nenhuma observação.'
                    : state.observacao!.trim(),
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              TextFormField(
                controller: _observacaoController,
                maxLines: 3,
                readOnly: carregando,
                decoration: const InputDecoration(
                  labelText: 'Observação',
                ),
                onChanged: (value) => _onCampoAlterado(
                  context,
                  observacao: value,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItensCard(
    BuildContext context,
    PedidoState state,
    bool carregando, {
    bool editavel = true,
  }) {
    final podeEditarItens = editavel && state.pedido?.situacao == 'em_andamento';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTituloSecao(
                    context,
                    'Itens do pedido',
                    Icons.list_alt_outlined,
                  ),
                ),
                TextButton.icon(
                  onPressed: (carregando || !podeEditarItens)
                      ? null
                      : () => _abrirGerenciarProdutos(context),
                  icon: const Icon(Icons.qr_code_scanner_outlined),
                  label: const Text('Gerenciar produtos'),
                ),
              ],
            ),
            if (!podeEditarItens) ...[
              const SizedBox(height: 4),
              Text(
                'Itens só podem ser adicionados ou removidos enquanto o '
                'pedido está em andamento.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 8),
            if (state.itens.isEmpty)
              const Text('Nenhum item adicionado ainda.')
            else
              ...state.itens.asMap().entries.map(
                    (entry) => _buildItemPedido(
                      context,
                      entry.value,
                      entry.key,
                    ),
                  ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total dos itens',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'R\$ ${state.valorTotalItens.toStringAsFixed(2)}',
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemPedido(
    BuildContext context,
    PedidoItem item,
    int index,
  ) {
    final theme = Theme.of(context);
    final unitario = item.valorUnitario ?? 0;
    final desconto = item.valorUnitDesconto ?? 0;
    final solicitado = item.solicitado ?? 0;
    final atendido = item.atendido ?? 0;
    final subtotal = (unitario - desconto) * solicitado;
    final corNome = item.corNome ?? '';
    final tamanhoNome = item.tamanhoNome ?? '';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              child: Text('${index + 1}'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.referenciaNome?.trim().isNotEmpty == true
                        ? item.referenciaNome!
                        : 'Produto #${item.produtoId ?? '-'}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (corNome.isNotEmpty || tamanhoNome.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (corNome.isNotEmpty) 'Cor: $corNome',
                        if (tamanhoNome.isNotEmpty) 'Tamanho: $tamanhoNome',
                      ].join('  •  '),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    'Qtd solicitada: ${solicitado.toInt().toString()}'
                    '${atendido > 0 ? ' · Atendida: ${atendido.toStringAsFixed(3)}' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vlr. unit.: R\$ ${unitario.toStringAsFixed(2)}'
                    '${desconto > 0 ? '  •  Desconto: R\$ ${desconto.toStringAsFixed(2)}' : ''}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text('Qtd.', style: theme.textTheme.labelSmall),
                  Text(
                    solicitado.toInt().toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'R\$ ${subtotal.toStringAsFixed(2)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Adicionar/remover produtos passou a acontecer numa tela dedicada com o LeitorWidget (mostra
  // cliente/pedido/funcionário, permite bipar livremente e só aplica a diferença ao confirmar) --
  // substitui os antigos dois fluxos separados (dialog "Adicionar produto" + botão de excluir por
  // linha). Reusa a mesma instância de PedidoBloc via BlocProvider.value pra que as alterações já
  // apareçam nesta tela ao voltar.
  Future<void> _abrirGerenciarProdutos(BuildContext context) async {
    final bloc = context.read<PedidoBloc>();

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: bloc,
          child: const PedidoItensLeitorPage(),
        ),
      ),
    );
  }

  Widget _buildPagamentosCard(
    BuildContext context,
    PedidoState state, {
    bool permitirAdicionar = true,
  }) {
    final valorRestante = _valorRestantePagamento(state);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildTituloSecao(
                    context,
                    'Pagamentos',
                    Icons.payments_outlined,
                  ),
                ),
                if (permitirAdicionar)
                  TextButton.icon(
                    onPressed: _criandoPagamento
                        ? null
                        : () => _abrirPagamento(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Adicionar'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if ((state.pedido?.desconto ?? 0) > 0)
              Text(
                'Desconto aplicado: R\$ ${(state.pedido?.desconto ?? 0).toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Text(
              'Valor restante: R\$ ${valorRestante.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: valorRestante > 0 ? Colors.orange : Colors.green,
                  ),
            ),
            const SizedBox(height: 8),
            if (state.pagamentos.isEmpty)
              const Text('Nenhum pagamento adicionado ainda.')
            else
              ...state.pagamentos.map(
                (pagamento) => _buildPagamentoItem(
                  context,
                  pagamento,
                  state.formasDePagamentoPorId,
                ),
              ),
            if (_criandoPagamento) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Criando pagamento...'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPagamentoItem(
    BuildContext context,
    PedidoPagamento pagamento,
    Map<int, String> formasDePagamentoPorId,
  ) {
    final confirmado = pagamento.confirmadoEm != null;
    final ehOnline = pagamento.tipo == 'controlado';
    final label = ehOnline
        ? (confirmado
            ? 'Confirmado (pagamento online)'
            : 'Aguardando confirmação do pagamento online')
        : (confirmado ? 'Confirmado' : 'Aguardando confirmação manual');
    final nomeForma = formasDePagamentoPorId[pagamento.formaDePagamentoId] ??
        'Forma #${pagamento.formaDePagamentoId ?? '-'}';
    final cobranca = pagamento.cobranca;
    final linkCobranca = cobranca?.urlPagamentoAvulsoSiteEmpresa ??
        cobranca?.urlDePagamento ??
        cobranca?.chavePixCopiaECola;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nomeForma,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Esperado: R\$ ${(pagamento.valorEsperado ?? 0).toStringAsFixed(2)}'
                      '${pagamento.valorConfirmado != null ? ' · Confirmado: R\$ ${pagamento.valorConfirmado!.toStringAsFixed(2)}' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    if (pagamento.valorParaTroco != null)
                      Text(
                        'Troco esperado: R\$ '
                        '${(pagamento.valorParaTroco! - (pagamento.valorEsperado ?? 0)).toStringAsFixed(2)}'
                        ' (cliente paga R\$ ${pagamento.valorParaTroco!.toStringAsFixed(2)})',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    Text(
                      label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: confirmado ? Colors.green : Colors.orange,
                          ),
                    ),
                  ],
                ),
              ),
              if (!confirmado && !ehOnline)
                TextButton(
                  onPressed: () =>
                      _confirmarPagamentoManual(context, pagamento),
                  child: const Text('Confirmar'),
                ),
              if (!confirmado)
                IconButton(
                  tooltip: 'Remover pagamento',
                  onPressed: () => _removerPagamento(context, pagamento),
                  icon: const Icon(Icons.delete_outline),
                ),
            ],
          ),
          if (!confirmado && ehOnline && linkCobranca != null)
            if (pagamento.estoqueDisponivel == false)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Sem estoque suficiente pra concluir esse pedido agora -- o link de '
                  'pagamento não foi liberado. Verifique o estoque antes de enviar ao cliente.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
              )
            else
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Envie ao cliente (R\$ ${(pagamento.valorEsperado ?? 0).toStringAsFixed(2)}):',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      linkCobranca,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, PedidoState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTituloSecao(context, 'Histórico', Icons.history),
            const SizedBox(height: 12),
            if (state.eventos.isEmpty)
              const Text('Nenhum evento registrado ainda.')
            else
              ...state.eventos
                  .map((evento) => _buildEventoItem(context, evento)),
          ],
        ),
      ),
    );
  }

  Widget _buildEventoItem(BuildContext context, PedidoEvento evento) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_iconeEvento(evento.tipo), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_labelEvento(evento.tipo)),
                if ((evento.operadorNome ?? '').trim().isNotEmpty)
                  Text(
                    'Por: ${evento.operadorNome}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if ((evento.observacao ?? '').trim().isNotEmpty)
                  Text(
                    evento.observacao!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (evento.criadoEm != null)
                  Text(
                    _formatarDataHoraEvento(evento.criadoEm),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatarDataHoraEvento(DateTime? data) {
    if (data == null) return '-';
    final local = data.toLocal();
    final dia = local.day.toString().padLeft(2, '0');
    final mes = local.month.toString().padLeft(2, '0');
    final ano = local.year.toString();
    final hora = local.hour.toString().padLeft(2, '0');
    final minuto = local.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$ano às $hora:$minuto';
  }

  IconData _iconeEvento(String? tipo) {
    switch (tipo) {
      case 'criado':
        return Icons.add_circle_outline;
      case 'atualizado':
        return Icons.edit_outlined;
      case 'conferido':
        return Icons.fact_check_outlined;
      case 'item_adicionado':
        return Icons.add_shopping_cart_outlined;
      case 'item_removido':
        return Icons.remove_shopping_cart_outlined;
      case 'item_conferido':
        return Icons.checklist_outlined;
      case 'pagamento_adicionado':
        return Icons.add_card_outlined;
      case 'pagamento_removido':
        return Icons.money_off_outlined;
      case 'pagamento_confirmado':
        return Icons.payments_outlined;
      case 'nota_emitida':
        return Icons.description_outlined;
      case 'entregador_chamado':
        return Icons.delivery_dining;
      case 'entrega_confirmada':
        return Icons.check_circle_outline;
      case 'encerrado':
        return Icons.lock_outline;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  String _labelEvento(String? tipo) {
    switch (tipo) {
      case 'criado':
        return 'Pedido criado';
      case 'atualizado':
        return 'Pedido atualizado';
      case 'conferido':
        return 'Pedido conferido';
      case 'item_adicionado':
        return 'Item adicionado';
      case 'item_removido':
        return 'Item removido';
      case 'item_conferido':
        return 'Itens conferidos';
      case 'pagamento_adicionado':
        return 'Pagamento adicionado';
      case 'pagamento_removido':
        return 'Pagamento removido';
      case 'pagamento_confirmado':
        return 'Pagamento confirmado';
      case 'nota_emitida':
        return 'Nota emitida';
      case 'entregador_chamado':
        return 'Entregador chamado';
      case 'entrega_confirmada':
        return 'Entrega confirmada';
      case 'encerrado':
        return 'Pedido encerrado';
      case 'cancelado':
        return 'Pedido cancelado';
      default:
        return tipo ?? '-';
    }
  }

  Widget _buildTituloSecao(
    BuildContext context,
    String titulo,
    IconData icone,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icone, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          titulo,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colors.primary),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildInfoLinha(
    BuildContext context, {
    required IconData icone,
    required String titulo,
    required String valor,
    String? complemento,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(
            icone,
            size: 18,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: theme.textTheme.labelMedium),
              const SizedBox(height: 2),
              Text(
                valor,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (complemento != null && complemento.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  complemento,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _valorOuFallback(String? valor, {String fallback = '-'}) {
    if (valor == null || valor.trim().isEmpty) {
      return fallback;
    }
    return valor.trim();
  }

  Widget _campoNumero({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(labelText: label),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Campo obrigatorio';
        }
        return null;
      },
    );
  }

  List<SelectData>? _selectDataInicial({
    required String? idTexto,
    required String nomeFallback,
  }) {
    final id = int.tryParse(idTexto ?? '');
    if (id == null || id <= 0) {
      return null;
    }

    return [
      SelectData(
        id: id,
        nome: nomeFallback,
        data: {'id': id, 'nome': nomeFallback},
      ),
    ];
  }

  void _sincronizarControllers(PedidoState state) {
    _sincronizarController(_pessoaIdController, state.pessoaId ?? '');
    _sincronizarController(_funcionarioIdController, state.funcionarioId ?? '');
    _sincronizarController(_tabelaPrecoIdController, state.tabelaPrecoId ?? '');
    _sincronizarController(_observacaoController, state.observacao ?? '');
    _sincronizarController(
      _valorTaxaEntregaController,
      state.valorTaxaEntrega ?? '',
    );
  }

  void _sincronizarController(TextEditingController controller, String value) {
    if (controller.text == value) return;

    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
  }

  void _onCampoAlterado(
    BuildContext context, {
    String? pessoaId,
    String? funcionarioId,
    String? tabelaPrecoId,
    String? parcelas,
    String? intervalo,
    String? dataBasePagamento,
    String? previsaoDeFaturamento,
    String? previsaoDeEntrega,
    String? tipo,
    bool? fiscal,
    String? observacao,
    String? valorTaxaEntrega,
  }) {
    context.read<PedidoBloc>().add(
          PedidoCampoAlterado(
            pessoaId: pessoaId,
            funcionarioId: funcionarioId,
            tabelaPrecoId: tabelaPrecoId,
            parcelas: parcelas,
            intervalo: intervalo,
            dataBasePagamento: dataBasePagamento,
            previsaoDeFaturamento: previsaoDeFaturamento,
            previsaoDeEntrega: previsaoDeEntrega,
            tipo: tipo,
            fiscal: fiscal,
            observacao: observacao,
            valorTaxaEntrega: valorTaxaEntrega,
          ),
        );
  }
}
