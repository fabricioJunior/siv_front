abstract interface class ILocalDataSource<E> {
  Future<void> put(E entity);

  Future<void> putAll(Iterable<E> entities);

  Future<E?> fetchById<Key>(Key id);

  Future<Iterable<E>> fetchAll();

  Future<Iterable<E>> fetchWhere(covariant Test test);

  Future<void> deleteAll();
}

abstract class Test<E, TestBuilder> {
  E call(TestBuilder t);
}
