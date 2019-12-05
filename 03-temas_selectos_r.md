
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
#>    id           a          b        c        d
#> 1   1 -1.18688351  2.9006395 3.168742 3.135200
#> 2   2 -1.51887789  3.2458571 1.369252 4.424412
#> 3   3 -1.36438267  1.0158107 3.594310 3.891270
#> 4   4  1.81291847  1.3888213 2.985978 2.727282
#> 5   5 -0.38008858 -0.1688064 2.543343 3.457098
#> 6   6 -1.64796565  1.3137741 2.905813 3.269625
#> 7   7 -0.19430762  1.8763914 2.418071 2.946325
#> 8   8 -0.07210022  2.4854930 1.977271 3.002364
#> 9   9  0.12072886  2.0459092 3.626008 3.182824
#> 10 10 -1.51022365  2.8493524 2.709297 2.403379
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.5941182
mean(df$b)
#> [1] 1.895324
mean(df$c)
#> [1] 2.729809
mean(df$d)
#> [1] 3.243978
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.5941182  1.8953242  2.7298086  3.2439778
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
#> [1] -0.5941182  1.8953242  2.7298086  3.2439778
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
#> [1]  5.5000000 -0.5941182  1.8953242  2.7298086  3.2439778
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
#> [1]  5.500000 -0.783486  1.961150  2.807555  3.159012
col_describe(df, mean)
#> [1]  5.5000000 -0.5941182  1.8953242  2.7298086  3.2439778
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
#>         id          a          b          c          d 
#>  5.5000000 -0.5941182  1.8953242  2.7298086  3.2439778
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
#>   4.224   0.164   4.387
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.003   0.671
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
#>  14.202   0.873  10.740
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
#>   0.119   0.000   0.118
plyr_st
#>    user  system elapsed 
#>   4.473   0.016   4.489
est_l_st
#>    user  system elapsed 
#>  65.477   1.287  66.768
est_r_st
#>    user  system elapsed 
#>   0.396   0.012   0.408
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

<!--html_preserve--><div id="htmlwidget-edecb677a69243ed0cea" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-edecb677a69243ed0cea">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,3,3,3,4,4,5,5,5,6,6,6,7,7,7,8,8,9,9,10,10,11,11,11,12,12,12,13,13,14,14,14,15,15,16,16,17,17,18,18,19,19,19,20,20,20,20,20,21,21,22,22,22,22,22,23,23,23,24,24,24,24,24,25,25,25,25,25,26,26,27,27,28,28,29,29,29,29,29,30,30,30,30,30,31,31,32,32,33,33,34,34,35,35,35,36,36,36,36,36,37,37,37,38,38,39,39,40,40,41,41,41,42,42,43,43,44,44,45,45,46,46,46,47,47,47,48,48,49,49,49,49,50,50,51,51,52,52,52,52,53,53,53,53,53,54,54,55,55,55,56,56,57,57,58,58,59,59,59,60,60,60,61,61,62,62,62,62,62,63,63,63,63,64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,74,75,75,75,76,76,76,77,77,77,77,77,77,78,79,79,80,80,81,81,82,82,82,83,83,84,84,85,85,86,86,87,87,87,88,88,89,89,89,89,89,90,90,91,91,92,92,93,93,94,94,95,95,96,96,96,96,96,96,97,97,97,97,97,97,98,98,99,99,99,100,100,100,100,101,101,101,101,101,101,102,102,102,102,102,103,103,104,104,105,105,105,106,106,106,107,107,107,107,107,108,108,108,109,109,109,109,109,110,110,111,111,111,111,111,111,112,112,113,113,114,114,115,115,116,116,117,117,118,118,119,119,120,120,121,121,122,122,122,122,122,123,123,123,123,123,124,124,124,125,125,125,126,126,127,127,127,128,128,128,129,129,129,129,129,130,130,131,131,132,132,133,133,133,134,134,135,135,136,136,136,136,137,137,138,138,139,139,139,140,140,140,140,141,141,141,142,142,142,143,143,143,143,143,143,144,144,144,145,145,145,146,146,146,146,146,146,147,147,147,147,148,148,148,148,148,149,149,150,150,150,151,151,151,151,151,151,152,152,153,153,153,154,154,155,155,155,156,156,157,157,157,157,158,158,158,158,158,159,160,160,160,161,161,161,161,162,162,163,163,163,164,164,165,165,166,166,166,166,166,166,167,167,168,168,169,169,169,169,169,170,170,170,171,171,171,171,171,172,172,172,172,172,172,173,173,173,174,174,174,174,174,175,175,175,176,176,177,177,178,178,178,179,179,179,180,180,180,180,180,181,181,181,182,182,183,183,183,184,184,184,184,185,185,185,185,186,186,187,187,188,188,189,189,189,189,189,190,190,191,191,191,192,192,192,193,193,193,193,194,194,195,195,196,196,196,197,197,198,198,199,199,200,200,200,201,201,202,202,203,203,204,204,205,205,206,206,206,207,207,208,208,208,208,209,209,209,210,210,211,211,212,212,213,213,213,213,213,213,214,214,214,215,215,215,215,215,216,216,216,217,217,218,218,219,219,219,219,220,220,221,221,222,222,222,223,223,224,224,225,225,225,226,226,227,227,227,227,228,228,228,228,229,229,229,229,229,230,230,231,231,231,232,232,233,233,234,234,234,234,234,234,235,235,235,236,236,236,237,237,237,238,238,238,238,238,239,239,240,240,241,241,242,242,242,242,242,242,243,243,243,243,243,244,244,244,244,245,246,246,246,246,247,247,248,248,249,249,249,250,250,250,250,250,251,251,252,252,253,253,254,254,255,255,256,256,257,257,258,258,258,259,259,259,260,260,260,260,261,261,262,262,262,263,263,264,264,265,265,266,266,266,266,266,267,267,268,268,269,269,270,270,270,271,271,271,272,272,272,273,273,274,274,275,275,275,275,275,275,276,276,277,277,277,277,278,278,279,279,280,280,280,281,281,282,282,282,283,283,284,284,284,284,284],"depth":[2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,4,3,2,1,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","==","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","nrow","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","dim","[.data.frame","[","sum","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,null,null,null,null,1,null,1,1,null,1,1,null,null,null,null,null,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,null,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1],"linenum":[9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,11,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,11,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,null,null,null,null,11,null,9,9,null,9,9,null,null,null,null,null,11,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,null,11,10,10,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,11,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,11,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,9,9,10,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,13],"memalloc":[63.1583480834961,63.1583480834961,83.8833694458008,83.8833694458008,109.92943572998,109.92943572998,109.92943572998,109.92943572998,109.92943572998,127.57447052002,127.57447052002,146.33341217041,146.33341217041,146.33341217041,59.6201858520508,59.6201858520508,59.6201858520508,91.4379806518555,91.4379806518555,91.4379806518555,111.384780883789,111.384780883789,141.754570007324,141.754570007324,44.7940216064453,44.7940216064453,76.4122848510742,76.4122848510742,76.4122848510742,96.8829116821289,96.8829116821289,96.8829116821289,126.868789672852,126.868789672852,146.352653503418,146.352653503418,146.352653503418,60.8620376586914,60.8620376586914,81.857177734375,81.857177734375,112.353378295898,112.353378295898,132.359184265137,132.359184265137,46.5695190429688,46.5695190429688,46.5695190429688,67.3010635375977,67.3010635375977,67.3010635375977,67.3010635375977,67.3010635375977,99.7075042724609,99.7075042724609,120.897804260254,120.897804260254,120.897804260254,120.897804260254,120.897804260254,146.347305297852,146.347305297852,146.347305297852,55.6253204345703,55.6253204345703,55.6253204345703,55.6253204345703,55.6253204345703,87.1125183105469,87.1125183105469,87.1125183105469,87.1125183105469,87.1125183105469,108.495475769043,108.495475769043,140.315460205078,140.315460205078,43.8832778930664,43.8832778930664,75.1743240356445,75.1743240356445,75.1743240356445,75.1743240356445,75.1743240356445,94.7931442260742,94.7931442260742,94.7931442260742,94.7931442260742,94.7931442260742,123.788223266602,123.788223266602,142.815338134766,142.815338134766,57.3296279907227,57.3296279907227,77.9360809326172,77.9360809326172,108.708358764648,108.708358764648,108.708358764648,128.587532043457,128.587532043457,128.587532043457,128.587532043457,128.587532043457,73.1912460327148,73.1912460327148,73.1912460327148,63.6322784423828,63.6322784423828,95.5236434936523,95.5236434936523,115.402656555176,115.402656555176,145.121780395508,145.121780395508,145.121780395508,49.7936706542969,49.7936706542969,80.3029403686523,80.3029403686523,100.703468322754,100.703468322754,132.196434020996,132.196434020996,146.36547088623,146.36547088623,146.36547088623,67.2433242797852,67.2433242797852,67.2433242797852,88.1734237670898,88.1734237670898,117.956253051758,117.956253051758,117.956253051758,117.956253051758,137.703636169434,137.703636169434,51.3712310791016,51.3712310791016,71.9711456298828,71.9711456298828,71.9711456298828,71.9711456298828,101.814002990723,101.814002990723,101.814002990723,101.814002990723,101.814002990723,121.949752807617,121.949752807617,146.354850769043,146.354850769043,146.354850769043,56.2317581176758,56.2317581176758,87.6558380126953,87.6558380126953,107.66641998291,107.66641998291,137.646286010742,137.646286010742,137.646286010742,146.372688293457,146.372688293457,146.372688293457,72.824592590332,72.824592590332,93.6887283325195,93.6887283325195,93.6887283325195,93.6887283325195,93.6887283325195,123.28254699707,123.28254699707,123.28254699707,123.28254699707,142.502540588379,142.502540588379,142.502540588379,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,146.373291015625,42.7887115478516,42.7887115478516,42.7887115478516,54.400260925293,54.400260925293,54.400260925293,74.8716049194336,74.8716049194336,74.8716049194336,106.886764526367,106.886764526367,106.886764526367,106.886764526367,106.886764526367,106.886764526367,128.335884094238,43.9706115722656,43.9706115722656,62.0783386230469,62.0783386230469,91.93505859375,91.93505859375,111.482429504395,111.482429504395,111.482429504395,140.672332763672,140.672332763672,45.5455627441406,45.5455627441406,75.385009765625,75.385009765625,95.0012435913086,95.0012435913086,124.520866394043,124.520866394043,124.520866394043,144.000396728516,144.000396728516,59.789680480957,59.789680480957,59.789680480957,59.789680480957,59.789680480957,80.5832290649414,80.5832290649414,112.528350830078,112.528350830078,133.592330932617,133.592330932617,49.8135223388672,49.8135223388672,70.4179534912109,70.4179534912109,101.901756286621,101.901756286621,121.513618469238,121.513618469238,121.513618469238,121.513618469238,121.513618469238,121.513618469238,146.377975463867,146.377975463867,146.377975463867,146.377975463867,146.377975463867,146.377975463867,57.0325469970703,57.0325469970703,88.5221252441406,88.5221252441406,88.5221252441406,109.51277923584,109.51277923584,109.51277923584,109.51277923584,140.863639831543,140.863639831543,140.863639831543,140.863639831543,140.863639831543,140.863639831543,45.4892959594727,45.4892959594727,45.4892959594727,45.4892959594727,45.4892959594727,74.5514678955078,74.5514678955078,95.4780731201172,95.4780731201172,127.033203125,127.033203125,127.033203125,146.383605957031,146.383605957031,146.383605957031,64.5178146362305,64.5178146362305,64.5178146362305,64.5178146362305,64.5178146362305,85.306022644043,85.306022644043,85.306022644043,117.122840881348,117.122840881348,117.122840881348,117.122840881348,117.122840881348,137.851379394531,137.851379394531,53.8930587768555,53.8930587768555,53.8930587768555,53.8930587768555,53.8930587768555,53.8930587768555,74.9451751708984,74.9451751708984,106.697883605957,106.697883605957,127.819129943848,127.819129943848,44.5101547241211,44.5101547241211,64.2559432983398,64.2559432983398,96.3927993774414,96.3927993774414,116.465065002441,116.465065002441,145.78052520752,145.78052520752,51.6617584228516,51.6617584228516,82.8855514526367,82.8855514526367,102.507133483887,102.507133483887,102.507133483887,102.507133483887,102.507133483887,131.372009277344,131.372009277344,131.372009277344,131.372009277344,131.372009277344,146.332038879395,146.332038879395,146.332038879395,65.7709121704102,65.7709121704102,65.7709121704102,85.9815826416016,85.9815826416016,117.537780761719,117.537780761719,117.537780761719,138.002410888672,138.002410888672,138.002410888672,54.3527450561523,54.3527450561523,54.3527450561523,54.3527450561523,54.3527450561523,75.2188034057617,75.2188034057617,106.179023742676,106.179023742676,126.647407531738,126.647407531738,43.9265213012695,43.9265213012695,43.9265213012695,64.1971130371094,64.1971130371094,96.0223922729492,96.0223922729492,116.227821350098,116.227821350098,116.227821350098,116.227821350098,145.622711181641,145.622711181641,51.9306945800781,51.9306945800781,83.4921951293945,83.4921951293945,83.4921951293945,104.939521789551,104.939521789551,104.939521789551,104.939521789551,136.957420349121,136.957420349121,136.957420349121,124.675804138184,124.675804138184,124.675804138184,72.2089920043945,72.2089920043945,72.2089920043945,72.2089920043945,72.2089920043945,72.2089920043945,92.7418060302734,92.7418060302734,92.7418060302734,124.225425720215,124.225425720215,124.225425720215,144.629692077637,144.629692077637,144.629692077637,144.629692077637,144.629692077637,144.629692077637,61.1227722167969,61.1227722167969,61.1227722167969,61.1227722167969,81.8536071777344,81.8536071777344,81.8536071777344,81.8536071777344,81.8536071777344,113.538841247559,113.538841247559,134.533668518066,134.533668518066,134.533668518066,51.540153503418,51.540153503418,51.540153503418,51.540153503418,51.540153503418,51.540153503418,72.0036010742188,72.0036010742188,101.979438781738,101.979438781738,101.979438781738,121.72624206543,121.72624206543,146.390449523926,146.390449523926,146.390449523926,57.1154632568359,57.1154632568359,86.5073623657227,86.5073623657227,86.5073623657227,86.5073623657227,106.972969055176,106.972969055176,106.972969055176,106.972969055176,106.972969055176,136.492309570312,146.332344055176,146.332344055176,146.332344055176,72.3468627929688,72.3468627929688,72.3468627929688,72.3468627929688,92.4923934936523,92.4923934936523,120.895767211914,120.895767211914,120.895767211914,139.7890625,139.7890625,54.4316101074219,54.4316101074219,74.7613067626953,74.7613067626953,74.7613067626953,74.7613067626953,74.7613067626953,74.7613067626953,106.635688781738,106.635688781738,127.430046081543,127.430046081543,42.8543548583984,42.8543548583984,42.8543548583984,42.8543548583984,42.8543548583984,63.0498886108398,63.0498886108398,63.0498886108398,94.6674194335938,94.6674194335938,94.6674194335938,94.6674194335938,94.6674194335938,115.394020080566,115.394020080566,115.394020080566,115.394020080566,115.394020080566,115.394020080566,146.353996276855,146.353996276855,146.353996276855,52.0391311645508,52.0391311645508,52.0391311645508,52.0391311645508,52.0391311645508,83.85205078125,83.85205078125,83.85205078125,104.905502319336,104.905502319336,137.174797058105,137.174797058105,86.6002807617188,86.6002807617188,86.6002807617188,73.3538284301758,73.3538284301758,73.3538284301758,93.6223754882812,93.6223754882812,93.6223754882812,93.6223754882812,93.6223754882812,125.30248260498,125.30248260498,125.30248260498,146.290298461914,146.290298461914,61.681510925293,61.681510925293,61.681510925293,82.2729797363281,82.2729797363281,82.2729797363281,82.2729797363281,114.277030944824,114.277030944824,114.277030944824,114.277030944824,134.542366027832,134.542366027832,48.4979934692383,48.4979934692383,67.5195693969727,67.5195693969727,98.4132308959961,98.4132308959961,98.4132308959961,98.4132308959961,98.4132308959961,119.136840820312,119.136840820312,146.352233886719,146.352233886719,146.352233886719,54.8623046875,54.8623046875,54.8623046875,84.7043685913086,84.7043685913086,84.7043685913086,84.7043685913086,105.561431884766,105.561431884766,136.258613586426,136.258613586426,146.35814666748,146.35814666748,146.35814666748,73.095458984375,73.095458984375,94.4776611328125,94.4776611328125,125.763305664062,125.763305664062,146.355133056641,146.355133056641,146.355133056641,63.7198715209961,63.7198715209961,85.0998611450195,85.0998611450195,115.924919128418,115.924919128418,135.92894744873,135.92894744873,52.2418899536133,52.2418899536133,72.7708206176758,72.7708206176758,72.7708206176758,104.382232666016,104.382232666016,125.10831451416,125.10831451416,125.10831451416,125.10831451416,140.207359313965,140.207359313965,140.207359313965,62.4721984863281,62.4721984863281,93.9537200927734,93.9537200927734,114.749153137207,114.749153137207,146.360298156738,146.360298156738,146.360298156738,146.360298156738,146.360298156738,146.360298156738,52.9659118652344,52.9659118652344,52.9659118652344,84.3755645751953,84.3755645751953,84.3755645751953,84.3755645751953,84.3755645751953,105.422302246094,105.422302246094,105.422302246094,137.814811706543,137.814811706543,44.4445724487305,44.4445724487305,75.7878112792969,75.7878112792969,75.7878112792969,75.7878112792969,94.7377700805664,94.7377700805664,126.47354888916,126.47354888916,146.342460632324,146.342460632324,146.342460632324,62.8706130981445,62.8706130981445,83.5256805419922,83.5256805419922,114.605659484863,114.605659484863,114.605659484863,134.015724182129,134.015724182129,49.9556274414062,49.9556274414062,49.9556274414062,49.9556274414062,69.890625,69.890625,69.890625,69.890625,101.890579223633,101.890579223633,101.890579223633,101.890579223633,101.890579223633,123.137474060059,123.137474060059,146.35124206543,146.35124206543,146.35124206543,59.463623046875,59.463623046875,80.9712371826172,80.9712371826172,102.215057373047,102.215057373047,102.215057373047,102.215057373047,102.215057373047,102.215057373047,134.344184875488,134.344184875488,134.344184875488,146.342720031738,146.342720031738,146.342720031738,72.6448593139648,72.6448593139648,72.6448593139648,91.6606369018555,91.6606369018555,91.6606369018555,91.6606369018555,91.6606369018555,124.11669921875,124.11669921875,145.165451049805,145.165451049805,62.4164886474609,62.4164886474609,83.3332824707031,83.3332824707031,83.3332824707031,83.3332824707031,83.3332824707031,83.3332824707031,113.759056091309,113.759056091309,113.759056091309,113.759056091309,113.759056091309,132.577255249023,132.577255249023,132.577255249023,132.577255249023,48.7119293212891,69.2358779907227,69.2358779907227,69.2358779907227,69.2358779907227,101.103507995605,101.103507995605,122.348388671875,122.348388671875,146.345283508301,146.345283508301,146.345283508301,60.0539093017578,60.0539093017578,60.0539093017578,60.0539093017578,60.0539093017578,91.7855606079102,91.7855606079102,113.092308044434,113.092308044434,143.51318359375,143.51318359375,49.8268661499023,49.8268661499023,81.3622207641602,81.3622207641602,102.144706726074,102.144706726074,134.270812988281,134.270812988281,146.334167480469,146.334167480469,146.334167480469,72.3817596435547,72.3817596435547,72.3817596435547,93.0333786010742,93.0333786010742,93.0333786010742,93.0333786010742,125.683143615723,125.683143615723,146.335289001465,146.335289001465,146.335289001465,60.8178024291992,60.8178024291992,81.4692840576172,81.4692840576172,113.463401794434,113.463401794434,134.57462310791,134.57462310791,134.57462310791,134.57462310791,134.57462310791,50.8531494140625,50.8531494140625,71.8982849121094,71.8982849121094,103.956939697266,103.956939697266,124.936454772949,124.936454772949,124.936454772949,146.374412536621,146.374412536621,146.374412536621,59.2457733154297,59.2457733154297,59.2457733154297,88.8785171508789,88.8785171508789,109.202171325684,109.202171325684,138.573310852051,138.573310852051,138.573310852051,138.573310852051,138.573310852051,138.573310852051,43.7736663818359,43.7736663818359,73.3414459228516,73.3414459228516,73.3414459228516,73.3414459228516,93.5995025634766,93.5995025634766,124.281829833984,124.281829833984,144.015167236328,144.015167236328,144.015167236328,58.0663833618164,58.0663833618164,77.5380096435547,77.5380096435547,77.5380096435547,106.974128723145,106.974128723145,109.034553527832,109.034553527832,109.034553527832,109.034553527832,109.034553527832],"meminc":[0,0,20.7250213623047,0,26.0460662841797,0,0,0,0,17.6450347900391,0,18.7589416503906,0,0,-86.7132263183594,0,0,31.8177947998047,0,0,19.9468002319336,0,30.3697891235352,0,-96.9605484008789,0,31.6182632446289,0,0,20.4706268310547,0,0,29.9858779907227,0,19.4838638305664,0,0,-85.4906158447266,0,20.9951400756836,0,30.4962005615234,0,20.0058059692383,0,-85.789665222168,0,0,20.7315444946289,0,0,0,0,32.4064407348633,0,21.190299987793,0,0,0,0,25.4495010375977,0,0,-90.7219848632812,0,0,0,0,31.4871978759766,0,0,0,0,21.3829574584961,0,31.8199844360352,0,-96.4321823120117,0,31.2910461425781,0,0,0,0,19.6188201904297,0,0,0,0,28.9950790405273,0,19.0271148681641,0,-85.485710144043,0,20.6064529418945,0,30.7722778320312,0,0,19.8791732788086,0,0,0,0,-55.3962860107422,0,0,-9.55896759033203,0,31.8913650512695,0,19.8790130615234,0,29.719123840332,0,0,-95.3281097412109,0,30.5092697143555,0,20.4005279541016,0,31.4929656982422,0,14.1690368652344,0,0,-79.1221466064453,0,0,20.9300994873047,0,29.782829284668,0,0,0,19.7473831176758,0,-86.332405090332,0,20.5999145507812,0,0,0,29.8428573608398,0,0,0,0,20.1357498168945,0,24.4050979614258,0,0,-90.1230926513672,0,31.4240798950195,0,20.0105819702148,0,29.979866027832,0,0,8.72640228271484,0,0,-73.548095703125,0,20.8641357421875,0,0,0,0,29.5938186645508,0,0,0,19.2199935913086,0,0,3.87075042724609,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,11.6115493774414,0,0,20.4713439941406,0,0,32.0151596069336,0,0,0,0,0,21.4491195678711,-84.3652725219727,0,18.1077270507812,0,29.8567199707031,0,19.5473709106445,0,0,29.1899032592773,0,-95.1267700195312,0,29.8394470214844,0,19.6162338256836,0,29.5196228027344,0,0,19.4795303344727,0,-84.2107162475586,0,0,0,0,20.7935485839844,0,31.9451217651367,0,21.0639801025391,0,-83.77880859375,0,20.6044311523438,0,31.4838027954102,0,19.6118621826172,0,0,0,0,0,24.8643569946289,0,0,0,0,0,-89.3454284667969,0,31.4895782470703,0,0,20.9906539916992,0,0,0,31.3508605957031,0,0,0,0,0,-95.3743438720703,0,0,0,0,29.0621719360352,0,20.9266052246094,0,31.5551300048828,0,0,19.3504028320312,0,0,-81.8657913208008,0,0,0,0,20.7882080078125,0,0,31.8168182373047,0,0,0,0,20.7285385131836,0,-83.9583206176758,0,0,0,0,0,21.052116394043,0,31.7527084350586,0,21.1212463378906,0,-83.3089752197266,0,19.7457885742188,0,32.1368560791016,0,20.072265625,0,29.3154602050781,0,-94.118766784668,0,31.2237930297852,0,19.62158203125,0,0,0,0,28.864875793457,0,0,0,0,14.9600296020508,0,0,-80.5611267089844,0,0,20.2106704711914,0,31.5561981201172,0,0,20.4646301269531,0,0,-83.6496658325195,0,0,0,0,20.8660583496094,0,30.9602203369141,0,20.4683837890625,0,-82.7208862304688,0,0,20.2705917358398,0,31.8252792358398,0,20.2054290771484,0,0,0,29.394889831543,0,-93.6920166015625,0,31.5615005493164,0,0,21.4473266601562,0,0,0,32.0178985595703,0,0,-12.2816162109375,0,0,-52.4668121337891,0,0,0,0,0,20.5328140258789,0,0,31.4836196899414,0,0,20.4042663574219,0,0,0,0,0,-83.5069198608398,0,0,0,20.7308349609375,0,0,0,0,31.6852340698242,0,20.9948272705078,0,0,-82.9935150146484,0,0,0,0,0,20.4634475708008,0,29.9758377075195,0,0,19.7468032836914,0,24.6642074584961,0,0,-89.2749862670898,0,29.3918991088867,0,0,0,20.4656066894531,0,0,0,0,29.5193405151367,9.84003448486328,0,0,-73.985481262207,0,0,0,20.1455307006836,0,28.4033737182617,0,0,18.8932952880859,0,-85.3574523925781,0,20.3296966552734,0,0,0,0,0,31.874382019043,0,20.7943572998047,0,-84.5756912231445,0,0,0,0,20.1955337524414,0,0,31.6175308227539,0,0,0,0,20.7266006469727,0,0,0,0,0,30.9599761962891,0,0,-94.3148651123047,0,0,0,0,31.8129196166992,0,0,21.0534515380859,0,32.2692947387695,0,-50.5745162963867,0,0,-13.246452331543,0,0,20.2685470581055,0,0,0,0,31.6801071166992,0,0,20.9878158569336,0,-84.6087875366211,0,0,20.5914688110352,0,0,0,32.0040512084961,0,0,0,20.2653350830078,0,-86.0443725585938,0,19.0215759277344,0,30.8936614990234,0,0,0,0,20.7236099243164,0,27.2153930664062,0,0,-91.4899291992188,0,0,29.8420639038086,0,0,0,20.857063293457,0,30.6971817016602,0,10.0995330810547,0,0,-73.2626876831055,0,21.3822021484375,0,31.28564453125,0,20.5918273925781,0,0,-82.6352615356445,0,21.3799896240234,0,30.8250579833984,0,20.0040283203125,0,-83.6870574951172,0,20.5289306640625,0,0,31.6114120483398,0,20.7260818481445,0,0,0,15.0990447998047,0,0,-77.7351608276367,0,31.4815216064453,0,20.7954330444336,0,31.6111450195312,0,0,0,0,0,-93.3943862915039,0,0,31.4096527099609,0,0,0,0,21.0467376708984,0,0,32.3925094604492,0,-93.3702392578125,0,31.3432388305664,0,0,0,18.9499588012695,0,31.7357788085938,0,19.8689117431641,0,0,-83.4718475341797,0,20.6550674438477,0,31.0799789428711,0,0,19.4100646972656,0,-84.0600967407227,0,0,0,19.9349975585938,0,0,0,31.9999542236328,0,0,0,0,21.2468948364258,0,23.2137680053711,0,0,-86.8876190185547,0,21.5076141357422,0,21.2438201904297,0,0,0,0,0,32.1291275024414,0,0,11.99853515625,0,0,-73.6978607177734,0,0,19.0157775878906,0,0,0,0,32.4560623168945,0,21.0487518310547,0,-82.7489624023438,0,20.9167938232422,0,0,0,0,0,30.4257736206055,0,0,0,0,18.8181991577148,0,0,0,-83.8653259277344,20.5239486694336,0,0,0,31.8676300048828,0,21.2448806762695,0,23.9968948364258,0,0,-86.291374206543,0,0,0,0,31.7316513061523,0,21.3067474365234,0,30.4208755493164,0,-93.6863174438477,0,31.5353546142578,0,20.7824859619141,0,32.126106262207,0,12.0633544921875,0,0,-73.9524078369141,0,0,20.6516189575195,0,0,0,32.6497650146484,0,20.6521453857422,0,0,-85.5174865722656,0,20.651481628418,0,31.9941177368164,0,21.1112213134766,0,0,0,0,-83.7214736938477,0,21.0451354980469,0,32.0586547851562,0,20.9795150756836,0,0,21.4379577636719,0,0,-87.1286392211914,0,0,29.6327438354492,0,20.3236541748047,0,29.3711395263672,0,0,0,0,0,-94.7996444702148,0,29.5677795410156,0,0,0,20.258056640625,0,30.6823272705078,0,19.7333374023438,0,0,-85.9487838745117,0,19.4716262817383,0,0,29.4361190795898,0,2.0604248046875,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpoWWOBx/file3c62630e6b65.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq        mean      median
#>         compute_pi0(m)    789.999    802.0370   1129.7077    806.8435
#>    compute_pi0(m * 10)   7929.459   7951.5300   8048.1187   7981.7190
#>   compute_pi0(m * 100)  79394.960  79695.8055  80491.5508  79888.1055
#>         compute_pi1(m)    158.626    181.0035    275.4752    291.4600
#>    compute_pi1(m * 10)   1299.012   1384.0725   7899.6336   1467.5015
#>   compute_pi1(m * 100)  13383.293  14448.0055  35395.8797  19948.5690
#>  compute_pi1(m * 1000) 342870.051 378033.3125 432086.9419 451242.2685
#>           uq        max neval
#>     814.1640   7213.091    20
#>    8042.3360   8734.576    20
#>   80486.2060  88239.260    20
#>     326.1535    427.002    20
#>    1595.3770 121531.157    20
#>   25796.7110 179111.406    20
#>  481543.4805 501007.216    20
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
#>   memory_copy1(n) 5183.41707 3833.07945 628.740476 4006.65582 3970.43645
#>   memory_copy2(n)   99.55138   73.16762  14.752259   67.88413   64.26971
#>  pre_allocate1(n)   20.09684   14.91604   3.571504   14.02466   13.24295
#>  pre_allocate2(n)  198.38486  146.19851  22.220305  136.15043  129.38427
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  106.473657    10
#>    6.274648    10
#>    1.917200    10
#>    4.145254    10
#>    1.000000    10
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
#>    expr      min       lq     mean   median       uq      max neval
#>  f1(df) 348.6726 352.8418 118.5461 333.6893 91.60538 54.42847     5
#>  f2(df)   1.0000   1.0000   1.0000   1.0000  1.00000  1.00000     5
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
