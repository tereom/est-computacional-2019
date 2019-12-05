
# Temas selectos de R

Esta sección describe algunos aspectos de R como lenguaje de programación (en 
contraste a introducir funciones para análisis de datos). Es importante tener
en cuenta como funciona R para escribir código más claro, minimizando errores
y más eficiente. Las referencias para esta sección son @advr y @r4ds.

## Funciones e iteración

> “To understand computations in R, two slogans are helpful:  
> * Everything that exists is an object.  
> * Everything that happens is a function call."  
> — John Chambers

### Funciones {-}

En R todas las operaciones son producto de la llamada a una función, esto 
incluye operaciones como `+`, operadores que controlan flujo como `for`, `if` y 
`while`, e incluso operadores para obtener subconjuntos como `[ ]` y `$`.


```r
a <- 3
b <- 4
a + b
#> [1] 7
`+`(a, b)
#> [1] 7

for (i in 1:2) print(i)
#> [1] 1
#> [1] 2
`for`(i, 1:2, print(i))
#> [1] 1
#> [1] 2
```

Para escribir código eficiente y fácil de leer es importante saber escribir
funciones, se dice que si hiciste *copy-paste* de una sección de tu código 3
o más veces es momento de escribir una función.

Escribimos una función para calcular un promedio ponderado:


```r
wtd_mean <- function(x, wt = rep(1, length(x))) {
  sum(x * wt) / sum(wt)
}
```

Notemos que esta función recibe hasta dos argumentos: 

1. `x`: el vector a partir del cual calcularemos el promedio y

2. `wt`: un vector de *ponderadores* para cada componente del vector `x`. 

Notemos además que al segundo argumento le asignamos un valor predeterminado, 
esto implica que si no especificamos los ponderadores la función usará el 
valor predeterminado y promediara con mismo peso a todas las componentes.


```r
wtd_mean(c(1:10))
#> [1] 5.5
wtd_mean(1:10, 10:1)
#> [1] 4
```

Veamos como escribir una función que reciba un vector y devuelva el mismo vector
centrado en cero. 

* Comenzamos escribiendo el código para un caso particular, por ejemplo, 
reescalando el vector $(0, 5, 10)$. 


```r
vec <- c(0, 5, 10)
vec - mean(vec)
#> [1] -5  0  5
```

Una vez que lo probamos lo convertimos en función:


```r
center_vector <- function(vec) {
  vec - mean(vec)
}
center_vector(c(0, 5, 10))
#> [1] -5  0  5
```

#### Ejercicio {-}
![](img/manicule2.jpg) Escribe una función que reciba un vector y devuelva el 
mismo vector reescalado al rango 0 a 1. Comienza escribiendo el código para un 
caso particular, por ejemplo, empieza reescalando el vector 
. Tip: la función `range()` devuelve el rango de un 
vector.  

#### Estructura de una función {-}

Las funciones de R tienen tres partes:

1. El cuerpo: el código dentro de la función


```r
body(wtd_mean)
#> {
#>     sum(x * wt)/sum(wt)
#> }
```

2. Los formales: la lista de argumentos que controlan como puedes llamar a la
función, 


```r
formals(wtd_mean)
#> $x
#> 
#> 
#> $wt
#> rep(1, length(x))
```

3. El ambiente: el _mapeo_ de la ubicación de las variables de la función, cómo
busca la función cada función el valor de las variables que usa.


```r
environment(wtd_mean)
#> <environment: R_GlobalEnv>
```

Veamos mas ejemplos, ¿qué regresan las siguientes funciones?


```r
# 1
x <- 5
f <- function(){
  y <- 10
  c(x = x, y = y) 
}
rm(x, f)

# 2
x <- 5
g <- function(){
  x <- 20
  y <- 10
  c(x = x, y = y)
}
rm(x, g)

# 3
x <- 5
h <- function(){
  y <- 10
  i <- function(){
    z <- 20
    c(x = x, y = y, z = z)
  }
  i() 
}

# 4 ¿qué ocurre si la corremos por segunda vez?
j <- function(){
  if (!exists("a")){
    a <- 5
  } else{
    a <- a + 1 
}
  print(a) 
}
x <- 0
y <- 10

# 5 ¿qué regresa k()? ¿y k()()?
k <- function(){
  x <- 1
  function(){
    y <- 2
    x + y 
  }
}
```

Las reglas de búsqueda determinan como se busca el valor de una variable libre 
en una función. A nivel lenguaje R usa _lexical scoping_, esto implica que en R 
los valores de los símbolos se basan en como se anidan las funciones cuando 
fueron creadas y no en como son llamadas. 

Las reglas de bússqueda de R, _lexical scoping_, son:

1. Enmascaramiento de nombres: los nombres definidos dentro de una función
enmascaran aquellos definidos fuera.


```r
x <- 5
g <- function(){
  x <- 20
  y <- 10
  c(x = x, y = y)
}
g()
#>  x  y 
#> 20 10
```
Si un nombre no está definido R busca un nivel arriba,


```r
x <- 5
f <- function(){
  y <- 10
  c(x = x, y = y) 
}
f()
#>  x  y 
#>  5 10
```

Y lo mismo ocurre cuando una función está definida dentro de una función.


```r
x <- 5
h <- function(){
  y <- 10
  i <- function(){
    z <- 20
    c(x = x, y = y, z = z)
  }
  i() 
}
h()
#>  x  y  z 
#>  5 10 20
```

Y cuando una función crea otra función:


```r
x <- 10
k <- function(){
  x <- 1
  function(){
    y <- 2
    x + y 
  }
}
k()()
#> [1] 3
```

2. Funciones o variables: en R las funciones son objetos, sin embargo una 
función y un objeto no-función pueden llamarse igual. En estos casos usamos un 
nombre en el llamado de una función se buscará únicamente entre los objetos de
tipo función.


```r
p <- function(x) {
    5 * x 
} 
m <- function(){
    p <- 2
    p(p)
} 
m()
#> [1] 10
```

3. Cada vez que llamamos una función es un ambiente limpio, es decir, los 
objetos que se crean durante la llamada de la función no se *pasan* a las
llamadas posteriores.


```r
# 4 ¿qué ocurre si la corremos por segunda vez?
j <- function(){
  if (!exists("a")) {
    a <- 5
  } else{
    a <- a + 1 
}
  print(a) 
}
j()
#> [1] 4
j()
#> [1] 4
```

4. Búsqueda dinámica: la búsqueda lexica determina donde se busca un valor más
no determina cuando. En el caso de R los valores se buscan cuando la función se
llama, y no cuando la función se crea.


```r
q <- function() x + 1
x <- 15
q()
#> [1] 16

x <- 20
q()
#> [1] 21
```

Las reglas de búsqueda de R lo hacen muy flexible pero también propenso a 
cometer errores. Una función que suele resultar útil para revisar las 
dependencias de nuestras funciones es `findGlobals()` en el paquete `codetools`,
esta función enlista las dependencias dentro de una función:


```r
codetools::findGlobals(q)
#> [1] "+" "x"
```



#### Observaciones del uso de funciones {-}

1. Cuando llamamos a una función podemos especificar los argumentos en base a 
posición, nombre completo o nombre parcial:


```r
f <- function(abcdef, bcde1, bcde2) {
  c(a = abcdef, b1 = bcde1, b2 = bcde2)
}
# Posición
f(1, 2, 3)
#>  a b1 b2 
#>  1  2  3
f(2, 3, abcdef = 1)
#>  a b1 b2 
#>  1  2  3
# Podemos abreviar el nombre de los argumentos
f(2, 3, a = 1)
#>  a b1 b2 
#>  1  2  3
# Siempre y cuando la abreviación no sea ambigua
f(1, 3, b = 1)
#> Error in f(1, 3, b = 1): argument 3 matches multiple formal arguments
```

2. Los argumentos de las funciones en R se evalúan conforme se necesitan (*lazy
evaluation*), 


```r
f <- function(a, b){
  a ^ 2
}
f(2)
#> [1] 4
```

La función anterior nunca utiliza el argumento _b_, de tal manera que `f(2)`
no produce ningún error.

3. Funciones con el mismo nombre en distintos paquetes:

La función `filter()` (incluida en R base) aplica un filtro lineal a una serie
de tiempo de una variable.




```r
x <- 1:100
filter(x, rep(1, 3))
#> Error in UseMethod("filter_"): no applicable method for 'filter_' applied to an object of class "c('integer', 'numeric')"
```

Ahora cargamos `dplyr`.


```r
library(dplyr)
filter(x, rep(1, 3))
#> Error in UseMethod("filter_"): no applicable method for 'filter_' applied to an object of class "c('integer', 'numeric')"
```

R tiene un conflicto en la función a llamar, nosotros requerimos usar 
`filter` de stats y no la función `filter` de `dplyr`. R utiliza por default
la función que pertenece al último paquete que se cargó.

La función `search()` nos enlista los paquetes cargados y el orden.


```r
search()
#>  [1] ".GlobalEnv"        "package:dplyr"     "package:forcats"  
#>  [4] "package:stringr"   "package:purrr"     "package:readr"    
#>  [7] "package:tidyr"     "package:tibble"    "package:ggplot2"  
#> [10] "package:tidyverse" "package:stats"     "package:graphics" 
#> [13] "package:grDevices" "package:utils"     "package:datasets" 
#> [16] "package:methods"   "Autoloads"         "package:base"
```

Una opción es especificar el paquete en la llamada de la función:


```r
stats::filter(x, rep(1, 3))
#> Time Series:
#> Start = 1 
#> End = 100 
#> Frequency = 1 
#>   [1]  NA   6   9  12  15  18  21  24  27  30  33  36  39  42  45  48  51  54
#>  [19]  57  60  63  66  69  72  75  78  81  84  87  90  93  96  99 102 105 108
#>  [37] 111 114 117 120 123 126 129 132 135 138 141 144 147 150 153 156 159 162
#>  [55] 165 168 171 174 177 180 183 186 189 192 195 198 201 204 207 210 213 216
#>  [73] 219 222 225 228 231 234 237 240 243 246 249 252 255 258 261 264 267 270
#>  [91] 273 276 279 282 285 288 291 294 297  NA
```

Como alternativa surge el paquete [conflicted](https://github.com/r-lib/conflicted)
que alerta cuando hay conflictos y tiene funciones para especificar a que 
paquete se desea dar preferencia en una sesión de R.


## Vectores

En R se puede trabajar con distintas estructuras de datos, algunas son de una
sola dimensión y otras permiten más, como indica el diagrama de abajo:

<img src="imagenes/data_structures.png" width="250px"/>

Hasta ahora nos hemos centrado en trabajar con `data.frames`, y hemos usado
vectores atómicos sin profundizar, en esta sección se explican características
de los vectores, y veremos que son la base de los `data.frames`.

En R hay dos tipos de vectores, esto es, estructuras de datos de una sola 
dimensión: los vectores atómicos y las listas. 

* Los vectores atómicos pueden ser de 6 tipos: lógico, entero, double, caracter, 
complejo y raw. Los dos últimos son poco comunes. 

Vector atómico de tipo lógico:


```r
a <- c(TRUE, FALSE, FALSE)
a
#> [1]  TRUE FALSE FALSE
```

Numérico (double):


```r
b <- c(5, 2, 4.1, 7, 9.2)
b
#> [1] 5.0 2.0 4.1 7.0 9.2
b[1]
#> [1] 5
b[2]
#> [1] 2
b[2:4]
#> [1] 2.0 4.1 7.0
```

Las operaciones básicas con vectores atómicos son componente a componente:


```r
c <- b + 10
c
#> [1] 15.0 12.0 14.1 17.0 19.2
d <- sqrt(b)
d
#> [1] 2.236068 1.414214 2.024846 2.645751 3.033150
b + d
#> [1]  7.236068  3.414214  6.124846  9.645751 12.233150
10 * b
#> [1] 50 20 41 70 92
b * d
#> [1] 11.180340  2.828427  8.301867 18.520259 27.904982
```

Y podemos crear secuencias como sigue:


```r
e <- 1:10
e
#>  [1]  1  2  3  4  5  6  7  8  9 10
f <- seq(0, 1, 0.25)
f
#> [1] 0.00 0.25 0.50 0.75 1.00
```

Para calcular características de vectores atómicos usamos funciones:


```r
# media del vector
mean(b)
#> [1] 5.46
# suma de sus componentes
sum(b)
#> [1] 27.3
# longitud del vector
length(b)
#> [1] 5
```

Y ejemplo de vector atómico de tipo caracter y funciones:


```r
frutas <- c('manzana', 'manzana', 'pera', 'plátano', 'fresa', "kiwi")
frutas
#> [1] "manzana" "manzana" "pera"    "plátano" "fresa"   "kiwi"
grep("a", frutas)
#> [1] 1 2 3 4 5
gsub("a", "x", frutas)
#> [1] "mxnzxnx" "mxnzxnx" "perx"    "plátxno" "fresx"   "kiwi"
```

* Las listas, a diferencia de los vectores atómicos, pueden contener otras 
listas. Las listas son muy flexibles pues pueden almacenar objetos de cualquier 
tipo.


```r
x <- list(1:3, "Mila", c(TRUE, FALSE, FALSE), c(2, 5, 3.2))
str(x)
#> List of 4
#>  $ : int [1:3] 1 2 3
#>  $ : chr "Mila"
#>  $ : logi [1:3] TRUE FALSE FALSE
#>  $ : num [1:3] 2 5 3.2
```

Las listas son vectores _recursivos_ debido a que pueden almacenar otras listas.


```r
y <- list(list(list(list())))
str(y)
#> List of 1
#>  $ :List of 1
#>   ..$ :List of 1
#>   .. ..$ : list()
```


Para construir subconjuntos a partir de listas usamos `[]` y `[[]]`. En el primer 
caso siempre obtenemos como resultado una lista:


```r
x_1 <- x[1]
x_1
#> [[1]]
#> [1] 1 2 3
str(x_1)
#> List of 1
#>  $ : int [1:3] 1 2 3
```

Y en el caso de `[[]]` extraemos un componente de la lista, eliminando un nivel
de la jerarquía de la lista.


```r
x_2 <- x[[1]]
x_2
#> [1] 1 2 3
str(x_2)
#>  int [1:3] 1 2 3
```

¿Cómo se comparan `y`, `y[1]` y `y[[1]]`?

### Propiedades {-}
Todos los vectores (atómicos y listas) tienen las propiedades tipo y longitud, 
la función `typeof()` se usa para determinar el tipo,


```r
typeof(a)
#> [1] "logical"
typeof(b)
#> [1] "double"
typeof(frutas)
#> [1] "character"
typeof(x)
#> [1] "list"
```

y `length()` la longitud:


```r
length(a)
#> [1] 3
length(frutas)
#> [1] 6
length(x)
#> [1] 4
length(y)
#> [1] 1
```

La flexibilidad de las listas las convierte en estructuras muy útiles y muy 
comunes, muchas funciones regresan resultados en forma de lista. Incluso podemos
ver que un data.frame es una lista de vectores, donde todos los vectores son
de la misma longitud.

Adicionalmente, los vectores pueden tener atributo de nombres, que puede usarse
para indexar.


```r
names(b) <- c("momo", "mila", "duna", "milu", "moka")
b
#> momo mila duna milu moka 
#>  5.0  2.0  4.1  7.0  9.2
b["moka"]
#> moka 
#>  9.2
```


```r
names(x) <- c("a", "b", "c", "d")
x
#> $a
#> [1] 1 2 3
#> 
#> $b
#> [1] "Mila"
#> 
#> $c
#> [1]  TRUE FALSE FALSE
#> 
#> $d
#> [1] 2.0 5.0 3.2
x$a
#> [1] 1 2 3
x[["c"]]
#> [1]  TRUE FALSE FALSE
```


## Iteración

En análisis de datos es común implementar rutinas iteraivas, esto es, cuando
debemos aplicar los mismos pasos a distintas entradas. Veremos que hay dos 
paradigmas de iteración:

1. Programación imperativa: ciclos `for` y ciclos `while`.

2. Programación funcional: los ciclos se implmentan mediante funciones, 

La ventaja de la programación imperativa es que hacen la iteración de manera
clara, sin embargo, veremos que una vez que nos familiarizamos con el paradigma
de programación funcional, resulta en código más fácil de mantener y menos
propenso a errores.

### Ciclos for {-}

Supongamos que tenemos una base de datos y queremos calcular la media de sus
columnas numéricas.


```r
df <- data.frame(id = 1:10, a = rnorm(10), b = rnorm(10, 2), c = rnorm(10, 3), 
    d = rnorm(10, 4))
df
#>    id          a          b        c        d
#> 1   1  0.7121914  2.3718704 3.195423 3.808701
#> 2   2  1.1505555  2.2545473 1.799928 4.428536
#> 3   3 -0.3066320  1.3723335 4.449414 4.596258
#> 4   4 -1.7776316  1.8808830 2.590505 5.742982
#> 5   5 -0.6204625  3.8522284 2.385698 2.832891
#> 6   6 -0.1857880  1.4964503 2.288345 4.035952
#> 7   7  0.1489240  2.9911949 4.210013 3.395680
#> 8   8 -0.7905242  1.2260981 2.436687 3.957895
#> 9   9  1.7366654 -0.1528785 3.040460 3.303055
#> 10 10 -0.5056813  3.6525674 2.685626 4.468739
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.04383835
mean(df$b)
#> [1] 2.094529
mean(df$c)
#> [1] 2.90821
mean(df$d)
#> [1] 4.057069
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.04383835  2.09452950  2.90820987  4.05706886
```

Los ciclos `for` tienen 3 componentes:

1. La salida: `salida <- vector("double", 4)`. Es importante especificar el 
tamaño de la salida antes de iniciar el ciclo `for`, de lo contrario el código
puede ser muy lento.

2. La secuencia: determina sobre que será la iteración, la función `seq_along` 
puede resultar útil.


```r
salida <- vector("double", 5)  
for (i in seq_along(df)) {            
  salida[[i]] <- mean(df[[i]])      
}
seq_along(df)
#> [1] 1 2 3 4 5
```

3. El cuerpo: `salida[[i]] <- mean(df[[i]])`, el código que calcula lo que nos
interesa sobre cada objeto en la iteración.



![](img/manicule2.jpg) Calcula el valor máximo de cada columna numérica de los 
datos de ENLACE 3o de primaria `enlacep_2013_3`.


```r
library(estcomp)
head(enlacep_2013_3)
#> # A tibble: 6 x 6
#>   CVE_ENT PUNT_ESP_3 PUNT_MAT_3 PUNT_FCE_3 ALUM_NOCONFIABLE_3 ALUM_EVAL_3
#>   <chr>        <dbl>      <dbl>      <dbl>              <dbl>       <dbl>
#> 1 01             513        536        459                  0          40
#> 2 01             472        472        404                  2          36
#> 3 01             496        526        426                  0          96
#> 4 01             543        586        495                  5          74
#> 5 01             554        560        506                  0          30
#> 6 01             505        546        460                  0          67
```


* Recordando la limpieza de datos de la sección anterior en uno de los 
últimos ejercicios leíamos archivos de manera iteativa. En este ejercicio 
descargaremos un archivo zip con archivos csv que contienen información 
de monitoreo de contaminantes en ciudad de México ([RAMA](http://www.aire.cdmx.gob.mx/default.php?opc=%27aKBh%27)), en particular
PM2.5. Y juntaremos la información en una sola tabla, la siguiente instrucción 
descarga los datos en una carpeta `data`.



```r
library(usethis)
use_directory("data") # crea carpeta en caso de que no exista ya
usethis::use_zip("https://github.com/tereom/estcomp/raw/master/data-raw/19RAMA.zip", 
    "data") # descargar y descomprimir zip
```

* Enlistamos los archivos xls en la carpeta.


```r
paths <- dir("data/19RAMA", pattern = "\\.xls$", full.names = TRUE)
```

![](img/manicule2.jpg) Tu turno, implementa un ciclo `for` para leer los 
archivos y crear una única tabla de datos. Si *pegas* los data.frames de manera
iterativa sugerimos usar la función `bind_rows()`.


#### Programación funcional {-}

Ahora veremos como abordar iteración usando programación funcional.

Regresando al ejemplo inicial de calcular la media de las columnas de una
tabla de datos:


```r
salida <- vector("double", 4) 

for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.04383835  2.09452950  2.90820987  4.05706886
```

Podemos crear una función que calcula la media de las columnas de un 
`data.frame`:


```r
col_media <- function(df) {
  salida <- vector("double", length(df))
  for (i in seq_along(df)) {
    salida[i] <- mean(df[[i]])
  }
  salida
}
col_media(df)
#> [1]  5.50000000 -0.04383835  2.09452950  2.90820987  4.05706886
col_media(select(iris, -Species))
#> [1] 5.843333 3.057333 3.758000 1.199333
```

Y podemos extender a crear más funciones que describan los datos:


```r
col_mediana <- function(df) {
  salida <- vector("double", length(df))
  for (i in seq_along(df)) {
    salida[i] <- median(df[[i]])
  }
  salida
}
col_sd <- function(df) {
  salida <- vector("double", length(df))
  for (i in seq_along(df)) {
    salida[i] <- sd(df[[i]])
  }
  salida
}
```

Podemos hacer nuestro código más general y compacto escribiendo una función 
que reciba los datos sobre los que queremos iterar y la función que queremos
aplicar:


```r
col_describe <- function(df, fun) {
  salida <- vector("double", length(df))
  for (i in seq_along(df)) {
    salida[i] <- fun(df[[i]])
  }
  salida
}
col_describe(df, median)
#> [1]  5.500000 -0.246210  2.067715  2.638065  3.996923
col_describe(df, mean)
#> [1]  5.50000000 -0.04383835  2.09452950  2.90820987  4.05706886
```

Ahora utilizaremos esta idea de pasar funciones a funciones para eliminar los
ciclos `for`.

La iteración a través de funciones es muy común en R, hay funciones para hacer 
esto en R base (`lapply()`, `apply()`, `sapply()`). Nosotros utilizaremos las 
funciones del paquete `purrr`, 

La familia de funciones del paquete iteran siempre sobre un vector (vector 
atómico o lista), aplican una 
función a cada parte y regresan un nuevo vector de la misma longitud que el 
vector entrada. Cada función especifica en su nombre el tipo de salida:

* `map()` devuelve una lista.
* `map_lgl()` devuelve un vector lógico.
* `map_int()` devuelve un vector entero.
* `map_dbl()` devuelve un vector double.
* `map_chr()` devuelve un vector caracter.
* `map_df()` devuelve un data.frame.


En el ejemplo de las medias, `map` puede recibir un `data.frame` (lista de 
vectores) y aplicará las funciones a las columnas del mismo.


```r
library(purrr)
map_dbl(df, mean)
#>          id           a           b           c           d 
#>  5.50000000 -0.04383835  2.09452950  2.90820987  4.05706886
map_dbl(select(iris, -Species), median)
#> Sepal.Length  Sepal.Width Petal.Length  Petal.Width 
#>         5.80         3.00         4.35         1.30
```

Usaremos `map` para ajustar un modelo lineal a subconjuntos de los datos 
`mtcars` determinados por el cilindraje del motor.


```r
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(function(df) lm(mpg ~ wt, data = df))
```

Podemos usar la notación `.` para hacer código más corto:


```r
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(~lm(mpg ~ wt, data = .))
```

Usemos `map_**` para unir tablas de datos que están almacenadas en múltiples 
archivos csv.



En este caso es más apropiado usar map_df


```r
library(readxl)
rama <- map_df(paths, read_excel, .id = "FILENAME")
```

#### Ejercicio {-}

* Usa la función `map_**` para calcular el número de valores únicos en las 
columnas de `iris`.

* Usa la función `map_**` para extraer el coeficiete de la variable `wt` para
cada modelo:


```r
models[[1]]$coefficients[2]
#>        wt 
#> -5.647025
```


## Rendimiento en R

> "We should forget about small efficiencies, say about 97% of the time: 
>  premature optimization is the root of all evil. Yet we should not pass up our 
opportunities in that critical 3%. A good programmer will not be lulled into 
complacency by such reasoning, he will be wise to look carefully at the critical 
code; but only after that code has been identified."
> -Donald Knuth

Diseña primero, luego optimiza. La optimización del código es un proceso 
iterativo:  

1. Encuentra el cuello de botella más importante.  
2. Intenta eliminarlo (no siempre se puede).  
3. Repite hasta que tu código sea lo suficientemente rápido.  

### Diagnosticar {-}

Una vez que tienes código que se puede leer y funciona, el perfilamiento 
(profiling) del código es un método sistemático que nos permite conocer cuanto 
tiempo se esta usando en diferentes partes del programa.

Comenzaremos con la función **system.time** (no es perfilamiento aún),
esta calcula el tiempo en segundos que toma ejecutar una expresión (si hay un 
error, regresa el tiempo hasta que ocurre el error):


```r
data("Batting", package = "Lahman") 
system.time(lm(R ~ AB + teamID, Batting))
#>    user  system elapsed 
#>   3.600   0.092   3.692
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.023   0.000   1.421
```

o al revés:


```r
library(parallel)
system.time(mclapply(2000:2007, 
  function(x){
    sub <- subset(Batting, yearID == x)
    lm(R ~ AB + playerID, sub)
}, mc.cores = 7))
#>    user  system elapsed 
#>  12.223   0.744   9.386
```

Comparemos la velocidad de `dplyr` con funciones que se encuentran en R
estándar y `plyr`.


```r
# dplyr
dplyr_st <- system.time({
    Batting %>%
    group_by(playerID) %>%
    summarise(total = sum(R, na.rm = TRUE), n = n()) %>%
    dplyr::arrange(desc(total))
})

# plyr
plyr_st <- system.time({
    Batting %>% 
    plyr::ddply("playerID", plyr::summarise, total = sum(R, na.rm = TRUE), 
        n = length(R)) %>% 
    plyr::arrange(-total)
})

# estándar lento
est_l_st <- system.time({
    players <- unique(Batting$playerID)
    n_players <- length(players)
    total <- rep(NA, n_players)
    n <- rep(NA, n_players)
    for (i in 1:n_players) {
        sub_Batting <- Batting[Batting$playerID == players[i], ]
        total[i] <- sum(sub_Batting$R, na.rm = TRUE)
        n[i] <- nrow(sub_Batting)
    }
    Batting_2 <- data.frame(playerID = players, total = total, n = n)
    Batting_2[order(Batting_2$total, decreasing = TRUE), ]
})

# estándar rápido
est_r_st <- system.time({
    Batting_2 <- aggregate(. ~ playerID, data = Batting[, c("playerID", "R")], 
        sum)
    Batting_ord <- Batting_2[order(Batting_2$R, decreasing = TRUE), ]
})

dplyr_st
#>    user  system elapsed 
#>   0.113   0.000   0.114
plyr_st
#>    user  system elapsed 
#>   3.894   0.016   3.910
est_l_st
#>    user  system elapsed 
#>  60.604   0.716  61.322
est_r_st
#>    user  system elapsed 
#>   0.394   0.016   0.410
```

La función system.time supone que sabes donde buscar, es decir, que sabes que
expresiones debes evaluar, una función que puede ser más útil cuando uno
desconoce cuál es la función que _alenta_ un programa es **profvis()** del 
paquete con el mismo nombre.


```r
library(profvis)
Batting_recent <- filter(Batting, yearID > 2006)
profvis({
    players <- unique(Batting_recent$playerID)
    n_players <- length(players)
    total <- rep(NA, n_players)
    n <- rep(NA, n_players)
    for (i in 1:n_players) {
        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]
        total[i] <- sum(sub_Batting$R, na.rm = TRUE)
        n[i] <- nrow(sub_Batting)
    }
    Batting_2 <- data.frame(playerID = players, total = total, n = n)
    Batting_2[order(Batting_2$total, decreasing = TRUE), ]
})
```

<!--html_preserve--><div id="htmlwidget-d3663b89da7fa604ef91" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-d3663b89da7fa604ef91">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,4,4,4,4,4,5,5,5,6,6,7,7,8,8,8,8,8,8,9,9,10,10,11,11,11,11,11,12,12,13,13,14,14,14,15,15,16,16,17,17,18,18,19,19,20,20,20,20,21,21,21,22,22,23,23,23,24,24,25,25,26,26,26,26,26,27,27,27,28,28,29,29,30,30,30,30,30,31,31,32,32,32,32,32,32,33,33,33,33,33,34,34,34,35,35,35,35,35,36,36,37,37,38,38,38,39,39,39,39,39,39,40,40,40,41,41,41,41,41,42,42,43,43,44,44,45,45,45,46,46,47,47,48,48,49,49,49,50,50,50,51,51,51,52,52,53,53,53,54,54,54,55,55,55,56,56,56,57,57,57,57,57,57,58,58,58,59,59,59,60,60,61,61,62,62,62,63,63,64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,74,75,75,75,75,75,76,76,77,77,77,78,78,78,78,78,79,79,79,80,80,81,81,81,82,82,82,82,82,82,83,83,83,83,83,83,84,84,84,84,84,85,85,85,85,85,86,86,86,87,87,87,88,88,88,89,89,90,90,90,90,91,91,91,92,92,93,93,94,94,94,94,94,95,95,95,96,96,96,96,96,96,97,97,97,97,97,98,98,98,99,99,99,99,99,100,100,100,100,100,100,101,101,102,102,102,103,104,104,104,105,105,105,106,106,107,107,108,108,108,108,109,109,109,110,110,110,111,111,112,112,112,112,112,113,113,113,114,114,115,115,115,115,115,116,116,117,117,118,118,118,118,118,119,119,119,120,120,120,120,120,121,121,121,121,121,121,122,122,122,123,123,123,124,124,125,125,125,126,126,126,126,127,127,128,128,128,128,128,129,129,130,130,130,130,130,130,131,131,132,132,133,133,134,134,135,135,135,135,135,135,136,136,136,137,137,137,137,138,138,139,139,140,140,140,140,140,141,141,141,142,142,143,143,143,143,143,144,144,144,145,145,145,145,145,146,146,147,147,147,147,147,148,148,149,149,150,150,151,151,152,152,153,153,153,153,153,153,154,154,154,155,155,155,156,156,157,157,157,158,158,159,159,160,160,160,161,161,162,162,162,162,163,163,163,163,164,164,164,165,165,165,165,166,166,166,166,166,166,167,167,167,167,167,167,168,168,168,168,168,168,169,169,169,169,170,170,170,171,171,172,172,173,173,173,174,174,174,174,174,175,175,175,176,176,177,177,177,178,178,179,179,179,179,179,180,180,180,180,180,180,181,181,181,181,181,182,182,182,182,182,182,183,183,183,184,184,184,184,184,185,185,185,186,186,187,187,187,187,187,188,188,188,189,189,189,189,189,190,190,191,191,192,192,192,193,193,193,193,193,193,194,194,194,194,194,195,195,196,196,196,196,196,197,197,198,198,199,199,199,199,199,200,200,200,201,201,201,202,202,203,203,203,203,203,204,204,205,205,205,206,206,206,206,206,207,207,208,208,209,209,210,210,211,212,212,213,213,213,214,214,215,215,215,215,216,216,217,217,218,218,218,218,219,219,220,220,220,220,220,221,221,221,222,222,223,223,223,224,224,224,224,224,225,225,225,225,225,226,226,226,226,226,227,227,228,228,229,229,230,230,231,231,231,232,232,232,232,232,232,233,233,233,233,234,234,235,235,236,236,237,237,238,238,238,239,239,240,240,240,241,241,241,241,241,242,242,243,243,243,243,243,243,244,244,244,244,244,244,245,245,246,246,246,246,246,247,247,247,247,247,247,248,248,248,248,248,249,249,250,250,251,251,252,252,253,253,253,254,254,254,254,255,255,255,256,256,257,257,257,258,258,259,259,260,260,261,261,262,262,262,262,262,262,263,263,264,264,264,264,265,265,266,266,266,267,267,267,268,268,268,269,269,270,270,270,270,270,271,271,271,271,271,272,272,273,273,274,274,275,275,275,276,276,277,277,277,278,278],"depth":[2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1],"label":["dim","nrow","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sum","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","["],"filenum":[null,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,null,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,null,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,null,1,1,1,null,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,null,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1],"linenum":[null,11,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,null,11,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,null,11,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,null,11,9,9,null,9,9,10,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,10,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,null,11,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9],"memalloc":[62.3712921142578,62.3712921142578,83.7522735595703,83.7522735595703,110.191795349121,110.191795349121,127.312271118164,127.312271118164,127.312271118164,127.312271118164,127.312271118164,146.333419799805,146.333419799805,146.333419799805,60.7353820800781,60.7353820800781,92.9463958740234,92.9463958740234,112.30305480957,112.30305480957,112.30305480957,112.30305480957,112.30305480957,112.30305480957,142.672889709473,142.672889709473,48.006477355957,48.006477355957,79.7578353881836,79.7578353881836,79.7578353881836,79.7578353881836,79.7578353881836,100.426200866699,100.426200866699,130.15064239502,130.15064239502,146.352661132812,146.352661132812,146.352661132812,66.3722457885742,66.3722457885742,87.6931228637695,87.6931228637695,118.125968933105,118.125968933105,138.524230957031,138.524230957031,52.8034133911133,52.8034133911133,73.7987976074219,73.7987976074219,73.7987976074219,73.7987976074219,104.75870513916,104.75870513916,104.75870513916,124.962547302246,124.962547302246,146.347312927246,146.347312927246,146.347312927246,62.0515594482422,62.0515594482422,94.5897598266602,94.5897598266602,115.973693847656,115.973693847656,115.973693847656,115.973693847656,115.973693847656,146.352165222168,146.352165222168,146.352165222168,54.3119583129883,54.3119583129883,85.4053726196289,85.4053726196289,105.879432678223,105.879432678223,105.879432678223,105.879432678223,105.879432678223,136.450080871582,136.450080871582,146.36173248291,146.36173248291,146.36173248291,146.36173248291,146.36173248291,146.36173248291,72.7527160644531,72.7527160644531,72.7527160644531,72.7527160644531,72.7527160644531,93.6200256347656,93.6200256347656,93.6200256347656,123.601257324219,123.601257324219,123.601257324219,123.601257324219,123.601257324219,143.741333007812,143.741333007812,59.6974258422852,59.6974258422852,80.5642929077148,80.5642929077148,80.5642929077148,110.941925048828,110.941925048828,110.941925048828,110.941925048828,110.941925048828,110.941925048828,130.953971862793,130.953971862793,130.953971862793,46.1852798461914,46.1852798461914,46.1852798461914,46.1852798461914,46.1852798461914,66.7266159057617,66.7266159057617,98.5375823974609,98.5375823974609,119.601119995117,119.601119995117,146.365478515625,146.365478515625,146.365478515625,57.2089157104492,57.2089157104492,87.648193359375,87.648193359375,106.934440612793,106.934440612793,136.523910522461,136.523910522461,136.523910522461,146.364700317383,146.364700317383,146.364700317383,73.2826232910156,73.2826232910156,73.2826232910156,94.338264465332,94.338264465332,123.655906677246,123.655906677246,123.655906677246,142.548934936523,142.548934936523,142.548934936523,57.3466644287109,57.3466644287109,57.3466644287109,77.8180236816406,77.8180236816406,77.8180236816406,108.649971008301,108.649971008301,108.649971008301,108.649971008301,108.649971008301,108.649971008301,128.331932067871,128.331932067871,128.331932067871,87.9901885986328,87.9901885986328,87.9901885986328,63.3104476928711,63.3104476928711,94.2130508422852,94.2130508422852,113.901649475098,113.901649475098,113.901649475098,143.02758026123,143.02758026123,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,42.7887191772461,42.7887191772461,42.7887191772461,62.2750091552734,62.2750091552734,62.2750091552734,93.9000625610352,93.9000625610352,93.9000625610352,93.9000625610352,93.9000625610352,115.740249633789,115.740249633789,146.374198913574,146.374198913574,146.374198913574,54.3992156982422,54.3992156982422,54.3992156982422,54.3992156982422,54.3992156982422,85.765869140625,85.765869140625,85.765869140625,105.116561889648,105.116561889648,133.458923339844,133.458923339844,133.458923339844,146.382781982422,146.382781982422,146.382781982422,146.382781982422,146.382781982422,146.382781982422,66.2027816772461,66.2027816772461,66.2027816772461,66.2027816772461,66.2027816772461,66.2027816772461,85.4226837158203,85.4226837158203,85.4226837158203,85.4226837158203,85.4226837158203,113.831123352051,113.831123352051,113.831123352051,113.831123352051,113.831123352051,132.39111328125,132.39111328125,132.39111328125,47.9126815795898,47.9126815795898,47.9126815795898,67.725212097168,67.725212097168,67.725212097168,98.4903793334961,98.4903793334961,118.956718444824,118.956718444824,118.956718444824,118.956718444824,146.383903503418,146.383903503418,146.383903503418,54.868537902832,54.868537902832,85.8973846435547,85.8973846435547,105.443870544434,105.443870544434,105.443870544434,105.443870544434,105.443870544434,133.715728759766,133.715728759766,133.715728759766,146.377983093262,146.377983093262,146.377983093262,146.377983093262,146.377983093262,146.377983093262,69.4303894042969,69.4303894042969,69.4303894042969,69.4303894042969,69.4303894042969,90.095573425293,90.095573425293,90.095573425293,121.910400390625,121.910400390625,121.910400390625,121.910400390625,121.910400390625,143.551620483398,143.551620483398,143.551620483398,143.551620483398,143.551620483398,143.551620483398,60.6483459472656,60.6483459472656,81.7032241821289,81.7032241821289,81.7032241821289,114.371360778809,135.560791015625,135.560791015625,135.560791015625,53.7574234008789,53.7574234008789,53.7574234008789,74.4862670898438,74.4862670898438,107.214805603027,107.214805603027,128.340927124023,128.340927124023,128.340927124023,128.340927124023,46.0188598632812,46.0188598632812,46.0188598632812,65.69970703125,65.69970703125,65.69970703125,96.9190673828125,96.9190673828125,117.914459228516,117.914459228516,117.914459228516,117.914459228516,117.914459228516,146.385955810547,146.385955810547,146.385955810547,56.3155212402344,56.3155212402344,87.4074554443359,87.4074554443359,87.4074554443359,87.4074554443359,87.4074554443359,108.135314941406,108.135314941406,138.633720397949,138.633720397949,45.6274185180664,45.6274185180664,45.6274185180664,45.6274185180664,45.6274185180664,75.4723281860352,75.4723281860352,75.4723281860352,96.5374526977539,96.5374526977539,96.5374526977539,96.5374526977539,96.5374526977539,126.516868591309,126.516868591309,126.516868591309,126.516868591309,126.516868591309,126.516868591309,146.331924438477,146.331924438477,146.331924438477,64.0007247924805,64.0007247924805,64.0007247924805,85.3256301879883,85.3256301879883,117.537788391113,117.537788391113,117.537788391113,138.790344238281,138.790344238281,138.790344238281,138.790344238281,57.2388610839844,57.2388610839844,77.252799987793,77.252799987793,77.252799987793,77.252799987793,77.252799987793,107.621292114258,107.621292114258,128.157997131348,128.157997131348,128.157997131348,128.157997131348,128.157997131348,128.157997131348,45.7645111083984,45.7645111083984,66.0345916748047,66.0345916748047,97.0719985961914,97.0719985961914,116.752632141113,116.752632141113,146.212791442871,146.212791442871,146.212791442871,146.212791442871,146.212791442871,146.212791442871,53.5711212158203,53.5711212158203,53.5711212158203,84.8685684204102,84.8685684204102,84.8685684204102,84.8685684204102,105.923774719238,105.923774719238,138.007385253906,138.007385253906,45.3071746826172,45.3071746826172,45.3071746826172,45.3071746826172,45.3071746826172,75.4256210327148,75.4256210327148,75.4256210327148,96.3486633300781,96.3486633300781,128.227691650391,128.227691650391,128.227691650391,128.227691650391,128.227691650391,146.335327148438,146.335327148438,146.335327148438,66.6988906860352,66.6988906860352,66.6988906860352,66.6988906860352,66.6988906860352,87.8209075927734,87.8209075927734,119.707550048828,119.707550048828,119.707550048828,119.707550048828,119.707550048828,140.765609741211,140.765609741211,58.8208847045898,58.8208847045898,79.8760375976562,79.8760375976562,111.295288085938,111.295288085938,129.466361999512,129.466361999512,46.6228179931641,46.6228179931641,46.6228179931641,46.6228179931641,46.6228179931641,46.6228179931641,67.2848739624023,67.2848739624023,67.2848739624023,98.7745056152344,98.7745056152344,98.7745056152344,119.177192687988,119.177192687988,146.33235168457,146.33235168457,146.33235168457,56.8590850830078,56.8590850830078,87.3765335083008,87.3765335083008,108.300567626953,108.300567626953,108.300567626953,138.280052185059,138.280052185059,45.6423721313477,45.6423721313477,45.6423721313477,45.6423721313477,77.123046875,77.123046875,77.123046875,77.123046875,97.3890609741211,97.3890609741211,97.3890609741211,129.201377868652,129.201377868652,129.201377868652,129.201377868652,146.387557983398,146.387557983398,146.387557983398,146.387557983398,146.387557983398,146.387557983398,67.314453125,67.314453125,67.314453125,67.314453125,67.314453125,67.314453125,88.4995269775391,88.4995269775391,88.4995269775391,88.4995269775391,88.4995269775391,88.4995269775391,119.394882202148,119.394882202148,119.394882202148,119.394882202148,140.450752258301,140.450752258301,140.450752258301,57.3534851074219,57.3534851074219,78.4078903198242,78.4078903198242,102.806968688965,102.806968688965,102.806968688965,121.432525634766,121.432525634766,121.432525634766,121.432525634766,121.432525634766,146.357315063477,146.357315063477,146.357315063477,59.2542114257812,59.2542114257812,90.6715698242188,90.6715698242188,90.6715698242188,112.05339050293,112.05339050293,144.257400512695,144.257400512695,144.257400512695,144.257400512695,144.257400512695,50.7940826416016,50.7940826416016,50.7940826416016,50.7940826416016,50.7940826416016,50.7940826416016,82.6663131713867,82.6663131713867,82.6663131713867,82.6663131713867,82.6663131713867,104.110847473145,104.110847473145,104.110847473145,104.110847473145,104.110847473145,104.110847473145,136.246925354004,136.246925354004,136.246925354004,43.3182220458984,43.3182220458984,43.3182220458984,43.3182220458984,43.3182220458984,74.60498046875,74.60498046875,74.60498046875,95.7245025634766,95.7245025634766,128.252471923828,128.252471923828,128.252471923828,128.252471923828,128.252471923828,146.352241516113,146.352241516113,146.352241516113,67.3252868652344,67.3252868652344,67.3252868652344,67.3252868652344,67.3252868652344,89.0985488891602,89.0985488891602,121.302070617676,121.302070617676,141.374092102051,141.374092102051,141.374092102051,57.0925827026367,57.0925827026367,57.0925827026367,57.0925827026367,57.0925827026367,57.0925827026367,78.0808715820312,78.0808715820312,78.0808715820312,78.0808715820312,78.0808715820312,109.82543182373,109.82543182373,131.075981140137,131.075981140137,131.075981140137,131.075981140137,131.075981140137,48.9634017944336,48.9634017944336,70.2772598266602,70.2772598266602,102.350280761719,102.350280761719,102.350280761719,102.350280761719,102.350280761719,123.862747192383,123.862747192383,123.862747192383,146.358612060547,146.358612060547,146.358612060547,63.0631637573242,63.0631637573242,94.9367980957031,94.9367980957031,94.9367980957031,94.9367980957031,94.9367980957031,116.776069641113,116.776069641113,146.359817504883,146.359817504883,146.359817504883,56.6369476318359,56.6369476318359,56.6369476318359,56.6369476318359,56.6369476318359,89.166389465332,89.166389465332,110.616851806641,110.616851806641,143.146522521973,143.146522521973,50.343017578125,50.343017578125,82.4738159179688,104.110870361328,104.110870361328,136.044311523438,136.044311523438,136.044311523438,43.5915908813477,43.5915908813477,74.4756698608398,74.4756698608398,74.4756698608398,74.4756698608398,93.6231994628906,93.6231994628906,124.571907043457,124.571907043457,145.555793762207,145.555793762207,145.555793762207,145.555793762207,61.4937286376953,61.4937286376953,82.6073150634766,82.6073150634766,82.6073150634766,82.6073150634766,82.6073150634766,114.605667114258,114.605667114258,114.605667114258,134.540145874023,134.540145874023,51.2677154541016,51.2677154541016,51.2677154541016,72.0549545288086,72.0549545288086,72.0549545288086,72.0549545288086,72.0549545288086,104.381965637207,104.381965637207,104.381965637207,104.381965637207,104.381965637207,125.56396484375,125.56396484375,125.56396484375,125.56396484375,125.56396484375,44.4471664428711,44.4471664428711,65.0372543334961,65.0372543334961,96.6424179077148,96.6424179077148,118.213592529297,118.213592529297,146.342727661133,146.342727661133,146.342727661133,57.2360992431641,57.2360992431641,57.2360992431641,57.2360992431641,57.2360992431641,57.2360992431641,88.644401550293,88.644401550293,88.644401550293,88.644401550293,109.363677978516,109.363677978516,141.165687561035,141.165687561035,48.2524490356445,48.2524490356445,79.9893035888672,79.9893035888672,99.2675476074219,99.2675476074219,99.2675476074219,130.675338745117,130.675338745117,146.345970153809,146.345970153809,146.345970153809,66.3504409790039,66.3504409790039,66.3504409790039,66.3504409790039,66.3504409790039,87.5301361083984,87.5301361083984,119.595008850098,119.595008850098,119.595008850098,119.595008850098,119.595008850098,119.595008850098,139.461059570312,139.461059570312,139.461059570312,139.461059570312,139.461059570312,139.461059570312,57.6279067993164,57.6279067993164,78.8701553344727,78.8701553344727,78.8701553344727,78.8701553344727,78.8701553344727,110.470329284668,110.470329284668,110.470329284668,110.470329284668,110.470329284668,110.470329284668,131.44953918457,131.44953918457,131.44953918457,131.44953918457,131.44953918457,49.8924102783203,49.8924102783203,71.1350708007812,71.1350708007812,103.521583557129,103.521583557129,125.026344299316,125.026344299316,59.6767044067383,59.6767044067383,59.6767044067383,63.9240951538086,63.9240951538086,63.9240951538086,63.9240951538086,95.9835433959961,95.9835433959961,95.9835433959961,117.815872192383,117.815872192383,146.335296630859,146.335296630859,146.335296630859,55.8353118896484,55.8353118896484,87.0421371459961,87.0421371459961,108.742637634277,108.742637634277,141.130493164062,141.130493164062,47.7718734741211,47.7718734741211,47.7718734741211,47.7718734741211,47.7718734741211,47.7718734741211,79.1751022338867,79.1751022338867,99.564338684082,99.564338684082,99.564338684082,99.564338684082,129.525215148926,129.525215148926,146.374420166016,146.374420166016,146.374420166016,65.8017654418945,65.8017654418945,65.8017654418945,85.9942855834961,85.9942855834961,85.9942855834961,115.627029418945,115.627029418945,135.098709106445,135.098709106445,135.098709106445,135.098709106445,135.098709106445,51.3788375854492,51.3788375854492,51.3788375854492,51.3788375854492,51.3788375854492,71.9645462036133,71.9645462036133,101.728858947754,101.728858947754,121.593757629395,121.593757629395,146.375640869141,146.375640869141,146.375640869141,57.2143707275391,57.2143707275391,86.9786605834961,86.9786605834961,86.9786605834961,106.580917358398,106.580917358398],"meminc":[0,0,21.3809814453125,0,26.4395217895508,0,17.120475769043,0,0,0,0,19.0211486816406,0,0,-85.5980377197266,0,32.2110137939453,0,19.3566589355469,0,0,0,0,0,30.3698348999023,0,-94.6664123535156,0,31.7513580322266,0,0,0,0,20.6683654785156,0,29.7244415283203,0,16.202018737793,0,0,-79.9804153442383,0,21.3208770751953,0,30.4328460693359,0,20.3982620239258,0,-85.720817565918,0,20.9953842163086,0,0,0,30.9599075317383,0,0,20.2038421630859,0,21.384765625,0,0,-84.2957534790039,0,32.538200378418,0,21.3839340209961,0,0,0,0,30.3784713745117,0,0,-92.0402069091797,0,31.0934143066406,0,20.4740600585938,0,0,0,0,30.5706481933594,0,9.91165161132812,0,0,0,0,0,-73.609016418457,0,0,0,0,20.8673095703125,0,0,29.9812316894531,0,0,0,0,20.1400756835938,0,-84.0439071655273,0,20.8668670654297,0,0,30.3776321411133,0,0,0,0,0,20.0120468139648,0,0,-84.7686920166016,0,0,0,0,20.5413360595703,0,31.8109664916992,0,21.0635375976562,0,26.7643585205078,0,0,-89.1565628051758,0,30.4392776489258,0,19.286247253418,0,29.589469909668,0,0,9.84078979492188,0,0,-73.0820770263672,0,0,21.0556411743164,0,29.3176422119141,0,0,18.8930282592773,0,0,-85.2022705078125,0,0,20.4713592529297,0,0,30.8319473266602,0,0,0,0,0,19.6819610595703,0,0,-40.3417434692383,0,0,-24.6797409057617,0,30.9026031494141,0,19.6885986328125,0,0,29.1259307861328,0,3.34571838378906,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,19.4862899780273,0,0,31.6250534057617,0,0,0,0,21.8401870727539,0,30.6339492797852,0,0,-91.974983215332,0,0,0,0,31.3666534423828,0,0,19.3506927490234,0,28.3423614501953,0,0,12.9238586425781,0,0,0,0,0,-80.1800003051758,0,0,0,0,0,19.2199020385742,0,0,0,0,28.4084396362305,0,0,0,0,18.5599899291992,0,0,-84.4784317016602,0,0,19.8125305175781,0,0,30.7651672363281,0,20.4663391113281,0,0,0,27.4271850585938,0,0,-91.5153656005859,0,31.0288467407227,0,19.5464859008789,0,0,0,0,28.271858215332,0,0,12.6622543334961,0,0,0,0,0,-76.9475936889648,0,0,0,0,20.6651840209961,0,0,31.814826965332,0,0,0,0,21.6412200927734,0,0,0,0,0,-82.9032745361328,0,21.0548782348633,0,0,32.6681365966797,21.1894302368164,0,0,-81.8033676147461,0,0,20.7288436889648,0,32.7285385131836,0,21.1261215209961,0,0,0,-82.3220672607422,0,0,19.6808471679688,0,0,31.2193603515625,0,20.9953918457031,0,0,0,0,28.4714965820312,0,0,-90.0704345703125,0,31.0919342041016,0,0,0,0,20.7278594970703,0,30.498405456543,0,-93.0063018798828,0,0,0,0,29.8449096679688,0,0,21.0651245117188,0,0,0,0,29.9794158935547,0,0,0,0,0,19.815055847168,0,0,-82.3311996459961,0,0,21.3249053955078,0,32.212158203125,0,0,21.252555847168,0,0,0,-81.5514831542969,0,20.0139389038086,0,0,0,0,30.3684921264648,0,20.5367050170898,0,0,0,0,0,-82.3934860229492,0,20.2700805664062,0,31.0374069213867,0,19.6806335449219,0,29.4601593017578,0,0,0,0,0,-92.6416702270508,0,0,31.2974472045898,0,0,0,21.0552062988281,0,32.083610534668,0,-92.7002105712891,0,0,0,0,30.1184463500977,0,0,20.9230422973633,0,31.8790283203125,0,0,0,0,18.1076354980469,0,0,-79.6364364624023,0,0,0,0,21.1220169067383,0,31.8866424560547,0,0,0,0,21.0580596923828,0,-81.9447250366211,0,21.0551528930664,0,31.4192504882812,0,18.1710739135742,0,-82.8435440063477,0,0,0,0,0,20.6620559692383,0,0,31.489631652832,0,0,20.4026870727539,0,27.155158996582,0,0,-89.4732666015625,0,30.517448425293,0,20.9240341186523,0,0,29.9794845581055,0,-92.6376800537109,0,0,0,31.4806747436523,0,0,0,20.2660140991211,0,0,31.8123168945312,0,0,0,17.1861801147461,0,0,0,0,0,-79.0731048583984,0,0,0,0,0,21.1850738525391,0,0,0,0,0,30.8953552246094,0,0,0,21.0558700561523,0,0,-83.0972671508789,0,21.0544052124023,0,24.3990783691406,0,0,18.6255569458008,0,0,0,0,24.9247894287109,0,0,-87.1031036376953,0,31.4173583984375,0,0,21.3818206787109,0,32.2040100097656,0,0,0,0,-93.4633178710938,0,0,0,0,0,31.8722305297852,0,0,0,0,21.4445343017578,0,0,0,0,0,32.1360778808594,0,0,-92.9287033081055,0,0,0,0,31.2867584228516,0,0,21.1195220947266,0,32.5279693603516,0,0,0,0,18.0997695922852,0,0,-79.0269546508789,0,0,0,0,21.7732620239258,0,32.2035217285156,0,20.072021484375,0,0,-84.2815093994141,0,0,0,0,0,20.9882888793945,0,0,0,0,31.7445602416992,0,21.2505493164062,0,0,0,0,-82.1125793457031,0,21.3138580322266,0,32.0730209350586,0,0,0,0,21.5124664306641,0,0,22.4958648681641,0,0,-83.2954483032227,0,31.8736343383789,0,0,0,0,21.8392715454102,0,29.5837478637695,0,0,-89.7228698730469,0,0,0,0,32.5294418334961,0,21.4504623413086,0,32.529670715332,0,-92.8035049438477,0,32.1307983398438,21.6370544433594,0,31.9334411621094,0,0,-92.4527206420898,0,30.8840789794922,0,0,0,19.1475296020508,0,30.9487075805664,0,20.98388671875,0,0,0,-84.0620651245117,0,21.1135864257812,0,0,0,0,31.9983520507812,0,0,19.9344787597656,0,-83.2724304199219,0,0,20.787239074707,0,0,0,0,32.3270111083984,0,0,0,0,21.181999206543,0,0,0,0,-81.1167984008789,0,20.590087890625,0,31.6051635742188,0,21.571174621582,0,28.1291351318359,0,0,-89.1066284179688,0,0,0,0,0,31.4083023071289,0,0,0,20.7192764282227,0,31.8020095825195,0,-92.9132385253906,0,31.7368545532227,0,19.2782440185547,0,0,31.4077911376953,0,15.6706314086914,0,0,-79.9955291748047,0,0,0,0,21.1796951293945,0,32.0648727416992,0,0,0,0,0,19.8660507202148,0,0,0,0,0,-81.8331527709961,0,21.2422485351562,0,0,0,0,31.6001739501953,0,0,0,0,0,20.9792098999023,0,0,0,0,-81.55712890625,0,21.2426605224609,0,32.3865127563477,0,21.5047607421875,0,-65.3496398925781,0,0,4.24739074707031,0,0,0,32.0594482421875,0,0,21.8323287963867,0,28.5194244384766,0,0,-90.4999847412109,0,31.2068252563477,0,21.7005004882812,0,32.3878555297852,0,-93.3586196899414,0,0,0,0,0,31.4032287597656,0,20.3892364501953,0,0,0,29.9608764648438,0,16.8492050170898,0,0,-80.5726547241211,0,0,20.1925201416016,0,0,29.6327438354492,0,19.4716796875,0,0,0,0,-83.7198715209961,0,0,0,0,20.5857086181641,0,29.7643127441406,0,19.8648986816406,0,24.7818832397461,0,0,-89.1612701416016,0,29.764289855957,0,0,19.6022567749023,0],"filename":[null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpfVvLw6/file3c4757691563.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

`profvis()` utiliza a su vez la función `Rprof()` de R base, este es un 
perfilador de muestreo que registra cambios en la pila de funciones, funciona 
tomando muestras a intervalos regulares y tabula cuánto tiempo se lleva en cada 
función.

### Estrategias para mejorar desempeño {-}

Algunas estrategias para mejorar desempeño:

1. Utilizar apropiadamente funciones de R, o funciones de paquetes que muchas 
veces están mejor escritas de lo que nosotros podríamos hacer. 
2. Hacer lo menos posible. 
3. Usar funciones vectorizadas en R (casi siempre). No hacer crecer objetos (es 
preferible definir su tamaño antes de operar en ellos).
4. Paralelizar.
5. La más simple y muchas veces la más barata: conseguir una máquina más grande 
(por ejemplo [Amazon web services](http://aws.amazon.com)).

A continuación revisamos y ejemplificamos los puntos anteriores, los ejemplos de 
código se tomaron del taller [EfficientR](https://github.com/Bioconductor/BiocAdvanced/blob/LatAm-2018/vignettes/EfficientR.Rmd), impartido por Martin Morgan.

#### Utilizar apropiadamente funciones de R {-}

Si el cuello de botella es la función de un paquete vale la pena buscar 
alternativas, [CRAN task views](http://cran.rstudio.com/web/views/) es un buen 
lugar para buscar.

##### Hacer lo menos posible {-} 

Utiliza funciones más específicas, por ejemplo: 

* rowSums(), colSums(), rowMeans() y colMeans() son más rápidas que las 
invocaciones equivalentes de apply().  

* Si quieres checar si un vector contiene un valor `any(x == 10)` es más veloz 
que `10 %in% x`, esto es porque examinar igualdad es más sencillo que examinar 
inclusión en un conjunto.  
Este conocimiento requiere que conozcas alternativas, para ello debes construir 
tu _vocabulario_, puedes comenzar por lo 
[básico](http://adv-r.had.co.nz/Vocabulary.html#vocabulary) e ir incrementando 
conforme lees código.  
Otro caso es cuando las funciones son más rápidas cunado les das más información 
del problema, por ejemplo:

* read.csv(), especificar las clases de las columnas con colClasses.  
* factor() especifica los niveles con el argumento levels.

##### Usar funciones vectorizadas en R {-}

Es común escuchar que en R _vectorizar_ es conveniente, el enfoque vectorizado 
va más allá que evitar ciclos _for_:

* Pensar en objetos, en lugar de enfocarse en las componentes de un vector, se 
piensa únicamente en el vector completo.  

* Los ciclos en las funciones vectorizadas de R están escritos en C, lo que los 
hace más veloces.

Las funciones vectorizadas programadas en R pueden mejorar la interfaz de una 
función pero no necesariamente mejorar el desempeño. Usar vectorización para 
desempeño implica encontrar funciones de R implementadas en C.

Al igual que en el punto anterior, vectorizar requiere encontrar las
funciones apropiadas, algunos ejemplos incluyen: _rowSums(), colSums(), 
rowMeans() y colMeans().

Ejemplo: iteración (`for`, `lapply()`, `sapply()`, `vapply()`, `mapply()`, 
`apply()`, ...) en un vector de `n` elementos llama a R base `n` veces


```r
compute_pi0 <- function(m) {
    s = 0
    sign = 1
    for (n in 0:m) {
        s = s + sign / (2 * n + 1)
        sign = -sign
    }
    4 * s
}

compute_pi1 <- function(m) {
    even <- seq(0, m, by = 2)
    odd <- seq(1, m, by = 2)
    s <- sum(1 / (2 * even + 1)) - sum(1 / (2 * odd + 1))
    4 * s
}
m <- 1e6
```

Utilizamos el paquete [microbenchmark](https://cran.r-project.org/package=microbenchmark)
para medir tiempos varias veces.


```r
library(microbenchmark)
m <- 1e4
result <- microbenchmark(
    compute_pi0(m),
    compute_pi0(m * 10),
    compute_pi0(m * 100),
    compute_pi1(m),
    compute_pi1(m * 10),
    compute_pi1(m * 100),
    compute_pi1(m * 1000),
    times = 20
)
result
#> Unit: microseconds
#>                   expr        min         lq        mean     median          uq
#>         compute_pi0(m)   1033.677   1049.081   1055.1813   1057.214   1061.8865
#>    compute_pi0(m * 10)  10451.949  10482.325  10879.3765  10520.546  10572.2855
#>   compute_pi0(m * 100) 104721.467 104971.254 105123.9494 105119.327 105252.7820
#>         compute_pi1(m)    161.444    222.245    651.2346    261.324    284.2485
#>    compute_pi1(m * 10)   1268.423   1330.380   1371.5979   1386.994   1414.9030
#>   compute_pi1(m * 100)  12659.731  15351.993  24239.6331  20128.395  24399.7470
#>  compute_pi1(m * 1000) 243394.356 339099.853 340881.2567 353790.552 359846.8385
#>         max neval
#>    1074.163    20
#>   16847.269    20
#>  105804.163    20
#>    8333.733    20
#>    1428.012    20
#>  116345.024    20
#>  461054.585    20
```

#### Evitar copias {-}

Otro aspecto importante es que generalmente conviene asignar objetos en lugar de 
hacerlos crecer (es más eficiente asignar toda la memoria necesaria antes del 
cálculo que asignarla sucesivamente). Esto es porque cuando se usan 
instrucciones para crear un objeto más grande (e.g. append(), cbind(), c(),
rbind()) R debe primero asignar espacio a un nuevo objeto y luego copiar al 
nuevo lugar. Para leer más sobre esto @burns2012r es una buena 
referencia.

Ejemplo: *crecer* un vector puede causar que R copie de manera repetida el 
vector chico en el nuevo vector, aumentando el tiempo de ejecución. 

Solución: crear vector de tamaño final y llenarlo con valores. Las funciones 
como `lapply()` y map hacen esto de manera automática y son más sencillas que los 
ciclos `for`.


```r
memory_copy1 <- function(n) {
    result <- numeric()
    for (i in seq_len(n))
        result <- c(result, 1/i)
    result
}

memory_copy2 <- function(n) {
    result <- numeric()
    for (i in seq_len(n))
        result[i] <- 1 / i
    result
}

pre_allocate1 <- function(n) {
    result <- numeric(n)
    for (i in seq_len(n))
        result[i] <- 1 / i
    result
}

pre_allocate2 <- function(n) {
    vapply(seq_len(n), function(i) 1 / i, numeric(1))
}

vectorized <- function(n) {
    1 / seq_len(n)
}

n <- 10000
microbenchmark(
    memory_copy1(n),
    memory_copy2(n),
    pre_allocate1(n),
    pre_allocate2(n),
    vectorized(n),
    times = 10, unit = "relative"
)
#> Unit: relative
#>              expr        min         lq       mean     median         uq
#>   memory_copy1(n) 5010.34428 4035.34741 607.193017 3798.22205 3246.38620
#>   memory_copy2(n)   93.13468   75.85373  12.526764   71.48353   59.43918
#>  pre_allocate1(n)   20.58214   16.74391   3.927884   15.89485   13.40176
#>  pre_allocate2(n)  196.32682  158.97258  24.956454  152.31521  131.07153
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  94.118759    10
#>   3.114420    10
#>   2.009718    10
#>   4.551792    10
#>   1.000000    10
```

Un caso común donde se hacen copias sin necesidad es al trabajar con 
data.frames.

Ejemplo: actualizar un data.frame copia el data.frame completo.

Solución: operar en vectores y actualiza el data.frame al final.


```r
n <- 1e4
df <- data.frame(Index = 1:n, A = seq(10, by = 1, length.out = n))

f1 <- function(df) {
    ## constants
    cost1 <- 3
    cost2 <- 0.05
    cost3 <- 50

    ## update data.frame -- copies entire data frame each time!
    df$S[1] <- cost1
    for (j in 2:(n))
        df$S[j] <- df$S[j - 1] - cost3 + df$S[j - 1] * cost2 / 12

    ## return result
    df
}
.f2helper <- function(cost1, cost2, cost3, n) {
    ## create the result vector separately
    cost2 <- cost2 / 12   # 'hoist' common operations
    result <- numeric(n)
    result[1] <- cost1
    for (j in 2:(n))
        result[j] <- (1 + cost2) * result[j - 1] - cost3
    result
}

f2 <- function(df) {
    cost1 <- 3
    cost2 <- 0.05
    cost3 <- 50

    ## update the data.frame once
    df$S <- .f2helper(cost1, cost2, cost3, n)
    df
}

microbenchmark(
    f1(df),
    f2(df),
    times = 5, unit = "relative"
)
#> Unit: relative
#>    expr      min      lq     mean   median       uq      max neval
#>  f1(df) 239.9147 235.471 89.61058 231.7121 78.98066 40.17611     5
#>  f2(df)   1.0000   1.000  1.00000   1.0000  1.00000  1.00000     5
```

#### Paralelizar {-}

Paralelizar usa varios _cores_  para trabajar de manera simultánea en varias 
secciones de un problema, no reduce el tiempo computacional pero incrementa el 
tiempo del usuario pues aprovecha los recursos. Como referencia está 
[Parallel Computing for Data Science] de Norm Matloff.

## Lecturas y recursos recomendados de R

Algunas recomendaciones para mejorar el flujo de trabajo y aprender nuevas
herramientas de R son:

* [What they forgot to teach you about R](https://whattheyforgot.org) de 
Jenny Bryan y Jim Hester. Flujos de trabajo basados en proyectos que facilitan 
el trabajo del analista.

* [Good enough practices in scientific computing](https://journals.plos.org/ploscompbiol/article?id=10.1371/journal.pcbi.1005510), 
Greg Wilson, Jennifer Bryan, et al. 

* [Happy Git with R](https://happygitwithr.com), Jenny Bryan y Jim Hester.

* [R Markdown: The Definitive Guide](https://bookdown.org/yihui/rmarkdown/), 
Yihui Xie, J. J. Allaire, Garrett Grolemund.
