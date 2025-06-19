<?php
// Enable error reporting for debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Database credentials
$servername = "localhost";
$username = "root";
$password = "";
$database = "user_auth";
$port = "3306";

// Create connection
$conn = new mysqli($servername, $username, $password, $database, $port);

// Check connection
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if the form was submitted via POST
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    // Debug: Print POST data to check if form data is being received
    echo '<pre>';
    print_r($_POST);
    echo '</pre>';

    // Check if required form fields are filled
    if (!empty($_POST['email']) && !empty($_POST['password'])) {
        $email = $_POST['email'];
        $password = password_hash($_POST['password'], PASSWORD_BCRYPT); // Hash the password securely

        // Check if the email already exists in the database
        if ($stmt = $conn->prepare("SELECT id FROM users WHERE email = ?")) {
            $stmt->bind_param("s", $email);
            $stmt->execute();
            $stmt->store_result();

            // If email already exists, show an error message
            if ($stmt->num_rows > 0) {
                echo "Email already registered!";
            } else {
                // Insert the new user into the database
                if ($stmt = $conn->prepare("INSERT INTO users (email, password) VALUES (?, ?)")) {
                    $stmt->bind_param("ss", $email, $password);

                    // If the insertion is successful, redirect to login page
                    if ($stmt->execute()) {
                        // Prevent "headers already sent" issue by stopping output before redirection
                        header("Location: login.html");
                        exit(); // Always exit after a header redirection
                    } else {
                        echo "Error: " . $stmt->error; // Show SQL error if insertion fails
                    }
                } else {
                    echo "Error preparing statement: " . $conn->error; // Show preparation error
                }
            }

            // Close the prepared statement
            $stmt->close();
        } else {
            echo "Error preparing statement: " . $conn->error; // Show preparation error
        }
    } else {
        echo "Please fill in all fields."; // Show error if fields are empty
    }
}

// Close the database connection
$conn->close();
?>
