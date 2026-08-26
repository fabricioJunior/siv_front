// FNV-1a de 32 bits -- variante do `fastHash` (isar/isar_utils.dart) que cabe
// em inteiro seguro do JS (dart2js/dart2wasm não representam literal de 64
// bits). Só usado por DTOs Hive; nunca precisa bater com o hash do Isar (são
// bancos/chaves independentes).
//
// Usa `.toUnsigned(32)` em vez de `& 0xFFFFFFFF`: no dart2js, `&` bruto pode
// devolver um resultado no range SIGNED de 32 bits (semântica de `&` do
// JavaScript, que sempre trunca via ToInt32) -- se o bit 31 for 1, o valor
// vem negativo em vez do positivo esperado. `Hive` exige chave inteira entre
// 0 e 0xFFFFFFFF; um hash negativo quebra com
// "Integer keys need to be in the range 0 - 0xFFFFFFFF". `.toUnsigned(32)` é
// método de `dart:core`, com semântica de truncamento unsigned garantida em
// qualquer platform (VM, dart2js, dart2wasm).
int hiveHash(String value) {
  var hash = 0x811c9dc5;

  for (var i = 0; i < value.length; i++) {
    hash = (hash ^ value.codeUnitAt(i)).toUnsigned(32);
    hash = (hash * 0x01000193).toUnsigned(32);
  }

  return hash;
}
