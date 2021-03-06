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
DIAS=$(( (`date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${AYER}) +"%s"`-`date -d date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${ULTIMA_FECHA}) "+%s"`)/86400 ))

echo "Descarga de incidencias acumuladas por Concello para el dia: ${AYER}"
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
wget -O ${CARPETA}/sergasConfig.html https://coronavirus.sergas.es/datos/libs/hot-config/hot-config.txt


# 2.- Filtramos la linea con CASE_MAP para obtener el Id del Mapa

IDENTIFICADOR=`cat ${CARPETA}/sergasConfig.html | grep CASES_MAP | awk '{l=split($0,datos,"\""); print datos[4];}'`
echo "Identificador del fichero datos/redireccion: ${IDENTIFICADOR}"


#
# Ahora la descarga de datos puede ser inmediata con el fichero 
# https://datawrapper.dwcdn.net/jKpTc/1/
# o bien este contiene una redireccion para el fichero que realmente hay que descargar.


# 3.- Se descarga el fichero de datos/redireccion

 wget -O ${CARPETA}/${HOY}_mapa-covid.html https://datawrapper.dwcdn.net/${IDENTIFICADOR}/1/


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


while [ -n "${nuevoFichero}" ]
do 
	echo "Redireccion..."
	echo "Se descarga el fichero de datos: ${nuevoFichero}"
	wget -O ${CARPETA}/${HOY}_mapa-covid.html ${nuevoFichero}
	nuevoFichero=`cat  ${CARPETA}/${HOY}_mapa-covid.html | grep REFRESH |  awk '{l=split($0,datos,"\"");l=split(datos[4],url,"=");print url[2];}'`
	echo ${nuevoFichero}
done 

# 
# Ahora estamos seguros de tener el fichero ${HOY}_mapa-covid.html los datos de incidencia acumulada por Concello
# 
# \"MapAttribution\"}]}]},\"chartData\":\"ID,NOME,CASOS,NIVEL,COR\\r\\n\\\"34121515001\\\",\\\"ABEGONDO\\\",\\\"N\u00FAmero de novos casos diagnosticados no concello: 11.\\\",\\\"Incidencia acumulada para o concello: >150 e \u2264250.\\\",\\\"0\\\"\\r\\n\\\"34121515002\\\",\\\"AMES\\\",\\\"N\u00FAmero de novos casos diagnosticados no concello: 33.\\\",\\\"Incidencia acumulada para o concello: >50 e \u2264150.\\\",\\\"0\\\"\\r\\n\\\"34121515003\\\",\\\"ARANGA\\\",\\\"N\u00FAmero de novos casos diagnosticados no concello: entre 1 e 9.\\\",\\\"Incidencia acumulada para o concello: >250.\\\",\\\"0\\\"\\r\\n\\\"34121515004\\\",\\\"ARES\\\",\\\"N\u00FAmero de novos casos diagnosticados no concello: 15.\\\",\\\"Incidencia acumulada para o concello: >250.\\\"
# 
# Los datos de los concellos empiezan despues de la cadena "chartData" y tienen el formato
# "ID,NOMBRE CONCELLO, CASOS, IA
# "34121515001\\\",\\\"ABEGONDO\\\",\\\"N\u00FAmero de novos casos diagnosticados no concello: 11.\\\",\\\"Incidencia acumulada para o concello: >150 e \u2264250.\\\",\\\"0\\\"\\r\\n\\\
#

# Para cargarse la última línea del fichero: sed \$d


#  El día 02/03 empiezan a publicar datos de IA7 
#cat ${CARPETA}/${HOY}_mapa-covid.html | grep chartData | sed 's/.*chartData//' | sed 's/isPreview.*//' | sed 's/\\\\r\\\\n/\n/g' | sed 's/\\\\\\\"//g' | sed 's/\\":\\"//g' | sed 's/\\u2264/<=/g' | sed 's/\\\u00D1/Ñ/g' | sed 's/\\u00FA/ú/g' | sed 's/\.//g' |awk -v fecha=${AYER} '{gsub("Sen novos casos diagnosticados no concello"," :0",$0); l=split($0,datos,",");l=split(datos[3],novos,":"); if (l>=2) { print fecha";"datos[1]";"datos[2]";"novos[2]";"datos[4]} else { print "Fecha;"datos[1]";"datos[2]";"datos[3]";"datos[4]}}' | sed \$d  > ${CARPETA}/${HOY}_incidencia_concello.csv

#  El día 02/03 empiezan a publicar datos de IA7 
# Para los nuevos casos "entre 1 y 9" se pone 5
cat ${CARPETA}/${HOY}_mapa-covid.html | grep chartData | sed 's/.*chartData//' | sed 's/isPreview.*//' | sed 's/\\\\r\\\\n/\n/g' | sed 's/\\\\\\\"//g' | sed 's/\\":\\"//g' |
sed 's/\\u2264/<=/g' | sed 's/\\\u00D1/Ñ/g' | sed 's/\\u00FA/ú/g' | sed 's/\.//g' | sed 's/\\\\n/\n/g' | sed 's/\\",\\"//g' | sed 's/,/;/g' | 
sed 's/Sen novos casos diagnosticados no concello/0/g' | sed 's/Número de novos casos diagnosticados no concello: entre 1 e 9/5/g'> ${CARPETA}/${HOY}_incidencia_concello_tmp.csv

# Ponemos la fecha a todas las lineas excepto la cabecera, ademas eliminamos la ultima linea
head -n -1 ${CARPETA}/${HOY}_incidencia_concello_tmp.csv | awk -v fecha=${AYER} '{
    l=split($0,datos,";"); 
    if (datos[1]=="ID") { 
            print "Fecha;"datos[1]";"datos[2]";"datos[3]";"datos[4]";"datos[5]";"datos[6];
        } 
        else { 
            print fecha";"datos[1]";"datos[2]";"datos[3]";"datos[4]";"datos[5]";"datos[6];
        }
    }' > ${CARPETA}/${HOY}_incidencia_concello.csv

rm ${CARPETA}/${HOY}_incidencia_concello_tmp.csv 


#
# Se añade el fichero al acumulado
#

# Para cargarse la primera línea del fichero:  tail -n+2


# Se concatena el nuevo fichero en el historico


awk 'FNR==1 && NR!=1 { while (/^Fecha;/) getline; } 1 {print} ' ${CARPETA}/historico_incidencia_concello.csv ${CARPETA}/${HOY}_incidencia_concello.csv > ${CARPETA}/prov.csv
mv ${CARPETA}/prov.csv ${CARPETA}/historico_incidencia_concello.csv


# Se borran los ficheros html del mapa
# rm ${CARPETA}/${HOY}_mapa-covid.html
 
 
 
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
