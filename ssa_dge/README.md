# Datos de la Dirección general de Epidemiología de la Secretaría de Salud

**AYUDA** *Si tienes las tablas de casos positivos/sospechosos
antes del 2020-03-15, o las tablas de casosn/defunciones por estado antes
del 2020-04-01 en cualquier formato por favor avísame en
[Twitter](https://twitter.com/sur_hp)*.

## Archivos principales

* **reportes_diarios.csv**: Esta tabla contiene los números
agregados nacionales para casos positivos, sospechosos y muertes.
Los números son tomados del comunicado técnico diario desde el
2020-02-27.
* **tabla_casos_confirmados.csv**: Vínculo a la a tabla de casos
conformados como positivos por el InDRE en la fecha más
reciente disponible en formato CSV.
* **datos_mapa.csv**: Vínculo a tabla más reciente con casos confirmados,
sospechosos, negativos y muertes por estado en formato CSV.

## Subdirectorios por fecha

Hay un directorio por fecha desde el 2020-02-27.

Por cada fecha hay un *Comunicado Técnico Diario* en
formato PDF suele tener un nombre de la forma
"Comunicado\_Tecnico\_Diario\_COVID-19\_*YYYY.MM.DD*.pdf"

A partir del 2020-03-25 también hay dos archivos PDF con
las tablas de casos positivos y la tabla de casos sospechosos.
Los archivos suelen tener nombres de la forma:
"Tabla\_casos\_positivos\_COVID-19\_resultado\_InDRE\_*YYYY.MM.DD*.pdf", y
"Tabla\_casos\_sospechosos\_COVID-19\_*YYYY.MM.DD*.pdf" respectivamente.

A partir del 2020-03-25, la tabla de caos positivos del InDRE
ha sido convertida a formato CSV con el nombre:
tabla\_casos\_confirmados.csv

A partir del 2020-04-01 se descarga una tabla en formato json del
[mapa interactivo](http://ncov.sinave.gob.mx/mapa.aspx)
de la Dirección General de Epidemiología.
Los archivos se llaman "datos\_mapa.json". Además la tabla es convertida
a formato CSV y llamada "datos\_mapa.csv".

Todos los archivos PDF son descargados diariamente de la
[Dirección General de Epidemiología](https://www.gob.mx/salud/acciones-y-programas/direccion-general-de-epidemiologia) en el siguiente URL:
https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449

## Compilación de datos

Los comunicados técnicos diarios desde 2020-02-27 fueron compilados por Sur Herrera Paredes.

Las tablas de casos positivos y sospechosos desde 2020-03-25 fueron compilados por Sur Herrera Paredes.

### Otros contribuyentes:

* Guillermo de Anda-Jáuregui (https://github.com/guillermodeandajauregui/datos_covid19.mx)
* Repositorio [mexicovid19/Mexico-datos](https://github.com/mexicovid19/Mexico-datos)
