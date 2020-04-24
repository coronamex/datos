#!/usr/bin/env bash

DIR="./datos_abiertos/"
fecha="2020-04-23"

echo $DIR
echo $fecha


echo "Borrando vínculo"
rm $DIR/base_de_datos.csv

echo "Creando vínculo"
ln -s $fecha/base_de_datos.csv $DIR/base_de_datos.csv

echo "Series de tiempo"
Rscript src/datos_abiertos_series_tiempo.r

echo "Fechas confirmacion"
Rscript src/datos_abiertos_series_tiempo_fecha_confirmacion.r
