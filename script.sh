#!/bin/bash
aqua="\033[1;36m"
amarillo="\033[1;93m"
magenta="\033[1;35m"
rojo="\033[1;31m"
rojob="\033[0;31m"
blanco="\033[1;97m"
verde="\033[1;32m"
fin="\e[0m"
users=".output.txt"
let col=$(tput cols)-7
echo $COLUMNS

echo -e "$verde\n"
figlet INSTAFINDER

echo -e "${blanco}Programa automatizado para la busqueda de nombres de usuario en Instagram \nGracias a ${magenta}OSRFramework ${blanco}y ${magenta}Osintgram"
echo -e "${rojob}'Comprobar credenciales de Instagram si no funciona a la primera' $blanco \n"
printf '%s%*s%s' "$(tput setaf 1)" 63 "==> C0C05_ <==" "$NORMAL"



genUsers(){
	echo -en "\n\n$amarillo [?] $blanco Inserte el nombre: $magenta "
	read nombre
	echo -en "\n\n$amarillo [?] $blanco Inserte el primer apellido: $magenta"
	read apellido
	echo -en "\n\n$amarillo [?] $blanco Inserte el segundo apellido: $magenta"
	read apellido2
	echo -en "\n\n$amarillo [?] $blanco Inserte año de nacimiento: $magenta"
	read year
	echo -en "\n\n$amarillo [?] $blanco Inserte Ciudad: $magenta"
	read ciudad
	echo -en "\n\n$amarillo [?] $blanco Inserte pais: $magenta"
	read pais

	echo -e "\n\n$aqua 	GENERANDO NOMBRES DE USUARIO POSIBLES \n"
	sleep 0.2
	alias_generator -n "$nombre" -s1 "$apellido" -s2 "$apellido2" -c "$ciudad" -C "$pais" -y "$year" -o $users  >/dev/null 2>/dev/null

}

userFinder(){
	echo -en "\n\n\n$amarillo [+] $blanco Comprobando nombres de usuarios validos \n\n"
	sleep 0.2
	while read user
	do
  		echo -ne "\r$rojob procesando $blanco"
		python3 ./Osintgram/main.py $user -c exit >/dev/null 2>/dev/null && echo "$user" >> ./validUsers &
	done < "$users"
	wait;
	echo -e "\n\n$aqua      MOSTRANDO USUARIOS DISPONIBLES EN INSTAGRAM. ${rojo}ARCHIVO DE SALIDA ==> ${blanco}./validUsers \n"
	sleep 2
	cat validUsers | pr -3 -S"   " -T
	echo -e "\n${rojo}chaoo ;)\n"
	exit 0
}

comprobaciones(){

	credFolder="./Osintgram/config/"
	credFile="./config/credentials.ini"

	if [ ! -f ./validUsers ]
	then
        	touch ./validUsers
	else
        	echo "" > ./validUsers
	fi

	which python3 >/dev/null
	esta_python=$?
	if [ ! $esta_python ]
	then
        	apt install python3 >/dev/null 2>/dev/null
	fi


	which pip3 >/dev/null
	esta_pip3=$?
	if [ $esta_pip3 -eq 1 ]
	then
	        apt install -y python3-pip >/dev/null 2>/dev/null
	fi

	which alias_generator > /dev/null
	if [ ! $? ]
	then
        	pip3 install osrframework
	fi
	if [ ! -d ./Osintgram ]
	then
        	git clone https://github.com/Datalux/Osintgram.git >/dev/null 2>/dev/null
	        pip3 install -r ./Osintgram/requirements.txt >/dev/null 2>/dev/null
	fi


	if [ ! -d ./config ]
	then
	        cp -r Osintgram/config ./
	fi

}

login(){
	echo -e "\n$aqua	AHORA INSERTAREMOS NUESTRAS CREDENCIALES DE INSTAGRAM PARA LA BUSQUEDA"
	sleep 0.3
        echo -en "\n\n$amarillo [?] $blanco Nombre de usuario de instagram: $verde"
        read username
        echo -en "\n\n$amarillo [?] $blanco Contraseña de instagram: "
        read -s pass
	grep -q "username = $username" $credFile
        validUser=$?
        grep -q "password = $pass" $credFile
        validPass=$?

        if [[ $validUser -eq 1 || $validPass -eq 1 ]]
        then
                echo -e "\n\n$amarillo 	[+] $blanco Validando usuario \n"
                echo "[Credentials]
username = $username
password = $pass" > $credFile

        fi
}

comprobaciones
genUsers
login
userFinder
