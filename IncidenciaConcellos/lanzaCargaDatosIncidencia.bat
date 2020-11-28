@ECHO off
REM Para poder ejecutar esta script es necesario tener instalado el Linux Bash Shell en Windows 10
echo Carpeta de ejecucion: %CD%
REM Se ejecuta la script linux de descarga de los datos de incidencia por Concello que proporciona el Sergas desde el 21/11/2020
REM El path de la script debe ser pasado en formato linux
bash - "/mnt/c/PERSONALES/Coronavirus/sources/Sergas/Datos_Covid_Portal_Sergas/IncidenciaConcellos/cargaIncidenciaConcello.sh"

pause