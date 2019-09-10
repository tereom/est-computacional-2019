
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
#>    id           a        b        c        d
#> 1   1  2.01517303 2.133459 3.242543 4.457143
#> 2   2  1.44233071 2.541103 2.072219 6.267019
#> 3   3  0.14804181 2.463590 4.229705 4.467003
#> 4   4 -0.41602629 1.863292 3.588948 5.524970
#> 5   5 -1.06813843 1.322386 4.566072 4.108160
#> 6   6  1.76277467 1.729673 3.480623 5.782934
#> 7   7  0.06314249 2.531000 2.182135 2.304593
#> 8   8  1.95222984 1.039890 3.104609 5.085241
#> 9   9  1.15278545 3.120072 3.018056 4.006716
#> 10 10 -1.33420894 2.338069 4.494978 2.181994
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.5718104
mean(df$b)
#> [1] 2.108253
mean(df$c)
#> [1] 3.397989
mean(df$d)
#> [1] 4.418578
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.5718104 2.1082535 3.3979888 4.4185776
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
#> [1] 0.5718104 2.1082535 3.3979888 4.4185776
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
#> [1] 5.5000000 0.5718104 2.1082535 3.3979888 4.4185776
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
#> [1] 5.5000000 0.6504136 2.2357643 3.3615828 4.4620733
col_describe(df, mean)
#> [1] 5.5000000 0.5718104 2.1082535 3.3979888 4.4185776
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
#> 5.5000000 0.5718104 2.1082535 3.3979888 4.4185776
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
#>   3.806   0.128   3.935
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.024   0.000   0.613
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
#>  12.799   0.763   9.828
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
#>   0.101   0.008   0.109
plyr_st
#>    user  system elapsed 
#>   3.990   0.012   4.002
est_l_st
#>    user  system elapsed 
#>  62.608   0.923  63.535
est_r_st
#>    user  system elapsed 
#>   0.383   0.000   0.382
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

<!--html_preserve--><div id="htmlwidget-0a83fa8d25ca40b29dc4" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-0a83fa8d25ca40b29dc4">{"x":{"message":{"prof":{"time":[1,1,2,2,2,2,2,3,3,3,3,4,4,5,5,5,6,6,6,6,6,7,7,8,8,8,8,9,9,10,10,10,11,11,12,12,12,13,13,14,14,14,15,15,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,21,21,21,22,22,22,22,22,22,23,23,23,24,24,25,25,26,26,27,27,27,28,28,29,29,30,30,30,30,30,31,31,32,32,32,32,32,32,33,33,34,34,34,35,35,35,35,35,36,36,37,37,37,38,38,38,39,39,40,40,40,41,41,41,42,42,43,43,43,43,43,44,44,45,45,45,46,46,46,47,47,47,47,47,48,48,48,49,49,49,50,50,50,51,51,51,52,52,53,53,53,53,53,54,54,54,55,55,56,56,56,56,56,56,57,57,58,58,59,59,59,60,60,61,61,61,62,62,62,62,62,63,63,63,64,64,65,65,65,65,65,66,66,67,67,67,68,68,68,69,69,69,69,69,70,70,71,71,72,72,72,73,73,73,74,74,75,75,76,76,76,77,77,77,77,77,77,78,78,78,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,93,93,94,94,94,94,94,94,95,95,96,96,97,97,97,97,97,98,98,98,98,98,98,99,99,99,100,100,100,100,100,101,101,102,102,103,103,104,104,104,105,105,106,106,106,107,107,108,108,109,109,109,110,110,111,111,111,111,111,112,112,113,113,113,113,113,114,114,114,114,114,115,115,115,116,116,117,117,117,117,117,118,118,118,119,119,120,120,121,121,122,122,123,123,123,123,123,123,124,124,124,125,125,125,125,125,125,126,126,126,127,127,128,128,129,129,130,130,131,131,131,132,132,132,132,132,133,133,134,134,135,135,135,136,136,136,137,137,138,138,139,139,139,140,140,141,141,142,142,142,143,143,144,144,144,145,145,146,146,147,147,147,148,148,148,148,148,149,149,150,150,150,151,151,152,152,152,153,153,154,154,155,155,156,156,157,157,157,158,158,159,159,160,160,161,161,161,162,162,163,163,164,164,165,165,165,165,166,166,166,166,167,167,168,168,169,169,170,170,170,170,170,170,171,171,172,172,173,173,173,173,173,173,174,174,175,175,176,176,177,177,177,177,177,177,178,178,179,179,179,180,180,180,180,180,180,181,181,181,182,182,183,183,183,184,184,184,184,184,184,185,185,185,185,185,185,186,186,187,187,188,188,188,189,189,190,190,191,191,192,192,193,194,194,195,195,196,196,197,197,198,198,198,199,199,200,200,200,200,201,201,201,201,202,202,203,203,204,204,205,205,206,206,206,206,206,207,207,208,208,209,209,210,210,210,211,211,211,212,212,212,213,213,213,214,214,215,215,216,216,216,217,217,218,218,218,218,218,219,219,220,220,220,221,221,221,221,222,222,223,223,223,224,224,225,225,226,226,226,226,227,227,227,227,227,227,228,228,229,229,229,230,230,230,230,230,231,231,232,232,232,233,233,233,233,233,234,234,234,235,235,235,236,236,236,237,237,238,238,239,239,240,240,240,240,240,241,241,241,241,241,241,242,242,242,242,242,243,243,243,243,243,244,244,245,245,245,246,246,246,247,247,247,248,248,249,249,249,250,250,250,250,250,250,251,251,252,252,252,252,252,253,253,253,254,254,254,255,255,255,256,256,257,257,258,258,259,259,260,260,261,261,261,262,262,262,262,263,263,263,264,264,265,265,266,266,266,266,266,267,267,267,267,267,268,268,268,268,268,268,269,269,269,269,269,270,270,271,271,272,272,273,273,274,274,275,275,275,276,276,276,277,277,278,278,278,278,278],"depth":[2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,4,3,2,1,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1],"label":["[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,null,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1],"linenum":[9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,null,11,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,10,10,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,11,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,11,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,10,10,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,13],"memalloc":[64.994743347168,64.994743347168,86.244758605957,86.244758605957,86.244758605957,86.244758605957,86.244758605957,113.012496948242,113.012496948242,113.012496948242,113.012496948242,130.788665771484,130.788665771484,92.4785079956055,92.4785079956055,92.4785079956055,63.293586730957,63.293586730957,63.293586730957,63.293586730957,63.293586730957,95.3740310668945,95.3740310668945,115.319496154785,115.319496154785,115.319496154785,115.319496154785,145.951477050781,145.951477050781,49.5806503295898,49.5806503295898,49.5806503295898,81.5961303710938,81.5961303710938,102.197250366211,102.197250366211,102.197250366211,132.054046630859,132.054046630859,146.287307739258,146.287307739258,146.287307739258,67.4885177612305,67.4885177612305,88.6769256591797,88.6769256591797,119.306106567383,119.306106567383,119.306106567383,119.306106567383,138.786972045898,138.786972045898,138.786972045898,138.786972045898,53.0667724609375,53.0667724609375,53.0667724609375,53.0667724609375,72.4862442016602,72.4862442016602,104.759346008301,104.759346008301,104.759346008301,126.275909423828,126.275909423828,126.275909423828,126.275909423828,126.275909423828,126.275909423828,146.281959533691,146.281959533691,146.281959533691,62.5771179199219,62.5771179199219,94.3929901123047,94.3929901123047,115.645568847656,115.645568847656,146.286811828613,146.286811828613,146.286811828613,51.7548370361328,51.7548370361328,83.5685729980469,83.5685729980469,104.109336853027,104.109336853027,104.109336853027,104.109336853027,104.109336853027,134.483139038086,134.483139038086,146.296379089355,146.296379089355,146.296379089355,146.296379089355,146.296379089355,146.296379089355,69.4076690673828,69.4076690673828,90.405517578125,90.405517578125,90.405517578125,120.582000732422,120.582000732422,120.582000732422,120.582000732422,120.582000732422,140.460876464844,140.460876464844,54.9712371826172,54.9712371826172,54.9712371826172,75.7707214355469,75.7707214355469,75.7707214355469,106.875801086426,106.875801086426,126.164527893066,126.164527893066,126.164527893066,146.302696228027,146.302696228027,146.302696228027,61.3464965820312,61.3464965820312,93.614372253418,93.614372253418,93.614372253418,93.614372253418,93.614372253418,114.877082824707,114.877082824707,146.30012512207,146.30012512207,146.30012512207,50.6483612060547,50.6483612060547,50.6483612060547,82.598762512207,82.598762512207,82.598762512207,82.598762512207,82.598762512207,102.933662414551,102.933662414551,102.933662414551,133.243293762207,133.243293762207,133.243293762207,146.299346923828,146.299346923828,146.299346923828,68.4965438842773,68.4965438842773,68.4965438842773,89.8126220703125,89.8126220703125,120.639289855957,120.639289855957,120.639289855957,120.639289855957,120.639289855957,140.907508850098,140.907508850098,140.907508850098,55.4442977905273,55.4442977905273,76.1132431030273,76.1132431030273,76.1132431030273,76.1132431030273,76.1132431030273,76.1132431030273,107.469924926758,107.469924926758,127.412658691406,127.412658691406,146.307342529297,146.307342529297,146.307342529297,62.8516006469727,62.8516006469727,94.9346389770508,94.9346389770508,94.9346389770508,114.950576782227,114.950576782227,114.950576782227,114.950576782227,114.950576782227,144.733711242676,144.733711242676,144.733711242676,49.3436584472656,49.3436584472656,81.0352096557617,81.0352096557617,81.0352096557617,81.0352096557617,81.0352096557617,102.619827270508,102.619827270508,134.561225891113,134.561225891113,134.561225891113,146.303619384766,146.303619384766,146.303619384766,70.4703674316406,70.4703674316406,70.4703674316406,70.4703674316406,70.4703674316406,89.8956756591797,89.8956756591797,120.464584350586,120.464584350586,140.538139343262,140.538139343262,140.538139343262,55.8391342163086,55.8391342163086,55.8391342163086,77.2859420776367,77.2859420776367,108.057479858398,108.057479858398,129.568778991699,129.568778991699,129.568778991699,44.8223571777344,44.8223571777344,44.8223571777344,44.8223571777344,44.8223571777344,44.8223571777344,65.1636962890625,65.1636962890625,65.1636962890625,96.0607681274414,96.0607681274414,117.115325927734,117.115325927734,117.115325927734,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,146.31120300293,42.7233810424805,42.7233810424805,42.7233810424805,54.0722808837891,54.0722808837891,85.4345474243164,85.4345474243164,106.751182556152,106.751182556152,106.751182556152,106.751182556152,106.751182556152,106.751182556152,138.891952514648,138.891952514648,43.907096862793,43.907096862793,74.081787109375,74.081787109375,74.081787109375,74.081787109375,74.081787109375,95.2058181762695,95.2058181762695,95.2058181762695,95.2058181762695,95.2058181762695,95.2058181762695,125.708938598633,125.708938598633,125.708938598633,145.05558013916,145.05558013916,145.05558013916,145.05558013916,145.05558013916,61.4243545532227,61.4243545532227,82.2835388183594,82.2835388183594,113.704956054688,113.704956054688,134.041046142578,134.041046142578,134.041046142578,49.4199295043945,49.4199295043945,70.0201797485352,70.0201797485352,70.0201797485352,102.153511047363,102.153511047363,122.888160705566,122.888160705566,146.304817199707,146.304817199707,146.304817199707,60.1161575317383,60.1161575317383,91.4026870727539,91.4026870727539,91.4026870727539,91.4026870727539,91.4026870727539,112.20068359375,112.20068359375,142.308006286621,142.308006286621,142.308006286621,142.308006286621,142.308006286621,47.7833480834961,47.7833480834961,47.7833480834961,47.7833480834961,47.7833480834961,79.1403198242188,79.1403198242188,79.1403198242188,100.583564758301,100.583564758301,132.659469604492,132.659469604492,132.659469604492,132.659469604492,132.659469604492,146.299354553223,146.299354553223,146.299354553223,70.6087951660156,70.6087951660156,89.8971176147461,89.8971176147461,122.309097290039,122.309097290039,143.431907653809,143.431907653809,60.0544281005859,60.0544281005859,60.0544281005859,60.0544281005859,60.0544281005859,60.0544281005859,80.7242965698242,80.7242965698242,80.7242965698242,112.740715026855,112.740715026855,112.740715026855,112.740715026855,112.740715026855,112.740715026855,134.256874084473,134.256874084473,134.256874084473,51.1984329223633,51.1984329223633,72.1253433227539,72.1253433227539,104.269660949707,104.269660949707,125.260719299316,125.260719299316,146.255668640137,146.255668640137,146.255668640137,62.6806335449219,62.6806335449219,62.6806335449219,62.6806335449219,62.6806335449219,94.5044326782227,94.5044326782227,115.823959350586,115.823959350586,146.269165039062,146.269165039062,146.269165039062,53.7587966918945,53.7587966918945,53.7587966918945,85.3855514526367,85.3855514526367,106.504943847656,106.504943847656,138.785850524902,138.785850524902,138.785850524902,44.9059753417969,44.9059753417969,76.1374435424805,76.1374435424805,97.3899841308594,97.3899841308594,97.3899841308594,129.85888671875,129.85888671875,146.261512756348,146.261512756348,146.261512756348,67.2160339355469,67.2160339355469,88.468620300293,88.468620300293,120.617858886719,120.617858886719,120.617858886719,141.806999206543,141.806999206543,141.806999206543,141.806999206543,141.806999206543,58.2875137329102,58.2875137329102,79.2782287597656,79.2782287597656,79.2782287597656,111.418113708496,111.418113708496,132.867660522461,132.867660522461,132.867660522461,49.6971130371094,49.6971130371094,71.0803909301758,71.0803909301758,102.570030212402,102.570030212402,122.90650177002,122.90650177002,146.25846862793,146.25846862793,146.25846862793,59.6722564697266,59.6722564697266,91.5669708251953,91.5669708251953,112.621238708496,112.621238708496,144.765235900879,144.765235900879,144.765235900879,51.0135498046875,51.0135498046875,82.6234359741211,82.6234359741211,104.004486083984,104.004486083984,134.835258483887,134.835258483887,134.835258483887,134.835258483887,146.314331054688,146.314331054688,146.314331054688,146.314331054688,71.9975280761719,71.9975280761719,93.0513381958008,93.0513381958008,123.749656677246,123.749656677246,142.182189941406,142.182189941406,142.182189941406,142.182189941406,142.182189941406,142.182189941406,58.7552185058594,58.7552185058594,79.6787338256836,79.6787338256836,111.488876342773,111.488876342773,111.488876342773,111.488876342773,111.488876342773,111.488876342773,132.871772766113,132.871772766113,49.9001007080078,49.9001007080078,70.626350402832,70.626350402832,102.897483825684,102.897483825684,102.897483825684,102.897483825684,102.897483825684,102.897483825684,124.213233947754,124.213233947754,146.315536499023,146.315536499023,146.315536499023,62.8880233764648,62.8880233764648,62.8880233764648,62.8880233764648,62.8880233764648,62.8880233764648,94.7612915039062,94.7612915039062,94.7612915039062,116.271217346191,116.271217346191,146.308464050293,146.308464050293,146.308464050293,52.1027069091797,52.1027069091797,52.1027069091797,52.1027069091797,52.1027069091797,52.1027069091797,84.1793060302734,84.1793060302734,84.1793060302734,84.1793060302734,84.1793060302734,84.1793060302734,105.427635192871,105.427635192871,137.49535369873,137.49535369873,118.13988494873,118.13988494873,118.13988494873,72.3052520751953,72.3052520751953,92.6363296508789,92.6363296508789,124.314453125,124.314453125,145.108345031738,145.108345031738,60.7605285644531,81.6835784912109,81.6835784912109,113.297340393066,113.297340393066,133.89168548584,133.89168548584,48.367546081543,48.367546081543,69.2235641479492,69.2235641479492,69.2235641479492,101.098159790039,101.098159790039,122.675941467285,122.675941467285,122.675941467285,122.675941467285,146.287605285645,146.287605285645,146.287605285645,146.287605285645,59.6460723876953,59.6460723876953,91.7172698974609,91.7172698974609,112.967559814453,112.967559814453,144.97607421875,144.97607421875,50.2060394287109,50.2060394287109,50.2060394287109,50.2060394287109,50.2060394287109,82.2752380371094,82.2752380371094,103.526077270508,103.526077270508,135.994338989258,135.994338989258,146.289207458496,146.289207458496,146.289207458496,73.352897644043,73.352897644043,73.352897644043,94.729850769043,94.729850769043,94.729850769043,124.630699157715,124.630699157715,124.630699157715,145.087875366211,145.087875366211,61.6844635009766,61.6844635009766,82.9306106567383,82.9306106567383,82.9306106567383,115.452690124512,115.452690124512,136.698867797852,136.698867797852,136.698867797852,136.698867797852,136.698867797852,53.2882995605469,53.2882995605469,72.7635879516602,72.7635879516602,72.7635879516602,104.892776489258,104.892776489258,104.892776489258,104.892776489258,126.466255187988,126.466255187988,43.7162933349609,43.7162933349609,43.7162933349609,64.1772537231445,64.1772537231445,96.4392776489258,96.4392776489258,116.572982788086,116.572982788086,116.572982788086,116.572982788086,146.278015136719,146.278015136719,146.278015136719,146.278015136719,146.278015136719,146.278015136719,53.0938949584961,53.0938949584961,85.6838455200195,85.6838455200195,85.6838455200195,106.468696594238,106.468696594238,106.468696594238,106.468696594238,106.468696594238,136.957847595215,136.957847595215,68.7090606689453,68.7090606689453,68.7090606689453,74.4068832397461,74.4068832397461,74.4068832397461,74.4068832397461,74.4068832397461,96.1759719848633,96.1759719848633,96.1759719848633,127.845947265625,127.845947265625,127.845947265625,146.270973205566,146.270973205566,146.270973205566,65.6864852905273,65.6864852905273,86.9967269897461,86.9967269897461,119.520721435547,119.520721435547,140.895881652832,140.895881652832,140.895881652832,140.895881652832,140.895881652832,57.1612014770508,57.1612014770508,57.1612014770508,57.1612014770508,57.1612014770508,57.1612014770508,78.3409042358398,78.3409042358398,78.3409042358398,78.3409042358398,78.3409042358398,109.290321350098,109.290321350098,109.290321350098,109.290321350098,109.290321350098,130.86287689209,130.86287689209,47.78564453125,47.78564453125,47.78564453125,69.0929794311523,69.0929794311523,69.0929794311523,101.283393859863,101.283393859863,101.283393859863,122.983558654785,122.983558654785,146.258155822754,146.258155822754,146.258155822754,60.3089141845703,60.3089141845703,60.3089141845703,60.3089141845703,60.3089141845703,60.3089141845703,92.5647583007812,92.5647583007812,114.003303527832,114.003303527832,114.003303527832,114.003303527832,114.003303527832,146.259902954102,146.259902954102,146.259902954102,52.5075302124023,52.5075302124023,52.5075302124023,85.09228515625,85.09228515625,85.09228515625,106.268630981445,106.268630981445,138.393684387207,138.393684387207,44.7065353393555,44.7065353393555,76.7002639770508,76.7002639770508,97.9421234130859,97.9421234130859,130.592491149902,130.592491149902,130.592491149902,146.261505126953,146.261505126953,146.261505126953,146.261505126953,69.0951995849609,69.0951995849609,69.0951995849609,90.2708969116211,90.2708969116211,122.329551696777,122.329551696777,143.243644714355,143.243644714355,143.243644714355,143.243644714355,143.243644714355,59.9829330444336,59.9829330444336,59.9829330444336,59.9829330444336,59.9829330444336,81.4862670898438,81.4862670898438,81.4862670898438,81.4862670898438,81.4862670898438,81.4862670898438,113.742073059082,113.742073059082,113.742073059082,113.742073059082,113.742073059082,135.311378479004,135.311378479004,51.5915069580078,51.5915069580078,72.7021713256836,72.7021713256836,104.95743560791,104.95743560791,126.461311340332,126.461311340332,68.62890625,68.62890625,68.62890625,63.1779022216797,63.1779022216797,63.1779022216797,95.4987716674805,95.4987716674805,113.55574798584,113.55574798584,113.55574798584,113.55574798584,113.55574798584],"meminc":[0,0,21.2500152587891,0,0,0,0,26.7677383422852,0,0,0,17.7761688232422,0,-38.3101577758789,0,0,-29.1849212646484,0,0,0,0,32.0804443359375,0,19.9454650878906,0,0,0,30.6319808959961,0,-96.3708267211914,0,0,32.0154800415039,0,20.6011199951172,0,0,29.8567962646484,0,14.2332611083984,0,0,-78.7987899780273,0,21.1884078979492,0,30.6291809082031,0,0,0,19.4808654785156,0,0,0,-85.7201995849609,0,0,0,19.4194717407227,0,32.2731018066406,0,0,21.5165634155273,0,0,0,0,0,20.0060501098633,0,0,-83.7048416137695,0,31.8158721923828,0,21.2525787353516,0,30.641242980957,0,0,-94.5319747924805,0,31.8137359619141,0,20.5407638549805,0,0,0,0,30.3738021850586,0,11.8132400512695,0,0,0,0,0,-76.8887100219727,0,20.9978485107422,0,0,30.1764831542969,0,0,0,0,19.8788757324219,0,-85.4896392822266,0,0,20.7994842529297,0,0,31.1050796508789,0,19.2887268066406,0,0,20.1381683349609,0,0,-84.9561996459961,0,32.2678756713867,0,0,0,0,21.2627105712891,0,31.4230422973633,0,0,-95.6517639160156,0,0,31.9504013061523,0,0,0,0,20.3348999023438,0,0,30.3096313476562,0,0,13.0560531616211,0,0,-77.8028030395508,0,0,21.3160781860352,0,30.8266677856445,0,0,0,0,20.2682189941406,0,0,-85.4632110595703,0,20.6689453125,0,0,0,0,0,31.3566818237305,0,19.9427337646484,0,18.8946838378906,0,0,-83.4557418823242,0,32.0830383300781,0,0,20.0159378051758,0,0,0,0,29.7831344604492,0,0,-95.3900527954102,0,31.6915512084961,0,0,0,0,21.5846176147461,0,31.9413986206055,0,0,11.7423934936523,0,0,-75.833251953125,0,0,0,0,19.4253082275391,0,30.5689086914062,0,20.0735549926758,0,0,-84.6990051269531,0,0,21.4468078613281,0,30.7715377807617,0,21.5112991333008,0,0,-84.7464218139648,0,0,0,0,0,20.3413391113281,0,0,30.8970718383789,0,21.054557800293,0,0,29.1958770751953,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.587821960449,0,0,11.3488998413086,0,31.3622665405273,0,21.3166351318359,0,0,0,0,0,32.1407699584961,0,-94.9848556518555,0,30.174690246582,0,0,0,0,21.1240310668945,0,0,0,0,0,30.5031204223633,0,0,19.3466415405273,0,0,0,0,-83.6312255859375,0,20.8591842651367,0,31.4214172363281,0,20.3360900878906,0,0,-84.6211166381836,0,20.6002502441406,0,0,32.1333312988281,0,20.7346496582031,0,23.4166564941406,0,0,-86.1886596679688,0,31.2865295410156,0,0,0,0,20.7979965209961,0,30.1073226928711,0,0,0,0,-94.524658203125,0,0,0,0,31.3569717407227,0,0,21.443244934082,0,32.0759048461914,0,0,0,0,13.6398849487305,0,0,-75.690559387207,0,19.2883224487305,0,32.411979675293,0,21.1228103637695,0,-83.3774795532227,0,0,0,0,0,20.6698684692383,0,0,32.0164184570312,0,0,0,0,0,21.5161590576172,0,0,-83.0584411621094,0,20.9269104003906,0,32.1443176269531,0,20.9910583496094,0,20.9949493408203,0,0,-83.5750350952148,0,0,0,0,31.8237991333008,0,21.3195266723633,0,30.4452056884766,0,0,-92.510368347168,0,0,31.6267547607422,0,21.1193923950195,0,32.2809066772461,0,0,-93.8798751831055,0,31.2314682006836,0,21.2525405883789,0,0,32.4689025878906,0,16.4026260375977,0,0,-79.0454788208008,0,21.2525863647461,0,32.1492385864258,0,0,21.1891403198242,0,0,0,0,-83.5194854736328,0,20.9907150268555,0,0,32.1398849487305,0,21.4495468139648,0,0,-83.1705474853516,0,21.3832778930664,0,31.4896392822266,0,20.3364715576172,0,23.3519668579102,0,0,-86.5862121582031,0,31.8947143554688,0,21.0542678833008,0,32.1439971923828,0,0,-93.7516860961914,0,31.6098861694336,0,21.3810501098633,0,30.8307723999023,0,0,0,11.4790725708008,0,0,0,-74.3168029785156,0,21.0538101196289,0,30.6983184814453,0,18.4325332641602,0,0,0,0,0,-83.4269714355469,0,20.9235153198242,0,31.8101425170898,0,0,0,0,0,21.3828964233398,0,-82.9716720581055,0,20.7262496948242,0,32.2711334228516,0,0,0,0,0,21.3157501220703,0,22.1023025512695,0,0,-83.4275131225586,0,0,0,0,0,31.8732681274414,0,0,21.5099258422852,0,30.0372467041016,0,0,-94.2057571411133,0,0,0,0,0,32.0765991210938,0,0,0,0,0,21.2483291625977,0,32.0677185058594,0,-19.35546875,0,0,-45.8346328735352,0,20.3310775756836,0,31.6781234741211,0,20.7938919067383,0,-84.3478164672852,20.9230499267578,0,31.6137619018555,0,20.5943450927734,0,-85.5241394042969,0,20.8560180664062,0,0,31.8745956420898,0,21.5777816772461,0,0,0,23.6116638183594,0,0,0,-86.6415328979492,0,32.0711975097656,0,21.2502899169922,0,32.0085144042969,0,-94.7700347900391,0,0,0,0,32.0691986083984,0,21.2508392333984,0,32.46826171875,0,10.2948684692383,0,0,-72.9363098144531,0,0,21.376953125,0,0,29.9008483886719,0,0,20.4571762084961,0,-83.4034118652344,0,21.2461471557617,0,0,32.5220794677734,0,21.2461776733398,0,0,0,0,-83.4105682373047,0,19.4752883911133,0,0,32.1291885375977,0,0,0,21.5734786987305,0,-82.7499618530273,0,0,20.4609603881836,0,32.2620239257812,0,20.1337051391602,0,0,0,29.7050323486328,0,0,0,0,0,-93.1841201782227,0,32.5899505615234,0,0,20.7848510742188,0,0,0,0,30.4891510009766,0,-68.2487869262695,0,0,5.69782257080078,0,0,0,0,21.7690887451172,0,0,31.6699752807617,0,0,18.4250259399414,0,0,-80.5844879150391,0,21.3102416992188,0,32.5239944458008,0,21.3751602172852,0,0,0,0,-83.7346801757812,0,0,0,0,0,21.1797027587891,0,0,0,0,30.9494171142578,0,0,0,0,21.5725555419922,0,-83.0772323608398,0,0,21.3073348999023,0,0,32.1904144287109,0,0,21.7001647949219,0,23.2745971679688,0,0,-85.9492416381836,0,0,0,0,0,32.2558441162109,0,21.4385452270508,0,0,0,0,32.2565994262695,0,0,-93.7523727416992,0,0,32.5847549438477,0,0,21.1763458251953,0,32.1250534057617,0,-93.6871490478516,0,31.9937286376953,0,21.2418594360352,0,32.6503677368164,0,0,15.6690139770508,0,0,0,-77.1663055419922,0,0,21.1756973266602,0,32.0586547851562,0,20.9140930175781,0,0,0,0,-83.2607116699219,0,0,0,0,21.5033340454102,0,0,0,0,0,32.2558059692383,0,0,0,0,21.5693054199219,0,-83.7198715209961,0,21.1106643676758,0,32.2552642822266,0,21.5038757324219,0,-57.832405090332,0,0,-5.45100402832031,0,0,32.3208694458008,0,18.0569763183594,0,0,0,0],"filename":["<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmp3bsqhW/file36393f36ae79.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    816.518    822.801    831.1244    830.2875
#>    compute_pi0(m * 10)   8223.409   8250.367   8298.7711   8278.5290
#>   compute_pi0(m * 100)  82009.376  82207.918  82834.5575  82314.4845
#>         compute_pi1(m)    151.117    170.328    237.5847    249.2485
#>    compute_pi1(m * 10)   1244.388   1366.016   2399.1560   1402.5795
#>   compute_pi1(m * 100)  12818.157  13100.263  22443.8337  15345.3470
#>  compute_pi1(m * 1000) 242726.558 329503.262 338571.8512 346929.4110
#>          uq        max neval
#>     833.889    886.307    20
#>    8326.450   8476.216    20
#>   82433.242  88315.656    20
#>     291.455    326.139    20
#>    1447.884   8271.769    20
#>   20512.961 128284.941    20
#>  351542.958 446626.543    20
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
#>   memory_copy1(n) 5578.43716 5415.09617 620.287448 4265.91375 3561.41144
#>   memory_copy2(n)   96.42319   94.34348  12.359685   78.21081   66.48237
#>  pre_allocate1(n)   21.11749   20.62980   3.921356   16.06344   13.48745
#>  pre_allocate2(n)  204.26856  201.06847  24.824861  161.81038  143.64531
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  85.390880    10
#>   2.772414    10
#>   2.121196    10
#>   4.494756    10
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
#>    expr      min     lq     mean   median       uq      max neval
#>  f1(df) 247.1612 240.59 79.81128 233.7589 64.47879 29.77538     5
#>  f2(df)   1.0000   1.00  1.00000   1.0000  1.00000  1.00000     5
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
