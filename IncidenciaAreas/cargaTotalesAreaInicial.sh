#!/bin/bash


function devuelveCarpetaEjecucion()
{
	CARPETA="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
	echo "Carpeta de la script: " ${CARPETA}
}


devuelveCarpetaEjecucion

INI=$(date -d '20201007' +'%Y%m%d')
HOY=$(date +"%Y%m%d")
AYER=$(date -d @$(($(date "+%s")-86400)) "+%d-%m-%Y")
DIAS=$(( (`date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${AYER}) +"%s"`-`date -d date -d $(sed -E "s/(..)-(..)-(....)/\3\2\1/g" <<< ${INI}) "+%s"`)/86400 ))

echo "Fecha inicio: ${INI}"
echo "Hoy: ${HOY}"
echo "Dias: ${DIAS}" 

echo "Se van a cargar los ficheros desde el ${INI}"

for (( i = 0; i <= $DIAS; i++ )) 
do 
	AYER_DEC=$(date -d @$(($(date -d "20201007" "+%s")+$i*86400)) "+%Y-%m-%d") 
    echo "Cargando datos de dia: ${AYER_DEC}" 

	# Dato diario de: pacientes con infeccion activa, hospitalizados hoxe, coidados intensivos hoxe, curados, falecidos, contaxiados, confirmados PCR 24 horas, pruebas PCR, prueba serologica
	# Es un fichero incremental, se concatena al historico	
	wget -O ${CARPETA}/${AYER_DEC}_CifrasTotales.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}_COVID19_Web_CifrasTotais.csv
	{ head -1 ${CARPETA}/historico_CifrasTotales.csv; { tail -n+2  ${CARPETA}/historico_CifrasTotales.csv; tail -n+2 ${CARPETA}/${AYER_DEC}_CifrasTotales.csv; } | sort -u;} > ${CARPETA}/prov.csv
	mv ${CARPETA}/prov.csv ${CARPETA}/historico_CifrasTotales.csv

	# Dato acumulado de infectados por fecha y area sanitaria
	# Al tratarse de un fichero acumulado, el último descargado introduce cambios en cualquier fecha anterior
	wget -O ${CARPETA}/${AYER_DEC}_InfectadosArea.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}_COVID19_Web_InfectadosPorFecha.csv
	cp ${CARPETA}/${AYER_DEC}_InfectadosArea.csv ${CARPETA}/historico_InfectadosArea.csv 

	# Dato acumulado de positividades por fecha y area sanitaria
	# Al tratarse de un fichero acumulado, el último descargado introduce cambios en cualquier fecha anterior
	wget -O ${CARPETA}/${AYER_DEC}_PositividadArea.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}_COVID19_Web_PorcentajeInfeccionesPorFecha.csv
	cp ${CARPETA}/${AYER_DEC}_PositividadArea.csv ${CARPETA}/historico_positividadArea.csv 

	# Dato diario de situación de hospitales
	# Es un fichero incremental, se concatena al historico
	wget -O ${CARPETA}/${AYER_DEC}_SituacionHospitales.csv https://coronavirus.sergas.gal/infodatos/${AYER_DEC}_COVID19_Web_OcupacionCamasHospital.csv
	{ head -1 ${CARPETA}/historico_SituacionHospitales.csv; { tail -n+2  ${CARPETA}/historico_SituacionHospitales.csv; tail -n+2 ${CARPETA}/${AYER_DEC}_SituacionHospitales.csv; } | sort -u;} > ${CARPETA}/prov.csv
	mv ${CARPETA}/prov.csv ${CARPETA}/historico_SituacionHospitales.csv
done


	
