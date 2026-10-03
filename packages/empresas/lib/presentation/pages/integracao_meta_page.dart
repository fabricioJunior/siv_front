import 'package:core/bloc.dart';
import 'package:core/injecoes.dart';
import 'package:core/presentation.dart';
import 'package:core/tema.dart';
import 'package:empresas/domain/entities/integracao_meta.dart';
import 'package:empresas/presentation/blocs/integracao_meta_bloc/integracao_meta_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IntegracaoMetaPage extends StatelessWidget {
  final int idEmpresa;

  const IntegracaoMetaPage({super.key, required this.idEmpresa});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<IntegracaoMetaBloc>(
      create: (_) =>
          sl<IntegracaoMetaBloc>()..add(IntegracaoMetaIniciou(idEmpresa)),
      child: const _IntegracaoMetaView(),
    );
  }
}

class _IntegracaoMetaView extends StatefulWidget {
  const _IntegracaoMetaView();

  @override
  State<_IntegracaoMetaView> createState() => _IntegracaoMetaViewState();
}

class _IntegracaoMetaViewState extends State<_IntegracaoMetaView> {
  final _formKey = GlobalKey<FormState>();
  final _versao = TextEditingController();
  final _graphUrl = TextEditingController();
  final _token = TextEditingController();
  final _business = TextEditingController();
  final _catalogo = TextEditingController();
  final _pixel = TextEditingController();
  final _ecommerce = TextEditingController();
  final _urlSite = TextEditingController();
  final _marca = TextEditingController();
  final _moeda = TextEditingController();
  final _capiToken = TextEditingController();
  final _capiCodigoTeste = TextEditingController();
  final _capiTentativas = TextEditingController();
  final _intervalo = TextEditingController();
  final _lote = TextEditingController();
  final _timeout = TextEditingController();
  final _tentativasApi = TextEditingController();

  bool _syncAuto = false;
  bool _validarImagens = false;
  bool _capiHabilitada = false;
  bool _removerToken = false;
  bool _removerCapiToken = false;
  bool _sujo = false;

  List<TextEditingController> get _controllers => [
    _versao,
    _graphUrl,
    _token,
    _business,
    _catalogo,
    _pixel,
    _ecommerce,
    _urlSite,
    _marca,
    _moeda,
    _capiToken,
    _capiCodigoTeste,
    _capiTentativas,
    _intervalo,
    _lote,
    _timeout,
    _tentativasApi,
  ];

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _preencher(IntegracaoMeta c) {
    _versao.text = c.versaoGraphApi;
    _graphUrl.text = c.graphApiUrl;
    _business.text = c.businessId;
    _catalogo.text = c.catalogoId;
    _pixel.text = c.pixelId;
    _ecommerce.text = c.ecommerceId.toString();
    _urlSite.text = c.urlSite;
    _marca.text = c.marcaPadrao;
    _moeda.text = c.moeda;
    _capiCodigoTeste.text = c.capiCodigoTeste;
    _capiTentativas.text = c.capiMaxTentativas.toString();
    _intervalo.text = c.syncIntervaloMinutos.toString();
    _lote.text = c.syncTamanhoLote.toString();
    _timeout.text = c.timeoutMs.toString();
    _tentativasApi.text = c.maxTentativasApi.toString();
    _token.clear();
    _capiToken.clear();
    _syncAuto = c.syncAutoHabilitada;
    _validarImagens = c.validarImagens;
    _capiHabilitada = c.capiHabilitada;
    _removerToken = false;
    _removerCapiToken = false;
    _sujo = false;
  }

  void _alterou(VoidCallback fn) => setState(() {
    fn();
    _sujo = true;
  });

  int? _int(TextEditingController c) => int.tryParse(c.text.trim());

  IntegracaoMetaAlteracoes _montar() => IntegracaoMetaAlteracoes(
    versaoGraphApi: _versao.text.trim(),
    graphApiUrl: _graphUrl.text.trim(),
    accessToken: _token.text.trim(),
    removerAccessToken: _removerToken,
    capiAccessToken: _capiToken.text.trim(),
    removerCapiAccessToken: _removerCapiToken,
    businessId: _business.text.trim(),
    catalogoId: _catalogo.text.trim(),
    pixelId: _pixel.text.trim(),
    ecommerceId: _int(_ecommerce) ?? 0,
    urlSite: _urlSite.text.trim(),
    marcaPadrao: _marca.text.trim(),
    moeda: _moeda.text.trim().toUpperCase(),
    capiHabilitada: _capiHabilitada,
    capiCodigoTeste: _capiCodigoTeste.text.trim(),
    capiMaxTentativas: _int(_capiTentativas),
    syncAutoHabilitada: _syncAuto,
    syncIntervaloMinutos: _int(_intervalo),
    syncTamanhoLote: _int(_lote),
    validarImagens: _validarImagens,
    timeoutMs: _int(_timeout),
    maxTentativasApi: _int(_tentativasApi),
  );

  void _salvar({bool testarDepois = false}) {
    if (!_formKey.currentState!.validate()) return;
    context.read<IntegracaoMetaBloc>().add(
      IntegracaoMetaSalvar(_montar(), testarDepois: testarDepois),
    );
  }

  Future<void> _testar() async {
    final bloc = context.read<IntegracaoMetaBloc>();
    if (!_sujo) {
      bloc.add(IntegracaoMetaTestar());
      return;
    }
    final salvarAntes = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Alterações não salvas'),
        content: const Text(
          'O teste usa a configuração salva. Deseja salvar antes de testar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Testar o salvo'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Salvar e testar'),
          ),
        ],
      ),
    );
    if (salvarAntes == null || !mounted) return;
    if (salvarAntes) {
      _salvar(testarDepois: true);
    } else {
      bloc.add(IntegracaoMetaTestar());
    }
  }

  String? _opcional(String? v, bool Function(String) ok, String msg) {
    final t = v?.trim() ?? '';
    return t.isEmpty || ok(t) ? null : msg;
  }

  String? _idMeta(String? v) => _opcional(
    v,
    (t) => RegExp(r'^\d{5,20}$').hasMatch(t),
    'De 5 a 20 dígitos',
  );

  String? _faixa(String? v, int min, int max) => _opcional(v, (t) {
    final n = int.tryParse(t);
    return n != null && n >= min && n <= max;
  }, 'Informe de $min a $max');

  String? _url(String? v) => _opcional(v, (t) {
    final u = Uri.tryParse(t);
    return u != null &&
        u.hasAuthority &&
        (u.scheme == 'http' || u.scheme == 'https');
  }, 'URL inválida (http:// ou https://)');

  @override
  Widget build(BuildContext context) {
    return BlocListener<IntegracaoMetaBloc, IntegracaoMetaState>(
      listenWhen: (p, c) =>
          p.configuracao != c.configuracao ||
          p.salvou != c.salvou ||
          p.erro != c.erro,
      listener: (context, state) {
        final c = state.configuracao;
        if (c != null) setState(() => _preencher(c));
        if (state.salvou) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Configuração salva com sucesso.')),
          );
        }
        if (state.erro != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.erro!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Integração Meta')),
        body: BlocBuilder<IntegracaoMetaBloc, IntegracaoMetaState>(
          builder: (context, state) {
            final config = state.configuracao;
            if (state.carregando || config == null) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            final ocupado = state.salvando || state.testando;
            return SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _conexao(config),
                            const SizedBox(height: 16),
                            _catalogoCard(config),
                            const SizedBox(height: 16),
                            _conversoes(config),
                            const SizedBox(height: 16),
                            _avancado(),
                            const SizedBox(height: 16),
                            if (state.teste != null) ...[
                              _resultadoTeste(state.teste!),
                              const SizedBox(height: 16),
                            ],
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                FilledButton.icon(
                                  onPressed: ocupado ? null : _salvar,
                                  icon: state.salvando
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.save),
                                  label: const Text('Salvar'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: ocupado ? null : _testar,
                                  icon: state.testando
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.wifi_tethering),
                                  label: const Text('Testar conexão'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _card(String titulo, List<Widget> filhos) => SivCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titulo, style: context.sivTextos.secao),
        const SizedBox(height: 16),
        ...filhos,
      ],
    ),
  );

  /// Dois campos por linha em telas largas, um por linha no mobile.
  Widget _campos(List<Widget> filhos) => LayoutBuilder(
    builder: (context, c) {
      final largura = c.maxWidth >= 560 ? (c.maxWidth - 12) / 2 : c.maxWidth;
      return Wrap(
        spacing: 12,
        runSpacing: 16,
        children: [for (final f in filhos) SizedBox(width: largura, child: f)],
      );
    },
  );

  Widget _texto(
    TextEditingController c,
    String label, {
    String? ajuda,
    String? Function(String?)? validator,
    bool numerico = false,
    int? maxLength,
  }) => TextFormField(
    controller: c,
    validator: validator,
    maxLength: maxLength,
    keyboardType: numerico ? TextInputType.number : null,
    inputFormatters: numerico ? [FilteringTextInputFormatter.digitsOnly] : null,
    decoration: InputDecoration(
      labelText: label,
      helperText: ajuda,
      helperMaxLines: 3,
      counterText: '',
      border: const OutlineInputBorder(),
    ),
    onChanged: (_) => _alterou(() {}),
  );

  Widget _switch(String titulo, bool valor, ValueChanged<bool> onChanged) =>
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(titulo),
        value: valor,
        onChanged: (v) => _alterou(() => onChanged(v)),
      );

  /// Token write-only: vazio = não alterar; nunca exibe o valor salvo.
  Widget _segredo({
    required TextEditingController controller,
    required String label,
    required bool configurado,
    required bool remover,
    required void Function(bool) onRemover,
    required String ajuda,
    required String rotuloRemover,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      TextFormField(
        controller: controller,
        obscureText: true,
        enableSuggestions: false,
        autocorrect: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: configurado ? '•••• (não alterado)' : null,
          helperText: remover
              ? 'Será removido ao salvar.'
              : configurado
              ? 'Configurado. $ajuda'
              : ajuda,
          helperMaxLines: 3,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) => _alterou(() {
          if (v.isNotEmpty) onRemover(false);
        }),
      ),
      if (configurado || remover)
        TextButton.icon(
          onPressed: () => _alterou(() {
            onRemover(!remover);
            controller.clear();
          }),
          icon: Icon(remover ? Icons.undo : Icons.delete_outline, size: 18),
          label: Text(remover ? 'Cancelar remoção' : rotuloRemover),
        ),
    ],
  );

  Widget _pendencias(List<String> itens) => itens.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final i in itens)
                Chip(
                  avatar: const Icon(Icons.warning_amber_rounded, size: 18),
                  label: Text('Falta: $i'),
                ),
            ],
          ),
        );

  Widget _conexao(IntegracaoMeta c) => _card('Conexão com a Meta', [
    _campos([
      _texto(
        _versao,
        'Versão da Graph API',
        ajuda: 'Ex.: v21.0',
        validator: (v) => _opcional(
          v,
          (t) => RegExp(r'^v\d{2}\.\d$').hasMatch(t),
          'Formato vNN.N (ex.: v21.0)',
        ),
      ),
      _texto(
        _business,
        'ID do Business Manager',
        numerico: true,
        validator: _idMeta,
      ),
      _segredo(
        controller: _token,
        label: 'Token de acesso',
        configurado: c.accessTokenConfigurado,
        remover: _removerToken,
        onRemover: (v) => _removerToken = v,
        ajuda: 'Deixe vazio para não alterar.',
        rotuloRemover: 'Remover token',
      ),
    ]),
  ]);

  Widget _catalogoCard(IntegracaoMeta c) => _card('Catálogo', [
    _pendencias(c.pendenciasCatalogo),
    _campos([
      _texto(_catalogo, 'ID do catálogo', numerico: true, validator: _idMeta),
      _texto(
        _ecommerce,
        'E-commerce',
        numerico: true,
        ajuda: '0 ou vazio = primeiro da empresa',
        validator: (v) =>
            _opcional(v, (t) => int.tryParse(t) != null, 'Número inválido'),
      ),
      _texto(_marca, 'Marca padrão', maxLength: 100),
      _texto(
        _moeda,
        'Moeda',
        ajuda: 'Ex.: BRL',
        maxLength: 3,
        validator: (v) => _opcional(
          v,
          (t) => RegExp(r'^[A-Za-z]{3}$').hasMatch(t),
          'Use 3 letras',
        ),
      ),
      _texto(
        _urlSite,
        'URL do site',
        ajuda: 'Usada nos links dos produtos e como origem dos eventos.',
        validator: _url,
      ),
      _texto(
        _intervalo,
        'Intervalo de sincronização (min)',
        numerico: true,
        validator: (v) => _faixa(v, 5, 1440),
      ),
      _texto(
        _lote,
        'Tamanho do lote',
        numerico: true,
        validator: (v) => _faixa(v, 1, 3000),
      ),
    ]),
    _switch('Sincronização automática', _syncAuto, (v) => _syncAuto = v),
    _switch('Validar imagens', _validarImagens, (v) => _validarImagens = v),
  ]);

  Widget _conversoes(IntegracaoMeta c) => _card('Pixel e API de Conversões', [
    _pendencias(c.pendenciasConversoes),
    _campos([
      _texto(_pixel, 'ID do Pixel', numerico: true, validator: _idMeta),
      _texto(
        _capiTentativas,
        'Máx. tentativas (CAPI)',
        numerico: true,
        validator: (v) => _faixa(v, 1, 20),
      ),
      _segredo(
        controller: _capiToken,
        label: 'Token próprio da API de Conversões',
        configurado: c.capiAccessTokenProprioConfigurado,
        remover: _removerCapiToken,
        onRemover: (v) => _removerCapiToken = v,
        ajuda: 'Opcional. Vazio = usa o token de acesso.',
        rotuloRemover: 'Remover token próprio',
      ),
      _texto(
        _capiCodigoTeste,
        'Código de teste',
        ajuda: 'Só para testes na aba Testar eventos; deixe vazio em produção.',
      ),
    ]),
    _switch(
      'Enviar compras pelo servidor (API de Conversões)',
      _capiHabilitada,
      (v) => _capiHabilitada = v,
    ),
  ]);

  Widget _avancado() => SivCard(
    child: ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(top: 8),
      title: Text('Avançado', style: context.sivTextos.secao),
      children: [
        _campos([
          _texto(
            _graphUrl,
            'URL da Graph API',
            validator: (v) => _opcional(
              v,
              (t) => t.startsWith('https://') && _url(t) == null,
              'URL inválida (https://)',
            ),
          ),
          _texto(
            _timeout,
            'Timeout (ms)',
            numerico: true,
            validator: (v) => _faixa(v, 1000, 120000),
          ),
          _texto(
            _tentativasApi,
            'Tentativas da API',
            numerico: true,
            validator: (v) => _faixa(v, 0, 10),
          ),
        ]),
      ],
    ),
  );

  Widget _resultadoTeste(IntegracaoMetaTeste t) => _card('Resultado do teste', [
    _linhaTeste('Catálogo', t.catalogo),
    _linhaTeste('Pixel', t.pixel),
  ]);

  Widget _linhaTeste(String titulo, IntegracaoMetaTesteItem i) => ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Icon(
      i.ok ? Icons.check_circle : Icons.error,
      color: i.ok ? Colors.green : Theme.of(context).colorScheme.error,
    ),
    title: Text(
      i.nome == null || i.nome!.isEmpty ? titulo : '$titulo: ${i.nome}',
    ),
    subtitle: Text(
      [
        i.mensagem,
        if (i.detalhe != null && i.detalhe!.isNotEmpty) i.detalhe!,
      ].join(' - '),
    ),
  );
}
