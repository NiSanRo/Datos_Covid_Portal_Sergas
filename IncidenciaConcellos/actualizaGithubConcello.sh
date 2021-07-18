#!/bin/bash


function devuelveCarpetaEjecucion()
{
	CARPETA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	echo "Carpeta de la script: " ${CARPETA}
}


devuelveCarpetaEjecucion

HOY=$(date +"%Y%m%d")
AYER=$(date -d @$(($(date "+%s")-86400)) "+%d-%m-%Y")
# Se obtiene la ultima fecha cargada
ULTIMA_FECHA=`tail -1 ${CARPETA}/historico_incidencia_concello.csv |awk '{l=split($0,datos,";"); print datos[1];}'`

 
# Subida automatica Github

cd ${CARPETA}


# Para evitar  subidas a Github comentar la siguiente linea


# GIT: Anhadir todos los nuevos ficheros en local
# a: anhadir
# *: todos
# q: salir
echo  -e "a\n*\nq\n" | git add -i

# Ahora se hace el commit
git commit -a -m "Nuevos ficheros datos incidencia ${AYER}" 

# Ahora se realiza el push al main de Github NiSanRo
git push origin main


