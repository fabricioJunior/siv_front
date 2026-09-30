import 'package:produtos/models.dart';

/// Grade (agrupamento) de um tamanho, pra separar em abas no seletor
/// "Adicionar variações". O backend ainda não tem esse campo -- heurística
/// isolada aqui pra trocar fácil por um campo real quando existir.
enum GradeDeTamanho { letras, numerica, sutia, infantil, unico }

const _ordemLetras = [
  'PP',
  'P',
  'M',
  'G',
  'GG',
  'XG',
  'XGG',
  'EG',
  'EGG',
];

final _regexNumerico = RegExp(r'^\d{2,3}$');
final _regexSutia = RegExp(r'^\d{2,3}[A-DFG]$', caseSensitive: false);
final _regexInfantil = RegExp(r'^\d{1,2}\s?(anos|a|m)$', caseSensitive: false);

/// Classifica um tamanho pela grade a que pertence, pelo nome.
GradeDeTamanho classificarGradeDeTamanho(String nomeTamanho) {
  final nome = nomeTamanho.trim().toUpperCase();

  if (nome == 'ÚNICO' || nome == 'UNICO' || nome == 'U') {
    return GradeDeTamanho.unico;
  }
  if (_regexSutia.hasMatch(nome)) {
    return GradeDeTamanho.sutia;
  }
  if (_regexInfantil.hasMatch(nomeTamanho.trim())) {
    return GradeDeTamanho.infantil;
  }
  if (_regexNumerico.hasMatch(nome)) {
    return GradeDeTamanho.numerica;
  }
  if (_ordemLetras.contains(nome)) {
    return GradeDeTamanho.letras;
  }
  return GradeDeTamanho.letras;
}

/// Ordena tamanhos "na ordem da grade": letras na ordem PP..XGG, numérico
/// crescente, os demais por ordem alfabética.
int compararTamanhosNaOrdemDaGrade(Tamanho a, Tamanho b) {
  final indiceA = _ordemLetras.indexOf(a.nome.trim().toUpperCase());
  final indiceB = _ordemLetras.indexOf(b.nome.trim().toUpperCase());

  if (indiceA != -1 && indiceB != -1) return indiceA.compareTo(indiceB);
  if (indiceA != -1) return -1;
  if (indiceB != -1) return 1;

  final numA = int.tryParse(a.nome.trim());
  final numB = int.tryParse(b.nome.trim());
  if (numA != null && numB != null) return numA.compareTo(numB);

  return a.nome.toLowerCase().compareTo(b.nome.toLowerCase());
}
