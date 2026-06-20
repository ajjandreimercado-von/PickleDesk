import 'package:hive/hive.dart';

class BaseRepository<T> {
  final Box<T> _box;

  BaseRepository(this._box);

  List<T> getAll() {
    return _box.values.toList();
  }

  T? getById(String id) {
    // Assuming entities have an id field, we'll need to cast or rely on dynamic if we don't have an interface
    // Since we don't have an interface, we can search.
    try {
      return _box.values.firstWhere((e) => (e as dynamic).id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> add(T item) async {
    final id = (item as dynamic).id;
    await _box.put(id, item);
  }

  Future<void> update(String id, T item) async {
    await _box.put(id, item);
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
  }

  Stream<BoxEvent> watch() {
    return _box.watch();
  }
}
