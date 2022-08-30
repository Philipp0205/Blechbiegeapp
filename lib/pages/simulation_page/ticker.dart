class Ticker {
  const Ticker();
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(const Duration(seconds: 4), (x) => ticks + x + 1)
        .take(ticks);
  }
}