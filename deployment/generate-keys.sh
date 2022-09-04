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
read -p "Welchome to the setup of the '$(echo -e ${Cyan}elbrus analytics software${Color_Off})'? (y/n) " yn
case $yn in
    [yY] | "yes" | "Yes" ) break;;
    [nN] | "no" | "No" ) echo -e ${Red}exiting...${Color_Off};
            exit;;
    * ) echo -e ${Red}invalid response${Color_Off};;
esac
done
echo
sleep 0.25

echo -e "${Cyan}starting${Color_Off} to create ssh-keys to clone the github repositorys."
echo
KEYDIR=/var/elbrus/shared/key
read -p "Where should the ssh keys be stored (dir) [$KEYDIR]: " KEYDIR
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

mkdir -p $KEYDIR
cd $KEYDIR

echo
echo -e Creating ssh-keys:
echo -ne "\r[          ]"
echo -ne "\r[#         ]"
ssh-keygen -t rsa -b 2048 -f database_key -q -N ""
echo -ne "\r[##        ]"
ssh-keygen -t rsa -b 2048 -f tabby_key -q -N ""
echo -ne "\r[###       ]"
ssh-keygen -t rsa -b 2048 -f snmp_manager_key -q -N ""
echo -ne "\r[####      ]"
ssh-keygen -t rsa -b 2048 -f ssh_manager_key -q -N ""
echo -ne "\r[#####     ]"
ssh-keygen -t rsa -b 2048 -f uptime_monitor_key -q -N ""
echo -ne "\r[######    ]"
ssh-keygen -t rsa -b 2048 -f geo_session_finder_key -q -N ""
echo -ne "\r[#######   ]"
ssh-keygen -t rsa -b 2048 -f office365_analyzer_key -q -N ""
echo -ne "\r[########  ]"
ssh-keygen -t rsa -b 2048 -f api_key -q -N ""
echo -ne "\r[######### ]"
ssh-keygen -t rsa -b 2048 -f webinterface_key -q -N ""
echo -ne "\r[##########]"

echo -e "\nPlease send the generated public keys to ${Cyan}keys@Elbrus-Analytics.at${Color_Off}."