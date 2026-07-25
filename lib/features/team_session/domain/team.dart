/// チーム共有モードにおけるチーム。[id]はスタッフ間で共有する短いコード。
class Team {
  const Team({required this.id, required this.name, required this.createdAt});

  final String id;
  final String name;
  final DateTime createdAt;
}
