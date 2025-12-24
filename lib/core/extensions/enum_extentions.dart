extension EnumExtentions on List {
  Map<String, dynamic> get mapEnums {
    if (isEmpty) {
      return {};
    } else {
      if (this[0] is Enum) {
        return map((e) => {e.name as String: e}).fold(<String, dynamic>{}, (
          acc,
          map,
        ) {
          acc.addAll(map);
          return acc;
        });
      } else {
        return {};
      }
    }
  }
}
