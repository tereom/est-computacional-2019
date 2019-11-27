
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
#>    id          a        b        c        d
#> 1   1  0.4971371 1.198006 3.060626 4.102369
#> 2   2 -0.9240590 2.338983 3.467148 5.847701
#> 3   3  0.0614679 1.472840 2.872905 5.176102
#> 4   4 -1.4847126 2.230693 2.320675 2.038593
#> 5   5 -0.3746203 2.216018 2.768983 1.514450
#> 6   6 -1.0493223 1.542916 2.722161 3.232174
#> 7   7  0.3313339 2.226522 4.800993 4.367160
#> 8   8 -0.4439614 1.299054 3.683803 5.748659
#> 9   9 -2.4244433 2.160426 3.036749 4.926191
#> 10 10 -1.3450236 1.744600 3.700491 3.411617
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.7156204
mean(df$b)
#> [1] 1.843006
mean(df$c)
#> [1] 3.243453
mean(df$d)
#> [1] 4.036502
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.7156204  1.8430058  3.2434533  4.0365016
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
#> [1] -0.7156204  1.8430058  3.2434533  4.0365016
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
#> [1]  5.5000000 -0.7156204  1.8430058  3.2434533  4.0365016
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
#> [1]  5.5000000 -0.6840102  1.9525129  3.0486876  4.2347648
col_describe(df, mean)
#> [1]  5.5000000 -0.7156204  1.8430058  3.2434533  4.0365016
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
#>  5.5000000 -0.7156204  1.8430058  3.2434533  4.0365016
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
#>   3.828   0.091   3.922
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.017   0.003   0.497
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
#>  12.675   0.667   9.614
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
#>   0.106   0.004   0.111
plyr_st
#>    user  system elapsed 
#>   4.013   0.004   4.018
est_l_st
#>    user  system elapsed 
#>  60.946   1.471  62.450
est_r_st
#>    user  system elapsed 
#>    0.39    0.00    0.39
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

<!--html_preserve--><div id="htmlwidget-7cb99aa5e9ce3eac0315" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-7cb99aa5e9ce3eac0315">{"x":{"message":{"prof":{"time":[1,1,1,2,2,2,3,3,3,3,3,3,4,4,5,5,5,6,6,7,7,7,8,8,9,9,10,10,10,10,10,11,11,12,12,13,13,14,14,14,15,15,15,16,16,17,17,17,18,18,19,19,20,20,20,20,20,21,21,21,22,22,23,23,23,24,24,25,25,26,26,27,27,27,28,28,29,29,30,30,30,31,31,31,32,32,32,33,33,34,34,35,35,36,36,37,37,37,38,38,39,39,39,39,39,39,40,40,41,41,41,42,42,42,43,43,43,43,44,44,45,45,46,46,46,46,46,47,47,48,48,49,49,49,50,50,50,50,51,51,51,52,52,53,53,54,54,54,54,54,54,55,55,55,55,56,56,57,57,57,57,57,58,58,58,58,58,59,59,59,60,60,60,61,61,62,62,63,63,63,63,64,64,64,64,65,65,65,66,66,66,66,66,67,67,68,68,68,69,69,69,70,70,71,71,71,71,71,72,72,73,73,74,74,75,75,76,76,76,76,76,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,88,88,89,89,90,90,91,91,92,92,92,92,93,93,93,94,94,95,95,95,95,95,96,96,97,97,98,98,98,99,99,100,100,101,101,102,102,103,103,104,104,105,105,105,106,106,107,107,108,108,108,109,109,109,109,109,110,110,111,111,112,112,112,113,113,113,113,113,113,114,114,114,114,114,114,115,115,115,115,116,116,117,117,118,118,119,119,120,120,121,121,122,122,122,123,123,123,123,123,124,124,125,125,126,126,126,126,127,127,127,128,128,129,129,129,130,130,131,131,131,131,132,132,132,132,133,133,133,134,134,135,135,135,135,135,136,136,136,137,137,137,138,138,139,139,140,140,140,140,140,141,141,141,141,141,142,142,142,142,142,143,143,144,144,145,145,145,146,146,146,147,147,148,148,148,149,149,150,150,150,150,151,151,152,152,152,152,152,153,153,153,154,154,154,154,154,154,155,155,155,155,155,155,156,156,156,156,156,157,157,158,158,158,159,159,160,160,160,160,160,160,161,161,161,161,162,162,162,163,163,164,164,164,164,164,165,165,165,166,166,166,166,166,167,167,167,168,168,169,169,169,170,170,171,171,172,172,173,173,174,174,174,174,174,175,175,175,176,176,177,177,177,178,178,178,178,178,179,179,180,180,181,181,181,181,182,182,183,183,183,184,184,184,185,185,186,186,186,186,187,187,188,188,189,189,189,190,190,191,191,192,192,192,193,193,193,194,194,195,195,196,196,196,197,197,197,198,198,198,198,198,199,199,200,200,201,201,201,202,202,203,203,203,203,203,203,204,204,204,205,205,206,206,206,207,207,208,208,209,209,210,210,211,211,212,212,212,212,212,213,213,213,213,214,214,215,215,216,216,217,217,218,218,218,219,219,220,220,221,221,222,222,223,223,223,224,224,224,224,225,225,225,225,225,225,226,226,226,227,227,227,228,228,229,229,229,230,230,231,231,232,232,232,232,232,232,233,233,233,233,233,233,234,234,235,235,236,236,236,237,237,237,238,238,239,239,239,239,240,240,240,240,240,240,241,241,242,242,243,243,243,244,244,245,245,245,246,246,247,247,247,248,248,249,249,249,250,250,250,250,250,251,251,252,252,252,252,252,252,253,253,253,254,254,255,255,256,256,257,257,257,258,258,258,259,259,259,259,259,260,260,261,261,261,261,262,262,262,262,262,262,263,263,264,264,264,264,264,264,265,265,266,266,267,267,268,268,269,269,270,270,271,271,272,272,273,273,273,274,274,275,275,276,276,276,276,276,276,277,277,278,278,278,278,278],"depth":[3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1],"label":["==","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1],"linenum":[null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,null,13],"memalloc":[62.4189224243164,62.4189224243164,62.4189224243164,83.8650436401367,83.8650436401367,83.8650436401367,111.288932800293,111.288932800293,111.288932800293,111.288932800293,111.288932800293,111.288932800293,129.260879516602,129.260879516602,146.315055847168,146.315055847168,146.315055847168,61.307258605957,61.307258605957,92.9942016601562,92.9942016601562,92.9942016601562,112.612327575684,112.612327575684,143.113388061523,143.113388061523,47.3328628540039,47.3328628540039,47.3328628540039,47.3328628540039,47.3328628540039,79.6735992431641,79.6735992431641,100.538940429688,100.538940429688,131.312805175781,131.312805175781,146.334297180176,146.334297180176,146.334297180176,66.1569747924805,66.1569747924805,66.1569747924805,87.8058319091797,87.8058319091797,118.107482910156,118.107482910156,118.107482910156,137.784156799316,137.784156799316,50.5525817871094,50.5525817871094,70.4319915771484,70.4319915771484,70.4319915771484,70.4319915771484,70.4319915771484,101.656806945801,101.656806945801,101.656806945801,122.715049743652,122.715049743652,146.328948974609,146.328948974609,146.328948974609,54.4267654418945,54.4267654418945,86.7000885009766,86.7000885009766,108.083808898926,108.083808898926,140.363212585449,140.363212585449,140.363212585449,45.1756973266602,45.1756973266602,76.0084533691406,76.0084533691406,95.6929321289062,95.6929321289062,95.6929321289062,122.456977844238,122.456977844238,122.456977844238,141.354118347168,141.354118347168,141.354118347168,55.802604675293,55.802604675293,75.4235458374023,75.4235458374023,103.769660949707,103.769660949707,122.794364929199,122.794364929199,146.281539916992,146.281539916992,146.281539916992,56.593505859375,56.593505859375,86.7122421264648,86.7122421264648,86.7122421264648,86.7122421264648,86.7122421264648,86.7122421264648,106.005081176758,106.005081176758,135.79125213623,135.79125213623,135.79125213623,146.284103393555,146.284103393555,146.284103393555,71.1673583984375,71.1673583984375,71.1673583984375,71.1673583984375,92.6761856079102,92.6761856079102,122.729423522949,122.729423522949,142.018608093262,142.018608093262,142.018608093262,142.018608093262,142.018608093262,56.8641052246094,56.8641052246094,77.9204177856445,77.9204177856445,106.851600646973,106.851600646973,106.851600646973,126.730995178223,126.730995178223,126.730995178223,126.730995178223,146.281455993652,146.281455993652,146.281455993652,61.8514175415039,61.8514175415039,93.9264068603516,93.9264068603516,114.193519592285,114.193519592285,114.193519592285,114.193519592285,114.193519592285,114.193519592285,144.170249938965,144.170249938965,144.170249938965,144.170249938965,48.7328262329102,48.7328262329102,80.0291748046875,80.0291748046875,80.0291748046875,80.0291748046875,80.0291748046875,100.626502990723,100.626502990723,100.626502990723,100.626502990723,100.626502990723,130.085227966309,130.085227966309,130.085227966309,146.289154052734,146.289154052734,146.289154052734,65.3274230957031,65.3274230957031,86.4501266479492,86.4501266479492,116.50611114502,116.50611114502,116.50611114502,116.50611114502,136.515701293945,136.515701293945,136.515701293945,136.515701293945,51.3584213256836,51.3584213256836,51.3584213256836,72.0946960449219,72.0946960449219,72.0946960449219,72.0946960449219,72.0946960449219,103.84789276123,103.84789276123,124.965698242188,124.965698242188,124.965698242188,146.285369873047,146.285369873047,146.285369873047,61.8586654663086,61.8586654663086,92.9613037109375,92.9613037109375,92.9613037109375,92.9613037109375,92.9613037109375,113.491722106934,113.491722106934,143.928817749023,143.928817749023,48.8053741455078,48.8053741455078,80.6116790771484,80.6116790771484,101.933441162109,101.933441162109,101.933441162109,101.933441162109,101.933441162109,134.600807189941,134.600807189941,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,146.276596069336,42.7700271606445,42.7700271606445,42.7700271606445,50.6432952880859,50.6432952880859,50.6432952880859,50.6432952880859,50.6432952880859,82.4619216918945,82.4619216918945,102.730224609375,102.730224609375,131.859214782715,131.859214782715,146.292274475098,146.292274475098,146.292274475098,146.292274475098,69.0143051147461,69.0143051147461,69.0143051147461,90.2037734985352,90.2037734985352,120.245498657227,120.245498657227,120.245498657227,120.245498657227,120.245498657227,140.514106750488,140.514106750488,56.6158447265625,56.6158447265625,77.9995040893555,77.9995040893555,77.9995040893555,107.588638305664,107.588638305664,127.65811920166,127.65811920166,43.0373382568359,43.0373382568359,64.0988540649414,64.0988540649414,95.8437423706055,95.8437423706055,117.230880737305,117.230880737305,146.292533874512,146.292533874512,146.292533874512,54.1257934570312,54.1257934570312,86.1333999633789,86.1333999633789,107.581909179688,107.581909179688,107.581909179688,139.13761138916,139.13761138916,139.13761138916,139.13761138916,139.13761138916,45.1392288208008,45.1392288208008,76.4956283569336,76.4956283569336,97.8123550415039,97.8123550415039,97.8123550415039,130.090370178223,130.090370178223,130.090370178223,130.090370178223,130.090370178223,130.090370178223,146.294082641602,146.294082641602,146.294082641602,146.294082641602,146.294082641602,146.294082641602,68.2333984375,68.2333984375,68.2333984375,68.2333984375,90.1379318237305,90.1379318237305,121.886863708496,121.886863708496,142.938346862793,142.938346862793,59.3745803833008,59.3745803833008,80.1698379516602,80.1698379516602,112.319526672363,112.319526672363,133.57576751709,133.57576751709,133.57576751709,50.8518676757812,50.8518676757812,50.8518676757812,50.8518676757812,50.8518676757812,71.5829391479492,71.5829391479492,101.045440673828,101.045440673828,120.268218994141,120.268218994141,120.268218994141,120.268218994141,146.308860778809,146.308860778809,146.308860778809,58.0666656494141,58.0666656494141,89.8210601806641,89.8210601806641,89.8210601806641,110.286514282227,110.286514282227,139.743049621582,139.743049621582,139.743049621582,139.743049621582,46.1963272094727,46.1963272094727,46.1963272094727,46.1963272094727,77.0316314697266,77.0316314697266,77.0316314697266,95.0124740600586,95.0124740600586,118.03882598877,118.03882598877,118.03882598877,118.03882598877,118.03882598877,137.921615600586,137.921615600586,137.921615600586,54.1999359130859,54.1999359130859,54.1999359130859,74.8091659545898,74.8091659545898,106.224601745605,106.224601745605,127.609992980957,127.609992980957,127.609992980957,127.609992980957,127.609992980957,44.691780090332,44.691780090332,44.691780090332,44.691780090332,44.691780090332,65.0279235839844,65.0279235839844,65.0279235839844,65.0279235839844,65.0279235839844,97.4372329711914,97.4372329711914,119.079818725586,119.079818725586,146.308799743652,146.308799743652,146.308799743652,58.2110061645508,58.2110061645508,58.2110061645508,90.0918884277344,90.0918884277344,111.744285583496,111.744285583496,111.744285583496,142.380332946777,142.380332946777,48.6286010742188,48.6286010742188,48.6286010742188,48.6286010742188,80.7683029174805,80.7683029174805,102.412460327148,102.412460327148,102.412460327148,102.412460327148,102.412460327148,135.014831542969,135.014831542969,135.014831542969,146.297889709473,146.297889709473,146.297889709473,146.297889709473,146.297889709473,146.297889709473,74.4088134765625,74.4088134765625,74.4088134765625,74.4088134765625,74.4088134765625,74.4088134765625,95.7310943603516,95.7310943603516,95.7310943603516,95.7310943603516,95.7310943603516,128.463768005371,128.463768005371,146.306671142578,146.306671142578,146.306671142578,66.5438995361328,66.5438995361328,87.546630859375,87.546630859375,87.546630859375,87.546630859375,87.546630859375,87.546630859375,119.752418518066,119.752418518066,119.752418518066,119.752418518066,141.009353637695,141.009353637695,141.009353637695,58.9309692382812,58.9309692382812,80.0481491088867,80.0481491088867,80.0481491088867,80.0481491088867,80.0481491088867,112.121086120605,112.121086120605,112.121086120605,133.307090759277,133.307090759277,133.307090759277,133.307090759277,133.307090759277,51.1909713745117,51.1909713745117,51.1909713745117,72.5055541992188,72.5055541992188,104.646041870117,104.646041870117,104.646041870117,126.355865478516,126.355865478516,44.6359100341797,44.6359100341797,65.4964447021484,65.4964447021484,97.5033493041992,97.5033493041992,117.965751647949,117.965751647949,117.965751647949,117.965751647949,117.965751647949,146.301223754883,146.301223754883,146.301223754883,55.5253601074219,55.5253601074219,87.5959701538086,87.5959701538086,87.5959701538086,108.654479980469,108.654479980469,108.654479980469,108.654479980469,108.654479980469,138.561424255371,138.561424255371,43.4913558959961,43.4913558959961,75.3029403686523,75.3029403686523,75.3029403686523,75.3029403686523,96.2875061035156,96.2875061035156,128.880416870117,128.880416870117,128.880416870117,146.326461791992,146.326461791992,146.326461791992,66.2525024414062,66.2525024414062,87.0472030639648,87.0472030639648,87.0472030639648,87.0472030639648,119.705718994141,119.705718994141,141.019073486328,141.019073486328,57.3324813842773,57.3324813842773,57.3324813842773,78.4526977539062,78.4526977539062,110.458679199219,110.458679199219,131.906555175781,131.906555175781,131.906555175781,48.4148406982422,48.4148406982422,48.4148406982422,69.7951736450195,69.7951736450195,102.064086914062,102.064086914062,123.904861450195,123.904861450195,123.904861450195,146.332466125488,146.332466125488,146.332466125488,61.2042465209961,61.2042465209961,61.2042465209961,61.2042465209961,61.2042465209961,91.8977813720703,91.8977813720703,112.754409790039,112.754409790039,145.022933959961,145.022933959961,145.022933959961,51.1701965332031,51.1701965332031,83.3728561401367,83.3728561401367,83.3728561401367,83.3728561401367,83.3728561401367,83.3728561401367,104.75227355957,104.75227355957,104.75227355957,135.514724731445,135.514724731445,146.33716583252,146.33716583252,146.33716583252,72.1552886962891,72.1552886962891,92.5538101196289,92.5538101196289,123.450309753418,123.450309753418,144.763259887695,144.763259887695,60.9431838989258,60.9431838989258,82.2539672851562,82.2539672851562,82.2539672851562,82.2539672851562,82.2539672851562,114.25373840332,114.25373840332,114.25373840332,114.25373840332,135.431701660156,135.431701660156,51.8967742919922,51.8967742919922,73.0759658813477,73.0759658813477,105.206260681152,105.206260681152,126.647567749023,126.647567749023,126.647567749023,43.8949432373047,43.8949432373047,64.7460327148438,64.7460327148438,97.0076675415039,97.0076675415039,118.251472473145,118.251472473145,146.318130493164,146.318130493164,146.318130493164,56.5535354614258,56.5535354614258,56.5535354614258,56.5535354614258,88.8161392211914,88.8161392211914,88.8161392211914,88.8161392211914,88.8161392211914,88.8161392211914,110.455940246582,110.455940246582,110.455940246582,143.112205505371,143.112205505371,143.112205505371,49.3393096923828,49.3393096923828,81.601692199707,81.601692199707,81.601692199707,102.583152770996,102.583152770996,133.662673950195,133.662673950195,146.317825317383,146.317825317383,146.317825317383,146.317825317383,146.317825317383,146.317825317383,71.8317337036133,71.8317337036133,71.8317337036133,71.8317337036133,71.8317337036133,71.8317337036133,93.403938293457,93.403938293457,125.729507446289,125.729507446289,146.318984985352,146.318984985352,146.318984985352,63.4395599365234,63.4395599365234,63.4395599365234,81.7990570068359,81.7990570068359,113.798324584961,113.798324584961,113.798324584961,113.798324584961,133.337821960449,133.337821960449,133.337821960449,133.337821960449,133.337821960449,133.337821960449,49.0794296264648,49.0794296264648,70.1925277709961,70.1925277709961,102.453987121582,102.453987121582,102.453987121582,124.15779876709,124.15779876709,146.318550109863,146.318550109863,146.318550109863,61.7329406738281,61.7329406738281,94.3169631958008,94.3169631958008,94.3169631958008,115.95157623291,115.95157623291,146.306968688965,146.306968688965,146.306968688965,53.8657531738281,53.8657531738281,53.8657531738281,53.8657531738281,53.8657531738281,85.9253158569336,85.9253158569336,106.773971557617,106.773971557617,106.773971557617,106.773971557617,106.773971557617,106.773971557617,139.751914978027,139.751914978027,139.751914978027,46.6544570922852,46.6544570922852,78.846076965332,78.846076965332,100.481597900391,100.481597900391,133.328125,133.328125,133.328125,146.309150695801,146.309150695801,146.309150695801,71.8969802856445,71.8969802856445,71.8969802856445,71.8969802856445,71.8969802856445,93.8590927124023,93.8590927124023,125.592063903809,125.592063903809,125.592063903809,125.592063903809,145.981323242188,145.981323242188,145.981323242188,145.981323242188,145.981323242188,145.981323242188,64.6196746826172,64.6196746826172,86.4512786865234,86.4512786865234,86.4512786865234,86.4512786865234,86.4512786865234,86.4512786865234,119.624572753906,119.624572753906,141.652755737305,141.652755737305,60.0311737060547,60.0311737060547,81.5349197387695,81.5349197387695,113.593612670898,113.593612670898,135.359649658203,135.359649658203,51.9487075805664,51.9487075805664,73.7142105102539,73.7142105102539,105.314605712891,105.314605712891,105.314605712891,126.686912536621,126.686912536621,43.7540588378906,43.7540588378906,64.7990875244141,64.7990875244141,64.7990875244141,64.7990875244141,64.7990875244141,64.7990875244141,97.5786437988281,97.5786437988281,113.603424072266,113.603424072266,113.603424072266,113.603424072266,113.603424072266],"meminc":[0,0,0,21.4461212158203,0,0,27.4238891601562,0,0,0,0,0,17.9719467163086,0,17.0541763305664,0,0,-85.0077972412109,0,31.6869430541992,0,0,19.6181259155273,0,30.5010604858398,0,-95.7805252075195,0,0,0,0,32.3407363891602,0,20.8653411865234,0,30.7738647460938,0,15.0214920043945,0,0,-80.1773223876953,0,0,21.6488571166992,0,30.3016510009766,0,0,19.6766738891602,0,-87.231575012207,0,19.8794097900391,0,0,0,0,31.2248153686523,0,0,21.0582427978516,0,23.613899230957,0,0,-91.9021835327148,0,32.273323059082,0,21.3837203979492,0,32.2794036865234,0,0,-95.1875152587891,0,30.8327560424805,0,19.6844787597656,0,0,26.764045715332,0,0,18.8971405029297,0,0,-85.551513671875,0,19.6209411621094,0,28.3461151123047,0,19.0247039794922,0,23.487174987793,0,0,-89.6880340576172,0,30.1187362670898,0,0,0,0,0,19.292839050293,0,29.7861709594727,0,0,10.4928512573242,0,0,-75.1167449951172,0,0,0,21.5088272094727,0,30.0532379150391,0,19.2891845703125,0,0,0,0,-85.1545028686523,0,21.0563125610352,0,28.9311828613281,0,0,19.87939453125,0,0,0,19.5504608154297,0,0,-84.4300384521484,0,32.0749893188477,0,20.2671127319336,0,0,0,0,0,29.9767303466797,0,0,0,-95.4374237060547,0,31.2963485717773,0,0,0,0,20.5973281860352,0,0,0,0,29.4587249755859,0,0,16.2039260864258,0,0,-80.9617309570312,0,21.1227035522461,0,30.0559844970703,0,0,0,20.0095901489258,0,0,0,-85.1572799682617,0,0,20.7362747192383,0,0,0,0,31.7531967163086,0,21.117805480957,0,0,21.3196716308594,0,0,-84.4267044067383,0,31.1026382446289,0,0,0,0,20.5304183959961,0,30.4370956420898,0,-95.1234436035156,0,31.8063049316406,0,21.3217620849609,0,0,0,0,32.667366027832,0,11.6757888793945,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,7.87326812744141,0,0,0,0,31.8186264038086,0,20.2683029174805,0,29.1289901733398,0,14.4330596923828,0,0,0,-77.2779693603516,0,0,21.1894683837891,0,30.0417251586914,0,0,0,0,20.2686080932617,0,-83.8982620239258,0,21.383659362793,0,0,29.5891342163086,0,20.0694808959961,0,-84.6207809448242,0,21.0615158081055,0,31.7448883056641,0,21.3871383666992,0,29.061653137207,0,0,-92.1667404174805,0,32.0076065063477,0,21.4485092163086,0,0,31.5557022094727,0,0,0,0,-93.9983825683594,0,31.3563995361328,0,21.3167266845703,0,0,32.2780151367188,0,0,0,0,0,16.2037124633789,0,0,0,0,0,-78.0606842041016,0,0,0,21.9045333862305,0,31.7489318847656,0,21.0514831542969,0,-83.5637664794922,0,20.7952575683594,0,32.1496887207031,0,21.2562408447266,0,0,-82.7238998413086,0,0,0,0,20.731071472168,0,29.4625015258789,0,19.2227783203125,0,0,0,26.040641784668,0,0,-88.2421951293945,0,31.75439453125,0,0,20.4654541015625,0,29.4565353393555,0,0,0,-93.5467224121094,0,0,0,30.8353042602539,0,0,17.980842590332,0,23.0263519287109,0,0,0,0,19.8827896118164,0,0,-83.7216796875,0,0,20.6092300415039,0,31.4154357910156,0,21.3853912353516,0,0,0,0,-82.918212890625,0,0,0,0,20.3361434936523,0,0,0,0,32.409309387207,0,21.6425857543945,0,27.2289810180664,0,0,-88.0977935791016,0,0,31.8808822631836,0,21.6523971557617,0,0,30.6360473632812,0,-93.7517318725586,0,0,0,32.1397018432617,0,21.644157409668,0,0,0,0,32.6023712158203,0,0,11.2830581665039,0,0,0,0,0,-71.8890762329102,0,0,0,0,0,21.3222808837891,0,0,0,0,32.7326736450195,0,17.842903137207,0,0,-79.7627716064453,0,21.0027313232422,0,0,0,0,0,32.2057876586914,0,0,0,21.2569351196289,0,0,-82.0783843994141,0,21.1171798706055,0,0,0,0,32.0729370117188,0,0,21.1860046386719,0,0,0,0,-82.1161193847656,0,0,21.314582824707,0,32.1404876708984,0,0,21.7098236083984,0,-81.7199554443359,0,20.8605346679688,0,32.0069046020508,0,20.46240234375,0,0,0,0,28.3354721069336,0,0,-90.7758636474609,0,32.0706100463867,0,0,21.0585098266602,0,0,0,0,29.9069442749023,0,-95.070068359375,0,31.8115844726562,0,0,0,20.9845657348633,0,32.5929107666016,0,0,17.446044921875,0,0,-80.0739593505859,0,20.7947006225586,0,0,0,32.6585159301758,0,21.3133544921875,0,-83.6865921020508,0,0,21.1202163696289,0,32.0059814453125,0,21.4478759765625,0,0,-83.4917144775391,0,0,21.3803329467773,0,32.268913269043,0,21.8407745361328,0,0,22.427604675293,0,0,-85.1282196044922,0,0,0,0,30.6935348510742,0,20.8566284179688,0,32.2685241699219,0,0,-93.8527374267578,0,32.2026596069336,0,0,0,0,0,21.3794174194336,0,0,30.762451171875,0,10.8224411010742,0,0,-74.1818771362305,0,20.3985214233398,0,30.8964996337891,0,21.3129501342773,0,-83.8200759887695,0,21.3107833862305,0,0,0,0,31.9997711181641,0,0,0,21.1779632568359,0,-83.5349273681641,0,21.1791915893555,0,32.1302947998047,0,21.4413070678711,0,0,-82.7526245117188,0,20.8510894775391,0,32.2616348266602,0,21.2438049316406,0,28.0666580200195,0,0,-89.7645950317383,0,0,0,32.2626037597656,0,0,0,0,0,21.6398010253906,0,0,32.6562652587891,0,0,-93.7728958129883,0,32.2623825073242,0,0,20.9814605712891,0,31.0795211791992,0,12.6551513671875,0,0,0,0,0,-74.4860916137695,0,0,0,0,0,21.5722045898438,0,32.325569152832,0,20.5894775390625,0,0,-82.8794250488281,0,0,18.3594970703125,0,31.999267578125,0,0,0,19.5394973754883,0,0,0,0,0,-84.2583923339844,0,21.1130981445312,0,32.2614593505859,0,0,21.7038116455078,0,22.1607513427734,0,0,-84.5856094360352,0,32.5840225219727,0,0,21.6346130371094,0,30.3553924560547,0,0,-92.4412155151367,0,0,0,0,32.0595626831055,0,20.8486557006836,0,0,0,0,0,32.9779434204102,0,0,-93.0974578857422,0,32.1916198730469,0,21.6355209350586,0,32.8465270996094,0,0,12.9810256958008,0,0,-74.4121704101562,0,0,0,0,21.9621124267578,0,31.7329711914062,0,0,0,20.3892593383789,0,0,0,0,0,-81.3616485595703,0,21.8316040039062,0,0,0,0,0,33.1732940673828,0,22.0281829833984,0,-81.62158203125,0,21.5037460327148,0,32.0586929321289,0,21.7660369873047,0,-83.4109420776367,0,21.7655029296875,0,31.6003952026367,0,0,21.3723068237305,0,-82.9328536987305,0,21.0450286865234,0,0,0,0,0,32.7795562744141,0,16.0247802734375,0,0,0,0],"filename":[null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmp7AngaP/file3ba950038b4a.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    784.964    791.4180   1106.2905    797.3110
#>    compute_pi0(m * 10)   7865.182   7894.3130   8004.4153   7963.6775
#>   compute_pi0(m * 100)  78922.878  79197.2850  80252.5285  79522.7855
#>         compute_pi1(m)    157.390    191.9395    227.9121    211.9925
#>    compute_pi1(m * 10)   1262.583   1348.1545   7051.9219   1415.1665
#>   compute_pi1(m * 100)  12696.498  13116.3115  17938.8587  17877.3530
#>  compute_pi1(m * 1000) 252175.027 311324.5515 348194.4333 366318.1885
#>           uq        max neval
#>     805.0290   6870.010    20
#>    8070.8960   8431.918    20
#>   80174.5375  86115.562    20
#>     284.3965    312.081    20
#>    1452.8225 114371.084    20
#>   20379.9890  29959.172    20
#>  373761.9175 493773.429    20
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
#>   memory_copy1(n) 5303.66457 5149.16186 720.41426 4449.96396 3698.10577
#>   memory_copy2(n)   92.98136   90.51234  14.48172   82.19918   69.33438
#>  pre_allocate1(n)   20.48813   19.90476   4.36514   17.62014   14.63096
#>  pre_allocate2(n)  201.52290  194.06326  28.34799  169.89504  145.57172
#>     vectorized(n)    1.00000    1.00000   1.00000    1.00000    1.00000
#>         max neval
#>  110.873521    10
#>    3.530643    10
#>    2.239274    10
#>    5.144965    10
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
#>  f1(df) 244.4873 248.0854 81.41178 241.8914 65.94354 29.92245     5
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
