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
