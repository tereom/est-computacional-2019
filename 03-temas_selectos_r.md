
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
#>   [1]  NA   6   9  12  15  18  21  24  27  30  33  36  39  42  45  48  51  54
#>  [19]  57  60  63  66  69  72  75  78  81  84  87  90  93  96  99 102 105 108
#>  [37] 111 114 117 120 123 126 129 132 135 138 141 144 147 150 153 156 159 162
#>  [55] 165 168 171 174 177 180 183 186 189 192 195 198 201 204 207 210 213 216
#>  [73] 219 222 225 228 231 234 237 240 243 246 249 252 255 258 261 264 267 270
#>  [91] 273 276 279 282 285 288 291 294 297  NA
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
#>    id           a         b        c        d
#> 1   1  0.16337888 1.1074125 3.071574 4.562870
#> 2   2  0.02077245 1.6092425 2.895221 3.115304
#> 3   3 -0.18104921 0.9543220 3.524771 4.784387
#> 4   4 -1.10870535 2.2912814 3.483704 4.112083
#> 5   5  0.53428134 1.5774733 3.005246 3.539704
#> 6   6  1.43980848 0.9694430 3.920223 4.295568
#> 7   7 -0.23661427 0.5367437 2.532426 3.905398
#> 8   8 -0.37430159 1.5721674 2.813730 3.700091
#> 9   9 -0.83832038 3.6099930 2.739458 2.907819
#> 10 10 -0.53124073 0.3186107 1.758181 4.776744
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.111199
mean(df$b)
#> [1] 1.454669
mean(df$c)
#> [1] 2.974453
mean(df$d)
#> [1] 3.969997
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.111199  1.454669  2.974453  3.969997
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
#> [1] -0.111199  1.454669  2.974453  3.969997
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
#> [1]  5.500000 -0.111199  1.454669  2.974453  3.969997
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
#> [1]  5.5000000 -0.2088317  1.3397900  2.9502337  4.0087408
col_describe(df, mean)
#> [1]  5.500000 -0.111199  1.454669  2.974453  3.969997
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
#>        id         a         b         c         d 
#>  5.500000 -0.111199  1.454669  2.974453  3.969997
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
#>   4.167   0.196   4.363
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.004   1.101
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
#>  13.671   0.909  10.385
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
#>   0.107   0.008   0.115
plyr_st
#>    user  system elapsed 
#>   4.537   0.004   4.540
est_l_st
#>    user  system elapsed 
#>  64.959   2.352  67.317
est_r_st
#>    user  system elapsed 
#>   0.401   0.004   0.405
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

<!--html_preserve--><div id="htmlwidget-11783cfaeb86625c1338" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-11783cfaeb86625c1338">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,3,3,3,3,4,4,4,5,5,5,6,6,7,7,7,8,8,8,9,9,9,9,9,10,10,10,11,11,12,12,13,13,13,14,14,14,15,15,15,16,16,16,17,17,18,18,19,19,20,20,20,21,21,21,21,21,22,22,23,23,24,24,24,25,25,25,26,26,26,26,26,27,27,28,28,28,29,29,30,30,30,31,31,32,32,33,33,34,34,35,35,35,35,35,35,36,36,36,37,37,38,38,38,38,38,39,39,40,40,41,41,42,42,43,43,43,44,44,44,44,45,45,45,46,46,46,47,47,47,48,48,48,49,49,49,49,50,50,50,51,51,51,51,52,52,53,53,53,54,54,55,55,55,55,55,56,56,56,57,57,57,57,57,58,58,59,59,59,60,60,61,61,62,62,62,63,63,64,64,65,65,66,66,66,67,67,68,68,69,69,69,69,69,69,70,70,71,71,71,72,72,73,73,73,74,74,75,75,75,76,76,76,77,77,78,78,78,78,78,79,79,80,80,81,81,82,82,82,83,83,83,83,83,84,84,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,102,102,103,103,103,103,103,104,104,104,104,105,105,106,106,106,106,107,107,107,108,108,109,109,109,109,109,110,110,110,110,110,111,111,112,112,113,113,113,113,113,114,114,114,115,115,115,115,116,116,116,116,117,117,117,118,118,119,119,119,119,119,120,120,120,120,120,121,121,122,122,123,123,124,124,124,124,124,125,125,125,126,126,126,127,127,127,127,127,128,128,129,129,130,130,131,131,131,131,131,132,132,132,133,133,133,133,133,134,134,134,134,134,135,135,135,136,136,137,137,137,137,137,137,138,138,139,139,139,140,140,140,141,141,141,141,142,142,143,143,144,144,145,145,145,146,146,146,147,147,147,148,148,149,149,150,150,150,151,151,151,151,151,152,152,152,153,153,153,154,154,154,154,154,155,155,155,156,156,157,157,157,158,158,158,159,159,159,160,160,160,161,161,162,162,162,163,163,164,164,165,165,166,166,167,167,167,168,168,168,168,168,168,169,169,169,169,170,170,171,171,172,172,173,173,174,174,174,174,174,174,175,175,176,176,177,177,177,177,178,178,178,179,179,179,180,180,180,181,181,182,182,182,183,183,184,184,184,185,185,185,186,186,187,187,187,187,187,188,188,189,189,189,190,190,190,190,190,191,191,192,192,193,193,193,193,194,194,194,195,195,195,196,196,196,197,197,197,197,197,198,198,199,199,199,200,200,201,201,202,202,202,202,202,202,203,203,204,204,204,205,205,206,206,206,207,207,207,208,208,209,209,209,209,209,210,210,210,210,211,211,212,212,212,213,213,213,214,214,214,214,214,215,215,216,216,216,216,216,217,217,218,218,218,219,219,220,220,221,221,222,222,222,222,222,223,223,224,224,225,225,225,226,226,226,226,226,227,227,227,228,228,228,229,229,230,230,230,230,230,231,231,232,232,232,233,233,234,234,235,235,235,236,236,237,237,238,238,239,239,239,239,239,240,240,241,241,241,242,242,242,242,243,243,243,244,244,245,245,246,246,246,246,247,247,248,248,248,249,249,250,250,251,251,251,251,252,252,253,253,254,254,255,255,255,256,256,256,256,256,256,257,257,258,258,258,258,258,258,259,259,260,260,260,260,260,260,261,261,262,262,263,263,264,264,265,265,266,266,266,266,266,267,267,267,268,268,269,269,269,270,270,270,270,271,271,272,272,273,273,274,274,274,275,275,275,275,275,275,276,276,276,277,277,277,278,278,278,279,279,280,280,281,281,281,282,282,282,283,283,283,283,283,283,284,284,285,285,285,285,285,285,286,286,286,287,287,288,288,288,288,289,289,290,290,290,290,290,291,291,291,291,292,292,293,293,294,294,295,295,295,295,295,296,296,297,297,298,298,299,299,300,300,300,300,300,301,301,301,302,302,303,303,303,303,304,304,304,305,305,306,306,306,307,307,308,308,309,309,310,310,310,310,310],"depth":[2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","length","length","[.data.frame","[","==","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,null,null,null,1,1,null,null,1,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1],"linenum":[9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,11,9,9,9,9,null,null,null,9,9,null,null,11,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,11,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,13],"memalloc":[65.9611740112305,65.9611740112305,86.6865615844727,86.6865615844727,112.142097473145,112.142097473145,112.142097473145,112.142097473145,112.142097473145,112.142097473145,128.803146362305,128.803146362305,128.803146362305,146.31600189209,146.31600189209,146.31600189209,54.2881317138672,54.2881317138672,85.1245040893555,85.1245040893555,85.1245040893555,104.020927429199,104.020927429199,104.020927429199,132.68310546875,132.68310546875,132.68310546875,132.68310546875,132.68310546875,146.327285766602,146.327285766602,146.327285766602,61.3713226318359,61.3713226318359,82.1687240600586,82.1687240600586,111.04118347168,111.04118347168,111.04118347168,129.936470031738,129.936470031738,129.936470031738,146.335243225098,146.335243225098,146.335243225098,58.2880554199219,58.2880554199219,58.2880554199219,87.6101684570312,87.6101684570312,104.399154663086,104.399154663086,131.42374420166,131.42374420166,146.314903259277,146.314903259277,146.314903259277,56.920654296875,56.920654296875,56.920654296875,56.920654296875,56.920654296875,76.4037704467773,76.4037704467773,105.921730041504,105.921730041504,125.273376464844,125.273376464844,125.273376464844,146.329895019531,146.329895019531,146.329895019531,52.4587631225586,52.4587631225586,52.4587631225586,52.4587631225586,52.4587631225586,81.3868637084961,81.3868637084961,101.000144958496,101.000144958496,101.000144958496,130.393760681152,130.393760681152,146.334747314453,146.334747314453,146.334747314453,57.9703750610352,57.9703750610352,77.9763336181641,77.9763336181641,105.730865478516,105.730865478516,123.967704772949,123.967704772949,146.278709411621,146.278709411621,146.278709411621,146.278709411621,146.278709411621,146.278709411621,49.5080184936523,49.5080184936523,49.5080184936523,78.8368911743164,78.8368911743164,97.7342529296875,97.7342529296875,97.7342529296875,97.7342529296875,97.7342529296875,125.225273132324,125.225273132324,143.133666992188,143.133666992188,49.6432723999023,49.6432723999023,69.2566833496094,69.2566833496094,98.0038833618164,98.0038833618164,98.0038833618164,116.368721008301,116.368721008301,116.368721008301,116.368721008301,143.662078857422,143.662078857422,143.662078857422,146.285049438477,146.285049438477,146.285049438477,69.3324279785156,69.3324279785156,69.3324279785156,89.7928695678711,89.7928695678711,89.7928695678711,118.074256896973,118.074256896973,118.074256896973,118.074256896973,137.031967163086,137.031967163086,137.031967163086,45.3805160522461,45.3805160522461,45.3805160522461,45.3805160522461,65.1271820068359,65.1271820068359,95.8320159912109,95.8320159912109,95.8320159912109,114.65763092041,114.65763092041,143.394813537598,143.394813537598,143.394813537598,143.394813537598,143.394813537598,140.784324645996,140.784324645996,140.784324645996,72.8722229003906,72.8722229003906,72.8722229003906,72.8722229003906,72.8722229003906,93.7961883544922,93.7961883544922,120.818984985352,120.818984985352,120.818984985352,138.985931396484,138.985931396484,46.109016418457,46.109016418457,66.2553329467773,66.2553329467773,66.2553329467773,95.9665069580078,95.9665069580078,114.012847900391,114.012847900391,141.761474609375,141.761474609375,146.290100097656,146.290100097656,146.290100097656,69.9214782714844,69.9214782714844,89.6655807495117,89.6655807495117,118.212890625,118.212890625,118.212890625,118.212890625,118.212890625,118.212890625,137.041000366211,137.041000366211,45.4558792114258,45.4558792114258,45.4558792114258,65.0085067749023,65.0085067749023,95.6487121582031,95.6487121582031,95.6487121582031,116.30850982666,116.30850982666,146.286315917969,146.286315917969,146.286315917969,44.9981460571289,44.9981460571289,44.9981460571289,73.3388748168945,73.3388748168945,92.4370574951172,92.4370574951172,92.4370574951172,92.4370574951172,92.4370574951172,120.381477355957,120.381477355957,138.093811035156,138.093811035156,46.0512466430664,46.0512466430664,65.6571960449219,65.6571960449219,65.6571960449219,95.3095855712891,95.3095855712891,95.3095855712891,95.3095855712891,95.3095855712891,115.124214172363,115.124214172363,145.162666320801,145.162666320801,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,146.277542114258,42.7709732055664,42.7709732055664,42.7709732055664,48.6765365600586,48.6765365600586,67.3750228881836,67.3750228881836,96.2389373779297,96.2389373779297,96.2389373779297,96.2389373779297,96.2389373779297,114.801307678223,114.801307678223,114.801307678223,114.801307678223,142.291923522949,142.291923522949,44.7784576416016,44.7784576416016,44.7784576416016,44.7784576416016,71.1802062988281,71.1802062988281,71.1802062988281,90.204719543457,90.204719543457,117.165023803711,117.165023803711,117.165023803711,117.165023803711,117.165023803711,135.662055969238,135.662055969238,135.662055969238,135.662055969238,135.662055969238,45.0051803588867,45.0051803588867,64.4864349365234,64.4864349365234,94.0745468139648,94.0745468139648,94.0745468139648,94.0745468139648,94.0745468139648,114.147071838379,114.147071838379,114.147071838379,143.333137512207,143.333137512207,143.333137512207,143.333137512207,43.7594146728516,43.7594146728516,43.7594146728516,43.7594146728516,72.296630859375,72.296630859375,72.296630859375,91.2559814453125,91.2559814453125,119.790473937988,119.790473937988,119.790473937988,119.790473937988,119.790473937988,138.946800231934,138.946800231934,138.946800231934,138.946800231934,138.946800231934,49.2719192504883,49.2719192504883,69.1501922607422,69.1501922607422,99.5757904052734,99.5757904052734,118.935249328613,118.935249328613,118.935249328613,118.935249328613,118.935249328613,146.288131713867,146.288131713867,146.288131713867,47.7656478881836,47.7656478881836,47.7656478881836,76.1032028198242,76.1032028198242,76.1032028198242,76.1032028198242,76.1032028198242,95.6489791870117,95.6489791870117,124.254081726074,124.254081726074,143.801048278809,143.801048278809,53.7340087890625,53.7340087890625,53.7340087890625,53.7340087890625,53.7340087890625,72.8920822143555,72.8920822143555,72.8920822143555,102.403007507324,102.403007507324,102.403007507324,102.403007507324,102.403007507324,121.625213623047,121.625213623047,121.625213623047,121.625213623047,121.625213623047,146.283126831055,146.283126831055,146.283126831055,50.979118347168,50.979118347168,80.1708221435547,80.1708221435547,80.1708221435547,80.1708221435547,80.1708221435547,80.1708221435547,99.7253570556641,99.7253570556641,129.311477661133,129.311477661133,129.311477661133,146.304878234863,146.304878234863,146.304878234863,56.4941177368164,56.4941177368164,56.4941177368164,56.4941177368164,75.719367980957,75.719367980957,104.523818969727,104.523818969727,123.61604309082,123.61604309082,146.30980682373,146.30980682373,146.30980682373,53.6086273193359,53.6086273193359,53.6086273193359,83.5267028808594,83.5267028808594,83.5267028808594,103.597183227539,103.597183227539,131.937690734863,131.937690734863,146.304313659668,146.304313659668,146.304313659668,61.4176559448242,61.4176559448242,61.4176559448242,61.4176559448242,61.4176559448242,81.4289016723633,81.4289016723633,81.4289016723633,111.346588134766,111.346588134766,111.346588134766,130.246070861816,130.246070861816,130.246070861816,130.246070861816,130.246070861816,146.319076538086,146.319076538086,146.319076538086,60.567741394043,60.567741394043,90.416862487793,90.416862487793,90.416862487793,110.885215759277,110.885215759277,110.885215759277,140.211799621582,140.211799621582,140.211799621582,146.314193725586,146.314193725586,146.314193725586,71.0666351318359,71.0666351318359,89.962516784668,89.962516784668,89.962516784668,118.753082275391,118.753082275391,138.765586853027,138.765586853027,50.0117492675781,50.0117492675781,70.0862274169922,70.0862274169922,100.723609924316,100.723609924316,100.723609924316,120.536346435547,120.536346435547,120.536346435547,120.536346435547,120.536346435547,120.536346435547,146.318969726562,146.318969726562,146.318969726562,146.318969726562,51.9736404418945,51.9736404418945,82.0814590454102,82.0814590454102,100.904663085938,100.904663085938,130.949363708496,130.949363708496,146.298835754395,146.298835754395,146.298835754395,146.298835754395,146.298835754395,146.298835754395,59.9765625,59.9765625,78.742431640625,78.742431640625,107.60408782959,107.60408782959,107.60408782959,107.60408782959,126.95630645752,126.95630645752,126.95630645752,146.3076171875,146.3076171875,146.3076171875,56.1783676147461,56.1783676147461,56.1783676147461,84.9219665527344,84.9219665527344,104.79914855957,104.79914855957,104.79914855957,133.992935180664,133.992935180664,146.322975158691,146.322975158691,146.322975158691,63.7854766845703,63.7854766845703,63.7854766845703,83.9182815551758,83.9182815551758,112.187644958496,112.187644958496,112.187644958496,112.187644958496,112.187644958496,131.996383666992,131.996383666992,71.2246932983398,71.2246932983398,71.2246932983398,62.5364532470703,62.5364532470703,62.5364532470703,62.5364532470703,62.5364532470703,89.6887969970703,89.6887969970703,108.909759521484,108.909759521484,136.589385986328,136.589385986328,136.589385986328,136.589385986328,146.299201965332,146.299201965332,146.299201965332,65.4318313598633,65.4318313598633,65.4318313598633,84.3215103149414,84.3215103149414,84.3215103149414,113.178955078125,113.178955078125,113.178955078125,113.178955078125,113.178955078125,130.887817382812,130.887817382812,146.302169799805,146.302169799805,146.302169799805,62.3469467163086,62.3469467163086,92.7141952514648,92.7141952514648,112.786094665527,112.786094665527,112.786094665527,112.786094665527,112.786094665527,112.786094665527,141.644226074219,141.644226074219,126.59309387207,126.59309387207,126.59309387207,71.9584808349609,71.9584808349609,92.6811141967773,92.6811141967773,92.6811141967773,124.159889221191,124.159889221191,124.159889221191,143.441062927246,143.441062927246,54.0532531738281,54.0532531738281,54.0532531738281,54.0532531738281,54.0532531738281,74.6494522094727,74.6494522094727,74.6494522094727,74.6494522094727,105.279815673828,105.279815673828,126.135940551758,126.135940551758,126.135940551758,146.332763671875,146.332763671875,146.332763671875,57.6614227294922,57.6614227294922,57.6614227294922,57.6614227294922,57.6614227294922,88.0280609130859,88.0280609130859,108.885467529297,108.885467529297,108.885467529297,108.885467529297,108.885467529297,139.910743713379,139.910743713379,146.33748626709,146.33748626709,146.33748626709,70.8453674316406,70.8453674316406,91.5706253051758,91.5706253051758,123.250297546387,123.250297546387,143.972808837891,143.972808837891,143.972808837891,143.972808837891,143.972808837891,55.1054840087891,55.1054840087891,75.0430908203125,75.0430908203125,105.673011779785,105.673011779785,105.673011779785,126.33226776123,126.33226776123,126.33226776123,126.33226776123,126.33226776123,146.335723876953,146.335723876953,146.335723876953,57.7950057983398,57.7950057983398,57.7950057983398,88.4230575561523,88.4230575561523,108.82022857666,108.82022857666,108.82022857666,108.82022857666,108.82022857666,136.827156066895,136.827156066895,146.338111877441,146.338111877441,146.338111877441,67.0408554077148,67.0408554077148,87.6361465454102,87.6361465454102,118.793472290039,118.793472290039,118.793472290039,139.518569946289,139.518569946289,50.7799530029297,50.7799530029297,71.303466796875,71.303466796875,102.319061279297,102.319061279297,102.319061279297,102.319061279297,102.319061279297,123.433723449707,123.433723449707,146.316955566406,146.316955566406,146.316955566406,53.7339935302734,53.7339935302734,53.7339935302734,53.7339935302734,85.012321472168,85.012321472168,85.012321472168,105.666481018066,105.666481018066,137.075622558594,137.075622558594,146.321632385254,146.321632385254,146.321632385254,146.321632385254,67.4352264404297,67.4352264404297,87.435676574707,87.435676574707,87.435676574707,118.64575958252,118.64575958252,139.302421569824,139.302421569824,50.3899230957031,50.3899230957031,50.3899230957031,50.3899230957031,70.8496170043945,70.8496170043945,101.079109191895,101.079109191895,121.998809814453,121.998809814453,146.326431274414,146.326431274414,146.326431274414,54.1272048950195,54.1272048950195,54.1272048950195,54.1272048950195,54.1272048950195,54.1272048950195,85.3399429321289,85.3399429321289,106.321510314941,106.321510314941,106.321510314941,106.321510314941,106.321510314941,106.321510314941,137.073547363281,137.073547363281,146.318771362305,146.318771362305,146.318771362305,146.318771362305,146.318771362305,146.318771362305,69.275146484375,69.275146484375,90.3887710571289,90.3887710571289,120.616355895996,120.616355895996,141.009063720703,141.009063720703,52.5548248291016,52.5548248291016,72.9480133056641,72.9480133056641,72.9480133056641,72.9480133056641,72.9480133056641,104.357009887695,104.357009887695,104.357009887695,124.355613708496,124.355613708496,146.321014404297,146.321014404297,146.321014404297,56.4239044189453,56.4239044189453,56.4239044189453,56.4239044189453,87.4391098022461,87.4391098022461,108.421684265137,108.421684265137,139.435745239258,139.435745239258,146.319496154785,146.319496154785,146.319496154785,72.0270385742188,72.0270385742188,72.0270385742188,72.0270385742188,72.0270385742188,72.0270385742188,92.7444686889648,92.7444686889648,92.7444686889648,124.213523864746,124.213523864746,124.213523864746,144.668792724609,144.668792724609,144.668792724609,56.2920150756836,56.2920150756836,76.1578674316406,76.1578674316406,107.823486328125,107.823486328125,107.823486328125,128.738327026367,128.738327026367,128.738327026367,146.308982849121,146.308982849121,146.308982849121,146.308982849121,146.308982849121,146.308982849121,61.47314453125,61.47314453125,93.0081405639648,93.0081405639648,93.0081405639648,93.0081405639648,93.0081405639648,93.0081405639648,114.381767272949,114.381767272949,114.381767272949,145.588516235352,145.588516235352,46.9844207763672,46.9844207763672,46.9844207763672,46.9844207763672,77.6668167114258,77.6668167114258,97.9906692504883,97.9906692504883,97.9906692504883,97.9906692504883,97.9906692504883,127.035346984863,127.035346984863,127.035346984863,127.035346984863,146.309951782227,146.309951782227,58.1957702636719,58.1957702636719,78.7815856933594,78.7815856933594,110.512634277344,110.512634277344,110.512634277344,110.512634277344,110.512634277344,131.360504150391,131.360504150391,44.1666488647461,44.1666488647461,64.4902038574219,64.4902038574219,95.6313018798828,95.6313018798828,116.676002502441,116.676002502441,116.676002502441,116.676002502441,116.676002502441,146.309242248535,146.309242248535,146.309242248535,47.2948532104492,47.2948532104492,78.7637252807617,78.7637252807617,78.7637252807617,78.7637252807617,99.0217895507812,99.0217895507812,99.0217895507812,129.375984191895,129.375984191895,146.290664672852,146.290664672852,146.290664672852,60.1452026367188,60.1452026367188,80.468879699707,80.468879699707,111.806091308594,111.806091308594,113.604370117188,113.604370117188,113.604370117188,113.604370117188,113.604370117188],"meminc":[0,0,20.7253875732422,0,25.4555358886719,0,0,0,0,0,16.6610488891602,0,0,17.5128555297852,0,0,-92.0278701782227,0,30.8363723754883,0,0,18.8964233398438,0,0,28.6621780395508,0,0,0,0,13.6441802978516,0,0,-84.9559631347656,0,20.7974014282227,0,28.8724594116211,0,0,18.8952865600586,0,0,16.3987731933594,0,0,-88.0471878051758,0,0,29.3221130371094,0,16.7889862060547,0,27.0245895385742,0,14.8911590576172,0,0,-89.3942489624023,0,0,0,0,19.4831161499023,0,29.5179595947266,0,19.3516464233398,0,0,21.0565185546875,0,0,-93.8711318969727,0,0,0,0,28.9281005859375,0,19.61328125,0,0,29.3936157226562,0,15.9409866333008,0,0,-88.364372253418,0,20.0059585571289,0,27.7545318603516,0,18.2368392944336,0,22.3110046386719,0,0,0,0,0,-96.7706909179688,0,0,29.3288726806641,0,18.8973617553711,0,0,0,0,27.4910202026367,0,17.9083938598633,0,-93.4903945922852,0,19.613410949707,0,28.747200012207,0,0,18.3648376464844,0,0,0,27.2933578491211,0,0,2.62297058105469,0,0,-76.9526214599609,0,0,20.4604415893555,0,0,28.2813873291016,0,0,0,18.9577102661133,0,0,-91.6514511108398,0,0,0,19.7466659545898,0,30.704833984375,0,0,18.8256149291992,0,28.7371826171875,0,0,0,0,-2.61048889160156,0,0,-67.9121017456055,0,0,0,0,20.9239654541016,0,27.0227966308594,0,0,18.1669464111328,0,-92.8769149780273,0,20.1463165283203,0,0,29.7111740112305,0,18.0463409423828,0,27.7486267089844,0,4.52862548828125,0,0,-76.3686218261719,0,19.7441024780273,0,28.5473098754883,0,0,0,0,0,18.8281097412109,0,-91.5851211547852,0,0,19.5526275634766,0,30.6402053833008,0,0,20.659797668457,0,29.9778060913086,0,0,-101.28816986084,0,0,28.3407287597656,0,19.0981826782227,0,0,0,0,27.9444198608398,0,17.7123336791992,0,-92.0425643920898,0,19.6059494018555,0,0,29.6523895263672,0,0,0,0,19.8146286010742,0,30.0384521484375,0,1.11487579345703,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,5.90556335449219,0,18.698486328125,0,28.8639144897461,0,0,0,0,18.562370300293,0,0,0,27.4906158447266,0,-97.5134658813477,0,0,0,26.4017486572266,0,0,19.0245132446289,0,26.9603042602539,0,0,0,0,18.4970321655273,0,0,0,0,-90.6568756103516,0,19.4812545776367,0,29.5881118774414,0,0,0,0,20.0725250244141,0,0,29.1860656738281,0,0,0,-99.5737228393555,0,0,0,28.5372161865234,0,0,18.9593505859375,0,28.5344924926758,0,0,0,0,19.1563262939453,0,0,0,0,-89.6748809814453,0,19.8782730102539,0,30.4255981445312,0,19.3594589233398,0,0,0,0,27.3528823852539,0,0,-98.5224838256836,0,0,28.3375549316406,0,0,0,0,19.5457763671875,0,28.6051025390625,0,19.5469665527344,0,-90.0670394897461,0,0,0,0,19.158073425293,0,0,29.5109252929688,0,0,0,0,19.2222061157227,0,0,0,0,24.6579132080078,0,0,-95.3040084838867,0,29.1917037963867,0,0,0,0,0,19.5545349121094,0,29.5861206054688,0,0,16.9934005737305,0,0,-89.8107604980469,0,0,0,19.2252502441406,0,28.8044509887695,0,19.0922241210938,0,22.6937637329102,0,0,-92.7011795043945,0,0,29.9180755615234,0,0,20.0704803466797,0,28.3405075073242,0,14.3666229248047,0,0,-84.8866577148438,0,0,0,0,20.0112457275391,0,0,29.9176864624023,0,0,18.8994827270508,0,0,0,0,16.0730056762695,0,0,-85.751335144043,0,29.84912109375,0,0,20.4683532714844,0,0,29.3265838623047,0,0,6.10239410400391,0,0,-75.24755859375,0,18.895881652832,0,0,28.7905654907227,0,20.0125045776367,0,-88.7538375854492,0,20.0744781494141,0,30.6373825073242,0,0,19.8127365112305,0,0,0,0,0,25.7826232910156,0,0,0,-94.345329284668,0,30.1078186035156,0,18.8232040405273,0,30.0447006225586,0,15.3494720458984,0,0,0,0,0,-86.3222732543945,0,18.765869140625,0,28.8616561889648,0,0,0,19.3522186279297,0,0,19.3513107299805,0,0,-90.1292495727539,0,0,28.7435989379883,0,19.8771820068359,0,0,29.1937866210938,0,12.3300399780273,0,0,-82.5374984741211,0,0,20.1328048706055,0,28.2693634033203,0,0,0,0,19.8087387084961,0,-60.7716903686523,0,0,-8.68824005126953,0,0,0,0,27.15234375,0,19.2209625244141,0,27.6796264648438,0,0,0,9.70981597900391,0,0,-80.8673706054688,0,0,18.8896789550781,0,0,28.8574447631836,0,0,0,0,17.7088623046875,0,15.4143524169922,0,0,-83.9552230834961,0,30.3672485351562,0,20.0718994140625,0,0,0,0,0,28.8581314086914,0,-15.0511322021484,0,0,-54.6346130371094,0,20.7226333618164,0,0,31.4787750244141,0,0,19.2811737060547,0,-89.387809753418,0,0,0,0,20.5961990356445,0,0,0,30.6303634643555,0,20.8561248779297,0,0,20.1968231201172,0,0,-88.6713409423828,0,0,0,0,30.3666381835938,0,20.8574066162109,0,0,0,0,31.025276184082,0,6.42674255371094,0,0,-75.4921188354492,0,20.7252578735352,0,31.6796722412109,0,20.7225112915039,0,0,0,0,-88.8673248291016,0,19.9376068115234,0,30.6299209594727,0,0,20.6592559814453,0,0,0,0,20.0034561157227,0,0,-88.5407180786133,0,0,30.6280517578125,0,20.3971710205078,0,0,0,0,28.0069274902344,0,9.51095581054688,0,0,-79.2972564697266,0,20.5952911376953,0,31.1573257446289,0,0,20.72509765625,0,-88.7386169433594,0,20.5235137939453,0,31.0155944824219,0,0,0,0,21.1146621704102,0,22.8832321166992,0,0,-92.5829620361328,0,0,0,31.2783279418945,0,0,20.6541595458984,0,31.4091415405273,0,9.24600982666016,0,0,0,-78.8864059448242,0,20.0004501342773,0,0,31.2100830078125,0,20.6566619873047,0,-88.9124984741211,0,0,0,20.4596939086914,0,30.2294921875,0,20.9197006225586,0,24.3276214599609,0,0,-92.1992263793945,0,0,0,0,0,31.2127380371094,0,20.9815673828125,0,0,0,0,0,30.7520370483398,0,9.24522399902344,0,0,0,0,0,-77.0436248779297,0,21.1136245727539,0,30.2275848388672,0,20.392707824707,0,-88.4542388916016,0,20.3931884765625,0,0,0,0,31.4089965820312,0,0,19.9986038208008,0,21.9654006958008,0,0,-89.8971099853516,0,0,0,31.0152053833008,0,20.9825744628906,0,31.0140609741211,0,6.88375091552734,0,0,-74.2924575805664,0,0,0,0,0,20.7174301147461,0,0,31.4690551757812,0,0,20.4552688598633,0,0,-88.3767776489258,0,19.865852355957,0,31.6656188964844,0,0,20.9148406982422,0,0,17.5706558227539,0,0,0,0,0,-84.8358383178711,0,31.5349960327148,0,0,0,0,0,21.3736267089844,0,0,31.2067489624023,0,-98.6040954589844,0,0,0,30.6823959350586,0,20.3238525390625,0,0,0,0,29.044677734375,0,0,0,19.2746047973633,0,-88.1141815185547,0,20.5858154296875,0,31.7310485839844,0,0,0,0,20.8478698730469,0,-87.1938552856445,0,20.3235549926758,0,31.1410980224609,0,21.0447006225586,0,0,0,0,29.6332397460938,0,0,-99.0143890380859,0,31.4688720703125,0,0,0,20.2580642700195,0,0,30.3541946411133,0,16.914680480957,0,0,-86.1454620361328,0,20.3236770629883,0,31.3372116088867,0,1.79827880859375,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpwZuASz/file3c3f576dc825.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    804.051    812.0305    820.9221    819.4810
#>    compute_pi0(m * 10)   8050.455   8081.4255   8466.0091   8107.0430
#>   compute_pi0(m * 100)  80767.118  80868.3855  81353.0550  81140.1020
#>         compute_pi1(m)    161.168    210.1325    282.5663    293.9215
#>    compute_pi1(m * 10)   1373.494   1513.1435   1974.6782   1580.6230
#>   compute_pi1(m * 100)  14172.674  19300.5615  29094.0058  20928.4080
#>  compute_pi1(m * 1000) 200832.799 316590.0155 399412.5637 399889.1745
#>          uq        max neval
#>     831.240    836.469    20
#>    8158.860  14931.727    20
#>   81418.331  83677.615    20
#>     324.160    492.287    20
#>    1614.609   9870.635    20
#>   26960.086 165076.778    20
#>  487565.737 642880.965    20
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
#>   memory_copy1(n) 5285.50227 3965.77155 585.794815 3834.99912 3739.68203
#>   memory_copy2(n)   91.01961   66.67579  11.269777   65.39529   70.62276
#>  pre_allocate1(n)   18.64064   13.65255   3.267216   13.49195   13.06951
#>  pre_allocate2(n)  187.43918  135.14828  20.534693  129.79205  133.07247
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  101.451652    10
#>    2.800258    10
#>    1.741241    10
#>    3.796022    10
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
#>    expr      min       lq     mean  median       uq      max neval
#>  f1(df) 342.3984 341.9281 105.2613 334.087 89.24848 37.56227     5
#>  f2(df)   1.0000   1.0000   1.0000   1.000  1.00000  1.00000     5
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
