import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';

const String _resultadoRomaneioStatusKey = 'status';
const String _resultadoRomaneioIdKey = 'romaneioId';
const String _resultadoRomaneioStatusSucesso = 'sucesso';
const String _resultadoRomaneioStatusFalha = 'falha';
const String _resultadoRomaneioStatusParcial = 'parcial';

class CriarRomaneioPorParametrosPage extends StatelessWidget {
  final String hashLista;
  final List<Map<String, dynamic>> formasDePagamentoRealizadas;
  final double desconto;
  final List<Map<String, dynamic>> descontosItens;
  final bool incluirCpfNaNota;
  final String cpfNaNota;
  final bool pontuarFidelidade;
  final int? consignacaoId;
  final List<int> romaneiosConsignacao;

  const CriarRomaneioPorParametrosPage({
    super.key,
    required this.hashLista,
    this.formasDePagamentoRealizadas = const [],
    this.desconto = 0,
    this.descontosItens = const [],
    this.incluirCpfNaNota = true,
    this.cpfNaNota = '',
    this.pontuarFidelidade = false,
    this.consignacaoId,
    this.romaneiosConsignacao = const [],
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RomaneioCriacaoBloc>(
      create: (_) => sl<RomaneioCriacaoBloc>()
        ..add(
          RomaneioCriacaoSolicitada(
            hashLista: hashLista,
            formasDePagamentoRealizadas: formasDePagamentoRealizadas,
            desconto: desconto,
            descontosItens: descontosItens,
            incluirCpfNaNota: incluirCpfNaNota,
            cpfNaNota: cpfNaNota,
            pontuarFidelidade: pontuarFidelidade,
            consignacaoId: consignacaoId,
            romaneiosConsignacao: romaneiosConsignacao,
          ),
        ),
      child: BlocConsumer<RomaneioCriacaoBloc, RomaneioCriacaoState>(
        listenWhen: (previous, current) => previous.erro != current.erro,
        listener: (context, state) {
          if (state.step == RomaneioCriacaoStep.falha && state.erro != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.erro!)),
            );
          }
        },
        builder: (context, state) {
          // Sem isso, sair da tela pelo gesto/botão voltar do sistema (em
          // vez de um botão "Voltar"/"Tentar novamente" do próprio app)
          // fazia Navigator.pop() sem resultado nenhum -- a VendaPage, que
          // só reseta o fluxo quando reconhece o Map de resultado de
          // sucesso/parcial/falha, nunca via esse reset acontecer e ficava
          // com os dados da venda anterior. PopScope garante que QUALQUER
          // forma de sair devolve o mesmo resultado que os botões in-app
          // já devolviam.
          Map<String, dynamic>? resultadoParaPop() {
            return switch (state.step) {
              RomaneioCriacaoStep.sucesso => {
                  _resultadoRomaneioStatusKey: _resultadoRomaneioStatusSucesso,
                  _resultadoRomaneioIdKey: state.romaneio?.id,
                },
              RomaneioCriacaoStep.falha => {
                  _resultadoRomaneioStatusKey:
                      state.listaCompartilhada?.idLista == null
                          ? _resultadoRomaneioStatusFalha
                          : _resultadoRomaneioStatusParcial,
                  _resultadoRomaneioIdKey: state.listaCompartilhada?.idLista,
                },
              _ => null,
            };
          }

          final permiteVoltarDireto =
              state.step == RomaneioCriacaoStep.inicial ||
                  state.step == RomaneioCriacaoStep.processando;

          return PopScope<Object?>(
            canPop: permiteVoltarDireto,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              Navigator.of(context).pop(resultadoParaPop());
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Criação de romaneio'),
              ),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: switch (state.step) {
                  RomaneioCriacaoStep.inicial ||
                  RomaneioCriacaoStep.processando =>
                    _ProcessandoRomaneioView(
                      quantidadeItens: state.produtosCompartilhados.length,
                    ),
                  RomaneioCriacaoStep.falha => _FalhaRomaneioView(
                      erro: state.erro ?? 'Falha ao criar romaneio.',
                      romaneioId: state.listaCompartilhada?.idLista,
                      onTentarNovamente: () {
                        context.read<RomaneioCriacaoBloc>().add(
                              RomaneioCriacaoSolicitada(
                                hashLista: hashLista,
                                formasDePagamentoRealizadas:
                                    formasDePagamentoRealizadas,
                                desconto: desconto,
                                descontosItens: descontosItens,
                                incluirCpfNaNota: incluirCpfNaNota,
                                cpfNaNota: cpfNaNota,
                                pontuarFidelidade: pontuarFidelidade,
                                consignacaoId: consignacaoId,
                                romaneiosConsignacao: romaneiosConsignacao,
                              ),
                            );
                      },
                      onVoltar: () {
                        final romaneioId = state.listaCompartilhada?.idLista;
                        Navigator.of(context).pop({
                          _resultadoRomaneioStatusKey: romaneioId == null
                              ? _resultadoRomaneioStatusFalha
                              : _resultadoRomaneioStatusParcial,
                          _resultadoRomaneioIdKey: romaneioId,
                        });
                      },
                    ),
                  RomaneioCriacaoStep.sucesso => _SucessoRomaneioView(
                      romaneio: state.romaneio,
                      quantidadeItens: state.totalItensProcessados,
                    ),
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ProcessandoRomaneioView extends StatelessWidget {
  final int quantidadeItens;

  const _ProcessandoRomaneioView({required this.quantidadeItens});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 16),
          Text(
            quantidadeItens > 0
                ? 'Criando romaneio e enviando $quantidadeItens item(ns)...'
                : 'Criando romaneio a partir da lista compartilhada...',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FalhaRomaneioView extends StatelessWidget {
  final String erro;
  final int? romaneioId;
  final VoidCallback onTentarNovamente;
  final VoidCallback onVoltar;

  const _FalhaRomaneioView({
    required this.erro,
    required this.romaneioId,
    required this.onTentarNovamente,
    required this.onVoltar,
  });

  @override
  Widget build(BuildContext context) {
    final romaneioPendente = romaneioId != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            romaneioPendente
                ? Icons.warning_amber_rounded
                : Icons.error_outline,
            size: 48,
          ),
          const SizedBox(height: 12),
          if (romaneioPendente) ...[
            Text(
              'Romaneio criado com pendência',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'O romaneio #$romaneioId já foi criado. Agora, volte e abra os romaneios pendentes para concluir o recebimento manualmente.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
          ],
          Text(
            erro,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onTentarNovamente,
            icon: const Icon(Icons.refresh),
            label: Text(
              romaneioPendente
                  ? 'Tentar concluir novamente'
                  : 'Tentar novamente',
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onVoltar,
            icon: Icon(
              romaneioPendente ? Icons.warning_amber : Icons.arrow_back,
            ),
            label: Text(
              romaneioPendente
                  ? 'Voltar e ver pendências'
                  : 'Voltar para entrada manual',
            ),
          ),
        ],
      ),
    );
  }
}

class _SucessoRomaneioView extends StatelessWidget {
  final Romaneio? romaneio;
  final int quantidadeItens;

  const _SucessoRomaneioView({
    required this.romaneio,
    required this.quantidadeItens,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _mensagemSucesso(romaneio?.operacao),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Operação: ${romaneio?.operacao?.descricao ?? '-'}'),
                Text('Situação: ${romaneio?.situacao ?? '-'}'),
                Text('Quantidade de produtos: $quantidadeItens'),
                if (romaneio?.valorBruto != null)
                  Text('Valor de entrada: ${romaneio!.valorBruto}'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: romaneio?.id == null
              ? null
              : () {
                  Navigator.of(context).pushReplacementNamed(
                    '/romaneio',
                    result: {
                      _resultadoRomaneioStatusKey:
                          _resultadoRomaneioStatusSucesso,
                      _resultadoRomaneioIdKey: romaneio?.id,
                    },
                    arguments: {
                      'idRomaneio': romaneio!.id,
                      'permitirEdicao': false,
                    },
                  );
                },
          icon: const Icon(Icons.open_in_new),
          label: const Text('Abrir romaneio criado'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop({
            _resultadoRomaneioStatusKey: _resultadoRomaneioStatusSucesso,
            _resultadoRomaneioIdKey: romaneio?.id,
          }),
          child: const Text('Voltar'),
        ),
      ],
    );
  }

  String _mensagemSucesso(TipoOperacao? operacao) {
    switch (operacao) {
      case TipoOperacao.venda:
        return 'Venda realizada com sucesso!';
      case TipoOperacao.manual_saida:
        return 'Saída de produtos realizada com sucesso!';
      default:
        return 'Entrada de produtos realizada com sucesso!';
    }
  }
}
