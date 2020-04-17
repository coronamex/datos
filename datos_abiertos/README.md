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
síntomas. Por cada día desde entonces se muestra el número de nuevos casos
que mostraron síntomas (*sintomas_nuevos*), el número de nuevos casos que
buscaron atención médica (*ingreso_nuevos*), y el número de defunciones
(*muertes_nuevas*). Además se incluyen columnas con los números acumulados
correspondientes.
* **serie_tiempo_nacional_confirmados.csv**: Serie de tiempo para los
casos confirmados a nivel nacional. Contiene las mismas columnas que
*serie_tiempo_estados_um_confirmados.csv* pero los números son agregados
nacionales.

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
