#!/bin/bash


function devuelveCarpetaEjecucion()
{
	CARPETA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	echo "Carpeta de la script: " ${CARPETA}
}


devuelveCarpetaEjecucion

HOY=$(date -d @$(($(date "+%s")-1*86400)) "+"%Y%m%d"")
AYER=$(date -d @$(($(date "+%s")-2*86400)) "+%d-%m-%Y")


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
echo "Fichero datos:  ${CARPETA}/${HOY}_incidencia_concello.csv"
awk 'FNR==1 && NR!=1 { while (/^Fecha;/) getline; } 1 {print} ' ${CARPETA}/historico_incidencia_concello.csv ${CARPETA}/${HOY}_incidencia_concello.csv > ${CARPETA}/prov.csv
mv ${CARPETA}/prov.csv ${CARPETA}/historico_incidencia_concello.csv


# Para cargarse la primera línea del fichero:  tail -n+2


