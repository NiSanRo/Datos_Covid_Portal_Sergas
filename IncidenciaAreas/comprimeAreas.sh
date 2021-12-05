#!/bin/bash
# Script que verifica si se ha creado el fichero ZIP con los datos de 
# incidencia en las Areas
# Si se ha creado no hace nada, en caso contrario crea el fichero ZIP
# en el que se incluyen todos los ficheros de incidencia del mes anterior
#

function devuelveCarpetaEjecucion()
{
        CARPETA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
        echo "Carpeta de la script: " ${CARPETA}
}


devuelveCarpetaEjecucion

# Se verifican los meses anteriores para ver si existe fichero ZIP
meses=( $(ls /home/nisanro/Datos_Covid_Portal_Sergas/IncidenciaAreas/*.csv | awk '{l=split($0,datos,"/"); print substr(datos[l],1,7)}' | grep "202*" | grep -v $(date +"%Y-%m")|  sort -u) )
echo "Se va comprobar si existe ZIP para cada uno de los meses: ${meses[@]}"

for mes in "${meses[@]}"
do
  FICH_ZIP="${CARPETA}/${mes}_IncidenciaArea.zip"
  if test -f ${FICH_ZIP}; then
     echo "Ya esta creado el fichero agregado del mes ${mes}: ${FICH_ZIP}"
  else
     echo "Se crea el fichero agregdo del mes ${mes}: ${FICH_ZIP}"
     ls ${CARPETA}/${mes}*.csv | xargs zip -v  ${FICH_ZIP}
     # Se verifica que la integridad del fichero es correcta
     RESULTADO=$(zip -T  ${FICH_ZIP} | awk '{l=split($0,datos," "); print datos[l]}' )
     echo "Resultado de creacion del fichero ZIP: ${RESULTADO}"
  fi

done


# Se van a borrar los ficheros csv con mas de 45 dias de antiguedad
echo "Ficheros que se borran:"
find ${CARPETA} -type f -mtime +45 -daystart | grep ".csv" | sort -u | xargs -I % sh -c 'ls  -l %;rm %'


