
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
#> 1   1  0.24419308 2.6661297 2.456787 3.592285
#> 2   2  0.05680516 2.9725526 4.506592 4.493967
#> 3   3 -0.15716419 3.3694220 3.899465 2.829560
#> 4   4 -1.39553423 4.0417818 1.968298 3.735882
#> 5   5 -0.51036930 2.0831897 3.172187 3.973892
#> 6   6  0.92723329 3.8297482 3.281759 3.920636
#> 7   7  1.41591596 0.9077938 4.172105 5.532247
#> 8   8 -1.00729925 2.7220106 3.232441 3.459956
#> 9   9 -0.74212797 1.9620590 2.319968 5.575188
#> 10 10  0.15811042 3.5841889 3.120108 4.515694
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.1010237
mean(df$b)
#> [1] 2.813888
mean(df$c)
#> [1] 3.212971
mean(df$d)
#> [1] 4.162931
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.1010237  2.8138876  3.2129710  4.1629307
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
#> [1] -0.1010237  2.8138876  3.2129710  4.1629307
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
#> [1]  5.5000000 -0.1010237  2.8138876  3.2129710  4.1629307
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
#> [1]  5.50000000 -0.05017952  2.84728162  3.20231398  3.94726366
col_describe(df, mean)
#> [1]  5.5000000 -0.1010237  2.8138876  3.2129710  4.1629307
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
#>  5.5000000 -0.1010237  2.8138876  3.2129710  4.1629307
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
#>   3.872   0.136   4.008
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.021   0.000   0.605
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
#>  12.849   0.964   9.933
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
#>   0.113   0.004   0.117
plyr_st
#>    user  system elapsed 
#>   4.085   0.000   4.085
est_l_st
#>    user  system elapsed 
#>  62.619   1.947  64.569
est_r_st
#>    user  system elapsed 
#>   0.391   0.008   0.400
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

<!--html_preserve--><div id="htmlwidget-e0fb70d495b7764b1d43" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-e0fb70d495b7764b1d43">{"x":{"message":{"prof":{"time":[1,1,2,2,2,2,3,3,4,4,5,5,5,6,6,7,7,8,8,8,9,9,9,9,9,10,10,10,10,10,10,11,11,12,12,12,13,13,14,14,14,14,14,15,15,16,16,17,17,18,18,19,19,19,19,19,20,20,21,21,22,22,23,23,23,24,24,25,25,25,26,26,27,27,28,28,28,29,29,29,30,30,31,31,32,32,32,33,33,33,34,34,34,34,35,35,36,36,37,37,37,38,38,38,39,39,40,40,41,41,41,41,41,42,42,42,42,42,42,43,43,43,43,44,44,45,45,46,46,46,47,47,48,48,48,49,49,49,49,49,50,50,50,50,51,51,52,52,52,52,52,53,53,53,53,54,54,55,55,55,56,56,57,57,58,58,59,59,60,60,60,61,61,62,62,63,63,63,63,63,64,64,64,64,65,65,66,66,66,67,67,68,68,69,69,69,70,70,71,71,72,72,73,73,74,74,74,75,75,75,76,76,76,76,76,76,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,90,90,90,90,90,91,91,92,92,93,93,94,94,94,95,95,95,96,96,96,96,96,97,97,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,104,104,104,105,105,105,106,106,106,106,107,107,108,108,109,109,110,110,110,110,110,111,111,111,112,112,112,112,112,112,113,113,114,114,115,115,115,116,116,117,117,118,118,118,119,119,120,120,120,121,121,122,122,123,123,123,124,124,125,125,126,126,126,127,127,127,128,128,128,128,128,129,129,130,130,131,131,131,131,132,132,132,132,133,133,133,134,134,134,134,134,134,135,135,135,135,135,136,136,137,137,138,138,138,139,139,140,140,141,141,142,142,142,143,143,143,143,143,144,144,145,145,146,146,146,147,147,147,148,148,149,149,149,149,149,150,150,151,151,151,152,152,152,153,153,153,153,153,154,154,155,155,155,156,156,156,157,157,157,157,158,158,159,159,160,160,161,161,162,162,162,162,162,163,163,163,163,163,163,164,164,164,165,165,166,166,167,167,168,168,169,169,170,170,171,171,171,172,172,172,172,172,173,173,174,174,174,174,174,175,175,176,176,176,176,176,176,177,177,177,178,178,179,179,179,179,179,180,180,180,181,181,182,182,183,183,184,184,184,184,184,184,185,185,186,186,186,187,187,187,187,187,188,188,189,189,190,190,190,191,191,191,191,191,192,192,193,193,193,193,193,193,194,194,194,194,194,194,195,195,195,196,196,196,196,196,197,197,197,198,198,199,199,199,200,200,201,201,201,201,202,202,203,203,204,204,204,205,205,205,205,206,206,207,207,207,207,207,208,208,209,209,209,209,209,210,210,211,211,211,212,212,212,212,213,213,214,214,214,215,215,216,216,217,217,217,218,218,219,219,219,220,220,220,220,220,221,221,221,221,222,222,223,223,224,224,224,225,225,225,225,225,226,226,226,227,227,227,227,227,227,228,228,228,228,229,229,229,229,229,230,230,231,231,232,232,232,232,232,232,233,233,233,234,234,235,235,236,236,236,236,236,237,237,237,237,237,238,238,238,239,239,239,240,240,241,241,242,242,242,243,243,243,244,244,244,244,244,245,245,246,246,247,247,247,248,248,248,249,249,249,249,250,250,250,251,251,252,252,252,253,253,253,254,254,255,255,256,256,256,257,257,258,258,258,259,259,259,259,259,260,260,261,261,261,262,262,263,263,264,264,265,265,265,266,266,267,267,267,267,268,268,269,269,270,270,271,271,272,272,273,273,273,274,274,274,275,275,276,276,276,277,277,277,277,277,277,278,278,279,279,279,279,279,280,280,280,281,281,281,281,281,282,282,282,282,282],"depth":[2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","length","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","length","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","dim","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","$","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,null,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1],"linenum":[9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,null,11,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,13],"memalloc":[62.3391952514648,62.3391952514648,83.1959686279297,83.1959686279297,83.1959686279297,83.1959686279297,110.356620788574,110.356620788574,128.329177856445,128.329177856445,146.301498413086,146.301498413086,146.301498413086,59.7848510742188,59.7848510742188,91.3398971557617,91.3398971557617,111.025215148926,111.025215148926,111.025215148926,140.477478027344,140.477478027344,140.477478027344,140.477478027344,140.477478027344,43.8444900512695,43.8444900512695,43.8444900512695,43.8444900512695,43.8444900512695,43.8444900512695,75.3968276977539,75.3968276977539,95.6705856323242,95.6705856323242,95.6705856323242,125.853073120117,125.853073120117,145.79598236084,145.79598236084,145.79598236084,145.79598236084,145.79598236084,60.3713531494141,60.3713531494141,81.7597198486328,81.7597198486328,111.927925109863,111.927925109863,132.195640563965,132.195640563965,45.4230651855469,45.4230651855469,45.4230651855469,45.4230651855469,45.4230651855469,66.4160232543945,66.4160232543945,97.3809661865234,97.3809661865234,118.767196655273,118.767196655273,146.315391540527,146.315391540527,146.315391540527,53.5602188110352,53.5602188110352,85.2436676025391,85.2436676025391,85.2436676025391,106.298301696777,106.298301696777,138.447547912598,138.447547912598,113.987327575684,113.987327575684,113.987327575684,73.6349487304688,73.6349487304688,73.6349487304688,94.3022232055664,94.3022232055664,124.610305786133,124.610305786133,144.4912109375,144.4912109375,144.4912109375,58.9399566650391,58.9399566650391,58.9399566650391,79.6099166870117,79.6099166870117,79.6099166870117,79.6099166870117,110.775604248047,110.775604248047,130.588745117188,130.588745117188,44.3152847290039,44.3152847290039,44.3152847290039,64.7813949584961,64.7813949584961,64.7813949584961,96.1475524902344,96.1475524902344,115.764205932617,115.764205932617,145.417831420898,145.417831420898,145.417831420898,145.417831420898,145.417831420898,49.8931427001953,49.8931427001953,49.8931427001953,49.8931427001953,49.8931427001953,49.8931427001953,80.5332489013672,80.5332489013672,80.5332489013672,80.5332489013672,101.392517089844,101.392517089844,130.063232421875,130.063232421875,146.333572387695,146.333572387695,146.333572387695,63.9306106567383,63.9306106567383,84.5995025634766,84.5995025634766,84.5995025634766,114.773551940918,114.773551940918,114.773551940918,114.773551940918,114.773551940918,134.720184326172,134.720184326172,134.720184326172,134.720184326172,48.516960144043,48.516960144043,68.8577575683594,68.8577575683594,68.8577575683594,68.8577575683594,68.8577575683594,100.27367401123,100.27367401123,100.27367401123,100.27367401123,120.475616455078,120.475616455078,146.322937011719,146.322937011719,146.322937011719,53.8365631103516,53.8365631103516,84.0174865722656,84.0174865722656,103.764717102051,103.764717102051,133.547607421875,133.547607421875,146.275161743164,146.275161743164,146.275161743164,67.7411117553711,67.7411117553711,88.4036712646484,88.4036712646484,119.11743927002,119.11743927002,119.11743927002,119.11743927002,119.11743927002,139.780250549316,139.780250549316,139.780250549316,139.780250549316,54.3637313842773,54.3637313842773,75.03173828125,75.03173828125,75.03173828125,104.423782348633,104.423782348633,124.098571777344,124.098571777344,146.271377563477,146.271377563477,146.271377563477,56.7894973754883,56.7894973754883,87.4336166381836,87.4336166381836,108.294738769531,108.294738769531,139.259986877441,139.259986877441,89.6629867553711,89.6629867553711,89.6629867553711,74.7623138427734,74.7623138427734,74.7623138427734,95.2950210571289,95.2950210571289,95.2950210571289,95.2950210571289,95.2950210571289,95.2950210571289,127.241912841797,127.241912841797,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,146.328033447266,42.7565460205078,42.7565460205078,42.7565460205078,54.5032730102539,54.5032730102539,75.493408203125,75.493408203125,75.493408203125,75.493408203125,75.493408203125,107.046363830566,107.046363830566,128.168960571289,128.168960571289,44.0694046020508,44.0694046020508,64.6076812744141,64.6076812744141,64.6076812744141,94.7141342163086,94.7141342163086,94.7141342163086,114.65860748291,114.65860748291,114.65860748291,114.65860748291,114.65860748291,144.830917358398,144.830917358398,49.7802276611328,49.7802276611328,80.8758010864258,80.8758010864258,80.8758010864258,101.410568237305,101.410568237305,101.410568237305,131.250953674316,131.250953674316,131.250953674316,146.270332336426,146.270332336426,146.270332336426,67.1672973632812,67.1672973632812,87.7631607055664,87.7631607055664,87.7631607055664,117.677780151367,117.677780151367,117.677780151367,136.833587646484,136.833587646484,136.833587646484,136.833587646484,49.9149932861328,49.9149932861328,70.7097015380859,70.7097015380859,101.138221740723,101.138221740723,122.463768005371,122.463768005371,122.463768005371,122.463768005371,122.463768005371,146.274101257324,146.274101257324,146.274101257324,59.7576065063477,59.7576065063477,59.7576065063477,59.7576065063477,59.7576065063477,59.7576065063477,91.1096267700195,91.1096267700195,112.3671875,112.3671875,144.246757507324,144.246757507324,144.246757507324,50.1779708862305,50.1779708862305,80.9453353881836,80.9453353881836,101.929656982422,101.929656982422,101.929656982422,132.038162231445,132.038162231445,146.334190368652,146.334190368652,146.334190368652,67.8900527954102,67.8900527954102,89.0783004760742,89.0783004760742,120.637603759766,120.637603759766,120.637603759766,141.826690673828,141.826690673828,57.859260559082,57.859260559082,78.7233581542969,78.7233581542969,78.7233581542969,110.283187866211,110.283187866211,110.283187866211,131.34156036377,131.34156036377,131.34156036377,131.34156036377,131.34156036377,47.7570037841797,47.7570037841797,68.1572418212891,68.1572418212891,99.9084625244141,99.9084625244141,99.9084625244141,99.9084625244141,120.047508239746,120.047508239746,120.047508239746,120.047508239746,146.290557861328,146.290557861328,146.290557861328,56.0231628417969,56.0231628417969,56.0231628417969,56.0231628417969,56.0231628417969,56.0231628417969,87.6462326049805,87.6462326049805,87.6462326049805,87.6462326049805,87.6462326049805,108.642112731934,108.642112731934,138.826370239258,138.826370239258,44.4139862060547,44.4139862060547,44.4139862060547,74.8617935180664,74.8617935180664,96.3055191040039,96.3055191040039,126.678291320801,126.678291320801,146.300735473633,146.300735473633,146.300735473633,61.7974472045898,61.7974472045898,61.7974472045898,61.7974472045898,61.7974472045898,82.2091674804688,82.2091674804688,112.376724243164,112.376724243164,133.76407623291,133.76407623291,133.76407623291,50.1944427490234,50.1944427490234,50.1944427490234,71.1225967407227,71.1225967407227,103.201705932617,103.201705932617,103.201705932617,103.201705932617,103.201705932617,124.326316833496,124.326316833496,146.303840637207,146.303840637207,146.303840637207,62.5201950073242,62.5201950073242,62.5201950073242,94.0040740966797,94.0040740966797,94.0040740966797,94.0040740966797,94.0040740966797,115.454116821289,115.454116821289,146.284660339355,146.284660339355,146.284660339355,54.1244583129883,54.1244583129883,54.1244583129883,85.8784103393555,85.8784103393555,85.8784103393555,85.8784103393555,106.934295654297,106.934295654297,139.142921447754,139.142921447754,45.7985992431641,45.7985992431641,76.9689483642578,76.9689483642578,97.4392547607422,97.4392547607422,97.4392547607422,97.4392547607422,97.4392547607422,129.385368347168,129.385368347168,129.385368347168,129.385368347168,129.385368347168,129.385368347168,146.308898925781,146.308898925781,146.308898925781,66.9858551025391,66.9858551025391,88.4297409057617,88.4297409057617,120.306060791016,120.306060791016,139.920288085938,139.920288085938,56.6207733154297,56.6207733154297,77.5414886474609,77.5414886474609,109.092704772949,109.092704772949,109.092704772949,129.951362609863,129.951362609863,129.951362609863,129.951362609863,129.951362609863,46.9844512939453,46.9844512939453,67.1887893676758,67.1887893676758,67.1887893676758,67.1887893676758,67.1887893676758,99.1298599243164,99.1298599243164,120.313903808594,120.313903808594,120.313903808594,120.313903808594,120.313903808594,120.313903808594,146.287864685059,146.287864685059,146.287864685059,58.7910919189453,58.7910919189453,90.0757446289062,90.0757446289062,90.0757446289062,90.0757446289062,90.0757446289062,111.067253112793,111.067253112793,111.067253112793,141.761100769043,141.761100769043,46.3640747070312,46.3640747070312,77.5186157226562,77.5186157226562,97.7822341918945,97.7822341918945,97.7822341918945,97.7822341918945,97.7822341918945,97.7822341918945,128.473167419434,128.473167419434,146.313179016113,146.313179016113,146.313179016113,63.0905151367188,63.0905151367188,63.0905151367188,63.0905151367188,63.0905151367188,83.6889495849609,83.6889495849609,115.495559692383,115.495559692383,136.808540344238,136.808540344238,136.808540344238,52.531494140625,52.531494140625,52.531494140625,52.531494140625,52.531494140625,73.7151641845703,73.7151641845703,105.722808837891,105.722808837891,105.722808837891,105.722808837891,105.722808837891,105.722808837891,127.037879943848,127.037879943848,127.037879943848,127.037879943848,127.037879943848,127.037879943848,81.394172668457,81.394172668457,81.394172668457,62.5000686645508,62.5000686645508,62.5000686645508,62.5000686645508,62.5000686645508,93.7213897705078,93.7213897705078,93.7213897705078,115.101982116699,115.101982116699,146.318656921387,146.318656921387,146.318656921387,51.9435729980469,51.9435729980469,83.2924575805664,83.2924575805664,83.2924575805664,83.2924575805664,104.215156555176,104.215156555176,135.039772033691,135.039772033691,146.321594238281,146.321594238281,146.321594238281,71.1598663330078,71.1598663330078,71.1598663330078,71.1598663330078,91.5544891357422,91.5544891357422,123.364318847656,123.364318847656,123.364318847656,123.364318847656,123.364318847656,144.485496520996,144.485496520996,59.8134613037109,59.8134613037109,59.8134613037109,59.8134613037109,59.8134613037109,80.9319534301758,80.9319534301758,112.940902709961,112.940902709961,112.940902709961,134.192169189453,134.192169189453,134.192169189453,134.192169189453,48.9942016601562,48.9942016601562,68.141357421875,68.141357421875,68.141357421875,99.2874450683594,99.2874450683594,120.206115722656,120.206115722656,146.301628112793,146.301628112793,146.301628112793,57.5872268676758,57.5872268676758,89.4557495117188,89.4557495117188,89.4557495117188,110.503196716309,110.503196716309,110.503196716309,110.503196716309,110.503196716309,142.502166748047,142.502166748047,142.502166748047,142.502166748047,47.8142929077148,47.8142929077148,78.7642974853516,78.7642974853516,99.8129043579102,99.8129043579102,99.8129043579102,132.33634185791,132.33634185791,132.33634185791,132.33634185791,132.33634185791,146.303802490234,146.303802490234,146.303802490234,69.4579544067383,69.4579544067383,69.4579544067383,69.4579544067383,69.4579544067383,69.4579544067383,90.5719528198242,90.5719528198242,90.5719528198242,90.5719528198242,122.836250305176,122.836250305176,122.836250305176,122.836250305176,122.836250305176,144.278533935547,144.278533935547,60.8663330078125,60.8663330078125,81.19384765625,81.19384765625,81.19384765625,81.19384765625,81.19384765625,81.19384765625,112.863662719727,112.863662719727,112.863662719727,134.369667053223,134.369667053223,50.9659957885742,50.9659957885742,71.8831024169922,71.8831024169922,71.8831024169922,71.8831024169922,71.8831024169922,103.225799560547,103.225799560547,103.225799560547,103.225799560547,103.225799560547,124.994186401367,124.994186401367,124.994186401367,146.304801940918,146.304801940918,146.304801940918,62.5726852416992,62.5726852416992,94.3743438720703,94.3743438720703,115.161254882812,115.161254882812,115.161254882812,146.305885314941,146.305885314941,146.305885314941,52.8026580810547,52.8026580810547,52.8026580810547,52.8026580810547,52.8026580810547,83.2936325073242,83.2936325073242,104.407012939453,104.407012939453,136.797927856445,136.797927856445,136.797927856445,115.084533691406,115.084533691406,115.084533691406,73.9783706665039,73.9783706665039,73.9783706665039,73.9783706665039,93.9083557128906,93.9083557128906,93.9083557128906,125.31184387207,125.31184387207,146.029769897461,146.029769897461,146.029769897461,62.4404907226562,62.4404907226562,62.4404907226562,83.4201278686523,83.4201278686523,115.347862243652,115.347862243652,136.394180297852,136.394180297852,136.394180297852,52.737434387207,52.737434387207,73.3249893188477,73.3249893188477,73.3249893188477,105.056579589844,105.056579589844,105.056579589844,105.056579589844,105.056579589844,126.560836791992,126.560836791992,50.9322967529297,50.9322967529297,50.9322967529297,63.9498901367188,63.9498901367188,95.8121719360352,95.8121719360352,116.661041259766,116.661041259766,146.294898986816,146.294898986816,146.294898986816,53.7879791259766,53.7879791259766,84.5359573364258,84.5359573364258,84.5359573364258,84.5359573364258,104.793975830078,104.793975830078,137.50804901123,137.50804901123,44.4790802001953,44.4790802001953,75.8168182373047,75.8168182373047,96.5337066650391,96.5337066650391,128.39624786377,128.39624786377,128.39624786377,146.294090270996,146.294090270996,146.294090270996,63.4735946655273,63.4735946655273,84.6497192382812,84.6497192382812,84.6497192382812,116.708488464355,116.708488464355,116.708488464355,116.708488464355,116.708488464355,116.708488464355,138.212272644043,138.212272644043,54.1647109985352,54.1647109985352,54.1647109985352,54.1647109985352,54.1647109985352,75.6029357910156,75.6029357910156,75.6029357910156,105.69507598877,105.69507598877,105.69507598877,105.69507598877,105.69507598877,113.393257141113,113.393257141113,113.393257141113,113.393257141113,113.393257141113],"meminc":[0,0,20.8567733764648,0,0,0,27.1606521606445,0,17.9725570678711,0,17.9723205566406,0,0,-86.5166473388672,0,31.555046081543,0,19.6853179931641,0,0,29.452262878418,0,0,0,0,-96.6329879760742,0,0,0,0,0,31.5523376464844,0,20.2737579345703,0,0,30.182487487793,0,19.9429092407227,0,0,0,0,-85.4246292114258,0,21.3883666992188,0,30.1682052612305,0,20.2677154541016,0,-86.772575378418,0,0,0,0,20.9929580688477,0,30.9649429321289,0,21.38623046875,0,27.5481948852539,0,0,-92.7551727294922,0,31.6834487915039,0,0,21.0546340942383,0,32.1492462158203,0,-24.4602203369141,0,0,-40.3523788452148,0,0,20.6672744750977,0,30.3080825805664,0,19.8809051513672,0,0,-85.5512542724609,0,0,20.6699600219727,0,0,0,31.1656875610352,0,19.8131408691406,0,-86.2734603881836,0,0,20.4661102294922,0,0,31.3661575317383,0,19.6166534423828,0,29.6536254882812,0,0,0,0,-95.5246887207031,0,0,0,0,0,30.6401062011719,0,0,0,20.8592681884766,0,28.6707153320312,0,16.2703399658203,0,0,-82.402961730957,0,20.6688919067383,0,0,30.1740493774414,0,0,0,0,19.9466323852539,0,0,0,-86.2032241821289,0,20.3407974243164,0,0,0,0,31.4159164428711,0,0,0,20.2019424438477,0,25.8473205566406,0,0,-92.4863739013672,0,30.1809234619141,0,19.7472305297852,0,29.7828903198242,0,12.7275543212891,0,0,-78.534049987793,0,20.6625595092773,0,30.7137680053711,0,0,0,0,20.6628112792969,0,0,0,-85.4165191650391,0,20.6680068969727,0,0,29.3920440673828,0,19.6747894287109,0,22.1728057861328,0,0,-89.4818801879883,0,30.6441192626953,0,20.8611221313477,0,30.9652481079102,0,-49.5970001220703,0,0,-14.9006729125977,0,0,20.5327072143555,0,0,0,0,0,31.946891784668,0,19.0861206054688,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,11.7467269897461,0,20.9901351928711,0,0,0,0,31.5529556274414,0,21.1225967407227,0,-84.0995559692383,0,20.5382766723633,0,0,30.1064529418945,0,0,19.9444732666016,0,0,0,0,30.1723098754883,0,-95.0506896972656,0,31.095573425293,0,0,20.5347671508789,0,0,29.8403854370117,0,0,15.0193786621094,0,0,-79.1030349731445,0,20.5958633422852,0,0,29.9146194458008,0,0,19.1558074951172,0,0,0,-86.9185943603516,0,20.7947082519531,0,30.4285202026367,0,21.3255462646484,0,0,0,0,23.8103332519531,0,0,-86.5164947509766,0,0,0,0,0,31.3520202636719,0,21.2575607299805,0,31.8795700073242,0,0,-94.0687866210938,0,30.7673645019531,0,20.9843215942383,0,0,30.1085052490234,0,14.296028137207,0,0,-78.4441375732422,0,21.1882476806641,0,31.5593032836914,0,0,21.1890869140625,0,-83.9674301147461,0,20.8640975952148,0,0,31.5598297119141,0,0,21.0583724975586,0,0,0,0,-83.5845565795898,0,20.4002380371094,0,31.751220703125,0,0,0,20.139045715332,0,0,0,26.243049621582,0,0,-90.2673950195312,0,0,0,0,0,31.6230697631836,0,0,0,0,20.9958801269531,0,30.1842575073242,0,-94.4123840332031,0,0,30.4478073120117,0,21.4437255859375,0,30.3727722167969,0,19.622444152832,0,0,-84.503288269043,0,0,0,0,20.4117202758789,0,30.1675567626953,0,21.3873519897461,0,0,-83.5696334838867,0,0,20.9281539916992,0,32.0791091918945,0,0,0,0,21.1246109008789,0,21.9775238037109,0,0,-83.7836456298828,0,0,31.4838790893555,0,0,0,0,21.4500427246094,0,30.8305435180664,0,0,-92.1602020263672,0,0,31.7539520263672,0,0,0,21.0558853149414,0,32.208625793457,0,-93.3443222045898,0,31.1703491210938,0,20.4703063964844,0,0,0,0,31.9461135864258,0,0,0,0,0,16.9235305786133,0,0,-79.3230438232422,0,21.4438858032227,0,31.8763198852539,0,19.6142272949219,0,-83.2995147705078,0,20.9207153320312,0,31.5512161254883,0,0,20.8586578369141,0,0,0,0,-82.966911315918,0,20.2043380737305,0,0,0,0,31.9410705566406,0,21.1840438842773,0,0,0,0,0,25.9739608764648,0,0,-87.4967727661133,0,31.2846527099609,0,0,0,0,20.9915084838867,0,0,30.69384765625,0,-95.3970260620117,0,31.154541015625,0,20.2636184692383,0,0,0,0,0,30.6909332275391,0,17.8400115966797,0,0,-83.2226638793945,0,0,0,0,20.5984344482422,0,31.8066101074219,0,21.3129806518555,0,0,-84.2770462036133,0,0,0,0,21.1836700439453,0,32.0076446533203,0,0,0,0,0,21.315071105957,0,0,0,0,0,-45.6437072753906,0,0,-18.8941040039062,0,0,0,0,31.221321105957,0,0,21.3805923461914,0,31.2166748046875,0,0,-94.3750839233398,0,31.3488845825195,0,0,0,20.9226989746094,0,30.8246154785156,0,11.2818222045898,0,0,-75.1617279052734,0,0,0,20.3946228027344,0,31.8098297119141,0,0,0,0,21.1211776733398,0,-84.6720352172852,0,0,0,0,21.1184921264648,0,32.0089492797852,0,0,21.2512664794922,0,0,0,-85.1979675292969,0,19.1471557617188,0,0,31.1460876464844,0,20.9186706542969,0,26.0955123901367,0,0,-88.7144012451172,0,31.868522644043,0,0,21.0474472045898,0,0,0,0,31.9989700317383,0,0,0,-94.687873840332,0,30.9500045776367,0,21.0486068725586,0,0,32.5234375,0,0,0,0,13.9674606323242,0,0,-76.8458480834961,0,0,0,0,0,21.1139984130859,0,0,0,32.2642974853516,0,0,0,0,21.4422836303711,0,-83.4122009277344,0,20.3275146484375,0,0,0,0,0,31.6698150634766,0,0,21.5060043334961,0,-83.4036712646484,0,20.917106628418,0,0,0,0,31.3426971435547,0,0,0,0,21.7683868408203,0,0,21.3106155395508,0,0,-83.7321166992188,0,31.8016586303711,0,20.7869110107422,0,0,31.1446304321289,0,0,-93.5032272338867,0,0,0,0,30.4909744262695,0,21.1133804321289,0,32.3909149169922,0,0,-21.7133941650391,0,0,-41.1061630249023,0,0,0,19.9299850463867,0,0,31.4034881591797,0,20.7179260253906,0,0,-83.5892791748047,0,0,20.9796371459961,0,31.927734375,0,21.0463180541992,0,0,-83.6567459106445,0,20.5875549316406,0,0,31.7315902709961,0,0,0,0,21.5042572021484,0,-75.6285400390625,0,0,13.0175933837891,0,31.8622817993164,0,20.8488693237305,0,29.6338577270508,0,0,-92.5069198608398,0,30.7479782104492,0,0,0,20.2580184936523,0,32.7140731811523,0,-93.0289688110352,0,31.3377380371094,0,20.7168884277344,0,31.8625411987305,0,0,17.8978424072266,0,0,-82.8204956054688,0,21.1761245727539,0,0,32.0587692260742,0,0,0,0,0,21.5037841796875,0,-84.0475616455078,0,0,0,0,21.4382247924805,0,0,30.0921401977539,0,0,0,0,7.69818115234375,0,0,0,0],"filename":["<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpfFeReF/file3c887a7cf24f.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    786.559    797.3535   1118.126    810.2990
#>    compute_pi0(m * 10)   7882.606   7914.9795   7996.436   7984.3300
#>   compute_pi0(m * 100)  78692.202  79090.3900  79426.600  79369.7440
#>         compute_pi1(m)    160.655    183.4975    238.029    258.0765
#>    compute_pi1(m * 10)   1273.109   1382.2500   1523.247   1431.8860
#>   compute_pi1(m * 100)  13136.530  13971.5545  24605.343  20350.2255
#>  compute_pi1(m * 1000) 253971.325 369143.6840 371711.349 378968.2900
#>           uq        max neval
#>     824.8200   6947.915    20
#>    8024.8540   8336.242    20
#>   79642.6780  80320.046    20
#>     284.1455    299.057    20
#>    1454.9935   2473.243    20
#>   21218.8625 132978.408    20
#>  383558.4505 485098.566    20
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
#>   memory_copy1(n) 5291.25285 3722.88144 638.697759 3617.35250 3324.33463
#>   memory_copy2(n)   93.59814   65.20896  13.422013   64.74231   61.08126
#>  pre_allocate1(n)   19.99766   13.83465   3.692785   13.55344   12.56719
#>  pre_allocate2(n)  195.41262  135.99626  22.848522  131.19501  121.74779
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  116.001653    10
#>    3.421329    10
#>    2.037836    10
#>    4.449640    10
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
#>  f1(df) 256.7074 251.0921 79.48427 250.8163 67.55984 28.36135     5
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
