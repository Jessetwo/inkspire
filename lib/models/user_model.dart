class UserModel {
  final String id;
  final String firstname;
  final String othername;
  final String email;
  final String? profilePicture; // Add profile picture field

  UserModel({
    required this.id,
    required this.firstname,
    required this.othername,
    required this.email,
    this.profilePicture,
  });

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'othername': othername,
      'email': email,
      'profilePicture': profilePicture,
    };
  }

  // Create UserModel from JSON (Firestore document)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstname: json['firstname'] ?? '',
      othername: json['othername'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }

  // CopyWith for easy updates
  UserModel copyWith({
    String? id,
    String? firstname,
    String? othername,
    String? email,
    String? profilePicture,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      othername: othername ?? this.othername,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
    );
  }
}
