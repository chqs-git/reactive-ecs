/// A SparseSet is a cache-friendly data structure because the dense array is contiguous in memory.
///
/// Note: The sparse list can be either a Map or an optimized paginated List.
/// Lookups are slightly faster with a paginated List (O(1)) when there is a very high number of entities.
///
/// For the purpose of this Package, it is unlikely to have that many entities.
/// Therefore a Map will be used since it also allows us to efficiently iterate over
/// all entities that contain the component specific to this SparseSet.
class SparseSet<T> {
  final Map<int, int> sparse; // ids
  final List<T> dense; // content

  // constructor
  SparseSet({required this.sparse, required this.dense});

  static SparseSet<T> create<T>() {
    return SparseSet<T>(sparse: {}, dense: List.empty(growable: true));
  }

  void add(int id, T content) {
    // Map ID in sparse to back of dense list
    sparse[id] = dense.length;
    dense.add(content);
  }

  void delete(int id) {
    if (sparse[id] == null) return;

    final index = sparse[id]!;
    final lastIndex = dense.length - 1;

    if (index != lastIndex) {
      final lastElem = dense[lastIndex];
      final lastElemSparseId = sparse.entries.firstWhere((entry) => entry.value == lastIndex).key;

      // Swap first and last elem
      dense[index] = lastElem;
      sparse[lastElemSparseId] = index;
    }

    sparse.remove(id);
    dense.removeAt(lastIndex);
  }

  T? get(int id) {
    if (sparse[id] == null) return null;
    return dense[sparse[id]!];
  }
}