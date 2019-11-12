
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
#> 1   1 -0.01679732 2.3389068 3.746752 3.889621
#> 2   2 -0.45418128 1.0343884 3.235681 4.679951
#> 3   3 -1.39836227 1.3771240 2.253174 5.025229
#> 4   4 -1.14079218 1.6114542 4.799184 4.975042
#> 5   5 -1.06107930 3.3389060 3.050450 4.699469
#> 6   6 -1.04810227 1.3045784 2.201350 5.815860
#> 7   7  0.59002828 2.8160611 1.771257 1.749812
#> 8   8  0.56235993 0.9724905 3.364968 4.558255
#> 9   9  0.19130811 2.4460442 3.156994 2.921779
#> 10 10  1.21694978 2.9376915 2.652737 6.485907
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.2558669
mean(df$b)
#> [1] 2.017765
mean(df$c)
#> [1] 3.023255
mean(df$d)
#> [1] 4.480093
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.2558669  2.0177645  3.0232546  4.4800925
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
#> [1] -0.2558669  2.0177645  3.0232546  4.4800925
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
#> [1]  5.5000000 -0.2558669  2.0177645  3.0232546  4.4800925
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
#> [1]  5.5000000 -0.2354893  1.9751805  3.1037217  4.6897102
col_describe(df, mean)
#> [1]  5.5000000 -0.2558669  2.0177645  3.0232546  4.4800925
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
#>  5.5000000 -0.2558669  2.0177645  3.0232546  4.4800925
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
#>   3.891   0.120   4.012
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.014   0.008   0.642
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
#>  13.009   0.768  10.014
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
#>   0.116   0.004   0.120
plyr_st
#>    user  system elapsed 
#>   4.177   0.004   4.181
est_l_st
#>    user  system elapsed 
#>  65.054   1.008  66.067
est_r_st
#>    user  system elapsed 
#>   0.399   0.000   0.399
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

<!--html_preserve--><div id="htmlwidget-0fdab36f4f8411645e9e" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-0fdab36f4f8411645e9e">{"x":{"message":{"prof":{"time":[1,1,1,2,2,3,3,3,4,4,4,5,5,5,5,6,6,6,7,7,7,8,8,8,8,9,9,9,10,10,10,11,11,11,12,12,12,12,12,13,13,13,13,13,13,14,14,14,15,15,16,16,16,17,17,18,18,18,18,19,19,20,20,21,21,21,22,22,23,23,23,24,24,25,25,26,26,26,26,26,27,27,27,27,28,28,28,29,29,30,30,30,30,30,31,32,32,33,33,33,34,34,35,35,36,36,37,37,37,38,38,39,39,39,40,40,40,41,41,41,41,41,42,42,42,43,43,44,44,45,45,46,46,46,47,47,48,48,49,49,49,49,49,50,50,50,51,51,52,52,53,53,54,54,54,54,55,55,55,56,56,57,57,57,58,58,58,59,59,59,60,60,60,61,61,62,62,63,63,64,64,64,65,65,65,65,65,65,66,66,67,67,68,68,69,69,69,69,69,70,70,71,71,72,72,72,73,73,73,74,74,75,75,76,76,76,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,90,90,91,91,92,92,92,92,92,92,93,93,94,94,95,95,96,96,97,97,97,98,98,99,99,100,100,101,101,101,102,102,102,102,102,103,103,104,104,104,105,105,105,105,106,106,106,106,106,106,107,107,108,108,109,109,110,110,111,111,111,111,111,111,112,112,112,112,112,113,113,113,113,113,114,114,114,114,114,115,115,115,116,116,117,117,117,117,117,117,118,118,119,119,120,120,120,121,121,122,122,123,123,123,124,124,124,125,125,125,125,126,126,126,127,127,128,128,128,129,129,129,129,129,130,130,130,130,130,131,131,131,132,132,132,133,133,133,134,134,135,135,136,136,137,137,137,137,138,138,138,139,139,139,139,140,140,141,141,141,142,142,143,143,144,144,145,145,146,146,147,147,147,147,148,148,149,149,150,150,151,151,151,152,152,152,153,153,154,154,155,155,156,156,156,156,156,156,157,157,157,158,158,159,159,160,160,161,161,161,161,161,162,162,163,163,164,164,164,164,164,164,165,165,165,166,166,167,167,167,167,167,168,168,169,169,169,169,169,170,170,171,171,172,172,172,172,172,173,173,174,174,174,175,175,176,176,177,177,177,177,177,178,178,178,178,178,179,179,180,180,181,181,181,182,182,183,183,183,183,184,184,185,185,186,186,187,187,187,188,188,188,188,188,189,189,190,190,191,191,192,192,192,193,193,193,193,193,194,194,195,195,196,196,196,197,197,197,197,197,198,198,199,199,199,200,200,200,201,201,201,202,202,202,203,203,203,203,203,203,204,204,205,205,206,206,206,207,207,207,207,207,208,208,209,210,210,210,210,211,211,211,211,211,211,212,212,213,213,214,214,215,215,215,215,216,216,217,217,217,217,218,218,219,219,219,220,220,221,221,221,221,221,221,222,222,222,222,222,222,223,223,223,223,223,224,224,224,224,225,225,226,226,226,227,227,228,228,228,229,229,230,230,230,230,230,231,231,231,231,232,232,233,233,234,234,235,235,236,236,236,237,237,238,238,238,238,238,239,239,239,240,240,241,241,241,242,242,243,243,244,244,244,245,245,245,246,246,246,246,247,247,248,248,249,249,250,250,250,251,251,252,252,252,253,253,254,254,254,254,254,255,255,256,256,256,257,257,257,257,258,258,258,259,259,260,260,260,261,261,262,262,262,263,263,263,264,264,265,265,266,266,266,266,266,267,267,268,268,268,268,268,268,269,269,270,270,271,271,271,271,272,272,272,273,273,273,273,274,274,275,275,276,276,276,276,276,277,277,278,278,278,279,279,280,280,281,281,281,281,281,282,282,282,283,283,284,284,284,284,284],"depth":[3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1],"label":["==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","n[i] <- nrow(sub_Batting)","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1],"linenum":[null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,11,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,11,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,10,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,13],"memalloc":[67.1267547607422,67.1267547607422,67.1267547607422,88.1161117553711,88.1161117553711,115.931159973145,115.931159973145,115.931159973145,133.249237060547,133.249237060547,133.249237060547,44.1055908203125,44.1055908203125,44.1055908203125,44.1055908203125,63.0647583007812,63.0647583007812,63.0647583007812,94.5551528930664,94.5551528930664,94.5551528930664,113.647956848145,113.647956848145,113.647956848145,113.647956848145,143.362487792969,143.362487792969,143.362487792969,46.4671173095703,46.4671173095703,46.4671173095703,77.888069152832,77.888069152832,77.888069152832,97.6377182006836,97.6377182006836,97.6377182006836,97.6377182006836,97.6377182006836,126.96809387207,126.96809387207,126.96809387207,126.96809387207,126.96809387207,126.96809387207,146.320671081543,146.320671081543,146.320671081543,60.7645034790039,60.7645034790039,81.8913650512695,81.8913650512695,81.8913650512695,113.108383178711,113.108383178711,132.786170959473,132.786170959473,132.786170959473,132.786170959473,46.0127487182617,46.0127487182617,66.8091735839844,66.8091735839844,98.4294586181641,98.4294586181641,98.4294586181641,117.915153503418,117.915153503418,146.315322875977,146.315322875977,146.315322875977,53.1006469726562,53.1006469726562,83.7987899780273,83.7987899780273,104.395843505859,104.395843505859,104.395843505859,104.395843505859,104.395843505859,135.890769958496,135.890769958496,135.890769958496,135.890769958496,146.320175170898,146.320175170898,146.320175170898,70.6187362670898,70.6187362670898,91.5442962646484,91.5442962646484,91.5442962646484,91.5442962646484,91.5442962646484,122.377403259277,141.996368408203,141.996368408203,55.7231597900391,55.7231597900391,55.7231597900391,76.1320648193359,76.1320648193359,107.560989379883,107.560989379883,127.309577941895,127.309577941895,146.333625793457,146.333625793457,146.333625793457,60.5183029174805,60.5183029174805,92.210563659668,92.210563659668,92.210563659668,112.549758911133,112.549758911133,112.549758911133,142.270645141602,142.270645141602,142.270645141602,142.270645141602,142.270645141602,45.562873840332,45.562873840332,45.562873840332,76.6620712280273,76.6620712280273,97.3891143798828,97.3891143798828,126.78337097168,126.78337097168,146.333381652832,146.333381652832,146.333381652832,60.0619277954102,60.0619277954102,81.188232421875,81.188232421875,112.477752685547,112.477752685547,112.477752685547,112.477752685547,112.477752685547,132.358489990234,132.358489990234,132.358489990234,46.4837341308594,46.4837341308594,66.953483581543,66.953483581543,99.0277938842773,99.0277938842773,119.426124572754,119.426124572754,119.426124572754,119.426124572754,146.322868347168,146.322868347168,146.322868347168,54.0987014770508,54.0987014770508,85.7225723266602,85.7225723266602,85.7225723266602,106.192077636719,106.192077636719,106.192077636719,136.106399536133,136.106399536133,136.106399536133,146.275093078613,146.275093078613,146.275093078613,71.2181243896484,71.2181243896484,92.1466903686523,92.1466903686523,124.235565185547,124.235565185547,145.422416687012,145.422416687012,145.422416687012,59.5477294921875,59.5477294921875,59.5477294921875,59.5477294921875,59.5477294921875,59.5477294921875,80.4772872924805,80.4772872924805,112.292457580566,112.292457580566,132.16796875,132.16796875,46.6231536865234,46.6231536865234,46.6231536865234,46.6231536865234,46.6231536865234,67.6175765991211,67.6175765991211,99.6381149291992,99.6381149291992,118.793037414551,118.793037414551,118.793037414551,146.278282165527,146.278282165527,146.278282165527,55.2821884155273,55.2821884155273,87.0268478393555,87.0268478393555,107.894119262695,107.894119262695,107.894119262695,140.033226013184,140.033226013184,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,42.756477355957,42.756477355957,42.756477355957,42.756477355957,42.756477355957,42.756477355957,73.3942489624023,73.3942489624023,94.192138671875,94.192138671875,126.266036987305,126.266036987305,146.278930664062,146.278930664062,146.278930664062,146.278930664062,146.278930664062,146.278930664062,62.3756713867188,62.3756713867188,82.8455276489258,82.8455276489258,112.428047180176,112.428047180176,131.97428894043,131.97428894043,46.2373352050781,46.2373352050781,46.2373352050781,66.6355056762695,66.6355056762695,97.6041564941406,97.6041564941406,117.872406005859,117.872406005859,146.270263671875,146.270263671875,146.270263671875,51.8786087036133,51.8786087036133,51.8786087036133,51.8786087036133,51.8786087036133,82.9081649780273,82.9081649780273,103.508819580078,103.508819580078,103.508819580078,132.37141418457,132.37141418457,132.37141418457,132.37141418457,146.278991699219,146.278991699219,146.278991699219,146.278991699219,146.278991699219,146.278991699219,66.31640625,66.31640625,86.3167495727539,86.3167495727539,118.199256896973,118.199256896973,137.943687438965,137.943687438965,51.8214874267578,51.8214874267578,51.8214874267578,51.8214874267578,51.8214874267578,51.8214874267578,72.1541748046875,72.1541748046875,72.1541748046875,72.1541748046875,72.1541748046875,103.641510009766,103.641510009766,103.641510009766,103.641510009766,103.641510009766,124.829345703125,124.829345703125,124.829345703125,124.829345703125,124.829345703125,146.280540466309,146.280540466309,146.280540466309,61.0668640136719,61.0668640136719,91.9606094360352,91.9606094360352,91.9606094360352,91.9606094360352,91.9606094360352,91.9606094360352,113.212608337402,113.212608337402,143.383392333984,143.383392333984,48.210823059082,48.210823059082,48.210823059082,79.4999237060547,79.4999237060547,98.6616897583008,98.6616897583008,130.083847045898,130.083847045898,130.083847045898,146.290390014648,146.290390014648,146.290390014648,65.0787048339844,65.0787048339844,65.0787048339844,65.0787048339844,85.3525314331055,85.3525314331055,85.3525314331055,116.6435546875,116.6435546875,137.310157775879,137.310157775879,137.310157775879,52.020637512207,52.020637512207,52.020637512207,52.020637512207,52.020637512207,71.1763687133789,71.1763687133789,71.1763687133789,71.1763687133789,71.1763687133789,100.564834594727,100.564834594727,100.564834594727,120.965591430664,120.965591430664,120.965591430664,146.290489196777,146.290489196777,146.290489196777,55.3670120239258,55.3670120239258,86.5313262939453,86.5313262939453,105.822601318359,105.822601318359,134.036201477051,134.036201477051,134.036201477051,134.036201477051,146.303955078125,146.303955078125,146.303955078125,67.9710845947266,67.9710845947266,67.9710845947266,67.9710845947266,88.0424270629883,88.0424270629883,118.414474487305,118.414474487305,118.414474487305,137.17822265625,137.17822265625,49.7950134277344,49.7950134277344,69.2798843383789,69.2798843383789,97.4897384643555,97.4897384643555,117.164772033691,117.164772033691,146.296310424805,146.296310424805,146.296310424805,146.296310424805,51.4400863647461,51.4400863647461,79.979377746582,79.979377746582,100.248832702637,100.248832702637,131.084106445312,131.084106445312,131.084106445312,146.303771972656,146.303771972656,146.303771972656,68.0293502807617,68.0293502807617,88.5608596801758,88.5608596801758,119.718643188477,119.718643188477,140.708381652832,140.708381652832,140.708381652832,140.708381652832,140.708381652832,140.708381652832,57.3388748168945,57.3388748168945,57.3388748168945,77.7431945800781,77.7431945800781,109.491508483887,109.491508483887,130.745307922363,130.745307922363,47.1757659912109,47.1757659912109,47.1757659912109,47.1757659912109,47.1757659912109,67.8436508178711,67.8436508178711,99.3412017822266,99.3412017822266,120.264526367188,120.264526367188,120.264526367188,120.264526367188,120.264526367188,120.264526367188,146.30883026123,146.30883026123,146.30883026123,56.6876602172852,56.6876602172852,88.0364532470703,88.0364532470703,88.0364532470703,88.0364532470703,88.0364532470703,109.220077514648,109.220077514648,140.576705932617,140.576705932617,140.576705932617,140.576705932617,140.576705932617,46.7845687866211,46.7845687866211,77.9352569580078,77.9352569580078,97.2869033813477,97.2869033813477,97.2869033813477,97.2869033813477,97.2869033813477,128.70450592041,128.70450592041,146.285057067871,146.285057067871,146.285057067871,65.8767395019531,65.8767395019531,86.995849609375,86.995849609375,118.870491027832,118.870491027832,118.870491027832,118.870491027832,118.870491027832,139.794303894043,139.794303894043,139.794303894043,139.794303894043,139.794303894043,56.627197265625,56.627197265625,76.9575424194336,76.9575424194336,109.230979919434,109.230979919434,109.230979919434,130.217491149902,130.217491149902,45.4463424682617,45.4463424682617,45.4463424682617,45.4463424682617,66.6309127807617,66.6309127807617,98.2408294677734,98.2408294677734,118.242668151855,118.242668151855,146.313110351562,146.313110351562,146.313110351562,52.202522277832,52.202522277832,52.202522277832,52.202522277832,52.202522277832,81.6545867919922,81.6545867919922,101.985954284668,101.985954284668,129.530883789062,129.530883789062,146.318618774414,146.318618774414,146.318618774414,65.4518356323242,65.4518356323242,65.4518356323242,65.4518356323242,65.4518356323242,85.5203857421875,85.5203857421875,116.740043640137,116.740043640137,135.696647644043,135.696647644043,135.696647644043,49.9089508056641,49.9089508056641,49.9089508056641,49.9089508056641,49.9089508056641,70.5027847290039,70.5027847290039,101.591217041016,101.591217041016,101.591217041016,122.055473327637,122.055473327637,122.055473327637,146.318588256836,146.318588256836,146.318588256836,56.5346145629883,56.5346145629883,56.5346145629883,87.4241333007812,87.4241333007812,87.4241333007812,87.4241333007812,87.4241333007812,87.4241333007812,108.215530395508,108.215530395508,137.465843200684,137.465843200684,141.020095825195,141.020095825195,141.020095825195,71.6847610473633,71.6847610473633,71.6847610473633,71.6847610473633,71.6847610473633,91.6199722290039,91.6199722290039,123.232543945312,144.02660369873,144.02660369873,144.02660369873,144.02660369873,59.6823196411133,59.6823196411133,59.6823196411133,59.6823196411133,59.6823196411133,59.6823196411133,80.6039123535156,80.6039123535156,112.087577819824,112.087577819824,133.273345947266,133.273345947266,48.2731246948242,48.2731246948242,48.2731246948242,48.2731246948242,69.2557373046875,69.2557373046875,101.189460754395,101.189460754395,101.189460754395,101.189460754395,122.369369506836,122.369369506836,146.301559448242,146.301559448242,146.301559448242,58.1776657104492,58.1776657104492,90.242431640625,90.242431640625,90.242431640625,90.242431640625,90.242431640625,90.242431640625,109.978790283203,109.978790283203,109.978790283203,109.978790283203,109.978790283203,109.978790283203,141.71558380127,141.71558380127,141.71558380127,141.71558380127,141.71558380127,46.5690612792969,46.5690612792969,46.5690612792969,46.5690612792969,77.7146682739258,77.7146682739258,98.2390060424805,98.2390060424805,98.2390060424805,130.237419128418,130.237419128418,146.303733825684,146.303733825684,146.303733825684,67.6212921142578,67.6212921142578,87.2939605712891,87.2939605712891,87.2939605712891,87.2939605712891,87.2939605712891,119.62296295166,119.62296295166,119.62296295166,119.62296295166,140.672203063965,140.672203063965,55.947998046875,55.947998046875,76.6036376953125,76.6036376953125,108.535873413086,108.535873413086,130.173789978027,130.173789978027,130.173789978027,45.9154052734375,45.9154052734375,66.5714111328125,66.5714111328125,66.5714111328125,66.5714111328125,66.5714111328125,98.2420501708984,98.2420501708984,98.2420501708984,119.748443603516,119.748443603516,146.304733276367,146.304733276367,146.304733276367,57.5889205932617,57.5889205932617,89.849494934082,89.849494934082,110.439697265625,110.439697265625,110.439697265625,141.91325378418,141.91325378418,141.91325378418,47.4914474487305,47.4914474487305,47.4914474487305,47.4914474487305,79.0308990478516,79.0308990478516,100.079292297363,100.079292297363,131.618392944336,131.618392944336,146.304779052734,146.304779052734,146.304779052734,68.2085571289062,68.2085571289062,89.3850250244141,89.3850250244141,89.3850250244141,121.902725219727,121.902725219727,143.144989013672,143.144989013672,143.144989013672,143.144989013672,143.144989013672,60.0144958496094,60.0144958496094,81.3222351074219,81.3222351074219,81.3222351074219,113.118988037109,113.118988037109,113.118988037109,113.118988037109,134.820655822754,134.820655822754,134.820655822754,51.032844543457,51.032844543457,71.7514801025391,71.7514801025391,71.7514801025391,103.02375793457,103.02375793457,123.67650604248,123.67650604248,123.67650604248,146.294876098633,146.294876098633,146.294876098633,60.2125625610352,60.2125625610352,91.0262069702148,91.0262069702148,112.202735900879,112.202735900879,112.202735900879,112.202735900879,112.202735900879,144.131416320801,144.131416320801,50.1167831420898,50.1167831420898,50.1167831420898,50.1167831420898,50.1167831420898,50.1167831420898,81.9133453369141,81.9133453369141,102.826728820801,102.826728820801,134.885940551758,134.885940551758,134.885940551758,134.885940551758,146.293365478516,146.293365478516,146.293365478516,71.686408996582,71.686408996582,71.686408996582,71.686408996582,92.8624649047852,92.8624649047852,124.855583190918,124.855583190918,145.113777160645,145.113777160645,145.113777160645,145.113777160645,145.113777160645,59.9989624023438,59.9989624023438,81.5027694702148,81.5027694702148,81.5027694702148,113.889175415039,113.889175415039,134.802658081055,134.802658081055,50.2308044433594,50.2308044433594,50.2308044433594,50.2308044433594,50.2308044433594,70.8825454711914,70.8825454711914,70.8825454711914,103.072341918945,103.072341918945,113.393188476562,113.393188476562,113.393188476562,113.393188476562,113.393188476562],"meminc":[0,0,0,20.9893569946289,0,27.8150482177734,0,0,17.3180770874023,0,0,-89.1436462402344,0,0,0,18.9591674804688,0,0,31.4903945922852,0,0,19.0928039550781,0,0,0,29.7145309448242,0,0,-96.8953704833984,0,0,31.4209518432617,0,0,19.7496490478516,0,0,0,0,29.3303756713867,0,0,0,0,0,19.3525772094727,0,0,-85.5561676025391,0,21.1268615722656,0,0,31.2170181274414,0,19.6777877807617,0,0,0,-86.7734222412109,0,20.7964248657227,0,31.6202850341797,0,0,19.4856948852539,0,28.4001693725586,0,0,-93.2146759033203,0,30.6981430053711,0,20.597053527832,0,0,0,0,31.4949264526367,0,0,0,10.4294052124023,0,0,-75.7014389038086,0,20.9255599975586,0,0,0,0,30.8331069946289,19.6189651489258,0,-86.2732086181641,0,0,20.4089050292969,0,31.4289245605469,0,19.7485885620117,0,19.0240478515625,0,0,-85.8153228759766,0,31.6922607421875,0,0,20.3391952514648,0,0,29.7208862304688,0,0,0,0,-96.7077713012695,0,0,31.0991973876953,0,20.7270431518555,0,29.3942565917969,0,19.5500106811523,0,0,-86.2714538574219,0,21.1263046264648,0,31.2895202636719,0,0,0,0,19.8807373046875,0,0,-85.874755859375,0,20.4697494506836,0,32.0743103027344,0,20.3983306884766,0,0,0,26.8967437744141,0,0,-92.2241668701172,0,31.6238708496094,0,0,20.4695053100586,0,0,29.9143218994141,0,0,10.1686935424805,0,0,-75.0569686889648,0,20.9285659790039,0,32.0888748168945,0,21.1868515014648,0,0,-85.8746871948242,0,0,0,0,0,20.929557800293,0,31.8151702880859,0,19.8755111694336,0,-85.5448150634766,0,0,0,0,20.9944229125977,0,32.0205383300781,0,19.1549224853516,0,0,27.4852447509766,0,0,-90.99609375,0,31.7446594238281,0,20.8672714233398,0,0,32.1391067504883,0,6.29473876953125,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,0,0,0,30.6377716064453,0,20.7978897094727,0,32.0738983154297,0,20.0128936767578,0,0,0,0,0,-83.9032592773438,0,20.469856262207,0,29.58251953125,0,19.5462417602539,0,-85.7369537353516,0,0,20.3981704711914,0,30.9686508178711,0,20.2682495117188,0,28.3978576660156,0,0,-94.3916549682617,0,0,0,0,31.0295562744141,0,20.6006546020508,0,0,28.8625946044922,0,0,0,13.9075775146484,0,0,0,0,0,-79.9625854492188,0,20.0003433227539,0,31.8825073242188,0,19.7444305419922,0,-86.122200012207,0,0,0,0,0,20.3326873779297,0,0,0,0,31.4873352050781,0,0,0,0,21.1878356933594,0,0,0,0,21.4511947631836,0,0,-85.2136764526367,0,30.8937454223633,0,0,0,0,0,21.2519989013672,0,30.170783996582,0,-95.1725692749023,0,0,31.2891006469727,0,19.1617660522461,0,31.4221572875977,0,0,16.20654296875,0,0,-81.2116851806641,0,0,0,20.2738265991211,0,0,31.2910232543945,0,20.6666030883789,0,0,-85.2895202636719,0,0,0,0,19.1557312011719,0,0,0,0,29.3884658813477,0,0,20.4007568359375,0,0,25.3248977661133,0,0,-90.9234771728516,0,31.1643142700195,0,19.2912750244141,0,28.2136001586914,0,0,0,12.2677536010742,0,0,-78.3328704833984,0,0,0,20.0713424682617,0,30.3720474243164,0,0,18.7637481689453,0,-87.3832092285156,0,19.4848709106445,0,28.2098541259766,0,19.6750335693359,0,29.1315383911133,0,0,0,-94.8562240600586,0,28.5392913818359,0,20.2694549560547,0,30.8352737426758,0,0,15.2196655273438,0,0,-78.2744216918945,0,20.5315093994141,0,31.1577835083008,0,20.9897384643555,0,0,0,0,0,-83.3695068359375,0,0,20.4043197631836,0,31.7483139038086,0,21.2537994384766,0,-83.5695419311523,0,0,0,0,20.6678848266602,0,31.4975509643555,0,20.9233245849609,0,0,0,0,0,26.044303894043,0,0,-89.6211700439453,0,31.3487930297852,0,0,0,0,21.1836242675781,0,31.3566284179688,0,0,0,0,-93.7921371459961,0,31.1506881713867,0,19.3516464233398,0,0,0,0,31.4176025390625,0,17.5805511474609,0,0,-80.408317565918,0,21.1191101074219,0,31.874641418457,0,0,0,0,20.9238128662109,0,0,0,0,-83.167106628418,0,20.3303451538086,0,32.2734375,0,0,20.9865112304688,0,-84.7711486816406,0,0,0,21.1845703125,0,31.6099166870117,0,20.001838684082,0,28.070442199707,0,0,-94.1105880737305,0,0,0,0,29.4520645141602,0,20.3313674926758,0,27.5449295043945,0,16.7877349853516,0,0,-80.8667831420898,0,0,0,0,20.0685501098633,0,31.2196578979492,0,18.9566040039062,0,0,-85.7876968383789,0,0,0,0,20.5938339233398,0,31.0884323120117,0,0,20.4642562866211,0,0,24.2631149291992,0,0,-89.7839736938477,0,0,30.889518737793,0,0,0,0,0,20.7913970947266,0,29.2503128051758,0,3.55425262451172,0,0,-69.335334777832,0,0,0,0,19.9352111816406,0,31.6125717163086,20.794059753418,0,0,0,-84.3442840576172,0,0,0,0,0,20.9215927124023,0,31.4836654663086,0,21.1857681274414,0,-85.0002212524414,0,0,0,20.9826126098633,0,31.933723449707,0,0,0,21.1799087524414,0,23.9321899414062,0,0,-88.123893737793,0,32.0647659301758,0,0,0,0,0,19.7363586425781,0,0,0,0,0,31.7367935180664,0,0,0,0,-95.1465225219727,0,0,0,31.1456069946289,0,20.5243377685547,0,0,31.9984130859375,0,16.0663146972656,0,0,-78.6824417114258,0,19.6726684570312,0,0,0,0,32.3290023803711,0,0,0,21.0492401123047,0,-84.7242050170898,0,20.6556396484375,0,31.9322357177734,0,21.6379165649414,0,0,-84.2583847045898,0,20.656005859375,0,0,0,0,31.6706390380859,0,0,21.5063934326172,0,26.5562896728516,0,0,-88.7158126831055,0,32.2605743408203,0,20.590202331543,0,0,31.4735565185547,0,0,-94.4218063354492,0,0,0,31.5394515991211,0,21.0483932495117,0,31.5391006469727,0,14.6863861083984,0,0,-78.0962219238281,0,21.1764678955078,0,0,32.5177001953125,0,21.2422637939453,0,0,0,0,-83.1304931640625,0,21.3077392578125,0,0,31.7967529296875,0,0,0,21.7016677856445,0,0,-83.7878112792969,0,20.718635559082,0,0,31.2722778320312,0,20.6527481079102,0,0,22.6183700561523,0,0,-86.0823135375977,0,30.8136444091797,0,21.1765289306641,0,0,0,0,31.9286804199219,0,-94.0146331787109,0,0,0,0,0,31.7965621948242,0,20.9133834838867,0,32.059211730957,0,0,0,11.4074249267578,0,0,-74.6069564819336,0,0,0,21.1760559082031,0,31.9931182861328,0,20.2581939697266,0,0,0,0,-85.1148147583008,0,21.5038070678711,0,0,32.3864059448242,0,20.9134826660156,0,-84.5718536376953,0,0,0,0,20.651741027832,0,0,32.1897964477539,0,10.3208465576172,0,0,0,0],"filename":[null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmpm3ef1r/file42ee71513f9.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    787.752    799.5290    808.9246    804.8260
#>    compute_pi0(m * 10)   7907.712   7940.9300   8771.3983   8008.5185
#>   compute_pi0(m * 100)  79107.598  79373.1660  79791.9780  79648.1870
#>         compute_pi1(m)    156.783    239.8815    263.0617    285.1415
#>    compute_pi1(m * 10)   1262.205   1332.0540   1759.5986   1414.3330
#>   compute_pi1(m * 100)  12965.462  14952.8685  20376.9768  21948.0140
#>  compute_pi1(m * 1000) 205804.366 268150.1650 333010.1743 365261.8680
#>           uq        max neval
#>     813.3375    846.541    20
#>    8210.0330  16501.083    20
#>   79971.9275  81864.913    20
#>     293.4385    328.578    20
#>    1437.3595   8789.169    20
#>   24454.9580  28382.255    20
#>  377986.5615 498622.611    20
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
#>   memory_copy1(n) 4640.96798 3853.17076 694.291813 3298.16889 1984.48600
#>   memory_copy2(n)   80.47995   67.67215  12.979226   58.03040   34.44708
#>  pre_allocate1(n)   17.10897   14.15194   4.189292   12.22839    7.15238
#>  pre_allocate2(n)  168.72849  142.12045  26.033207  124.15430   71.73102
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  122.403919    10
#>    3.172867    10
#>    2.491924    10
#>    5.140659    10
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
#>    expr      min       lq     mean  median       uq      max neval
#>  f1(df) 247.8849 249.1399 78.55565 247.924 60.55815 29.02409     5
#>  f2(df)   1.0000   1.0000  1.00000   1.000  1.00000  1.00000     5
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
