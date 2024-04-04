-- Active: 1709224738097@@127.0.0.1@3306@test
use test;
use library_db;
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT '1');

insert into users (username, password,type) values ('mem1', 'mem1','0');
insert into users (username, password,type) values ('mem2', 'mem2','0');

insert into users (username, password) values ('sridhar', 'sridhar');
insert into users (username, password) values ('swyam', 'swyam');
insert into users (username, password) values ('shaurya', 'shaurya');

select * from users;


-- Create the database (if it doesn't exist)
CREATE DATABASE IF NOT EXISTS library_db;
USE library_db;

-- Create the tables
CREATE TABLE books (
    book_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    author VARCHAR(255) NOT NULL,
    publisher VARCHAR(255),
    isbn VARCHAR(20) UNIQUE,
    genre VARCHAR(100),
    available BOOLEAN DEFAULT TRUE
);

CREATE TABLE members (
    member_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    contact VARCHAR(255)
);

CREATE TABLE borrowings (
    borrowing_id INT AUTO_INCREMENT PRIMARY KEY,
    book_id INT NOT NULL,
    member_id INT NOT NULL,
    borrowed_date DATE NOT NULL,
    due_date DATE NOT NULL,
    returned_date DATE,
    FOREIGN KEY (book_id) REFERENCES books(book_id),
    FOREIGN KEY (member_id) REFERENCES members(member_id)
);

-- Insert some sample data
INSERT INTO books (title, author, publisher, isbn, genre)
VALUES
    ('The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', '978-0743273565', 'Fiction'),
    ('To Kill a Mockingbird', 'Harper Lee', 'J. B. Lippincott & Co.', '978-0446310789', 'Fiction'),
    ('Pride and Prejudice', 'Jane Austen', 'T. Egerton', '978-0141439518', 'Romance'),
    ('1984', 'George Orwell', 'Secker & Warburg', '978-0451524935', 'Fiction'),
    ('The Catcher in the Rye', 'J. D. Salinger', 'Little, Brown and Company', '978-0316769488', 'Fiction'),
    ('Animal Farm', 'George Orwell', 'Secker & Warburg', '978-0451524935', 'Fiction'),
    ('Brave New World', 'Aldous Huxley', 'Chatto & Windus', '978-0060850524', 'Science Fiction'),
    ('The Hobbit', 'J.R.R. Tolkien', 'Allen & Unwin', '978-0345534835', 'Fantasy'),
    ('The Lord of the Rings', 'J.R.R. Tolkien', 'Allen & Unwin', '978-0544003415', 'Fantasy'),
    ('The Da Vinci Code', 'Dan Brown', 'Doubleday', '978-0307474278', 'Mystery'),
    ('The Alchemist', 'Paulo Coelho', 'HarperCollins', '978-0062315007', 'Fiction');

INSERT INTO books (title, author, publisher, isbn, genre)
VALUES
  ('The Lost City', 'Emily Rollins', 'Penguin Books', '978-0143135012', 'Adventure'),
  ('Quantum Paradox', 'Michael Jennings', 'HarperCollins', '978-0062887207', 'Science Fiction'),
  ('The Forgotten Heir', 'Sophia Parker', 'Bloomsbury Publishing', '978-1526637383', 'Historical Fiction'),
  ('Midnight in Paris', 'Liam Roberts', 'Doubleday', '978-0385537063', 'Romance'),
  ('The Crimson Cipher', 'David Wilkins', 'Tor Books', '978-0765379603', 'Mystery'),
  ('Shattered Illusions', 'Olivia Thompson', 'Sourcebooks Landmark', '978-1728241690', 'Thriller'),
  ('The Mythic Lands', 'Alexander James', 'Orbit', '978-0316419574', 'Fantasy');


INSERT INTO members (name, contact)
VALUES
    ('John Doe', 'john.doe@example.com');

-- Book management
-- Add a new book
INSERT INTO books (title, author, publisher, isbn, genre)
VALUES ('1984', 'George Orwell', 'Secker & Warburg', '978-0451524935', 'Fiction');

-- Update a book's information
UPDATE books
SET title = 'Animal Farm', author = 'George Orwell'
WHERE book_id = 3;

-- Remove a book
DELETE FROM books
WHERE book_id = 3;

-- Member management
-- Add a new member
INSERT INTO members (name, contact)
VALUES ('Jane Smith', 'jane.smith@example.com');

-- Update a member's information
UPDATE members
SET contact = 'john.doe@newemail.com'
WHERE member_id = 1;

-- Remove a member
DELETE FROM members
WHERE member_id = 2;

-- Borrowing and returning
-- Borrow a book
INSERT INTO borrowings (book_id, member_id, borrowed_date, due_date)
VALUES (1, 1, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 14 DAY));

-- Return a book
UPDATE borrowings
SET returned_date = CURDATE()
WHERE borrowing_id = 1;

-- Search and filtering
-- Search for books by title or author
SELECT *
FROM books
WHERE title LIKE '%Great%' OR author LIKE '%Fitzgerald%';

-- Filter books by genre
SELECT *
FROM books
WHERE genre = 'Fiction';

-- Get a list of borrowed books and their due dates
SELECT bk.title, b.borrowed_date, b.due_date
FROM borrowings b, books bk
WHERE b.book_id = bk.book_id AND b.returned_date IS NULL;

-- Get a list of overdue books
SELECT bk.title, b.borrowed_date, b.due_date
FROM borrowings b
JOIN books bk ON b.book_id = bk.book_id
WHERE b.returned_date IS NULL AND b.due_date < CURDATE();