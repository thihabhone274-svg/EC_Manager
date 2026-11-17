import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.instance.database;
  runApp(const ECApp());
}

class ECApp extends StatelessWidget {
  const ECApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xFF5B2AA6);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EC Payment Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seed),
        scaffoldBackgroundColor: const Color(0xFFF0EEF7),
        fontFamily: 'Poppins',
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _refreshToken = 0;

  void _notifyChange() => setState(() => _refreshToken++);

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(refreshToken: _refreshToken, onChanged: _notifyChange),
      OrderSessionsPage(refreshToken: _refreshToken, onChanged: _notifyChange),
      StudentsPage(refreshToken: _refreshToken, onChanged: _notifyChange),
      SubjectsPage(refreshToken: _refreshToken, onChanged: _notifyChange),
      PaymentMethodsPage(refreshToken: _refreshToken, onChanged: _notifyChange),
      ReportsPage(refreshToken: _refreshToken, onChanged: _notifyChange),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _index,
            onTap: (value) => setState(() => _index = value),
            selectedItemColor: const Color(0xFF5B2AA6),
            unselectedItemColor: Colors.grey.shade500,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                activeIcon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart_outlined),
                activeIcon: Icon(Icons.shopping_cart),
                label: 'Orders',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.people_outline_rounded),
                activeIcon: Icon(Icons.people_rounded),
                label: 'Students',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.book_outlined),
                activeIcon: Icon(Icons.book_rounded),
                label: 'Subjects',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.payment_outlined),
                activeIcon: Icon(Icons.payment_rounded),
                label: 'Payments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long_rounded),
                label: 'Reports',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// Models
// =============================================================================
class Student {
  final int? id;
  final int rollNo;
  final String name;

  const Student({this.id, required this.rollNo, required this.name});

  factory Student.fromMap(Map<String, Object?> map) => Student(
    id: map['id'] as int?,
    rollNo: map['rollNo'] as int,
    name: map['name'] as String,
  );
}

class Subject {
  final int? id;
  final String name;

  const Subject({this.id, required this.name});

  factory Subject.fromMap(Map<String, Object?> map) =>
      Subject(id: map['id'] as int?, name: map['name'] as String);
}

class PaymentMethod {
  final int? id;
  final String name;
  final bool isDefault;

  const PaymentMethod({this.id, required this.name, this.isDefault = false});

  factory PaymentMethod.fromMap(Map<String, Object?> map) => PaymentMethod(
    id: map['id'] as int?,
    name: map['name'] as String,
    isDefault: (map['isDefault'] as int?) == 1,
  );
}

class SessionModel {
  final int? id;
  final int subjectId;
  final String subjectName;
  final String name;
  final double amount;
  final int buyerCount;
  final String createdAt;
  final bool isOrder;
  final int orderMode;
  final int? sourceSessionId;

  const SessionModel({
    this.id,
    required this.subjectId,
    required this.subjectName,
    required this.name,
    required this.amount,
    required this.buyerCount,
    required this.createdAt,
    this.isOrder = false,
    this.orderMode = 0,
    this.sourceSessionId,
  });

  factory SessionModel.fromMap(Map<String, Object?> map) => SessionModel(
    id: map['id'] as int?,
    subjectId: map['subjectId'] as int,
    subjectName: (map['subjectName'] as String?) ?? '',
    name: map['name'] as String,
    amount: (map['amount'] as num).toDouble(),
    buyerCount: (map['buyerCount'] as int?) ?? 0,
    createdAt: map['createdAt'] as String,
    isOrder: (map['isOrder'] as int?) == 1,
    orderMode: (map['orderMode'] as int?) ?? 0,
    sourceSessionId: map['sourceSessionId'] as int?,
  );

  double get expectedTotal => amount * buyerCount;
}

class PaymentRecord {
  final int? id;
  final int sessionId;
  final int studentId;
  final double requiredAmount;
  final double paidAmount;
  final double carriedAmount;
  final String remark;
  final String paymentDate;
  final int? paymentMethodId;
  final String paymentMethodName;
  final String firstPaidAt;
  final double firstPaidAmount;
  final String firstPartialPaidAt;
  final double firstPartialPaidAmount;
  final String firstFullPaidAt;
  final String lastEditedAt;
  final double lastPaidAmount;
  final int paymentCount;
  final String arrivedAt;

  const PaymentRecord({
    this.id,
    required this.sessionId,
    required this.studentId,
    required this.requiredAmount,
    required this.paidAmount,
    this.carriedAmount = 0,
    required this.remark,
    required this.paymentDate,
    this.paymentMethodId,
    this.paymentMethodName = 'Cash',
    this.firstPaidAt = '',
    this.firstPaidAmount = 0,
    this.firstPartialPaidAt = '',
    this.firstPartialPaidAmount = 0,
    this.firstFullPaidAt = '',
    this.lastEditedAt = '',
    this.lastPaidAmount = 0,
    this.paymentCount = 0,
    this.arrivedAt = '',
  });

  factory PaymentRecord.fromMap(Map<String, Object?> map) => PaymentRecord(
    id: map['id'] as int?,
    sessionId: map['sessionId'] as int,
    studentId: map['studentId'] as int,
    requiredAmount: (map['requiredAmount'] as num).toDouble(),
    paidAmount: (map['paidAmount'] as num).toDouble(),
    carriedAmount: (map['carriedAmount'] as num?)?.toDouble() ?? 0.0,
    remark: (map['remark'] as String?) ?? '',
    paymentDate: (map['paymentDate'] as String?) ?? '',
    paymentMethodId: map['paymentMethodId'] as int?,
    paymentMethodName: (map['paymentMethodName'] as String?) ?? 'Cash',
    firstPaidAt: (map['firstPaidAt'] as String?) ?? '',
    firstPaidAmount: (map['firstPaidAmount'] as num?)?.toDouble() ?? 0.0,
    firstPartialPaidAt: (map['firstPartialPaidAt'] as String?) ?? '',
    firstPartialPaidAmount:
        (map['firstPartialPaidAmount'] as num?)?.toDouble() ?? 0.0,
    firstFullPaidAt: (map['firstFullPaidAt'] as String?) ?? '',
    lastEditedAt: (map['lastEditedAt'] as String?) ?? '',
    lastPaidAmount: (map['lastPaidAmount'] as num?)?.toDouble() ?? 0.0,
    paymentCount: (map['paymentCount'] as int?) ?? 0,
    arrivedAt: (map['arrivedAt'] as String?) ?? '',
  );

  double get effectivePaidAmount => paidAmount + carriedAmount;

  String get status {
    if (effectivePaidAmount > requiredAmount) return 'Overpaid';
    if (effectivePaidAmount <= 0) return 'Unpaid';
    if (effectivePaidAmount < requiredAmount) return 'Partial';
    return 'Paid';
  }

  bool get isArrived => arrivedAt.isNotEmpty;

  String get lastActivityTime {
    final times = [
      if (lastEditedAt.isNotEmpty) lastEditedAt,
      if (paymentDate.isNotEmpty) paymentDate,
      if (firstPaidAt.isNotEmpty) firstPaidAt,
    ];
    if (times.isEmpty) return '';
    times.sort();
    return times.last;
  }
}

class PaymentView {
  final PaymentRecord payment;
  final Student student;

  const PaymentView({required this.payment, required this.student});

  String get status => payment.status;
}

class DashboardStats {
  final SessionModel? currentSession;
  final int paidCount;
  final int partialCount;
  final int unpaidCount;
  final int overpaidCount;
  final int totalStudents;
  final int totalSubjects;
  final int totalSessions;
  final double expectedTotal;
  final double collectedTotal;
  final double leftTotal;

  const DashboardStats({
    required this.currentSession,
    required this.paidCount,
    required this.partialCount,
    required this.unpaidCount,
    required this.overpaidCount,
    required this.totalStudents,
    required this.totalSubjects,
    required this.totalSessions,
    required this.expectedTotal,
    required this.collectedTotal,
    required this.leftTotal,
  });
}

// =============================================================================
// Database Helper
// =============================================================================
class DBHelper {
  DBHelper._();
  static final DBHelper instance = DBHelper._();

  static const String _dbName = 'ec_payment_manager.db';
  static const int _dbVersion = 7;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
CREATE TABLE students(
id INTEGER PRIMARY KEY AUTOINCREMENT,
rollNo INTEGER NOT NULL UNIQUE,
name TEXT NOT NULL
)
''');
        await db.execute('''
CREATE TABLE subjects(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL UNIQUE
)
''');
        await db.execute('''
CREATE TABLE payment_methods(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL UNIQUE,
isDefault INTEGER NOT NULL DEFAULT 0
)
''');
        await db.execute(
          "INSERT INTO payment_methods (name, isDefault) VALUES ('Cash', 1)",
        );
        await db.execute(
          "INSERT INTO payment_methods (name, isDefault) VALUES ('Wave Pay', 0)",
        );
        await db.execute(
          "INSERT INTO payment_methods (name, isDefault) VALUES ('KPay', 0)",
        );
        await db.execute(
          "INSERT INTO payment_methods (name, isDefault) VALUES ('KBZ Pay', 0)",
        );
        await db.execute('''
CREATE TABLE sessions(
id INTEGER PRIMARY KEY AUTOINCREMENT,
subjectId INTEGER NOT NULL,
name TEXT NOT NULL,
amount REAL NOT NULL,
buyerCount INTEGER NOT NULL DEFAULT 0,
createdAt TEXT NOT NULL,
isOrder INTEGER NOT NULL DEFAULT 0,
orderMode INTEGER NOT NULL DEFAULT 0,
sourceSessionId INTEGER,
FOREIGN KEY(subjectId) REFERENCES subjects(id) ON DELETE CASCADE,
FOREIGN KEY(sourceSessionId) REFERENCES sessions(id) ON DELETE SET NULL
)
''');
        await db.execute('''
CREATE TABLE payments(
id INTEGER PRIMARY KEY AUTOINCREMENT,
sessionId INTEGER NOT NULL,
studentId INTEGER NOT NULL,
requiredAmount REAL NOT NULL,
paidAmount REAL NOT NULL DEFAULT 0,
carriedAmount REAL NOT NULL DEFAULT 0,
remark TEXT NOT NULL DEFAULT '',
paymentDate TEXT NOT NULL DEFAULT '',
paymentMethodId INTEGER,
paymentMethodName TEXT DEFAULT 'Cash',
firstPaidAt TEXT NOT NULL DEFAULT '',
firstPaidAmount REAL NOT NULL DEFAULT 0,
firstPartialPaidAt TEXT NOT NULL DEFAULT '',
firstPartialPaidAmount REAL NOT NULL DEFAULT 0,
firstFullPaidAt TEXT NOT NULL DEFAULT '',
lastEditedAt TEXT NOT NULL DEFAULT '',
lastPaidAmount REAL NOT NULL DEFAULT 0,
paymentCount INTEGER NOT NULL DEFAULT 0,
arrivedAt TEXT NOT NULL DEFAULT '',
UNIQUE(sessionId, studentId),
FOREIGN KEY(sessionId) REFERENCES sessions(id) ON DELETE CASCADE,
FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE,
FOREIGN KEY(paymentMethodId) REFERENCES payment_methods(id)
)
''');
        await db.execute('''
CREATE TABLE payment_history(
id INTEGER PRIMARY KEY AUTOINCREMENT,
paymentId INTEGER NOT NULL,
sessionId INTEGER NOT NULL,
studentId INTEGER NOT NULL,
actionType TEXT NOT NULL,
requiredAmount REAL NOT NULL,
carriedAmount REAL NOT NULL DEFAULT 0,
previousPaidAmount REAL NOT NULL DEFAULT 0,
previousEffectivePaidAmount REAL NOT NULL DEFAULT 0,
paidAmount REAL NOT NULL DEFAULT 0,
effectivePaidAmount REAL NOT NULL DEFAULT 0,
paymentMethodId INTEGER,
paymentMethodName TEXT DEFAULT 'Cash',
remark TEXT NOT NULL DEFAULT '',
createdAt TEXT NOT NULL,
FOREIGN KEY(paymentId) REFERENCES payments(id) ON DELETE CASCADE,
FOREIGN KEY(sessionId) REFERENCES sessions(id) ON DELETE CASCADE,
FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE,
FOREIGN KEY(paymentMethodId) REFERENCES payment_methods(id)
)
''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE sessions ADD COLUMN buyerCount INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 4) {
          await db.execute(
            'ALTER TABLE sessions ADD COLUMN isOrder INTEGER NOT NULL DEFAULT 0',
          );
        }
        if (oldVersion < 5) {
          await db.execute(
            'ALTER TABLE sessions ADD COLUMN orderMode INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute('''
CREATE TABLE payment_methods(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL UNIQUE,
isDefault INTEGER NOT NULL DEFAULT 0
)
''');
          await db.execute(
            "INSERT INTO payment_methods (name, isDefault) VALUES ('Cash', 1)",
          );
          await db.execute(
            "INSERT INTO payment_methods (name, isDefault) VALUES ('Wave Pay', 0)",
          );
          await db.execute(
            "INSERT INTO payment_methods (name, isDefault) VALUES ('KPay', 0)",
          );
          await db.execute(
            "INSERT INTO payment_methods (name, isDefault) VALUES ('KBZ Pay', 0)",
          );
          await db.execute(
            'ALTER TABLE payments ADD COLUMN paymentMethodId INTEGER',
          );
          await db.execute(
            "ALTER TABLE payments ADD COLUMN paymentMethodName TEXT DEFAULT 'Cash'",
          );
        }
        if (oldVersion < 6) {
          await db.execute(
            'ALTER TABLE sessions ADD COLUMN sourceSessionId INTEGER',
          );
          await db.execute(
            'ALTER TABLE payments ADD COLUMN carriedAmount REAL NOT NULL DEFAULT 0',
          );
          await db.execute(
            "ALTER TABLE payments ADD COLUMN firstPaidAt TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE payments ADD COLUMN firstPaidAmount REAL NOT NULL DEFAULT 0',
          );
          await db.execute(
            "ALTER TABLE payments ADD COLUMN firstPartialPaidAt TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE payments ADD COLUMN firstPartialPaidAmount REAL NOT NULL DEFAULT 0',
          );
          await db.execute(
            "ALTER TABLE payments ADD COLUMN firstFullPaidAt TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            "ALTER TABLE payments ADD COLUMN lastEditedAt TEXT NOT NULL DEFAULT ''",
          );
          await db.execute(
            'ALTER TABLE payments ADD COLUMN lastPaidAmount REAL NOT NULL DEFAULT 0',
          );
          await db.execute(
            'ALTER TABLE payments ADD COLUMN paymentCount INTEGER NOT NULL DEFAULT 0',
          );
          await db.execute('''
CREATE TABLE IF NOT EXISTS payment_history(
id INTEGER PRIMARY KEY AUTOINCREMENT,
paymentId INTEGER NOT NULL,
sessionId INTEGER NOT NULL,
studentId INTEGER NOT NULL,
actionType TEXT NOT NULL,
requiredAmount REAL NOT NULL,
carriedAmount REAL NOT NULL DEFAULT 0,
previousPaidAmount REAL NOT NULL DEFAULT 0,
previousEffectivePaidAmount REAL NOT NULL DEFAULT 0,
paidAmount REAL NOT NULL DEFAULT 0,
effectivePaidAmount REAL NOT NULL DEFAULT 0,
paymentMethodId INTEGER,
paymentMethodName TEXT DEFAULT 'Cash',
remark TEXT NOT NULL DEFAULT '',
createdAt TEXT NOT NULL,
FOREIGN KEY(paymentId) REFERENCES payments(id) ON DELETE CASCADE,
FOREIGN KEY(sessionId) REFERENCES sessions(id) ON DELETE CASCADE,
FOREIGN KEY(studentId) REFERENCES students(id) ON DELETE CASCADE,
FOREIGN KEY(paymentMethodId) REFERENCES payment_methods(id)
)
''');
        }
        if (oldVersion < 7) {
          await db.execute(
            "ALTER TABLE payments ADD COLUMN arrivedAt TEXT NOT NULL DEFAULT ''",
          );
        }
      },
    );
  }

  Future<List<Student>> getStudents() async {
    final db = await database;
    final rows = await db.query('students', orderBy: 'rollNo ASC');
    return rows.map(Student.fromMap).toList();
  }

  Future<int> insertStudent(Student student) async {
    final db = await database;
    return db.insert('students', {
      'rollNo': student.rollNo,
      'name': student.name,
    });
  }

  Future<int> updateStudent(Student student) async {
    final db = await database;
    return db.update(
      'students',
      {'rollNo': student.rollNo, 'name': student.name},
      where: 'id = ?',
      whereArgs: [student.id],
    );
  }

  Future<int> deleteStudent(int id) async {
    final db = await database;
    return db.delete('students', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Subject>> getSubjects() async {
    final db = await database;
    final rows = await db.query('subjects', orderBy: 'name ASC');
    return rows.map(Subject.fromMap).toList();
  }

  Future<int> insertSubject(Subject subject) async {
    final db = await database;
    return db.insert('subjects', {'name': subject.name});
  }

  Future<int> updateSubject(Subject subject) async {
    final db = await database;
    return db.update(
      'subjects',
      {'name': subject.name},
      where: 'id = ?',
      whereArgs: [subject.id],
    );
  }

  Future<int> deleteSubject(int id) async {
    final db = await database;
    return db.delete('subjects', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<PaymentMethod>> getPaymentMethods() async {
    final db = await database;
    await _ensureCorePaymentMethods(db);
    final rows = await db.query(
      'payment_methods',
      orderBy: 'isDefault DESC, name ASC',
    );
    return rows.map(PaymentMethod.fromMap).toList();
  }

  Future<void> _ensureCorePaymentMethods(Database db) async {
    final methods = <Map<String, Object>>[
      {'name': 'Cash', 'isDefault': 1},
      {'name': 'Wave Pay', 'isDefault': 0},
      {'name': 'KPay', 'isDefault': 0},
    ];

    for (final method in methods) {
      final name = method['name'] as String;
      final isDefault = method['isDefault'] as int;
      final existing = await db.query(
        'payment_methods',
        where: 'LOWER(name) = LOWER(?)',
        whereArgs: [name],
        limit: 1,
      );
      if (existing.isEmpty) {
        await db.insert('payment_methods', {
          'name': name,
          'isDefault': isDefault,
        });
      }
    }

    final hasDefault = (await db.query(
      'payment_methods',
      where: 'isDefault = 1',
    )).isNotEmpty;
    if (!hasDefault) {
      await db.update(
        'payment_methods',
        {'isDefault': 1},
        where: 'LOWER(name) = LOWER(?)',
        whereArgs: ['Cash'],
      );
    }
  }

  Future<double> getCarriedPrepaidAmount({
    required int studentId,
    required int subjectId,
    int? sourceSessionId,
  }) async {
    final db = await database;

    Future<double> sumPaymentsForSession(int sessionId) async {
      final rows = await db.query(
        'payments',
        columns: ['paidAmount'],
        where: 'sessionId = ? AND studentId = ?',
        whereArgs: [sessionId, studentId],
        limit: 1,
      );
      if (rows.isEmpty) return 0.0;
      return (rows.first['paidAmount'] as num?)?.toDouble() ?? 0.0;
    }

    if (sourceSessionId != null) {
      final source = await db.query(
        'sessions',
        columns: ['id'],
        where: 'id = ? AND isOrder = 1 AND orderMode = 0',
        whereArgs: [sourceSessionId],
        limit: 1,
      );
      if (source.isNotEmpty) {
        return sumPaymentsForSession(sourceSessionId);
      }
    }

    final sessions = await db.query(
      'sessions',
      columns: ['id'],
      where: 'subjectId = ? AND isOrder = 1 AND orderMode = 0',
      whereArgs: [subjectId],
      orderBy: 'id ASC',
    );

    double carried = 0;
    for (final session in sessions) {
      carried += await sumPaymentsForSession(session['id'] as int);
    }
    return carried;
  }

  Future<int> insertPaymentMethod(PaymentMethod method) async {
    final db = await database;
    if (method.isDefault) {
      await db.update('payment_methods', {'isDefault': 0});
    }
    return db.insert('payment_methods', {
      'name': method.name,
      'isDefault': method.isDefault ? 1 : 0,
    });
  }

  Future<int> updatePaymentMethod(PaymentMethod method) async {
    final db = await database;
    if (method.isDefault) {
      await db.update('payment_methods', {'isDefault': 0});
    }
    return db.update(
      'payment_methods',
      {'name': method.name, 'isDefault': method.isDefault ? 1 : 0},
      where: 'id = ?',
      whereArgs: [method.id],
    );
  }

  Future<int> deletePaymentMethod(int id) async {
    final db = await database;
    return db.delete('payment_methods', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<SessionModel>> getSessions({
    int? subjectId,
    bool? isOrder,
    int? orderMode,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (subjectId != null) {
      whereClause = 'sessions.subjectId = ?';
      whereArgs.add(subjectId);
    }
    if (isOrder != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'sessions.isOrder = ?';
      whereArgs.add(isOrder ? 1 : 0);
    }
    if (orderMode != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'sessions.orderMode = ?';
      whereArgs.add(orderMode);
    }

    final rows = await db.rawQuery('''
SELECT sessions.id,
sessions.subjectId,
sessions.name,
sessions.amount,
sessions.buyerCount,
sessions.createdAt,
sessions.isOrder,
sessions.orderMode,
sessions.sourceSessionId,
subjects.name AS subjectName
FROM sessions
INNER JOIN subjects ON subjects.id = sessions.subjectId
${whereClause.isNotEmpty ? 'WHERE $whereClause' : ''}
ORDER BY sessions.id DESC
''', whereArgs);

    return rows.map(SessionModel.fromMap).toList();
  }

  Future<int> insertSession(SessionModel session) async {
    final db = await database;
    return db.insert('sessions', {
      'subjectId': session.subjectId,
      'name': session.name,
      'amount': session.amount,
      'buyerCount': session.buyerCount,
      'createdAt': session.createdAt,
      'isOrder': session.isOrder ? 1 : 0,
      'orderMode': session.orderMode,
      'sourceSessionId': session.sourceSessionId,
    });
  }

  Future<int> insertSessionWithPayments(
    SessionModel session, {
    List<int>? selectedStudentIds,
  }) async {
    final db = await database;
    return db.transaction<int>((txn) async {
      final sessionId = await txn.insert('sessions', {
        'subjectId': session.subjectId,
        'name': session.name,
        'amount': session.amount,
        'buyerCount': session.buyerCount,
        'createdAt': session.createdAt,
        'isOrder': session.isOrder ? 1 : 0,
        'orderMode': session.orderMode,
        'sourceSessionId': session.sourceSessionId,
      });

      List<Map<String, Object?>> students;
      if (selectedStudentIds != null && selectedStudentIds.isNotEmpty) {
        final ids = selectedStudentIds.toSet().toList()..sort();
        final placeholders = List.filled(ids.length, '?').join(', ');
        students = await txn.query(
          'students',
          where: 'id IN ($placeholders)',
          whereArgs: ids,
          orderBy: 'rollNo ASC',
        );
      } else {
        students = await txn.query('students', orderBy: 'rollNo ASC');
      }

      for (final row in students) {
        await txn.insert('payments', {
          'sessionId': sessionId,
          'studentId': row['id'],
          'requiredAmount': session.amount,
          'paidAmount': 0.0,
          'carriedAmount': 0.0,
          'remark': '',
          'paymentDate': '',
          'paymentMethodId': null,
          'paymentMethodName': 'Cash',
          'firstPaidAt': '',
          'firstPaidAmount': 0.0,
          'firstPartialPaidAt': '',
          'firstPartialPaidAmount': 0.0,
          'firstFullPaidAt': '',
          'lastEditedAt': '',
          'lastPaidAmount': 0.0,
          'paymentCount': 0,
          'arrivedAt': '',
        }, conflictAlgorithm: ConflictAlgorithm.ignore);
      }
      return sessionId;
    });
  }

  Future<int> updateSession(SessionModel session) async {
    final db = await database;
    return db.update(
      'sessions',
      {
        'subjectId': session.subjectId,
        'name': session.name,
        'amount': session.amount,
        'buyerCount': session.buyerCount,
        'createdAt': session.createdAt,
        'isOrder': session.isOrder ? 1 : 0,
        'orderMode': session.orderMode,
        'sourceSessionId': session.sourceSessionId,
      },
      where: 'id = ?',
      whereArgs: [session.id],
    );
  }

  Future<int> deleteSession(int id) async {
    final db = await database;
    return db.delete('sessions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<int>> getSelectedStudentIdsForSession(int sessionId) async {
    final db = await database;
    final rows = await db.query(
      'payments',
      columns: ['studentId'],
      where: 'sessionId = ?',
      whereArgs: [sessionId],
    );
    return rows.map((r) => r['studentId'] as int).toList();
  }

  Future<void> updateOrderStudents(
    int sessionId,
    List<int> selectedStudentIds,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      final existing = await txn.query(
        'payments',
        where: 'sessionId = ?',
        whereArgs: [sessionId],
      );
      final existingMap = {
        for (var row in existing) row['studentId'] as int: row,
      };

      final session = await txn.query(
        'sessions',
        columns: ['amount'],
        where: 'id = ?',
        whereArgs: [sessionId],
        limit: 1,
      );
      final requiredAmount = session.isNotEmpty
          ? (session.first['amount'] as num).toDouble()
          : 0.0;

      // Add new students
      for (final studentId in selectedStudentIds) {
        if (!existingMap.containsKey(studentId)) {
          await txn.insert('payments', {
            'sessionId': sessionId,
            'studentId': studentId,
            'requiredAmount': requiredAmount,
            'paidAmount': 0.0,
            'carriedAmount': 0.0,
            'remark': '',
            'paymentDate': '',
            'paymentMethodId': null,
            'paymentMethodName': 'Cash',
            'firstPaidAt': '',
            'firstPaidAmount': 0.0,
            'firstPartialPaidAt': '',
            'firstPartialPaidAmount': 0.0,
            'firstFullPaidAt': '',
            'lastEditedAt': '',
            'lastPaidAmount': 0.0,
            'paymentCount': 0,
            'arrivedAt': '',
          });
        }
      }

      // Remove unselected students
      for (final entry in existingMap.entries) {
        if (!selectedStudentIds.contains(entry.key)) {
          await txn.delete(
            'payments',
            where: 'id = ?',
            whereArgs: [entry.value['id']],
          );
        }
      }

      await txn.update(
        'sessions',
        {'buyerCount': selectedStudentIds.length},
        where: 'id = ?',
        whereArgs: [sessionId],
      );
    });
  }

  Future<List<PaymentView>> getPaymentsForSession(int sessionId) async {
    final db = await database;
    final sessionRows = await db.query(
      'sessions',
      columns: ['subjectId', 'orderMode', 'sourceSessionId', 'amount'],
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    final sessionAmount = sessionRows.isNotEmpty
        ? (sessionRows.first['amount'] as num).toDouble()
        : 0.0;
    final sessionSubjectId = sessionRows.isNotEmpty
        ? sessionRows.first['subjectId'] as int
        : null;
    final sourceSessionId = sessionRows.isNotEmpty
        ? sessionRows.first['sourceSessionId'] as int?
        : null;
    final isArrivalMode =
        sessionRows.isNotEmpty && (sessionRows.first['orderMode'] as int?) == 1;
    final isOrder =
        sessionRows.isNotEmpty && (sessionRows.first['isOrder'] as int?) == 1;

    final rows = await db.rawQuery(
      '''
SELECT p.id AS paymentId,
p.sessionId,
p.studentId,
p.requiredAmount,
p.paidAmount,
p.carriedAmount,
p.remark,
p.paymentDate,
p.paymentMethodId,
p.paymentMethodName,
p.firstPaidAt,
p.firstPaidAmount,
p.firstPartialPaidAt,
p.firstPartialPaidAmount,
p.firstFullPaidAt,
p.lastEditedAt,
p.lastPaidAmount,
p.paymentCount,
p.arrivedAt,
s.id AS realStudentId,
s.rollNo,
s.name AS studentName
FROM payments p
INNER JOIN students s ON s.id = p.studentId
WHERE p.sessionId = ?
ORDER BY s.rollNo ASC
''',
      [sessionId],
    );

    final views = <PaymentView>[];
    for (final row in rows) {
      final rawPaidAmount = (row['paidAmount'] as num).toDouble();
      final storedCarried = (row['carriedAmount'] as num?)?.toDouble() ?? 0.0;
      double carriedAmount = storedCarried;

      if (isArrivalMode && sessionSubjectId != null) {
        carriedAmount = await getCarriedPrepaidAmount(
          studentId: row['studentId'] as int,
          subjectId: sessionSubjectId,
          sourceSessionId: sourceSessionId,
        );
      } else if (isOrder) {
        carriedAmount = 0.0;
      }

      views.add(
        PaymentView(
          payment: PaymentRecord(
            id: row['paymentId'] as int,
            sessionId: row['sessionId'] as int,
            studentId: row['studentId'] as int,
            requiredAmount: sessionAmount,
            paidAmount: rawPaidAmount,
            carriedAmount: carriedAmount,
            remark: (row['remark'] as String?) ?? '',
            paymentDate: (row['paymentDate'] as String?) ?? '',
            paymentMethodId: row['paymentMethodId'] as int?,
            paymentMethodName: (row['paymentMethodName'] as String?) ?? 'Cash',
            firstPaidAt: (row['firstPaidAt'] as String?) ?? '',
            firstPaidAmount:
                (row['firstPaidAmount'] as num?)?.toDouble() ?? 0.0,
            firstPartialPaidAt: (row['firstPartialPaidAt'] as String?) ?? '',
            firstPartialPaidAmount:
                (row['firstPartialPaidAmount'] as num?)?.toDouble() ?? 0.0,
            firstFullPaidAt: (row['firstFullPaidAt'] as String?) ?? '',
            lastEditedAt: (row['lastEditedAt'] as String?) ?? '',
            lastPaidAmount: (row['lastPaidAmount'] as num?)?.toDouble() ?? 0.0,
            paymentCount: (row['paymentCount'] as int?) ?? 0,
            arrivedAt: (row['arrivedAt'] as String?) ?? '',
          ),
          student: Student(
            id: row['realStudentId'] as int,
            rollNo: row['rollNo'] as int,
            name: row['studentName'] as String,
          ),
        ),
      );
    }
    return views;
  }

  Future<void> updatePayment({
    required int paymentId,
    required double paidAmount,
    required String remark,
    int? paymentMethodId,
    String paymentMethodName = 'Cash',
  }) async {
    final db = await database;
    await db.transaction((txn) async {
      final currentRows = await txn.query(
        'payments',
        where: 'id = ?',
        whereArgs: [paymentId],
        limit: 1,
      );
      if (currentRows.isEmpty) return;

      final current = currentRows.first;
      final previousPaidAmount =
          (current['paidAmount'] as num?)?.toDouble() ?? 0.0;
      final carriedAmount =
          (current['carriedAmount'] as num?)?.toDouble() ?? 0.0;
      final previousEffectivePaidAmount = previousPaidAmount + carriedAmount;
      final requiredAmount =
          (current['requiredAmount'] as num?)?.toDouble() ?? 0.0;

      final now = DateTime.now().toIso8601String();
      final newEffectivePaidAmount = paidAmount + carriedAmount;

      final wasUnpaid = previousEffectivePaidAmount <= 0;
      final wasPartial =
          previousEffectivePaidAmount > 0 &&
          previousEffectivePaidAmount < requiredAmount;
      final nowPartial =
          newEffectivePaidAmount > 0 && newEffectivePaidAmount < requiredAmount;
      final nowFull = newEffectivePaidAmount >= requiredAmount;

      final updates = <String, Object?>{
        'paidAmount': paidAmount,
        'remark': remark,
        'paymentDate': now,
        'paymentMethodId': paymentMethodId,
        'paymentMethodName': paymentMethodName,
        'lastEditedAt': now,
        'lastPaidAmount': paidAmount,
        'paymentCount': ((current['paymentCount'] as int?) ?? 0) + 1,
      };

      if (wasUnpaid && paidAmount > 0) {
        updates['firstPaidAt'] = now;
        updates['firstPaidAmount'] = paidAmount;
      }
      if (!wasPartial && nowPartial) {
        updates['firstPartialPaidAt'] = now;
        updates['firstPartialPaidAmount'] = paidAmount;
      }
      if (previousEffectivePaidAmount < requiredAmount &&
          newEffectivePaidAmount >= requiredAmount &&
          (current['firstFullPaidAt'] as String?)?.isNotEmpty != true) {
        updates['firstFullPaidAt'] = now;
      }

      await txn.update(
        'payments',
        updates,
        where: 'id = ?',
        whereArgs: [paymentId],
      );

      final actionType = nowFull
          ? 'FULL_PAID'
          : (nowPartial ? 'PARTIAL_PAID' : 'RESET_OR_EDIT');
      await txn.insert('payment_history', {
        'paymentId': paymentId,
        'sessionId': current['sessionId'],
        'studentId': current['studentId'],
        'actionType': actionType,
        'requiredAmount': requiredAmount,
        'carriedAmount': carriedAmount,
        'previousPaidAmount': previousPaidAmount,
        'previousEffectivePaidAmount': previousEffectivePaidAmount,
        'paidAmount': paidAmount,
        'effectivePaidAmount': newEffectivePaidAmount,
        'paymentMethodId': paymentMethodId,
        'paymentMethodName': paymentMethodName,
        'remark': remark,
        'createdAt': now,
      });
    });
  }

  Future<void> markArrived(int paymentId) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.update(
      'payments',
      {'arrivedAt': now},
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  Future<void> unmarkArrived(int paymentId) async {
    final db = await database;
    await db.update(
      'payments',
      {'arrivedAt': ''},
      where: 'id = ?',
      whereArgs: [paymentId],
    );
  }

  Future<List<Map<String, Object?>>> getPaymentHistory({
    int? sessionId,
    int? studentId,
  }) async {
    final db = await database;
    final where = <String>[];
    final args = <Object?>[];

    if (sessionId != null) {
      where.add('ph.sessionId = ?');
      args.add(sessionId);
    }
    if (studentId != null) {
      where.add('ph.studentId = ?');
      args.add(studentId);
    }

    final whereClause = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    return db.rawQuery('''
SELECT ph.*,
s.name AS sessionName,
sub.name AS subjectName
FROM payment_history ph
INNER JOIN sessions s ON s.id = ph.sessionId
INNER JOIN subjects sub ON sub.id = s.subjectId
$whereClause
ORDER BY ph.createdAt ASC, ph.id ASC
''', args);
  }

  Future<DashboardStats> getDashboardStats({int? sessionId}) async {
    final students = await getStudents();
    final subjects = await getSubjects();
    final sessions = await getSessions();

    SessionModel? selected;
    if (sessions.isNotEmpty) {
      if (sessionId == null) {
        selected = sessions.first;
      } else {
        for (final s in sessions) {
          if (s.id == sessionId) {
            selected = s;
            break;
          }
        }
        selected ??= sessions.first;
      }
    }

    int paid = 0;
    int partial = 0;
    int unpaid = 0;
    int overpaid = 0;
    double expected = 0;
    double collected = 0;

    if (selected != null && selected.id != null) {
      final items = await getPaymentsForSession(selected.id!);
      expected = selected.expectedTotal;
      for (final item in items) {
        collected += item.payment.effectivePaidAmount;
        switch (item.status) {
          case 'Paid':
            paid++;
            break;
          case 'Partial':
            partial++;
            break;
          case 'Overpaid':
            overpaid++;
            break;
          default:
            unpaid++;
        }
      }
    }

    final left = expected - collected;
    return DashboardStats(
      currentSession: selected,
      paidCount: paid,
      partialCount: partial,
      unpaidCount: unpaid,
      overpaidCount: overpaid,
      totalStudents: students.length,
      totalSubjects: subjects.length,
      totalSessions: sessions.length,
      expectedTotal: expected,
      collectedTotal: collected,
      leftTotal: left < 0 ? 0 : left,
    );
  }
}

// =============================================================================
// Dashboard Page
// =============================================================================
class DashboardPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const DashboardPage({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _loading = true;
  List<Subject> _subjects = [];
  List<SessionModel> _sessions = [];
  int? _selectedSubjectId;
  int? _selectedSessionId;
  DashboardStats? _stats;
  List<PaymentView> _allPayments = [];
  List<PaymentView> _filteredPayments = [];
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant DashboardPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _reload();
    }
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _subjects = await DBHelper.instance.getSubjects();
    if (_subjects.isNotEmpty && _selectedSubjectId == null) {
      _selectedSubjectId = _subjects.first.id;
    }
    _sessions = await DBHelper.instance.getSessions(
      subjectId: _selectedSubjectId,
      isOrder: false,
    );
    if (_sessions.isNotEmpty) {
      if (_selectedSessionId == null ||
          _sessions.every((s) => s.id != _selectedSessionId)) {
        _selectedSessionId = _sessions.first.id;
      }
      _stats = await DBHelper.instance.getDashboardStats(
        sessionId: _selectedSessionId,
      );
      _allPayments = await DBHelper.instance.getPaymentsForSession(
        _selectedSessionId!,
      );
      _applyFilters();
    } else {
      _selectedSessionId = null;
      _stats = await DBHelper.instance.getDashboardStats();
      _allPayments = [];
      _filteredPayments = [];
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _applyFilters() {
    List<PaymentView> filtered = _allPayments;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((payment) {
        final searchText = _searchQuery.toLowerCase();
        return payment.student.name.toLowerCase().contains(searchText) ||
            payment.student.rollNo.toString().contains(searchText);
      }).toList();
    }
    if (_filterStatus != 'all') {
      filtered = filtered.where((payment) {
        if (_filterStatus == 'paid') return payment.status == 'Paid';
        if (_filterStatus == 'partial') return payment.status == 'Partial';
        if (_filterStatus == 'unpaid') return payment.status == 'Unpaid';
        if (_filterStatus == 'overpaid') return payment.status == 'Overpaid';
        return true;
      }).toList();
    }
    setState(() {
      _filteredPayments = filtered;
    });
  }

  Future<void> _updateSinglePayment(
    int paymentId,
    double paidAmount,
    String remark,
    int? paymentMethodId,
    String paymentMethodName,
  ) async {
    await DBHelper.instance.updatePayment(
      paymentId: paymentId,
      paidAmount: paidAmount,
      remark: remark,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
    );
    final index = _allPayments.indexWhere((p) => p.payment.id == paymentId);
    if (index != -1) {
      final oldPayment = _allPayments[index];
      final updatedPayment = PaymentView(
        payment: PaymentRecord(
          id: oldPayment.payment.id,
          sessionId: oldPayment.payment.sessionId,
          studentId: oldPayment.payment.studentId,
          requiredAmount: oldPayment.payment.requiredAmount,
          paidAmount: paidAmount,
          carriedAmount: oldPayment.payment.carriedAmount,
          remark: remark,
          paymentDate: DateTime.now().toIso8601String(),
          paymentMethodId: paymentMethodId,
          paymentMethodName: paymentMethodName,
        ),
        student: oldPayment.student,
      );
      _allPayments[index] = updatedPayment;
      _applyFilters();
    }
    if (_selectedSessionId != null) {
      _stats = await DBHelper.instance.getDashboardStats(
        sessionId: _selectedSessionId,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  SessionModel? get _currentSession {
    for (final s in _sessions) {
      if (s.id == _selectedSessionId) return s;
    }
    return _sessions.isNotEmpty ? _sessions.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final session = _currentSession;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _reload();
            widget.onChanged();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildFiltersCard(),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (session == null)
                SliverToBoxAdapter(child: _buildEmptyState())
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSessionCard(session),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatsGrid(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSearchAndFilterBar(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPaymentList(session),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5B2AA6).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EC Payment Manager',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B2AA6),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Payment Sessions',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildDropdown(
              label: 'Subject',
              icon: Icons.book_outlined,
              value: _selectedSubjectId,
              items: _subjects
                  .where((s) => s.id != null)
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedSubjectId = value;
                  _selectedSessionId = null;
                });
                await _reload();
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _buildDropdown(
              label: 'Session',
              icon: Icons.event_note_outlined,
              value: _selectedSessionId,
              items: _sessions
                  .where((s) => s.id != null)
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                setState(() => _selectedSessionId = value);
                _stats = await DBHelper.instance.getDashboardStats(
                  sessionId: value,
                );
                _allPayments = await DBHelper.instance.getPaymentsForSession(
                  value!,
                );
                _applyFilters();
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: _showSessionDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New', style: TextStyle(fontSize: 11)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B2AA6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                minimumSize: const Size(0, 0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(icon, size: 18, color: const Color(0xFF5B2AA6)),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              items: items.isEmpty
                  ? [const DropdownMenuItem(child: Text('None'))]
                  : items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5B2AA6).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.subjectName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount per Student',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    child: Text(
                      _fmtMoney(session.amount),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${session.buyerCount} Students',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fmtDateShort(session.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMoneyStat(
                    'Total Expected',
                    _fmtMoney(_stats?.expectedTotal ?? 0),
                    Colors.white,
                  ),
                ),
                Container(
                  width: 1,
                  height: 45,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMoneyStat(
                    'Collected',
                    _fmtMoney(_stats?.collectedTotal ?? 0),
                    Colors.green.shade300,
                  ),
                ),
                Container(
                  width: 1,
                  height: 45,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMoneyStat(
                    'Remaining',
                    _fmtMoney(_stats?.leftTotal ?? 0),
                    Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: [
        _buildStatCard(
          'Unpaid',
          _stats?.unpaidCount ?? 0,
          Colors.red,
          Icons.cancel_rounded,
          Colors.red.shade50,
        ),
        _buildStatCard(
          'Partial',
          _stats?.partialCount ?? 0,
          Colors.orange,
          Icons.timelapse_rounded,
          Colors.orange.shade50,
        ),
        _buildStatCard(
          'Paid',
          _stats?.paidCount ?? 0,
          Colors.green,
          Icons.check_circle_rounded,
          Colors.green.shade50,
        ),
        _buildStatCard(
          'Overpaid',
          _stats?.overpaidCount ?? 0,
          Colors.purple,
          Icons.warning_rounded,
          Colors.purple.shade50,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    int value,
    Color color,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by roll no. or name...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton('all', 'All', Icons.list),
              const SizedBox(width: 8),
              _buildFilterButton('paid', 'Paid', Icons.check_circle),
              const SizedBox(width: 8),
              _buildFilterButton('partial', 'Partial', Icons.timelapse),
              const SizedBox(width: 8),
              _buildFilterButton('unpaid', 'Unpaid', Icons.cancel),
              const SizedBox(width: 8),
              _buildFilterButton('overpaid', 'Overpaid', Icons.warning),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String status, String label, IconData icon) {
    final isActive = _filterStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF5B2AA6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF5B2AA6).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 22 : 18,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isActive ? 13 : 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(SessionModel session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(40),
                1: FlexColumnWidth(2.5),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2.5),
                4: FixedColumnWidth(50),
              },
              children: [
                TableRow(
                  children: [
                    const SizedBox.shrink(),
                    _tableHeader('Student'),
                    _tableHeader('Status'),
                    _tableHeader('Payment'),
                    const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
          if (_filteredPayments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'No students found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ..._filteredPayments.map((item) => _buildPaymentRow(item, session)),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaymentRow(PaymentView item, SessionModel session) {
    final isPaid = item.status == 'Paid' || item.status == 'Overpaid';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isPaid ? Colors.green.shade50 : Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(40),
          1: FlexColumnWidth(2.5),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2.5),
          4: FixedColumnWidth(50),
        },
        children: [
          TableRow(
            children: [
              Checkbox(
                value: isPaid,
                activeColor: const Color(0xFF5B2AA6),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: isPaid
                    ? null
                    : (val) async {
                        if (val == true) {
                          final methods = await DBHelper.instance
                              .getPaymentMethods();
                          final defaultMethod = methods.firstWhere(
                            (m) => m.isDefault,
                            orElse: () => methods.first,
                          );
                          final remaining =
                              item.payment.requiredAmount -
                              item.payment.effectivePaidAmount;
                          if (remaining > 0) {
                            await _updateSinglePayment(
                              item.payment.id!,
                              item.payment.paidAmount + remaining,
                              'Full paid via checkbox',
                              defaultMethod.id,
                              defaultMethod.name,
                            );
                          }
                        }
                      },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.student.name.isEmpty
                        ? 'Roll ${item.student.rollNo}'
                        : item.student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Roll ${item.student.rollNo}',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Center(child: _buildStatusChip(item.status)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fmtMoney(item.payment.effectivePaidAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _getStatusColor(item.status),
                    ),
                  ),
                  Text(
                    item.payment.paymentMethodName.isEmpty
                        ? 'Cash'
                        : item.payment.paymentMethodName,
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _recordPayment(context, session, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5B2AA6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '\$',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.shade700;
      case 'Overpaid':
        return Colors.purple.shade700;
      case 'Partial':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildStatusChip(String status) {
    final config = {
      'Unpaid': {
        'color': Colors.red,
        'bgColor': Colors.red.shade50,
        'icon': Icons.cancel_rounded,
      },
      'Partial': {
        'color': Colors.orange,
        'bgColor': Colors.orange.shade50,
        'icon': Icons.timelapse_rounded,
      },
      'Paid': {
        'color': Colors.green,
        'bgColor': Colors.green.shade50,
        'icon': Icons.check_circle_rounded,
      },
      'Overpaid': {
        'color': Colors.purple,
        'bgColor': Colors.purple.shade50,
        'icon': Icons.warning_rounded,
      },
    }[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (config['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 10,
            color: config['color'] as Color,
          ),
          const SizedBox(width: 2),
          Text(
            status,
            style: TextStyle(
              color: config['color'] as Color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          const Text(
            'No Session Selected',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create a subject and session to start managing payments',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _showSessionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create New Session'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B2AA6),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showSessionDialog() async {
    final subjects = await DBHelper.instance.getSubjects();
    final students = await DBHelper.instance.getStudents();

    if (subjects.isEmpty) {
      if (!mounted) return;
      _showModernSnackBar('Create a subject first.', Colors.orange);
      return;
    }
    if (students.isEmpty) {
      if (!mounted) return;
      _showModernSnackBar('Add students first.', Colors.orange);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final sessionName = TextEditingController();
    final amount = TextEditingController(text: '5000');
    final buyers = TextEditingController(text: students.length.toString());
    int selectedSubjectId = _selectedSubjectId ?? subjects.first.id!;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'New Session',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Subject',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedSubjectId,
                              isExpanded: true,
                              items: subjects
                                  .where((s) => s.id != null)
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s.id,
                                      child: Text(s.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setLocalState(() => selectedSubjectId = v!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Session Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: sessionName,
                          decoration: InputDecoration(
                            hintText: 'e.g. DS Chapter 3',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F3FA),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter session name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Amount per Student',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: amount,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Color(0xFF5B2AA6),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F3FA),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter amount';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Amount must be numeric';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Number of Students',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: buyers,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.people_outline,
                              color: Color(0xFF5B2AA6),
                            ),
                            helperText: 'Default: ${students.length} students',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F3FA),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter number of students';
                            }
                            final n = int.tryParse(v.trim());
                            if (n == null) return 'Must be numeric';
                            if (n <= 0) return 'Must be greater than 0';
                            if (n > students.length) {
                              return 'Cannot exceed total students';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5B2AA6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Save Session'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved != true) return;
    if (!formKey.currentState!.validate()) return;

    await DBHelper.instance.insertSessionWithPayments(
      SessionModel(
        id: null,
        subjectId: selectedSubjectId,
        subjectName: '',
        name: sessionName.text.trim(),
        amount: double.parse(amount.text.trim()),
        buyerCount: int.parse(buyers.text.trim()),
        createdAt: DateTime.now().toIso8601String(),
        isOrder: false,
        orderMode: 0,
      ),
    );

    await _reload();
    widget.onChanged();
  }

  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _recordPayment(
    BuildContext context,
    SessionModel session,
    PaymentView item,
  ) async {
    final paymentMethods = await DBHelper.instance.getPaymentMethods();
    final carriedAmount = item.payment.carriedAmount;
    final remainingAmount =
        (item.payment.requiredAmount - item.payment.effectivePaidAmount)
            .clamp(0.0, item.payment.requiredAmount)
            .toDouble();

    final isEditingFullPayment =
        item.payment.effectivePaidAmount >= item.payment.requiredAmount &&
        item.payment.paidAmount > 0;
    final initialAmount = isEditingFullPayment
        ? item.payment.paidAmount
        : remainingAmount;

    final paid = TextEditingController(text: initialAmount.toStringAsFixed(0));
    final remark = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Remember the user's previously chosen payment method
    int? existingMethodId = item.payment.paymentMethodId;
    int? selectedPaymentMethodId =
        (existingMethodId != null &&
            paymentMethods.any((m) => m.id == existingMethodId))
        ? existingMethodId
        : paymentMethods
              .firstWhere(
                (m) => m.isDefault,
                orElse: () => paymentMethods.first,
              )
              .id;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                // Header - Fixed at top
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.payment,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Payment Voucher',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Scrollable Content Area
                Flexible(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student Info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _infoRow(
                                  'Roll No.',
                                  item.student.rollNo.toString(),
                                ),
                                _infoRow('Name', item.student.name),
                                const Divider(height: 16),
                                _infoRow('Subject', session.subjectName),
                                _infoRow('Session', session.name),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Payment Summary
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _infoRow(
                                  'Required',
                                  _fmtMoney(item.payment.requiredAmount),
                                ),
                                _infoRow(
                                  'Already Paid',
                                  _fmtMoney(item.payment.effectivePaidAmount),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Payment Method
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FA),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedPaymentMethodId,
                                isExpanded: true,
                                items: paymentMethods
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m.id,
                                        child: Text(m.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setDialogState(() {
                                  selectedPaymentMethodId = v;
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Amount
                          const Text(
                            'Amount to Pay',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: paid,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.attach_money,
                                color: Color(0xFF5B2AA6),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F3FA),
                              hintText: 'Enter amount',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return 'Enter amount';
                              final value = double.tryParse(v.trim());
                              if (value == null) return 'Must be numeric';
                              if (value <= 0) return 'Must be positive';
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),

                          // Remark
                          const Text(
                            'Remark (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: remark,
                            maxLines: 1,
                            decoration: InputDecoration(
                              hintText: 'Add a note',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F3FA),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                ),

                const Divider(height: 24),

                // Action Buttons - Fixed at bottom
                Row(
                  children: [
                    if (item.payment.effectivePaidAmount > 0)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                          _showCancelPaymentDialog(context, item);
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 18,
                        ),
                        label: const Text(
                          'Reset',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(dialogContext, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B2AA6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved != true) return;

    final inputAmount = double.parse(paid.text.trim());
    final method = paymentMethods.firstWhere(
      (m) => m.id == selectedPaymentMethodId,
    );

    final newRawPaid = isEditingFullPayment
        ? inputAmount
        : item.payment.paidAmount + inputAmount;
    final newEffectivePaid = newRawPaid + carriedAmount;
    final newStatus = newEffectivePaid > item.payment.requiredAmount
        ? 'Overpaid'
        : newEffectivePaid >= item.payment.requiredAmount
        ? 'Paid'
        : 'Partial';

    final history =
        '[${method.name.toUpperCase()}] ${_fmtTime(DateTime.now())} - $newStatus (${_fmtMoney(inputAmount)})${remark.text.isNotEmpty ? ' | ${remark.text}' : ''}';

    await _updateSinglePayment(
      item.payment.id!,
      newRawPaid,
      history,
      method.id,
      method.name,
    );

    // Show success message instead
    if (context.mounted) {
      _showModernSnackBar('Payment saved successfully', Colors.green);
    }
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelPaymentDialog(BuildContext context, PaymentView item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel this payment? This will reset the amount to 0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateSinglePayment(
        item.payment.id!,
        0,
        'Payment cancelled',
        item.payment.paymentMethodId,
        item.payment.paymentMethodName,
      );

      if (mounted) {
        _showModernSnackBar('Payment cancelled', Colors.orange);
      }
    }
  }

  void _showReceiptDialog(
    PaymentView item,
    SessionModel session,
    double paidValue,
    String remark,
    String paymentMethod,
    double totalPaid,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Payment Receipt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF5B2AA6),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'PAYMENT VOUCHER',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B2AA6),
                          ),
                        ),
                      ),
                      const Divider(),
                      _receiptRow('Date', _fmtDate(DateTime.now())),
                      _receiptRow('Time', _fmtTime(DateTime.now())),
                      _receiptRow(
                        'Voucher No.',
                        'VCH-${DateTime.now().year}-${item.payment.id}',
                      ),
                      const Divider(),
                      const Text(
                        'Student Info',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      _receiptRow('Roll No.', item.student.rollNo.toString()),
                      _receiptRow('Name', item.student.name),
                      const Divider(),
                      const Text(
                        'Session Info',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      _receiptRow('Subject', session.subjectName),
                      _receiptRow('Session', session.name),
                      _receiptRow(
                        'Amount',
                        _fmtMoney(item.payment.requiredAmount),
                      ),
                      const Divider(),
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      _receiptRow('Method', paymentMethod),
                      _receiptRow(
                        'Total Paid',
                        _fmtMoney(totalPaid),
                        color: totalPaid > item.payment.requiredAmount
                            ? Colors.purple
                            : Colors.green,
                      ),
                      _receiptRow(
                        'Remaining',
                        _fmtMoney(
                          _remaining(item.payment.requiredAmount, totalPaid),
                        ),
                        color: Colors.orange,
                      ),
                      if (remark.isNotEmpty) _receiptRow('Remark', remark),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.share),
                      label: const Text('Share'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.check),
                      label: const Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B2AA6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// Order Sessions Page
// =============================================================================
class OrderSessionsPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const OrderSessionsPage({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<OrderSessionsPage> createState() => _OrderSessionsPageState();
}

class _OrderSessionsPageState extends State<OrderSessionsPage> {
  bool _loading = true;
  List<Subject> _subjects = [];
  List<SessionModel> _sessions = [];
  int? _selectedSubjectId;
  int? _selectedSessionId;
  DashboardStats? _stats;
  List<PaymentView> _allPayments = [];
  List<PaymentView> _filteredPayments = [];
  String _searchQuery = '';
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant OrderSessionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _reload();
    }
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _subjects = await DBHelper.instance.getSubjects();
    if (_subjects.isNotEmpty && _selectedSubjectId == null) {
      _selectedSubjectId = _subjects.first.id;
    }
    _sessions = await DBHelper.instance.getSessions(
      subjectId: _selectedSubjectId,
      isOrder: true,
      orderMode: 0,
    );
    if (_sessions.isNotEmpty) {
      if (_selectedSessionId == null ||
          _sessions.every((s) => s.id != _selectedSessionId)) {
        _selectedSessionId = _sessions.first.id;
      }
      _stats = await DBHelper.instance.getDashboardStats(
        sessionId: _selectedSessionId,
      );
      _allPayments = await DBHelper.instance.getPaymentsForSession(
        _selectedSessionId!,
      );
      _applyFilters();
    } else {
      _selectedSessionId = null;
      _stats = await DBHelper.instance.getDashboardStats();
      _allPayments = [];
      _filteredPayments = [];
    }
    if (!mounted) return;
    setState(() => _loading = false);
  }

  void _applyFilters() {
    List<PaymentView> filtered = _allPayments;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((payment) {
        final searchText = _searchQuery.toLowerCase();
        return payment.student.name.toLowerCase().contains(searchText) ||
            payment.student.rollNo.toString().contains(searchText);
      }).toList();
    }
    if (_filterStatus != 'all') {
      filtered = filtered.where((payment) {
        if (_filterStatus == 'paid') return payment.status == 'Paid';
        if (_filterStatus == 'partial') return payment.status == 'Partial';
        if (_filterStatus == 'unpaid') return payment.status == 'Unpaid';
        if (_filterStatus == 'overpaid') return payment.status == 'Overpaid';
        if (_filterStatus == 'not_arrived') return !payment.payment.isArrived;
        return true;
      }).toList();
    }
    setState(() {
      _filteredPayments = filtered;
    });
  }

  Future<void> _updateSinglePayment(
    int paymentId,
    double paidAmount,
    String remark,
    int? paymentMethodId,
    String paymentMethodName,
  ) async {
    await DBHelper.instance.updatePayment(
      paymentId: paymentId,
      paidAmount: paidAmount,
      remark: remark,
      paymentMethodId: paymentMethodId,
      paymentMethodName: paymentMethodName,
    );
    final index = _allPayments.indexWhere((p) => p.payment.id == paymentId);
    if (index != -1) {
      final oldPayment = _allPayments[index];
      final updatedPayment = PaymentView(
        payment: PaymentRecord(
          id: oldPayment.payment.id,
          sessionId: oldPayment.payment.sessionId,
          studentId: oldPayment.payment.studentId,
          requiredAmount: oldPayment.payment.requiredAmount,
          paidAmount: paidAmount,
          carriedAmount: oldPayment.payment.carriedAmount,
          remark: remark,
          paymentDate: DateTime.now().toIso8601String(),
          paymentMethodId: paymentMethodId,
          paymentMethodName: paymentMethodName,
        ),
        student: oldPayment.student,
      );
      _allPayments[index] = updatedPayment;
      _applyFilters();
    }
    if (_selectedSessionId != null) {
      _stats = await DBHelper.instance.getDashboardStats(
        sessionId: _selectedSessionId,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _toggleArrived(int paymentId, bool arrived) async {
    if (arrived) {
      await DBHelper.instance.markArrived(paymentId);
    } else {
      await DBHelper.instance.unmarkArrived(paymentId);
    }
    final index = _allPayments.indexWhere((p) => p.payment.id == paymentId);
    if (index != -1) {
      final oldPayment = _allPayments[index];
      final updatedPayment = PaymentView(
        payment: PaymentRecord(
          id: oldPayment.payment.id,
          sessionId: oldPayment.payment.sessionId,
          studentId: oldPayment.payment.studentId,
          requiredAmount: oldPayment.payment.requiredAmount,
          paidAmount: oldPayment.payment.paidAmount,
          carriedAmount: oldPayment.payment.carriedAmount,
          remark: oldPayment.payment.remark,
          paymentDate: oldPayment.payment.paymentDate,
          paymentMethodId: oldPayment.payment.paymentMethodId,
          paymentMethodName: oldPayment.payment.paymentMethodName,
          arrivedAt: arrived ? DateTime.now().toIso8601String() : '',
        ),
        student: oldPayment.student,
      );
      _allPayments[index] = updatedPayment;
      _applyFilters();
    }
    if (_selectedSessionId != null) {
      _stats = await DBHelper.instance.getDashboardStats(
        sessionId: _selectedSessionId,
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  SessionModel? get _currentSession {
    for (final s in _sessions) {
      if (s.id == _selectedSessionId) return s;
    }
    return _sessions.isNotEmpty ? _sessions.first : null;
  }

  @override
  Widget build(BuildContext context) {
    final session = _currentSession;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF7),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _reload();
            widget.onChanged();
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildHeader()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _buildFiltersCard(),
                ),
              ),
              if (_loading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (session == null)
                SliverToBoxAdapter(child: _buildEmptyState())
              else ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSessionCard(session),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildStatsGrid(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildSearchAndFilterBar(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildPaymentList(session),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF5B2AA6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Sessions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B2AA6),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Manage Orders',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildDropdown(
              label: 'Subject',
              icon: Icons.book_outlined,
              value: _selectedSubjectId,
              items: _subjects
                  .where((s) => s.id != null)
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                setState(() {
                  _selectedSubjectId = value;
                  _selectedSessionId = null;
                });
                await _reload();
                widget.onChanged();
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: _buildDropdown(
              label: 'Order Session',
              icon: Icons.shopping_cart_outlined,
              value: _selectedSessionId,
              items: _sessions
                  .where((s) => s.id != null)
                  .map(
                    (s) => DropdownMenuItem(
                      value: s.id,
                      child: Text(s.name, style: const TextStyle(fontSize: 13)),
                    ),
                  )
                  .toList(),
              onChanged: (value) async {
                setState(() => _selectedSessionId = value);
                _stats = await DBHelper.instance.getDashboardStats(
                  sessionId: value,
                );
                _allPayments = await DBHelper.instance.getPaymentsForSession(
                  value!,
                );
                _applyFilters();
                if (mounted) setState(() {});
              },
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            flex: 1,
            child: ElevatedButton.icon(
              onPressed: _showCreateSessionDialog,
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New', style: TextStyle(fontSize: 10)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C4DFF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                minimumSize: const Size(0, 0),
              ),
            ),
          ),
          if (_selectedSessionId != null) ...[
            const SizedBox(width: 8),
            Flexible(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () => _editOrderStudents(_selectedSessionId!),
                icon: const Icon(Icons.group_add, size: 16),
                label: const Text('Students', style: TextStyle(fontSize: 10)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  minimumSize: const Size(0, 0),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F3FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              icon: Icon(icon, size: 18, color: const Color(0xFF7C4DFF)),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              items: items.isEmpty
                  ? [const DropdownMenuItem(child: Text('None'))]
                  : items,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionCard(SessionModel session) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFF5B2AA6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C4DFF).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.subjectName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amount per Student',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    child: Text(
                      _fmtMoney(session.amount),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${session.buyerCount} Ordered',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fmtDateShort(session.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildMoneyStat(
                    'Total Expected',
                    _fmtMoney(_stats?.expectedTotal ?? 0),
                    Colors.white,
                  ),
                ),
                Container(
                  width: 1,
                  height: 45,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMoneyStat(
                    'Paid',
                    _fmtMoney(_stats?.collectedTotal ?? 0),
                    Colors.green.shade300,
                  ),
                ),
                Container(
                  width: 1,
                  height: 45,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
                Expanded(
                  child: _buildMoneyStat(
                    'Remaining',
                    _fmtMoney(_stats?.leftTotal ?? 0),
                    Colors.red.shade300,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoneyStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: color.withValues(alpha: 0.9),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.9,
      children: [
        _buildStatCard(
          'Unpaid',
          _stats?.unpaidCount ?? 0,
          Colors.red,
          Icons.cancel_rounded,
          Colors.red.shade50,
        ),
        _buildStatCard(
          'Partial',
          _stats?.partialCount ?? 0,
          Colors.orange,
          Icons.timelapse_rounded,
          Colors.orange.shade50,
        ),
        _buildStatCard(
          'Paid',
          _stats?.paidCount ?? 0,
          Colors.green,
          Icons.check_circle_rounded,
          Colors.green.shade50,
        ),
        _buildStatCard(
          'Overpaid',
          _stats?.overpaidCount ?? 0,
          Colors.purple,
          Icons.warning_rounded,
          Colors.purple.shade50,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    int value,
    Color color,
    IconData icon,
    Color bgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  value.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Colors.grey, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search by roll no. or name...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterButton('all', 'All', Icons.list),
              const SizedBox(width: 8),
              _buildFilterButton('paid', 'Paid', Icons.check_circle),
              const SizedBox(width: 8),
              _buildFilterButton('partial', 'Partial', Icons.timelapse),
              const SizedBox(width: 8),
              _buildFilterButton('unpaid', 'Unpaid', Icons.cancel),
              const SizedBox(width: 8),
              _buildFilterButton('overpaid', 'Overpaid', Icons.warning),
              const SizedBox(width: 8),
              _buildFilterButton(
                'not_arrived',
                'Not Arrived',
                Icons.local_shipping_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String status, String label, IconData icon) {
    final isActive = _filterStatus == status;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterStatus = status;
        });
        _applyFilters();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF7C4DFF) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: isActive ? 22 : 18,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: isActive ? 13 : 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? Colors.white : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList(SessionModel session) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C4DFF), Color(0xFF5B2AA6)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Table(
              columnWidths: const {
                0: FixedColumnWidth(35),
                1: FixedColumnWidth(35),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
                4: FlexColumnWidth(2.5),
                5: FixedColumnWidth(50),
              },
              children: [
                TableRow(
                  children: [
                    _tableHeader('Arrive'),
                    _tableHeader('Paid'),
                    _tableHeader('Student'),
                    _tableHeader('Status'),
                    _tableHeader('Amount'),
                    const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
          if (_filteredPayments.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Text(
                  'No orders found',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            )
          else
            ..._filteredPayments.map((item) => _buildPaymentRow(item, session)),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPaymentRow(PaymentView item, SessionModel session) {
    final isPaid = item.status == 'Paid' || item.status == 'Overpaid';
    final isArrived = item.payment.isArrived;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isArrived
            ? Colors.blue.shade50
            : (isPaid ? Colors.green.shade50 : Colors.white),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(35),
          1: FixedColumnWidth(35),
          2: FlexColumnWidth(2),
          3: FlexColumnWidth(2),
          4: FlexColumnWidth(2.5),
          5: FixedColumnWidth(50),
        },
        children: [
          TableRow(
            children: [
              // Arrived Checkbox
              Checkbox(
                value: isArrived,
                activeColor: Colors.blue,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (val) =>
                    _toggleArrived(item.payment.id!, val ?? false),
              ),
              // Paid Checkbox
              Checkbox(
                value: isPaid,
                activeColor: Colors.green,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: isPaid
                    ? null
                    : (val) async {
                        if (val == true) {
                          final methods = await DBHelper.instance
                              .getPaymentMethods();
                          final defaultMethod = methods.firstWhere(
                            (m) => m.isDefault,
                            orElse: () => methods.first,
                          );
                          final remaining =
                              item.payment.requiredAmount -
                              item.payment.effectivePaidAmount;
                          if (remaining > 0) {
                            await _updateSinglePayment(
                              item.payment.id!,
                              item.payment.paidAmount + remaining,
                              'Full paid via checkbox',
                              defaultMethod.id,
                              defaultMethod.name,
                            );
                          }
                        }
                      },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.student.name.isEmpty
                        ? 'Roll ${item.student.rollNo}'
                        : item.student.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Roll ${item.student.rollNo}',
                    style: TextStyle(fontSize: 9, color: Colors.grey.shade600),
                  ),
                ],
              ),
              Center(child: _buildStatusChip(item.status)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _fmtMoney(item.payment.effectivePaidAmount),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _getStatusColor(item.status),
                    ),
                  ),
                  Text(
                    item.payment.paymentMethodName.isEmpty
                        ? 'Cash'
                        : item.payment.paymentMethodName,
                    style: TextStyle(fontSize: 8, color: Colors.grey.shade600),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _recordPayment(context, session, item),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C4DFF),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '\$',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Paid':
        return Colors.green.shade700;
      case 'Overpaid':
        return Colors.purple.shade700;
      case 'Partial':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildStatusChip(String status) {
    final config = {
      'Unpaid': {
        'color': Colors.red,
        'bgColor': Colors.red.shade50,
        'icon': Icons.cancel_rounded,
      },
      'Partial': {
        'color': Colors.orange,
        'bgColor': Colors.orange.shade50,
        'icon': Icons.timelapse_rounded,
      },
      'Paid': {
        'color': Colors.green,
        'bgColor': Colors.green.shade50,
        'icon': Icons.check_circle_rounded,
      },
      'Overpaid': {
        'color': Colors.purple,
        'bgColor': Colors.purple.shade50,
        'icon': Icons.warning_rounded,
      },
    }[status]!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: config['bgColor'] as Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (config['color'] as Color).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config['icon'] as IconData,
            size: 10,
            color: config['color'] as Color,
          ),
          const SizedBox(width: 2),
          Text(
            status,
            style: TextStyle(
              color: config['color'] as Color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 24),
          const Text(
            'No Order Session',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Create an order session to manage payments',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _showCreateSessionDialog,
            icon: const Icon(Icons.add),
            label: const Text('Create Order'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C4DFF),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateSessionDialog() async {
    final subjects = await DBHelper.instance.getSubjects();
    if (subjects.isEmpty) {
      if (!mounted) return;
      _showModernSnackBar('Create a subject first.', Colors.orange);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final sessionName = TextEditingController();
    final amount = TextEditingController(text: '5000');
    int selectedSubjectId = _selectedSubjectId ?? subjects.first.id!;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF5B2AA6)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.shopping_cart,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'New Order Session',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Form(
                    key: formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Subject',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F3FA),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int>(
                              value: selectedSubjectId,
                              isExpanded: true,
                              items: subjects
                                  .where((s) => s.id != null)
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s.id,
                                      child: Text(s.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setLocalState(() => selectedSubjectId = v!),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Session Name',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: sessionName,
                          decoration: InputDecoration(
                            hintText: 'e.g. Textbook Order',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F3FA),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Enter session name'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Amount per Student',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: amount,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Color(0xFF7C4DFF),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F3FA),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter amount';
                            }
                            if (double.tryParse(v.trim()) == null) {
                              return 'Amount must be numeric';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7C4DFF),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Create Session'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (saved != true) return;
    if (!formKey.currentState!.validate()) return;

    final sessionId = await DBHelper.instance.insertSession(
      SessionModel(
        id: null,
        subjectId: selectedSubjectId,
        subjectName: '',
        name: sessionName.text.trim(),
        amount: double.parse(amount.text.trim()),
        buyerCount: 0,
        createdAt: DateTime.now().toIso8601String(),
        isOrder: true,
        orderMode: 0,
      ),
    );

    if (sessionId > 0) {
      await _editOrderStudents(sessionId);
      await _reload();
    }
    widget.onChanged();
  }

  Future<void> _editOrderStudents(int sessionId) async {
    final students = await DBHelper.instance.getStudents();
    if (students.isEmpty) {
      _showModernSnackBar(
        'No students available. Add students first.',
        Colors.orange,
      );
      return;
    }

    final selectedIds = await DBHelper.instance.getSelectedStudentIdsForSession(
      sessionId,
    );

    final tempSelections = <int>{};
    for (final id in selectedIds) {
      tempSelections.add(id);
    }

    String searchQuery = '';

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setLocalState) {
          final filteredStudents = searchQuery.isEmpty
              ? students
              : students
                    .where(
                      (s) => '${s.name} ${s.rollNo}'.toLowerCase().contains(
                        searchQuery.toLowerCase(),
                      ),
                    )
                    .toList();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFF5B2AA6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.group_add,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Select Ordering Students',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F3FA),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 16,
                      ),
                    ),
                    onChanged: (val) => setLocalState(() => searchQuery = val),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (context, index) {
                        final student = filteredStudents[index];
                        final isSelected = tempSelections.contains(student.id);
                        return Card(
                          elevation: 0,
                          color: isSelected
                              ? const Color(0xFFF5F3FA)
                              : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isSelected
                                  ? const Color(0xFF7C4DFF)
                                  : Colors.grey.shade200,
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: CheckboxListTile(
                            value: isSelected,
                            activeColor: const Color(0xFF7C4DFF),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            onChanged: (value) {
                              setLocalState(() {
                                if (value == true) {
                                  tempSelections.add(student.id!);
                                } else {
                                  tempSelections.remove(student.id);
                                }
                              });
                            },
                            title: Text(
                              student.name.isEmpty
                                  ? 'Roll ${student.rollNo}'
                                  : student.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text('Roll ${student.rollNo}'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C4DFF),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Save Selection',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    if (saved == true) {
      await DBHelper.instance.updateOrderStudents(
        sessionId,
        tempSelections.toList(),
      );
      await _reload();
      widget.onChanged();
      _showModernSnackBar('Student list updated', Colors.green);
    }
  }

  void _showModernSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.white),
            const SizedBox(width: 10),
            Text(message),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _recordPayment(
    BuildContext context,
    SessionModel session,
    PaymentView item,
  ) async {
    final paymentMethods = await DBHelper.instance.getPaymentMethods();
    final remainingAmount =
        (item.payment.requiredAmount - item.payment.effectivePaidAmount)
            .clamp(0.0, item.payment.requiredAmount)
            .toDouble();

    final isEditingFullPayment =
        item.payment.effectivePaidAmount >= item.payment.requiredAmount &&
        item.payment.paidAmount > 0;
    final initialAmount = isEditingFullPayment
        ? item.payment.paidAmount
        : remainingAmount;

    final paid = TextEditingController(text: initialAmount.toStringAsFixed(0));
    final remark = TextEditingController();
    final formKey = GlobalKey<FormState>();

    // Remember the user's previously chosen payment method
    int? existingMethodId = item.payment.paymentMethodId;
    int? selectedPaymentMethodId =
        (existingMethodId != null &&
            paymentMethods.any((m) => m.id == existingMethodId))
        ? existingMethodId
        : paymentMethods
              .firstWhere(
                (m) => m.isDefault,
                orElse: () => paymentMethods.first,
              )
              .id;

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C4DFF), Color(0xFF5B2AA6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Order Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Student Info Section
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _infoRow(
                                  'Roll No.',
                                  item.student.rollNo.toString(),
                                ),
                                _infoRow('Name', item.student.name),
                                const Divider(),
                                _infoRow('Subject', session.subjectName),
                                _infoRow('Session', session.name),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Payment Info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _infoRow(
                                  'Required',
                                  _fmtMoney(item.payment.requiredAmount),
                                ),
                                _infoRow(
                                  'Already Paid',
                                  _fmtMoney(item.payment.effectivePaidAmount),
                                ),
                                if (item.payment.lastActivityTime.isNotEmpty)
                                  _infoRow(
                                    'Last Activity',
                                    _formatTimestamp(
                                      item.payment.lastActivityTime,
                                    ),
                                    color: Colors.blueGrey,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Payment Method
                          const Text(
                            'Payment Method',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FA),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                value: selectedPaymentMethodId,
                                isExpanded: true,
                                items: paymentMethods
                                    .map(
                                      (m) => DropdownMenuItem(
                                        value: m.id,
                                        child: Text(m.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setDialogState(() {
                                  selectedPaymentMethodId = v;
                                }),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Amount to Pay
                          const Text(
                            'Amount to Pay',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: paid,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(
                                Icons.attach_money,
                                color: Color(0xFF7C4DFF),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F3FA),
                              hintText: 'Enter amount',
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter amount';
                              }
                              final value = double.tryParse(v.trim());
                              if (value == null) return 'Must be numeric';
                              if (value <= 0) return 'Must be positive';
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Remark
                          const Text(
                            'Remark (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: remark,
                            decoration: InputDecoration(
                              hintText: 'Add a note (optional)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF5F3FA),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons - Always visible at bottom
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (item.payment.effectivePaidAmount > 0)
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(dialogContext, false);
                          _showCancelPaymentDialog(context, item);
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 18,
                        ),
                        label: const Text(
                          'Cancel Payment',
                          style: TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(dialogContext, true);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C4DFF),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Save Payment',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (saved != true) return;

    final inputAmount = double.parse(paid.text.trim());
    final method = paymentMethods.firstWhere(
      (m) => m.id == selectedPaymentMethodId,
    );

    final newRawPaid = isEditingFullPayment
        ? inputAmount
        : item.payment.paidAmount + inputAmount;
    final newEffectivePaid = newRawPaid;
    final newStatus = newEffectivePaid > item.payment.requiredAmount
        ? 'Overpaid'
        : newEffectivePaid >= item.payment.requiredAmount
        ? 'Paid'
        : 'Partial';

    final history =
        '[${method.name.toUpperCase()}] ${_fmtTime(DateTime.now())} - $newStatus (${_fmtMoney(inputAmount)})${remark.text.isNotEmpty ? ' | ${remark.text}' : ''}';

    await _updateSinglePayment(
      item.payment.id!,
      newRawPaid,
      history,
      method.id,
      method.name,
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color ?? Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelPaymentDialog(BuildContext context, PaymentView item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Payment?'),
        content: const Text(
          'Are you sure you want to cancel this payment? This will reset the amount to 0.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _updateSinglePayment(
        item.payment.id!,
        0,
        'Payment cancelled',
        item.payment.paymentMethodId,
        item.payment.paymentMethodName,
      );

      if (mounted) {
        _showModernSnackBar('Payment cancelled', Colors.orange);
      }
    }
  }
}

// =============================================================================
// Students Page (with History Feature)
// =============================================================================
class StudentsPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const StudentsPage({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  bool _loading = true;
  List<Student> _items = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant StudentsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _items = await DBHelper.instance.getStudents();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<Student> get _filtered => _search.trim().isEmpty
      ? _items
      : _items
            .where(
              (s) => '${s.rollNo} ${s.name}'.toLowerCase().contains(
                _search.trim().toLowerCase(),
              ),
            )
            .toList();

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.people_outline,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Students',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B2AA6),
                          ),
                        ),
                        Text(
                          'Manage Students',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B2AA6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _showBulkAddDialog,
                    icon: const Icon(Icons.add_chart, size: 18),
                    label: const Text('Add Range'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search students...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 100,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No students yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final s = items[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 10,
                            ),
                            leading: CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFE9DDFB),
                              child: Text(
                                s.rollNo.toString(),
                                style: const TextStyle(
                                  color: Color(0xFF5B2AA6),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            title: Text(
                              s.name.isEmpty ? '(no name)' : s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              'Roll ${s.rollNo}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.history,
                                    size: 22,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _showStudentHistory(s),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 22,
                                    color: Color(0xFF5B2AA6),
                                  ),
                                  onPressed: () => _showForm(student: s),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 22,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _delete(s),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showStudentHistory(Student student) async {
    final history = await DBHelper.instance.getPaymentHistory(
      studentId: student.id,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.history, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Payment History - ${student.name.isEmpty ? "Roll ${student.rollNo}" : student.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (history.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No payment history found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final record = history[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getActionColor(
                                        record['actionType'] as String,
                                      ).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      record['actionType'] as String,
                                      style: TextStyle(
                                        color: _getActionColor(
                                          record['actionType'] as String,
                                        ),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    _formatTimestamp(
                                      record['createdAt'] as String,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              _historyRow(
                                'Subject',
                                record['subjectName'] as String? ?? '-',
                              ),
                              _historyRow(
                                'Session',
                                record['sessionName'] as String? ?? '-',
                              ),
                              _historyRow(
                                'Amount',
                                _fmtMoney(
                                  (record['paidAmount'] as num).toDouble(),
                                ),
                              ),
                              _historyRow(
                                'Method',
                                record['paymentMethodName'] as String? ??
                                    'Cash',
                              ),
                              if ((record['remark'] as String?)?.isNotEmpty ==
                                  true)
                                _historyRow(
                                  'Remark',
                                  record['remark'] as String,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'FULL_PAID':
        return Colors.green;
      case 'PARTIAL_PAID':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _historyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showBulkAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final startCtrl = TextEditingController(text: '1');
    final endCtrl = TextEditingController(text: '30');

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Students by Range'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: startCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Start Roll',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (int.tryParse(v.trim()) == null) return 'Must be a number';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: endCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'End Roll',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  if (int.tryParse(v.trim()) == null) return 'Must be a number';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final start = int.parse(startCtrl.text.trim());
    final end = int.parse(endCtrl.text.trim());

    if (start > end) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Start must be <= End')));
      return;
    }

    final existingRolls = _items.map((s) => s.rollNo).toSet();
    final duplicates = <int>[];
    for (int i = start; i <= end; i++) {
      if (existingRolls.contains(i)) duplicates.add(i);
    }

    if (duplicates.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Roll numbers ${duplicates.join(', ')} already exist.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    for (int i = start; i <= end; i++) {
      await DBHelper.instance.insertStudent(Student(rollNo: i, name: ''));
    }

    await _reload();
    widget.onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${end - start + 1} students.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showForm({Student? student}) async {
    final roll = TextEditingController(text: student?.rollNo.toString() ?? '');
    final name = TextEditingController(text: student?.name ?? '');
    final key = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        student == null ? Icons.person_add : Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      student == null ? 'Add Student' : 'Edit Student',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: key,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: roll,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Roll number',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F3FA),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter roll number'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: name,
                        decoration: InputDecoration(
                          labelText: 'Student name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF5F3FA),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Enter name'
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B2AA6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true) return;
    if (!key.currentState!.validate()) return;

    try {
      final item = Student(
        id: student?.id,
        rollNo: int.parse(roll.text.trim()),
        name: name.text.trim(),
      );
      if (student == null) {
        await DBHelper.instance.insertStudent(item);
      } else {
        await DBHelper.instance.updateStudent(item);
      }
      await _reload();
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _delete(Student student) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Student',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Delete ${student.name}?',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;
    await DBHelper.instance.deleteStudent(student.id!);
    await _reload();
    widget.onChanged();
  }
}

// =============================================================================
// Subjects Page (unchanged)
// =============================================================================
class SubjectsPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const SubjectsPage({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  bool _loading = true;
  List<Subject> _items = [];
  String _search = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant SubjectsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _items = await DBHelper.instance.getSubjects();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<Subject> get _filtered => _search.trim().isEmpty
      ? _items
      : _items
            .where(
              (s) =>
                  s.name.toLowerCase().contains(_search.trim().toLowerCase()),
            )
            .toList();

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.book_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subjects',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B2AA6),
                          ),
                        ),
                        Text(
                          'Manage Subjects',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B2AA6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search subjects...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                onChanged: (value) => setState(() => _search = value),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 100,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No subjects yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final s = items[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9DDFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.book_outlined,
                                color: Color(0xFF5B2AA6),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 22,
                                    color: Color(0xFF5B2AA6),
                                  ),
                                  onPressed: () => _showForm(subject: s),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 22,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _delete(s),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showForm({Subject? subject}) async {
    final name = TextEditingController(text: subject?.name ?? '');
    final key = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        subject == null ? Icons.add_box : Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      subject == null ? 'Add Subject' : 'Edit Subject',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: key,
                  child: TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'Subject name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F3FA),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter subject name'
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B2AA6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true) return;
    if (!key.currentState!.validate()) return;

    try {
      final item = Subject(id: subject?.id, name: name.text.trim());
      if (subject == null) {
        await DBHelper.instance.insertSubject(item);
      } else {
        await DBHelper.instance.updateSubject(item);
      }
      await _reload();
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _delete(Subject subject) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Subject',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Delete "${subject.name}"?',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;
    await DBHelper.instance.deleteSubject(subject.id!);
    await _reload();
    widget.onChanged();
  }
}

// =============================================================================
// Payment Methods Page (unchanged)
// =============================================================================
class PaymentMethodsPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const PaymentMethodsPage({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  bool _loading = true;
  List<PaymentMethod> _items = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant PaymentMethodsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _items = await DBHelper.instance.getPaymentMethods();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.payment_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Payment Methods',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B2AA6),
                          ),
                        ),
                        Text(
                          'Manage Payment Options',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showForm(),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B2AA6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.payment_outlined,
                            size: 100,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No payment methods',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final method = _items[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: method.isDefault
                                    ? Colors.green.shade50
                                    : const Color(0xFFE9DDFB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                method.isDefault
                                    ? Icons.account_balance_wallet
                                    : Icons.payment,
                                color: method.isDefault
                                    ? Colors.green
                                    : const Color(0xFF5B2AA6),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              method.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              method.isDefault
                                  ? 'Default Payment Method'
                                  : 'Alternative Payment',
                              style: const TextStyle(fontSize: 13),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!method.isDefault)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.star_outline,
                                      size: 22,
                                      color: Color(0xFF5B2AA6),
                                    ),
                                    onPressed: () => _setDefault(method),
                                  ),
                                if (!method.isDefault)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 22,
                                      color: Color(0xFF5B2AA6),
                                    ),
                                    onPressed: () => _showForm(method: method),
                                  ),
                                if (!method.isDefault)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 22,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _delete(method),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showForm({PaymentMethod? method}) async {
    final name = TextEditingController(text: method?.name ?? '');
    final key = GlobalKey<FormState>();

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        method == null ? Icons.add_box : Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      method == null
                          ? 'Add Payment Method'
                          : 'Edit Payment Method',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Form(
                  key: key,
                  child: TextFormField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: 'Payment method name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F3FA),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Enter payment method name'
                        : null,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5B2AA6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (ok != true) return;
    if (!key.currentState!.validate()) return;

    try {
      final item = PaymentMethod(
        id: method?.id,
        name: name.text.trim(),
        isDefault: method?.isDefault ?? false,
      );
      if (method == null) {
        await DBHelper.instance.insertPaymentMethod(item);
      } else {
        await DBHelper.instance.updatePaymentMethod(item);
      }
      await _reload();
      widget.onChanged();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _setDefault(PaymentMethod method) async {
    await DBHelper.instance.updatePaymentMethod(
      PaymentMethod(id: method.id, name: method.name, isDefault: true),
    );
    await _reload();
    widget.onChanged();
  }

  Future<void> _delete(PaymentMethod method) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Payment Method',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Delete "${method.name}"?',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;
    await DBHelper.instance.deletePaymentMethod(method.id!);
    await _reload();
    widget.onChanged();
  }
}

// =============================================================================
// Reports Page (with Edit Session)
// =============================================================================
class ReportsPage extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onChanged;

  const ReportsPage({
    super.key,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  bool _loading = true;
  List<Subject> _subjects = [];
  List<SessionModel> _sessions = [];
  int? _subjectFilter;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void didUpdateWidget(covariant ReportsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) _reload();
  }

  Future<void> _reload() async {
    setState(() => _loading = true);
    _subjects = await DBHelper.instance.getSubjects();
    _sessions = await DBHelper.instance.getSessions(subjectId: _subjectFilter);
    if (!mounted) return;
    setState(() => _loading = false);
  }

  List<SessionModel> get _filtered => _search.trim().isEmpty
      ? _sessions
      : _sessions
            .where(
              (s) => '${s.subjectName} ${s.name}'.toLowerCase().contains(
                _search.trim().toLowerCase(),
              ),
            )
            .toList();

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF0EEF7),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5B2AA6), Color(0xFF7C4DFF)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.receipt_long_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reports',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF5B2AA6),
                          ),
                        ),
                        Text(
                          'Session Reports',
                          style: TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  DropdownButtonFormField<int?>(
                    value: _subjectFilter,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Filter by subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All subjects'),
                      ),
                      ..._subjects
                          .where((s) => s.id != null)
                          .map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          ),
                    ],
                    onChanged: (value) async {
                      _subjectFilter = value;
                      await _reload();
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Search sessions...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) => setState(() => _search = value),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 100,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No sessions yet',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final s = items[index];
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: s.isOrder
                                    ? const Color(0xFFE9DDFB)
                                    : const Color(0xFFE8F5E9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                s.isOrder
                                    ? Icons.shopping_cart_outlined
                                    : Icons.event_note_outlined,
                                color: s.isOrder
                                    ? const Color(0xFF7C4DFF)
                                    : const Color(0xFF5B2AA6),
                                size: 22,
                              ),
                            ),
                            title: Text(
                              '${s.subjectName} - ${s.name}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              'Amount: ${_fmtMoney(s.amount)} | ${s.isOrder ? "Orders" : "Students"}: ${s.buyerCount}',
                              style: const TextStyle(fontSize: 13),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    size: 22,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () => _editSession(s),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 22,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _delete(s),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editSession(SessionModel session) async {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController(text: session.name);
    final amountCtrl = TextEditingController(text: session.amount.toString());

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Session'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Session Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Name cannot be empty'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount per Student',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final val = double.tryParse(v.trim());
                  if (val == null) return 'Must be a number';
                  if (val <= 0) return 'Amount must be > 0';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final newName = nameCtrl.text.trim();
    final newAmount = double.parse(amountCtrl.text.trim());

    final updated = SessionModel(
      id: session.id,
      subjectId: session.subjectId,
      subjectName: session.subjectName,
      name: newName,
      amount: newAmount,
      buyerCount: session.buyerCount,
      createdAt: session.createdAt,
      isOrder: session.isOrder,
      orderMode: session.orderMode,
      sourceSessionId: session.sourceSessionId,
    );

    await DBHelper.instance.updateSession(updated);
    await _reload();
    widget.onChanged();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session updated successfully')),
    );
  }

  Future<void> _delete(SessionModel session) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delete Session',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Delete "${session.name}"?',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (ok != true) return;
    await DBHelper.instance.deleteSession(session.id!);
    await _reload();
    widget.onChanged();
  }
}

// =============================================================================
// Helper Functions
// =============================================================================
String _fmtMoney(double value) =>
    value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(2);

String _fmtDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String _fmtDateShort(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return _fmtDate(dt);
}

String _fmtTime(DateTime dt) {
  return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

double _remaining(double required, double paid) {
  final value = required - paid;
  return value < 0 ? 0 : value;
}

String _formatTimestamp(String iso) {
  final dt = DateTime.tryParse(iso);
  if (dt == null) return iso;
  return '${_fmtDate(dt)} ${_fmtTime(dt)}';
}
