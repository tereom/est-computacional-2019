
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
#>    id             a         b        c        d
#> 1   1 -0.8344687587 0.7851821 3.467179 2.462565
#> 2   2  0.0468630132 1.8880384 2.524731 4.078327
#> 3   3 -0.1023668397 1.1019884 4.064760 3.788266
#> 4   4  0.8185547663 3.4099802 2.392484 2.942093
#> 5   5 -0.3173898876 1.7981352 5.398223 4.302966
#> 6   6  0.5216780475 0.6983223 2.792362 3.955860
#> 7   7  1.3274516860 2.6485304 4.462287 3.860322
#> 8   8  1.5096516216 1.6439322 4.276557 4.106271
#> 9   9 -0.9068820116 3.2840638 2.751054 3.334016
#> 10 10  0.0009503141 3.2225068 3.940266 4.858442
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.2064042
mean(df$b)
#> [1] 2.048068
mean(df$c)
#> [1] 3.60699
mean(df$d)
#> [1] 3.768913
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.2064042 2.0480680 3.6069903 3.7689129
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
#> [1] 0.2064042 2.0480680 3.6069903 3.7689129
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
#> [1] 5.5000000 0.2064042 2.0480680 3.6069903 3.7689129
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
#> [1] 5.50000000 0.02390666 1.84308678 3.70372240 3.90809126
col_describe(df, mean)
#> [1] 5.5000000 0.2064042 2.0480680 3.6069903 3.7689129
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
#> 5.5000000 0.2064042 2.0480680 3.6069903 3.7689129
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
#>   4.120   0.172   4.291
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.023   0.000   1.130
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
#>  13.738   0.965  10.616
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
#>   0.126   0.004   0.130
plyr_st
#>    user  system elapsed 
#>   4.617   0.003   4.618
est_l_st
#>    user  system elapsed 
#>  69.699   1.276  70.969
est_r_st
#>    user  system elapsed 
#>   0.412   0.004   0.416
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

<!--html_preserve--><div id="htmlwidget-55794cf67d1ff3d90c5b" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-55794cf67d1ff3d90c5b">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,4,4,4,4,5,5,5,6,6,6,7,7,7,8,8,9,9,10,10,10,11,11,11,12,12,12,12,12,13,13,14,14,15,15,16,16,16,17,17,18,18,19,19,19,19,19,20,20,20,21,21,21,22,22,23,23,24,24,25,26,26,26,27,27,27,27,27,28,28,29,29,30,30,30,30,30,31,31,31,32,32,33,33,34,34,35,35,36,36,36,36,36,36,37,37,38,38,39,39,39,40,40,40,40,40,41,41,41,42,42,42,42,42,42,43,43,43,43,43,44,44,45,45,45,46,46,47,47,48,48,49,49,49,50,50,50,51,51,52,52,52,53,53,54,54,55,55,55,55,55,55,56,56,57,57,57,58,58,59,59,60,60,61,61,62,62,62,63,63,64,64,64,64,64,65,65,65,65,66,66,66,66,66,67,67,68,68,68,69,69,69,69,69,70,70,71,71,72,72,72,72,72,73,73,73,74,74,75,75,76,76,77,77,77,77,78,78,78,79,79,79,79,79,80,80,81,81,81,81,81,81,82,82,83,83,84,84,84,85,85,86,86,86,86,87,87,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,103,104,104,104,105,105,106,106,106,107,107,108,108,109,109,109,109,109,109,110,110,110,111,111,112,112,112,112,112,112,113,113,113,114,114,114,115,115,116,116,116,116,116,117,117,118,118,119,119,119,120,120,120,121,121,122,122,123,123,124,124,124,124,124,124,125,125,125,125,126,126,127,127,127,128,128,128,129,129,129,130,130,130,130,130,130,131,131,132,132,133,133,134,134,134,135,135,135,135,135,135,136,136,137,137,137,137,137,138,138,138,139,139,139,140,140,141,141,142,142,143,143,143,143,143,144,144,144,145,145,145,145,146,146,147,147,148,148,148,149,149,149,149,149,149,150,150,150,150,150,150,151,151,152,152,153,153,154,154,154,155,155,155,156,156,156,157,157,157,158,158,158,159,159,159,160,160,160,160,160,160,161,161,162,162,162,163,163,164,164,164,165,165,165,165,165,166,166,167,167,168,168,168,169,169,169,169,170,170,170,171,171,172,172,173,173,174,174,174,175,175,175,175,175,176,176,177,177,177,177,177,178,178,179,179,180,180,181,181,181,182,182,182,182,182,183,183,183,183,183,183,184,184,184,185,185,185,185,185,186,186,187,187,188,188,189,189,189,190,190,190,190,190,190,191,191,191,191,192,192,193,193,193,194,194,194,194,195,195,196,196,196,197,197,197,198,198,198,199,199,200,200,201,201,202,202,203,203,203,204,204,205,205,205,206,206,206,206,206,207,207,207,208,208,208,209,209,209,210,210,211,211,211,212,212,212,213,213,213,214,214,214,215,215,215,215,215,216,216,216,216,216,217,217,217,218,218,218,219,219,220,220,220,220,220,220,221,221,221,222,222,223,223,223,224,225,225,225,226,226,226,227,227,228,228,228,228,229,229,229,230,230,230,230,230,231,231,231,231,231,232,232,232,233,233,234,234,235,235,236,236,236,237,237,237,237,238,238,238,238,238,239,239,239,239,240,240,240,240,241,241,241,241,241,241,242,242,242,242,242,242,243,243,243,243,243,243,244,244,245,245,245,245,245,246,246,246,247,247,247,247,247,248,248,249,249,250,250,250,250,250,250,251,251,252,252,253,253,254,254,254,254,254,255,255,255,255,255,256,256,257,257,258,258,259,259,259,260,260,261,261,261,262,262,262,263,263,264,264,265,265,266,266,267,267,268,268,268,269,269,269,270,270,271,271,272,272,273,273,273,274,274,274,274,274,275,275,275,275,275,276,276,277,277,277,278,278,278,278,278,278,279,279,279,280,280,281,281,282,282,283,283,283,284,284,284,285,285,285,285,285,286,286,286,287,287,288,288,289,289,289,289,289,290,290,291,291,291,292,292,292,293,293,293,294,294,295,295,295,295,295,296,296,297,297,298,298,299,299,299,300,300,300,301,301,301,301,301,301,302,302,303,303,304,304,305,305,305,305,305,306,306,307,307,308,308,309,309,310,310,310,310,310,310,311,311,311,312,312,312,312,312],"depth":[2,1,2,1,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,1,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,5,4,3,2,1,4,3,2,1,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","$","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,null,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,null,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1],"linenum":[9,9,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,10,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,10,10,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,null,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,null,11,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,13],"memalloc":[59.0570602416992,59.0570602416992,78.9305572509766,78.9305572509766,104.384140014648,104.384140014648,120.261077880859,120.261077880859,120.261077880859,120.261077880859,144.267074584961,144.267074584961,144.267074584961,146.301383972168,146.301383972168,146.301383972168,69.364128112793,69.364128112793,69.364128112793,88.9788970947266,88.9788970947266,116.992073059082,116.992073059082,135.491081237793,135.491081237793,135.491081237793,146.31266784668,146.31266784668,146.31266784668,59.5844955444336,59.5844955444336,59.5844955444336,59.5844955444336,59.5844955444336,89.6333312988281,89.6333312988281,108.007179260254,108.007179260254,136.351837158203,136.351837158203,146.320625305176,146.320625305176,146.320625305176,62.3393478393555,62.3393478393555,81.7596054077148,81.7596054077148,110.223297119141,110.223297119141,110.223297119141,110.223297119141,110.223297119141,129.048805236816,129.048805236816,129.048805236816,146.300285339355,146.300285339355,146.300285339355,54.0182037353516,54.0182037353516,83.6060943603516,83.6060943603516,102.233947753906,102.233947753906,133.06713104248,146.315277099609,146.315277099609,146.315277099609,58.8061828613281,58.8061828613281,58.8061828613281,58.8061828613281,58.8061828613281,78.6158447265625,78.6158447265625,108.594551086426,108.594551086426,128.017555236816,128.017555236816,128.017555236816,128.017555236816,128.017555236816,146.320129394531,146.320129394531,146.320129394531,54.6078338623047,54.6078338623047,84.3229598999023,84.3229598999023,102.961120605469,102.961120605469,130.712829589844,130.712829589844,146.329696655273,146.329696655273,146.329696655273,146.329696655273,146.329696655273,146.329696655273,55.0020523071289,55.0020523071289,74.6223983764648,74.6223983764648,103.033958435059,103.033958435059,103.033958435059,121.402244567871,121.402244567871,121.402244567871,121.402244567871,121.402244567871,146.33358001709,146.33358001709,146.33358001709,45.6260223388672,45.6260223388672,45.6260223388672,45.6260223388672,45.6260223388672,45.6260223388672,74.4263763427734,74.4263763427734,74.4263763427734,74.4263763427734,74.4263763427734,93.8514556884766,93.8514556884766,121.473365783691,121.473365783691,121.473365783691,139.778686523438,139.778686523438,45.4966583251953,45.4966583251953,63.9390869140625,63.9390869140625,91.155158996582,91.155158996582,91.155158996582,108.546546936035,108.546546936035,108.546546936035,134.525482177734,134.525482177734,146.333457946777,146.333457946777,146.333457946777,56.9802627563477,56.9802627563477,75.3486175537109,75.3486175537109,103.229270935059,103.229270935059,103.229270935059,103.229270935059,103.229270935059,103.229270935059,119.367431640625,119.367431640625,146.332550048828,146.332550048828,146.332550048828,44.1220932006836,44.1220932006836,72.8567886352539,72.8567886352539,92.6660690307617,92.6660690307617,121.000259399414,121.000259399414,139.627464294434,139.627464294434,139.627464294434,45.9629211425781,45.9629211425781,64.8621597290039,64.8621597290039,64.8621597290039,64.8621597290039,64.8621597290039,94.2468185424805,94.2468185424805,94.2468185424805,94.2468185424805,112.817169189453,112.817169189453,112.817169189453,112.817169189453,112.817169189453,139.97509765625,139.97509765625,146.275047302246,146.275047302246,146.275047302246,65.4450759887695,65.4450759887695,65.4450759887695,65.4450759887695,65.4450759887695,85.5174255371094,85.5174255371094,114.852760314941,114.852760314941,133.813255310059,133.813255310059,133.813255310059,133.813255310059,133.813255310059,146.275619506836,146.275619506836,146.275619506836,57.1833648681641,57.1833648681641,85.7893600463867,85.7893600463867,100.882385253906,100.882385253906,122.982345581055,122.982345581055,122.982345581055,122.982345581055,140.76146697998,140.76146697998,140.76146697998,47.1478500366211,47.1478500366211,47.1478500366211,47.1478500366211,47.1478500366211,66.3048553466797,66.3048553466797,95.4399871826172,95.4399871826172,95.4399871826172,95.4399871826172,95.4399871826172,95.4399871826172,115.577667236328,115.577667236328,144.965232849121,144.965232849121,146.27823638916,146.27823638916,146.27823638916,70.6943283081055,70.6943283081055,90.374137878418,90.374137878418,90.374137878418,90.374137878418,119.50227355957,119.50227355957,139.311294555664,139.311294555664,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,146.327919006348,42.7564315795898,42.7564315795898,42.7564315795898,42.7564315795898,42.7564315795898,42.7564315795898,58.6362915039062,58.6362915039062,78.3159790039062,78.3159790039062,78.3159790039062,108.095565795898,108.095565795898,127.906211853027,127.906211853027,146.278884887695,146.278884887695,146.278884887695,146.278884887695,146.278884887695,146.278884887695,55.156379699707,55.156379699707,55.156379699707,83.8947219848633,83.8947219848633,103.701416015625,103.701416015625,103.701416015625,103.701416015625,103.701416015625,103.701416015625,131.908721923828,131.908721923828,131.908721923828,146.275375366211,146.275375366211,146.275375366211,59.8158264160156,59.8158264160156,79.5621871948242,79.5621871948242,79.5621871948242,79.5621871948242,79.5621871948242,108.951751708984,108.951751708984,126.923400878906,126.923400878906,146.270217895508,146.270217895508,146.270217895508,55.486701965332,55.486701965332,55.486701965332,84.7468643188477,84.7468643188477,104.62296295166,104.62296295166,132.830093383789,132.830093383789,146.278945922852,146.278945922852,146.278945922852,146.278945922852,146.278945922852,146.278945922852,59.0333404541016,59.0333404541016,59.0333404541016,59.0333404541016,78.9064178466797,78.9064178466797,108.223976135254,108.223976135254,108.223976135254,127.841728210449,127.841728210449,127.841728210449,146.273986816406,146.273986816406,146.273986816406,56.2169342041016,56.2169342041016,56.2169342041016,56.2169342041016,56.2169342041016,56.2169342041016,85.9276580810547,85.9276580810547,105.542747497559,105.542747497559,135.850875854492,135.850875854492,146.280494689941,146.280494689941,146.280494689941,64.8726806640625,64.8726806640625,64.8726806640625,64.8726806640625,64.8726806640625,64.8726806640625,84.8795013427734,84.8795013427734,113.73787689209,113.73787689209,113.73787689209,113.73787689209,113.73787689209,132.43187713623,132.43187713623,132.43187713623,125.978706359863,125.978706359863,125.978706359863,60.7404632568359,60.7404632568359,90.5230102539062,90.5230102539062,110.07689666748,110.07689666748,140.25301361084,140.25301361084,140.25301361084,140.25301361084,140.25301361084,146.290344238281,146.290344238281,146.290344238281,68.2914352416992,68.2914352416992,68.2914352416992,68.2914352416992,87.8461456298828,87.8461456298828,117.497077941895,117.497077941895,137.310111999512,137.310111999512,137.310111999512,46.7727890014648,46.7727890014648,46.7727890014648,46.7727890014648,46.7727890014648,46.7727890014648,65.8614807128906,65.8614807128906,65.8614807128906,65.8614807128906,65.8614807128906,65.8614807128906,95.3827362060547,95.3827362060547,114.337554931641,114.337554931641,141.631927490234,141.631927490234,146.29044342041,146.29044342041,146.29044342041,68.4877395629883,68.4877395629883,68.4877395629883,85.810302734375,85.810302734375,85.810302734375,114.153411865234,114.153411865234,114.153411865234,131.804763793945,131.804763793945,131.804763793945,146.303909301758,146.303909301758,146.303909301758,59.6353225708008,59.6353225708008,59.6353225708008,59.6353225708008,59.6353225708008,59.6353225708008,88.9604568481445,88.9604568481445,108.442222595215,108.442222595215,108.442222595215,136.127883911133,136.127883911133,146.300621032715,146.300621032715,146.300621032715,64.752555847168,64.752555847168,64.752555847168,64.752555847168,64.752555847168,84.5697479248047,84.5697479248047,114.344619750977,114.344619750977,133.763961791992,133.763961791992,133.763961791992,44.1269607543945,44.1269607543945,44.1269607543945,44.1269607543945,60.9529495239258,60.9529495239258,60.9529495239258,90.4720230102539,90.4720230102539,108.317222595215,108.317222595215,138.03604888916,138.03604888916,146.303726196289,146.303726196289,146.303726196289,65.0784759521484,65.0784759521484,65.0784759521484,65.0784759521484,65.0784759521484,83.9042434692383,83.9042434692383,113.945037841797,113.945037841797,113.945037841797,113.945037841797,113.945037841797,133.820457458496,133.820457458496,44.02587890625,44.02587890625,63.438835144043,63.438835144043,93.0281600952148,93.0281600952148,93.0281600952148,112.904113769531,112.904113769531,112.904113769531,112.904113769531,112.904113769531,143.078788757324,143.078788757324,143.078788757324,143.078788757324,143.078788757324,143.078788757324,45.8910369873047,45.8910369873047,45.8910369873047,73.0947494506836,73.0947494506836,73.0947494506836,73.0947494506836,73.0947494506836,93.2404937744141,93.2404937744141,123.020896911621,123.020896911621,140.733757019043,140.733757019043,50.8515548706055,50.8515548706055,50.8515548706055,69.8704986572266,69.8704986572266,69.8704986572266,69.8704986572266,69.8704986572266,69.8704986572266,99.9074401855469,99.9074401855469,99.9074401855469,99.9074401855469,120.174873352051,120.174873352051,146.282989501953,146.282989501953,146.282989501953,51.4397659301758,51.4397659301758,51.4397659301758,51.4397659301758,81.4105911254883,81.4105911254883,101.223457336426,101.223457336426,101.223457336426,131.197746276855,131.197746276855,131.197746276855,146.285011291504,146.285011291504,146.285011291504,58.4628829956055,58.4628829956055,77.5500564575195,77.5500564575195,107.655685424805,107.655685424805,127.856307983398,127.856307983398,146.287750244141,146.287750244141,146.287750244141,57.7423934936523,57.7423934936523,87.2548141479492,87.2548141479492,87.2548141479492,106.345527648926,106.345527648926,106.345527648926,106.345527648926,106.345527648926,136.056541442871,136.056541442871,136.056541442871,146.286293029785,146.286293029785,146.286293029785,64.4661254882812,64.4661254882812,64.4661254882812,84.5996475219727,84.5996475219727,112.800064086914,112.800064086914,112.800064086914,131.883804321289,131.883804321289,131.883804321289,127.397651672363,127.397651672363,127.397651672363,59.6788864135742,59.6788864135742,59.6788864135742,89.7224807739258,89.7224807739258,89.7224807739258,89.7224807739258,89.7224807739258,109.592643737793,109.592643737793,109.592643737793,109.592643737793,109.592643737793,139.890350341797,139.890350341797,139.890350341797,146.318572998047,146.318572998047,146.318572998047,67.4843902587891,67.4843902587891,86.7003784179688,86.7003784179688,86.7003784179688,86.7003784179688,86.7003784179688,86.7003784179688,114.641288757324,114.641288757324,114.641288757324,133.269653320312,133.269653320312,75.045295715332,75.045295715332,75.045295715332,60.5978164672852,91.4904022216797,91.4904022216797,91.4904022216797,112.610221862793,112.610221862793,112.610221862793,143.63013458252,143.63013458252,47.8115234375,47.8115234375,47.8115234375,47.8115234375,78.5703964233398,78.5703964233398,78.5703964233398,99.3613586425781,99.3613586425781,99.3613586425781,99.3613586425781,99.3613586425781,129.727882385254,129.727882385254,129.727882385254,129.727882385254,129.727882385254,146.321479797363,146.321479797363,146.321479797363,63.6816101074219,63.6816101074219,84.4067993164062,84.4067993164062,116.279342651367,116.279342651367,137.466682434082,137.466682434082,137.466682434082,52.2723388671875,52.2723388671875,52.2723388671875,52.2723388671875,73.3870468139648,73.3870468139648,73.3870468139648,73.3870468139648,73.3870468139648,105.134536743164,105.134536743164,105.134536743164,105.134536743164,126.059051513672,126.059051513672,126.059051513672,126.059051513672,146.323043823242,146.323043823242,146.323043823242,146.323043823242,146.323043823242,146.323043823242,61.5185623168945,61.5185623168945,61.5185623168945,61.5185623168945,61.5185623168945,61.5185623168945,92.8617324829102,92.8617324829102,92.8617324829102,92.8617324829102,92.8617324829102,92.8617324829102,113.911445617676,113.911445617676,145.580513000488,145.580513000488,145.580513000488,145.580513000488,145.580513000488,49.1945724487305,49.1945724487305,49.1945724487305,78.7018280029297,78.7018280029297,78.7018280029297,78.7018280029297,78.7018280029297,98.9634246826172,98.9634246826172,129.912010192871,129.912010192871,146.306396484375,146.306396484375,146.306396484375,146.306396484375,146.306396484375,146.306396484375,64.6006164550781,64.6006164550781,85.1897201538086,85.1897201538086,116.401039123535,116.401039123535,137.319404602051,137.319404602051,137.319404602051,137.319404602051,137.319404602051,52.3421173095703,52.3421173095703,52.3421173095703,52.3421173095703,52.3421173095703,73.1298980712891,73.1298980712891,104.736038208008,104.736038208008,125.06510925293,125.06510925293,146.311187744141,146.311187744141,146.311187744141,60.079475402832,60.079475402832,89.2595596313477,89.2595596313477,89.2595596313477,109.716278076172,109.716278076172,109.716278076172,140.664260864258,140.664260864258,45.2599945068359,45.2599945068359,75.8173217773438,75.8173217773438,95.6847534179688,95.6847534179688,125.911865234375,125.911865234375,146.3046875,146.3046875,146.3046875,61.6547775268555,61.6547775268555,61.6547775268555,82.2441329956055,82.2441329956055,113.783988952637,113.783988952637,134.700508117676,134.700508117676,50.3108291625977,50.3108291625977,50.3108291625977,69.4571380615234,69.4571380615234,69.4571380615234,69.4571380615234,69.4571380615234,100.997337341309,100.997337341309,100.997337341309,100.997337341309,100.997337341309,122.307571411133,122.307571411133,146.304733276367,146.304733276367,146.304733276367,57.8495788574219,57.8495788574219,57.8495788574219,57.8495788574219,57.8495788574219,57.8495788574219,89.3849792480469,89.3849792480469,89.3849792480469,110.49528503418,110.49528503418,142.030364990234,142.030364990234,47.1642913818359,47.1642913818359,78.17529296875,78.17529296875,78.17529296875,98.6301422119141,98.6301422119141,98.6301422119141,130.427803039551,130.427803039551,130.427803039551,130.427803039551,130.427803039551,146.29369354248,146.29369354248,146.29369354248,66.7684478759766,66.7684478759766,87.5515060424805,87.5515060424805,119.28392791748,119.28392791748,119.28392791748,119.28392791748,119.28392791748,140.525207519531,140.525207519531,56.8033218383789,56.8033218383789,56.8033218383789,77.9797286987305,77.9797286987305,77.9797286987305,109.449142456055,109.449142456055,109.449142456055,130.625762939453,130.625762939453,46.8387298583984,46.8387298583984,46.8387298583984,46.8387298583984,46.8387298583984,67.6866836547852,67.6866836547852,99.8108749389648,99.8108749389648,120.593818664551,120.593818664551,146.293319702148,146.293319702148,146.293319702148,57.066520690918,57.066520690918,57.066520690918,88.7975082397461,88.7975082397461,88.7975082397461,88.7975082397461,88.7975082397461,88.7975082397461,109.25218963623,109.25218963623,139.541313171387,139.541313171387,43.0842590332031,43.0842590332031,73.9632720947266,73.9632720947266,73.9632720947266,73.9632720947266,73.9632720947266,93.5654602050781,93.5654602050781,122.871017456055,122.871017456055,143.260208129883,143.260208129883,57.3114318847656,57.3114318847656,78.4871063232422,78.4871063232422,78.4871063232422,78.4871063232422,78.4871063232422,78.4871063232422,110.152488708496,110.152488708496,110.152488708496,113.393142700195,113.393142700195,113.393142700195,113.393142700195,113.393142700195],"meminc":[0,0,19.8734970092773,0,25.4535827636719,0,15.8769378662109,0,0,0,24.0059967041016,0,0,2.03430938720703,0,0,-76.937255859375,0,0,19.6147689819336,0,28.0131759643555,0,18.4990081787109,0,0,10.8215866088867,0,0,-86.7281723022461,0,0,0,0,30.0488357543945,0,18.3738479614258,0,28.3446578979492,0,9.96878814697266,0,0,-83.9812774658203,0,19.4202575683594,0,28.4636917114258,0,0,0,0,18.8255081176758,0,0,17.2514801025391,0,0,-92.2820816040039,0,29.587890625,0,18.6278533935547,0,30.8331832885742,13.2481460571289,0,0,-87.5090942382812,0,0,0,0,19.8096618652344,0,29.9787063598633,0,19.4230041503906,0,0,0,0,18.3025741577148,0,0,-91.7122955322266,0,29.7151260375977,0,18.6381607055664,0,27.751708984375,0,15.6168670654297,0,0,0,0,0,-91.3276443481445,0,19.6203460693359,0,28.4115600585938,0,0,18.3682861328125,0,0,0,0,24.9313354492188,0,0,-100.707557678223,0,0,0,0,0,28.8003540039062,0,0,0,0,19.4250793457031,0,27.6219100952148,0,0,18.3053207397461,0,-94.2820281982422,0,18.4424285888672,0,27.2160720825195,0,0,17.3913879394531,0,0,25.9789352416992,0,11.807975769043,0,0,-89.3531951904297,0,18.3683547973633,0,27.8806533813477,0,0,0,0,0,16.1381607055664,0,26.9651184082031,0,0,-102.210456848145,0,28.7346954345703,0,19.8092803955078,0,28.3341903686523,0,18.6272048950195,0,0,-93.6645431518555,0,18.8992385864258,0,0,0,0,29.3846588134766,0,0,0,18.5703506469727,0,0,0,0,27.1579284667969,0,6.29994964599609,0,0,-80.8299713134766,0,0,0,0,20.0723495483398,0,29.335334777832,0,18.9604949951172,0,0,0,0,12.4623641967773,0,0,-89.0922546386719,0,28.6059951782227,0,15.0930252075195,0,22.0999603271484,0,0,0,17.7791213989258,0,0,-93.6136169433594,0,0,0,0,19.1570053100586,0,29.1351318359375,0,0,0,0,0,20.1376800537109,0,29.387565612793,0,1.31300354003906,0,0,-75.5839080810547,0,19.6798095703125,0,0,0,29.1281356811523,0,19.8090209960938,0,7.01662445068359,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,0,0,0,15.8798599243164,0,19.6796875,0,0,29.7795867919922,0,19.8106460571289,0,18.372673034668,0,0,0,0,0,-91.1225051879883,0,0,28.7383422851562,0,19.8066940307617,0,0,0,0,0,28.2073059082031,0,0,14.3666534423828,0,0,-86.4595489501953,0,19.7463607788086,0,0,0,0,29.3895645141602,0,17.9716491699219,0,19.3468170166016,0,0,-90.7835159301758,0,0,29.2601623535156,0,19.8760986328125,0,28.2071304321289,0,13.4488525390625,0,0,0,0,0,-87.24560546875,0,0,0,19.8730773925781,0,29.3175582885742,0,0,19.6177520751953,0,0,18.432258605957,0,0,-90.0570526123047,0,0,0,0,0,29.7107238769531,0,19.6150894165039,0,30.3081283569336,0,10.4296188354492,0,0,-81.4078140258789,0,0,0,0,0,20.0068206787109,0,28.8583755493164,0,0,0,0,18.6940002441406,0,0,-6.45317077636719,0,0,-65.2382431030273,0,29.7825469970703,0,19.5538864135742,0,30.1761169433594,0,0,0,0,6.03733062744141,0,0,-77.998908996582,0,0,0,19.5547103881836,0,29.6509323120117,0,19.8130340576172,0,0,-90.5373229980469,0,0,0,0,0,19.0886917114258,0,0,0,0,0,29.5212554931641,0,18.9548187255859,0,27.2943725585938,0,4.65851593017578,0,0,-77.8027038574219,0,0,17.3225631713867,0,0,28.3431091308594,0,0,17.6513519287109,0,0,14.4991455078125,0,0,-86.668586730957,0,0,0,0,0,29.3251342773438,0,19.4817657470703,0,0,27.685661315918,0,10.172737121582,0,0,-81.5480651855469,0,0,0,0,19.8171920776367,0,29.7748718261719,0,19.4193420410156,0,0,-89.6370010375977,0,0,0,16.8259887695312,0,0,29.5190734863281,0,17.8451995849609,0,29.7188262939453,0,8.26767730712891,0,0,-81.2252502441406,0,0,0,0,18.8257675170898,0,30.0407943725586,0,0,0,0,19.8754196166992,0,-89.7945785522461,0,19.412956237793,0,29.5893249511719,0,0,19.8759536743164,0,0,0,0,30.174674987793,0,0,0,0,0,-97.1877517700195,0,0,27.2037124633789,0,0,0,0,20.1457443237305,0,29.780403137207,0,17.7128601074219,0,-89.8822021484375,0,0,19.0189437866211,0,0,0,0,0,30.0369415283203,0,0,0,20.2674331665039,0,26.1081161499023,0,0,-94.8432235717773,0,0,0,29.9708251953125,0,19.8128662109375,0,0,29.9742889404297,0,0,15.0872650146484,0,0,-87.8221282958984,0,19.0871734619141,0,30.1056289672852,0,20.2006225585938,0,18.4314422607422,0,0,-88.5453567504883,0,29.5124206542969,0,0,19.0907135009766,0,0,0,0,29.7110137939453,0,0,10.2297515869141,0,0,-81.8201675415039,0,0,20.1335220336914,0,28.2004165649414,0,0,19.083740234375,0,0,-4.48615264892578,0,0,-67.7187652587891,0,0,30.0435943603516,0,0,0,0,19.8701629638672,0,0,0,0,30.2977066040039,0,0,6.42822265625,0,0,-78.8341827392578,0,19.2159881591797,0,0,0,0,0,27.9409103393555,0,0,18.6283645629883,0,-58.2243576049805,0,0,-14.4474792480469,30.8925857543945,0,0,21.1198196411133,0,0,31.0199127197266,0,-95.8186111450195,0,0,0,30.7588729858398,0,0,20.7909622192383,0,0,0,0,30.3665237426758,0,0,0,0,16.5935974121094,0,0,-82.6398696899414,0,20.7251892089844,0,31.8725433349609,0,21.1873397827148,0,0,-85.1943435668945,0,0,0,21.1147079467773,0,0,0,0,31.7474899291992,0,0,0,20.9245147705078,0,0,0,20.2639923095703,0,0,0,0,0,-84.8044815063477,0,0,0,0,0,31.3431701660156,0,0,0,0,0,21.0497131347656,0,31.6690673828125,0,0,0,0,-96.3859405517578,0,0,29.5072555541992,0,0,0,0,20.2615966796875,0,30.9485855102539,0,16.3943862915039,0,0,0,0,0,-81.7057800292969,0,20.5891036987305,0,31.2113189697266,0,20.9183654785156,0,0,0,0,-84.9772872924805,0,0,0,0,20.7877807617188,0,31.6061401367188,0,20.3290710449219,0,21.2460784912109,0,0,-86.2317123413086,0,29.1800842285156,0,0,20.4567184448242,0,0,30.9479827880859,0,-95.4042663574219,0,30.5573272705078,0,19.867431640625,0,30.2271118164062,0,20.392822265625,0,0,-84.6499099731445,0,0,20.58935546875,0,31.5398559570312,0,20.9165191650391,0,-84.3896789550781,0,0,19.1463088989258,0,0,0,0,31.5401992797852,0,0,0,0,21.3102340698242,0,23.9971618652344,0,0,-88.4551544189453,0,0,0,0,0,31.535400390625,0,0,21.1103057861328,0,31.5350799560547,0,-94.8660736083984,0,31.0110015869141,0,0,20.4548492431641,0,0,31.7976608276367,0,0,0,0,15.8658905029297,0,0,-79.5252456665039,0,20.7830581665039,0,31.732421875,0,0,0,0,21.2412796020508,0,-83.7218856811523,0,0,21.1764068603516,0,0,31.4694137573242,0,0,21.1766204833984,0,-83.7870330810547,0,0,0,0,20.8479537963867,0,32.1241912841797,0,20.7829437255859,0,25.6995010375977,0,0,-89.2267990112305,0,0,31.7309875488281,0,0,0,0,0,20.4546813964844,0,30.2891235351562,0,-96.4570541381836,0,30.8790130615234,0,0,0,0,19.6021881103516,0,29.3055572509766,0,20.3891906738281,0,-85.9487762451172,0,21.1756744384766,0,0,0,0,0,31.6653823852539,0,0,3.24065399169922,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpWD42bL/file429c501c9622.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    814.167    831.3850    847.8918    837.8490
#>    compute_pi0(m * 10)   8123.060   8140.7850   8612.7028   8212.8145
#>   compute_pi0(m * 100)  81329.602  81669.8355  82210.9132  82045.7465
#>         compute_pi1(m)    183.318    209.7715   8663.6637    332.2405
#>    compute_pi1(m * 10)   1273.927   1408.9675   2295.5469   1532.6595
#>   compute_pi1(m * 100)  13121.484  14886.5700  20949.3877  21423.3220
#>  compute_pi1(m * 1000) 338396.324 383775.0765 438739.4167 436131.2125
#>           uq        max neval
#>     867.5355    921.154    20
#>    8323.9610  15479.403    20
#>   82464.8920  84609.417    20
#>     368.7420 167584.673    20
#>    1616.1245  10269.218    20
#>   24754.2015  31126.196    20
#>  480337.0745 661523.275    20
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
#>   memory_copy1(n) 5663.54333 3607.81686 655.073497 3418.56505 3159.77650
#>   memory_copy2(n)   94.39016   61.92876  12.556638   59.05184   55.05338
#>  pre_allocate1(n)   18.19881   12.03752   3.575232   11.76223   10.79700
#>  pre_allocate2(n)  185.32913  119.57268  23.311464  112.95626  106.33304
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  99.166385    10
#>   3.250717    10
#>   1.929341    10
#>   5.159128    10
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
#>  f1(df) 264.0296 343.2575 99.54802 350.3566 77.94574 42.31425     5
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
