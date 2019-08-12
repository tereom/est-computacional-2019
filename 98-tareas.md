
# Tareas {-}



* Las tareas se envían por correo a teresa.ortiz.mancera@gmail.com con título: 
EstComp-TareaXX (donde XX corresponde al número de tarea, 01..). 

* Las tareas deben incluir código y resultados (si conocen [Rmarkdown](https://rmarkdown.rstudio.com) 
es muy conveniente para este propósito).

## Visualización

![](img/manicule.jpg) Tarea. Explora alguna de las bases de datos incluídas


```r
# install.packages("gapminder")
library(gapminder)
gapminder
#> # A tibble: 1,704 x 6
#>    country     continent  year lifeExp      pop gdpPercap
#>    <fct>       <fct>     <int>   <dbl>    <int>     <dbl>
#>  1 Afghanistan Asia       1952    28.8  8425333      779.
#>  2 Afghanistan Asia       1957    30.3  9240934      821.
#>  3 Afghanistan Asia       1962    32.0 10267083      853.
#>  4 Afghanistan Asia       1967    34.0 11537966      836.
#>  5 Afghanistan Asia       1972    36.1 13079460      740.
#>  6 Afghanistan Asia       1977    38.4 14880372      786.
#>  7 Afghanistan Asia       1982    39.9 12881816      978.
#>  8 Afghanistan Asia       1987    40.8 13867957      852.
#>  9 Afghanistan Asia       1992    41.7 16317921      649.
#> 10 Afghanistan Asia       1997    41.8 22227415      635.
#> # … with 1,694 more rows
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; realiza al 
menos $3$ gráficas y explica las relaciones que encuentres. Debes usar lo que 
revisamos en estas notas: al menos una de las gráficas debe ser de páneles, 
realiza una gráfica con datos de México, y (opcional)si lo consideras 
interesante, puedes crear una variable categórica utilizando la función `cut2` 
del paquete Hmisc. 



1. [Stack Overflow dveloper survey results](whttps://insights.stackoverflow.com/survey/2019)
    + [Julia Silge y Jenny Bryan](https://github.com/jennybc/code-smells-and-feels/tree/master/stackoverflow-survey) 
    usaron los resultados para buscar evidencia de educación en 
    computación/programación entre usuarios de R.
    + Se pueden explorar diferencias por género en lenguajes que usan, edad en 
    la que se inició a programar,...
    + ¿Qué ocurre con México?, ¿En qué es distinto a otros países?


```r
# codigo original de Jenny Bryan 
# github.com/jennybc/code-smells-and-feels/blob/master/stackoverflow-survey

library(here)
survey_path <- here("data/developer_survey_2018/survey_results_public.csv")
if (!file.exists(survey_path)) {
  use_directory("data/stackoverflow-survey")
  ## consults Content-Description to get filename
  dl <- usethis:::use_zip(
    url = "https://drive.google.com/uc?export=download&id=1_9On2-nsBQIw3JiY43sWbrF8EjrqrR4U",
    destdir = here("data")
  )
}
```

    + 

