# Datos_Covid_Portal_Sergas
Ficheros de datos recopilados desde el Portal COVID del Sergas.
Se proporcionan las scripts de descargas de los ficheros de datos y generación de CSVs consolidados para facilitar 
su explotación. 

URL portal COVID del Sergas: https://coronavirus.sergas.gal/datos/#/gl-ES/galicia


Descripción ficheros:
- SeguimientoIncidenciaArea.xlsm
  Datos agregados por las 7 áreas sanitarias de Galicia para los 90 últimos días.
  En la pestaña "Totales" se muestran gráficas y está el botón que permite refrescar los datos del fichero desde este Github.
  Las pestañas "GrafXXXX" contienen gráficas pivotadas que pueden ser modificadas.
  Las pestañas "SeguimientoXXX" contienen las tablas de datos.
  
- SeguimientoIncidenciaConcello.xlsm 
  Contiene las pestañas:
  Gráficas: se muestran las gráficas de IA14 e IA14 x 100K habitantes para las 7 principales ciudades de Galicia.
  IA14_Ultimos15dias: tabla con el seguimiento de la IA14 en todos los concellos de Galicia durante los últimos 15 días.
  IA_14_100K: tabla con el seguimiento de la IA14 x 100K habitantes para las 7 principales ciudades de Galicia.
  DatosConcello: hoja que tiene el histórico de todos los datos de incidencia por concello desde el 2/11/2020.
 
- IncidenciaConcellos/aaaammdd_incidencia_concello.csv
  Fichero con los datos de incidencia a 14 días por concello para el día: dd/mm/aaaa
 
- IncidenciaConcellos/historico_incidencia_concello.csv
  Fichero con todos los datos de incidencia a 14 días por concello desde el 22/11/2020.
  Este fichero contiene los datos que alimentan la pestaña "DatosConcello" del fichero SeguimientoIncidenciaConcello.xlsx.
  
- IncidenciaConcellos/cargaIncidenciaConcello.sh
  Script bash de descarga de los datos de incidencia por concello desde el portal COVID del SERGAS.
  
- IncidenciaAreas/historico_CifrasTotales.csv
  Ficheros con los datos diarios publicados por el Sergas relativos a:
  1 - Casos totales
  2 - Casos confirmados por PCR en las últimas 24 horas
  3 - Pacientes activos
  4 - Pacientes dados de alta
  5 - Camas ocupadas en hospitales
  6 - Camas oucpadas en UCI
  7 - PCRs realizadas
  8 - Otras pruebas realizadas
  9 - Fallecidos
  Este fichero alimenta las gráficas mostradas en SeguimientoIncidenciaArea.xlsm
  
- IncidenciaAreas/historico_InfectadosArea.csv
  
- IncidenciaAreas/historico_positividadArea.csv
  
- IncidenciaAreas/historico_SituacionHospitales.csv
  
 Para actualizar en local:
 1.- Descargar los ficheros XLSM
 2.- Pulsar el botón "Actualizar" existente en los ficheros. Se sincroniza automáticamente con la información más actualizada
     existente en este Github.
 
