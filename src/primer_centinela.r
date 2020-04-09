library(tidyverse)

Dat <- tibble(totoal_usmer = c(43329,
                               43113,
                               45420,
                               42072,
                               48679,
                               33500),
              posibles_usmer = c(2472,
                                 2597,
                                 2465,
                                 2919,
                                 4081,
                                 5215),
              pruebas_usmer = c(961,
                                1034,
                                991,
                                1423,
                                2360,
                                3181),
              totales_nacional = c(583545,
                                   561882,
                                   609935,
                                   550483,
                                   652335,
                                   488071),
              posibles_nacional = c(42259,
                                    43534,
                                    40680,
                                    48186,
                                    69718,
                                    90678),
              semana = 8:13,
              positivos_usmer = c(3,3,27,167,295,544),
              estimados = c(133,131,751,4718,7566,13221))

ggplot(Dat, aes(positivos_usmer, estimados)) +
  geom_point() +
  scale_x_log10() +
  scale_y_log10() +
  # scale_y_log10(limits = c(1,100000)) +
  geom_smooth(method = "lm")
predict(lm(estimados ~ positivos_usmer, Dat))


Dat
GGally::ggpairs(Dat)
