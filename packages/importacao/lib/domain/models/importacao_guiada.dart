import 'package:core/equals.dart';
import 'package:core/sync.dart' show ImportacaoProgressoEvent;

// Espelha ImportacaoSituacao do backend (apps/api/.../importacao/enum).
enum ImportacaoSituacao {
  pendente,
  processando,
  concluida,
  falha,
  cancelada;

  static ImportacaoSituacao fromString(String? value) {
    final normalizado = value?.toLowerCase();
    return ImportacaoSituacao.values.firstWhere(
      (situacao) => situacao.name == normalizado,
      orElse: () => ImportacaoSituacao.pendente,
    );
  }

  bool get finalizada =>
      this == concluida || this == falha || this == cancelada;

  bool get emAndamento => !finalizada;
}

/// Etapas do assistente, na ordem em que precisam ser importadas: vendas
/// apontam para clientes (CPF) e produtos (código de barras), e o estoque
/// só grava saldo de produto que já existe.
enum ImportacaoEtapa {
  clientes(
    titulo: 'Clientes',
    descricao:
        'Cadastra os clientes pelo CPF. Vem primeiro porque as vendas '
        'apontam para eles pelo CPF.',
    tipoBackend: 'cliente',
    caminhoModelo: '/pessoas/template',
    caminhoEnvio: '/pessoas/csv',
    nomeModelo: 'modelo-clientes.csv',
    permissao: 'IMPFP006',
  ),
  produtos(
    titulo: 'Produtos',
    descricao:
        'Cadastra referências, preços e produtos (cor, tamanho e código de '
        'barras). O modelo tem uma linha de cada tipo: REFERENCIA, '
        'REFERENCIA_PRECO e PRODUTO.',
    tipoBackend: 'produto',
    caminhoModelo: '/produtos/template',
    caminhoEnvio: '/produtos/csv',
    nomeModelo: 'modelo-produtos.csv',
    permissao: 'IMPFP001',
  ),
  estoque(
    titulo: 'Estoque',
    descricao:
        'Grava o saldo de estoque da empresa por produto (ID externo ou '
        'código de barras). Só grava saldo de produto já cadastrado.',
    tipoBackend: 'estoque',
    caminhoModelo: '/estoque/template',
    caminhoEnvio: '/estoque',
    nomeModelo: 'modelo-estoque.csv',
    permissao: 'IMPFP009',
  ),
  vendas(
    titulo: 'Vendas',
    descricao:
        'Importa vendas já realizadas como romaneios encerrados (sem mexer '
        'em estoque, caixa ou nota fiscal). Os produtos são localizados pelo '
        'código de barras; CPF sem cadastro entra como "Cliente não '
        'cadastrado".',
    tipoBackend: 'vendaromaneio',
    caminhoModelo: '/vendas/template',
    caminhoEnvio: '/vendas',
    nomeModelo: 'modelo-vendas.csv',
    permissao: 'IMPFP008',
  );

  final String titulo;
  final String descricao;

  /// `tipo` da importação no backend, em minúsculas.
  final String tipoBackend;
  final String caminhoModelo;
  final String caminhoEnvio;
  final String nomeModelo;

  /// Componente de permissão exigido pelas rotas dessa etapa.
  final String permissao;

  const ImportacaoEtapa({
    required this.titulo,
    required this.descricao,
    required this.tipoBackend,
    required this.caminhoModelo,
    required this.caminhoEnvio,
    required this.nomeModelo,
    required this.permissao,
  });

  /// Quem tem QUALQUER uma dessas permissões enxerga o assistente (cada etapa
  /// continua exigindo a sua).
  static List<String> get todasPermissoes => [
    for (final etapa in values) etapa.permissao,
  ];

  static ImportacaoEtapa? deTipo(String tipo) {
    final normalizado = tipo.toLowerCase();
    for (final etapa in values) {
      if (etapa.tipoBackend == normalizado) return etapa;
    }
    return null;
  }

  ImportacaoEtapa? get anterior => index == 0 ? null : values[index - 1];
}

/// Registro do CSV que não foi importado, com o motivo.
class ImportacaoProblema extends Equatable {
  final String titulo;
  final String motivo;
  final String? conteudo;

  const ImportacaoProblema({
    required this.titulo,
    required this.motivo,
    this.conteudo,
  });

  /// Cada importador devolve o seu formato: por linha (`linha`) ou por venda
  /// (`numeroVendaExterno`).
  factory ImportacaoProblema.fromJson(Map<String, dynamic> json) {
    final linha = json['linha'];
    final venda = json['numeroVendaExterno'];
    return ImportacaoProblema(
      titulo: linha != null
          ? 'Linha $linha'
          : venda != null
          ? 'Venda $venda'
          : 'Registro',
      motivo: json['motivo'] as String? ?? '',
      conteudo: json['conteudo'] as String?,
    );
  }

  @override
  List<Object?> get props => [titulo, motivo, conteudo];
}

/// Espelha ImportacaoEntity do backend. `problemas` e `avisos` só vêm na
/// consulta por id (o resultado detalhado não vai na listagem nem no
/// evento de andamento).
class ImportacaoGuiada extends Equatable {
  final int id;
  final String tipo;
  final ImportacaoSituacao situacao;
  final int totalRegistros;
  final int processados;
  final int importados;
  final int rejeitados;
  final String? erro;
  final List<ImportacaoProblema> problemas;
  final List<String> avisos;

  const ImportacaoGuiada({
    required this.id,
    required this.tipo,
    required this.situacao,
    this.totalRegistros = 0,
    this.processados = 0,
    this.importados = 0,
    this.rejeitados = 0,
    this.erro,
    this.problemas = const [],
    this.avisos = const [],
  });

  factory ImportacaoGuiada.fromJson(Map<String, dynamic> json) {
    int numero(String chave) => (json[chave] as num?)?.toInt() ?? 0;
    final resultado = json['resultado'] as Map<String, dynamic>?;
    final semCliente =
        (resultado?['semClienteCadastrado'] as num?)?.toInt() ?? 0;
    return ImportacaoGuiada(
      id: numero('id'),
      tipo: (json['tipo'] as String? ?? '').toLowerCase(),
      situacao: ImportacaoSituacao.fromString(json['situacao'] as String?),
      totalRegistros: numero('totalRegistros'),
      processados: numero('processados'),
      importados: numero('importados'),
      rejeitados: numero('rejeitados'),
      erro: json['erro'] as String?,
      problemas: (resultado?['rejeitados'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ImportacaoProblema.fromJson)
          .toList(growable: false),
      avisos: [
        if (semCliente > 0)
          '$semCliente venda(s) com CPF sem cadastro foram lançadas como '
              '"Cliente não cadastrado" (o CPF ficou na observação do romaneio).',
      ],
    );
  }

  /// Atualiza só o andamento (o evento não traz o detalhe das rejeições).
  ImportacaoGuiada comProgresso(ImportacaoProgressoEvent evento) {
    return ImportacaoGuiada(
      id: id,
      tipo: tipo,
      situacao: ImportacaoSituacao.fromString(evento.situacao),
      totalRegistros: evento.totalRegistros,
      processados: evento.processados,
      importados: evento.importados,
      rejeitados: evento.rejeitados,
      erro: evento.erro,
      problemas: problemas,
      avisos: avisos,
    );
  }

  factory ImportacaoGuiada.deEvento(ImportacaoProgressoEvent evento) {
    return ImportacaoGuiada(
      id: evento.id,
      tipo: evento.tipo,
      situacao: ImportacaoSituacao.fromString(evento.situacao),
    ).comProgresso(evento);
  }

  /// 0..1, ou `null` enquanto o total ainda não é conhecido.
  double? get fracao => totalRegistros > 0
      ? (processados / totalRegistros).clamp(0.0, 1.0)
      : null;

  @override
  List<Object?> get props => [
    id,
    tipo,
    situacao,
    totalRegistros,
    processados,
    importados,
    rejeitados,
    erro,
    problemas,
    avisos,
  ];
}
