
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
#>    id          a           b        c        d
#> 1   1  1.9765616 -0.05532882 4.243014 4.343046
#> 2   2 -0.6778489  0.44661875 2.047138 3.658961
#> 3   3  0.0468318  3.05426259 3.712646 1.656477
#> 4   4  0.9323369  1.77832716 1.988702 3.825575
#> 5   5  0.1923185  1.08502984 4.199279 2.703942
#> 6   6 -0.6633869  0.61261131 3.787499 2.735733
#> 7   7  1.0636966  3.30119548 1.082582 4.776752
#> 8   8 -0.6590706  2.83805330 3.998151 2.685439
#> 9   9  1.3587425  3.76514330 2.632233 3.870589
#> 10 10  2.4630484  2.82151863 3.943700 4.148602
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.603323
mean(df$b)
#> [1] 1.964743
mean(df$c)
#> [1] 3.163494
mean(df$d)
#> [1] 3.440511
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.603323 1.964743 3.163494 3.440511
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
#> [1] 0.603323 1.964743 3.163494 3.440511
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
#> [1] 5.500000 0.603323 1.964743 3.163494 3.440511
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
#> [1] 5.5000000 0.5623277 2.2999229 3.7500724 3.7422677
col_describe(df, mean)
#> [1] 5.500000 0.603323 1.964743 3.163494 3.440511
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
#>       id        a        b        c        d 
#> 5.500000 0.603323 1.964743 3.163494 3.440511
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
#>   3.946   0.124   4.072
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.022   0.004   0.689
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
#>  12.945   0.964  10.033
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
#>   0.119   0.000   0.119
plyr_st
#>    user  system elapsed 
#>   4.229   0.008   4.240
est_l_st
#>    user  system elapsed 
#>  69.058   1.188  70.283
est_r_st
#>    user  system elapsed 
#>   0.395   0.008   0.403
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

<!--html_preserve--><div id="htmlwidget-aa43a2b87fabea1c565e" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-aa43a2b87fabea1c565e">{"x":{"message":{"prof":{"time":[1,1,2,2,2,2,3,3,4,4,5,5,5,6,6,7,7,8,8,8,9,9,9,9,9,10,10,10,11,11,12,12,13,13,14,14,14,14,15,15,16,16,16,16,17,17,18,18,18,19,19,19,20,20,20,21,21,22,22,22,22,22,22,23,23,23,24,24,25,25,26,26,27,27,28,28,28,29,29,30,30,31,31,32,32,33,33,34,34,35,35,35,36,36,37,37,37,38,38,38,38,38,39,39,40,40,41,41,42,42,42,43,43,43,43,44,44,44,44,45,45,46,46,47,47,47,47,47,48,48,49,49,50,50,51,51,51,52,52,52,52,53,53,53,54,54,54,54,54,54,55,55,55,56,56,56,56,57,57,58,58,58,59,60,60,60,61,61,61,62,62,62,63,63,63,64,64,64,64,64,65,65,65,66,66,67,67,67,67,67,68,68,68,68,69,69,69,70,70,70,71,71,72,72,73,73,73,73,74,74,74,75,75,75,75,75,76,76,76,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,90,90,91,91,92,92,92,92,93,93,93,94,94,95,95,95,96,96,96,97,97,97,97,97,97,98,98,99,99,99,100,100,100,101,101,102,102,102,103,103,104,104,104,105,105,106,106,107,107,108,108,108,109,109,109,109,109,110,110,110,110,110,111,111,111,111,111,112,112,112,112,112,113,113,114,114,115,115,115,116,116,117,117,118,118,118,118,118,119,119,119,119,120,120,120,121,121,121,121,121,122,122,122,123,123,124,124,125,125,125,126,126,127,127,128,128,128,129,129,129,129,129,130,130,131,131,131,131,131,132,132,132,133,133,133,134,134,134,135,135,136,136,137,137,137,138,138,139,139,139,140,140,140,140,140,141,141,142,142,142,142,142,142,143,143,144,144,144,144,144,145,145,146,146,146,146,146,147,147,147,148,148,148,149,149,150,150,150,150,150,151,151,151,152,152,153,153,154,154,155,155,155,155,155,156,156,156,156,157,157,158,158,158,158,159,159,159,159,160,160,160,161,161,161,161,161,162,162,163,163,164,164,165,165,166,166,167,167,168,168,168,168,168,169,169,169,170,170,171,171,172,172,172,173,173,173,174,174,175,175,176,176,176,177,177,178,178,178,179,179,180,180,181,181,181,181,181,182,182,183,183,184,184,184,184,184,184,185,185,185,185,185,185,186,186,186,186,186,187,187,187,187,187,188,188,188,188,188,189,189,190,190,191,191,191,192,192,193,193,194,194,194,195,195,195,195,195,195,196,196,196,196,196,197,197,198,198,198,199,199,200,200,200,201,201,202,202,203,203,204,204,204,205,205,206,206,207,207,207,208,208,208,209,209,209,209,209,209,210,210,211,211,212,212,213,213,213,213,214,214,215,215,215,216,216,216,216,216,217,217,218,218,218,218,218,218,219,219,220,220,221,221,222,222,222,223,223,224,224,225,225,226,226,227,227,228,228,229,229,229,229,229,229,230,230,231,231,232,232,233,233,234,234,235,235,235,236,236,237,237,237,237,238,238,239,239,240,240,241,241,242,242,242,243,243,243,243,244,244,244,245,245,246,246,246,246,246,247,247,248,248,249,249,250,250,250,250,250,251,251,251,252,252,252,253,253,254,254,255,255,255,255,255,256,256,256,257,257,257,258,258,258,258,259,259,259,260,260,261,261,261,262,262,262,262,263,263,264,264,264,265,265,266,266,267,267,268,268,268,268,268,268,269,269,269,269,269,269,270,270,270,271,271,271,272,272,272,272,272,273,273,274,274,274,275,275,275,276,276,277,277,278,278,279,279,279,279,279,279,280,280,281,281,281,281,281,282,282,282,282,282],"depth":[2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","<GC>","[.data.frame","[","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","length","length","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,null,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,null,1,1,1,null,null,null,null,1,null,null,null,null,1],"linenum":[9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,10,10,9,9,9,9,null,9,9,null,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,10,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,null,11,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,null,11,9,9,null,null,null,null,13,null,null,null,null,13],"memalloc":[60.5991592407227,60.5991592407227,80.1450500488281,80.1450500488281,80.1450500488281,80.1450500488281,107.042457580566,107.042457580566,123.96728515625,123.96728515625,146.268661499023,146.268661499023,146.268661499023,54.5687026977539,54.5687026977539,85.6674575805664,85.6674575805664,105.54704284668,105.54704284668,105.54704284668,135.786109924316,135.786109924316,135.786109924316,135.786109924316,135.786109924316,146.279945373535,146.279945373535,146.279945373535,69.5921173095703,69.5921173095703,90.3883285522461,90.3883285522461,119.848937988281,119.848937988281,139.599235534668,139.599235534668,139.599235534668,139.599235534668,53.45166015625,53.45166015625,73.9181518554688,73.9181518554688,73.9181518554688,73.9181518554688,104.417251586914,104.417251586914,124.357902526855,124.357902526855,124.357902526855,146.267562866211,146.267562866211,146.267562866211,57.5301742553711,57.5301742553711,57.5301742553711,89.0823593139648,89.0823593139648,109.812217712402,109.812217712402,109.812217712402,109.812217712402,109.812217712402,109.812217712402,141.297439575195,141.297439575195,141.297439575195,44.1436386108398,44.1436386108398,75.0425262451172,75.0425262451172,96.1651763916016,96.1651763916016,128.050582885742,128.050582885742,146.287406921387,146.287406921387,146.287406921387,63.0410842895508,63.0410842895508,83.8313751220703,83.8313751220703,113.685607910156,113.685607910156,132.450553894043,132.450553894043,46.246696472168,46.246696472168,66.8474349975586,66.8474349975586,98.2771301269531,98.2771301269531,98.2771301269531,118.613876342773,118.613876342773,146.300857543945,146.300857543945,146.300857543945,52.4153594970703,52.4153594970703,52.4153594970703,52.4153594970703,52.4153594970703,83.5808181762695,83.5808181762695,103.793632507324,103.793632507324,133.842567443848,133.842567443848,146.303291320801,146.303291320801,146.303291320801,66.9243087768555,66.9243087768555,66.9243087768555,66.9243087768555,87.9093399047852,87.9093399047852,87.9093399047852,87.9093399047852,119.733039855957,119.733039855957,141.18473815918,141.18473815918,55.3736190795898,55.3736190795898,55.3736190795898,55.3736190795898,55.3736190795898,75.7748260498047,75.7748260498047,106.475654602051,106.475654602051,126.224304199219,126.224304199219,146.299942016602,146.299942016602,146.299942016602,60.2299499511719,60.2299499511719,60.2299499511719,60.2299499511719,92.1086349487305,92.1086349487305,92.1086349487305,112.310668945312,112.310668945312,112.310668945312,112.310668945312,112.310668945312,112.310668945312,142.484176635742,142.484176635742,142.484176635742,45.7991561889648,45.7991561889648,45.7991561889648,45.7991561889648,77.1629333496094,77.1629333496094,98.2160110473633,98.2160110473633,98.2160110473633,128.069931030273,146.30793762207,146.30793762207,146.30793762207,62.8522720336914,62.8522720336914,62.8522720336914,83.8456039428711,83.8456039428711,83.8456039428711,113.836891174316,113.836891174316,113.836891174316,133.649429321289,133.649429321289,133.649429321289,133.649429321289,133.649429321289,47.5724411010742,47.5724411010742,47.5724411010742,68.1102752685547,68.1102752685547,99.9316024780273,99.9316024780273,99.9316024780273,99.9316024780273,99.9316024780273,121.572090148926,121.572090148926,121.572090148926,121.572090148926,146.304214477539,146.304214477539,146.304214477539,57.0847778320312,57.0847778320312,57.0847778320312,88.7802886962891,88.7802886962891,109.116157531738,109.116157531738,139.358345031738,139.358345031738,139.358345031738,139.358345031738,84.5904006958008,84.5904006958008,84.5904006958008,75.2541275024414,75.2541275024414,75.2541275024414,75.2541275024414,75.2541275024414,96.508186340332,96.508186340332,96.508186340332,128.782440185547,128.782440185547,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,42.7237854003906,42.7237854003906,42.7237854003906,60.9015808105469,60.9015808105469,60.9015808105469,82.3500823974609,82.3500823974609,82.3500823974609,82.3500823974609,82.3500823974609,114.098266601562,114.098266601562,134.832855224609,134.832855224609,134.832855224609,134.832855224609,50.0080871582031,50.0080871582031,50.0080871582031,70.3454895019531,70.3454895019531,101.96231842041,101.96231842041,101.96231842041,121.903678894043,121.903678894043,121.903678894043,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,55.3222274780273,55.3222274780273,86.6806716918945,86.6806716918945,86.6806716918945,106.164375305176,106.164375305176,106.164375305176,136.069023132324,136.069023132324,146.301681518555,146.301681518555,146.301681518555,71.2651596069336,71.2651596069336,91.9295806884766,91.9295806884766,91.9295806884766,124.201690673828,124.201690673828,145.393218994141,145.393218994141,60.6393203735352,60.6393203735352,81.4962539672852,81.4962539672852,81.4962539672852,111.73747253418,111.73747253418,111.73747253418,111.73747253418,111.73747253418,132.204010009766,132.204010009766,132.204010009766,132.204010009766,132.204010009766,47.7831726074219,47.7831726074219,47.7831726074219,47.7831726074219,47.7831726074219,68.3169555664062,68.3169555664062,68.3169555664062,68.3169555664062,68.3169555664062,99.5374145507812,99.5374145507812,119.41576385498,119.41576385498,146.31201171875,146.31201171875,146.31201171875,53.6864318847656,53.6864318847656,84.3871383666992,84.3871383666992,105.178215026855,105.178215026855,105.178215026855,105.178215026855,105.178215026855,136.662712097168,136.662712097168,136.662712097168,136.662712097168,128.498100280762,128.498100280762,128.498100280762,72.9710464477539,72.9710464477539,72.9710464477539,72.9710464477539,72.9710464477539,93.1127624511719,93.1127624511719,93.1127624511719,122.900695800781,122.900695800781,141.924308776855,141.924308776855,57.5643692016602,57.5643692016602,57.5643692016602,77.7718963623047,77.7718963623047,109.397422790527,109.397422790527,130.259407043457,130.259407043457,130.259407043457,46.4113311767578,46.4113311767578,46.4113311767578,46.4113311767578,46.4113311767578,67.4017181396484,67.4017181396484,99.0217742919922,99.0217742919922,99.0217742919922,99.0217742919922,99.0217742919922,117.979385375977,117.979385375977,117.979385375977,146.256484985352,146.256484985352,146.256484985352,55.1386337280273,55.1386337280273,55.1386337280273,85.9746246337891,85.9746246337891,106.970649719238,106.970649719238,138.40096282959,138.40096282959,138.40096282959,44.6439971923828,44.6439971923828,75.1578063964844,75.1578063964844,75.1578063964844,95.8805465698242,95.8805465698242,95.8805465698242,95.8805465698242,95.8805465698242,125.990600585938,125.990600585938,144.890914916992,144.890914916992,144.890914916992,144.890914916992,144.890914916992,144.890914916992,60.3206634521484,60.3206634521484,80.4707412719727,80.4707412719727,80.4707412719727,80.4707412719727,80.4707412719727,112.212440490723,112.212440490723,133.075248718262,133.075248718262,133.075248718262,133.075248718262,133.075248718262,49.2444076538086,49.2444076538086,49.2444076538086,69.7127456665039,69.7127456665039,69.7127456665039,100.741630554199,100.741630554199,120.161819458008,120.161819458008,120.161819458008,120.161819458008,120.161819458008,146.271453857422,146.271453857422,146.271453857422,55.469841003418,55.469841003418,86.8245239257812,86.8245239257812,107.81315612793,107.81315612793,139.430725097656,139.430725097656,139.430725097656,139.430725097656,139.430725097656,45.5689468383789,45.5689468383789,45.5689468383789,45.5689468383789,76.0052642822266,76.0052642822266,96.6045761108398,96.6045761108398,96.6045761108398,96.6045761108398,126.910377502441,126.910377502441,126.910377502441,126.910377502441,146.261047363281,146.261047363281,146.261047363281,62.2337951660156,62.2337951660156,62.2337951660156,62.2337951660156,62.2337951660156,82.5802230834961,82.5802230834961,113.607841491699,113.607841491699,134.340156555176,134.340156555176,50.949333190918,50.949333190918,71.4105834960938,71.4105834960938,101.644165039062,101.644165039062,121.256042480469,121.256042480469,121.256042480469,121.256042480469,121.256042480469,146.315643310547,146.315643310547,146.315643310547,57.0464782714844,57.0464782714844,88.5262298583984,88.5262298583984,109.911598205566,109.911598205566,109.911598205566,141.397102355957,141.397102355957,141.397102355957,47.7381134033203,47.7381134033203,79.0252990722656,79.0252990722656,100.472091674805,100.472091674805,100.472091674805,132.152366638184,132.152366638184,146.253807067871,146.253807067871,146.253807067871,69.7751922607422,69.7751922607422,91.0908966064453,91.0908966064453,122.968620300293,122.968620300293,122.968620300293,122.968620300293,122.968620300293,142.120246887207,142.120246887207,57.0888671875,57.0888671875,78.2722091674805,78.2722091674805,78.2722091674805,78.2722091674805,78.2722091674805,78.2722091674805,110.471382141113,110.471382141113,110.471382141113,110.471382141113,110.471382141113,110.471382141113,130.604553222656,130.604553222656,130.604553222656,130.604553222656,130.604553222656,44.7606048583984,44.7606048583984,44.7606048583984,44.7606048583984,44.7606048583984,65.4207763671875,65.4207763671875,65.4207763671875,65.4207763671875,65.4207763671875,97.8232955932617,97.8232955932617,119.201889038086,119.201889038086,146.286460876465,146.286460876465,146.286460876465,56.1058120727539,56.1058120727539,87.7845306396484,87.7845306396484,109.363174438477,109.363174438477,109.363174438477,141.110298156738,141.110298156738,141.110298156738,141.110298156738,141.110298156738,141.110298156738,45.9416732788086,45.9416732788086,45.9416732788086,45.9416732788086,45.9416732788086,77.7496337890625,77.7496337890625,99.1973266601562,99.1973266601562,99.1973266601562,128.121757507324,128.121757507324,146.285858154297,146.285858154297,146.285858154297,63.5200729370117,63.5200729370117,83.9165573120117,83.9165573120117,115.463912963867,115.463912963867,135.991661071777,135.991661071777,135.991661071777,52.0417633056641,52.0417633056641,73.4228820800781,73.4228820800781,105.165145874023,105.165145874023,105.165145874023,126.416130065918,126.416130065918,126.416130065918,135.75318145752,135.75318145752,135.75318145752,135.75318145752,135.75318145752,135.75318145752,62.9276275634766,62.9276275634766,94.3432388305664,94.3432388305664,114.4169921875,114.4169921875,144.51969909668,144.51969909668,144.51969909668,144.51969909668,49.6842346191406,49.6842346191406,81.4875335693359,81.4875335693359,81.4875335693359,102.272430419922,102.272430419922,102.272430419922,102.272430419922,102.272430419922,134.926719665527,134.926719665527,146.270874023438,146.270874023438,146.270874023438,146.270874023438,146.270874023438,146.270874023438,72.4390869140625,72.4390869140625,93.8164215087891,93.8164215087891,126.272850036621,126.272850036621,146.273597717285,146.273597717285,146.273597717285,63.32470703125,63.32470703125,84.6348724365234,84.6348724365234,115.256225585938,115.256225585938,135.584533691406,135.584533691406,51.589958190918,51.589958190918,72.6399154663086,72.6399154663086,105.098770141602,105.098770141602,105.098770141602,105.098770141602,105.098770141602,105.098770141602,126.542236328125,126.542236328125,43.524040222168,43.524040222168,61.8191909790039,61.8191909790039,94.1454544067383,94.1454544067383,115.585876464844,115.585876464844,146.272071838379,146.272071838379,146.272071838379,53.4932250976562,53.4932250976562,85.0987319946289,85.0987319946289,85.0987319946289,85.0987319946289,106.670196533203,106.670196533203,138.40648651123,138.40648651123,44.7057723999023,44.7057723999023,76.1801910400391,76.1801910400391,97.0321350097656,97.0321350097656,97.0321350097656,127.194564819336,127.194564819336,127.194564819336,127.194564819336,146.275207519531,146.275207519531,146.275207519531,64.7048263549805,64.7048263549805,85.951042175293,85.951042175293,85.951042175293,85.951042175293,85.951042175293,118.277160644531,118.277160644531,139.783226013184,139.783226013184,56.9017333984375,56.9017333984375,77.8162994384766,77.8162994384766,77.8162994384766,77.8162994384766,77.8162994384766,110.59659576416,110.59659576416,110.59659576416,132.362312316895,132.362312316895,132.362312316895,49.4945220947266,49.4945220947266,70.7366104125977,70.7366104125977,103.254844665527,103.254844665527,103.254844665527,103.254844665527,103.254844665527,124.562850952148,124.562850952148,124.562850952148,146.263450622559,146.263450622559,146.263450622559,63.3949890136719,63.3949890136719,63.3949890136719,63.3949890136719,96.1099700927734,96.1099700927734,96.1099700927734,117.811225891113,117.811225891113,146.264587402344,146.264587402344,146.264587402344,56.511100769043,56.511100769043,56.511100769043,56.511100769043,88.5705108642578,88.5705108642578,110.205917358398,110.205917358398,110.205917358398,142.13451385498,142.13451385498,49.0378646850586,49.0378646850586,81.4242477416992,81.4242477416992,103.124778747559,103.124778747559,103.124778747559,103.124778747559,103.124778747559,103.124778747559,136.167053222656,136.167053222656,136.167053222656,136.167053222656,136.167053222656,136.167053222656,78.1280670166016,78.1280670166016,78.1280670166016,75.6559371948242,75.6559371948242,75.6559371948242,97.2904815673828,97.2904815673828,97.2904815673828,97.2904815673828,97.2904815673828,129.284042358398,129.284042358398,146.263786315918,146.263786315918,146.263786315918,66.5226898193359,66.5226898193359,66.5226898193359,88.1571426391602,88.1571426391602,120.93726348877,120.93726348877,142.572212219238,142.572212219238,58.9178237915039,58.9178237915039,58.9178237915039,58.9178237915039,58.9178237915039,58.9178237915039,80.4871826171875,80.4871826171875,112.493385314941,112.493385314941,112.493385314941,112.493385314941,112.493385314941,112.508522033691,112.508522033691,112.508522033691,112.508522033691,112.508522033691],"meminc":[0,0,19.5458908081055,0,0,0,26.8974075317383,0,16.9248275756836,0,22.3013763427734,0,0,-91.6999588012695,0,31.0987548828125,0,19.8795852661133,0,0,30.2390670776367,0,0,0,0,10.4938354492188,0,0,-76.6878280639648,0,20.7962112426758,0,29.4606094360352,0,19.7502975463867,0,0,0,-86.147575378418,0,20.4664916992188,0,0,0,30.4990997314453,0,19.9406509399414,0,0,21.9096603393555,0,0,-88.7373886108398,0,0,31.5521850585938,0,20.7298583984375,0,0,0,0,0,31.485221862793,0,0,-97.1538009643555,0,30.8988876342773,0,21.1226501464844,0,31.8854064941406,0,18.2368240356445,0,0,-83.2463226318359,0,20.7902908325195,0,29.8542327880859,0,18.7649459838867,0,-86.203857421875,0,20.6007385253906,0,31.4296951293945,0,0,20.3367462158203,0,27.6869812011719,0,0,-93.885498046875,0,0,0,0,31.1654586791992,0,20.2128143310547,0,30.0489349365234,0,12.4607238769531,0,0,-79.3789825439453,0,0,0,20.9850311279297,0,0,0,31.8236999511719,0,21.4516983032227,0,-85.8111190795898,0,0,0,0,20.4012069702148,0,30.7008285522461,0,19.748649597168,0,20.0756378173828,0,0,-86.0699920654297,0,0,0,31.8786849975586,0,0,20.202033996582,0,0,0,0,0,30.1735076904297,0,0,-96.6850204467773,0,0,0,31.3637771606445,0,21.0530776977539,0,0,29.8539199829102,18.2380065917969,0,0,-83.4556655883789,0,0,20.9933319091797,0,0,29.9912872314453,0,0,19.8125381469727,0,0,0,0,-86.0769882202148,0,0,20.5378341674805,0,31.8213272094727,0,0,0,0,21.6404876708984,0,0,0,24.7321243286133,0,0,-89.2194366455078,0,0,31.6955108642578,0,20.3358688354492,0,30.2421875,0,0,0,-54.7679443359375,0,0,-9.33627319335938,0,0,0,0,21.2540588378906,0,0,32.2742538452148,0,17.5127563476562,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,18.1777954101562,0,0,21.4485015869141,0,0,0,0,31.7481842041016,0,20.7345886230469,0,0,0,-84.8247680664062,0,0,20.33740234375,0,31.616828918457,0,0,19.9413604736328,0,0,24.4052886962891,0,0,0,0,0,-90.9867401123047,0,31.3584442138672,0,0,19.4837036132812,0,0,29.9046478271484,0,10.2326583862305,0,0,-75.0365219116211,0,20.664421081543,0,0,32.2721099853516,0,21.1915283203125,0,-84.7538986206055,0,20.85693359375,0,0,30.2412185668945,0,0,0,0,20.4665374755859,0,0,0,0,-84.4208374023438,0,0,0,0,20.5337829589844,0,0,0,0,31.220458984375,0,19.8783493041992,0,26.8962478637695,0,0,-92.6255798339844,0,30.7007064819336,0,20.7910766601562,0,0,0,0,31.4844970703125,0,0,0,-8.16461181640625,0,0,-55.5270538330078,0,0,0,0,20.141716003418,0,0,29.7879333496094,0,19.0236129760742,0,-84.3599395751953,0,0,20.2075271606445,0,31.6255264282227,0,20.8619842529297,0,0,-83.8480758666992,0,0,0,0,20.9903869628906,0,31.6200561523438,0,0,0,0,18.9576110839844,0,0,28.277099609375,0,0,-91.1178512573242,0,0,30.8359909057617,0,20.9960250854492,0,31.4303131103516,0,0,-93.756965637207,0,30.5138092041016,0,0,20.7227401733398,0,0,0,0,30.1100540161133,0,18.9003143310547,0,0,0,0,0,-84.5702514648438,0,20.1500778198242,0,0,0,0,31.74169921875,0,20.8628082275391,0,0,0,0,-83.8308410644531,0,0,20.4683380126953,0,0,31.0288848876953,0,19.4201889038086,0,0,0,0,26.1096343994141,0,0,-90.8016128540039,0,31.3546829223633,0,20.9886322021484,0,31.6175689697266,0,0,0,0,-93.8617782592773,0,0,0,30.4363174438477,0,20.5993118286133,0,0,0,30.3058013916016,0,0,0,19.3506698608398,0,0,-84.0272521972656,0,0,0,0,20.3464279174805,0,31.0276184082031,0,20.7323150634766,0,-83.3908233642578,0,20.4612503051758,0,30.2335815429688,0,19.6118774414062,0,0,0,0,25.0596008300781,0,0,-89.2691650390625,0,31.4797515869141,0,21.385368347168,0,0,31.4855041503906,0,0,-93.6589889526367,0,31.2871856689453,0,21.4467926025391,0,0,31.6802749633789,0,14.1014404296875,0,0,-76.4786148071289,0,21.3157043457031,0,31.8777236938477,0,0,0,0,19.1516265869141,0,-85.031379699707,0,21.1833419799805,0,0,0,0,0,32.1991729736328,0,0,0,0,0,20.133171081543,0,0,0,0,-85.8439483642578,0,0,0,0,20.6601715087891,0,0,0,0,32.4025192260742,0,21.3785934448242,0,27.0845718383789,0,0,-90.1806488037109,0,31.6787185668945,0,21.5786437988281,0,0,31.7471237182617,0,0,0,0,0,-95.1686248779297,0,0,0,0,31.8079605102539,0,21.4476928710938,0,0,28.924430847168,0,18.1641006469727,0,0,-82.7657852172852,0,20.396484375,0,31.5473556518555,0,20.5277481079102,0,0,-83.9498977661133,0,21.3811187744141,0,31.7422637939453,0,0,21.2509841918945,0,0,9.33705139160156,0,0,0,0,0,-72.825553894043,0,31.4156112670898,0,20.0737533569336,0,30.1027069091797,0,0,0,-94.8354644775391,0,31.8032989501953,0,0,20.7848968505859,0,0,0,0,32.6542892456055,0,11.3441543579102,0,0,0,0,0,-73.831787109375,0,21.3773345947266,0,32.456428527832,0,20.0007476806641,0,0,-82.9488906860352,0,21.3101654052734,0,30.6213531494141,0,20.3283081054688,0,-83.9945755004883,0,21.0499572753906,0,32.458854675293,0,0,0,0,0,21.4434661865234,0,-83.018196105957,0,18.2951507568359,0,32.3262634277344,0,21.4404220581055,0,30.6861953735352,0,0,-92.7788467407227,0,31.6055068969727,0,0,0,21.5714645385742,0,31.7362899780273,0,-93.7007141113281,0,31.4744186401367,0,20.8519439697266,0,0,30.1624298095703,0,0,0,19.0806427001953,0,0,-81.5703811645508,0,21.2462158203125,0,0,0,0,32.3261184692383,0,21.5060653686523,0,-82.8814926147461,0,20.9145660400391,0,0,0,0,32.7802963256836,0,0,21.7657165527344,0,0,-82.867790222168,0,21.2420883178711,0,32.5182342529297,0,0,0,0,21.3080062866211,0,0,21.7005996704102,0,0,-82.8684616088867,0,0,0,32.7149810791016,0,0,21.7012557983398,0,28.4533615112305,0,0,-89.7534866333008,0,0,0,32.0594100952148,0,21.6354064941406,0,0,31.928596496582,0,-93.0966491699219,0,32.3863830566406,0,21.7005310058594,0,0,0,0,0,33.0422744750977,0,0,0,0,0,-58.0389862060547,0,0,-2.47212982177734,0,0,21.6345443725586,0,0,0,0,31.9935607910156,0,16.9797439575195,0,0,-79.741096496582,0,0,21.6344528198242,0,32.7801208496094,0,21.6349487304688,0,-83.6543884277344,0,0,0,0,0,21.5693588256836,0,32.0062026977539,0,0,0,0,0.01513671875,0,0,0,0],"filename":["<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpP0tkw8/file3a574a8386e1.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    785.644    790.6285    826.2282    808.2910
#>    compute_pi0(m * 10)   7891.136   7956.8105   8372.4122   7983.2035
#>   compute_pi0(m * 100)  78640.046  79072.8215  79333.6110  79167.0330
#>         compute_pi1(m)    164.740    232.0000    672.2962    290.2585
#>    compute_pi1(m * 10)   1268.434   1395.1425   1499.6157   1415.5220
#>   compute_pi1(m * 100)  13070.487  14694.8715  27891.2734  18095.5790
#>  compute_pi1(m * 1000) 269308.717 343942.4390 389682.7949 377932.5965
#>           uq        max neval
#>     818.4800   1021.103    20
#>    8218.4705  13999.033    20
#>   79555.6690  81807.140    20
#>     329.6025   8239.470    20
#>    1603.2070   2439.019    20
#>   26048.2560 181635.069    20
#>  463247.7995 487039.526    20
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
#>   memory_copy1(n) 3829.73316 3696.87233 532.055752 3667.82307 2881.58105
#>   memory_copy2(n)   68.34251   65.38468  10.113216   61.70506   47.31803
#>  pre_allocate1(n)   14.60932   13.64594   3.404717   13.13879   10.01158
#>  pre_allocate2(n)  140.61121  132.00099  19.655060  124.46376   99.11878
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  78.816295    10
#>   2.525362    10
#>   2.004581    10
#>   3.955580    10
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
#>  f1(df) 256.9822 256.1757 97.75672 255.1643 95.24192 45.02341     5
#>  f2(df)   1.0000   1.0000  1.00000   1.0000  1.00000  1.00000     5
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
