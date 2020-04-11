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



# Dat1 %>%
#   split(.$fecha) %>%
#   map(function(d, dir = "ssa_dge/"){
#     d <- Dat %>% filter(fecha == "2020-04-04")
#     dir <- "ssa_dge/"
#     
#     d
#     fecha <- unique(d$fecha)
#     fecha_dir <- file.path(dir,fecha)
#     tabla_casos <- file.path(fecha_dir, "tabla_casos_confirmados.csv")
#     datos_mapa <- file.path(fecha_dir, "datos_mapa.csv")
#     if(file.exists(tabla_casos) && file.exists(datos_mapa)){
#       cat("Datos completos en fecha", fecha, "...saltando\n")
#     }else{
#       filename <- file.path(fecha_dir, "datos_estados.csv")
#       # d %>%
#       #   select(estado, casos_acumulados, muertes_acumuladas) %>%
#       #   write_csv(path = filename)
#     }
#   }, dir = args$dir)
