import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'platform/local_image_provider_stub.dart'
    if (dart.library.io) 'platform/local_image_provider_io.dart';

/// 選手写真の丸型アバター。photoPathが無い/読み込めない場合はイニシャル無しの
/// 人物アイコンにフォールバックする。Web環境（開発プレビュー用）ではblob URLを
/// Image.networkで、それ以外（Windows/macOS/Android/iOS）ではImage.fileで表示する。
class PlayerAvatar extends StatelessWidget {
  const PlayerAvatar({super.key, required this.photoPath, this.radius = 24});

  final String? photoPath;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final path = photoPath;

    if (path == null || path.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: cs.surfaceContainerHighest,
        child: Icon(Icons.person, color: cs.onSurfaceVariant, size: radius),
      );
    }

    final image = kIsWeb ? NetworkImage(path) as ImageProvider : localFileImageProvider(path);

    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.surfaceContainerHighest,
      backgroundImage: image,
      onBackgroundImageError: (_, __) {},
    );
  }
}
