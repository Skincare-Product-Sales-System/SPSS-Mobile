class TransactionDto {
  final String id;
  final String userId;
  final String userName;
  final String transactionType;
  final double amount;
  final String status;
  final String qrImageUrl;
  final String bankInformation;
  final String description;
  final DateTime createdTime;
  final DateTime lastUpdatedTime;
  final DateTime? approvedTime;

  TransactionDto({
    required this.id,
    required this.userId,
    required this.userName,
    required this.transactionType,
    required this.amount,
    required this.status,
    required this.qrImageUrl,
    required this.bankInformation,
    required this.description,
    required this.createdTime,
    required this.lastUpdatedTime,
    this.approvedTime,
  });

  factory TransactionDto.fromJson(Map<String, dynamic> json) {
    return TransactionDto(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      transactionType: json['transactionType'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      qrImageUrl: json['qrImageUrl'] ?? '',
      bankInformation: json['bankInformation'] ?? '',
      description: json['description'] ?? '',
      createdTime:
          json['createdTime'] != null
              ? DateTime.parse(json['createdTime'])
              : DateTime.now(),
      lastUpdatedTime:
          json['lastUpdatedTime'] != null
              ? DateTime.parse(json['lastUpdatedTime'])
              : DateTime.now(),
      approvedTime:
          json['approvedTime'] != null
              ? DateTime.parse(json['approvedTime'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'transactionType': transactionType,
      'amount': amount,
      'status': status,
      'qrImageUrl': qrImageUrl,
      'bankInformation': bankInformation,
      'description': description,
      'createdTime': createdTime.toIso8601String(),
      'lastUpdatedTime': lastUpdatedTime.toIso8601String(),
      'approvedTime': approvedTime?.toIso8601String(),
    };
  }
}
