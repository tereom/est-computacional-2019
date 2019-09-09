
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
#>    id           a         b         c        d
#> 1   1 -0.09106974 3.1316970 1.5524429 3.890669
#> 2   2  0.59335180 1.6750473 2.4839951 4.208494
#> 3   3  0.37340784 2.6627255 2.8823414 4.558897
#> 4   4 -0.24137666 0.4587353 3.8014011 2.355818
#> 5   5 -0.53494975 1.5612779 2.0507393 3.022445
#> 6   6 -0.26368884 3.2401406 2.7280984 4.124810
#> 7   7  1.45821013 1.4666610 0.9953887 2.580550
#> 8   8  0.85102446 3.7080059 3.2787138 3.642504
#> 9   9  0.14584979 1.4234618 2.7913564 4.789051
#> 10 10 -0.91608084 3.8442705 3.4068177 3.338610
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.1374678
mean(df$b)
#> [1] 2.317202
mean(df$c)
#> [1] 2.597129
mean(df$d)
#> [1] 3.651185
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.1374678 2.3172023 2.5971295 3.6511848
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
#> [1] 0.1374678 2.3172023 2.5971295 3.6511848
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
#> [1] 5.5000000 0.1374678 2.3172023 2.5971295 3.6511848
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
#> [1] 5.50000000 0.02739002 2.16888642 2.75972741 3.76658635
col_describe(df, mean)
#> [1] 5.5000000 0.1374678 2.3172023 2.5971295 3.6511848
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
#> 5.5000000 0.1374678 2.3172023 2.5971295 3.6511848
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
#>   2.933   0.128   3.061
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.020   0.004   1.901
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
#>  12.061   0.878   9.064
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
#>   0.123   0.000   0.123
plyr_st
#>    user  system elapsed 
#>   5.435   0.008   5.442
est_l_st
#>    user  system elapsed 
#>  65.292   1.359  66.656
est_r_st
#>    user  system elapsed 
#>   0.405   0.004   0.409
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

<!--html_preserve--><div id="htmlwidget-10db746e4286a38bbc4b" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-10db746e4286a38bbc4b">{"x":{"message":{"prof":{"time":[1,1,1,1,1,2,2,2,3,3,4,4,5,5,5,5,5,5,6,6,6,7,7,7,8,8,8,9,9,9,10,10,11,11,11,12,12,13,13,13,13,13,13,14,14,14,15,15,15,16,16,16,16,17,17,17,18,18,18,18,19,19,19,20,20,21,21,21,22,22,22,23,23,24,24,25,25,26,26,26,27,27,27,28,28,28,29,29,29,30,30,31,31,31,32,32,32,33,33,33,34,34,34,35,35,36,36,37,37,37,37,37,37,38,38,38,39,39,40,40,40,40,40,41,41,42,42,43,43,44,44,45,45,46,46,46,47,47,47,48,48,49,49,49,49,49,50,50,50,50,50,50,51,51,51,51,52,52,52,52,53,53,54,54,55,55,55,56,56,57,57,57,58,58,58,58,59,59,60,60,60,61,61,62,62,63,63,64,64,64,65,65,65,65,66,66,67,67,67,68,68,69,69,70,70,70,70,70,71,71,71,72,72,72,73,73,74,74,75,75,75,76,76,76,76,76,77,77,78,78,78,79,79,80,80,81,81,81,81,81,82,82,83,83,83,83,84,84,85,85,86,86,86,87,87,87,88,88,88,88,88,89,89,89,89,90,90,90,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,103,103,103,104,104,105,105,106,106,106,107,107,107,108,108,109,109,110,110,110,111,111,111,111,111,112,112,112,113,113,113,114,114,114,114,115,115,116,116,116,117,117,117,118,118,118,119,119,119,119,119,120,120,120,121,121,121,121,121,122,122,123,123,124,124,125,125,126,126,127,127,127,128,128,129,129,129,129,130,130,130,131,131,131,131,131,132,132,133,133,133,134,134,134,135,135,135,135,135,136,136,136,137,137,137,137,137,137,138,138,139,139,140,140,140,140,140,140,141,141,141,141,141,142,142,142,142,143,143,143,144,144,144,145,145,146,146,146,146,146,147,147,147,148,148,149,149,149,149,150,150,150,150,151,151,152,152,152,152,152,153,153,154,154,154,154,155,155,155,155,155,155,156,156,156,157,157,158,158,158,159,159,160,160,160,160,160,161,161,161,161,161,162,162,162,163,163,163,163,164,164,165,165,165,165,165,165,166,166,166,166,167,167,167,168,168,168,169,169,170,170,171,171,171,171,172,172,172,173,173,174,174,175,175,175,176,176,176,176,176,177,177,177,178,178,179,179,179,179,179,179,180,180,181,181,181,181,181,182,182,182,183,183,183,184,184,184,184,184,184,185,185,185,185,185,186,186,187,187,187,187,188,188,189,189,189,190,190,191,191,191,192,192,192,193,193,194,194,195,195,195,195,196,196,197,197,197,198,198,198,199,199,200,200,200,201,201,202,202,202,203,203,204,204,204,205,205,206,206,207,207,207,208,208,209,209,210,210,210,210,210,211,211,211,212,212,212,213,213,214,214,215,215,215,215,216,216,217,217,218,218,218,218,218,219,219,219,219,220,220,221,221,222,222,222,223,223,224,224,225,225,225,226,226,226,226,227,227,228,228,228,229,229,229,230,230,231,231,232,232,232,233,233,233,234,234,235,235,235,236,236,236,236,236,236,237,237,237,237,237,238,238,239,239,239,239,239,240,240,241,241,242,242,243,243,243,244,244,244,244,244,245,245,245,246,246,246,247,247,247,248,248,248,249,249,249,249,250,250,251,251,252,252,252,253,253,253,254,254,255,255,255,255,255,255,256,256,256,257,257,257,258,258,258,258,258,258,259,259,260,260,260,260,261,261,261,262,262,262,262,262,262,263,263,263,264,264,264,265,265,266,266,266,266,267,267,267,268,268,268,269,269,269,269,270,270,271,271,272,272,272,272,272,272,273,273,273,273,273,273,274,274,275,275,276,276,276,276,276,276,277,277,278,278,278,279,279,280,280,280,280,281,282,282,283,283,283,284,284,285,285,285,286,286,287,287,288,288,288,289,289,289,289,289,289,290,290,290,291,291,291,291,291,292,292,292,292,292,293,293,293,294,294,295,295,295,296,296,297,297,297,298,298,298,298,299,299,299,299,299,300,300,301,301,301,301,301,301,302,302,302,303,303,304,304,304,305,305,306,306,306,306,307,307,308,308,308,308,308,309,309,310,310,311,311,311,311,311,312,312,313,313,314,314,315,315,316,316,316,316,316],"depth":[5,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1],"label":["NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","$","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1],"linenum":[null,null,null,9,9,null,9,9,9,9,10,10,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,null,null,9,9,9,9,10,10,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,11,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,11,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,11,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,11,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,11,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,null,11,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,10,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,13],"memalloc":[56.3339157104492,56.3339157104492,56.3339157104492,56.3339157104492,56.3339157104492,74.9625015258789,74.9625015258789,74.9625015258789,99.6296844482422,99.6296844482422,114.257926940918,114.257926940918,135.641799926758,135.641799926758,135.641799926758,135.641799926758,135.641799926758,135.641799926758,146.268028259277,146.268028259277,146.268028259277,63.0313568115234,63.0313568115234,63.0313568115234,81.7297973632812,81.7297973632812,81.7297973632812,108.694427490234,108.694427490234,108.694427490234,126.009262084961,126.009262084961,146.279312133789,146.279312133789,146.279312133789,55.87744140625,55.87744140625,83.4330902099609,83.4330902099609,83.4330902099609,83.4330902099609,83.4330902099609,83.4330902099609,101.541259765625,101.541259765625,101.541259765625,128.312423706055,128.312423706055,128.312423706055,145.040580749512,145.040580749512,145.040580749512,145.040580749512,56.6662521362305,56.6662521362305,56.6662521362305,74.5081253051758,74.5081253051758,74.5081253051758,74.5081253051758,99.8259658813477,99.8259658813477,99.8259658813477,116.552574157715,116.552574157715,141.67268371582,141.67268371582,141.67268371582,146.266929626465,146.266929626465,146.266929626465,67.6949768066406,67.6949768066406,85.5399551391602,85.5399551391602,110.991744995117,110.991744995117,128.57201385498,128.57201385498,128.57201385498,146.281921386719,146.281921386719,146.281921386719,58.4449996948242,58.4449996948242,58.4449996948242,85.6038208007812,85.6038208007812,85.6038208007812,100.295799255371,100.295799255371,127.721839904785,127.721839904785,127.721839904785,146.286773681641,146.286773681641,146.286773681641,61.204216003418,61.204216003418,61.204216003418,79.436408996582,79.436408996582,79.436408996582,105.879516601562,105.879516601562,122.343879699707,122.343879699707,146.296340942383,146.296340942383,146.296340942383,146.296340942383,146.296340942383,146.296340942383,52.6074295043945,52.6074295043945,52.6074295043945,80.4939117431641,80.4939117431641,98.7362060546875,98.7362060546875,98.7362060546875,98.7362060546875,98.7362060546875,124.520408630371,124.520408630371,142.232528686523,142.232528686523,56.48095703125,56.48095703125,74.720817565918,74.720817565918,102.481559753418,102.481559753418,119.86393737793,119.86393737793,119.86393737793,146.302658081055,146.302658081055,146.302658081055,51.4345169067383,51.4345169067383,78.8608551025391,78.8608551025391,78.8608551025391,78.8608551025391,78.8608551025391,96.7000122070312,96.7000122070312,96.7000122070312,96.7000122070312,96.7000122070312,96.7000122070312,123.273948669434,123.273948669434,123.273948669434,123.273948669434,141.774909973145,141.774909973145,141.774909973145,141.774909973145,56.0286865234375,56.0286865234375,74.9870529174805,74.9870529174805,103.393173217773,103.393173217773,103.393173217773,121.694595336914,121.694595336914,146.299308776855,146.299308776855,146.299308776855,54.0604476928711,54.0604476928711,54.0604476928711,54.0604476928711,82.0740127563477,82.0740127563477,100.174613952637,100.174613952637,100.174613952637,126.672355651855,126.672355651855,144.385818481445,144.385818481445,59.5139999389648,59.5139999389648,77.7526321411133,77.7526321411133,77.7526321411133,105.502883911133,105.502883911133,105.502883911133,105.502883911133,123.212600708008,123.212600708008,146.307304382324,146.307304382324,146.307304382324,53.3401641845703,53.3401641845703,81.3522186279297,81.3522186279297,99.6628875732422,99.6628875732422,99.6628875732422,99.6628875732422,99.6628875732422,123.283317565918,123.283317565918,123.283317565918,137.451850891113,137.451850891113,137.451850891113,51.5733642578125,51.5733642578125,70.0138168334961,70.0138168334961,98.0926895141602,98.0926895141602,98.0926895141602,115.604347229004,115.604347229004,115.604347229004,115.604347229004,115.604347229004,143.351028442383,143.351028442383,49.4098739624023,49.4098739624023,49.4098739624023,77.5574722290039,77.5574722290039,96.9151611328125,96.9151611328125,124.598175048828,124.598175048828,124.598175048828,124.598175048828,124.598175048828,142.701454162598,142.701454162598,58.3959732055664,58.3959732055664,58.3959732055664,58.3959732055664,75.3844909667969,75.3844909667969,103.001647949219,103.001647949219,120.38712310791,120.38712310791,120.38712310791,146.294563293457,146.294563293457,146.294563293457,54.0752639770508,54.0752639770508,54.0752639770508,54.0752639770508,54.0752639770508,81.9566650390625,81.9566650390625,81.9566650390625,81.9566650390625,101.372520446777,101.372520446777,101.372520446777,129.776718139648,129.776718139648,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,146.311164855957,42.7233428955078,42.7233428955078,42.7233428955078,61.02880859375,61.02880859375,61.02880859375,61.02880859375,61.02880859375,79.7949371337891,79.7949371337891,108.062400817871,108.062400817871,126.887176513672,126.887176513672,126.887176513672,146.306282043457,146.306282043457,146.306282043457,58.9939346313477,58.9939346313477,86.1541595458984,86.1541595458984,103.671607971191,103.671607971191,103.671607971191,130.69149017334,130.69149017334,130.69149017334,130.69149017334,130.69149017334,146.301330566406,146.301330566406,146.301330566406,63.1975631713867,63.1975631713867,63.1975631713867,81.0361480712891,81.0361480712891,81.0361480712891,81.0361480712891,108.455986022949,108.455986022949,126.167404174805,126.167404174805,126.167404174805,146.308921813965,146.308921813965,146.308921813965,57.4231643676758,57.4231643676758,57.4231643676758,84.3799743652344,84.3799743652344,84.3799743652344,84.3799743652344,84.3799743652344,96.7740478515625,96.7740478515625,96.7740478515625,125.053016662598,125.053016662598,125.053016662598,125.053016662598,125.053016662598,143.943199157715,143.943199157715,59.1976852416992,59.1976852416992,78.2176742553711,78.2176742553711,105.901466369629,105.901466369629,123.286163330078,123.286163330078,146.311256408691,146.311256408691,146.311256408691,53.8812637329102,53.8812637329102,81.369384765625,81.369384765625,81.369384765625,81.369384765625,98.0258178710938,98.0258178710938,98.0258178710938,125.053581237793,125.053581237793,125.053581237793,125.053581237793,125.053581237793,143.479759216309,143.479759216309,57.8177719116211,57.8177719116211,57.8177719116211,76.1184158325195,76.1184158325195,76.1184158325195,101.119003295898,101.119003295898,101.119003295898,101.119003295898,101.119003295898,119.224700927734,119.224700927734,119.224700927734,145.139381408691,145.139381408691,145.139381408691,145.139381408691,145.139381408691,145.139381408691,50.8695297241211,50.8695297241211,75.8667068481445,75.8667068481445,94.3717346191406,94.3717346191406,94.3717346191406,94.3717346191406,94.3717346191406,94.3717346191406,120.745628356934,120.745628356934,120.745628356934,120.745628356934,120.745628356934,138.913848876953,138.913848876953,138.913848876953,138.913848876953,51.7236022949219,51.7236022949219,51.7236022949219,70.0910415649414,70.0910415649414,70.0910415649414,97.9062576293945,97.9062576293945,116.338264465332,116.338264465332,116.338264465332,116.338264465332,116.338264465332,143.041862487793,143.041862487793,143.041862487793,47.5256271362305,47.5256271362305,74.6872100830078,74.6872100830078,74.6872100830078,74.6872100830078,92.797981262207,92.797981262207,92.797981262207,92.797981262207,119.892288208008,119.892288208008,137.807815551758,137.807815551758,137.807815551758,137.807815551758,137.807815551758,53.0371704101562,53.0371704101562,71.479850769043,71.479850769043,71.479850769043,71.479850769043,98.5672607421875,98.5672607421875,98.5672607421875,98.5672607421875,98.5672607421875,98.5672607421875,116.740264892578,116.740264892578,116.740264892578,142.788703918457,142.788703918457,48.5803985595703,48.5803985595703,48.5803985595703,76.0719604492188,76.0719604492188,94.5696792602539,94.5696792602539,94.5696792602539,94.5696792602539,94.5696792602539,122.507423400879,122.507423400879,122.507423400879,122.507423400879,122.507423400879,141.472053527832,141.472053527832,141.472053527832,57.3748779296875,57.3748779296875,57.3748779296875,57.3748779296875,75.6146011352539,75.6146011352539,102.57608795166,102.57608795166,102.57608795166,102.57608795166,102.57608795166,102.57608795166,120.945709228516,120.945709228516,120.945709228516,120.945709228516,146.268829345703,146.268829345703,146.268829345703,55.7291107177734,55.7291107177734,55.7291107177734,82.4932632446289,82.4932632446289,100.593414306641,100.593414306641,127.161613464355,127.161613464355,127.161613464355,127.161613464355,145.462730407715,145.462730407715,145.462730407715,61.0419158935547,61.0419158935547,79.2854919433594,79.2854919433594,107.358589172363,107.358589172363,107.358589172363,124.612167358398,124.612167358398,124.612167358398,124.612167358398,124.612167358398,146.258430480957,146.258430480957,146.258430480957,56.3913269042969,56.3913269042969,83.5611190795898,83.5611190795898,83.5611190795898,83.5611190795898,83.5611190795898,83.5611190795898,102.061500549316,102.061500549316,129.548278808594,129.548278808594,129.548278808594,129.548278808594,129.548278808594,146.274276733398,146.274276733398,146.274276733398,64.5242462158203,64.5242462158203,64.5242462158203,83.8043746948242,83.8043746948242,83.8043746948242,83.8043746948242,83.8043746948242,83.8043746948242,111.548614501953,111.548614501953,111.548614501953,111.548614501953,111.548614501953,128.930671691895,128.930671691895,146.314292907715,146.314292907715,146.314292907715,146.314292907715,59.3390884399414,59.3390884399414,85.9006042480469,85.9006042480469,85.9006042480469,103.744964599609,103.744964599609,130.44083404541,130.44083404541,130.44083404541,146.315536499023,146.315536499023,146.315536499023,64.1347351074219,64.1347351074219,81.7127227783203,81.7127227783203,109.652389526367,109.652389526367,109.652389526367,109.652389526367,127.295959472656,127.295959472656,146.251670837402,146.251670837402,146.251670837402,61.1818161010742,61.1818161010742,61.1818161010742,88.3993835449219,88.3993835449219,107.161903381348,107.161903381348,107.161903381348,134.772933959961,134.772933959961,146.315498352051,146.315498352051,146.315498352051,66.8230209350586,66.8230209350586,84.7919998168945,84.7919998168945,84.7919998168945,112.401428222656,112.401428222656,130.698318481445,130.698318481445,44.9542541503906,44.9542541503906,44.9542541503906,63.8430938720703,63.8430938720703,91.3924331665039,91.3924331665039,109.034194946289,109.034194946289,109.034194946289,109.034194946289,109.034194946289,137.102020263672,137.102020263672,137.102020263672,67.8078079223633,67.8078079223633,67.8078079223633,70.2721786499023,70.2721786499023,88.8323211669922,88.8323211669922,116.116630554199,116.116630554199,116.116630554199,116.116630554199,134.154624938965,134.154624938965,47.3827590942383,47.3827590942383,65.8774337768555,65.8774337768555,65.8774337768555,65.8774337768555,65.8774337768555,92.4406814575195,92.4406814575195,92.4406814575195,92.4406814575195,107.198394775391,107.198394775391,128.513565063477,128.513565063477,142.61270904541,142.61270904541,142.61270904541,56.1721572875977,56.1721572875977,74.6008911132812,74.6008911132812,102.279151916504,102.279151916504,102.279151916504,120.642189025879,120.642189025879,120.642189025879,120.642189025879,145.762214660645,145.762214660645,47.7124328613281,47.7124328613281,47.7124328613281,71.3231964111328,71.3231964111328,71.3231964111328,89.8157958984375,89.8157958984375,118.278381347656,118.278381347656,135.859481811523,135.859481811523,135.859481811523,49.9436187744141,49.9436187744141,49.9436187744141,68.2381286621094,68.2381286621094,95.982048034668,95.982048034668,95.982048034668,114.087448120117,114.087448120117,114.087448120117,114.087448120117,114.087448120117,114.087448120117,138.420684814453,138.420684814453,138.420684814453,138.420684814453,138.420684814453,43.7137451171875,43.7137451171875,69.8779449462891,69.8779449462891,69.8779449462891,69.8779449462891,69.8779449462891,88.0415267944336,88.0415267944336,114.336357116699,114.336357116699,130.990417480469,130.990417480469,44.5033111572266,44.5033111572266,44.5033111572266,62.7993927001953,62.7993927001953,62.7993927001953,62.7993927001953,62.7993927001953,87.6513137817383,87.6513137817383,87.6513137817383,104.961929321289,104.961929321289,104.961929321289,132.960327148438,132.960327148438,132.960327148438,146.272537231445,146.272537231445,146.272537231445,65.8124084472656,65.8124084472656,65.8124084472656,65.8124084472656,84.5658950805664,84.5658950805664,112.630187988281,112.630187988281,131.318695068359,131.318695068359,131.318695068359,128.532562255859,128.532562255859,128.532562255859,60.1776885986328,60.1776885986328,87.850341796875,87.850341796875,87.850341796875,87.850341796875,87.850341796875,87.850341796875,106.079200744629,106.079200744629,106.079200744629,131.917068481445,131.917068481445,131.917068481445,146.277976989746,146.277976989746,146.277976989746,146.277976989746,146.277976989746,146.277976989746,64.8317337036133,64.8317337036133,83.3884353637695,83.3884353637695,83.3884353637695,83.3884353637695,109.288185119629,109.288185119629,109.288185119629,126.795448303223,126.795448303223,126.795448303223,126.795448303223,126.795448303223,126.795448303223,146.268692016602,146.268692016602,146.268692016602,57.0960006713867,57.0960006713867,57.0960006713867,84.1114196777344,84.1114196777344,102.273750305176,102.273750305176,102.273750305176,102.273750305176,129.222946166992,129.222946166992,129.222946166992,146.270935058594,146.270935058594,146.270935058594,62.8671798706055,62.8671798706055,62.8671798706055,62.8671798706055,81.2265625,81.2265625,108.110908508301,108.110908508301,126.077087402344,126.077087402344,126.077087402344,126.077087402344,126.077087402344,126.077087402344,146.272499084473,146.272499084473,146.272499084473,146.272499084473,146.272499084473,146.272499084473,59.8493881225586,59.8493881225586,86.2750930786133,86.2750930786133,104.372489929199,104.372489929199,104.372489929199,104.372489929199,104.372489929199,104.372489929199,132.108734130859,132.108734130859,146.270179748535,146.270179748535,146.270179748535,64.8309555053711,64.8309555053711,83.4506301879883,83.4506301879883,83.4506301879883,83.4506301879883,110.658065795898,129.342849731445,129.342849731445,73.934440612793,73.934440612793,73.934440612793,61.095329284668,61.095329284668,88.4347229003906,88.4347229003906,88.4347229003906,106.791290283203,106.791290283203,132.426971435547,132.426971435547,146.259864807129,146.259864807129,146.259864807129,64.9651870727539,64.9651870727539,64.9651870727539,64.9651870727539,64.9651870727539,64.9651870727539,83.5188064575195,83.5188064575195,83.5188064575195,110.530448913574,110.530448913574,110.530448913574,110.530448913574,110.530448913574,128.952987670898,128.952987670898,128.952987670898,128.952987670898,128.952987670898,44.0510559082031,44.0510559082031,44.0510559082031,61.8838958740234,61.8838958740234,89.6815414428711,89.6815414428711,89.6815414428711,108.038558959961,108.038558959961,135.509483337402,135.509483337402,135.509483337402,146.26146697998,146.26146697998,146.26146697998,146.26146697998,67.8495559692383,67.8495559692383,67.8495559692383,67.8495559692383,67.8495559692383,86.4685668945312,86.4685668945312,114.527893066406,114.527893066406,114.527893066406,114.527893066406,114.527893066406,114.527893066406,132.42610168457,132.42610168457,132.42610168457,46.2806091308594,46.2806091308594,64.3753890991211,64.3753890991211,64.3753890991211,91.7793273925781,91.7793273925781,109.545974731445,109.545974731445,109.545974731445,109.545974731445,137.802337646484,137.802337646484,44.1180267333984,44.1180267333984,44.1180267333984,44.1180267333984,44.1180267333984,71.7185211181641,71.7185211181641,90.2721252441406,90.2721252441406,118.266387939453,118.266387939453,118.266387939453,118.266387939453,118.266387939453,137.016654968262,137.016654968262,50.5243911743164,50.5243911743164,68.7502288818359,68.7502288818359,96.6134185791016,96.6134185791016,113.555709838867,113.555709838867,113.555709838867,113.555709838867,113.555709838867],"meminc":[0,0,0,0,0,18.6285858154297,0,0,24.6671829223633,0,14.6282424926758,0,21.3838729858398,0,0,0,0,0,10.6262283325195,0,0,-83.2366714477539,0,0,18.6984405517578,0,0,26.9646301269531,0,0,17.3148345947266,0,20.2700500488281,0,0,-90.4018707275391,0,27.5556488037109,0,0,0,0,0,18.1081695556641,0,0,26.7711639404297,0,0,16.728157043457,0,0,0,-88.3743286132812,0,0,17.8418731689453,0,0,0,25.3178405761719,0,0,16.7266082763672,0,25.1201095581055,0,0,4.59424591064453,0,0,-78.5719528198242,0,17.8449783325195,0,25.451789855957,0,17.5802688598633,0,0,17.7099075317383,0,0,-87.8369216918945,0,0,27.158821105957,0,0,14.6919784545898,0,27.4260406494141,0,0,18.5649337768555,0,0,-85.0825576782227,0,0,18.2321929931641,0,0,26.4431076049805,0,16.4643630981445,0,23.9524612426758,0,0,0,0,0,-93.6889114379883,0,0,27.8864822387695,0,18.2422943115234,0,0,0,0,25.7842025756836,0,17.7121200561523,0,-85.7515716552734,0,18.239860534668,0,27.7607421875,0,17.3823776245117,0,0,26.438720703125,0,0,-94.8681411743164,0,27.4263381958008,0,0,0,0,17.8391571044922,0,0,0,0,0,26.5739364624023,0,0,0,18.5009613037109,0,0,0,-85.746223449707,0,18.958366394043,0,28.406120300293,0,0,18.3014221191406,0,24.6047134399414,0,0,-92.2388610839844,0,0,0,28.0135650634766,0,18.1006011962891,0,0,26.4977416992188,0,17.7134628295898,0,-84.8718185424805,0,18.2386322021484,0,0,27.7502517700195,0,0,0,17.709716796875,0,23.0947036743164,0,0,-92.9671401977539,0,28.0120544433594,0,18.3106689453125,0,0,0,0,23.6204299926758,0,0,14.1685333251953,0,0,-85.8784866333008,0,18.4404525756836,0,28.0788726806641,0,0,17.5116577148438,0,0,0,0,27.7466812133789,0,-93.9411544799805,0,0,28.1475982666016,0,19.3576889038086,0,27.6830139160156,0,0,0,0,18.1032791137695,0,-84.3054809570312,0,0,0,16.9885177612305,0,27.6171569824219,0,17.3854751586914,0,0,25.9074401855469,0,0,-92.2192993164062,0,0,0,0,27.8814010620117,0,0,0,19.4158554077148,0,0,28.4041976928711,0,16.5344467163086,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.587821960449,0,0,18.3054656982422,0,0,0,0,18.7661285400391,0,28.267463684082,0,18.8247756958008,0,0,19.4191055297852,0,0,-87.3123474121094,0,27.1602249145508,0,17.517448425293,0,0,27.0198822021484,0,0,0,0,15.6098403930664,0,0,-83.1037673950195,0,0,17.8385848999023,0,0,0,27.4198379516602,0,17.7114181518555,0,0,20.1415176391602,0,0,-88.8857574462891,0,0,26.9568099975586,0,0,0,0,12.3940734863281,0,0,28.2789688110352,0,0,0,0,18.8901824951172,0,-84.7455139160156,0,19.0199890136719,0,27.6837921142578,0,17.3846969604492,0,23.0250930786133,0,0,-92.4299926757812,0,27.4881210327148,0,0,0,16.6564331054688,0,0,27.0277633666992,0,0,0,0,18.4261779785156,0,-85.6619873046875,0,0,18.3006439208984,0,0,25.0005874633789,0,0,0,0,18.1056976318359,0,0,25.914680480957,0,0,0,0,0,-94.2698516845703,0,24.9971771240234,0,18.5050277709961,0,0,0,0,0,26.373893737793,0,0,0,0,18.1682205200195,0,0,0,-87.1902465820312,0,0,18.3674392700195,0,0,27.8152160644531,0,18.4320068359375,0,0,0,0,26.7035980224609,0,0,-95.5162353515625,0,27.1615829467773,0,0,0,18.1107711791992,0,0,0,27.0943069458008,0,17.91552734375,0,0,0,0,-84.7706451416016,0,18.4426803588867,0,0,0,27.0874099731445,0,0,0,0,0,18.1730041503906,0,0,26.0484390258789,0,-94.2083053588867,0,0,27.4915618896484,0,18.4977188110352,0,0,0,0,27.937744140625,0,0,0,0,18.9646301269531,0,0,-84.0971755981445,0,0,0,18.2397232055664,0,26.9614868164062,0,0,0,0,0,18.3696212768555,0,0,0,25.3231201171875,0,0,-90.5397186279297,0,0,26.7641525268555,0,18.1001510620117,0,26.5681991577148,0,0,0,18.3011169433594,0,0,-84.4208145141602,0,18.2435760498047,0,28.0730972290039,0,0,17.2535781860352,0,0,0,0,21.6462631225586,0,0,-89.8671035766602,0,27.169792175293,0,0,0,0,0,18.5003814697266,0,27.4867782592773,0,0,0,0,16.7259979248047,0,0,-81.7500305175781,0,0,19.2801284790039,0,0,0,0,0,27.7442398071289,0,0,0,0,17.3820571899414,0,17.3836212158203,0,0,0,-86.9752044677734,0,26.5615158081055,0,0,17.8443603515625,0,26.6958694458008,0,0,15.8747024536133,0,0,-82.1808013916016,0,17.5779876708984,0,27.9396667480469,0,0,0,17.6435699462891,0,18.9557113647461,0,0,-85.0698547363281,0,0,27.2175674438477,0,18.7625198364258,0,0,27.6110305786133,0,11.5425643920898,0,0,-79.4924774169922,0,17.9689788818359,0,0,27.6094284057617,0,18.2968902587891,0,-85.7440643310547,0,0,18.8888397216797,0,27.5493392944336,0,17.6417617797852,0,0,0,0,28.0678253173828,0,0,-69.2942123413086,0,0,2.46437072753906,0,18.5601425170898,0,27.284309387207,0,0,0,18.0379943847656,0,-86.7718658447266,0,18.4946746826172,0,0,0,0,26.5632476806641,0,0,0,14.7577133178711,0,21.3151702880859,0,14.0991439819336,0,0,-86.4405517578125,0,18.4287338256836,0,27.6782608032227,0,0,18.363037109375,0,0,0,25.1200256347656,0,-98.0497817993164,0,0,23.6107635498047,0,0,18.4925994873047,0,28.4625854492188,0,17.5811004638672,0,0,-85.9158630371094,0,0,18.2945098876953,0,27.7439193725586,0,0,18.1054000854492,0,0,0,0,0,24.3332366943359,0,0,0,0,-94.7069396972656,0,26.1641998291016,0,0,0,0,18.1635818481445,0,26.2948303222656,0,16.6540603637695,0,-86.4871063232422,0,0,18.2960815429688,0,0,0,0,24.851921081543,0,0,17.3106155395508,0,0,27.9983978271484,0,0,13.3122100830078,0,0,-80.4601287841797,0,0,0,18.7534866333008,0,28.0642929077148,0,18.6885070800781,0,0,-2.7861328125,0,0,-68.3548736572266,0,27.6726531982422,0,0,0,0,0,18.2288589477539,0,0,25.8378677368164,0,0,14.3609085083008,0,0,0,0,0,-81.4462432861328,0,18.5567016601562,0,0,0,25.8997497558594,0,0,17.5072631835938,0,0,0,0,0,19.4732437133789,0,0,-89.1726913452148,0,0,27.0154190063477,0,18.1623306274414,0,0,0,26.9491958618164,0,0,17.0479888916016,0,0,-83.4037551879883,0,0,0,18.3593826293945,0,26.8843460083008,0,17.966178894043,0,0,0,0,0,20.1954116821289,0,0,0,0,0,-86.4231109619141,0,26.4257049560547,0,18.0973968505859,0,0,0,0,0,27.7362442016602,0,14.1614456176758,0,0,-81.4392242431641,0,18.6196746826172,0,0,0,27.2074356079102,18.6847839355469,0,-55.4084091186523,0,0,-12.839111328125,0,27.3393936157227,0,0,18.3565673828125,0,25.6356811523438,0,13.832893371582,0,0,-81.294677734375,0,0,0,0,0,18.5536193847656,0,0,27.0116424560547,0,0,0,0,18.4225387573242,0,0,0,0,-84.9019317626953,0,0,17.8328399658203,0,27.7976455688477,0,0,18.3570175170898,0,27.4709243774414,0,0,10.7519836425781,0,0,0,-78.4119110107422,0,0,0,0,18.619010925293,0,28.059326171875,0,0,0,0,0,17.8982086181641,0,0,-86.1454925537109,0,18.0947799682617,0,0,27.403938293457,0,17.7666473388672,0,0,0,28.2563629150391,0,-93.6843109130859,0,0,0,0,27.6004943847656,0,18.5536041259766,0,27.9942626953125,0,0,0,0,18.7502670288086,0,-86.4922637939453,0,18.2258377075195,0,27.8631896972656,0,16.9422912597656,0,0,0,0],"filename":[null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpXNobmL/file451c3f579cb3.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min         lq        mean      median
#>         compute_pi0(m)    836.734    855.253    876.5549    861.6220
#>    compute_pi0(m * 10)   8333.798   8452.028   8607.4682   8526.3265
#>   compute_pi0(m * 100)  84641.543  84982.762  86018.5899  85573.2650
#>         compute_pi1(m)    165.801    181.423    243.7246    271.0545
#>    compute_pi1(m * 10)   1144.043   1203.227   1568.3091   1254.1545
#>   compute_pi1(m * 100)  10944.165  11302.056  20940.7411  14296.5265
#>  compute_pi1(m * 1000) 205244.713 236601.967 293648.1525 322845.7245
#>           uq        max neval
#>     870.4755    970.512    20
#>    8591.7250   9883.754    20
#>   86358.9075  93433.433    20
#>     286.3980    300.640    20
#>    1292.6575   7747.267    20
#>   20317.2250 127097.362    20
#>  332691.4195 350140.967    20
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
#>   memory_copy1(n) 6983.00145 6922.94317 623.34912 5092.06253 3717.53015
#>   memory_copy2(n)  108.84465  106.87293  11.28942   80.05094   64.19479
#>  pre_allocate1(n)   24.38188   23.62674   3.68030   17.35643   12.50120
#>  pre_allocate2(n)  219.19450  211.81296  20.48581  159.09399  117.47479
#>     vectorized(n)    1.00000    1.00000   1.00000    1.00000    1.00000
#>        max neval
#>  80.866688    10
#>   2.842745    10
#>   2.048054    10
#>   3.835370    10
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
#>  f1(df) 277.5679 276.5063 93.65052 281.5644 73.74276 41.24307     5
#>  f2(df)   1.0000   1.0000  1.00000   1.0000  1.00000  1.00000     5
```

#### Paralelizar {-}

Paralelizar usa varios _cores_  para trabajar de manera simultánea en varias 
secciones de un problema, no reduce el tiempo computacional pero incrementa el 
tiempo del usuario pues aprovecha los recursos. Como referencia está 
[Parallel Computing for Data Science] de Norm Matloff.

### Lecturas y recursos recomendados de R

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
