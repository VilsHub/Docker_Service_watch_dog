<?php
// Set the content type to plain text
header('Content-Type: text/plain');

// Specify the path to the file
$filename = 'status.txt';

// Check if the file exists
if (file_exists($filename)) {
    // Open the file in read-only mode
    $file = fopen($filename, 'r');

    // Read the file content
    $content = fread($file, filesize($filename));

    // Close the file
    fclose($file);

    // Display the file content in the browser
   // echo "<pre>".$content."</pre>";
    echo $content;
} else {
    echo "The file $filename does not exist.";
}
?>