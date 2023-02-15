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
read -p "Do you want to setup the '$(echo -e ${Cyan}elbrus analytics software${Color_Off})'? (y/n) " yn
case $yn in
    [yY] | "yes" | "Yes" ) break;;
    [nN] | "no" | "No" ) echo -e ${Red}exiting...${Color_Off};
            exit;;
    * ) echo -e ${Red}invalid response${Color_Off};;
esac
done
echo
sleep 0.55

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
sleep 0.75

mkdir -p /var/elbrus
cd /var/elbrus

echo -e "\n${Cyan}info${Color_Off}: the '${Cyan}elbrus analytics software${Color_Off}' will be installed in '/var/elbrus'."
sleep 0.75

if ! which git &>/dev/null; then
  echo -e "${Cyan}info${Color_Off}: downloading git."
  sudo yum install -yq git  > /dev/null
  if [ $? -eq 0 ]; then
      echo -e "${Cyan}info${Color_Off}: downloaded git."
  else
      echo -e "${Red}Error:${Color_Off} unable to install git"
      echo -e "${Cyan}Info:${Color_Off} please install git manually"
      exit 1
  fi
fi

sleep 1
echo -e "\n---------------------------------------------"
echo -e " downloading the '${Cyan}elbrus analytics software${Color_Off}'"
echo -e "---------------------------------------------\n"
sleep 2

echo -ne "\r[          ]"
echo -ne "\r[#         ]"
git clone git@github.com:Elbrus-Analytics/database.git --config core.sshCommand="ssh -i $KEYDIR/database_key -o 'StrictHostKeyChecking=no'" 2>/dev/null
echo -ne "\r[##        ]"
git clone git@github.com:Elbrus-Analytics/tabby.git --config core.sshCommand="ssh -i $KEYDIR/tabby_key -o 'StrictHostKeyChecking=no'" 2>/dev/null
echo -ne "\r[###       ]"
git clone git@github.com:Elbrus-Analytics/snmp-manager.git --config core.sshCommand="ssh -i $KEYDIR/snmp_manager_key -o 'StrictHostKeyChecking=no'" 2>/dev/null
echo -ne "\r[####      ]"
git clone git@github.com:Elbrus-Analytics/ssh-manager.git --config core.sshCommand="ssh -i $KEYDIR/ssh_manager_key -o 'StrictHostKeyChecking=no'" 2>/dev/null
echo -ne "\r[#####     ]"
git clone git@github.com:Elbrus-Analytics/uptime-monitor.git --config core.sshCommand="ssh -i $KEYDIR/uptime_monitor_key -o 'StrictHostKeyChecking=no'" 2>/dev/null
echo -ne "\r[######    ]"
git clone git@github.com:Elbrus-Analytics/geo-session-finder.git --config core.sshCommand="ssh -i $KEYDIR/geo_session_finder_key -o 'StrictHostKeyChecking=no'"   2>/dev/null
echo -ne "\r[#######   ]"
git clone git@github.com:Elbrus-Analytics/office365-analyzer.git --config core.sshCommand="ssh -i $KEYDIR/office365_analyzer_key -o 'StrictHostKeyChecking=no'"   2>/dev/null
echo -ne "\r[########  ]"
git clone git@github.com:Elbrus-Analytics/api.git --config core.sshCommand="ssh -i $KEYDIR/api_key -o 'StrictHostKeyChecking=no'"   2>/dev/null
echo -ne "\r[######### ]"
git clone git@github.com:Elbrus-Analytics/webinterface.git --config core.sshCommand="ssh -i $KEYDIR/webinterface_key -o 'StrictHostKeyChecking=no'"   2>/dev/null
echo -ne "\r[##########]"
echo -ne "\r            "
echo -e "\r${Cyan}info${Color_Off}: checking downloaded directorys:\n"
sleep .3
tocheck="database tabby snmp-manager ssh-manager uptime-monitor geo-session-finder office365-analyzer api webinterface"
for check in $tocheck; do
  sleep .425
  if [ -d $check ]; then
    echo -e "${Green}Successfully${Color_Off} installed the '$check' software."
  else
    echo -e "${Red}Error${Color_Off}: Can not find the '$check' software, please install manually!"
  fi
done

sleep .5
echo -e "\n---------------------------------------------"
echo -e " downloading language dependencies"
echo -e "---------------------------------------------\n"
sleep .5

# ------ nodejs deployment! ------
while true; do
read -p "Do you want to download 'nodejs:12'? (y/n) " yn
  case $yn in
      [yY] | "yes" | "Yes" ) echo -e ${Cyan}Info:${Color_Off} downloading nodejs:12;
      sudo dnf -yq module install nodejs:12 &>/dev/null;
      if [ $? -eq 0 ]; then
          echo -e ${Cyan}Info:${Color_Off} downloaded nodejs:12;
      else
          sleep .5;
          echo -e ${Red}Error:${Color_Off} unable to download nodejs:12;
          sleep .4;
          echo -e ${Cyan}Info:${Color_Off} please download nodejs:12 manually;
      fi
      break;;
      [nN] | "no" | "No" ) echo -e "${Cyan}Info:${Color_Off} please install nodejs:12 manually!";
      break;;
      * ) echo -e ${Red}invalid response${Color_Off};;
  esac
done
echo
sleep .5

# ------ python deployment! ------
while true; do
read -p "Do you want to download 'python3.10'? (y/n) " yn
  case $yn in
      [yY] | "yes" | "Yes" ) echo -e ${Cyan}Info:${Color_Off} downloading python3.10, this may take a while;
                      				echo -ne "\r[       ]"
                      				sleep .234
                              
                      				echo -ne "\r[#      ]"
                      				sudo dnf install gcc openssl-devel bzip2-devel libffi-devel zlib-devel wget make tar -y &> /dev/null
                      				if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to download dependencies for python;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please download python manually;
                                  exit 1;
                              fi
                              
                              echo -ne "\r[##     ]"
                      			  sudo wget https://www.python.org/ftp/python/3.10.0/Python-3.10.0.tar.xz &> /dev/null
                      				if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to download python tar;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please download python manually;
                                  exit 1;
                              fi
                              
                              echo -ne "\r[###    ]"
                      				sudo tar -xf Python-3.10.0.tar.xz &> /dev/null
                              if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to extract python tar;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please download python manually;
                                  exit 1;
                              fi
                              
                      				echo -ne "\r[####   ]"
                  			      cd Python-3.10.0 &> /dev/null
                              if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to extract python tar;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please download python manually;
                                  exit 1;
                              fi
                              
                              sudo ./configure --enable-optimizations &> /dev/null
                      				if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to configure python;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please download python manually;
                                  exit 1;
                              fi
                              
                              echo -ne "\r[#####  ]"
                      				sudo make -j $(nproc) &> /dev/null
                              if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to configure python;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please download python manually;
                                  exit 1;
                              fi
                              
                      				echo -ne "\r[###### ]"
                      				sudo make install &> /dev/null
                      				if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to configure python;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please download python manually;
                                  exit 1;
                              fi
                              
                              echo -ne "\r[#######]"
                     				  cd ..
                              sudo /usr/local/bin/python3.10 -m pip install --upgrade pip &>/dev/null
                              if [ $? -eq 1 ]; then
                                  echo
                                  echo -e ${Red}Error:${Color_Off} unable to upgrade pip;
                                  sleep .4;
                                  echo -e ${Cyan}Info:${Color_Off} please upgrade pip manually;
                              fi
                              
                              echo -ne "\r${Cyan}Info:${Color_Off} downloaded python3.10\n"
                              break;;
      [nN] | "no" | "No" ) echo -e "${Cyan}Info:${Color_Off} please download python3.10 manually!";
                           break;;
      * ) echo -e ${Red}invalid response${Color_Off};;
  esac
done
echo
sleep .5

# ------ rust deployment! ------
while true; do
read -p "Do you want to download 'rust'? (y/n) " yn
  case $yn in
      [yY] | "yes" | "Yes" ) echo -e ${Cyan}Info:${Color_Off} downloading rust;
      dnf install iproute libpcap gcc -yq &> /dev/null
      if [ $? -eq 1 ]; then
          echo
          echo -e ${Red}Error:${Color_Off} unable to download dependencies for rust;
          sleep .4;
          echo -e ${Cyan}Info:${Color_Off} please download rust manually;
          exit 1;
      fi
      
      curl https://sh.rustup.rs -sSf | sh -s -- -y &> /dev/null
      if [ $? -eq 1 ]; then
          echo
          echo -e ${Red}Error:${Color_Off} unable to configure rust;
          sleep .4;
          echo -e ${Cyan}Info:${Color_Off} please download rust manually;
          exit 1;
      fi
      
      source ~/.profile &> /dev/null
      source ~/.cargo/env &> /dev/null
      if [ $? -eq 1 ]; then
          echo
          echo -e ${Red}Error:${Color_Off} unable to link rust;
          sleep .4;
          echo -e ${Cyan}Info:${Color_Off} please download rust manually;
          exit 1;
      fi
      
      echo -e "${Cyan}Info:${Color_Off} downloaded rust\n"
      break;;
      [nN] | "no" | "No" ) echo -e ${Cyan}Info:${Color_Off} please download rust manually!
      break;;
      * ) echo -e ${Red}invalid response${Color_Off};;
  esac
done


# ------ Elbrus deployment! ------

sleep .5
echo -e "\n---------------------------------------------"
echo -e " configuring '${Cyan}elbrus analytics software${Color_Off}' "
echo -e "---------------------------------------------"
sleep .5

echo -e "\n${Cyan}info${Color_Off}: creating global configuration file.  Step[1/10]"
mkdir -p /var/elbrus/shared
sudo chown -R elbrus:elbrus /var/elbrus
while true; do
    read -p "Do you want to create a new global configuration file'? (y/n) " yn
    case $yn in
        [yY] | "yes" | "Yes" ) sleep .4
sudo cat > "/var/elbrus/shared/.config" <<EOL
#database settings
DB_HOST=localhost
DB_PORT=5432
DB_NAME=elbrus
DB_USER=elbrus
EOL
            sudo chown elbrus:elbrus /var/elbrus/shared/.config
            sudo chmod 775 /var/elbrus/shared/.config
            sudo chmod 775 /var/elbrus/shared
            sleep .2
            break;;
        [nN] | "no" | "No" ) echo -e ${Red}skipping...${Color_Off}
        break;;
        * ) echo -e ${Red}invalid response${Color_Off};;
    esac
done
echo -e "${Cyan}info${Color_Off}: created global configuration file."

echo -e "\n\n${Cyan}info${Color_Off}: configuring the database. Step[2/10]"
sudo bash database/install.sh
echo -ne "\r${Cyan}info${Color_Off}: configured the database.             "

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'snmp-manager'.  Step[3/10]"
sudo bash snmp-manager/src/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'snmp-manager'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'ssh-manager'.  Step[4/10]"
sudo bash ssh-manager/src/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'ssh-manager'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'tabby'.  Step[5/10]"
sudo bash tabby/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'tabby'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'office365-analyzer'.  Step[6/10]"
sudo bash office365-analyzer/src/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'office365-analyzer'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'geo-session-finder'.  Step[7/10]"
sudo bash geo-session-finder/src/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'geo-session-finder'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'uptime-monitor'.  Step[8/10]"
sudo bash uptime-monitor/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'uptime-monitor'."
 
echo -e "\n\n${Cyan}info${Color_Off}: configuring 'api'.  Step[9/10]"
sudo bash api/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'api'."

echo -e "\n\n${Cyan}info${Color_Off}: configuring 'webinterface'.  Step[10/10]"
sudo bash webinterface/install.sh
echo -e "${Cyan}info${Color_Off}: configured the 'webinterface'."
echo -e "${Cyan}"
echo " _______        _                      _              _            _       _          "
echo "(_______)      (_)                 _  | |            (_)          (_)     | |     _   "
echo " _____   ____   _  ___  _   _    _| |_| |__  _____    _ ____   ___ _  ____| |__ _| |_ "
echo "|  ___) |  _ \ | |/ _ \| | | |  (_   _)  _ \| ___ |  | |  _ \ /___) |/ _  |  _ (_   _)"
echo "| |_____| | | || | |_| | |_| |    | |_| | | | ____|  | | | | |___ | ( (_| | | | || |_ "
echo "|_______)_| |_|| |\___/ \__  |     \__)_| |_|_____)  |_|_| |_(___/|_|\___ |_| |_| \__)" 
echo "             (__/      (____/                                       (_____|           "
echo " _______ _  _                         _______             _             _             "
echo "(_______) || |                       (_______)           | |        _  (_)            "
echo " _____  | || |__   ____ _   _  ___    _______ ____  _____| |_   _ _| |_ _  ____  ___  "
echo "|  ___) | ||  _ \ / ___) | | |/___)  |  ___  |  _ \(____ | | | | (_   _) |/ ___)/___) "
echo "| |_____| || |_) ) |   | |_| |___ |  | |   | | | | / ___ | | |_| | | |_| ( (___|___ | "
echo "|_______)\_)____/|_|   |____/(___/   |_|   |_|_| |_\_____|\_)__  |  \__)_|\____|___/  "
echo "                                                           (____/                     "
echo -e "\n\n${Green}Success!${Color_Off} finished with the installation of '${Cyan}elbrus-analytics${Color_Off}', we hope you enjoy our product."
echo -e "if any errors occured during the installation you can try to reinstall single sections manually."
echo -e "please consider writing an email to '${Cyan}info@elbrus-analytics.at${Color_Off}' in case you find any bugs."

echo -e "\n\n~${Cyan}Your Elbrus-Analytics Team${Color_Off}"
