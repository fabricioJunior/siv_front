import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pessoas/models.dart';

import '../bloc/pontos_bloc/pontos_bloc.dart';

class PontosPage extends StatelessWidget {
  final int idPessoa;

  const PontosPage({super.key, required this.idPessoa});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PontosBloc>(
      create: (context) =>
          sl<PontosBloc>()..add(PontosIniciou(idPessoa: idPessoa)),
      child: Scaffold(
        floatingActionButton: BlocBuilder<PontosBloc, PontosState>(
          builder: (context, state) {
            var enable = state is! PontosCarregarEmProgresso &&
                state is! PontosCriarPontoEmProgresso;
            return FloatingActionButton(
              onPressed: enable
                  ? () async {
                      var novoPonto =
                          await _NovoPontoModal.show(context: context);
                      if (novoPonto != null) {
                        // ignore: use_build_context_synchronously
                        context.read<PontosBloc>().add(
                              PontosCriouNovoPonto(
                                valor: novoPonto.valor.toDouble(),
                                descricao: novoPonto.descricao,
                              ),
                            );
                      }
                    }
                  : null,
              child: enable
                  ? Icon(Icons.add)
                  : CircularProgressIndicator.adaptive(),
            );
          },
        ),
        appBar: AppBar(
          title: BlocBuilder<PontosBloc, PontosState>(
            builder: (context, state) {
              if (state.pessoa != null) {
                return Text(state.pessoa?.nome ?? '');
              }
              return const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Histórico de pontos',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    BlocBuilder<PontosBloc, PontosState>(
                      builder: (context, state) {
                        return TextButton(
                          onPressed: () async {
                            var resgatePonto = await _ResgatarPontoModal.show(
                                context: context);
                            if (resgatePonto != null) {
                              // ignore: use_build_context_synchronously
                              context.read<PontosBloc>().add(
                                    PontosResgatou(
                                      valor: resgatePonto.valor,
                                      descricao: resgatePonto.descricao,
                                    ),
                                  );
                            }
                          },
                          child: const Text('Resgatar Pontos'),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: BlocBuilder<PontosBloc, PontosState>(
                      builder: (context, state) {
                        return Text(
                          'Total de pontos: ${state.totalDePontos}',
                          style: Theme.of(context).textTheme.titleSmall,
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: BlocBuilder<PontosBloc, PontosState>(
                    builder: (context, state) {
                      switch (state.runtimeType) {
                        case const (PontosCarregarEmProgresso):
                        case const (PontosCriarPontoEmProgresso):
                          return const Center(
                            child: CircularProgressIndicator.adaptive(),
                          );
                        default:
                          if (state.pontos == null || state.pontos!.isEmpty) {
                            return const Center(
                              child:
                                  Text('Nenhum ponto lançado até o momento.'),
                            );
                          }

                          return ListView.separated(
                            itemCount: state.pontos!.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              var ponto = state.pontos![index];
                              final isDebito = ponto.tipo == TipoDePonto.debito;
                              final dataCriacao = ponto.dtCriacao;
                              final dataTexto = dataCriacao == null
                                  ? 'Sem data'
                                  : '${dataCriacao.day.toString().padLeft(2, '0')}/${dataCriacao.month.toString().padLeft(2, '0')}/${dataCriacao.year}';

                              return Card(
                                color: isDebito
                                    ? const Color.fromRGBO(255, 82, 82, 1)
                                    : Colors.greenAccent.shade100,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  leading: CircleAvatar(
                                    child: Text(ponto.valor.toInt().toString()),
                                  ),
                                  title: Text(
                                    ponto.descricao,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(dataTexto),
                                  trailing: IconButton(
                                    onPressed: () {
                                      context.read<PontosBloc>().add(
                                            PontosCancelouPonto(
                                              idPonto: ponto.id,
                                            ),
                                          );
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ),
                              );
                            },
                          );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class _NovoPontoModal extends StatelessWidget {
  static Future<_NovoPonto?> show({
    required BuildContext context,
  }) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return _NovoPontoModal();
      },
    );
  }

  var formKey = GlobalKey<FormState>();
  var valorController = TextEditingController();
  var descricaoController = TextEditingController();

  _NovoPontoModal();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nova pontuação',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              const Text('Quantidade'),
              TextFormField(
                maxLength: 2,
                controller: valorController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a quantidade de pontos';
                  }
                  return null;
                },
              ),
              const Text('Descrição'),
              TextFormField(
                maxLength: 100,
                controller: descricaoController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o motivo dos pontos';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop(
                        _NovoPonto(
                          valor: int.parse(valorController.text),
                          descricao: descricaoController.text,
                        ),
                      );
                    }
                  },
                  label: const Text('Confirmar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NovoPonto {
  final int valor;
  final String descricao;

  _NovoPonto({required this.valor, required this.descricao});
}

// ignore: must_be_immutable
class _ResgatarPontoModal extends StatelessWidget {
  static Future<_ResgateDePontos?> show({
    required BuildContext context,
  }) async {
    return showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return _ResgatarPontoModal();
      },
    );
  }

  var formKey = GlobalKey<FormState>();
  var valorController = TextEditingController();
  var descricaoController = TextEditingController();

  _ResgatarPontoModal();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resgatar pontos',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              const Text('Quantidade'),
              TextFormField(
                maxLength: 2,
                controller: valorController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a quantidade de pontos';
                  }
                  return null;
                },
              ),
              const Text('Descrição'),
              TextFormField(
                maxLength: 100,
                controller: descricaoController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o motivo do resgate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.check),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      Navigator.of(context).pop(
                        _ResgateDePontos(
                          valor: int.parse(valorController.text),
                          descricao: descricaoController.text,
                        ),
                      );
                    }
                  },
                  label: const Text('Confirmar resgate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResgateDePontos {
  final int valor;
  final String descricao;

  _ResgateDePontos({required this.valor, required this.descricao});
}
