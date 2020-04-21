# Datos sobre el COVID-19 en méxico.

**IMPORTANTE**: A partir del 2020-04-13 la Secretaría de Salud ha comenzado
a publicar información más completa del COVID-19 en la plataforma de
[datos abiertos del gobierno](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico).
Se espera que estos datos se actualicen diariamente. Estos datos se encuentran
en el directorio [datos_abiertos](datos_abiertos/) de este repositorio,
y tomarán precendencia para los análisis y visualizaciones en
[CoronaMex](https://coronamex.github.io). Sin embargo, se siguen recolectando
los datos de los reportes diarios mientras el gobierno los siga publicando.

Este repositorio contiene los datos presentados en
[CoronaMex](https://github.com/coronamex).

Los siguientes directorios están presentes:

* **demograficos**: Datos demográficos de diversas fuentes. Revizar el archivo
[demograficos/README.md](demograficos/README.md) para más detalles.
* **datos_abiertos**: Datos liberados por la Secretaría de Salud a partir
del 2020-04-13  en la plataforma de
[datos abiertos](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico).
Estos datos toman precedencia para los análisis de
[CoronaMex](https://coronamex.github.io).
El archivo [datos_abiertos/README.md](datos_abiertos/README.md) describe
los datos disponibles.
* **sinave**: Archivos PDF del Boletín Epidemiológico del Sistema Nacional
de Vigilancia Epidemiológico (SINAVE), que la Dirección General de
Epidemiología
[publica cada semana](https://www.gob.mx/salud/documentos/boletinepidemiologico-sistema-nacional-de-vigilancia-epidemiologica-sistema-unico-de-informacion-231750) (con dos semanas de retraso). Además, se convierte a formato CSV la tabla de enfermedades respiratorias
infecciosas de los boletines. La Secretaría de Salud usa el número de casos
a nivel nacional de estas enfermedades para estimar un factor de corrección y
convertir el número de casos de COVID-19 en las USMER en un estimado de casos
de COVID-19 a nivel nacional (sistema Centinela). NOTA: los números en estas
tablas no concuerdan con las tablas mostradas en las conferencias de prensa
de la Secretaría de Salud, posiblemente porque los boletines incluyen
casos probables.
* **src**: Código para procesar datos.
* **ssa_dge_2020-04-19**: **Congelado después de 2020-04-19 cuando la DGE dejó de
publicar los comunicados técnicos diarios.**.
Datos liberados por la [Dirección General de Epidemiología](https://www.gob.mx/salud/acciones-y-programas/direccion-general-de-epidemiologia)
de la [Secretaría de Salud](https://www.gob.mx/salud) a través de sus comunicados
técnicos diarios así como las tablas de casos confirmados y casos sospechosos
del InDRE y liberados diariamente. También se obtienen datos del
[mapa interactivo](https://covid19.sinave.gob.mx/mapa.aspx) de la DGE.
El archivo [ssa_dge_2020-04-19/README.md](ssa_dge_2020-04-19/README.md) describe los datos
disponibles. `NOTA`: *Las tablas de casos confirmados y sospechosos dejaron
de publicarse después del 2020-04-18*.
* **util**: Archivos con utilidades para el código.

## Acerca de este repositorio

Los datos aquí presentados son públicos y fueron recopilados por
[Sur Herrera Paredes](https://github.com/surh) de diversas fuentes.
El código se distribuye bajo una licencia [GPL-3](CODE_LICENSE) y la recopilación
de datos bajo una licencia [CC BY-NC 4](DATA_LICENSE).

### Fuentes de datos

* Los comunicados técnicos diarios y las tablas de casos positivos y
sospechosos que elabora el InDRE y publicados por la Dirección General
de Epidemiología (DGE). La DGE tiene sus documentos más recientes
en su
[sitio de COVID-19](https://www.gob.mx/salud/documentos/coronavirus-covid-19-comunicado-tecnico-diario-238449),
y se pueden encontrar algunos de los archivos anteriores en su
[historial de documentos](https://www.gob.mx/salud/es/archivo/documentos).
Esta es una fuente oficial.
* El [mapa interactivo](http://covid19.sinave.gob.mx/mapa.aspx) de la DGE se
usa para obtener datos por estado. Esta es una fuente oficial.
* El portal de
[datos abiertos](https://datos.gob.mx/busca/dataset/informacion-referente-a-casos-covid-19-en-mexico)
del Gobierno de México y la
[página correspondiente](https://www.gob.mx/salud/documentos/datos-abiertos-152127) de la Dirección General de Epidemiología publican una tabla
en formato CSV desde el 2020-04-13. Esta es una fuente oficial.
* [Repositorio de Guillermo de Anda-Jáuregui](https://github.com/guillermodeandajauregui/datos_covid19.mx) para completar tablas de casos confirmados. Esta es una
fuente no oficial.
* Repositorio [mexicovid19/Mexico-datos](https://github.com/mexicovid19/Mexico-datos)
para completar tablas de casos confirmados y sospechosos. Esta es una fuente
no oficial.
* [Repositorio de Gabriel Alfonso Carranco-Sapiéns](https://github.com/carranco-sga/Mexico-COVID-19)
para completar tabla de casos confirmados. Esta es una fuente no oficial.
