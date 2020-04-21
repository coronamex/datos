# Datos abiertos del gobierno sobre COVID-19

Dede el 2020-04-13 el gobierno ha empezado a publicar los
[datos abiertos](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico)
del COVID-19. Estos datos se recolectan aquí y toman precendencia para la
mayoría de los análisis en [CoronaMex](https://coronamex.github.io).

## Archivos principales

* **base_de_datos.csv** Vínculo a la base de datos más reciente en formato
CSV.
* **serie_tiempo_estados_um_confirmados.csv**: Serie de tiempo para los
casos confirmados por entidad de la unidad médica en que buscaron atención.
La cuenta por estado inicia el día en que aparece el primer caso mostró
síntomas en dicho estado. Por cada día desde entonces se muestra el número
de casos que mostraron síntomas en una fecha determinada (*sintomas_nuevos*),
el número de casos que buscaron atención médica en una fecha determinada
(*ingreso_nuevos*), y el número de defunciones en una fecha determinada
(*muertes_nuevas*). Además se incluyen columnas con los números acumulados
totales correspondientes.
* **serie_tiempo_estados_res_confirmados.csv**: Tabla CSV equivalente a
*serie_tiempo_estados_um_confirmados.csv* pero usando la entidad de
residencia de los pacientes. En [CoronaMex](https://coronamex.github.io)
asumo que la entidad donde un paciente buscó atención médica es un mejor
indicador de donde pudo estar activo en estado infeccioso y por lo tanto
se usa esa tabla a menos que se indique lo contrario.
* **serie_tiempo_municipios_res_confirmados.csv**: Tabla CSV equivalente a
*serie_tiempo_estados_um_confirmados.csv* pero usando el municipio de
residencia de los pacientes. No tenemos municipio de las unidades médicas
y por lo tanto esta tabla se usa para análisis de municipios en
[CoronaMex](https://coronamex.github.io).
Se añade la columna *clave* que tiene la forma `##_###` donde los primeros
dos dígitos son la clave de la entidad y los tres dígitos finales son la
clave del municipio de la entidad correspondiente.
* **serie_tiempo_nacional_confirmados.csv**: Serie de tiempo para los
casos confirmados a nivel nacional. Contiene las mismas columnas que
*serie_tiempo_estados_um_confirmados.csv* pero los números son agregados
nacionales.
* **serie_tiempo_<REGION>_fecha_confirmación.csv**: Los archivos de este tipo
contienen series de tiempo de casos y defunciones de acuerdo a la fecha
en que fueron reportados por la SSA. Aunque estos números no son tan útiles
para describir la epidemia, son mejores para comparar con otros países y
para estudiar la respuesta del gobierno. Esta información no se encuentra
de manera directa en la base de datos abiertos de la SSA, pero puede inferirse
comparando las tablas desde `2020-04-12`. Para fechas anteriores, se completan
las tablas con los datos por estado del directorio
[ssa_dge](../ssa_dge_2020-04-19). Cuando hay discrepancias se le da
precendencia a los datos abiertos. En el caso de los datos por municipio
y por entidad de residencia, sólo tenemos datos abiertos, así que se
desconocen los números antes del `2020-04-12`.

## Directorio por fecha

Hay un directorio por cada fecha desde el 13 de abril (2020-04-13). Este día
la Secretaría de Salud comenzó a publicar información en la plataforma de
[datos abiertos](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico).

Cada directorio contiene los siguientes archivos:

* **base_de_datos.csv**: La base de datos liberada por el gobierno en formato
CSV para ese día y convertida a UTF-8 de ser necesario.
* **descriptores.csv** Tabla en formato CSV que explica el significado
de cada columna en la base de datos.
* **Diccionarios**: Archivos en formato CSV con nombres en mayúsculas. Explican
el código usado por la base de datos del gobierno. Estos archivos son:
*ENTIDADES.csv*, *MUNICIPIOS.csv*, *NACIONALIDAD.csv*, *ORIGEN.csv*,
*RESULTADO.csv*, *SECTOR.csv*, *SEXO.csv*, *SI_NO.csv* y *TIPO_PACIENTE.csv*.

## Problemas conocidos

* El 2020-04-16 la base de datos del gobierno cambió el nombre de
dos de sus columnas. `HABLA_LENGUA_INDI` camibió a `HABLA_LENGUA_INDIG`,
mientras que `OTRAS_CON` cambió a `OTRAS_COM`.

* Cuando se inicializaron las series de tiempo sobre fechas de confirmación
de casos/defunciones. Se encontraron algunas discrepancias entres los
datos recolectados de las tablas de casos del InDRE y el mapa de la
DGE con los datos abiertos. Se le dio precendencia a los datos abiertos,
pero estas son las discrepancias. Hay que notar que las diferencias del
2020-04-18 se deben a que el mapa de la DGE no se actualizó ese día.
    ```
    diferencias muertes Baja California 2020-04-18 33 68
    diferencias casos Baja California Sur 2020-04-15 164 165
    diferencias casos Baja California Sur 2020-04-16 165 166
    diferencias casos Campeche 2020-04-15 42 43
    diferencias muertes Ciudad de México 2020-04-18 136 178
    diferencias muertes Coahuila 2020-04-18 15 18
    diferencias muertes Chihuahua 2020-04-18 26 31
    diferencias muertes Guanajuato 2020-04-18 7 9
    diferencias muertes México 2020-04-18 49 52
    diferencias muertes Michoacán 2020-04-18 14 16
    diferencias muertes Morelos 2020-04-18 10 11
    diferencias muertes Nuevo León 2020-04-18 5 6
    diferencias muertes Oaxaca 2020-04-18 5 6
    diferencias casos Puebla 2020-04-15 290 291
    diferencias casos Puebla 2020-04-16 304 305
    diferencias muertes Puebla 2020-04-18 37 40
    diferencias muertes Sinaloa 2020-04-18 43 45
    diferencias muertes Tabasco 2020-04-18 27 28
    diferencias muertes Veracruz 2020-04-18 7 8
    diferencias muertes Yucatán 2020-04-18 8 10
    ```
