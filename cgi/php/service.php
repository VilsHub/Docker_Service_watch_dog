<?php
// Set the content type to plain text
header('Content-Type: text/plain');

// Specify the path to the file
$filename = './service_status';
$institution = "DOT17";

// Check if the file exists
if (file_exists($filename)) {

    // Open the file in read-only mode
    $file = fopen($filename, 'r');

    // Read the file content
    $last_time = fread($file, filesize($filename));

    // Close the file
    fclose($file);

    $diff = time() - $last_time;
    echo "validator_monitor_last_run{validator_id=\"$institution\"} $diff";

} else {

    echo "The file $filename does not exist.";

}
?>