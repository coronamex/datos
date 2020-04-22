library(tidyverse)

encontrar_nuevos_dirs <- function(dir, max_fecha){
  
  dias_extra <- as.numeric(Sys.Date() - max_fecha)
  if(dias_extra < 0){
    stop("ERROR en fechas")
  }
  nuevos_dirs <- NULL
  for(i in 1:dias_extra){
    fecha <- max_fecha + i
    
    fecha_dir <- file.path(dir, as.character(fecha))
    
    if(dir.exists(fecha_dir)){
      nuevos_dirs <- c(nuevos_dirs, as.character(fecha_dir))
    }else{
      return(nuevos_dirs)
    }
  }
  
  return(nuevos_dirs)
}

args <- list(estados_lut = "util/estados_lut_datos_abiertos.csv",
             municipios_lut = "util/municipios_lut_datos_abiertos.csv",
             dir_salida = "datos_abiertos/",
             serie_estados = "datos_abiertos/serie_tiempo_estados_fecha_confirmacion.csv",
             serie_municipios = "datos_abiertos/serie_tiempo_municipios_fecha_confirmacion.csv",
             serie_nacional = "datos_abiertos/serie_tiempo_nacional_fecha_confirmacion.csv")

estados_lut <- read_csv(args$estados_lut,
                        col_names = FALSE,
                        col_types = cols(.default = col_character()))
stop_for_problems(estados_lut)
estados_lut <- set_names(estados_lut$X2, estados_lut$X1)
municipios_lut <- read_csv(args$municipios_lut,
                           col_names = FALSE,
                           col_types = cols(.default = col_character()))
stop_for_problems(municipios_lut)


Serie_estados <- read_csv(args$serie_estados,
                           col_types = cols(fecha = col_date(format = "%Y-%m-%d"),
                                            estado = col_character(),
                                            .default = col_number()))
stop_for_problems(Serie_estados)
Serie_municipios <- read_csv(args$serie_municipios,
                             col_types = cols(fecha = col_date(format = "%Y-%m-%d"),
                                              municipio = col_character(),
                                              clave = col_character(),
                                              .default = col_number()))
stop_for_problems(Serie_municipios)
Serie_nacional <- read_csv(args$serie_nacional,
                             col_types = cols(fecha = col_date(format = "%Y-%m-%d"),
                                              .default = col_number()))
stop_for_problems(Serie_nacional)

max_fecha <- min(max(Serie_estados$fecha), max(Serie_municipios$fecha), max(Serie_nacional$fecha))
max_fecha
fechas_dirs <- encontrar_nuevos_dirs(dir = args$dir_salida, max_fecha = max_fecha)
if(length(fechas_dirs) == 0){
  stop("No hay directorios nuevos")
}

# Serie tiempo casos confirmados estados
Dat <- fechas_dirs %>%
  map_dfr(function(fecha_dir){
    fecha <- basename(fecha_dir) %>% parse_date(format = "%Y-%m-%d")
    cat(as.character(fecha), "\n")
    
    Dat <- read_csv(file.path(fecha_dir, "base_de_datos.csv"),
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
    
    # Confirmados
    Dat <- Dat %>%
      filter(RESULTADO == "1")
    
    entidad_um <- table(Dat$ENTIDAD_UM)
    entidad_res <- table(Dat$ENTIDAD_RES)
    municipio_res <- table(paste(Dat$ENTIDAD_RES, Dat$MUNICIPIO_RES,  sep = "_"))
    
    # Confirmados muertes
    Dat <- Dat %>%
      filter(!is.na(FECHA_DEF))
    
    entidad_um_muertes <- table(Dat$ENTIDAD_UM)
    entidad_res_muertes <- table(Dat$ENTIDAD_RES)
    municipio_res_muertes <- table(paste(Dat$ENTIDAD_RES, Dat$MUNICIPIO_RES,  sep = "_"))
    
    tibble(fecha = fecha,
           casos_acumulados = as.vector(entidad_um),
           tipo = "entidad_um",
           region = names(entidad_um),
           region_nombre = "estado") %>%
      full_join(tibble(fecha = fecha,
                       muertes_acumuladas = as.vector(entidad_um_muertes),
                       tipo = "entidad_um",
                       region = names(entidad_um_muertes),
                       region_nombre = "estado"),
                by = c("fecha", "tipo", "region", "region_nombre")) %>%
      bind_rows(tibble(fecha = fecha,
                       casos_acumulados = as.vector(entidad_res),
                       tipo = "entidad_res",
                       region = names(entidad_res),
                       region_nombre = "estado") %>%
                  full_join(tibble(fecha = fecha,
                                   muertes_acumuladas = as.vector(entidad_res_muertes),
                                   tipo = "entidad_res",
                                   region = names(entidad_res_muertes),
                                   region_nombre = "estado"),
                            by = c("fecha", "tipo", "region", "region_nombre"))) %>%
      bind_rows(tibble(fecha = fecha,
                       casos_acumulados = as.vector(municipio_res),
                       tipo = "municipio_res",
                       region = names(municipio_res),
                       region_nombre = "municipio")%>%
                  full_join(tibble(fecha = fecha,
                                   muertes_acumuladas = as.vector(municipio_res_muertes),
                                   tipo = "municipio_res",
                                   region = names(municipio_res_muertes),
                                   region_nombre = "municipio"),
                            by = c("fecha", "tipo", "region", "region_nombre"))) %>%
      mutate(muertes_acumuladas = replace_na(muertes_acumuladas, 0),
             casos_acumulados = replace_na(casos_acumulados, 0))
  }) %>%
  split(.$tipo) %>%
  map_dfr(function(d){
    cat(unique(d$tipo), "\n")
    region_nombre <- unique(d$region_nombre)
    d %>%
      select(region, fecha, casos_acumulados, muertes_acumuladas) %>%
      # mutate(fecha = parse_date(fecha, format = "%Y-%m-%d")) %>%
      split(.$region) %>%
      map_dfr(function(d){
        d %>%
          arrange(fecha) %>%
          select(fecha, casos_acumulados, muertes_acumuladas) %>%
          mutate(region_nombre = region_nombre)
      }, .id = "region") %>%
      mutate(region_nombre = region_nombre)
  }, .id = "tipo")

# Estados
Nuevos_estados <- Dat %>%
  filter(tipo == "entidad_um") %>%
  filter(fecha > max(Serie_estados$fecha)) %>%
  select(-region_nombre, -tipo) %>%
  mutate(estado = as.vector(estados_lut[region])) %>%
  select(estado, casos_acumulados, muertes_acumuladas, fecha) %>%
  full_join(Dat %>%
              filter(tipo == "entidad_res") %>%
              filter(fecha > max(Serie_estados$fecha)) %>%
              select(-region_nombre, -tipo) %>%
              mutate(estado = as.vector(estados_lut[region])) %>%
              select(estado, casos_acumulados, muertes_acumuladas, fecha),
            by = c("fecha", "estado"),
            suffix = c("_um", "_res")) %>%
  select(estado, fecha, everything())

# Municipios
Nuevos_municipios <- Dat %>%
  filter(tipo == "municipio_res") %>%
  filter(fecha > max(Serie_municipios$fecha)) %>%
  select(-region_nombre, -tipo) %>%
  mutate(municipio = as.vector(set_names(municipios_lut$X2, municipios_lut$X1)[region])) %>%
  select(municipio, fecha, casos_acumulados, muertes_acumuladas, clave = region) 

# Nacional
Nuevos_nacional <- Dat %>%
  filter(tipo == "entidad_um") %>%
  filter(fecha > max(Serie_nacional$fecha)) %>%
  select(-region_nombre, -tipo) %>%
  mutate(estado = as.vector(estados_lut[region])) %>%
  select(estado, casos_acumulados, muertes_acumuladas, fecha) %>%
  full_join(Dat %>%
              filter(tipo == "entidad_res") %>%
              filter(fecha > max(Serie_nacional$fecha)) %>%
              select(-region_nombre, -tipo) %>%
              mutate(estado = as.vector(estados_lut[region])) %>%
              select(estado, casos_acumulados, muertes_acumuladas, fecha),
            by = c("fecha", "estado"),
            suffix = c("_um", "_res")) %>%
  select(estado, fecha, everything()) %>%
  group_by(fecha) %>%
  summarise(casos_acumulados = sum(casos_acumulados_um, na.rm = TRUE),
            muertes_acumuladas = sum(muertes_acumuladas_um, na.rm = TRUE))

# Juntar
Serie_estados <- Serie_estados %>%
  bind_rows(Nuevos_estados) %>%
  split(.$estado) %>%
  map_dfr(function(d){
    d %>%
      arrange(fecha) %>%
      mutate(casos_nuevos_um = casos_acumulados_um - lag(casos_acumulados_um, 1, default = 0),
             casos_nuevos_res = casos_acumulados_res - lag(casos_acumulados_res, 1),
             muertes_nuevas_um = muertes_acumuladas_um - lag(muertes_acumuladas_um, 1, default = 0),
             muertes_nuevas_res = muertes_acumuladas_res - lag(muertes_acumuladas_res, 1))
  })

Serie_municipios <- Serie_municipios %>%
  bind_rows(Nuevos_municipios) %>%
  split(.$clave) %>%
  map_dfr(function(d){
    d %>%
      arrange(fecha) %>%
      mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1),
             muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1))
  })

Serie_nacional <- Serie_nacional %>%
  bind_rows(Nuevos_nacional) %>%
  mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1, default = 0),
         muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1, default = 0))

# Escribir archivos
Serie_estados %>%
  write_csv(args$serie_estados)
Serie_municipios %>%
  write_csv(args$serie_municipios)
Serie_nacional %>%
  write_csv(args$serie_nacional)

