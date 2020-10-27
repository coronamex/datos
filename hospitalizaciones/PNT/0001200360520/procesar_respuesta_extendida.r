library(tidyverse)

Dat <- read_tsv("~/Descargas/hosp.csv",
                col_types = cols(estado = col_character()))
Dat

Dat <- Dat %>%
  mutate(fecha = parse_date(fecha, format = "%b %d, %Y"),
         fecha2 = parse_date(fecha2, format = "%b %d, %Y")) %>%
  rename(IRAG_GEN_Ocupadas = irag_gen_ocupadas,
         IRAG_GEN_Disponibles = irag_gen_disponibles,
         IRAG_GEN_Total = total_irag_gen,
         IRAG_VENT_Ocupadas = irav_vent_ocupadas,
         IRAG_VENT_Disponibles = irag_vent_disp,
         IRAG_VENT_Total = total_irag_vent) %>%
  # filter(fecha != fecha2)
  select(-fecha2) %>%
  # select(estado) %>% table
  select(-estado, everything(), estado)
Dat


write_tsv(Dat, "serie_tiempo_estados_hosp_irag.tsv")

