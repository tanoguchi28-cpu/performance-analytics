import 'dart:math';

/// チームIDとして人が入力しやすい短いコードを生成する。
/// `0/O/1/I/L`など紛らわしい文字を除いた英数字のみを使う。
class TeamCodeGenerator {
  static const _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static const _length = 8;

  static String generate() {
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
        _length,
        (_) => _alphabet.codeUnitAt(random.nextInt(_alphabet.length)),
      ),
    );
  }
}
