library(tidyverse)

args <- list(base_de_datos = "datos_abiertos/base_de_datos.csv",
             estados_lut = "util/estados_lut_datos_abiertos.csv",
             dir_salida = "datos_abiertos/")


estados_lut <- read_csv(args$estados_lut,
                        col_names = FALSE,
                        col_types = cols(.default = col_character()))
stop_for_problems(estados_lut)
estados_lut <- set_names(estados_lut$X2, estados_lut$X1)


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


Serie_confirmados <- Dat %>%
  split(.$ENTIDAD_UM) %>%
  map_dfr(function(d){
    d <- Dat %>% filter(ENTIDAD_UM == "01")
    
    d <- d %>%
      filter(RESULTADO == "1")
    
    fecha_sintomas <- table(d$FECHA_SINTOMAS)
    fecha_ingreso <- table(d$FECHA_INGRESO)
    fecha_defuncion <- table(d$FECHA_DEF)
    # names(fecha_sintomas)
    
    bind_rows(tibble(fecha = names(fecha_sintomas) %>% parse_date(format = "%Y-%m-%d"),
                     numero = fecha_sintomas,
                     grupo = "sintomas_nuevos"),
              tibble(fecha = names(fecha_ingreso) %>% parse_date(format = "%Y-%m-%d"),
                     numero = fecha_ingreso,
                     grupo = "ingreso_nuevos"),
              tibble(fecha = names(fecha_defuncion) %>% parse_date(format = "%Y-%m-%d"),
                     numero = fecha_defuncion,
                     grupo = "muertes_nuevas")) %>%
      pivot_wider(fecha, names_from = "grupo", values_from = "numero",
                  values_fill = list(numero = 0)) %>%
      arrange(fecha) %>%
      mutate(sintomas_acumulados = cumsum(sintomas_nuevos),
             ingreso_acumulados = cumsum(ingreso_nuevos),
             muertes_acumuladas = cumsum(muertes_nuevas))
  }, .id = "ENTIDAD_UM")
Serie_confirmados %>%
  mutate(estado = estados_lut[ENTIDAD_UM]) %>%
  select(-ENTIDAD_UM) %>%
  write_csv(path = file.path(args$dir_salida, "serie_tiempo_estados_um_confirmados.csv"))




