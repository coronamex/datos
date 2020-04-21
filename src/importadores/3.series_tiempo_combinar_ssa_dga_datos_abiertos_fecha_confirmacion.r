library(tidyverse)

args <- list(dir = "datos_abiertos/",
             estados_lut = "util/estados_lut_datos_abiertos.csv",
             municipios_lut = "util/municipios_lut_datos_abiertos.csv",
             dir_salida = "datos_abiertos/",
             serie_ssa_dge_casos = "ssa_dge_2020-04-19/serie_tiempo_estados_casos_2020-04-18.csv",
             serie_ssa_dge_muertes = "ssa_dge_2020-04-19/serie_tiempo_estados_muertes_2020-04-18.csv")


estados_lut <- read_csv(args$estados_lut,
                        col_names = FALSE,
                        col_types = cols(.default = col_character()))
stop_for_problems(estados_lut)
estados_lut <- set_names(estados_lut$X2, estados_lut$X1)
municipios_lut <- read_csv(args$municipios_lut,
                           col_names = FALSE,
                           col_types = cols(.default = col_character()))
stop_for_problems(municipios_lut)

# Serie tiempo casos confirmados estados
Dat <- list.dirs(args$dir, full.names = TRUE, recursive = FALSE) %>%
  map_dfr(function(fecha_dir){
    # fecha_dir <- list.dirs(args$dir, full.names = TRUE, recursive = FALSE)[1]
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
          mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1)) %>%
          mutate(region_nombre = region_nombre,
                 muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1))
      }, .id = "region") %>%
      mutate(region_nombre = region_nombre)
  }, .id = "tipo")
Dat

# Comparar estados
dge_estados_casos <- read_csv(args$serie_ssa_dge_casos,
                        col_types = cols(estado = col_character(),
                                         casos_acumulados = col_number(),
                                         fecha = col_date(format = "%Y-%m-%d"),
                                         casos_nuevos = col_number()))
stop_for_problems(dge_estados_casos)
dge_estados_muertes <- read_csv(args$serie_ssa_dge_muertes,
                                col_types = cols(estado = col_character(),
                                                 muertes_acumuladas = col_number(),
                                                 fecha = col_date(format = "%Y-%m-%d"),
                                                 muertes_nuevas = col_number()))
stop_for_problems(dge_estados_muertes)
dge_estados <- dge_estados_casos %>%
  full_join(dge_estados_muertes,
            by = c("estado", "fecha")) %>%
  mutate(muertes_acumuladas = replace_na(muertes_acumuladas, 0),
         muertes_nuevas = replace_na(muertes_nuevas, 0))

dat_estados <- Dat %>%
  filter(tipo == "entidad_um") %>%
  mutate(estado = as.vector(estados_lut[region])) %>%
  select(estado, casos_acumulados, fecha, casos_nuevos, muertes_acumuladas, muertes_nuevas)

Res <- dge_estados %>%
  full_join(dat_estados, by = c("estado", "fecha"), suffix = c(".dge", ".da")) %>%
  split(.$estado) %>%
  map_dfr(function(d){
    # d <- dge_estados %>%
    #   full_join(dat_estados, by = c("estado", "fecha"), suffix = c(".dge", ".da")) %>%
    #   filter(estado == "Aguascalientes")
    # d
    d %>%
      pmap_dfr(function(estado, casos_acumulados.dge, fecha, casos_nuevos.dge,
                        muertes_acumuladas.dge, muertes_nuevas.dge,
                        casos_acumulados.da, casos_nuevos.da,
                        muertes_acumuladas.da, muertes_nuevas.da){
        if(is.na(casos_acumulados.dge) && is.na(casos_acumulados.da)){
          cat(estado,"\n")
          stop("ERROR")
        }else if(is.na(casos_acumulados.dge)){
          acum <- casos_acumulados.da
        }else if(is.na(casos_acumulados.da)){
          acum <- casos_acumulados.dge
        }else if (casos_acumulados.dge != casos_acumulados.da){
          cat("diferencias casos", estado, as.character(fecha), casos_acumulados.dge, casos_acumulados.da, "\n")
          # stop("ERROR")
          acum <- casos_acumulados.da
        }else{
          acum <- casos_acumulados.da
        }
        
        if(is.na(muertes_acumuladas.dge) && is.na(muertes_acumuladas.da)){
          cat(estado,"\n")
          stop("ERROR")
        }else if(is.na(muertes_acumuladas.dge)){
          acum_m <- muertes_acumuladas.da
        }else if(is.na(muertes_acumuladas.da)){
          acum_m <- muertes_acumuladas.dge
        }else if (muertes_acumuladas.dge != muertes_acumuladas.da){
          cat("diferencias muertes", estado, as.character(fecha), muertes_acumuladas.dge, muertes_acumuladas.da, "\n")
          # stop("ERROR")
          acum_m <- muertes_acumuladas.da
        }else{
          acum_m <- muertes_acumuladas.da
        }
          
        
        tibble(estado = estado,
               casos_acumulados = acum,
               muertes_acumuladas = acum_m,
               fecha = fecha)
      }) %>%
      arrange(fecha) %>%
      mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1, default = 0),
             muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1, default = 0))
  })

# Unir entidad_res entidad_um
Res_estados <- Res %>%
  full_join(Dat %>%
              filter(tipo == "entidad_res") %>%
              mutate(estado = as.vector(estados_lut[region])) %>%
              select(estado, casos_acumulados, muertes_acumuladas, fecha, casos_nuevos, muertes_nuevas),
            by = c("estado", "fecha"),
            suffix = c("_um", "_res")) %>%
  select(estado, fecha, starts_with("casos_acumulados"), starts_with("muertes_acumuladas"),
         starts_with("casos_nuevos"), starts_with("muertes_nuevas"))
Res_estados %>%
  write_csv("datos_abiertos/serie_tiempo_estados_fecha_confirmacion.csv")

Res_mun <- Dat %>%
  filter(tipo == "municipio_res") %>%
  mutate(municipio = as.vector(set_names(municipios_lut$X2, municipios_lut$X1)[region])) %>%
  select(municipio, fecha, casos_acumulados, muertes_acumuladas, casos_nuevos, muertes_nuevas, clave = region)
Res_mun %>%
  write_csv("datos_abiertos/serie_tiempo_municipios_fecha_confirmacion.csv")

Res_nac <- Res_estados %>%
  group_by(fecha) %>%
  summarise(casos_acumulados = sum(casos_acumulados_um, na.rm = TRUE),
            muertes_acumuladas = sum(muertes_acumuladas_um, na.rm = TRUE)) %>%
  mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1, default = 0),
         muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1, default = 0)) 
Res_nac %>%
  write_csv("datos_abiertos/serie_tiempo_nacional_fecha_confirmacion.csv")

