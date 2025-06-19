<?php

// Database configuration
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "blog_db";
$port = "3306";

// Create connection
$conn = new mysqli($servername, $username, $password, $dbname);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Decode the incoming JSON data
$data = json_decode(file_get_contents("php://input"), true);

// Get post data from the JSON request
$postTitle = $data['title'];
$postCategory = $data['category'];
$postDescription = $data['description'];

// Insert post into the database
$sql = "INSERT INTO posts (title, category, description, created_at) VALUES ('$postTitle', '$postCategory', '$postDescription', NOW())";

if ($conn->query($sql) === TRUE) {
    echo json_encode(["success" => true, "message" => "Post created successfully!"]);
} else {
    echo json_encode(["success" => false, "message" => "Error: " . $sql . "<br>" . $conn->error]);
}

$conn->close();
?>
