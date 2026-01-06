#!/bin/bash
dnf update -y || yum update -y
dnf install -y httpd || yum install -y httpd
systemctl enable httpd
systemctl start httpd


COLOR=$((RANDOM % 2))
if [ "$COLOR" -eq 0 ]; then
  BG="lightblue"
  MSG="Hello from App Server (Blue)"
else
  BG="lightgreen"
  MSG="Hello from App Server (Green)"
fi

echo "<html><body style='background-color:$BG;text-align:center;'>
<h1>$MSG</h1><p>Hostname: $(hostname)</p>
</body></html>" > /var/www/html/index.html
