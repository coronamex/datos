#!/usr/bin/env Rscript
library(tidyverse)
library(argparser)

process_arguments <- function(){
  p <- arg_parser(paste("Homogeneizar tablas principales"))

  # Optional arguments
  p <- add_argument(p, "--dir",
                     help = paste("Directorio con tablas."),
                     type = "character",
                     default = "ssa_dge/")
  p <- add_argument(p, "--dge_lut",
                    help = paste("Archivo con tabla LUT para nombres de estados"),
                    type = "character",
                    default = "util/dge_LUT.tsv")
                     
  # Read arguments
  cat("Processing arguments...\n")
  args <- parse_args(p)
  
  # Process arguments
  
  return(args)
}


args <- process_arguments()
# args <- list(dir = "ssa_dge/2020-04-10",
#              dge_lut = "util/dge_LUT.tsv")

# Leer lut de nombres
lut <- read_tsv(args$dge_lut, col_names = FALSE, col_types = cols(.default = col_character()))
lut <- set_names(x = lut$X2, nm = lut$X1)

cat("Procesando", args$dir, "\n")
# Tabla de casos_confirmados
Tab_casos <- read_csv(file.path(args$dir, "tabla_casos_confirmados.csv"),
                      col_types = cols(estado = col_character(),
                                       sexo = col_character(),
                                       edad = col_number(),
                                       fecha_sintomas = col_date(format = "%d/%m/%Y"),
                                       procedencia = col_character(),
                                       fecha_llegada = col_date(format = "%d/%m/%Y")))
stop_for_problems(Tab_casos)
Tab_casos <- Tab_casos %>%
  mutate(estado = str_remove(estado, pattern = "[*]$")) %>%
  mutate(estado = as.vector(lut[estado]))
if(any(is.na(Tab_casos$estado)))
  stop("ERROR: Hay un problema con el nombre de los estados en la tabla de casos confirmados.")
write_csv(Tab_casos, file.path(args$dir, "tabla_casos_confirmados.csv"))

# Datos mapa
if(file.exists(file.path(args$dir, "datos_mapa.csv"))){
  Dat_mapa <- read_csv(file.path(args$dir, "datos_mapa.csv"),
                       col_types = cols(estado = col_character(),
                                        casos_acumulados = col_number(),
                                        negativos_acumulados = col_number(),
                                        sospechosos = col_number(),
                                        muertes_acumuladas = col_number()))
  stop_for_problems(Dat_mapa)
  Dat_mapa <- Dat_mapa %>%
    mutate(estado = as.vector(lut[estado]))
  if(any(is.na(Dat_mapa$estado)))
    stop("ERROR: Hay un problema con el nombre de los estados en la tabla de casos confirmados.")
  write_csv(Dat_mapa, file.path(args$dir, "datos_mapa.csv"))
}else{
  cat("dato_mapa.csv no disponible.\n")
}
