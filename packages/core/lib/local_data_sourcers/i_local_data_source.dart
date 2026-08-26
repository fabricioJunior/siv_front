abstract interface class ILocalDataSource<E> {
  Future<void> put(E entity);

  Future<void> putAll(Iterable<E> entities);

  Future<E?> fetchById(int id);

  Future<Iterable<E>> fetchAll();

  Future<Iterable<E>> fetchWhere(bool Function(E) predicate);

  Future<void> deleteAll();
}
