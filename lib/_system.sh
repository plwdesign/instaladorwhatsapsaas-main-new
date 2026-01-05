#!/bin/bash

system_create_user() {
  print_banner
  printf "${WHITE} 💻 Agora, vamos criar o usuário para a instancia...${GRAY_LIGHT}\n\n"
  sleep 2

  sudo su - root <<EOF
if id "deploy" &>/dev/null; then
  echo "User deploy already exists"
else
  useradd -m -s /bin/bash deploy
  usermod -aG sudo deploy
  echo "deploy:${mysql_root_password}" | chpasswd
  echo "deploy ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/deploy
fi
EOF
  sleep 2
}

system_git_clone() {
  print_banner
  printf "${WHITE} 💻 Fazendo download do código Whaticket...${GRAY_LIGHT}\n\n"
  sleep 2

  read -p "Digite seu GitHub username: " github_username
  read -s -p "Digite seu GitHub token: " github_token
  echo ""

  if [[ $link_git == *"github.com"* ]]; then
    repo_url=$(echo "$link_git" | sed -E "s#https://#https://${github_username}:${github_token}@#")
    sudo -u deploy git clone "$repo_url" /home/deploy/${instancia_add}/
  else
    sudo -u deploy git clone "$link_git" /home/deploy/${instancia_add}/
  fi

  sudo chown -R deploy:deploy /home/deploy/${instancia_add}
  sleep 2
}

system_update() {
  print_banner
  printf "${WHITE} 💻 Vamos atualizar o sistema Whaticket...${GRAY_LIGHT}\n\n"
  sleep 2

  sudo su - root <<EOF
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y
apt-get install -y \
libxshmfence-dev \
libgbm-dev \
wget \
unzip \
fontconfig \
locales \
libasound2t64 \
libatk-bridge2.0-0 \
libatk1.0-0 \
libc6 \
libcairo2 \
libcups2 \
libdbus-1-3 \
libexpat1 \
libfontconfig1 \
libgcc1 \
libgdk-pixbuf2.0-0 \
libglib2.0-0 \
libgtk-3-0 \
libnspr4 \
libnss3 \
libpango-1.0-0 \
libpangocairo-1.0-0 \
libstdc++6 \
libx11-6 \
libx11-xcb1 \
libxcb1 \
libxcomposite1 \
libxcursor1 \
libxdamage1 \
libxext6 \
libxfixes3 \
libxi6 \
libxrandr2 \
libxrender1 \
libxss1 \
libxtst6 \
ca-certificates \
fonts-liberation \
libappindicator3-1 \
lsb-release \
xdg-utils
EOF
  sleep 2
}

deletar_tudo() {
  print_banner
  printf "${WHITE} 💻 Vamos deletar o Whaticket...${GRAY_LIGHT}\n\n"
  sleep 2

  sudo su - root <<EOF
docker container rm redis-${empresa_delete} --force
rm -rf /etc/nginx/sites-enabled/${empresa_delete}-frontend
rm -rf /etc/nginx/sites-enabled/${empresa_delete}-backend
rm -rf /etc/nginx/sites-available/${empresa_delete}-frontend
rm -rf /etc/nginx/sites-available/${empresa_delete}-backend
su - postgres -c "dropuser ${empresa_delete}"
su - postgres -c "dropdb ${empresa_delete}"
EOF

  sudo su - deploy <<EOF
rm -rf /home/deploy/${empresa_delete}
pm2 delete ${empresa_delete}-frontend ${empresa_delete}-backend
pm2 save
EOF
}

configurar_bloqueio() {
  sudo su - deploy <<EOF
pm2 stop ${empresa_bloquear}-backend
pm2 save
EOF
}

configurar_desbloqueio() {
  sudo su - deploy <<EOF
pm2 start ${empresa_desbloquear}-backend
pm2 save
EOF
}

system_node_install() {
  sudo su - root <<EOF
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt-get install -y nodejs
npm install -g npm@latest
echo "deb http://apt.postgresql.org/pub/repos/apt \$(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update -y
apt-get install -y postgresql
timedatectl set-timezone America/Sao_Paulo
EOF
}

system_docker_install() {
  sudo su - root <<EOF
apt-get update -y
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=\$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \$(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
EOF
}

system_puppeteer_dependencies() {
  sudo su - root <<EOF
apt-get update -y
apt-get install -y \
libxshmfence-dev \
libgbm-dev \
wget \
unzip \
fontconfig \
locales \
libasound2t64 \
libatk-bridge2.0-0 \
libatk1.0-0 \
libc6 \
libcairo2 \
libcups2 \
libdbus-1-3 \
libexpat1 \
libfontconfig1 \
libgcc1 \
libgdk-pixbuf2.0-0 \
libglib2.0-0 \
libgtk-3-0 \
libnspr4 \
libnss3 \
libpango-1.0-0 \
libpangocairo-1.0-0 \
libstdc++6 \
libx11-6 \
libx11-xcb1 \
libxcb1 \
libxcomposite1 \
libxcursor1 \
libxdamage1 \
libxext6 \
libxfixes3 \
libxi6 \
libxrandr2 \
libxrender1 \
libxss1 \
libxtst6 \
ca-certificates \
fonts-liberation \
libappindicator3-1 \
lsb-release \
xdg-utils
EOF
}

system_pm2_install() {
  sudo su - root <<EOF
npm install -g pm2
EOF
}

system_snapd_install() {
  sudo su - root <<EOF
apt install -y snapd
snap install core
snap refresh core
EOF
}

system_certbot_install() {
  sudo su - root <<EOF
apt-get remove -y certbot
snap install --classic certbot
ln -s /snap/bin/certbot /usr/bin/certbot
EOF
}

system_nginx_install() {
  sudo su - root <<EOF
apt install -y nginx
rm /etc/nginx/sites-enabled/default
EOF
}

system_nginx_restart() {
  sudo su - root <<EOF
service nginx restart
EOF
}

system_nginx_conf() {
  sudo su - root <<EOF
echo "client_max_body_size 100M;" > /etc/nginx/conf.d/deploy.conf
EOF
}
