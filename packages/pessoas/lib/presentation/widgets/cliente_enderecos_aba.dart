import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';
import 'package:pessoas/models.dart';
import 'package:pessoas/presentation/bloc/endereco_cadastro_bloc/endereco_cadastro_bloc.dart';
import 'package:pessoas/presentation/bloc/enderecos_bloc/enderecos_bloc.dart';
import 'package:pessoas/presentation/pages/endereco_cadastro_page.dart';

import 'cliente_aba_comum.dart';
import 'cliente_abas.dart';

/// Aba Endereços (3b). Exige EnderecosBloc acima na árvore.
class ClienteEnderecosAba extends StatefulWidget {
  final int idPessoa;

  const ClienteEnderecosAba({super.key, required this.idPessoa});

  @override
  State<ClienteEnderecosAba> createState() => _ClienteEnderecosAbaState();
}

class _ClienteEnderecosAbaState extends State<ClienteEnderecosAba> {
  late final ClienteAcoes _acoes;

  @override
  void initState() {
    super.initState();
    _acoes = context
        .getInheritedWidgetOfExactType<ClienteAcoesEscopo>()!
        .acoes
      ..definir(ClienteAcao.novoEndereco, _novo);
  }

  @override
  void dispose() {
    _acoes.definir(ClienteAcao.novoEndereco, null);
    super.dispose();
  }

  void _novo() {
    final bloc = context.read<EnderecosBloc>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: bloc),
            BlocProvider(create: (_) => sl<EnderecoCadastroBloc>()),
          ],
          child: EnderecoCadastroPage(idPessoa: widget.idPessoa),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mobile =
        MediaQuery.sizeOf(context).width < SivDimensoes.breakpointMenuDrawer;
    return BlocConsumer<EnderecosBloc, EnderecosState>(
      // Backend pode rebaixar o antigo principal: recarrega após salvar.
      listenWhen: (_, s) => s is EnderecosSalvarSucesso,
      listener: (context, s) => context
          .read<EnderecosBloc>()
          .add(EnderecosIniciou(idPessoa: widget.idPessoa)),
      builder: (context, state) {
        if (state is EnderecosCarregarEmProgresso && state.enderecos.isEmpty) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }
        if (state.enderecos.isEmpty) {
          return Center(
            child: Text('Nenhum endereço cadastrado.',
                style: context.sivTextos.apoio
                    .copyWith(color: context.sivColors.textoApoio)),
          );
        }
        return LayoutBuilder(
          builder: (context, c) {
            const gap = 16.0;
            final largura =
                mobile ? c.maxWidth - 32 : (c.maxWidth - 68 - gap) / 2;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal:
                    mobile ? 16 : SivDimensoes.paddingBarraTituloHorizontal,
                vertical: mobile ? 16 : 24,
              ),
              child: Wrap(
                spacing: gap,
                runSpacing: gap,
                children: [
                  for (final e in state.enderecos)
                    SizedBox(
                      width: largura,
                      child: _EnderecoCard(
                        endereco: e,
                        aoEditar: () => _EnderecoModal.show(context, e),
                        aoTornarPrincipal: () => _tornarPrincipal(e),
                        aoRemover: () => _remover(e),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _tornarPrincipal(Endereco e) => context.read<EnderecosBloc>().add(
        EnderecosAtualizouEndereco(
          endereco: Endereco.create(
            id: e.id,
            principal: true,
            tipoEndereco: e.tipoEndereco,
            cep: e.cep,
            logradouro: e.logradouro,
            numero: e.numero,
            complemento: e.complemento,
            bairro: e.bairro,
            municipio: e.municipio,
            uf: e.uf,
            pais: e.pais,
          ),
        ),
      );

  Future<void> _remover(Endereco e) async {
    final bloc = context.read<EnderecosBloc>();
    final ok = await confirmarCliente(
      context,
      titulo: 'Remover endereço',
      texto: 'Remover ${e.logradouro}, ${e.numero}? '
          'Não dá para desfazer pela tela.',
      confirmar: 'Remover',
    );
    if (ok) bloc.add(EnderecosExcluiuEndereco(idEndereco: e.id!));
  }
}

String _tipoLabel(TipoEndereco t) => switch (t) {
      TipoEndereco.comercial => 'Comercial',
      TipoEndereco.residencial => 'Residencial',
    };

class _EnderecoCard extends StatelessWidget {
  final Endereco endereco;
  final VoidCallback aoEditar;
  final VoidCallback aoTornarPrincipal;
  final VoidCallback aoRemover;

  const _EnderecoCard({
    required this.endereco,
    required this.aoEditar,
    required this.aoTornarPrincipal,
    required this.aoRemover,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final e = endereco;
    final compl = e.complemento.trim().isEmpty ? '' : ' · ${e.complemento}';

    return Stack(
      children: [
        SivCard(
          padding: const EdgeInsets.fromLTRB(20, 14, 8, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(_tipoLabel(e.tipoEndereco),
                        style: textos.secao.copyWith(fontSize: 15)),
                  ),
                  if (e.principal)
                    ClienteTag(
                      'Principal',
                      cor: cores.acoProfundo,
                      fundo: cores.aco.withValues(alpha: 0.15),
                    ),
                  ClienteMenuMais({
                    'Editar': aoEditar,
                    'Tornar principal':
                        e.principal || e.id == null ? null : aoTornarPrincipal,
                    // Principal só sai depois que outro virar principal.
                    'Remover': e.principal || e.id == null ? null : aoRemover,
                  }),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text('${e.logradouro}, ${e.numero}$compl',
                    style: textos.corpo),
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Text(
                  '${e.bairro} · ${e.municipio}/${e.uf} · CEP ${e.cep}',
                  style: textos.apoio.copyWith(color: cores.textoApoio),
                ),
              ),
            ],
          ),
        ),
        ...sivCantosBlueprint(cores.aco.withValues(alpha: 0.4)),
      ],
    );
  }
}

/// Edição de endereço, no visual de 2b (SivModal).
class _EnderecoModal extends StatefulWidget {
  final Endereco endereco;

  const _EnderecoModal(this.endereco);

  static Future<void> show(BuildContext context, Endereco endereco) {
    final bloc = context.read<EnderecosBloc>();
    return showDialog<void>(
      context: context,
      barrierColor: context.sivColors.acoEscuro.withValues(alpha: 0.35),
      builder: (_) => BlocProvider.value(
        value: bloc,
        child: _EnderecoModal(endereco),
      ),
    );
  }

  @override
  State<_EnderecoModal> createState() => _EnderecoModalState();
}

class _EnderecoModalState extends State<_EnderecoModal> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _c;
  late TipoEndereco _tipo = widget.endereco.tipoEndereco;
  late bool _principal = widget.endereco.principal;

  @override
  void initState() {
    super.initState();
    final e = widget.endereco;
    _c = {
      'CEP': e.cep,
      'Logradouro': e.logradouro,
      'Número': e.numero,
      'Complemento': e.complemento,
      'Bairro': e.bairro,
      'Município': e.municipio,
      'UF': e.uf,
      'País': e.pais,
    }.map((k, v) => MapEntry(k, TextEditingController(text: v)));
  }

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _t(String k) => _c[k]!.text.trim();

  void _salvar() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<EnderecosBloc>().add(
          EnderecosAtualizouEndereco(
            endereco: Endereco.create(
              id: widget.endereco.id,
              principal: _principal,
              tipoEndereco: _tipo,
              cep: _t('CEP'),
              logradouro: _t('Logradouro'),
              numero: _t('Número'),
              complemento: _t('Complemento'),
              bairro: _t('Bairro'),
              municipio: _t('Município'),
              uf: _t('UF'),
              pais: _t('País'),
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EnderecosBloc, EnderecosState>(
      listener: (context, state) {
        if (state is EnderecosSalvarSucesso) {
          Navigator.of(context).pop();
        } else if (state is EnderecosSalvarFalha) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível atualizar o endereço.'),
            ),
          );
        }
      },
      child: SivModal(
        titulo: 'Editar endereço',
        larguraMaxima: 560,
        corpo: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<TipoEndereco>(
                initialValue: _tipo,
                items: [
                  for (final t in TipoEndereco.values)
                    DropdownMenuItem(value: t, child: Text(_tipoLabel(t))),
                ],
                onChanged: (v) => setState(() => _tipo = v ?? _tipo),
                decoration:
                    const InputDecoration(labelText: 'Tipo de endereço'),
              ),
              CheckboxListTile(
                value: _principal,
                onChanged: (v) => setState(() => _principal = v ?? false),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('Endereço principal'),
              ),
              for (final e in _c.entries)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextFormField(
                    controller: e.value,
                    decoration: InputDecoration(labelText: e.key),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Informe ${e.key}'
                        : null,
                  ),
                ),
            ],
          ),
        ),
        acoes: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          BlocBuilder<EnderecosBloc, EnderecosState>(
            builder: (context, state) => ElevatedButton(
              onPressed: state is EnderecosSalvarEmProgresso ? null : _salvar,
              child: const Text('Salvar endereço'),
            ),
          ),
        ],
      ),
    );
  }
}
