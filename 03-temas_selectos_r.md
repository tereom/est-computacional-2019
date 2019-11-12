
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
#>    id          a         b         c        d
#> 1   1 -0.2916903 1.5051179 2.0322331 3.072309
#> 2   2 -0.4686586 1.8743425 3.3606855 4.705768
#> 3   3 -0.5707655 4.0404215 2.7278917 2.526764
#> 4   4  1.0194201 2.7511076 3.6156757 4.388157
#> 5   5 -0.6221568 2.0538890 1.9308952 5.039295
#> 6   6 -0.5429583 3.7254333 0.9502153 1.791019
#> 7   7  0.1046677 1.5066477 3.4333305 2.565208
#> 8   8 -0.3856422 0.7783676 3.0086664 5.513081
#> 9   9 -0.3701962 0.7908801 3.8106184 6.359136
#> 10 10  0.7576208 3.7097482 3.5190293 5.216480
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.1370359
mean(df$b)
#> [1] 2.273596
mean(df$c)
#> [1] 2.838924
mean(df$d)
#> [1] 4.117722
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.1370359  2.2735955  2.8389241  4.1177217
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
#> [1] -0.1370359  2.2735955  2.8389241  4.1177217
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
#> [1]  5.5000000 -0.1370359  2.2735955  2.8389241  4.1177217
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
#> [1]  5.5000000 -0.3779192  1.9641157  3.1846760  4.5469623
col_describe(df, mean)
#> [1]  5.5000000 -0.1370359  2.2735955  2.8389241  4.1177217
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
#>  5.5000000 -0.1370359  2.2735955  2.8389241  4.1177217
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
#>   3.876   0.132   4.009
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.022   0.000   0.684
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
#>  12.988   0.767  10.001
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
#>   0.121   0.000   0.121
plyr_st
#>    user  system elapsed 
#>   4.142   0.003   4.145
est_l_st
#>    user  system elapsed 
#>  64.206   1.036  65.246
est_r_st
#>    user  system elapsed 
#>   0.390   0.004   0.394
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

<!--html_preserve--><div id="htmlwidget-ba4024572fff9e2028a1" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-ba4024572fff9e2028a1">{"x":{"message":{"prof":{"time":[1,1,1,1,1,1,2,2,3,3,3,4,4,5,5,5,6,6,7,7,7,7,7,8,8,9,9,9,10,10,10,11,11,11,11,11,12,12,12,12,13,13,13,13,13,14,14,15,15,15,16,16,16,17,17,18,18,19,19,20,20,20,21,21,22,22,23,23,23,23,24,24,24,24,24,24,25,26,26,26,27,27,27,28,28,28,29,29,30,30,31,31,31,31,31,32,32,32,33,33,33,33,33,33,34,34,34,34,35,35,36,36,37,37,38,38,38,39,39,39,40,40,40,40,40,41,41,41,42,42,43,43,44,44,44,44,45,45,46,46,47,47,47,48,48,49,49,49,50,50,51,51,51,51,51,52,52,52,53,53,53,53,53,54,54,55,55,56,56,56,57,57,58,58,59,59,60,60,61,61,61,62,62,62,63,63,64,64,65,65,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,71,71,71,72,72,72,72,72,73,73,74,74,74,74,74,75,75,76,76,77,77,77,77,77,77,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,91,91,92,92,93,93,93,94,94,94,94,94,94,95,95,95,95,96,96,96,97,97,97,97,97,98,98,98,99,99,100,100,101,101,102,102,102,103,103,103,104,104,105,105,106,106,106,106,106,106,107,107,107,107,107,108,108,108,108,108,108,109,109,110,110,111,111,112,112,113,113,114,114,114,115,115,115,116,116,117,117,117,118,118,118,119,119,119,120,120,121,121,121,121,122,122,123,123,124,124,124,125,125,125,126,126,126,127,127,127,128,128,128,128,129,129,129,130,130,130,131,131,131,132,132,133,133,134,134,135,135,135,136,136,137,137,138,138,139,139,139,140,140,140,140,140,141,141,141,142,142,142,142,142,143,143,143,143,143,143,144,144,144,145,145,145,145,146,146,146,146,146,147,147,148,148,148,149,149,149,149,150,150,150,151,151,152,152,153,153,153,154,154,155,155,155,155,155,156,156,157,157,157,158,158,158,159,159,160,160,160,160,160,160,161,161,162,162,162,163,163,164,164,165,165,166,166,166,167,167,168,168,169,169,170,170,171,171,172,172,173,173,173,173,173,174,174,175,175,175,175,175,176,176,176,176,176,177,177,177,177,177,178,178,179,179,179,180,180,180,180,181,181,182,182,182,183,183,183,184,185,185,185,186,186,186,187,187,188,188,188,189,189,190,191,191,191,191,191,192,192,192,193,193,194,194,195,195,196,196,196,197,197,197,198,198,198,199,199,200,200,200,201,201,201,202,202,202,202,202,203,203,203,204,204,205,205,206,206,206,207,207,208,208,208,208,208,209,209,209,209,209,209,210,210,211,211,212,212,212,213,213,214,214,215,215,216,216,217,217,218,218,218,219,219,219,220,220,221,221,221,222,222,222,222,222,222,223,223,223,223,223,224,224,225,225,226,226,226,227,227,227,228,228,228,229,229,229,230,230,231,231,232,232,233,233,234,234,234,235,235,236,236,236,236,236,237,237,237,238,238,238,238,238,239,239,240,240,241,241,241,242,242,243,243,243,243,243,243,244,244,245,245,246,246,246,247,247,248,248,249,249,250,250,250,251,251,252,252,252,253,253,254,254,255,255,255,256,256,256,256,256,257,257,257,258,258,259,259,259,259,259,260,260,261,261,261,262,262,263,263,263,264,264,264,265,265,266,266,267,267,267,267,268,268,268,269,269,269,270,270,271,271,272,272,272,273,273,273,273,273,274,274,274,274,274,274,275,275,276,276,277,277,278,278,279,279,279,280,280,281,281,282,282,283,283,283,284,284,284,284,284],"depth":[6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,6,5,4,3,2,1,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,1,3,2,1,3,2,1,2,1,3,2,1,2,1,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1],"label":["sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","nrow","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","nrow","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","nrow",".row_names_info","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,null,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,null,null,null,null,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1],"linenum":[null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,null,null,9,9,11,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,11,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,null,11,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,11,null,9,9,null,9,9,9,9,null,9,9,9,9,11,null,null,null,null,11,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,13],"memalloc":[59.4514923095703,59.4514923095703,59.4514923095703,59.4514923095703,59.4514923095703,59.4514923095703,79.1274108886719,79.1274108886719,106.485191345215,106.485191345215,106.485191345215,123.737129211426,123.737129211426,146.301429748535,146.301429748535,146.301429748535,53.2892227172852,53.2892227172852,83.7987670898438,83.7987670898438,83.7987670898438,83.7987670898438,83.7987670898438,101.906021118164,101.906021118164,129.192070007324,129.192070007324,129.192070007324,146.312713623047,146.312713623047,146.312713623047,59.8471450805664,59.8471450805664,59.8471450805664,59.8471450805664,59.8471450805664,80.5791778564453,80.5791778564453,80.5791778564453,80.5791778564453,110.501525878906,110.501525878906,110.501525878906,110.501525878906,110.501525878906,129.790000915527,129.790000915527,94.744987487793,94.744987487793,94.744987487793,61.4203643798828,61.4203643798828,61.4203643798828,92.6440124511719,92.6440124511719,110.747596740723,110.747596740723,140.065437316895,140.065437316895,43.3233489990234,43.3233489990234,43.3233489990234,74.2255172729492,74.2255172729492,94.8889999389648,94.8889999389648,125.71851348877,125.71851348877,125.71851348877,125.71851348877,145.922004699707,145.922004699707,145.922004699707,145.922004699707,145.922004699707,145.922004699707,59.9862365722656,80.5202407836914,80.5202407836914,80.5202407836914,112.005355834961,112.005355834961,112.005355834961,132.48046875,132.48046875,132.48046875,46.4085922241211,46.4085922241211,66.6829071044922,66.6829071044922,97.516242980957,97.516242980957,97.516242980957,97.516242980957,97.516242980957,117.064765930176,117.064765930176,117.064765930176,146.329742431641,146.329742431641,146.329742431641,146.329742431641,146.329742431641,146.329742431641,49.756233215332,49.756233215332,49.756233215332,49.756233215332,80.7239227294922,80.7239227294922,101.000923156738,101.000923156738,131.113067626953,131.113067626953,146.333625793457,146.333625793457,146.333625793457,64.7813262939453,64.7813262939453,64.7813262939453,85.5181427001953,85.5181427001953,85.5181427001953,85.5181427001953,85.5181427001953,115.305152893066,115.305152893066,115.305152893066,133.744171142578,133.744171142578,46.743408203125,46.743408203125,66.6290893554688,66.6290893554688,66.6290893554688,66.6290893554688,98.1772842407227,98.1772842407227,118.125587463379,118.125587463379,146.333503723145,146.333503723145,146.333503723145,51.6653671264648,51.6653671264648,82.9600143432617,82.9600143432617,82.9600143432617,103.294807434082,103.294807434082,132.096237182617,132.096237182617,132.096237182617,132.096237182617,132.096237182617,146.332595825195,146.332595825195,146.332595825195,66.2312698364258,66.2312698364258,66.2312698364258,66.2312698364258,66.2312698364258,87.2231597900391,87.2231597900391,116.474761962891,116.474761962891,136.281227111816,136.281227111816,136.281227111816,50.8190383911133,50.8190383911133,71.2289505004883,71.2289505004883,101.663383483887,101.663383483887,121.869209289551,121.869209289551,146.275093078613,146.275093078613,146.275093078613,55.7366027832031,55.7366027832031,55.7366027832031,86.6328125,86.6328125,106.97900390625,106.97900390625,137.944107055664,137.944107055664,137.944107055664,137.944107055664,137.944107055664,143.788375854492,143.788375854492,143.788375854492,72.9988098144531,72.9988098144531,72.9988098144531,93.5328826904297,93.5328826904297,93.5328826904297,123.441925048828,123.441925048828,123.441925048828,143.187591552734,143.187591552734,57.379753112793,57.379753112793,57.379753112793,77.9844131469727,77.9844131469727,77.9844131469727,77.9844131469727,77.9844131469727,109.542251586914,109.542251586914,130.468078613281,130.468078613281,130.468078613281,130.468078613281,130.468078613281,45.7082672119141,45.7082672119141,66.6254119873047,66.6254119873047,98.3773193359375,98.3773193359375,98.3773193359375,98.3773193359375,98.3773193359375,98.3773193359375,119.371231079102,119.371231079102,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,146.327964782715,42.756477355957,42.756477355957,42.756477355957,44.2645034790039,44.2645034790039,75.6900863647461,75.6900863647461,95.2407836914062,95.2407836914062,127.118515014648,127.118515014648,127.118515014648,146.278930664062,146.278930664062,146.278930664062,146.278930664062,146.278930664062,146.278930664062,62.8345031738281,62.8345031738281,62.8345031738281,62.8345031738281,83.5013885498047,83.5013885498047,83.5013885498047,114.265029907227,114.265029907227,114.265029907227,114.265029907227,114.265029907227,133.87769317627,133.87769317627,133.87769317627,47.7471160888672,47.7471160888672,67.9488220214844,67.9488220214844,98.5888290405273,98.5888290405273,118.659545898438,118.659545898438,118.659545898438,146.270263671875,146.270263671875,146.270263671875,53.0583724975586,53.0583724975586,84.024528503418,84.024528503418,104.557518005371,104.557518005371,104.557518005371,104.557518005371,104.557518005371,104.557518005371,133.748687744141,133.748687744141,133.748687744141,133.748687744141,133.748687744141,146.278991699219,146.278991699219,146.278991699219,146.278991699219,146.278991699219,146.278991699219,69.0046844482422,69.0046844482422,89.7917556762695,89.7917556762695,120.428977966309,120.428977966309,140.37077331543,140.37077331543,56.2169342041016,56.2169342041016,76.5481948852539,76.5481948852539,76.5481948852539,108.035614013672,108.035614013672,108.035614013672,127.585563659668,127.585563659668,62.6989593505859,62.6989593505859,62.6989593505859,63.1652374267578,63.1652374267578,63.1652374267578,93.0754470825195,93.0754470825195,93.0754470825195,112.950561523438,112.950561523438,141.876091003418,141.876091003418,141.876091003418,141.876091003418,47.3578491210938,47.3578491210938,78.9747772216797,78.9747772216797,100.170677185059,100.170677185059,100.170677185059,131.658424377441,131.658424377441,131.658424377441,146.290390014648,146.290390014648,146.290390014648,68.0292053222656,68.0292053222656,68.0292053222656,88.4360122680664,88.4360122680664,88.4360122680664,88.4360122680664,119.992813110352,119.992813110352,119.992813110352,140.457443237305,140.457443237305,140.457443237305,56.6760559082031,56.6760559082031,56.6760559082031,77.6078414916992,77.6078414916992,108.043045043945,108.043045043945,127.329086303711,127.329086303711,144.326698303223,144.326698303223,144.326698303223,62.7808837890625,62.7808837890625,94.1457290649414,94.1457290649414,113.759628295898,113.759628295898,142.49991607666,142.49991607666,142.49991607666,47.8916244506836,47.8916244506836,47.8916244506836,47.8916244506836,47.8916244506836,79.0594787597656,79.0594787597656,79.0594787597656,98.2736282348633,98.2736282348633,98.2736282348633,98.2736282348633,98.2736282348633,128.320091247559,128.320091247559,128.320091247559,128.320091247559,128.320091247559,128.320091247559,146.300666809082,146.300666809082,146.300666809082,64.9495239257812,64.9495239257812,64.9495239257812,64.9495239257812,86.2747116088867,86.2747116088867,86.2747116088867,86.2747116088867,86.2747116088867,117.951782226562,117.951782226562,138.48998260498,138.48998260498,138.48998260498,54.65625,54.65625,54.65625,54.65625,75.1241607666016,75.1241607666016,75.1241607666016,106.545585632324,106.545585632324,127.738830566406,127.738830566406,44.9426498413086,44.9426498413086,44.9426498413086,65.8003540039062,65.8003540039062,97.2166061401367,97.2166061401367,97.2166061401367,97.2166061401367,97.2166061401367,118.471977233887,118.471977233887,146.284591674805,146.284591674805,146.284591674805,55.7642974853516,55.7642974853516,55.7642974853516,87.3205947875977,87.3205947875977,108.311149597168,108.311149597168,108.311149597168,108.311149597168,108.311149597168,108.311149597168,140.06111907959,140.06111907959,46.1925735473633,46.1925735473633,46.1925735473633,77.5596694946289,77.5596694946289,98.1606903076172,98.1606903076172,130.107612609863,130.107612609863,146.30883026123,146.30883026123,146.30883026123,67.0513229370117,67.0513229370117,87.7741851806641,87.7741851806641,119.452987670898,119.452987670898,140.379295349121,140.379295349121,57.2770080566406,57.2770080566406,78.0663146972656,78.0663146972656,110.07608795166,110.07608795166,110.07608795166,110.07608795166,110.07608795166,131.13232421875,131.13232421875,48.034912109375,48.034912109375,48.034912109375,48.034912109375,48.034912109375,68.3033981323242,68.3033981323242,68.3033981323242,68.3033981323242,68.3033981323242,100.310256958008,100.310256958008,100.310256958008,100.310256958008,100.310256958008,121.690399169922,121.690399169922,146.287796020508,146.287796020508,146.287796020508,59.250617980957,59.250617980957,59.250617980957,59.250617980957,91.2567825317383,91.2567825317383,112.443969726562,112.443969726562,112.443969726562,143.926094055176,143.926094055176,143.926094055176,48.2009048461914,79.8134536743164,79.8134536743164,79.8134536743164,100.2080078125,100.2080078125,100.2080078125,130.899604797363,130.899604797363,146.313110351562,146.313110351562,146.313110351562,66.0428009033203,66.0428009033203,86.3773574829102,117.855445861816,117.855445861816,117.855445861816,117.855445861816,117.855445861816,138.381927490234,138.381927490234,138.381927490234,52.7280426025391,52.7280426025391,73.2563400268555,73.2563400268555,105.19792175293,105.19792175293,126.250679016113,126.250679016113,126.250679016113,116.345016479492,116.345016479492,116.345016479492,62.2376403808594,62.2376403808594,62.2376403808594,93.4584426879883,93.4584426879883,114.183708190918,114.183708190918,114.183708190918,144.089431762695,144.089431762695,144.089431762695,48.9263305664062,48.9263305664062,48.9263305664062,48.9263305664062,48.9263305664062,80.14501953125,80.14501953125,80.14501953125,101.066535949707,101.066535949707,131.892654418945,131.892654418945,146.32152557373,146.32152557373,146.32152557373,67.3547286987305,67.3547286987305,87.4232635498047,87.4232635498047,87.4232635498047,87.4232635498047,87.4232635498047,119.230773925781,119.230773925781,119.230773925781,119.230773925781,119.230773925781,119.230773925781,139.762763977051,139.762763977051,55.7469024658203,55.7469024658203,76.7988815307617,76.7988815307617,76.7988815307617,108.676094055176,108.676094055176,129.994400024414,129.994400024414,46.2403259277344,46.2403259277344,67.0266723632812,67.0266723632812,99.2218399047852,99.2218399047852,119.288040161133,119.288040161133,119.288040161133,146.301559448242,146.301559448242,146.301559448242,56.0788803100586,56.0788803100586,87.8818511962891,87.8818511962891,87.8818511962891,109.126098632812,109.126098632812,109.126098632812,109.126098632812,109.126098632812,109.126098632812,139.027526855469,139.027526855469,139.027526855469,139.027526855469,139.027526855469,43.6839370727539,43.6839370727539,74.2393951416016,74.2393951416016,95.0921249389648,95.0921249389648,95.0921249389648,126.893524169922,126.893524169922,126.893524169922,146.303733825684,146.303733825684,146.303733825684,63.031005859375,63.031005859375,63.031005859375,84.3430328369141,84.3430328369141,115.032119750977,115.032119750977,135.951202392578,135.951202392578,51.8171691894531,51.8171691894531,73.128662109375,73.128662109375,73.128662109375,104.732482910156,104.732482910156,125.781288146973,125.781288146973,125.781288146973,125.781288146973,125.781288146973,143.09651184082,143.09651184082,143.09651184082,63.4241561889648,63.4241561889648,63.4241561889648,63.4241561889648,63.4241561889648,95.0286865234375,95.0286865234375,116.338577270508,116.338577270508,146.304733276367,146.304733276367,146.304733276367,54.3101577758789,54.3101577758789,84.6044235229492,84.6044235229492,84.6044235229492,84.6044235229492,84.6044235229492,84.6044235229492,105.652877807617,105.652877807617,137.913276672363,137.913276672363,44.0166778564453,44.0166778564453,44.0166778564453,75.4240188598633,75.4240188598633,96.0799865722656,96.0799865722656,127.881660461426,127.881660461426,146.304779052734,146.304779052734,146.304779052734,64.9303970336914,64.9303970336914,86.2381134033203,86.2381134033203,86.2381134033203,118.624740600586,118.624740600586,139.80143737793,139.80143737793,56.146240234375,56.146240234375,56.146240234375,76.9296417236328,76.9296417236328,76.9296417236328,76.9296417236328,76.9296417236328,108.070861816406,108.070861816406,108.070861816406,129.706207275391,129.706207275391,46.5752410888672,46.5752410888672,46.5752410888672,46.5752410888672,46.5752410888672,67.883186340332,67.883186340332,100.07398223877,100.07398223877,100.07398223877,121.774864196777,121.774864196777,146.294876098633,146.294876098633,146.294876098633,59.0983657836914,59.0983657836914,59.0983657836914,91.5504989624023,91.5504989624023,112.727577209473,112.727577209473,145.311210632324,145.311210632324,145.311210632324,145.311210632324,51.2313537597656,51.2313537597656,51.2313537597656,82.7001800537109,82.7001800537109,82.7001800537109,103.351539611816,103.351539611816,136.131103515625,136.131103515625,146.293365478516,146.293365478516,146.293365478516,73.6534805297852,73.6534805297852,73.6534805297852,73.6534805297852,73.6534805297852,94.0427093505859,94.0427093505859,94.0427093505859,94.0427093505859,94.0427093505859,94.0427093505859,126.363586425781,126.363586425781,145.900657653809,145.900657653809,61.1791381835938,61.1791381835938,82.8791046142578,82.8791046142578,115.266021728516,115.266021728516,115.266021728516,136.769836425781,136.769836425781,52.8533020019531,52.8533020019531,73.4391021728516,73.4391021728516,105.957107543945,105.957107543945,105.957107543945,113.393188476562,113.393188476562,113.393188476562,113.393188476562,113.393188476562],"meminc":[0,0,0,0,0,0,19.6759185791016,0,27.357780456543,0,0,17.2519378662109,0,22.5643005371094,0,0,-93.01220703125,0,30.5095443725586,0,0,0,0,18.1072540283203,0,27.2860488891602,0,0,17.1206436157227,0,0,-86.4655685424805,0,0,0,0,20.7320327758789,0,0,0,29.9223480224609,0,0,0,0,19.2884750366211,0,-35.0450134277344,0,0,-33.3246231079102,0,0,31.2236480712891,0,18.1035842895508,0,29.3178405761719,0,-96.7420883178711,0,0,30.9021682739258,0,20.6634826660156,0,30.8295135498047,0,0,0,20.2034912109375,0,0,0,0,0,-85.9357681274414,20.5340042114258,0,0,31.4851150512695,0,0,20.4751129150391,0,0,-86.0718765258789,0,20.2743148803711,0,30.8333358764648,0,0,0,0,19.5485229492188,0,0,29.2649765014648,0,0,0,0,0,-96.5735092163086,0,0,0,30.9676895141602,0,20.2770004272461,0,30.1121444702148,0,15.2205581665039,0,0,-81.5522994995117,0,0,20.73681640625,0,0,0,0,29.7870101928711,0,0,18.4390182495117,0,-87.0007629394531,0,19.8856811523438,0,0,0,31.5481948852539,0,19.9483032226562,0,28.2079162597656,0,0,-94.6681365966797,0,31.2946472167969,0,0,20.3347930908203,0,28.8014297485352,0,0,0,0,14.2363586425781,0,0,-80.1013259887695,0,0,0,0,20.9918899536133,0,29.2516021728516,0,19.8064651489258,0,0,-85.4621887207031,0,20.409912109375,0,30.4344329833984,0,20.2058258056641,0,24.4058837890625,0,0,-90.5384902954102,0,0,30.8962097167969,0,20.34619140625,0,30.9651031494141,0,0,0,0,5.84426879882812,0,0,-70.7895660400391,0,0,20.5340728759766,0,0,29.9090423583984,0,0,19.7456665039062,0,-85.8078384399414,0,0,20.6046600341797,0,0,0,0,31.5578384399414,0,20.9258270263672,0,0,0,0,-84.7598114013672,0,20.9171447753906,0,31.7519073486328,0,0,0,0,0,20.9939117431641,0,26.9567337036133,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,1.50802612304688,0,31.4255828857422,0,19.5506973266602,0,31.8777313232422,0,0,19.1604156494141,0,0,0,0,0,-83.4444274902344,0,0,0,20.6668853759766,0,0,30.7636413574219,0,0,0,0,19.612663269043,0,0,-86.1305770874023,0,20.2017059326172,0,30.640007019043,0,20.0707168579102,0,0,27.6107177734375,0,0,-93.2118911743164,0,30.9661560058594,0,20.5329895019531,0,0,0,0,0,29.1911697387695,0,0,0,0,12.5303039550781,0,0,0,0,0,-77.2743072509766,0,20.7870712280273,0,30.6372222900391,0,19.9417953491211,0,-84.1538391113281,0,20.3312606811523,0,0,31.487419128418,0,0,19.5499496459961,0,-64.886604309082,0,0,0.466278076171875,0,0,29.9102096557617,0,0,19.875114440918,0,28.9255294799805,0,0,0,-94.5182418823242,0,31.6169281005859,0,21.1958999633789,0,0,31.4877471923828,0,0,14.631965637207,0,0,-78.2611846923828,0,0,20.4068069458008,0,0,0,31.5568008422852,0,0,20.4646301269531,0,0,-83.7813873291016,0,0,20.9317855834961,0,30.4352035522461,0,19.2860412597656,0,16.9976119995117,0,0,-81.5458145141602,0,31.3648452758789,0,19.613899230957,0,28.7402877807617,0,0,-94.6082916259766,0,0,0,0,31.167854309082,0,0,19.2141494750977,0,0,0,0,30.0464630126953,0,0,0,0,0,17.9805755615234,0,0,-81.3511428833008,0,0,0,21.3251876831055,0,0,0,0,31.6770706176758,0,20.538200378418,0,0,-83.8337326049805,0,0,0,20.4679107666016,0,0,31.4214248657227,0,21.193244934082,0,-82.7961807250977,0,0,20.8577041625977,0,31.4162521362305,0,0,0,0,21.25537109375,0,27.812614440918,0,0,-90.5202941894531,0,0,31.5562973022461,0,20.9905548095703,0,0,0,0,0,31.7499694824219,0,-93.8685455322266,0,0,31.3670959472656,0,20.6010208129883,0,31.9469223022461,0,16.2012176513672,0,0,-79.2575073242188,0,20.7228622436523,0,31.6788024902344,0,20.9263076782227,0,-83.1022872924805,0,20.789306640625,0,32.0097732543945,0,0,0,0,21.0562362670898,0,-83.097412109375,0,0,0,0,20.2684860229492,0,0,0,0,32.0068588256836,0,0,0,0,21.3801422119141,0,24.5973968505859,0,0,-87.0371780395508,0,0,0,32.0061645507812,0,21.1871871948242,0,0,31.4821243286133,0,0,-95.7251892089844,31.612548828125,0,0,20.3945541381836,0,0,30.6915969848633,0,15.4135055541992,0,0,-80.2703094482422,0,20.3345565795898,31.4780883789062,0,0,0,0,20.526481628418,0,0,-85.6538848876953,0,20.5282974243164,0,31.9415817260742,0,21.0527572631836,0,0,-9.90566253662109,0,0,-54.1073760986328,0,0,31.2208023071289,0,20.7252655029297,0,0,29.9057235717773,0,0,-95.1631011962891,0,0,0,0,31.2186889648438,0,0,20.921516418457,0,30.8261184692383,0,14.4288711547852,0,0,-78.966796875,0,20.0685348510742,0,0,0,0,31.8075103759766,0,0,0,0,0,20.5319900512695,0,-84.0158615112305,0,21.0519790649414,0,0,31.8772125244141,0,21.3183059692383,0,-83.7540740966797,0,20.7863464355469,0,32.1951675415039,0,20.0662002563477,0,0,27.0135192871094,0,0,-90.2226791381836,0,31.8029708862305,0,0,21.2442474365234,0,0,0,0,0,29.9014282226562,0,0,0,0,-95.3435897827148,0,30.5554580688477,0,20.8527297973633,0,0,31.801399230957,0,0,19.4102096557617,0,0,-83.2727279663086,0,0,21.3120269775391,0,30.6890869140625,0,20.9190826416016,0,-84.134033203125,0,21.3114929199219,0,0,31.6038208007812,0,21.0488052368164,0,0,0,0,17.3152236938477,0,0,-79.6723556518555,0,0,0,0,31.6045303344727,0,21.3098907470703,0,29.9661560058594,0,0,-91.9945755004883,0,30.2942657470703,0,0,0,0,0,21.048454284668,0,32.2603988647461,0,-93.896598815918,0,0,31.407341003418,0,20.6559677124023,0,31.8016738891602,0,18.4231185913086,0,0,-81.374382019043,0,21.3077163696289,0,0,32.3866271972656,0,21.1766967773438,0,-83.6551971435547,0,0,20.7834014892578,0,0,0,0,31.1412200927734,0,0,21.6353454589844,0,-83.1309661865234,0,0,0,0,21.3079452514648,0,32.1907958984375,0,0,21.7008819580078,0,24.5200119018555,0,0,-87.1965103149414,0,0,32.4521331787109,0,21.1770782470703,0,32.5836334228516,0,0,0,-94.0798568725586,0,0,31.4688262939453,0,0,20.6513595581055,0,32.7795639038086,0,10.1622619628906,0,0,-72.6398849487305,0,0,0,0,20.3892288208008,0,0,0,0,0,32.3208770751953,0,19.5370712280273,0,-84.7215194702148,0,21.6999664306641,0,32.3869171142578,0,0,21.5038146972656,0,-83.9165344238281,0,20.5858001708984,0,32.5180053710938,0,0,7.43608093261719,0,0,0,0],"filename":[null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpfhsOqD/file42e475868454.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq        mean     median
#>         compute_pi0(m)    791.180    810.4945    828.3942    819.085
#>    compute_pi0(m * 10)   7980.322   8049.0880   8493.4463   8137.412
#>   compute_pi0(m * 100)  79740.850  80286.2580  80649.1858  80542.101
#>         compute_pi1(m)    164.259    202.8510    256.6001    265.107
#>    compute_pi1(m * 10)   1261.855   1331.8150   2028.4690   1406.653
#>   compute_pi1(m * 100)  13082.364  19097.2100  21808.5688  23618.272
#>  compute_pi1(m * 1000) 241644.861 262016.1490 324409.1469 313899.591
#>           uq        max neval
#>     829.8595    993.791    20
#>    8296.1550  14213.013    20
#>   80932.7880  82029.611    20
#>     299.7130    315.462    20
#>    1464.1745   8421.311    20
#>   25337.6945  31562.106    20
#>  378958.8285 479038.639    20
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
#>   memory_copy1(n) 5278.66453 4301.18753 643.358768 3399.56877 2947.20355
#>   memory_copy2(n)   93.43172   77.98139  12.642057   60.64492   53.49002
#>  pre_allocate1(n)   20.76970   17.04952   4.052775   13.12677   11.41208
#>  pre_allocate2(n)  200.95757  167.18449  25.608895  129.30095  124.38375
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  107.732791    10
#>    3.142776    10
#>    2.247408    10
#>    4.661459    10
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
#>  f1(df) 245.5067 235.3782 77.68287 236.2447 61.51927 28.74715     5
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
