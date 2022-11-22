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
echo -e "\n"


mostrarAyuda(){
	echo -e  "$blanco usage: Instafinder [-n <NOMBRE>] [-a <1º APELLIDO>] [-x <2º APELLIDO>] [-c <CIUDAD>] [-p <PAIS>] [-y <AÑO>]

  -h, --help            shows this help and exists.
\n
  Todos los campos son  necesarios, también se puede ejecutar el script sin ningún parametro.\n"
	exit 0
}
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

	echo -e "\n\n$aqua	GENERANDO NOMBRES DE USUARIO POSIBLES \n"
	sleep 0.2
	alias_generator -n "$nombre" -s1 "$apellido" -s2 "$apellido2" -c "$ciudad" -C "$pais" -y "$year" -o $users  >/dev/null 2>/dev/null

}

genUsersParam(){
	while getopts n:a:x:c:p:y: flag
        do
            case "${flag}" in
                n) nombre=${OPTARG};;
                a) apellido=${OPTARG};;
                x) apellido2=${OPTARG};;
                c) ciudad=${OPTARG};;
                p) pais=${OPTARG};;
                y) year=${OPTARG};;
		*) mostrarAyuda;;
            esac
        done
        echo -e "\n\n$aqua      GENERANDO NOMBRES DE USUARIO POSIBLES \n"
        sleep 0.2
        alias_generator -n "$nombre" -s1 "${apellido}" -s2 "$apellido2" -c "$ciudad" -C "$pais" -y "$year" -o $users >/dev/null 2>/dev/null
	if ! [ -s $users ]
	then
		mostrarAyuda
	fi
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
	if ! [ -s validUsers ]
	then
		echo -e "$rojo Comprobar credenciales, o el estado de conexión con la api de instagram $fin"
		python3 ./Osintgram/main.py test -c exit >/dev/null 2>./errors.txt
		cat ./errors.txt | tail -1
		echo -e "\n"
		exit 1
	fi
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
	credFile="./config/credentials.ini"
	echo -e "\n$aqua      AHORA INSERTAREMOS NUESTRAS CREDENCIALES DE INSTAGRAM PARA LA BUSQUEDA"
	sleep 0.3
        echo -en "\n\n$amarillo [?] $blanco Nombre de usuario de instagram: $verde"
        read username
        echo -en "\n\n$amarillo [?] $blanco Contraseña de instagram: "
        read -s pass
                echo -e "\n\n$amarillo 	[+] $blanco Validando usuario \n"
                echo "[Credentials]
username = $username
password = $pass" > $credFile

}

case $1 in
	"") comprobaciones; genUsers ;;
	"-h" | "--help") mostrarAyuda ;;
	*) genUsersParam $@ ;;
esac

login
userFinder
