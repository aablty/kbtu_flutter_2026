class Profile {
  const Profile({required this.name, required this.group});

  final String name;
  final String group;

  factory Profile.empty() => const Profile(name: '', group: '');

  Profile copyWith({String? name, String? group}) =>
      Profile(name: name ?? this.name, group: group ?? this.group);
}
