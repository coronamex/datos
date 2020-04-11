#!/usr/bin/env Rscript
library(tidyverse)

crear_tabla_estados_casos <- function(dir){
  # dir <- args$dge_dir
  fechas_dirs <- list.dirs(dir, recursive = FALSE, full.names = TRUE)
  
  # Calcular casos acumulados
  Dat <- fechas_dirs %>%
    map_dfr(function(fecha_dir){
      # fecha_dir <- "ssa_dge/2020-03-13/"
      # # fecha_dir <- "ssa_dge/2020-04-05/"
      
      fecha <- basename(fecha_dir) %>% as.Date()
      archivo_tabla <- file.path(fecha_dir, "tabla_casos_confirmados.csv")
      if(file.exists(archivo_tabla)){
        Tab <- read_csv(archivo_tabla,
                        col_types = cols(estado = col_character(),
                                         sexo = col_character(),
                                         edad = col_number(),
                                         fecha_sintomas = col_date(format = "%Y-%m-%d"),
                                         procedencia = col_character(),
                                         fecha_llegada = col_date(format = "%Y-%m-%d")))
        stop_for_problems(Tab)
        

        acum_estado <- table(Tab$estado)
        res <- tibble(estado = names(acum_estado),
                      casos_acumulados = as.numeric(acum_estado),
                      fecha = fecha)
        
        return(res)
      }else{
        Tab <- read_csv(file.path(fecha_dir, "datos_estado.csv"),
                        col_types = cols(estado = col_character(),
                                         casos_acumulados = col_number(),
                                         muertes_acumuladas = col_number()))
        stop_for_problems(Tab)
        res <- Tab %>%
          mutate(fecha = fecha) %>%
          select(-muertes_acumuladas) %>%
          filter(casos_acumulados > 0)
        
        return(res)
      }
    })
  
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

crear_tabla_estados_muertes <- function(dir){
  # dir <- args$dge_dir
  fechas_dirs <- list.dirs(dir, recursive = FALSE, full.names = TRUE)
  
  # Calcular casos acumulados
  Dat <- fechas_dirs %>%
    map_dfr(function(fecha_dir){
      # fecha_dir <- "ssa_dge/2020-03-13/"
      # fecha_dir <- "ssa_dge/2020-03-27/"
      # fecha_dir <- "ssa_dge/2020-04-05/"
      
      fecha <- basename(fecha_dir) %>% as.Date()
      archivo_tabla <- file.path(fecha_dir, "datos_mapa.csv")
      if(file.exists(archivo_tabla)){
        Tab <- read_csv(archivo_tabla,
                        col_types = cols(estado = col_character(),
                                         casos_acumulados = col_number(),
                                         muertes_acumuladas = col_number(),
                                         sospechosos = col_number(),
                                         negativos_acumulados = col_number()))
        stop_for_problems(Tab)

        res <- Tab %>%
          mutate(fecha = fecha) %>%
          select(estado, muertes_acumuladas, fecha) %>%
          filter(muertes_acumuladas > 0)
        
        return(res)
      }else{
        Tab <- read_csv(file.path(fecha_dir, "datos_estado.csv"),
                        col_types = cols(estado = col_character(),
                                         casos_acumulados = col_number(),
                                         muertes_acumuladas = col_number()))
        stop_for_problems(Tab)
        res <- Tab %>%
          mutate(fecha = fecha) %>%
          select(-casos_acumulados) %>%
          filter(muertes_acumuladas > 0)
        
        return(res)
      }
    })
  
  # Calcular casos nuevos
  Dat <- Dat %>%
    split(.$estado) %>%
    map_dfr(function(d){
      d %>%
        arrange(fecha) %>%
        mutate(muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1, default = 0))
    })
  
  Dat
}


args <- list(dge_dir = "ssa_dge/",
             casos_csv = "ssa_dge/serie_tiempo_estados_casos.csv",
             muertes_csv = "ssa_dge/serie_tiempo_estados_muertes.csv")

# Crear tabla casos
Dat <- crear_tabla_estados_casos(dir = args$dge_dir)
if(any(is.na(Dat$estado)))
  stop("ERROR: Hay un problema con los nombres de los estados.")
if(length(unique(Dat$estado)) != 32)
  stop("ERROR: Hay un problema con los nombres de los estados.")
write_csv(Dat, args$casos_csv)


# Crear tabla muertes
Dat <- crear_tabla_estados_muertes(dir = args$dge_dir)
if(any(is.na(Dat$estado)))
  stop("ERROR: Hay un problema con los nombres de los estados.")
# if(length(unique(Dat$estado)) != 32)
#   stop("ERROR: Hay un problema con los nombres de los estados.")
write_csv(Dat, args$muertes_csv)