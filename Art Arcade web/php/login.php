<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$database = "user_auth";
$port = "3306";

// Create connection
$conn = new mysqli($servername, $username, $password, $database);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if form data is set and not empty
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    if (!empty($_POST['email']) && !empty($_POST['password'])) {
        $email = $_POST['email'];
        $password = $_POST['password'];

        // Check if email exists
        $stmt = $conn->prepare("SELECT id, password FROM users WHERE email = ?");
        $stmt->bind_param("s", $email);
        $stmt->execute();
        $stmt->store_result();
        $stmt->bind_result($id, $hashed_password);
        $stmt->fetch();

        if ($stmt->num_rows > 0) {
            // Verify password
            if (password_verify($password, $hashed_password)) {
                // Password is correct, redirect to homefeed.html
                header("Location: homefeed.html");
                exit(); // Ensure no further code runs after redirection
            } else {
                echo "Invalid password.";
            }
        } else {
            echo "Email not found.";
        }

        $stmt->close();
    } else {
        echo "Please fill in all fields.";
    }
}

$conn->close();
?>
