
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
#>    id           a          b         c        d
#> 1   1 -0.84075088  1.5285510 4.0131652 4.671490
#> 2   2 -0.13921357  1.7425520 1.2569548 3.323422
#> 3   3  1.69379853  0.5998878 4.4812152 3.157229
#> 4   4  0.14403668 -0.8479200 2.0929375 3.105535
#> 5   5 -0.11493377  3.9486342 3.8736413 4.300345
#> 6   6  0.34627373  1.4668974 2.2866705 4.720987
#> 7   7  1.61653254  1.2077759 1.9046027 3.633604
#> 8   8 -0.11141808  1.1408666 3.5645730 2.806016
#> 9   9 -0.04844395  4.9817663 0.4607869 4.413572
#> 10 10 -1.29210349  3.1522896 2.6926060 6.195225
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.1253778
mean(df$b)
#> [1] 1.89213
mean(df$c)
#> [1] 2.662715
mean(df$d)
#> [1] 4.032743
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.1253778 1.8921301 2.6627153 4.0327426
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
#> [1] 0.1253778 1.8921301 2.6627153 4.0327426
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
#> [1] 5.5000000 0.1253778 1.8921301 2.6627153 4.0327426
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
#> [1]  5.50000000 -0.07993102  1.49772420  2.48963820  3.96697460
col_describe(df, mean)
#> [1] 5.5000000 0.1253778 1.8921301 2.6627153 4.0327426
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
#> 5.5000000 0.1253778 1.8921301 2.6627153 4.0327426
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
#>   3.083   0.105   3.187
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.001   0.509
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
#>  10.435   0.636   8.006
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
#>   0.095   0.000   0.096
plyr_st
#>    user  system elapsed 
#>   3.372   0.000   3.372
est_l_st
#>    user  system elapsed 
#>  50.716   1.616  52.334
est_r_st
#>    user  system elapsed 
#>   0.330   0.004   0.333
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

<!--html_preserve--><div id="htmlwidget-4a74cac6a7fc1c4e1de2" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-4a74cac6a7fc1c4e1de2">{"x":{"message":{"prof":{"time":[1,1,1,1,1,2,2,3,3,4,4,4,5,5,5,5,6,6,7,7,7,7,7,8,8,9,9,9,9,9,10,10,11,11,11,12,12,12,13,13,13,13,13,14,14,15,15,15,16,16,17,17,17,17,18,18,19,19,19,20,20,20,20,20,21,21,22,22,23,23,23,23,23,23,24,24,25,25,25,26,26,27,27,28,28,28,28,28,29,29,29,29,29,30,30,30,31,31,31,31,31,31,32,32,33,33,33,34,34,34,35,35,36,36,37,37,38,38,39,39,39,39,39,40,40,40,40,40,41,41,41,42,42,43,43,43,43,44,44,45,45,45,46,46,46,47,47,48,48,48,49,49,50,50,51,51,52,52,52,53,53,53,54,54,54,55,55,56,56,57,57,58,58,59,59,59,59,60,60,60,61,61,61,61,61,62,62,63,63,64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,74,74,75,75,76,76,76,76,77,77,78,78,78,79,79,80,80,80,80,80,81,81,81,82,82,82,82,82,83,83,83,84,84,85,85,86,86,86,86,86,86,87,87,87,87,87,87,88,88,88,88,88,89,89,90,90,90,90,91,91,92,92,93,93,94,94,94,94,94,94,95,95,96,96,97,97,98,98,98,99,99,100,100,100,100,100,100,101,101,101,102,102,103,103,104,104,104,105,105,105,106,106,107,107,108,108,108,109,109,110,110,110,111,111,112,112,112,113,113,114,114,114,115,115,116,117,117,117,117,117,118,118,119,119,119,120,120,121,121,122,122,122,123,123,124,124,125,125,126,126,127,127,127,127,128,128,128,128,128,129,129,129,129,129,129,130,130,130,131,131,132,132,132,133,133,134,134,134,135,135,136,136,137,137,137,138,138,139,139,140,140,140,140,140,141,141,141,142,142,143,143,144,144,144,145,145,146,146,146,146,146,146,147,147,147,148,148,149,149,149,149,150,150,151,151,152,152,152,153,153,153,154,154,155,155,155,155,155,156,156,157,157,157,157,157,158,158,159,159,159,160,160,160,161,161,161,161,161,162,162,163,163,163,164,164,164,165,165,166,166,166,167,167,168,168,168,168,168,169,169,170,170,170,171,171,172,172,172,172,173,173,173,173,174,174,175,175,176,176,177,177,177,177,177,177,178,178,179,179,179,180,180,181,181,181,181,181,181,182,182,183,183,184,184,184,185,185,186,186,187,187,188,188,189,189,189,189,190,190,191,191,191,191,191,191,192,192,192,193,193,194,194,194,194,194,195,195,195,195,195,195,196,196,197,197,197,198,198,198,198,199,199,199,199,199,199,200,200,201,201,201,201,202,202,203,203,204,204,205,205,205,206,206,206,206,207,207,208,208,208,208,208,208,209,209,210,210,210,211,211,212,212,213,213,214,214,214,215,215,216,216,216,217,217,218,218,219,219,219,219,219,220,220,221,221,222,222,223,223,224,224,224,224,224,225,225,226,226,226,227,227,228,228,229,229,229,229,229],"depth":[5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1],"label":["<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","nrow","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","length","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,null,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1],"linenum":[null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,null,11,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,11,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,11,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,10,10,null,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,13],"memalloc":[73.5014114379883,73.5014114379883,73.5014114379883,73.5014114379883,73.5014114379883,97.1173477172852,97.1173477172852,130.835494995117,130.835494995117,146.315101623535,146.315101623535,146.315101623535,75.0190582275391,75.0190582275391,75.0190582275391,75.0190582275391,99.9497604370117,99.9497604370117,137.406661987305,137.406661987305,137.406661987305,137.406661987305,137.406661987305,44.5135040283203,44.5135040283203,82.6930999755859,82.6930999755859,82.6930999755859,82.6930999755859,82.6930999755859,106.905349731445,106.905349731445,144.103744506836,144.103744506836,144.103744506836,51.9907302856445,51.9907302856445,51.9907302856445,91.6746368408203,91.6746368408203,91.6746368408203,91.6746368408203,91.6746368408203,116.402374267578,116.402374267578,146.314002990723,146.314002990723,146.314002990723,57.2477874755859,57.2477874755859,95.6245651245117,95.6245651245117,95.6245651245117,95.6245651245117,121.66593170166,121.66593170166,43.4036712646484,43.4036712646484,43.4036712646484,68.2006988525391,68.2006988525391,68.2006988525391,68.2006988525391,68.2006988525391,107.75609588623,107.75609588623,134.001571655273,134.001571655273,55.3436508178711,55.3436508178711,55.3436508178711,55.3436508178711,55.3436508178711,55.3436508178711,81.2544174194336,81.2544174194336,119.309005737305,119.309005737305,119.309005737305,143.453910827637,143.453910827637,65.2521591186523,65.2521591186523,90.5182266235352,90.5182266235352,90.5182266235352,90.5182266235352,90.5182266235352,126.995582580566,126.995582580566,126.995582580566,126.995582580566,126.995582580566,146.281585693359,146.281585693359,146.281585693359,71.1588592529297,71.1588592529297,71.1588592529297,71.1588592529297,71.1588592529297,71.1588592529297,95.3085861206055,95.3085861206055,131.066818237305,131.066818237305,131.066818237305,146.284149169922,146.284149169922,146.284149169922,76.2824325561523,76.2824325561523,101.668296813965,101.668296813965,138.147026062012,138.147026062012,45.3793869018555,45.3793869018555,84.0241012573242,84.0241012573242,84.0241012573242,84.0241012573242,84.0241012573242,108.753303527832,108.753303527832,108.753303527832,108.753303527832,108.753303527832,146.215675354004,146.215675354004,146.215675354004,53.8459777832031,53.8459777832031,91.630989074707,91.630989074707,91.630989074707,91.630989074707,116.02938079834,116.02938079834,146.337142944336,146.337142944336,146.337142944336,60.8088073730469,60.8088073730469,60.8088073730469,100.100547790527,100.100547790527,123.785095214844,123.785095214844,123.785095214844,43.9449615478516,43.9449615478516,68.1487655639648,68.1487655639648,106.270919799805,106.270919799805,130.022178649902,130.022178649902,130.022178649902,51.2928161621094,51.2928161621094,51.2928161621094,76.4882507324219,76.4882507324219,76.4882507324219,115.78231048584,115.78231048584,141.431243896484,141.431243896484,63.1710205078125,63.1710205078125,88.3664627075195,88.3664627075195,125.695434570312,125.695434570312,125.695434570312,125.695434570312,146.292388916016,146.292388916016,146.292388916016,71.8886260986328,71.8886260986328,71.8886260986328,71.8886260986328,71.8886260986328,97.6698608398438,97.6698608398438,136.896682739258,136.896682739258,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,146.276641845703,42.7700729370117,42.7700729370117,42.7700729370117,61.2748641967773,61.2748641967773,86.6617965698242,86.6617965698242,124.24666595459,124.24666595459,146.292320251465,146.292320251465,146.292320251465,146.292320251465,72.6893692016602,72.6893692016602,97.9406890869141,97.9406890869141,97.9406890869141,134.546981811523,134.546981811523,43.6274719238281,43.6274719238281,43.6274719238281,43.6274719238281,43.6274719238281,82.7277679443359,82.7277679443359,82.7277679443359,108.244613647461,108.244613647461,108.244613647461,108.244613647461,108.244613647461,146.284019470215,146.284019470215,146.284019470215,58.0605163574219,58.0605163574219,96.8936462402344,96.8936462402344,122.80574798584,122.80574798584,122.80574798584,122.80574798584,122.80574798584,122.80574798584,46.7770919799805,46.7770919799805,46.7770919799805,46.7770919799805,46.7770919799805,46.7770919799805,72.296989440918,72.296989440918,72.296989440918,72.296989440918,72.296989440918,111.453956604004,111.453956604004,137.30110168457,137.30110168457,137.30110168457,137.30110168457,60.8203735351562,60.8203735351562,86.3352737426758,86.3352737426758,124.843055725098,124.843055725098,146.294128417969,146.294128417969,146.294128417969,146.294128417969,146.294128417969,146.294128417969,74.5963973999023,74.5963973999023,100.828582763672,100.828582763672,140.511978149414,140.511978149414,50.1255950927734,50.1255950927734,50.1255950927734,88.3036499023438,88.3036499023438,114.286773681641,114.286773681641,114.286773681641,114.286773681641,114.286773681641,114.286773681641,146.303977966309,146.303977966309,146.303977966309,63.4496307373047,63.4496307373047,102.489326477051,102.489326477051,128.205154418945,128.205154418945,128.205154418945,51.0500640869141,51.0500640869141,51.0500640869141,76.1772689819336,76.1772689819336,114.744529724121,114.744529724121,138.628051757812,138.628051757812,138.628051757812,61.5478591918945,61.5478591918945,87.1356353759766,87.1356353759766,87.1356353759766,125.126121520996,125.126121520996,146.318176269531,146.318176269531,146.318176269531,72.8391342163086,72.8391342163086,98.2862319946289,98.2862319946289,98.2862319946289,138.176132202148,138.176132202148,49.0213623046875,87.0750274658203,87.0750274658203,87.0750274658203,87.0750274658203,87.0750274658203,111.207740783691,111.207740783691,146.30884552002,146.30884552002,146.30884552002,57.620719909668,57.620719909668,96.8491592407227,96.8491592407227,122.765251159668,122.765251159668,122.765251159668,47.2508926391602,47.2508926391602,73.0269241333008,73.0269241333008,112.777374267578,112.777374267578,138.229965209961,138.229965209961,61.2214736938477,61.2214736938477,61.2214736938477,61.2214736938477,86.2850189208984,86.2850189208984,86.2850189208984,86.2850189208984,86.2850189208984,124.988037109375,124.988037109375,124.988037109375,124.988037109375,124.988037109375,124.988037109375,146.306716918945,146.306716918945,146.306716918945,74.4861068725586,74.4861068725586,98.501823425293,98.501823425293,98.501823425293,134.385162353516,134.385162353516,81.2636184692383,81.2636184692383,81.2636184692383,81.6219177246094,81.6219177246094,107.331657409668,107.331657409668,145.640808105469,145.640808105469,145.640808105469,54.4690856933594,54.4690856933594,93.5586547851562,93.5586547851562,119.076675415039,119.076675415039,119.076675415039,119.076675415039,119.076675415039,99.2388000488281,99.2388000488281,99.2388000488281,68.6446533203125,68.6446533203125,107.144264221191,107.144264221191,131.54328918457,131.54328918457,131.54328918457,54.4762878417969,54.4762878417969,79.9869384765625,79.9869384765625,79.9869384765625,79.9869384765625,79.9869384765625,79.9869384765625,119.081161499023,119.081161499023,119.081161499023,142.889427185059,142.889427185059,64.5452117919922,64.5452117919922,64.5452117919922,64.5452117919922,90.2532653808594,90.2532653808594,129.86360168457,129.86360168457,146.326507568359,146.326507568359,146.326507568359,78.0600204467773,78.0600204467773,78.0600204467773,103.901885986328,103.901885986328,142.85572052002,142.85572052002,142.85572052002,142.85572052002,142.85572052002,52.2833404541016,52.2833404541016,91.7655258178711,91.7655258178711,91.7655258178711,91.7655258178711,91.7655258178711,117.737968444824,117.737968444824,146.336585998535,146.336585998535,146.336585998535,66.9746704101562,66.9746704101562,66.9746704101562,106.918243408203,106.918243408203,106.918243408203,106.918243408203,106.918243408203,132.693664550781,132.693664550781,55.3017578125,55.3017578125,55.3017578125,80.4867401123047,80.4867401123047,80.4867401123047,120.493156433105,120.493156433105,146.334823608398,146.334823608398,146.334823608398,69.9282608032227,69.9282608032227,95.5700149536133,95.5700149536133,95.5700149536133,95.5700149536133,95.5700149536133,133.284706115723,133.284706115723,95.285026550293,95.285026550293,95.285026550293,81.3395690917969,81.3395690917969,106.984298706055,106.984298706055,106.984298706055,106.984298706055,146.337493896484,146.337493896484,146.337493896484,146.337493896484,57.336540222168,57.336540222168,95.6959457397461,95.6959457397461,119.630187988281,119.630187988281,43.5008850097656,43.5008850097656,43.5008850097656,43.5008850097656,43.5008850097656,43.5008850097656,68.5513610839844,68.5513610839844,108.615829467773,108.615829467773,108.615829467773,134.713844299316,134.713844299316,58.1232757568359,58.1232757568359,58.1232757568359,58.1232757568359,58.1232757568359,58.1232757568359,84.3519287109375,84.3519287109375,124.153785705566,124.153785705566,146.318176269531,146.318176269531,146.318176269531,73.7997207641602,73.7997207641602,99.3064498901367,99.3064498901367,139.244125366211,139.244125366211,49.2082824707031,49.2082824707031,88.1589508056641,88.1589508056641,88.1589508056641,88.1589508056641,113.66438293457,113.66438293457,146.31787109375,146.31787109375,146.31787109375,146.31787109375,146.31787109375,146.31787109375,63.8321762084961,63.8321762084961,63.8321762084961,102.584007263184,102.584007263184,128.680648803711,128.680648803711,128.680648803711,128.680648803711,128.680648803711,52.7506866455078,52.7506866455078,52.7506866455078,52.7506866455078,52.7506866455078,52.7506866455078,78.8481292724609,78.8481292724609,118.453575134277,118.453575134277,118.453575134277,144.549743652344,144.549743652344,144.549743652344,144.549743652344,68.1599426269531,68.1599426269531,68.1599426269531,68.1599426269531,68.1599426269531,68.1599426269531,94.3232803344727,94.3232803344727,134.386840820312,134.386840820312,134.386840820312,134.386840820312,45.21142578125,45.21142578125,84.6136627197266,84.6136627197266,110.248176574707,110.248176574707,146.307014465332,146.307014465332,146.307014465332,61.0120849609375,61.0120849609375,61.0120849609375,61.0120849609375,101.135566711426,101.135566711426,127.229583740234,127.229583740234,127.229583740234,127.229583740234,127.229583740234,127.229583740234,51.1782379150391,51.1782379150391,76.6827621459961,76.6827621459961,76.6827621459961,116.085716247559,116.085716247559,142.506240844727,142.506240844727,66.3240814208984,66.3240814208984,92.3517608642578,92.3517608642578,92.3517608642578,131.557640075684,131.557640075684,146.309150695801,146.309150695801,146.309150695801,80.2885894775391,80.2885894775391,105.660255432129,105.660255432129,145.32405090332,145.32405090332,145.32405090332,145.32405090332,145.32405090332,55.7695617675781,55.7695617675781,94.0569610595703,94.0569610595703,120.477264404297,120.477264404297,43.8849868774414,43.8849868774414,69.453254699707,69.453254699707,69.453254699707,69.453254699707,69.453254699707,107.740135192871,107.740135192871,133.636581420898,133.636581420898,133.636581420898,56.8663787841797,56.8663787841797,82.8934326171875,82.8934326171875,113.603469848633,113.603469848633,113.603469848633,113.603469848633,113.603469848633],"meminc":[0,0,0,0,0,23.6159362792969,0,33.718147277832,0,15.479606628418,0,0,-71.2960433959961,0,0,0,24.9307022094727,0,37.456901550293,0,0,0,0,-92.8931579589844,0,38.1795959472656,0,0,0,0,24.2122497558594,0,37.1983947753906,0,0,-92.1130142211914,0,0,39.6839065551758,0,0,0,0,24.7277374267578,0,29.9116287231445,0,0,-89.0662155151367,0,38.3767776489258,0,0,0,26.0413665771484,0,-78.2622604370117,0,0,24.7970275878906,0,0,0,0,39.5553970336914,0,26.245475769043,0,-78.6579208374023,0,0,0,0,0,25.9107666015625,0,38.0545883178711,0,0,24.144905090332,0,-78.2017517089844,0,25.2660675048828,0,0,0,0,36.4773559570312,0,0,0,0,19.286003112793,0,0,-75.1227264404297,0,0,0,0,0,24.1497268676758,0,35.7582321166992,0,0,15.2173309326172,0,0,-70.0017166137695,0,25.3858642578125,0,36.4787292480469,0,-92.7676391601562,0,38.6447143554688,0,0,0,0,24.7292022705078,0,0,0,0,37.4623718261719,0,0,-92.3696975708008,0,37.7850112915039,0,0,0,24.3983917236328,0,30.3077621459961,0,0,-85.5283355712891,0,0,39.2917404174805,0,23.6845474243164,0,0,-79.8401336669922,0,24.2038040161133,0,38.1221542358398,0,23.7512588500977,0,0,-78.729362487793,0,0,25.1954345703125,0,0,39.294059753418,0,25.6489334106445,0,-78.2602233886719,0,25.195442199707,0,37.328971862793,0,0,0,20.5969543457031,0,0,-74.4037628173828,0,0,0,0,25.7812347412109,0,39.2268218994141,0,9.37995910644531,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,18.5047912597656,0,25.3869323730469,0,37.5848693847656,0,22.045654296875,0,0,0,-73.6029510498047,0,25.2513198852539,0,0,36.6062927246094,0,-90.9195098876953,0,0,0,0,39.1002960205078,0,0,25.516845703125,0,0,0,0,38.0394058227539,0,0,-88.223503112793,0,38.8331298828125,0,25.9121017456055,0,0,0,0,0,-76.0286560058594,0,0,0,0,0,25.5198974609375,0,0,0,0,39.1569671630859,0,25.8471450805664,0,0,0,-76.4807281494141,0,25.5149002075195,0,38.5077819824219,0,21.4510726928711,0,0,0,0,0,-71.6977310180664,0,26.2321853637695,0,39.6833953857422,0,-90.3863830566406,0,0,38.1780548095703,0,25.9831237792969,0,0,0,0,0,32.017204284668,0,0,-82.8543472290039,0,39.0396957397461,0,25.7158279418945,0,0,-77.1550903320312,0,0,25.1272048950195,0,38.5672607421875,0,23.8835220336914,0,0,-77.080192565918,0,25.587776184082,0,0,37.9904861450195,0,21.1920547485352,0,0,-73.4790420532227,0,25.4470977783203,0,0,39.8899002075195,0,-89.1547698974609,38.0536651611328,0,0,0,0,24.1327133178711,0,35.1011047363281,0,0,-88.6881256103516,0,39.2284393310547,0,25.9160919189453,0,0,-75.5143585205078,0,25.7760314941406,0,39.7504501342773,0,25.4525909423828,0,-77.0084915161133,0,0,0,25.0635452270508,0,0,0,0,38.7030181884766,0,0,0,0,0,21.3186798095703,0,0,-71.8206100463867,0,24.0157165527344,0,0,35.8833389282227,0,-53.1215438842773,0,0,0.358299255371094,0,25.7097396850586,0,38.3091506958008,0,0,-91.1717224121094,0,39.0895690917969,0,25.5180206298828,0,0,0,0,-19.8378753662109,0,0,-30.5941467285156,0,38.4996109008789,0,24.3990249633789,0,0,-77.0670013427734,0,25.5106506347656,0,0,0,0,0,39.0942230224609,0,0,23.8082656860352,0,-78.3442153930664,0,0,0,25.7080535888672,0,39.6103363037109,0,16.4629058837891,0,0,-68.266487121582,0,0,25.8418655395508,0,38.9538345336914,0,0,0,0,-90.572380065918,0,39.4821853637695,0,0,0,0,25.9724426269531,0,28.5986175537109,0,0,-79.3619155883789,0,0,39.9435729980469,0,0,0,0,25.7754211425781,0,-77.3919067382812,0,0,25.1849822998047,0,0,40.0064163208008,0,25.841667175293,0,0,-76.4065628051758,0,25.6417541503906,0,0,0,0,37.7146911621094,0,-37.9996795654297,0,0,-13.9454574584961,0,25.6447296142578,0,0,0,39.3531951904297,0,0,0,-89.0009536743164,0,38.3594055175781,0,23.9342422485352,0,-76.1293029785156,0,0,0,0,0,25.0504760742188,0,40.0644683837891,0,0,26.098014831543,0,-76.5905685424805,0,0,0,0,0,26.2286529541016,0,39.8018569946289,0,22.1643905639648,0,0,-72.5184555053711,0,25.5067291259766,0,39.9376754760742,0,-90.0358428955078,0,38.9506683349609,0,0,0,25.5054321289062,0,32.6534881591797,0,0,0,0,0,-82.4856948852539,0,0,38.7518310546875,0,26.0966415405273,0,0,0,0,-75.9299621582031,0,0,0,0,0,26.0974426269531,0,39.6054458618164,0,0,26.0961685180664,0,0,0,-76.3898010253906,0,0,0,0,0,26.1633377075195,0,40.0635604858398,0,0,0,-89.1754150390625,0,39.4022369384766,0,25.6345138549805,0,36.058837890625,0,0,-85.2949295043945,0,0,0,40.1234817504883,0,26.0940170288086,0,0,0,0,0,-76.0513458251953,0,25.504524230957,0,0,39.4029541015625,0,26.420524597168,0,-76.1821594238281,0,26.0276794433594,0,0,39.2058792114258,0,14.7515106201172,0,0,-66.0205612182617,0,25.3716659545898,0,39.6637954711914,0,0,0,0,-89.5544891357422,0,38.2873992919922,0,26.4203033447266,0,-76.5922775268555,0,25.5682678222656,0,0,0,0,38.2868804931641,0,25.8964462280273,0,0,-76.7702026367188,0,26.0270538330078,0,30.7100372314453,0,0,0,0],"filename":[null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmppHIZ1x/file3c4d65750059.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq        mean     median         uq
#>         compute_pi0(m)    619.178    629.5470    897.7665    635.379    662.698
#>    compute_pi0(m * 10)   6224.495   6281.0830   6370.6575   6343.914   6370.425
#>   compute_pi0(m * 100)  62526.805  62775.9645  63093.4201  63004.512  63258.553
#>         compute_pi1(m)    130.012    168.8545    201.5549    221.206    239.427
#>    compute_pi1(m * 10)   1097.189   1203.0935   1556.5692   1212.256   1257.102
#>   compute_pi1(m * 100)  10697.262  11236.7720  20215.4424  15767.037  20612.694
#>  compute_pi1(m * 1000) 198928.678 298193.2645 297760.4011 300550.127 306362.919
#>         max neval
#>    5671.463    20
#>    6843.430    20
#>   64390.648    20
#>     250.344    20
#>    7944.257    20
#>  103907.409    20
#>  325785.279    20
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
#>              expr        min        lq       mean     median         uq
#>   memory_copy1(n) 5049.26122 3740.6408 723.864398 3417.52306 3060.69398
#>   memory_copy2(n)   89.16154   67.4174  13.266396   61.67794   55.10083
#>  pre_allocate1(n)   19.12363   14.1981   4.255149   13.04637   11.73429
#>  pre_allocate2(n)  189.09055  138.1138  26.141508  125.57510  117.96583
#>     vectorized(n)    1.00000    1.0000   1.000000    1.00000    1.00000
#>         max neval
#>  136.444531    10
#>    3.271934    10
#>    2.414491    10
#>    4.996785    10
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
#>    expr     min       lq     mean   median     uq      max neval
#>  f1(df) 282.301 280.8956 89.80529 282.2657 63.901 37.48781     5
#>  f2(df)   1.000   1.0000  1.00000   1.0000  1.000  1.00000     5
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
