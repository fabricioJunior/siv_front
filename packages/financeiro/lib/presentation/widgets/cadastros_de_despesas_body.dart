import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/permissoes/componente_controlado_wiget.dart';
import 'package:core/presentation/debouncer.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:financeiro/models.dart';
import 'package:financeiro/presentation.dart';
import 'package:financeiro/presentation/utils/validacao_origem_pagamento_despesa.dart';
import 'package:financeiro/presentation/widgets/card_blueprint.dart';
import 'package:financeiro/presentation/widgets/despesa_status_mark.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _breakpointLargo = 1000.0;

class CadastrosDeDespesasBody extends StatelessWidget {
  const CadastrosDeDespesasBody({super.key});

  @override
  Widget build(BuildContext context) {
    final categorias = PermissaoPorNome.acessoPermitido('DESFM001');
    final origens = PermissaoPorNome.acessoPermitido('DESFM002');

    if (!categorias && !origens) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final largo = constraints.maxWidth >= _breakpointLargo;
        final colCategorias = categorias
            ? SizedBox(width: largo ? 380 : double.infinity, child: _CategoriasDespesaSection(largo: largo))
            : null;
        final colOrigens = origens
            ? SizedBox(width: largo && categorias ? null : double.infinity, child: _OrigensPagamentoDespesaSection(largo: largo))
            : null;

        if (largo && categorias && origens) {
          return Padding(
            // Esquerda 16 pra alinhar com o rótulo "PAINEL" da TabBar.
            padding: const EdgeInsets.fromLTRB(16, 20, 20, 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                colCategorias!,
                const SizedBox(width: 20),
                Expanded(child: colOrigens!),
              ],
            ),
          );
        }

        if (categorias && origens) {
          return _AbasCadastrosMobile(
            categorias: _CategoriasDespesaSection(largo: largo),
            origens: _OrigensPagamentoDespesaSection(largo: largo),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (colCategorias != null) colCategorias,
            if (colOrigens != null) colOrigens,
          ],
        );
      },
    );
  }
}

class _AbasCadastrosMobile extends StatefulWidget {
  final Widget categorias;
  final Widget origens;

  const _AbasCadastrosMobile({required this.categorias, required this.origens});

  @override
  State<_AbasCadastrosMobile> createState() => _AbasCadastrosMobileState();
}

class _AbasCadastrosMobileState extends State<_AbasCadastrosMobile> {
  bool _categoriasAtiva = true;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    Widget aba(String rotulo, bool ativa, VoidCallback onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
              decoration: BoxDecoration(
                color: ativa ? cores.acoAtivo : Colors.white,
                borderRadius: BorderRadius.circular(SivDimensoes.raio),
              ),
              child: Text(
                rotulo,
                style: textos.rotulo.copyWith(
                  fontSize: 12,
                  color: ativa ? Colors.white : cores.textoPrincipal,
                ),
              ),
            ),
          ),
        );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: cores.hairline),
            borderRadius: BorderRadius.circular(SivDimensoes.raio),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                aba('CATEGORIAS', _categoriasAtiva, () => setState(() => _categoriasAtiva = true)),
                aba('ORIGENS', !_categoriasAtiva, () => setState(() => _categoriasAtiva = false)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _categoriasAtiva ? widget.categorias : widget.origens,
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Categorias
// ---------------------------------------------------------------------------

class _CategoriasDespesaSection extends StatefulWidget {
  final bool largo;

  const _CategoriasDespesaSection({required this.largo});

  @override
  State<_CategoriasDespesaSection> createState() => _CategoriasDespesaSectionState();
}

class _CategoriasDespesaSectionState extends State<_CategoriasDespesaSection> {
  final bloc = sl<CategoriasDespesaBloc>();
  final debouncer = Debouncer(milliseconds: 400);
  int? _editandoId;
  bool _criandoNova = false;
  final _nomeController = TextEditingController();
  bool _inativa = false;

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  void initState() {
    super.initState();
    bloc.add(CategoriasDespesaIniciou(empresaId: _empresaId));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  void _abrirEdicao({int? id, String nome = '', bool inativa = false}) async {
    if (!widget.largo) {
      final result = await Navigator.of(context).pushNamed('/categoria_despesa', arguments: {'id': id});
      if (result == true && mounted) bloc.add(CategoriasDespesaIniciou(empresaId: _empresaId));
      return;
    }
    setState(() {
      _editandoId = id;
      _criandoNova = id == null;
      _nomeController.text = nome;
      _inativa = inativa;
    });
  }

  void _fecharEdicao() => setState(() {
        _editandoId = null;
        _criandoNova = false;
      });

  void _salvar() {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;
    bloc.add(CategoriasDespesaSalvou(id: _editandoId, empresaId: _empresaId, nome: nome, inativa: _inativa));
    _fecharEdicao();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final calendario = context.watch<CalendarioDeDespesasBloc>().state;
    final contagemPorCategoria = <int, int>{};
    for (final o in calendario.ocorrencias) {
      if (o.status == StatusDespesa.cancelado) continue;
      contagemPorCategoria.update(o.categoriaId, (v) => v + 1, ifAbsent: () => 1);
    }

    return BlocProvider<CategoriasDespesaBloc>(
      create: (_) => bloc,
      child: BlocConsumer<CategoriasDespesaBloc, CategoriasDespesaState>(
        listenWhen: (previous, current) => current.erro != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.erro!)));
        },
        builder: (context, state) {
          return CardBlueprint(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('CATEGORIAS', style: textos.secao.copyWith(fontSize: 16, color: cores.acoAtivo)),
                      OutlinedButton.icon(
                        onPressed: () => _abrirEdicao(),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text('Nova'),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: cores.hairline),
                if (_criandoNova) _linhaEdicao(context),
                if (state.categorias.length > 12)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: SearchBar(
                      hintText: 'Buscar por nome',
                      onChanged: (value) => debouncer.run(
                        () => bloc.add(CategoriasDespesaIniciou(empresaId: _empresaId, busca: value)),
                      ),
                    ),
                  ),
                if (state is CategoriasDespesaCarregarEmProgresso)
                  const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator.adaptive()))
                else if (state.categorias.isEmpty)
                  Padding(padding: const EdgeInsets.all(16), child: Text('Nenhuma categoria cadastrada.', style: textos.apoio))
                else
                  for (final categoria in state.categorias)
                    _editandoId == categoria.id
                        ? _linhaEdicao(context)
                        : _linhaCategoria(context, categoria, contagemPorCategoria[categoria.id] ?? 0),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _linhaEdicao(BuildContext context) {
    final cores = context.sivColors;
    return Container(
      color: cores.selecaoFundo,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _nomeController,
              autofocus: true,
              decoration: const InputDecoration(isDense: true),
              onSubmitted: (_) => _salvar(),
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Ativa', style: context.sivTextos.apoio),
              Switch.adaptive(value: !_inativa, onChanged: (v) => setState(() => _inativa = !v)),
            ],
          ),
          const SizedBox(width: 4),
          FilledButton(onPressed: _salvar, child: const Text('Salvar')),
        ],
      ),
    );
  }

  Widget _linhaCategoria(BuildContext context, CategoriaDespesa categoria, int contagem) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final subtitulo = contagem > 0 ? '$contagem despesas no mês' : 'Nenhuma despesa no mês';

    if (!widget.largo) {
      return _CardCadastroMobile(
        onTap: () => _abrirEdicao(id: categoria.id, nome: categoria.nome, inativa: categoria.inativa),
        nome: categoria.nome,
        opaco: categoria.inativa,
        subtitulo: subtitulo,
        tag: categoria.inativa ? const DespesaTag('Inativa', neutra: true) : null,
      );
    }

    return InkWell(
      onTap: () => _abrirEdicao(id: categoria.id, nome: categoria.nome, inativa: categoria.inativa),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: cores.hairline))),
        child: Row(
          children: [
            Expanded(
              child: Opacity(
                opacity: categoria.inativa ? 0.6 : 1,
                child: Text(categoria.nome, style: textos.corpo.copyWith(fontSize: 14)),
              ),
            ),
            if (categoria.inativa) ...[const DespesaTag('Inativa', neutra: true), const SizedBox(width: 8)],
            Text(
              contagem > 0 ? '$contagem despesas no mês' : '—',
              style: textos.apoio.copyWith(fontSize: 12, color: cores.textoApoio),
            ),
            const SizedBox(width: 8),
            Icon(Icons.edit_outlined, size: 15, color: cores.textoApoio),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Origens de pagamento
// ---------------------------------------------------------------------------

class _OrigensPagamentoDespesaSection extends StatefulWidget {
  final bool largo;

  const _OrigensPagamentoDespesaSection({required this.largo});

  @override
  State<_OrigensPagamentoDespesaSection> createState() => _OrigensPagamentoDespesaSectionState();
}

class _OrigensPagamentoDespesaSectionState extends State<_OrigensPagamentoDespesaSection> {
  final bloc = sl<OrigensPagamentoDespesaBloc>();
  late final TextEditingController _nomeController;
  late final TextEditingController _diaVencimentoController;
  late final TextEditingController _prazoController;

  int get _empresaId => sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController();
    _diaVencimentoController = TextEditingController();
    _prazoController = TextEditingController();
    bloc.add(OrigensPagamentoDespesaIniciou(empresaId: _empresaId));
  }

  Future<void> _abrirEdicao({int? id}) async {
    if (!widget.largo) {
      final result = await Navigator.of(context).pushNamed('/origem_pagamento_despesa', arguments: {'id': id});
      if (result == true && mounted) bloc.add(OrigensPagamentoDespesaIniciou(empresaId: _empresaId));
      return;
    }
    bloc.add(OrigensPagamentoDespesaSelecionou(id: id));
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _diaVencimentoController.dispose();
    _prazoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return BlocProvider<OrigensPagamentoDespesaBloc>(
      create: (_) => bloc,
      child: BlocConsumer<OrigensPagamentoDespesaBloc, OrigensPagamentoDespesaState>(
        listenWhen: (previous, current) => current.erro != null,
        listener: (context, state) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.erro!)));
        },
        builder: (context, state) {
          _sincronizarControllers(state);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardBlueprint(
                padding: EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('ORIGENS DE PAGAMENTO', style: textos.secao.copyWith(fontSize: 16, color: cores.acoAtivo)),
                          OutlinedButton.icon(
                            onPressed: () => _abrirEdicao(),
                            icon: const Icon(Icons.add, size: 14),
                            label: const Text('Nova origem'),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: cores.hairline),
                    if (widget.largo)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Row(
                          children: [
                            Expanded(flex: 14, child: Text('NOME', style: textos.rotulo.copyWith(fontSize: 11))),
                            Expanded(flex: 10, child: Text('TIPO', style: textos.rotulo.copyWith(fontSize: 11))),
                            Expanded(flex: 8, child: Text('VENCIMENTO', style: textos.rotulo.copyWith(fontSize: 11))),
                            Expanded(flex: 8, child: Text('FECHAMENTO', style: textos.rotulo.copyWith(fontSize: 11))),
                          ],
                        ),
                      ),
                    if (state is OrigensPagamentoDespesaCarregarEmProgresso)
                      const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator.adaptive()))
                    else if (state.origens.isEmpty)
                      Padding(padding: const EdgeInsets.all(16), child: Text('Nenhuma origem cadastrada.', style: textos.apoio))
                    else
                      for (final origem in state.origens)
                        _linhaOrigem(context, origem, selecionada: state is OrigensPagamentoDespesaCarregarSucesso && state.formId == origem.id),
                  ],
                ),
              ),
              if (widget.largo) ...[
                const SizedBox(height: 18),
                _cardEditarOrigem(context, state),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _linhaOrigem(BuildContext context, OrigemPagamentoDespesa origem, {required bool selecionada}) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    if (!widget.largo) {
      final credito = origem.tipo.diaVencimentoObrigatorio;
      final subtitulo = credito
          ? '${origem.tipo.label} · vence dia ${origem.diaVencimento} · fecha ${origem.prazoFechamentoDias} dias antes'
          : origem.tipo.label;
      return _CardCadastroMobile(
        onTap: () => _abrirEdicao(id: origem.id),
        nome: origem.nome,
        subtitulo: subtitulo,
      );
    }

    return InkWell(
      onTap: () => _abrirEdicao(id: origem.id),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selecionada ? cores.selecaoFundo : null,
          border: Border(
            left: BorderSide(color: selecionada ? cores.aco : Colors.transparent, width: 3),
            bottom: BorderSide(color: cores.hairline),
          ),
        ),
        child: Row(
          children: [
            Expanded(flex: 14, child: Text(origem.nome, style: textos.corpo.copyWith(fontSize: 14))),
            Expanded(flex: 10, child: Text(origem.tipo.label, style: textos.apoio.copyWith(fontSize: 13))),
            Expanded(
              flex: 8,
              child: Text(
                origem.tipo.diaVencimentoObrigatorio ? 'Dia ${origem.diaVencimento}' : '—',
                style: textos.corpo.copyWith(fontSize: 13),
              ),
            ),
            Expanded(
              flex: 8,
              child: Text(
                origem.tipo.diaVencimentoObrigatorio ? '${origem.prazoFechamentoDias} dias antes' : '—',
                style: textos.corpo.copyWith(fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardEditarOrigem(BuildContext context, OrigensPagamentoDespesaState state) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    if (state is! OrigensPagamentoDespesaCarregarSucesso || !state.editando) {
      return CardBlueprint(
        child: Text(
          'Clique numa linha acima pra editar, ou em "Nova origem" pra cadastrar.',
          style: textos.apoio.copyWith(color: cores.textoApoio),
        ),
      );
    }

    final credito = state.formTipo.diaVencimentoObrigatorio;
    final vencimentoFechamento = credito && state.formDiaVencimento != null && state.formPrazoFechamentoDias != null
        ? _diaFechamento(state.formDiaVencimento!, state.formPrazoFechamentoDias!)
        : null;

    return CardBlueprint(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(state.formId == null ? 'Nova origem' : 'Editar origem', style: textos.secao.copyWith(fontSize: 18)),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  controller: _nomeController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                  onChanged: (v) => bloc.add(OrigensPagamentoDespesaCampoAlterado(nome: v)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                flex: 2,
                child: _seletorTipo(context, state.formTipo),
              ),
            ],
          ),
          if (credito) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: _diaVencimentoController,
                    decoration: const InputDecoration(labelText: 'Dia de vencimento'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => bloc.add(OrigensPagamentoDespesaCampoAlterado(diaVencimento: int.tryParse(v))),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 170,
                  child: TextField(
                    controller: _prazoController,
                    decoration: const InputDecoration(labelText: 'Fecha dias antes'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (v) => bloc.add(OrigensPagamentoDespesaCampoAlterado(prazoFechamentoDias: int.tryParse(v))),
                  ),
                ),
                const SizedBox(width: 14),
                if (vencimentoFechamento != null)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Fatura fecha dia $vencimentoFechamento · compras após o fechamento vencem no mês seguinte.',
                        style: textos.apoio.copyWith(fontSize: 12.5, color: cores.acoAtivo),
                      ),
                    ),
                  ),
              ],
            ),
          ] else ...[
            const SizedBox(height: 10),
            Text(
              'Sem vencimento próprio — a despesa usa a data informada no lançamento.',
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => bloc.add(OrigensPagamentoDespesaSelecionou(id: null)),
                child: const Text('Descartar'),
              ),
              const SizedBox(width: 10),
              FilledButton(
                onPressed: () {
                  final erroDia = credito ? validarDiaVencimento(state.formDiaVencimento) : null;
                  final erroPrazo = credito ? validarPrazoFechamentoDias(state.formPrazoFechamentoDias) : null;
                  if (state.formNome.trim().isEmpty || erroDia != null || erroPrazo != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(erroDia ?? erroPrazo ?? 'Informe o nome da origem.')),
                    );
                    return;
                  }
                  bloc.add(OrigensPagamentoDespesaSalvou(empresaId: _empresaId));
                },
                child: const Text('Salvar origem'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _seletorTipo(BuildContext context, TipoOrigemPagamentoDespesa selecionado) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: cores.hairline), borderRadius: BorderRadius.circular(SivDimensoes.raio)),
      child: Row(
        children: [
          for (final tipo in TipoOrigemPagamentoDespesa.values)
            Expanded(
              child: InkWell(
                onTap: () => bloc.add(OrigensPagamentoDespesaCampoAlterado(tipo: tipo)),
                child: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
                  color: tipo == selecionado ? cores.acoAtivo : Colors.transparent,
                  child: Text(
                    _tipoAbreviado(tipo),
                    textAlign: TextAlign.center,
                    style: textos.apoio.copyWith(
                      fontSize: 11,
                      color: tipo == selecionado ? Colors.white : cores.textoPrincipal,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _sincronizarControllers(OrigensPagamentoDespesaState state) {
    if (state is! OrigensPagamentoDespesaCarregarSucesso) return;
    _sync(_nomeController, state.formNome);
    _sync(_diaVencimentoController, state.formDiaVencimento?.toString() ?? '');
    _sync(_prazoController, state.formPrazoFechamentoDias?.toString() ?? '');
  }

  void _sync(TextEditingController controller, String valor) {
    if (controller.text != valor) {
      controller.value = TextEditingValue(text: valor, selection: TextSelection.collapsed(offset: valor.length));
    }
  }
}

String _tipoAbreviado(TipoOrigemPagamentoDespesa tipo) {
  switch (tipo) {
    case TipoOrigemPagamentoDespesa.dinheiro:
      return 'Dinheiro';
    case TipoOrigemPagamentoDespesa.pix:
      return 'Pix';
    case TipoOrigemPagamentoDespesa.contaCorrente:
      return 'Conta\ncorrente';
    case TipoOrigemPagamentoDespesa.cartaoDebito:
      return 'Débito';
    case TipoOrigemPagamentoDespesa.cartaoCredito:
      return 'Crédito';
  }
}

class _CardCadastroMobile extends StatelessWidget {
  final VoidCallback onTap;
  final String nome;
  final String subtitulo;
  final Widget? tag;
  final bool opaco;

  const _CardCadastroMobile({
    required this.onTap,
    required this.nome,
    required this.subtitulo,
    this.tag,
    this.opaco = false,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: CardBlueprint(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Opacity(
                  opacity: opaco ? 0.6 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(nome,
                                style: textos.corpo.copyWith(fontSize: 14.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          if (tag != null) ...[const SizedBox(width: 8), tag!],
                        ],
                      ),
                      Text(subtitulo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textos.apoio
                              .copyWith(fontSize: 12, color: cores.textoApoio)),
                    ],
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: cores.textoApoio),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dia em que a fatura fecha (vencimento - prazo, com volta de mês).
int _diaFechamento(int diaVencimento, int prazoFechamentoDias) {
  final vencimento = DateTime(DateTime.now().year, DateTime.now().month, diaVencimento);
  return vencimento.subtract(Duration(days: prazoFechamentoDias)).day;
}
