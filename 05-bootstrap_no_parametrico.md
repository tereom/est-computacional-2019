
# Bootstrap no paramétrico

> Bootstrap: _to pull oneself up by one's bootstrap_

Estas notas se desarrollaron con base en @efron, adicionalmente se usaron ideas 
de @tim. Abordamos los siguientes temas:

* Muestras aleatorias  
* El principio del _plug-in_  
* Bootstrap no paramétrico  
* Ejemplos: componentes principales, ajuste de curvas, muestreo.

<!-- la inferencia estadística se ocupa de aprender de la experiencia: 
observamos una muestra aleatoria x y queremos inferir propiedades de la 
población que produjo la muestra. Probabilidad va en la dirección contraria:
de la composicion de una pob deducimos las propiedades de una muestra aleatoria
x -->

#### Ejemplo: aspirina y ataques cardiacos {-}
Como explican Efron y Tibshirani, las 
explicaciones del *bootstrap* y otros métodos computacionales involucran
las ideas de inferencia estadistica tradicional. Las ideas báscias no han 
cambiado pero la implementación de estas sí.

Los tres conceptos básicos de estadística son:

1. Recolección de datos,

2. resúmenes (o descriptivos) de datos y

3. inferencia.

Veamos un ejemplo de estos conceptos y como se introduce bootstrap. Usaremos 
datos de un estudio clínico de consumo de aspirina y ataques cardiacos cuyos 
resultados fueron publicados en el [New York Times](http://www.nytimes.com/1988/01/27/us/heart-attack-risk-found-to-be-cut-by-taking-aspirin.html):

**Planteamiento:** se diseñó un estudio para investigar si el consumo de dosis 
bajas de aspirina podía prevenir los ataques cardiacos en hombres sanos en edad 
media.

**Recolección de datos:** Se hizo un diseño controlado, aleatorizado y 
doblemente ciego. La mitad de los participantes recibieron aspirina y la otra 
mitad un placebo. 

**Descriptivos:** Las estadísticas descriptivas del artículo son muy sencillas:

<div class="mi-tabla">
grupo    | ataques cardiacos | sujetos 
---------|-------------------|---------
aspirina |    104            | 11037
placebo  |    189            | 11034
</div>

De manera que la estimación del cociente de las tasas es 
$$\hat{\theta}=\frac{104/11037}{189/11034} = 0.55$$
    En la muestra los individuos que toman aspirina tienen únicamente 55\% de 
    los ataques que los que toman placebo. Sin embargo, lo que realmente nos 
    interesa es $\theta$: el cociente de tasas que observaríamos si pudieramos 
    tratar a todos los hombres y no únicamente a una muestra.

**Inferencia:** aquí es donde recurrimos a inferencia estadística: 

$$0.43 < \theta < 0.70$$
    El verdadero valor de $\theta$ esta en el intervalo $(0.43,0.70)$ con una 
    confianza del 95%.

Ahora, el **bootstrap** es un método de simulación basado en datos para 
inferencia estadística. La idea detrás es que si una muestra es una aproximación 
de la población que la generó, entoces podemos hacer muestreos de la muestra 
para calcular una estadística de interés y medir la exactitud en la misma.

En este caso tenemos los resultados del experimento en la variable *trial*.


```r
trial <- tibble(patient = 1:22071, 
    group = ifelse(patient <= 11037, "aspirin", "control"), 
    heart_attack = c(rep(TRUE, 104), rep(FALSE, 10933), rep(TRUE, 189), 
      rep(FALSE, 10845)))
trial
#> # A tibble: 22,071 x 3
#>    patient group   heart_attack
#>      <int> <chr>   <lgl>       
#>  1       1 aspirin TRUE        
#>  2       2 aspirin TRUE        
#>  3       3 aspirin TRUE        
#>  4       4 aspirin TRUE        
#>  5       5 aspirin TRUE        
#>  6       6 aspirin TRUE        
#>  7       7 aspirin TRUE        
#>  8       8 aspirin TRUE        
#>  9       9 aspirin TRUE        
#> 10      10 aspirin TRUE        
#> # … with 22,061 more rows
```

Y calculamos el cociente de las tasas:


```r
summary_stats <- trial %>% 
    group_by(group) %>%
    summarise(
        n_attacks = sum(heart_attack), 
        n_subjects = n(),
        rate_attacks = n_attacks / n_subjects * 100
      )
summary_stats
#> # A tibble: 2 x 4
#>   group   n_attacks n_subjects rate_attacks
#>   <chr>       <int>      <int>        <dbl>
#> 1 aspirin       104      11037        0.942
#> 2 control       189      11034        1.71

ratio_rates <- summary_stats$rate_attacks[1] / summary_stats$rate_attacks[2]
ratio_rates
#> [1] 0.550115
```

Después calculamos 1000 replicaciones *bootstrap* de $\hat{\theta*}$


```r
boot_ratio_rates <- function(){
    boot_sample <- trial %>%
        group_by(group) %>%
        sample_frac(replace = TRUE)
    rates <- boot_sample %>% 
        summarise(rate_attacks = sum(heart_attack) / n()) %>%
        pull(rate_attacks)
    rates[1] / rates[2]
} 

boot_ratio_rates <- rerun(1000, boot_ratio_rates()) %>% 
    flatten_dbl()
```

Las replicaciones se pueden utilizar para hacer inferencia de los datos. Por 
ejemplo, podemos estimar el error estándar de $\theta$:


```r
se <- sd(boot_ratio_rates)
comma(se)
#> [1] "0.064"
```


## El principio del plug-in

### Muestras aleatorias {-} 

Supongamos que tenemos una población finita o _universo_ $U$, conformado
por unidades individuales con propiedades que nos gustaría aprender (opinión 
política, nivel educativo, preferencias de consumo, ...). Debido a que es muy 
difícil y caro examinar cada unidad en $U$ seleccionamos una muestra aleatoria.

<div class="caja">
Una **muestra aleatoria** de tamaño $n$ se define como una colección de $n$
unidades $u_1,...,u_n$ seleccionadas aleatoriamente de una población $U$.  

Una vez que se selecciona una muestra aleatoria, los **datos observados** son la colección de medidas $x_1,...,x_n$, también denotadas
$\textbf{x} = (x_1,...,x_n)$.
</div>

En principio, el proceso de muestreo es como sigue:

1. Seleccionamos $n$ enteros de manera independiente (con probabilidad $1/N$), 
cada uno de ellos asociado a un número entre $1$ y $N$.

2. Los enteros determinan las unidades que seleccionamos y tomamos medidas
a cada unidad.

En la práctica el proceso de selección suele ser más complicado y la
definición de la población $U$ suele ser deficiente; sin embargo, el marco
conceptual sigue siendo útil para entender la inferencia estadística.

<div class="caja">
Nuestra definición de muestra aleatoria comprende muestras con y sin reemplazo:

* **muestra sin reemplazo:** una unidad particular puede aparecer a lo más una
vez.

* **muestra con reemplazo:** permite que una unidad aparezca más de una vez.
</div>

* Es más común tomar muestras sin remplazo, sin embargo, **para hacer inferencia 
suele ser más sencillo permitir repeticiones (muestreo con 
remplazo)** y si el tamaño de la muestra $n$ es mucho más chico que la población 
$N$, la probabilidad de muestrear la misma unidad más de una vez es chica.

* El caso particular en el que obtenemos las medidas de interés de cada unidad 
en la población se denomina **censo**, y denotamos al conjunto de datos 
observados de la población por $\mathcal{X}$. 

En general, no nos interesa simplemente describir la muestra que observamos 
sino que queremos aprender acerca de la población de donde se seleccionó la
muestra:

<div class="caja">
El objetivo de la **inferencia estadística** es expresar lo que hemos aprendido 
de la población $\mathcal{X}$ a partir de los datos observados $\textbf{x}$.
</div>

#### Ejemplo: ENLACE {-}

Veamos un ejemplo donde tomamos una muestra de 300 escuelas primarias
del Estado de México, de un universo de 7,518 escuelas, 


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
glimpse(enlace)
#> Observations: 7,518
#> Variables: 8
#> $ id       <int> 38570, 38571, 38572, 38573, 38574, 38575, 38576, 38577,…
#> $ cve_ent  <chr> "15", "15", "15", "15", "15", "15", "15", "15", "15", "…
#> $ turno    <chr> "MATUTINO", "MATUTINO", "MATUTINO", "MATUTINO", "MATUTI…
#> $ tipo     <chr> "INDêGENA", "INDêGENA", "INDêGENA", "INDêGENA", "INDêGE…
#> $ esp_3    <dbl> 550, 485, 462, 646, 508, 502, 570, 441, 597, 648, 535, …
#> $ esp_6    <dbl> 483, 490, 385, 613, 452, 500, 454, 427, 582, 614, 443, …
#> $ n_eval_3 <dbl> 13, 17, 9, 33, 26, 10, 65, 82, 132, 16, 16, 6, 10, 27, …
#> $ n_eval_6 <dbl> 19, 18, 9, 26, 35, 13, 49, 78, 110, 18, 9, 2, 12, 34, 9…
set.seed(16021)
n <- 300
# muestra
enlace_muestra <- sample_n(enlace, n) %>% 
    mutate(clase = "muestra")
```

para cada escuela en la muestra consideremos la medida $x_i$, conformada por el 
promedio de las calificaciones en español de los alumnos de tercero y sexto 
de primaria (prueba ENLACE 2010):

$$x_i=(esp_{3i}, esp_{6i})$$

En este ejemplo contamos con un censo de las escuelas y tomamos la muestra
aleatoria de la tabla de datos general, sin embargo, es común contar únicamente 
con la muestra.

Para español 3^o^ de primaria la media observada es


```r
mean(enlace_muestra$esp_3)
#> [1] 554.5867
```

La media muestral es una estadística descriptiva de la muestra, pero también la
podemos usar para describir a la población de escuelas. 

Al usar la media observada para describir a la población estamos aplicando el 
principio del *plug-in* que dice que una característica dada de una distribución
puede ser aproximada por la equivalente evaluada en la distribución empírica de 
una muestra aleatoria.

### Función de distribución empírica {-}

<div class="caja">
Dada una muestra aleatoria de tamaño $n$ de una distribución de probabilidad 
$P$, la **función de distribución empírica** $P_n$ se define como la 
distribución que asigna probabilidad $1/n$ a cada valor $x_i$ con $i=1,2,...,n$. 

En otras palabras, $P_n$ asigna a un conjunto $A$ en el espacio muestral de $x$ 
la probabilidad empírica:

$$P_n(A)=\#\{x_i \in A \}/n$$
</div>

<!--Ahora, muchos problemas de inferencia estadística involucran la estimación
de algún aspecto de una distribución de de probabilidad $P$ en base a una 
muestra aleatoria obtenida de $P$. -->

* La función de distribución empírica $P_n$ es una estimación de la distribución 
completa $P$, por lo que una manera inmediata de estimar aspectos de $P$ 
(e.g media o mediana) es calcular el aspecto correspondiente de $P_n$.

* En cuanto a la teoría el principio del *plug-in* está soportado por el teorema 
de [Glivenko Cantelli](https://www.stat.berkeley.edu/~bartlett/courses/2013spring-stat210b/notes/8notes.pdf):

    Sea $X_1,...,X_n$ una muestra aleatoria de una distribución $P$, con 
    distribución empírica $P_n$ entonces
    $$\sup_{x \in \mathcal{R}}|P_n(x)-P(x)|\to_p0$$
    casi seguro.


Regresando al ejemplo de las escuelas, comparemos la distribución poblacional y 
la distribución empírica. 



```r
enlace_long <- enlace %>% 
    mutate(clase = "población") %>% 
    bind_rows(enlace_muestra) %>% 
    gather(grado, calif, esp_3:esp_6)
    
ggplot(enlace_long, aes(x = calif)) +
    geom_histogram(aes(y = ..density..), binwidth = 20, fill = "darkgray") +
    facet_grid(grado ~ clase)
```

<img src="05-bootstrap_no_parametrico_files/figure-html/distribucion_empirica-1.png" width="480" style="display: block; margin: auto;" />

Podemos comparar la función de distribución acumulada empírica y la función de
distribución acumulada poblacional: 

En la siguiente gráfica la curva roja 
representa la función de distribución acumulada empírica y la curva con relleno
gris la función de distribución acumulada poblacional.


```r
ggplot() +
    stat_ecdf(data = filter(enlace_long, clase == "población"), 
        aes(x = calif, ymin = 0, ymax = ..y..), geom = "ribbon", pad = TRUE, 
          alpha = 0.5, 
        fill = "gray", color = "darkgray")  +
    stat_ecdf(data = filter(enlace_long, clase == "muestra"), 
        aes(x = calif), geom = "step", color = "red") +
    facet_grid(~ grado) +
    labs(color = "")
```

<img src="05-bootstrap_no_parametrico_files/figure-html/unnamed-chunk-3-1.png" width="480" style="display: block; margin: auto;" />

Cuando la variable de interés toma pocos valores es fácil ver la distribución 
empírica, supongamos que la medición de las unidades que nos interesa es la 
variable tipo de escuela, entonces la distribución empírica en la muestra es


```r
table(enlace_muestra$tipo) / n
#> 
#>     CONAFE    GENERAL   INDêGENA PARTICULAR 
#> 0.01000000 0.82000000 0.02333333 0.14666667
```

Vale la pena notar que pasar de la muestra desagregada a la distribución 
empírica (lista de valores y la proporción que ocurre cada una en la muestra) 
no conlleva ninguna pérdida de información:  
_el vector de frecuencias observadas es un **estadístico suficiente** para la
verdadera distribución._

Esto quiere decir que toda la información de $P$ contenida en el vector de 
observaciones $\textbf{x}$ está también contenida en $P_n$.

**Nota**: el teorema de suficiencia asume que las observaciones $\textbf{x}$ son
una muestra aleatoria de la distribución $P$, este no es siempre el caso 
(e.g. si tenemos una serie de tiempo).

### Parámetros y estadísticas {-}

Cuando aplicamos teoría estadística a problemas reales, es común que las 
respuestas estén dadas en términos de distribuciones de probabilidad. Por 
ejemplo, podemos preguntarnos que tan correlacionados están los resultados de 
las pruebas de español correspondientes a 3^o^ y 6^o^. Si conocemos la 
distribución de probabilidad $P$ contestar esta pregunta es simplemente cuestión 
de aritmética, el coeficiente de correlación poblacional esta dado por:

$$corr(y,z) = \frac{\sum_{j=1}^{N}(Y_j - \mu_y)(Z_j-\mu_z)}
{[\sum_{j=1}^{N}(Y_j - \mu_y)^2\sum_{j=1}^{N}(Z_j - \mu_z)^2]^{1/2}}$$

en nuestro ejemplo $(Y_j,Z_j)$ son el j-ésimo punto en la población de escuelas 
primarias $\mathcal{X}$, $\mu_y=\sum Y_j/3311$ y $\mu_z=\sum Z_j/3311$.


```r
ggplot(enlace, aes(x = esp_3, y = esp_6)) +
    geom_point(alpha = 0.5)
```

<img src="05-bootstrap_no_parametrico_files/figure-html/grafica_corr-1.png" width="300px" style="display: block; margin: auto;" />

```r
cor(enlace$esp_3, enlace$esp_6) %>% round(2)
#> [1] 0.49
```

Si no tenemos un censo debemos inferir, podríamos estimar la correlación 
$corr(y,z)$ a través del coeficiente de correlación muestral:

$$\hat{corr}(y,z) = \frac{\sum_{j=1}^{n}(y_j - \hat{\mu}_y)(z_j-\hat{\mu}_z)}
{[\sum_{j=1}^{n}(y_j - \hat{\mu}_y)^2\sum_{j=1}^{n}(z_j - \hat{\mu}_z)^2]^{1/2}}$$

recordando que la distribución empírica es una estimación de la distribución 
completa.


```r
cor(enlace_muestra$esp_3, enlace_muestra$esp_6)
#> [1] 0.4392921
```

Al igual que la media esto es una estimación _plug-in_. Otros ejemplos son:

* Supongamos que nos interesa estimar la mediana de las calificaciones
de español para 3^o de primaria:


```r
median(enlace_muestra$esp_3)
#> [1] 554.5
```

* Supongamos que nos interesa estimar la probabilidad de que la calificación de 
español de una escuela sea mayor a 700:

$$\theta=\frac{1}{N}\sum_{j=1}^N I_{\{Y_i>700\}}$$

donde $I_{\{\cdot\}}$ es la función indicadora.

La estimación _plug-in_ de $\hat{\theta}$ sería:


```r
sum(enlace_muestra$esp_3 > 700) / n
#> [1] 0.01333333
```

#### Ejemplo: dado {-}

Observamos 100 lanzamientos de un dado, obteniendo la siguiente distribución 
empírica:


```r
dado <- read.table("data/dado.csv", header = TRUE, quote = "\"")
prop.table(table(dado$x))
#> 
#>    1    2    3    4    5    6 
#> 0.13 0.19 0.10 0.17 0.14 0.27
```

En este caso no tenemos un censo, solo contamos con la muestra. Una pregunta
de inferencia que surge de manera natural es si el dado es justo, esto es, 
si la distribución que generó esta muestra tiene una distribución 
$P = (1/6, 1/6, 1/6,1/6, 1/6, 1/6)$.

Para resolver esta pregunta, debemos hacer inferencia de la distribución 
empírica.

Antes de proseguir repasemos dos conceptos importantes: parámetros y 
estadísticos:

<div class='caja'>
Un **parámetro** es una función de la distribución de probabilidad 
$\theta=t(P)$, mientras que una **estadística** es una función de la 
muestra $\textbf{x}$. 
</div>

Por ejemplo, la $corr(x,y)$ es un parámetro de $P$ y $\hat{corr}(x,y)$ es una 
estadística con base en $\textbf{x}$ y $\textbf{y}$.

Entonces:

<div class="caja">
El **principio del _plug-in_** es un método para estimar parámetros a 
partir de muestras; la estimación _plug-in_ de un parámetro $\theta=t(P)$ se 
define como:
$$\hat{\theta}=t(P_n).$$
</div>

Es decir, estimamos la función $\theta = t(P)$ de la distribución de 
probabilidad $P$ con la misma función aplicada en la distribución empírica 
$\hat{\theta}=t(P_n)$.

¿Qué tan _bien_ funciona el principio del _plug-in_?

Suele ser muy bueno cuando la única información disponible de $P$ es la 
muestra $\textbf{x}$, bajo esta circunstancia $\hat{\theta}=t(P_n)$ no puede
ser superado como estimador de $\theta=t(P)$, al menos no en el sentido 
asintótico de teoría estadística $(n\to\infty)$.

El principio del _plug-in_ provee de una estimación más no habla de precisión: 
usaremos el bootstrap para estudiar el sesgo y el error estándar del 
estimador _plug-in_ $\hat{\theta}=t(P_n)$. 

### Distribuciones muestrales y errores estándar {-}

<div class="caja">
La **distribución muestral** de una estadística es la distribución de 
probabilidad de la misma, considerada como una variable aleatoria.
</div>

Es así que la distribución muestral depende de:  
1) La distribución poblacional,    
2) la estadística que se está considerando,  
y 3) la muestra aleatoria: cómo se seleccionan las unidades de la muestra y
cuántas.

En teoría para obtener la distribución muestral uno seguiría los siguientes 
pasos:

* Selecciona muestras de una población (todas las posibles o un número infinito 
de muestras).

* Calcula la estadística de interés para cada muestra.

* __La distribución de la estadística es la distribución muestral.__


```r
library(LaplacesDemon)
library(patchwork)
# En este ejemplo la población es una mezcla de normales
pob_plot <- ggplot(data_frame(x = -15:20), aes(x)) +
    stat_function(fun = dnormm, args = list(p = c(0.3, 0.7), mu = c(-2, 8), 
        sigma = c(3.5, 3)), alpha = 0.8) +
    geom_vline(aes(color = "mu", xintercept = 5), alpha = 0.5) +
    scale_colour_manual(values = c('mu' = 'red'), name = '', 
        labels = expression(mu)) +
    labs(x = "", subtitle = "Población", color = "")

samples <- data_frame(sample = 1:3) %>% 
    mutate(
        sims = rerun(3, rnormm(30, p = c(0.3, 0.7), mu = c(-2, 8), 
            sigma = c(3.5, 3))), 
        x_bar = map_dbl(sims, mean))
muestras_plot <- samples %>% 
    unnest() %>% 
    ggplot(aes(x = sims)) +
        geom_histogram(binwidth = 2, alpha = 0.5, fill = "darkgray") +
        geom_vline(xintercept = 5, color = "red", alpha = 0.5) +
        geom_segment(aes(x = x_bar, xend = x_bar, y = 0, yend = 0.8), 
            color = "blue") +
        xlim(-15, 20) +
        facet_wrap(~ sample) +
        geom_text(aes(x = x_bar, y = 0.95, label = "bar(x)"), parse = TRUE, 
            color = "blue", alpha = 0.2, hjust = 1) +
        labs(x = "", subtitle = "Muestras") 

samples_dist <- data_frame(sample = 1:10000) %>% 
    mutate(
        sims = rerun(10000, rnormm(100, p = c(0.3, 0.7), mu = c(-2, 8), 
            sigma = c(3.5, 3))), 
        mu_hat = map_dbl(sims, mean))
dist_muestral_plot <- ggplot(samples_dist, aes(x = mu_hat)) +
    geom_density(adjust = 2) +
    labs(x = "", subtitle = expression("Distribución muestral de "~hat(mu))) +
    geom_vline(xintercept = 5, color = "red", alpha = 0.5)

(pob_plot | plot_spacer()) / (muestras_plot | dist_muestral_plot) 
```

![](img/ideal_world.png)

Para hacer inferencia necesitamos describir la forma de la distribución
muestral, es natural pensar en la desviación estándar pues es una medida de la
dispersión de la distribución de la estadística alrededor de su media:

<div class="caja">
El **error estándar** es la desviación estándar de la distribución muestral de
una estadística.
</div>

#### Ejemplo: el error estándar de una media {-}

Supongamos que $x$ es una variable aleatoria que toma valores en los reales con 
distribución de probabilidad $P$. Denotamos por $\mu_P$ y $\sigma_P^2$ la 
media y varianza de $P$,

$$\mu_P = E_P(x),$$ 
$$\sigma_P^2=var_P(x)=E_P[(x-\mu_P)^2]$$

en la notación enfatizamos la dependencia de la media y varianza en la 
distribución $P$. 

Ahora, sea $(x_1,...,x_n)$ una muestra aleatoria de $P$, de tamaño $n$, 
la media de la muestra $\bar{x}=\sum_{i=1}^nx_i/n$ tiene:

* esperanza $\mu_P$,

* varianza $\sigma_P^2/n$.

En palabras: la esperanza de $\bar{x}$ es la misma que la esperanza de $x$, pero
la varianza de $\bar{x}$ es $1/n$ veces la varianza de $x$, así que entre
mayor es la $n$ tenemos una mejor estimación de $\mu_P$.

En el caso de la media $\bar{x}$, el error estándar, que denotamos 
$se_P(\bar{x})$, es la raíz de la varianza de $\bar{x}$,

$$se_P(\bar{x}) = [var_P(\bar{x})]^{1/2}= \sigma_P/ \sqrt{n}.$$

En este punto podemos usar el principio del _plug-in_, simplemente sustituimos
$P_n$ por $P$ y obtenemos, primero, una estimación de $\sigma_P$:
$$\hat{\sigma}=\hat{\sigma}_{P_n} = \bigg\{\frac{1}{n}\sum_{i=1}^n(x_i-\bar{x})^2\bigg\}^{1/2}$$

de donde se sigue la estimación del error estándar:

$$\hat{se}(\bar{x})=\hat{\sigma}_{P_n}/\sqrt{n}=\bigg\{\frac{1}{n^2}\sum_{i=1}^n(x_i-\bar{x})^2\bigg\}^{1/2}$$

Notemos que usamos el principio del _plug-in_ en dos ocasiones, primero para 
estimar la esperanza $\mu_P$ mediante $\mu_{P_n}$ y luego para estimar el 
error estándar $se_P(\bar{x})$. 

![](img/manicule2.jpg) Consideramos los datos de ENLACE edo. de México 
(`enlace`), y la columna de calificaciones de español 3^o^ de primaria (`esp_3`). 

- Selecciona una muestra de tamaño $n = 10, 100, 1000$. Para cada muestra 
calcula media y el error estándar de la media usando el principio del *plug-in*:
$\hat{\mu}=\bar{x}$, y $\hat{se}(\bar{x})=\hat{\sigma}_{P_n}/\sqrt{n}$.

- Ahora aproximareos la distribución muestral, para cada tamaño de muestra $n$: 
i) simula 10,000 muestras aleatorias, ii) calcula la media en cada muestra, iii)
Realiza un histograma de la distribución muestral de las medias (las medias del
paso anterior) iv) aproxima el error estándar calculando la desviación estándar
de las medias del paso ii.

- Calcula el error estándar de la media para cada tamaño de muestra usando la
información poblacional (ésta no es una aproximación), usa la fórmula:
$se_P(\bar{x}) = \sigma_P/ \sqrt{n}$.

- ¿Cómo se comparan los errores estándar correspondientes a los distintos 
tamaños de muestra? 

#### ¿Por qué bootstrap? {-}

* En el caso de la media $\hat{\theta}=\bar{x}$ la aplicación del principio del 
_plug-in_ para el cálculo de errores estándar es inmediata; sin embargo, hay 
estadísticas para las cuáles no es fácil aplicar este método.

* El método de aproximarlo con simulación, como lo hicimos en el ejercicio de 
arriba no es factible pues en la práctica no podemos seleccionar un número 
arbitrario de muestras de la población, sino que tenemos únicamente una muestra. 

* La idea del *bootstrap* es replicar el método de simulación para aproximar
el error estándar, esto es seleccionar muchas muestras y calcular la estadística 
de interés en cada una, con la diferencia que las muestras se seleccionan de la
distribución empírica a falta de la distribución poblacional.


## El estimador bootstrap del error estándar

Entonces, los pasos para calcular estimador bootstrap del error estándar son:

Tenemos una muestra aleatoria $\textbf{x}=(x_1,x_2,...,x_n)$ 
proveniente de una distribución de probabilidad desconocida $P$, 

1. Seleccionamos muestras aleatorias con reemplazo de la distribución empírica.

2. Calculamos la estadística de interés para cada muestra:
    $$\hat{\theta}=s(\textbf{x})$$ 
    la estimación puede ser la estimación _plug-in_ $t(P_n)$ pero también puede 
    ser otra. 

3. La distribución de la estadística es la distribución bootstrap, y el 
estimador bootstrap del error estándar es la desviación estándar de la 
distribución bootstrap.



```r
dist_empirica <- tibble(id = 1:30, obs = samples$sims[[1]])

dist_empirica_plot <- ggplot(dist_empirica, aes(x = obs)) +
    geom_histogram(binwidth = 2, alpha = 0.5, fill = "darkgray") +
    geom_vline(aes(color = "mu", xintercept = 5), alpha = 0.5) +
    geom_vline(aes(xintercept = samples$x_bar[1], color = "x_bar"), 
        alpha = 0.8, linetype = "dashed") +
    xlim(-15, 20) +
    geom_vline(xintercept = 5, color = "red", alpha = 0.5) +
    labs(x = "", subtitle = expression("Distribución empírica"~P[n])) +
    scale_colour_manual(values = c('mu' = 'red', 'x_bar' = 'blue'), name = '', 
        labels = c(expression(mu), expression(bar(x)))) 
    
samples_boot <- data_frame(sample_boot = 1:3) %>% 
    mutate(
        sims_boot = rerun(3, sample(dist_empirica$obs, replace = TRUE)), 
        x_bar_boot = map_dbl(sims_boot, mean)
      )

muestras_boot_plot <- samples_boot %>% 
    unnest() %>% 
    ggplot(aes(x = sims_boot)) +
        geom_histogram(binwidth = 2, alpha = 0.5, fill = "darkgray") +
        geom_vline(aes(xintercept = samples$x_bar[1]), color = "blue",
            linetype = "dashed", alpha = 0.8) +
        geom_vline(xintercept = 5, color = "red", alpha = 0.5) +
        geom_segment(aes(x = x_bar_boot, xend = x_bar_boot, y = 0, yend = 0.8), 
            color = "black") +
        xlim(-15, 20) +
        facet_wrap(~ sample_boot) +
        geom_text(aes(x = x_bar_boot, y = 0.95, label = "bar(x)^'*'"), 
            parse = TRUE, color = "black", alpha = 0.3, hjust = 1) +
        labs(x = "", subtitle = "Muestras bootstrap") 

boot_dist <- data_frame(sample = 1:10000) %>% 
    mutate(
        sims_boot = rerun(10000, sample(dist_empirica$obs, replace = TRUE)), 
        mu_hat_star = map_dbl(sims_boot, mean))
boot_muestral_plot <- ggplot(boot_dist, aes(x = mu_hat_star)) +
    geom_histogram(alpha = 0.5, fill = "darkgray") +
    labs(x = "", 
        subtitle = expression("Distribución bootstrap de "~hat(mu)^'*')) +
    geom_vline(xintercept = 5, color = "red", alpha = 0.5) +
    geom_vline(aes(xintercept = samples$x_bar[1]), color = "blue", 
        linetype = "dashed", alpha = 0.8)

(dist_empirica_plot | plot_spacer()) / (muestras_boot_plot | boot_muestral_plot) 
```

![](img/bootstrap_world.png)

Describamos la notación y conceptos:

<div class="caja">
Definimos una **muestra bootstrap** como una muestra aleatoria de tamaño $n$ que
se obtiene de la distribución empírica $P_n$ y la denotamos 
$$\textbf{x}^* = (x_1^*,...,x_n^*).$$
</div>

La notación de estrella indica que $\textbf{x}^*$ no son los datos $\textbf{x}$
sino una versión de **remuestreo** de $\textbf{x}$.

Otra manera de frasearlo: Los datos bootsrtap $x_1^*,...,x_n^*$ son una muestra
aleatoria de tamaño $n$ seleccionada con reemplazo de la población de $n$
objetos $(x_1,...,x_n)$. 

<div class="caja">
A cada muestra bootstrap $\textbf{x}^*$ le corresponde una replicación
$\hat{\theta}^*=s(\textbf{x}^*).$
</div>

el estimador bootstrap de $se_P(\hat{\theta})$ se define como:

$$se_{P_n}(\hat{\theta}^*)$$

en otras palabras, la estimación bootstrap de $se_P(\hat{\theta})$ es el error
estándar de $\hat{\theta}$ para conjuntos de datos de tamaño $n$ seleccionados
de manera aleatoria de $P_n$.

La fórmula $se_{P_n}(\hat{\theta}^*)$ no existe para casi ninguna estimación 
diferente de la media, por lo que recurrimos a la técnica computacional 
bootstrap: 

<div class="caja">

**Algoritmo bootstrap para estimar errores estándar** 

1. Selecciona $B$ muestras bootstrap independientes: 
$$\textbf{x}^{*1},..., \textbf{x}^{*B}$$.  

2. Evalúa la replicación bootstrap correspondiente a cada muestra bootstrap:
$$\hat{\theta}^{*b}=s(\textbf{x}^{*b})$$
para $b=1,2,...,B.$

3. Estima el error estándar $se_P(\hat{\theta})$ usando la desviación estándar
muestral de las $B$ replicaciones:
$$\hat{se}_B = \bigg\{\frac{\sum_{b=1}^B[\hat{\theta}^{*}(b)-\hat{\theta}^*(\cdot)]^2 }{B-1}\bigg\}^{1/2}$$

donde $$\hat{\theta}^*(\cdot)=\sum_{b=1}^B \theta^{*}(b)/B $$.
</p>
</div>

Notemos que:

* La estimación bootstrap de $se_{P}(\hat{\theta})$, el error estándar
de una estadística $\hat{\theta}$, es un estimador *plug-in* que usa la 
función de distribución empírica $P_n$ en lugar de la distribución desconocida
$P$. 

* Conforme el número de replicaciones $B$ aumenta 
$$\hat{se}_B\approx se_{P_n}(\hat{\theta})$$
    este hecho equivale a decir que la desviación estándar empírica se acerca a 
    la desviación estándar poblacional conforme crece el número de muestras. La 
    _población_ en este caso es la población de valores $\hat{\theta}^*=s(x^*)$.

* Al estimador de bootstrap ideal $se_{P_n}(\hat{\theta})$ y su aproximación
$\hat{se}_B$ se les denota **estimadores bootstrap no paramétricos** ya que 
estan basados en $P_n$, el estimador no paramétrico de la población $P$.

#### Ejemplo: Error estándar bootstrap de una media {-}


```r
mediaBoot <- function(x){ 
  # x: variable de interés
  # n: número de replicaciones bootstrap
  n <- length(x)
  muestra_boot <- sample(x, size = n, replace = TRUE)
  mean(muestra_boot) # replicacion bootstrap de theta_gorro
}
thetas_boot <- rerun(10000, mediaBoot(enlace_muestra$esp_3)) %>% flatten_dbl()
sd(thetas_boot)
#> [1] 3.238793
```

y se compara con $\hat{se}(\bar{x})$ (estimador *plug-in* del error estándar):


```r
se <- function(x) sqrt(sum((x - mean(x)) ^ 2)) / length(x)
se(enlace_muestra$esp_3)
#> [1] 3.264511
```

**Nota:** Conforme $B$ aumenta $\hat{se}_{B}(\bar{x})\to \{\sum_{i=1}^n(x_i - \bar{x})^2 / n \}^{1/2}$, 
se demuestra con la ley débil de los grandes números.

![](img/manicule2.jpg) Considera el coeficiente de correlación muestral entre la 
calificación de $y=$esp_3 y la de $z=$esp_6: $\hat{corr}(y,z)=0.9$. ¿Qué tan 
precisa es esta estimación? 

### Variación en distribuciones bootstrap {-}

En el proceso de estimación bootstrap hay dos fuentes de variación pues:

* La muestra original se selecciona con aleatoriedad de una población.

* Las muestras bootstrap se seleccionan con aleatoriedad de la muestra 
original. Esto es: *La estimación bootstrap ideal es un resultado asintótico 
$B=\infty$, en esta caso $\hat{se}_B$ iguala la estimación _plug-in_ 
$se_{P_n}$.* 

En el proceso de *bootstrap* podemos controlar la variación del segundo aspecto,
conocida como **implementación de muestreo Monte Carlo**, y la variación 
Monte Carlo decrece conforme incrementamos el número de muestras. 

Podemos eliminar la variación Monte Carlo si seleccionamos todas las posibles
muestras con reemplazo de tamaño $n$, hay ${2n-1}\choose{n}$ posibles muestras 
y si seleccionamos todas obtenemos $\hat{se}_\infty$ (bootstrap ideal), sin
embargo, en la mayor parte de los problemas no es factible proceder así.


```r
set.seed(8098)
pob_plot <- ggplot(data_frame(x = -15:20), aes(x)) +
    stat_function(fun = dnormm, args = list(p = c(0.3, 0.7), mu = c(-2, 8), 
        sigma = c(3.5, 3)), alpha = 0.8) +
    geom_vline(aes(color = "mu", xintercept = 5), alpha = 0.5) +
    scale_colour_manual(values = c('mu' = 'red'), name = '', 
        labels = expression(mu)) +
    labs(x = "", y = "", subtitle = "Población", color = "") +
    theme(axis.text.y = element_blank())

samples <- data_frame(sample = 1:6) %>% 
    mutate(
        sims = rerun(6, rnormm(50, p = c(0.3, 0.7), mu = c(-2, 8), 
            sigma = c(3.5, 3))), 
        x_bar = map_dbl(sims, mean))

 means_boot <- function(n, sims) {
    rerun(n, mean(sample(sims, replace = TRUE))) %>%
        flatten_dbl()
 }
samples_boot <- samples %>% 
    mutate(
        medias_boot_30_1 = map(sims, ~means_boot(n = 30, .)), 
        medias_boot_30_2 = map(sims, ~means_boot(n = 30, .)), 
        medias_boot_1000_1 = map(sims, ~means_boot(n = 1000, .)), 
        medias_boot_1000_2 = map(sims, ~means_boot(n = 1000, .))
    )

emp_dists <- samples_boot %>% 
    unnest(cols = sims) %>% 
    rename(obs = sims)
emp_dists_plots <- ggplot(emp_dists, aes(x = obs)) +
    geom_histogram(binwidth = 2, alpha = 0.5, fill = "darkgray") +
    geom_vline(aes(color = "mu", xintercept = 5), alpha = 0.5, 
      show.legend = FALSE) +
    geom_vline(aes(xintercept = x_bar, color = "x_bar"), show.legend = FALSE, 
        alpha = 0.8, linetype = "dashed") +
    xlim(-15, 20) +
    geom_vline(xintercept = 5, color = "red", alpha = 0.5) +
    labs(x = "", y = "", subtitle = expression("Distribución empírica"~P[n])) +
    scale_colour_manual(values = c('mu' = 'red', 'x_bar' = 'blue'), name = '', 
        labels = c(expression(mu), expression(bar(x)))) +
    facet_wrap(~ sample, ncol = 1) +
    theme(strip.background = element_blank(), strip.text.x = element_blank(), 
        axis.text.y = element_blank())
 
boot_dists_30 <- samples_boot %>% 
    unnest(cols = c(medias_boot_30_1, medias_boot_30_2)) %>% 
    pivot_longer(cols = c(medias_boot_30_1, medias_boot_30_2), 
    values_to = "mu_hat_star", names_to = "boot_trial",
    names_prefix = "medias_boot_30_")
boot_dists_30_plot <- ggplot(boot_dists_30, aes(x = mu_hat_star)) +
    geom_histogram(alpha = 0.5, fill = "darkgray") +
    labs(x = "", y = "",
        subtitle = expression("Distribución bootstrap B = 30")) +
    geom_vline(xintercept = 5, color = "red", alpha = 0.5) +
    geom_vline(aes(xintercept = x_bar), color = "blue", 
        linetype = "dashed", alpha = 0.8) +
    facet_grid(sample~boot_trial) +
    theme(strip.background = element_blank(), strip.text.y = element_blank(), 
        axis.text.y = element_blank())

boot_dists_1000 <- samples_boot %>% 
    unnest(cols = c(medias_boot_1000_1, medias_boot_1000_2)) %>% 
    pivot_longer(cols = c(medias_boot_1000_1, medias_boot_1000_2), 
    values_to = "mu_hat_star", names_to = "boot_trial",
    names_prefix = "medias_boot_1000_")
boot_dists_1000_plot <- ggplot(boot_dists_1000, aes(x = mu_hat_star)) +
    geom_histogram(alpha = 0.5, fill = "darkgray") +
    labs(subtitle = expression("Distribución bootstrap B = 1000"), 
       x = "", y = "") +
    geom_vline(xintercept = 5, color = "red", alpha = 0.5) +
    geom_vline(aes(xintercept = x_bar), color = "blue", 
        linetype = "dashed", alpha = 0.8) +
    facet_grid(sample~boot_trial) +
    scale_colour_manual(values = c('mu' = 'red', 'x_bar' = 'blue'), name = '',
    labels = c(expression(mu), expression(bar(x)))) +
    theme(strip.background = element_blank(), strip.text.y = element_blank(), 
        strip.text.x = element_blank(), axis.text.y = element_blank())

(pob_plot | plot_spacer() | plot_spacer()) /
(emp_dists_plots | boot_dists_30_plot | boot_dists_1000_plot) +
plot_layout(heights = c(1, 5))
```

En la siguiente gráfica mostramos 6 posibles muestras de tamaño 50 simuladas de
la población, para cada una de ellas se graficó la distribución empírica y se
se realizan histogramas de la distribución bootstrap con $B=30$ y $B=1000$, en 
cada caso hacemos dos repeticiones, notemos que cuando el número de muestras 
bootstrap es grande las distribuciones bootstrap son muy similares (para una 
muestra de la población dada), esto es porque disminuimos el erro Monte Carlo. 
También vale la pena recalcar que la distribución bootstrap está centrada en el 
valor observado en la muestra (línea azúl punteada) y no en el valor poblacional
sin embargo la forma de la distribución es similar a lo largo de las filas.

![](img/bootstrap_mc_error.png)


<!--
* En la práctica para elegir el tamaño de $B$ debemos considerar que buscamos 
las mismas propiedades para la estimación de un error estándar que para 
cualquier estimación: poco sesgo y desviación estándar chica. El sesgo de la 
estifmación bootstrap del error estándar suele ser bajo y el error estándar está

 Una respuesta aproximada es en términos del coeficiente de variación de 
$\hat{se}_B$, esto es el cociente de la desviación estándar de $\hat{se}_B$ y su 
valor esperado, la variabilidad adicional de parar en $B$ replicaciones en lugar 
de seguir hasta infiniti se refleja en un incremento en el coeficiente de 
variación
-->

Entonces, ¿cuántas muestras bootstrap? 

1. Incluso un número chico de replicaciones bootstrap, digamos $B=25$ es 
informativo, y $B=50$ con frecuencia es suficiente para dar una buena 
estimación de $se_P(\hat{\theta})$ (@efron).

2. Cuando se busca estimar error estándar @tim recomienda $B=1000$ muestras, o 
$B=10,000$ muestras dependiendo la presición que se busque.



```r
seMediaBoot <- function(x, B){
    thetas_boot <- rerun(B, mediaBoot(x)) %>% flatten_dbl()
    sd(thetas_boot)
}

B_muestras <- data_frame(n_sims = c(5, 25, 50, 100, 200, 400, 1000, 1500, 3000, 
    5000, 10000, 20000)) %>% 
    mutate(est = map_dbl(n_sims, ~seMediaBoot(x = enlace_muestra$esp_3, B = .)))
#> Warning: `data_frame()` is deprecated, use `tibble()`.
#> This warning is displayed once per session.
B_muestras
#> # A tibble: 12 x 2
#>    n_sims   est
#>     <dbl> <dbl>
#>  1      5  3.08
#>  2     25  3.20
#>  3     50  3.17
#>  4    100  3.04
#>  5    200  3.36
#>  6    400  3.24
#>  7   1000  3.17
#>  8   1500  3.38
#>  9   3000  3.27
#> 10   5000  3.29
#> 11  10000  3.27
#> 12  20000  3.26
```

#### Ejemplo componentes principales: calificaciones en exámenes {-}

Los datos _marks_ (Mardia, Kent y Bibby, 1979) contienen los puntajes de 88 
estudiantes en 5 pruebas: mecánica, vectores, álgebra, análisis y estadística.
Cada renglón corresponde a la calificación de un estudiante en cada prueba.


```r
data(marks, package = "ggm")
glimpse(marks)
#> Observations: 88
#> Variables: 5
#> $ mechanics  <dbl> 77, 63, 75, 55, 63, 53, 51, 59, 62, 64, 52, 55, 50, 6…
#> $ vectors    <dbl> 82, 78, 73, 72, 63, 61, 67, 70, 60, 72, 64, 67, 50, 6…
#> $ algebra    <dbl> 67, 80, 71, 63, 65, 72, 65, 68, 58, 60, 60, 59, 64, 5…
#> $ analysis   <dbl> 67, 70, 66, 70, 70, 64, 65, 62, 62, 62, 63, 62, 55, 5…
#> $ statistics <dbl> 81, 81, 81, 68, 63, 73, 68, 56, 70, 45, 54, 44, 63, 3…
```

Entonces un análisis de componentes principales proseguiría como sigue:


```r
pc_marks <- princomp(marks)
summary(pc_marks)
#> Importance of components:
#>                            Comp.1     Comp.2      Comp.3     Comp.4
#> Standard deviation     26.0600955 14.1291852 10.13060363 9.15149631
#> Proportion of Variance  0.6191097  0.1819910  0.09355915 0.07634838
#> Cumulative Proportion   0.6191097  0.8011007  0.89465983 0.97100821
#>                            Comp.5
#> Standard deviation     5.63935825
#> Proportion of Variance 0.02899179
#> Cumulative Proportion  1.00000000
loadings(pc_marks)
#> 
#> Loadings:
#>            Comp.1 Comp.2 Comp.3 Comp.4 Comp.5
#> mechanics   0.505  0.749  0.301  0.295       
#> vectors     0.368  0.207 -0.419 -0.781  0.190
#> algebra     0.346        -0.146        -0.924
#> analysis    0.451 -0.301 -0.594  0.521  0.286
#> statistics  0.535 -0.547  0.600 -0.178  0.151
#> 
#>                Comp.1 Comp.2 Comp.3 Comp.4 Comp.5
#> SS loadings       1.0    1.0    1.0    1.0    1.0
#> Proportion Var    0.2    0.2    0.2    0.2    0.2
#> Cumulative Var    0.2    0.4    0.6    0.8    1.0
plot(pc_marks, type = "lines")
```

<img src="05-bootstrap_no_parametrico_files/figure-html/pc-1.png" width="288" style="display: block; margin: auto;" />



```r
biplot(pc_marks)
```

<img src="05-bootstrap_no_parametrico_files/figure-html/unnamed-chunk-9-1.png" width="672" style="display: block; margin: auto;" />

Los cálculos de un análisis de componentes principales involucran la matriz de 
covarianzas empírica $G$ (estimaciones _plug-in_)

$$G_{jk} = \frac{1}{88}\sum_{i=1}^88(x_{ij}-\bar{x_j})(x_{ik}-\bar{x_k})$$

para $j,k=1,2,3,4,5$, y donde $\bar{x_j} = \sum_{i=1}^88 x_{ij} / 88$ (la media 
de la i-ésima columna).


```r
G <- cov(marks) * 87 / 88
G
#>            mechanics   vectors   algebra  analysis statistics
#> mechanics   302.2147 125.59969 100.31599 105.11415  116.15819
#> vectors     125.5997 170.87810  84.18957  93.59711   97.88688
#> algebra     100.3160  84.18957 111.60318 110.83936  120.48567
#> analysis    105.1142  93.59711 110.83936 217.87603  153.76808
#> statistics  116.1582  97.88688 120.48567 153.76808  294.37177
```

Los _pesos_ y las _componentes principales_ no son mas que los eigenvalores y 
eigenvectores de la matriz de covarianzas $G$, estos se calculan a través de una 
serie de de manipulaciones algebraicas que requieren cálculos del orden de p^3^
(cuando G es una matriz de tamaño p$\times$p).


```r
eigen_G <- eigen(G)
lambda <- eigen_G$values
v <- eigen_G$vectors
lambda
#> [1] 679.12858 199.63388 102.62913  83.74988  31.80236
v
#>           [,1]        [,2]       [,3]         [,4]        [,5]
#> [1,] 0.5053373  0.74917585  0.3006046  0.294631757 -0.07873256
#> [2,] 0.3682215  0.20692361 -0.4185473 -0.781332853 -0.18955902
#> [3,] 0.3456083 -0.07622065 -0.1457830 -0.003348995  0.92384059
#> [4,] 0.4512152 -0.30063472 -0.5944322  0.520724416 -0.28551729
#> [5,] 0.5347961 -0.54747360  0.5998773 -0.177611847 -0.15121842
```

1. Proponemos el siguiente modelo simple para puntajes correlacionados:

$$\textbf{x}_i = Q_i \textbf{v}$$

donde $\textbf{x}_i$ es la tupla de calificaciones del i-ésimo estudiante, 
$Q_i$ es un número que representa la habilidad del estudiante y $\textbf{v}$ es
un vector fijo con 5 números que aplica a todos los estudiantes. Si este modelo
simple fuera cierto, entonces únicamente el $\hat{\lambda}_1$ sería positivo
y $\textbf{v} = \hat{v}_1$.
Sea $$\hat{\theta}=\sum_{i=1}^5\hat{\lambda}_i$$
el modelo propuesto es equivalente a $\hat{\theta}=1$, inculso si el modelo es
correcto, no esperamos que $\hat{\theta}$ sea exactamente uno pues hay ruido en 
los datos.


```r
theta_hat <- lambda[1]/sum(lambda)
theta_hat
#> [1] 0.6191097
```

El valor de $\hat{\theta}$ mide el porcentaje de la varianza explicada en la 
primer componente principal, ¿qué tan preciso es  $\hat{\theta}$? La complejidad
matemática en el cálculo de  $\hat{\theta}$ es irrelevante siempre y cuando 
podamos calcular  $\hat{\theta}^*$ para una muestra bootstrap, en esta caso una
muestra bootsrtap es una base de datos de 88 $\times$ 5 $\textbf{X}^*$, donde las
filas $\bf{x_i}^*$ de $\textbf{X}^*$ son una muestra aleatoria de tamaño
88 de la verdadera matriz de datos.


```r
pc_boot <- function(){
    muestra_boot <- sample_n(marks, size = 88, replace = TRUE)
    G <- cov(muestra_boot) * 87 / 88 
    eigen_G <- eigen(G)
    theta_hat <- eigen_G$values[1] / sum(eigen_G$values)
}
B <- 1000
thetas_boot <- rerun(B, pc_boot()) %>% flatten_dbl()
```

Veamos un histograma de las replicaciones de  $\hat{\theta}$:


```r
ggplot(data_frame(theta = thetas_boot)) +
    geom_histogram(aes(x = theta, y = ..density..), binwidth = 0.02, 
        fill = "gray40") + 
    geom_vline(aes(xintercept = mean(theta)), color = "red") +
    labs(x = expression(hat(theta)^"*"), y = "")
```

<img src="05-bootstrap_no_parametrico_files/figure-html/pc_hist-1.png" width="300px" style="display: block; margin: auto;" />

Estas tienen un error estándar


```r
theta_se <- sd(thetas_boot)
theta_se
#> [1] 0.04657769
```

y media


```r
mean(thetas_boot)
#> [1] 0.6199592
```

la media de las replicaciones es muy similar a la estimación $\hat{\theta}$, 
esto indica que $\hat{\theta}$ es cercano a insesgado. 

2. El eigenvetor $\hat{v}_1$ correspondiente al mayor eigenvalor se conoce
como primera componente de $G$, supongamos que deseamos resumir la calificación
de los estudiantes mediante un único número, entonces la mejor combinación 
lineal de los puntajes es 

$$y_i = \sum_{k = 1}^5 \hat{v}_{1k}x_{ik}$$

esto es, la combinación lineal que utiliza las componentes de $\hat{v}_1$ como
ponderadores. Si queremos un resumen compuesto por dos números $(y_i,z_i)$, la
segunda combinación lineal debería ser:

$$z_i = \sum_{k = 1}^5 \hat{v}_{2k}x_{ik}$$

![](img/manicule2.jpg) Las componentes principales $\hat{v}_1$ y 
$\hat{v}_2$ son estadísticos, usa bootstrap para dar una medición de su 
variabilidad calculando el error estándar de cada una.



## Intervalos de confianza

Hasta ahora hemos discutido la idea detrás del bootstrap y como se puede usar 
para estimar errores estándar. Comenzamos con el error estándar pues es la 
manera más común para describir la precisión de una estadística. 

* En términos generales, esperamos que $\bar{x}$ este a una distancia de $\mu_P$ 
menor a un error estándar el 68% del tiempo, y a menos de 2 errores estándar el 
95% del tiempo. 

* Estos porcentajes están basados el teorema central del límite que nos dice que 
bajo ciertas condiciones (bastante generales) de $P$ la distribución de 
$\bar{x}$ se aproximará a una distribución normal:

$$\bar{x} \overset{\cdot}{\sim} N(\mu_P,\sigma_P^2/n)$$

Veamos algunos ejemplos de como funciona el Teorema del Límite
Central, buscamos ver como se aproxima la distribución muestral de la media 
(cuando las observaciones provienen de distintas distribuciones) a una 
Normal conforme aumenta el tamaño de muestra. Para esto, aproximamos la 
distribución muestral de la media usando simulación de la población.

Vale la pena observar que hay distribuciones que requieren un mayor tamaño 
de muestra $n$ para lograr una buena aproximación (por ejemplo la log-normal), 
¿a qué se debe esto?

Para la opción de *Elecciones* tenemos una población de tamaño $N=143,437$ y el 
objetivo es estimar la media del tamaño de la lista nominal de las casillas 
(datos de las elecciones presidenciales de 2012). Podemos ver como mejora la 
aproximación Normal de la distribución muestral conforme aumenta el tamaño de 
muestra $n$; sin embargo, también sobresale que no es necesario tomar una 
muestra demasiado grande ($n = 60$ ya es razonable).

```r
knitr::include_app("https://tereom.shinyapps.io/15-TLC/", height = "1000px")
```

<iframe src="https://tereom.shinyapps.io/15-TLC/?showcase=0" width="672" height="1000px"></iframe>

En lo que sigue veremos distintas maneras de construir intervalos de confianza 
usando bootstrap.

<div class="caja">
Un **intervalo de confianza** $(1-2\alpha)$% para un parámetro $\theta$ es un 
intervalo $(a,b)$ tal que $P(a \le \theta \le b) = 1-2\alpha$ para todo 
$\theta \in \Theta$.
</div>

Y comenzamos con la versión bootstrap del intervalo más popular.

<div class="caja">
1. **Intervalo Normal** con error estándar bootstrap. 
El intervalo para $\hat{\theta}$ con un nivel de confianza de 
$100\cdot(1-2\alpha)\%$ se define como:

$$(\hat{\theta}-z^{(1-\alpha)}\cdot \hat{se}_B, \hat{\theta}+z^{(1-\alpha)}\cdot \hat{se})$$.

donde $z^{(\alpha)}$ denota el percentil $100\cdot \alpha$ de una 
distribución $N(0,1)$.
</div>

este intervalo está soportado por el Teorema Central del Límite, sin embargo,
no es adecuado cuando $\hat{\theta}$ no se distribuye aproximadamente Normal.


#### Ejemplo: kurtosis {-}

Supongamos que queremos estimar la kurtosis de una base de datos que consta de
799 tiempos de espera entre pulsasiones de un nervio (Cox, Lewis 1976).

$$\hat{\theta} = t(P_n) =\frac{1/n \sum_{i=1}^n(x_i-\hat{\mu})^3}{\hat{\sigma}^3}$$


```r
library(ACSWR)
data("nerve")
head(nerve)
#> [1] 0.21 0.03 0.05 0.11 0.59 0.06

kurtosis <- function(x){
    n <- length(x)
    1 / n * sum((x - mean(x)) ^ 3) / sd(x) ^ 3 
}

theta_hat <- kurtosis(nerve)
theta_hat
#> [1] 1.757943

kurtosis_boot <- function(x){
  x_boot <- sample(x, replace = TRUE)
  kurtosis(x_boot)
}
B <- 10000
kurtosis <- rerun(B, kurtosis_boot(nerve)) %>% 
  flatten_dbl()
```

Usando el intervalo normal tenemos:


```r
li_normal <- round(theta_hat - 1.96 * sd(kurtosis), 2)
ls_normal <- round(theta_hat + 1.96 * sd(kurtosis), 2)
c(li_normal, ls_normal)
#> [1] 1.44 2.08
```

Una modificación común del intervalo normal es el intervalo t, estos intervalos
son mejores en caso de muestras pequeñas ($n$ chica).

<div class="caja">
2. **Intervalo $t$** con error estándar bootstrap. Para una muestra de tamaño 
$n$ el intervalo $t$ con un nivel de confianza de  $100\cdot(1-2\alpha)\%$ se
define como:

$$(\hat{\theta}-t^{(1-\alpha)}_{n-1}\cdot \hat{se}_B, \hat{\theta}+t^{(1-\alpha)}_{n-1}\cdot \hat{se}_B)$$.

donde $t^{(\alpha)}_{n-1}$ denota denota el percentil $100\cdot \alpha$ de una 
distribución $t$ con $n-1$ grados de libertad.
</div>



```r
n_nerve <- length(nerve)
li_t <- round(theta_hat + qt(0.025, n_nerve - 1) * sd(kurtosis), 2)
ls_t <- round(theta_hat - qt(0.025, n_nerve - 1) * sd(kurtosis), 2)
c(li_t, ls_t)
#> [1] 1.44 2.08
```

Los intervalos normales y $t$ se valen de la estimación bootstrap del error 
estándar; sin embargo, el bootstrap se puede usar para estimar la función de
distribución de $\hat{\theta}$ por lo que no es necesario hacer supuestos
distribucionales para $\hat{\theta}$ sino que podemos estimarla como parte del
proceso de construir intervalos de confianza.

Veamos un histograma de las replicaciones bootstrap de $\hat{\theta}^*$


```r
library(gridExtra)
nerve_kurtosis <- tibble(kurtosis)
hist_nerve <- ggplot(nerve_kurtosis, aes(x = kurtosis)) + 
        geom_histogram(binwidth = 0.05, fill = "gray30") +
            geom_vline(xintercept = c(li_normal, ls_normal, theta_hat), 
            color = c("black", "black", "red"), alpha = 0.5)

qq_nerve <- ggplot(nerve_kurtosis) +
  geom_abline(color = "red", alpha = 0.5) +
  stat_qq(aes(sample = kurtosis), dparams = list(mean = mean(kurtosis), sd = sd(kurtosis))) 

grid.arrange(hist_nerve, qq_nerve, ncol = 2, newpage = FALSE)
```

<img src="05-bootstrap_no_parametrico_files/figure-html/unnamed-chunk-19-1.png" width="816" style="display: block; margin: auto;" />

En el ejemplo anterior el supuesto de normalidad parece razonable, veamos 
como se comparan los cuantiles de la estimación de la distribución de 
$\hat{\theta}$ con los cuantiles de una normal:


```r
comma(q_kurt <- quantile(kurtosis, 
  probs = c(0.025, 0.05, 0.1, 0.9, 0.95, 0.975)))
comma(qnorm(p = c(0.025, 0.05, 0.1, 0.9, 0.95, 0.975), mean = theta_hat, 
  sd = sd(kurtosis)))
#>  2.5%    5%   10%   90%   95% 97.5% 
#> "1.4" "1.5" "1.5" "2.0" "2.0" "2.1" 
#> [1] "1.4" "1.5" "1.5" "2.0" "2.0" "2.1"
```

Esto sugiere usar los cuantiles del histograma bootstrap para definir los 
límites de los intervalos de confianza:

<div class="caja">
3. **Percentiles**. Denotemos por $G$ la función de distribución acumulada de
$\hat{\theta}^*$ el intervalo percentil de $1-2\alpha$ se define por los 
percentiles $\alpha$ y $1-\alpha$ de $G$
$$(\theta^*_{\%,inf}, \theta^*_{\%,sup}) = (G^{-1}(\alpha), G^{-1}(1-\alpha))$$
Por definición $G^{-1}(\alpha)=\hat{\theta}^*(\alpha)$, esto es, el percentil 
$100\cdot \alpha$ de la distribución bootstrap, por lo que podemos escribir el
intervalo bootstrap como 
$$(\theta^*_{\%,inf}, \theta^*_{\%,sup})=(\hat{\theta}^*(\alpha),\hat{\theta}^*(1-\alpha))$$
</div>


```r
ggplot(arrange(nerve_kurtosis, kurtosis)) + 
    stat_ecdf(aes(x = kurtosis)) + 
    geom_segment(data = data_frame(x = c(-Inf, -Inf, q_kurt[c(1, 6)]), 
        xend = q_kurt[c(1, 6, 1, 6)], y = c(0.025, 0.975, 0, 0), 
        yend = c(0.025, 0.975, 0.025, 0.975)), aes(x = x, xend = xend, y = y, 
        yend = yend), color = "red", size = 0.4, alpha = 0.5) + 
  labs(x = "Cuantiles muestrales", y = "ecdf")
```

<img src="05-bootstrap_no_parametrico_files/figure-html/unnamed-chunk-21-1.png" width="384" style="display: block; margin: auto;" />

Las expresiones de arriba hacen referencia a la situación bootstrap _ideal_ 
donde el número de replicaciones bootstrap es infinito, en la práctica usamos
aproximaciones. Y se procede como sigue:

<div style="caja">
Intervalo percentil:

+ Generamos B muestras bootstrap independientes $\textbf{x}^{*1},..., \textbf{x}^{*B}$ y calculamos las replicaciones $\hat{\theta}^{*b}=s(x^{*b}).$  

+ Sea $\hat{\theta}^{*}_B(\alpha)$ el percentil $100\cdot\alpha$ de la 
distribución empírica de $\hat{\theta}^{*}$, y $\hat{\theta}^{*}_B(1-\alpha)$
el correspondiente al percentil $100\cdot (1-\alpha)$, escribimos el intervalo
de percentil $1-2\alpha$ como 
$$(\theta^*_{\%,inf}, \theta^*_{\%,sup})\approx(\hat{\theta}^*_B(\alpha),\hat{\theta}^*_B(1-\alpha))$$
</div>



```r
ls_per <- round(quantile(kurtosis, probs = 0.975), 2)
li_per <- round(quantile(kurtosis, probs = 0.025), 2)
stringr::str_c(li_normal, ls_normal, sep = ",")
stringr::str_c(li_per, ls_per, sep = ",")
#> [1] "1.44,2.08"
#> [1] "1.43,2.07"
```

Si la distribución de $\hat{\theta}^*$ es aproximadamente normal, entonces 
los intervalos normales y de percentiles serán similares.

Con el fin de comparar los intervalos creamos un ejemplo de simulación 
(ejemplo tomado de @efron), generamos una muestra de tamaño 10 de una 
distribución normal estándar, supongamos que el parámetro de interés es 
$e^{\mu}$ donde $\mu$ es la media poblacional.


```r
set.seed(137612)
x <- rnorm(10)

boot_sim_exp <- function(){
  x_boot <- sample(x, size = 10, replace = TRUE)
  exp(mean(x_boot))
}
theta_boot <- rerun(1000, boot_sim_exp()) %>% flatten_dbl()
theta_boot_df <- data_frame(theta_boot)

hist_emu <- ggplot(theta_boot_df, aes(x = theta_boot)) +
    geom_histogram(fill = "gray30", binwidth = 0.08) 
qq_emu <- ggplot(theta_boot_df) +
    geom_abline(color = "red", alpha = 0.5) +
    stat_qq(aes(sample = theta_boot), 
        dparams = list(mean = mean(theta_boot), sd = sd(theta_boot))) 

grid.arrange(hist_emu, qq_emu, ncol = 2, newpage = FALSE)
```

<img src="05-bootstrap_no_parametrico_files/figure-html/unnamed-chunk-23-1.png" width="816" style="display: block; margin: auto;" />

La distribución empírica de $\hat{\theta}^*$ es asimétrica, por lo que no
esperamos que coincidan los intervalos.


```r
# Normal
round(exp(mean(x)) - 1.96 * sd(theta_boot), 2)
#> [1] 0.36
round(exp(mean(x)) + 1.96 * sd(theta_boot), 2)
#> [1] 1.6

#Percentil
round(quantile(theta_boot, prob = 0.025), 2)
#> 2.5% 
#> 0.53
round(quantile(theta_boot, prob = 0.975), 2)
#> 97.5% 
#>  1.79
```

La inspección del histograma deja claro que la aproximación normal no es
conveniente en este caso, veamos que ocurre cuando aplicamos la transformación
logarítmica.


```r
hist_log <- ggplot(data_frame(theta_boot), aes(x = log(theta_boot))) +
  geom_histogram(fill = "gray30", binwidth = 0.08) 
qq_log <- ggplot(data_frame(theta_boot)) +
    geom_abline(color = "red", alpha = 0.5) +
    stat_qq(aes(sample = log(theta_boot)), 
        dparams = list(mean = mean(log(theta_boot)), sd = sd(log(theta_boot)))) 

grid.arrange(hist_log, qq_log, ncol = 2, newpage = FALSE)
```

<img src="05-bootstrap_no_parametrico_files/figure-html/unnamed-chunk-25-1.png" width="816" style="display: block; margin: auto;" />

Y los intervalos se comparan:


```r
# Normal
round(mean(x) - 1.96 * sd(log(theta_boot)), 2)
#> [1] -0.63
round(mean(x) + 1.96 * sd(log(theta_boot)), 2)
#> [1] 0.58

#Percentil
round(quantile(log(theta_boot), prob = 0.025), 2)
#>  2.5% 
#> -0.63
round(quantile(log(theta_boot), prob = 0.975), 2)
#> 97.5% 
#>  0.58
```

La transformación logarítmica convierte la distribución de $\hat{\theta}$ en 
normal y por tanto los intervalos de $\hat{\phi}^*=log(\hat{\theta}^*)$ son
similares. La forma normal no es sorprendente pues  $\hat{\phi}^*=\bar{x}^*$. 

Si mapeamos los intervalos normales calculados para $log(\hat{\theta}^*)$ de 
regreso a la escala de $\theta$ obtenemos intervalos similares a los calculados
para $\hat{\theta}^*$ usando percentiles:


```r
exp(round(mean(x) - 1.96 * sd(log(theta_boot)), 2))
#> [1] 0.5325918
exp(round(mean(x) + 1.96 * sd(log(theta_boot)), 2))
#> [1] 1.786038
```

Podemos ver que el método de aplicar una transformación, calcular intervalos 
usando la normal y aplicar la transformación inversa para volver a la escala
original genera intervalos de confianza atractivos, el problema con este 
método es que requiere que conozcamos la transformación adecuada para cada 
parámetro. 

Por otra parte, podemos pensar en el método del percentil como un 
algoritmo que incorpora la transformación de manera automática.

<div class="caja">
**Lema**. Supongamos que la transformación $\hat{\phi}=m(\hat{\theta})$ 
normaliza la distribución de $\hat{\theta}$ de manera perfecta, 
$$\hat{\phi} \approx N(\phi, c^2)$$
para alguna desviación estándar $c$. Entonces el intervalo de percentil basado
en $\hat{\theta}$ es igual a 
$$(m^{-1} (\hat{\phi}-z^{(1-\alpha)}c), m^{-1}(\hat{\phi}-z^{(\alpha)}c))$$
</div>

Se dice que el intervalo de confianza de percentiles es **invariante a transformaciones**.

Existen otras alternativas al método del percentil y cubren otras fallas del 
intervalo normal. Por ejemplo, hay ocasiones en que $\hat{\theta}$ tiene una
distribución normal sesgada:
$$\hat{\theta} \approx N(\theta + sesgo, \hat{se}^2)$$

en este caso no existe una transformación $m(\theta)$ que _arregle_ el 
intervalo.

<div class="caja">
3. **Intervalos acelerados y corregidos por sesgo**. Esta es una versión 
mejorada del intervalo de percentil, la denotamos $BC_{a}$ (*bias-corrected and 
accelerated*).
</div>

Usaremos un ejemplo de @efron, los datos constan de los resultados 
en dos pruebas espaciales de 26 niños con discapacidad neurológico. Supongamos
que queremos calcular un intervalo de confianza de 90\% para $\theta=var(A)$.

El estimador plugin es:
$$\hat{\theta}=\sum_{i=1}^n(A_i-\bar{A})^2/n$$
notemos que el estimador _plug-in_ es ligeramente menor que el estimador
usual insesgado:
$$\hat{\theta}=\sum_{i=1}^n(A_i-\bar{A})^2/(n-1)$$



```r
library(bootstrap)

spatial
#>      A  B
#> V1  48 42
#> V2  36 33
#> V3  20 16
#> V4  29 39
#> V5  42 38
#> V6  42 36
#> V7  20 15
#> V8  42 33
#> V9  22 20
#> V10 41 43
#> V11 45 34
#> V12 14 22
#> V13  6  7
#> V14  0 15
#> V15 33 34
#> V16 28 29
#> V17 34 41
#> V18  4 13
#> V19 32 38
#> V20 24 25
#> V21 47 27
#> V22 41 41
#> V23 24 28
#> V24 26 14
#> V25 30 28
#> V26 41 40

ggplot(spatial) +
    geom_point(aes(A, B))
```

<img src="05-bootstrap_no_parametrico_files/figure-html/spatial-1.png" width="336" style="display: block; margin: auto;" />

El estimador *plug-in* de $\theta$ es 


```r
sum((spatial$A - mean(spatial$A)) ^ 2) / nrow(spatial)
#> [1] 171.534
```

Notemos que es ligeramente menor que el estimador insesgado:


```r
sum((spatial$A - mean(spatial$A)) ^ 2) / (nrow(spatial) - 1)
#> [1] 178.3954
```

El método $BC_{a}$ corrige el sesgo de manera automática, lo cuál es una 
de sus prinicipales ventajas comparado con el método del percentil.

Los extremos en los intervalos $BC_{a}$ están dados por percentiles de la
distribución bootstrap, los percentiles usados dependen de dos números $\hat{a}$
y $\hat{z}_0$, que se denominan la aceleración y la corrección del sesgo:
$$BC_a : (\hat{\theta}_{inf}, \hat{\theta}_{sup})=(\hat{\theta}^*(\alpha_1), \hat{\theta}^*(\alpha_2))$$ 
donde 
$$\alpha_1= \Phi\bigg(\hat{z}_0 + \frac{\hat{z}_0 + z^{(\alpha)}}{1- \hat{a}(\hat{z}_0 + z^{(\alpha)})}\bigg)$$
$$\alpha_2= \Phi\bigg(\hat{z}_0 + \frac{\hat{z}_0 + z^{(1-\alpha)}}{1- \hat{a}(\hat{z}_0 + z^{(1-\alpha)})}\bigg)$$
y $\Phi$ es la función de distribución acumulada de la distribución normal estándar
y $z^{\alpha}$ es el percentil $100 \cdot \alpha$ de una distribución normal
estándar.

Notemos que si $\hat{a}$ y $\hat{z}_0$ son cero entonces $\alpha_1=\alpha$  
y $\alpha_2=1-\alpha$, obteniendo así los intervalos de percentiles.
El valor de la corrección por sesgo $\hat{z}_0$ se obtiene de la 
propoción de de replicaciones bootstrap menores a la estimación original 
$\hat{\theta}$, 

$$z_0=\Phi^{-1}\bigg(\frac{\#\{\hat{\theta}^*(b) < \hat{\theta} \} }{B} \bigg)$$

a grandes razgos $\hat{z}_0$ mide la mediana del sesgo de $\hat{\theta}^*$, esto 
es, la discrepancia entre la mediana de $\hat{\theta}^*$ y $\hat{\theta}$ en 
unidades normales.

Por su parte la aceleración $\hat{a}$ se refiere a la tasa de cambio del error 
estándar de $\hat{\theta}$ respecto al verdadero valor del parámetro $\theta$. 
La aproximación estándar usual $\hat{\theta} \approx N(\theta, se^2)$ supone que 
el error estándar de $\hat{\theta}$ es el mismo para toda $\hat{\theta}$, esto 
puede ser poco realista, en nuestro ejemplo, donde $\hat{\theta}$ es la varianza
si los datos provienen de una normal $se(\hat{\theta})$ depende de $\theta$. 
Una manera de calcular $\hat{a}$ es

$$\hat{a}=\frac{\sum_{i=1}^n (\hat{\theta}(\cdot) - \hat{\theta}(i))^3}{6\{\sum_{i=1}^n (\hat{\theta}(\cdot) - \hat{\theta}(i))^2\}^{3/2}}$$

Los intervalos $BC_{a}$ tienen 2 ventajas teóricas: 

1. Respetan transformaciones, esto nos dice que los extremos del intervalo se 
transforman de manera adecuada si cambiamos el parámetro de interés por una
función del mismo.

2. Su exactitud, los intervalos $BC_{a}$ tienen precisión de segundo orden, esto
es, los errores de cobertura se van a cero a una tasa de 1/n.

Los intervalos $BC_{a}$ están implementados en el paquete boot (`boot.ci()`) y 
en el paquete bootstrap (`bcanon()`). La desventaja de los intervalos $BC_{a}$ es 
que requieren intenso cómputo estadístico, de acuerdo a @efron al
menos $B= 1000$ replicaciones son necesarias para reducir el error de muestreo.

Ante esto surgen los intervalos ABC (approximate bootstrap confidence 
intervals), que es un método para aproximar $BC_{a}$ analíticamente (usando
expansiones de Taylor), estos intervalos requieren que la estadística 
$\hat{\theta} = s(x)$ este definida de manera suave sobre x (la mediana, por 
ejemplo, no es suave).

Usando la implementación del paquete bootstrap:


```r
var_sesgada <- function(x) sum((x - mean(x)) ^ 2) / length(x)
bcanon(x = spatial[, 1], nboot = 2000, theta = var_sesgada, alpha = c(0.025, 0.975))
#> $confpoints
#>      alpha bca point
#> [1,] 0.025  103.8402
#> [2,] 0.975  274.0533
#> 
#> $z0
#> [1] 0.1383042
#> 
#> $acc
#> [1] 0.06124012
#> 
#> $u
#>  [1] 164.3936 176.7200 174.5184 178.3776 172.0544 172.0544 174.5184
#>  [8] 172.0544 175.9584 173.0400 168.5984 168.2016 155.1200 141.8144
#> [15] 177.9296 178.2816 177.6096 151.0176 178.1664 177.0656 165.8784
#> [22] 173.0400 177.0656 177.8400 178.3904 173.0400
#> 
#> $call
#> bcanon(x = spatial[, 1], nboot = 2000, theta = var_sesgada, alpha = c(0.025, 
#>     0.975))
```

![](img/manicule2.jpg) Comapara el intervalo anterior con los intervalos
normal y de percentiles.

Otros intervalos basados en bootstrap incluyen los intervalos pivotales y los 
intervalos bootstrap-t. Sin embargo, BC y ABC son mejores alternativas.

<div class="caja">
4. **Intervalos pivotales**. Sea $\theta=s(P)$ y $\hat{\theta}=s(P_n)$ definimos
el pivote $R=\hat{\theta}-\theta$. Sea $H(r)$ la función de distribución 
acumulada del pivote:
$$H(r) = P(R<r)$$

Definimos $C_n^*=(a,b)$ donde:
$$a=\hat{\theta}-H^{-1}(1-\alpha), b=\hat{\theta}-H^{-1}(\alpha)$$
$C_n^*$ es un intervalo de confianza de $1-2\alpha$ para $\theta$; sin
embargo, $a$ y $b$ dependen de la distribución desconocida $H$, la podemos
estimar usando bootstrap:
$$\hat{H}(r)=\frac{1}{B}\sum_{b=1}^B I(R^*_b \le r)$$
 y obtenemos
$$C_n=(2\hat{\theta} - \hat{\theta}^*_{1-\alpha}, 2\hat{\theta} + \hat{\theta}^*_{1-\alpha})$$
</div>

<div class="caja">
**Exactitud en intervalos de confianza.** Un intervalo de $95%$ de confianza
exacto no captura el verdadero valor $2.5%$ de las veces, en cada lado.

Un intervalo que sub-cubre un lado y sobre-cubre el otro es **sesgado**.
</div>

* Los intervalos estándar y de percentiles tienen exactitud de primer 
orden: los errores de cobertura se van a cero a una tasa de $1/\sqrt{n}$. Suelen
ser demasido estrechos resultando en cobertura real menor a la nominal, 
sobretodo con muestras chicas.

* Los intervalos $BC_a$ tienen exactitud de segundo 
orden: los errores de cobertura se van a cero a una tasa de $1/n$.

* A pesar de que los intervalos $BC_a$ pueden ser superiores a los intervalos
normales y de percentiles, en la práctica es más común utilizar intervalos
normales o de percentiles pues su implementación es más sencilla y son 
adecuados para un gran número de casos.


## Más alla de muestras aleatorias simples

Introdujimos el bootstrap en el contexto de muestras aleatorias, esto es,
suponiendo que las observaciones son independientes; en este escenario basta con
aproximar la distribución desconocida $P$ usando la dsitribución empírica $P_n$, 
y el cálculo de los estadísticos es inmediato. Hay casos en los que el mecanismo
que generó los datos es más complicado, por ejemplo, cuando tenemos dos 
muestras, en diseños de encuestas complejas o en series de 
tiempo.

#### Ejemplo: Dos muestras {-}

En el ejemplo de experimentos clínicos de aspirina y ataques de de corazón, 
podemos pensar el modelo probabilístico $P$ como compuesto por dos 
distribuciones de probabilidad $G$ y $Q$ una correspondiente al grupo control y
otra al grupo de tratamiento, entonces las observaciones de 
cada grupo provienen de distribuciones distintas y el método bootstrap debe 
tomar en cuenta esto al generar las muestras, en este caso implica seleccionar 
muesreas de manera independiente dentro de cada grupo.

#### Ejemplo: Bootstrap en muestreo de encuestas {-}

La necesidad de estimaciones confiables junto con el uso eficiente de recursos
conllevan a diseños de muestras complejas. Estos diseños típicamente usan las
siguientes técnicas: muestreo sin reemplazo de una población finita, muestreo
sistemático, estratificación, conglomerados, ajustes a no-respuesta, 
postestratificación. Como consecuencia, los valores de la muestra suelen no ser
independientes.

La complejidad de los diseños de encuestas conlleva a que el cálculo de errores
estándar sea muy complicado, para atacar este problema hay dos técnicas básicas:
1) un enfoque analítico usando linearización, 2) métodos de remuestreo como 
bootstrap. El incremento en el poder de cómputo ha favorecido los métodos de
remuestreo pues la linearización requiere del desarrollo de una fórmula para 
cada estimación y supuestos adicionales para simplificar.

En 1988 @RaoWu propusieron un método de bootstrap para diseños 
estratificados multietápicos con reemplazo de UPMs que describimos a 
continuación.

**ENIGH**. Usaremos como ejemplo la Encuesta Nacional de Ingresos y 
Gastos de los Hogares, ENIGH 2018 [@enigh], esta encuesta usa un diseño de 
conglomerados estratificado.

Antes de proceder a bootstrap debemos entender como se seleccionaron los datos,
esto es, el [diseño de la muestra](https://www.inegi.org.mx/contenidos/programas/enigh/nc/2018/doc/enigh18_diseno_muestral_ns.pdf):

1. Unidad primaria de muestreo (UPM). Las UPMs están constituidas por 
agrupaciones de viviendas. Se les denomina unidades primarias pues corresponden
a la primera etapa de selección, las unidades secundarias (USMs) serían los 
hogares.

2. Estratificación. Los estratos se construyen en base a estado, ámbito (urbano, 
complemento urbano, rural), características sociodemográficas de los habitantes
de las viviendas, características físicas y equipamiento. El proceso de 
estratificación resulta en 888 subestratos en todo el ámbito nacional.

3. La selección de la muestra es independiente para cada estrato, y una 
vez que se obtiene la muestra se calculan los factores de expansión que 
reflejan las distintas probabilidades de selección. Después se llevan a cabo
ajustes por no respuesta y por proyección (calibración), esta última 
busca que distintos dominios de la muestra coincidan con la proyección de 
población de INEGI.


```r
library(usethis)
use_zip("https://www.inegi.org.mx/contenidos/programas/enigh/nc/2018/datosabiertos/conjunto_de_datos_enigh_2018_ns_csv.zip", "data")
```



```r
library(here)

concentrado_hogar <- read_csv(here("data", 
    "conjunto_de_datos_enigh_2018_ns_csv", 
    "conjunto_de_datos_concentradohogar_enigh_2018_ns", "conjunto_de_datos",
    "conjunto_de_datos_concentradohogar_enigh_2018_ns.csv"))
glimpse(concentrado_hogar)
#> Observations: 74,647
#> Variables: 126
#> $ folioviv   <dbl> 100013601, 100013602, 100013603, 100013604, 100013606…
#> $ foliohog   <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ ubica_geo  <dbl> 1001, 1001, 1001, 1001, 1001, 1001, 1001, 1001, 1001,…
#> $ tam_loc    <dbl> 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,…
#> $ est_socio  <dbl> 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,…
#> $ est_dis    <dbl> 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,…
#> $ upm        <dbl> 1, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4,…
#> $ factor     <dbl> 175, 175, 175, 175, 175, 189, 189, 189, 189, 186, 186…
#> $ clase_hog  <dbl> 2, 2, 2, 2, 2, 2, 1, 2, 2, 3, 2, 1, 2, 2, 2, 2, 3, 1,…
#> $ sexo_jefe  <dbl> 1, 1, 1, 2, 2, 2, 2, 1, 1, 1, 2, 1, 1, 1, 1, 1, 1, 1,…
#> $ edad_jefe  <dbl> 74, 48, 39, 70, 51, 41, 57, 53, 30, 69, 76, 77, 70, 2…
#> $ educa_jefe <dbl> 4, 11, 10, 8, 4, 11, 9, 11, 6, 4, 3, 4, 6, 6, 9, 7, 6…
#> $ tot_integ  <dbl> 3, 5, 2, 2, 4, 4, 1, 2, 3, 4, 2, 1, 2, 4, 4, 2, 5, 1,…
#> $ hombres    <dbl> 2, 2, 1, 1, 1, 2, 0, 1, 2, 4, 0, 1, 1, 2, 3, 1, 2, 1,…
#> $ mujeres    <dbl> 1, 3, 1, 1, 3, 2, 1, 1, 1, 0, 2, 0, 1, 2, 1, 1, 3, 0,…
#> $ mayores    <dbl> 3, 5, 2, 2, 3, 4, 1, 2, 2, 3, 2, 1, 2, 2, 4, 2, 5, 1,…
#> $ menores    <dbl> 0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 0, 0, 0, 2, 0, 0, 0, 0,…
#> $ p12_64     <dbl> 1, 5, 2, 1, 3, 4, 1, 2, 2, 2, 1, 0, 0, 2, 2, 0, 5, 1,…
#> $ p65mas     <dbl> 2, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 1, 2, 0, 2, 2, 0, 0,…
#> $ ocupados   <dbl> 2, 2, 2, 0, 2, 2, 1, 2, 2, 2, 1, 1, 1, 1, 2, 0, 4, 1,…
#> $ percep_ing <dbl> 3, 5, 2, 2, 2, 2, 1, 2, 2, 4, 2, 1, 2, 1, 4, 2, 4, 1,…
#> $ perc_ocupa <dbl> 2, 2, 2, 0, 2, 2, 1, 2, 2, 2, 1, 1, 1, 1, 2, 0, 4, 1,…
#> $ ing_cor    <dbl> 76403.70, 42987.73, 580697.74, 46252.71, 53837.09, 23…
#> $ ingtrab    <dbl> 53114.74, 15235.06, 141885.21, 0.00, 43229.49, 129836…
#> $ trabajo    <dbl> 53114.74, 0.00, 141885.21, 0.00, 8852.45, 129836.03, …
#> $ sueldos    <dbl> 53114.74, 0.00, 133770.48, 0.00, 8852.45, 95901.63, 2…
#> $ horas_extr <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ comisiones <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 22131.14, 0.00, 0.00, 0…
#> $ aguinaldo  <dbl> 0.00, 0.00, 3934.42, 0.00, 0.00, 11803.26, 0.00, 2213…
#> $ indemtrab  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ otra_rem   <dbl> 0.00, 0.00, 4180.31, 0.00, 0.00, 0.00, 0.00, 0.00, 0.…
#> $ remu_espec <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ negocio    <dbl> 0.00, 13759.66, 0.00, 0.00, 34377.04, 0.00, 0.00, 0.0…
#> $ noagrop    <dbl> 0.00, 13759.66, 0.00, 0.00, 34377.04, 0.00, 0.00, 0.0…
#> $ industria  <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ comercio   <dbl> 0.00, 0.00, 0.00, 0.00, 34377.04, 0.00, 0.00, 0.00, 0…
#> $ servicios  <dbl> 0.00, 13759.66, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0…
#> $ agrope     <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ agricolas  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ pecuarios  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ reproducc  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ pesca      <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ otros_trab <dbl> 0.0, 1475.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, …
#> $ rentas     <dbl> 0.00, 0.00, 29508.19, 0.00, 0.00, 0.00, 0.00, 0.00, 0…
#> $ utilidad   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ arrenda    <dbl> 0.00, 0.00, 29508.19, 0.00, 0.00, 0.00, 0.00, 0.00, 0…
#> $ transfer   <dbl> 11288.96, 3752.67, 391304.34, 34252.71, 107.60, 89906…
#> $ jubilacion <dbl> 9147.54, 0.00, 0.00, 23606.55, 0.00, 23606.55, 0.00, …
#> $ becas      <dbl> 0.0, 491.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0…
#> $ donativos  <dbl> 0.00, 147.54, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.0…
#> $ remesas    <dbl> 0.00, 98.36, 0.00, 5901.63, 0.00, 0.00, 0.00, 0.00, 0…
#> $ bene_gob   <dbl> 1622.95, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.…
#> $ transf_hog <dbl> 0.00, 3014.97, 0.00, 0.00, 107.60, 61714.26, 0.00, 0.…
#> $ trans_inst <dbl> 518.47, 0.00, 391304.34, 4744.53, 0.00, 4585.70, 0.00…
#> $ estim_alqu <dbl> 12000.00, 24000.00, 18000.00, 12000.00, 10500.00, 180…
#> $ otros_ing  <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ gasto_mon  <dbl> 18551.47, 55470.99, 103106.89, 19340.06, 13605.03, 33…
#> $ alimentos  <dbl> 5618.47, 20930.29, 37594.06, 2892.84, 7367.09, 0.00, …
#> $ ali_dentro <dbl> 4075.63, 8587.46, 25251.25, 2892.84, 4795.67, 0.00, 8…
#> $ cereales   <dbl> 964.25, 2689.65, 3728.53, 385.71, 257.14, 0.00, 437.1…
#> $ carnes     <dbl> 0.00, 1401.41, 2828.56, 2121.42, 2931.41, 0.00, 1787.…
#> $ pescado    <dbl> 745.71, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.0…
#> $ leche      <dbl> 0.00, 443.55, 4345.70, 0.00, 0.00, 0.00, 2841.41, 149…
#> $ huevo      <dbl> 719.98, 0.00, 411.42, 0.00, 0.00, 0.00, 308.57, 629.9…
#> $ aceites    <dbl> 0.00, 0.00, 1928.57, 0.00, 0.00, 0.00, 0.00, 0.00, 0.…
#> $ tuberculo  <dbl> 0.00, 257.14, 385.71, 0.00, 128.57, 0.00, 231.42, 411…
#> $ verduras   <dbl> 745.70, 1893.29, 2635.66, 0.00, 835.70, 0.00, 861.38,…
#> $ frutas     <dbl> 0.00, 533.16, 1864.27, 0.00, 0.00, 0.00, 244.27, 809.…
#> $ azucar     <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 257.14, 0.00, 0.0…
#> $ cafe       <dbl> 0.00, 462.85, 1414.28, 0.00, 0.00, 0.00, 964.28, 0.00…
#> $ especias   <dbl> 0.00, 167.14, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.0…
#> $ otros_alim <dbl> 0.00, 392.13, 2545.71, 385.71, 514.28, 0.00, 0.00, 26…
#> $ bebidas    <dbl> 899.99, 347.14, 3162.84, 0.00, 128.57, 0.00, 411.42, …
#> $ ali_fuera  <dbl> 771.42, 12342.83, 12342.81, 0.00, 2571.42, 0.00, 1928…
#> $ tabaco     <dbl> 771.42, 0.00, 0.00, 0.00, 0.00, 0.00, 1182.84, 0.00, …
#> $ vesti_calz <dbl> 0.00, 401.06, 2015.21, 97.82, 0.00, 0.00, 0.00, 1565.…
#> $ vestido    <dbl> 0.00, 224.98, 2015.21, 97.82, 0.00, 0.00, 0.00, 293.4…
#> $ calzado    <dbl> 0.00, 176.08, 0.00, 0.00, 0.00, 0.00, 0.00, 1271.73, …
#> $ vivienda   <dbl> 3912.00, 2495.00, 4475.00, 1458.00, 300.00, 2801.00, …
#> $ alquiler   <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 3900.…
#> $ pred_cons  <dbl> 0.00, 1250.00, 1250.00, 0.00, 0.00, 140.00, 250.00, 0…
#> $ agua       <dbl> 312.00, 750.00, 750.00, 600.00, 0.00, 741.00, 630.00,…
#> $ energia    <dbl> 3600.00, 495.00, 2475.00, 858.00, 300.00, 1920.00, 35…
#> $ limpieza   <dbl> 522.00, 412.16, 3318.26, 5514.00, 3300.00, 5682.00, 2…
#> $ cuidados   <dbl> 522.00, 375.00, 2340.00, 5514.00, 3300.00, 5682.00, 2…
#> $ utensilios <dbl> 0.00, 37.16, 978.26, 0.00, 0.00, 0.00, 195.65, 391.30…
#> $ enseres    <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 5901.63, 0.…
#> $ salud      <dbl> 0.00, 1348.99, 28858.68, 322.82, 56.73, 0.00, 4695.64…
#> $ atenc_ambu <dbl> 0.00, 1007.59, 28858.68, 0.00, 56.73, 0.00, 4695.64, …
#> $ hospital   <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ medicinas  <dbl> 0.00, 341.40, 0.00, 322.82, 0.00, 0.00, 0.00, 0.00, 0…
#> $ transporte <dbl> 8400.00, 7628.56, 12325.68, 7350.00, 600.00, 18235.70…
#> $ publico    <dbl> 0.00, 578.56, 4255.68, 0.00, 0.00, 1285.70, 0.00, 0.0…
#> $ foraneo    <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 590.16, 0.00, 0.0…
#> $ adqui_vehi <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ mantenim   <dbl> 7200.00, 3600.00, 4500.00, 6000.00, 0.00, 13200.00, 4…
#> $ refaccion  <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 2213.11, 0.00, 0.…
#> $ combus     <dbl> 7200.00, 3600.00, 4500.00, 6000.00, 0.00, 13200.00, 2…
#> $ comunica   <dbl> 1200.00, 3450.00, 3570.00, 1350.00, 600.00, 3750.00, …
#> $ educa_espa <dbl> 0.00, 17567.05, 0.00, 639.34, 0.00, 1800.00, 627.00, …
#> $ educacion  <dbl> 0.00, 8547.39, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.…
#> $ esparci    <dbl> 0.00, 167.21, 0.00, 639.34, 0.00, 1800.00, 627.00, 36…
#> $ paq_turist <dbl> 0.00, 8852.45, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.…
#> $ personales <dbl> 99.00, 4663.29, 8520.00, 1065.24, 1686.13, 5109.00, 3…
#> $ cuida_pers <dbl> 99.00, 1497.00, 8520.00, 180.00, 1647.00, 4509.00, 15…
#> $ acces_pers <dbl> 0.00, 166.29, 0.00, 0.00, 39.13, 0.00, 0.00, 0.00, 0.…
#> $ otros_gas  <dbl> 0.00, 3000.00, 0.00, 885.24, 0.00, 600.00, 1835.65, 0…
#> $ transf_gas <dbl> 0.00, 24.59, 6000.00, 0.00, 295.08, 0.00, 491.80, 236…
#> $ percep_tot <dbl> 0.00, 6073.09, 3857.14, 1380.55, 0.00, 1928.57, 489.1…
#> $ retiro_inv <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ prestamos  <dbl> 0.00, 7.37, 0.00, 737.70, 0.00, 0.00, 0.00, 0.00, 491…
#> $ otras_perc <dbl> 0.00, 462.28, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.0…
#> $ ero_nm_viv <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ ero_nm_hog <dbl> 0.00, 5603.44, 3857.14, 642.85, 0.00, 1928.57, 489.13…
#> $ erogac_tot <dbl> 0.00, 9009.82, 81147.53, 0.00, 0.00, 14754.09, 0.00, …
#> $ cuota_viv  <dbl> 0, 0, 0, 0, 0, 0, 0, 12000, 0, 0, 0, 0, 0, 0, 0, 0, 0…
#> $ mater_serv <dbl> 0.00, 147.54, 0.00, 0.00, 0.00, 0.00, 0.00, 7868.85, …
#> $ material   <dbl> 0.00, 147.54, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.0…
#> $ servicio   <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 7868.85, 0.…
#> $ deposito   <dbl> 0.00, 9.83, 66393.44, 0.00, 0.00, 0.00, 0.00, 0.00, 0…
#> $ prest_terc <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ pago_tarje <dbl> 0.00, 8852.45, 0.00, 0.00, 0.00, 14754.09, 0.00, 0.00…
#> $ deudas     <dbl> 0.00, 0.00, 14754.09, 0.00, 0.00, 0.00, 0.00, 38360.6…
#> $ balance    <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
#> $ otras_erog <dbl> 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,…
#> $ smg        <dbl> 7952.4, 7952.4, 7952.4, 7952.4, 7952.4, 7952.4, 7952.…

# seleccionar variable de ingreso corriente
hogar <- concentrado_hogar %>% 
    mutate(
        upm = as.integer(upm),
        jefe_hombre = sexo_jefe == 1, 
        edo = str_sub(ubica_geo, 1, 2), 
        jefa_50 = (sexo_jefe == 2) & (edad_jefe > 50)
        ) %>% 
    select(folioviv, foliohog, est_dis, upm, factor, ing_cor, sexo_jefe, 
       edad_jefe, edo, jefa_50) %>% 
    group_by(est_dis) %>% 
    mutate(n = n_distinct(upm)) %>% # número de upms por estrato
    ungroup()
hogar
#> # A tibble: 74,647 x 11
#>    folioviv foliohog est_dis   upm factor ing_cor sexo_jefe edad_jefe edo  
#>       <dbl>    <dbl>   <dbl> <int>  <dbl>   <dbl>     <dbl>     <dbl> <chr>
#>  1   1.00e8        1       2     1    175  76404.         1        74 10   
#>  2   1.00e8        1       2     1    175  42988.         1        48 10   
#>  3   1.00e8        1       2     1    175 580698.         1        39 10   
#>  4   1.00e8        1       2     1    175  46253.         2        70 10   
#>  5   1.00e8        1       2     1    175  53837.         2        51 10   
#>  6   1.00e8        1       2     2    189 237743.         2        41 10   
#>  7   1.00e8        1       2     2    189  32607.         2        57 10   
#>  8   1.00e8        1       2     2    189 169918.         1        53 10   
#>  9   1.00e8        1       2     2    189  17311.         1        30 10   
#> 10   1.00e8        1       2     3    186 120488.         1        69 10   
#> # … with 74,637 more rows, and 2 more variables: jefa_50 <lgl>, n <int>
```

Para el cálculo de estadísticos debemos usar los factores de expansión, por 
ejemplo el ingreso trimestral total sería:


```r
sum(hogar$factor * hogar$ing_cor / 1000)
#> [1] 1723700566
```

y ingreso trimestral medio (miles pesos)


```r
sum(hogar$factor * hogar$ing_cor / 1000) / sum(hogar$factor)
#> [1] 49.61029
```

La estimación del error estándar, por otro lado, no es sencilla y requiere
usar aproximaciones, en la metodología de INEGI proponen una aproximación con 
series de Taylor.


<div class="figure" style="text-align: center">
<img src="img/inegi_metodologia_razon.png" alt="Extracto de estimación de errores de muestreo, ENIGH 2018." width="400px" />
<p class="caption">(\#fig:unnamed-chunk-35)Extracto de estimación de errores de muestreo, ENIGH 2018.</p>
</div>

Veamos ahora como calcular el error estándar siguiendo el bootstrap de Rao y Wu:

1. En cada estrato se seleccionan con reemplazo $m_h$ UPMs de las $n_h$ de la
muestra original. Denotamos por $m_{hi}^*$ el número de veces que se seleccionó
la UPM $i$ en el estrato $h$ (de tal manera que $\sum m_{hi}^*=m_h$). Creamos
una replicación del ponderador correspondiente a la $k$-ésima unidad (USM) como:

$$d_k^*=d_k \bigg[\bigg(1-\sqrt{\frac{m_h}{n_h - 1}}\bigg) + 
\bigg(\sqrt{\frac{m_h}{n_h - 1}}\frac{n_h}{m_h}m_{h}^*\bigg)\bigg]$$

donde $d_k$ es el inverso de la probabilidad de selección. Si $m_h<(n_h -1)$ 
todos los pesos definidos de esta manera serán no negativos. Calculamos el 
peso final $w_k^*$ aplicando a $d_k^*$ los mismos ajustes que se hicieron a los 
ponderadores originales.

2. Calculamos el estadístico de interés $\hat{\theta}$ usando los ponderadores
$w_k^*$ en lugar de los originales $w_k$.

3. Repetimos los pasos 1 y 2 $B$ veces para obtener $\hat{\theta}^{*1},\hat{\theta}^{*2},...,\hat{\theta}^{*B}$.

4. Calculamos el error estándar como:

$$\hat{se}_B = \bigg\{\frac{\sum_{b=1}^B[\hat{\theta}^*(b)-\hat{\theta}^*(\cdot)]^2 }{B}\bigg\}^{1/2}$$

Podemos elegir cualquier valor de $m_h \geq 1$, el más sencillo es elegir
$m_h=n_h-1$, en este caso:
$$d_k^*=d_k \frac{n_h}{n_h-1}m_{hi}^*$$
en este escenario las unidades que no se incluyen en la muestra tienen 
un valor de cero como ponderador. Si elegimos $n_h \ne n_h-1$ las unidades que 
no están en la muestra tienen ponderador distinto a cero, si $m_h=n_h$ el
ponderador podría tomar valores negativos.

Implementemos el bootstrap de Rao y Wu a la ENIGH, usaremos $m_h=n_h-1$


```r
# creamos una tabla con los estratos y upms
est_upm <- hogar %>% 
    distinct(est_dis, upm, n)

hogar_factor <- est_upm %>% 
    split(.$est_dis) %>% # dentro de cada estrato tomamos muestra (n_h-1)
    map_df(~sample_n(., size = first(.$n) - 1, replace = TRUE)) %>% 
    add_count(upm, name = "m_hi") %>% # calculamos m_hi*
    left_join(hogar, by = c("est_dis", "upm", "n")) %>% 
    mutate(factor_b = factor * m_hi * n / (n - 1))

# unimos los pasos anteriores en una función para replicar en cada muestra bootstrap
svy_boot <- function(est_upm, hogar){
    m_hi <- est_upm %>% 
        split(.$est_dis) %>% 
        map(~sample(.$upm, size = first(.$n) - 1, replace = TRUE)) %>% 
        flatten_int() %>% 
        plyr::count() %>% 
        select(upm = x, m_h = freq)
    m_hi %>% 
        left_join(hogar, by = c("upm")) %>% 
        mutate(factor_b = factor * m_h * n / (n - 1))
}
set.seed(1038984)
boot_rep <- rerun(500, svy_boot(est_upm, hogar))

# Aplicación a ingreso medio
wtd_mean <- function(w, x, na.rm = FALSE) {
    sum(w * x, na.rm = na.rm) / sum(w, na.rm = na.rm)
} 

# La media es:
hogar %>% 
    summarise(media = wtd_mean(factor, ing_cor))
#> # A tibble: 1 x 1
#>    media
#>    <dbl>
#> 1 49610.
```

Y el error estándar:


```r
map_dbl(boot_rep, ~wtd_mean(w = .$factor_b, x = .$ing_cor)) %>% sd()
#> [1] 441.0439
```


El método bootstrap está implementado en el paquete `survey` y más recientemente 
en `srvyr` que es una versión *tidy* que utiliza las funciones en `survey`. 

Podemos comparar nuestros resultados con la implementación en `survey`.


```r
# 1. Definimos el diseño de la encuesta
library(survey)
library(srvyr)

enigh_design <- hogar %>% 
    as_survey_design(ids = upm, weights = factor, strata = est_dis)

# 2. Elegimos bootstrap como el método para el cálculo de errores estándar
set.seed(7398731)
enigh_boot <- enigh_design %>% 
    as_survey_rep(type = "subbootstrap", replicates = 500)

# 3. Así calculamos la media
enigh_boot %>% 
    srvyr::summarise(mean_ingcor = survey_mean(ing_cor))
#> # A tibble: 1 x 2
#>   mean_ingcor mean_ingcor_se
#>         <dbl>          <dbl>
#> 1      49610.           459.

enigh_boot %>% 
    group_by(edo) %>% 
    srvyr::summarise(mean_ingcor = survey_mean(ing_cor)) 
#> # A tibble: 30 x 3
#>    edo   mean_ingcor mean_ingcor_se
#>    <chr>       <dbl>          <dbl>
#>  1 10         50161.           942.
#>  2 11         46142.          1252.
#>  3 12         29334.          1067.
#>  4 13         38783.           933.
#>  5 14         60541.          1873.
#>  6 15         48013.          1245.
#>  7 16         42653.          1239.
#>  8 17         42973.          1675.
#>  9 18         48148.          1822.
#> 10 19         68959.          3625.
#> # … with 20 more rows

# cuantiles
svyquantile(~ing_cor, enigh_boot, quantiles = seq(0.1, 1, 0.1), 
    interval.type = "quantile")
#> Statistic:
#>         ing_cor
#> q0.1   13155.75
#> q0.2   18895.37
#> q0.3   24041.89
#> q0.4   29358.29
#> q0.5   35505.47
#> q0.6   42695.44
#> q0.7   52426.32
#> q0.8   66594.08
#> q0.9   94613.04
#> q1   4501830.28
#> SE:
#>          ing_cor
#> q0.1    114.2707
#> q0.2    110.1885
#> q0.3    130.8151
#> q0.4    152.8712
#> q0.5    199.3702
#> q0.6    241.1244
#> q0.7    339.4501
#> q0.8    479.4980
#> q0.9    908.6814
#> q1   384477.9727
```

Supongamos que queremos calcular la media para los hogares con jefe de familia
mujer mayor a 50 años.


```r
# Creamos datos con filter y repetimos lo de arriba
hogar_mujer <- filter(hogar, jefa_50)
est_upm_mujer <- hogar_mujer %>% 
    distinct(est_dis, upm, n)
# bootstrap
boot_rep_mujer <- rerun(500, svy_boot(est_upm_mujer, hogar_mujer))
# media y error estándar
hogar_mujer %>% 
    summarise(media = wtd_mean(factor, ing_cor))
#> # A tibble: 1 x 1
#>    media
#>    <dbl>
#> 1 44356.
# usamos bootstrap para calcular los errores estándar
map_dbl(boot_rep_mujer, ~wtd_mean(w = .$factor_b, x = .$ing_cor, na.rm = TRUE)) %>% 
    sd()
#> [1] 546.8034
```

Comparemos con los resultados de `srvyr`. ¿qué pasa?


```r
library(srvyr)
enigh_boot %>% 
    srvyr::group_by(jefa_50) %>% 
    srvyr::summarise(mean_ingcor = survey_mean(ing_cor))
#> # A tibble: 2 x 3
#>   jefa_50 mean_ingcor mean_ingcor_se
#>   <lgl>         <dbl>          <dbl>
#> 1 FALSE        50574.           502.
#> 2 TRUE         44356.           726.
```

Sub-poblaciones como "jefas de familia mayores a 50" se conocen como un dominio, 
esto es un subgrupo cuyo tamaño de muestra es aleatorio, este ejemplo nos 
recalca la importancia de considerar el proceso en que se generó la muestra para 
calcular los errores estándar bootstrap.


```r
map_dbl(boot_rep, 
    function(x){hm <- filter(x, jefa_50); 
    wtd_mean(w = hm$factor_b, x = hm$ing_cor)}) %>% 
    sd()
#> [1] 715.9535
```

Resumiendo:

* El bootstrap de Rao y Wu genera un estimador consistente y aproximadamente 
insesgado de la varianza de estadísticos no lineales y para la varianza de un 
cuantil. 

* Este método supone que la seleccion de UPMs es con reemplazo; hay variaciones 
del estimador bootstrap de Rao y Wu que extienden el método que acabamos de 
estudiar; sin embargo, es común ignorar este aspecto, 
por ejemplo [Mach et al](https://fcsm.sites.usa.gov/files/2014/05/2005FCSM_Mach_Dumais_Robidou_VA.pdf) estudian las propiedades del estimador de varianza bootstrap de Rao y Wu cuando 
la muestra se seleccionó sin reemplazo.


## Bootstrap en R

Es común crear nuestras propias funciones cuando usamos bootstrap, sin embargo, 
en R también hay alternativas que pueden resultar convenientes, mencionamos 3:

1. El paquete `rsample` (forma parte de la colección [tidymodels](https://www.tidyverse.org/articles/2018/08/tidymodels-0-0-1/)) 
y tiene una función `bootsrtraps()` que regresa un arreglo cuadrangular 
(`tibble`, `data.frame`) que incluye una columna con las muestras bootstrap y un 
identificador del número y tipo de muestra.

Veamos un ejemplo donde seleccionamos muestras del conjunto de datos 
`muestra_computos` que contiene 10,000 observaciones.


```r
library(rsample)
library(estcomp)
muestra_computos <- sample_n(election_2012, 10000)
muestra_computos
#> # A tibble: 10,000 x 23
#>    state_code state_name state_abbr district_loc_17 district_fed_17
#>    <chr>      <chr>      <chr>                <int>           <int>
#>  1 27         Tabasco    TAB                      5               5
#>  2 15         México     MEX                     32              24
#>  3 09         Ciudad de… CDMX                    20              17
#>  4 21         Puebla     PUE                     16              12
#>  5 12         Guerrero   GRO                     17               1
#>  6 30         Veracruz   VER                      8               7
#>  7 11         Guanajuato GTO                     18               7
#>  8 12         Guerrero   GRO                      4               4
#>  9 30         Veracruz   VER                     25              19
#> 10 15         México     MEX                     29              15
#> # … with 9,990 more rows, and 18 more variables: polling_id <int>,
#> #   section <int>, region <chr>, polling_type <chr>, section_type <chr>,
#> #   pri_pvem <int>, pan <int>, panal <int>, prd_pt_mc <int>, otros <int>,
#> #   total <int>, nominal_list <int>, pri_pvem_pct <dbl>, pan_pct <dbl>,
#> #   panal_pct <dbl>, prd_pt_mc_pct <dbl>, otros_pct <dbl>, winner <chr>
```

Generamos 100 muestras bootstrap, y la función nos regresa un arreglo con 100
renglones, cada uno corresponde a una muestra bootstrap.


```r
set.seed(839287482)
computos_boot <- bootstraps(muestra_computos, times = 100)
computos_boot
#> # Bootstrap sampling 
#> # A tibble: 100 x 2
#>    splits             id          
#>    <list>             <chr>       
#>  1 <split [10K/3.6K]> Bootstrap001
#>  2 <split [10K/3.6K]> Bootstrap002
#>  3 <split [10K/3.7K]> Bootstrap003
#>  4 <split [10K/3.7K]> Bootstrap004
#>  5 <split [10K/3.7K]> Bootstrap005
#>  6 <split [10K/3.7K]> Bootstrap006
#>  7 <split [10K/3.7K]> Bootstrap007
#>  8 <split [10K/3.7K]> Bootstrap008
#>  9 <split [10K/3.6K]> Bootstrap009
#> 10 <split [10K/3.7K]> Bootstrap010
#> # … with 90 more rows
```

La columna `splits` tiene información de las muestras seleccionadas, para la 
primera vemos que de 10,000 observaciones en la muestra original la primera 
muestra bootstrap contiene 10000-3647=6353.


```r
first_computos_boot <- computos_boot$splits[[1]]
first_computos_boot 
#> <10000/3647/10000>
```

Y podemos obtener los datos de la muestra bootstrap con la función 
`as.data.frame()`


```r
as.data.frame(first_computos_boot)
#> # A tibble: 10,000 x 23
#>    state_code state_name state_abbr district_loc_17 district_fed_17
#>    <chr>      <chr>      <chr>                <int>           <int>
#>  1 01         Aguascali… AGS                     18               3
#>  2 15         México     MEX                     17              18
#>  3 02         Baja Cali… BC                      10               6
#>  4 16         Michoacán  MICH                     8               2
#>  5 09         Ciudad de… CDMX                     7               9
#>  6 05         Coahuila   COAH                    15               7
#>  7 26         Sonora     SON                     20               7
#>  8 09         Ciudad de… CDMX                     4               2
#>  9 30         Veracruz   VER                     14              12
#> 10 30         Veracruz   VER                     24              19
#> # … with 9,990 more rows, and 18 more variables: polling_id <int>,
#> #   section <int>, region <chr>, polling_type <chr>, section_type <chr>,
#> #   pri_pvem <int>, pan <int>, panal <int>, prd_pt_mc <int>, otros <int>,
#> #   total <int>, nominal_list <int>, pri_pvem_pct <dbl>, pan_pct <dbl>,
#> #   panal_pct <dbl>, prd_pt_mc_pct <dbl>, otros_pct <dbl>, winner <chr>
```

Una de las principales ventajas de usar este paquete es que es eficiente en 
el uso de memoria.


```r
library(pryr)
#> Registered S3 method overwritten by 'pryr':
#>   method      from
#>   print.bytes Rcpp
#> 
#> Attaching package: 'pryr'
#> The following objects are masked from 'package:purrr':
#> 
#>     compose, partial
object_size(muestra_computos)
#> 1.41 MB
object_size(computos_boot)
#> 5.49 MB
# tamaño por muestra
object_size(computos_boot)/nrow(computos_boot)
#> 54.9 kB
# el incremento en tamaño es << 100
as.numeric(object_size(computos_boot)/object_size(muestra_computos))
#> [1] 3.894717
```

2. El paquete `boot` está asociado al libro *Bootstrap Methods and Their 
Applications* (@davison) y tiene, entre otras, funciones para calcular 
replicaciones bootstrap y para construir intervalos de confianza usando bootstrap: 
    + calculo de replicaciones bootstrap con la función `boot()`,
    + intervalos normales, de percentiles y $BC_a$ con la función `boot.ci()`,
    + intevalos ABC con la función `abc.ci().
    

3. El paquete `bootstrap` contiene datos usados en @efron, y la implementación 
de funciones para calcular replicaciones y construir intervalos de confianza:
    + calculo de replicaciones bootstrap con la función `bootstrap()`,
    + intervalos $BC_a$ con la función `bcanon()`, 
    + intevalos ABC con la función `abcnon().



## Conclusiones y observaciones

* El principio fundamental del Bootstrap no paramétrico es que podemos estimar
la distribución poblacional con la distribución empírica. Por tanto para 
hacer inferencia tomamos muestras con reemplazo de la distribución empírica y 
analizamos la variación de la estadística de interés a lo largo de las 
muestras.

* El bootstrap nos da la posibilidad de crear intervalos de confianza
cuando no contamos con fórmulas para hacerlo de manera analítica y sin 
supuestos distribucionales de la población.

* Hay muchas opciones para construir intervalos bootstrap, los que tienen 
mejores propiedades son los intervalos $BC_a$, sin embargo los más comunes son 
los intervalos normales con error estándar bootstrap y los intervalos de 
percentiles de la distribución bootstrap.

* Antes de hacer intervalos normales (o con percentiles de una t) vale la pena 
graficar la distribución bootstrap y evaluar si el supuesto de normalidad es 
razonable.

* En cuanto al número de muestras bootstrap se recomienda al menos $1,000$ 
al hacer pruebas, y $10,000$ o $15,000$ para los resultados finales, sobre
todo cuando se hacen intervalos de confianza de percentiles.

* La función de distribución empírica es una mala estimación en las colas de 
las distribuciones, por lo que es difícil construir intervalos de confianza 
(usando bootstrap no paramétrico) para estadísticas que dependen mucho de las 
colas.
