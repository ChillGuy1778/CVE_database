-- Создание базы данных
DROP DATABASE IF EXISTS journal_db;
CREATE DATABASE journal_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE journal_db;

-- === Таблица студентов ===
CREATE TABLE students (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL COMMENT 'SHA-256 hash'
);

-- === Таблица учителей ===
CREATE TABLE teachers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL COMMENT 'SHA-256 hash'
);

-- === Таблица предметов ===
CREATE TABLE subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- === Таблица оценок ===
CREATE TABLE grades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    teacher_id INT NOT NULL,
    grade_value INT NOT NULL,
    grade_date DATE NOT NULL,

    CONSTRAINT fk_grade_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_grade_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE RESTRICT ON UPDATE RESTRICT,
    CONSTRAINT fk_grade_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- === Примерные данные ===

-- Учителя (пароль "teacherpass" и "kowalpass")
INSERT INTO teachers (username, full_name, password_hash) VALUES
('KowJan', 'Jan Kowalski', 'e7cf3ef4f17c3999a94f2c6f612e8a888e5b1026878e4e19398b23bd38ec221a'),
('DoeAnn', 'Anna Doe', '67d5e0ed1603e50e9bc7f5ba6d847c87d1871d3b0d10423dad372edf74c15c16');

-- Студенты (пароль "studentpass")
INSERT INTO students (username, full_name, password_hash) VALUES
('LinYar', 'Alina Yaroshyna', '67d5e0ed1603e50e9bc7f5ba6d847c87d1871d3b0d10423dad372edf74c15c16');

-- Предметы
INSERT INTO subjects (name) VALUES
('Mathematics'),
('History');

-- Оценки
INSERT INTO grades (student_id, subject_id, teacher_id, grade_value, grade_date) VALUES
(1, 1, 1, 5, '2025-05-01');
