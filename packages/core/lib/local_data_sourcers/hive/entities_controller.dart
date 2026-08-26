Map<Type, int>? _storageTypes;

int typeId(Type type) {
  final storageTypes = _storageTypes;
  if (storageTypes == null) {
    throw UninitializedStorageException();
  }
  final id = storageTypes[type];
  if (id == null) {
    throw NotRegisteredTypeException(type);
  }
  return id;
}

/// Registro central dos typeIds usados pelos adapters Hive do app inteiro.
/// typeId é global (não por box) -- nunca reusar um id já registrado por
/// outro tipo. Chamado uma vez no bootstrap (ver `Hive.initFlutter()` em
/// `main.dart`), reunindo os mapas de cada módulo que tem DTOs Hive.
void inicializarStorage(Map<Type, int> storageTypes) {
  _verificarIdentificadoresDuplicados(storageTypes);
  _storageTypes = storageTypes;
}

void _verificarIdentificadoresDuplicados(Map<Type, int> storageTypes) {
  final numeroDeIdentificadores = storageTypes.values.length;
  final numeroDeIdentificadoresDistintos = storageTypes.values.toSet().length;

  if (numeroDeIdentificadores != numeroDeIdentificadoresDistintos) {
    throw AssertionError(
      'Existem tipos com typeId duplicado no registro de entidades Hive',
    );
  }
}

class UninitializedStorageException extends FormatException {
  UninitializedStorageException()
      : super(
          'O storage Hive não foi inicializado, chame inicializarStorage() '
          'antes de armazenar ou ler qualquer informação',
        );
}

class NotRegisteredTypeException extends FormatException {
  NotRegisteredTypeException(Type type)
      : super('${type.toString()} não está registrado como StorageEntity');
}
