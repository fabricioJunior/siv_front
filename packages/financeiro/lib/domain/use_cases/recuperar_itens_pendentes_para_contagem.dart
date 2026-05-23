import 'package:financeiro/domain/data/repositories/i_contagem_do_caixa_repository.dart';
import 'package:financeiro/domain/models/contagem_do_caixa_item.dart';

class RecuperarItensPendentesParaContagemDoCaixaUseCase { 
  final IContagemDoCaixaRepository repository;
 
  RecuperarItensPendentesParaContagemDoCaixaUseCase({
    required this.repository,
  });
 
  Future<List<ContagemDoCaixaItem>> call({
    required int caixaId,
  }) {
    return repository.recuperarItensPendentesParaContagemDoCaixa(
      caixaId: caixaId,
    );
  }
}