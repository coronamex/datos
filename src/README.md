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

* **crear_tabla_estados_casos.r**: Le las tablas de casos positivos
diarias y produce un archivo CSV con casos acumulados y casos
nuevos por estado por día.

## Importadores

Este código se usa para obtener datos que no pudieron adquirise 
directamente de la SSA/DGE.
