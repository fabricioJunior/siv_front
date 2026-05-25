import 'package:core/remote_data_sourcers.dart';
import 'package:produtos/domain/data/remote/i_etiquetas_remote_data_source.dart';
import 'package:produtos/models.dart';

class EtiquetasRemoteDatasource extends RemoteDataSourceBase
    implements IEtiquetasRemoteDataSource {
  EtiquetasRemoteDatasource({required super.informacoesParaRequest});

  @override
  String get path => '/v1/etiquetas/{id}';

  @override
  Future<List<Etiqueta>> fetchEtiquetas() async {
    final response = await get();
    return (response.body as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => _fromMap(
            item,
            nomePadrao: '',
            alturaPadrao: 0,
            larguraPadrao: 0,
            dpiPadrao: EtiquetaDpi.d203,
            elementosPadrao: const <EtiquetaElemento>[],
            viasPadrao: const <EtiquetaVia>[],
          ),
        )
        .toList();
  }

  @override
  Future<Etiqueta> createEtiqueta({
    required String nome,
    required double altura,
    required double largura,
    required EtiquetaDpi dpi,
    required List<EtiquetaElemento> elementos,
    required List<EtiquetaVia> vias,
  }) async {
    final response = await post(
      body: {
        'nome': nome,
        'altura': altura,
        'largura': largura,
        'dpi': dpi.valor,
        'elementos': elementos
            .map(
              (item) => {
                'x': item.x,
                'y': item.y,
                'nome': item.nome,
                'tipoElemento': item.tipoElemento.valor,
              },
            )
            .toList(growable: false),
        'vias': vias
            .map(
              (item) => {
                'ordem': item.ordem,
                'zpl': item.zpl,
              },
            )
            .toList(growable: false),
      },
    );

    final body = response.body;
    if (body is Map<String, dynamic>) {
      return _fromMap(
        body,
        nomePadrao: nome,
        alturaPadrao: altura,
        larguraPadrao: largura,
        dpiPadrao: dpi,
        elementosPadrao: elementos,
        viasPadrao: vias,
      );
    }

    return Etiqueta.create(
      nome: nome,
      altura: altura,
      largura: largura,
      dpi: dpi,
      elementos: elementos,
      vias: vias,
    );
  }

  Etiqueta _fromMap(
    Map<String, dynamic> json, {
    required String nomePadrao,
    required double alturaPadrao,
    required double larguraPadrao,
    required EtiquetaDpi dpiPadrao,
    required List<EtiquetaElemento> elementosPadrao,
    required List<EtiquetaVia> viasPadrao,
  }) {
    final elementosJson = json['elementos'];
    final viasJson = json['vias'];

    final elementos = elementosJson is List
        ? elementosJson
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => EtiquetaElemento.create(
                  nome: (item['nome'] as String?)?.trim() ?? '',
                  tipoElemento: TipoElementoEtiquetaX.fromValue(item['tipoElemento']),
                  x: (item['x'] as num?)?.toDouble() ?? 0,
                  y: (item['y'] as num?)?.toDouble() ?? 0,
                ),
              )
              .toList(growable: false)
        : elementosPadrao;

    final vias = viasJson is List
        ? viasJson
              .whereType<Map<String, dynamic>>()
              .map(
                (item) => EtiquetaVia.create(
                  ordem: (item['ordem'] as num?)?.toInt() ?? 0,
                  zpl: (item['zpl'] as String?)?.trim() ?? '',
                ),
              )
              .where((item) => item.zpl.isNotEmpty)
              .toList(growable: false)
        : viasPadrao;

    return Etiqueta.create(
      id: json['id'] as int?,
      nome: (json['nome'] as String?)?.trim().isNotEmpty == true
          ? json['nome'] as String
          : nomePadrao,
      altura: (json['altura'] as num?)?.toDouble() ?? alturaPadrao,
      largura: (json['largura'] as num?)?.toDouble() ?? larguraPadrao,
      dpi: EtiquetaDpiX.fromValue(json['dpi'] ?? dpiPadrao.valor),
      elementos: elementos,
      vias: vias,
    );
  }
}
