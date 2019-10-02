
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

### Solución + bootstrap {-}

Presentamos la solución del ejercicio y agregamos como haríamos con bootsrtap.

Suponemos que me interesa hacer inferencia del promedio de las 
calificaciones de los estudiantes de tercero de primaria en el Estado de México.

En este ejercicio planteamos $3$ escenarios (que simulamos): 1) que tengo una 
muestra de tamaño $10$, 2) que tengo una muestra de tamaño $100$, y 3) que tengo una 
muestra de tamaño $1000$. 

- Selección de muestras:


```r
set.seed(373783326)
muestras <- tibble(tamanos = c(10, 100, 1000)) %>% 
    mutate(muestras = map(tamanos, ~sample(enlace$esp_3, size = .)))
```

Ahora procedemos de manera *usual* en estadística (usando fórmulas y no 
simulación), estimo la media de la muestra con el estimador *plug-in* 
$$\bar{x}={1/n\sum x_i}$$ 
y el error estándar de $\bar{x}$ con el estimador *plug-in* 
$$\hat{se}(\bar{x}) =\bigg\{\frac{1}{n^2}\sum_{i=1}^n(x_i-\bar{x})^2\bigg\}^{1/2}$$

- Estimadores *plug-in*:

```r
se_plug_in <- function(x){
    x_bar <- mean(x)
    n_x <- length(x)
    var_x <- 1 / n_x ^ 2 * sum((x - x_bar) ^ 2)
    sqrt(var_x)
}
muestras_est <- muestras %>% 
    mutate(
        medias = map_dbl(muestras, mean), 
        e_estandar_plug_in = map_dbl(muestras, se_plug_in)
    )
muestras_est
#> # A tibble: 3 x 4
#>   tamanos muestras      medias e_estandar_plug_in
#>     <dbl> <list>         <dbl>              <dbl>
#> 1      10 <dbl [10]>      602.              19.3 
#> 2     100 <dbl [100]>     553.               6.54
#> 3    1000 <dbl [1,000]>   552.               1.90
```

Ahora, recordemos que la distribución muestral es la distribución de una
estadística, considerada como una variable aleatoria. Usando esta definción 
podemos aproximarla, para cada tamaño de muestra, simulando:  

1) simulamos muestras de tamaño $n$ de la población,   
2) calculamos la estadística de interés (en este caso $\bar{x}$),  
3) vemos la distribución de la estadística a lo largo de simulaciones.

- Histogramas de distribución muestral y aproximación de errores estándar con 
simulación 


```r
muestras_sims <- muestras_est %>%
    mutate(
        sims_muestras = map(tamanos, ~rerun(10000, sample(enlace$esp_3, 
            size = ., replace = TRUE))), 
        sims_medias = map(sims_muestras, ~map_dbl(., mean)), 
        e_estandar_aprox = map_dbl(sims_medias, sd)
        )
sims_medias <- muestras_sims %>% 
    select(tamanos, sims_medias) %>% 
    unnest(sims_medias) 

ggplot(sims_medias, aes(x = sims_medias)) +
    geom_histogram(binwidth = 2) +
    facet_wrap(~tamanos, nrow = 1) +
    theme_minimal()
```

<img src="98-tareas_files/figure-html/unnamed-chunk-13-1.png" width="672" height="350px" style="display: block; margin: auto;" />

Notamos que la variación en la distribución muestral decrece conforme aumenta
el tamaño de muestra, esto es esperado pues el error estándar de una media 
es $\sigma_P / \sqrt{n}$, y dado que en este ejemplo estamos calculando la media 
para la misma población el valor poblacional $\sigma_P$ es constante y solo 
cambia el denominador.

Nuestros valores de error estándar con simulación están en la columna 
`e_estandar_aprox`:


```r
muestras_sims %>% 
    select(tamanos, medias, e_estandar_plug_in, e_estandar_aprox)
#> # A tibble: 3 x 4
#>   tamanos medias e_estandar_plug_in e_estandar_aprox
#>     <dbl>  <dbl>              <dbl>            <dbl>
#> 1      10   602.              19.3             18.9 
#> 2     100   553.               6.54             5.92
#> 3    1000   552.               1.90             1.87
```

En este ejercicio estamos simulando para examinar las distribuciones muestrales
y para ver que podemos aproximar el error estándar de la media usando 
simulación; sin embargo, dado que en este caso hipotético conocemos la varianza 
poblacional y la fórmula del error estándar de una media, por lo que podemos 
calcular el verdadero error estándar para una muestra de cada tamaño.

- Calcula el error estándar de la media para cada tamaño de muestra usando la
información poblacional:


```r
muestras_sims_est <- muestras_sims %>% 
    mutate(e_estandar_pob = sd(enlace$esp_3) / sqrt(tamanos))
muestras_sims_est %>% 
    select(tamanos, e_estandar_plug_in, e_estandar_aprox, e_estandar_pob)
#> # A tibble: 3 x 4
#>   tamanos e_estandar_plug_in e_estandar_aprox e_estandar_pob
#>     <dbl>              <dbl>            <dbl>          <dbl>
#> 1      10              19.3             18.9           18.7 
#> 2     100               6.54             5.92           5.93
#> 3    1000               1.90             1.87           1.87
```

En la tabla de arriba podemos comparar los $3$ errores estándar que calculamos, 
recordemos que de estos $3$ el *plug-in* es el único que podríamos obtener en 
un escenario real pues los otros dos los calculamos usando la población. 

Una alternativa al estimador *plug-in* del error estándar es usar *bootstrap* 
(en muchos casos no podemos calcular el error estándar *plug-in* por falta de 
fórmulas) pero podemos usar *bootstrap*: utilizamos una 
estimación de la distribución poblacional y calculamos el error estándar 
bootstrap usando simulación. Hacemos el mismo procedimiento que usamos para 
calcular *e_estandar_apox* pero sustituimos la distribución poblacional por la 
distriución empírica. Hagámoslo usando las muestras que sacamos en el primer 
paso:


```r
muestras_sims_est_boot <- muestras_sims_est %>% 
    mutate(
        sims_muestras_boot = map2(muestras, tamanos,
            ~rerun(10000, sample(.x, size = .y, replace = TRUE))), 
        sims_medias_boot = map(sims_muestras_boot, ~map_dbl(., mean)), 
        e_estandar_boot = map_dbl(sims_medias_boot, sd)
        )
muestras_sims_est_boot
#> # A tibble: 3 x 11
#>   tamanos muestras medias e_estandar_plug… sims_muestras sims_medias
#>     <dbl> <list>    <dbl>            <dbl> <list>        <list>     
#> 1      10 <dbl [1…   602.            19.3  <list [10,00… <dbl [10,0…
#> 2     100 <dbl [1…   553.             6.54 <list [10,00… <dbl [10,0…
#> 3    1000 <dbl [1…   552.             1.90 <list [10,00… <dbl [10,0…
#> # … with 5 more variables: e_estandar_aprox <dbl>, e_estandar_pob <dbl>,
#> #   sims_muestras_boot <list>, sims_medias_boot <list>,
#> #   e_estandar_boot <dbl>
```

Graficamos los histogramas de la distribución bootstrap para cada muestra.


```r
sims_medias_boot <- muestras_sims_est_boot %>% 
    select(tamanos, sims_medias_boot) %>% 
    unnest(sims_medias_boot) 

ggplot(sims_medias_boot, aes(x = sims_medias_boot)) +
    geom_histogram(binwidth = 4) +
    facet_wrap(~tamanos, nrow = 1) +
    theme_minimal()
```

<img src="98-tareas_files/figure-html/unnamed-chunk-17-1.png" width="672" height="350px" style="display: block; margin: auto;" />

Y la tabla con todos los errores estándar quedaría:


```r
muestras_sims_est_boot %>% 
    select(tamanos, e_estandar_boot, e_estandar_plug_in, e_estandar_aprox, 
        e_estandar_pob)
#> # A tibble: 3 x 5
#>   tamanos e_estandar_boot e_estandar_plug_… e_estandar_aprox e_estandar_pob
#>     <dbl>           <dbl>             <dbl>            <dbl>          <dbl>
#> 1      10           19.3              19.3             18.9           18.7 
#> 2     100            6.53              6.54             5.92           5.93
#> 3    1000            1.89              1.90             1.87           1.87
```

Observamos que el estimador bootstrap del error estándar es muy similar al 
estimador plug-in del error estándar, esto es esperado pues se calcularon con la 
misma muestra y el error estándar *bootstrap* converge al *plug-in* conforme 
incrementamos el número de muestras *bootstrap*.


  
## 5. Bootstrap conteo {-}

**Conteo rápido**

En México, las elecciones tienen lugar un domingo, los resultados oficiales 
del proceso se presentan a la población una semana después. A fin de evitar 
proclamaciones de victoria injustificadas durante ese periodo el INE organiza un 
conteo rápido.
El conteo rápido es un procedimiento para estimar, a partir de una muestra 
aleatoria de casillas, el porcentaje de votos a favor de los candidatos 
en la elección. 

En este ejercicio deberás crear intervalos de confianza para la proporción de
votos que recibió cada candidato en las elecciones de 2006. La inferencia se 
hará a partir de una muestra de las casillas similar a la que se utilizó para el 
conteo rápido de 2006.

El diseño utilizado es *muestreo estratificado simple*, lo que quiere decir que:

i) se particionan las casillas de la pablación en estratos (cada casilla
pertenece a exactamente un estrato), y 

ii) dentro de cada estrato se usa *muestreo aleatorio* para seleccionar las 
casillas que estarán en la muestra. 

En este ejercicio (similar al conteo rápido de 2006):

* Se seleccionó una muestra de $7,200$ casillas

* La muestra se repartió a lo largo de 300 estratos. 

* La tabla `strata_sample_2006` contiene en la columna $N$ el número total de 
casillas en el estrato y en $n$ el número de casillas que se seleccionaron en la 
muestra, para cada estrato:


```r
library(estcomp)
strata_sample_2006
#> # A tibble: 300 x 3
#>    stratum     n     N
#>      <dbl> <int> <int>
#>  1       1    20   369
#>  2       2    23   420
#>  3       3    24   440
#>  4       4    31   570
#>  5       5    29   528
#>  6       6    37   664
#>  7       7    26   474
#>  8       8    21   373
#>  9       9    25   457
#> 10      10    24   430
#> # … with 290 more rows
```

* La tabla `sample_2006` en el paquete `estcomp` (vuelve a instalar de ser 
necesario) contiene para cada casilla:
    + el estrato al que pertenece: `stratum`
    + el número de votos que recibió cada partido/coalición: `pan`, `pri_pvem`, 
    `panal`, `prd_pt_convergencia`, `psd` y la columna `otros` indica el 
    número de votos nulos o por candidatos no registrados.
    + el total de votos registrado en la casilla: `total`.


```r
sample_2006
#> # A tibble: 7,200 x 11
#>    polling_id stratum edo_id rural pri_pvem   pan panal prd_pt_conv   psd
#>         <int>   <dbl>  <int> <dbl>    <int> <int> <int>       <int> <int>
#>  1      74593     106     16     1       47    40     0          40     0
#>  2     109927     194     27     0      131    10     0         147     1
#>  3     112039     199     28     0       51    74     2          57     2
#>  4      86392     141     20     1      145    64     2         139     1
#>  5     101306     176     24     0       51   160     0          64    14
#>  6      86044     140     20     1      150    20     0         166     1
#>  7      56057      57     15     1      117   119     2          82     0
#>  8      84186     128     19     0      118   205     8          73     9
#>  9      27778     283      9     0       26    65     5         249     7
#> 10      29892     289      9     0       27    32     0         338    14
#> # … with 7,190 more rows, and 2 more variables: otros <int>, total <int>
```

Una de las metodolgías de estimación, que se usa en el conteo rápido, es 
*estimador de razón* y se contruyen intervalos de 95% de confianza usando el 
método normal con error estándar bootstrap. En este ejercicio debes construir 
intervalos usando este procedimiento.

Para cada candidato:

1. Calcula el estimador de razón combinado, para muestreo estratificado la 
fórmula es:

$$\hat{p}=\frac{\sum_h \frac{N_h}{n_h} \sum_i Y_{hi}}{\sum_h \frac{N_h}{n_h} \sum_i X_{hi}}$$
donde:

* $\hat{p}$ es la estimación de la proporción de votos que recibió el candidato
en la elección.

* $Y_{hi}$ es el número total de votos que recibió el candidato
en la $i$-ésima casillas, que pertence al $h$-ésimo estrato.

* $X_{hi}$ es el número total de votos en la $i$-ésima casilla, que pertence al 
$h$-ésimo estrato. 

* $N_h$ es el número total de casillas en el $h$-ésimo estrato.

* $n_h$ es el número de casillas del $h$-ésimo estrato que se seleccionaron en 
la muestra.

2. Utiliza **bootstrap** para calcular el error estándar, y reporta tu 
estimación del error.
    + Genera 1000 muestras bootstrap.
    + Recuerda que las muestras bootstrap tienen que tomar en cuenta la 
    metodología que se utilizó en la selección de la muestra original, en este
    caso, lo que implica es que debes tomar una muestra aleatoria independient
    dentro de cada estrato.

3. Construye un intervalo del 95% de confianza utilizando el método normal.

Repite para todos los partidos (y la categoría otros). Reporta tus intervalos
en una tabla. 

## Respuesta ejercicios clase {-}

* Considera el coeficiente de correlación muestral entre la 
calificación de $y=$esp_3 y la de $z=$esp_6. ¿Qué tan 
precisa es esta estimación? Calcula el estimador plug-in y el error estándar 
bootstrap.


```r
library(estcomp)
# universo: creamos datos de ENLACE estado de México
enlace <- enlacep_2013 %>% 
    janitor::clean_names() %>% 
    mutate(id = 1:n()) %>% 
    select(id, cve_ent, turno, tipo, esp_3 = punt_esp_3, esp_6 = punt_esp_6, 
        n_eval_3 = alum_eval_3, n_eval_6 = alum_eval_6) %>% 
    na.omit() %>% 
    filter(esp_3 > 0, esp_6 > 0, n_eval_3 > 0, n_eval_6 > 0, cve_ent == "15")
glimpse(enlace)
set.seed(16021)
n <- 300
# muestra
enlace_muestra <- sample_n(enlace, n)

# estimador plug-in
theta_hat <- cor(enlace_muestra$esp_3, enlace_muestra$esp_6)

boot_reps <- function(){
    muestra_boot <- sample_frac(enlace_muestra, size = 1, replace = TRUE)
    cor(muestra_boot$esp_3, muestra_boot$esp_6)
}
# error estandar bootstrap
replicaciones <- rerun(1000, boot_reps()) %>% flatten_dbl()
sd(replicaciones)
```


* Varianza sesgada con datos spatial.


```r
library(bootstrap)

rep_bootstrap <- function() {
  boot_sample <- sample(spatial$A, replace = TRUE)
  boot_replication <- var_sesgada(boot_sample)
}
theta_hat <- var_sesgada(spatial$A)
reps_boot <- rerun(5000, rep_bootstrap()) %>% flatten_dbl()
qplot(reps_boot)
sd_spatial <- sd(reps_boot)
# Normal
theta_hat - 2 * sd_spatial
theta_hat + 2 * sd_spatial
# t
theta_hat + qt(0.025, 25) * sd_spatial
theta_hat + qt(0.975, 25) * sd_spatial
# Percentiles
quantile(reps_boot, probs = c(0.025, 0.975))
```



## 6. Más bootstrap {-}

1. Consideramos la siguiente muestra de los datos de ENLACE:


```r
library(estcomp)
set.seed(1983)
enlace_sample <- enlacep_2013 %>% 
    janitor::clean_names() %>% 
    mutate(id = 1:n()) %>% 
    select(id, cve_ent, turno, tipo, mat_3 = punt_mat_3, 
        n_eval_3 = alum_eval_3) %>% 
    na.omit() %>% 
    filter(mat_3 > 0, n_eval_3 > 0) %>% 
    group_by(cve_ent) %>% 
    sample_frac(size = 0.1) %>% 
    ungroup()
```

  - Selecciona el subconjunto de datos de Chiapas (clave de entidad 07):
    
    + Calcula el estimador plug-in para la mediana de las calificaciones de 
  matemáticas (en Chiapas).
  
    + Calcula el estimador bootstrap del error estándar y construye un intrvalo 
    de confianza normal. Debes 1) tomar muestras bootstrap con reemplazo del 
    subconjunto de datos de Chiapas, 2) calcular la mediana en cada una de las 
    muestras y 3) calcular la desviación estándar de las medianas de 2).

  - Repite los pasos anteriores para la Ciudad de México (clave de entidad 09).
  
  - Compara los intervalos de confianza.

2. Intervalos de confianza. En este ejercicio compararemos distintos intervalos
de confianza para las medias de una exponencial

  + Simula una muestra de tamaño 40 de una distribución exponencial(1/2).
  
  + Calcula el estimador *plug-in*.
  
  + Calcula intervalos: normal, de percentiles y $BC_a$, presentalos en una
  tabla (para los $BC_a$ usa la función `boot.ci()` del paquete `boot`.
  
  + Repite los pasos anteriores 200 veces y grafica los intervalos, ¿cómo se 
  comparan?


```r
library(boot)
sim_exp <- rexp(40, 1/2)
my_mean <- function(x, ind) mean(x[ind])
boot_sim_exp <- boot(sim_exp, my_mean, R = 10000)
ints <- boot.ci(boot_sim_exp, type = c("norm", "perc", "bca"))
```





## EXAMEN PARCIAL {-}

**Entrega:** 7 de octubre antes de las 16:00 horas, por correo electrónico.

**Instrucciones:**

* Resuelve todas las preguntas, tus respuestas deben ser claras y debes explicar 
los resultados, incluye también tus procedimientos/código de manera ordenada, 
el código comentado.

* Se evaluará la presentación de resultados (calidad de las gráficas, tablas, 
...), revisa la sección de teoría de visualización en las notas.

* Se puede realizar individual o en parejas, en el caso de parejas envíen una 
sola respuesta con el nombre de ambos.

* Si tienes preguntas puedes escribirlas en [este documento](https://docs.google.com/document/d/1hUZOtGkd8NOxVk4cjQr_0b5Z2XBl3uP_oOb96356Vf0/edit?usp=sharing), será el único medio para resolver dudas del examen (**no 
correos**).

* El examen se puede entregar después de la fecha establecida, sin embargo habrá 
una penalización de un punto (sobre 10) por cada día tarde.


#### 1. Tablas de conteos y bootstrap {-}

En la sección de visualización vimos un ejemplo de tabla de perfiles (ver
sub-sección de [tinta de datos](https://tereom.github.io/est-computacional-2019/tinta-de-datos.html)).

En este ejercicio construiremos intervalos de confianza para una tabla de 
perfiles usando bootstrap. Usaremos los datos de tomadores de te (del paquete 
@factominer):


```r
library(FactoMineR)
data(tea)
tea <- tea %>% 
  as_tibble %>% 
  select(how, price, sugar)
```

Nos interesa ver qué personas compran té suelto (`unpacked`), y de qué tipo 
(`Tea`). Empezamos por ver las proporciones que compran té según su empaque (en 
bolsita o suelto):


how                     n    %
-------------------  ----  ---
tea bag               170   57
tea bag+unpackaged     94   31
unpackaged             36   12

La tabla de arriba es poco informativa, buscamos comparar grupos, por ejemplo, 
queremos investigar si hay diferencias en los patrones de compra (en términos de 
precio o marca) dependiendo del tipo de té que consumen. En la siguiente tabla
leemos, por ejemplo, que de los compradores de te suelto (`unpackaged`) el 56%
de las compras corresponden a té fino (`upscale`).

<table class="table table-striped table-hover table-condensed table-responsive" style="font-size: 15px; width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> price </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> tea bag </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> tea bag+unpackaged </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> unpackaged </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> p_branded </td>
   <td style="text-align:right;"> 41 </td>
   <td style="text-align:right;"> 21 </td>
   <td style="text-align:right;"> 14 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_cheap </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_private label </td>
   <td style="text-align:right;"> 9 </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 3 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_unknown </td>
   <td style="text-align:right;"> 6 </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_upscale </td>
   <td style="text-align:right;"> 8 </td>
   <td style="text-align:right;"> 20 </td>
   <td style="text-align:right;"> 56 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_variable </td>
   <td style="text-align:right;"> 32 </td>
   <td style="text-align:right;"> 52 </td>
   <td style="text-align:right;"> 25 </td>
  </tr>
</tbody>
</table>

Para facilitar la comparación podemos calcular *perfiles columna*. Comparamos 
cada una de las columnas con la columna marginal (la tabla de tipo de estilo de té):



<table class="table table-hover table-condensed" style="width: auto !important; margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;"> price </th>
   <th style="text-align:left;"> tea bag </th>
   <th style="text-align:left;"> tea bag+unpackaged </th>
   <th style="text-align:left;"> unpackaged </th>
   <th style="text-align:right;"> promedio </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> p_private label </td>
   <td style="text-align:left;"> <span style="     color: black !important;">0.72</span> </td>
   <td style="text-align:left;"> <span style="     color: lightgray !important;">-0.22</span> </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-0.49</span> </td>
   <td style="text-align:right;"> 5 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_unknown </td>
   <td style="text-align:left;"> <span style="     color: black !important;">0.72</span> </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-0.72</span> </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-1</span> </td>
   <td style="text-align:right;"> 4 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_branded </td>
   <td style="text-align:left;"> <span style="     color: black !important;">0.62</span> </td>
   <td style="text-align:left;"> <span style="     color: lightgray !important;">-0.16</span> </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-0.45</span> </td>
   <td style="text-align:right;"> 25 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_cheap </td>
   <td style="text-align:left;"> <span style="     color: black !important;">0.3</span> </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-0.53</span> </td>
   <td style="text-align:left;"> <span style="     color: lightgray !important;">0.23</span> </td>
   <td style="text-align:right;"> 2 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_variable </td>
   <td style="text-align:left;"> <span style="     color: lightgray !important;">-0.12</span> </td>
   <td style="text-align:left;"> <span style="     color: black !important;">0.44</span> </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-0.31</span> </td>
   <td style="text-align:right;"> 36 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> p_upscale </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-0.71</span> </td>
   <td style="text-align:left;"> <span style="     color: red !important;">-0.28</span> </td>
   <td style="text-align:left;"> <span style="     color: black !important;">0.98</span> </td>
   <td style="text-align:right;"> 28 </td>
  </tr>
</tbody>
</table>

Leemos esta tabla como sigue: por ejemplo, los compradores de té suelto 
(`unpacked`) compran té fino (`upscale`) a una tasa casi el doble (0.98) que el 
promedio. 

También podemos graficar como:

<img src="98-tareas_files/figure-html/unnamed-chunk-31-1.png" width="576" style="display: block; margin: auto;" />

**Observación**: hay dos maneras de construir la columna promedio: tomando los 
porcentajes sobre todos los datos, o promediando los porcentajes de las 
columnas como en este ejemplo.

1. Utiliza bootstrap para crear intervalos de confianza sobre los perfiles de 
la última tabla.

2. Modifica la última gráfica para representar los intervalos de confianza.

3. Comenta tus observaciones.


#### 2. Cuantificando el error Monte Carlo {-}

Recordemos que ante la pregunta ¿cuántas muestras bootstrap se necesitan?
el error que podemos disminuir al aumentar el número de replicaciones es el 
error de Monte Carlo, y una manera de cuantificarlo es haciendo bootstrap del
bootstrap.

Retomemos el ejemplo de la media de las calificaciones de ENLACE de español
3o de primaria en el estado de México. Nos interesa la media de las 
calificaciones y usaremos el estimador *plug-in*.


```r
library(estcomp)
# universo
enlace <- enlacep_2013 %>% 
    janitor::clean_names() %>% 
    mutate(id = 1:n()) %>% 
    select(id, cve_ent, turno, tipo, esp_3 = punt_esp_3, esp_6 = punt_esp_6, 
        n_eval_3 = alum_eval_3, n_eval_6 = alum_eval_6) %>% 
    na.omit() %>% 
    filter(esp_3 > 0, esp_6 > 0, n_eval_3 > 0, n_eval_6 > 0, cve_ent == "15")
set.seed(16021)
n <- 300
# muestra
enlace_muestra <- sample_n(enlace, n) %>% 
    mutate(clase = "muestra")
```

1. Crea un intervalo del 90% para $\hat{\theta}$ usando los percentiles de la 
distribución bootstrap, y $B=100$ replicaciones.

2. Podemos estimar el error estándar de Monte Carlo de los extremos de los 
intervalos (percentiles 0.05 y 0.95) haciendo bootstrap de la distribución 
bootstrap:
  + Selecciona muestras con reemplazo de tamaño $B$ de la distribución bootstrap,  
  + Calcula los percentiles de interés (0.05 y 0.95),  
  + Calcula la desviación estándar de los percentiles (una para cada extremo), 
  esta será tu aproximación al error de Monte Carlo

3. ¿Cuál es el error estándar de Monte Carlo con $B = 100, 1000, 10000$ 
replicaciones para cada extremo del intervalo de percentiles?

#### 3. Cobertura de intervalos de confianza {-}

En este problema realizarás un ejercicio de simulación para comparar la 
exactitud de distintos intervalos de confianza. Simularás muestras de  
una distribución Poisson con parámetro $\lambda=2.5$ y el estadístico de interés  
es $\theta=exp(-2\lambda)$.

Sigue el siguiente proceso:

i) Genera una muestra aleatoria de tamaño $n=60$ con distribución 
$Poisson(\lambda)$, parámetro $\lambda=2.5$ (en R usa la función `rpois()`).

ii) Genera $10,000$ muestras bootstrap y calcula intervalos de confianza del 
95\% para $\hat{\theta}$ usando 1) el método normal, 2) percentiles y 3) $BC_a$.

iii) Revisa si el intervalo de confianza contiene el verdadero valor del 
parámetro ($\theta=exp(-2\cdot2.5)$), en caso de que no lo contenga registra si 
falló por la izquierda (el límite inferior $exp(-2.5*\lambda)$) o falló por la 
derecha (el límite superior $exp(-2.5*\lambda)$).

a) Repite el proceso descrito 1000 veces y llena la siguiente tabla:

<div class="mi-tabla">
Método     | \% fallo izquierda   | \% fallo derecha  | Cobertura | Longitud promedio
-----------|----------------------|-------------------|-----------|------------ 
Normal     |                      |                   |           |
Percentiles|                      |                   |           |
BC_a       |                      |                   |           |
</div>

La columna cobertura es una estimación de la cobertura del intervalo basada en 
las simulaciones, para calcularla simplemente escribe el porcentaje de los 
intervalos que incluyeron el verdadero valor del parámetro. La longitud promedio
es la longitud promedio de los intervalos de confianza bajo cada método.

b) Realiza una gráfica de páneles, en cada panel mostrarás los resultados de 
uno de los métodos (normal, percentiles y BC_a), en el vertical 
graficarás los límites de los intervalos.

c) Repite los incisos a) y b) seleccionando muestras de tamaño $300$.

Nota: Un ejemplo en donde la cantidad $P(X=0)^2 = e^{-\lambda}$ es de interés 
es como sigue, las llamadas telefónicas a un conmutador se modelan con 
un proceso Poisson y $\lambda$ es el número promedio de llamadas por minuto, 
entonce $e^{- \lambda}$ es la probabilidad de que no se reciban llamadas en 
$1$ minuto.

#### 4. Cobertura en la práctica {-}

En el caso del conteo rápido es posible evaluar la cobertura del intervalo de
confianza bootstrap (tarea 5) usando los resultados de elecciones pasadas, para 
ello usaremos los resultados de las elecciones 2006 (datos `election_2006` del 
paquete `estcomp`) repetirás los siguientes dos pasos 100 veces (asegurate de 
que tu ejercicio de simulación sea replicable):

1. Selecciona una muestra estratificada de `election_2006` usando los tamaños de 
muestra que indica la tabla `strata_sample_2006` (donde `n` era el tamaño de 
muestra por estrato y `N` es el número de casillas en el mismo).

2. Utiliza estimador de razón y bootstrap para construir intervalos de confianza
para todos los candidatos.

Evalúa la cobertura del intervalo para cada candidato a lo largo de las 100
muestras, presenta los resultados en una tabla que incluya la longitud media de 
los intervalos y la cobertura observada.

**Opicional (punto extra):** Las muestras con las que se estima en el conteo 
rápido nunca llegan completas, y los faltantes suelen presentar patrones, por 
ejemplo, las casillas en las zonas rurales tienen mayor probabilidad de no 
llegar. Repite el ejercicio de simulación de arriba añadiendo un paso de 
casillas faltantes, lo que debes hacer es que una vez simulada una muestra
*completa* cada casilla se censura de acuerdo a cierta probabilidad (tu la 
eliges como desees), y esta probabilidad puede depender, por ejemplo, de si la 
casilla es rural o urbana o quizá puede variar por estado. Elige uno (o más) 
procedimiento(s) de censura de casillas y evalúa la cobertura de los intervalos 
en este(os) escenario(s). Puedes explorar las variables disponibles viendo la
documentación de los datos (`?election_2006`).

#### 5. Simulación de variables aleatorias {-}

Recuerda que una variable aleatoria $X$ tiene una distribución geométrica
con parámetro $p$ si
$$p_X(i) = P(X=i)=pq^{i-1}$$
para $i=1,2,...$  y donde $q=1-p$. 

Notemos que
$$\sum_{i=1}^{j-1}P(X=i)=1-P(X\geq j-1)$$
$$=1 - q^{j-1}$$
para $j\geq 1$.
por lo que podemos generar un valor de $X$ generando un número aleatorio
$U$ y seleccionando $j$ tal que
$$1-q^{j-1} \leq U \leq 1-q^j$$

Esto es, podemos definir $X$ como:
$$X=min\{j : (1-p)^j < 1-U\}$$
usando que el logaritmo es una función monótona (i.e. $a<b$ implica $log(a)<log(b)$) 
obtenemos que podemos expresar $X$ como 
$$X=min\big\{j : j \cdot log(q) < log(1-U)\big\}$$
$$=min\big\{j : j > log(U)/log(q)\big\}$$
entonces
$$X= int\bigg(\frac{log(U)}{log(q)}\bigg)+1$$

es geométrica con parámetro $p$.

Ahora, sea $X$ el número de lanzamientos de una moneda que se requieren
para alcanzar $r$ éxitos (soles) cuando cada lanzamiento es independiente, $X$ 
tiene una distribución binomial negativa.

Una variable aleatoria $X$ tiene distribución binomial negativa con parámetros 
$(r,p)$ donde $r$ es un entero positivo y $0<p<r$ si
$$P(X=j)=\frac{(j-1)!}{(j-r)!(r-1)!}p^r(1-p)^{j-r}.$$

a) Recuerda la distribución geométrica ¿cuál es a relación entre la variable 
aleatoria binomial negativa y la geométrica?

b) Utiliza el procedimiento descrito para generar observaciones de una variable 
aleatoria con distribución geométrica y la relación entre la geométrica y la 
binomial negativa para generar simulaciones de una variable aleatoria con
distribución binomial negativa (parámetro p = 0.7, r = 20). Utiliza la semilla 
341285 y reporta las primeras 10 simulaciones obtenidas.

c) Verifica la relación
$$p_{j+1}=\frac{j(1-p)}{j+1-r}p_j$$

y úsala para generar un nuevo algoritmo de simulación, vuelve a definir la
semilla y reporta las primeras 10 simulaciones.

$$ \frac{p_{j +1}}{p_j} = \frac{\frac{j!}{(j+1-r)!(r-1)!}p^r(1-p)^{j+1-r}}{\frac{(j-1)!}{(j-r)!(r-1)!}p^r(1-p)^{j-r}}= \frac{j(1 - p) }{j + 1 - r}.$$

d) Realiza 10,000 simulaciones usando cada uno de los algoritmos y compara el 
tiempo de ejecución (puedes usar la función `system.time()`, explicada en 
la sección de [rendimiento en R](https://tereom.github.io/est-computacional-2019/rendimiento-en-r.html)).

e) Genera un histogrma para cada algoritmo (usa 1000 simulaciones) y comparalo 
con la distribución construida usando la función de R _dnbinom_.




</br>
</br>





**No he dado ni recibido ayuda no autorizada en la realización de este exámen.**

</br>
</br>

------------

Firma
