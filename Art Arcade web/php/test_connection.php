<?php
// Database credentials
$servername = "localhost";
$username = "root"; // Default WAMP username
$password = "";     // Leave it empty for WAMP
$database = "test"; // Your database name
$port = "3306";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
echo "Connected successfully to the database!";
?>
