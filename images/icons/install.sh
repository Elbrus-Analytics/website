#!/usr/bin/env bash

# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

while true; do
echo -e "${Cyan}info${Color_Off}: please make sure you run the script as 'elbrus', be aware 'elbrus' ${Cyan}needs${Color_Off} sudo permissions."
read -p "Do you want to proceed with the setup of the '$(echo -e ${Cyan}elbrus analytics software${Color_Off})'? (y/n) " yn
case $yn in
    [yY] | "yes" | "Yes" ) break;;
    [nN] | "no" | "No" ) echo -e ${Red}exiting...${Color_Off};
            exit;;
    * ) echo -e ${Red}invalid response${Color_Off};;
esac
done
echo
sleep 0.25

KEYDIR=/var/elbrus/shared/key
read -p "Where are the previously generated ssh keys stored (dir) [$KEYDIR]: " KEYDIR
KEYDIR=${KEYDIR:-/var/elbrus/shared/key}

while true; do
read -p "Please confirm the key folder '$KEYDIR'. (y/n/exit) " confirm
case $confirm in
    [yY] | "yes" | "Yes" ) break;;
    [nN] | "no" | "No" )
            read -p "Where should the ssh keys be stored (dir) [$KEYDIR]: " KEYDIR;
            KEYDIR=${KEYDIR:-/var/elbrus/shared/key};;
    [eE] | "exit" | "Exit" ) echo -e ${Red}exiting...${Color_Off};
            exit;;
    * ) echo -e ${Red}invalid response${Color_Off};;
esac
done

echo
echo -e "${Cyan}info${Color_Off}: the '${Cyan}elbrus analytics software${Color_Off}' will be installed in '/var/elbrus'."
mkdir -p /var/elbrus
cd /var/elbrus
echo

echo -e "${Cyan}info${Color_Off}: installing the vcs git."
sudo yum install -yq git  &> /dev/null
echo -e "${Cyan}info${Color_Off}: installed git."


echo -e "\n\nDownloading the '${Cyan}elbrus analytics software${Color_Off}':"
sleep 0.3
echo -ne "\r[         ]"
echo -ne "\r[#        ]"
git clone git@github.com:Elbrus-Analytics/database.git --config core.sshCommand="ssh -i $KEYDIR/database_key" 2>/dev/null
echo -ne "\r[##       ]"
git clone git@github.com:Elbrus-Analytics/tabby.git --config core.sshCommand="ssh -i $KEYDIR/tabby_key" 2>/dev/null
echo -ne "\r[###       ]"
git clone git@github.com:Elbrus-Analytics/snmp-manager.git --config core.sshCommand="ssh -i $KEYDIR/snmp_manager_key" 2>/dev/null
echo -ne "\r[####      ]"
git clone git@github.com:Elbrus-Analytics/ssh-manager.git --config core.sshCommand="ssh -i $KEYDIR/ssh_manager_key" 2>/dev/null
echo -ne "\r[#####     ]"
git clone git@github.com:Elbrus-Analytics/uptime-monitor.git --config core.sshCommand="ssh -i $KEYDIR/uptime_monitor_key" 2>/dev/null
echo -ne "\r[######    ]"
git clone git@github.com:Elbrus-Analytics/geo-session-finder.git --config core.sshCommand="ssh -i $KEYDIR/geo_session_finder_key" 2>/dev/null
echo -ne "\r[#######   ]"
git clone git@github.com:Elbrus-Analytics/office365-analyzer.git --config core.sshCommand="ssh -i $KEYDIR/office365_analyzer_key" 2>/dev/null
echo -ne "\r[########  ]"
git clone git@github.com:Elbrus-Analytics/api.git --config core.sshCommand="ssh -i $KEYDIR/api_key" 2>/dev/null
echo -ne "\r[######### ]"
git clone git@github.com:Elbrus-Analytics/webinterface.git --config core.sshCommand="ssh -i $KEYDIR/webinterface_key" 2>/dev/null
echo -ne "\r[##########]"
echo -e "\n\n${Cyan}checking${Color_Off} downloaded directorys:"
sleep .3
tocheck="database capture-device report-generator snmp-manager ssh-manager uptime-monitor geo-session-finder office365-analyzer api webinterface"
for check in $tocheck; do
  sleep .425
  if [ -d $check ]; then
    echo -e "${Green}Successfully${Color_Off} installed the '$check' software."
  else
    echo -e "${Red}Error${Color_Off}: Can not find the '$check' software, please install manually!"
  fi
done
echo

echo -e "Downloading language dependencys:\n"

while true; do
read -p "Do you want to install nodejs:12'? (y/n) " yn
  case $yn in
      [yY] | "yes" | "Yes" ) echo -e ${Cyan}Info:${Color_Off} installing nodejs:12;
      sudo dnf -yq module install nodejs:12;
      echo -e ${Cyan}Info:${Color_Off} installed nodejs:12;
      break;;
      [nN] | "no" | "No" ) echo -e ${Cyan}Info:${Color_Off} please install nodejs:12 manually!;
      break;;
      * ) echo -e ${Red}invalid response${Color_Off};;
  esac
done
echo

while true; do
read -p "Do you want to install python3.10'? (y/n) " yn
  case $yn in
      [yY] | "yes" | "Yes" ) echo -e ${Cyan}Info:${Color_Off} installing python3.10;
      sudo bash ssh-manager/pythonSourceInstall.sh;
      /usr/local/bin/python3.10 -m pip install --upgrade pip;
      echo -e ${Cyan}Info:${Color_Off} installed python3.10;
      break;;
      [nN] | "no" | "No" ) echo -e ${Cyan}Info:${Color_Off} please install python3.10 manually!;
      break;;
      * ) echo -e ${Red}invalid response${Color_Off};;
  esac
done
echo

while true; do
read -p "Do you want to install rust'? (y/n) " yn
  case $yn in
      [yY] | "yes" | "Yes" ) echo -e ${Cyan}Info:${Color_Off} installing rust;
      sudo dnf install gcc -yq;
      curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh;
      source ~/.profile;
      source ~/.cargo/env;
      echo -e ${Cyan}Info:${Color_Off} installed rust;
      break;;
      [nN] | "no" | "No" ) echo -e ${Cyan}Info:${Color_Off} please install rust manually!
      break;;
      * ) echo -e ${Red}invalid response${Color_Off};;
  esac
done
echo
echo -e "${Cyan}info${Color_Off}: installation and configuration of the database."

SECRET=$(/dev/urandom | tr -dc A-Za-z0-9 | head -c 64)
DBUSERPASS=$SECRET
echo -e "${Cyan}info${Color_Off}: the password has been automatically created!"
read -p "Please choose a password for the database user [$DBUSERPASS]: " DBUSERPASS
DBUSERPASS=${DBUSERPASS:-$SECRET}

while true; do
read -p "Please confirm your password '$DBUSERPASS'. (y/n/exit) " confirm
case $confirm in
    [yY] | "yes" | "Yes" ) break;;
    [nN] | "no" | "No" )
            read -p "Where should the ssh keys be stored (dir) [$DBUSERPASS]: " DBUSERPASS;
            DBUSERPASS=${DBUSERPASS:-elbrus123!};;
    [eE] | "exit" | "Exit" ) echo -e ${Red}exiting...${Color_Off};
            exit;;
    * ) echo -e ${Red}invalid response${Color_Off};;
esac
done
echo -e "\n${Cyan}info${Color_Off}: configuring the database. Step[1/9]"
echo -ne "\r[               ]"
sleep .255 
echo -ne "\r[#              ]"
sudo yum install -yq https://download.postgresql.org/pub/repos/yum/reporpms/\EL-$(rpm -E %{rhel})-x86_64/pgdg-redhat-repo-latest.noarch.rpm
echo -ne "\r[##             ]"
sudo cat > /etc/yum.repos.d/timescale_timescaledb.repo <<EOL
[timescale_timescaledb]
name=timescale_timescaledb
baseurl=https://packagecloud.io/timescale/timescaledb/el/$(rpm -E %{rhel})/\$basearch
repo_gpgcheck=1
gpgcheck=0
enabled=1
gpgkey=https://packagecloud.io/timescale/timescaledb/gpgkey
sslverify=1
sslcacert=/etc/pki/tls/certs/ca-bundle.crt
metadata_expire=300
EOL

echo -ne "\r[###            ]"
sudo yum update -yq
echo -ne "\r[####           ]"
sudo dnf -qy module disable postgresql
echo -ne "\r[#####          ]"
sudo dnf install postgresql14 postgresql14-server -yq
echo -ne "\r[######         ]"
sudo dnf install timescaledb-2-postgresql-14 -yq
echo -ne "\r[#######        ]"
sudo /usr/pgsql-14/bin/postgresql-14-setup initdb &> /dev/null
echo -ne "\r[########       ]"
sudo systemctl enable postgresql-14 &> /dev/null
echo -ne "\r[#########      ]"
sudo systemctl start postgresql-14 &> /dev/null
echo -ne "\r[##########     ]"
sudo sed  -i -e "/#shared_preload_libraries = ''/c  shared_preload_libraries = 'timescaledb'" "/var/lib/pgsql/14/data/postgresql.conf" &> /dev/null
echo -ne "\r[###########    ]"
sudo timescaledb-tune --pg-config=/usr/pgsql-14/bin/pg_config --yes &> /dev/null
echo -ne "\r[############   ]"
sudo systemctl restart postgresql-14 &> /dev/null
echo -ne "\r[#############  ]"

su - postgres -c "psql -c 'CREATE DATABASE elbrus;'" &> /dev/null
runuser -u postgres -- psql -c "ALTER DATABASE elbrus SET timezone to 'Europe/Vienna';" &> /dev/null
runuser -u postgres -- psql -c "CREATE USER elbrus PASSWORD '$DBUSERPASS';" &> /dev/null
su - postgres -c "psql -c 'GRANT ALL ON DATABASE elbrus TO elbrus;'" &> /dev/null
runuser -u postgres -- psql -d elbrus -c "CREATE EXTENSION IF NOT EXISTS timescaledb;" &> /dev/null
echo -ne "\r[############## ]"
psql -U elbrus -d elbrus -f database/sql/init.sq &> /dev/null
echo -ne "\r[###############]"
echo -e "\n${Cyan}info${Color_Off}: configured the database."
echo
mkdir -p /var/elbrus/shared

echo -e "\n${Cyan}info${Color_Off}: creating global configuration file.  Step[2/9]"
cat > var/elbrus/shared/.config << EOF
#database settings
DB_HOST=localhost
DB_PORT=5432
DB_NAME=elbrus
DB_USER=elbrus
DB_PASSWORD=$DBUSERPASS
EOF
sudo chown elbrus:elbrus /var/elbrus/shared/.config
sudo chmod 776 /var/elbrus/shared/.config
echo -e "\n${Cyan}info${Color_Off}: created global configuration file."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'snmp-manager'.  Step[3/9]"
sudo bash snmp-manager/src/install.sh
echo -e "\n${Cyan}info${Color_Off}: configured the 'snmp-manager'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'ssh-manager'.  Step[4/9]"
sudo bash ssh-manager/src/install.sh
echo -e "\n${Cyan}info${Color_Off}: configured the 'ssh-manager'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'tabby'.  Step[5/9]"
sudo bash tabby/install.sh
echo -e "\n${Cyan}info${Color_Off}: configured the 'tabby'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'geo-session-finder'.  Step[6/9]"
sudo bash geo-session-finder/src/install.sh
echo -e "\n${Cyan}info${Color_Off}: configured the 'geo-session-finder'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'uptime-monitor'.  Step[7/9]"
sudo bash uptime-monitor/install.sh
echo -e "\n${Cyan}info${Color_Off}: configured the 'uptime-monitor'."
 
echo -e "\n\n${Cyan}info${Color_Off}: configuring 'api'.  Step[8/9]"
sudo bash api/install.sh
echo -e "\n${Cyan}info${Color_Off}: configured the 'api'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'webinterface'.  Step[9/9]"
sudo bash webinterface/install.sh
echo -e "\n${Cyan}info${Color_Off}: configured the 'webinterface'."
echo -e "${Cyan}"
echo " _______        _                      _              _            _       _                                   
(_______)      (_)                 _  | |            (_)          (_)     | |     _                            
 _____   ____   _  ___  _   _    _| |_| |__  _____    _ ____   ___ _  ____| |__ _| |_    _____                 
|  ___) |  _ \ | |/ _ \| | | |  (_   _)  _ \| ___ |  | |  _ \ /___) |/ _  |  _ (_   _)  (_____)                
| |_____| | | || | |_| | |_| |    | |_| | | | ____|  | | | | |___ | ( (_| | | | || |_                          
|_______)_| |_|| |\___/ \__  |     \__)_| |_|_____)  |_|_| |_(___/|_|\___ |_| |_| \__)                         
             (__/      (____/                                       (_____|                                    
 _______ _  _                         _______             _             _               _______                
(_______) || |                       (_______)           | |        _  (_)             (_______)               
 _____  | || |__   ____ _   _  ___    _______ ____  _____| |_   _ _| |_ _  ____  ___       _ _____ _____ ____  
|  ___) | ||  _ \ / ___) | | |/___)  |  ___  |  _ \(____ | | | | (_   _) |/ ___)/___)     | | ___ (____ |    \ 
| |_____| || |_) ) |   | |_| |___ |  | |   | | | | / ___ | | |_| | | |_| ( (___|___ |     | | ____/ ___ | | | |
|_______)\_)____/|_|   |____/(___/   |_|   |_|_| |_\_____|\_)__  |  \__)_|\____|___/      |_|_____)_____|_|_|_|
                                                           (____/                                              "
echo -e "\n\n${Cyan}info:${Color_Off} finished with the installation of '${Cyan}elbrus-analytics${Color_Off}', we hope you enjoy our product.
If any errors occured during the installation you can try to reinstall single sections manually, using the ${Cyan}deployment guide${Color_Off}.
Please consider writing an email to '${Cyan}info@elbrus-analytics.at${Color_Off}' in case you find any bugs.

~Your Elbrus-Analytics Team"                                                                                   
echo -e "${Color_Off}"