
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
#>    id           a          b        c        d
#> 1   1 -0.30538320 3.06285540 3.424953 3.874253
#> 2   2  1.35251263 1.46259798 3.447932 4.209466
#> 3   3 -1.36811647 1.23302372 2.651299 4.998164
#> 4   4 -0.09765063 2.44228758 2.010872 5.191997
#> 5   5 -0.19198874 2.39765247 2.098473 3.890677
#> 6   6 -0.16490813 0.77996889 2.549638 3.891822
#> 7   7  2.29470660 2.07111855 4.839239 3.859890
#> 8   8 -0.24310573 3.91677849 1.496061 3.453551
#> 9   9  0.93498724 0.08050824 2.121374 3.602782
#> 10 10  0.91780789 0.43999624 2.720417 4.611714
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.3128861
mean(df$b)
#> [1] 1.788679
mean(df$c)
#> [1] 2.736026
mean(df$d)
#> [1] 4.158431
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.3128861 1.7886788 2.7360257 4.1584315
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
#> [1] 0.3128861 1.7886788 2.7360257 4.1584315
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
#> [1] 5.5000000 0.3128861 1.7886788 2.7360257 4.1584315
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
#> [1]  5.5000000 -0.1312794  1.7668583  2.6004685  3.8912491
col_describe(df, mean)
#> [1] 5.5000000 0.3128861 1.7886788 2.7360257 4.1584315
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
#> 5.5000000 0.3128861 1.7886788 2.7360257 4.1584315
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
#>   4.128   0.196   4.327
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.020   0.004   1.399
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
#>  12.765   0.952   9.850
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
#>   0.111   0.007   0.119
plyr_st
#>    user  system elapsed 
#>   3.962   0.000   3.963
est_l_st
#>    user  system elapsed 
#>  60.526   1.335  61.892
est_r_st
#>    user  system elapsed 
#>   0.375   0.016   0.391
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

<!--html_preserve--><div id="htmlwidget-5373079a7040e68630ef" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-5373079a7040e68630ef">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,3,3,3,4,4,5,5,5,6,6,7,7,8,8,8,8,8,9,9,9,10,10,11,11,11,12,12,13,13,14,14,14,15,15,15,15,16,16,16,16,16,17,17,18,18,18,18,18,19,19,19,19,19,20,20,20,21,21,22,22,23,23,23,24,24,25,25,25,25,25,26,26,27,27,27,27,28,28,29,29,30,30,31,31,31,31,31,31,32,32,32,33,33,33,33,34,34,35,35,36,36,36,37,37,37,38,38,38,39,39,39,39,39,40,40,41,41,42,42,43,43,43,44,44,44,45,45,46,46,47,47,47,47,47,48,48,49,49,49,50,50,51,51,52,52,53,53,53,53,54,54,54,55,55,55,56,56,57,57,58,58,58,59,59,59,59,59,60,60,61,61,61,61,62,62,63,63,63,63,63,64,64,65,65,66,66,66,66,67,67,67,68,68,68,68,69,69,69,69,70,70,71,71,71,71,71,72,72,72,73,73,74,74,74,74,74,75,75,76,76,76,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,87,87,87,87,88,88,89,89,90,90,90,91,91,92,92,92,92,93,93,94,94,95,95,96,96,96,97,97,97,97,98,98,99,100,100,100,101,101,101,101,101,102,102,103,103,103,104,104,105,105,106,106,106,106,106,106,107,107,108,108,109,109,110,110,110,110,110,110,111,111,112,112,112,113,113,114,114,115,115,115,116,116,117,117,117,118,118,119,119,120,120,120,121,121,122,122,123,123,123,123,123,124,124,124,125,125,125,125,125,125,126,126,127,127,128,128,128,128,128,129,129,129,130,130,130,130,130,131,131,132,132,132,133,133,134,134,134,134,134,134,135,135,136,136,137,137,137,137,137,137,138,138,138,138,138,138,139,139,140,140,140,140,141,141,141,142,142,143,143,144,144,145,145,146,146,147,147,147,148,148,149,149,149,149,149,150,150,150,150,151,151,151,152,152,152,152,152,152,153,153,154,154,155,155,156,156,156,156,157,157,158,158,159,159,160,160,160,161,161,162,162,163,163,163,163,163,164,164,164,165,165,165,165,165,166,166,167,167,167,168,168,168,169,169,169,169,169,170,170,171,171,172,172,172,173,173,173,174,174,175,175,176,176,176,176,177,177,178,178,179,179,179,179,179,179,180,180,181,181,182,182,182,183,183,184,184,185,185,186,186,186,187,187,188,188,188,188,188,188,189,189,189,190,190,190,190,190,191,191,191,191,191,192,192,193,193,194,194,195,195,196,196,197,197,197,198,198,199,199,199,200,200,201,201,201,201,201,202,202,202,202,203,203,204,204,205,205,206,206,207,207,208,208,208,209,209,209,210,210,210,211,211,212,212,212,213,213,214,214,214,214,215,215,215,215,215,215,216,216,217,217,218,218,218,219,219,220,220,221,221,221,222,222,222,223,223,224,224,224,224,224,224,225,225,225,225,226,226,227,227,227,228,228,229,229,229,230,230,231,231,231,232,232,233,233,233,233,233,233,234,234,234,235,235,235,235,236,236,236,237,237,238,238,238,238,238,238,239,239,239,240,240,241,241,242,242,243,243,244,244,244,245,245,246,246,247,247,247,248,248,248,249,249,250,250,250,251,251,251,252,252,252,253,253,254,254,254,255,255,255,255,255,255,256,256,256,257,257,257,258,258,259,259,260,260,260,261,261,261,261,262,262,263,263,264,264,264,265,265,265,265,265,265,266,266,266,267,267,268,268,269,269,269,269,270,270,271,271,271,272,272,272,272,272,273,273,274,274,275,275,275,275,275,276,276,276,276,276],"depth":[2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","n[i] <- nrow(sub_Batting)","nrow","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sum","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,null,null,null,null,1],"linenum":[9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,11,11,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,10,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,10,10,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,11,null,null,null,null,13],"memalloc":[66.5692138671875,66.5692138671875,87.7554016113281,87.7554016113281,114.58683013916,114.58683013916,114.58683013916,114.58683013916,114.58683013916,132.888305664062,132.888305664062,45.7135696411133,45.7135696411133,45.7135696411133,66.6410446166992,66.6410446166992,98.0646896362305,98.0646896362305,118.401718139648,118.401718139648,118.401718139648,118.401718139648,118.401718139648,146.279960632324,146.279960632324,146.279960632324,53.3839721679688,53.3839721679688,85.7957611083984,85.7957611083984,85.7957611083984,106.20263671875,106.20263671875,136.581359863281,136.581359863281,146.28791809082,146.28791809082,146.28791809082,73.721549987793,73.721549987793,73.721549987793,73.721549987793,94.7099304199219,94.7099304199219,94.7099304199219,94.7099304199219,94.7099304199219,125.60319519043,125.60319519043,145.151473999023,145.151473999023,145.151473999023,145.151473999023,145.151473999023,60.9394607543945,60.9394607543945,60.9394607543945,60.9394607543945,60.9394607543945,82.7207641601562,82.7207641601562,82.7207641601562,114.994430541992,114.994430541992,136.314025878906,136.314025878906,52.1488647460938,52.1488647460938,52.1488647460938,73.8620223999023,73.8620223999023,106.002906799316,106.002906799316,106.002906799316,106.002906799316,106.002906799316,127.656196594238,127.656196594238,43.6215362548828,43.6215362548828,43.6215362548828,43.6215362548828,64.8124237060547,64.8124237060547,97.1549606323242,97.1549606323242,117.425277709961,117.425277709961,146.296989440918,146.296989440918,146.296989440918,146.296989440918,146.296989440918,146.296989440918,52.6080780029297,52.6080780029297,52.6080780029297,84.4340515136719,84.4340515136719,84.4340515136719,84.4340515136719,104.97087097168,104.97087097168,135.343521118164,135.343521118164,146.300872802734,146.300872802734,146.300872802734,71.7038345336914,71.7038345336914,71.7038345336914,93.0972900390625,93.0972900390625,93.0972900390625,123.277809143066,123.277809143066,123.277809143066,123.277809143066,123.277809143066,143.417640686035,143.417640686035,58.8515319824219,58.8515319824219,80.2382049560547,80.2382049560547,112.843330383301,112.843330383301,112.843330383301,133.640716552734,133.640716552734,133.640716552734,49.7960739135742,49.7960739135742,69.6710739135742,69.6710739135742,101.359954833984,101.359954833984,101.359954833984,101.359954833984,101.359954833984,121.826377868652,121.826377868652,146.299957275391,146.299957275391,146.299957275391,57.6703872680664,57.6703872680664,89.7476806640625,89.7476806640625,110.343467712402,110.343467712402,139.594741821289,139.594741821289,139.594741821289,139.594741821289,44.6830596923828,44.6830596923828,44.6830596923828,76.1798248291016,76.1798248291016,76.1798248291016,97.2964096069336,97.2964096069336,127.872772216797,127.872772216797,146.307952880859,146.307952880859,146.307952880859,63.705696105957,63.705696105957,63.705696105957,63.705696105957,63.705696105957,85.4190979003906,85.4190979003906,115.47599029541,115.47599029541,115.47599029541,115.47599029541,135.681564331055,135.681564331055,48.6224746704102,48.6224746704102,48.6224746704102,48.6224746704102,48.6224746704102,67.9131088256836,67.9131088256836,97.7649307250977,97.7649307250977,118.556266784668,118.556266784668,118.556266784668,118.556266784668,146.304229736328,146.304229736328,146.304229736328,55.5769882202148,55.5769882202148,55.5769882202148,55.5769882202148,87.2700958251953,87.2700958251953,87.2700958251953,87.2700958251953,107.540100097656,107.540100097656,137.718307495117,137.718307495117,137.718307495117,137.718307495117,137.718307495117,146.311233520508,146.311233520508,146.311233520508,74.5331192016602,74.5331192016602,96.3111190795898,96.3111190795898,96.3111190795898,96.3111190795898,96.3111190795898,128.651382446289,128.651382446289,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,146.295211791992,42.7238006591797,42.7238006591797,42.7238006591797,46.2005004882812,46.2005004882812,77.8897552490234,77.8897552490234,77.8897552490234,77.8897552490234,99.4707260131836,99.4707260131836,131.879600524902,131.879600524902,146.311988830566,146.311988830566,146.311988830566,68.7710189819336,68.7710189819336,89.5673446655273,89.5673446655273,89.5673446655273,89.5673446655273,120.789093017578,120.789093017578,141.059394836426,141.059394836426,57.3555526733398,57.3555526733398,77.2306060791016,77.2306060791016,77.2306060791016,108.065574645996,108.065574645996,108.065574645996,108.065574645996,128.462669372559,128.462669372559,44.6308288574219,64.8392715454102,64.8392715454102,64.8392715454102,96.6511535644531,96.6511535644531,96.6511535644531,96.6511535644531,96.6511535644531,118.431213378906,118.431213378906,146.311218261719,146.311218261719,146.311218261719,56.3753814697266,56.3753814697266,88.513298034668,88.513298034668,109.833061218262,109.833061218262,109.833061218262,109.833061218262,109.833061218262,109.833061218262,142.042610168457,142.042610168457,48.3738174438477,48.3738174438477,80.1222686767578,80.1222686767578,101.310485839844,101.310485839844,101.310485839844,101.310485839844,101.310485839844,101.310485839844,132.143295288086,132.143295288086,146.312026977539,146.312026977539,146.312026977539,68.8423309326172,68.8423309326172,90.4188766479492,90.4188766479492,122.233291625977,122.233291625977,122.233291625977,143.874626159668,143.874626159668,60.6425247192383,60.6425247192383,60.6425247192383,82.2205200195312,82.2205200195312,113.649681091309,113.649681091309,134.052833557129,134.052833557129,134.052833557129,50.7401428222656,50.7401428222656,71.7346801757812,71.7346801757812,103.820693969727,103.820693969727,103.820693969727,103.820693969727,103.820693969727,125.535690307617,125.535690307617,125.535690307617,75.7723693847656,75.7723693847656,75.7723693847656,75.7723693847656,75.7723693847656,75.7723693847656,64.1873168945312,64.1873168945312,95.0866165161133,95.0866165161133,116.142066955566,116.142066955566,116.142066955566,116.142066955566,116.142066955566,146.256500244141,146.256500244141,146.256500244141,54.154914855957,54.154914855957,54.154914855957,54.154914855957,54.154914855957,85.2536926269531,85.2536926269531,106.643013000488,106.643013000488,106.643013000488,137.154808044434,137.154808044434,43.6607360839844,43.6607360839844,43.6607360839844,43.6607360839844,43.6607360839844,43.6607360839844,75.0918197631836,75.0918197631836,96.0772399902344,96.0772399902344,126.77848815918,126.77848815918,126.77848815918,126.77848815918,126.77848815918,126.77848815918,146.269714355469,146.269714355469,146.269714355469,146.269714355469,146.269714355469,146.269714355469,62.7502059936523,62.7502059936523,83.3564300537109,83.3564300537109,83.3564300537109,83.3564300537109,115.688934326172,115.688934326172,115.688934326172,136.947273254395,136.947273254395,53.90234375,53.90234375,74.5020523071289,74.5020523071289,106.383041381836,106.383041381836,126.526397705078,126.526397705078,146.271469116211,146.271469116211,146.271469116211,62.0294036865234,62.0294036865234,94.3651962280273,94.3651962280273,94.3651962280273,94.3651962280273,94.3651962280273,115.291893005371,115.291893005371,115.291893005371,115.291893005371,146.252983093262,146.252983093262,146.252983093262,54.617317199707,54.617317199707,54.617317199707,54.617317199707,54.617317199707,54.617317199707,86.5019302368164,86.5019302368164,107.75456237793,107.75456237793,137.99600982666,137.99600982666,44.2585906982422,44.2585906982422,44.2585906982422,44.2585906982422,75.5592956542969,75.5592956542969,96.6205139160156,96.6205139160156,128.632164001465,128.632164001465,146.277717590332,146.277717590332,146.277717590332,66.9522094726562,66.9522094726562,88.0690002441406,88.0690002441406,119.748168945312,119.748168945312,119.748168945312,119.748168945312,119.748168945312,139.887649536133,139.887649536133,139.887649536133,57.0465850830078,57.0465850830078,57.0465850830078,57.0465850830078,57.0465850830078,77.5736083984375,77.5736083984375,108.337783813477,108.337783813477,108.337783813477,129.458724975586,129.458724975586,129.458724975586,47.3449096679688,47.3449096679688,47.3449096679688,47.3449096679688,47.3449096679688,67.6132965087891,67.6132965087891,99.4890823364258,99.4890823364258,121.000915527344,121.000915527344,121.000915527344,146.25382232666,146.25382232666,146.25382232666,59.9378814697266,59.9378814697266,90.8285827636719,90.8285827636719,111.950500488281,111.950500488281,111.950500488281,111.950500488281,144.218780517578,144.218780517578,49.4140472412109,49.4140472412109,81.8778762817383,81.8778762817383,81.8778762817383,81.8778762817383,81.8778762817383,81.8778762817383,103.45304107666,103.45304107666,134.802772521973,134.802772521973,146.280281066895,146.280281066895,146.280281066895,72.1759338378906,72.1759338378906,93.5607223510742,93.5607223510742,126.285850524902,126.285850524902,146.286468505859,146.286468505859,146.286468505859,63.6489868164062,63.6489868164062,84.7018127441406,84.7018127441406,84.7018127441406,84.7018127441406,84.7018127441406,84.7018127441406,117.101013183594,117.101013183594,117.101013183594,138.35514831543,138.35514831543,138.35514831543,138.35514831543,138.35514831543,53.8114395141602,53.8114395141602,53.8114395141602,53.8114395141602,53.8114395141602,74.7323379516602,74.7323379516602,107.003463745117,107.003463745117,128.384094238281,128.384094238281,44.8941040039062,44.8941040039062,65.7500305175781,65.7500305175781,96.6404113769531,96.6404113769531,96.6404113769531,118.152183532715,118.152183532715,146.289604187012,146.289604187012,146.289604187012,55.7142715454102,55.7142715454102,88.0479583740234,88.0479583740234,88.0479583740234,88.0479583740234,88.0479583740234,109.821166992188,109.821166992188,109.821166992188,109.821166992188,141.765167236328,141.765167236328,47.7806396484375,47.7806396484375,79.9809265136719,79.9809265136719,100.771583557129,100.771583557129,131.208084106445,131.208084106445,146.289794921875,146.289794921875,146.289794921875,68.1098403930664,68.1098403930664,68.1098403930664,89.3559112548828,89.3559112548828,89.3559112548828,121.551200866699,121.551200866699,142.663711547852,142.663711547852,142.663711547852,59.1288146972656,59.1288146972656,80.5708999633789,80.5708999633789,80.5708999633789,80.5708999633789,112.962364196777,112.962364196777,112.962364196777,112.962364196777,112.962364196777,112.962364196777,134.471008300781,134.471008300781,51.5868301391602,51.5868301391602,73.0291137695312,73.0291137695312,73.0291137695312,104.830528259277,104.830528259277,125.289176940918,125.289176940918,146.273628234863,146.273628234863,146.273628234863,62.4755096435547,62.4755096435547,62.4755096435547,93.8849868774414,93.8849868774414,115.329406738281,115.329406738281,115.329406738281,115.329406738281,115.329406738281,115.329406738281,146.149574279785,146.149574279785,146.149574279785,146.149574279785,52.1134719848633,52.1134719848633,83.7201461791992,83.7201461791992,83.7201461791992,105.291687011719,105.291687011719,137.617256164551,137.617256164551,137.617256164551,44.4431533813477,44.4431533813477,75.3941955566406,75.3941955566406,75.3941955566406,96.5726852416992,96.5726852416992,128.898788452148,128.898788452148,128.898788452148,128.898788452148,128.898788452148,128.898788452148,146.275009155273,146.275009155273,146.275009155273,67.3943557739258,67.3943557739258,67.3943557739258,67.3943557739258,89.1633682250977,89.1633682250977,89.1633682250977,120.047714233398,120.047714233398,140.11205291748,140.11205291748,140.11205291748,140.11205291748,140.11205291748,140.11205291748,57.3617706298828,57.3617706298828,57.3617706298828,78.8033599853516,78.8033599853516,109.949768066406,109.949768066406,131.260185241699,131.260185241699,48.1169662475586,48.1169662475586,69.6868591308594,69.6868591308594,69.6868591308594,102.270080566406,102.270080566406,123.774147033691,123.774147033691,146.26171875,146.26171875,146.26171875,61.5576553344727,61.5576553344727,61.5576553344727,93.5519332885742,93.5519332885742,115.121406555176,115.121406555176,115.121406555176,146.263458251953,146.263458251953,146.263458251953,53.6256713867188,53.6256713867188,53.6256713867188,85.5546569824219,85.5546569824219,107.124870300293,107.124870300293,107.124870300293,139.446434020996,139.446434020996,139.446434020996,139.446434020996,139.446434020996,139.446434020996,46.4801712036133,46.4801712036133,46.4801712036133,78.7365112304688,78.7365112304688,78.7365112304688,100.568016052246,100.568016052246,133.283683776855,133.283683776855,146.264511108398,146.264511108398,146.264511108398,72.376953125,72.376953125,72.376953125,72.376953125,94.0117797851562,94.0117797851562,126.660827636719,126.660827636719,146.263092041016,146.263092041016,146.263092041016,66.543098449707,66.543098449707,66.543098449707,66.543098449707,66.543098449707,66.543098449707,88.2434844970703,88.2434844970703,88.2434844970703,120.629890441895,120.629890441895,142.264839172363,142.264839172363,58.5896682739258,58.5896682739258,58.5896682739258,58.5896682739258,80.3554916381836,80.3554916381836,112.152496337891,112.152496337891,112.152496337891,133.721488952637,133.721488952637,133.721488952637,133.721488952637,133.721488952637,50.198600769043,50.198600769043,71.6368942260742,71.6368942260742,102.974197387695,102.974197387695,102.974197387695,102.974197387695,102.974197387695,112.50853729248,112.50853729248,112.50853729248,112.50853729248,112.50853729248],"meminc":[0,0,21.1861877441406,0,26.831428527832,0,0,0,0,18.3014755249023,0,-87.1747360229492,0,0,20.9274749755859,0,31.4236450195312,0,20.337028503418,0,0,0,0,27.8782424926758,0,0,-92.8959884643555,0,32.4117889404297,0,0,20.4068756103516,0,30.3787231445312,0,9.70655822753906,0,0,-72.5663681030273,0,0,0,20.9883804321289,0,0,0,0,30.8932647705078,0,19.5482788085938,0,0,0,0,-84.2120132446289,0,0,0,0,21.7813034057617,0,0,32.2736663818359,0,21.3195953369141,0,-84.1651611328125,0,0,21.7131576538086,0,32.1408843994141,0,0,0,0,21.6532897949219,0,-84.0346603393555,0,0,0,21.1908874511719,0,32.3425369262695,0,20.2703170776367,0,28.871711730957,0,0,0,0,0,-93.6889114379883,0,0,31.8259735107422,0,0,0,20.5368194580078,0,30.3726501464844,0,10.9573516845703,0,0,-74.597038269043,0,0,21.3934555053711,0,0,30.1805191040039,0,0,0,0,20.1398315429688,0,-84.5661087036133,0,21.3866729736328,0,32.6051254272461,0,0,20.7973861694336,0,0,-83.8446426391602,0,19.875,0,31.6888809204102,0,0,0,0,20.466423034668,0,24.4735794067383,0,0,-88.6295700073242,0,32.0772933959961,0,20.5957870483398,0,29.2512741088867,0,0,0,-94.9116821289062,0,0,31.4967651367188,0,0,21.116584777832,0,30.5763626098633,0,18.4351806640625,0,0,-82.6022567749023,0,0,0,0,21.7134017944336,0,30.0568923950195,0,0,0,20.2055740356445,0,-87.0590896606445,0,0,0,0,19.2906341552734,0,29.8518218994141,0,20.7913360595703,0,0,0,27.7479629516602,0,0,-90.7272415161133,0,0,0,31.6931076049805,0,0,0,20.2700042724609,0,30.1782073974609,0,0,0,0,8.59292602539062,0,0,-71.7781143188477,0,21.7779998779297,0,0,0,0,32.3402633666992,0,17.6438293457031,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,3.47669982910156,0,31.6892547607422,0,0,0,21.5809707641602,0,32.4088745117188,0,14.4323883056641,0,0,-77.5409698486328,0,20.7963256835938,0,0,0,31.2217483520508,0,20.2703018188477,0,-83.7038421630859,0,19.8750534057617,0,0,30.8349685668945,0,0,0,20.3970947265625,0,-83.8318405151367,20.2084426879883,0,0,31.811882019043,0,0,0,0,21.7800598144531,0,27.8800048828125,0,0,-89.9358367919922,0,32.1379165649414,0,21.3197631835938,0,0,0,0,0,32.2095489501953,0,-93.6687927246094,0,31.7484512329102,0,21.1882171630859,0,0,0,0,0,30.8328094482422,0,14.1687316894531,0,0,-77.4696960449219,0,21.576545715332,0,31.8144149780273,0,0,21.6413345336914,0,-83.2321014404297,0,0,21.577995300293,0,31.4291610717773,0,20.4031524658203,0,0,-83.3126907348633,0,20.9945373535156,0,32.0860137939453,0,0,0,0,21.7149963378906,0,0,-49.7633209228516,0,0,0,0,0,-11.5850524902344,0,30.899299621582,0,21.0554504394531,0,0,0,0,30.1144332885742,0,0,-92.1015853881836,0,0,0,0,31.0987777709961,0,21.3893203735352,0,0,30.5117950439453,0,-93.4940719604492,0,0,0,0,0,31.4310836791992,0,20.9854202270508,0,30.7012481689453,0,0,0,0,0,19.4912261962891,0,0,0,0,0,-83.5195083618164,0,20.6062240600586,0,0,0,32.3325042724609,0,0,21.2583389282227,0,-83.0449295043945,0,20.5997085571289,0,31.880989074707,0,20.1433563232422,0,19.7450714111328,0,0,-84.2420654296875,0,32.3357925415039,0,0,0,0,20.9266967773438,0,0,0,30.9610900878906,0,0,-91.6356658935547,0,0,0,0,0,31.8846130371094,0,21.2526321411133,0,30.2414474487305,0,-93.737419128418,0,0,0,31.3007049560547,0,21.0612182617188,0,32.0116500854492,0,17.6455535888672,0,0,-79.3255081176758,0,21.1167907714844,0,31.6791687011719,0,0,0,0,20.1394805908203,0,0,-82.841064453125,0,0,0,0,20.5270233154297,0,30.7641754150391,0,0,21.1209411621094,0,0,-82.1138153076172,0,0,0,0,20.2683868408203,0,31.8757858276367,0,21.511833190918,0,0,25.2529067993164,0,0,-86.3159408569336,0,30.8907012939453,0,21.1219177246094,0,0,0,32.2682800292969,0,-94.8047332763672,0,32.4638290405273,0,0,0,0,0,21.5751647949219,0,31.3497314453125,0,11.4775085449219,0,0,-74.1043472290039,0,21.3847885131836,0,32.7251281738281,0,20.000617980957,0,0,-82.6374816894531,0,21.0528259277344,0,0,0,0,0,32.3992004394531,0,0,21.2541351318359,0,0,0,0,-84.5437088012695,0,0,0,0,20.9208984375,0,32.271125793457,0,21.3806304931641,0,-83.489990234375,0,20.8559265136719,0,30.890380859375,0,0,21.5117721557617,0,28.1374206542969,0,0,-90.5753326416016,0,32.3336868286133,0,0,0,0,21.7732086181641,0,0,0,31.9440002441406,0,-93.9845275878906,0,32.2002868652344,0,20.790657043457,0,30.4365005493164,0,15.0817108154297,0,0,-78.1799545288086,0,0,21.2460708618164,0,0,32.1952896118164,0,21.1125106811523,0,0,-83.5348968505859,0,21.4420852661133,0,0,0,32.3914642333984,0,0,0,0,0,21.5086441040039,0,-82.8841781616211,0,21.4422836303711,0,0,31.8014144897461,0,20.4586486816406,0,20.9844512939453,0,0,-83.7981185913086,0,0,31.4094772338867,0,21.4444198608398,0,0,0,0,0,30.8201675415039,0,0,0,-94.0361022949219,0,31.6066741943359,0,0,21.5715408325195,0,32.325569152832,0,0,-93.1741027832031,0,30.951042175293,0,0,21.1784896850586,0,32.3261032104492,0,0,0,0,0,17.376220703125,0,0,-78.8806533813477,0,0,0,21.7690124511719,0,0,30.8843460083008,0,20.064338684082,0,0,0,0,0,-82.7502822875977,0,0,21.4415893554688,0,31.1464080810547,0,21.310417175293,0,-83.1432189941406,0,21.5698928833008,0,0,32.5832214355469,0,21.5040664672852,0,22.4875717163086,0,0,-84.7040634155273,0,0,31.9942779541016,0,21.5694732666016,0,0,31.1420516967773,0,0,-92.6377868652344,0,0,31.9289855957031,0,21.5702133178711,0,0,32.3215637207031,0,0,0,0,0,-92.9662628173828,0,0,32.2563400268555,0,0,21.8315048217773,0,32.7156677246094,0,12.980827331543,0,0,-73.8875579833984,0,0,0,21.6348266601562,0,32.6490478515625,0,19.6022644042969,0,0,-79.7199935913086,0,0,0,0,0,21.7003860473633,0,0,32.3864059448242,0,21.6349487304688,0,-83.6751708984375,0,0,0,21.7658233642578,0,31.797004699707,0,0,21.5689926147461,0,0,0,0,-83.5228881835938,0,21.4382934570312,0,31.3373031616211,0,0,0,0,9.53433990478516,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpAiBGam/file357c2670b49e.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    790.391    794.0735   1075.106    800.6825
#>    compute_pi0(m * 10)   7869.385   7919.7475   7987.332   7948.9440
#>   compute_pi0(m * 100)  78956.063  79103.1545  80027.887  79361.3815
#>         compute_pi1(m)    163.283    184.7490   6089.053    232.0125
#>    compute_pi1(m * 10)   1270.304   1329.0730   1940.997   1397.0665
#>   compute_pi1(m * 100)  12794.276  12897.3895  16443.850  13933.4145
#>  compute_pi1(m * 1000) 262461.005 334096.7970 361516.370 362775.0190
#>           uq        max neval
#>     808.9415   6279.759    20
#>    8029.6140   8288.579    20
#>   80333.4660  87667.578    20
#>     283.1115 109240.247    20
#>    1492.8175  10312.186    20
#>   19661.0140  25061.034    20
#>  387345.7500 469085.890    20
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
#>   memory_copy1(n) 4569.82076 4234.33472 594.485239 3771.88128 3272.64813
#>   memory_copy2(n)   80.42747   76.14292  11.932872   68.99589   59.55848
#>  pre_allocate1(n)   17.12883   16.29638   3.813372   14.69918   12.60671
#>  pre_allocate2(n)  167.55256  156.37268  23.343246  140.61655  124.02846
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  85.195906    10
#>   2.842727    10
#>   2.120251    10
#>   4.353876    10
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
#>  f1(df) 247.5944 247.3386 86.95149 248.6057 62.72017 41.17126     5
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
