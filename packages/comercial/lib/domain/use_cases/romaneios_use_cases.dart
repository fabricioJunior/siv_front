import 'package:comercial/data.dart';
import 'package:comercial/models.dart';

class RecuperarRomaneios {
  final IRomaneiosRepository repository;

  RecuperarRomaneios({required this.repository});

  Future<List<Romaneio>> call({int page = 1, int limit = 50}) {
    return repository.recuperarRomaneios(page: page, limit: limit);
  }
}

class RecuperarRomaneio {
  final IRomaneiosRepository repository;

  RecuperarRomaneio({required this.repository});

  Future<Romaneio> call(int id) => repository.recuperarRomaneio(id);
}

class CriarRomaneio {
  final IRomaneiosRepository repository;

  CriarRomaneio({required this.repository});

  Future<Romaneio> call(Romaneio romaneio) =>
      repository.criarRomaneio(romaneio);
}

class AtualizarRomaneio {
  final IRomaneiosRepository repository;

  AtualizarRomaneio({required this.repository});

  Future<Romaneio> call(Romaneio romaneio) =>
      repository.atualizarRomaneio(romaneio);
}

class AtualizarObservacaoRomaneio {
  final IRomaneiosRepository repository;

  AtualizarObservacaoRomaneio({required this.repository});

  Future<Romaneio> call(int id, String observacao) {
    return repository.atualizarObservacao(id, observacao);
  }
}
