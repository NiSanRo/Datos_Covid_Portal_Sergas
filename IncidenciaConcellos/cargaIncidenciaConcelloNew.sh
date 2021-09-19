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

# Se comprueba la diferencia entre fechas. Si es 0 no se realiza carga
# Hay que tener en cuenta que date no admite el formato %d-%m-%Y por lo que aplicamos
# un comando sed para invertir las cadenas y que tengan formato %Y-%m-%d que si se admite
# Ejemplo:  date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<<"27-11-2020")
# Check: echo ` date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${ULTIMA_FECHA}) `
# Un dia son 86400 segundos, pero con el cambio de hora se convierten en 82800
DIAS=$(( (`date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${AYER}) +"%s"`-`date -d date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${ULTIMA_FECHA}) "+%s"`)/82800 ))
#ARRIBA=$(date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< "${AYER}") +"%s")
#ABAJO=$(date -d date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${ULTIMA_FECHA}) "+%s")
#DIAS=$(( (ARRIBA-ABAJO)/82800 ))   #Un dia son 86400 segundos, pero con el cambio de hora se convierten en 82800

#HOY="20210918"
#AYER="20210917"
#DIAS="1"

echo "Descarga de incidencias acumuladas por Concello para el dia: ${AYER}"
echo "HOY: ${HOY}"
echo "AYER: ${AYER}"
echo "Ultima fecha cargada: ${ULTIMA_FECHA}"
echo "Diferencia de dias: " ${DIAS} 


# Si el ultimo dia cargado corresponde con el de ayer, no se realiza la carga
if [ ${DIAS} -eq 0 ]
then
	echo "Ya estan cargados los datos mas actualizados"
	exit
fi



# La URL para descargar el mapa tiene formato:
# https://datawrapper.dwcdn.net/jKpTc/1/
# Siendo jKpTc un identificador que es necesario obtener de:
# https://coronavirus.sergas.es/datos/libs/hot-config/hot-config.txt
# En concreto filtrando la seccion:
#    "MAPS_DATAWRAPPER": {
#     "URL": "https://datawrapper.dwcdn.net/{ID}/?cache={TIMESTAMP}",
#     "CASES_MAP": "jKpTc"
#   }

# 1.- Descargar el fichero de configuracion del Sergas
wget -O ${CARPETA}/sergasConfig.html https://coronavirus.sergas.es/datos/libs/hot-config/hot-config.txt --no-check-certificate


# 2.- Filtramos la linea con CASE_MAP para obtener el Id del Mapa

IDENTIFICADOR=`cat ${CARPETA}/sergasConfig.html | grep CASES_MAP | awk '{l=split($0,datos,"\""); print datos[4];}'`
echo "Identificador del fichero datos/redireccion: ${IDENTIFICADOR}"

#
# Ahora la descarga de datos puede ser inmediata con el fichero 
# https://datawrapper.dwcdn.net/jKpTc/1/
# o bien este contiene una redireccion para el fichero que realmente hay que descargar.


# 3.- Se descarga el fichero de datos/redireccion

 wget -O ${CARPETA}/${HOY}_mapa-covid.html https://datawrapper.dwcdn.net/${IDENTIFICADOR}/1/   --no-check-certificate


# En el caso de contener una redireccion o otra pagina y no los datos directos, el fichero
# contendra una linea del estilo de:
# <html><head><meta http-equiv="REFRESH" content="0; url=https://datawrapper.dwcdn.net/jKpTc/5/"></head></html>

# 4.- Se da por supuesto que es un REFRESH, y se tiene que descargar otro fichero
#     se intenta coger el nombre de ese fichero y si la cadena tiene longitud 0 es que  
#     no se trata de la redireccion esperada

nuevoFichero=`cat  ${CARPETA}/${HOY}_mapa-covid.html | grep REFRESH |  awk '{l=split($0,datos,"\"");l=split(datos[4],url,"=");print url[2];}'`

# 20/12/2020: Se detectan dos redirecciones en los ficheros html
# Cuando la cadena sea nula (no hay REFRESH) se para la ejecucion del bucle
#  -z: la cadena es nula
#  -n: la cadena es no nula

#if [ -z "${nuevoFichero}" ]; then
#    echo "No hay redireccion"
#else
#	echo "Se descarga el fichero de datos: ${nuevoFichero}"
#	wget -O ${CARPETA}/${HOY}_mapa-covid.html ${nuevoFichero}
#fi

NUMERO=$(echo ${nuevoFichero} | awk '{n=split($0,datos,"/");print datos[n-1];}')


while [ -n "${nuevoFichero}" ]
do 
	NUMERO=$(echo ${nuevoFichero} | awk '{n=split($0,datos,"/");print datos[n-1];}')
	echo "ID CARPETA REDIRECCION: ${IDENTIFICADOR}/${NUMERO}/"
	echo "Se descarga el fichero de datos: ${nuevoFichero}"
	wget -O ${CARPETA}/${HOY}_mapa-covid.html ${nuevoFichero}  --no-check-certificate
	nuevoFichero=`cat  ${CARPETA}/${HOY}_mapa-covid.html | grep REFRESH |  awk '{l=split($0,datos,"\"");l=split(datos[4],url,"=");print url[2];}'`
done 

datasetFich="https://datawrapper.dwcdn.net/${IDENTIFICADOR}/${NUMERO}/dataset.csv"

echo ""
echo ""
echo "FICHERO DE DATOS: ${datasetFich}"
echo ""
echo ""

wget -O ${CARPETA}/${HOY}_incidencia_concello_tmp.csv ${datasetFich} --no-check-certificate
# Se normaliza el separador de columnas
sed -i 's/,/;/g' ${CARPETA}/${HOY}_incidencia_concello_tmp.csv
sed -i 's/"//g' ${CARPETA}/${HOY}_incidencia_concello_tmp.csv
sed -i 's/\.;/;/g' ${CARPETA}/${HOY}_incidencia_concello_tmp.csv
sed -i 's/Sen novos casos diagnosticados no concello/0/g' ${CARPETA}/${HOY}_incidencia_concello_tmp.csv
sed -i 's/Número de novos casos diagnosticados no concello: entre 1 e 9/5/g' ${CARPETA}/${HOY}_incidencia_concello_tmp.csv



# Ponemos la fecha a todas las lineas excepto la cabecera, ademas eliminamos la ultima linea
# estan cambiando continuamente el formato de los datos, bailando una columna COR
# en caso de que apararezca como segunda columna, hay que pasar de ella
COR=$(head -1  ${CARPETA}/${HOY}_incidencia_concello_tmp.csv | awk '{l=split($0,datos,";"); print datos[2];}')
#head -n -1 ${CARPETA}/${HOY}_incidencia_concello_tmp.csv | awk -v fecha=${AYER} -v formato=${COR} '{
# Para cargarse la primera línea del fichero:  tail -n+2

tail -n+2 ${CARPETA}/${HOY}_incidencia_concello_tmp.csv | awk -v fecha=${AYER} -v formato=${COR} '{
    l=split($0,datos,";"); 
    if (datos[1]=="ID") {
			if (formato=="COR"){ 
            	print "Fecha;"datos[1]";"datos[3]";"datos[4]";"datos[5]";"datos[6]";"datos[7];
			}
			else {
				print "Fecha;"datos[1]";"datos[2]";"datos[3]";"datos[4]";"datos[5]";"datos[6];
			}
        } 
        else { 
			if (formato=="COR") {
            	print fecha";"datos[1]";"datos[3]";"datos[4]";"datos[5]";"datos[6]";"datos[7];
			} 
			else {
				print fecha";"datos[1]";"datos[2]";"datos[3]";"datos[4]";"datos[5]";"datos[6];
			}
        }
    }' > ${CARPETA}/${HOY}_incidencia_concello.csv

rm ${CARPETA}/${HOY}_incidencia_concello_tmp.csv 



# Se añade el fichero al acumulado
#



# Se concatena el nuevo fichero en el historico

awk 'FNR==1 && NR!=1 { while (/^Fecha;/) getline; } 1 {print} ' ${CARPETA}/historico_incidencia_concello.csv ${CARPETA}/${HOY}_incidencia_concello.csv > ${CARPETA}/prov.csv


mv ${CARPETA}/prov.csv ${CARPETA}/historico_incidencia_concello.csv



# Se borran los ficheros html del mapa
rm ${CARPETA}/${HOY}_mapa-covid.html
 
 
 
# Subida automatica Github

cd ${CARPETA}



# Para evitar  subidas a Github comentar la siguiente linea


# GIT: Anhadir todos los nuevos ficheros en local
# a: anhadir
# *: todos
# q: salir
#echo  -e "a\n*\nq\n" | git add -i

# Ahora se hace el commit
#git commit -a -m "Nuevos ficheros datos incidencia ${AYER}" 

# Ahora se realiza el push al main de Github NiSanRo
#git push origin main


# Finalmente descargamos los datos de COVID-BENS

#/mnt/c/PERSONALES/Coronavirus/sources/COVID-BENS/cargaIncidenciaBens.sh

# Para chequear la carga
 tail  -10  ${CARPETA}/historico_incidencia_concello.csv 
