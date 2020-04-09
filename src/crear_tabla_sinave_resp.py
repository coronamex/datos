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


import crear_tabla_de_casos as dge
import camelot
import pandas as pd
import shutil
import argparse


def process_arguments():
    # Read arguments
    parser_format = argparse.ArgumentDefaultsHelpFormatter
    parser = argparse.ArgumentParser(formatter_class=parser_format)
    required = parser.add_argument_group("Required arguments")

    # Define description
    parser.description = ("Leer Boletín Epidemiológico del Sistema "
                          "Nacional de Vigilancia Epidemiológica y "
                          "producir tabla CSV con números de enfermedades "
                          "respiratorias.")

    # Define required arguments
    required.add_argument("--sinave_pdf",
                          help=("PDF con boletín del SINAVE"),
                          required=True,
                          type=str)

    # Define other arguments
    parser.add_argument("--archivo_salida",
                        help=("Nombre del archivo CSV producido"),
                        type=str,
                        default="sinave_resp.csv")
    parser.add_argument("--pagina_inicio",
                        help=("Página del PDF donde inician los datos de "
                              "enfermedades respiratorias."),
                        type=int,
                        default=22)

    # Read arguments
    print("Reading arguments")
    args = parser.parse_args()

    # Processing goes here if needed

    return args


def leer_sinave_tab(archivo, pagina,
                    lineas_saltar=6,
                    columnas=['estado',
                              'IRA_nuevos', 'IRA_acum_M', 'IRA_acum_F',
                              'IRA_acum_previo',
                              'neum_nuevos', 'neum_acum_M', 'neum_acum_F',
                              'neum_acum_previo',
                              'covid19_nuevos', 'covid19_acum_M',
                              'covid19_acum_F']):
    """Leer una tabla del Boletín del SINAVE"""

    # Dividir PDF y leer página especificada
    archivos = dge.dividir_paginas_pdf(archivo=archivo,
                                       tempdir="./tempdir/")
    tab = camelot.read_pdf(archivos[pagina - 1],
                           pages='all', flavor='stream')
    tab = tab[0].df

    # Formatear tabla
    tab = tab.drop(range(lineas_saltar))
    tab = tab.drop(tab.index[32:])
    tab.columns = columnas[0:tab.shape[1]]

    tab_numerica = tab.iloc[:, [0]].copy()
    for i in range(1, tab.shape[1]):
        vals = [pd.to_numeric(n.replace(' ', '').replace('-', '0')) for n in tab.iloc[:,i]]
        tab_numerica[tab.columns[i]] = vals

    # Limpiar
    shutil.rmtree("./tempdir")

    return(tab_numerica)


def leer_sinave_resp(archivo, inicio=22):
    """Leer tablas de enfermedades respiratorias del boletín
    del SINAVE"""
    Tab1 = leer_sinave_tab(archivo, pagina=inicio,
                           lineas_saltar=7,
                           columnas=['estado',
                                     'tub_nuevos', 'tub_acum_M', 'tub_acum_F',
                                     'tub_acum_previo',
                                     'ot_nuevos', 'ot_acum_M', 'ot_acum_F',
                                     'ot_acum_previo',
                                     'far_nuevos', 'far_acum_M', 'far_acum_F',
                                     'far_acum_previo'])
    Tab2 = leer_sinave_tab(archivo, pagina=inicio + 1,
                           lineas_saltar=6,
                           columnas=['estado',
                                     'IRA_nuevos', 'IRA_acum_M', 'IRA_acum_F',
                                     'IRA_acum_previo',
                                     'neum_nuevos', 'neum_acum_M',
                                     'neum_acum_F',
                                     'neum_acum_previo',
                                     'covid19_nuevos', 'covid19_acum_M',
                                     'covid19_acum_F'])

    # Combinar tablas
    Tab = pd.concat([Tab1.reset_index(), Tab2.reset_index()], axis=1)
    Tab = Tab.iloc[:, ~Tab.columns.duplicated()].drop(columns=['index'])

    return Tab


if __name__ == "__main__":
    args = process_arguments()

    Tab = leer_sinave_resp(args.sinave_pdf, inicio=args.pagina_inicio)

    Tab.to_csv(args.archivo_salida, sep=',', index=False, na_rep="NA")
