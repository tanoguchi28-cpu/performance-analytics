import 'dart:io';

import 'package:flutter/material.dart';

/// Android/Windows/iOS/macOS/Linux向け: ローカルファイルパスから[ImageProvider]を作る。
ImageProvider localFileImageProvider(String path) => FileImage(File(path));
