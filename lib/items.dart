



class Items<T> {
  Items({
    this.crossAxisCount = 4,
    this.mainAxisCount = 4,
    required this.itemBuilder,
  })  : assert(crossAxisCount > 0, 'crossAxisCount must be greater than zero'),
        assert(mainAxisCount > 0, 'mainAxisCount must be greater than zero') {
    _initializeItems();
  }

  int mainAxisCount;
  int crossAxisCount;
  final T Function(int index) itemBuilder;

  late List<T> _items;

  // Initialize or reinitialize the items list based on current crossAxisCount and mainAxisCount
  void _initializeItems() {
    _items = List.generate(
      mainAxisCount * crossAxisCount,
      (index) => itemBuilder(index),
    );
  }

  int get lastItemIndex => (_items.length - 1);
  int _dragItemIndex = -1;
  int get dragItemIndex => _dragItemIndex;

  set dragItemIndex(int index) {
    assert(index >= 0 && index < _items.length, 'Index $index is out of bounds for items list.');
    _dragItemIndex = index;
  }

  List<T> get items => List<T>.unmodifiable(_items);

  // Method to swap items
  void swapItem(bool canSwap, int newIndex) {
  if (canSwap) {
    assert(_dragItemIndex != -1, 'No item is currently being dragged.');
    assert(newIndex >= 0 && newIndex < _items.length, 'Index $newIndex is out of bounds for items list.');

    // Check if the new index is directly adjacent (vertically or horizontally)
    final bool isSameRow = (dragItemIndex ~/ crossAxisCount) == (newIndex ~/ crossAxisCount);
    final bool isUpperItem = newIndex == dragItemIndex - crossAxisCount;
    final bool isLowerItem = newIndex == dragItemIndex + crossAxisCount;
    final bool isLeftNeighbor = newIndex == dragItemIndex - 1 && isSameRow;
    final bool isRightNeighbor = newIndex == dragItemIndex + 1 && isSameRow;

    // Only swap if the item is in the same row or adjacent in a valid way
    if (isUpperItem || isLowerItem || isLeftNeighbor || isRightNeighbor) {
      final T draggedItem = _items[dragItemIndex];
      _items[dragItemIndex] = _items[newIndex];
      _items[newIndex] = draggedItem;
      dragItemIndex = newIndex;
    }
  }
}

  // Method to update the grid dimensions
  void updateGridDimensions(int newCrossAxisCount, int newMainAxisCount) {
    crossAxisCount = newCrossAxisCount;
    mainAxisCount = newMainAxisCount;
    _initializeItems(); // Reinitialize the grid with the new dimensions
    dragItemIndex = lastItemIndex;
  }

  // Method to randomize items

void randomizeItems() {
 
  List<T> itemsToShuffle = _items.sublist(0, _items.length - 1);
  itemsToShuffle.shuffle();

  // Reassign the shuffled items back to _items, keeping the last item in place
  _items = [...itemsToShuffle, _items.last];
}

}











 