# ----- SERVER SETUP -----
# create user
read -p "Please enter your new username (myuser): " username
if [ -z "$username" ]; then
  username="myuser"
fi

useradd ${username}
passwd ${username}
usermod -aG sudo ${username}

# setup domain settings
read -p "Enter domain name (mydomain): " domain
if [ -z "$domain" ]; then
  domain="mydomain"
fi

read -p "Enter Top Level Domain (.com): " tld
if [ -z "$tld" ]; then
  tld=".com"
fi

read -p "Enter application port (3000): " port

if [ -z "$port" ]; then
  port="3000"
fi

# firewall settings
ufw allow OpenSSH
ufw enable

# enable external access
rsync --archive --chown=${username}:${username} ~/.ssh /home/${username}

# ----- NGINX -----
# install nginx
sudo apt update
sudo apt install nginx

# update firewall
sudo ufw allow 'Nginx HTTP'
sudo ufw status #verify

# check web server
curl $(curl -4 icanhazip.com)

# start web server
sudo systemctl start nginx

# enable at startup
sudo systemctl enable nginx

# setup server blocks
sudo mkdir -p /var/www/${domain}
# sudo chown -R ${username}:${username} /var/www/${domain}
sudo chown -R $USER:$USER /var/www/${domain}
sudo chmod -R 755 /var/www/${domain}
sudo touch /etc/nginx/sites-available/${domain}

# Create an index.html file to later verify server is working
cat << EOF > /var/www/${domain}/index.html
<html>
    <head>
        <title>Welcome to ${domain}!</title>
    </head>
    <body>
        <h1>Success!  The your_domain server block is working!</h1>
    </body>
</html>
EOF

# Create the actual server block file
cat << EOF > /etc/nginx/sites-available/${domain}
server {
        listen 80;
        listen [::]:80;

        root /var/www/${domain};
        index index.html index.htm index.nginx-debian.html;

        server_name ${domain}.${tld} www.${domain}.${tld};

        location / {
               #try_files $uri $uri/ =404;
					#proxy_pass http://localhost:${port};
					proxy_http_version 1.1;
					proxy_set_header Upgrade $http_upgrade;
					proxy_set_header Connection 'upgrade';
					proxy_set_header Host $host;
					proxy_cache_bypass $http_upgrade; 
        }
}
EOF

# enable the domain
sudo ln -s /etc/nginx/sites-available/${domain} /etc/nginx/sites-enabled/

# To avoid a possible hash bucket memory problem that can arise from adding additional server names, it is necessary to adjust a single value in the /etc/nginx/nginx.conf file. Open the file:
file_path="/etc/nginx/nginx.conf"
sed -i -e 's/# server_names_hash_bucket_size 64;/server_names_hash_bucket_size 64;/g' "$file_path"

sudo nginx -t
sudo systemctl restart nginx

# ----- LETS ENCRYPE -----
sudo apt install certbot python3-certbot-nginx
sudo systemctl reload nginx

# setup firewall
sudo ufw allow 'Nginx Full'
sudo ufw delete allow 'Nginx HTTP'

# Obtain SSL Cert
sudo certbot --nginx -d ${domain}.com -d www.${domain}.com

# auto-renewal
sudo systemctl status certbot.timer

# certbot dry run
sudo certbot renew --dry-run

# ----- NODE -----
# install node
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash - &&\
sudo apt-get install -y nodejs
node -v
sudo apt install build-essential

# install pm2
sudo npm install pm2@latest -g
pm2 startup systemd

# start pm2 on boot
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u ${username} --hp /home/${username}

# Update sites-available port
sed -i -e 's/#proxy_pass/proxy_pass/g' /etc/nginx/sites-available/${domain}

# Restart nginx
sudo nginx -t
sudo systemctl restart nginx

echo Complete. Deploy application in /var/www/${domain}
echo once complete, run the following command to start
echo pm2 start npm --name "app name" -- start