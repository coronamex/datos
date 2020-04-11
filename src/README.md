# Código para extraer y procesar datos

## Recolectores

Estos scripts extraen datos de los archivos de la DGE/SSA.

* **crear_tabla_de_casos.py**: Lee el archivo PDF de casos positivos
confirmados por el InDRE y lo convierte en una tabla CSV.
* **obtener_datos_de_mapa.py**: Realiza una petición POST al app
con el mapa interactivo de la DGE/SSA y obtiene el archivo JSON
con datos por estado. Guarda los datos en formato JSON y CSV.

## Procesadores

Estos scripts usan los datos recolectados y producen tablas
estandarizadas.

* **crear_series_tiempo_estados.r**: Lee las tablas de casos positivos
diarias, así como los datos del mapa interactivo y produce archivos CSV
con casos y muertes por día (acumulados y nuevos) por estado. Para
los días en que no hay tablas de casos positivos o datos de mapa,
usa los archivos "datos\_estado.csv".
* **procesar_tablas_principales**: Homogeniza los nombres de los
estados en las tablas de casos confirmados y los datos del mapa
interactivo.

## Importadores

Este código se usa para obtener datos que no pudieron adquirise 
directamente de la SSA/DGE.
