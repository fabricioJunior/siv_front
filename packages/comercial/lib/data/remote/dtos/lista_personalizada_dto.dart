import 'package:comercial/domain/models/lista_personalizada.dart';

class ListaPersonalizadaDto {
  static ListaPersonalizada fromJson(Map<String, dynamic> json) {
    return ListaPersonalizada(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      hash: json['hash']?.toString() ?? '',
      tabelaPrecoId: int.tryParse(json['tabelaPrecoId']?.toString() ?? ''),
      dataInicio: DateTime.tryParse(json['dataInicio']?.toString() ?? ''),
      dataExpiracao: DateTime.tryParse(json['dataExpiracao']?.toString() ?? ''),
      situacao: situacaoDeJson(json['situacao']?.toString()),
      titulo: json['titulo']?.toString(),
      descricao: json['descricao']?.toString(),
      icone: json['icone']?.toString(),
      tipo: tipoDeJson(json['tipo']?.toString()),
      modo: modoDeJson(json['modo']?.toString()),
      filtro: ListaFiltroDto.fromJson(json['filtro']),
      itens: (json['itens'] as List<dynamic>? ?? [])
          .map((item) => _item(item as Map<String, dynamic>))
          .toList(),
    );
  }

  static ListaPersonalizadaItem _item(Map<String, dynamic> json) {
    return ListaPersonalizadaItem(
      referenciaId: int.tryParse(json['referenciaId']?.toString() ?? '') ?? 0,
      nome: json['nome']?.toString() ?? '',
      valor: num.tryParse(json['valor']?.toString() ?? '') ?? 0,
      imagemUrl: json['imagemUrl']?.toString(),
    );
  }

  /// Corpo de POST/PATCH. No PATCH ([incluirNulos]) período, tabela e filtro
  /// vão como `null` explícito para permitir limpar o valor.
  static Map<String, dynamic> inputToJson(
    ListaPersonalizadaInput input, {
    bool incluirNulos = false,
  }) {
    final titulo = input.titulo?.trim();
    final descricao = input.descricao?.trim();
    return {
      'tipo': input.tipo.name,
      'modo': input.modo.name,
      if (titulo != null && titulo.isNotEmpty) 'titulo': titulo,
      if (incluirNulos) 'descricao': descricao?.isEmpty == true ? null : descricao,
      if (!incluirNulos && descricao != null && descricao.isNotEmpty)
        'descricao': descricao,
      if (incluirNulos || input.dataInicio != null)
        'dataInicio': input.dataInicio?.toIso8601String(),
      if (incluirNulos || input.dataExpiracao != null)
        'dataExpiracao': input.dataExpiracao?.toIso8601String(),
      if (incluirNulos || input.tabelaPrecoId != null)
        'tabelaPrecoId': input.tabelaPrecoId,
      if (input.modo == ListaModo.filtro)
        'filtro': ListaFiltroDto.toJson(input.filtro ?? const ListaFiltro())
      else if (incluirNulos)
        'filtro': null,
      if (input.referenciaIds.isNotEmpty) 'referenciaIds': input.referenciaIds,
    };
  }

  static Map<String, dynamic> loteToJson(ListaItensLote lote) => {
        if (lote.categoriaIds.isNotEmpty) 'categoriaIds': lote.categoriaIds,
        if (lote.subCategoriaIds.isNotEmpty)
          'subCategoriaIds': lote.subCategoriaIds,
        if (lote.apenasPublicadasNoEcommerce) 'apenasPublicadasNoEcommerce': true,
        if (lote.search != null && lote.search!.isNotEmpty) 'search': lote.search,
      };
}

class ListaFiltroDto {
  static const _operadores = {
    EstoqueOperador.igual: 'igual',
    EstoqueOperador.ate: 'ate',
    EstoqueOperador.aPartir: 'a_partir',
  };

  /// Formato do contrato: campos vazios não são enviados.
  static Map<String, dynamic> toJson(ListaFiltro f) => {
        if (f.categoriaIds.isNotEmpty) 'categoriaIds': f.categoriaIds,
        if (f.subCategoriaIds.isNotEmpty) 'subCategoriaIds': f.subCategoriaIds,
        if (f.tamanhoIds.isNotEmpty) 'tamanhoIds': f.tamanhoIds,
        if (f.corIds.isNotEmpty) 'corIds': f.corIds,
        if (f.estoque != null)
          'estoque': {
            'operador': _operadores[f.estoque!.operador],
            'quantidade': f.estoque!.quantidade,
          },
        if (f.promocaoIds.isNotEmpty) 'promocaoIds': f.promocaoIds,
        if (f.apenasEmPromocao) 'apenasEmPromocao': true,
      };

  static ListaFiltro? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    List<int> ids(String chave) => (raw[chave] as List<dynamic>? ?? [])
        .map((e) => int.tryParse(e.toString()))
        .whereType<int>()
        .toList();
    ListaFiltroEstoque? estoque;
    final e = raw['estoque'];
    if (e is Map) {
      final operador = _operadores.entries
          .where((o) => o.value == e['operador']?.toString())
          .map((o) => o.key)
          .firstOrNull;
      final quantidade = int.tryParse(e['quantidade']?.toString() ?? '');
      if (operador != null && quantidade != null) {
        estoque = ListaFiltroEstoque(operador: operador, quantidade: quantidade);
      }
    }
    return ListaFiltro(
      categoriaIds: ids('categoriaIds'),
      subCategoriaIds: ids('subCategoriaIds'),
      tamanhoIds: ids('tamanhoIds'),
      corIds: ids('corIds'),
      estoque: estoque,
      promocaoIds: ids('promocaoIds'),
      apenasEmPromocao: raw['apenasEmPromocao'] == true,
    );
  }
}

class ListaPreviaDto {
  static ListaPrevia fromJson(Map<String, dynamic> json) {
    final meta = json['meta'] as Map<String, dynamic>? ?? const {};
    num? preco(Map<String, dynamic> r) => num.tryParse(
        (r['preco'] ?? r['valor'] ?? r['precoPor'] ?? '').toString());
    String? imagem(Map<String, dynamic> r) {
      final direta = r['imagemUrl'] ?? r['imagem'] ?? r['thumbnail'];
      if (direta != null) return direta.toString();
      final imagens = r['imagens'] ?? r['midias'];
      if (imagens is List && imagens.isNotEmpty) {
        final primeira = imagens.first;
        return primeira is Map
            ? (primeira['url'] ?? primeira['imagemUrl'])?.toString()
            : primeira.toString();
      }
      return null;
    }

    return ListaPrevia(
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .map((r) => ListaPreviaItem(
                id: int.tryParse(r['id']?.toString() ?? '') ?? 0,
                nome: (r['nome'] ?? r['titulo'] ?? '').toString(),
                preco: preco(r),
                imagemUrl: imagem(r),
              ))
          .toList(),
      totalItems: int.tryParse(meta['totalItems']?.toString() ?? '') ?? 0,
      page: int.tryParse(meta['currentPage']?.toString() ?? '') ?? 1,
      totalPages: int.tryParse(meta['totalPages']?.toString() ?? '') ?? 0,
    );
  }
}

ListaPersonalizadaSituacao situacaoDeJson(String? valor) {
  switch (valor) {
    case 'cancelada':
      return ListaPersonalizadaSituacao.cancelada;
    case 'expirada':
      return ListaPersonalizadaSituacao.expirada;
    case 'agendada':
      return ListaPersonalizadaSituacao.agendada;
    default:
      return ListaPersonalizadaSituacao.ativa;
  }
}

ListaTipo tipoDeJson(String? valor) =>
    valor == 'catalogo' ? ListaTipo.catalogo : ListaTipo.provador;

ListaModo modoDeJson(String? valor) =>
    valor == 'filtro' ? ListaModo.filtro : ListaModo.manual;
