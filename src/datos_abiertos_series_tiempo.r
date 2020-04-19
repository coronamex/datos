#!/usr/bin/env Rscript
library(tidyverse)

crear_series_tiempo_variable <- function(Dat, variable = "ENTIDAD_UM", resultado = c("1")){
  
  Serie_var <- Dat %>%
    split(.[,variable]) %>%
    map_dfr(function(d, fecha_final = Sys.Date(), resultado = c("1")){
      # d <- Dat %>% filter(ENTIDAD_UM == "01")
      # d <- Dat %>% filter(MUNICIPIO_RES == "123")
      # fecha_final <- Sys.Date()
      # cat(unique(d[[variable]]), "\n")
      
      d <- d %>%
        filter(RESULTADO %in% resultado)
      
      if(nrow(d)){
        fecha_sintomas <- table(d$FECHA_SINTOMAS)
        fecha_ingreso <- table(d$FECHA_INGRESO)
        fecha_defuncion <- table(d$FECHA_DEF)
        # names(fecha_sintomas)
        
        res <-  bind_rows(tibble(fecha = names(fecha_sintomas),
                                 numero = fecha_sintomas,
                                 grupo = "sintomas_nuevos"),
                          tibble(fecha = names(fecha_ingreso),
                                 numero = fecha_ingreso,
                                 grupo = "ingreso_nuevos"))
        if(length(fecha_defuncion)){
          res <- res %>%
            bind_rows(tibble(fecha = names(fecha_defuncion),
                             numero = fecha_defuncion,
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
      
    }, resultado = resultado, .id = variable)
  
  Serie_agg <- Serie_var %>%
    select(!variable) %>%
    group_by(fecha) %>%
    summarise_all(sum) %>%
    arrange(fecha)
  
  return(list(Serie_var = Serie_var, Serie_agg = Serie_agg))
}


args <- list(base_de_datos = "datos_abiertos/base_de_datos.csv",
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

Dat <- read_csv(args$base_de_datos,
                col_types = cols(FECHA_ACTUALIZACION = col_date(format = "%Y-%m-%d"),
                                 FECHA_INGRESO = col_date(format = "%Y-%m-%d"),
                                 FECHA_SINTOMAS = col_date(format = "%Y-%m-%d"),
                                 FECHA_DEF = col_character(),
                                 EDAD = col_number(),
                                 .default = col_character())) 
stop_for_problems(Dat)
Dat <- Dat %>%
  mutate(FECHA_DEF = parse_date(x = FECHA_DEF, format = "%Y-%m-%d", na = c("9999-99-99", "", "NA")),
         PAIS_NACIONALIDAD = parse_character(PAIS_NACIONALIDAD, na = c("99", "", "NA")),
         PAIS_ORIGEN = parse_character(PAIS_ORIGEN, na = c("97", "", "NA")))

# ENTIDAD_UM
Series <- crear_series_tiempo_variable(Dat = Dat, variable = "ENTIDAD_UM", resultado = "1")
Series$Serie_var
Series$Serie_agg
Series$Serie_var %>%
  mutate(estado = estados_lut[ENTIDAD_UM]) %>%
  select(-ENTIDAD_UM) %>%
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_estados_um_confirmados.csv"))
Series$Serie_agg %>%
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_nacional_confirmados.csv"))

# ENTIDAD_RES
Series <- crear_series_tiempo_variable(Dat = Dat, variable = "ENTIDAD_RES", resultado = "1")
Series$Serie_var
# Series$Serie_agg
Series$Serie_var %>%
  mutate(estado = estados_lut[ENTIDAD_RES]) %>%
  select(-ENTIDAD_RES) %>%
  # print(n=100)
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_estados_res_confirmados.csv"))

# MUNICIPIO_RES
Series <- crear_series_tiempo_variable(Dat = Dat %>%
                                         mutate(municipio = paste(ENTIDAD_RES, MUNICIPIO_RES,  sep = "_")),
                                       variable = "municipio", resultado = "1")
Series$Serie_var
# Series$Serie_agg
Series$Serie_var %>%
  mutate(clave = municipio,
         municipio = set_names(municipios_lut$X2, municipios_lut$X1)[municipio]) %>%
  # select(-MUNICIPIO_RES) %>%
  # print(n=100) %>%
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_municipio_res_confirmados.csv"))


