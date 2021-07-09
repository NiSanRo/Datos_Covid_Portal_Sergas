#!/bin/bash


function devuelveCarpetaEjecucion()
{
	CARPETA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	echo "Carpeta de la script: " ${CARPETA}
}


devuelveCarpetaEjecucion

HOY='20210707'
AYER='06-07-2021'
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


# Para cargarse la última línea del fichero: sed \$d


# Para los nuevos casos "entre 1 y 9" se pone 5
cat ${CARPETA}/${HOY}_incidencia_concello_bak.csv | sed 's/Sen novos casos diagnosticados no concello/0/g' | sed 's/Número de novos casos diagnosticados no concello: entre 1 e 9/5/g'> ${CARPETA}/${HOY}_incidencia_concello_tmp.csv

# Ponemos la fecha a todas las lineas excepto la cabecera, ademas eliminamos la ultima linea
# estan cambiando continuamente el formato de los datos, bailando una columna COR
# en caso de que apararezca como segunda columna, hay que pasar de ella
COR=$(head -1  ${CARPETA}/${HOY}_incidencia_concello_tmp.csv | awk '{l=split($0,datos,";"); print datos[2];}')
head -n -1 ${CARPETA}/${HOY}_incidencia_concello_tmp.csv | awk -v fecha=${AYER} -v formato=${COR} '{
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


#
# Se añade el fichero al acumulado
#

# Para cargarse la primera línea del fichero:  tail -n+2


# Se concatena el nuevo fichero en el historico

awk 'FNR==1 && NR!=1 { while (/^Fecha;/) getline; } 1 {print} ' ${CARPETA}/historico_incidencia_concello.csv ${CARPETA}/${HOY}_incidencia_concello.csv > ${CARPETA}/prov.csv
mv ${CARPETA}/prov.csv ${CARPETA}/historico_incidencia_concello.csv



 
exit 
 
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


# Finalmente descargamos los datos de COVID-BENS

/mnt/c/PERSONALES/Coronavirus/sources/COVID-BENS/cargaIncidenciaBens.sh