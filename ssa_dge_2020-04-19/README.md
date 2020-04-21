# Datos de la Dirección general de Epidemiología de la Secretaría de Salud
**CONGELADO**: El `2020-04-19` la DGE ya no publicó sus tablas de casos
confirmados y sospechosos. El `2020-04-20` ya no se publicaron los
comunicados técnicos diarios y el mapa interactivo dejó de incluir el
número de casos/sospechosos/defunciones/negativos por estado. Este
directorio *ya no se actualiza*.

**IMPORTANTE**: A partir del 2020-04-13 la Secretaría de Salud ha comenzado
a publicar información más completa del COVID-19 en la plataforma de
[datos abiertos del gobierno](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico).
Estos datos se encuentran
en el directorio [datos_abiertos](../datos_abiertos/),
y tomarán precendencia para los análisis y visualizaciones en
[CoronaMex](https://coronamex.github.io). Sin embargo, se siguen recolectando
los datos de los reportes diarios mientras el gobierno los siga publicando.
Después del 2020-04-18, la Secretaría de Salud ha dejado de publicar las
tablas de casos confirmados y sospechosos del InDRE. A partir de esa
fecha sólo se recolectan los comunicados técnicos diarios y los datos
del mapa interactivo de la DGE.

**AYUDA** *Si tienes las tablas de casos positivos/sospechosos
antes del 2020-03-15, o las tablas de casos/defunciones por estado antes
del 2020-04-01 en cualquier formato por favor avísame en
[Twitter](https://twitter.com/sur_hp)*.

## Archivos principales

* **datos_mapa.csv**: Vínculo a tabla más reciente con casos confirmados,
sospechosos, negativos y muertes por estado en formato CSV. Los números
en esta tabla son recolectados del mapa interactivo de la DGE.
* **reportes_diarios.csv**: Esta tabla contiene los números
agregados nacionales para casos positivos, sospechosos y muertes.
Los números son tomados del comunicado técnico diario desde el
2020-02-27.
* **serie_tiempo_estados_casos_2020-04-18.csv**: Esta tabla contiene el número
de casos nuevos y casos acumulados por estado por fecha. Los números
se calculan a partir de las tablas de casos positivos confirmados
del InDRE desde 2020-03-14. **CONGELADO EL 2020-04-18**.
* **serie_tiempo_estados_muertes_2020-04-18.csv**: Esta tabla contiene el número
de muertes nuevas y muertes acumuladas por estado por fecha. Los números
se calculan a partir de las tablas de casos positivos confirmados
del InDRE desde 2020-03-14. **CONGELADO EL 2020-04-18**.

## Subdirectorios por fecha

Hay un directorio por fecha desde el 2020-02-27.

Por cada fecha hay un *Comunicado Técnico Diario* en
formato PDF suele tener un nombre de la forma
"Comunicado\_Tecnico\_Diario\_COVID-19\_*YYYY.MM.DD*.pdf"

Los siguientes archivod dejaron de publicarse a después del 2020-04-18.
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
