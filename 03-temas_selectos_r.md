
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
#>    id           a          b        c        d
#> 1   1 -0.09528258  4.0938063 3.537191 3.191991
#> 2   2  0.55105453 -0.2048075 2.526752 3.958035
#> 3   3 -1.29480927  1.9787144 4.979063 5.177134
#> 4   4  1.22590684  3.2070085 2.314251 4.976223
#> 5   5 -0.89806209  2.8149306 1.171100 3.569784
#> 6   6 -0.22216252  2.8784355 4.775945 4.371727
#> 7   7  0.19798131  2.4327186 3.035971 3.617703
#> 8   8  0.10539105  1.3306706 3.247287 3.551424
#> 9   9  0.40168545  2.6566876 2.569378 3.104814
#> 10 10  0.09217783  1.5484709 3.641215 3.461137
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.006388054
mean(df$b)
#> [1] 2.273664
mean(df$c)
#> [1] 3.179815
mean(df$d)
#> [1] 3.897997
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.006388054 2.273663550 3.179815231 3.897997377
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
#> [1] 0.006388054 2.273663550 3.179815231 3.897997377
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
#> [1] 5.500000000 0.006388054 2.273663550 3.179815231 3.897997377
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
#> [1] 5.50000000 0.09878444 2.54470308 3.14162872 3.59374347
col_describe(df, mean)
#> [1] 5.500000000 0.006388054 2.273663550 3.179815231 3.897997377
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
#> 5.500000000 0.006388054 2.273663550 3.179815231 3.897997377
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
#>   4.802   0.204   5.008
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.017   0.012   1.171
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
#>  15.898   1.141  12.399
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
#>   0.154   0.000   0.155
plyr_st
#>    user  system elapsed 
#>   5.686   0.007   5.693
est_l_st
#>    user  system elapsed 
#>  82.138   2.556  84.699
est_r_st
#>    user  system elapsed 
#>   0.436   0.012   0.448
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

<!--html_preserve--><div id="htmlwidget-fea2eebf6825d5c656c1" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-fea2eebf6825d5c656c1">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,4,4,4,4,4,5,5,6,6,6,7,7,7,7,7,8,8,9,9,9,9,9,10,10,10,10,10,11,11,11,12,12,12,13,13,14,14,14,14,15,15,16,16,17,17,18,18,19,19,19,19,20,20,21,21,21,22,22,22,23,23,24,24,25,25,26,26,26,26,26,26,27,27,27,28,28,29,29,30,30,30,30,30,31,31,32,32,32,33,33,33,33,33,34,34,35,35,35,35,35,36,36,37,37,38,38,38,38,38,38,39,39,39,39,39,40,40,41,41,41,41,41,42,42,42,43,43,43,44,44,44,44,44,44,45,45,45,46,46,46,46,46,47,47,48,48,49,49,49,50,50,51,51,51,51,52,52,53,53,53,54,54,54,55,55,55,56,56,57,57,58,58,58,59,59,59,60,60,60,61,61,61,62,62,62,62,62,62,63,63,63,63,63,63,64,64,65,65,66,66,67,67,68,68,68,68,68,69,69,69,69,70,70,70,71,71,72,72,72,73,73,73,73,73,74,74,75,75,75,76,76,77,77,78,78,79,79,79,79,80,80,80,81,81,82,82,82,82,83,83,84,84,85,85,85,86,86,87,87,87,87,88,88,89,89,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,103,104,104,104,105,105,105,106,106,106,107,107,107,107,107,108,108,108,109,109,109,110,110,111,111,111,112,112,113,113,113,114,114,115,115,115,115,115,116,116,116,117,117,118,118,119,119,120,120,120,120,121,121,122,122,122,123,123,124,124,125,125,125,125,126,126,126,126,126,127,127,128,128,129,129,130,130,131,131,132,132,132,132,132,132,133,133,134,134,135,135,135,135,136,136,136,137,137,137,138,138,139,139,140,140,140,140,140,140,141,141,142,142,142,143,143,143,143,144,144,144,145,145,146,146,147,147,147,148,148,148,149,149,149,149,150,150,150,150,151,151,151,152,152,152,152,152,152,153,153,153,154,154,155,155,155,155,155,156,156,156,156,156,157,157,157,158,158,158,158,158,158,159,159,160,160,161,161,161,162,162,163,163,163,164,164,165,165,165,166,166,166,167,167,167,168,168,169,169,170,170,171,171,171,172,172,173,173,173,174,174,175,175,176,176,176,177,177,177,178,178,178,179,179,179,180,180,180,180,180,181,181,181,181,181,182,182,182,182,182,182,183,183,183,183,183,184,184,184,185,185,186,186,187,187,187,188,188,188,189,189,189,190,190,191,191,192,192,192,193,193,194,194,194,194,194,195,195,195,196,196,196,197,197,198,198,198,199,199,200,200,201,201,202,202,203,203,204,204,205,205,205,205,205,206,206,206,207,207,207,207,207,208,208,209,209,210,210,211,211,212,212,212,213,213,213,213,213,213,214,214,215,215,216,216,216,217,217,218,218,218,219,219,220,220,220,221,221,222,222,223,223,223,224,224,225,225,226,226,226,227,227,228,228,228,228,228,228,229,229,230,230,231,231,231,231,231,232,232,232,233,233,233,234,234,235,235,235,235,235,236,236,237,237,237,238,238,238,239,239,240,240,241,241,242,242,243,243,243,244,244,244,244,244,245,245,246,246,246,247,247,247,248,248,248,249,249,250,250,250,251,251,252,252,253,253,253,254,254,254,254,254,255,255,255,255,256,256,257,257,258,258,259,259,259,259,259,260,260,260,260,260,261,261,262,262,263,263,263,263,264,264,264,265,265,265,265,265,266,266,267,267,267,268,268,268,268,268,269,269,269,269,269,270,270,270,270,271,271,271,272,272,272,273,273,273,274,274,274,274,274,275,275,275,275,275,276,276,276,277,277,278,278,279,279,280,280,281,281,282,282,282,282,283,283,284,284,284,285,285,286,286,286,287,287,288,288,289,289,289,290,290,290,291,291,292,292,292,292,292,293,293,294,294,294,295,295,296,296,297,297,297,298,298,298,298,298,299,299,299,300,300,301,301,302,302,302,303,303,304,304,304,304,305,305,306,306,306,307,307,308,308,309,309,310,310,311,311,311,311,311,312,312,313,313,313,314,314,314,315,315,315,316,316,316,316,316,316,317,317,318,318,318,319,319,319,319,319,320,320,320,320,321,321,322,322,322,322,322,323,323,323,324,324,324,324,325,325,326,326,326,326,326,327,327,327,327,327],"depth":[2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.factor","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1],"linenum":[9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,null,11,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,13],"memalloc":[54.4405899047852,54.4405899047852,73.3313446044922,73.3313446044922,98.9168930053711,98.9168930053711,114.463310241699,114.463310241699,114.463310241699,114.463310241699,114.463310241699,138.404975891113,138.404975891113,146.276191711426,146.276191711426,146.276191711426,61.5969085693359,61.5969085693359,61.5969085693359,61.5969085693359,61.5969085693359,81.2132263183594,81.2132263183594,109.030830383301,109.030830383301,109.030830383301,109.030830383301,109.030830383301,126.27961730957,126.27961730957,126.27961730957,126.27961730957,126.27961730957,146.287475585938,146.287475585938,146.287475585938,49.5887756347656,49.5887756347656,49.5887756347656,77.0762023925781,77.0762023925781,95.5141448974609,95.5141448974609,95.5141448974609,95.5141448974609,122.67798614502,122.67798614502,140.393135070801,140.393135070801,44.672966003418,44.672966003418,63.0367584228516,63.0367584228516,91.570182800293,91.570182800293,91.570182800293,91.570182800293,109.804275512695,109.804275512695,135.383674621582,135.383674621582,135.383674621582,146.275093078613,146.275093078613,146.275093078613,57.2088775634766,57.2088775634766,76.232795715332,76.232795715332,104.04606628418,104.04606628418,121.758186340332,121.758186340332,121.758186340332,121.758186340332,121.758186340332,121.758186340332,146.290084838867,146.290084838867,146.290084838867,44.8072280883789,44.8072280883789,72.8206634521484,72.8206634521484,91.7769775390625,91.7769775390625,91.7769775390625,91.7769775390625,91.7769775390625,119.329490661621,119.329490661621,137.176689147949,137.176689147949,137.176689147949,43.4323501586914,43.4323501586914,43.4323501586914,43.4323501586914,43.4323501586914,61.0812149047852,61.0812149047852,89.6148147583008,89.6148147583008,89.6148147583008,89.6148147583008,89.6148147583008,108.775039672852,108.775039672852,136.458404541016,136.458404541016,146.304504394531,146.304504394531,146.304504394531,146.304504394531,146.304504394531,146.304504394531,60.6876373291016,60.6876373291016,60.6876373291016,60.6876373291016,60.6876373291016,78.7315063476562,78.7315063476562,106.356163024902,106.356163024902,106.356163024902,106.356163024902,106.356163024902,124.069190979004,124.069190979004,124.069190979004,146.308387756348,146.308387756348,146.308387756348,47.1090469360352,47.1090469360352,47.1090469360352,47.1090469360352,47.1090469360352,47.1090469360352,75.7788467407227,75.7788467407227,75.7788467407227,94.6794815063477,94.6794815063477,94.6794815063477,94.6794815063477,94.6794815063477,120.069007873535,120.069007873535,136.736175537109,136.736175537109,61.5509948730469,61.5509948730469,61.5509948730469,61.354621887207,61.354621887207,89.4905700683594,89.4905700683594,89.4905700683594,89.4905700683594,107.404899597168,107.404899597168,135.418464660645,135.418464660645,135.418464660645,146.308250427246,146.308250427246,146.308250427246,60.889289855957,60.889289855957,60.889289855957,80.5723190307617,80.5723190307617,110.287048339844,110.287048339844,130.169494628906,130.169494628906,130.169494628906,146.307472229004,146.307472229004,146.307472229004,56.4303817749023,56.4303817749023,56.4303817749023,85.2963333129883,85.2963333129883,85.2963333129883,102.478187561035,102.478187561035,102.478187561035,102.478187561035,102.478187561035,102.478187561035,127.663589477539,127.663589477539,127.663589477539,127.663589477539,127.663589477539,127.663589477539,144.918922424316,144.918922424316,51.2536315917969,51.2536315917969,70.0878219604492,70.0878219604492,98.8143539428711,98.8143539428711,117.122673034668,117.122673034668,117.122673034668,117.122673034668,117.122673034668,144.93709564209,144.93709564209,144.93709564209,144.93709564209,146.315467834473,146.315467834473,146.315467834473,68.3728561401367,68.3728561401367,88.6410903930664,88.6410903930664,88.6410903930664,116.335525512695,116.335525512695,116.335525512695,116.335525512695,116.335525512695,131.097312927246,131.097312927246,146.316070556641,146.316070556641,146.316070556641,54.9937896728516,54.9937896728516,83.0758514404297,83.0758514404297,102.300193786621,102.300193786621,132.470443725586,132.470443725586,132.470443725586,132.470443725586,146.311744689941,146.311744689941,146.311744689941,57.5518341064453,57.5518341064453,77.0408096313477,77.0408096313477,77.0408096313477,77.0408096313477,105.580337524414,105.580337524414,123.819229125977,123.819229125977,146.318748474121,146.318748474121,146.318748474121,48.4381942749023,48.4381942749023,77.5564651489258,77.5564651489258,77.5564651489258,77.5564651489258,96.5812759399414,96.5812759399414,124.068511962891,124.068511962891,142.303482055664,142.303482055664,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,146.302726745605,42.731315612793,42.731315612793,42.731315612793,52.180534362793,52.180534362793,52.180534362793,52.180534362793,52.180534362793,71.6640472412109,71.6640472412109,71.6640472412109,100.003028869629,100.003028869629,100.003028869629,118.631324768066,118.631324768066,146.31950378418,146.31950378418,146.31950378418,46.2769393920898,46.2769393920898,75.2114562988281,75.2114562988281,75.2114562988281,93.901741027832,93.901741027832,121.518051147461,121.518051147461,121.518051147461,121.518051147461,121.518051147461,139.754020690918,139.754020690918,139.754020690918,47.9833831787109,47.9833831787109,67.3977127075195,67.3977127075195,96.331657409668,96.331657409668,114.827095031738,114.827095031738,114.827095031738,114.827095031738,141.716804504395,141.716804504395,146.309211730957,146.309211730957,146.309211730957,68.1250991821289,68.1250991821289,87.1468963623047,87.1468963623047,115.617324829102,115.617324829102,115.617324829102,115.617324829102,134.512145996094,134.512145996094,134.512145996094,134.512145996094,134.512145996094,43.3925552368164,43.3925552368164,61.1062393188477,61.1062393188477,89.9633407592773,89.9633407592773,108.32999420166,108.32999420166,136.803771972656,136.803771972656,146.315040588379,146.315040588379,146.315040588379,146.315040588379,146.315040588379,146.315040588379,65.6344985961914,65.6344985961914,84.7210464477539,84.7210464477539,113.193420410156,113.193420410156,113.193420410156,113.193420410156,130.969207763672,130.969207763672,130.969207763672,146.319541931152,146.319541931152,146.319541931152,56.710563659668,56.710563659668,85.7715835571289,85.7715835571289,105.25138092041,105.25138092041,105.25138092041,105.25138092041,105.25138092041,105.25138092041,134.504821777344,134.504821777344,146.308609008789,146.308609008789,146.308609008789,62.9463272094727,62.9463272094727,62.9463272094727,62.9463272094727,82.0967712402344,82.0967712402344,82.0967712402344,110.509536743164,110.509536743164,129.795387268066,129.795387268066,146.263702392578,146.263702392578,146.263702392578,57.8349609375,57.8349609375,57.8349609375,85.5249176025391,85.5249176025391,85.5249176025391,85.5249176025391,103.303161621094,103.303161621094,103.303161621094,103.303161621094,132.233711242676,132.233711242676,132.233711242676,146.270980834961,146.270980834961,146.270980834961,146.270980834961,146.270980834961,146.270980834961,60.3883056640625,60.3883056640625,60.3883056640625,80.0743713378906,80.0743713378906,110.377212524414,110.377212524414,110.377212524414,110.377212524414,110.377212524414,129.86449432373,129.86449432373,129.86449432373,129.86449432373,129.86449432373,146.264015197754,146.264015197754,146.264015197754,57.5717086791992,57.5717086791992,57.5717086791992,57.5717086791992,57.5717086791992,57.5717086791992,86.5725326538086,86.5725326538086,106.38835144043,106.38835144043,130.730987548828,130.730987548828,130.730987548828,140.901473999023,140.901473999023,46.8180847167969,46.8180847167969,46.8180847167969,65.5835418701172,65.5835418701172,94.3143768310547,94.3143768310547,94.3143768310547,114.52108001709,114.52108001709,114.52108001709,144.438766479492,144.438766479492,144.438766479492,44.7840347290039,44.7840347290039,73.2597427368164,73.2597427368164,92.9394378662109,92.9394378662109,121.992500305176,121.992500305176,121.992500305176,140.825073242188,140.825073242188,47.6758651733398,47.6758651733398,47.6758651733398,64.7344436645508,64.7344436645508,91.4974899291992,91.4974899291992,110.656593322754,110.656593322754,110.656593322754,137.42138671875,137.42138671875,137.42138671875,146.278984069824,146.278984069824,146.278984069824,64.7269439697266,64.7269439697266,64.7269439697266,84.0773391723633,84.0773391723633,84.0773391723633,84.0773391723633,84.0773391723633,113.987205505371,113.987205505371,113.987205505371,113.987205505371,113.987205505371,133.993774414062,133.993774414062,133.993774414062,133.993774414062,133.993774414062,133.993774414062,44.0017700195312,44.0017700195312,44.0017700195312,44.0017700195312,44.0017700195312,61.3802032470703,61.3802032470703,61.3802032470703,89.7910995483398,89.7910995483398,109.992988586426,109.992988586426,140.102561950684,140.102561950684,140.102561950684,146.268577575684,146.268577575684,146.268577575684,69.2640609741211,69.2640609741211,69.2640609741211,88.9534606933594,88.9534606933594,117.025527954102,117.025527954102,136.839141845703,136.839141845703,136.839141845703,45.6433486938477,45.6433486938477,63.1556015014648,63.1556015014648,63.1556015014648,63.1556015014648,63.1556015014648,91.0926895141602,91.0926895141602,91.0926895141602,109.983459472656,109.983459472656,109.983459472656,137.139556884766,137.139556884766,146.257637023926,146.257637023926,146.257637023926,64.7912521362305,64.7912521362305,84.5986404418945,84.5986404418945,114.511093139648,114.511093139648,134.515991210938,134.515991210938,44.8582534790039,44.8582534790039,63.5540618896484,63.5540618896484,93.0036163330078,93.0036163330078,93.0036163330078,93.0036163330078,93.0036163330078,113.204078674316,113.204078674316,113.204078674316,143.375274658203,143.375274658203,143.375274658203,143.375274658203,143.375274658203,44.7935943603516,44.7935943603516,74.0453796386719,74.0453796386719,93.3949584960938,93.3949584960938,122.97607421875,122.97607421875,142.324531555176,142.324531555176,142.324531555176,48.4384002685547,48.4384002685547,48.4384002685547,48.4384002685547,48.4384002685547,48.4384002685547,66.9344940185547,66.9344940185547,96.1833648681641,96.1833648681641,115.267211914062,115.267211914062,115.267211914062,142.74600982666,142.74600982666,143.080940246582,143.080940246582,143.080940246582,68.3785934448242,68.3785934448242,87.3371810913086,87.3371810913086,87.3371810913086,116.78141784668,116.78141784668,134.226089477539,134.226089477539,43.65185546875,43.65185546875,43.65185546875,61.2286682128906,61.2286682128906,88.7090606689453,88.7090606689453,108.25496673584,108.25496673584,108.25496673584,137.902282714844,137.902282714844,146.296989440918,146.296989440918,146.296989440918,146.296989440918,146.296989440918,146.296989440918,64.1148910522461,64.1148910522461,82.7417755126953,82.7417755126953,112.191276550293,112.191276550293,112.191276550293,112.191276550293,112.191276550293,131.670738220215,131.670738220215,131.670738220215,146.292846679688,146.292846679688,146.292846679688,58.7386779785156,58.7386779785156,87.5307083129883,87.5307083129883,87.5307083129883,87.5307083129883,87.5307083129883,107.469375610352,107.469375610352,136.129684448242,136.129684448242,136.129684448242,146.296516418457,146.296516418457,146.296516418457,63.6564865112305,63.6564865112305,82.2835998535156,82.2835998535156,111.20573425293,111.20573425293,128.455848693848,128.455848693848,146.297813415527,146.297813415527,146.297813415527,52.836540222168,52.836540222168,52.836540222168,52.836540222168,52.836540222168,80.5780868530273,80.5780868530273,99.729133605957,99.729133605957,99.729133605957,128.066635131836,128.066635131836,128.066635131836,146.034591674805,146.034591674805,146.034591674805,54.8052139282227,54.8052139282227,74.0837173461914,74.0837173461914,74.0837173461914,103.78727722168,103.78727722168,123.131721496582,123.131721496582,146.277565002441,146.277565002441,146.277565002441,51.333122253418,51.333122253418,51.333122253418,51.333122253418,51.333122253418,80.6434936523438,80.6434936523438,80.6434936523438,80.6434936523438,99.8561477661133,99.8561477661133,127.329315185547,127.329315185547,145.36270904541,145.36270904541,53.7579498291016,53.7579498291016,53.7579498291016,53.7579498291016,53.7579498291016,72.7083206176758,72.7083206176758,72.7083206176758,72.7083206176758,72.7083206176758,101.559234619141,101.559234619141,120.246444702148,120.246444702148,146.280494689941,146.280494689941,146.280494689941,146.280494689941,48.1217041015625,48.1217041015625,48.1217041015625,76.8440780639648,76.8440780639648,76.8440780639648,76.8440780639648,76.8440780639648,96.514404296875,96.514404296875,125.238159179688,125.238159179688,125.238159179688,144.451568603516,144.451568603516,144.451568603516,144.451568603516,144.451568603516,52.645378112793,52.645378112793,52.645378112793,52.645378112793,52.645378112793,71.3999252319336,71.3999252319336,71.3999252319336,71.3999252319336,100.249946594238,100.249946594238,100.249946594238,118.412246704102,118.412246704102,118.412246704102,146.278999328613,146.278999328613,146.278999328613,45.8269424438477,45.8269424438477,45.8269424438477,45.8269424438477,45.8269424438477,73.0402145385742,73.0402145385742,73.0402145385742,73.0402145385742,73.0402145385742,92.7768707275391,92.7768707275391,92.7768707275391,119.725616455078,119.725616455078,137.298484802246,137.298484802246,45.2376251220703,45.2376251220703,63.1389999389648,63.1389999389648,90.9407806396484,90.9407806396484,109.694557189941,109.694557189941,109.694557189941,109.694557189941,138.086288452148,138.086288452148,146.282135009766,146.282135009766,146.282135009766,63.6623153686523,63.6623153686523,82.6139526367188,82.6139526367188,82.6139526367188,111.726913452148,111.726913452148,130.545753479004,130.545753479004,146.28067779541,146.28067779541,146.28067779541,57.1052398681641,57.1052398681641,57.1052398681641,84.1170043945312,84.1170043945312,103.063987731934,103.063987731934,103.063987731934,103.063987731934,103.063987731934,134.008193969727,134.008193969727,146.268630981445,146.268630981445,146.268630981445,63.7939758300781,63.7939758300781,83.3966903686523,83.3966903686523,113.554336547852,113.554336547852,113.554336547852,131.71607208252,131.71607208252,131.71607208252,131.71607208252,131.71607208252,146.270370483398,146.270370483398,146.270370483398,61.4345550537109,61.4345550537109,91.6587295532227,91.6587295532227,111.918060302734,111.918060302734,111.918060302734,142.796829223633,142.796829223633,44.1267852783203,44.1267852783203,44.1267852783203,44.1267852783203,73.95703125,73.95703125,92.9700164794922,92.9700164794922,92.9700164794922,122.735160827637,122.735160827637,142.600189208984,142.600189208984,53.4368591308594,53.4368591308594,73.3673095703125,73.3673095703125,101.558258056641,101.558258056641,101.558258056641,101.558258056641,101.558258056641,121.225868225098,121.225868225098,146.269996643066,146.269996643066,146.269996643066,50.5532913208008,50.5532913208008,50.5532913208008,80.4486618041992,80.4486618041992,80.4486618041992,100.313125610352,100.313125610352,100.313125610352,100.313125610352,100.313125610352,100.313125610352,129.61865234375,129.61865234375,146.270652770996,146.270652770996,146.270652770996,56.564826965332,56.564826965332,56.564826965332,56.564826965332,56.564826965332,76.8884811401367,76.8884811401367,76.8884811401367,76.8884811401367,103.243721008301,103.243721008301,120.354934692383,120.354934692383,120.354934692383,120.354934692383,120.354934692383,146.316543579102,146.316543579102,146.316543579102,46.0756912231445,46.0756912231445,46.0756912231445,46.0756912231445,73.1517639160156,73.1517639160156,90.9845962524414,90.9845962524414,90.9845962524414,90.9845962524414,90.9845962524414,112.581581115723,112.581581115723,112.581581115723,112.581581115723,112.581581115723],"meminc":[0,0,18.890754699707,0,25.5855484008789,0,15.5464172363281,0,0,0,0,23.9416656494141,0,7.8712158203125,0,0,-84.6792831420898,0,0,0,0,19.6163177490234,0,27.8176040649414,0,0,0,0,17.2487869262695,0,0,0,0,20.0078582763672,0,0,-96.6986999511719,0,0,27.4874267578125,0,18.4379425048828,0,0,0,27.1638412475586,0,17.7151489257812,0,-95.7201690673828,0,18.3637924194336,0,28.5334243774414,0,0,0,18.2340927124023,0,25.5793991088867,0,0,10.8914184570312,0,0,-89.0662155151367,0,19.0239181518555,0,27.8132705688477,0,17.7121200561523,0,0,0,0,0,24.5318984985352,0,0,-101.482856750488,0,28.0134353637695,0,18.9563140869141,0,0,0,0,27.5525131225586,0,17.8471984863281,0,0,-93.7443389892578,0,0,0,0,17.6488647460938,0,28.5335998535156,0,0,0,0,19.1602249145508,0,27.6833648681641,0,9.84609985351562,0,0,0,0,0,-85.6168670654297,0,0,0,0,18.0438690185547,0,27.6246566772461,0,0,0,0,17.7130279541016,0,0,22.2391967773438,0,0,-99.1993408203125,0,0,0,0,0,28.6697998046875,0,0,18.900634765625,0,0,0,0,25.3895263671875,0,16.6671676635742,0,-75.1851806640625,0,0,-0.196372985839844,0,28.1359481811523,0,0,0,17.9143295288086,0,28.0135650634766,0,0,10.8897857666016,0,0,-85.4189605712891,0,0,19.6830291748047,0,29.714729309082,0,19.8824462890625,0,0,16.1379776000977,0,0,-89.8770904541016,0,0,28.8659515380859,0,0,17.1818542480469,0,0,0,0,0,25.1854019165039,0,0,0,0,0,17.2553329467773,0,-93.6652908325195,0,18.8341903686523,0,28.7265319824219,0,18.3083190917969,0,0,0,0,27.8144226074219,0,0,0,1.37837219238281,0,0,-77.9426116943359,0,20.2682342529297,0,0,27.6944351196289,0,0,0,0,14.7617874145508,0,15.2187576293945,0,0,-91.3222808837891,0,28.0820617675781,0,19.2243423461914,0,30.1702499389648,0,0,0,13.8413009643555,0,0,-88.7599105834961,0,19.4889755249023,0,0,0,28.5395278930664,0,18.2388916015625,0,22.4995193481445,0,0,-97.8805541992188,0,29.1182708740234,0,0,0,19.0248107910156,0,27.4872360229492,0,18.2349700927734,0,3.99924468994141,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,9.44921875,0,0,0,0,19.483512878418,0,0,28.338981628418,0,0,18.6282958984375,0,27.6881790161133,0,0,-100.04256439209,0,28.9345169067383,0,0,18.6902847290039,0,27.6163101196289,0,0,0,0,18.235969543457,0,0,-91.770637512207,0,19.4143295288086,0,28.9339447021484,0,18.4954376220703,0,0,0,26.8897094726562,0,4.5924072265625,0,0,-78.1841125488281,0,19.0217971801758,0,28.4704284667969,0,0,0,18.8948211669922,0,0,0,0,-91.1195907592773,0,17.7136840820312,0,28.8571014404297,0,18.3666534423828,0,28.4737777709961,0,9.51126861572266,0,0,0,0,0,-80.6805419921875,0,19.0865478515625,0,28.4723739624023,0,0,0,17.7757873535156,0,0,15.3503341674805,0,0,-89.6089782714844,0,29.0610198974609,0,19.4797973632812,0,0,0,0,0,29.2534408569336,0,11.8037872314453,0,0,-83.3622817993164,0,0,0,19.1504440307617,0,0,28.4127655029297,0,19.2858505249023,0,16.4683151245117,0,0,-88.4287414550781,0,0,27.6899566650391,0,0,0,17.7782440185547,0,0,0,28.930549621582,0,0,14.0372695922852,0,0,0,0,0,-85.8826751708984,0,0,19.6860656738281,0,30.3028411865234,0,0,0,0,19.4872817993164,0,0,0,0,16.3995208740234,0,0,-88.6923065185547,0,0,0,0,0,29.0008239746094,0,19.8158187866211,0,24.3426361083984,0,0,10.1704864501953,0,-94.0833892822266,0,0,18.7654571533203,0,28.7308349609375,0,0,20.2067031860352,0,0,29.9176864624023,0,0,-99.6547317504883,0,28.4757080078125,0,19.6796951293945,0,29.0530624389648,0,0,18.8325729370117,0,-93.1492080688477,0,0,17.0585784912109,0,26.7630462646484,0,19.1591033935547,0,0,26.7647933959961,0,0,8.85759735107422,0,0,-81.5520401000977,0,0,19.3503952026367,0,0,0,0,29.9098663330078,0,0,0,0,20.0065689086914,0,0,0,0,0,-89.9920043945312,0,0,0,0,17.3784332275391,0,0,28.4108963012695,0,20.2018890380859,0,30.1095733642578,0,0,6.166015625,0,0,-77.0045166015625,0,0,19.6893997192383,0,28.0720672607422,0,19.8136138916016,0,0,-91.1957931518555,0,17.5122528076172,0,0,0,0,27.9370880126953,0,0,18.8907699584961,0,0,27.1560974121094,0,9.11808013916016,0,0,-81.4663848876953,0,19.8073883056641,0,29.9124526977539,0,20.0048980712891,0,-89.6577377319336,0,18.6958084106445,0,29.4495544433594,0,0,0,0,20.2004623413086,0,0,30.1711959838867,0,0,0,0,-98.5816802978516,0,29.2517852783203,0,19.3495788574219,0,29.5811157226562,0,19.3484573364258,0,0,-93.8861312866211,0,0,0,0,0,18.49609375,0,29.2488708496094,0,19.0838470458984,0,0,27.4787979125977,0,0.334930419921875,0,0,-74.7023468017578,0,18.9585876464844,0,0,29.4442367553711,0,17.4446716308594,0,-90.5742340087891,0,0,17.5768127441406,0,27.4803924560547,0,19.5459060668945,0,0,29.6473159790039,0,8.39470672607422,0,0,0,0,0,-82.1820983886719,0,18.6268844604492,0,29.4495010375977,0,0,0,0,19.4794616699219,0,0,14.6221084594727,0,0,-87.5541687011719,0,28.7920303344727,0,0,0,0,19.9386672973633,0,28.6603088378906,0,0,10.1668319702148,0,0,-82.6400299072266,0,18.6271133422852,0,28.9221343994141,0,17.250114440918,0,17.8419647216797,0,0,-93.4612731933594,0,0,0,0,27.7415466308594,0,19.1510467529297,0,0,28.3375015258789,0,0,17.9679565429688,0,0,-91.229377746582,0,19.2785034179688,0,0,29.7035598754883,0,19.3444442749023,0,23.1458435058594,0,0,-94.9444427490234,0,0,0,0,29.3103713989258,0,0,0,19.2126541137695,0,27.4731674194336,0,18.0333938598633,0,-91.6047592163086,0,0,0,0,18.9503707885742,0,0,0,0,28.8509140014648,0,18.6872100830078,0,26.034049987793,0,0,0,-98.1587905883789,0,0,28.7223739624023,0,0,0,0,19.6703262329102,0,28.7237548828125,0,0,19.2134094238281,0,0,0,0,-91.8061904907227,0,0,0,0,18.7545471191406,0,0,0,28.8500213623047,0,0,18.1623001098633,0,0,27.8667526245117,0,0,-100.452056884766,0,0,0,0,27.2132720947266,0,0,0,0,19.7366561889648,0,0,26.9487457275391,0,17.572868347168,0,-92.0608596801758,0,17.9013748168945,0,27.8017807006836,0,18.753776550293,0,0,0,28.391731262207,0,8.19584655761719,0,0,-82.6198196411133,0,18.9516372680664,0,0,29.1129608154297,0,18.8188400268555,0,15.7349243164062,0,0,-89.1754379272461,0,0,27.0117645263672,0,18.9469833374023,0,0,0,0,30.944206237793,0,12.2604370117188,0,0,-82.4746551513672,0,19.6027145385742,0,30.1576461791992,0,0,18.161735534668,0,0,0,0,14.5542984008789,0,0,-84.8358154296875,0,30.2241744995117,0,20.2593307495117,0,0,30.8787689208984,0,-98.6700439453125,0,0,0,29.8302459716797,0,19.0129852294922,0,0,29.7651443481445,0,19.8650283813477,0,-89.163330078125,0,19.9304504394531,0,28.1909484863281,0,0,0,0,19.667610168457,0,25.0441284179688,0,0,-95.7167053222656,0,0,29.8953704833984,0,0,19.8644638061523,0,0,0,0,0,29.3055267333984,0,16.6520004272461,0,0,-89.7058258056641,0,0,0,0,20.3236541748047,0,0,0,26.3552398681641,0,17.111213684082,0,0,0,0,25.9616088867188,0,0,-100.240852355957,0,0,0,27.0760726928711,0,17.8328323364258,0,0,0,0,21.5969848632812,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpVuw8PJ/file366037d52886.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq       mean      median
#>         compute_pi0(m)    788.821    803.6975    826.326    822.9685
#>    compute_pi0(m * 10)   7899.065   7960.0585   8059.160   8027.8565
#>   compute_pi0(m * 100)  78865.641  79779.7605  80936.931  80333.5565
#>         compute_pi1(m)    169.325    202.0595   9218.398    330.8700
#>    compute_pi1(m * 10)   1396.028   1452.2760   1966.162   1495.8505
#>   compute_pi1(m * 100)  14834.948  15245.9075  21508.717  16353.5865
#>  compute_pi1(m * 1000) 308132.483 482228.3605 475649.939 488186.8250
#>           uq        max neval
#>     838.9000    894.541    20
#>    8150.0520   8342.589    20
#>   81400.6115  87014.418    20
#>     359.7315 169329.582    20
#>    1598.0650  10324.581    20
#>   29164.6575  33956.198    20
#>  499680.4790 659762.042    20
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
#>              expr        min         lq      mean     median         uq
#>   memory_copy1(n) 5550.25645 4370.97574 561.18164 3973.74371 3185.99414
#>   memory_copy2(n)   94.25975   75.80372  10.72685   68.67119   54.65449
#>  pre_allocate1(n)   19.11840   15.22052   3.34191   13.74237   10.87638
#>  pre_allocate2(n)  183.12246  149.62478  20.19388  137.82654  112.90342
#>     vectorized(n)    1.00000    1.00000   1.00000    1.00000    1.00000
#>        max neval
#>  85.020835    10
#>   2.671651    10
#>   1.908686    10
#>   3.803148    10
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
#>    expr      min       lq     mean   median      uq      max neval
#>  f1(df) 341.8988 334.8092 100.4246 341.3566 72.2781 40.58383     5
#>  f2(df)   1.0000   1.0000   1.0000   1.0000  1.0000  1.00000     5
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
