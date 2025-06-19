CREATE DATABASE IF NOT EXISTS blog_db;

USE blog_db;

CREATE TABLE IF NOT EXISTS posts (
    id INT(11) UNSIGNED AUTO_INCREMENT PRIMARY KEY,  -- Unique ID for each post
    title VARCHAR(255) NOT NULL,                    -- Blog post title
    category VARCHAR(255) NOT NULL,                 -- Category of the post
    description TEXT NOT NULL,                      -- Blog post description or content
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- Time when the post was created
);
