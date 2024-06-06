import 'package:cloud_firestore/cloud_firestore.dart';

class SystemUser{

String? userId;
   String? name;
   String? profilePicture;
   String? email;
   String? gender;
   String? password;
   Timestamp? birthDate;
   Timestamp? signedDate;
   String? createdBy;
   String? roleType;

SystemUser({
  this.birthDate,
  this.createdBy,
  this.email,
  this.gender,
  this.name,
  this.password,
  this.profilePicture,
  this.roleType,
  this.signedDate,
  this.userId,
});


  factory SystemUser.fromDoc(DocumentSnapshot doc) {
    return SystemUser(
      userId: doc.id,
      name: doc['name'],
      profilePicture: doc['profilePicture'],
      email: doc['email'],
      gender: doc['gender'],
      password: doc['password'],
      birthDate: doc['birthDate'],
      signedDate: doc['signedDate'],
      createdBy: doc['createdBy'],
      roleType: doc['roleType']
    );
  }
  
}