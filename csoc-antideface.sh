#!/bin/bash
#Codigo creado por Antonio Orozco R. correo: antoniojorz@hotmail.com
# Pausa prompt
function pause(){
	local message="$@"
	[ -z $message ] && message="Presione [Enter] para continuar..."
	read -p "$message" readEnterKey
}
#MENU
function show_menu(){
	#ASCII
	echo -e "\e[97m======================================================================================================="	
	echo " Script Desarrollado para la validacion de cambios de contenido web, desarrollador: Antonio Orozco R."
	echo "======================================================================================================="
	echo "		 ___ ___  ___   ___       ____ ____ | |_(_) __| | ___ / _| ____  ___ ___ "
	echo " 		/ __/ __|/ _ \ / __|____ / _  |  _ \| __| |/ _  |/ _ \ |_ / _  |/ __/ _ \ "
	echo "		 (__\__ \ (_) | (_|_____| (_| | | | | |_| | (_| |  __/  _| (_| | (_|  __/"
	echo "		\___|___/\___/ \___|     \____|_| |_|\__|_|\____|\___|_|  \____|\___\___|"
	echo "======================================================================================================="
	date
	echo -e "=======================================================================================================\e[0m"
	echo -e "\e[92m 1. Generar nuevas lineas base de las URLs"
	echo " 2. Generar linea base de una URL "
	echo " 3. Validar Cambios sobre las URLs"
	echo " 4. Monitorear Cambios de contenido en las URLs"
	echo " 5. Salir"
}
#añadir funcion de una urlr
#Lectura de entradas
# Purpose - Get input via the keyboard and make a decision using case..esac 
function read_input(){
	local c
	read -p "Seleciona una opcion [ 1 - 5 ] " c
	echo "=========================================================================================================="
	case $c in
		1)	BaseLines ;;
		2)	Gbase ;;
		3)	Logica ;;
		4)	monitoreo ;;
		5)	echo "Se ha cerrado con exito!"; exit 0 ;;
		*)	echo "Por favor seleccione una opcion unicamente del 1 -5 ."
			pause
	esac
}

#===============================================
#funcion Crear lineas bases
#===============================================      
function BaseLines(){
	while read -r url filename tail; do
	echo -e "\e[0m"	
	curl --connect-timeout 8 -o "baseline/$filename" "$url"
	done < urls.list
	echo "=========================================================================================================="
	echo "Lineas base descargadas exitosamente"
	echo "=========================================================================================================="
	pause
}
#===============================================
#funcion Crear linea base x url
#===============================================      
function Gbase(){
	preg="n"	
	# recojo los datos	
	echo -e "\e[0m digite la URL a crear linea base"
	read varul
	echo "digite el nombre a dar la linea base"
	read nameurl
	echo "Desea añadir esta URL al listado de URLs? s/n"
	read preg
	if [[ $preg = "s" ]]
	then
	  echo "$varul $nameurl.html" >> urls.list
	  echo "La url se ha añadido con exito"
		#ejecuto la descarga del contenido
		curl --connect-timeout 8 -o "baseline/$nameurl.html" "$varul"
		pause
	else
		#ejecuto la descarga del contenido
		curl --connect-timeout 8 -o "baseline/$nameurl.html" "$varul"
		echo "Descarga exitosa"
		pause
	fi
}
#===============================================
#funcion logica del programa
#===============================================      
function Logica(){                                                                       
	counter=1
	umbral=5
	while read -r url filename tail; do
	  echo -e "\e[0m"	
	  curl -s --connect-timeout 5 -o"./tmp/$filename" "$url"
	  wdiff -s "./tmp/$filename" "./baseline/$filename" > ./results/$filename
	  cat ./results/$filename | grep "% cambiada" > ./results/change.txt
	  change=$(head -n 1 ./results/change.txt)
	  spacesplitarr=( $change )
	  changepercent=${spacesplitarr[10]}
	  empt=""
	  result=${changepercent//%/$empt}
	  echo $result > ./results/$filename
	  rm ./results/change.txt
	  lineCount=$(cat ./urls.list | wc -l)
	  echo "($counter/$lineCount): $filename Terminado. Con $result % de Cambio."
	  if [ $result -gt $umbral ]
	  then
	    echo "Cambio detectado, por favor revisar la URL: $url ha superado el umbral de: $umbral %" 
	    #Enviar correo
	  fi
	  #--------------------------------------------------------------------------------------------
          #invoco funcion de hashes
	  #--------------------------------------------------------------------------------------------
	  hashm	  
	  #--------------------------------------------------------------------------------------------
	  counter=$((counter+1))
	done < urls.list
	pause
}
function hashm(){
#COMPRUEBO LOS HASH MD5
	  md5=`md5sum ./baseline/$filename | awk '{ print $1 }'`
	  md5_down=`md5sum ./tmp/$filename | awk '{ print $1 }'`
if [ $md5 != $md5_down ]
then
    echo "los hashes no coinciden"
    echo "======================================================================================================="
    echo "hash_base= $md5 | hash_nuevo=$md5_down"
    echo "======================================================================================================="
 fi
}
#===============================================
#funcion de monitoreo
#===============================================    
function monitoreo(){
	while true
	do
	counter=1
	umbral=5
	while read -r url filename tail; do
     	  echo -e "\e[0m"	
          curl -s --connect-timeout 5 -o"./tmp/$filename" "$url"
	  wdiff -s "./tmp/$filename" "./baseline/$filename" > ./results/$filename
	  cat ./results/$filename | grep "% cambiada" > ./results/change.txt
	  change=$(head -n 1 ./results/change.txt)
	  spacesplitarr=( $change )
	  changepercent=${spacesplitarr[10]}
	  empt=""
	  result=${changepercent//%/$empt}
	  echo $result > ./results/$filename
	  rm ./results/change.txt
	  lineCount=$(cat ./urls.list | wc -l)
	  echo "($counter/$lineCount): $filename Terminado. Con $result % de Cambio."
	  if [ $result -gt $umbral ]
	  then
	    varmail=$(echo "Cambio detectado, por favor revisar la URL: $url ha superado el umbral de: $umbral %" )
	    #Enviar correo
	    correo
	  fi
	  #--------------------------------------------------------------------------------------------
          #invoco funcion de hashes
	  #--------------------------------------------------------------------------------------------
	  hashm	  
	  #--------------------------------------------------------------------------------------------
	  counter=$((counter+1))
	done < urls.list
	sleep 20
	done	
	
}
#================================================
#Envio de correos
function correo(){
	email=antonio.orozcor.ext@claro.com
	cat $varmail|mail -s "Alerta de cambio de contenido web" $email

}
#===============================================   
# ignore CTRL+C, CTRL+Z and quit singles using the trap
#trap '' SIGINT SIGQUIT SIGTSTP

# Main
while true
do
	clear
 	show_menu	# display memu
 	read_input  # wait for user input
done


