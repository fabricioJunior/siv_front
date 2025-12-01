import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
                                valor: novoPonto.valor,
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
              return CircularProgressIndicator();
            },
          ),
        ),
        body: Column(
          children: [
            Text('Histórico de pontos'),
            Expanded(
              child: BlocBuilder<PontosBloc, PontosState>(
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case const (PontosCarregarEmProgresso):
                    case const (PontosCriarPontoEmProgresso):
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [CircularProgressIndicator.adaptive()],
                      );
                    default:
                      return ListView.builder(
                        itemCount: state.pontos?.length ?? 0,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var ponto = state.pontos![index];
                          return ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${ponto.valor} ${ponto.descricao}'),
                                Text(ponto.dtCriacao?.toString() ?? '')
                              ],
                            ),
                          );
                        },
                      );
                  }
                },
              ),
            )
          ],
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

  _NovoPontoModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.check,
        ),
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
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nova pontuação',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(
                height: 16,
              ),
              Text('Quantidade'),
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
              Text('Descrição'),
              TextFormField(
                maxLength: 100,
                controller: descricaoController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o motivo dos pontos';
                  }
                  return null;
                },
              )
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
