
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
#>    id          a        b           c        d
#> 1   1 -0.7005778 2.615372  1.29285095 4.473129
#> 2   2 -0.7719991 1.330998  4.87731300 3.862538
#> 3   3 -1.9505609 1.300961  2.23644767 5.189777
#> 4   4 -0.1767101 3.048946  4.19442365 3.675698
#> 5   5  0.5958737 0.938813  3.95014228 5.098813
#> 6   6 -1.3815770 1.590492  5.61257152 4.455706
#> 7   7 -0.1100750 3.220801  3.01537035 4.962204
#> 8   8 -1.0473520 2.387755  3.88337598 3.429396
#> 9   9  1.2407275 2.160329 -0.05223882 4.641645
#> 10 10 -0.8247634 2.657575  2.92428989 3.382317
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.5127014
mean(df$b)
#> [1] 2.125204
mean(df$c)
#> [1] 3.193455
mean(df$d)
#> [1] 4.317122
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.5127014  2.1252043  3.1934546  4.3171222
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
#> [1] -0.5127014  2.1252043  3.1934546  4.3171222
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
#> [1]  5.5000000 -0.5127014  2.1252043  3.1934546  4.3171222
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
#> [1]  5.5000000 -0.7362884  2.2740419  3.4493732  4.4644172
col_describe(df, mean)
#> [1]  5.5000000 -0.5127014  2.1252043  3.1934546  4.3171222
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
#>  5.5000000 -0.5127014  2.1252043  3.1934546  4.3171222
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
#>   4.075   0.132   4.207
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.022   0.000   0.663
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
#>  12.974   0.980  10.125
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
#>   0.127   0.000   0.127
plyr_st
#>    user  system elapsed 
#>   4.394   0.000   4.395
est_l_st
#>    user  system elapsed 
#>  68.919   1.112  70.032
est_r_st
#>    user  system elapsed 
#>   0.415   0.000   0.415
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

<!--html_preserve--><div id="htmlwidget-ff8898ae8850c894ed8b" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-ff8898ae8850c894ed8b">{"x":{"message":{"prof":{"time":[1,1,1,1,2,2,3,3,4,4,4,5,5,5,6,6,7,7,7,7,7,8,8,8,9,9,10,10,10,11,11,11,11,11,12,12,12,12,12,13,13,13,13,13,13,14,14,14,15,15,15,16,16,16,16,17,17,18,18,18,18,18,19,19,20,20,20,21,21,22,22,23,23,24,24,25,25,26,26,26,26,26,27,27,28,28,29,29,29,30,30,30,30,30,30,31,31,31,32,32,33,33,33,34,34,34,34,34,34,35,35,36,36,37,37,38,38,38,39,39,39,40,40,41,41,42,42,43,43,43,43,44,44,44,45,45,45,45,45,46,46,46,47,47,47,48,48,48,49,49,50,50,50,51,51,51,52,52,52,52,53,53,53,54,54,55,55,55,55,55,55,56,56,56,56,56,57,57,58,58,58,59,59,59,59,59,59,60,60,60,60,60,61,61,62,62,63,63,63,64,64,65,65,66,66,67,67,67,67,67,67,68,68,68,69,69,69,69,69,69,70,70,71,71,71,71,71,71,72,72,73,73,73,73,74,74,75,75,75,75,75,75,76,76,77,77,77,78,78,78,79,79,79,79,79,80,80,80,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,97,97,98,98,99,99,100,100,100,101,101,101,101,102,102,102,103,103,103,103,104,104,105,105,105,105,105,105,106,106,106,106,106,107,107,108,108,108,108,108,109,109,109,110,110,110,110,111,111,111,112,112,112,112,112,113,113,114,114,114,115,115,116,116,116,116,117,117,118,118,118,119,119,119,120,120,120,121,121,122,122,123,123,124,124,124,125,125,125,126,126,127,127,128,128,128,129,129,130,130,131,131,132,132,133,133,133,134,134,134,135,135,135,135,135,135,136,136,136,136,136,137,137,137,138,138,138,139,139,140,140,141,141,141,141,141,141,142,142,142,142,142,142,143,143,144,144,145,145,146,146,146,146,147,147,147,148,148,149,150,150,150,150,151,151,152,152,152,153,153,154,154,154,154,154,155,155,156,156,156,156,156,156,157,157,158,158,158,158,158,159,159,160,160,161,161,162,162,162,163,163,163,163,163,164,164,165,165,166,166,166,166,167,167,167,168,168,168,168,168,169,169,169,170,170,171,171,171,172,172,172,173,173,173,174,174,174,175,175,176,176,177,177,177,177,177,178,178,179,179,180,180,180,180,180,180,181,181,182,182,182,182,182,183,183,184,184,184,184,185,185,185,186,186,187,187,187,188,188,189,189,190,190,190,191,191,192,192,193,193,194,194,195,195,196,196,197,197,198,198,199,199,199,200,200,201,201,202,202,203,203,204,204,204,205,205,206,206,206,206,207,207,207,207,208,208,209,209,210,210,210,210,210,210,211,211,211,211,211,212,212,213,213,213,214,214,215,215,215,215,215,216,216,216,217,217,218,218,218,219,219,220,220,221,221,222,222,223,223,224,224,224,225,225,226,226,227,227,227,227,227,227,228,228,229,229,230,230,231,231,232,232,232,233,233,233,234,234,234,235,235,235,236,236,236,236,237,237,237,237,237,238,238,239,239,239,240,240,240,241,241,241,242,242,243,243,244,244,244,244,244,244,245,245,245,245,246,246,246,246,247,247,248,248,249,249,249,250,250,250,250,251,251,252,253,253,253,254,254,255,255,255,256,256,257,257,258,258,258,259,259,259,259,259,260,260,260,261,261,262,262,262,263,263,264,264,265,265,266,266,267,267,267,267,267,268,268,268,268,269,269,269,270,270,270,270,270,271,271,271,272,272,273,273,274,274,274,275,275,275,275,275,276,276,276,277,277,277,277,277,278,278,278,279,279,280,280,280,281,281,282,282,282,283,283,283,284,284,285,285,285,286,286,286,287,287,287,288,288,289,289,289,290,290,291,291,291,291,291,292,292,292,293,293,293,293,293,294,294,295,295,296,296,296,297,297,298,298,298,298,298,299,299,299,299,299,300,300,300,300,300],"depth":[4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1],"label":["[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","nrow","attr","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","length","length","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","$","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","dim","dim","nrow","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,null,1,1,1,null,null,null,null,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1],"linenum":[null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,11,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,null,11,9,9,null,null,null,null,11,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,10,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,11,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,13],"memalloc":[64.6976623535156,64.6976623535156,64.6976623535156,64.6976623535156,85.8811264038086,85.8811264038086,112.452713012695,112.452713012695,128.523658752441,128.523658752441,128.523658752441,146.298805236816,146.298805236816,146.298805236816,54.7955932617188,54.7955932617188,85.3696670532227,85.3696670532227,85.3696670532227,85.3696670532227,85.3696670532227,105.577186584473,105.577186584473,105.577186584473,133.51838684082,133.51838684082,146.310089111328,146.310089111328,146.310089111328,62.5356674194336,62.5356674194336,62.5356674194336,62.5356674194336,62.5356674194336,82.939094543457,82.939094543457,82.939094543457,82.939094543457,82.939094543457,112.728958129883,112.728958129883,112.728958129883,112.728958129883,112.728958129883,112.728958129883,131.493850708008,131.493850708008,131.493850708008,146.318046569824,146.318046569824,146.318046569824,61.3519058227539,61.3519058227539,61.3519058227539,61.3519058227539,92.8379592895508,92.8379592895508,111.925354003906,111.925354003906,111.925354003906,111.925354003906,111.925354003906,140.784759521484,140.784759521484,146.297706604004,146.297706604004,146.297706604004,70.8097457885742,70.8097457885742,91.1466903686523,91.1466903686523,122.698799133301,122.698799133301,143.229415893555,143.229415893555,52.7041625976562,52.7041625976562,72.9088516235352,72.9088516235352,72.9088516235352,72.9088516235352,72.9088516235352,104.19652557373,104.19652557373,125.061096191406,125.061096191406,146.31755065918,146.31755065918,146.31755065918,55.7864303588867,55.7864303588867,55.7864303588867,55.7864303588867,55.7864303588867,55.7864303588867,86.2247314453125,86.2247314453125,86.2247314453125,105.779205322266,105.779205322266,135.03881072998,135.03881072998,135.03881072998,146.327117919922,146.327117919922,146.327117919922,146.327117919922,146.327117919922,146.327117919922,64.9077606201172,64.9077606201172,85.382209777832,85.382209777832,115.233192443848,115.233192443848,134.126480102539,134.126480102539,134.126480102539,65.4333572387695,65.4333572387695,65.4333572387695,62.8102951049805,62.8102951049805,93.2585906982422,93.2585906982422,113.531623840332,113.531623840332,142.26806640625,142.26806640625,142.26806640625,142.26806640625,136.057426452637,136.057426452637,136.057426452637,71.6759414672852,71.6759414672852,71.6759414672852,71.6759414672852,71.6759414672852,92.7259292602539,92.7259292602539,92.7259292602539,124.224159240723,124.224159240723,124.224159240723,144.625640869141,144.625640869141,144.625640869141,53.4355697631836,53.4355697631836,73.5077590942383,73.5077590942383,73.5077590942383,103.75171661377,103.75171661377,103.75171661377,122.906242370605,122.906242370605,122.906242370605,122.906242370605,146.330085754395,146.330085754395,146.330085754395,52.6483154296875,52.6483154296875,82.7618255615234,82.7618255615234,82.7618255615234,82.7618255615234,82.7618255615234,82.7618255615234,103.812759399414,103.812759399414,103.812759399414,103.812759399414,103.812759399414,132.867828369141,132.867828369141,146.320243835449,146.320243835449,146.320243835449,61.1197204589844,61.1197204589844,61.1197204589844,61.1197204589844,61.1197204589844,61.1197204589844,81.258544921875,81.258544921875,81.258544921875,81.258544921875,81.258544921875,111.568382263184,111.568382263184,130.986213684082,130.986213684082,146.272499084473,146.272499084473,146.272499084473,61.5702743530273,61.5702743530273,92.0126647949219,92.0126647949219,112.752136230469,112.752136230469,143.58381652832,143.58381652832,143.58381652832,143.58381652832,143.58381652832,143.58381652832,44.6513900756836,44.6513900756836,44.6513900756836,74.1109771728516,74.1109771728516,74.1109771728516,74.1109771728516,74.1109771728516,74.1109771728516,94.1868057250977,94.1868057250977,124.22728729248,124.22728729248,124.22728729248,124.22728729248,124.22728729248,124.22728729248,143.381744384766,143.381744384766,53.1778564453125,53.1778564453125,53.1778564453125,53.1778564453125,73.2561111450195,73.2561111450195,103.898231506348,103.898231506348,103.898231506348,103.898231506348,103.898231506348,103.898231506348,124.56315612793,124.56315612793,146.275688171387,146.275688171387,146.275688171387,55.8038940429688,55.8038940429688,55.8038940429688,86.0405578613281,86.0405578613281,86.0405578613281,86.0405578613281,86.0405578613281,106.446929931641,106.446929931641,106.446929931641,106.446929931641,106.446929931641,106.446929931641,137.733100891113,137.733100891113,137.733100891113,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,146.325340270996,42.7538681030273,42.7538681030273,42.7538681030273,53.25341796875,53.25341796875,84.2821578979492,84.2821578979492,104.879508972168,104.879508972168,133.877182006836,133.877182006836,146.276351928711,146.276351928711,146.276351928711,66.4407577514648,66.4407577514648,66.4407577514648,66.4407577514648,86.5815963745117,86.5815963745117,86.5815963745117,116.688850402832,116.688850402832,116.688850402832,116.688850402832,135.316864013672,135.316864013672,46.2349624633789,46.2349624633789,46.2349624633789,46.2349624633789,46.2349624633789,46.2349624633789,66.6334915161133,66.6334915161133,66.6334915161133,66.6334915161133,66.6334915161133,97.7327194213867,97.7327194213867,117.345359802246,117.345359802246,117.345359802246,117.345359802246,117.345359802246,146.333183288574,146.333183288574,146.333183288574,48.2021484375,48.2021484375,48.2021484375,48.2021484375,78.1830520629883,78.1830520629883,78.1830520629883,98.9133758544922,98.9133758544922,98.9133758544922,98.9133758544922,98.9133758544922,128.431884765625,128.431884765625,146.276351928711,146.276351928711,146.276351928711,60.0142669677734,60.0142669677734,80.3463516235352,80.3463516235352,80.3463516235352,80.3463516235352,111.766540527344,111.766540527344,130.792198181152,130.792198181152,130.792198181152,67.0756607055664,67.0756607055664,67.0756607055664,61.9842987060547,61.9842987060547,61.9842987060547,92.5501403808594,92.5501403808594,113.348731994629,113.348731994629,144.506408691406,144.506408691406,47.2909469604492,47.2909469604492,47.2909469604492,77.2052841186523,77.2052841186523,77.2052841186523,98.123779296875,98.123779296875,129.740776062012,129.740776062012,146.331420898438,146.331420898438,146.331420898438,63.4946136474609,63.4946136474609,83.7611083984375,83.7611083984375,115.189323425293,115.189323425293,135.264152526855,135.264152526855,47.6218109130859,47.6218109130859,47.6218109130859,67.8954925537109,67.8954925537109,67.8954925537109,98.2079544067383,98.2079544067383,98.2079544067383,98.2079544067383,98.2079544067383,98.2079544067383,118.545600891113,118.545600891113,118.545600891113,118.545600891113,118.545600891113,146.292945861816,146.292945861816,146.292945861816,49.9184646606445,49.9184646606445,49.9184646606445,78.1305770874023,78.1305770874023,97.676139831543,97.676139831543,127.917663574219,127.917663574219,127.917663574219,127.917663574219,127.917663574219,127.917663574219,146.287940979004,146.287940979004,146.287940979004,146.287940979004,146.287940979004,146.287940979004,59.4958724975586,59.4958724975586,78.983039855957,78.983039855957,107.524642944336,107.524642944336,126.160820007324,126.160820007324,126.160820007324,126.160820007324,146.301338195801,146.301338195801,146.301338195801,58.5832977294922,58.5832977294922,86.7285537719727,107.455932617188,107.455932617188,107.455932617188,107.455932617188,136.584983825684,136.584983825684,146.298217773438,146.298217773438,146.298217773438,66.9159088134766,66.9159088134766,86.6656723022461,86.6656723022461,86.6656723022461,86.6656723022461,86.6656723022461,114.669906616211,114.669906616211,134.351409912109,134.351409912109,134.351409912109,134.351409912109,134.351409912109,134.351409912109,46.6461868286133,46.6461868286133,64.9529266357422,64.9529266357422,64.9529266357422,64.9529266357422,64.9529266357422,94.6025543212891,94.6025543212891,114.940246582031,114.940246582031,145.448028564453,145.448028564453,47.956413269043,47.956413269043,47.956413269043,77.3401794433594,77.3401794433594,77.3401794433594,77.3401794433594,77.3401794433594,96.9516677856445,96.9516677856445,127.193603515625,127.193603515625,145.757270812988,145.757270812988,145.757270812988,145.757270812988,58.8452835083008,58.8452835083008,58.8452835083008,78.9231033325195,78.9231033325195,78.9231033325195,78.9231033325195,78.9231033325195,109.226432800293,109.226432800293,109.226432800293,129.628532409668,129.628532409668,140.138175964355,140.138175964355,140.138175964355,61.868293762207,61.868293762207,61.868293762207,91.2705535888672,91.2705535888672,91.2705535888672,111.406913757324,111.406913757324,111.406913757324,141.845642089844,141.845642089844,44.5518188476562,44.5518188476562,74.589111328125,74.589111328125,74.589111328125,74.589111328125,74.589111328125,94.7223129272461,94.7223129272461,124.698226928711,124.698226928711,143.590858459473,143.590858459473,143.590858459473,143.590858459473,143.590858459473,143.590858459473,55.896728515625,55.896728515625,75.8999252319336,75.8999252319336,75.8999252319336,75.8999252319336,75.8999252319336,106.401565551758,106.401565551758,126.865104675293,126.865104675293,126.865104675293,126.865104675293,146.282485961914,146.282485961914,146.282485961914,60.3633575439453,60.3633575439453,90.207649230957,90.207649230957,90.207649230957,109.686477661133,109.686477661133,138.021354675293,138.021354675293,146.285179138184,146.285179138184,146.285179138184,71.1188430786133,71.1188430786133,91.450813293457,91.450813293457,120.705360412598,120.705360412598,141.168464660645,141.168464660645,52.0021667480469,52.0021667480469,71.9420700073242,71.9420700073242,103.418312072754,103.418312072754,124.143020629883,124.143020629883,146.310531616211,146.310531616211,146.310531616211,54.757568359375,54.757568359375,85.3916320800781,85.3916320800781,106.24633026123,106.24633026123,137.657974243164,137.657974243164,146.315994262695,146.315994262695,146.315994262695,69.318489074707,69.318489074707,89.9115753173828,89.9115753173828,89.9115753173828,89.9115753173828,120.015472412109,120.015472412109,120.015472412109,120.015472412109,139.367935180664,139.367935180664,49.9717788696289,49.9717788696289,68.2050552368164,68.2050552368164,68.2050552368164,68.2050552368164,68.2050552368164,68.2050552368164,97.0630798339844,97.0630798339844,97.0630798339844,97.0630798339844,97.0630798339844,117.658256530762,117.658256530762,146.315986633301,146.315986633301,146.315986633301,50.0386734008789,50.0386734008789,79.7484893798828,79.7484893798828,79.7484893798828,79.7484893798828,79.7484893798828,99.8832397460938,99.8832397460938,99.8832397460938,130.381011962891,130.381011962891,146.318916320801,146.318916320801,146.318916320801,61.0545883178711,61.0545883178711,80.7977523803711,80.7977523803711,109.653968811035,109.653968811035,130.380187988281,130.380187988281,43.2200317382812,43.2200317382812,62.5647430419922,62.5647430419922,62.5647430419922,93.7827835083008,93.7827835083008,114.643852233887,114.643852233887,145.140159606934,145.140159606934,145.140159606934,145.140159606934,145.140159606934,145.140159606934,47.0899200439453,47.0899200439453,77.7123641967773,77.7123641967773,98.563835144043,98.563835144043,129.972602844238,129.972602844238,146.298919677734,146.298919677734,146.298919677734,62.6339263916016,62.6339263916016,62.6339263916016,83.02685546875,83.02685546875,83.02685546875,114.500671386719,114.500671386719,114.500671386719,135.091087341309,135.091087341309,135.091087341309,135.091087341309,47.9432830810547,47.9432830810547,47.9432830810547,47.9432830810547,47.9432830810547,68.6633529663086,68.6633529663086,99.7446365356445,99.7446365356445,99.7446365356445,120.201759338379,120.201759338379,120.201759338379,146.301071166992,146.301071166992,146.301071166992,53.1265563964844,53.1265563964844,84.0126495361328,84.0126495361328,105.257934570312,105.257934570312,105.257934570312,105.257934570312,105.257934570312,105.257934570312,136.079742431641,136.079742431641,136.079742431641,136.079742431641,146.30916595459,146.30916595459,146.30916595459,146.30916595459,69.4530868530273,69.4530868530273,90.4358291625977,90.4358291625977,119.285484313965,119.285484313965,119.285484313965,140.726417541504,140.726417541504,140.726417541504,140.726417541504,53.6514663696289,53.6514663696289,74.4375228881836,105.976707458496,105.976707458496,105.976707458496,126.89315032959,126.89315032959,146.302108764648,146.302108764648,146.302108764648,58.9634552001953,58.9634552001953,88.7327041625977,88.7327041625977,109.519050598145,109.519050598145,109.519050598145,139.419021606445,139.419021606445,139.419021606445,139.419021606445,139.419021606445,146.303176879883,146.303176879883,146.303176879883,71.9458160400391,71.9458160400391,92.6016387939453,92.6016387939453,92.6016387939453,123.68204498291,123.68204498291,144.663017272949,144.663017272949,57.0604629516602,57.0604629516602,77.4501800537109,77.4501800537109,109.443557739258,109.443557739258,109.443557739258,109.443557739258,109.443557739258,130.292221069336,130.292221069336,130.292221069336,130.292221069336,129.337745666504,129.337745666504,129.337745666504,62.4378509521484,62.4378509521484,62.4378509521484,62.4378509521484,62.4378509521484,93.7760696411133,93.7760696411133,93.7760696411133,114.165077209473,114.165077209473,145.569488525391,145.569488525391,48.0148468017578,48.0148468017578,48.0148468017578,79.1568832397461,79.1568832397461,79.1568832397461,79.1568832397461,79.1568832397461,100.005821228027,100.005821228027,100.005821228027,131.672233581543,131.672233581543,131.672233581543,131.672233581543,131.672233581543,146.292198181152,146.292198181152,146.292198181152,65.3895263671875,65.3895263671875,85.7132873535156,85.7132873535156,85.7132873535156,116.985977172852,116.985977172852,137.638343811035,137.638343811035,137.638343811035,49.4581832885742,49.4581832885742,49.4581832885742,69.9128875732422,69.9128875732422,100.988479614258,100.988479614258,100.988479614258,121.902458190918,121.902458190918,121.902458190918,146.290687561035,146.290687561035,146.290687561035,55.0971984863281,55.0971984863281,85.7795181274414,85.7795181274414,85.7795181274414,106.430877685547,106.430877685547,137.899780273438,137.899780273438,137.899780273438,137.899780273438,137.899780273438,146.291343688965,146.291343688965,146.291343688965,70.1579742431641,70.1579742431641,70.1579742431641,70.1579742431641,70.1579742431641,89.1706314086914,89.1706314086914,118.803497314453,118.803497314453,138.275268554688,138.275268554688,138.275268554688,50.1625442504883,50.1625442504883,70.5518112182617,70.5518112182617,70.5518112182617,70.5518112182617,70.5518112182617,99.2674942016602,99.2674942016602,99.2674942016602,99.2674942016602,99.2674942016602,113.259483337402,113.259483337402,113.259483337402,113.259483337402,113.259483337402],"meminc":[0,0,0,0,21.183464050293,0,26.5715866088867,0,16.0709457397461,0,0,17.775146484375,0,0,-91.5032119750977,0,30.5740737915039,0,0,0,0,20.20751953125,0,0,27.9412002563477,0,12.7917022705078,0,0,-83.7744216918945,0,0,0,0,20.4034271240234,0,0,0,0,29.7898635864258,0,0,0,0,0,18.764892578125,0,0,14.8241958618164,0,0,-84.9661407470703,0,0,0,31.4860534667969,0,19.0873947143555,0,0,0,0,28.8594055175781,0,5.51294708251953,0,0,-75.4879608154297,0,20.3369445800781,0,31.5521087646484,0,20.5306167602539,0,-90.5252532958984,0,20.2046890258789,0,0,0,0,31.2876739501953,0,20.8645706176758,0,21.2564544677734,0,0,-90.531120300293,0,0,0,0,0,30.4383010864258,0,0,19.5544738769531,0,29.2596054077148,0,0,11.2883071899414,0,0,0,0,0,-81.4193572998047,0,20.4744491577148,0,29.8509826660156,0,18.8932876586914,0,0,-68.6931228637695,0,0,-2.62306213378906,0,30.4482955932617,0,20.2730331420898,0,28.736442565918,0,0,0,-6.21063995361328,0,0,-64.3814849853516,0,0,0,0,21.0499877929688,0,0,31.4982299804688,0,0,20.401481628418,0,0,-91.190071105957,0,20.0721893310547,0,0,30.2439575195312,0,0,19.1545257568359,0,0,0,23.4238433837891,0,0,-93.681770324707,0,30.1135101318359,0,0,0,0,0,21.0509338378906,0,0,0,0,29.0550689697266,0,13.4524154663086,0,0,-85.2005233764648,0,0,0,0,0,20.1388244628906,0,0,0,0,30.3098373413086,0,19.4178314208984,0,15.2862854003906,0,0,-84.7022247314453,0,30.4423904418945,0,20.7394714355469,0,30.8316802978516,0,0,0,0,0,-98.9324264526367,0,0,29.459587097168,0,0,0,0,0,20.0758285522461,0,30.0404815673828,0,0,0,0,0,19.1544570922852,0,-90.2038879394531,0,0,0,20.078254699707,0,30.6421203613281,0,0,0,0,0,20.664924621582,0,21.712532043457,0,0,-90.471794128418,0,0,30.2366638183594,0,0,0,0,20.4063720703125,0,0,0,0,0,31.2861709594727,0,0,8.59223937988281,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571472167969,0,0,10.4995498657227,0,31.0287399291992,0,20.5973510742188,0,28.997673034668,0,12.399169921875,0,0,-79.8355941772461,0,0,0,20.1408386230469,0,0,30.1072540283203,0,0,0,18.6280136108398,0,-89.081901550293,0,0,0,0,0,20.3985290527344,0,0,0,0,31.0992279052734,0,19.6126403808594,0,0,0,0,28.9878234863281,0,0,-98.1310348510742,0,0,0,29.9809036254883,0,0,20.7303237915039,0,0,0,0,29.5185089111328,0,17.8444671630859,0,0,-86.2620849609375,0,20.3320846557617,0,0,0,31.4201889038086,0,19.0256576538086,0,0,-63.7165374755859,0,0,-5.09136199951172,0,0,30.5658416748047,0,20.7985916137695,0,31.1576766967773,0,-97.215461730957,0,0,29.9143371582031,0,0,20.9184951782227,0,31.6169967651367,0,16.5906448364258,0,0,-82.8368072509766,0,20.2664947509766,0,31.4282150268555,0,20.0748291015625,0,-87.6423416137695,0,0,20.273681640625,0,0,30.3124618530273,0,0,0,0,0,20.337646484375,0,0,0,0,27.7473449707031,0,0,-96.3744812011719,0,0,28.2121124267578,0,19.5455627441406,0,30.2415237426758,0,0,0,0,0,18.3702774047852,0,0,0,0,0,-86.7920684814453,0,19.4871673583984,0,28.5416030883789,0,18.6361770629883,0,0,0,20.1405181884766,0,0,-87.7180404663086,0,28.1452560424805,20.7273788452148,0,0,0,29.1290512084961,0,9.71323394775391,0,0,-79.3823089599609,0,19.7497634887695,0,0,0,0,28.0042343139648,0,19.6815032958984,0,0,0,0,0,-87.7052230834961,0,18.3067398071289,0,0,0,0,29.6496276855469,0,20.3376922607422,0,30.5077819824219,0,-97.4916152954102,0,0,29.3837661743164,0,0,0,0,19.6114883422852,0,30.2419357299805,0,18.5636672973633,0,0,0,-86.9119873046875,0,0,20.0778198242188,0,0,0,0,30.3033294677734,0,0,20.402099609375,0,10.5096435546875,0,0,-78.2698822021484,0,0,29.4022598266602,0,0,20.136360168457,0,0,30.4387283325195,0,-97.2938232421875,0,30.0372924804688,0,0,0,0,20.1332015991211,0,29.9759140014648,0,18.8926315307617,0,0,0,0,0,-87.6941299438477,0,20.0031967163086,0,0,0,0,30.5016403198242,0,20.4635391235352,0,0,0,19.4173812866211,0,0,-85.9191284179688,0,29.8442916870117,0,0,19.4788284301758,0,28.3348770141602,0,8.26382446289062,0,0,-75.1663360595703,0,20.3319702148438,0,29.2545471191406,0,20.4631042480469,0,-89.1662979125977,0,19.9399032592773,0,31.4762420654297,0,20.7247085571289,0,22.1675109863281,0,0,-91.5529632568359,0,30.6340637207031,0,20.8546981811523,0,31.4116439819336,0,8.65802001953125,0,0,-76.9975051879883,0,20.5930862426758,0,0,0,30.1038970947266,0,0,0,19.3524627685547,0,-89.3961563110352,0,18.2332763671875,0,0,0,0,0,28.858024597168,0,0,0,0,20.5951766967773,0,28.6577301025391,0,0,-96.2773132324219,0,29.7098159790039,0,0,0,0,20.1347503662109,0,0,30.4977722167969,0,15.9379043579102,0,0,-85.2643280029297,0,19.7431640625,0,28.8562164306641,0,20.7262191772461,0,-87.16015625,0,19.3447113037109,0,0,31.2180404663086,0,20.8610687255859,0,30.4963073730469,0,0,0,0,0,-98.0502395629883,0,30.622444152832,0,20.8514709472656,0,31.4087677001953,0,16.3263168334961,0,0,-83.6649932861328,0,0,20.3929290771484,0,0,31.4738159179688,0,0,20.5904159545898,0,0,0,-87.1478042602539,0,0,0,0,20.7200698852539,0,31.0812835693359,0,0,20.4571228027344,0,0,26.0993118286133,0,0,-93.1745147705078,0,30.8860931396484,0,21.2452850341797,0,0,0,0,0,30.8218078613281,0,0,0,10.2294235229492,0,0,0,-76.8560791015625,0,20.9827423095703,0,28.8496551513672,0,0,21.4409332275391,0,0,0,-87.074951171875,0,20.7860565185547,31.5391845703125,0,0,20.9164428710938,0,19.4089584350586,0,0,-87.3386535644531,0,29.7692489624023,0,20.7863464355469,0,0,29.8999710083008,0,0,0,0,6.8841552734375,0,0,-74.3573608398438,0,20.6558227539062,0,0,31.0804061889648,0,20.9809722900391,0,-87.6025543212891,0,20.3897171020508,0,31.9933776855469,0,0,0,0,20.8486633300781,0,0,0,-0.954475402832031,0,0,-66.8998947143555,0,0,0,0,31.3382186889648,0,0,20.3890075683594,0,31.404411315918,0,-97.5546417236328,0,0,31.1420364379883,0,0,0,0,20.8489379882812,0,0,31.6664123535156,0,0,0,0,14.6199645996094,0,0,-80.9026718139648,0,20.3237609863281,0,0,31.2726898193359,0,20.6523666381836,0,0,-88.1801605224609,0,0,20.454704284668,0,31.0755920410156,0,0,20.9139785766602,0,0,24.3882293701172,0,0,-91.193489074707,0,30.6823196411133,0,0,20.6513595581055,0,31.4689025878906,0,0,0,0,8.39156341552734,0,0,-76.1333694458008,0,0,0,0,19.0126571655273,0,29.6328659057617,0,19.4717712402344,0,0,-88.1127243041992,0,20.3892669677734,0,0,0,0,28.7156829833984,0,0,0,0,13.9919891357422,0,0,0,0],"filename":[null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpcbBtKr/file3a526890d880.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    800.095    806.4400    823.1653    819.980
#>    compute_pi0(m * 10)   7986.707   8027.8805   8422.3232   8058.789
#>   compute_pi0(m * 100)  80158.840  80336.6935  80591.5958  80554.626
#>         compute_pi1(m)    163.203    229.9275    286.1230    316.622
#>    compute_pi1(m * 10)   1343.544   1402.8610   1906.5937   1490.891
#>   compute_pi1(m * 100)  13622.821  13966.3205  24473.1718  14266.265
#>  compute_pi1(m * 1000) 263250.059 381398.0875 403382.1595 431635.011
#>           uq        max neval
#>     832.9755    876.060    20
#>    8149.9495  14832.362    20
#>   80858.6300  81106.034    20
#>     336.1480    352.127    20
#>    1506.5620   9285.946    20
#>   19959.9490 166969.835    20
#>  437500.2290 578329.715    20
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
#>              expr       min         lq       mean     median         uq
#>   memory_copy1(n) 5730.5907 4069.56050 570.809458 3442.96692 3058.85113
#>   memory_copy2(n)  100.4427   73.65614  11.484146   62.89263   54.36697
#>  pre_allocate1(n)   20.5436   14.67403   3.528971   12.56589   10.85964
#>  pre_allocate2(n)  200.1313  143.81496  21.238690  125.44053  106.49640
#>     vectorized(n)    1.0000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  85.180517    10
#>   2.917283    10
#>   2.006676    10
#>   4.071999    10
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
#>  f1(df) 299.8154 295.2658 100.235 295.8111 77.40599 46.42607     5
#>  f2(df)   1.0000   1.0000   1.000   1.0000  1.00000  1.00000     5
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
