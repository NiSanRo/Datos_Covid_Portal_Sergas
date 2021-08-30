#!/bin/bash
# Script que verifica si se ha creado el fichero ZIP con los datos de 
# incidencia en los concellos.
# Si se ha creado no hace nada, en caso contrario crea el fichero ZIP
# en el que se incluyen todos los ficheros de incidencia del mes anterior
#

function devuelveCarpetaEjecucion()
{
        CARPETA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
        echo "Carpeta de la script: " ${CARPETA}
}


devuelveCarpetaEjecucion


MES_ANTERIOR=$(date --date="$(date +'%Y-%m-01') - 1 month" +"%Y%m")
FICH_ZIP="${CARPETA}/${MES_ANTERIOR}_IncidenciaConcello.zip"


# Se chequea si existe el fichero ZIP correspondiente

if test -f ${FICH_ZIP}; then
   echo "Ya esta creado el fichero agregado del mes anterior: ${FICH_ZIP}"
else 
   echo "Se crea el fichero agregdo del mes anterior: ${FICH_ZIP}"
   ls ${CARPETA}/${MES_ANTERIOR}*.csv | xargs zip -v  ${FICH_ZIP}
   # Se verifica que la integridad del fichero es correcta
   RESULTADO=$(zip -T  ${FICH_ZIP} | awk '{l=split($0,datos," "); print datos[l]}' )
   echo "Resultado de creacion del fichero ZIP: ${RESULTADO}"
fi
