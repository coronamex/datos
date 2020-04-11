library(tidyverse)
# https://github.com/mexicovid19/Mexico-datos
# https://github.com/carranco-sga/Mexico-COVID-19

args <- list(casos_acum_tiempo = "../Mexico-datos/datos/series_de_tiempo/covid19_mex_casos_totales.csv",
             muertes_acum_tiempo = "../Mexico-datos/datos/series_de_tiempo/covid19_mex_muertes.csv",
             # sospechosos_acum_tiempo = "../Mexico-datos/datos/series_de_tiempo/covid19_mex_sospechosos.csv",
             # negativos_acum_tiempr = "../Mexico-datos/datos/series_de_tiempo/covid19_mex_negativos.csv",
             serie_total = "../Mexico-COVID-19/Mexico_COVID19.csv",
             coronamex_serie = "ssa_dge/serie_tiempo_estados_casos.csv",
             lut = "util/dge_LUT.tsv",
             iso_lut = "util/iso_LUT.tsv",
             dir = "ssa_dge/")

# Leer lut
lut <- read_tsv(args$lut, col_names = FALSE)
lut <- set_names(lut$X2, lut$X1)

# Casos
casos_fecha <- read_csv(args$casos_acum_tiempo,
                        col_types = cols(Fecha = col_date(format = "%Y-%m-%d")))
casos_fecha <- casos_fecha %>%
  pivot_longer(-Fecha, names_to = "estado", values_to = "casos_acumulados") %>%
  filter(estado != "México") %>%
  mutate(estado = lut[estado]) %>%
  mutate(fecha = Fecha) %>%
  select(-Fecha)
any(is.na(casos_fecha$estado))

casos_fecha <- casos_fecha %>%
  split(.$estado) %>%
  map_dfr(function(d){
    d %>%
      arrange(fecha) %>%
      mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1, default = 0))
  })


# Muertes
muertes_fecha <- read_csv(args$muertes_acum_tiempo,
                        col_types = cols(Fecha = col_date(format = "%Y-%m-%d")))
muertes_fecha <- muertes_fecha %>%
  pivot_longer(-Fecha, names_to = "estado", values_to = "muertes_acumuladas") %>%
  filter(estado != "México") %>%
  mutate(estado = lut[estado]) %>%
  mutate(fecha = Fecha) %>%
  select(-Fecha)
any(is.na(muertes_fecha$estado))

muertes_fecha <- muertes_fecha %>%
  split(.$estado) %>%
  map_dfr(function(d){
    d %>%
      arrange(fecha) %>%
      mutate(muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1, default = 0))
  })

# Combinar
Dat1 <- casos_fecha %>%
  full_join(muertes_fecha, by = c("estado", "fecha"))
Dat1

Dat1 %>%
  filter(casos_nuevos < 0)
Dat1 %>%
  filter(muertes_nuevas < 0)


### Carranco repo
Dat2 <- read_csv(args$serie_total,
                 col_types = cols(Fecha = col_date(format = "%Y-%m-%d"),
                                  .default = col_number()))
Dat2 <- Dat2 %>%
  select(-ends_with("_S"), -ends_with("_I"), -ends_with("_L"),
         -ends_with("_R"), -starts_with("Pos"),
         -starts_with("Susp"),
         -Neg_rep, -IRAG_Test, -Tested_tot,
         -Recovered, -Deceased) %>%
  mutate(fecha = Fecha) %>%
  select(-Fecha) %>%
  filter(fecha >= "2020-02-28") %>%
  pivot_longer(-fecha) %>%
  mutate(estado = str_remove(name, "_D$")) %>%
  mutate(name = replace(name, str_detect(name, "_D$",negate = TRUE), "casos_acumulados")) %>%
  mutate(name = replace(name, str_detect(name, "_D$"), "muertes_acumuladas")) %>%
  pivot_wider(id_cols = c("fecha", "estado"))
Dat2

iso_lut <- read_tsv(args$iso_lut, col_names = FALSE)
iso_lut <- set_names(iso_lut$X2, iso_lut$X1)
Dat2 <- Dat2 %>%
  mutate(estado = iso_lut[estado])
Dat2
Dat2 <- Dat2 %>%
  split(.$estado) %>%
  map_dfr(function(d){
    d %>%
      arrange(fecha) %>%
      mutate(casos_nuevos = casos_acumulados - lag(casos_acumulados, 1, default = 0)) %>%
      mutate(muertes_nuevas = muertes_acumuladas - lag(muertes_acumuladas, 1, default = 0))
  })
Dat2
Dat2 %>%
  filter(casos_nuevos < 0)
Dat2 %>%
  filter(muertes_nuevas < 0)

# Leer coronamex
Dat3 <- read_csv(args$coronamex_serie,
                 col_types = cols(fecha = col_date(format = "%Y-%m-%d")))
Dat3 %>%
  filter(casos_nuevos < 0)

# CoronaMex y Carranco reportan mismos 2 casos (Chiapas y Zacatecas) de decrecimiento
# de casos. Mexicovid19 tiene más incosistencias.

list.dirs(args$dir, full.names = TRUE, recursive = FALSE)[-1] %>%
  map(function(fecha_dir){
    # fecha_dir <- "ssa_dge/2020-02-28/"
    # fecha_dir <- "ssa_dge/2020-02-29/"
    # fecha_dir <- "ssa_dge/2020-03-15"
    # fecha_dir <- "ssa_dge/2020-03-27"
    # fecha_dir <- "ssa_dge/2020-04-05"
    cat(fecha_dir, "\n")
    fecha_checando <- basename(fecha_dir)
    
    tabla_casos <- file.path(fecha_dir, "tabla_casos_confirmados.csv")
    datos_mapa <- file.path(fecha_dir,  "datos_mapa.csv")
    
    if(file.exists(tabla_casos) && file.exists(datos_mapa)){
      cat("\tsaltar\n")
    }else if(file.exists(tabla_casos)){
      cat("\tfaltan muertes\n")
      d1 <- Dat1 %>%
        filter(fecha == fecha_checando)
      d2 <- Dat2 %>%
        filter(fecha == fecha_checando)
      d3 <- Dat3 %>%
        filter(fecha == fecha_checando)
      
      Dat <- d1 %>%
        full_join(d2, by = c("estado", "fecha"), suffix = c(".d1", ".d2")) %>%
        full_join(d3, by = c("estado", "fecha"), suffix = c("", ".d3")) %>%
        select(-fecha) %>%
        select(estado, starts_with("casos_acumulados"), starts_with("muertes_acumuladas"))
      if(nrow(Dat) != 32)
        stop("ERROR")
      
      Dat <- Dat %>%
        transmute(estado, casos_acumulados = replace(casos_acumulados, is.na(casos_acumulados), 0),
                  muertes_acumuladas = muertes_acumuladas.d2)
      
      archivo <- file.path(fecha_dir, "datos_estado.csv")
      write_csv(Dat, archivo)
      
    }else if(file.exists(datos_mapa)){
      stop("ERROR")
    }else{
      cat("\tfalta todo\n")
      d1 <- Dat1 %>%
        filter(fecha == fecha_checando)
      d2 <- Dat2 %>%
        filter(fecha == fecha_checando)
      Dat <- d1 %>%
        full_join(d2, by = c("estado", "fecha"), suffix = c(".d1", ".d2")) %>%
        select(-fecha) %>%
        select(estado, starts_with("casos_acumulados"), starts_with("muertes_acumuladas"))
        
      if(nrow(Dat) != 32)
        stop("ERROR")
      
      Dat <- Dat %>%
        transmute(estado, casos_acumulados = replace(casos_acumulados.d2, is.na(casos_acumulados.d2), 0),
                  muertes_acumuladas = muertes_acumuladas.d2)
      
      archivo <- file.path(fecha_dir, "datos_estado.csv")
      write_csv(Dat, archivo)
      }
    })
