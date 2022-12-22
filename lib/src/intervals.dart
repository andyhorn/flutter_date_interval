enum Intervals { once, daily, weekly, monthly, yearly }

extension IntervalsExtension on Intervals {
  static Intervals? fromString(String s) {
    var map = Intervals.values;

    for (var i = 0; i < map.length; i++) {
      if (map[i].toString() == "Intervals.$s") {
        return map[i];
      }
    }

    return null;
  }
}
