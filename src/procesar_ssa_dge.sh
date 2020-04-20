#!/usr/bin/env bash

DIR="./ssa_dge/"
fecha="2020-04-19"

echo $DIR
echo $fecha

# touch $DIR/$fecha/test

#./src/crear_tabla_de_casos.py --tabla_csv $DIR/$fecha/tabla_casos_confirmados.csv --pdf_dge $DIR/$fecha/Tabla_casos_positivos_COVID-19_resultado_InDRE_*.pdf
./src/obtener_datos_de_mapa.py --dir_salida $DIR/$fecha --url https://covid19.sinave.gob.mx/mapa.aspx/Grafica22
./src/procesar_tablas_principales.r --dir $DIR/$fecha

#rm $DIR/tabla_casos_confirmados.csv
rm $DIR/datos_mapa.csv
#ln -s $fecha/tabla_casos_confirmados.csv $DIR/
ln -s $fecha/datos_mapa.csv $DIR/

./src/crear_series_tiempo_estados.r
