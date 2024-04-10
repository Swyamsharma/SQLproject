-- Create the database
CREATE DATABASE student_db;

-- Use the database
USE student_db;

-- Create the student table
CREATE TABLE students (
  student_id INT AUTO_INCREMENT PRIMARY KEY,
  first_name VARCHAR(50) NOT NULL,
  last_name VARCHAR(50) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  phone VARCHAR(20),
  date_of_birth DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(100) NOT NULL
);

-- Create the courses table
CREATE TABLE courses (
  course_id INT AUTO_INCREMENT PRIMARY KEY,
  course_name VARCHAR(100) NOT NULL,
  course_description TEXT,
  credits INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Create the enrollments table
CREATE TABLE enrollments (
  enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  course_id INT NOT NULL,
  grade DECIMAL(4,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id),
  FOREIGN KEY (course_id) REFERENCES courses(course_id)
);

-- Insert sample data
INSERT INTO students (first_name, last_name, email, phone, date_of_birth, username, password)
VALUES
  ('John', 'Doe', 'john.doe@example.com', '1234567890', '1990-01-01', 'student1', 'student123'),
  ('Jane', 'Doe', 'jane.doe@example.com', '0987654321', '1992-05-15', 'student2', 'student123'),
  ('Bob', 'Smith', 'bob.smith@example.com', '5555555555', '1988-11-30', 'student3', 'student123');

INSERT INTO courses (course_name, course_description, credits)
VALUES
  ('Introduction to Computer Science', 'Covers the fundamentals of computer science', 3),
  ('Calculus I', 'Covers the concepts of differential calculus', 4),
  ('English Composition', 'Focuses on developing writing skills', 3);

INSERT INTO enrollments (student_id, course_id, grade)
VALUES
  (1, 1, 3.5),
  (1, 2, 4.0),
  (2, 1, 3.8),
  (2, 3, 4.0),
  (3, 1, 2.5),
  (3, 2, 3.0);


-- Create the reports table
CREATE TABLE reports (
  report_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  report_date DATE NOT NULL,
  report_title VARCHAR(100) NOT NULL,
  report_content TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- Insert sample data
INSERT INTO reports (student_id, report_date, report_title, report_content)
VALUES
  (1, '2023-04-01', 'Midterm Progress Report', 'The student is performing well in all courses and is on track to complete the semester successfully.'),
  (1, '2023-06-15', 'Final Exam Preparation', 'The student has been diligently studying and is well-prepared for the final exams.'),
  (2, '2023-05-01', 'Academic Advising Report', 'The student met with the academic advisor to discuss course selection for the upcoming semester.'),
  (2, '2023-07-01', 'Internship Placement', 'The student has secured an internship at a local technology company for the summer.'),
  (3, '2023-03-15', 'Tutoring Recommendation', 'The student has been referred to the tutoring center for additional support in mathematics.');


  CREATE TABLE news (
  news_id INT AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(100) NOT NULL,
  content TEXT NOT NULL,
  posted_by VARCHAR(50) NOT NULL,
  posted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_published BOOLEAN DEFAULT TRUE
);

-- Sample data
INSERT INTO news (title, content, posted_by)
VALUES
  ('Campus Events Update', 'The annual student festival will be held on May 15th.', 'Admin'),
  ('New Scholarship Opportunities', 'The university is offering several new scholarship programs for the upcoming semester.', 'Admin'),
  ('Library Hours Change', 'The library will have extended hours during the final exam period.', 'Librarian');

  CREATE TABLE complaints (
  complaint_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  complaint_title VARCHAR(100) NOT NULL,
  complaint_description TEXT NOT NULL,
  complaint_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('open', 'in progress', 'resolved') DEFAULT 'open',
  FOREIGN KEY (student_id) REFERENCES students(student_id)
);

-- Sample data
INSERT INTO complaints (student_id, complaint_title, complaint_description)
VALUES
  (1, 'Faulty Equipment in Lab', 'The computers in the computer lab are outdated and frequently freeze during use.'),
  (2, 'Unsatisfactory Food Options', 'The food options in the cafeteria are limited and not very healthy.'),
  (3, 'Lack of Study Spaces', 'There are not enough quiet study spaces available on campus.');

  CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(100) NOT NULL
);

-- Sample data
INSERT INTO users (username, password)
VALUES
  ('student1', 'student123'),
  ('student2', 'student123'),
  ('student3', 'student123');

CREATE TABLE attendance_list (
  attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  subject VARCHAR(100) NOT NULL,
  attendance_date DATE NOT NULL,
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  secret_code VARCHAR(50) NOT NULL
);

-- Sample data
INSERT INTO attendance_list (subject, attendance_date, start_time, end_time, secret_code)
VALUES
  ('Mathematics', '2023-04-7', '09:00:00', '11:30:00', 'abc123'),
  ('English', '2023-04-16', '11:00:00', '12:30:00', 'def456'),
  ('Physics', '2023-04-17', '14:00:00', '15:30:00', 'ghi789'),
  ('Chemistry', '2023-04-18', '16:00:00', '17:30:00', 'jkl012');

-- Create the student_attendance table
CREATE TABLE student_attendance (
  student_attendance_id INT AUTO_INCREMENT PRIMARY KEY,
  student_id INT NOT NULL,
  attendance_id INT NOT NULL,
  attendance_status ENUM('present', 'absent') NOT NULL,
  FOREIGN KEY (attendance_id) REFERENCES attendance_list(attendance_id),
  UNIQUE KEY (student_id, attendance_id)
);

-- Sample data for attendance_list
INSERT INTO attendance_list (subject, attendance_date, attendance_status)
VALUES
  ('Mathematics', '2023-04-15', 1),
  ('English', '2023-04-16', 0),
  ('Physics', '2023-04-17', 1),
  ('Chemistry', '2023-04-18', 0);

-- Sample data for student_attendance
INSERT INTO student_attendance (student_id, attendance_id, attendance_status)
VALUES
  (1, 1, 'present'),
  (1, 2, 'absent'),
  (1, 3, 'present'),
  (1, 4, 'present'),
  (2, 1, 'present'),
  (2, 2, 'present'),
  (2, 3, 'absent'),
  (2, 4, 'absent'),
  (3, 1, 'absent'),
  (3, 2, 'present'),
  (3, 3, 'present'),
  (3, 4, 'absent');

use student_db;
DELIMITER //

CREATE FUNCTION create_attendance_func(subject_name VARCHAR(255))
RETURNS VARCHAR(255)
BEGIN
    DECLARE success_status VARCHAR(255);
    DECLARE start_time DATETIME;
    DECLARE end_time DATETIME;
    DECLARE secret_code VARCHAR(6);

    -- Generate start and end time for the attendance (15 minutes duration)
    SET start_time = NOW();
    SET end_time = DATE_ADD(start_time, INTERVAL 15 MINUTE);

    -- Generate a random secret code
    SET secret_code = CONCAT(SUBSTRING(MD5(RAND()) FROM 1 FOR 6));

    -- Insert attendance record into the table
    INSERT INTO attendance_list (subject, attendance_date, start_time, end_time, secret_code) 
    VALUES (subject_name, CURDATE(), start_time, end_time, secret_code);

    -- Check if the INSERT was successful
    IF ROW_COUNT() > 0 THEN
        SET success_status = 'Attendance created successfully.';
    ELSE
        SET success_status = 'Failed to create attendance.';
    END IF;

    -- Concatenate success status and secret code
    SET success_status = CONCAT(success_status, ' Secret Code: ', secret_code);

    RETURN success_status;
END //

DELIMITER ;


SELECT create_attendance_func('Mathematics');

CREATE FUNCTION clear_attendance_records_and_return_status(attendance_id_param INT)
RETURNS VARCHAR(100)
BEGIN
    DECLARE status_msg VARCHAR(100);

    -- Initialize status message
    SET status_msg = '';

    -- Delete records from student_attendance table
    DELETE FROM student_attendance WHERE attendance_id = attendance_id_param;

    -- Check if any rows were affected
    DELETE FROM attendance_list WHERE attendance_id = attendance_id_param;
    IF ROW_COUNT() > 0 THEN
        SET status_msg = CONCAT('Records successfully cleared for attendance ID ', CAST(attendance_id_param AS CHAR));
    ELSE
        SET status_msg = CONCAT('No records found for attendance ID ', CAST(attendance_id_param AS CHAR));
    END IF;

    RETURN status_msg;
END;


select clear_attendance_records_and_return_status(27);

USE student_db;
DELIMITER //

CREATE FUNCTION add_news_func(news_title VARCHAR(255), news_content TEXT)
RETURNS VARCHAR(255)
BEGIN
    DECLARE add_result VARCHAR(255);

    -- Insert news record into the table
    INSERT INTO news (title, content, posted_by) VALUES (news_title, news_content, 'Admin');

    -- Check if the INSERT was successful
    IF ROW_COUNT() > 0 THEN
        SET add_result = 'News added successfully.';
    ELSE
        SET add_result = 'Failed to add news.';
    END IF;

    RETURN add_result;
END //

CREATE FUNCTION remove_news_func(news_id_param INT)
RETURNS VARCHAR(255)
BEGIN
    DECLARE remove_result VARCHAR(255);

    -- Delete news record from the table
    DELETE FROM news WHERE news_id = news_id_param;

    -- Check if any rows were affected
    IF ROW_COUNT() > 0 THEN
        SET remove_result = CONCAT('News with ID ', CAST(news_id_param AS CHAR), ' removed successfully.');
    ELSE
        SET remove_result = CONCAT('No news found with ID ', CAST(news_id_param AS CHAR), '.');
    END IF;

    RETURN remove_result;
END //

DELIMITER ;
-- Create a function to add a student report
-- Create a function to add a student report
CREATE FUNCTION add_student_report_func(
    student_id_param INT,
    report_date_param DATE,
    report_title_param VARCHAR(100),
    report_content_param TEXT
) RETURNS VARCHAR(255)
BEGIN
    DECLARE result_msg VARCHAR(255);

    -- Check if the student exists
    DECLARE student_exists INT;
    SELECT COUNT(*) INTO student_exists FROM students WHERE student_id = student_id_param;

    IF student_exists = 0 THEN
        SET result_msg = 'Student not found.';
        RETURN result_msg;
    END IF;

    -- Attempt to insert the student reportv
    INSERT INTO reports (student_id, report_date, report_title, report_content)
    VALUES (student_id_param, report_date_param, report_title_param, report_content_param);

    -- Check if the insertion was successful
    IF ROW_COUNT() > 0 THEN
        SET result_msg = 'Student report added successfully.';
    ELSE
        SET result_msg = 'Failed to add student report.';
    END IF;

    RETURN result_msg;
END;


-- Create a function to remove a student report
CREATE FUNCTION remove_student_report_func(report_id_param INT) RETURNS VARCHAR(255)
BEGIN
    DECLARE result_msg VARCHAR(255);

    -- Attempt to delete the student report
    DELETE FROM reports WHERE report_id = report_id_param;

    -- Check if the deletion was successful
    IF ROW_COUNT() > 0 THEN
        SET result_msg = 'Student report removed successfully.';
    ELSE
        SET result_msg = 'Failed to remove student report.';
    END IF;

    RETURN result_msg;
END;
SELECT add_student_report_func(66, '2000-11-11', '234', '323') AS result