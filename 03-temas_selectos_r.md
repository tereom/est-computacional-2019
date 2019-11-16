
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
#>    id           a        b        c        d
#> 1   1 -1.01139271 1.636112 4.151560 3.557783
#> 2   2 -1.07903732 2.130419 3.715328 4.233399
#> 3   3  0.08948567 1.276631 2.590337 3.051756
#> 4   4  0.28551873 1.220317 4.128475 3.671674
#> 5   5  0.19676463 2.423516 1.184523 7.374211
#> 6   6  0.09412745 2.012393 3.876039 4.158166
#> 7   7  1.21052977 3.101240 2.302659 4.240041
#> 8   8  0.43421421 2.710012 3.386001 6.445357
#> 9   9 -0.40628677 2.749292 4.402172 4.689637
#> 10 10 -1.01920313 2.518660 2.459556 3.458039
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.1205279
mean(df$b)
#> [1] 2.177859
mean(df$c)
#> [1] 3.219665
mean(df$d)
#> [1] 4.488006
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.1205279  2.1778592  3.2196650  4.4880063
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
#> [1] -0.1205279  2.1778592  3.2196650  4.4880063
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
#> [1]  5.5000000 -0.1205279  2.1778592  3.2196650  4.4880063
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
#> [1] 5.50000000 0.09180656 2.27696748 3.55066467 4.19578246
col_describe(df, mean)
#> [1]  5.5000000 -0.1205279  2.1778592  3.2196650  4.4880063
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
#>  5.5000000 -0.1205279  2.1778592  3.2196650  4.4880063
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
#>   3.974   0.112   4.084
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.017   0.004   0.616
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
#>  13.801   0.877  10.440
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
#>   4.088   0.000   4.087
est_l_st
#>    user  system elapsed 
#>  62.434   1.623  64.028
est_r_st
#>    user  system elapsed 
#>   0.393   0.008   0.401
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

<!--html_preserve--><div id="htmlwidget-c6299609b5fdb5bbf68b" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-c6299609b5fdb5bbf68b">{"x":{"message":{"prof":{"time":[1,1,1,2,2,3,3,3,3,3,4,4,5,5,5,6,6,6,6,6,7,7,8,8,9,9,9,10,10,10,11,11,12,12,12,13,13,13,13,13,14,14,15,15,15,16,16,17,17,17,17,17,18,18,18,19,19,19,20,20,20,20,20,21,21,22,22,23,23,24,24,24,25,25,26,26,27,27,28,28,28,29,29,29,29,30,30,31,31,31,31,31,32,32,32,33,33,34,34,35,35,36,36,36,36,36,37,37,38,38,39,39,39,40,40,40,41,41,41,42,42,42,43,43,43,44,44,45,45,46,46,46,47,47,47,48,48,48,48,48,48,49,49,49,49,50,50,50,51,51,51,52,52,53,53,53,53,53,54,54,55,55,56,56,56,57,57,58,58,58,58,59,59,59,59,59,60,60,60,61,61,61,61,61,62,62,63,63,64,64,64,65,65,65,66,66,67,67,67,68,68,68,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,75,75,76,76,76,76,76,77,77,78,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,91,91,92,92,93,93,94,94,94,94,95,95,96,96,96,97,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,102,102,103,103,103,104,104,104,104,104,105,105,106,106,107,107,107,108,108,108,109,109,110,110,110,110,110,111,111,111,111,112,112,112,113,113,113,114,114,115,115,116,116,117,117,117,117,118,118,119,119,120,120,120,121,121,121,121,121,122,122,123,123,124,124,125,125,125,126,126,126,126,126,127,127,128,128,129,129,129,129,129,130,130,130,130,130,131,131,131,131,131,132,132,133,133,134,134,134,135,135,135,135,135,135,136,136,137,137,137,138,138,138,138,139,139,140,140,141,141,141,142,142,143,143,144,144,145,145,145,145,145,145,146,146,146,146,146,147,147,147,148,148,149,149,150,150,150,151,151,152,152,152,152,153,153,154,154,155,155,155,156,156,156,156,156,156,157,157,158,158,158,158,159,159,160,160,161,161,161,162,162,163,163,164,164,164,164,164,165,165,165,165,165,166,166,166,166,166,167,167,167,167,167,168,168,168,168,168,169,169,169,170,170,171,171,172,172,173,173,174,174,174,175,175,175,175,176,176,177,177,177,177,177,177,178,178,179,179,180,180,180,181,181,181,182,182,183,183,184,184,185,185,186,186,187,187,187,188,188,189,189,190,190,190,191,191,192,192,192,193,193,194,194,194,194,195,195,196,196,196,197,197,198,198,199,199,199,199,199,200,200,201,201,202,202,203,203,204,204,204,204,204,205,205,205,206,206,207,207,208,208,209,209,209,210,210,211,211,211,211,211,212,212,213,213,213,213,213,214,214,214,214,215,215,215,215,215,216,216,216,217,217,217,217,217,217,218,218,218,218,218,219,219,220,220,220,220,220,220,221,221,222,222,223,223,223,223,223,224,224,225,225,226,226,226,227,227,227,228,228,229,229,230,230,230,230,230,231,231,231,232,232,232,233,233,234,234,235,235,236,236,236,236,236,236,237,237,238,238,238,239,239,240,240,240,241,241,241,242,242,242,242,242,243,243,243,243,243,244,244,245,245,246,246,247,247,247,247,248,248,248,248,249,249,250,251,251,251,251,251,251,252,252,252,253,253,253,254,254,255,255,255,255,255,255,256,256,257,257,257,258,258,258,258,258,259,259,260,260,260,260,260,261,261,262,262,262,262,263,263,263,263,263,264,264,264,264,264,264,265,265,266,266,266,267,267,267,268,268,268,268,268,269,269,270,270,271,271,272,272,272,273,273,273,274,274,275,275,275,276,276,277,277,277,278,278,279,279,279,280,280,281,281,281,282,282,283,283,283,283,283],"depth":[3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,4,3,2,1,2,1,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1],"label":["==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,null,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1],"linenum":[null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,11,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,null,11,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,10,10,null,null,9,9,null,null,9,9,9,9,10,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,13],"memalloc":[57.6918563842773,57.6918563842773,57.6918563842773,78.6815567016602,78.6815567016602,106.760864257812,106.760864257812,106.760864257812,106.760864257812,106.760864257812,124.21012878418,124.21012878418,146.314712524414,146.314712524414,146.314712524414,53.8933258056641,53.8933258056641,53.8933258056641,53.8933258056641,53.8933258056641,85.713508605957,85.713508605957,105.264907836914,105.264907836914,133.928337097168,133.928337097168,133.928337097168,146.325996398926,146.325996398926,146.325996398926,67.0795059204102,67.0795059204102,88.2027435302734,88.2027435302734,88.2027435302734,117.599426269531,117.599426269531,117.599426269531,117.599426269531,117.599426269531,137.545547485352,137.545547485352,50.4168853759766,50.4168853759766,50.4168853759766,71.4065704345703,71.4065704345703,102.627342224121,102.627342224121,102.627342224121,102.627342224121,102.627342224121,121.255546569824,121.255546569824,121.255546569824,146.313613891602,146.313613891602,146.313613891602,54.8192596435547,54.8192596435547,54.8192596435547,54.8192596435547,54.8192596435547,86.4396743774414,86.4396743774414,107.16756439209,107.16756439209,139.376052856445,139.376052856445,110.592109680176,110.592109680176,110.592109680176,73.9736099243164,73.9736099243164,94.7029342651367,94.7029342651367,126.586334228516,126.586334228516,146.333457946777,146.333457946777,146.333457946777,60.2003860473633,60.2003860473633,60.2003860473633,60.2003860473633,81.3196105957031,81.3196105957031,111.764068603516,111.764068603516,111.764068603516,111.764068603516,111.764068603516,131.840400695801,131.840400695801,131.840400695801,44.3253631591797,44.3253631591797,64.2683410644531,64.2683410644531,95.4381484985352,95.4381484985352,115.314796447754,115.314796447754,115.314796447754,115.314796447754,115.314796447754,144.837593078613,144.837593078613,47.6069488525391,47.6069488525391,79.1006774902344,79.1006774902344,79.1006774902344,99.5771713256836,99.5771713256836,99.5771713256836,129.492988586426,129.492988586426,129.492988586426,146.283760070801,146.283760070801,146.283760070801,63.033203125,63.033203125,63.033203125,83.3651123046875,83.3651123046875,113.808258056641,113.808258056641,133.883407592773,133.883407592773,133.883407592773,47.0196380615234,47.0196380615234,47.0196380615234,67.6191940307617,67.6191940307617,67.6191940307617,67.6191940307617,67.6191940307617,67.6191940307617,99.24365234375,99.24365234375,99.24365234375,99.24365234375,119.447486877441,119.447486877441,119.447486877441,146.281112670898,146.281112670898,146.281112670898,52.9271545410156,52.9271545410156,83.8274078369141,83.8274078369141,83.8274078369141,83.8274078369141,83.8274078369141,104.091537475586,104.091537475586,134.13102722168,134.13102722168,146.336753845215,146.336753845215,146.336753845215,68.3532180786133,68.3532180786133,89.0799255371094,89.0799255371094,89.0799255371094,89.0799255371094,117.948394775391,117.948394775391,117.948394775391,117.948394775391,117.948394775391,136.382446289062,136.382446289062,136.382446289062,48.4039764404297,48.4039764404297,48.4039764404297,48.4039764404297,48.4039764404297,68.5425567626953,68.5425567626953,99.7090225219727,99.7090225219727,119.262199401855,119.262199401855,119.262199401855,146.28938293457,146.28938293457,146.28938293457,51.8827209472656,51.8827209472656,82.7872772216797,82.7872772216797,82.7872772216797,101.683685302734,101.683685302734,101.683685302734,133.75545501709,133.75545501709,146.285026550293,146.285026550293,146.285026550293,68.6819534301758,68.6819534301758,68.6819534301758,89.1544036865234,89.1544036865234,89.1544036865234,119.06908416748,119.06908416748,119.06908416748,138.35489654541,138.35489654541,52.1492004394531,52.1492004394531,72.6108551025391,72.6108551025391,72.6108551025391,72.6108551025391,72.6108551025391,104.689193725586,104.689193725586,125.681381225586,125.681381225586,125.681381225586,125.681381225586,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,146.276252746582,42.7696838378906,42.7696838378906,42.7696838378906,49.5278472900391,49.5278472900391,79.7063598632812,79.7063598632812,99.2545700073242,99.2545700073242,127.590744018555,127.590744018555,146.291931152344,146.291931152344,146.291931152344,146.291931152344,62.8478927612305,62.8478927612305,83.7770004272461,83.7770004272461,83.7770004272461,114.278327941895,114.278327941895,114.278327941895,114.278327941895,134.153305053711,134.153305053711,134.153305053711,49.3998794555664,49.3998794555664,49.3998794555664,70.1292953491211,70.1292953491211,70.1292953491211,101.620422363281,101.620422363281,101.620422363281,122.935882568359,122.935882568359,122.935882568359,122.935882568359,122.935882568359,146.283630371094,146.283630371094,146.283630371094,59.9648056030273,59.9648056030273,59.9648056030273,59.9648056030273,59.9648056030273,91.6479644775391,91.6479644775391,112.965980529785,112.965980529785,144.717491149902,144.717491149902,144.717491149902,49.3369216918945,49.3369216918945,49.3369216918945,80.7552795410156,80.7552795410156,100.822189331055,100.822189331055,100.822189331055,100.822189331055,100.822189331055,132.708831787109,132.708831787109,132.708831787109,132.708831787109,146.286842346191,146.286842346191,146.286842346191,68.9546127319336,68.9546127319336,68.9546127319336,89.4178466796875,89.4178466796875,121.103759765625,121.103759765625,142.290306091309,142.290306091309,57.9299545288086,57.9299545288086,57.9299545288086,57.9299545288086,77.3517990112305,77.3517990112305,109.751350402832,109.751350402832,131.133567810059,131.133567810059,131.133567810059,47.5020217895508,47.5020217895508,47.5020217895508,47.5020217895508,47.5020217895508,67.9032287597656,67.9032287597656,99.1994476318359,99.1994476318359,120.453254699707,120.453254699707,146.303588867188,146.303588867188,146.303588867188,57.6748580932617,57.6748580932617,57.6748580932617,57.6748580932617,57.6748580932617,89.0396270751953,89.0396270751953,110.426918029785,110.426918029785,142.045806884766,142.045806884766,142.045806884766,142.045806884766,142.045806884766,47.5732574462891,47.5732574462891,47.5732574462891,47.5732574462891,47.5732574462891,79.1305694580078,79.1305694580078,79.1305694580078,79.1305694580078,79.1305694580078,100.77392578125,100.77392578125,129.705772399902,129.705772399902,146.303024291992,146.303024291992,146.303024291992,65.6800689697266,65.6800689697266,65.6800689697266,65.6800689697266,65.6800689697266,65.6800689697266,86.938606262207,86.938606262207,117.64510345459,117.64510345459,117.64510345459,137.396171569824,137.396171569824,137.396171569824,137.396171569824,53.3469009399414,53.3469009399414,74.1519393920898,74.1519393920898,106.158699035645,106.158699035645,106.158699035645,127.215606689453,127.215606689453,44.1006317138672,44.1006317138672,63.7795486450195,63.7795486450195,95.7971954345703,95.7971954345703,95.7971954345703,95.7971954345703,95.7971954345703,95.7971954345703,117.046340942383,117.046340942383,117.046340942383,117.046340942383,117.046340942383,146.308456420898,146.308456420898,146.308456420898,54.6693344116211,54.6693344116211,85.9599609375,85.9599609375,107.018714904785,107.018714904785,107.018714904785,138.63996887207,138.63996887207,44.8898315429688,44.8898315429688,44.8898315429688,44.8898315429688,75.9781265258789,75.9781265258789,97.1636734008789,97.1636734008789,128.718063354492,128.718063354492,128.718063354492,146.297546386719,146.297546386719,146.297546386719,146.297546386719,146.297546386719,146.297546386719,66.3388366699219,66.3388366699219,86.2846755981445,86.2846755981445,86.2846755981445,86.2846755981445,118.691680908203,118.691680908203,139.746513366699,139.746513366699,56.0460052490234,56.0460052490234,56.0460052490234,76.6531677246094,76.6531677246094,109.061210632324,109.061210632324,130.251426696777,130.251426696777,130.251426696777,130.251426696777,130.251426696777,46.7969512939453,46.7969512939453,46.7969512939453,46.7969512939453,46.7969512939453,67.3922424316406,67.3922424316406,67.3922424316406,67.3922424316406,67.3922424316406,97.1668090820312,97.1668090820312,97.1668090820312,97.1668090820312,97.1668090820312,115.333541870117,115.333541870117,115.333541870117,115.333541870117,115.333541870117,146.296119689941,146.296119689941,146.296119689941,52.5014343261719,52.5014343261719,83.653450012207,83.653450012207,104.252159118652,104.252159118652,135.407493591309,135.407493591309,146.297912597656,146.297912597656,146.297912597656,71.7263031005859,71.7263031005859,71.7263031005859,71.7263031005859,92.5190124511719,92.5190124511719,123.605926513672,123.605926513672,123.605926513672,123.605926513672,123.605926513672,123.605926513672,143.21745300293,143.21745300293,59.1317901611328,59.1317901611328,79.724235534668,79.724235534668,79.724235534668,111.211280822754,111.211280822754,111.211280822754,130.951477050781,130.951477050781,44.934211730957,44.934211730957,65.725212097168,65.725212097168,97.7953567504883,97.7953567504883,118.518051147461,118.518051147461,146.326118469238,146.326118469238,146.326118469238,51.8874130249023,51.8874130249023,83.0456314086914,83.0456314086914,104.098793029785,104.098793029785,104.098793029785,136.100471496582,136.100471496582,146.331474304199,146.331474304199,146.331474304199,70.6475982666016,70.6475982666016,90.5845947265625,90.5845947265625,90.5845947265625,90.5845947265625,122.72176361084,122.72176361084,143.910591125488,143.910591125488,143.910591125488,59.3655700683594,59.3655700683594,79.6313095092773,79.6313095092773,111.705879211426,111.705879211426,111.705879211426,111.705879211426,111.705879211426,133.217567443848,133.217567443848,48.8081893920898,48.8081893920898,69.5987930297852,69.5987930297852,102.129272460938,102.129272460938,123.313812255859,123.313812255859,123.313812255859,123.313812255859,123.313812255859,146.334434509277,146.334434509277,146.334434509277,59.8259124755859,59.8259124755859,92.028205871582,92.028205871582,112.491218566895,112.491218566895,142.533142089844,142.533142089844,142.533142089844,46.5817108154297,46.5817108154297,77.9934005737305,77.9934005737305,77.9934005737305,77.9934005737305,77.9934005737305,99.243537902832,99.243537902832,130.992462158203,130.992462158203,130.992462158203,130.992462158203,130.992462158203,146.337104797363,146.337104797363,146.337104797363,146.337104797363,67.6962203979492,67.6962203979492,67.6962203979492,67.6962203979492,67.6962203979492,88.8765029907227,88.8765029907227,88.8765029907227,121.530975341797,121.530975341797,121.530975341797,121.530975341797,121.530975341797,121.530975341797,141.070198059082,141.070198059082,141.070198059082,141.070198059082,141.070198059082,57.7321472167969,57.7321472167969,78.8469009399414,78.8469009399414,78.8469009399414,78.8469009399414,78.8469009399414,78.8469009399414,111.500091552734,111.500091552734,132.418037414551,132.418037414551,48.6809005737305,48.6809005737305,48.6809005737305,48.6809005737305,48.6809005737305,69.9254913330078,69.9254913330078,102.317924499512,102.317924499512,123.629028320312,123.629028320312,123.629028320312,146.31778717041,146.31778717041,146.31778717041,61.4709014892578,61.4709014892578,92.814567565918,92.814567565918,113.865509033203,113.865509033203,113.865509033203,113.865509033203,113.865509033203,146.325141906738,146.325141906738,146.325141906738,51.6997375488281,51.6997375488281,51.6997375488281,83.1087188720703,83.1087188720703,104.22191619873,104.22191619873,136.416137695312,136.416137695312,146.317481994629,146.317481994629,146.317481994629,146.317481994629,146.317481994629,146.317481994629,73.207878112793,73.207878112793,94.2562713623047,94.2562713623047,94.2562713623047,126.975189208984,126.975189208984,146.318641662598,146.318641662598,146.318641662598,65.0130462646484,65.0130462646484,65.0130462646484,86.3230514526367,86.3230514526367,86.3230514526367,86.3230514526367,86.3230514526367,118.781272888184,118.781272888184,118.781272888184,118.781272888184,118.781272888184,139.43546295166,139.43546295166,55.8326187133789,55.8326187133789,77.208251953125,77.208251953125,109.731979370117,109.731979370117,109.731979370117,109.731979370117,130.977012634277,130.977012634277,130.977012634277,130.977012634277,47.7025833129883,47.7025833129883,69.0753936767578,100.872680664062,100.872680664062,100.872680664062,100.872680664062,100.872680664062,100.872680664062,122.638778686523,122.638778686523,122.638778686523,146.306625366211,146.306625366211,146.306625366211,60.028450012207,60.028450012207,91.8255920410156,91.8255920410156,91.8255920410156,91.8255920410156,91.8255920410156,91.8255920410156,113.460609436035,113.460609436035,146.045379638672,146.045379638672,146.045379638672,51.6372222900391,51.6372222900391,51.6372222900391,51.6372222900391,51.6372222900391,83.6971740722656,83.6971740722656,105.267051696777,105.267051696777,105.267051696777,105.267051696777,105.267051696777,137.982070922852,137.982070922852,44.2294921875,44.2294921875,44.2294921875,44.2294921875,75.371223449707,75.371223449707,75.371223449707,75.371223449707,75.371223449707,96.7435913085938,96.7435913085938,96.7435913085938,96.7435913085938,96.7435913085938,96.7435913085938,127.951583862305,127.951583862305,146.30876159668,146.30876159668,146.30876159668,64.9470138549805,64.9470138549805,64.9470138549805,84.680908203125,84.680908203125,84.680908203125,84.680908203125,84.680908203125,117.460357666016,117.460357666016,138.767677307129,138.767677307129,55.5070266723633,55.5070266723633,76.6831512451172,76.6831512451172,76.6831512451172,107.430595397949,107.430595397949,107.430595397949,127.164375305176,127.164375305176,146.307952880859,146.307952880859,146.307952880859,61.0608062744141,61.0608062744141,92.7267227172852,92.7267227172852,92.7267227172852,112.853286743164,112.853286743164,144.650276184082,144.650276184082,144.650276184082,48.9981994628906,48.9981994628906,80.5330810546875,80.5330810546875,80.5330810546875,101.97093963623,101.97093963623,113.603080749512,113.603080749512,113.603080749512,113.603080749512,113.603080749512],"meminc":[0,0,0,20.9897003173828,0,28.0793075561523,0,0,0,0,17.4492645263672,0,22.1045837402344,0,0,-92.42138671875,0,0,0,0,31.820182800293,0,19.551399230957,0,28.6634292602539,0,0,12.3976593017578,0,0,-79.2464904785156,0,21.1232376098633,0,0,29.3966827392578,0,0,0,0,19.9461212158203,0,-87.128662109375,0,0,20.9896850585938,0,31.2207717895508,0,0,0,0,18.6282043457031,0,0,25.0580673217773,0,0,-91.4943542480469,0,0,0,0,31.6204147338867,0,20.7278900146484,0,32.2084884643555,0,-28.7839431762695,0,0,-36.6184997558594,0,20.7293243408203,0,31.8833999633789,0,19.7471237182617,0,0,-86.1330718994141,0,0,0,21.1192245483398,0,30.4444580078125,0,0,0,0,20.0763320922852,0,0,-87.5150375366211,0,19.9429779052734,0,31.169807434082,0,19.8766479492188,0,0,0,0,29.5227966308594,0,-97.2306442260742,0,31.4937286376953,0,0,20.4764938354492,0,0,29.9158172607422,0,0,16.790771484375,0,0,-83.2505569458008,0,0,20.3319091796875,0,30.4431457519531,0,20.0751495361328,0,0,-86.86376953125,0,0,20.5995559692383,0,0,0,0,0,31.6244583129883,0,0,0,20.2038345336914,0,0,26.833625793457,0,0,-93.3539581298828,0,30.9002532958984,0,0,0,0,20.2641296386719,0,30.0394897460938,0,12.2057266235352,0,0,-77.9835357666016,0,20.7267074584961,0,0,0,28.8684692382812,0,0,0,0,18.4340515136719,0,0,-87.9784698486328,0,0,0,0,20.1385803222656,0,31.1664657592773,0,19.5531768798828,0,0,27.0271835327148,0,0,-94.4066619873047,0,30.9045562744141,0,0,18.8964080810547,0,0,32.0717697143555,0,12.5295715332031,0,0,-77.6030731201172,0,0,20.4724502563477,0,0,29.914680480957,0,0,19.2858123779297,0,-86.205696105957,0,20.4616546630859,0,0,0,0,32.0783386230469,0,20.9921875,0,0,0,20.5948715209961,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,6.75816345214844,0,30.1785125732422,0,19.548210144043,0,28.3361740112305,0,18.7011871337891,0,0,0,-83.4440383911133,0,20.9291076660156,0,0,30.5013275146484,0,0,0,19.8749771118164,0,0,-84.7534255981445,0,0,20.7294158935547,0,0,31.4911270141602,0,0,21.3154602050781,0,0,0,0,23.3477478027344,0,0,-86.3188247680664,0,0,0,0,31.6831588745117,0,21.3180160522461,0,31.7515106201172,0,0,-95.3805694580078,0,0,31.4183578491211,0,20.0669097900391,0,0,0,0,31.8866424560547,0,0,0,13.578010559082,0,0,-77.3322296142578,0,0,20.4632339477539,0,31.6859130859375,0,21.1865463256836,0,-84.3603515625,0,0,0,19.4218444824219,0,32.3995513916016,0,21.3822174072266,0,0,-83.6315460205078,0,0,0,0,20.4012069702148,0,31.2962188720703,0,21.2538070678711,0,25.8503341674805,0,0,-88.6287307739258,0,0,0,0,31.3647689819336,0,21.3872909545898,0,31.6188888549805,0,0,0,0,-94.4725494384766,0,0,0,0,31.5573120117188,0,0,0,0,21.6433563232422,0,28.9318466186523,0,16.5972518920898,0,0,-80.6229553222656,0,0,0,0,0,21.2585372924805,0,30.7064971923828,0,0,19.7510681152344,0,0,0,-84.0492706298828,0,20.8050384521484,0,32.0067596435547,0,0,21.0569076538086,0,-83.1149749755859,0,19.6789169311523,0,32.0176467895508,0,0,0,0,0,21.2491455078125,0,0,0,0,29.2621154785156,0,0,-91.6391220092773,0,31.2906265258789,0,21.0587539672852,0,0,31.6212539672852,0,-93.7501373291016,0,0,0,31.0882949829102,0,21.185546875,0,31.5543899536133,0,0,17.5794830322266,0,0,0,0,0,-79.9587097167969,0,19.9458389282227,0,0,0,32.4070053100586,0,21.0548324584961,0,-83.7005081176758,0,0,20.6071624755859,0,32.4080429077148,0,21.1902160644531,0,0,0,0,-83.454475402832,0,0,0,0,20.5952911376953,0,0,0,0,29.7745666503906,0,0,0,0,18.1667327880859,0,0,0,0,30.9625778198242,0,0,-93.7946853637695,0,31.1520156860352,0,20.5987091064453,0,31.1553344726562,0,10.8904190063477,0,0,-74.5716094970703,0,0,0,20.7927093505859,0,31.0869140625,0,0,0,0,0,19.6115264892578,0,-84.0856628417969,0,20.5924453735352,0,0,31.4870452880859,0,0,19.7401962280273,0,-86.0172653198242,0,20.7910003662109,0,32.0701446533203,0,20.7226943969727,0,27.8080673217773,0,0,-94.4387054443359,0,31.1582183837891,0,21.0531616210938,0,0,32.0016784667969,0,10.2310028076172,0,0,-75.6838760375977,0,19.9369964599609,0,0,0,32.1371688842773,0,21.1888275146484,0,0,-84.5450210571289,0,20.265739440918,0,32.0745697021484,0,0,0,0,21.5116882324219,0,-84.4093780517578,0,20.7906036376953,0,32.5304794311523,0,21.1845397949219,0,0,0,0,23.020622253418,0,0,-86.5085220336914,0,32.2022933959961,0,20.4630126953125,0,30.0419235229492,0,0,-95.9514312744141,0,31.4116897583008,0,0,0,0,21.2501373291016,0,31.7489242553711,0,0,0,0,15.3446426391602,0,0,0,-78.6408843994141,0,0,0,0,21.1802825927734,0,0,32.6544723510742,0,0,0,0,0,19.5392227172852,0,0,0,0,-83.3380508422852,0,21.1147537231445,0,0,0,0,0,32.653190612793,0,20.9179458618164,0,-83.7371368408203,0,0,0,0,21.2445907592773,0,32.3924331665039,0,21.3111038208008,0,0,22.6887588500977,0,0,-84.8468856811523,0,31.3436660766602,0,21.0509414672852,0,0,0,0,32.4596328735352,0,0,-94.6254043579102,0,0,31.4089813232422,0,21.1131973266602,0,32.194221496582,0,9.90134429931641,0,0,0,0,0,-73.1096038818359,0,21.0483932495117,0,0,32.7189178466797,0,19.3434524536133,0,0,-81.3055953979492,0,0,21.3100051879883,0,0,0,0,32.4582214355469,0,0,0,0,20.6541900634766,0,-83.6028442382812,0,21.3756332397461,0,32.5237274169922,0,0,0,21.2450332641602,0,0,0,-83.2744293212891,0,21.3728103637695,31.7972869873047,0,0,0,0,0,21.7660980224609,0,0,23.6678466796875,0,0,-86.2781753540039,0,31.7971420288086,0,0,0,0,0,21.6350173950195,0,32.5847702026367,0,0,-94.4081573486328,0,0,0,0,32.0599517822266,0,21.5698776245117,0,0,0,0,32.7150192260742,0,-93.7525787353516,0,0,0,31.141731262207,0,0,0,0,21.3723678588867,0,0,0,0,0,31.2079925537109,0,18.357177734375,0,0,-81.3617477416992,0,0,19.7338943481445,0,0,0,0,32.7794494628906,0,21.3073196411133,0,-83.2606506347656,0,21.1761245727539,0,0,30.747444152832,0,0,19.7337799072266,0,19.1435775756836,0,0,-85.2471466064453,0,31.6659164428711,0,0,20.1265640258789,0,31.796989440918,0,0,-95.6520767211914,0,31.5348815917969,0,0,21.437858581543,0,11.6321411132812,0,0,0,0],"filename":[null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmp75X6l2/file3ad354ce784a.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    785.073    793.9585    807.1086    800.9600
#>    compute_pi0(m * 10)   7875.121   7907.2825   7981.8443   7949.0775
#>   compute_pi0(m * 100)  78740.849  79029.9320  79799.1357  79312.4085
#>         compute_pi1(m)    164.566    208.9960    671.7128    271.0815
#>    compute_pi1(m * 10)   1287.444   1316.3585   1389.0517   1396.1665
#>   compute_pi1(m * 100)  13090.019  13439.8755  22885.9890  17231.6330
#>  compute_pi1(m * 1000) 261594.310 376019.3410 375817.2568 384048.3435
#>           uq        max neval
#>     808.3585    861.715    20
#>    8023.2415   8257.169    20
#>   79890.6620  85797.284    20
#>     299.1045   8727.703    20
#>    1455.9565   1490.485    20
#>   20552.4040 134227.087    20
#>  388661.1835 488704.908    20
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
#>              expr        min         lq       mean     median          uq
#>   memory_copy1(n) 5639.73753 3911.16577 568.359422 3316.88684 2228.701474
#>   memory_copy2(n)   97.57595   68.79082  11.057703   60.22661   42.896064
#>  pre_allocate1(n)   21.24165   14.77939   3.487521   12.83627    8.329693
#>  pre_allocate2(n)  206.27092  144.51799  21.383430  124.32291   84.752446
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.000000
#>        max neval
#>  86.791444    10
#>   2.718436    10
#>   1.926532    10
#>   4.028975    10
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
#>  f1(df) 253.3503 246.8537 79.79299 195.6253 68.24215 29.32804     5
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
