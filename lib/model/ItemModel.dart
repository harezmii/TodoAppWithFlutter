class ItemModel {
  String _itemModelTitle;
  String _itemModelExplain;
  String _timestamp;


  ItemModel(this._itemModelTitle, this._itemModelExplain, this._timestamp);

  String get itemModelTitle => _itemModelTitle;

  set itemModelTitle(String value) {
    _itemModelTitle = value;
  }

  String get itemModelExplain => _itemModelExplain;

  String get timestamp => _timestamp;

  set timestamp(String value) {
    _timestamp = value;
  }

  set itemModelExplain(String value) {
    _itemModelExplain = value;
  }
}