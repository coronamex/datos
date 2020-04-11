# Datos de la Dirección general de Epidemiología de la Secretaría de Salud

**AYUDA** *Si tienes las tablas de casos positivos/sospechosos
antes del 2020-03-15, o las tablas de casos/defunciones por estado antes
del 2020-04-01 en cualquier formato por favor avísame en
[Twitter](https://twitter.com/sur_hp)*.

## Archivos principales

* **datos_mapa.csv**: Vínculo a tabla más reciente con casos confirmados,
sospechosos, negativos y muertes por estado en formato CSV.
* **reportes_diarios.csv**: Esta tabla contiene los números
agregados nacionales para casos positivos, sospechosos y muertes.
Los números son tomados del comunicado técnico diario desde el
2020-02-27.
* **serie_tiempo_estados_casos.csv**: Esta tabla contiene el número
de casos nuevos y casos acumulados por estado por fecha. Los números
se calculan a partir de las tablas de casos positivos confirmados
del InDRE desde 2020-03-14.
* **tabla_casos_confirmados.csv**: Vínculo a la a tabla de casos
conformados como positivos por el InDRE en la fecha más
reciente disponible en formato CSV.

## Subdirectorios por fecha

Hay un directorio por fecha desde el 2020-02-27.

Por cada fecha hay un *Comunicado Técnico Diario* en
formato PDF suele tener un nombre de la forma
"Comunicado\_Tecnico\_Diario\_COVID-19\_*YYYY.MM.DD*.pdf"

A partir del 2020-03-14 hay un archivo PDF con
las tabla de casos positivos confirmados del InDRE. El archivo suelen
tener nombre de la forma:
"Tabla\_casos\_positivos\_COVID-19\_resultado\_InDRE\_*YYYY.MM.DD*.pdf",
y hay un archivo CSV con el nombre "tabla\_casos\_confirmados.csv" con
los datos del archivo del InDRE. **NOTA**: A partir del `2020-04-06` la 
Secretaría de Salud dejó de incluir la fecha de llegada a México de los
casos confirmados, y a partir del `2020-04-08` la Secretaría de Salud dejó
de incluir la fecha de llegada a México de los casos con historial de viaje.
Desde esas fechas, las columnas correspondientes sólo tiene el valor `NA`,

A partir del 2020-03-16 también hay un archivo PDF con la tablas de casos
sospechosos. El archivo suele tener nombre de la forma:
"Tabla\_casos\_sospechosos\_COVID-19\_*YYYY.MM.DD*.pdf".

A partir del 2020-04-01 se descarga una tabla en formato JSON del
[mapa interactivo](https://ncov.sinave.gob.mx/mapa.aspx)
de la Dirección General de Epidemiología. Los archivos se llaman 
"datos\_mapa.json". Además la tabla es convertida
a formato CSV y llamada "datos\_mapa.csv".

Previo al 2020-04-01. Hay un archivo "datos\_estados.csv" que contiene
los casos y muertes acumulado(a)s por estado. Estos datos fueron
importados del 
[repositorio de Gabriel Alfonso Carranco-Sapiéns](https://github.com/carranco-sga/Mexico-COVID-19). Los números de casos coinciden completamente
con los números calculados en CoronaMex basados en la tabla de
casos positivos en. Estos archivos se usan para completar la línea del
tiempo de casos por estado antes del 2020-03-14, y la línea
del tiempo de muertes por estado antes del 2020-04-01. Cuando
están presentes, los archivos "datos\_mapa.csv", y
"tabla\_casos\_confirmados.csv" toman precendencia.

Todos los archivos PDF son descargados diariamente de la
[Dirección General de Epidemiología](https://www.gob.mx/salud/acciones-y-programas/direccion-general-de-epidemiologia) en el siguiente URL:
https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449

## Compilación de datos

Los comunicados técnicos diarios desde 2020-02-27 fueron compilados
por Sur Herrera Paredes.

Las tablas de casos positivos y sospechosos desde 2020-03-25 fueron
compiladas por Sur Herrera Paredes.

### Otras fuentes

Algunos datos fueron recolectados de otras fuentes que ya los habían compilado.

* Guillermo de Anda-Jáuregui (https://github.com/guillermodeandajauregui/datos_covid19.mx).
* Repositorio [mexicovid19/Mexico-datos](https://github.com/mexicovid19/Mexico-datos).
* Repositorio de Gabriel Alfonso Carranco-Sapiéns (https://github.com/carranco-sga/Mexico-COVID-19).
