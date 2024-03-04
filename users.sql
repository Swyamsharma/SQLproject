-- Active: 1709493645945@@127.0.0.1@3306@test
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    password VARCHAR(255) NOT NULL
);

insert into users (username, password) values ('admin', 'admin');
insert into users (username, password) values ('admin1', 'admin1');

insert into users (username, password) values ('sridhar', 'sridhar');
insert into users (username, password) values ('swyam', 'swyam');
insert into users (username, password) values ('shaurya', 'shaurya');