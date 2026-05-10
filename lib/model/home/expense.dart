enum TransactionType { income, expense }

extension TransactionTypeExt on TransactionType {
  String get label => this == TransactionType.income ? 'Income' : 'Expense';
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final TransactionType type;
  final String? description;
  final String? projectId;
  final String? createdBy;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.type = TransactionType.expense,
    this.description,
    this.projectId,
    this.createdBy,
  });

  factory Expense.fromJson(Map<String, dynamic> json, String id) => Expense(
        id: id,
        title: json['title'] ?? json['description'] ?? '',
        amount: (json['amount'] as num?)?.toDouble() ?? 0,
        category: json['category'] ?? '',
        date: json['date'] != null
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        type: json['type'] == 'income'
            ? TransactionType.income
            : TransactionType.expense,
        description: json['description'],
        projectId: json['project_id'],
        createdBy: json['created_by'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.toIso8601String(),
        'type': type.name,
        'description': description,
        'project_id': projectId,
        'created_by': createdBy,
      };
}
