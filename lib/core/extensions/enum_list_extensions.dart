extension EnumListExtensions<E extends Enum> on List<E> {
  Map<String, E> get mapEnums {
    return {
      for (final e in this) e.name: e,
    };
  }
}
