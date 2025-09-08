#!/bin/bash

# Update package list and install Nginx
sudo apt-get update
sudo apt-get install -y nginx

# Start and enable Nginx
sudo systemctl start nginx
sudo systemctl enable nginx

# Create HTML directory and sample page
sudo mkdir -p /var/www/html
sudo cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Azure Web Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        img { max-width: 100%; height: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to Azure Web Server!</h1>
        <p>This web server is running on an Azure VM with Nginx.</p>
        <img src="REPLACE_WITH_BLOB_URL" alt="Sample Image from Blob Storage">
        <p>Image hosted on Azure Blob Storage</p>
    </div>
</body>
</html>
EOF

# Configure Nginx to serve our custom page
sudo cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    root /var/www/html;
    index index.html index.htm;
    
    server_name _;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Restart Nginx to apply changes
sudo systemctl restart nginx

echo "Web server installation completed!"
