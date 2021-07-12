#!/usr/bin/env bash

DIR="./datos_abiertos/"
fecha="2021-07-11"

echo $DIR
echo $fecha


echo "Borrando vínculo"
rm $DIR/base_de_datos.csv.gz
if [ $? -ne 0 ]; then
    echo "Error"
    exit 1
fi

echo "Creando vínculo"
ln -s $fecha/base_de_datos.csv.gz $DIR/base_de_datos.csv.gz
if [ $? -ne 0 ]; then
    echo "Error"
    exit 1
fi

echo "Series de tiempo"
Rscript src/datos_abiertos_series_tiempo.r
if [ $? -ne 0 ]; then
    echo "Error"
    exit 1
fi

echo "Fechas confirmacion"
Rscript src/datos_abiertos_series_tiempo_fecha_confirmacion.r
if [ $? -ne 0 ]; then
    echo "Error"
    exit 1
fi
