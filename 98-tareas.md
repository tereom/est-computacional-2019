
# Tareas {-}



* Las tareas se envían por correo a teresa.ortiz.mancera@gmail.com con título: 
EstComp-TareaXX (donde XX corresponde al número de tarea, 01..). 

* Las tareas deben incluir código y resultados (si conocen [Rmarkdown](https://rmarkdown.rstudio.com) 
es muy conveniente para este propósito).

## 1. Instalación y visualización {-}

#### 1. Instala los siguientes paquetes (o colecciones): {-}

* tidyverse de CRAN (`install.packages("tidyverse")`)
* devtools de CRAN (`install.packages("devtools")`)
* gapminder de CRAN (`install.packages("gapminder")`)
* estcomp de GitHUB (debes haber instalado devtools y correr 
`devtools::install_github("tereom/estcomp")`)
* mxmaps **instalarlo es opcional** de [GitHub](https://github.com/diegovalle/mxmaps#installation)


#### 2. Visualización {-}

* Elige un base de datos, recuerda que en la ayuda puedes encontrar más 
información de las variables (`?gapminder`): 
    + gapminder (paquete `gapminder` en CRAN).
    + election_2012 ó election_sub_2012 (paquete `estcomp`).
    + df_edu (paquete `estcomp`).
    + enlacep_2013 o un subconjuto de este (paquete `estcomp`).

* Escribe algunas preguntas que consideres interesantes de los datos.

* Realiza $3$ gráficas buscando explorar las preguntas de arriba y explica las
relaciones que encuentres. Debes usar lo que revisamos en estas notas y al menos
una de las gráficas debe ser de paneles (usando `facet_wrap()` o `facet_grid`).

#### 4. Prueba (en clase)! {-}

Ejercicios basados en ejercicios de @r4ds.

Socrative: https://b.socrative.com/login/student/  
Room: ESTCOMP


```r
library(tidyverse,warn.conflicts = FALSE, quietly = TRUE)
library(gridExtra)

# 1.
one <- ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# 2.
two <- ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy), se = FALSE)

# 3.
three <- ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))
```

<img src="98-tareas_files/figure-html/unnamed-chunk-3-1.png" width="720" style="display: block; margin: auto;" />



```r
# 4. 
four <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "blue"), 
    show.legend = FALSE)

# 5.
five <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "blue", 
    show.legend = FALSE)

# 6. 
six <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy), color = "class", 
    show.legend = FALSE)

# 7.
seven <- ggplot(data = mpg) + 
  geom_point(mapping = aes(x = displ, y = hwy, color = "class"), 
    show.legend = FALSE)
```



<img src="98-tareas_files/figure-html/unnamed-chunk-5-1.png" width="672" style="display: block; margin: auto;" />



```r
eight <- ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) + 
  geom_point() + 
  geom_smooth()

nine <- ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(color = drv)) + 
  geom_smooth(data = select(mpg, displ, hwy), aes(x = displ, y = hwy))

ten <- ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) + 
  geom_point(aes(color = drv)) +
  geom_smooth()

eleven <- ggplot(data = mpg) + 
  geom_point(aes(x = displ, y = hwy, color = drv)) + 
  geom_smooth(aes(x = displ, y = hwy, color = drv))
```

## 2. Transformación de datos {-}

1. Vuelve a instalar el paquete `estcomp` para asegurar que tengas todos los
datos y su documentación: `devtools::install_github("tereom/estcomp")`

2. Usaremos los datos `df_edu`, ve la ayuda para entender sus variables:


```r
library(estcomp)
?df_edu
```

  * ¿Cuál es el municipo con mayor escolaridad promedio (valor de `schoolyrs`)?
    Tip: usa `filter` para quedarte únicamente con `sex` correspondiente a 
    `Total`.
  
  * Crea una `data.frame` que contenga una línea por cada estado y por sexo, con 
  la siguiente información:
    + la escolaridad promedio por estado y sexo (ponderada por la población 
    `pop_15`)
    + la población de cada sexo (mayor a 15 años)
  
  * Crea una variable que indique el porcentaje de la población que cursó al 
  menos educación básica. 
  
  * Enuncia al menos una pregunta que se pueda responder transformando y 
  graficando estos datos. Crea tu(s) gráfica(s).
  
## 3. Unión de tablas y limpieza de datos {-}

Pueden encontrar la versión de las notas de datos limpuis usando `gather()` y 
`spread()` [aquí](https://tereom.github.io/tutoriales/datos_limpios.html.

Trabajaremos con los datos `df_marital`, 

1. ¿Están limpios los datos? en caso de que no
¿qué principio no cumplen?


```r
library(estcomp)
df_marital
#> # A tibble: 29,484 x 14
#>    state_code municipio_code region state_name state_abbr municipio_name
#>    <chr>      <chr>          <chr>  <chr>      <chr>      <chr>         
#>  1 01         001            01001  Aguascali… AGS        Aguascalientes
#>  2 01         001            01001  Aguascali… AGS        Aguascalientes
#>  3 01         001            01001  Aguascali… AGS        Aguascalientes
#>  4 01         001            01001  Aguascali… AGS        Aguascalientes
#>  5 01         001            01001  Aguascali… AGS        Aguascalientes
#>  6 01         001            01001  Aguascali… AGS        Aguascalientes
#>  7 01         001            01001  Aguascali… AGS        Aguascalientes
#>  8 01         001            01001  Aguascali… AGS        Aguascalientes
#>  9 01         001            01001  Aguascali… AGS        Aguascalientes
#> 10 01         001            01001  Aguascali… AGS        Aguascalientes
#> # … with 29,474 more rows, and 8 more variables: sex <chr>,
#> #   age_group <chr>, pop <dbl>, single <dbl>, married <dbl>,
#> #   living_w_partner <dbl>, separated <dbl>, other <dbl>
```

2. Limpia los datos y muestra las primeras y últimas líneas (usa `head()` y 
`tail()`).

3. Filtra para eliminar los casos a total en las variables sexo y edad, calcula 
a nivel nacional cuál es la proporción en cada situación conyugal por grupo de 
edad y sexo. ¿Cómo puedes graficar o presentar los resultados?

4. Regresando a los datos que obtuviste en 2, une la tabla de datos con 
`df_edu`, ¿qué variables se usarán para unir?

## 4. Programación funcional y distribución muestral {-}

1. Descarga la carpeta specdata, ésta contiene 332 archivos csv que almacenan 
información de monitoreo de contaminación en 332 ubicaciones de EUA. Cada 
archivo contiene información de una unidad de monitoreo y el número de 
identificación del monitor es el nombre del archivo. En este ejercicio nos 
interesa unir todas las tablas en un solo data.frame que incluya el 
identificador de las estaciones.

  + La siguiente instrucción descarga los datos si trabajas con proyectos de 
  RStudio, también puedes descargar el zip manualmente.


```r
library(usethis)
use_directory("data") 
use_zip("https://d396qusza40orc.cloudfront.net/rprog%2Fdata%2Fspecdata.zip", 
    destdir = "data")
```

  + Crea un vector con las direcciones de los archivos.  
  + Lee uno de los archivos usando la función `read_csv()` del paquete `readr`.  
  Tip: especifica el tipo de cada columna usando el parámetro `col_types`.  
  + Utiliza la función `map_df()` para iterar sobre el vector con las 
  direcciones de los archivos csv y crea un data.frame con todos los datos, 
  recuerda añadir una columna con el nombre del archivo para poder identificar
  la estación.  
  
2. Consideramos los datos de ENLACE edo. de México 
(`enlace`), y la columna de calificaciones de español 3^o^ de primaria (`esp_3`). 


```r
library(estcomp)
enlace <- enlacep_2013 %>% 
    janitor::clean_names() %>% 
    mutate(id = 1:n()) %>% 
    select(id, cve_ent, turno, tipo, esp_3 = punt_esp_3, esp_6 = punt_esp_6, 
        n_eval_3 = alum_eval_3, n_eval_6 = alum_eval_6) %>% 
    na.omit() %>% 
    filter(esp_3 > 0, esp_6 > 0, n_eval_3 > 0, n_eval_6 > 0, cve_ent == "15")

```


- Selecciona una muestra de tamaño $n = 10, 100, 1000$. Para cada muestra 
calcula media y el error estándar de la media usando el principio del *plug-in*:
$\hat{\mu}=\bar{x}$, y $\hat{se}(\bar{x})=\hat{\sigma}_{P_n}/\sqrt{n}$. Tip:
Usa la función `sample_n()` del paquete `deplyr` para generar las muestras.

- Ahora aproximareos la distribución muestral, para cada tamaño de muestra $n$: 
i) simula $10,000$ muestras aleatorias, ii) calcula la media en cada muestra, 
iii) Realiza un histograma de la distribución muestral de las medias (las medias 
del paso anterior) iv) aproxima el error estándar calculando la desviación 
estándar de las medias del paso ii. Tip: Escribe una función que dependa del 
tamaño de muestra y usa la función `rerun()` del paquete `purrr` para hacer las 
$10,000$ simulaciones.


```r
simula_media <- function(n) {
    
}
medias_10 <- rerun(10000, simula_media(n = 10)) %>% flatten_dbl()
```

- Calcula el error estándar de la media para cada tamaño de muestra usando la
información poblacional (ésta no es una aproximación), usa la fórmula:
$se_P(\bar{x}) = \sigma_P/ \sqrt{n}$.

- ¿Cómo se comparan los errores estándar correspondientes a los distintos 
tamaños de muestra? 
  
