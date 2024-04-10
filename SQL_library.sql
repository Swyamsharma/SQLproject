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

-- Add 10 more copies of the book 'Quantum Paradox'
INSERT INTO books (title, author, publisher, isbn, genre)
VALUES ('Whispers of the Wind', 'Vanessa Mason', 'Random House', '978-0747569735', 'Romance'),
('Shadows of the Moon', 'Nicholas Drake', 'St. Martin''s Press', '978-0312623572', 'Fantasy'),
('The Silver Lining', 'Emily White', 'Simon & Schuster', '978-0743222416', 'Drama'),
('Secret of the Seas', 'Jasmine Evans', 'Hodder & Stoughton', '978-0340985578', 'Adventure'),
('The Labyrinth of Time', 'David Green', 'Del Rey Books', '978-0345496718', 'Sci-Fi'),
('A Dance with Destiny', 'Olivia Brown', 'Harlequin Enterprises', '978-0373127468', 'Historical Fiction'),
('Songs of the Sirens', 'James Wilson', 'Tor Books', '978-0765388021', 'Fantasy'),
('The Last Rose of Summer', 'Elizabeth Taylor', 'Penguin Group', '978-0399167324', 'Historical Fiction'),
('Murder at the Manor', 'Victoria Thompson', 'Berkley Publishing Group', '978-0451489621', 'Mystery');

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
VALUES (1, 1, CURDATE(), '1980-11-11');

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

DELIMITER $$
CREATE FUNCTION borrow_book(
    p_book_id INT,
    p_member_id INT,
    p_due_date_interval INT
)
RETURNS VARCHAR(255)
BEGIN
    DECLARE v_result VARCHAR(255);
    DECLARE v_available BOOLEAN;
    DECLARE v_book_title VARCHAR(255);
    DECLARE v_member_name VARCHAR(255);

    -- Check if the book exists and is available
    SELECT available, title INTO v_available, v_book_title
    FROM books
    WHERE book_id = p_book_id;

    IF v_available IS NULL THEN
        SET v_result = CONCAT('Book with ID ', p_book_id, ' does not exist.');
        RETURN v_result;
    ELSEIF NOT v_available THEN
        SET v_result = CONCAT('Book "', v_book_title, '" is not available.');
        RETURN v_result;
    END IF;

    -- Check if the member exists
    SELECT name INTO v_member_name
    FROM members
    WHERE member_id = p_member_id;

    IF v_member_name IS NULL THEN
        SET v_result = CONCAT('Member with ID ', p_member_id, ' does not exist.');
        RETURN v_result;
    END IF;

    -- Insert a new borrowing record
    INSERT INTO borrowings (book_id, member_id, borrowed_date, due_date)
    VALUES (p_book_id, p_member_id, CURDATE(), DATE_ADD(CURDATE(), INTERVAL p_due_date_interval DAY));

    -- Update the book's availability status
    UPDATE books
    SET available = FALSE
    WHERE book_id = p_book_id;

    SET v_result = CONCAT('Book "', v_book_title, '" borrowed by ', v_member_name, '.');

    RETURN v_result;
END$$
DELIMITER ;

SELECT borrow_book(5, 155, 14);


DELIMITER $$

CREATE FUNCTION return_book(
    p_book_id INT,
    p_member_id INT
)
RETURNS VARCHAR(255)
BEGIN
    DECLARE v_result VARCHAR(255);
    DECLARE v_book_title VARCHAR(255);
    DECLARE v_member_name VARCHAR(255);
    DECLARE v_borrowed_date DATE;
    DECLARE v_due_date DATE;

    -- Check if the book exists and is borrowed by the member
    SELECT b.title, m.name, br.borrowed_date, br.due_date
    INTO v_book_title, v_member_name, v_borrowed_date, v_due_date
    FROM books b
    JOIN borrowings br ON b.book_id = br.book_id
    JOIN members m ON br.member_id = m.member_id
    WHERE b.book_id = p_book_id
        AND br.member_id = p_member_id
        AND br.returned_date IS NULL;

    IF v_book_title IS NULL THEN
        SET v_result = CONCAT('Book with ID ', p_book_id, ' is not borrowed by member with ID ', p_member_id, '.');
        RETURN v_result;
    END IF;

    -- Update the borrowing record with the returned date
    UPDATE borrowings
    SET returned_date = CURDATE()
    WHERE book_id = p_book_id
        AND member_id = p_member_id
        AND returned_date IS NULL;

    -- Update the book's availability status
    UPDATE books
    SET available = TRUE
    WHERE book_id = p_book_id;

    SET v_result = CONCAT('Book "', v_book_title, '" returned by ', v_member_name, ' after ', DATEDIFF(CURDATE(), v_borrowed_date), ' days.');

    RETURN v_result;
END$$

DELIMITER ;
use library_db;
SELECT return_book(1, 1);

select * from borrowings; -- Returns book with ID 1 borrowed by member with ID 2



-- Function to add a new book
DELIMITER $$

CREATE FUNCTION add_book(
    p_title VARCHAR(255),
    p_author VARCHAR(255),
    p_publisher VARCHAR(255),
    p_isbn VARCHAR(20),
    p_genre VARCHAR(100)
)
RETURNS VARCHAR(255)
BEGIN
    DECLARE v_result VARCHAR(255);

    -- Check if the book already exists based on ISBN
    IF EXISTS (SELECT 1 FROM books WHERE isbn = p_isbn) THEN
        SET v_result = CONCAT('Book with ISBN "', p_isbn, '" already exists.');
        RETURN v_result;
    END IF;

    -- Insert the new book
    INSERT INTO books (title, author, publisher, isbn, genre, available)
    VALUES (p_title, p_author, p_publisher, p_isbn, p_genre, TRUE);

    SET v_result = CONCAT('Book "', p_title, '" by ', p_author, ' has been added to the library.');
    RETURN v_result;
END$$

DELIMITER ;


-- Function to remove a book
DELIMITER $$

CREATE FUNCTION remove_book(
    p_book_id INT
)
RETURNS VARCHAR(255)
BEGIN
    DECLARE v_result VARCHAR(255);
    DECLARE v_book_title VARCHAR(255);
    DECLARE v_book_available BOOLEAN;

    -- Check if the book exists
    SELECT title, available INTO v_book_title, v_book_available
    FROM books
    WHERE book_id = p_book_id;

    IF v_book_title IS NULL THEN
        SET v_result = CONCAT('Book with ID ', p_book_id, ' does not exist.');
        RETURN v_result;
    END IF;

    -- Check if the book is borrowed
    IF v_book_available = FALSE THEN
        SET v_result = CONCAT('Book "', v_book_title, '" cannot be removed as it is currently borrowed.');
        RETURN v_result;
    END IF;

    -- Delete the book
    DELETE FROM books
    WHERE book_id = p_book_id;

    SET v_result = CONCAT('Book "', v_book_title, '" has been removed from the library.');
    RETURN v_result;
END$$

DELIMITER ;

-- Add a new book
SELECT add_book('The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', '978-0743273562', 'Fiction');

-- Remove a book                                                
SELECT remove_book(113);

use library_db;

INSERT INTO books (title, author, publisher, isbn, genre)
VALUES
('1984', 'George Orwell', 'Signet Classics', '978-0-451-52093-5', 'Fiction'),
('Harry Potter and the Sorcerer''s Stone', 'J.K. Rowling', 'Scholastic', '978-0-545-02936-3', 'Fantasy'),
('To Kill a Mockingbird', 'Harper Lee', 'Harper Perennial Modern Classics', '978-0-06-093546-8', 'Fiction'),
('The Old Man and the Sea', 'Ernest Hemingway', 'Scribner', '978-0-684-80122-3', 'Fiction'),
('Pride and Prejudice', 'Jane Austen', 'Penguin Classics', '978-0-141-43962-0', 'Romance'),
('I Know Why the Caged Bird Sings', 'Maya Angelou', 'Random House Trade Paperbacks', '978-0-345-51440-0', 'Memoir'),
('The Great Gatsby', 'F. Scott Fitzgerald', 'Scribner', '978-0-7432-7356-5', 'Fiction'),
('Of Mice and Men', 'John Steinbeck', 'Penguin Classics', '978-0-f14-017737-3', 'Fiction'),
('Beloved', 'Toni Morrison', 'Vintage International', '978-1-4000-3341-9', 'Fiction'),
('The Kite Runner', 'Khaled Hosseini', 'Riverhead Books', '978-1-59448-385-5', 'Fiction'),
('The Handmaid''s Tale', 'Margaret Atwood', 'Anchor', '978-0-385-49081-7', 'Fiction'),
('The Underground Railroad', 'Colson Whitehead', 'Anchor', '978-0-385-34953-1', 'Fiction'),
('Americanah', 'Chimamanda Ngozi Adichie', 'Anchor', '978-1-4068-0360-3', 'Fiction'),
('The Book Thief', 'Markus Zusak', 'Knopf Books for Young Readers', '978-0-375-84220-7', 'Fiction'),
('Little Fires Everywhere', 'Celeste Ng', 'Penguin Press', '978-0-7352-1707-0', 'Fiction'),
('American Gods', 'Neil Gaiman', 'HarperTorch', '978-0-380-78901-8', 'Fantasy'),
('Circe', 'Madeline Miller', 'Little, Brown and Company', '978-0-416-55806-3', 'Fiction'),
('Homegoing', 'Yaa Gyasi', 'Knopf', '978-1-5947-1436-6', 'Fiction'),
('An American Marriage', 'Tayari Jones', 'Algonquin Books', '978-1-61620-670-5', 'Fiction'),
('The Night Circus', 'Erin Morgenstern', 'Anchor', '978-0-307-59358-7', 'Fantasy'),
('Pachinko', 'Min Jin Lee', 'Grand Central Publishing', '978-1-455-2178-7', 'Fiction'),
('Where the Crawdads Sing', 'Delia Owens', 'G.P. Putnam''s Sons', '978-0-7352-1909-8', 'Fiction'),
('Girl, Woman, Other', 'Bernardine Evaristo', 'Penguin', '978-0-241-98229-7', 'Fiction'),
('Olive Kitteridge', 'Elizabeth Strout', 'Random House', '978-0-8129-8228-9', 'Fiction'),
('Normal People', 'Sally Rooney', 'Hogarth', '978-0-571-33313-4', 'Fiction'),
('There There', 'Tommy Orange', 'Knopf', '978-0-525-52037-7', 'Fiction'),
('Gilead', 'Marilynne Robinson', 'Picador', '978-0-312-4440-7', 'Fiction'),
('The Interpreter of Maladies', 'Jhumpa Lahiri', 'Houghton Mifflin', '978-0-395-92720-6', 'Fiction'),
('The Fifth Season', 'N.K. Jemisin', 'Orbit', '978-0-316-38957-9', 'Science Fiction'),
('Catch and Kill', 'Ronan Farrow', 'Little, Brown and Company', '978-0-316-48592-9', 'Nonfiction'),
('Lost Children Archive', 'Valeria Luiselli', 'Knopf', '978-0-525-43528-9', 'Fiction'),
('A Brief History of Seven Killings', 'Marlon James', 'Riverhead Books', '978-1-59463-390-0', 'Fiction'),
('The Nickel Boys', 'Colson Whitehead', 'Doubleday', '978-0-385-53707-1', 'Fiction'),
('Long Way Down', 'Jason Reynolds', 'Atheneum/Caitlyn Dlouhy Books', '978-1-4814-3825-4', 'Young Adult'),
('Song of Achilles', 'Madeline Miller', 'Little, Brown and Company', '978-0-316-55806-3', 'Fiction'),
('Such a Fun Age', 'Kiley Reid', 'G.P. Putnam''s Sons', '978-0-399-59251-9', 'Fiction'),
('The Testaments', 'Margaret Atwood', 'Anchor', '978-0-385-49381-7', 'Fiction'),
('Caste: The Origins of Our Discontents', 'Isabel Wilkerson', 'Random House', '978-0-593-23262-9', 'Nonfiction'),
('The Vanishing Half', 'Brit Bennett', 'Riverhead Books', '978-0-525-53707-8', 'Fiction'),
('In the Dream House', 'Carmen Maria Machado', 'Graywolf Press', '978-1-324-00375-0', 'Fiction'),
('Shuggie Bain', 'Douglas Stuart', 'Grove Press', '978-1-984-82568-2', 'Fiction'),
('Luster', 'Raven Leilani', 'Farrar, Straus and Giroux', '978-0-374-19159-6', 'Fiction'),
('Minor Feelings: An Asian American Reckoning', 'Cathy Park Hong', 'One World', '978-1-984-82234-6', 'Nonfiction'),
('Me Talk Pretty One Day', 'David Sedaris', 'Back Bay Books', '978-0-316-77876-6', 'Humor'),
('Brown Girl Dreaming', 'Jacqueline Woodson', 'Speak', '978-0-14-241543-8', 'Young Adult'),
('On Earth We\'re Briefly Gorgeous', 'Ocean Vuong', 'Penguin Press', '978-1-984-89097-4', 'Fiction'),
('Wolf Hall', 'Hilary Mantel', 'Picador', '978-0-8050-9245-6', 'Historical Fiction'),
('Between the World and Me', 'Ta-Nehisi Coates', 'Spiegel & Grau', '978-0-8129-8316-3', 'Nonfiction'),
('The Wind-Up Bird Chronicle', 'Haruki Murakami', 'Vintage International', '978-1-4000-3297-9', 'Fiction'),
('The Sympathizer', 'Viet Thanh Nguyen', 'Grove Press', '978-0-8041-7180-6', 'Fiction'),
('The Friend', 'Sigrid Nunez', 'Riverhead Books', '978-0-7352-2342-2', 'Fiction'),
('All the Light We Cannot See', 'Anthony Doerr', 'Scribner', '978-1-4767-4658-6', 'Fiction'),
('The Overstory', 'Richard Powers', 'W.W. Norton & Company', '978-0-393-35957-6', 'Fiction'),
('The Night Watchman', 'Louise Erdrich', 'Harper Perennial', '978-0-06-267118-2', 'Fiction'),
('Never Let Me Go', 'Kazuo Ishiguro', 'Vintage International', '978-0-375-40561-9', 'Fiction'),
('The Emperor''s Babe', 'Bernardine Evaristo', 'Penguin', '978-0-241-58229-7', 'Fiction'),
('Conversations with Friends', 'Sally Rooney', 'Hogarth', '978-1-984-82001-4', 'Fiction'),
('Bel Canto', 'Ann Patchett', 'Harper Perennial', '978-0-06-196320-4', 'Fiction'),
('Free Food for Millionaires', 'Min Jin Lee', 'Grand Central Publishing', '978-1-54555-2178-7', 'Fiction'),
('The Underground Railroad', 'Colson Whitehead', 'Doubleday', '978-0-385-53710-1', 'Fiction'),
('Transcendent Kingdom', 'Yaa Gyasi', 'Knopf', '978-1-547-1436-6', 'Fiction'),
('The Long Ranger and Tonto Fistfight in Heaven', 'Tommy Orange', 'Knopf', '978-0-525-52036-0', 'Fiction'),
('The Obelisk Gate', 'N.K. Jemisin', 'Orbit', '978-0-316-38958-6', 'Science Fiction'),
('The Mothers', 'Brit Bennett', 'Riverhead Books', '978-0-593-18596-6', 'Fiction'),
('Real Life', 'Brandon Taylor', 'Riverhead Books', '978-0-399-18531-5', 'Fiction'),
('Behold the Dreamers', 'Imbolo Mbue', 'Random House', '978-0-525-42494-8', 'Fiction'),
('Unaccustomed Earth', 'Jhumpa Lahiri', 'Vintage', '978-1-4000-7881-6', 'Fiction'),
('War on Peace: The End of Diplomacy and the Decline of American Influence', 'Ronan Farrow', 'Little, Brown and Company', '978-0-316-48593-6', 'Nonfiction'),
('Everything I Never Told You', 'Celeste Ng', 'Penguin Press', '978-0-7352-1701-8', 'Fiction'),
('Home', 'Marilynne Robinson', 'Picador', '978-0-312-42440-7', 'Fiction'),
('How Beautiful We Were', 'Imbolo Mbue', 'Random House', '978-0-525-5036-0', 'Fiction'),
('Ghost', 'Jason Reynolds', 'Atheneum/Caitlyn Dlouhy Books', '978-1-4814-385-4', 'Young Adult'),
('The Starless Sea', 'Erin Morgenstern', 'Doubleday', '978-0-385-54034-7', 'Fiction'),
('Her Body and Other Parties', 'Carmen Maria Machado', 'Graywolf Press', '978-1-936787-98-9', 'Fiction'),
('Hamnet', 'Maggie O''Farrell', 'Knopf', '978-0-525-42505-1', 'Fiction'),
('The Witch Elm', 'Tana French', 'Penguin Books', '978-0-14-311715-0', 'Mystery'),
('When the Light of the World Was Subdued, Our Songs Came Through: A Norton Anthology of Native Nations Poetry', 'Tommy Orange', 'Knopf', '978-0-525-52038-4', 'Fiction'),
('The God of Small Things', 'Arundhati Roy', 'Random House', '978-0-375-40787-3', 'Fiction'),
('Drive Your Plow Over the Bones of the Dead', 'Olga Tokarczuk', 'Riverhead Books', '978-0-525-65806-8', 'Fiction'),
('The Story of My Teeth', 'Valeria Luiselli', 'Knopf', '978-0-593-08468-3', 'Fiction'),
('Moon Witch, Spider King', 'Marlon James', 'Riverhead Books', '978-1-59463-396-2', 'Fiction'),
('Native Guard', 'Natasha Trethewey', 'Mariner Books', '978-0-618-56608-5', 'Poetry'),
('Sag Harbor', 'Colson Whitehead', 'Doubleday', '978-0-385-54338-6', 'Fiction'),
('The Hate U Give', 'Angie Thomas', 'Balzer + Bray', '978-0-06-249853-3', 'Young Adult'),
('If You Come Softly', 'Jacqueline Woodson', 'Putnam Juvenile', '978-0-515-15397-3', 'Fiction'),
('Night Sky with Exit Wounds', 'Ocean Vuong', 'Penguin Press', '978-1-984-82503-3', 'Poetry'),
('Where Reasons End', 'Yiyun Li', 'Random House', '978-0-399-58961-8', 'Fiction'),
('Bewilderment', 'Richard Powers', 'W.W. Norton & Company', '978-0-393-06571-1', 'Fiction'),
('The Sentence', 'Louise Erdrich', 'Harper', '978-0-06-267117-5', 'Fiction'),
('Kafka on the Shore', 'Haruki Murakami', 'Vintage International', '978-0-375-41067-5', 'Fiction'),
('The Refugees', 'Viet Thanh Nguyen', 'Grove Press', '978-0-8041-7181-3', 'Fiction'),
('Oryx and Crake', 'Margaret Atwood', 'Anchor', '978-0-385-4981-7', 'Fiction'),
('What Are You Going Through', 'Sigrid Nunez', 'Riverhead Books', '978-0-7352-2343-9', 'Fiction'),
('Cloud Cuckoo Land', 'Anthony Doerr', 'Scribner', '978-1-4767-4659-3', 'Fiction'),
('Generosity: An Enhancement', 'Richard Powers', 'W.W. Norton & Company', '978-0-393-06598-8', 'Fiction'),
('LaRose', 'Louise Erdrich', 'Harper', '978-0-06-267116-8', 'Fiction'),
('The Bu', 'Kazuo Ishiguro', 'Faber & Faber', '978-0-571-29366-6', 'Fiction'),
('The Lost City', 'Emily Rollins', 'Penguin Books', '978-014315012', 'Adventure');


use library_db;
DELIMITER $$

CREATE FUNCTION add_member(
    p_name VARCHAR(255),
    p_contact VARCHAR(255)
)
RETURNS VARCHAR(255)
BEGIN
    DECLARE v_result VARCHAR(255);

    -- Check if the member already exists based on contact information
    IF EXISTS (SELECT 1 FROM members WHERE contact = p_contact) THEN
        SET v_result = CONCAT('Member with contact "', p_contact, '" already exists.');
        RETURN v_result;
    END IF;

    -- Insert the new member
    INSERT INTO members (name, contact)
    VALUES (p_name, p_contact);

    SET v_result = CONCAT('Member "', p_name, '" with contact "', p_contact, '" has been added to the library.');
    RETURN v_result;
END$$

DELIMITER ;
use library_db;

DELIMITER $$

CREATE FUNCTION remove_member(
    p_member_id INT
)
RETURNS VARCHAR(255)
BEGIN
    DECLARE v_result VARCHAR(255);
    DECLARE v_member_name VARCHAR(255);
    DECLARE v_active_borrowings INT;

    -- Check if the member exists
    SELECT name INTO v_member_name
    FROM members
    WHERE member_id = p_member_id;

    IF v_member_name IS NULL THEN
        SET v_result = CONCAT('Member with ID ', p_member_id, ' does not exist.');
        RETURN v_result;
    END IF;

    -- Check if the member has active borrowings
    SELECT COUNT(*)
    INTO v_active_borrowings
    FROM borrowings
    WHERE member_id = p_member_id
    AND returned_date IS NULL;

    IF v_active_borrowings > 0 THEN
        SET v_result = CONCAT('Member "', v_member_name, '" cannot be removed because they have active borrowings.');
        RETURN v_result;
    END IF;

    -- If no active borrowings, delete the member
    DELETE FROM members
    WHERE member_id = p_member_id;

    SET v_result = CONCAT('Member "', v_member_name, '" has been removed from the library.');
    RETURN v_result;
END$$

DELIMITER ;

SELECT add_member('JohnDoe', 'john.de@newmail.com');
SELECT remove_member(1);

use library_db;
SELECT COUNT(*) AS num_borrowed_books FROM borrowings WHERE returned_date IS NULL AND due_date < CURDATE();