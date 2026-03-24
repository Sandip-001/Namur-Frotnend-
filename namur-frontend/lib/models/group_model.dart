class GroupModel {
  final String name;
  final String iconPath;
  final bool isActive;
  final int membersCount;

  GroupModel({
    required this.name,
    required this.iconPath,
    this.isActive = false,
    this.membersCount = 0,
  });
}
