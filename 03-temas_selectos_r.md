
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
#> Time Series:
#> Start = 1 
#> End = 100 
#> Frequency = 1 
#>   [1]  NA   6   9  12  15  18  21  24  27  30  33  36  39  42  45  48  51
#>  [18]  54  57  60  63  66  69  72  75  78  81  84  87  90  93  96  99 102
#>  [35] 105 108 111 114 117 120 123 126 129 132 135 138 141 144 147 150 153
#>  [52] 156 159 162 165 168 171 174 177 180 183 186 189 192 195 198 201 204
#>  [69] 207 210 213 216 219 222 225 228 231 234 237 240 243 246 249 252 255
#>  [86] 258 261 264 267 270 273 276 279 282 285 288 291 294 297  NA
```

Ahora cargamos `dplyr`.


```r
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
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
#>   [1]  NA   6   9  12  15  18  21  24  27  30  33  36  39  42  45  48  51
#>  [18]  54  57  60  63  66  69  72  75  78  81  84  87  90  93  96  99 102
#>  [35] 105 108 111 114 117 120 123 126 129 132 135 138 141 144 147 150 153
#>  [52] 156 159 162 165 168 171 174 177 180 183 186 189 192 195 198 201 204
#>  [69] 207 210 213 216 219 222 225 228 231 234 237 240 243 246 249 252 255
#>  [86] 258 261 264 267 270 273 276 279 282 285 288 291 294 297  NA
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
#>    id           a         b        c        d
#> 1   1 -0.09214073 1.1139721 4.018519 4.670653
#> 2   2 -0.63182581 2.2492831 2.398403 3.306206
#> 3   3  0.66174264 1.7195193 4.324928 5.213717
#> 4   4 -1.20527557 1.8116460 3.318948 6.628707
#> 5   5  1.64814238 1.0765408 3.069962 4.662651
#> 6   6  1.17298781 1.6421640 2.449522 4.790320
#> 7   7  0.49465698 1.2428957 2.706776 4.550370
#> 8   8 -0.20972337 1.4907209 1.794923 4.065807
#> 9   9 -2.10775705 0.5662776 5.084725 4.842825
#> 10 10 -0.37064820 4.2570627 3.107511 3.420776
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.06398409
mean(df$b)
#> [1] 1.717008
mean(df$c)
#> [1] 3.227422
mean(df$d)
#> [1] 4.615203
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.06398409  1.71700822  3.22742162  4.61520318
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
#> [1] -0.06398409  1.71700822  3.22742162  4.61520318
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
#> [1]  5.50000000 -0.06398409  1.71700822  3.22742162  4.61520318
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
#> [1]  5.500000 -0.150932  1.566442  3.088736  4.666652
col_describe(df, mean)
#> [1]  5.50000000 -0.06398409  1.71700822  3.22742162  4.61520318
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
#>  5.50000000 -0.06398409  1.71700822  3.22742162  4.61520318
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
#>   4.014   0.132   4.144
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.022   0.004   0.566
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
#>  13.413   0.741  10.296
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
#>   0.120   0.004   0.125
plyr_st
#>    user  system elapsed 
#>   4.204   0.004   4.205
est_l_st
#>    user  system elapsed 
#>  68.597   1.897  70.461
est_r_st
#>    user  system elapsed 
#>   0.415   0.004   0.419
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

<!--html_preserve--><div id="htmlwidget-727af8abd5cb1d2ee445" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-727af8abd5cb1d2ee445">{"x":{"message":{"prof":{"time":[1,1,1,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,8,8,8,8,8,9,9,10,10,10,11,11,11,11,11,12,12,12,12,12,13,13,14,14,15,15,16,16,16,17,17,18,18,19,19,19,20,20,20,20,21,21,22,22,23,23,24,24,24,25,25,26,26,27,27,28,28,29,29,30,30,30,31,31,31,32,32,32,33,33,33,33,33,33,34,34,34,35,35,36,36,37,37,38,38,38,39,39,39,40,40,40,40,40,41,41,42,42,42,43,43,43,43,43,44,44,44,44,44,45,45,45,46,46,46,47,47,47,48,48,48,49,49,49,50,50,50,50,50,51,51,52,52,52,53,53,53,53,54,54,55,55,56,56,56,57,57,58,58,59,59,60,61,61,61,61,62,62,63,63,64,64,65,65,66,66,67,67,68,68,69,69,69,70,70,71,71,71,71,71,72,72,72,73,73,73,73,73,74,74,75,75,76,76,77,77,77,78,78,79,79,79,79,79,80,80,80,80,80,81,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,94,94,95,95,96,96,97,97,97,98,98,98,99,100,100,101,101,102,102,103,103,103,104,104,105,105,106,106,106,106,106,107,107,107,108,108,109,109,109,109,109,110,110,111,111,112,112,113,113,113,113,113,114,114,115,115,115,115,115,115,116,116,117,117,117,118,118,118,119,119,119,120,120,121,121,121,121,121,122,122,122,123,123,124,124,125,125,125,126,126,126,126,126,126,127,127,127,127,127,128,128,129,129,129,130,130,130,130,131,131,132,132,133,133,133,134,134,134,134,134,134,135,135,136,136,136,136,136,136,137,137,138,138,138,138,139,139,140,140,140,140,141,141,142,142,142,143,143,143,143,143,144,144,144,145,145,146,146,146,146,146,146,147,147,147,147,148,148,149,149,150,150,151,151,151,151,152,152,153,153,153,154,154,154,155,155,155,155,155,155,156,156,157,157,157,157,157,158,158,159,159,159,160,160,160,161,161,162,162,162,163,163,163,163,163,163,164,164,164,165,165,166,166,166,167,167,168,168,169,169,170,170,171,171,171,172,172,173,173,173,174,174,174,175,175,175,175,175,176,176,176,177,177,178,178,179,179,180,180,181,181,181,181,181,182,182,183,183,183,183,183,184,184,184,184,184,185,185,186,186,187,187,188,188,189,189,189,190,190,190,191,191,191,192,192,193,193,193,194,194,195,195,196,196,197,197,198,198,199,199,199,200,200,201,201,201,201,201,202,202,203,203,203,203,203,203,204,204,204,204,204,204,205,205,205,206,206,207,207,207,207,207,208,208,209,209,209,210,210,211,211,212,212,213,213,213,214,214,215,215,215,215,215,216,216,216,217,217,217,217,217,218,218,218,219,219,219,220,220,220,220,221,221,222,222,222,223,223,224,224,225,225,226,226,227,227,227,228,228,228,228,228,229,229,230,230,231,231,232,232,232,233,233,234,234,235,235,235,236,236,237,237,237,237,237,238,238,238,238,239,239,240,240,241,241,241,242,242,243,243,244,244,245,246,246,246,247,247,248,248,249,249,249,249,249,250,250,251,251,251,252,252,253,253,253,253,253,254,254,254,254,254,255,255,255,256,256,257,257,257,257,257,258,258,259,259,259,260,260,260,260,260,261,261,262,262,262,263,263,264,264,264,265,265,265,265,265,266,266,266,266,266,267,267,267,268,268,268,269,269,269,269,270,270,271,271,271,272,272,272,272,272,273,273,273,274,274,274,275,275,276,276,276,276,277,277,277,278,278,278,279,279,280,280,280,280,281,281,282,282,282,283,283,283,284,284,284,285,285,286,286,287,287,287,288,288,288,289,289,289,290,290,290,290,290,290,291,291,292,292,292,292,293,293,293,294,294,295,295,295,295,295],"depth":[3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1],"label":["==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","names","names","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[.data.frame","[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","attr","[.factor","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1],"linenum":[null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,10,null,null,null,11,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,11,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,11,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,13],"memalloc":[62.3793487548828,62.3793487548828,62.3793487548828,83.43212890625,83.43212890625,110.59300994873,110.59300994873,110.59300994873,128.500335693359,128.500335693359,128.500335693359,146.275482177734,146.275482177734,146.275482177734,58.3169631958008,58.3169631958008,58.3169631958008,89.411750793457,89.411750793457,108.96460723877,108.96460723877,108.96460723877,108.96460723877,108.96460723877,138.549034118652,138.549034118652,146.286766052246,146.286766052246,146.286766052246,70.8456573486328,70.8456573486328,70.8456573486328,70.8456573486328,70.8456573486328,91.3791885375977,91.3791885375977,91.3791885375977,91.3791885375977,91.3791885375977,120.97095489502,120.97095489502,140.720108032227,140.720108032227,53.4588928222656,53.4588928222656,73.9910354614258,73.9910354614258,73.9910354614258,104.096115112305,104.096115112305,124.101844787598,124.101844787598,146.274383544922,146.274383544922,146.274383544922,57.0113906860352,57.0113906860352,57.0113906860352,57.0113906860352,86.7282104492188,86.7282104492188,107.259620666504,107.259620666504,138.091468811035,138.091468811035,146.289375305176,146.289375305176,146.289375305176,71.7045745849609,71.7045745849609,92.0384368896484,92.0384368896484,122.675880432129,122.675880432129,142.619735717773,142.619735717773,55.3039398193359,55.3039398193359,75.182373046875,75.182373046875,75.182373046875,105.100448608398,105.100448608398,105.100448608398,124.256187438965,124.256187438965,124.256187438965,146.30379486084,146.30379486084,146.30379486084,146.30379486084,146.30379486084,146.30379486084,54.2550659179688,54.2550659179688,54.2550659179688,84.1783294677734,84.1783294677734,102.810943603516,102.810943603516,132.136177062988,132.136177062988,146.307678222656,146.307678222656,146.307678222656,64.7553787231445,64.7553787231445,64.7553787231445,85.3610076904297,85.3610076904297,85.3610076904297,85.3610076904297,85.3610076904297,114.295570373535,114.295570373535,134.046684265137,134.046684265137,134.046684265137,47.373779296875,47.373779296875,47.373779296875,47.373779296875,47.373779296875,67.8495559692383,67.8495559692383,67.8495559692383,67.8495559692383,67.8495559692383,99.7925186157227,99.7925186157227,99.7925186157227,121.051322937012,121.051322937012,121.051322937012,146.307540893555,146.307540893555,146.307540893555,54.5932769775391,54.5932769775391,54.5932769775391,84.5079574584961,84.5079574584961,84.5079574584961,103.728378295898,103.728378295898,103.728378295898,103.728378295898,103.728378295898,132.594863891602,132.594863891602,146.306762695312,146.306762695312,146.306762695312,65.1547775268555,65.1547775268555,65.1547775268555,65.1547775268555,85.5578002929688,85.5578002929688,115.399078369141,115.399078369141,134.616256713867,134.616256713867,134.616256713867,46.6593170166016,46.6593170166016,66.6078414916992,66.6078414916992,96.1875,96.1875,115.479789733887,143.819953918457,143.819953918457,143.819953918457,143.819953918457,45.6757278442383,45.6757278442383,71.8485107421875,71.8485107421875,90.6103363037109,90.6103363037109,118.040924072266,118.040924072266,136.0166015625,136.0166015625,47.0545806884766,47.0545806884766,65.099853515625,65.099853515625,93.3102798461914,93.3102798461914,93.3102798461914,112.069854736328,112.069854736328,139.227333068848,139.227333068848,139.227333068848,139.227333068848,139.227333068848,146.31103515625,146.31103515625,146.31103515625,68.7732772827148,68.7732772827148,68.7732772827148,68.7732772827148,68.7732772827148,87.8019943237305,87.8019943237305,115.092849731445,115.092849731445,132.871086120605,132.871086120605,44.5668182373047,44.5668182373047,44.5668182373047,63.5834503173828,63.5834503173828,92.3166427612305,92.3166427612305,92.3166427612305,92.3166427612305,92.3166427612305,110.621719360352,110.621719360352,110.621719360352,110.621719360352,110.621719360352,138.957809448242,138.957809448242,138.957809448242,138.957809448242,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,42.7306060791016,42.7306060791016,42.7306060791016,49.095458984375,49.095458984375,69.8272399902344,69.8272399902344,101.509689331055,101.509689331055,122.238807678223,122.238807678223,146.318794250488,146.318794250488,146.318794250488,57.889289855957,57.889289855957,57.889289855957,89.3114624023438,109.776229858398,109.776229858398,139.096939086914,139.096939086914,43.7828674316406,43.7828674316406,74.3519134521484,74.3519134521484,74.3519134521484,95.3458633422852,95.3458633422852,125.453659057617,125.453659057617,145.19401550293,145.19401550293,145.19401550293,145.19401550293,145.19401550293,60.4501342773438,60.4501342773438,60.4501342773438,80.8500061035156,80.8500061035156,111.091186523438,111.091186523438,111.091186523438,111.091186523438,111.091186523438,131.755035400391,131.755035400391,46.6063003540039,46.6063003540039,66.1588668823242,66.1588668823242,97.5031509399414,97.5031509399414,97.5031509399414,97.5031509399414,97.5031509399414,118.435508728027,118.435508728027,146.314331054688,146.314331054688,146.314331054688,146.314331054688,146.314331054688,146.314331054688,52.1871337890625,52.1871337890625,77.8977279663086,77.8977279663086,77.8977279663086,97.9024200439453,97.9024200439453,97.9024200439453,126.247009277344,126.247009277344,126.247009277344,144.744171142578,144.744171142578,57.4969329833984,57.4969329833984,57.4969329833984,57.4969329833984,57.4969329833984,76.5912933349609,76.5912933349609,76.5912933349609,105.316162109375,105.316162109375,125.848823547363,125.848823547363,146.307899475098,146.307899475098,146.307899475098,62.0934448242188,62.0934448242188,62.0934448242188,62.0934448242188,62.0934448242188,62.0934448242188,93.3821563720703,93.3821563720703,93.3821563720703,93.3821563720703,93.3821563720703,113.45930480957,113.45930480957,141.931015014648,141.931015014648,141.931015014648,46.2862319946289,46.2862319946289,46.2862319946289,46.2862319946289,77.1879272460938,77.1879272460938,97.9219360351562,97.9219360351562,127.116325378418,127.116325378418,127.116325378418,146.27027130127,146.27027130127,146.27027130127,146.27027130127,146.27027130127,146.27027130127,61.6337127685547,61.6337127685547,81.123649597168,81.123649597168,81.123649597168,81.123649597168,81.123649597168,81.123649597168,111.491218566895,111.491218566895,129.14143371582,129.14143371582,129.14143371582,129.14143371582,43.8616714477539,43.8616714477539,63.0835571289062,63.0835571289062,63.0835571289062,63.0835571289062,91.2981033325195,91.2981033325195,110.454177856445,110.454177856445,110.454177856445,141.163047790527,141.163047790527,141.163047790527,141.163047790527,141.163047790527,45.2413024902344,45.2413024902344,45.2413024902344,75.2301864624023,75.2301864624023,95.6251831054688,95.6251831054688,95.6251831054688,95.6251831054688,95.6251831054688,95.6251831054688,125.800651550293,125.800651550293,125.800651550293,125.800651550293,145.357086181641,145.357086181641,60.2619476318359,60.2619476318359,80.2151107788086,80.2151107788086,111.301170349121,111.301170349121,111.301170349121,111.301170349121,132.42594909668,132.42594909668,47.6751556396484,47.6751556396484,47.6751556396484,66.5700531005859,66.5700531005859,66.5700531005859,96.2195587158203,96.2195587158203,96.2195587158203,96.2195587158203,96.2195587158203,96.2195587158203,116.03345489502,116.03345489502,145.360694885254,145.360694885254,145.360694885254,145.360694885254,145.360694885254,50.2945861816406,50.2945861816406,80.4678649902344,80.4678649902344,80.4678649902344,100.931747436523,100.931747436523,100.931747436523,131.893486022949,131.893486022949,146.259788513184,146.259788513184,146.259788513184,67.7456588745117,67.7456588745117,67.7456588745117,67.7456588745117,67.7456588745117,67.7456588745117,88.1502532958984,88.1502532958984,88.1502532958984,117.670013427734,117.670013427734,136.95344543457,136.95344543457,136.95344543457,51.7422332763672,51.7422332763672,71.2317886352539,71.2317886352539,101.153526306152,101.153526306152,121.290985107422,121.290985107422,146.284523010254,146.284523010254,146.284523010254,57.4485702514648,57.4485702514648,87.944709777832,87.944709777832,87.944709777832,108.406677246094,108.406677246094,108.406677246094,136.74536895752,136.74536895752,136.74536895752,136.74536895752,136.74536895752,146.256927490234,146.256927490234,146.256927490234,72.6626434326172,72.6626434326172,93.3224792480469,93.3224792480469,124.742408752441,124.742408752441,145.733558654785,145.733558654785,61.4541931152344,61.4541931152344,61.4541931152344,61.4541931152344,61.4541931152344,81.2619476318359,81.2619476318359,111.891319274902,111.891319274902,111.891319274902,111.891319274902,111.891319274902,132.683822631836,132.683822631836,132.683822631836,132.683822631836,132.683822631836,48.8593292236328,48.8593292236328,69.0599517822266,69.0599517822266,99.6914215087891,99.6914215087891,120.352203369141,120.352203369141,146.258186340332,146.258186340332,146.258186340332,50.7336273193359,50.7336273193359,50.7336273193359,77.1649780273438,77.1649780273438,77.1649780273438,95.9860000610352,95.9860000610352,123.136367797852,123.136367797852,123.136367797852,141.958213806152,141.958213806152,54.6696853637695,54.6696853637695,74.8065490722656,74.8065490722656,100.517875671387,100.517875671387,119.798332214355,119.798332214355,146.292724609375,146.292724609375,146.292724609375,51.7189636230469,51.7189636230469,80.7737731933594,80.7737731933594,80.7737731933594,80.7737731933594,80.7737731933594,101.629745483398,101.629745483398,132.26057434082,132.26057434082,132.26057434082,132.26057434082,132.26057434082,132.26057434082,146.296279907227,146.296279907227,146.296279907227,146.296279907227,146.296279907227,146.296279907227,67.8539810180664,67.8539810180664,67.8539810180664,86.9389190673828,86.9389190673828,115.535575866699,115.535575866699,115.535575866699,115.535575866699,115.535575866699,135.341590881348,135.341590881348,49.4911575317383,49.4911575317383,49.4911575317383,69.7558822631836,69.7558822631836,100.38525390625,100.38525390625,121.503807067871,121.503807067871,146.295806884766,146.295806884766,146.295806884766,57.8838195800781,57.8838195800781,89.3649597167969,89.3649597167969,89.3649597167969,89.3649597167969,89.3649597167969,110.024345397949,110.024345397949,110.024345397949,141.836990356445,141.836990356445,141.836990356445,141.836990356445,141.836990356445,46.2134475708008,46.2134475708008,46.2134475708008,77.6911010742188,77.6911010742188,77.6911010742188,98.3507614135742,98.3507614135742,98.3507614135742,98.3507614135742,127.999816894531,127.999816894531,146.296096801758,146.296096801758,146.296096801758,61.2314453125,61.2314453125,80.2470245361328,80.2470245361328,108.966835021973,108.966835021973,128.572898864746,128.572898864746,146.27685546875,146.27685546875,146.27685546875,60.7742385864258,60.7742385864258,60.7742385864258,60.7742385864258,60.7742385864258,88.9704971313477,88.9704971313477,107.525917053223,107.525917053223,134.870651245117,134.870651245117,146.279968261719,146.279968261719,146.279968261719,68.1828460693359,68.1828460693359,88.9040756225586,88.9040756225586,119.590148925781,119.590148925781,119.590148925781,139.59105682373,139.59105682373,54.3507232666016,54.3507232666016,54.3507232666016,54.3507232666016,54.3507232666016,74.8100357055664,74.8100357055664,74.8100357055664,74.8100357055664,102.875198364258,102.875198364258,122.74560546875,122.74560546875,146.287010192871,146.287010192871,146.287010192871,53.9562301635742,53.9562301635742,83.2014083862305,83.2014083862305,103.068534851074,103.068534851074,134.082359313965,146.278289794922,146.278289794922,146.278289794922,69.3672943115234,69.3672943115234,89.7599792480469,89.7599792480469,119.79061126709,119.79061126709,119.79061126709,119.79061126709,119.79061126709,140.510986328125,140.510986328125,56.187385559082,56.187385559082,56.187385559082,76.5140762329102,76.5140762329102,107.792205810547,107.792205810547,107.792205810547,107.792205810547,107.792205810547,128.64347076416,128.64347076416,128.64347076416,128.64347076416,128.64347076416,44.844367980957,44.844367980957,44.844367980957,65.1698837280273,65.1698837280273,95.4653167724609,95.4653167724609,95.4653167724609,95.4653167724609,95.4653167724609,116.512870788574,116.512870788574,146.279968261719,146.279968261719,146.279968261719,52.7779846191406,52.7779846191406,52.7779846191406,52.7779846191406,52.7779846191406,83.9852142333984,83.9852142333984,104.374534606934,104.374534606934,104.374534606934,135.253257751465,135.253257751465,146.267921447754,146.267921447754,146.267921447754,68.251838684082,68.251838684082,68.251838684082,68.251838684082,68.251838684082,88.7067108154297,88.7067108154297,88.7067108154297,88.7067108154297,88.7067108154297,119.913497924805,119.913497924805,119.913497924805,139.91024017334,139.91024017334,139.91024017334,55.2054061889648,55.2054061889648,55.2054061889648,55.2054061889648,75.8579559326172,75.8579559326172,107.19660949707,107.19660949707,107.19660949707,127.979652404785,127.979652404785,127.979652404785,127.979652404785,127.979652404785,44.2575073242188,44.2575073242188,44.2575073242188,64.6471939086914,64.6471939086914,64.6471939086914,96.5094909667969,96.5094909667969,118.079261779785,118.079261779785,118.079261779785,118.079261779785,146.270751953125,146.270751953125,146.270751953125,55.2066955566406,55.2066955566406,55.2066955566406,85.9541244506836,85.9541244506836,106.933204650879,106.933204650879,106.933204650879,106.933204650879,138.401985168457,138.401985168457,107.26025390625,107.26025390625,107.26025390625,69.3023300170898,69.3023300170898,69.3023300170898,86.7417297363281,86.7417297363281,86.7417297363281,113.621315002441,113.621315002441,131.912269592285,131.912269592285,44.5668411254883,44.5668411254883,44.5668411254883,63.4481582641602,63.4481582641602,63.4481582641602,94.1300506591797,94.1300506591797,94.1300506591797,115.043579101562,115.043579101562,115.043579101562,115.043579101562,115.043579101562,115.043579101562,145.004440307617,145.004440307617,48.4354248046875,48.4354248046875,48.4354248046875,48.4354248046875,79.510871887207,79.510871887207,79.510871887207,99.8996887207031,99.8996887207031,112.580871582031,112.580871582031,112.580871582031,112.580871582031,112.580871582031],"meminc":[0,0,0,21.0527801513672,0,27.1608810424805,0,0,17.9073257446289,0,0,17.775146484375,0,0,-87.9585189819336,0,0,31.0947875976562,0,19.5528564453125,0,0,0,0,29.5844268798828,0,7.73773193359375,0,0,-75.4411087036133,0,0,0,0,20.5335311889648,0,0,0,0,29.5917663574219,0,19.749153137207,0,-87.2612152099609,0,20.5321426391602,0,0,30.1050796508789,0,20.005729675293,0,22.1725387573242,0,0,-89.2629928588867,0,0,0,29.7168197631836,0,20.5314102172852,0,30.8318481445312,0,8.19790649414062,0,0,-74.5848007202148,0,20.3338623046875,0,30.6374435424805,0,19.9438552856445,0,-87.3157958984375,0,19.8784332275391,0,0,29.9180755615234,0,0,19.1557388305664,0,0,22.047607421875,0,0,0,0,0,-92.0487289428711,0,0,29.9232635498047,0,18.6326141357422,0,29.3252334594727,0,14.171501159668,0,0,-81.5522994995117,0,0,20.6056289672852,0,0,0,0,28.9345626831055,0,19.7511138916016,0,0,-86.6729049682617,0,0,0,0,20.4757766723633,0,0,0,0,31.9429626464844,0,0,21.2588043212891,0,0,25.256217956543,0,0,-91.7142639160156,0,0,29.914680480957,0,0,19.2204208374023,0,0,0,0,28.8664855957031,0,13.7118988037109,0,0,-81.151985168457,0,0,0,20.4030227661133,0,29.8412780761719,0,19.2171783447266,0,0,-87.9569396972656,0,19.9485244750977,0,29.5796585083008,0,19.2922897338867,28.3401641845703,0,0,0,-98.1442260742188,0,26.1727828979492,0,18.7618255615234,0,27.4305877685547,0,17.9756774902344,0,-88.9620208740234,0,18.0452728271484,0,28.2104263305664,0,0,18.7595748901367,0,27.1574783325195,0,0,0,0,7.08370208740234,0,0,-77.5377578735352,0,0,0,0,19.0287170410156,0,27.2908554077148,0,17.7782363891602,0,-88.3042678833008,0,0,19.0166320800781,0,28.7331924438477,0,0,0,0,18.3050765991211,0,0,0,0,28.3360900878906,0,0,0,7.34420776367188,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,6.36485290527344,0,20.7317810058594,0,31.6824493408203,0,20.729118347168,0,24.0799865722656,0,0,-88.4295043945312,0,0,31.4221725463867,20.4647674560547,0,29.3207092285156,0,-95.3140716552734,0,30.5690460205078,0,0,20.9939498901367,0,30.107795715332,0,19.7403564453125,0,0,0,0,-84.7438812255859,0,0,20.3998718261719,0,30.2411804199219,0,0,0,0,20.6638488769531,0,-85.1487350463867,0,19.5525665283203,0,31.3442840576172,0,0,0,0,20.9323577880859,0,27.8788223266602,0,0,0,0,0,-94.127197265625,0,25.7105941772461,0,0,20.0046920776367,0,0,28.3445892333984,0,0,18.4971618652344,0,-87.2472381591797,0,0,0,0,19.0943603515625,0,0,28.7248687744141,0,20.5326614379883,0,20.4590759277344,0,0,-84.2144546508789,0,0,0,0,0,31.2887115478516,0,0,0,0,20.0771484375,0,28.4717102050781,0,0,-95.6447830200195,0,0,0,30.9016952514648,0,20.7340087890625,0,29.1943893432617,0,0,19.1539459228516,0,0,0,0,0,-84.6365585327148,0,19.4899368286133,0,0,0,0,0,30.3675689697266,0,17.6502151489258,0,0,0,-85.2797622680664,0,19.2218856811523,0,0,0,28.2145462036133,0,19.1560745239258,0,0,30.708869934082,0,0,0,0,-95.921745300293,0,0,29.988883972168,0,20.3949966430664,0,0,0,0,0,30.1754684448242,0,0,0,19.5564346313477,0,-85.0951385498047,0,19.9531631469727,0,31.0860595703125,0,0,0,21.1247787475586,0,-84.7507934570312,0,0,18.8948974609375,0,0,29.6495056152344,0,0,0,0,0,19.8138961791992,0,29.3272399902344,0,0,0,0,-95.0661087036133,0,30.1732788085938,0,0,20.4638824462891,0,0,30.9617385864258,0,14.3663024902344,0,0,-78.5141296386719,0,0,0,0,0,20.4045944213867,0,0,29.5197601318359,0,19.2834320068359,0,0,-85.2112121582031,0,19.4895553588867,0,29.9217376708984,0,20.1374588012695,0,24.993537902832,0,0,-88.8359527587891,0,30.4961395263672,0,0,20.4619674682617,0,0,28.3386917114258,0,0,0,0,9.51155853271484,0,0,-73.5942840576172,0,20.6598358154297,0,31.4199295043945,0,20.9911499023438,0,-84.2793655395508,0,0,0,0,19.8077545166016,0,30.6293716430664,0,0,0,0,20.7925033569336,0,0,0,0,-83.8244934082031,0,20.2006225585938,0,30.6314697265625,0,20.6607818603516,0,25.9059829711914,0,0,-95.5245590209961,0,0,26.4313507080078,0,0,18.8210220336914,0,27.1503677368164,0,0,18.8218460083008,0,-87.2885284423828,0,20.1368637084961,0,25.7113265991211,0,19.2804565429688,0,26.4943923950195,0,0,-94.5737609863281,0,29.0548095703125,0,0,0,0,20.8559722900391,0,30.6308288574219,0,0,0,0,0,14.0357055664062,0,0,0,0,0,-78.4422988891602,0,0,19.0849380493164,0,28.5966567993164,0,0,0,0,19.8060150146484,0,-85.8504333496094,0,0,20.2647247314453,0,30.6293716430664,0,21.1185531616211,0,24.7919998168945,0,0,-88.4119873046875,0,31.4811401367188,0,0,0,0,20.6593856811523,0,0,31.8126449584961,0,0,0,0,-95.6235427856445,0,0,31.477653503418,0,0,20.6596603393555,0,0,0,29.649055480957,0,18.2962799072266,0,0,-85.0646514892578,0,19.0155792236328,0,28.7198104858398,0,19.6060638427734,0,17.7039566040039,0,0,-85.5026168823242,0,0,0,0,28.1962585449219,0,18.555419921875,0,27.3447341918945,0,11.4093170166016,0,0,-78.0971221923828,0,20.7212295532227,0,30.6860733032227,0,0,20.0009078979492,0,-85.2403335571289,0,0,0,0,20.4593124389648,0,0,0,28.0651626586914,0,19.8704071044922,0,23.5414047241211,0,0,-92.3307800292969,0,29.2451782226562,0,19.8671264648438,0,31.0138244628906,12.195930480957,0,0,-76.9109954833984,0,20.3926849365234,0,30.030632019043,0,0,0,0,20.7203750610352,0,-84.323600769043,0,0,20.3266906738281,0,31.2781295776367,0,0,0,0,20.8512649536133,0,0,0,0,-83.7991027832031,0,0,20.3255157470703,0,30.2954330444336,0,0,0,0,21.0475540161133,0,29.7670974731445,0,0,-93.5019836425781,0,0,0,0,31.2072296142578,0,20.3893203735352,0,0,30.8787231445312,0,11.0146636962891,0,0,-78.0160827636719,0,0,0,0,20.4548721313477,0,0,0,0,31.206787109375,0,0,19.9967422485352,0,0,-84.704833984375,0,0,0,20.6525497436523,0,31.3386535644531,0,0,20.7830429077148,0,0,0,0,-83.7221450805664,0,0,20.3896865844727,0,0,31.8622970581055,0,21.5697708129883,0,0,0,28.1914901733398,0,0,-91.0640563964844,0,0,30.747428894043,0,20.9790802001953,0,0,0,31.4687805175781,0,-31.141731262207,0,0,-37.9579238891602,0,0,17.4393997192383,0,0,26.8795852661133,0,18.2909545898438,0,-87.3454284667969,0,0,18.8813171386719,0,0,30.6818923950195,0,0,20.9135284423828,0,0,0,0,0,29.9608612060547,0,-96.5690155029297,0,0,0,31.0754470825195,0,0,20.3888168334961,0,12.6811828613281,0,0,0,0],"filename":[null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpJsPcvj/file542050c3bc07.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    786.070    803.4105    822.9924    814.5920
#>    compute_pi0(m * 10)   7885.147   7921.2305   8013.2255   7961.0385
#>   compute_pi0(m * 100)  78958.746  79391.2695  80289.1095  79780.3280
#>         compute_pi1(m)    174.160    195.4865    254.3952    267.5465
#>    compute_pi1(m * 10)   1267.628   1371.0205   1810.1705   1411.7080
#>   compute_pi1(m * 100)  13196.518  13542.0230  26571.3560  21265.5555
#>  compute_pi1(m * 1000) 257618.947 274135.8815 348375.4894 365517.3030
#>           uq        max neval
#>     827.9815    907.899    20
#>    8099.0690   8267.253    20
#>   80793.8515  85339.736    20
#>     292.4230    336.071    20
#>    1445.3570   9600.584    20
#>   25729.0905 143200.340    20
#>  384793.8720 505382.895    20
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
#>   memory_copy1(n) 5459.69888 4532.83617 641.913142 3964.95144 3466.34971
#>   memory_copy2(n)   93.19004   78.78158  12.166384   70.23018   59.93455
#>  pre_allocate1(n)   19.99412   16.95721   3.788431   14.87177   13.02697
#>  pre_allocate2(n)  198.68098  166.62532  24.478067  149.40904  140.14789
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  98.494443    10
#>   3.011749    10
#>   2.023070    10
#>   4.352693    10
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
#>    expr      min       lq     mean   median       uq    max neval
#>  f1(df) 252.2792 255.8254 86.87936 256.3595 64.81865 40.833     5
#>  f2(df)   1.0000   1.0000  1.00000   1.0000  1.00000  1.000     5
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
