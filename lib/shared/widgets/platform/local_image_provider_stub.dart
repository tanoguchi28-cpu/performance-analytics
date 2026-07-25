import 'package:flutter/material.dart';

/// Web向けスタブ。Web版では[PlayerAvatar]がこの関数を呼ばず`NetworkImage`を
/// 使うため、実際に呼ばれることはない想定（`dart:io`をWebのビルド対象から
/// 除外するために存在するファイル）。
ImageProvider localFileImageProvider(String path) {
  throw UnsupportedError('Web版ではローカルファイルの画像表示はサポートされていません');
}
