#!/bin/bash

# Update package lists
sudo apt update -y

# Install Apache2 web server
sudo apt install -y apache2

# Create a simple HTML file with server hostname and IP address
echo "<h1>Server Details</h1>
<p><strong>Hostname:</strong> $(hostname)</p>
<p><strong>IP Address:</strong> $(hostname -I | awk '{print $1}')</p>" | sudo tee /var/www/html/index.html > /dev/null

# Restart Apache2 service to ensure it’s running
sudo systemctl restart apache2
