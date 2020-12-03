# Datos_Covid_Portal_Sergas
Ficheros de datos recopilados desde el Portal COVID del Sergas.
Se proporcionan las scripts de descargas de los ficheros de datos y generación de CSVs consolidados para facilitar 
su explotación. 

URL portal COVID del Sergas: https://coronavirus.sergas.gal/datos/#/gl-ES/galicia


Descripción ficheros:
- SeguimientoIncidenciaConcello.xlsx 
  Contiene las pestañas:
  I14_Concello: tabla con el seguimiento de la IA14 en todos los concellos de Galicia durante los últimos 7 días.
  DatosConcello: hoja que tiene el histórico de todos los datos de incidencia por concello desde el 2/11/2020.
  Para actualizar los datos hay que descargar los ficheros CSVs desde este repositorio y dentro del excel 
  seleccionar: Datos > Actualizar Todos

- IncidenciaConcellos/aaaammdd_incidencia_concello.csv
  Fichero con los datos de incidencia a 14 días por concello para el día: dd/mm/aaaa
 
- IncidenciaConcellos/historico_incidencia_concello.csv
  Fichero con todos los datos de incidencia a 14 días por concello desde el 22/11/2020.
  Este fichero contiene los datos que alimentan la pestaña "DatosConcello" del fichero SeguimientoIncidenciaConcello.xlsx.
  
- IncidenciaConcellos/cargaIncidenciaConcello.sh
  Script bash de descarga de los datos de incidencia por concello desde el portal COVID del SERGAS.
  
 Para actualizar en local:
 1.- Descargar el fichero SeguimientoIncidenciaConcello.xlsx
 2.- Crear en la misma carpeta el subdirectorio: IncidenciaConcellos
 3.- Descargar el fichero ~/IncidenciaConcellos/historico_incidencia_concello.csv
 4.- Seleccionar Data > Refresh All en excel
