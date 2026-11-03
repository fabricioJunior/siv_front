export 'package:produtos/presentantion/bloc/referencia_midias_bloc/referencia_midias_bloc.dart';
import 'package:produtos/presentantion/bloc/referencia_midias_bloc/referencia_midias_bloc.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:core/imagens/cache_imagem_service.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:produtos/domain/data/repositorios/i_referencia_midias_repository.dart';
import 'package:produtos/models.dart';

import 'package:produtos/use_cases.dart';

ReferenciaMidia midia(int id, {bool capa = false, String? cor, String? estampa, String? tamanho, String origem = 'site'}) =>
    ReferenciaMidia.create(
      id: id, url: 'http://x/$id.jpg', referenciaId: 100, ePrincipal: capa, ePublica: true,
      cor: cor, estampa: estampa, tamanho: tamanho, origem: origem,
    );

class FakeMidiasRepo implements IReferenciaMidiasRepository {
  List<ReferenciaMidia> midias;
  final List<List<int>> reordenacoes = [];
  final List<Map<String, Object?>> criadas = [];
  final List<bool> validacoesAtualizacao = [];
  Object? falha;

  FakeMidiasRepo(this.midias);

  @override
  Future<List<ReferenciaMidia>> recuperarReferenciasMidias(int referenciaId) async => midias;

  @override
  Future<void> reordenarReferenciaMidias({required int referenciaId, required List<int> ids}) async {
    if (falha != null) throw falha!;
    reordenacoes.add(ids);
    midias = [
      for (var i = 0; i < ids.length; i++)
        () {
          final m = midias.firstWhere((m) => m.id == ids[i]);
          return midia(m.id, capa: i == 0, cor: m.cor, estampa: m.estampa, tamanho: m.tamanho);
        }(),
    ];
  }

  @override
  Future<ReferenciaMidia> criarReferenciaMidia({
    required Uint8List bytes,
    required String fileName,
    required int referenciaId,
    required bool ePrincipal,
    required bool ePublica,
    required TipoReferenciaMidia tipo,
    required String field,
    required String? descricao,
    required String? cor,
    required String? tamanho,
    String? estampa,
    bool validarAssociacao = false,
    String origem = 'site',
    void Function(int sent, int total)? onSendProgress,
  }) async {
    if (falha != null) throw falha!;
    criadas.add({'estampa': estampa, 'validar': validarAssociacao, 'cor': cor, 'tamanho': tamanho});
    return midia(99, cor: cor, estampa: estampa, tamanho: tamanho);
  }

  @override
  Future<ReferenciaMidia> atualizarReferenciaMidia(ReferenciaMidia m, {bool validarAssociacao = false}) async {
    validacoesAtualizacao.add(validarAssociacao);
    return m;
  }

  @override
  Future<void> excluirReferenciaMidia({required int referenciaId, required int id}) async {}
}

class FakeCache implements ICacheImagemService {
  @override
  BaseCacheManager get cacheManager => throw UnimplementedError();
  @override
  Future<void> deleteImagemComCacheKey(String cacheKey) async {}
  @override
  Future<File?> getImagemFileFromCache(String cacheKey) async => null;
  @override
  Future<void> updateImageInCache(String cacheKey, String url) async {}
}

ReferenciaMidiasBloc novoMidiasBloc(FakeMidiasRepo r) => ReferenciaMidiasBloc(
  RecuperarReferenciaMidias(referenciaMidiasRepository: r),
  CriarReferenciaMidia(referenciaMidiasRepository: r),
  ExcluirReferenciaMidia(referenciaMidiasRepository: r),
  AtualizarReferenciaMidia(referenciaMidiasRepository: r),
  ReordenarReferenciaMidias(referenciaMidiasRepository: r),
  FakeCache(),
);
