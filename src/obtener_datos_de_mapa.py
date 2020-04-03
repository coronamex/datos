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
import os
import json
import pycurl
from io import BytesIO
import pandas as pd


def process_arguments():
    # Read arguments
    parser_format = argparse.ArgumentDefaultsHelpFormatter
    parser = argparse.ArgumentParser(formatter_class=parser_format)
    # required = parser.add_argument_group("Required arguments")

    # Define description
    parser.description = ("Obtiene datos de casos por estado del mapa "
                          "interactivo de la DGE vía una petición "
                          "POST.")

    # Define other arguments
    parser.add_argument("--url",
                        help=("URL del app para el cual hacer la petición "
                              "POST."),
                        type=str,
                        default=("http://ncov.sinave.gob.mx/"
                                 "mapa.aspx/Grafica22"))
    parser.add_argument("--dir_salida",
                        help=("Directorio para guardar archivos generaros"),
                        type=str,
                        default='./')
    parser.add_argument("--sobreescribir",
                        help=("Indica que se deben sobreescribir archivos "
                              "en el directorio de salida"),
                        action="store_true",
                        default=False)

    # Read arguments
    print("Reading arguments")
    args = parser.parse_args()

    # Processing goes here if needed
    args.archivo_json = args.dir_salida + '/datos_mapa.json'
    args.archivo_csv = args.dir_salida + '/datos_mapa.csv'

    if not os.path.isdir(args.dir_salida):
        raise ValueError("Directorio de salida no existe.")
    if os.path.isfile(args.archivo_csv) and not args.sobreescribir:
        raise FileExistsError("Archivo de salida CSV ya existe.")
    if os.path.isfile(args.archivo_json) and not args.sobreescribir:
        raise FileExistsError("Archivo de salida JSON ya existe.")

    return args


def obtener_json(url):
    """Hace una petición POST y obtiene una cadena en forma JSON"""

    # Usar pycurl para la petición POST
    buffer = BytesIO()
    c = pycurl.Curl()
    c.setopt(c.URL, url)
    c.setopt(c.WRITEDATA, buffer)
    data = json.dumps({})
    c.setopt(pycurl.POST, 1)
    c.setopt(pycurl.POSTFIELDS, data)
    # c.setopt(pycurl.HTTPHEADER, ['User-Agent: Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:74.0) Gecko/20100101 Firefox/74.0',
    #                              'Accept: */*',
    #                              'Accept-Language: es-ES,es;q=0.8,en-US;q=0.5,en;q=0.3',
    #                              'Content-Type: application/json; charset=utf-8',
    #                              'X-Requested-With: XMLHttpRequest',
    #                              'Origin: http://ncov.sinave.gob.mx',
    #                              'Connection: keep-alive',
    #                              'Referer: http://ncov.sinave.gob.mx/mapa.aspx',
    #                              'Cookie: acceptcookiefreecounterstat=ok; counter=7c1b9c58284212977601e1056d7ecf31; counter_nv=7c1b9c58284212977601e1056d7ecf31',
    #                              'DNT: 1',
    #                              'Cache-Control: max-age=0'])
    c.setopt(pycurl.HTTPHEADER,
             ['Content-Type: application/json; charset=utf-8'])
    c.perform()
    c.close()

    # Obtener el resultado como cadena
    body = buffer.getvalue()
    # print(body.decode('UTF-8'))
    mapa_json = body.decode('UTF-8')

    return mapa_json


def json_a_dataframe(json):
    """Convertir json a pandas Data Frame"""

    tab = json.loads(json.loads(json)['d'])
    df = pd.DataFrame(tab,
                      columns=['id', 'estado', 'pob', 'num',
                               'casos_acumulados',
                               'negativos_acumulados',
                               'sospechosos', 'muertes_acumuladas'])
    df = df.drop(columns=['id', 'pob', 'num'])
    ii = ['casos_acumulados', 'negativos_acumulados',
          'sospechosos', 'muertes_acumuladas']
    df[ii] = df[ii].apply(pd.to_numeric)

    return df


if __name__ == "__main__":
    args = process_arguments()

    # Leer el mapa en formato json
    print("Leyendo mapa...")
    mapa_json = obtener_json(args.url)
    with open(args.archivo_json, 'w') as hs:
        hs.write(mapa_json)
    hs.close

    # Convertir a pandas
    print("Convirtiendo a DataFrame...")
    df = json_a_dataframe(mapa_json)
    with open(args.archivo_csv, 'w') as hs:
        hs.write(df)
    hs.close
