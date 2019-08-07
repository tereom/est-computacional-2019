# Tareas {-}



* Las tareas se envían por correo a teresa.ortiz.mancera@gmail.com con título: 
EstComp-TareaXX (donde XX corresponde al número de tarea, 01..). 

* Las tareas deben incluir código y resultados (si conocen [Rmarkdown](https://rmarkdown.rstudio.com) 
es muy conveniente para este propósito).

# Visualización

1. [Stack Overflo dveloper survey results](whttps://insights.stackoverflow.com/survey/2019)
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

