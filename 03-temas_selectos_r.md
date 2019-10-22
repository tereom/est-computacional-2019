
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
#>    id          a         b        c        d
#> 1   1 -1.0536014 1.8576832 3.390390 3.268844
#> 2   2  1.0056908 3.4663513 4.457507 4.959985
#> 3   3 -0.9269792 3.5647487 2.151752 4.121730
#> 4   4  1.9653268 1.2576962 3.485904 2.781570
#> 5   5 -0.4091388 3.0758781 3.979114 5.341204
#> 6   6 -2.1042105 0.9932249 3.385317 4.138425
#> 7   7  0.5777292 1.2404933 3.558574 3.922159
#> 8   8 -1.1741783 0.9909010 2.602621 5.173825
#> 9   9  0.7069060 1.9262512 2.344521 5.217066
#> 10 10  0.2250129 2.0348611 4.289533 5.577579
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.1187442
mean(df$b)
#> [1] 2.040809
mean(df$c)
#> [1] 3.364523
mean(df$d)
#> [1] 4.450239
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.1187442  2.0408089  3.3645232  4.4502388
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
#> [1] -0.1187442  2.0408089  3.3645232  4.4502388
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
#> [1]  5.5000000 -0.1187442  2.0408089  3.3645232  4.4502388
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
#> [1]  5.50000000 -0.09206294  1.89196718  3.43814693  4.54920513
col_describe(df, mean)
#> [1]  5.5000000 -0.1187442  2.0408089  3.3645232  4.4502388
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
#>  5.5000000 -0.1187442  2.0408089  3.3645232  4.4502388
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
#>   4.251   0.185   4.433
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.023   0.000   0.634
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
#>  13.048   1.098  10.222
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
#>   0.117   0.000   0.117
plyr_st
#>    user  system elapsed 
#>   4.271   0.007   4.277
est_l_st
#>    user  system elapsed 
#>  69.196   1.636  70.804
est_r_st
#>    user  system elapsed 
#>   0.429   0.012   0.440
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

<!--html_preserve--><div id="htmlwidget-5c04dc601abc3b30029f" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-5c04dc601abc3b30029f">{"x":{"message":{"prof":{"time":[1,1,1,2,2,2,3,3,4,4,4,5,5,5,6,6,6,6,6,6,7,7,7,7,7,8,8,9,9,10,10,10,11,11,11,11,11,12,12,13,13,14,14,15,15,16,16,16,16,17,17,18,18,19,19,19,20,20,21,21,22,22,22,22,22,23,23,24,24,24,25,25,26,26,27,27,28,28,28,29,29,29,30,30,31,31,31,32,32,32,32,32,32,33,33,33,33,34,34,35,35,35,36,36,37,37,37,38,38,39,39,40,40,40,40,41,41,41,41,41,42,42,42,43,43,44,44,45,45,46,46,46,46,47,47,48,48,49,49,49,49,50,50,51,51,51,52,52,53,53,53,53,54,54,55,55,55,55,55,56,56,56,57,57,58,58,58,59,59,59,59,59,59,60,60,61,61,61,62,62,62,62,62,63,63,64,64,64,64,64,65,65,66,66,66,67,67,68,68,68,68,68,69,69,70,70,70,71,71,71,72,72,72,72,72,73,73,74,74,74,74,75,76,76,76,77,77,77,77,77,78,78,78,78,78,79,79,80,80,80,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,97,97,97,98,98,99,99,100,100,100,101,101,102,102,103,103,103,103,104,104,105,105,105,105,105,105,106,106,106,107,107,107,107,108,108,109,109,110,110,111,111,111,112,112,112,113,113,114,114,114,114,114,115,115,115,116,116,116,116,116,117,117,118,118,118,119,119,119,119,119,120,120,120,120,120,120,121,121,122,122,122,123,123,124,124,125,125,125,126,126,127,127,127,128,128,129,129,130,130,130,131,131,132,132,133,133,133,133,133,134,134,134,134,134,135,135,135,136,136,136,137,137,138,138,139,139,140,140,140,140,140,140,141,141,141,142,142,143,143,144,144,144,144,144,145,145,146,146,147,147,148,148,148,148,149,149,149,149,149,150,150,150,151,151,152,152,152,153,153,153,153,154,154,154,155,155,155,155,155,155,156,156,157,157,157,158,158,159,159,160,160,160,161,161,162,162,163,163,163,164,164,164,165,165,165,166,166,166,167,167,167,168,168,168,168,168,169,169,169,170,170,171,171,171,172,172,172,172,172,173,173,173,173,174,174,174,175,175,176,176,176,176,176,177,177,177,177,177,178,178,179,179,180,180,180,180,180,180,181,181,181,181,182,182,182,183,183,183,183,183,183,184,184,184,185,185,185,185,185,186,186,186,186,186,187,187,187,188,188,189,189,189,189,189,190,190,190,190,190,190,191,191,192,192,193,193,194,194,195,195,195,195,195,196,196,196,197,197,197,197,197,198,198,199,199,200,200,201,201,202,202,203,203,203,204,204,204,204,204,205,205,206,206,207,207,208,208,208,209,209,209,209,209,209,210,210,211,211,211,212,212,213,213,213,214,214,214,215,215,216,216,217,217,217,218,218,218,219,219,219,219,219,220,220,220,220,220,220,221,221,222,222,223,223,223,224,224,224,225,225,225,225,225,226,226,226,226,226,227,227,227,228,228,229,229,229,230,230,231,231,231,231,232,232,233,233,234,234,235,235,236,236,236,237,237,237,237,237,238,238,239,239,240,240,241,241,242,242,242,243,243,244,244,244,245,245,246,246,246,246,247,247,248,248,248,248,248,249,249,249,250,250,251,251,252,252,252,252,252,252,253,253,253,254,254,255,255,256,256,256,257,257,258,258,258,259,259,259,259,259,260,260,261,261,262,262,263,263,263,264,264,265,265,265,265,266,266,267,267,268,268,269,269,269,270,270,270,270,270,271,271,271,272,272,273,273,273,274,274,274,274,275,275,276,276,277,277,277,278,278,278,279,279,280,280,280,281,281,282,282,283,283,283,283,284,284,284,284,285,285,286,286,287,287,287,287,287,288,288,288,289,289,290,290,290,291,291,291,292,292,293,293,293,294,294,295,295,296,296,297,297,297,297],"depth":[3,2,1,3,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1],"label":["==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","anyDuplicated.default","anyDuplicated","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","["],"filenum":[null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1],"linenum":[null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,11,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,10,10,null,null,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,11,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,14,14],"memalloc":[60.8094787597656,60.8094787597656,60.8094787597656,79.6983947753906,79.6983947753906,79.6983947753906,106.531005859375,106.531005859375,123.783554077148,123.783554077148,123.783554077148,146.281684875488,146.281684875488,146.281684875488,53.7947845458984,53.7947845458984,53.7947845458984,53.7947845458984,53.7947845458984,53.7947845458984,84.7620849609375,84.7620849609375,84.7620849609375,84.7620849609375,84.7620849609375,104.51097869873,104.51097869873,134.486122131348,134.486122131348,146.29296875,146.29296875,146.29296875,68.0954437255859,68.0954437255859,68.0954437255859,68.0954437255859,68.0954437255859,88.759880065918,88.759880065918,118.222244262695,118.222244262695,137.840957641602,137.840957641602,52.0884094238281,52.0884094238281,72.3574295043945,72.3574295043945,72.3574295043945,72.3574295043945,103.249702453613,103.249702453613,122.927520751953,122.927520751953,146.280586242676,146.280586242676,146.280586242676,56.9517974853516,56.9517974853516,88.636100769043,88.636100769043,109.8251953125,109.8251953125,109.8251953125,109.8251953125,109.8251953125,141.965934753418,141.965934753418,45.8620681762695,45.8620681762695,45.8620681762695,77.1534805297852,77.1534805297852,97.9489059448242,97.9489059448242,130.162757873535,130.162757873535,146.300430297852,146.300430297852,146.300430297852,65.7441329956055,65.7441329956055,65.7441329956055,86.3388748168945,86.3388748168945,116.127182006836,116.127182006836,116.127182006836,136.005096435547,136.005096435547,136.005096435547,136.005096435547,136.005096435547,136.005096435547,50.0641479492188,50.0641479492188,50.0641479492188,50.0641479492188,70.5370788574219,70.5370788574219,101.440841674805,101.440841674805,101.440841674805,121.316886901855,121.316886901855,146.31388092041,146.31388092041,146.31388092041,55.2469940185547,55.2469940185547,86.3508682250977,86.3508682250977,106.233993530273,106.233993530273,106.233993530273,106.233993530273,136.151519775391,136.151519775391,136.151519775391,136.151519775391,136.151519775391,146.316314697266,146.316314697266,146.316314697266,67.0027923583984,67.0027923583984,87.9223480224609,87.9223480224609,117.842826843262,117.842826843262,137.063690185547,137.063690185547,137.063690185547,137.063690185547,50.8584976196289,50.8584976196289,71.6519241333008,71.6519241333008,102.553802490234,102.553802490234,102.553802490234,102.553802490234,120.331077575684,120.331077575684,146.312965393066,146.312965393066,146.312965393066,50.3352127075195,50.3352127075195,81.0369567871094,81.0369567871094,81.0369567871094,81.0369567871094,100.778244018555,100.778244018555,130.358741760254,130.358741760254,130.358741760254,130.358741760254,130.358741760254,146.303123474121,146.303123474121,146.303123474121,64.0546340942383,64.0546340942383,84.3261260986328,84.3261260986328,84.3261260986328,112.732009887695,112.732009887695,112.732009887695,112.732009887695,112.732009887695,112.732009887695,131.953247070312,131.953247070312,44.5674819946289,44.5674819946289,44.5674819946289,63.7842483520508,63.7842483520508,63.7842483520508,63.7842483520508,63.7842483520508,92.1926116943359,92.1926116943359,110.242294311523,110.242294311523,110.242294311523,110.242294311523,110.242294311523,138.776306152344,138.776306152344,146.321563720703,146.321563720703,146.321563720703,65.5651779174805,65.5651779174805,84.5237731933594,84.5237731933594,84.5237731933594,84.5237731933594,84.5237731933594,115.223930358887,115.223930358887,134.246803283691,134.246803283691,134.246803283691,118.107711791992,118.107711791992,118.107711791992,61.4317398071289,61.4317398071289,61.4317398071289,61.4317398071289,61.4317398071289,91.680305480957,91.680305480957,110.571388244629,110.571388244629,110.571388244629,110.571388244629,138.911979675293,146.324241638184,146.324241638184,146.324241638184,65.2946090698242,65.2946090698242,65.2946090698242,65.2946090698242,65.2946090698242,85.1707077026367,85.1707077026367,85.1707077026367,85.1707077026367,85.1707077026367,115.351509094238,115.351509094238,135.551055908203,135.551055908203,135.551055908203,135.551055908203,135.551055908203,135.551055908203,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,146.308219909668,42.7368087768555,42.7368087768555,42.7368087768555,43.7204666137695,43.7204666137695,73.2441177368164,73.2441177368164,73.2441177368164,93.4508819580078,93.4508819580078,123.426635742188,123.426635742188,142.520942687988,142.520942687988,142.520942687988,52.2505264282227,52.2505264282227,71.6718292236328,71.6718292236328,101.909507751465,101.909507751465,101.909507751465,101.909507751465,120.539733886719,120.539733886719,146.321990966797,146.321990966797,146.321990966797,146.321990966797,146.321990966797,146.321990966797,48.9068908691406,48.9068908691406,48.9068908691406,78.7537078857422,78.7537078857422,78.7537078857422,78.7537078857422,98.2401428222656,98.2401428222656,126.181282043457,126.181282043457,144.675285339355,144.675285339355,54.1542892456055,54.1542892456055,54.1542892456055,73.049934387207,73.049934387207,73.049934387207,103.619659423828,103.619659423828,124.214805603027,124.214805603027,124.214805603027,124.214805603027,124.214805603027,146.324226379395,146.324226379395,146.324226379395,54.4855880737305,54.4855880737305,54.4855880737305,54.4855880737305,54.4855880737305,83.2794723510742,83.2794723510742,103.546195983887,103.546195983887,103.546195983887,133.462829589844,133.462829589844,133.462829589844,133.462829589844,133.462829589844,146.320533752441,146.320533752441,146.320533752441,146.320533752441,146.320533752441,146.320533752441,64.1306610107422,64.1306610107422,83.7434234619141,83.7434234619141,83.7434234619141,112.543502807617,112.543502807617,131.171607971191,131.171607971191,146.325035095215,146.325035095215,146.325035095215,58.3567962646484,58.3567962646484,87.8099212646484,87.8099212646484,87.8099212646484,106.174537658691,106.174537658691,136.15047454834,136.15047454834,146.314102172852,146.314102172852,146.314102172852,64.5252914428711,64.5252914428711,83.8749694824219,83.8749694824219,112.810081481934,112.810081481934,112.810081481934,112.810081481934,112.810081481934,131.244567871094,131.244567871094,131.244567871094,131.244567871094,131.244567871094,146.269195556641,146.269195556641,146.269195556641,57.8404541015625,57.8404541015625,57.8404541015625,86.0554046630859,86.0554046630859,105.867004394531,105.867004394531,136.371315002441,136.371315002441,146.276473999023,146.276473999023,146.276473999023,146.276473999023,146.276473999023,146.276473999023,65.119026184082,65.119026184082,65.119026184082,84.6710052490234,84.6710052490234,112.874267578125,112.874267578125,133.082328796387,133.082328796387,133.082328796387,133.082328796387,133.082328796387,43.4744415283203,43.4744415283203,61.9095230102539,61.9095230102539,92.2236251831055,92.2236251831055,112.101699829102,112.101699829102,112.101699829102,112.101699829102,142.742820739746,142.742820739746,142.742820739746,142.742820739746,142.742820739746,94.7748260498047,94.7748260498047,94.7748260498047,70.5119094848633,70.5119094848633,87.7614364624023,87.7614364624023,87.7614364624023,115.509979248047,115.509979248047,115.509979248047,115.509979248047,133.420349121094,133.420349121094,133.420349121094,111.004287719727,111.004287719727,111.004287719727,111.004287719727,111.004287719727,111.004287719727,61.0558547973633,61.0558547973633,87.500732421875,87.500732421875,87.500732421875,107.042510986328,107.042510986328,136.040641784668,136.040641784668,146.276077270508,146.276077270508,146.276077270508,66.3136138916016,66.3136138916016,85.4688949584961,85.4688949584961,115.383201599121,115.383201599121,115.383201599121,132.639297485352,132.639297485352,132.639297485352,94.8396682739258,94.8396682739258,94.8396682739258,63.1578598022461,63.1578598022461,63.1578598022461,94.6407623291016,94.6407623291016,94.6407623291016,115.435989379883,115.435989379883,115.435989379883,115.435989379883,115.435989379883,146.265991210938,146.265991210938,146.265991210938,53.1219863891602,53.1219863891602,83.4335021972656,83.4335021972656,83.4335021972656,104.226455688477,104.226455688477,104.226455688477,104.226455688477,104.226455688477,134.202629089355,134.202629089355,134.202629089355,134.202629089355,146.274070739746,146.274070739746,146.274070739746,71.5005645751953,71.5005645751953,91.6484222412109,91.6484222412109,91.6484222412109,91.6484222412109,91.6484222412109,123.265380859375,123.265380859375,123.265380859375,123.265380859375,123.265380859375,144.518730163574,144.518730163574,60.4068298339844,60.4068298339844,80.8014678955078,80.8014678955078,80.8014678955078,80.8014678955078,80.8014678955078,80.8014678955078,112.219017028809,112.219017028809,112.219017028809,112.219017028809,132.027397155762,132.027397155762,132.027397155762,48.3374252319336,48.3374252319336,48.3374252319336,48.3374252319336,48.3374252319336,48.3374252319336,69.0613098144531,69.0613098144531,69.0613098144531,100.809379577637,100.809379577637,100.809379577637,100.809379577637,100.809379577637,121.272560119629,121.272560119629,121.272560119629,121.272560119629,121.272560119629,146.26505279541,146.26505279541,146.26505279541,58.7046585083008,58.7046585083008,89.9267578125,89.9267578125,89.9267578125,89.9267578125,89.9267578125,110.651260375977,110.651260375977,110.651260375977,110.651260375977,110.651260375977,110.651260375977,141.937255859375,141.937255859375,48.3405914306641,48.3405914306641,77.9190979003906,77.9190979003906,99.1074676513672,99.1074676513672,130.851524353027,130.851524353027,130.851524353027,130.851524353027,130.851524353027,146.264389038086,146.264389038086,146.264389038086,66.8088836669922,66.8088836669922,66.8088836669922,66.8088836669922,66.8088836669922,87.9901809692383,87.9901809692383,117.633186340332,117.633186340332,138.292015075684,138.292015075684,53.6914138793945,53.6914138793945,74.2220458984375,74.2220458984375,106.229736328125,106.229736328125,106.229736328125,126.95433807373,126.95433807373,126.95433807373,126.95433807373,126.95433807373,43.0673904418945,43.0673904418945,63.2678604125977,63.2678604125977,94.9456481933594,94.9456481933594,116.130340576172,116.130340576172,116.130340576172,146.30248260498,146.30248260498,146.30248260498,146.30248260498,146.30248260498,146.30248260498,52.8400344848633,52.8400344848633,84.3211441040039,84.3211441040039,84.3211441040039,105.30997467041,105.30997467041,137.119483947754,137.119483947754,137.119483947754,50.8705902099609,50.8705902099609,50.8705902099609,73.3039398193359,73.3039398193359,94.6196746826172,94.6196746826172,126.692230224609,126.692230224609,126.692230224609,146.30200958252,146.30200958252,146.30200958252,63.6620712280273,63.6620712280273,63.6620712280273,63.6620712280273,63.6620712280273,81.436393737793,81.436393737793,81.436393737793,81.436393737793,81.436393737793,81.436393737793,112.457176208496,112.457176208496,132.922378540039,132.922378540039,49.3669204711914,49.3669204711914,49.3669204711914,69.9570693969727,69.9570693969727,69.9570693969727,101.637168884277,101.637168884277,101.637168884277,101.637168884277,101.637168884277,122.038703918457,122.038703918457,122.038703918457,122.038703918457,122.038703918457,146.302299499512,146.302299499512,146.302299499512,58.1559295654297,58.1559295654297,90.0893478393555,90.0893478393555,90.0893478393555,111.268424987793,111.268424987793,140.840423583984,140.840423583984,140.840423583984,140.840423583984,46.1580276489258,46.1580276489258,77.3699188232422,77.3699188232422,98.2878112792969,98.2878112792969,130.54801940918,130.54801940918,146.286170959473,146.286170959473,146.286170959473,67.9268493652344,67.9268493652344,67.9268493652344,67.9268493652344,67.9268493652344,88.7136383056641,88.7136383056641,120.514144897461,120.514144897461,141.761840820312,141.761840820312,58.4879684448242,58.4879684448242,79.6037902832031,79.6037902832031,79.6037902832031,110.292045593262,110.292045593262,131.538970947266,131.538970947266,131.538970947266,48.3229064941406,48.3229064941406,69.4376602172852,69.4376602172852,69.4376602172852,69.4376602172852,101.304542541504,101.304542541504,121.893905639648,121.893905639648,121.893905639648,121.893905639648,121.893905639648,146.284492492676,146.284492492676,146.284492492676,58.0295562744141,58.0295562744141,88.9136810302734,88.9136810302734,109.567474365234,109.567474365234,109.567474365234,109.567474365234,109.567474365234,109.567474365234,141.566535949707,141.566535949707,141.566535949707,47.3410339355469,47.3410339355469,79.1434707641602,79.1434707641602,100.257751464844,100.257751464844,100.257751464844,131.862754821777,131.862754821777,146.287628173828,146.287628173828,146.287628173828,70.2914047241211,70.2914047241211,70.2914047241211,70.2914047241211,70.2914047241211,91.0124206542969,91.0124206542969,123.010673522949,123.010673522949,144.057197570801,144.057197570801,60.3237075805664,60.3237075805664,60.3237075805664,81.23779296875,81.23779296875,112.444717407227,112.444717407227,112.444717407227,112.444717407227,133.882614135742,133.882614135742,50.2278366088867,50.2278366088867,70.6834869384766,70.6834869384766,101.038307189941,101.038307189941,101.038307189941,121.82096862793,121.82096862793,121.82096862793,121.82096862793,121.82096862793,146.275863647461,146.275863647461,146.275863647461,57.4407958984375,57.4407958984375,88.320671081543,88.320671081543,88.320671081543,109.038482666016,109.038482666016,109.038482666016,109.038482666016,141.032241821289,141.032241821289,47.0168380737305,47.0168380737305,78.814453125,78.814453125,78.814453125,99.203239440918,99.203239440918,99.203239440918,130.739547729492,130.739547729492,146.276954650879,146.276954650879,146.276954650879,68.8491821289062,68.8491821289062,89.6315002441406,89.6315002441406,121.494110107422,121.494110107422,121.494110107422,121.494110107422,143.063018798828,143.063018798828,143.063018798828,143.063018798828,59.9333572387695,59.9333572387695,79.7327575683594,79.7327575683594,110.546295166016,110.546295166016,110.546295166016,110.546295166016,110.546295166016,131.918502807617,131.918502807617,131.918502807617,46.7363967895508,46.7363967895508,67.4533004760742,67.4533004760742,67.4533004760742,98.070068359375,98.070068359375,98.070068359375,118.590354919434,118.590354919434,146.322036743164,146.322036743164,146.322036743164,53.1618728637695,53.1618728637695,85.2205276489258,85.2205276489258,106.462211608887,106.462211608887,113.065223693848,113.065223693848,113.065223693848,113.065223693848],"meminc":[0,0,0,18.888916015625,0,0,26.8326110839844,0,17.2525482177734,0,0,22.4981307983398,0,0,-92.4869003295898,0,0,0,0,0,30.9673004150391,0,0,0,0,19.748893737793,0,29.9751434326172,0,11.8068466186523,0,0,-78.1975250244141,0,0,0,0,20.664436340332,0,29.4623641967773,0,19.6187133789062,0,-85.7525482177734,0,20.2690200805664,0,0,0,30.8922729492188,0,19.6778182983398,0,23.3530654907227,0,0,-89.3287887573242,0,31.6843032836914,0,21.189094543457,0,0,0,0,32.140739440918,0,-96.1038665771484,0,0,31.2914123535156,0,20.7954254150391,0,32.2138519287109,0,16.1376724243164,0,0,-80.5562973022461,0,0,20.5947418212891,0,29.7883071899414,0,0,19.8779144287109,0,0,0,0,0,-85.9409484863281,0,0,0,20.4729309082031,0,30.9037628173828,0,0,19.8760452270508,0,24.9969940185547,0,0,-91.0668869018555,0,31.103874206543,0,19.8831253051758,0,0,0,29.9175262451172,0,0,0,0,10.164794921875,0,0,-79.3135223388672,0,20.9195556640625,0,29.9204788208008,0,19.2208633422852,0,0,0,-86.205192565918,0,20.7934265136719,0,30.9018783569336,0,0,0,17.7772750854492,0,25.9818878173828,0,0,-95.9777526855469,0,30.7017440795898,0,0,0,19.7412872314453,0,29.5804977416992,0,0,0,0,15.9443817138672,0,0,-82.2484893798828,0,20.2714920043945,0,0,28.4058837890625,0,0,0,0,0,19.2212371826172,0,-87.3857650756836,0,0,19.2167663574219,0,0,0,0,28.4083633422852,0,18.0496826171875,0,0,0,0,28.5340118408203,0,7.54525756835938,0,0,-80.7563858032227,0,18.9585952758789,0,0,0,0,30.7001571655273,0,19.0228729248047,0,0,-16.1390914916992,0,0,-56.6759719848633,0,0,0,0,30.2485656738281,0,18.8910827636719,0,0,0,28.3405914306641,7.41226196289062,0,0,-81.0296325683594,0,0,0,0,19.8760986328125,0,0,0,0,30.1808013916016,0,20.1995468139648,0,0,0,0,0,10.7571640014648,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,0.983657836914062,0,29.5236511230469,0,0,20.2067642211914,0,29.9757537841797,0,19.0943069458008,0,0,-90.2704162597656,0,19.4213027954102,0,30.237678527832,0,0,0,18.6302261352539,0,25.7822570800781,0,0,0,0,0,-97.4151000976562,0,0,29.8468170166016,0,0,0,19.4864349365234,0,27.9411392211914,0,18.4940032958984,0,-90.52099609375,0,0,18.8956451416016,0,0,30.5697250366211,0,20.5951461791992,0,0,0,0,22.1094207763672,0,0,-91.8386383056641,0,0,0,0,28.7938842773438,0,20.2667236328125,0,0,29.916633605957,0,0,0,0,12.8577041625977,0,0,0,0,0,-82.1898727416992,0,19.6127624511719,0,0,28.8000793457031,0,18.6281051635742,0,15.1534271240234,0,0,-87.9682388305664,0,29.453125,0,0,18.364616394043,0,29.9759368896484,0,10.1636276245117,0,0,-81.7888107299805,0,19.3496780395508,0,28.9351119995117,0,0,0,0,18.4344863891602,0,0,0,0,15.0246276855469,0,0,-88.4287414550781,0,0,28.2149505615234,0,19.8115997314453,0,30.5043106079102,0,9.90515899658203,0,0,0,0,0,-81.1574478149414,0,0,19.5519790649414,0,28.2032623291016,0,20.2080612182617,0,0,0,0,-89.6078872680664,0,18.4350814819336,0,30.3141021728516,0,19.8780746459961,0,0,0,30.6411209106445,0,0,0,0,-47.9679946899414,0,0,-24.2629165649414,0,17.2495269775391,0,0,27.7485427856445,0,0,0,17.9103698730469,0,0,-22.4160614013672,0,0,0,0,0,-49.9484329223633,0,26.4448776245117,0,0,19.5417785644531,0,28.9981307983398,0,10.2354354858398,0,0,-79.9624633789062,0,19.1552810668945,0,29.914306640625,0,0,17.2560958862305,0,0,-37.7996292114258,0,0,-31.6818084716797,0,0,31.4829025268555,0,0,20.7952270507812,0,0,0,0,30.8300018310547,0,0,-93.1440048217773,0,30.3115158081055,0,0,20.7929534912109,0,0,0,0,29.9761734008789,0,0,0,12.0714416503906,0,0,-74.7735061645508,0,20.1478576660156,0,0,0,0,31.6169586181641,0,0,0,0,21.2533493041992,0,-84.1119003295898,0,20.3946380615234,0,0,0,0,0,31.4175491333008,0,0,0,19.8083801269531,0,0,-83.6899719238281,0,0,0,0,0,20.7238845825195,0,0,31.7480697631836,0,0,0,0,20.4631805419922,0,0,0,0,24.9924926757812,0,0,-87.5603942871094,0,31.2220993041992,0,0,0,0,20.7245025634766,0,0,0,0,0,31.2859954833984,0,-93.5966644287109,0,29.5785064697266,0,21.1883697509766,0,31.7440567016602,0,0,0,0,15.4128646850586,0,0,-79.4555053710938,0,0,0,0,21.1812973022461,0,29.6430053710938,0,20.6588287353516,0,-84.6006011962891,0,20.530632019043,0,32.0076904296875,0,0,20.7246017456055,0,0,0,0,-83.8869476318359,0,20.2004699707031,0,31.6777877807617,0,21.1846923828125,0,0,30.1721420288086,0,0,0,0,0,-93.4624481201172,0,31.4811096191406,0,0,20.9888305664062,0,31.8095092773438,0,0,-86.248893737793,0,0,22.433349609375,0,21.3157348632812,0,32.0725555419922,0,0,19.6097793579102,0,0,-82.6399383544922,0,0,0,0,17.7743225097656,0,0,0,0,0,31.0207824707031,0,20.465202331543,0,-83.5554580688477,0,0,20.5901489257812,0,0,31.6800994873047,0,0,0,0,20.4015350341797,0,0,0,0,24.2635955810547,0,0,-88.146369934082,0,31.9334182739258,0,0,21.1790771484375,0,29.5719985961914,0,0,0,-94.6823959350586,0,31.2118911743164,0,20.9178924560547,0,32.2602081298828,0,15.738151550293,0,0,-78.3593215942383,0,0,0,0,20.7867889404297,0,31.8005065917969,0,21.2476959228516,0,-83.2738723754883,0,21.1158218383789,0,0,30.6882553100586,0,21.2469253540039,0,0,-83.216064453125,0,21.1147537231445,0,0,0,31.8668823242188,0,20.5893630981445,0,0,0,0,24.3905868530273,0,0,-88.2549362182617,0,30.8841247558594,0,20.6537933349609,0,0,0,0,0,31.9990615844727,0,0,-94.2255020141602,0,31.8024368286133,0,21.1142807006836,0,0,31.6050033569336,0,14.4248733520508,0,0,-75.996223449707,0,0,0,0,20.7210159301758,0,31.9982528686523,0,21.0465240478516,0,-83.7334899902344,0,0,20.9140853881836,0,31.2069244384766,0,0,0,21.4378967285156,0,-83.6547775268555,0,20.4556503295898,0,30.3548202514648,0,0,20.7826614379883,0,0,0,0,24.4548950195312,0,0,-88.8350677490234,0,30.8798751831055,0,0,20.7178115844727,0,0,0,31.9937591552734,0,-94.0154037475586,0,31.7976150512695,0,0,20.388786315918,0,0,31.5363082885742,0,15.5374069213867,0,0,-77.4277725219727,0,20.7823181152344,0,31.8626098632812,0,0,0,21.5689086914062,0,0,0,-83.1296615600586,0,19.7994003295898,0,30.8135375976562,0,0,0,0,21.3722076416016,0,0,-85.1821060180664,0,20.7169036865234,0,0,30.6167678833008,0,0,20.5202865600586,0,27.7316818237305,0,0,-93.1601638793945,0,32.0586547851562,0,21.2416839599609,0,6.60301208496094,0,0,0],"filename":[null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpN3TOy8/file37325979fc63.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    791.213    802.7495    845.1974    823.8725
#>    compute_pi0(m * 10)   7880.272   7962.7775   8342.9957   8015.2610
#>   compute_pi0(m * 100)  79006.116  79400.2065  80142.1699  79700.3040
#>         compute_pi1(m)    168.109    260.3360    299.6110    294.9840
#>    compute_pi1(m * 10)   1307.643   1418.5990   7383.9201   1558.5640
#>   compute_pi1(m * 100)  14172.545  18878.0300  23857.2942  25153.0205
#>  compute_pi1(m * 1000) 251458.839 328623.3750 416274.8533 429489.5200
#>           uq        max neval
#>     856.4480   1174.264    20
#>    8085.5025  14351.301    20
#>   79945.0040  85739.333    20
#>     358.3695    415.106    20
#>    1622.2255 118274.150    20
#>   28448.5920  32094.314    20
#>  492688.4690 678412.533    20
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
#>   memory_copy1(n) 5964.19204 5511.25987 603.232409 3993.52554 3694.76031
#>   memory_copy2(n)  106.45663   98.24637  11.459008   72.07790   61.53506
#>  pre_allocate1(n)   20.04944   18.92462   3.545476   13.80714   12.34178
#>  pre_allocate2(n)  204.72537  190.26674  21.537643  145.59072  130.45570
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  94.923209    10
#>   2.850250    10
#>   2.075589    10
#>   3.776474    10
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
#>    expr      min       lq     mean   median       uq      max neval
#>  f1(df) 374.7527 382.1697 108.1191 360.3693 81.56429 39.57149     5
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
