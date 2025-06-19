-- SQLBook: Code
-- Create database
CREATE DATABASE IF NOT EXISTS user_auth;

-- Use the newly created database
USE user_auth;

-- Create users table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
