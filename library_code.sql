-- ====================================================================
-- LIBRARY MANAGEMENT SYSTEM
-- College DBMS Project
-- DBMS: MySQL 8.0
-- ====================================================================
-- This single script builds the complete project in the order:
-- PART 1  - Database creation
-- PART 2  - Table creation
-- PART 3  - Constraints (built into PART 2, summarized again here)
-- PART 4  - Sample data
-- PART 5  - DDL queries (ALTER TABLE examples)
-- PART 6  - DML queries (INSERT / UPDATE / DELETE)
-- PART 7  - DQL queries (SELECT, WHERE, LIKE, BETWEEN, IN, ORDER BY...)
-- PART 8  - CRUD operations (Student, Book, Issue, Fine)
-- PART 9  - Joins
-- PART 10 - Aggregate functions
-- PART 11 - Subqueries
-- PART 12 - Views
-- PART 13 - Triggers
-- PART 14 - Transactions
-- PART 15 - Data integrity explanation (as comments)
-- PART 16 - Important library operations
-- PART 17 - Final demonstration queries (20+)
-- ====================================================================


-- ====================================================================
-- PART 1: DATABASE CREATION
-- ====================================================================
-- Purpose: create a dedicated database for the project and select it.

DROP DATABASE IF EXISTS library_management_system;
CREATE DATABASE library_management_system;
USE library_management_system;


-- ====================================================================
-- PART 2 & 3: TABLE CREATION WITH CONSTRAINTS
-- ====================================================================
-- Tables are created in dependency order so no foreign key ever
-- references a table that does not exist yet:
-- CATEGORY, PUBLISHER, AUTHOR, LIBRARIAN, STUDENT  (no dependencies)
-- BOOK               (depends on PUBLISHER, CATEGORY)
-- BOOK_AUTHOR        (depends on BOOK, AUTHOR)
-- ISSUE              (depends on STUDENT, BOOK, LIBRARIAN)
-- FINE               (depends on ISSUE)

-- --------------------------------------------------------------
-- CATEGORY
-- Purpose: classifies books (Fiction, Science, etc.)
-- --------------------------------------------------------------
CREATE TABLE CATEGORY (
    category_id     INT AUTO_INCREMENT PRIMARY KEY,
    category_name   VARCHAR(50)  NOT NULL UNIQUE,
    description     VARCHAR(255) NOT NULL
);

-- --------------------------------------------------------------
-- PUBLISHER
-- Purpose: stores publishing houses that publish books
-- --------------------------------------------------------------
CREATE TABLE PUBLISHER (
    publisher_id    INT AUTO_INCREMENT PRIMARY KEY,
    publisher_name  VARCHAR(100) NOT NULL UNIQUE,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15)  NOT NULL UNIQUE,
    address         VARCHAR(255) NOT NULL
);

-- --------------------------------------------------------------
-- AUTHOR
-- Purpose: stores authors; linked to books via BOOK_AUTHOR (N:M)
-- --------------------------------------------------------------
CREATE TABLE AUTHOR (
    author_id       INT AUTO_INCREMENT PRIMARY KEY,
    author_name     VARCHAR(100) NOT NULL,
    nationality     VARCHAR(50)  NOT NULL,
    date_of_birth   DATE         NOT NULL,
    biography       TEXT         NOT NULL
);

-- --------------------------------------------------------------
-- LIBRARIAN
-- Purpose: staff who process issue/return transactions
-- --------------------------------------------------------------
CREATE TABLE LIBRARIAN (
    librarian_id    INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15)  NOT NULL UNIQUE,
    hire_date       DATE         NOT NULL DEFAULT (CURRENT_DATE)
);

-- --------------------------------------------------------------
-- STUDENT
-- Purpose: library members who borrow books
-- --------------------------------------------------------------
CREATE TABLE STUDENT (
    student_id      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    email           VARCHAR(100) NOT NULL UNIQUE,
    phone           VARCHAR(15)  NOT NULL UNIQUE,
    department      VARCHAR(50)  NOT NULL,
    year            INT          NOT NULL,
    join_date       DATE         NOT NULL DEFAULT (CURRENT_DATE),
    status          VARCHAR(10)  NOT NULL DEFAULT 'Active',
    CONSTRAINT chk_student_year   CHECK (year BETWEEN 1 AND 6),
    CONSTRAINT chk_student_status CHECK (status IN ('Active', 'Inactive'))
);

-- --------------------------------------------------------------
-- BOOK
-- Purpose: catalog of books available in the library
-- --------------------------------------------------------------
CREATE TABLE BOOK (
    book_id             INT AUTO_INCREMENT PRIMARY KEY,
    title               VARCHAR(200) NOT NULL,
    isbn                VARCHAR(20)  NOT NULL UNIQUE,
    publication_year    INT          NOT NULL,
    language            VARCHAR(30)  NOT NULL,
    total_copies        INT          NOT NULL,
    available_copies    INT          NOT NULL,
    publisher_id        INT          NOT NULL,
    category_id         INT          NOT NULL,
    CONSTRAINT chk_publication_year CHECK (publication_year > 0),
    CONSTRAINT chk_total_copies     CHECK (total_copies > 0),
    CONSTRAINT chk_available_copies CHECK (available_copies >= 0),
    CONSTRAINT fk_book_publisher FOREIGN KEY (publisher_id)
        REFERENCES PUBLISHER(publisher_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_book_category FOREIGN KEY (category_id)
        REFERENCES CATEGORY(category_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- --------------------------------------------------------------
-- BOOK_AUTHOR
-- Purpose: resolves the BOOK N:M AUTHOR relationship
-- --------------------------------------------------------------
CREATE TABLE BOOK_AUTHOR (
    book_id     INT NOT NULL,
    author_id   INT NOT NULL,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book FOREIGN KEY (book_id)
        REFERENCES BOOK(book_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id)
        REFERENCES AUTHOR(author_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

-- --------------------------------------------------------------
-- ISSUE
-- Purpose: records every book issue transaction
-- --------------------------------------------------------------
CREATE TABLE ISSUE (
    issue_id        INT AUTO_INCREMENT PRIMARY KEY,
    student_id      INT         NOT NULL,
    book_id         INT         NOT NULL,
    librarian_id    INT         NOT NULL,
    issue_date      DATE        NOT NULL DEFAULT (CURRENT_DATE),
    due_date        DATE        NOT NULL,
    return_date     DATE        NULL,
    status          VARCHAR(10) NOT NULL DEFAULT 'Issued',
    CONSTRAINT chk_issue_status CHECK (status IN ('Issued', 'Returned')),
    CONSTRAINT fk_issue_student FOREIGN KEY (student_id)
        REFERENCES STUDENT(student_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_issue_book FOREIGN KEY (book_id)
        REFERENCES BOOK(book_id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_issue_librarian FOREIGN KEY (librarian_id)
        REFERENCES LIBRARIAN(librarian_id)
        ON UPDATE CASCADE ON DELETE RESTRICT
);

-- --------------------------------------------------------------
-- FINE
-- Purpose: at most one fine per issue (issue_id is UNIQUE)
-- --------------------------------------------------------------
CREATE TABLE FINE (
    fine_id         INT AUTO_INCREMENT PRIMARY KEY,
    issue_id        INT           NOT NULL UNIQUE,
    amount          DECIMAL(8,2)  NOT NULL,
    fine_date       DATE          NOT NULL DEFAULT (CURRENT_DATE),
    payment_status  VARCHAR(10)   NOT NULL DEFAULT 'Unpaid',
    payment_date    DATE          NULL,
    CONSTRAINT chk_fine_amount CHECK (amount >= 0),
    CONSTRAINT chk_payment_status CHECK (payment_status IN ('Paid', 'Unpaid')),
    CONSTRAINT fk_fine_issue FOREIGN KEY (issue_id)
        REFERENCES ISSUE(issue_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);


-- ====================================================================
-- PART 4: SAMPLE DATA
-- ====================================================================

-- CATEGORY (6)
INSERT INTO CATEGORY (category_name, description) VALUES
('Fiction',     'Imaginative narrative writing such as novels and stories'),
('Non-Fiction', 'Factual writing based on real events and information'),
('Science',     'Books covering scientific concepts and discoveries'),
('Technology',  'Books on computing, engineering and technology'),
('History',     'Books covering historical events and analysis'),
('Biography',   'Life stories of real people');

-- PUBLISHER (5)
INSERT INTO PUBLISHER (publisher_name, email, phone, address) VALUES
('Penguin Random House', 'contact@penguin.com',   '9000000001', '123 Publisher St, New Delhi'),
('Oxford University Press', 'contact@oup.com',    '9000000002', '45 Press Ave, Mumbai'),
('HarperCollins',        'contact@harper.com',    '9000000003', '78 Book Blvd, Bengaluru'),
('Pearson Education',    'contact@pearson.com',   '9000000004', '12 Learning Rd, Chennai'),
('McGraw Hill Education','contact@mcgrawhill.com','9000000005', '90 Knowledge Park, Hyderabad');

-- AUTHOR (8)
INSERT INTO AUTHOR (author_name, nationality, date_of_birth, biography) VALUES
('J.K. Rowling',       'United Kingdom', '1965-07-31', 'British author best known for the Harry Potter series.'),
('George Orwell',      'United Kingdom', '1903-06-25', 'English novelist and essayist known for dystopian fiction.'),
('Agatha Christie',    'United Kingdom', '1890-09-15', 'English writer famous for detective novels.'),
('Stephen Hawking',    'United Kingdom', '1942-01-08', 'Theoretical physicist and author of popular science books.'),
('Yuval Noah Harari',  'Israel',         '1976-02-24', 'Historian and author of books on human history and the future.'),
('Chetan Bhagat',      'India',          '1974-04-22', 'Indian author known for popular fiction on youth and campus life.'),
('Jane Austen',        'United Kingdom', '1775-12-16', 'English novelist known for romantic fiction of the landed gentry.'),
('Malcolm Gladwell',   'Canada',         '1963-09-03', 'Journalist and author known for books on social science topics.');

-- LIBRARIAN (5)
INSERT INTO LIBRARIAN (name, email, phone, hire_date) VALUES
('Ravi Kumar',    'ravi.kumar@library.com',   '9876543210', '2015-06-01'),
('Sunita Rao',    'sunita.rao@library.com',   '9876543211', '2017-03-15'),
('Anil Mehta',    'anil.mehta@library.com',   '9876543212', '2018-09-10'),
('Priya Nair',    'priya.nair@library.com',   '9876543213', '2019-11-20'),
('Vikram Singh',  'vikram.singh@library.com', '9876543214', '2020-01-05');

-- STUDENT (10)
INSERT INTO STUDENT (name, email, phone, department, year, join_date, status) VALUES
('Arjun Sharma',  'arjun.sharma@college.edu',  '9123456780', 'Computer Science', 2, '2023-07-01', 'Active'),
('Sneha Patel',   'sneha.patel@college.edu',   '9123456781', 'Electronics',      3, '2022-07-01', 'Active'),
('Rahul Verma',   'rahul.verma@college.edu',   '9123456782', 'Mechanical',       1, '2024-07-01', 'Active'),
('Priya Desai',   'priya.desai@college.edu',   '9123456783', 'Computer Science', 4, '2021-07-01', 'Active'),
('Karan Singh',   'karan.singh@college.edu',   '9123456784', 'Civil',            2, '2023-07-01', 'Active'),
('Anjali Gupta',  'anjali.gupta@college.edu',  '9123456785', 'Electronics',      3, '2022-07-01', 'Inactive'),
('Vikas Yadav',   'vikas.yadav@college.edu',   '9123456786', 'Computer Science', 1, '2024-07-01', 'Active'),
('Neha Joshi',    'neha.joshi@college.edu',    '9123456787', 'Mechanical',       2, '2023-07-01', 'Active'),
('Rohan Kapoor',  'rohan.kapoor@college.edu',  '9123456788', 'Civil',            4, '2021-07-01', 'Active'),
('Divya Reddy',   'divya.reddy@college.edu',   '9123456789', 'Electronics',      3, '2022-07-01', 'Active');

-- BOOK (15)
INSERT INTO BOOK (title, isbn, publication_year, language, total_copies, available_copies, publisher_id, category_id) VALUES
('Harry Potter and the Philosopher''s Stone', '9780747532699', 1997, 'English', 5, 5, 1, 1),
('1984',                                      '9780451524935', 1949, 'English', 4, 4, 1, 1),
('Animal Farm',                               '9780451526342', 1945, 'English', 3, 3, 1, 1),
('Murder on the Orient Express',              '9780062073501', 1934, 'English', 4, 4, 3, 1),
('A Brief History of Time',                   '9780553380163', 1988, 'English', 3, 3, 2, 3),
('Sapiens: A Brief History of Humankind',     '9780062316097', 2011, 'English', 5, 5, 1, 5),
('Five Point Someone',                        '9788129135728', 2004, 'English', 3, 3, 4, 1),
('Pride and Prejudice',                       '9780141439518', 1813, 'English', 4, 4, 2, 1),
('Outliers: The Story of Success',            '9780316017930', 2008, 'English', 3, 3, 5, 2),
('A Short History of Nearly Everything',      '9780552997041', 2003, 'English', 3, 3, 2, 3),
('The Diary of a Young Girl',                 '9780553296983', 1947, 'English', 4, 4, 3, 6),
('Half Girlfriend',                           '9789351950319', 2014, 'English', 3, 3, 4, 1),
('Homo Deus: A Brief History of Tomorrow',    '9781784703936', 2015, 'English', 4, 4, 1, 5),
('Emma',                                      '9780141439587', 1815, 'English', 3, 3, 2, 1),
('The Theory of Everything',                  '9781580632751', 2002, 'English', 2, 2, 2, 3);

-- BOOK_AUTHOR (21 records — demonstrates single and multiple authors per book)
INSERT INTO BOOK_AUTHOR (book_id, author_id) VALUES
(1, 1), (1, 2),
(2, 2),
(3, 2),
(4, 3),
(5, 4),
(6, 5),
(7, 6),
(8, 7),
(9, 8), (9, 6),
(10, 4), (10, 5),
(11, 3), (11, 7),
(12, 6),
(13, 5), (13, 4),
(14, 7),
(15, 4), (15, 8);

-- ISSUE (15) — mix of returned, currently issued, on-time and overdue
INSERT INTO ISSUE (student_id, book_id, librarian_id, issue_date, due_date, return_date, status) VALUES
(1, 1,  1, '2025-01-05', '2025-01-19', '2025-01-15', 'Returned'),
(1, 3,  2, '2025-02-01', '2025-02-15', NULL,          'Issued'),
(2, 2,  1, '2025-01-10', '2025-01-24', '2025-01-20', 'Returned'),
(3, 5,  3, '2025-01-15', '2025-01-29', '2025-01-25', 'Returned'),
(4, 1,  2, '2025-02-05', '2025-02-19', NULL,          'Issued'),
(5, 6,  4, '2025-01-20', '2025-02-03', '2025-02-10', 'Returned'),
(6, 7,  5, '2025-01-25', '2025-02-08', '2025-02-08', 'Returned'),
(7, 8,  1, '2025-02-10', '2025-02-24', NULL,          'Issued'),
(8, 9,  2, '2025-01-12', '2025-01-26', '2025-01-22', 'Returned'),
(9, 10, 3, '2025-02-15', '2025-03-01', NULL,          'Issued'),
(10,1,  4, '2025-02-18', '2025-03-04', NULL,          'Issued'),
(2, 11, 5, '2025-01-28', '2025-02-11', '2025-02-11', 'Returned'),
(3, 12, 1, '2025-02-01', '2025-02-15', NULL,          'Issued'),
(4, 13, 2, '2025-01-08', '2025-01-22', '2025-01-30', 'Returned'),
(1, 14, 3, '2025-02-20', '2025-03-06', NULL,          'Issued');

-- FINE (5) — 2 paid (from late returns), 3 unpaid (from overdue, still-issued books)
INSERT INTO FINE (issue_id, amount, fine_date, payment_status, payment_date) VALUES
(6,  35.00, '2025-02-10', 'Paid',   '2025-02-12'),
(14, 40.00, '2025-01-30', 'Paid',   '2025-02-01'),
(2,  46.00, '2025-03-10', 'Unpaid', NULL),
(5,  38.00, '2025-03-10', 'Unpaid', NULL),
(8,  28.00, '2025-03-10', 'Unpaid', NULL);


-- ====================================================================
-- PART 5: DDL QUERIES (ALTER TABLE examples)
-- ====================================================================

-- Add a column to record a student's date of birth (useful, optional field)
ALTER TABLE STUDENT ADD COLUMN date_of_birth DATE NULL;

-- Add an index on BOOK.title to speed up title searches (used heavily in Part 16/17)
ALTER TABLE BOOK ADD INDEX idx_book_title (title);

-- Widen the FINE.amount precision example (demonstrates MODIFY COLUMN)
ALTER TABLE FINE MODIFY COLUMN amount DECIMAL(10,2) NOT NULL;

-- Example of dropping a column (kept commented so the demo data above is unaffected)
-- ALTER TABLE STUDENT DROP COLUMN date_of_birth;


-- ====================================================================
-- PART 6: DML QUERIES (INSERT / UPDATE / DELETE)
-- ====================================================================

-- INSERT: add a new student
INSERT INTO STUDENT (name, email, phone, department, year, join_date, status)
VALUES ('Meera Iyer', 'meera.iyer@college.edu', '9123456790', 'Computer Science', 1, CURRENT_DATE, 'Active');

-- UPDATE: correct a student's department
UPDATE STUDENT
SET department = 'Information Technology'
WHERE student_id = 11;

-- UPDATE: mark a returned issue as complete with a return date
UPDATE ISSUE
SET return_date = '2025-03-05', status = 'Returned'
WHERE issue_id = 13;

-- DELETE: remove a student who never issued a book (safe delete, no FK conflict)
DELETE FROM STUDENT WHERE student_id = 11;


-- ====================================================================
-- PART 7: DQL QUERIES (SELECT, WHERE, LOGICAL OPS, LIKE, ORDER BY...)
-- ====================================================================

-- SELECT * : view all books
SELECT * FROM BOOK;

-- WHERE : find active students
SELECT student_id, name, department FROM STUDENT WHERE status = 'Active';

-- AND / OR : Computer Science students in year 1 OR year 2
SELECT name, department, year FROM STUDENT
WHERE department = 'Computer Science' AND (year = 1 OR year = 2);

-- BETWEEN : books published between 1900 and 2000
SELECT title, publication_year FROM BOOK
WHERE publication_year BETWEEN 1900 AND 2000;

-- IN : books belonging to Fiction or History categories
SELECT title, category_id FROM BOOK
WHERE category_id IN (1, 5);

-- LIKE : books with 'History' in the title
SELECT title FROM BOOK WHERE title LIKE '%History%';

-- ORDER BY : students ordered by join_date (most recent first)
SELECT name, join_date FROM STUDENT ORDER BY join_date DESC;

-- DISTINCT : list distinct departments
SELECT DISTINCT department FROM STUDENT;

-- LIMIT : top 5 books by publication year (latest)
SELECT title, publication_year FROM BOOK ORDER BY publication_year DESC LIMIT 5;

-- Aliases : friendlier column names
SELECT s.name AS student_name, s.department AS dept
FROM STUDENT AS s
WHERE s.status = 'Active';


-- ====================================================================
-- PART 8: CRUD OPERATIONS
-- ====================================================================

-- ---------- STUDENT ----------
-- Create
INSERT INTO STUDENT (name, email, phone, department, year, status)
VALUES ('Aditya Rao', 'aditya.rao@college.edu', '9123456791', 'Electronics', 2, 'Active');
-- Read
SELECT * FROM STUDENT WHERE email = 'aditya.rao@college.edu';
-- Update
UPDATE STUDENT SET year = 3 WHERE email = 'aditya.rao@college.edu';
-- Delete
DELETE FROM STUDENT WHERE email = 'aditya.rao@college.edu';

-- ---------- BOOK ----------
-- Create
INSERT INTO BOOK (title, isbn, publication_year, language, total_copies, available_copies, publisher_id, category_id)
VALUES ('The Hobbit', '9780547928227', 1937, 'English', 4, 4, 1, 1);
-- Read
SELECT * FROM BOOK WHERE isbn = '9780547928227';
-- Update
UPDATE BOOK SET total_copies = 5, available_copies = 5 WHERE isbn = '9780547928227';
-- Delete
DELETE FROM BOOK WHERE isbn = '9780547928227';

-- ---------- ISSUE ----------
-- Create (issue a book to a student)
INSERT INTO ISSUE (student_id, book_id, librarian_id, issue_date, due_date, status)
VALUES (7, 4, 2, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY), 'Issued');
-- Read
SELECT * FROM ISSUE WHERE student_id = 7 AND book_id = 4;
-- Update (return the book)
UPDATE ISSUE SET return_date = CURRENT_DATE, status = 'Returned'
WHERE student_id = 7 AND book_id = 4 AND status = 'Issued';
-- Delete (remove an erroneous issue record)
DELETE FROM ISSUE WHERE student_id = 7 AND book_id = 4;

-- ---------- FINE ----------
-- Create
INSERT INTO FINE (issue_id, amount, fine_date, payment_status)
VALUES (10, 20.00, CURRENT_DATE, 'Unpaid');
-- Read
SELECT * FROM FINE WHERE issue_id = 10;
-- Update (mark as paid)
UPDATE FINE SET payment_status = 'Paid', payment_date = CURRENT_DATE WHERE issue_id = 10;
-- Delete
DELETE FROM FINE WHERE issue_id = 10;


-- ====================================================================
-- PART 9: JOINS
-- ====================================================================

-- INNER JOIN: Student + Issue + Book (which student issued which book)
SELECT s.name AS student_name, b.title AS book_title, i.issue_date, i.status
FROM STUDENT s
INNER JOIN ISSUE i ON s.student_id = i.student_id
INNER JOIN BOOK b ON i.book_id = b.book_id;

-- INNER JOIN: Book + Publisher + Category
SELECT b.title, p.publisher_name, c.category_name
FROM BOOK b
INNER JOIN PUBLISHER p ON b.publisher_id = p.publisher_id
INNER JOIN CATEGORY c ON b.category_id = c.category_id;

-- INNER JOIN: Book + Book_Author + Author (books with their authors)
SELECT b.title, a.author_name
FROM BOOK b
INNER JOIN BOOK_AUTHOR ba ON b.book_id = ba.book_id
INNER JOIN AUTHOR a ON ba.author_id = a.author_id
ORDER BY b.title;

-- INNER JOIN: Issue + Student + Book + Librarian (full transaction detail)
SELECT i.issue_id, s.name AS student_name, b.title AS book_title,
       l.name AS librarian_name, i.issue_date, i.due_date, i.status
FROM ISSUE i
INNER JOIN STUDENT s   ON i.student_id = s.student_id
INNER JOIN BOOK b      ON i.book_id = b.book_id
INNER JOIN LIBRARIAN l ON i.librarian_id = l.librarian_id;

-- LEFT JOIN: Issue + Fine (show every issue, with fine details if any exist)
SELECT i.issue_id, i.status, f.amount, f.payment_status
FROM ISSUE i
LEFT JOIN FINE f ON i.issue_id = f.issue_id;

-- RIGHT JOIN: same as above, from FINE's perspective (every fine, with its issue)
SELECT i.issue_id, i.status, f.amount, f.payment_status
FROM ISSUE i
RIGHT JOIN FINE f ON i.issue_id = f.issue_id;

-- SELF JOIN: students in the same department (paired up, genuinely useful for finding peers)
SELECT s1.name AS student_a, s2.name AS student_b, s1.department
FROM STUDENT s1
INNER JOIN STUDENT s2
    ON s1.department = s2.department AND s1.student_id < s2.student_id;

-- Multiple-table JOIN: books currently issued, with student, category and publisher
SELECT b.title, c.category_name, p.publisher_name, s.name AS issued_to, i.due_date
FROM ISSUE i
INNER JOIN BOOK b      ON i.book_id = b.book_id
INNER JOIN CATEGORY c  ON b.category_id = c.category_id
INNER JOIN PUBLISHER p ON b.publisher_id = p.publisher_id
INNER JOIN STUDENT s   ON i.student_id = s.student_id
WHERE i.status = 'Issued';


-- ====================================================================
-- PART 10: AGGREGATE FUNCTIONS
-- ====================================================================

-- COUNT: number of books in each category
SELECT c.category_name, COUNT(b.book_id) AS total_books
FROM CATEGORY c
LEFT JOIN BOOK b ON c.category_id = b.category_id
GROUP BY c.category_name;

-- COUNT: number of books published by each publisher
SELECT p.publisher_name, COUNT(b.book_id) AS total_books
FROM PUBLISHER p
LEFT JOIN BOOK b ON p.publisher_id = b.publisher_id
GROUP BY p.publisher_name;

-- COUNT: number of books issued by each student
SELECT s.name, COUNT(i.issue_id) AS books_issued
FROM STUDENT s
INNER JOIN ISSUE i ON s.student_id = i.student_id
GROUP BY s.name
ORDER BY books_issued DESC;

-- SUM: total fines collected across the library
SELECT SUM(amount) AS total_fines FROM FINE;

-- AVG: average fine amount
SELECT AVG(amount) AS average_fine FROM FINE;

-- MIN / MAX: lowest and highest fine
SELECT MIN(amount) AS lowest_fine, MAX(amount) AS highest_fine FROM FINE;

-- GROUP BY + HAVING: librarians who have processed more than 2 issues
SELECT l.name, COUNT(i.issue_id) AS issues_handled
FROM LIBRARIAN l
INNER JOIN ISSUE i ON l.librarian_id = i.librarian_id
GROUP BY l.name
HAVING COUNT(i.issue_id) > 2;


-- ====================================================================
-- PART 11: SUBQUERIES
-- ====================================================================

-- Students who issued more books than the average number of issues per student
SELECT s.name, COUNT(i.issue_id) AS total_issues
FROM STUDENT s
INNER JOIN ISSUE i ON s.student_id = i.student_id
GROUP BY s.name
HAVING COUNT(i.issue_id) > (
    SELECT AVG(issue_count) FROM (
        SELECT COUNT(issue_id) AS issue_count FROM ISSUE GROUP BY student_id
    ) AS student_issue_counts
);

-- Books issued more than the average number of times
SELECT b.title, COUNT(i.issue_id) AS times_issued
FROM BOOK b
INNER JOIN ISSUE i ON b.book_id = i.book_id
GROUP BY b.title
HAVING COUNT(i.issue_id) > (
    SELECT AVG(book_issue_count) FROM (
        SELECT COUNT(issue_id) AS book_issue_count FROM ISSUE GROUP BY book_id
    ) AS book_issue_counts
);

-- Highest fine, using a subquery instead of MAX() directly
SELECT * FROM FINE
WHERE amount = (SELECT MAX(amount) FROM FINE);

-- Books belonging to the 'Fiction' category using a subquery on CATEGORY
SELECT title FROM BOOK
WHERE category_id = (SELECT category_id FROM CATEGORY WHERE category_name = 'Fiction');


-- ====================================================================
-- PART 12: VIEWS
-- ====================================================================

-- AVAILABLE_BOOKS: books that currently have at least one available copy
CREATE OR REPLACE VIEW AVAILABLE_BOOKS AS
SELECT book_id, title, available_copies, total_copies
FROM BOOK
WHERE available_copies > 0;

SELECT * FROM AVAILABLE_BOOKS;

-- CURRENT_ISSUES: currently issued books with student and book information
CREATE OR REPLACE VIEW CURRENT_ISSUES AS
SELECT i.issue_id, s.name AS student_name, b.title AS book_title,
       i.issue_date, i.due_date
FROM ISSUE i
INNER JOIN STUDENT s ON i.student_id = s.student_id
INNER JOIN BOOK b ON i.book_id = b.book_id
WHERE i.status = 'Issued';

SELECT * FROM CURRENT_ISSUES;

-- STUDENT_ISSUE_HISTORY: full borrowing history per student
CREATE OR REPLACE VIEW STUDENT_ISSUE_HISTORY AS
SELECT s.student_id, s.name AS student_name, b.title AS book_title,
       i.issue_date, i.due_date, i.return_date, i.status
FROM STUDENT s
INNER JOIN ISSUE i ON s.student_id = i.student_id
INNER JOIN BOOK b ON i.book_id = b.book_id;

SELECT * FROM STUDENT_ISSUE_HISTORY WHERE student_id = 1;

-- FINE_DETAILS: fine information with student/book/issue details
CREATE OR REPLACE VIEW FINE_DETAILS AS
SELECT f.fine_id, s.name AS student_name, b.title AS book_title,
       i.issue_id, f.amount, f.fine_date, f.payment_status, f.payment_date
FROM FINE f
INNER JOIN ISSUE i   ON f.issue_id = i.issue_id
INNER JOIN STUDENT s ON i.student_id = s.student_id
INNER JOIN BOOK b    ON i.book_id = b.book_id;

SELECT * FROM FINE_DETAILS;


-- ====================================================================
-- PART 13: TRIGGERS
-- ====================================================================
-- Trigger 1: automatically decrease available_copies when a book is
-- issued (a new row is inserted into ISSUE with status 'Issued').
-- This runs instead of requiring a manual UPDATE on BOOK in the
-- application code, so the two never fall out of sync.

DELIMITER //

CREATE TRIGGER trg_after_issue_insert
AFTER INSERT ON ISSUE
FOR EACH ROW
BEGIN
    IF NEW.status = 'Issued' THEN
        UPDATE BOOK
        SET available_copies = available_copies - 1
        WHERE book_id = NEW.book_id;
    END IF;
END//

DELIMITER ;

-- Trigger 2: automatically increase available_copies when a book's
-- issue record is updated from 'Issued' to 'Returned'.

DELIMITER //

CREATE TRIGGER trg_after_issue_update
AFTER UPDATE ON ISSUE
FOR EACH ROW
BEGIN
    IF OLD.status = 'Issued' AND NEW.status = 'Returned' THEN
        UPDATE BOOK
        SET available_copies = available_copies + 1
        WHERE book_id = NEW.book_id;
    END IF;
END//

DELIMITER ;

-- NOTE: Because these triggers already maintain available_copies,
-- application code (see PART 16) should insert/update ISSUE rows and
-- let the triggers adjust BOOK.available_copies automatically, rather
-- than updating BOOK.available_copies manually in the same request —
-- doing both would double-count the change.


-- ====================================================================
-- PART 14: TRANSACTIONS
-- ====================================================================
-- Demonstrates issuing a book as a single atomic transaction:
-- check availability, insert the issue record, and (via the trigger
-- above) decrement available_copies. If anything fails, roll back.

START TRANSACTION;

-- Step 1: check book availability (application reads this result first)
SELECT available_copies INTO @avail FROM BOOK WHERE book_id = 2 FOR UPDATE;

-- Step 2: only proceed if a copy is available
-- (in application code this IF would be handled in the host language;
--  shown here as a guarded INSERT for demonstration)
INSERT INTO ISSUE (student_id, book_id, librarian_id, issue_date, due_date, status)
SELECT 6, 2, 3, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY), 'Issued'
WHERE @avail > 0;

-- Step 3: available_copies is decremented automatically by trg_after_issue_insert

COMMIT;
-- If the availability check had failed, or any statement had errored,
-- the correct response would be: ROLLBACK;


-- ====================================================================
-- PART 15: DATA INTEGRITY (explanation)
-- ====================================================================
-- Entity integrity:
--   Every table has a PRIMARY KEY (single or composite, e.g.
--   BOOK_AUTHOR's (book_id, author_id)) so every row is uniquely
--   identifiable and no primary key column can be NULL.
--
-- Referential integrity:
--   FOREIGN KEY constraints (e.g. ISSUE.student_id -> STUDENT.student_id,
--   BOOK.publisher_id -> PUBLISHER.publisher_id, FINE.issue_id ->
--   ISSUE.issue_id) guarantee that a referencing row can never point
--   to a parent row that does not exist, and ON DELETE RESTRICT /
--   CASCADE rules control what happens if a parent row is removed.
--
-- Domain integrity:
--   CHECK constraints restrict a column to a valid set/range of values
--   (e.g. STUDENT.year BETWEEN 1 AND 6, ISSUE.status IN ('Issued',
--   'Returned'), FINE.amount >= 0), and appropriate data types
--   (DATE, DECIMAL, INT, VARCHAR) further constrain what can be stored.
--
-- Data consistency:
--   NOT NULL constraints ensure mandatory business data is always
--   captured; UNIQUE constraints prevent duplicate emails, phone
--   numbers, ISBNs, and publisher/category names; DEFAULT constraints
--   (e.g. STUDENT.status DEFAULT 'Active', ISSUE.status DEFAULT
--   'Issued') keep new rows in a valid state without requiring the
--   application to supply every value; and the triggers in PART 13
--   keep BOOK.available_copies consistent with ISSUE activity.
--
-- Purpose of each constraint type:
--   PRIMARY KEY - uniquely identifies each row (entity integrity)
--   FOREIGN KEY - enforces valid relationships between tables
--   NOT NULL    - guarantees required data is always present
--   UNIQUE      - prevents duplicate values where none should exist
--   CHECK       - restricts a column to logically valid values
--   DEFAULT     - supplies a sensible value when none is given


-- ====================================================================
-- PART 16: IMPORTANT LIBRARY OPERATIONS
-- ====================================================================

-- Add a new student
INSERT INTO STUDENT (name, email, phone, department, year, status)
VALUES ('Ishaan Malhotra', 'ishaan.malhotra@college.edu', '9123456792', 'Civil', 1, 'Active');

-- Add a new book
INSERT INTO BOOK (title, isbn, publication_year, language, total_copies, available_copies, publisher_id, category_id)
VALUES ('Brave New World', '9780060850524', 1932, 'English', 3, 3, 3, 1);

-- Add an author
INSERT INTO AUTHOR (author_name, nationality, date_of_birth, biography)
VALUES ('Aldous Huxley', 'United Kingdom', '1894-07-26', 'English writer known for Brave New World.');

-- Add a publisher
INSERT INTO PUBLISHER (publisher_name, email, phone, address)
VALUES ('Bloomsbury Publishing', 'contact@bloomsbury.com', '9000000006', '55 Fiction Lane, Kolkata');

-- Add a category
INSERT INTO CATEGORY (category_name, description)
VALUES ('Self-Help', 'Books focused on personal growth and self-improvement');

-- Add a librarian
INSERT INTO LIBRARIAN (name, email, phone, hire_date)
VALUES ('Meena Shah', 'meena.shah@library.com', '9876543215', CURRENT_DATE);

-- Issue a book (triggers automatically decrement available_copies)
INSERT INTO ISSUE (student_id, book_id, librarian_id, issue_date, due_date, status)
VALUES (5, 3, 1, CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 14 DAY), 'Issued');

-- Return a book (triggers automatically increment available_copies)
UPDATE ISSUE
SET return_date = CURRENT_DATE, status = 'Returned'
WHERE student_id = 5 AND book_id = 3 AND status = 'Issued';

-- Update available copies when issuing (manual reference — normally
-- handled by trg_after_issue_insert; shown for teaching purposes only)
-- UPDATE BOOK SET available_copies = available_copies - 1 WHERE book_id = 3;

-- Update available copies when returning (manual reference — normally
-- handled by trg_after_issue_update; shown for teaching purposes only)
-- UPDATE BOOK SET available_copies = available_copies + 1 WHERE book_id = 3;

-- Generate a fine for an overdue book (7 days late at ₹5/day)
INSERT INTO FINE (issue_id, amount, fine_date, payment_status)
SELECT issue_id, DATEDIFF(CURRENT_DATE, due_date) * 5, CURRENT_DATE, 'Unpaid'
FROM ISSUE
WHERE issue_id = 10 AND status = 'Issued' AND CURRENT_DATE > due_date;

-- Mark a fine as paid
UPDATE FINE SET payment_status = 'Paid', payment_date = CURRENT_DATE WHERE fine_id = 3;

-- Search for a book (by partial title)
SELECT * FROM BOOK WHERE title LIKE '%Brief History%';

-- Check available books
SELECT title, available_copies FROM BOOK WHERE available_copies > 0;

-- Display currently issued books
SELECT * FROM CURRENT_ISSUES;

-- Display a student's borrowing history
SELECT * FROM STUDENT_ISSUE_HISTORY WHERE student_id = 2;


-- ====================================================================
-- PART 17: FINAL DEMONSTRATION QUERIES (20+)
-- ====================================================================

-- 1. Display all students
SELECT * FROM STUDENT;

-- 2. Display all books
SELECT * FROM BOOK;

-- 3. Display available books
SELECT title, available_copies FROM BOOK WHERE available_copies > 0;

-- 4. Find books by title
SELECT * FROM BOOK WHERE title LIKE '%Emma%';

-- 5. Find books by author
SELECT b.title FROM BOOK b
INNER JOIN BOOK_AUTHOR ba ON b.book_id = ba.book_id
INNER JOIN AUTHOR a ON ba.author_id = a.author_id
WHERE a.author_name = 'George Orwell';

-- 6. Find books by category
SELECT b.title FROM BOOK b
INNER JOIN CATEGORY c ON b.category_id = c.category_id
WHERE c.category_name = 'Science';

-- 7. Display currently issued books
SELECT * FROM CURRENT_ISSUES;

-- 8. Display overdue books (still issued, past due date)
SELECT s.name, b.title, i.due_date
FROM ISSUE i
INNER JOIN STUDENT s ON i.student_id = s.student_id
INNER JOIN BOOK b ON i.book_id = b.book_id
WHERE i.status = 'Issued' AND i.due_date < CURRENT_DATE;

-- 9. Display a student's issue history
SELECT * FROM STUDENT_ISSUE_HISTORY WHERE student_id = 4;

-- 10. Count books in each category
SELECT c.category_name, COUNT(b.book_id) AS book_count
FROM CATEGORY c LEFT JOIN BOOK b ON c.category_id = b.category_id
GROUP BY c.category_name;

-- 11. Count issues per student
SELECT s.name, COUNT(i.issue_id) AS issue_count
FROM STUDENT s INNER JOIN ISSUE i ON s.student_id = i.student_id
GROUP BY s.name;

-- 12. Count issues per librarian
SELECT l.name, COUNT(i.issue_id) AS issue_count
FROM LIBRARIAN l INNER JOIN ISSUE i ON l.librarian_id = i.librarian_id
GROUP BY l.name;

-- 13. Find the most issued books
SELECT b.title, COUNT(i.issue_id) AS times_issued
FROM BOOK b INNER JOIN ISSUE i ON b.book_id = i.book_id
GROUP BY b.title
ORDER BY times_issued DESC
LIMIT 5;

-- 14. Find the highest fine
SELECT * FROM FINE ORDER BY amount DESC LIMIT 1;

-- 15. Calculate total fines
SELECT SUM(amount) AS total_fines FROM FINE;

-- 16. Display unpaid fines
SELECT * FROM FINE WHERE payment_status = 'Unpaid';

-- 17. Display books with their publisher names
SELECT b.title, p.publisher_name FROM BOOK b
INNER JOIN PUBLISHER p ON b.publisher_id = p.publisher_id;

-- 18. Display books with their authors
SELECT b.title, GROUP_CONCAT(a.author_name SEPARATOR ', ') AS authors
FROM BOOK b
INNER JOIN BOOK_AUTHOR ba ON b.book_id = ba.book_id
INNER JOIN AUTHOR a ON ba.author_id = a.author_id
GROUP BY b.title;

-- 19. Display students and their issued books
SELECT s.name, b.title, i.status
FROM STUDENT s
INNER JOIN ISSUE i ON s.student_id = i.student_id
INNER JOIN BOOK b ON i.book_id = b.book_id
ORDER BY s.name;

-- 20. Display students who currently have books issued
SELECT DISTINCT s.name
FROM STUDENT s
INNER JOIN ISSUE i ON s.student_id = i.student_id
WHERE i.status = 'Issued';

-- ====================================================================
-- END OF SCRIPT
-- ====================================================================
