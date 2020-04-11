#!/usr/bin/env Rscript
library(tidyverse)

crear_tabla_estados_casos <- function(dir, lut){
  fechas_dirs <- list.dirs(dir, recursive = FALSE, full.names = TRUE)
  
  # Calcular casos acumulados
  Dat <- fechas_dirs %>%
    map_dfr(function(fecha_dir, lut){
      # fecha_dir <- "../datos/ssa_dge/2020-04-06/"
      archivo_tabla <- file.path(fecha_dir, "tabla_casos_confirmados.csv")
      if(file.exists(archivo_tabla)){
        Tab <- read_csv(archivo_tabla,
                        col_types = cols(estado = col_character(),
                                         sexo = col_character(),
                                         edad = col_number(),
                                         fecha_sintomas = col_date(format = "%d/%m/%Y"),
                                         procedencia = col_character(),
                                         fecha_llegada = col_date(format = "%d/%m/%Y")))
        
        # Elminar información sobre recuperados porque está incompleta
        Tab <- Tab %>%
          mutate(estado = str_remove(estado, pattern = "[*]$")) %>%
          mutate(estado = as.vector(lut[estado]))
        fecha <- basename(fecha_dir) %>% as.Date()
        acum_estado <- table(Tab$estado)
        res <- tibble(estado = names(acum_estado),
                      casos_acumulados = as.numeric(acum_estado),
                      fecha = fecha)
        
        return(res)
      }
    }, lut = lut)
  
  # Calcular casos nuevos
  Dat <- Dat %>%
    split(.$estado) %>%
    map_dfr(function(d){
      d %>%
        arrange(fecha) %>%
        mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1, default = 0))
    })
  
  Dat
}

args <- list(dge_dir = "ssa_dge/",
             dge_lut = "util/dge_LUT.tsv",
             csv_salida = "ssa_dge/serie_tiempo_estados_casos.csv")

# Leer lut de nombres
dge_lut <- read_tsv(args$dge_lut, col_names = FALSE, col_types = cols(.default = col_character()))
dge_lut <- set_names(x = dge_lut$X2, nm = dge_lut$X1)

# Crear tabla estados
Dat <- crear_tabla_estados_casos(dir = args$dge_dir, lut = dge_lut)
write_csv(Dat, args$csv_salida)