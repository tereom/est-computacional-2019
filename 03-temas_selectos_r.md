
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
#> 1   1 -0.28430412 2.5051766 2.296912 2.030959
#> 2   2 -0.30384616 2.9777399 2.923198 3.765206
#> 3   3 -0.57493840 0.9337207 2.106321 3.378323
#> 4   4 -0.01229109 2.0588207 4.429956 1.892239
#> 5   5 -0.89917177 2.3617836 3.988669 3.484772
#> 6   6 -0.06274762 1.6724023 4.694340 3.931569
#> 7   7  0.19395253 0.6483803 2.069775 2.290945
#> 8   8 -0.26271956 1.1422134 5.434102 5.267077
#> 9   9  0.63304950 1.9352643 4.339416 4.131909
#> 10 10  0.43403990 1.3051475 2.887647 4.977729
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.1138977
mean(df$b)
#> [1] 1.754065
mean(df$c)
#> [1] 3.517034
mean(df$d)
#> [1] 3.515073
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.1138977  1.7540649  3.5170336  3.5150728
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
#> [1] -0.1138977  1.7540649  3.5170336  3.5150728
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
#> [1]  5.5000000 -0.1138977  1.7540649  3.5170336  3.5150728
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
#> [1]  5.5000000 -0.1627336  1.8038333  3.4559332  3.6249890
col_describe(df, mean)
#> [1]  5.5000000 -0.1138977  1.7540649  3.5170336  3.5150728
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
#>  5.5000000 -0.1138977  1.7540649  3.5170336  3.5150728
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
#>   3.120   0.124   3.245
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.019   0.005   0.715
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
#>  12.826   0.912   9.647
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
#>   0.131   0.000   0.130
plyr_st
#>    user  system elapsed 
#>   5.858   0.011   5.872
est_l_st
#>    user  system elapsed 
#>  68.542   1.447  70.032
est_r_st
#>    user  system elapsed 
#>   0.434   0.000   0.434
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

<!--html_preserve--><div id="htmlwidget-61df4ad6a1fbd2e1e6ad" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-61df4ad6a1fbd2e1e6ad">{"x":{"message":{"prof":{"time":[1,1,1,2,2,2,3,3,3,3,3,4,4,4,5,5,6,6,6,7,7,7,8,8,8,8,8,8,9,9,9,9,9,10,10,11,11,11,12,12,12,12,12,13,13,14,14,15,15,16,16,17,17,18,18,19,19,19,20,20,20,20,20,20,21,21,21,21,22,22,22,23,23,24,24,24,25,25,26,26,26,26,26,26,27,27,28,28,28,28,28,29,29,29,30,30,30,31,31,31,31,31,31,32,32,32,33,33,33,33,33,33,34,34,34,34,34,35,35,36,36,36,37,37,37,38,38,39,39,39,40,40,40,40,40,41,41,41,42,42,42,43,43,44,44,44,44,45,45,46,46,46,46,47,47,47,48,49,49,50,50,51,51,52,52,52,52,53,53,54,54,55,55,55,55,55,56,56,56,57,57,58,58,59,59,60,60,60,60,61,61,62,62,63,63,64,64,65,65,66,66,67,67,68,68,68,69,69,69,70,70,71,71,72,72,73,73,73,74,74,74,75,75,75,75,75,76,76,76,77,77,78,78,78,79,79,79,80,80,80,80,80,81,81,81,82,82,82,82,82,83,83,83,84,84,84,84,84,84,85,85,86,86,87,87,87,88,88,89,89,89,89,89,90,90,90,91,91,91,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,103,104,104,104,105,105,105,105,105,106,106,107,107,107,108,108,108,108,109,109,109,110,110,111,111,111,111,111,111,112,112,112,113,113,113,113,114,114,114,115,115,116,116,116,116,116,117,117,118,118,118,118,118,118,119,119,119,120,120,120,121,121,122,122,123,123,124,124,125,125,125,125,125,125,126,126,126,127,127,127,128,128,128,129,129,130,130,130,130,131,131,131,132,132,133,133,133,133,133,134,134,134,135,135,136,136,136,137,137,138,138,139,139,140,140,140,141,141,141,141,141,141,142,142,143,143,144,144,144,145,145,146,146,147,147,148,148,148,149,150,150,151,151,151,152,152,152,153,153,153,153,154,154,155,155,155,156,156,156,156,156,156,157,157,158,158,158,159,159,160,160,160,160,160,161,161,162,162,162,163,163,164,164,164,165,165,165,165,165,166,166,166,166,167,167,167,168,168,169,169,169,170,170,171,171,172,172,172,173,173,174,174,175,175,175,175,175,176,176,176,176,177,177,178,178,178,178,179,179,179,180,180,180,180,180,181,181,181,182,182,183,183,183,184,184,185,185,186,186,186,186,186,186,187,187,187,187,187,188,188,189,189,189,189,190,190,190,190,190,191,191,192,192,193,193,193,193,194,194,195,195,196,196,197,197,197,197,197,197,198,198,198,198,199,199,199,199,200,200,200,201,201,202,202,202,203,203,204,204,205,205,206,206,207,207,207,207,207,207,208,208,209,209,210,210,210,210,210,211,212,212,213,213,213,213,213,213,214,214,214,215,215,216,216,217,217,217,217,217,218,218,218,218,218,218,219,219,220,220,220,221,221,221,222,222,223,223,224,224,224,225,225,225,225,226,226,226,226,226,226,227,227,228,228,229,229,229,229,229,230,230,230,231,231,232,232,232,232,232,232,233,233,234,234,235,235,235,236,236,236,236,236,237,237,237,237,237,237,238,238,238,238,238,239,239,239,239,239,239,240,240,240,241,241,242,242,243,243,243,244,244,244,244,244,245,245,246,246,247,247,248,248,248,248,248,249,249,250,250,250,251,251,252,252,252,252,252,253,253,253,254,254,255,255,255,256,256,256,256,256,257,257,258,258,259,259,259,259,260,260,260,261,261,261,261,262,262,262,262,262,263,263,263,264,264,265,265,265,265,265,265,266,266,266,266,266,266,267,267,267,268,268,268,268,268,269,269,269,269,269,270,270,270,271,271,271,272,272,272,272,273,273,273,274,274,275,275,275,275,275,275,276,276,276,277,277,277,278,278,279,279,280,280,281,281,282,282,282,282,283,283,284,284,284,284,284,285,285,286,286,286,286,286,286,287,287,287,288,288,288,289,289,289,290,290,291,291,292,292,292,292,293,293,294,294,294,294,294,295,295,295,296,296,296,296,297,297,297,298,298,298,298,298,298,299,299,299,300,300,300,301,301,301,301,301,301,302,302,302,303,303,304,304,304,305,305,305,305,305,306,306,306,306,306,307,307,308,308,308,308,309,309,309,309,310,310,311,311,312,312,312,313,313,314,314,314,315,315,316,316,317,317,317,318,318,319,319,319,320,320,320,321,321,321,321,322,323,323,323,323,323,324,324,325,325,325,326,326,327,327,328,328,329,329,329,329,329,330,330,330,330,330],"depth":[3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,4,3,2,1,3,2,1,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","for (i in 1:n_players) {","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","attr","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","names","names","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","attr","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[[.data.frame","[[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","nrow","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,null,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,null,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,null,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,null,null,null,null,1],"linenum":[null,9,9,null,9,9,null,null,null,9,9,null,null,11,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,10,10,null,null,9,9,9,9,null,null,9,9,null,9,9,8,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,11,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,null,11,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,10,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,10,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,null,11,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,null,11,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,null,11,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,10,10,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,11,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,13,null,null,null,null,13],"memalloc":[59.2190475463867,59.2190475463867,59.2190475463867,78.1079635620117,78.1079635620117,78.1079635620117,103.561943054199,103.561943054199,103.561943054199,103.561943054199,103.561943054199,118.979507446289,118.979507446289,118.979507446289,140.820861816406,140.820861816406,146.265830993652,146.265830993652,146.265830993652,61.4553298950195,61.4553298950195,61.4553298950195,75.7570266723633,75.7570266723633,75.7570266723633,75.7570266723633,75.7570266723633,75.7570266723633,99.6380996704102,99.6380996704102,99.6380996704102,99.6380996704102,99.6380996704102,116.300537109375,116.300537109375,141.424911499023,141.424911499023,141.424911499023,43.546516418457,43.546516418457,43.546516418457,43.546516418457,43.546516418457,70.1149597167969,70.1149597167969,88.4161148071289,88.4161148071289,113.810104370117,113.810104370117,130.54231262207,130.54231262207,43.6786575317383,43.6786575317383,61.8444137573242,61.8444137573242,90.4449615478516,90.4449615478516,90.4449615478516,108.41674041748,108.41674041748,108.41674041748,108.41674041748,108.41674041748,108.41674041748,135.635795593262,135.635795593262,135.635795593262,135.635795593262,146.26473236084,146.26473236084,146.26473236084,69.0055770874023,69.0055770874023,88.0960464477539,88.0960464477539,88.0960464477539,116.369934082031,116.369934082031,134.737777709961,134.737777709961,134.737777709961,134.737777709961,134.737777709961,134.737777709961,48.9301071166992,48.9301071166992,66.7727508544922,66.7727508544922,66.7727508544922,66.7727508544922,66.7727508544922,93.0778656005859,93.0778656005859,93.0778656005859,110.396301269531,110.396301269531,110.396301269531,138.14973449707,138.14973449707,138.14973449707,138.14973449707,138.14973449707,138.14973449707,128.743682861328,128.743682861328,128.743682861328,70.648796081543,70.648796081543,70.648796081543,70.648796081543,70.648796081543,70.648796081543,89.4731063842773,89.4731063842773,89.4731063842773,89.4731063842773,89.4731063842773,116.963569641113,116.963569641113,135.005836486816,135.005836486816,135.005836486816,47.884521484375,47.884521484375,47.884521484375,64.8747863769531,64.8747863769531,91.9778594970703,91.9778594970703,91.9778594970703,109.559593200684,109.559593200684,109.559593200684,109.559593200684,109.559593200684,132.913459777832,132.913459777832,132.913459777832,146.298027038574,146.298027038574,146.298027038574,61.5313186645508,61.5313186645508,78.0011978149414,78.0011978149414,78.0011978149414,78.0011978149414,105.102912902832,105.102912902832,122.618423461914,122.618423461914,122.618423461914,122.618423461914,146.30046081543,146.30046081543,146.30046081543,51.6948318481445,78.4648895263672,78.4648895263672,96.6321411132812,96.6321411132812,123.862358093262,123.862358093262,141.772727966309,141.772727966309,141.772727966309,141.772727966309,56.223762512207,56.223762512207,73.8686676025391,73.8686676025391,101.291557312012,101.291557312012,101.291557312012,101.291557312012,101.291557312012,119.135223388672,119.135223388672,119.135223388672,146.034286499023,146.034286499023,49.7290725708008,49.7290725708008,77.6773834228516,77.6773834228516,95.1888656616211,95.1888656616211,95.1888656616211,95.1888656616211,120.374855041504,120.374855041504,137.689178466797,137.689178466797,51.1775207519531,51.1775207519531,69.6830139160156,69.6830139160156,97.687629699707,97.687629699707,114.487045288086,114.487045288086,138.627601623535,138.627601623535,146.305107116699,146.305107116699,146.305107116699,68.1657409667969,68.1657409667969,68.1657409667969,86.0070343017578,86.0070343017578,113.37467956543,113.37467956543,130.824592590332,130.824592590332,101.733497619629,101.733497619629,101.733497619629,61.4802322387695,61.4802322387695,61.4802322387695,89.4948654174805,89.4948654174805,89.4948654174805,89.4948654174805,89.4948654174805,107.404319763184,107.404319763184,107.404319763184,135.411483764648,135.411483764648,146.301383972168,146.301383972168,146.301383972168,66.7947387695312,66.7947387695312,66.7947387695312,85.7578659057617,85.7578659057617,85.7578659057617,85.7578659057617,85.7578659057617,113.771499633789,113.771499633789,113.771499633789,132.07332611084,132.07332611084,132.07332611084,132.07332611084,132.07332611084,46.1332397460938,46.1332397460938,46.1332397460938,64.8193893432617,64.8193893432617,64.8193893432617,64.8193893432617,64.8193893432617,64.8193893432617,93.2257995605469,93.2257995605469,112.122207641602,112.122207641602,140.654167175293,140.654167175293,140.654167175293,45.9342422485352,45.9342422485352,74.015266418457,74.015266418457,74.015266418457,74.015266418457,74.015266418457,90.351676940918,90.351676940918,90.351676940918,117.113090515137,117.113090515137,117.113090515137,133.25439453125,133.25439453125,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,146.308967590332,42.7211456298828,42.7211456298828,42.7211456298828,42.7211456298828,42.7211456298828,42.7211456298828,68.4398422241211,68.4398422241211,68.4398422241211,68.4398422241211,68.4398422241211,85.1045532226562,85.1045532226562,111.143707275391,111.143707275391,111.143707275391,125.573432922363,125.573432922363,125.573432922363,125.573432922363,146.304084777832,146.304084777832,146.304084777832,54.7939147949219,54.7939147949219,79.1302261352539,79.1302261352539,79.1302261352539,79.1302261352539,79.1302261352539,79.1302261352539,97.3703536987305,97.3703536987305,97.3703536987305,122.820045471191,122.820045471191,122.820045471191,122.820045471191,139.805015563965,139.805015563965,139.805015563965,50.9881820678711,50.9881820678711,67.720085144043,67.720085144043,67.720085144043,67.720085144043,67.720085144043,91.7287445068359,91.7287445068359,108.781532287598,108.781532287598,108.781532287598,108.781532287598,108.781532287598,108.781532287598,132.465370178223,132.465370178223,132.465370178223,146.30672454834,146.30672454834,146.30672454834,58.1431884765625,58.1431884765625,74.6074676513672,74.6074676513672,99.2628784179688,99.2628784179688,116.392318725586,116.392318725586,142.694931030273,142.694931030273,142.694931030273,142.694931030273,142.694931030273,142.694931030273,46.7299346923828,46.7299346923828,46.7299346923828,73.7566528320312,73.7566528320312,73.7566528320312,91.0724868774414,91.0724868774414,91.0724868774414,115.871238708496,115.871238708496,131.810882568359,131.810882568359,131.810882568359,131.810882568359,121.175758361816,121.175758361816,121.175758361816,60.3742980957031,60.3742980957031,85.7608032226562,85.7608032226562,85.7608032226562,85.7608032226562,85.7608032226562,102.745094299316,102.745094299316,102.745094299316,128.985054016113,128.985054016113,145.248107910156,145.248107910156,145.248107910156,59.4557113647461,59.4557113647461,76.8385848999023,76.8385848999023,104.987342834473,104.987342834473,123.946983337402,123.946983337402,123.946983337402,146.253326416016,146.253326416016,146.253326416016,146.253326416016,146.253326416016,146.253326416016,57.2966003417969,57.2966003417969,83.7409820556641,83.7409820556641,99.4849319458008,99.4849319458008,99.4849319458008,124.87574005127,124.87574005127,139.043182373047,139.043182373047,51.1961975097656,51.1961975097656,67.2674026489258,67.2674026489258,67.2674026489258,92.5917510986328,111.15357208252,111.15357208252,138.315185546875,138.315185546875,138.315185546875,134.733779907227,134.733779907227,134.733779907227,68.4508285522461,68.4508285522461,68.4508285522461,68.4508285522461,85.2483901977539,85.2483901977539,113.263778686523,113.263778686523,113.263778686523,130.849319458008,130.849319458008,130.849319458008,130.849319458008,130.849319458008,130.849319458008,44.4424667358398,44.4424667358398,61.6339340209961,61.6339340209961,61.6339340209961,87.0222930908203,87.0222930908203,104.533660888672,104.533660888672,104.533660888672,104.533660888672,104.533660888672,132.155731201172,132.155731201172,146.263732910156,146.263732910156,146.263732910156,64.9783477783203,64.9783477783203,80.0730667114258,80.0730667114258,80.0730667114258,107.484680175781,107.484680175781,107.484680175781,107.484680175781,107.484680175781,124.409973144531,124.409973144531,124.409973144531,124.409973144531,146.25927734375,146.25927734375,146.25927734375,55.40576171875,55.40576171875,79.6800384521484,79.6800384521484,79.6800384521484,96.6665802001953,96.6665802001953,121.795623779297,121.795623779297,139.835945129395,139.835945129395,139.835945129395,53.56201171875,53.56201171875,69.3694229125977,69.3694229125977,96.7863311767578,96.7863311767578,96.7863311767578,96.7863311767578,96.7863311767578,112.333839416504,112.333839416504,112.333839416504,112.333839416504,140.672103881836,140.672103881836,46.0888671875,46.0888671875,46.0888671875,46.0888671875,72.7179946899414,72.7179946899414,72.7179946899414,90.6310577392578,90.6310577392578,90.6310577392578,90.6310577392578,90.6310577392578,118.379898071289,118.379898071289,118.379898071289,136.481201171875,136.481201171875,50.4849243164062,50.4849243164062,50.4849243164062,67.9390487670898,67.9390487670898,95.7625503540039,95.7625503540039,112.094604492188,112.094604492188,112.094604492188,112.094604492188,112.094604492188,112.094604492188,139.909660339355,139.909660339355,139.909660339355,139.909660339355,139.909660339355,45.7632598876953,45.7632598876953,71.2760009765625,71.2760009765625,71.2760009765625,71.2760009765625,89.2452545166016,89.2452545166016,89.2452545166016,89.2452545166016,89.2452545166016,112.923324584961,112.923324584961,129.584671020508,129.584671020508,146.31209564209,146.31209564209,146.31209564209,146.31209564209,56.0583038330078,56.0583038330078,82.9469909667969,82.9469909667969,98.8894271850586,98.8894271850586,124.33814239502,124.33814239502,124.33814239502,124.33814239502,124.33814239502,124.33814239502,140.802429199219,140.802429199219,140.802429199219,140.802429199219,54.7508773803711,54.7508773803711,54.7508773803711,54.7508773803711,72.134521484375,72.134521484375,72.134521484375,98.1076889038086,98.1076889038086,114.634590148926,114.634590148926,114.634590148926,140.411491394043,140.411491394043,46.027961730957,46.027961730957,69.6398468017578,69.6398468017578,86.757080078125,86.757080078125,114.372482299805,114.372482299805,114.372482299805,114.372482299805,114.372482299805,114.372482299805,131.227821350098,131.227821350098,44.7176284790039,44.7176284790039,61.574592590332,61.574592590332,61.574592590332,61.574592590332,61.574592590332,86.2971725463867,104.462913513184,104.462913513184,132.532814025879,132.532814025879,132.532814025879,132.532814025879,132.532814025879,132.532814025879,146.306282043457,146.306282043457,146.306282043457,62.4630966186523,62.4630966186523,78.1410293579102,78.1410293579102,101.162925720215,101.162925720215,101.162925720215,101.162925720215,101.162925720215,116.507797241211,116.507797241211,116.507797241211,116.507797241211,116.507797241211,116.507797241211,139.591514587402,139.591514587402,45.9449996948242,45.9449996948242,45.9449996948242,69.0890121459961,69.0890121459961,69.0890121459961,87.9115982055664,87.9115982055664,111.392539978027,111.392539978027,129.56046295166,129.56046295166,129.56046295166,43.5766754150391,43.5766754150391,43.5766754150391,43.5766754150391,61.021110534668,61.021110534668,61.021110534668,61.021110534668,61.021110534668,61.021110534668,89.0274887084961,89.0274887084961,106.277435302734,106.277435302734,133.10237121582,133.10237121582,133.10237121582,133.10237121582,133.10237121582,146.282432556152,146.282432556152,146.282432556152,63.4496459960938,63.4496459960938,81.3542251586914,81.3542251586914,81.3542251586914,81.3542251586914,81.3542251586914,81.3542251586914,109.360084533691,109.360084533691,127.199447631836,127.199447631836,111.857978820801,111.857978820801,111.857978820801,60.8900375366211,60.8900375366211,60.8900375366211,60.8900375366211,60.8900375366211,89.4203262329102,89.4203262329102,89.4203262329102,89.4203262329102,89.4203262329102,89.4203262329102,108.5712890625,108.5712890625,108.5712890625,108.5712890625,108.5712890625,134.61124420166,134.61124420166,134.61124420166,134.61124420166,134.61124420166,134.61124420166,146.285949707031,146.285949707031,146.285949707031,66.4650802612305,66.4650802612305,83.6500015258789,83.6500015258789,111.330062866211,111.330062866211,111.330062866211,130.024055480957,130.024055480957,130.024055480957,130.024055480957,130.024055480957,44.2358551025391,44.2358551025391,62.6629028320312,62.6629028320312,89.6786117553711,89.6786117553711,107.840927124023,107.840927124023,107.840927124023,107.840927124023,107.840927124023,134.201431274414,134.201431274414,146.265441894531,146.265441894531,146.265441894531,65.0263366699219,65.0263366699219,81.8135986328125,81.8135986328125,81.8135986328125,81.8135986328125,81.8135986328125,108.106628417969,108.106628417969,108.106628417969,126.400573730469,126.400573730469,146.270355224609,146.270355224609,146.270355224609,58.9254913330078,58.9254913330078,58.9254913330078,58.9254913330078,58.9254913330078,84.8259201049805,84.8259201049805,103.054725646973,103.054725646973,130.988540649414,130.988540649414,130.988540649414,130.988540649414,146.267585754395,146.267585754395,146.267585754395,61.0279159545898,61.0279159545898,61.0279159545898,61.0279159545898,77.8154907226562,77.8154907226562,77.8154907226562,77.8154907226562,77.8154907226562,102.011764526367,102.011764526367,102.011764526367,116.636268615723,116.636268615723,139.259284973145,139.259284973145,139.259284973145,139.259284973145,139.259284973145,139.259284973145,136.261535644531,136.261535644531,136.261535644531,136.261535644531,136.261535644531,136.261535644531,66.7972106933594,66.7972106933594,66.7972106933594,84.8290252685547,84.8290252685547,84.8290252685547,84.8290252685547,84.8290252685547,110.925483703613,110.925483703613,110.925483703613,110.925483703613,110.925483703613,126.596588134766,126.596588134766,126.596588134766,146.266510009766,146.266510009766,146.266510009766,55.3232879638672,55.3232879638672,55.3232879638672,55.3232879638672,82.0108108520508,82.0108108520508,82.0108108520508,99.9110717773438,99.9110717773438,127.647003173828,127.647003173828,127.647003173828,127.647003173828,127.647003173828,127.647003173828,146.268753051758,146.268753051758,146.268753051758,61.0943984985352,61.0943984985352,61.0943984985352,79.1916885375977,79.1916885375977,104.043663024902,104.043663024902,120.108375549316,120.108375549316,144.237075805664,144.237075805664,48.6351699829102,48.6351699829102,48.6351699829102,48.6351699829102,72.1089172363281,72.1089172363281,86.9283676147461,86.9283676147461,86.9283676147461,86.9283676147461,86.9283676147461,110.468292236328,110.468292236328,125.615776062012,125.615776062012,125.615776062012,125.615776062012,125.615776062012,125.615776062012,146.267997741699,146.267997741699,146.267997741699,50.9303207397461,50.9303207397461,50.9303207397461,76.1059417724609,76.1059417724609,76.1059417724609,93.2168045043945,93.2168045043945,119.70336151123,119.70336151123,136.421730041504,136.421730041504,136.421730041504,136.421730041504,46.8006057739258,46.8006057739258,61.1587448120117,61.1587448120117,61.1587448120117,61.1587448120117,61.1587448120117,83.5806732177734,83.5806732177734,83.5806732177734,97.8732986450195,97.8732986450195,97.8732986450195,97.8732986450195,121.474960327148,121.474960327148,121.474960327148,137.53840637207,137.53840637207,137.53840637207,137.53840637207,137.53840637207,137.53840637207,52.7019119262695,52.7019119262695,52.7019119262695,67.782096862793,67.782096862793,67.782096862793,94.4647979736328,94.4647979736328,94.4647979736328,94.4647979736328,94.4647979736328,94.4647979736328,112.62638092041,112.62638092041,112.62638092041,138.260391235352,138.260391235352,146.258827209473,146.258827209473,146.258827209473,67.9788131713867,67.9788131713867,67.9788131713867,67.9788131713867,67.9788131713867,83.9099807739258,83.9099807739258,83.9099807739258,83.9099807739258,83.9099807739258,110.068626403809,110.068626403809,127.836692810059,127.836692810059,127.836692810059,127.836692810059,146.259284973145,146.259284973145,146.259284973145,146.259284973145,57.9473114013672,57.9473114013672,83.7127685546875,83.7127685546875,98.9883499145508,98.9883499145508,98.9883499145508,125.933486938477,125.933486938477,143.044715881348,143.044715881348,143.044715881348,57.2269744873047,57.2269744873047,72.1743392944336,72.1743392944336,95.8420333862305,95.8420333862305,95.8420333862305,111.444869995117,111.444869995117,138.32494354248,138.32494354248,138.32494354248,146.257804870605,146.257804870605,146.257804870605,66.9305572509766,66.9305572509766,66.9305572509766,66.9305572509766,83.254753112793,105.676727294922,105.676727294922,105.676727294922,105.676727294922,105.676727294922,123.967575073242,123.967575073242,146.258506774902,146.258506774902,146.258506774902,48.8831329345703,48.8831329345703,77.2050628662109,77.2050628662109,92.4151916503906,92.4151916503906,113.553512573242,113.553512573242,113.553512573242,113.553512573242,113.553512573242,113.553512573242,113.553512573242,113.553512573242,113.553512573242,113.553512573242],"meminc":[0,0,0,18.888916015625,0,0,25.4539794921875,0,0,0,0,15.4175643920898,0,0,21.8413543701172,0,5.44496917724609,0,0,-84.8105010986328,0,0,14.3016967773438,0,0,0,0,0,23.8810729980469,0,0,0,0,16.6624374389648,0,25.1243743896484,0,0,-97.8783950805664,0,0,0,0,26.5684432983398,0,18.301155090332,0,25.3939895629883,0,16.7322082519531,0,-86.863655090332,0,18.1657562255859,0,28.6005477905273,0,0,17.9717788696289,0,0,0,0,0,27.2190551757812,0,0,0,10.6289367675781,0,0,-77.2591552734375,0,19.0904693603516,0,0,28.2738876342773,0,18.3678436279297,0,0,0,0,0,-85.8076705932617,0,17.842643737793,0,0,0,0,26.3051147460938,0,0,17.3184356689453,0,0,27.7534332275391,0,0,0,0,0,-9.40605163574219,0,0,-58.0948867797852,0,0,0,0,0,18.8243103027344,0,0,0,0,27.4904632568359,0,18.0422668457031,0,0,-87.1213150024414,0,0,16.9902648925781,0,27.1030731201172,0,0,17.5817337036133,0,0,0,0,23.3538665771484,0,0,13.3845672607422,0,0,-84.7667083740234,0,16.4698791503906,0,0,0,27.1017150878906,0,17.515510559082,0,0,0,23.6820373535156,0,0,-94.6056289672852,26.7700576782227,0,18.1672515869141,0,27.2302169799805,0,17.9103698730469,0,0,0,-85.5489654541016,0,17.644905090332,0,27.4228897094727,0,0,0,0,17.8436660766602,0,0,26.8990631103516,0,-96.3052139282227,0,27.9483108520508,0,17.5114822387695,0,0,0,25.1859893798828,0,17.314323425293,0,-86.5116577148438,0,18.5054931640625,0,28.0046157836914,0,16.7994155883789,0,24.1405563354492,0,7.67750549316406,0,0,-78.1393661499023,0,0,17.8412933349609,0,27.3676452636719,0,17.4499130249023,0,-29.0910949707031,0,0,-40.2532653808594,0,0,28.0146331787109,0,0,0,0,17.9094543457031,0,0,28.0071640014648,0,10.8899002075195,0,0,-79.5066452026367,0,0,18.9631271362305,0,0,0,0,28.0136337280273,0,0,18.3018264770508,0,0,0,0,-85.9400863647461,0,0,18.686149597168,0,0,0,0,0,28.4064102172852,0,18.8964080810547,0,28.5319595336914,0,0,-94.7199249267578,0,28.0810241699219,0,0,0,0,16.3364105224609,0,0,26.7614135742188,0,0,16.1413040161133,0,13.054573059082,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.587821960449,0,0,0,0,0,25.7186965942383,0,0,0,0,16.6647109985352,0,26.0391540527344,0,0,14.4297256469727,0,0,0,20.7306518554688,0,0,-91.5101699829102,0,24.336311340332,0,0,0,0,0,18.2401275634766,0,0,25.4496917724609,0,0,0,16.9849700927734,0,0,-88.8168334960938,0,16.7319030761719,0,0,0,0,24.008659362793,0,17.0527877807617,0,0,0,0,0,23.683837890625,0,0,13.8413543701172,0,0,-88.1635360717773,0,16.4642791748047,0,24.6554107666016,0,17.1294403076172,0,26.3026123046875,0,0,0,0,0,-95.9649963378906,0,0,27.0267181396484,0,0,17.3158340454102,0,0,24.7987518310547,0,15.9396438598633,0,0,0,-10.635124206543,0,0,-60.8014602661133,0,25.3865051269531,0,0,0,0,16.9842910766602,0,0,26.2399597167969,0,16.263053894043,0,0,-85.7923965454102,0,17.3828735351562,0,28.1487579345703,0,18.9596405029297,0,0,22.3063430786133,0,0,0,0,0,-88.9567260742188,0,26.4443817138672,0,15.7439498901367,0,0,25.3908081054688,0,14.1674423217773,0,-87.8469848632812,0,16.0712051391602,0,0,25.324348449707,18.5618209838867,0,27.1616134643555,0,0,-3.58140563964844,0,0,-66.2829513549805,0,0,0,16.7975616455078,0,28.0153884887695,0,0,17.5855407714844,0,0,0,0,0,-86.406852722168,0,17.1914672851562,0,0,25.3883590698242,0,17.5113677978516,0,0,0,0,27.6220703125,0,14.1080017089844,0,0,-81.2853851318359,0,15.0947189331055,0,0,27.4116134643555,0,0,0,0,16.92529296875,0,0,0,21.8493041992188,0,0,-90.853515625,0,24.2742767333984,0,0,16.9865417480469,0,25.1290435791016,0,18.0403213500977,0,0,-86.2739334106445,0,15.8074111938477,0,27.4169082641602,0,0,0,0,15.5475082397461,0,0,0,28.338264465332,0,-94.5832366943359,0,0,0,26.6291275024414,0,0,17.9130630493164,0,0,0,0,27.7488403320312,0,0,18.1013031005859,0,-85.9962768554688,0,0,17.4541244506836,0,27.8235015869141,0,16.3320541381836,0,0,0,0,0,27.815055847168,0,0,0,0,-94.1464004516602,0,25.5127410888672,0,0,0,17.9692535400391,0,0,0,0,23.6780700683594,0,16.6613464355469,0,16.727424621582,0,0,0,-90.253791809082,0,26.8886871337891,0,15.9424362182617,0,25.4487152099609,0,0,0,0,0,16.4642868041992,0,0,0,-86.0515518188477,0,0,0,17.3836441040039,0,0,25.9731674194336,0,16.5269012451172,0,0,25.7769012451172,0,-94.3835296630859,0,23.6118850708008,0,17.1172332763672,0,27.6154022216797,0,0,0,0,0,16.855339050293,0,-86.5101928710938,0,16.8569641113281,0,0,0,0,24.7225799560547,18.1657409667969,0,28.0699005126953,0,0,0,0,0,13.7734680175781,0,0,-83.8431854248047,0,15.6779327392578,0,23.0218963623047,0,0,0,0,15.3448715209961,0,0,0,0,0,23.0837173461914,0,-93.6465148925781,0,0,23.1440124511719,0,0,18.8225860595703,0,23.4809417724609,0,18.1679229736328,0,0,-85.9837875366211,0,0,0,17.4444351196289,0,0,0,0,0,28.0063781738281,0,17.2499465942383,0,26.8249359130859,0,0,0,0,13.180061340332,0,0,-82.8327865600586,0,17.9045791625977,0,0,0,0,0,28.005859375,0,17.8393630981445,0,-15.3414688110352,0,0,-50.9679412841797,0,0,0,0,28.5302886962891,0,0,0,0,0,19.1509628295898,0,0,0,0,26.0399551391602,0,0,0,0,0,11.6747055053711,0,0,-79.8208694458008,0,17.1849212646484,0,27.680061340332,0,0,18.6939926147461,0,0,0,0,-85.788200378418,0,18.4270477294922,0,27.0157089233398,0,18.1623153686523,0,0,0,0,26.3605041503906,0,12.0640106201172,0,0,-81.2391052246094,0,16.7872619628906,0,0,0,0,26.2930297851562,0,0,18.2939453125,0,19.8697814941406,0,0,-87.3448638916016,0,0,0,0,25.9004287719727,0,18.2288055419922,0,27.9338150024414,0,0,0,15.2790451049805,0,0,-85.2396697998047,0,0,0,16.7875747680664,0,0,0,0,24.1962738037109,0,0,14.6245040893555,0,22.6230163574219,0,0,0,0,0,-2.99774932861328,0,0,0,0,0,-69.4643249511719,0,0,18.0318145751953,0,0,0,0,26.0964584350586,0,0,0,0,15.6711044311523,0,0,19.669921875,0,0,-90.9432220458984,0,0,0,26.6875228881836,0,0,17.900260925293,0,27.7359313964844,0,0,0,0,0,18.6217498779297,0,0,-85.1743545532227,0,0,18.0972900390625,0,24.8519744873047,0,16.0647125244141,0,24.1287002563477,0,-95.6019058227539,0,0,0,23.473747253418,0,14.819450378418,0,0,0,0,23.539924621582,0,15.1474838256836,0,0,0,0,0,20.6522216796875,0,0,-95.3376770019531,0,0,25.1756210327148,0,0,17.1108627319336,0,26.4865570068359,0,16.7183685302734,0,0,0,-89.6211242675781,0,14.3581390380859,0,0,0,0,22.4219284057617,0,0,14.2926254272461,0,0,0,23.6016616821289,0,0,16.0634460449219,0,0,0,0,0,-84.8364944458008,0,0,15.0801849365234,0,0,26.6827011108398,0,0,0,0,0,18.1615829467773,0,0,25.6340103149414,0,7.99843597412109,0,0,-78.2800140380859,0,0,0,0,15.9311676025391,0,0,0,0,26.1586456298828,0,17.76806640625,0,0,0,18.4225921630859,0,0,0,-88.3119735717773,0,25.7654571533203,0,15.2755813598633,0,0,26.9451370239258,0,17.1112289428711,0,0,-85.817741394043,0,14.9473648071289,0,23.6676940917969,0,0,15.6028366088867,0,26.8800735473633,0,0,7.932861328125,0,0,-79.3272476196289,0,0,0,16.3241958618164,22.4219741821289,0,0,0,0,18.2908477783203,0,22.2909317016602,0,0,-97.375373840332,0,28.3219299316406,0,15.2101287841797,0,21.1383209228516,0,0,0,0,0,0,0,0,0],"filename":[null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpArLijd/file36af6e6316ab.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    841.587    862.641   1245.0426    900.1400
#>    compute_pi0(m * 10)   8444.256   8575.472   8997.0908   8850.1200
#>   compute_pi0(m * 100)  83927.698  85626.620  88500.4717  88588.3570
#>         compute_pi1(m)    178.473    201.249    617.4999    283.6005
#>    compute_pi1(m * 10)   1140.011   1241.986   8269.3595   1318.6985
#>   compute_pi1(m * 100)  11004.962  11863.721  17205.8820  18546.3465
#>  compute_pi1(m * 1000) 173560.107 294351.056 305097.2999 315144.2120
#>           uq        max neval
#>     918.5750   7979.703    20
#>    9312.1350   9916.455    20
#>   90925.3910  93786.954    20
#>     301.7125   7310.923    20
#>    1520.4870 117015.703    20
#>   21330.9245  25061.840    20
#>  337482.1265 466322.295    20
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
#>   memory_copy1(n) 6783.23254 5292.67704 591.710339 4467.37470 4161.88187
#>   memory_copy2(n)  108.42060   88.44116  10.908680   74.10534   68.15606
#>  pre_allocate1(n)   24.82392   19.28665   3.546839   16.24964   14.87889
#>  pre_allocate2(n)  222.03667  172.95408  21.633943  149.78412  153.59398
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  82.039853    10
#>   2.747461    10
#>   1.964669    10
#>   4.529005    10
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
#>  f1(df) 239.7847 247.5427 83.34793 249.1666 64.43385 31.97402     5
#>  f2(df)   1.0000   1.0000  1.00000   1.0000  1.00000  1.00000     5
```

#### Paralelizar {-}

Paralelizar usa varios _cores_  para trabajar de manera simultánea en varias 
secciones de un problema, no reduce el tiempo computacional pero incrementa el 
tiempo del usuario pues aprovecha los recursos. Como referencia está 
[Parallel Computing for Data Science] de Norm Matloff.
