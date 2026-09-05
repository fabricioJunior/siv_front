import 'package:comercial/models.dart';
import 'package:comercial/presentation.dart';
import 'package:core/arquivos.dart';
import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/seletores.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:empresas/presentation/widgets/empresa_seletor.dart';
import 'package:empresas/presentation/widgets/terminal_seletor.dart';
import 'package:financeiro/domain/models/forma_de_pagamento.dart';
import 'package:financeiro/presentation/widgets/formas_de_pagamento_seletor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:precos/presentation/widgets/tabelas_de_preco_seletor.dart';

/// Formulário de dados/identidade/integração do e-commerce, compartilhado
/// pelas rotas `/ecommerces` (mestre-detalhe) e `/configuracao_ecommerce`
/// (atalho que abre o mesmo formulário com o canal selecionado).
class EcommerceConfiguracaoFormulario extends StatefulWidget {
  final int? empresaId;
  final int? ecommerceId;
  final VoidCallback? onSalvou;
  final VoidCallback? onExcluido;

  const EcommerceConfiguracaoFormulario({
    super.key,
    this.empresaId,
    this.ecommerceId,
    this.onSalvou,
    this.onExcluido,
  });

  @override
  State<EcommerceConfiguracaoFormulario> createState() =>
      _EcommerceConfiguracaoFormularioState();
}

class _EcommerceConfiguracaoFormularioState
    extends State<EcommerceConfiguracaoFormulario> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _subtituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _iconeController = TextEditingController();

  late final int _empresaId;
  late final EcommerceConfiguracaoBloc _bloc;

  @override
  void initState() {
    super.initState();
    _empresaId =
        widget.empresaId ?? sl<IAcessoGlobalSessao>().empresaIdDaSessao ?? 0;
    _bloc = sl<EcommerceConfiguracaoBloc>()
      ..add(
        EcommerceConfiguracaoIniciou(
          empresaId: _empresaId,
          ecommerceId: widget.ecommerceId,
        ),
      );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _subtituloController.dispose();
    _descricaoController.dispose();
    _iconeController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceConfiguracaoBloc>.value(
      value: _bloc,
      child: BlocListener<EcommerceConfiguracaoBloc, EcommerceConfiguracaoState>(
        listener: (context, state) {
          if (state.step == EcommerceConfiguracaoStep.criado ||
              state.step == EcommerceConfiguracaoStep.salvo) {
            SivAviso.mostrar(context, mensagem: 'Configuração salva.');
            widget.onSalvou?.call();
          }
          if (state.step == EcommerceConfiguracaoStep.falha && state.erro != null) {
            SivAviso.mostrar(context, mensagem: state.erro!, tipo: SivAvisoTipo.falha);
          }
        },
        child: BlocBuilder<EcommerceConfiguracaoBloc, EcommerceConfiguracaoState>(
          builder: (context, state) {
            if (state.step == EcommerceConfiguracaoStep.carregando ||
                state.step == EcommerceConfiguracaoStep.inicial) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }

            if (state.titulo != null && _tituloController.text.isEmpty) {
              _tituloController.text = state.titulo!;
            }
            if (state.subtitulo != null && _subtituloController.text.isEmpty) {
              _subtituloController.text = state.subtitulo!;
            }
            if (state.descricao != null && _descricaoController.text.isEmpty) {
              _descricaoController.text = state.descricao!;
            }
            if (state.icone != null && _iconeController.text.isEmpty) {
              _iconeController.text = state.icone!;
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: SivDimensoes.paginaHorizontal,
                  vertical: SivDimensoes.paginaVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (state.id != null) ...[
                      _CardIntegracao(ecommerceId: state.id!),
                      const SizedBox(height: SivDimensoes.gapCards),
                    ],
                    SivCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('Identidade do canal', style: context.sivTextos.rotulo),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _tituloController,
                            decoration: const InputDecoration(labelText: 'Título'),
                            validator: (value) => (value == null || value.trim().isEmpty)
                                ? 'Informe o título'
                                : null,
                            onChanged: (value) => _emitirEdicao(context, state),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _subtituloController,
                            decoration: const InputDecoration(labelText: 'Subtítulo'),
                            onChanged: (value) => _emitirEdicao(context, state),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _descricaoController,
                            decoration: const InputDecoration(labelText: 'Descrição'),
                            maxLines: 3,
                            onChanged: (value) => _emitirEdicao(context, state),
                          ),
                          const SizedBox(height: 12),
                          // Não há uploader de imagem reutilizável no projeto -- fallback simples
                          // de URL até existir uma tela/serviço de upload dedicado.
                          TextFormField(
                            controller: _iconeController,
                            decoration: const InputDecoration(
                              labelText: 'Ícone (URL)',
                              hintText: 'https://...',
                            ),
                            onChanged: (value) => _emitirEdicao(context, state),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SivDimensoes.gapCards),
                    SivCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text('De onde o site puxa', style: context.sivTextos.rotulo),
                          const SizedBox(height: 12),
                          EmpresaSeletor(
                            titulo: 'Empresa de estoque',
                            itemsSelecionadosInicial: _idInicial(state.empresaEstoqueId),
                            onEmpresaChanged: (selecionadas) => _emitirEdicao(
                              context,
                              state,
                              empresaEstoqueId:
                                  selecionadas.isEmpty ? null : selecionadas.first.id,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TabelasDePrecoSeletor(
                            itemsSelecionadosInicial: _idInicial(state.tabelaDePrecoId),
                            onTabelaDePrecoChanged: (selecionadas) => _emitirEdicao(
                              context,
                              state,
                              tabelaDePrecoId:
                                  selecionadas.isEmpty ? null : selecionadas.first.id,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TerminalSeletor(
                            empresaId: _empresaId,
                            tipoFiltro: 'ecommerce',
                            itemsSelecionadosInicial: _idInicial(state.terminalId),
                            onTerminalChanged: (selecionadas) => _emitirEdicao(
                              context,
                              state,
                              terminalId: selecionadas.isEmpty ? null : selecionadas.first.id,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FormasDePagamentoSeletor(
                            modo: FormasDePagamentoSeletorModo.multipla,
                            tipoOperacaoFiltro: TipoOperacaoFormaPagamento.online,
                            itemsSelecionadosInicial: state.formasDePagamentoIds
                                .map((id) => SelectData(id: id, nome: '', data: const {}))
                                .toList(),
                            onFormaDePagamentoChanged: (selecionadas) => _emitirEdicao(
                              context,
                              state,
                              formasDePagamentoIds: selecionadas
                                  .map((forma) => forma.id)
                                  .whereType<int>()
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: SivDimensoes.gapCards),
                    FilledButton.icon(
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          context
                              .read<EcommerceConfiguracaoBloc>()
                              .add(const EcommerceConfiguracaoSalvou());
                        }
                      },
                      icon: const Icon(Icons.check),
                      label: const Text('Salvar configuração'),
                    ),
                    if (state.id != null) ...[
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(
                          '/ecommerce_referencias',
                          arguments: {'ecommerceId': state.id, 'titulo': state.titulo},
                        ),
                        icon: const Icon(Icons.shopping_bag_outlined),
                        label: const Text('Produtos no site'),
                      ),
                      const SizedBox(height: 12),
                      PermissaoPorNome(
                        idComponente: 'ECOFM003',
                        child: _EcommerceBannersBloco(ecommerceId: state.id!),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<SelectData> _idInicial(int? id) =>
      id == null ? const [] : [SelectData(id: id, nome: '', data: const {})];

  void _emitirEdicao(
    BuildContext context,
    EcommerceConfiguracaoState state, {
    int? empresaEstoqueId,
    int? tabelaDePrecoId,
    int? terminalId,
    List<int>? formasDePagamentoIds,
  }) {
    context.read<EcommerceConfiguracaoBloc>().add(
          EcommerceConfiguracaoEditou(
            titulo: _tituloController.text,
            subtitulo: _subtituloController.text,
            descricao: _descricaoController.text,
            icone: _iconeController.text,
            empresaEstoqueId: empresaEstoqueId ?? state.empresaEstoqueId,
            tabelaDePrecoId: tabelaDePrecoId ?? state.tabelaDePrecoId,
            terminalId: terminalId ?? state.terminalId,
            formasDePagamentoIds: formasDePagamentoIds ?? state.formasDePagamentoIds,
          ),
        );
  }
}

// Card com os dados que quem integra o site externo precisa: o id real do e-commerce (não
// confundir com empresaId) e o endpoint público do catálogo já montado com esse id.
class _CardIntegracao extends StatelessWidget {
  final int ecommerceId;

  const _CardIntegracao({required this.ecommerceId});

  String get _endpoint =>
      '/v1/e-commerce/$ecommerceId/catalogos/referencias?page=1&limit=24';

  void _copiar(BuildContext context, String texto, String rotulo) {
    Clipboard.setData(ClipboardData(text: texto));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$rotulo copiado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    return SivCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dados para integração', style: textos.rotulo),
          const SizedBox(height: 12),
          _linha(
            context,
            label: 'ID do e-commerce (use este, não o da empresa)',
            valor: '$ecommerceId',
          ),
          const SizedBox(height: 8),
          _linha(context, label: 'Endpoint do catálogo público', valor: _endpoint),
        ],
      ),
    );
  }

  Widget _linha(BuildContext context, {required String label, required String valor}) {
    final textos = context.sivTextos;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: textos.rotulo),
              SelectableText(valor, style: textos.codigo),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 18),
          tooltip: 'Copiar',
          onPressed: () => _copiar(context, valor, label),
        ),
      ],
    );
  }
}

class _EcommerceBannersBloco extends StatelessWidget {
  final int ecommerceId;

  const _EcommerceBannersBloco({required this.ecommerceId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<EcommerceBannersBloc>(
      create: (_) => sl<EcommerceBannersBloc>()
        ..add(EcommerceBannersIniciou(ecommerceId: ecommerceId)),
      child: const _EcommerceBannersCard(),
    );
  }
}

class _EcommerceBannersCard extends StatelessWidget {
  const _EcommerceBannersCard();

  Future<void> _adicionar(BuildContext context) async {
    final bloc = context.read<EcommerceBannersBloc>();
    final arquivo = await sl<ArquivoService>().selecionarArquivoComBytes(
      extensoes: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'mp4', 'mov', 'webm'],
    );
    if (arquivo == null) return;
    if (arquivo.tamanho > 20 * 1024 * 1024) {
      if (!context.mounted) return;
      SivAviso.mostrar(
        context,
        mensagem: 'Arquivo maior que 20MB — escolha um menor.',
        tipo: SivAvisoTipo.atencao,
      );
      return;
    }
    bloc.add(EcommerceBannerAdicionou(bytes: arquivo.bytes, nomeArquivo: arquivo.nome));
  }

  Future<void> _excluir(BuildContext context, int id) async {
    await SivDialogo.mostrar(
      context,
      titulo: 'Remover este banner do site?',
      variante: SivDialogoVariante.destrutivo,
      corpo: const Text('O arquivo enviado será apagado. Essa ação não pode ser desfeita.'),
      textoAcao: 'Remover',
      onConfirmar: (_) =>
          context.read<EcommerceBannersBloc>().add(EcommerceBannerExcluiu(id: id)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textos = context.sivTextos;
    final cores = context.sivColors;

    return SivCard(
      child: BlocBuilder<EcommerceBannersBloc, EcommerceBannersState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Banners do site', style: textos.rotulo),
                  OutlinedButton.icon(
                    onPressed: state.enviando ? null : () => _adicionar(context),
                    icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                    label: const Text('Adicionar banner'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('Arraste pra reordenar', style: textos.apoio),
              if (state.enviando) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(value: state.progressoEnvio, color: cores.aco),
              ],
              const SizedBox(height: 12),
              if (state.step == EcommerceBannersStep.carregando)
                const Center(child: CircularProgressIndicator.adaptive())
              else if (state.banners.isEmpty)
                Text('Nenhum banner cadastrado.', style: textos.apoio)
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (var i = 0; i < state.banners.length; i++)
                      _CardBanner(
                        banner: state.banners[i],
                        podeSubir: i > 0,
                        podeDescer: i < state.banners.length - 1,
                        onExcluir: () => _excluir(context, state.banners[i].id),
                      ),
                  ],
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CardBanner extends StatelessWidget {
  final EcommerceBanner banner;
  final bool podeSubir;
  final bool podeDescer;
  final VoidCallback onExcluir;

  const _CardBanner({
    required this.banner,
    required this.podeSubir,
    required this.podeDescer,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final bloc = context.read<EcommerceBannersBloc>();

    return Container(
      width: 200,
      decoration: BoxDecoration(
        border: Border.all(color: cores.hairline),
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: banner.type == EcommerceBannerTipo.video
                    ? Container(
                        color: cores.superficieRecuada,
                        child: Icon(Icons.videocam_outlined, color: cores.textoApoio),
                      )
                    : Image.network(
                        banner.url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: cores.superficieRecuada,
                          child: Icon(Icons.image_not_supported_outlined, color: cores.textoApoio),
                        ),
                      ),
              ),
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: cores.acoEscuro,
                    borderRadius: BorderRadius.circular(SivDimensoes.raio),
                  ),
                  child: Text(
                    banner.type == EcommerceBannerTipo.video ? 'VÍDEO' : 'IMAGEM',
                    style: textos.rotulo.copyWith(color: cores.textoSobreEscuroTitulo, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Switch(
                  value: banner.ativo,
                  onChanged: (ativo) => bloc.add(
                    EcommerceBannerAtivoAlterou(id: banner.id, ativo: ativo),
                  ),
                ),
                IconButton(
                  tooltip: 'Mover para cima',
                  icon: const Icon(Icons.arrow_upward, size: 18),
                  onPressed: podeSubir
                      ? () => bloc.add(EcommerceBannerMoveu(id: banner.id, paraCima: true))
                      : null,
                ),
                IconButton(
                  tooltip: 'Mover para baixo',
                  icon: const Icon(Icons.arrow_downward, size: 18),
                  onPressed: podeDescer
                      ? () => bloc.add(EcommerceBannerMoveu(id: banner.id, paraCima: false))
                      : null,
                ),
                IconButton(
                  tooltip: 'Remover',
                  icon: Icon(Icons.delete_outline, size: 18, color: cores.vinho),
                  onPressed: onExcluir,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
