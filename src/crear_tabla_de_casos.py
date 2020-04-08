#!/usr/bin/env python
# Copyright (C) 2020 Sur Herrera Paredes

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

import argparse
import camelot
import os
import PyPDF2 as pypdf
import pandas as pd
import shutil


def process_arguments():
    # Read arguments
    parser_format = argparse.ArgumentDefaultsHelpFormatter
    parser = argparse.ArgumentParser(formatter_class=parser_format)
    required = parser.add_argument_group("Argumentos obligatorios")

    # Define description
    parser.description = ("Este script toma la tabla de casos confirmados "
                          "de la Dirección General de Epidemiología, y "
                          "produce una tabla CSV con todos los casos "
                          "confirmados.")

    # Define required arguments
    required.add_argument("--pdf_dge",
                          help=("Archivo PDF con tabla de casos "
                                "confirmados de la DGE."),
                          required=True, type=str)

    # Define other arguments
    parser.add_argument("--tabla_csv",
                        help=("Nombre del archivo producido"),
                        type=str,
                        default="tabla_casos_confirmados.csv")

    # Read arguments
    print("Reading arguments")
    args = parser.parse_args()

    # Processing goes here if needed

    return args


def dividir_paginas_pdf(archivo, tempdir="./tempdir/"):
    """Tomar un pdf y dividirlo en un archivo por página"""

    if os.path.isdir(tempdir):
        raise ValueError("Directorio temporal ya existe.")
    else:
        os.mkdir(tempdir)

    # Leer archivo
    pdf = pypdf.PdfFileReader(open(archivo, "rb"))

    # Separara en páginas
    archivos_pdf = []
    for i in range(pdf.numPages):
        nuevo = pypdf.PdfFileWriter()
        nuevo.addPage(pdf.getPage(i))
        archivos_pdf.append(tempdir + "/" + str(i) + ".pdf")
        with open(archivos_pdf[i], "wb") as hs:
            nuevo.write(hs)
        hs.close()

    return archivos_pdf


def combinar_tablas_de_pdf(archivo):
    """Toma un archivo PDF con una tabla en varias
    páginas, lee todo el archivo en una tabla por
    página, y combina las tablas en una"""

    # Leer y combinar todas las hojas en una tabla
    casos_positivos = camelot.read_pdf(archivo, pages='all')
    Tab = casos_positivos[0].df
    Tab = Tab.drop(0)
    for i in range(1, casos_positivos.n):
        Tab = Tab.append(casos_positivos[i].df)
    Tab.columns = ['caso', 'estado', 'sexo', 'edad',
                   'fecha_sintomas', 'confirmado',
                   'procedencia', 'fecha_llegada']
    # Tab.columns = ['caso', 'estado', 'sexo', 'edad',
    #                'fecha_sintomas', 'confirmado',
    #                'procedencia']
    Tab = Tab.reset_index()
    Tab = Tab.drop(columns=['caso', 'confirmado', 'index'])

    return Tab


def dividir_pdf_y_combinar(archivo, tempdir="./tempdir/"):
    """Toma un archivo pdf lo divide en un archivo por
    página, lee la tabla de cada archivo y las combina en
    una tabla.

    No hay ventaja de tiempo directa, pero podría ser
    paralelizable."""

    # Dividir archivo en páginas
    archivos = dividir_paginas_pdf(archivo=archivo,
                                   tempdir=tempdir)

    # Leer y combinar todas las hojas en una tabla
    Tab = pd.DataFrame()
    for a in archivos:
        casos_positivos = camelot.read_pdf(a, pages='all')
        Tab = Tab.append(casos_positivos[0].df)
    Tab = Tab.reset_index().drop(columns='index').drop(0)
    Tab.columns = ['caso', 'estado', 'sexo', 'edad',
                   'fecha_sintomas', 'confirmado',
                   'procedencia', 'fecha_llegada']
    # Tab = Tab.reset_index()
    # Tab = Tab.drop(columns=['caso', 'confirmado', 'index'])
    Tab = Tab.drop(columns=['caso', 'confirmado'])

    # Limpiar
    shutil.rmtree("./tempdir/")

    return Tab


if __name__ == "__main__":
    args = process_arguments()

    Tab = combinar_tablas_de_pdf(args.pdf_dge)

    # Escribir el archivo final
    Tab.to_csv(args.tabla_csv, sep=",", index=False)
