
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
#>    id          a        b        c        d
#> 1   1 -0.3117798 1.602084 3.648775 3.437656
#> 2   2 -0.3279764 1.180887 4.112777 3.060843
#> 3   3  1.1770236 1.910850 3.523927 4.223959
#> 4   4  0.7079493 2.119346 2.761888 3.410039
#> 5   5  1.5913424 2.058353 3.569785 4.284833
#> 6   6 -1.0157169 4.522292 3.426374 4.562804
#> 7   7  1.2162129 2.182531 2.542930 4.211132
#> 8   8 -1.2760249 1.197423 2.426448 4.715538
#> 9   9 -0.4391714 1.801172 4.133222 4.239301
#> 10 10  1.8524734 2.514581 3.136550 3.313227
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.3174332
mean(df$b)
#> [1] 2.108952
mean(df$c)
#> [1] 3.328268
mean(df$d)
#> [1] 3.945933
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.3174332 2.1089520 3.3282676 3.9459331
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
#> [1] 0.3174332 2.1089520 3.3282676 3.9459331
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
#> [1] 5.5000000 0.3174332 2.1089520 3.3282676 3.9459331
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
#> [1] 5.5000000 0.1980847 1.9846015 3.4751504 4.2175456
col_describe(df, mean)
#> [1] 5.5000000 0.3174332 2.1089520 3.3282676 3.9459331
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
#> 5.5000000 0.3174332 2.1089520 3.3282676 3.9459331
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
#>   3.857   0.132   3.986
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.004   0.632
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
#>  12.849   0.805   9.877
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
#>   0.117   0.001   0.118
plyr_st
#>    user  system elapsed 
#>   4.044   0.003   4.046
est_l_st
#>    user  system elapsed 
#>  61.314   1.389  62.673
est_r_st
#>    user  system elapsed 
#>   0.381   0.008   0.389
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

<!--html_preserve--><div id="htmlwidget-34243f8420be466626b5" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-34243f8420be466626b5">{"x":{"message":{"prof":{"time":[1,1,1,1,2,2,3,3,3,4,4,5,5,5,6,6,6,7,7,8,8,8,9,9,9,9,9,10,10,11,11,11,12,12,13,13,14,14,14,15,15,16,16,17,18,18,18,18,18,19,19,19,20,20,21,21,21,22,22,23,23,23,24,24,25,25,26,26,26,26,27,27,27,28,28,29,29,29,29,29,30,30,31,31,31,32,32,32,32,32,32,33,33,34,34,34,35,35,35,36,36,37,37,38,38,39,39,39,39,39,39,40,40,40,40,40,41,41,41,41,41,42,42,43,43,43,44,44,45,45,45,46,46,46,46,46,47,47,48,48,48,48,48,48,49,49,50,50,50,51,51,52,52,53,53,53,54,54,55,55,55,55,56,56,57,57,57,58,58,59,59,60,60,61,61,62,62,63,63,63,64,64,65,65,65,66,66,66,66,67,67,68,68,69,69,70,70,71,71,71,71,72,72,72,73,73,74,74,74,75,75,76,76,76,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,88,88,88,89,89,89,90,90,90,90,91,91,91,91,92,92,92,93,93,93,93,94,94,95,95,95,96,96,97,97,98,98,98,98,98,98,99,99,100,100,100,101,101,102,102,102,102,102,103,103,104,104,105,105,106,106,106,106,106,107,107,108,108,109,109,110,110,110,110,110,110,111,111,111,112,112,113,113,114,114,114,115,115,116,116,116,116,117,117,117,118,118,119,119,119,119,119,119,120,120,121,121,121,121,122,122,123,123,124,124,125,125,125,125,125,126,126,126,127,127,127,127,127,128,128,128,128,128,129,129,129,129,130,130,131,131,132,132,132,132,132,133,133,133,133,133,133,134,134,134,135,135,136,136,137,137,138,138,139,139,139,140,140,141,141,141,141,141,141,142,142,143,143,144,144,144,145,145,146,146,146,147,147,148,148,148,149,149,150,150,150,151,151,151,152,152,152,152,152,153,153,153,153,153,154,154,154,154,154,154,155,155,156,156,157,157,157,158,158,158,158,159,159,160,160,160,160,161,161,161,162,162,163,163,163,163,164,164,165,165,165,166,166,166,167,167,167,168,168,169,169,169,169,169,170,170,170,170,170,171,171,172,172,173,173,174,174,174,175,175,175,175,175,176,176,177,177,178,178,178,178,179,179,180,180,181,181,182,182,183,183,184,184,184,185,185,185,186,186,187,187,188,188,188,189,189,189,190,190,191,191,191,192,192,192,193,193,194,194,195,195,196,196,197,197,197,197,197,197,198,198,199,199,199,200,200,200,201,201,202,202,202,203,203,204,204,204,204,204,205,205,206,206,206,206,206,206,207,207,207,207,208,208,208,209,209,210,210,211,211,211,212,212,213,213,214,214,215,215,215,215,215,216,216,217,217,217,217,217,217,218,218,219,219,219,220,220,220,221,221,221,222,222,223,223,224,224,225,225,225,226,226,226,226,227,227,227,228,228,228,228,228,228,229,229,229,230,230,230,231,231,232,232,233,233,234,234,235,235,235,236,236,236,237,237,238,239,239,240,240,241,241,241,242,242,242,243,243,243,244,244,245,245,245,246,246,247,247,248,248,249,249,250,250,250,251,251,251,251,252,252,252,253,253,253,253,253,253,254,254,254,254,255,255,255,255,255,256,256,256,256,256,256,257,257,258,258,259,259,259,260,260,261,261,262,262,263,263,263,263,263,264,264,265,265,265,266,266,267,267,267,268,268,268,268,268,268,269,269,269,270,270,271,271,271,271,271,272,272,272,273,273,273,274,274,275,275,275,276,276],"depth":[4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1],"label":["[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","nrow","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","oldClass","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","dim","dim","nrow","[.data.frame","["],"filenum":[null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,null,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1],"linenum":[null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,11,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,10,10,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,null,11,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,11,9,9],"memalloc":[57.9381561279297,57.9381561279297,57.9381561279297,57.9381561279297,79.5177307128906,79.5177307128906,108.055908203125,108.055908203125,108.055908203125,125.899475097656,125.899475097656,146.298316955566,146.298316955566,146.298316955566,58.3397979736328,58.3397979736328,58.3397979736328,90.6809310913086,90.6809310913086,110.300788879395,110.300788879395,110.300788879395,141.195297241211,141.195297241211,141.195297241211,141.195297241211,141.195297241211,45.4149169921875,45.4149169921875,77.9510192871094,77.9510192871094,77.9510192871094,98.8811721801758,98.8811721801758,129.655601501465,129.655601501465,146.317558288574,146.317558288574,146.317558288574,64.5007019042969,64.5007019042969,85.4944686889648,85.4944686889648,116.451309204102,136.717620849609,136.717620849609,136.717620849609,136.717620849609,136.717620849609,51.2585296630859,51.2585296630859,51.2585296630859,72.1226348876953,72.1226348876953,104.723533630371,104.723533630371,104.723533630371,126.371650695801,126.371650695801,146.312210083008,146.312210083008,146.312210083008,63.001106262207,63.001106262207,95.4078826904297,95.4078826904297,116.923614501953,116.923614501953,116.923614501953,116.923614501953,146.31706237793,146.31706237793,146.31706237793,54.3424377441406,54.3424377441406,86.4869384765625,86.4869384765625,86.4869384765625,86.4869384765625,86.4869384765625,106.696846008301,106.696846008301,136.874946594238,136.874946594238,136.874946594238,146.326629638672,146.326629638672,146.326629638672,146.326629638672,146.326629638672,146.326629638672,72.8486099243164,72.8486099243164,93.5849227905273,93.5849227905273,93.5849227905273,123.500381469727,123.500381469727,123.500381469727,143.640647888184,143.640647888184,58.6785430908203,58.6785430908203,80.1347198486328,80.1347198486328,110.841239929199,110.841239929199,110.841239929199,110.841239929199,110.841239929199,110.841239929199,130.918968200684,130.918968200684,130.918968200684,130.918968200684,130.918968200684,45.7566299438477,45.7566299438477,45.7566299438477,45.7566299438477,45.7566299438477,66.7570953369141,66.7570953369141,97.4521636962891,97.4521636962891,97.4521636962891,118.909538269043,118.909538269043,146.330375671387,146.330375671387,146.330375671387,54.8784713745117,54.8784713745117,54.8784713745117,54.8784713745117,54.8784713745117,86.3020477294922,86.3020477294922,107.030471801758,107.030471801758,107.030471801758,107.030471801758,107.030471801758,107.030471801758,137.734077453613,137.734077453613,146.329597473145,146.329597473145,146.329597473145,73.4442749023438,73.4442749023438,94.8278198242188,94.8278198242188,125.194259643555,125.194259643555,125.194259643555,144.744117736816,144.744117736816,59.5442733764648,59.5442733764648,59.5442733764648,59.5442733764648,79.8151931762695,79.8151931762695,110.846755981445,110.846755981445,110.846755981445,131.248001098633,131.248001098633,45.5674591064453,45.5674591064453,66.6216354370117,66.6216354370117,98.5110321044922,98.5110321044922,120.163475036621,120.163475036621,146.272583007812,146.272583007812,146.272583007812,57.0490875244141,57.0490875244141,88.7401275634766,88.7401275634766,88.7401275634766,109.338607788086,109.338607788086,109.338607788086,109.338607788086,140.167915344238,140.167915344238,45.2427215576172,45.2427215576172,76.9973831176758,76.9973831176758,98.3897476196289,98.3897476196289,130.13720703125,130.13720703125,130.13720703125,130.13720703125,146.275199890137,146.275199890137,146.275199890137,66.8189163208008,66.8189163208008,87.3522262573242,87.3522262573242,87.3522262573242,118.778289794922,118.778289794922,139.308685302734,139.308685302734,139.308685302734,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,146.324851989746,42.7533798217773,42.7533798217773,42.7533798217773,57.9116744995117,57.9116744995117,78.9689102172852,78.9689102172852,78.9689102172852,109.732131958008,109.732131958008,109.732131958008,130.727363586426,130.727363586426,130.727363586426,130.727363586426,46.8890838623047,46.8890838623047,46.8890838623047,46.8890838623047,67.6862106323242,67.6862106323242,67.6862106323242,97.9894714355469,97.9894714355469,97.9894714355469,97.9894714355469,117.736946105957,117.736946105957,146.272338867188,146.272338867188,146.272338867188,53.3845062255859,53.3845062255859,85.2022323608398,85.2022323608398,105.99885559082,105.99885559082,105.99885559082,105.99885559082,105.99885559082,105.99885559082,136.755981445312,136.755981445312,124.47193145752,124.47193145752,124.47193145752,73.5258865356445,73.5258865356445,94.5819625854492,94.5819625854492,94.5819625854492,94.5819625854492,94.5819625854492,125.543815612793,125.543815612793,145.816307067871,145.816307067871,62.4412841796875,62.4412841796875,83.8865585327148,83.8865585327148,83.8865585327148,83.8865585327148,83.8865585327148,115.44214630127,115.44214630127,135.643699645996,135.643699645996,52.1459732055664,52.1459732055664,72.5443344116211,72.5443344116211,72.5443344116211,72.5443344116211,72.5443344116211,72.5443344116211,104.752891540527,104.752891540527,104.752891540527,126.335693359375,126.335693359375,43.61572265625,43.61572265625,64.6070556640625,64.6070556640625,64.6070556640625,96.221809387207,96.221809387207,117.539916992188,117.539916992188,117.539916992188,117.539916992188,146.330932617188,146.330932617188,146.330932617188,55.6852951049805,55.6852951049805,87.1715316772461,87.1715316772461,87.1715316772461,87.1715316772461,87.1715316772461,87.1715316772461,108.500137329102,108.500137329102,140.905471801758,140.905471801758,140.905471801758,140.905471801758,47.2927856445312,47.2927856445312,78.5889511108398,78.5889511108398,99.8478851318359,99.8478851318359,130.550888061523,130.550888061523,130.550888061523,130.550888061523,130.550888061523,146.292457580566,146.292457580566,146.292457580566,65.9895706176758,65.9895706176758,65.9895706176758,65.9895706176758,65.9895706176758,86.2631607055664,86.2631607055664,86.2631607055664,86.2631607055664,86.2631607055664,118.534980773926,118.534980773926,118.534980773926,118.534980773926,139.661331176758,139.661331176758,56.8718719482422,56.8718719482422,78.1291885375977,78.1291885375977,78.1291885375977,78.1291885375977,78.1291885375977,109.885093688965,109.885093688965,109.885093688965,109.885093688965,109.885093688965,109.885093688965,131.342498779297,131.342498779297,131.342498779297,47.888427734375,47.888427734375,68.6238174438477,68.6238174438477,100.042671203613,100.042671203613,120.446220397949,120.446220397949,146.297729492188,146.297729492188,146.297729492188,57.3978652954102,57.3978652954102,87.9104614257812,87.9104614257812,87.9104614257812,87.9104614257812,87.9104614257812,87.9104614257812,108.370475769043,108.370475769043,138.552452087402,138.552452087402,45.1351165771484,45.1351165771484,45.1351165771484,76.4339370727539,76.4339370727539,97.0942230224609,97.0942230224609,97.0942230224609,129.638084411621,129.638084411621,146.300552368164,146.300552368164,146.300552368164,67.9607162475586,67.9607162475586,88.9516067504883,88.9516067504883,88.9516067504883,120.437545776367,120.437545776367,120.437545776367,140.70532989502,140.70532989502,140.70532989502,140.70532989502,140.70532989502,57.5981826782227,57.5981826782227,57.5981826782227,57.5981826782227,57.5981826782227,78.7256546020508,78.7256546020508,78.7256546020508,78.7256546020508,78.7256546020508,78.7256546020508,110.21061706543,110.21061706543,131.332633972168,131.332633972168,49.205924987793,49.205924987793,49.205924987793,70.006477355957,70.006477355957,70.006477355957,70.006477355957,102.551979064941,102.551979064941,124.067886352539,124.067886352539,124.067886352539,124.067886352539,146.305770874023,146.305770874023,146.305770874023,63.505859375,63.505859375,95.1818389892578,95.1818389892578,95.1818389892578,95.1818389892578,116.62882232666,116.62882232666,146.279930114746,146.279930114746,146.279930114746,53.9281158447266,53.9281158447266,53.9281158447266,85.4091033935547,85.4091033935547,85.4091033935547,107.056442260742,107.056442260742,139.195999145508,139.195999145508,139.195999145508,139.195999145508,139.195999145508,46.4562225341797,46.4562225341797,46.4562225341797,46.4562225341797,46.4562225341797,78.3346176147461,78.3346176147461,99.848258972168,99.848258972168,130.542755126953,130.542755126953,146.284690856934,146.284690856934,146.284690856934,68.6913299560547,68.6913299560547,68.6913299560547,68.6913299560547,68.6913299560547,90.2692031860352,90.2692031860352,122.606460571289,122.606460571289,144.054161071777,144.054161071777,144.054161071777,144.054161071777,60.2006454467773,60.2006454467773,81.7114868164062,81.7114868164062,113.977012634277,113.977012634277,135.553939819336,135.553939819336,52.2648696899414,52.2648696899414,73.7792053222656,73.7792053222656,73.7792053222656,106.508094787598,106.508094787598,106.508094787598,128.150779724121,128.150779724121,45.3137130737305,45.3137130737305,66.3668899536133,66.3668899536133,66.3668899536133,97.8483123779297,97.8483123779297,97.8483123779297,119.03125,119.03125,146.318572998047,146.318572998047,146.318572998047,55.8736801147461,55.8736801147461,55.8736801147461,86.6991195678711,86.6991195678711,107.753967285156,107.753967285156,139.431297302246,139.431297302246,45.3811187744141,45.3811187744141,76.7311477661133,76.7311477661133,76.7311477661133,76.7311477661133,76.7311477661133,76.7311477661133,98.1773910522461,98.1773910522461,130.44669342041,130.44669342041,130.44669342041,146.318428039551,146.318428039551,146.318428039551,68.5328063964844,68.5328063964844,90.1746673583984,90.1746673583984,90.1746673583984,122.835845947266,122.835845947266,143.892448425293,143.892448425293,143.892448425293,143.892448425293,143.892448425293,60.9243469238281,60.9243469238281,82.306037902832,82.306037902832,82.306037902832,82.306037902832,82.306037902832,82.306037902832,114.709106445312,114.709106445312,114.709106445312,114.709106445312,136.483825683594,136.483825683594,136.483825683594,53.6466598510742,53.6466598510742,75.1542205810547,75.1542205810547,107.414909362793,107.414909362793,107.414909362793,128.595268249512,128.595268249512,45.9123840332031,45.9123840332031,67.2880935668945,67.2880935668945,99.1571044921875,99.1571044921875,99.1571044921875,99.1571044921875,99.1571044921875,120.79411315918,120.79411315918,146.303337097168,146.303337097168,146.303337097168,146.303337097168,146.303337097168,146.303337097168,59.4828872680664,59.4828872680664,91.8761520385742,91.8761520385742,91.8761520385742,112.33324432373,112.33324432373,112.33324432373,144.202842712402,144.202842712402,144.202842712402,50.4376373291016,50.4376373291016,82.5695495605469,82.5695495605469,103.22469329834,103.22469329834,135.358055114746,135.358055114746,135.358055114746,146.30867767334,146.30867767334,146.30867767334,146.30867767334,73.3873977661133,73.3873977661133,73.3873977661133,94.2385864257812,94.2385864257812,94.2385864257812,94.2385864257812,94.2385864257812,94.2385864257812,126.498138427734,126.498138427734,126.498138427734,146.299621582031,146.299621582031,146.299621582031,64.8633422851562,64.8633422851562,86.0435791015625,86.0435791015625,118.565330505371,118.565330505371,140.33470916748,140.33470916748,56.7991027832031,56.7991027832031,56.7991027832031,77.8474426269531,77.8474426269531,77.8474426269531,109.518531799316,109.518531799316,130.697326660156,46.7667083740234,46.7667083740234,67.2896957397461,67.2896957397461,98.9619903564453,98.9619903564453,98.9619903564453,120.075439453125,120.075439453125,120.075439453125,146.301628112793,146.301628112793,146.301628112793,55.9452743530273,55.9452743530273,87.6773529052734,87.6773529052734,87.6773529052734,108.328857421875,108.328857421875,139.207939147949,139.207939147949,45.0633850097656,45.0633850097656,76.9920272827148,76.9920272827148,98.4959487915039,98.4959487915039,98.4959487915039,131.276847839355,131.276847839355,131.276847839355,131.276847839355,146.290573120117,146.290573120117,146.290573120117,69.51904296875,69.51904296875,69.51904296875,69.51904296875,69.51904296875,69.51904296875,90.8920364379883,90.8920364379883,90.8920364379883,90.8920364379883,122.886489868164,122.886489868164,122.886489868164,122.886489868164,122.886489868164,144.062789916992,144.062789916992,144.062789916992,144.062789916992,144.062789916992,144.062789916992,61.9139175415039,61.9139175415039,83.2868728637695,83.2868728637695,115.609146118164,115.609146118164,115.609146118164,137.506286621094,137.506286621094,55.5547943115234,55.5547943115234,77.0586853027344,77.0586853027344,109.773345947266,109.773345947266,109.773345947266,109.773345947266,109.773345947266,131.539245605469,131.539245605469,49.5898818969727,49.5898818969727,49.5898818969727,70.9621887207031,70.9621887207031,103.086875915527,103.086875915527,103.086875915527,124.786926269531,124.786926269531,124.786926269531,124.786926269531,124.786926269531,124.786926269531,146.290855407715,146.290855407715,146.290855407715,62.3557434082031,62.3557434082031,94.2838745117188,94.2838745117188,94.2838745117188,94.2838745117188,94.2838745117188,115.984306335449,115.984306335449,115.984306335449,146.273063659668,146.273063659668,146.273063659668,57.5049667358398,57.5049667358398,89.5636749267578,89.5636749267578,89.5636749267578,111.198570251465,111.198570251465],"meminc":[0,0,0,0,21.5795745849609,0,28.5381774902344,0,0,17.8435668945312,0,20.3988418579102,0,0,-87.9585189819336,0,0,32.3411331176758,0,19.6198577880859,0,0,30.8945083618164,0,0,0,0,-95.7803802490234,0,32.5361022949219,0,0,20.9301528930664,0,30.7744293212891,0,16.6619567871094,0,0,-81.8168563842773,0,20.993766784668,0,30.9568405151367,20.2663116455078,0,0,0,0,-85.4590911865234,0,0,20.8641052246094,0,32.6008987426758,0,0,21.6481170654297,0,19.940559387207,0,0,-83.3111038208008,0,32.4067764282227,0,21.5157318115234,0,0,0,29.3934478759766,0,0,-91.9746246337891,0,32.1445007324219,0,0,0,0,20.2099075317383,0,30.1781005859375,0,0,9.45168304443359,0,0,0,0,0,-73.4780197143555,0,20.7363128662109,0,0,29.9154586791992,0,0,20.140266418457,0,-84.9621047973633,0,21.4561767578125,0,30.7065200805664,0,0,0,0,0,20.0777282714844,0,0,0,0,-85.1623382568359,0,0,0,0,21.0004653930664,0,30.695068359375,0,0,21.4573745727539,0,27.4208374023438,0,0,-91.451904296875,0,0,0,0,31.4235763549805,0,20.7284240722656,0,0,0,0,0,30.7036056518555,0,8.59552001953125,0,0,-72.8853225708008,0,21.383544921875,0,30.3664398193359,0,0,19.5498580932617,0,-85.1998443603516,0,0,0,20.2709197998047,0,31.0315628051758,0,0,20.4012451171875,0,-85.6805419921875,0,21.0541763305664,0,31.8893966674805,0,21.6524429321289,0,26.1091079711914,0,0,-89.2234954833984,0,31.6910400390625,0,0,20.5984802246094,0,0,0,30.8293075561523,0,-94.9251937866211,0,31.7546615600586,0,21.3923645019531,0,31.7474594116211,0,0,0,16.1379928588867,0,0,-79.4562835693359,0,20.5333099365234,0,0,31.4260635375977,0,20.5303955078125,0,0,7.01616668701172,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571472167969,0,0,15.1582946777344,0,21.0572357177734,0,0,30.7632217407227,0,0,20.995231628418,0,0,0,-83.8382797241211,0,0,0,20.7971267700195,0,0,30.3032608032227,0,0,0,19.7474746704102,0,28.5353927612305,0,0,-92.8878326416016,0,31.8177261352539,0,20.7966232299805,0,0,0,0,0,30.7571258544922,0,-12.284049987793,0,0,-50.946044921875,0,21.0560760498047,0,0,0,0,30.9618530273438,0,20.2724914550781,0,-83.3750228881836,0,21.4452743530273,0,0,0,0,31.5555877685547,0,20.2015533447266,0,-83.4977264404297,0,20.3983612060547,0,0,0,0,0,32.2085571289062,0,0,21.5828018188477,0,-82.719970703125,0,20.9913330078125,0,0,31.6147537231445,0,21.3181076049805,0,0,0,28.791015625,0,0,-90.645637512207,0,31.4862365722656,0,0,0,0,0,21.3286056518555,0,32.4053344726562,0,0,0,-93.6126861572266,0,31.2961654663086,0,21.2589340209961,0,30.7030029296875,0,0,0,0,15.741569519043,0,0,-80.3028869628906,0,0,0,0,20.2735900878906,0,0,0,0,32.2718200683594,0,0,0,21.126350402832,0,-82.7894592285156,0,21.2573165893555,0,0,0,0,31.7559051513672,0,0,0,0,0,21.457405090332,0,0,-83.4540710449219,0,20.7353897094727,0,31.4188537597656,0,20.4035491943359,0,25.8515090942383,0,0,-88.8998641967773,0,30.5125961303711,0,0,0,0,0,20.4600143432617,0,30.1819763183594,0,-93.4173355102539,0,0,31.2988204956055,0,20.660285949707,0,0,32.5438613891602,0,16.662467956543,0,0,-78.3398361206055,0,20.9908905029297,0,0,31.4859390258789,0,0,20.2677841186523,0,0,0,0,-83.1071472167969,0,0,0,0,21.1274719238281,0,0,0,0,0,31.4849624633789,0,21.1220169067383,0,-82.126708984375,0,0,20.8005523681641,0,0,0,32.5455017089844,0,21.5159072875977,0,0,0,22.2378845214844,0,0,-82.7999114990234,0,31.6759796142578,0,0,0,21.4469833374023,0,29.6511077880859,0,0,-92.3518142700195,0,0,31.4809875488281,0,0,21.6473388671875,0,32.1395568847656,0,0,0,0,-92.7397766113281,0,0,0,0,31.8783950805664,0,21.5136413574219,0,30.6944961547852,0,15.7419357299805,0,0,-77.5933609008789,0,0,0,0,21.5778732299805,0,32.3372573852539,0,21.4477005004883,0,0,0,-83.853515625,0,21.5108413696289,0,32.2655258178711,0,21.5769271850586,0,-83.2890701293945,0,21.5143356323242,0,0,32.728889465332,0,0,21.6426849365234,0,-82.8370666503906,0,21.0531768798828,0,0,31.4814224243164,0,0,21.1829376220703,0,27.2873229980469,0,0,-90.4448928833008,0,0,30.825439453125,0,21.0548477172852,0,31.6773300170898,0,-94.050178527832,0,31.3500289916992,0,0,0,0,0,21.4462432861328,0,32.2693023681641,0,0,15.8717346191406,0,0,-77.7856216430664,0,21.6418609619141,0,0,32.6611785888672,0,21.0566024780273,0,0,0,0,-82.9681015014648,0,21.3816909790039,0,0,0,0,0,32.4030685424805,0,0,0,21.7747192382812,0,0,-82.8371658325195,0,21.5075607299805,0,32.2606887817383,0,0,21.1803588867188,0,-82.6828842163086,0,21.3757095336914,0,31.869010925293,0,0,0,0,21.6370086669922,0,25.5092239379883,0,0,0,0,0,-86.8204498291016,0,32.3932647705078,0,0,20.4570922851562,0,0,31.8695983886719,0,0,-93.7652053833008,0,32.1319122314453,0,20.655143737793,0,32.1333618164062,0,0,10.9506225585938,0,0,0,-72.9212799072266,0,0,20.851188659668,0,0,0,0,0,32.2595520019531,0,0,19.8014831542969,0,0,-81.436279296875,0,21.1802368164062,0,32.5217514038086,0,21.7693786621094,0,-83.5356063842773,0,0,21.04833984375,0,0,31.6710891723633,0,21.1787948608398,-83.9306182861328,0,20.5229873657227,0,31.6722946166992,0,0,21.1134490966797,0,0,26.226188659668,0,0,-90.3563537597656,0,31.7320785522461,0,0,20.6515045166016,0,30.8790817260742,0,-94.1445541381836,0,31.9286422729492,0,21.5039215087891,0,0,32.7808990478516,0,0,0,15.0137252807617,0,0,-76.7715301513672,0,0,0,0,0,21.3729934692383,0,0,0,31.9944534301758,0,0,0,0,21.1763000488281,0,0,0,0,0,-82.1488723754883,0,21.3729553222656,0,32.3222732543945,0,0,21.8971405029297,0,-81.9514923095703,0,21.5038909912109,0,32.7146606445312,0,0,0,0,21.7658996582031,0,-81.9493637084961,0,0,21.3723068237305,0,32.1246871948242,0,0,21.7000503540039,0,0,0,0,0,21.5039291381836,0,0,-83.9351119995117,0,31.9281311035156,0,0,0,0,21.7004318237305,0,0,30.2887573242188,0,0,-88.7680969238281,0,32.058708190918,0,0,21.634895324707,0],"filename":[null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpKeUwn3/file367215b68cda.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    806.162    812.057    828.8578    825.6885
#>    compute_pi0(m * 10)   8041.661   8082.381   8504.7162   8107.4290
#>   compute_pi0(m * 100)  80252.375  80938.901  81183.2669  81036.8990
#>         compute_pi1(m)    174.787    199.579    248.5903    264.9255
#>    compute_pi1(m * 10)   1261.107   1304.725   6865.6269   1378.3535
#>   compute_pi1(m * 100)  12711.804  13017.558  16441.9393  13239.1230
#>  compute_pi1(m * 1000) 241270.838 303141.218 342155.1753 364503.9960
#>           uq        max neval
#>     839.0545    888.729    20
#>    8171.3535  14307.488    20
#>   81519.7950  82034.448    20
#>     284.9715    315.428    20
#>    1417.3465 110363.694    20
#>   19636.3085  24997.065    20
#>  368917.6655 469534.647    20
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
#>   memory_copy1(n) 5469.02149 4387.79153 628.001396 4186.14796 3124.56486
#>   memory_copy2(n)   96.50298   79.49712  12.811989   81.55740   59.45784
#>  pre_allocate1(n)   20.93240   16.86027   3.958916   16.21607   11.88163
#>  pre_allocate2(n)  204.18774  162.94078  24.889444  160.57723  126.90750
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  88.257780    10
#>   2.792591    10
#>   2.142010    10
#>   4.263440    10
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
#>    expr      min       lq    mean   median       uq      max neval
#>  f1(df) 237.2498 229.0803 79.5434 227.7279 59.65537 32.65984     5
#>  f2(df)   1.0000   1.0000  1.0000   1.0000  1.00000  1.00000     5
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
