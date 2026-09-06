import 'package:synthinnotech/model/employee/employee_model.dart';
import 'package:synthinnotech/model/home/expense.dart';
import 'package:synthinnotech/model/home/project.dart';

/// Sample content shown only when Firebase is not configured (local "demo
/// mode"), and used by the admin "Seed demo data" action to populate a fresh
/// Firestore project. It is never mixed with real data anymore.
class DemoData {
  const DemoData._();

  static List<EmployeeModel> employees() => [
        EmployeeModel(
          id: 'demo-e1',
          name: 'Vinoth A',
          email: 'admin@synthinnotech.com',
          phone: '+91 98765 43210',
          role: EmployeeRole.admin,
          department: 'Management',
          jobTitle: 'CEO & Founder',
          salary: 150000,
          isActive: true,
          joinDate: DateTime(2022, 1, 1),
        ),
        EmployeeModel(
          id: 'demo-e2',
          name: 'Priya Sharma',
          email: 'priya@synthinnotech.com',
          phone: '+91 98765 43211',
          role: EmployeeRole.manager,
          department: 'Technology',
          jobTitle: 'Tech Lead',
          salary: 95000,
          isActive: true,
          joinDate: DateTime(2022, 3, 15),
        ),
        EmployeeModel(
          id: 'demo-e3',
          name: 'Arjun Kumar',
          email: 'arjun@synthinnotech.com',
          phone: '+91 98765 43212',
          role: EmployeeRole.employee,
          department: 'Technology',
          jobTitle: 'Flutter Developer',
          salary: 70000,
          isActive: true,
          joinDate: DateTime(2022, 6, 1),
        ),
        EmployeeModel(
          id: 'demo-e4',
          name: 'Kavya Reddy',
          email: 'kavya@synthinnotech.com',
          phone: '+91 98765 43213',
          role: EmployeeRole.intern,
          department: 'Technology',
          jobTitle: 'Backend Intern',
          salary: 25000,
          isActive: true,
          joinDate: DateTime(2024, 1, 10),
        ),
      ];

  static List<Project> projects() {
    final now = DateTime.now();
    return [
      Project(
        id: 'demo-p1',
        name: 'Mobile App Redesign',
        description: 'Complete redesign with new UI/UX patterns.',
        clientName: 'TechCorp Inc',
        status: ProjectStatus.inProgress,
        progress: 0.75,
        budget: 50000,
        spent: 35000,
        startDate: now.subtract(const Duration(days: 30)),
        deadline: now.add(const Duration(days: 15)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Project(
        id: 'demo-p2',
        name: 'E-commerce Platform',
        description: 'Build a scalable e-commerce solution.',
        clientName: 'RetailMax',
        status: ProjectStatus.delayed,
        progress: 0.45,
        budget: 80000,
        spent: 42000,
        startDate: now.subtract(const Duration(days: 60)),
        deadline: now.subtract(const Duration(days: 2)),
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      Project(
        id: 'demo-p3',
        name: 'Brand Identity Design',
        description: 'Complete brand redesign including logo and guidelines.',
        clientName: 'StartupXYZ',
        status: ProjectStatus.review,
        progress: 0.90,
        budget: 15000,
        spent: 12000,
        startDate: now.subtract(const Duration(days: 20)),
        deadline: now.add(const Duration(days: 8)),
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Project(
        id: 'demo-p4',
        name: 'API Integration Suite',
        description: 'Third-party API integration and data sync.',
        clientName: 'DataFlow Ltd',
        status: ProjectStatus.done,
        progress: 1.0,
        budget: 25000,
        spent: 22000,
        startDate: now.subtract(const Duration(days: 90)),
        deadline: now.subtract(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 90)),
      ),
      Project(
        id: 'demo-p5',
        name: 'Analytics Dashboard',
        description: 'Real-time analytics with data visualization.',
        clientName: 'InsightCo',
        status: ProjectStatus.available,
        progress: 0.0,
        budget: 35000,
        spent: 0,
        deadline: now.add(const Duration(days: 45)),
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  static List<Expense> transactions() {
    final now = DateTime.now();
    Expense e(String id, String title, double amt, String cat, int daysAgo,
            TransactionType type) =>
        Expense(
          id: id,
          title: title,
          amount: amt,
          category: cat,
          date: now.subtract(Duration(days: daysAgo)),
          type: type,
        );
    return [
      e('demo-t1', 'Client Payment - TechCorp', 25000, 'Project Revenue', 1,
          TransactionType.income),
      e('demo-t2', 'Office Rent', 8500, 'Rent', 3, TransactionType.expense),
      e('demo-t3', 'Project Payment - RetailMax', 18000, 'Project Revenue', 5,
          TransactionType.income),
      e('demo-t4', 'Software Subscriptions', 1200, 'Software', 7,
          TransactionType.expense),
      e('demo-t5', 'Team Salaries', 45000, 'Payroll', 8,
          TransactionType.expense),
      e('demo-t6', 'Consulting Fee', 5500, 'Consulting', 10,
          TransactionType.income),
      e('demo-t7', 'Marketing & Ads', 3500, 'Marketing', 16,
          TransactionType.expense),
      e('demo-t8', 'New Project Advance', 12000, 'Project Revenue', 14,
          TransactionType.income),
    ];
  }
}
