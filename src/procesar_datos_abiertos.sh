#!/usr/bin/env bash

DIR="./datos_abiertos/"
fecha="2020-04-14"

echo $DIR
echo $fecha


rm $DIR/base_de_datos.csv
ln -s $fecha/base_de_datos/*.csv $DIR/base_de_datos.csv

Rscript src/datos_abiertos_series_tiempo.r
