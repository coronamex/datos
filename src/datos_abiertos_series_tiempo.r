#!/usr/bin/env Rscript
library(tidyverse)
source("../visualizando/util/leer_datos_abiertos.r")

#' Title
#' 
#' Crea una serie de tiempo por fecha de síntomas, ingreso y defunción basado en base
#' de datos abiertos de la SSA.
#'
#' @param Dat 
#' @param variable 
#'
#' @return
#' @export
#'
#' @examples
crear_series_tiempo_variable <- function(Dat, variable = "ENTIDAD_UM"){
  
  Serie_var <- Dat %>%
    split(.[,variable]) %>%
    map_dfr(function(d, fecha_final = Sys.Date()){
      # d <- Dat %>% filter(ENTIDAD_UM == "01")
      # d <- Dat %>% filter(MUNICIPIO_RES == "123")
      # fecha_final <- Sys.Date()
      # cat(unique(d[[variable]]), "\n")
      
      if(nrow(d)){
        fecha_sintomas <- table(d$FECHA_SINTOMAS)
        fecha_ingreso <- table(d$FECHA_INGRESO)
        fecha_defuncion <- table(d$FECHA_DEF)
        # names(fecha_sintomas)
        
        res <-  bind_rows(tibble(fecha = names(fecha_sintomas),
                                 numero = as.numeric(fecha_sintomas),
                                 grupo = "sintomas_nuevos"),
                          tibble(fecha = names(fecha_ingreso),
                                 numero = as.numeric(fecha_ingreso),
                                 grupo = "ingreso_nuevos"))
        if(length(fecha_defuncion)){
          res <- res %>%
            bind_rows(tibble(fecha = names(fecha_defuncion),
                             numero = as.numeric(fecha_defuncion),
                             grupo = "muertes_nuevas"))
        }else{
          res <- res %>%
            bind_rows(tibble(fecha = sort(names(fecha_sintomas), decreasing = TRUE)[1],
                             numero = 0,
                             grupo = "muertes_nuevas"))
        }
        res <- res %>%
          mutate(fecha = fecha %>% parse_date(format = "%Y-%m-%d"))
        
        tibble(fecha = min(res$fecha) + 0:(fecha_final - min(res$fecha))) %>%
          left_join(res %>%
                      pivot_wider(fecha, names_from = "grupo", values_from = "numero",
                                  values_fill = list(numero = 0)),
                    by = "fecha") %>%
          arrange(fecha) %>%
          replace_na(list(sintomas_nuevos = 0, ingreso_nuevos = 0, muertes_nuevas = 0)) %>%
          mutate(sintomas_acumulados = cumsum(sintomas_nuevos),
                 ingreso_acumulados = cumsum(ingreso_nuevos),
                 muertes_acumuladas = cumsum(muertes_nuevas))
        # print(n = 100)
      }
      
    }, .id = variable)
  
  Serie_agg <- Serie_var %>%
    # select(!variable) %>%
    select(!all_of(variable)) %>%
    group_by(fecha) %>%
    summarise_all(sum) %>%
    arrange(fecha)
  
  return(list(Serie_var = Serie_var, Serie_agg = Serie_agg))
}


args <- list(base_de_datos = "datos_abiertos/base_de_datos.csv.gz",
             estados_lut = "util/estados_lut_datos_abiertos.csv",
             municipios_lut = "util/municipios_lut_datos_abiertos.csv",
             dir_salida = "datos_abiertos/")


estados_lut <- read_csv(args$estados_lut,
                        col_names = FALSE,
                        col_types = cols(.default = col_character()))
stop_for_problems(estados_lut)
estados_lut <- set_names(estados_lut$X2, estados_lut$X1)
municipios_lut <- read_csv(args$municipios_lut,
                           col_names = FALSE,
                           col_types = cols(.default = col_character()))
stop_for_problems(municipios_lut)

cat("Leer base de datos\n")
Dat <- leer_datos_abiertos(args$base_de_datos,
                           solo_confirmados = TRUE,
                           solo_fallecidos = FALSE,
                           solo_laboratorio = FALSE,
                           version = "adivinar")

# ENTIDAD_UM
cat("Crear estado_um\n")
Series <- crear_series_tiempo_variable(Dat = Dat, variable = "ENTIDAD_UM")
# Series$Serie_var
# Series$Serie_agg
Series$Serie_var %>%
  mutate(estado = estados_lut[ENTIDAD_UM]) %>%
  select(-ENTIDAD_UM) %>%
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_estados_um_confirmados.csv.gz"))
Series$Serie_agg %>%
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_nacional_confirmados.csv.gz"))

# ENTIDAD_RES
cat("Crear estado_res\n")
Series <- crear_series_tiempo_variable(Dat = Dat, variable = "ENTIDAD_RES")
# Series$Serie_var
# Series$Serie_agg
Series$Serie_var %>%
  mutate(estado = estados_lut[ENTIDAD_RES]) %>%
  select(-ENTIDAD_RES) %>%
  # print(n=100)
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_estados_res_confirmados.csv.gz"))

# MUNICIPIO_RES
cat("Crear municipio_res\n")
Series <- crear_series_tiempo_variable(Dat = Dat %>%
                                         mutate(municipio = paste(ENTIDAD_RES, MUNICIPIO_RES,  sep = "_")),
                                       variable = "municipio")
# Series$Serie_var
# Series$Serie_agg
cat("Crear nacional\n")
Series$Serie_var %>%
  mutate(clave = municipio,
         municipio = set_names(municipios_lut$X2, municipios_lut$X1)[municipio]) %>%
  # select(-MUNICIPIO_RES) %>%
  # print(n=100) %>%
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_municipio_res_confirmados.csv.gz"))


