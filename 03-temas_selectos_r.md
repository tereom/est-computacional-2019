
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
#> 1   1  0.4234667 3.4812416 1.776705 3.410079
#> 2   2  0.4930643 0.7672046 1.668122 5.683072
#> 3   3  1.5502381 2.6566465 2.089481 3.801827
#> 4   4  1.0680218 1.7840262 3.474316 4.521595
#> 5   5 -0.2353150 2.4556543 4.638520 3.876785
#> 6   6  0.4655977 0.7479762 3.361073 4.199314
#> 7   7  0.2910099 0.4060914 3.603853 4.408699
#> 8   8  0.1719296 4.1578128 5.446763 4.575415
#> 9   9  1.2105569 4.6076910 1.671272 2.798995
#> 10 10 -0.3774315 1.4338696 2.689930 4.798164
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.5061138
mean(df$b)
#> [1] 2.249821
mean(df$c)
#> [1] 3.042004
mean(df$d)
#> [1] 4.207394
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.5061138 2.2498214 3.0420035 4.2073944
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
#> [1] 0.5061138 2.2498214 3.0420035 4.2073944
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
#> [1] 5.5000000 0.5061138 2.2498214 3.0420035 4.2073944
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
#> [1] 5.5000000 0.4445322 2.1198403 3.0255016 4.3040064
col_describe(df, mean)
#> [1] 5.5000000 0.5061138 2.2498214 3.0420035 4.2073944
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
#> 5.5000000 0.5061138 2.2498214 3.0420035 4.2073944
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
#>   3.896   0.128   4.024
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.015   0.008   0.518
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
#>  12.651   0.990   9.791
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
#>   0.119   0.001   0.119
plyr_st
#>    user  system elapsed 
#>   4.093   0.007   4.100
est_l_st
#>    user  system elapsed 
#>  64.128   2.016  66.148
est_r_st
#>    user  system elapsed 
#>   0.383   0.004   0.388
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

<!--html_preserve--><div id="htmlwidget-4f21276ff4f11d12f3ce" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-4f21276ff4f11d12f3ce">{"x":{"message":{"prof":{"time":[1,1,1,2,2,3,3,4,4,4,5,5,5,6,6,7,7,7,7,8,8,9,9,9,10,10,11,12,12,12,13,13,13,13,13,14,14,14,15,15,15,15,15,16,16,16,16,16,16,17,17,17,18,18,19,19,20,20,21,21,22,22,22,23,23,23,23,23,24,24,25,25,26,26,27,27,27,28,28,29,29,29,30,30,30,30,31,31,31,31,31,31,32,32,33,33,34,34,34,35,35,36,36,36,37,37,37,37,37,38,38,38,38,39,39,40,40,41,41,42,42,43,43,44,44,44,44,44,44,45,45,45,45,45,46,46,46,46,47,47,48,48,49,49,49,50,50,50,51,51,51,51,52,52,53,53,54,54,55,55,55,55,55,56,56,57,57,57,57,58,58,58,59,59,59,60,60,61,62,62,63,63,64,64,65,65,66,66,66,67,67,67,67,67,68,68,69,69,70,70,70,70,70,71,71,71,72,72,73,73,73,74,74,74,74,75,75,76,76,76,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,86,86,86,86,87,87,88,88,88,89,89,89,90,90,90,90,90,91,91,92,92,92,93,93,94,94,94,94,94,94,95,95,96,96,96,97,97,98,98,99,99,100,100,101,101,101,101,101,102,102,103,103,103,103,103,104,104,105,105,105,106,106,107,107,108,108,108,109,109,109,109,110,110,110,111,111,111,112,112,112,112,112,113,113,113,113,113,113,114,114,115,115,115,116,117,117,118,118,119,119,120,120,120,121,121,121,121,121,122,122,123,123,123,124,124,125,125,126,126,127,127,127,128,128,128,128,128,128,129,129,130,130,131,131,131,131,131,131,132,132,133,133,133,133,133,134,134,135,135,135,136,136,137,137,137,137,137,137,138,138,138,138,139,139,140,140,141,141,142,142,143,143,143,143,144,144,145,145,145,146,146,146,147,147,148,148,149,149,149,150,150,151,151,152,152,153,153,153,154,154,155,155,155,156,156,157,157,158,158,159,159,159,160,160,160,161,161,161,161,161,162,162,162,162,162,162,163,163,163,164,164,164,164,165,165,166,166,166,166,167,167,167,168,168,168,169,169,170,170,171,171,172,172,172,173,173,173,173,173,174,174,174,175,175,175,175,175,176,176,176,176,177,177,178,178,179,179,179,179,180,180,180,180,180,181,181,182,182,182,182,183,183,183,184,184,184,184,184,185,185,186,186,187,187,187,188,188,189,189,189,189,189,189,190,190,191,191,191,191,192,192,192,192,192,193,193,194,194,194,194,194,195,195,196,196,197,197,198,198,198,199,199,200,200,201,201,201,202,202,203,204,204,204,204,204,205,205,206,206,207,207,208,208,208,209,209,209,209,209,210,210,211,211,211,212,212,212,212,212,213,213,213,213,213,213,214,214,215,215,215,216,216,217,217,218,218,219,219,219,219,220,220,220,221,221,221,221,221,221,222,222,222,223,223,223,223,223,224,224,224,225,225,225,226,226,227,227,227,228,228,229,229,230,230,231,231,231,231,232,232,233,233,234,234,234,234,234,235,235,235,235,235,235,236,236,236,236,236,237,237,238,238,239,239,240,240,240,240,241,241,241,242,242,243,243,244,244,245,245,245,246,246,247,247,247,248,248,248,249,249,249,250,250,251,251,252,252,253,253,253,254,254,254,255,255,256,256,257,257,258,258,258,259,259,260,260,260,261,261,261,262,262,263,263,263,263,263,263,264,264,264,265,265,265,265,266,266,266,266,266,267,267,267,268,268,269,269,270,270,271,271,271,272,272,272,273,273,274,274,274,274,274],"depth":[3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,1,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1],"label":["[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","<GC>","[.data.frame","[","$","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","for (i in 1:n_players) {","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,null,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,null,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1],"linenum":[null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,11,9,9,null,9,9,9,9,10,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,10,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,8,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,11,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,10,10,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,10,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,null,11,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,13],"memalloc":[63.6901016235352,63.6901016235352,63.6901016235352,85.0713043212891,85.0713043212891,112.167037963867,112.167037963867,130.007804870605,130.007804870605,130.007804870605,96.3475036621094,96.3475036621094,96.3475036621094,64.08740234375,64.08740234375,96.036994934082,96.036994934082,96.036994934082,96.036994934082,116.047920227051,116.047920227051,146.28670501709,146.28670501709,146.28670501709,51.6859283447266,51.6859283447266,84.1619186401367,104.633865356445,104.633865356445,104.633865356445,134.948867797852,134.948867797852,134.948867797852,134.948867797852,134.948867797852,146.294662475586,146.294662475586,146.294662475586,72.6793975830078,72.6793975830078,72.6793975830078,72.6793975830078,72.6793975830078,94.1262664794922,94.1262664794922,94.1262664794922,94.1262664794922,94.1262664794922,94.1262664794922,124.36466217041,124.36466217041,124.36466217041,144.632804870605,144.632804870605,60.6179046630859,60.6179046630859,82.0714721679688,82.0714721679688,114.870010375977,114.870010375977,136.255264282227,136.255264282227,136.255264282227,52.4181823730469,52.4181823730469,52.4181823730469,52.4181823730469,52.4181823730469,73.9343185424805,73.9343185424805,104.763168334961,104.763168334961,126.021507263184,126.021507263184,101.918266296387,101.918266296387,101.918266296387,63.9659957885742,63.9659957885742,95.6532974243164,95.6532974243164,95.6532974243164,116.054885864258,116.054885864258,116.054885864258,116.054885864258,146.303733825684,146.303733825684,146.303733825684,146.303733825684,146.303733825684,146.303733825684,52.4177169799805,52.4177169799805,84.3094635009766,84.3094635009766,104.58406829834,104.58406829834,104.58406829834,135.218978881836,135.218978881836,146.3076171875,146.3076171875,146.3076171875,72.1044845581055,72.1044845581055,72.1044845581055,72.1044845581055,72.1044845581055,93.3009262084961,93.3009262084961,93.3009262084961,93.3009262084961,123.941009521484,123.941009521484,144.080238342285,144.080238342285,59.7121658325195,59.7121658325195,81.3591156005859,81.3591156005859,112.849937438965,112.849937438965,134.040794372559,134.040794372559,134.040794372559,134.040794372559,134.040794372559,134.040794372559,50.4590911865234,50.4590911865234,50.4590911865234,50.4590911865234,50.4590911865234,71.8423919677734,71.8423919677734,71.8423919677734,71.8423919677734,103.597198486328,103.597198486328,123.998313903809,123.998313903809,146.306701660156,146.306701660156,146.306701660156,60.6310272216797,60.6310272216797,60.6310272216797,92.7713623046875,92.7713623046875,92.7713623046875,92.7713623046875,113.038848876953,113.038848876953,143.999313354492,143.999313354492,49.3494873046875,49.3494873046875,80.9070281982422,80.9070281982422,80.9070281982422,80.9070281982422,80.9070281982422,102.097015380859,102.097015380859,132.799850463867,132.799850463867,132.799850463867,132.799850463867,146.314697265625,146.314697265625,146.314697265625,69.6844635009766,69.6844635009766,69.6844635009766,90.7415618896484,90.7415618896484,121.648635864258,141.918960571289,141.918960571289,57.3550796508789,57.3550796508789,78.7449493408203,78.7449493408203,111.152282714844,111.152282714844,132.666709899902,132.666709899902,132.666709899902,49.679443359375,49.679443359375,49.679443359375,49.679443359375,49.679443359375,70.412109375,70.412109375,102.104187011719,102.104187011719,121.914665222168,121.914665222168,121.914665222168,121.914665222168,121.914665222168,146.317977905273,146.317977905273,146.317977905273,58.2066192626953,58.2066192626953,90.2177734375,90.2177734375,90.2177734375,111.869407653809,111.869407653809,111.869407653809,111.869407653809,142.958122253418,142.958122253418,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,146.301956176758,44.8284072875977,65.630256652832,65.630256652832,65.630256652832,65.630256652832,97.0509948730469,97.0509948730469,117.318855285645,117.318855285645,117.318855285645,146.318733215332,146.318733215332,146.318733215332,54.2775802612305,54.2775802612305,54.2775802612305,54.2775802612305,54.2775802612305,86.0331573486328,86.0331573486328,105.513038635254,105.513038635254,105.513038635254,135.75276184082,135.75276184082,146.315727233887,146.315727233887,146.315727233887,146.315727233887,146.315727233887,146.315727233887,73.1055374145508,73.1055374145508,94.5580596923828,94.5580596923828,94.5580596923828,125.256988525391,125.256988525391,145.325050354004,145.325050354004,62.4852752685547,62.4852752685547,83.6706008911133,83.6706008911133,115.813354492188,115.813354492188,115.813354492188,115.813354492188,115.813354492188,137.331939697266,137.331939697266,53.4304122924805,53.4304122924805,53.4304122924805,53.4304122924805,53.4304122924805,74.7488327026367,74.7488327026367,106.689834594727,106.689834594727,106.689834594727,128.07869720459,128.07869720459,45.4932327270508,45.4932327270508,66.4220581054688,66.4220581054688,66.4220581054688,98.0994186401367,98.0994186401367,98.0994186401367,98.0994186401367,118.372207641602,118.372207641602,118.372207641602,146.318771362305,146.318771362305,146.318771362305,54.8734970092773,54.8734970092773,54.8734970092773,54.8734970092773,54.8734970092773,87.2132797241211,87.2132797241211,87.2132797241211,87.2132797241211,87.2132797241211,87.2132797241211,108.662521362305,108.662521362305,141.128204345703,141.128204345703,141.128204345703,47.3964691162109,78.5546340942383,78.5546340942383,99.4223175048828,99.4223175048828,130.188110351562,130.188110351562,146.26293182373,146.26293182373,146.26293182373,67.6093978881836,67.6093978881836,67.6093978881836,67.6093978881836,67.6093978881836,89.2618637084961,89.2618637084961,120.821319580078,120.821319580078,120.821319580078,142.20352935791,142.20352935791,58.420036315918,58.420036315918,79.7456893920898,79.7456893920898,112.343635559082,112.343635559082,112.343635559082,133.600425720215,133.600425720215,133.600425720215,133.600425720215,133.600425720215,133.600425720215,50.5546340942383,50.5546340942383,71.6796264648438,71.6796264648438,103.96102142334,103.96102142334,103.96102142334,103.96102142334,103.96102142334,103.96102142334,125.876083374023,125.876083374023,43.8642196655273,43.8642196655273,43.8642196655273,43.8642196655273,43.8642196655273,64.9269485473633,64.9269485473633,97.1988830566406,97.1988830566406,97.1988830566406,117.733528137207,117.733528137207,146.276458740234,146.276458740234,146.276458740234,146.276458740234,146.276458740234,146.276458740234,54.3585586547852,54.3585586547852,54.3585586547852,54.3585586547852,85.8552017211914,85.8552017211914,107.691612243652,107.691612243652,139.906829833984,139.906829833984,47.0181732177734,47.0181732177734,77.9216537475586,77.9216537475586,77.9216537475586,77.9216537475586,99.1740875244141,99.1740875244141,129.551124572754,129.551124572754,129.551124572754,146.278213500977,146.278213500977,146.278213500977,67.8074569702148,67.8074569702148,89.3226776123047,89.3226776123047,121.596138000488,121.596138000488,121.596138000488,143.307922363281,143.307922363281,60.7235717773438,60.7235717773438,81.5909194946289,81.5909194946289,113.337776184082,113.337776184082,113.337776184082,133.343109130859,133.343109130859,50.2344512939453,50.2344512939453,50.2344512939453,71.4286575317383,71.4286575317383,103.71053314209,103.71053314209,124.965362548828,124.965362548828,123.834426879883,123.834426879883,123.834426879883,64.3357238769531,64.3357238769531,64.3357238769531,96.6026000976562,96.6026000976562,96.6026000976562,96.6026000976562,96.6026000976562,116.999557495117,116.999557495117,116.999557495117,116.999557495117,116.999557495117,116.999557495117,146.256866455078,146.256866455078,146.256866455078,53.7733993530273,53.7733993530273,53.7733993530273,53.7733993530273,86.3025436401367,86.3025436401367,107.557426452637,107.557426452637,107.557426452637,107.557426452637,139.895561218262,139.895561218262,139.895561218262,47.0894241333008,47.0894241333008,47.0894241333008,79.2942428588867,79.2942428588867,99.9545745849609,99.9545745849609,131.896049499512,131.896049499512,146.260551452637,146.260551452637,146.260551452637,71.4874572753906,71.4874572753906,71.4874572753906,71.4874572753906,71.4874572753906,92.8694763183594,92.8694763183594,92.8694763183594,123.762466430664,123.762466430664,123.762466430664,123.762466430664,123.762466430664,145.143699645996,145.143699645996,145.143699645996,145.143699645996,61.4895553588867,61.4895553588867,82.9345703125,82.9345703125,113.626777648926,113.626777648926,113.626777648926,113.626777648926,134.351142883301,134.351142883301,134.351142883301,134.351142883301,134.351142883301,51.3242111206055,51.3242111206055,72.9691772460938,72.9691772460938,72.9691772460938,72.9691772460938,104.649642944336,104.649642944336,104.649642944336,126.292137145996,126.292137145996,126.292137145996,126.292137145996,126.292137145996,43.6513290405273,43.6513290405273,64.6392288208008,64.6392288208008,97.2355499267578,97.2355499267578,97.2355499267578,116.976119995117,116.976119995117,146.29621887207,146.29621887207,146.29621887207,146.29621887207,146.29621887207,146.29621887207,54.407600402832,54.407600402832,85.4299468994141,85.4299468994141,85.4299468994141,85.4299468994141,105.89453125,105.89453125,105.89453125,105.89453125,105.89453125,137.768661499023,137.768661499023,43.7848510742188,43.7848510742188,43.7848510742188,43.7848510742188,43.7848510742188,76.0527801513672,76.0527801513672,96.8433837890625,96.8433837890625,129.636764526367,129.636764526367,146.295745849609,146.295745849609,146.295745849609,67.3291625976562,67.3291625976562,87.3976974487305,87.3976974487305,119.467994689941,119.467994689941,119.467994689941,140.852699279785,140.852699279785,57.1626358032227,78.0191268920898,78.0191268920898,78.0191268920898,78.0191268920898,78.0191268920898,109.89616394043,109.89616394043,130.296028137207,130.296028137207,46.542724609375,46.542724609375,67.4603652954102,67.4603652954102,67.4603652954102,100.049179077148,100.049179077148,100.049179077148,100.049179077148,100.049179077148,121.688446044922,121.688446044922,146.276794433594,146.276794433594,146.276794433594,60.7741775512695,60.7741775512695,60.7741775512695,60.7741775512695,60.7741775512695,93.0357055664062,93.0357055664062,93.0357055664062,93.0357055664062,93.0357055664062,93.0357055664062,114.804611206055,114.804611206055,146.279907226562,146.279907226562,146.279907226562,54.281494140625,54.281494140625,86.4121398925781,86.4121398925781,107.590606689453,107.590606689453,140.247406005859,140.247406005859,140.247406005859,140.247406005859,46.5463562011719,46.5463562011719,46.5463562011719,78.8104476928711,78.8104476928711,78.8104476928711,78.8104476928711,78.8104476928711,78.8104476928711,100.055755615234,100.055755615234,100.055755615234,131.795066833496,131.795066833496,131.795066833496,131.795066833496,131.795066833496,146.286949157715,146.286949157715,146.286949157715,69.6285171508789,69.6285171508789,69.6285171508789,91.3320236206055,91.3320236206055,123.133338928223,123.133338928223,123.133338928223,144.638999938965,144.638999938965,61.4988632202148,61.4988632202148,83.1371307373047,83.1371307373047,115.659027099609,115.659027099609,115.659027099609,115.659027099609,137.297714233398,137.297714233398,55.2035293579102,55.2035293579102,76.6456832885742,76.6456832885742,76.6456832885742,76.6456832885742,76.6456832885742,109.627716064453,109.627716064453,109.627716064453,109.627716064453,109.627716064453,109.627716064453,131.266098022461,131.266098022461,131.266098022461,131.266098022461,131.266098022461,48.9091796875,48.9091796875,70.088493347168,70.088493347168,101.890632629395,101.890632629395,123.791702270508,123.791702270508,123.791702270508,123.791702270508,146.279907226562,146.279907226562,146.279907226562,63.2017059326172,63.2017059326172,95.0648574829102,95.0648574829102,116.699440002441,116.699440002441,146.267860412598,146.267860412598,146.267860412598,55.6634826660156,55.6634826660156,87.5264587402344,87.5264587402344,87.5264587402344,108.899276733398,108.899276733398,108.899276733398,140.369407653809,140.369407653809,140.369407653809,47.0098342895508,47.0098342895508,79.4636077880859,79.4636077880859,101.033477783203,101.033477783203,133.945655822754,133.945655822754,133.945655822754,146.270736694336,146.270736694336,146.270736694336,73.5630416870117,73.5630416870117,94.4772567749023,94.4772567749023,127.061538696289,127.061538696289,146.270690917969,146.270690917969,146.270690917969,66.8106155395508,66.8106155395508,88.2489013671875,88.2489013671875,88.2489013671875,120.963005065918,120.963005065918,120.963005065918,142.597953796387,142.597953796387,60.3865280151367,60.3865280151367,60.3865280151367,60.3865280151367,60.3865280151367,60.3865280151367,82.0213470458984,82.0213470458984,82.0213470458984,114.080101013184,114.080101013184,114.080101013184,114.080101013184,135.780532836914,135.780532836914,135.780532836914,135.780532836914,135.780532836914,52.4340133666992,52.4340133666992,52.4340133666992,73.7407836914062,73.7407836914062,106.520904541016,106.520904541016,128.352462768555,128.352462768555,44.8951187133789,44.8951187133789,44.8951187133789,66.3329772949219,66.3329772949219,66.3329772949219,98.0639343261719,98.0639343261719,112.580810546875,112.580810546875,112.580810546875,112.580810546875,112.580810546875],"meminc":[0,0,0,21.3812026977539,0,27.0957336425781,0,17.8407669067383,0,0,-33.6603012084961,0,0,-32.2601013183594,0,31.949592590332,0,0,0,20.0109252929688,0,30.2387847900391,0,0,-94.6007766723633,0,32.4759902954102,20.4719467163086,0,0,30.3150024414062,0,0,0,0,11.3457946777344,0,0,-73.6152648925781,0,0,0,0,21.4468688964844,0,0,0,0,0,30.238395690918,0,0,20.2681427001953,0,-84.0149002075195,0,21.4535675048828,0,32.7985382080078,0,21.38525390625,0,0,-83.8370819091797,0,0,0,0,21.5161361694336,0,30.8288497924805,0,21.2583389282227,0,-24.1032409667969,0,0,-37.9522705078125,0,31.6873016357422,0,0,20.4015884399414,0,0,0,30.2488479614258,0,0,0,0,0,-93.8860168457031,0,31.8917465209961,0,20.2746047973633,0,0,30.6349105834961,0,11.0886383056641,0,0,-74.2031326293945,0,0,0,0,21.1964416503906,0,0,0,30.6400833129883,0,20.1392288208008,0,-84.3680725097656,0,21.6469497680664,0,31.4908218383789,0,21.1908569335938,0,0,0,0,0,-83.5817031860352,0,0,0,0,21.38330078125,0,0,0,31.7548065185547,0,20.4011154174805,0,22.3083877563477,0,0,-85.6756744384766,0,0,32.1403350830078,0,0,0,20.2674865722656,0,30.9604644775391,0,-94.6498260498047,0,31.5575408935547,0,0,0,0,21.1899871826172,0,30.7028350830078,0,0,0,13.5148468017578,0,0,-76.6302337646484,0,0,21.0570983886719,0,30.9070739746094,20.2703247070312,0,-84.5638809204102,0,21.3898696899414,0,32.4073333740234,0,21.5144271850586,0,0,-82.9872665405273,0,0,0,0,20.732666015625,0,31.6920776367188,0,19.8104782104492,0,0,0,0,24.4033126831055,0,0,-88.1113586425781,0,32.0111541748047,0,0,21.6516342163086,0,0,0,31.0887145996094,0,3.34383392333984,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-101.47354888916,20.8018493652344,0,0,0,31.4207382202148,0,20.2678604125977,0,0,28.9998779296875,0,0,-92.0411529541016,0,0,0,0,31.7555770874023,0,19.4798812866211,0,0,30.2397232055664,0,10.5629653930664,0,0,0,0,0,-73.2101898193359,0,21.452522277832,0,0,30.6989288330078,0,20.0680618286133,0,-82.8397750854492,0,21.1853256225586,0,32.1427536010742,0,0,0,0,21.5185852050781,0,-83.9015274047852,0,0,0,0,21.3184204101562,0,31.9410018920898,0,0,21.3888626098633,0,-82.5854644775391,0,20.928825378418,0,0,31.677360534668,0,0,0,20.2727890014648,0,0,27.9465637207031,0,0,-91.4452743530273,0,0,0,0,32.3397827148438,0,0,0,0,0,21.4492416381836,0,32.4656829833984,0,0,-93.7317352294922,31.1581649780273,0,20.8676834106445,0,30.7657928466797,0,16.074821472168,0,0,-78.6535339355469,0,0,0,0,21.6524658203125,0,31.559455871582,0,0,21.382209777832,0,-83.7834930419922,0,21.3256530761719,0,32.5979461669922,0,0,21.2567901611328,0,0,0,0,0,-83.0457916259766,0,21.1249923706055,0,32.2813949584961,0,0,0,0,0,21.9150619506836,0,-82.0118637084961,0,0,0,0,21.0627288818359,0,32.2719345092773,0,0,20.5346450805664,0,28.5429306030273,0,0,0,0,0,-91.9179000854492,0,0,0,31.4966430664062,0,21.8364105224609,0,32.215217590332,0,-92.8886566162109,0,30.9034805297852,0,0,0,21.2524337768555,0,30.3770370483398,0,0,16.7270889282227,0,0,-78.4707565307617,0,21.5152206420898,0,32.2734603881836,0,0,21.711784362793,0,-82.5843505859375,0,20.8673477172852,0,31.7468566894531,0,0,20.0053329467773,0,-83.1086578369141,0,0,21.194206237793,0,32.2818756103516,0,21.2548294067383,0,-1.13093566894531,0,0,-59.4987030029297,0,0,32.2668762207031,0,0,0,0,20.3969573974609,0,0,0,0,0,29.2573089599609,0,0,-92.4834671020508,0,0,0,32.5291442871094,0,21.2548828125,0,0,0,32.338134765625,0,0,-92.8061370849609,0,0,32.2048187255859,0,20.6603317260742,0,31.9414749145508,0,14.364501953125,0,0,-74.7730941772461,0,0,0,0,21.3820190429688,0,0,30.8929901123047,0,0,0,0,21.381233215332,0,0,0,-83.6541442871094,0,21.4450149536133,0,30.6922073364258,0,0,0,20.724365234375,0,0,0,0,-83.0269317626953,0,21.6449661254883,0,0,0,31.6804656982422,0,0,21.6424942016602,0,0,0,0,-82.6408081054688,0,20.9878997802734,0,32.596321105957,0,0,19.7405700683594,0,29.3200988769531,0,0,0,0,0,-91.8886184692383,0,31.022346496582,0,0,0,20.4645843505859,0,0,0,0,31.8741302490234,0,-93.9838104248047,0,0,0,0,32.2679290771484,0,20.7906036376953,0,32.7933807373047,0,16.6589813232422,0,0,-78.9665832519531,0,20.0685348510742,0,32.0702972412109,0,0,21.3847045898438,0,-83.6900634765625,20.8564910888672,0,0,0,0,31.8770370483398,0,20.3998641967773,0,-83.753303527832,0,20.9176406860352,0,0,32.5888137817383,0,0,0,0,21.6392669677734,0,24.5883483886719,0,0,-85.5026168823242,0,0,0,0,32.2615280151367,0,0,0,0,0,21.7689056396484,0,31.4752960205078,0,0,-91.9984130859375,0,32.1306457519531,0,21.178466796875,0,32.6567993164062,0,0,0,-93.7010498046875,0,0,32.2640914916992,0,0,0,0,0,21.2453079223633,0,0,31.7393112182617,0,0,0,0,14.4918823242188,0,0,-76.6584320068359,0,0,21.7035064697266,0,31.8013153076172,0,0,21.5056610107422,0,-83.14013671875,0,21.6382675170898,0,32.5218963623047,0,0,0,21.6386871337891,0,-82.0941848754883,0,21.4421539306641,0,0,0,0,32.9820327758789,0,0,0,0,0,21.6383819580078,0,0,0,0,-82.3569183349609,0,21.179313659668,0,31.8021392822266,0,21.9010696411133,0,0,0,22.4882049560547,0,0,-83.0782012939453,0,31.863151550293,0,21.6345825195312,0,29.5684204101562,0,0,-90.604377746582,0,31.8629760742188,0,0,21.3728179931641,0,0,31.4701309204102,0,0,-93.3595733642578,0,32.4537734985352,0,21.5698699951172,0,32.9121780395508,0,0,12.325080871582,0,0,-72.7076950073242,0,20.9142150878906,0,32.5842819213867,0,19.2091522216797,0,0,-79.460075378418,0,21.4382858276367,0,0,32.7141036987305,0,0,21.6349487304688,0,-82.21142578125,0,0,0,0,0,21.6348190307617,0,0,32.0587539672852,0,0,0,21.7004318237305,0,0,0,0,-83.3465194702148,0,0,21.306770324707,0,32.7801208496094,0,21.8315582275391,0,-83.4573440551758,0,0,21.437858581543,0,0,31.73095703125,0,14.5168762207031,0,0,0,0],"filename":[null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpgDkjub/file359c746da5ee.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    785.820    796.7175    816.8865    804.5135
#>    compute_pi0(m * 10)   7868.091   7917.4580   7966.5210   7964.4925
#>   compute_pi0(m * 100)  78611.246  79061.2855  79888.2722  79314.4860
#>         compute_pi1(m)    158.783    189.9375   8214.0432    252.8885
#>    compute_pi1(m * 10)   1283.583   1390.2795   1876.6539   1496.8925
#>   compute_pi1(m * 100)  12637.315  19142.7315  21571.2864  20625.4530
#>  compute_pi1(m * 1000) 295347.347 359214.2750 398181.3412 385699.5455
#>           uq        max neval
#>     823.4225    931.569    20
#>    8008.3210   8073.792    20
#>   79823.0490  85805.123    20
#>     322.2305 159571.260    20
#>    1583.0125   9449.209    20
#>   24012.0270  30734.198    20
#>  465625.4625 485466.830    20
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
#>   memory_copy1(n) 5352.51357 4867.31089 751.047946 4055.48997 4024.15198
#>   memory_copy2(n)   91.24115   83.99853  13.132332   69.01310   71.22169
#>  pre_allocate1(n)   19.84110   18.16650   3.753039   13.96035   13.63235
#>  pre_allocate2(n)  194.50022  180.85742  24.571052  136.13771  131.56131
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  171.893093    10
#>    3.117535    10
#>    1.898930    10
#>    4.274419    10
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
#>  f1(df) 353.1471 353.6645 109.8004 334.2083 90.04267 39.22075     5
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
