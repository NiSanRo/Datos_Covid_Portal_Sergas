#!/bin/bash


function devuelveCarpetaEjecucion()
{
	CARPETA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	echo "Carpeta de la script: " ${CARPETA}
}


devuelveCarpetaEjecucion

HOY=$(date +"%Y%m%d")
AYER=$(date -d @$(($(date "+%s")-86400)) "+%d-%m-%Y")
#AYER_DEC se utiliza para descargar los datos de la URL https://coronavirus.sergas.gal/infodatos/
AYER_DEC=$(date -d @$(($(date "+%s")-86400)) "+%Y-%m-%d")
# Se obtiene la ultima fecha cargada
ULTIMA_FECHA=`tail -1 ${CARPETA}/historico_CifrasTotales.csv |awk '{l=split($0,datos,";"); print datos[1];}'`

# Se comprueba la diferencia entre fechas. Si es 0 no se realiza carga
# Hay que tener en cuenta que date no admite el formato %d-%m-%Y por lo que aplicamos
# un comando sed para invertir las cadenas y que tengan formato %Y-%m-%d que si se admite
# Ejemplo:  date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<<"27-11-2020")
# Check: echo ` date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${ULTIMA_FECHA}) `
# Un dia son 86400 segundos, pero con el cambio de hora se convierten en 82800
DIAS=$(( (`date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${AYER}) +"%s"`-`date -d date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${ULTIMA_FECHA}) "+%s"`)/82800 ))

HOY="20210918"
AYER="20210917"
DIAS="1"
AYER_DEC="2021-09-17"

echo "Descarga de incidencias acumuladas por Concello para el dia: ${AYER}"
echo "Ultima fecha cargada: ${ULTIMA_FECHA}"
echo "Diferencia de dias: " ${DIAS} 

# Vamos descargar el fichero de configuracion
#wget -O ${CARPETA}/sergasConfig.html https://coronavirus.sergas.es/datos/libs/hot-config/hot-config.txt

wget -O ${CARPETA}/hot-config.txt https://coronavirus.sergas.es/datos/libs/hot-config/hot-config.txt --no-check-certificate
 
# Dato diario de: pacientes con infeccion activa, hospitalizados hoxe, coidados intensivos hoxe, curados, falecidos, contaxiados, confirmados PCR 24 horas, pruebas PCR, prueba serologica
# Es un fichero incremental, se concatena al historico
SUFIJO=$(cat ${CARPETA}/hot-config.txt  |grep CifrasTotais | grep URL | awk '{l=split($0,datos,"}");print datos[2];}' | sed 's/",//g')
echo "Se cargan datos de: https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO}"

# wget -O ${CARPETA}/${AYER_DEC}_CifrasTotales.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}_COVID19_Web_CifrasTotais.csv
wget -O ${CARPETA}/${AYER_DEC}_CifrasTotales.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO} --no-check-certificate
{ head -1 ${CARPETA}/historico_CifrasTotales.csv; { tail -n+2  ${CARPETA}/historico_CifrasTotales.csv; tail -n+2 ${CARPETA}/${AYER_DEC}_CifrasTotales.csv; } | sort -u;} > ${CARPETA}/prov.csv
mv ${CARPETA}/prov.csv ${CARPETA}/historico_CifrasTotales.csv


# Dato acumulado de infectados por fecha y area sanitaria
# Al tratarse de un fichero acumulado, el último descargado introduce cambios en cualquier fecha anterior
SUFIJO=$(cat ${CARPETA}/hot-config.txt  |grep InfectadosPorFecha | grep URL | awk '{l=split($0,datos,"}");print datos[2];}' | sed 's/",//g')
echo "Se cargan datos de: https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO}"
wget -O ${CARPETA}/${AYER_DEC}_InfectadosArea.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO} --no-check-certificate
cp ${CARPETA}/${AYER_DEC}_InfectadosArea.csv ${CARPETA}/historico_InfectadosArea.csv 

# Dato acumulado de positividades por fecha y area sanitaria
# Al tratarse de un fichero acumulado, el último descargado introduce cambios en cualquier fecha anterior
SUFIJO=$(cat ${CARPETA}/hot-config.txt  |grep PorcentajeInfecciones | grep URL | awk '{l=split($0,datos,"}");print datos[2];}' | sed 's/",//g')
echo "Se cargan datos de: https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO}"
wget -O ${CARPETA}/${AYER_DEC}_PositividadArea.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO} --no-check-certificate
cp ${CARPETA}/${AYER_DEC}_PositividadArea.csv ${CARPETA}/historico_positividadArea.csv 

# Dato diario de situación de hospitales
# Es un fichero incremental, se concatena al historico
SUFIJO=$(cat ${CARPETA}/hot-config.txt  |grep OcupacionCamas | grep URL | awk '{l=split($0,datos,"}");print datos[2];}' | sed 's/",//g')
echo "Se cargan datos de: https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO}"
wget -O ${CARPETA}/${AYER_DEC}_SituacionHospitales.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}${SUFIJO} --no-check-certificate
{ head -1 ${CARPETA}/historico_SituacionHospitales.csv; { tail -n+2  ${CARPETA}/historico_SituacionHospitales.csv; tail -n+2 ${CARPETA}/${AYER_DEC}_SituacionHospitales.csv; } | sort -u;} > ${CARPETA}/prov.csv
mv ${CARPETA}/prov.csv ${CARPETA}/historico_SituacionHospitales.csv

# La URL de descarga de las cifras totales tiene un formato del estilo de: 
# https://coronavirus.sergas.gal/infodatos/2021-01-06_COVID19_Web_CifrasTotais.csv

 
# Se borra el fichero temporal
rm ${CARPETA}/prov.csv


 
# Subida automatica Github

cd ${CARPETA}

# GIT: Anhadir todos los nuevos ficheros en local
# a: anhadir
# *: todos
# q: salir
echo  -e "a\n*\nq\n" | git add -i

# Ahora se hace el commit
git commit -a -m "Nuevos ficheros datos totales ${AYER}" 

# Ahora se realiza el push al main de Github NiSanRo
git push origin main
