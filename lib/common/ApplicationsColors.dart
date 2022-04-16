import "dart:math";

class ApplicationColors {
  static List<String> colors = [
    '5e81ac',
    '81a1c1',
    '88c0d0',
    '8fbcbb',
  ];

  static int getRandomColor() {
    final _random = new Random();

    String color = "0xff" + colors[_random.nextInt(colors.length)];

    print('Random color: $color');

    return int.parse(color);
  }
}
