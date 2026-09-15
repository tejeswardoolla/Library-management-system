# 📚 Library Management System — DBMS Project

A comprehensive **Library Management System** built as a college DBMS project using **MySQL 8.0**. This project demonstrates core database concepts including schema design, constraints, SQL querying, transactions, triggers, and views — all implemented in a single, well-documented SQL script.

---

## 🗄️ Database: `library_management_system`

| Detail | Info |
|--------|------|
| 🛢️ DBMS | MySQL 8.0 |
| 📄 Language | SQL |
| 🎓 Type | College DBMS Capstone Project |

---

## 📁 Project Structure

The project is organized into **17 sequential parts** inside a single SQL script:

| Part | Description |
|------|-------------|
| 1 | Database Creation |
| 2–3 | Table Creation with Constraints |
| 4 | Sample Data (INSERT) |
| 5 | DDL Queries (ALTER TABLE) |
| 6 | DML Queries (INSERT / UPDATE / DELETE) |
| 7 | DQL Queries (SELECT, WHERE, LIKE, BETWEEN, IN, ORDER BY) |
| 8 | CRUD Operations (Student, Book, Issue, Fine) |
| 9 | Joins |
| 10 | Aggregate Functions |
| 11 | Subqueries |
| 12 | Views |
| 13 | Triggers |
| 14 | Transactions |
| 15 | Data Integrity |
| 16 | Important Library Operations |
| 17 | Final Demonstration Queries (20+) |

---

## 🏗️ Schema Overview

The database consists of the following tables, created in dependency order:

```
CATEGORY ──────────────────────────┐
PUBLISHER ──────────────────────── BOOK ── BOOK_AUTHOR ── AUTHOR
AUTHOR ─────────────────────────────┘         │
LIBRARIAN ─────────────────────── ISSUE ── FINE
STUDENT ────────────────────────────┘
```

### Tables
- **CATEGORY** — Classifies books (Fiction, Science, etc.)
- **PUBLISHER** — Publishing houses
- **AUTHOR** — Authors; linked to books via `BOOK_AUTHOR` (Many-to-Many)
- **LIBRARIAN** — Librarian staff details
- **STUDENT** — Registered students
- **BOOK** — Book records with category and publisher reference
- **BOOK_AUTHOR** — Bridge table for Book ↔ Author (N:M)
- **ISSUE** — Book issue/return records
- **FINE** — Fines linked to issue records

---

## 🚀 How to Run

1. Make sure **MySQL 8.0** is installed and running.
2. Open your MySQL client (MySQL Workbench, CLI, DBeaver, etc.).
3. Run the SQL script:

```sql
SOURCE path/to/library_management_system.sql;
```

Or via CLI:
```bash
mysql -u root -p < library_management_system.sql
```

4. The script will automatically:
   - Drop and recreate the database
   - Create all tables with constraints
   - Insert sample data
   - Run all demonstration queries

---

## 🧠 Concepts Demonstrated

- ✅ ER Diagram → Relational Schema mapping
- ✅ Primary Keys, Foreign Keys, UNIQUE, NOT NULL constraints
- ✅ Normalization (up to 3NF)
- ✅ DDL & DML operations
- ✅ Complex SELECT queries (JOINs, Subqueries, Aggregates)
- ✅ Views and Triggers
- ✅ ACID-compliant Transactions
- ✅ Data Integrity enforcement

