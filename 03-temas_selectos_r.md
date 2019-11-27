
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
#>    id          a         b        c        d
#> 1   1  0.3612787 2.4293341 2.507944 3.909600
#> 2   2 -0.4806637 3.3721098 4.353338 5.014960
#> 3   3 -0.8846985 3.0396986 3.135359 3.266996
#> 4   4 -1.5948402 2.0896639 2.532486 3.175891
#> 5   5  0.2546178 2.0533773 2.840186 3.189521
#> 6   6 -0.5459508 0.9785084 4.328133 3.483898
#> 7   7  0.3781570 2.1315852 2.578436 4.582246
#> 8   8  0.6694799 2.3508348 3.015562 2.259758
#> 9   9 -0.2358184 1.7352233 2.569199 4.681486
#> 10 10 -1.5209278 1.1932796 4.005951 4.933696
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.3599366
mean(df$b)
#> [1] 2.137361
mean(df$c)
#> [1] 3.186659
mean(df$d)
#> [1] 3.849805
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.3599366  2.1373615  3.1866594  3.8498052
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
#> [1] -0.3599366  2.1373615  3.1866594  3.8498052
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
#> [1]  5.5000000 -0.3599366  2.1373615  3.1866594  3.8498052
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
#> [1]  5.500000 -0.358241  2.110625  2.927874  3.696749
col_describe(df, mean)
#> [1]  5.5000000 -0.3599366  2.1373615  3.1866594  3.8498052
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
#>  5.5000000 -0.3599366  2.1373615  3.1866594  3.8498052
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
#>   3.781   0.128   3.909
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.013   0.012   8.742
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
#>  12.779   0.676   9.673
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
#>   0.109   0.000   0.110
plyr_st
#>    user  system elapsed 
#>   3.965   0.008   3.973
est_l_st
#>    user  system elapsed 
#>  59.928   1.708  61.639
est_r_st
#>    user  system elapsed 
#>   0.382   0.008   0.390
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

<!--html_preserve--><div id="htmlwidget-d37d582f295ddc7b4804" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-d37d582f295ddc7b4804">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,4,4,5,5,5,6,6,6,7,7,8,8,8,9,9,10,10,10,10,10,11,11,11,11,12,12,13,13,14,14,14,14,14,15,15,15,16,16,16,16,16,16,17,17,18,18,18,18,19,19,20,20,20,21,21,21,22,22,23,23,23,24,24,25,25,26,26,26,27,27,28,28,29,29,29,29,30,30,31,31,31,32,32,32,32,32,32,33,33,34,34,34,34,34,35,35,36,36,36,36,36,37,37,37,38,38,38,38,38,39,39,40,40,40,41,41,41,42,42,42,42,42,43,43,44,44,45,45,45,45,46,46,47,47,48,48,49,49,50,50,50,51,51,51,52,52,53,53,54,54,54,55,55,55,56,56,56,56,57,57,58,58,59,59,59,60,60,61,61,62,62,63,63,63,63,63,64,64,65,65,66,66,66,66,66,67,67,67,68,68,68,69,69,70,70,70,70,70,71,71,72,72,73,73,74,74,75,75,76,76,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,89,89,89,90,90,91,91,91,91,92,92,93,93,94,94,95,95,95,95,95,96,96,97,97,98,98,98,98,99,99,100,100,100,101,101,101,102,102,102,102,103,103,103,103,104,104,104,105,105,106,106,107,107,108,108,108,108,109,109,109,109,110,110,110,111,111,112,112,113,113,113,114,114,115,115,115,115,116,116,116,116,116,117,117,117,118,118,119,119,119,120,120,120,121,121,122,122,122,123,123,123,124,124,125,125,125,125,125,125,126,126,126,127,127,128,128,128,129,129,129,130,130,130,131,131,131,131,132,132,132,132,132,133,133,133,133,133,134,134,134,135,135,136,136,136,137,137,137,138,138,139,139,139,140,140,140,140,140,140,141,141,142,142,142,143,143,143,143,143,144,144,145,145,146,146,146,147,147,147,147,147,148,148,148,148,149,149,150,150,150,151,151,151,151,152,152,152,153,153,154,154,154,154,154,155,155,156,156,157,157,158,158,159,159,160,160,161,161,162,162,163,163,164,164,165,165,165,166,166,167,167,167,168,168,169,169,170,170,171,171,172,172,172,173,173,174,174,174,175,175,175,175,175,176,176,177,177,177,177,178,178,178,178,179,179,179,180,180,180,180,181,181,181,182,182,182,182,182,183,183,183,184,184,184,185,185,186,186,187,187,187,188,188,189,189,190,190,191,191,192,192,192,192,192,193,193,193,193,193,194,194,195,195,196,196,196,197,197,197,197,197,198,198,198,198,199,199,199,200,200,200,200,200,201,201,201,202,202,202,202,202,203,203,203,203,203,204,204,205,205,205,206,206,206,207,207,208,208,209,209,209,210,210,210,210,211,211,212,212,212,213,213,214,214,214,214,214,215,215,216,216,216,216,216,217,217,217,218,218,219,219,220,220,220,221,221,222,222,223,223,224,224,225,225,226,226,226,227,227,227,228,228,229,229,230,230,230,230,230,231,231,232,232,233,233,233,233,233,234,234,234,235,235,236,236,236,236,237,237,238,238,239,239,239,239,240,240,240,241,241,242,242,242,242,243,243,243,243,243,244,244,244,245,245,245,245,245,246,246,247,247,247,248,248,249,250,250,250,250,250,251,251,252,252,252,252,252,253,253,253,253,253,253,254,254,255,255,256,256,256,257,257,257,258,258,258,258,259,259,259,260,260,261,261,262,262,262,263,263,264,264,265,265,265,265,265,266,266,266,267,267,268,268,268,268,268,269,269,270,270,270,271,271,272,272,272,273,273,273,274,274,275,275,275,275,275,276,276,277,277,277,277,277,278,278,278,278,278],"depth":[2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,1,5,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","names","%in%","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1],"linenum":[9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,11,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,10,10,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,10,10,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,10,10,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,10,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,13],"memalloc":[59.9908447265625,59.9908447265625,80.3891906738281,80.3891906738281,108.270523071289,108.270523071289,126.179512023926,126.179512023926,146.316024780273,146.316024780273,146.316024780273,58.029182434082,58.029182434082,58.029182434082,89.7144393920898,89.7144393920898,108.74242401123,108.74242401123,108.74242401123,138.851989746094,138.851989746094,43.2684555053711,43.2684555053711,43.2684555053711,43.2684555053711,43.2684555053711,75.0181198120117,75.0181198120117,75.0181198120117,75.0181198120117,96.0128326416016,96.0128326416016,126.064254760742,126.064254760742,145.941604614258,145.941604614258,145.941604614258,145.941604614258,145.941604614258,61.4349594116211,61.4349594116211,61.4349594116211,82.8238143920898,82.8238143920898,82.8238143920898,82.8238143920898,82.8238143920898,82.8238143920898,114.107315063477,114.107315063477,134.505577087402,134.505577087402,134.505577087402,134.505577087402,49.1749572753906,49.1749572753906,70.1703872680664,70.1703872680664,70.1703872680664,101.591697692871,101.591697692871,101.591697692871,122.650482177734,122.650482177734,146.329917907715,146.329917907715,146.329917907715,58.5585556030273,58.5585556030273,91.0296859741211,91.0296859741211,110.446495056152,110.446495056152,110.446495056152,142.660217285156,142.660217285156,46.948371887207,46.948371887207,78.6979598999023,78.6979598999023,78.6979598999023,78.6979598999023,99.4329605102539,99.4329605102539,130.334182739258,130.334182739258,130.334182739258,146.278732299805,146.278732299805,146.278732299805,146.278732299805,146.278732299805,146.278732299805,66.6316299438477,66.6316299438477,87.6321105957031,87.6321105957031,87.6321105957031,87.6321105957031,87.6321105957031,117.94019317627,117.94019317627,138.015106201172,138.015106201172,138.015106201172,138.015106201172,138.015106201172,52.3316192626953,52.3316192626953,52.3316192626953,73.1295776367188,73.1295776367188,73.1295776367188,73.1295776367188,73.1295776367188,104.693893432617,104.693893432617,124.769821166992,124.769821166992,124.769821166992,146.28507232666,146.28507232666,146.28507232666,60.4748611450195,60.4748611450195,60.4748611450195,60.4748611450195,60.4748611450195,93.0053634643555,93.0053634643555,113.218482971191,113.218482971191,143.527938842773,143.527938842773,143.527938842773,143.527938842773,47.8743362426758,47.8743362426758,79.7589645385742,79.7589645385742,100.359031677246,100.359031677246,130.143882751465,130.143882751465,146.282424926758,146.282424926758,146.282424926758,65.7208709716797,65.7208709716797,65.7208709716797,87.1073760986328,87.1073760986328,117.867622375488,117.867622375488,138.133331298828,138.133331298828,138.133331298828,52.9338531494141,52.9338531494141,52.9338531494141,73.6053237915039,73.6053237915039,73.6053237915039,73.6053237915039,105.616958618164,105.616958618164,125.820922851562,125.820922851562,146.29012298584,146.29012298584,146.29012298584,62.0469131469727,62.0469131469727,94.2618560791016,94.2618560791016,114.343696594238,114.343696594238,145.110046386719,145.110046386719,145.110046386719,145.110046386719,145.110046386719,50.3756103515625,50.3756103515625,82.3947601318359,82.3947601318359,103.52108001709,103.52108001709,103.52108001709,103.52108001709,103.52108001709,136.315139770508,136.315139770508,136.315139770508,146.286338806152,146.286338806152,146.286338806152,73.0106964111328,73.0106964111328,93.8817901611328,93.8817901611328,93.8817901611328,93.8817901611328,93.8817901611328,122.808479309082,122.808479309082,141.963119506836,141.963119506836,57.2640609741211,57.2640609741211,78.3182601928711,78.3182601928711,110.597351074219,110.597351074219,130.403938293457,130.403938293457,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,146.277565002441,42.77099609375,42.77099609375,42.77099609375,59.7660064697266,59.7660064697266,59.7660064697266,81.216667175293,81.216667175293,111.652976989746,111.652976989746,111.652976989746,130.415397644043,130.415397644043,44.8064498901367,44.8064498901367,44.8064498901367,44.8064498901367,64.2274932861328,64.2274932861328,95.7119216918945,95.7119216918945,115.329391479492,115.329391479492,145.961532592773,145.961532592773,145.961532592773,145.961532592773,145.961532592773,52.0238952636719,52.0238952636719,83.8431396484375,83.8431396484375,104.836494445801,104.836494445801,104.836494445801,104.836494445801,137.757873535156,137.757873535156,43.9565505981445,43.9565505981445,43.9565505981445,75.4458084106445,75.4458084106445,75.4458084106445,96.8290786743164,96.8290786743164,96.8290786743164,96.8290786743164,129.040000915527,129.040000915527,129.040000915527,129.040000915527,146.293502807617,146.293502807617,146.293502807617,67.3139953613281,67.3139953613281,88.1674118041992,88.1674118041992,119.328491210938,119.328491210938,140.253509521484,140.253509521484,140.253509521484,140.253509521484,56.1653137207031,56.1653137207031,56.1653137207031,56.1653137207031,76.8250579833984,76.8250579833984,76.8250579833984,108.772003173828,108.772003173828,130.02571105957,130.02571105957,46.3902740478516,46.3902740478516,46.3902740478516,67.3156280517578,67.3156280517578,99.4526062011719,99.4526062011719,99.4526062011719,99.4526062011719,120.377822875977,120.377822875977,120.377822875977,120.377822875977,120.377822875977,146.283149719238,146.283149719238,146.283149719238,58.6541442871094,58.6541442871094,90.5372085571289,90.5372085571289,90.5372085571289,111.533805847168,111.533805847168,111.533805847168,143.481079101562,143.481079101562,49.4754333496094,49.4754333496094,49.4754333496094,81.0359649658203,81.0359649658203,81.0359649658203,102.424667358398,102.424667358398,134.502944946289,134.502944946289,134.502944946289,134.502944946289,134.502944946289,134.502944946289,146.309829711914,146.309829711914,146.309829711914,70.2712097167969,70.2712097167969,91.3981018066406,91.3981018066406,91.3981018066406,121.307907104492,121.307907104492,121.307907104492,141.252494812012,141.252494812012,141.252494812012,57.7425842285156,57.7425842285156,57.7425842285156,57.7425842285156,78.5408477783203,78.5408477783203,78.5408477783203,78.5408477783203,78.5408477783203,110.100059509277,110.100059509277,110.100059509277,110.100059509277,110.100059509277,130.245994567871,130.245994567871,130.245994567871,46.2634963989258,46.2634963989258,66.8027572631836,66.8027572631836,66.8027572631836,98.2871551513672,98.2871551513672,98.2871551513672,119.215766906738,119.215766906738,146.31421661377,146.31421661377,146.31421661377,57.1530151367188,57.1530151367188,57.1530151367188,57.1530151367188,57.1530151367188,57.1530151367188,89.1090927124023,89.1090927124023,110.48656463623,110.48656463623,110.48656463623,140.734237670898,140.734237670898,140.734237670898,140.734237670898,140.734237670898,47.1229629516602,47.1229629516602,78.0269470214844,78.0269470214844,99.1475601196289,99.1475601196289,99.1475601196289,130.902870178223,130.902870178223,130.902870178223,130.902870178223,130.902870178223,146.318992614746,146.318992614746,146.318992614746,146.318992614746,68.7647476196289,68.7647476196289,89.362419128418,89.362419128418,89.362419128418,121.635139465332,121.635139465332,121.635139465332,121.635139465332,142.887924194336,142.887924194336,142.887924194336,60.763053894043,60.763053894043,81.5646514892578,81.5646514892578,81.5646514892578,81.5646514892578,81.5646514892578,114.229293823242,114.229293823242,135.284934997559,135.284934997559,53.0279846191406,53.0279846191406,73.6993103027344,73.6993103027344,106.242034912109,106.242034912109,127.432037353516,127.432037353516,45.2898712158203,45.2898712158203,66.4094467163086,66.4094467163086,98.3478164672852,98.3478164672852,119.532814025879,119.532814025879,146.297431945801,146.297431945801,146.297431945801,58.6677169799805,58.6677169799805,90.5427932739258,90.5427932739258,90.5427932739258,112.057914733887,112.057914733887,143.477836608887,143.477836608887,50.2783584594727,50.2783584594727,81.8938369750977,81.8938369750977,103.210464477539,103.210464477539,103.210464477539,133.971412658691,133.971412658691,146.302192687988,146.302192687988,146.302192687988,72.0543518066406,72.0543518066406,72.0543518066406,72.0543518066406,72.0543518066406,92.1889572143555,92.1889572143555,120.984580993652,120.984580993652,120.984580993652,120.984580993652,141.053703308105,141.053703308105,141.053703308105,141.053703308105,56.4797668457031,56.4797668457031,56.4797668457031,77.9264068603516,77.9264068603516,77.9264068603516,77.9264068603516,109.993232727051,109.993232727051,109.993232727051,131.11083984375,131.11083984375,131.11083984375,131.11083984375,131.11083984375,47.4307250976562,47.4307250976562,47.4307250976562,68.4186019897461,68.4186019897461,68.4186019897461,100.623512268066,100.623512268066,121.937461853027,121.937461853027,146.332786560059,146.332786560059,146.332786560059,58.0549087524414,58.0549087524414,88.0280838012695,88.0280838012695,107.836769104004,107.836769104004,139.845184326172,139.845184326172,45.5946197509766,45.5946197509766,45.5946197509766,45.5946197509766,45.5946197509766,76.8126678466797,76.8126678466797,76.8126678466797,76.8126678466797,76.8126678466797,97.8016204833984,97.8016204833984,130.201957702637,130.201957702637,146.333435058594,146.333435058594,146.333435058594,66.6489334106445,66.6489334106445,66.6489334106445,66.6489334106445,66.6489334106445,87.111198425293,87.111198425293,87.111198425293,87.111198425293,118.264762878418,118.264762878418,118.264762878418,139.251564025879,139.251564025879,139.251564025879,139.251564025879,139.251564025879,53.663215637207,53.663215637207,53.663215637207,73.8645782470703,73.8645782470703,73.8645782470703,73.8645782470703,73.8645782470703,103.507553100586,103.507553100586,103.507553100586,103.507553100586,103.507553100586,122.98616027832,122.98616027832,146.338134765625,146.338134765625,146.338134765625,56.6803131103516,56.6803131103516,56.6803131103516,86.1274185180664,86.1274185180664,105.936431884766,105.936431884766,135.38818359375,135.38818359375,135.38818359375,146.338417053223,146.338417053223,146.338417053223,146.338417053223,70.7791976928711,70.7791976928711,91.2381744384766,91.2381744384766,91.2381744384766,123.236763000488,123.236763000488,144.61222076416,144.61222076416,144.61222076416,144.61222076416,144.61222076416,61.339599609375,61.339599609375,82.5859146118164,82.5859146118164,82.5859146118164,82.5859146118164,82.5859146118164,114.911697387695,114.911697387695,114.911697387695,136.48526763916,136.48526763916,53.6652450561523,53.6652450561523,74.8450927734375,74.8450927734375,74.8450927734375,107.826416015625,107.826416015625,129.46565246582,129.46565246582,46.519889831543,46.519889831543,67.7020568847656,67.7020568847656,100.422782897949,100.422782897949,121.474464416504,121.474464416504,121.474464416504,146.326454162598,146.326454162598,146.326454162598,58.7830581665039,58.7830581665039,90.716682434082,90.716682434082,111.764236450195,111.764236450195,111.764236450195,111.764236450195,111.764236450195,144.416625976562,144.416625976562,50.8491973876953,50.8491973876953,82.9797821044922,82.9797821044922,82.9797821044922,82.9797821044922,82.9797821044922,104.74885559082,104.74885559082,104.74885559082,137.664291381836,137.664291381836,44.4895172119141,44.4895172119141,44.4895172119141,44.4895172119141,76.8820724487305,76.8820724487305,98.4550933837891,98.4550933837891,131.502914428711,131.502914428711,131.502914428711,131.502914428711,146.32103729248,146.32103729248,146.32103729248,70.8490142822266,70.8490142822266,92.4882736206055,92.4882736206055,92.4882736206055,92.4882736206055,125.142738342285,125.142738342285,125.142738342285,125.142738342285,125.142738342285,146.319519042969,146.319519042969,146.319519042969,63.8317489624023,63.8317489624023,63.8317489624023,63.8317489624023,63.8317489624023,84.1558303833008,84.1558303833008,116.346267700195,116.346267700195,116.346267700195,137.850059509277,137.850059509277,54.7186584472656,75.5026168823242,75.5026168823242,75.5026168823242,75.5026168823242,75.5026168823242,108.085624694824,108.085624694824,129.197273254395,129.197273254395,129.197273254395,129.197273254395,129.197273254395,47.0492858886719,47.0492858886719,47.0492858886719,47.0492858886719,47.0492858886719,47.0492858886719,67.7673568725586,67.7673568725586,100.482467651367,100.482467651367,122.314903259277,122.314903259277,122.314903259277,146.310119628906,146.310119628906,146.310119628906,61.7357635498047,61.7357635498047,61.7357635498047,61.7357635498047,93.926139831543,93.926139831543,93.926139831543,115.299369812012,115.299369812012,146.047782897949,146.047782897949,53.0166473388672,53.0166473388672,53.0166473388672,85.4685897827148,85.4685897827148,106.972480773926,106.972480773926,139.621559143066,139.621559143066,139.621559143066,139.621559143066,139.621559143066,46.7890930175781,46.7890930175781,46.7890930175781,78.7822647094727,78.7822647094727,100.548278808594,100.548278808594,100.548278808594,100.548278808594,100.548278808594,132.869102478027,132.869102478027,146.309265136719,146.309265136719,146.309265136719,70.1750793457031,70.1750793457031,91.1545944213867,91.1545944213867,91.1545944213867,122.623420715332,122.623420715332,122.623420715332,144.061264038086,144.061264038086,60.4074935913086,60.4074935913086,60.4074935913086,60.4074935913086,60.4074935913086,81.5175170898438,81.5175170898438,112.724266052246,112.724266052246,112.724266052246,112.724266052246,112.724266052246,113.604393005371,113.604393005371,113.604393005371,113.604393005371,113.604393005371],"meminc":[0,0,20.3983459472656,0,27.8813323974609,0,17.9089889526367,0,20.1365127563477,0,0,-88.2868423461914,0,0,31.6852569580078,0,19.0279846191406,0,0,30.1095657348633,0,-95.5835342407227,0,0,0,0,31.7496643066406,0,0,0,20.9947128295898,0,30.0514221191406,0,19.8773498535156,0,0,0,0,-84.5066452026367,0,0,21.3888549804688,0,0,0,0,0,31.2835006713867,0,20.3982620239258,0,0,0,-85.3306198120117,0,20.9954299926758,0,0,31.4213104248047,0,0,21.0587844848633,0,23.6794357299805,0,0,-87.7713623046875,0,32.4711303710938,0,19.4168090820312,0,0,32.2137222290039,0,-95.7118453979492,0,31.7495880126953,0,0,0,20.7350006103516,0,30.9012222290039,0,0,15.9445495605469,0,0,0,0,0,-79.647102355957,0,21.0004806518555,0,0,0,0,30.3080825805664,0,20.0749130249023,0,0,0,0,-85.6834869384766,0,0,20.7979583740234,0,0,0,0,31.5643157958984,0,20.075927734375,0,0,21.515251159668,0,0,-85.8102111816406,0,0,0,0,32.5305023193359,0,20.2131195068359,0,30.309455871582,0,0,0,-95.6536026000977,0,31.8846282958984,0,20.6000671386719,0,29.7848510742188,0,16.138542175293,0,0,-80.5615539550781,0,0,21.3865051269531,0,30.7602462768555,0,20.2657089233398,0,0,-85.1994781494141,0,0,20.6714706420898,0,0,0,32.0116348266602,0,20.2039642333984,0,20.4692001342773,0,0,-84.2432098388672,0,32.2149429321289,0,20.0818405151367,0,30.7663497924805,0,0,0,0,-94.7344360351562,0,32.0191497802734,0,21.1263198852539,0,0,0,0,32.794059753418,0,0,9.97119903564453,0,0,-73.2756423950195,0,20.87109375,0,0,0,0,28.9266891479492,0,19.1546401977539,0,-84.6990585327148,0,21.05419921875,0,32.2790908813477,0,19.8065872192383,0,15.8736267089844,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,16.9950103759766,0,0,21.4506607055664,0,30.4363098144531,0,0,18.7624206542969,0,-85.6089477539062,0,0,0,19.4210433959961,0,31.4844284057617,0,19.6174697875977,0,30.6321411132812,0,0,0,0,-93.9376373291016,0,31.8192443847656,0,20.9933547973633,0,0,0,32.9213790893555,0,-93.8013229370117,0,0,31.4892578125,0,0,21.3832702636719,0,0,0,32.2109222412109,0,0,0,17.2535018920898,0,0,-78.9795074462891,0,20.8534164428711,0,31.1610794067383,0,20.9250183105469,0,0,0,-84.0881958007812,0,0,0,20.6597442626953,0,0,31.9469451904297,0,21.2537078857422,0,-83.6354370117188,0,0,20.9253540039062,0,32.1369781494141,0,0,0,20.9252166748047,0,0,0,0,25.9053268432617,0,0,-87.6290054321289,0,31.8830642700195,0,0,20.9965972900391,0,0,31.9472732543945,0,-94.0056457519531,0,0,31.5605316162109,0,0,21.3887023925781,0,32.0782775878906,0,0,0,0,0,11.806884765625,0,0,-76.0386199951172,0,21.1268920898438,0,0,29.9098052978516,0,0,19.9445877075195,0,0,-83.5099105834961,0,0,0,20.7982635498047,0,0,0,0,31.559211730957,0,0,0,0,20.1459350585938,0,0,-83.9824981689453,0,20.5392608642578,0,0,31.4843978881836,0,0,20.9286117553711,0,27.0984497070312,0,0,-89.1612014770508,0,0,0,0,0,31.9560775756836,0,21.3774719238281,0,0,30.247673034668,0,0,0,0,-93.6112747192383,0,30.9039840698242,0,21.1206130981445,0,0,31.7553100585938,0,0,0,0,15.4161224365234,0,0,0,-77.5542449951172,0,20.5976715087891,0,0,32.2727203369141,0,0,0,21.2527847290039,0,0,-82.124870300293,0,20.8015975952148,0,0,0,0,32.6646423339844,0,21.0556411743164,0,-82.256950378418,0,20.6713256835938,0,32.542724609375,0,21.1900024414062,0,-82.1421661376953,0,21.1195755004883,0,31.9383697509766,0,21.1849975585938,0,26.7646179199219,0,0,-87.6297149658203,0,31.8750762939453,0,0,21.5151214599609,0,31.419921875,0,-93.1994781494141,0,31.615478515625,0,21.3166275024414,0,0,30.7609481811523,0,12.3307800292969,0,0,-74.2478408813477,0,0,0,0,20.1346054077148,0,28.7956237792969,0,0,0,20.0691223144531,0,0,0,-84.5739364624023,0,0,21.4466400146484,0,0,0,32.0668258666992,0,0,21.1176071166992,0,0,0,0,-83.6801147460938,0,0,20.9878768920898,0,0,32.2049102783203,0,21.3139495849609,0,24.3953247070312,0,0,-88.2778778076172,0,29.9731750488281,0,19.8086853027344,0,32.008415222168,0,-94.2505645751953,0,0,0,0,31.2180480957031,0,0,0,0,20.9889526367188,0,32.4003372192383,0,16.131477355957,0,0,-79.6845016479492,0,0,0,0,20.4622650146484,0,0,0,31.153564453125,0,0,20.9868011474609,0,0,0,0,-85.5883483886719,0,0,20.2013626098633,0,0,0,0,29.6429748535156,0,0,0,0,19.4786071777344,0,23.3519744873047,0,0,-89.6578216552734,0,0,29.4471054077148,0,19.8090133666992,0,29.4517517089844,0,0,10.9502334594727,0,0,0,-75.5592193603516,0,20.4589767456055,0,0,31.9985885620117,0,21.3754577636719,0,0,0,0,-83.2726211547852,0,21.2463150024414,0,0,0,0,32.3257827758789,0,0,21.5735702514648,0,-82.8200225830078,0,21.1798477172852,0,0,32.9813232421875,0,21.6392364501953,0,-82.9457626342773,0,21.1821670532227,0,32.7207260131836,0,21.0516815185547,0,0,24.8519897460938,0,0,-87.5433959960938,0,31.9336242675781,0,21.0475540161133,0,0,0,0,32.6523895263672,0,-93.5674285888672,0,32.1305847167969,0,0,0,0,21.7690734863281,0,0,32.9154357910156,0,-93.1747741699219,0,0,0,32.3925552368164,0,21.5730209350586,0,33.0478210449219,0,0,0,14.8181228637695,0,0,-75.4720230102539,0,21.6392593383789,0,0,0,32.6544647216797,0,0,0,0,21.1767807006836,0,0,-82.4877700805664,0,0,0,0,20.3240814208984,0,32.1904373168945,0,0,21.503791809082,0,-83.1314010620117,20.7839584350586,0,0,0,0,32.5830078125,0,21.1116485595703,0,0,0,0,-82.1479873657227,0,0,0,0,0,20.7180709838867,0,32.7151107788086,0,21.8324356079102,0,0,23.9952163696289,0,0,-84.5743560791016,0,0,0,32.1903762817383,0,0,21.3732299804688,0,30.7484130859375,0,-93.031135559082,0,0,32.4519424438477,0,21.5038909912109,0,32.6490783691406,0,0,0,0,-92.8324661254883,0,0,31.9931716918945,0,21.7660140991211,0,0,0,0,32.3208236694336,0,13.4401626586914,0,0,-76.1341857910156,0,20.9795150756836,0,0,31.4688262939453,0,0,21.4378433227539,0,-83.6537704467773,0,0,0,0,21.1100234985352,0,31.2067489624023,0,0,0,0,0.880126953125,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpB6xxiP/file3c1b1f8ea26d.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    783.172    792.7335    806.1465    802.1365
#>    compute_pi0(m * 10)   7856.850   7907.9525   7975.5348   7965.0105
#>   compute_pi0(m * 100)  78957.173  79222.5280  79777.0224  79448.0805
#>         compute_pi1(m)    152.825    189.9740    240.8507    260.3435
#>    compute_pi1(m * 10)   1273.590   1337.6375   1787.0261   1392.3180
#>   compute_pi1(m * 100)  12426.282  12755.1545  23192.9735  18997.3795
#>  compute_pi1(m * 1000) 220932.045 357147.3230 351538.6745 359446.6780
#>           uq        max neval
#>     812.1105    869.290    20
#>    8013.3715   8289.812    20
#>   79803.6695  85650.761    20
#>     288.9500    306.516    20
#>    1430.1280   9563.743    20
#>   23498.2080 121950.894    20
#>  365329.4820 488520.759    20
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
#>   memory_copy1(n) 5796.10927 5368.12443 609.400534 4182.21951 3084.91090
#>   memory_copy2(n)   99.77897   94.69146  12.069795   74.99731   55.93357
#>  pre_allocate1(n)   22.10778   20.82364   4.094677   16.48949   11.99598
#>  pre_allocate2(n)  214.99549  200.51464  24.036098  159.15682  120.67895
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  90.651773    10
#>   3.000340    10
#>   2.333233    10
#>   4.170577    10
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
#>    expr    min       lq     mean   median       uq      max neval
#>  f1(df) 252.27 248.4018 82.39169 231.2569 69.34723 29.61848     5
#>  f2(df)   1.00   1.0000  1.00000   1.0000  1.00000  1.00000     5
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
