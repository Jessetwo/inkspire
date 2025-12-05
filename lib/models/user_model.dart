class UserModel {
  final String id;
  final String firstname;
  final String othername;
  final String email;

  UserModel({
    required this.id,
    required this.firstname,
    required this.othername,
    required this.email,
  });

  // Convert UserModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstname,
      'othername': othername,
      'email': email,
    };
  }

  // Create UserModel from JSON (Firestore document)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstname: json['firstname'] ?? '',
      othername: json['othername'] ?? '',
      email: json['email'] ?? '',
    );
  }

  // CopyWith for easy updates
  UserModel copyWith({
    String? id,
    String? firstname,
    String? othername,
    String? email,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstname: firstname ?? this.firstname,
      othername: othername ?? this.othername,
      email: email ?? this.email,
    );
  }
}
