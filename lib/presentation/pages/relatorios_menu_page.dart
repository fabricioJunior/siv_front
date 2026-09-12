import 'package:core/hive_anotacoes.dart';
import 'package:core/injecoes.dart';
import 'package:core/local_data_sourcers/database_configs/i_hive_database_instance.dart';
import 'package:core/local_data_sourcers/hive/storage_entity_adapter.dart';
import 'package:core/presentation.dart';
import 'package:core/sessao.dart';
import 'package:core/tema.dart';
import 'package:flutter/material.dart';

/// Largura mínima pro layout de grade em 2 colunas (9a). Abaixo disso, lista
/// em seções (9b) -- ver [RelatoriosMenuPage].
const _larguraLayoutGrade = 1000.0;

/// Domínios em que os relatórios são agrupados na tela. Ordem define a
/// leitura em grade (2x2, preenchida por linha: vendas|clientes /
/// estoque|caixaFiscal) e a ordem das seções na lista mobile.
enum GrupoRelatorio { vendas, clientes, estoque, caixaFiscal }

class _GrupoInfo {
  final String rotulo9a;
  final String pergunta9b;
  const _GrupoInfo(this.rotulo9a, this.pergunta9b);
}

const _infoPorGrupo = {
  GrupoRelatorio.vendas: _GrupoInfo('VENDAS E FATURAMENTO', 'Quanto vendemos?'),
  GrupoRelatorio.clientes: _GrupoInfo('CLIENTES', 'Quem compra da gente?'),
  GrupoRelatorio.estoque: _GrupoInfo('ESTOQUE E PRODUTOS', 'O que saiu do estoque?'),
  GrupoRelatorio.caixaFiscal: _GrupoInfo('CAIXA E FISCAL', 'O caixa e o fisco fecham?'),
};

/// DTO Hive dos relatórios fixados pelo usuário -- única persistência nova
/// desta tela (item "Fixados por você"). Segue o padrão manual
/// `StorageEntity`/`fromStorage` de `lib/hive_storage_types.dart`, sem
/// codegen. Chave = id do usuário (preferência é por pessoa, não por
/// empresa/terminal).
class RelatoriosMenuPrefsHiveDto implements HiveDto, StorageEntity {
  final int usuarioId;
  final List<String> rotasFixadas;

  RelatoriosMenuPrefsHiveDto({
    required this.usuarioId,
    this.rotasFixadas = const [],
  });

  @override
  int get dataBaseId => usuarioId;

  @override
  Map<String, dynamic> get storageProperties => {
    'usuarioId': usuarioId,
    'rotasFixadas': rotasFixadas,
  };

  static RelatoriosMenuPrefsHiveDto fromStorage(Map<String, dynamic> props) {
    return RelatoriosMenuPrefsHiveDto(
      usuarioId: props['usuarioId'] as int,
      rotasFixadas:
          (props['rotasFixadas'] as List?)?.cast<String>() ?? const [],
    );
  }
}

Future<Box<RelatoriosMenuPrefsHiveDto>> _getRelatoriosMenuPrefsBox() {
  return sl<IHiveDatabaseInstance>().getBox<RelatoriosMenuPrefsHiveDto>(
    boxKey: 'RelatoriosMenuPrefsHiveDto',
    adapters: [
      StorageEntityAdapter<RelatoriosMenuPrefsHiveDto>(
        RelatoriosMenuPrefsHiveDto.fromStorage,
      ),
    ],
    isCommonData: true,
  );
}

// Acentos não deveriam importar na busca ("caixa" == "caixa" mesmo digitando
// "cáixa"). Mesma tabela usada em generic_seletor.dart -- duplicada aqui por
// ser privada lá; candidata a virar util de `core` se aparecer um 3º uso.
const _comAcento = 'àáâãäåèéêëìíîïòóôõöùúûüçñÀÁÂÃÄÅÈÉÊËÌÍÎÏÒÓÔÕÖÙÚÛÜÇÑ';
const _semAcento = 'aaaaaaeeeeiiiiooooouuuucnAAAAAAEEEEIIIIOOOOOUUUUCN';

String _normalizarBusca(String texto) {
  final buffer = StringBuffer();
  for (final codeUnit in texto.toLowerCase().runes) {
    final char = String.fromCharCode(codeUnit);
    final indice = _comAcento.indexOf(char);
    buffer.write(indice >= 0 ? _semAcento[indice] : char);
  }
  return buffer.toString();
}

class _ItemData {
  final IconData icon;
  final String titulo;
  final String subtitulo;
  final GrupoRelatorio grupo;
  final String componente;
  final String route;

  const _ItemData({
    required this.icon,
    required this.titulo,
    required this.subtitulo,
    required this.grupo,
    required this.componente,
    required this.route,
  });

  bool correspondeA(String termoNormalizado) {
    return _normalizarBusca(titulo).contains(termoNormalizado) ||
        _normalizarBusca(subtitulo).contains(termoNormalizado);
  }
}

const _todosOsRelatorios = <_ItemData>[
  _ItemData(
    icon: Icons.trending_up,
    titulo: 'Faturamento e Ticket',
    subtitulo: 'Consolidado de vendas, ticket médio e por vendedor.',
    grupo: GrupoRelatorio.vendas,
    componente: 'RELFC001',
    route: '/relatorio_faturamento',
  ),
  _ItemData(
    icon: Icons.badge_outlined,
    titulo: 'Vendas por Funcionário',
    subtitulo: 'Vendas de funcionários selecionados em um período.',
    grupo: GrupoRelatorio.vendas,
    componente: 'RELFC004',
    route: '/relatorio_vendas_por_funcionario',
  ),
  _ItemData(
    icon: Icons.leaderboard_outlined,
    titulo: 'Curva ABC',
    subtitulo: 'Classificação de produtos por participação no faturamento.',
    grupo: GrupoRelatorio.vendas,
    componente: 'RELFC002',
    route: '/relatorio_curva_abc',
  ),
  _ItemData(
    icon: Icons.people_outline,
    titulo: 'Clientes Ativos',
    subtitulo: 'Clientes com compra recente no período selecionado.',
    grupo: GrupoRelatorio.clientes,
    componente: 'RELFC003',
    route: '/relatorio_clientes_ativos',
  ),
  _ItemData(
    icon: Icons.shopping_bag_outlined,
    titulo: 'Compras de Clientes',
    subtitulo: 'Clientes vs. categoria, referência ou produto comprado.',
    grupo: GrupoRelatorio.clientes,
    componente: 'RELFC007',
    route: '/relatorio_compras_clientes',
  ),
  _ItemData(
    icon: Icons.stars_outlined,
    titulo: 'Pontos de Fidelidade',
    subtitulo: 'Saldo, último crédito e cadastro no portal.',
    grupo: GrupoRelatorio.clientes,
    componente: 'RELFC006',
    route: '/relatorio_pontos_fidelidade',
  ),
  _ItemData(
    icon: Icons.cake_outlined,
    titulo: 'Aniversariantes',
    subtitulo: 'Clientes que fazem aniversário no mês.',
    grupo: GrupoRelatorio.clientes,
    componente: 'RELFC009',
    route: '/relatorio_clientes_aniversariantes',
  ),
  _ItemData(
    icon: Icons.trending_down_outlined,
    titulo: 'Produtos Defasados',
    subtitulo: 'Produtos ou referências sem movimentação recente.',
    grupo: GrupoRelatorio.estoque,
    componente: 'RELFC008',
    route: '/relatorio_produtos_defasados',
  ),
  _ItemData(
    icon: Icons.history,
    titulo: 'Histórico de Caixas',
    subtitulo: 'Caixas abertos, em contagem e fechados por período.',
    grupo: GrupoRelatorio.caixaFiscal,
    componente: 'FCXFP008',
    route: '/historico_de_caixas',
  ),
  _ItemData(
    icon: Icons.receipt_long_outlined,
    titulo: 'Fiscal',
    subtitulo: 'Saldo e movimentação de notas fiscais emitidas.',
    grupo: GrupoRelatorio.caixaFiscal,
    componente: 'FISFM001',
    route: '/relatorio_fiscal',
  ),
];

class RelatoriosMenuPage extends StatefulWidget {
  const RelatoriosMenuPage({super.key});

  @override
  State<RelatoriosMenuPage> createState() => _RelatoriosMenuPageState();
}

class _RelatoriosMenuPageState extends State<RelatoriosMenuPage> {
  final _buscaController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 250);
  String _termoBusca = '';
  Set<String> _fixados = {};

  int? get _usuarioId => sl<IAcessoGlobalSessao>().usuarioIdDaSessao;

  @override
  void initState() {
    super.initState();
    _carregarFixados();
  }

  @override
  void dispose() {
    _debouncer.cancel();
    _buscaController.dispose();
    super.dispose();
  }

  Future<void> _carregarFixados() async {
    final usuarioId = _usuarioId;
    if (usuarioId == null) return;
    final box = await _getRelatoriosMenuPrefsBox();
    final dto = box.get(usuarioId);
    if (dto == null || !mounted) return;
    setState(() => _fixados = dto.rotasFixadas.toSet());
  }

  Future<void> _salvarFixados() async {
    final usuarioId = _usuarioId;
    if (usuarioId == null) return;
    final box = await _getRelatoriosMenuPrefsBox();
    await box.put(
      usuarioId,
      RelatoriosMenuPrefsHiveDto(
        usuarioId: usuarioId,
        rotasFixadas: _fixados.toList(),
      ),
    );
  }

  // ponytail: sem feedback quando já há 3 fixados -- ação é simplesmente
  // ignorada. Se virar dúvida recorrente do usuário, trocar por substituição
  // do mais antigo ou um aviso.
  void _alternarFixado(String route) {
    setState(() {
      if (_fixados.contains(route)) {
        _fixados.remove(route);
      } else if (_fixados.length < 3) {
        _fixados.add(route);
      }
    });
    _salvarFixados();
  }

  @override
  Widget build(BuildContext context) {
    final permitidos = _todosOsRelatorios
        .where((item) => PermissaoPorNome.acessoPermitido(item.componente))
        .toList();

    if (permitidos.isEmpty) {
      return const _SemAcesso();
    }

    final termoNormalizado = _normalizarBusca(_termoBusca.trim());
    final itensFiltrados = termoNormalizado.isEmpty
        ? permitidos
        : permitidos.where((item) => item.correspondeA(termoNormalizado)).toList();

    final grupos = {
      for (final grupo in GrupoRelatorio.values)
        grupo: itensFiltrados.where((item) => item.grupo == grupo).toList(),
    }..removeWhere((_, itens) => itens.isEmpty);

    final fixados = permitidos.where((item) => _fixados.contains(item.route)).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= _larguraLayoutGrade) {
          return _LayoutDesktop(
            totalPermitidos: permitidos.length,
            grupos: grupos,
            fixados: fixados,
            fixadosIds: _fixados,
            buscaController: _buscaController,
            onBuscaChanged: _onBuscaChanged,
            onAlternarFixado: _alternarFixado,
            semResultado: itensFiltrados.isEmpty,
          );
        }
        return _LayoutMobile(
          totalPermitidos: permitidos.length,
          grupos: grupos,
          buscaController: _buscaController,
          onBuscaChanged: _onBuscaChanged,
          semResultado: itensFiltrados.isEmpty,
        );
      },
    );
  }

  void _onBuscaChanged(String valor) {
    _debouncer.run(() {
      if (mounted) setState(() => _termoBusca = valor);
    });
  }
}

class _SemAcesso extends StatelessWidget {
  const _SemAcesso();

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: cores.textoApoio),
            const SizedBox(height: 12),
            Text(
              'Sem acesso',
              style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              'Você não possui permissão para acessar nenhum relatório.',
              textAlign: TextAlign.center,
              style: textos.apoio.copyWith(color: cores.textoApoio),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoBusca extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _CampoBusca({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        hintText: 'Buscar relatório...',
        prefixIcon: Icon(Icons.search, size: 20),
        isDense: true,
      ),
    );
  }
}

class _LayoutDesktop extends StatelessWidget {
  final int totalPermitidos;
  final Map<GrupoRelatorio, List<_ItemData>> grupos;
  final List<_ItemData> fixados;
  final Set<String> fixadosIds;
  final TextEditingController buscaController;
  final ValueChanged<String> onBuscaChanged;
  final ValueChanged<String> onAlternarFixado;
  final bool semResultado;

  const _LayoutDesktop({
    required this.totalPermitidos,
    required this.grupos,
    required this.fixados,
    required this.fixadosIds,
    required this.buscaController,
    required this.onBuscaChanged,
    required this.onAlternarFixado,
    required this.semResultado,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final empresa = sl<IAcessoGlobalSessao>().empresaNomeDaSessao ?? '—';

    final colunaEsquerda = [GrupoRelatorio.vendas, GrupoRelatorio.estoque]
        .where(grupos.containsKey)
        .toList();
    final colunaDireita = [GrupoRelatorio.clientes, GrupoRelatorio.caixaFiscal]
        .where(grupos.containsKey)
        .toList();

    return ListView(
      padding: const EdgeInsets.all(SivDimensoes.paginaHorizontal),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Relatórios', style: textos.secao),
                  const SizedBox(height: 2),
                  Text(
                    '$totalPermitidos disponíveis para o seu perfil · $empresa',
                    style: textos.apoio.copyWith(color: cores.textoApoio),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 300,
              child: _CampoBusca(
                controller: buscaController,
                onChanged: onBuscaChanged,
              ),
            ),
          ],
        ),
        if (fixados.isNotEmpty) ...[
          const SizedBox(height: SivDimensoes.gapCards * 1.5),
          _FaixaFixados(itens: fixados, onAlternarFixado: onAlternarFixado),
        ],
        const SizedBox(height: SivDimensoes.gapCards * 1.5),
        if (semResultado)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Text(
              'Nenhum relatório com esse nome.',
              style: textos.corpo.copyWith(color: cores.textoApoio),
            ),
          )
        else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ColunaDeGrupos(
                  grupos: colunaEsquerda,
                  itensPorGrupo: grupos,
                  fixadosIds: fixadosIds,
                  onAlternarFixado: onAlternarFixado,
                ),
              ),
              const SizedBox(width: SivDimensoes.gapCards),
              Expanded(
                child: _ColunaDeGrupos(
                  grupos: colunaDireita,
                  itensPorGrupo: grupos,
                  fixadosIds: fixadosIds,
                  onAlternarFixado: onAlternarFixado,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ColunaDeGrupos extends StatelessWidget {
  final List<GrupoRelatorio> grupos;
  final Map<GrupoRelatorio, List<_ItemData>> itensPorGrupo;
  final Set<String> fixadosIds;
  final ValueChanged<String> onAlternarFixado;

  const _ColunaDeGrupos({
    required this.grupos,
    required this.itensPorGrupo,
    required this.fixadosIds,
    required this.onAlternarFixado,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final grupo in grupos) ...[
          _CabecalhoGrupo(grupo: grupo, quantidade: itensPorGrupo[grupo]!.length),
          const SizedBox(height: 10),
          for (final item in itensPorGrupo[grupo]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CardRelatorio(
                item: item,
                fixado: fixadosIds.contains(item.route),
                onAlternarFixado: () => onAlternarFixado(item.route),
              ),
            ),
          const SizedBox(height: SivDimensoes.gapCards),
        ],
      ],
    );
  }
}

class _CabecalhoGrupo extends StatelessWidget {
  final GrupoRelatorio grupo;
  final int quantidade;

  const _CabecalhoGrupo({required this.grupo, required this.quantidade});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final info = _infoPorGrupo[grupo]!;

    return Row(
      children: [
        Text(
          info.rotulo9a,
          style: textos.rotulo.copyWith(color: cores.acoAtivo, letterSpacing: 1.4),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: cores.hairline, height: 1)),
        const SizedBox(width: 10),
        Text('$quantidade', style: textos.apoio.copyWith(color: cores.textoApoio)),
      ],
    );
  }
}

class _FaixaFixados extends StatelessWidget {
  final List<_ItemData> itens;
  final ValueChanged<String> onAlternarFixado;

  const _FaixaFixados({required this.itens, required this.onAlternarFixado});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FIXADOS POR VOCÊ',
          style: textos.rotulo.copyWith(color: cores.acoAtivo, letterSpacing: 1.4),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < itens.length; i++) ...[
              if (i > 0) const SizedBox(width: SivDimensoes.gapCards),
              Expanded(child: _CardFixado(item: itens[i], onDesafixar: () => onAlternarFixado(itens[i].route))),
            ],
          ],
        ),
      ],
    );
  }
}

class _CardFixado extends StatelessWidget {
  final _ItemData item;
  final VoidCallback onDesafixar;

  const _CardFixado({required this.item, required this.onDesafixar});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return Material(
      color: cores.acoEscuro,
      borderRadius: BorderRadius.circular(SivDimensoes.raio),
      child: InkWell(
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        onTap: () => Navigator.of(context).pushNamed(item.route),
        child: Container(
          constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(item.icon, color: cores.textoSobreEscuroApoio, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.titulo,
                  style: textos.corpo.copyWith(
                    color: cores.textoSobreEscuroTitulo,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Semantics(
                label: 'Desafixar relatório',
                child: IconButton(
                  icon: Icon(Icons.push_pin, size: 16, color: cores.textoSobreEscuroApoio),
                  onPressed: onDesafixar,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardRelatorio extends StatefulWidget {
  final _ItemData item;
  final bool fixado;
  final VoidCallback onAlternarFixado;

  const _CardRelatorio({
    required this.item,
    required this.fixado,
    required this.onAlternarFixado,
  });

  @override
  State<_CardRelatorio> createState() => _CardRelatorioState();
}

class _CardRelatorioState extends State<_CardRelatorio> {
  bool _emHover = false;
  bool _focado = false;

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return MouseRegion(
      onEnter: (_) => setState(() => _emHover = true),
      onExit: (_) => setState(() => _emHover = false),
      child: Material(
        color: cores.superficie,
        borderRadius: BorderRadius.circular(SivDimensoes.raio),
        child: InkWell(
          borderRadius: BorderRadius.circular(SivDimensoes.raio),
          onTap: () => Navigator.of(context).pushNamed(widget.item.route),
          onFocusChange: (focado) => setState(() => _focado = focado),
          child: Container(
            constraints: const BoxConstraints(minHeight: SivDimensoes.alvoToqueMinimo),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SivDimensoes.raio),
              border: Border.all(
                color: _focado ? cores.aco : cores.hairline,
                width: _focado ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(widget.item.icon, color: cores.aco, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.item.titulo,
                        style: textos.corpo.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.subtitulo,
                        style: textos.apoio.copyWith(
                          fontSize: 12,
                          color: cores.textoPrincipal.withValues(alpha: 0.55),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (_emHover || widget.fixado)
                  Semantics(
                    label: widget.fixado ? 'Desafixar relatório' : 'Fixar relatório',
                    child: IconButton(
                      icon: Icon(
                        widget.fixado ? Icons.push_pin : Icons.push_pin_outlined,
                        size: 16,
                        color: cores.aco,
                      ),
                      onPressed: widget.onAlternarFixado,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                const SizedBox(width: 8),
                Text(
                  widget.item.componente,
                  style: textos.codigo.copyWith(
                    fontSize: 11,
                    color: cores.textoPrincipal.withValues(alpha: 0.35),
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

class _LayoutMobile extends StatelessWidget {
  final int totalPermitidos;
  final Map<GrupoRelatorio, List<_ItemData>> grupos;
  final TextEditingController buscaController;
  final ValueChanged<String> onBuscaChanged;
  final bool semResultado;

  const _LayoutMobile({
    required this.totalPermitidos,
    required this.grupos,
    required this.buscaController,
    required this.onBuscaChanged,
    required this.semResultado,
  });

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Container(
          width: double.infinity,
          color: cores.acoEscuro,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Relatórios',
                style: textos.secao.copyWith(color: cores.textoSobreEscuroTitulo),
              ),
              const SizedBox(height: 2),
              Text(
                '$totalPermitidos disponíveis para o seu perfil',
                style: textos.apoio.copyWith(color: cores.textoSobreEscuroApoio),
              ),
              const SizedBox(height: 14),
              _CampoBusca(controller: buscaController, onChanged: onBuscaChanged),
            ],
          ),
        ),
        if (semResultado)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Nenhum relatório com esse nome.',
              style: textos.corpo.copyWith(color: cores.textoApoio),
            ),
          )
        else
          for (final grupo in GrupoRelatorio.values)
            if (grupos.containsKey(grupo))
              _SecaoMobile(grupo: grupo, itens: grupos[grupo]!),
      ],
    );
  }
}

class _SecaoMobile extends StatelessWidget {
  final GrupoRelatorio grupo;
  final List<_ItemData> itens;

  const _SecaoMobile({required this.grupo, required this.itens});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;
    final info = _infoPorGrupo[grupo]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: cores.papel,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  info.pergunta9b,
                  style: textos.corpo.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text('${itens.length}', style: textos.apoio.copyWith(color: cores.textoApoio)),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: cores.hairline),
              bottom: BorderSide(color: cores.hairline),
            ),
          ),
          child: Column(
            children: [
              for (var i = 0; i < itens.length; i++) ...[
                if (i > 0) Divider(height: 1, color: cores.hairline),
                _LinhaMobile(item: itens[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _LinhaMobile extends StatelessWidget {
  final _ItemData item;

  const _LinhaMobile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cores = context.sivColors;
    final textos = context.sivTextos;

    return InkWell(
      onTap: () => Navigator.of(context).pushNamed(item.route),
      child: Container(
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        color: cores.superficie,
        child: Row(
          children: [
            Icon(item.icon, color: cores.aco, size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.titulo,
                    style: textos.corpo.copyWith(fontSize: 16.5, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitulo,
                    style: textos.apoio.copyWith(fontSize: 12, color: cores.textoApoio),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cores.textoApoio, size: 20),
          ],
        ),
      ),
    );
  }
}
