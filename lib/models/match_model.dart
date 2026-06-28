import 'package:cloud_firestore/cloud_firestore.dart';

enum MatchStatus { pending, accepted, refused }

MatchStatus matchStatusFromString(String value) {
  return MatchStatus.values.firstWhere(
    (e) => e.name == value,
    orElse: () => MatchStatus.pending,
  );
}

class MatchModel {
  final String id;
  final String requesterId;
  final String receiverId; 
  final MatchStatus status;
  final DateTime createdAt;

  MatchModel({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
  });

  List<String> get users => [requesterId, receiverId];

  factory MatchModel.fromFirestore(Map<String, dynamic> map, String id) {
    return MatchModel(
      id: id,
      requesterId: map['requesterId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      status: matchStatusFromString(map['status'] ?? 'pending'),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

}