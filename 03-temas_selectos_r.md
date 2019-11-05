
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
#> 1   1  0.2951779 2.2999897 1.313790 3.427600
#> 2   2 -1.2146227 0.6258689 2.722499 2.831394
#> 3   3  0.3697387 2.4076245 3.823132 2.572492
#> 4   4  1.7435616 2.1988513 3.216408 3.123617
#> 5   5 -0.3820751 1.5696810 3.064717 4.000643
#> 6   6 -0.3165826 2.5368435 2.561533 3.169956
#> 7   7 -0.4500451 2.4319351 2.352849 4.402324
#> 8   8  0.4172227 1.2293098 2.614205 4.210218
#> 9   9 -1.6980356 2.4025327 1.699090 3.811151
#> 10 10  1.4353036 1.0618785 1.753130 2.959235
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.01996434
mean(df$b)
#> [1] 1.876452
mean(df$c)
#> [1] 2.512135
mean(df$d)
#> [1] 3.450863
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.01996434 1.87645150 2.51213528 3.45086307
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
#> [1] 0.01996434 1.87645150 2.51213528 3.45086307
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
#> [1] 5.50000000 0.01996434 1.87645150 2.51213528 3.45086307
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
#> [1]  5.50000000 -0.01070234  2.24942053  2.58786909  3.29877800
col_describe(df, mean)
#> [1] 5.50000000 0.01996434 1.87645150 2.51213528 3.45086307
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
#> 5.50000000 0.01996434 1.87645150 2.51213528 3.45086307
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
#>   4.271   0.196   4.467
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.020   0.004   0.711
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
#>  14.464   0.999  11.084
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
#>   0.127   0.000   0.126
plyr_st
#>    user  system elapsed 
#>   4.700   0.000   4.701
est_l_st
#>    user  system elapsed 
#>  68.881   1.343  70.227
est_r_st
#>    user  system elapsed 
#>   0.458   0.000   0.458
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

<!--html_preserve--><div id="htmlwidget-d653fe8cdf094bddc762" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-d653fe8cdf094bddc762">{"x":{"message":{"prof":{"time":[1,1,1,1,1,1,2,2,2,3,3,4,4,4,5,5,6,6,6,7,7,8,8,8,9,9,10,10,10,10,11,11,12,12,12,12,12,13,13,14,14,14,14,14,15,15,16,16,16,17,17,18,18,18,18,18,19,19,19,19,20,20,21,21,22,22,22,23,23,23,23,23,24,24,25,25,25,25,26,26,26,27,27,27,28,28,29,29,30,30,31,31,31,32,32,33,33,34,34,35,35,36,36,36,36,36,36,37,37,37,37,37,37,38,38,39,39,40,40,41,41,41,42,42,42,42,42,43,43,44,44,44,45,45,45,46,46,46,47,47,48,48,48,49,49,50,50,51,51,51,52,52,52,53,53,54,54,55,55,56,56,56,57,57,58,58,59,59,59,59,59,60,60,60,60,60,61,61,61,62,62,63,63,63,64,64,65,65,65,65,65,66,66,66,67,67,68,68,69,69,70,70,71,71,71,72,72,72,73,73,73,73,73,74,74,74,74,74,75,75,76,76,76,77,77,77,77,77,78,78,79,79,79,79,80,80,80,80,81,81,81,82,82,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,103,103,103,104,104,105,105,105,105,105,106,106,106,106,106,106,107,107,108,108,108,108,108,109,109,110,110,111,111,111,111,112,112,113,113,114,114,115,115,116,116,116,117,117,118,118,119,119,119,120,120,120,121,121,121,121,121,121,122,122,123,123,123,124,124,125,125,125,126,126,126,127,127,127,127,127,128,128,128,128,128,129,129,129,130,130,131,131,131,131,132,132,133,133,133,134,134,134,135,135,135,136,136,136,136,136,137,137,137,137,137,138,138,138,138,138,139,139,140,140,140,140,141,141,141,141,141,142,142,142,143,143,144,144,145,145,145,146,146,146,147,147,148,148,148,148,148,149,149,150,150,150,150,150,151,151,151,151,151,151,152,152,152,152,152,152,153,153,153,153,153,154,154,154,154,154,155,155,156,156,156,157,157,157,157,158,158,159,159,159,159,159,160,160,161,161,161,162,162,163,163,164,164,164,164,164,165,165,166,166,166,166,167,167,168,168,168,168,169,169,169,169,169,169,170,170,171,171,171,172,172,172,172,172,173,173,173,173,173,174,174,175,175,176,176,176,177,177,178,178,178,178,178,178,179,179,179,180,180,180,180,180,181,181,181,182,182,182,183,183,184,184,185,185,186,186,186,187,187,187,188,188,188,188,188,189,189,190,190,191,191,191,192,192,192,192,192,193,193,193,193,194,194,194,194,194,195,195,195,196,196,196,197,197,197,198,198,198,198,198,199,199,200,200,200,200,200,200,201,201,202,202,202,202,203,203,203,203,203,204,204,205,205,206,206,207,207,207,208,208,208,209,209,210,210,211,211,212,212,212,212,213,213,213,213,213,214,214,214,215,215,215,216,216,217,217,217,217,217,217,218,218,218,218,219,219,219,219,219,219,220,220,220,221,221,221,222,222,223,223,224,224,225,225,226,226,226,227,227,228,228,228,228,228,229,229,229,230,230,230,231,231,231,232,232,232,232,233,233,234,234,235,235,235,236,236,236,237,237,238,239,239,239,239,239,239,240,240,241,241,242,242,243,243,244,244,244,245,245,246,246,247,247,248,248,249,249,249,250,250,251,251,251,251,251,252,252,252,252,253,253,253,253,254,254,255,255,256,256,257,257,258,258,258,259,259,259,260,260,261,261,262,262,262,262,262,262,263,263,263,264,264,265,265,265,265,265,266,266,267,267,268,268,268,268,268,268,269,269,270,270,271,271,271,271,271,272,272,272,273,273,273,273,273,274,274,275,275,276,276,276,276,276,276,277,277,277,278,278,279,279,279,280,280,280,280,280,281,281,282,282,282,282,283,283,284,284,284,284,285,285,286,286,286,286,286,287,287,288,288,288,289,289,289,289,289,290,290,290,290,291,291,291,292,292,293,293,293,293,293,293,294,294,294,295,295,296,296,296,297,297,297,298,298,298,299,299,299,299,300,300,300,300,300,301,301,301,301,301,302,302,302,302,302,303,303,304,304,304,305,305,305,306,306,307,307,307,307,308,308,308,309,309,309,309,309,309,310,310,310,310,310,310,311,311,312,312,313,313,313,313,313,314,314,314,314,314],"depth":[6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[.data.frame","[","names","names","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","dim","nrow","names","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","n[i] <- nrow(sub_Batting)","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,null,null,null,null,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,null,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,null,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,null,null,null,null,1],"linenum":[null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,10,10,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,11,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,11,null,null,null,null,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,11,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,null,null,11,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,null,11,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,null,11,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,null,13,null,null,null,null,13],"memalloc":[55.1217041015625,55.1217041015625,55.1217041015625,55.1217041015625,55.1217041015625,55.1217041015625,74.9959945678711,74.9959945678711,74.9959945678711,104.253288269043,104.253288269043,120.654983520508,120.654983520508,120.654983520508,145.31672668457,145.31672668457,49.7067260742188,49.7067260742188,49.7067260742188,71.6588897705078,71.6588897705078,91.4060897827148,91.4060897827148,91.4060897827148,119.876922607422,119.876922607422,138.574699401855,138.574699401855,138.574699401855,138.574699401855,45.7458038330078,45.7458038330078,65.6229705810547,65.6229705810547,65.6229705810547,65.6229705810547,65.6229705810547,95.9328079223633,95.9328079223633,115.158828735352,115.158828735352,115.158828735352,115.158828735352,115.158828735352,143.827514648438,143.827514648438,122.627082824707,122.627082824707,122.627082824707,71.7868728637695,71.7868728637695,91.9232788085938,91.9232788085938,91.9232788085938,91.9232788085938,91.9232788085938,119.274002075195,119.274002075195,119.274002075195,119.274002075195,137.901786804199,137.901786804199,44.5045623779297,44.5045623779297,63.8591003417969,63.8591003417969,63.8591003417969,93.3148498535156,93.3148498535156,93.3148498535156,93.3148498535156,93.3148498535156,112.469253540039,112.469253540039,141.789176940918,141.789176940918,141.789176940918,141.789176940918,146.315414428711,146.315414428711,146.315414428711,66.2826995849609,66.2826995849609,66.2826995849609,86.2932052612305,86.2932052612305,116.401100158691,116.401100158691,136.021865844727,136.021865844727,43.6544494628906,43.6544494628906,43.6544494628906,62.6803741455078,62.6803741455078,93.0548706054688,93.0548706054688,110.242752075195,110.242752075195,135.959320068359,135.959320068359,146.329833984375,146.329833984375,146.329833984375,146.329833984375,146.329833984375,146.329833984375,62.2219390869141,62.2219390869141,62.2219390869141,62.2219390869141,62.2219390869141,62.2219390869141,82.4967346191406,82.4967346191406,112.153457641602,112.153457641602,131.047523498535,131.047523498535,146.333717346191,146.333717346191,146.333717346191,56.3177032470703,56.3177032470703,56.3177032470703,56.3177032470703,56.3177032470703,86.1083755493164,86.1083755493164,105.72925567627,105.72925567627,105.72925567627,132.432708740234,132.432708740234,132.432708740234,146.270568847656,146.270568847656,146.270568847656,58.81884765625,58.81884765625,78.6320648193359,78.6320648193359,78.6320648193359,107.758354187012,107.758354187012,126.455764770508,126.455764770508,146.333595275879,146.333595275879,146.333595275879,51.5341949462891,51.5341949462891,51.5341949462891,81.3860626220703,81.3860626220703,101.851509094238,101.851509094238,129.931526184082,129.931526184082,146.33268737793,146.33268737793,146.33268737793,56.1930923461914,56.1930923461914,76.1381301879883,76.1381301879883,106.636039733887,106.636039733887,106.636039733887,106.636039733887,106.636039733887,125.722068786621,125.722068786621,125.722068786621,125.722068786621,125.722068786621,146.322959899902,146.322959899902,146.322959899902,52.4592895507812,52.4592895507812,82.5746459960938,82.5746459960938,82.5746459960938,102.713813781738,102.713813781738,131.120094299316,131.120094299316,131.120094299316,131.120094299316,131.120094299316,146.275184631348,146.275184631348,146.275184631348,58.0312728881836,58.0312728881836,77.9751358032227,77.9751358032227,108.751365661621,108.751365661621,129.155349731445,129.155349731445,146.275756835938,146.275756835938,146.275756835938,56.5276641845703,56.5276641845703,56.5276641845703,85.9864730834961,85.9864730834961,85.9864730834961,85.9864730834961,85.9864730834961,106.194450378418,106.194450378418,106.194450378418,106.194450378418,106.194450378418,134.594467163086,134.594467163086,146.27140045166,146.27140045166,146.27140045166,62.5014495849609,62.5014495849609,62.5014495849609,62.5014495849609,62.5014495849609,82.7764129638672,82.7764129638672,114.003486633301,114.003486633301,114.003486633301,114.003486633301,134.472663879395,134.472663879395,134.472663879395,134.472663879395,49.2140197753906,49.2140197753906,49.2140197753906,63.4779434204102,63.4779434204102,93.6549758911133,93.6549758911133,111.041481018066,111.041481018066,111.041481018066,140.952018737793,140.952018737793,140.952018737793,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,146.328056335449,42.7565689086914,42.7565689086914,42.7565689086914,47.8090057373047,47.8090057373047,47.8090057373047,66.3117904663086,66.3117904663086,92.4872970581055,92.4872970581055,92.4872970581055,112.032386779785,112.032386779785,139.917198181152,139.917198181152,139.917198181152,139.917198181152,139.917198181152,146.279022216797,146.279022216797,146.279022216797,146.279022216797,146.279022216797,146.279022216797,69.7223663330078,69.7223663330078,90.0590362548828,90.0590362548828,90.0590362548828,90.0590362548828,90.0590362548828,119.641342163086,119.641342163086,138.335464477539,138.335464477539,44.6629104614258,44.6629104614258,44.6629104614258,44.6629104614258,61.2587966918945,61.2587966918945,88.4198760986328,88.4198760986328,105.280609130859,105.280609130859,132.56177520752,132.56177520752,146.270355224609,146.270355224609,146.270355224609,59.8205718994141,59.8205718994141,79.6276626586914,79.6276626586914,109.805305480957,109.805305480957,109.805305480957,128.63143157959,128.63143157959,128.63143157959,146.279083251953,146.279083251953,146.279083251953,146.279083251953,146.279083251953,146.279083251953,57.9833221435547,57.9833221435547,88.4155044555664,88.4155044555664,88.4155044555664,108.617378234863,108.617378234863,138.861907958984,138.861907958984,138.861907958984,146.274124145508,146.274124145508,146.274124145508,69.2692947387695,69.2692947387695,69.2692947387695,69.2692947387695,69.2692947387695,89.4045257568359,89.4045257568359,89.4045257568359,89.4045257568359,89.4045257568359,120.368560791016,120.368560791016,120.368560791016,139.325584411621,139.325584411621,49.1950149536133,49.1950149536133,49.1950149536133,49.1950149536133,69.0065002441406,69.0065002441406,99.3730850219727,99.3730850219727,99.3730850219727,116.887298583984,116.887298583984,116.887298583984,143.186943054199,143.186943054199,143.186943054199,43.2923583984375,43.2923583984375,43.2923583984375,43.2923583984375,43.2923583984375,72.4143371582031,72.4143371582031,72.4143371582031,72.4143371582031,72.4143371582031,92.5567169189453,92.5567169189453,92.5567169189453,92.5567169189453,92.5567169189453,123.524803161621,123.524803161621,143.729904174805,143.729904174805,143.729904174805,143.729904174805,53.9218673706055,53.9218673706055,53.9218673706055,53.9218673706055,53.9218673706055,74.0652923583984,74.0652923583984,74.0652923583984,103.984405517578,103.984405517578,123.798248291016,123.798248291016,146.295585632324,146.295585632324,146.295585632324,53.2664260864258,53.2664260864258,53.2664260864258,82.2658004760742,82.2658004760742,99.515022277832,99.515022277832,99.515022277832,99.515022277832,99.515022277832,127.985717773438,127.985717773438,144.912651062012,144.912651062012,144.912651062012,144.912651062012,144.912651062012,54.055419921875,54.055419921875,54.055419921875,54.055419921875,54.055419921875,54.055419921875,70.9166641235352,70.9166641235352,70.9166641235352,70.9166641235352,70.9166641235352,70.9166641235352,96.9664077758789,96.9664077758789,96.9664077758789,96.9664077758789,96.9664077758789,115.333610534668,115.333610534668,115.333610534668,115.333610534668,115.333610534668,142.040626525879,142.040626525879,141.329803466797,141.329803466797,141.329803466797,70.0702896118164,70.0702896118164,70.0702896118164,70.0702896118164,88.9605941772461,88.9605941772461,117.49641418457,117.49641418457,117.49641418457,117.49641418457,117.49641418457,134.553977966309,134.553977966309,107.095413208008,107.095413208008,107.095413208008,58.5823593139648,58.5823593139648,85.4882888793945,85.4882888793945,104.505668640137,104.505668640137,104.505668640137,104.505668640137,104.505668640137,133.304718017578,133.304718017578,146.296401977539,146.296401977539,146.296401977539,146.296401977539,60.8867950439453,60.8867950439453,79.1269836425781,79.1269836425781,79.1269836425781,79.1269836425781,106.611679077148,106.611679077148,106.611679077148,106.611679077148,106.611679077148,106.611679077148,125.11393737793,125.11393737793,146.303863525391,146.303863525391,146.303863525391,52.4842224121094,52.4842224121094,52.4842224121094,52.4842224121094,52.4842224121094,79.8373336791992,79.8373336791992,79.8373336791992,79.8373336791992,79.8373336791992,99.9717178344727,99.9717178344727,128.574043273926,128.574043273926,146.284683227539,146.284683227539,146.284683227539,54.8461456298828,54.8461456298828,73.7394638061523,73.7394638061523,73.7394638061523,73.7394638061523,73.7394638061523,73.7394638061523,102.998657226562,102.998657226562,102.998657226562,122.15510559082,122.15510559082,122.15510559082,122.15510559082,122.15510559082,146.293334960938,146.293334960938,146.293334960938,50.9152603149414,50.9152603149414,50.9152603149414,80.7081069946289,80.7081069946289,98.6854705810547,98.6854705810547,129.516525268555,129.516525268555,146.308921813965,146.308921813965,146.308921813965,60.2961654663086,60.2961654663086,60.2961654663086,79.5102920532227,79.5102920532227,79.5102920532227,79.5102920532227,79.5102920532227,108.760719299316,108.760719299316,127.390785217285,127.390785217285,146.283126831055,146.283126831055,146.283126831055,55.8993911743164,55.8993911743164,55.8993911743164,55.8993911743164,55.8993911743164,84.8215560913086,84.8215560913086,84.8215560913086,84.8215560913086,101.551345825195,101.551345825195,101.551345825195,101.551345825195,101.551345825195,131.066184997559,131.066184997559,131.066184997559,146.285148620605,146.285148620605,146.285148620605,61.9406356811523,61.9406356811523,61.9406356811523,81.9453887939453,81.9453887939453,81.9453887939453,81.9453887939453,81.9453887939453,111.852729797363,111.852729797363,132.054862976074,132.054862976074,132.054862976074,132.054862976074,132.054862976074,132.054862976074,44.0997085571289,44.0997085571289,63.5789642333984,63.5789642333984,63.5789642333984,63.5789642333984,93.8812255859375,93.8812255859375,93.8812255859375,93.8812255859375,93.8812255859375,114.411926269531,114.411926269531,145.368057250977,145.368057250977,44.5933380126953,44.5933380126953,75.0276031494141,75.0276031494141,75.0276031494141,95.4873580932617,95.4873580932617,95.4873580932617,124.604766845703,124.604766845703,144.869644165039,144.869644165039,53.9732666015625,53.9732666015625,74.1760482788086,74.1760482788086,74.1760482788086,74.1760482788086,102.445579528809,102.445579528809,102.445579528809,102.445579528809,102.445579528809,122.644500732422,122.644500732422,122.644500732422,146.318710327148,146.318710327148,146.318710327148,52.2033157348633,52.2033157348633,80.2747344970703,80.2747344970703,80.2747344970703,80.2747344970703,80.2747344970703,80.2747344970703,99.7529373168945,99.7529373168945,99.7529373168945,99.7529373168945,130.776596069336,130.776596069336,130.776596069336,130.776596069336,130.776596069336,130.776596069336,146.32177734375,146.32177734375,146.32177734375,60.532356262207,60.532356262207,60.532356262207,81.0612411499023,81.0612411499023,111.95450592041,111.95450592041,132.28653717041,132.28653717041,43.5476226806641,43.5476226806641,62.8300094604492,62.8300094604492,62.8300094604492,93.6550216674805,93.6550216674805,113.462615966797,113.462615966797,113.462615966797,113.462615966797,113.462615966797,141.925880432129,141.925880432129,141.925880432129,81.9829711914062,81.9829711914062,81.9829711914062,71.3570938110352,71.3570938110352,71.3570938110352,89.6531600952148,89.6531600952148,89.6531600952148,89.6531600952148,119.952239990234,119.952239990234,138.122695922852,138.122695922852,48.4693374633789,48.4693374633789,48.4693374633789,68.8622207641602,68.8622207641602,68.8622207641602,98.7701263427734,98.7701263427734,119.237594604492,146.323181152344,146.323181152344,146.323181152344,146.323181152344,146.323181152344,146.323181152344,49.3881912231445,49.3881912231445,80.3375091552734,80.3375091552734,100.14013671875,100.14013671875,131.155517578125,131.155517578125,146.301651000977,146.301651000977,146.301651000977,62.3739166259766,62.3739166259766,82.8329238891602,82.8329238891602,113.585037231445,113.585037231445,133.912734985352,133.912734985352,44.7331085205078,44.7331085205078,44.7331085205078,64.0763626098633,64.0763626098633,94.5673751831055,94.5673751831055,94.5673751831055,94.5673751831055,94.5673751831055,114.958648681641,114.958648681641,114.958648681641,114.958648681641,145.385704040527,145.385704040527,145.385704040527,145.385704040527,45.8490219116211,45.8490219116211,76.6054534912109,76.6054534912109,96.8664855957031,96.8664855957031,128.016220092773,128.016220092773,146.311325073242,146.311325073242,146.311325073242,59.3584747314453,59.3584747314453,59.3584747314453,79.2267837524414,79.2267837524414,110.240898132324,110.240898132324,130.960441589355,130.960441589355,130.960441589355,130.960441589355,130.960441589355,130.960441589355,113.708869934082,113.708869934082,113.708869934082,62.1130447387695,62.1130447387695,92.2753982543945,92.2753982543945,92.2753982543945,92.2753982543945,92.2753982543945,112.929206848145,112.929206848145,143.94458770752,143.94458770752,44.8025588989258,44.8025588989258,44.8025588989258,44.8025588989258,44.8025588989258,44.8025588989258,74.8344497680664,74.8344497680664,95.5548858642578,95.5548858642578,126.37329864502,126.37329864502,126.37329864502,126.37329864502,126.37329864502,146.305908203125,146.305908203125,146.305908203125,56.9336700439453,56.9336700439453,56.9336700439453,56.9336700439453,56.9336700439453,77.1293869018555,77.1293869018555,108.275459289551,108.275459289551,128.930404663086,128.930404663086,128.930404663086,128.930404663086,128.930404663086,128.930404663086,146.304870605469,146.304870605469,146.304870605469,60.341194152832,60.341194152832,90.9585571289062,90.9585571289062,90.9585571289062,111.610191345215,111.610191345215,111.610191345215,111.610191345215,111.610191345215,142.816802978516,142.816802978516,43.8865356445312,43.8865356445312,43.8865356445312,43.8865356445312,72.7336578369141,72.7336578369141,89.3207321166992,89.3207321166992,89.3207321166992,89.3207321166992,119.871635437012,119.871635437012,140.458755493164,140.458755493164,140.458755493164,140.458755493164,140.458755493164,51.6234359741211,51.6234359741211,71.7515716552734,71.7515716552734,71.7515716552734,101.97526550293,101.97526550293,101.97526550293,101.97526550293,101.97526550293,122.562019348145,122.562019348145,122.562019348145,122.562019348145,146.294967651367,146.294967651367,146.294967651367,54.311637878418,54.311637878418,84.5359649658203,84.5359649658203,84.5359649658203,84.5359649658203,84.5359649658203,84.5359649658203,104.860046386719,104.860046386719,104.860046386719,135.673950195312,135.673950195312,146.294921875,146.294921875,146.294921875,66.9658508300781,66.9658508300781,66.9658508300781,87.4205932617188,87.4205932617188,87.4205932617188,118.56128692627,118.56128692627,118.56128692627,118.56128692627,139.278182983398,139.278182983398,139.278182983398,139.278182983398,139.278182983398,50.1831130981445,50.1831130981445,50.1831130981445,50.1831130981445,50.1831130981445,70.5066909790039,70.5066909790039,70.5066909790039,70.5066909790039,70.5066909790039,101.450752258301,101.450752258301,122.102508544922,122.102508544922,122.102508544922,146.29411315918,146.29411315918,146.29411315918,50.8860855102539,50.8860855102539,81.8306274414062,81.8306274414062,81.8306274414062,81.8306274414062,102.154266357422,102.154266357422,102.154266357422,133.754211425781,133.754211425781,133.754211425781,133.754211425781,133.754211425781,133.754211425781,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,63.7364044189453,63.7364044189453,84.2566833496094,84.2566833496094,113.393280029297,113.393280029297,113.393280029297,113.393280029297,113.393280029297,113.393280029297,113.393280029297,113.393280029297,113.393280029297,113.393280029297],"meminc":[0,0,0,0,0,0,19.8742904663086,0,0,29.2572937011719,0,16.4016952514648,0,0,24.6617431640625,0,-95.6100006103516,0,0,21.9521636962891,0,19.747200012207,0,0,28.470832824707,0,18.6977767944336,0,0,0,-92.8288955688477,0,19.8771667480469,0,0,0,0,30.3098373413086,0,19.2260208129883,0,0,0,0,28.6686859130859,0,-21.2004318237305,0,0,-50.8402099609375,0,20.1364059448242,0,0,0,0,27.3507232666016,0,0,0,18.6277847290039,0,-93.3972244262695,0,19.3545379638672,0,0,29.4557495117188,0,0,0,0,19.1544036865234,0,29.3199234008789,0,0,0,4.52623748779297,0,0,-80.03271484375,0,0,20.0105056762695,0,30.1078948974609,0,19.6207656860352,0,-92.3674163818359,0,0,19.0259246826172,0,30.3744964599609,0,17.1878814697266,0,25.7165679931641,0,10.3705139160156,0,0,0,0,0,-84.1078948974609,0,0,0,0,0,20.2747955322266,0,29.6567230224609,0,18.8940658569336,0,15.2861938476562,0,0,-90.0160140991211,0,0,0,0,29.7906723022461,0,19.6208801269531,0,0,26.7034530639648,0,0,13.8378601074219,0,0,-87.4517211914062,0,19.8132171630859,0,0,29.1262893676758,0,18.6974105834961,0,19.8778305053711,0,0,-94.7994003295898,0,0,29.8518676757812,0,20.465446472168,0,28.0800170898438,0,16.4011611938477,0,0,-90.1395950317383,0,19.9450378417969,0,30.4979095458984,0,0,0,0,19.0860290527344,0,0,0,0,20.6008911132812,0,0,-93.8636703491211,0,30.1153564453125,0,0,20.1391677856445,0,28.4062805175781,0,0,0,0,15.1550903320312,0,0,-88.2439117431641,0,19.9438629150391,0,30.7762298583984,0,20.4039840698242,0,17.1204071044922,0,0,-89.7480926513672,0,0,29.4588088989258,0,0,0,0,20.2079772949219,0,0,0,0,28.400016784668,0,11.6769332885742,0,0,-83.7699508666992,0,0,0,0,20.2749633789062,0,31.2270736694336,0,0,0,20.4691772460938,0,0,0,-85.2586441040039,0,0,14.2639236450195,0,30.1770324707031,0,17.3865051269531,0,0,29.9105377197266,0,0,5.37603759765625,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,5.05243682861328,0,0,18.5027847290039,0,26.1755065917969,0,0,19.5450897216797,0,27.8848114013672,0,0,0,0,6.36182403564453,0,0,0,0,0,-76.5566558837891,0,20.336669921875,0,0,0,0,29.5823059082031,0,18.6941223144531,0,-93.6725540161133,0,0,0,16.5958862304688,0,27.1610794067383,0,16.8607330322266,0,27.2811660766602,0,13.7085800170898,0,0,-86.4497833251953,0,19.8070907592773,0,30.1776428222656,0,0,18.8261260986328,0,0,17.6476516723633,0,0,0,0,0,-88.2957611083984,0,30.4321823120117,0,0,20.2018737792969,0,30.2445297241211,0,0,7.41221618652344,0,0,-77.0048294067383,0,0,0,0,20.1352310180664,0,0,0,0,30.9640350341797,0,0,18.9570236206055,0,-90.1305694580078,0,0,0,19.8114852905273,0,30.366584777832,0,0,17.5142135620117,0,0,26.2996444702148,0,0,-99.8945846557617,0,0,0,0,29.1219787597656,0,0,0,0,20.1423797607422,0,0,0,0,30.9680862426758,0,20.2051010131836,0,0,0,-89.8080368041992,0,0,0,0,20.143424987793,0,0,29.9191131591797,0,19.8138427734375,0,22.4973373413086,0,0,-93.0291595458984,0,0,28.9993743896484,0,17.2492218017578,0,0,0,0,28.4706954956055,0,16.9269332885742,0,0,0,0,-90.8572311401367,0,0,0,0,0,16.8612442016602,0,0,0,0,0,26.0497436523438,0,0,0,0,18.3672027587891,0,0,0,0,26.7070159912109,0,-0.710823059082031,0,0,-71.2595138549805,0,0,0,18.8903045654297,0,28.5358200073242,0,0,0,0,17.0575637817383,0,-27.4585647583008,0,0,-48.513053894043,0,26.9059295654297,0,19.0173797607422,0,0,0,0,28.7990493774414,0,12.9916839599609,0,0,0,-85.4096069335938,0,18.2401885986328,0,0,0,27.4846954345703,0,0,0,0,0,18.5022583007812,0,21.1899261474609,0,0,-93.8196411132812,0,0,0,0,27.3531112670898,0,0,0,0,20.1343841552734,0,28.6023254394531,0,17.7106399536133,0,0,-91.4385375976562,0,18.8933181762695,0,0,0,0,0,29.2591934204102,0,0,19.1564483642578,0,0,0,0,24.1382293701172,0,0,-95.3780746459961,0,0,29.7928466796875,0,17.9773635864258,0,30.8310546875,0,16.7923965454102,0,0,-86.0127563476562,0,0,19.2141265869141,0,0,0,0,29.2504272460938,0,18.6300659179688,0,18.8923416137695,0,0,-90.3837356567383,0,0,0,0,28.9221649169922,0,0,0,16.7297897338867,0,0,0,0,29.5148391723633,0,0,15.2189636230469,0,0,-84.3445129394531,0,0,20.004753112793,0,0,0,0,29.907341003418,0,20.2021331787109,0,0,0,0,0,-87.9551544189453,0,19.4792556762695,0,0,0,30.3022613525391,0,0,0,0,20.5307006835938,0,30.9561309814453,0,-100.774719238281,0,30.4342651367188,0,0,20.4597549438477,0,0,29.1174087524414,0,20.2648773193359,0,-90.8963775634766,0,20.2027816772461,0,0,0,28.26953125,0,0,0,0,20.1989212036133,0,0,23.6742095947266,0,0,-94.1153945922852,0,28.071418762207,0,0,0,0,0,19.4782028198242,0,0,0,31.0236587524414,0,0,0,0,0,15.5451812744141,0,0,-85.789421081543,0,0,20.5288848876953,0,30.8932647705078,0,20.33203125,0,-88.7389144897461,0,19.2823867797852,0,0,30.8250122070312,0,19.8075942993164,0,0,0,0,28.463264465332,0,0,-59.9429092407227,0,0,-10.6258773803711,0,0,18.2960662841797,0,0,0,30.2990798950195,0,18.1704559326172,0,-89.6533584594727,0,0,20.3928833007812,0,0,29.9079055786133,0,20.4674682617188,27.0855865478516,0,0,0,0,0,-96.9349899291992,0,30.9493179321289,0,19.8026275634766,0,31.015380859375,0,15.1461334228516,0,0,-83.927734375,0,20.4590072631836,0,30.7521133422852,0,20.3276977539062,0,-89.1796264648438,0,0,19.3432540893555,0,30.4910125732422,0,0,0,0,20.3912734985352,0,0,0,30.4270553588867,0,0,0,-99.5366821289062,0,30.7564315795898,0,20.2610321044922,0,31.1497344970703,0,18.2951049804688,0,0,-86.9528503417969,0,0,19.8683090209961,0,31.0141143798828,0,20.7195434570312,0,0,0,0,0,-17.2515716552734,0,0,-51.5958251953125,0,30.162353515625,0,0,0,0,20.65380859375,0,31.015380859375,0,-99.1420288085938,0,0,0,0,0,30.0318908691406,0,20.7204360961914,0,30.8184127807617,0,0,0,0,19.9326095581055,0,0,-89.3722381591797,0,0,0,0,20.1957168579102,0,31.1460723876953,0,20.6549453735352,0,0,0,0,0,17.3744659423828,0,0,-85.9636764526367,0,30.6173629760742,0,0,20.6516342163086,0,0,0,0,31.2066116333008,0,-98.9302673339844,0,0,0,28.8471221923828,0,16.5870742797852,0,0,0,30.5509033203125,0,20.5871200561523,0,0,0,0,-88.835319519043,0,20.1281356811523,0,0,30.2236938476562,0,0,0,0,20.5867538452148,0,0,0,23.7329483032227,0,0,-91.9833297729492,0,30.2243270874023,0,0,0,0,0,20.3240814208984,0,0,30.8139038085938,0,10.6209716796875,0,0,-79.3290710449219,0,0,20.4547424316406,0,0,31.1406936645508,0,0,0,20.7168960571289,0,0,0,0,-89.0950698852539,0,0,0,0,20.3235778808594,0,0,0,0,30.9440612792969,0,20.6517562866211,0,0,24.1916046142578,0,0,-95.4080276489258,0,30.9445419311523,0,0,0,20.3236389160156,0,0,31.5999450683594,0,0,0,0,0,12.5220413208008,0,0,0,0,0,-82.5398483276367,0,20.5202789306641,0,29.1365966796875,0,0,0,0,0,0,0,0,0],"filename":[null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpGaSEiO/file3c3858f9dc99.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq        mean     median
#>         compute_pi0(m)    807.893    818.7575    846.3945    829.687
#>    compute_pi0(m * 10)   8121.053   8160.7130   8355.2542   8225.825
#>   compute_pi0(m * 100)  81872.519  82159.5225  83552.1442  82395.857
#>         compute_pi1(m)    164.296    233.4915    729.2719    291.655
#>    compute_pi1(m * 10)   1285.365   1360.2045  10427.8669   1445.195
#>   compute_pi1(m * 100)  13140.500  15667.1850  20247.9577  19451.864
#>  compute_pi1(m * 1000) 255036.223 320224.9725 378232.4718 374034.797
#>           uq        max neval
#>     853.4495    969.114    20
#>    8429.0995   9083.081    20
#>   83325.6850  93172.527    20
#>     328.8420   9350.246    20
#>    1488.2310 169822.560    20
#>   22944.6640  32896.695    20
#>  431595.6220 548212.223    20
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
#>   memory_copy1(n) 5604.73317 4497.70003 529.580937 4585.13776 3710.22299
#>   memory_copy2(n)   94.62142   78.68479   9.990142   80.45041   60.51348
#>  pre_allocate1(n)   20.88245   16.47390   3.414168   16.13515   12.73294
#>  pre_allocate2(n)  202.60171  165.99069  20.777562  166.03169  144.57918
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  85.509810    10
#>   2.495117    10
#>   2.005549    10
#>   4.218411    10
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
#>  f1(df) 300.1084 274.9412 103.7353 278.4561 87.40608 40.57864     5
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
