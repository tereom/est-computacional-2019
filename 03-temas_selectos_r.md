
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
#>    id          a          b        c        d
#> 1   1 -0.6822655 4.05323450 2.211745 4.457796
#> 2   2 -0.6957742 2.71044770 1.656618 4.816482
#> 3   3 -0.9503748 4.20779187 1.544356 3.199017
#> 4   4 -0.9456638 2.47107520 2.789810 2.950297
#> 5   5  0.5037280 2.98074209 1.805467 2.841556
#> 6   6  0.4524857 0.07079133 2.990490 3.413743
#> 7   7  0.6371684 1.08300276 2.398855 3.273912
#> 8   8  0.8486384 1.44460219 2.941703 4.149874
#> 9   9  1.0667624 2.20089788 2.555851 6.090475
#> 10 10  2.1939241 1.98554300 5.296956 3.908913
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.2428629
mean(df$b)
#> [1] 2.320813
mean(df$c)
#> [1] 2.619185
mean(df$d)
#> [1] 3.910207
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.2428629 2.3208129 2.6191852 3.9102066
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
#> [1] 0.2428629 2.3208129 2.6191852 3.9102066
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
#> [1] 5.5000000 0.2428629 2.3208129 2.6191852 3.9102066
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
#> [1] 5.5000000 0.4781068 2.3359865 2.4773531 3.6613282
col_describe(df, mean)
#> [1] 5.5000000 0.2428629 2.3208129 2.6191852 3.9102066
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
#> 5.5000000 0.2428629 2.3208129 2.6191852 3.9102066
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
#>   4.142   0.156   4.299
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.005   0.663
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
#>  14.246   0.917  10.915
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
#>   0.133   0.000   0.133
plyr_st
#>    user  system elapsed 
#>   4.710   0.004   4.713
est_l_st
#>    user  system elapsed 
#>  72.220   1.923  74.147
est_r_st
#>    user  system elapsed 
#>   0.427   0.016   0.443
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

<!--html_preserve--><div id="htmlwidget-40776e5f5e210390a9ed" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-40776e5f5e210390a9ed">{"x":{"message":{"prof":{"time":[1,1,2,2,2,3,3,4,4,4,5,5,5,6,6,6,7,7,8,8,9,9,10,10,11,11,11,12,12,12,13,13,13,13,14,14,15,15,16,16,17,17,18,18,18,19,19,20,20,20,21,21,21,22,22,22,23,23,24,24,24,25,25,26,26,27,27,27,28,28,28,29,29,30,30,30,30,31,31,31,31,32,32,32,33,33,34,34,34,35,35,35,35,36,36,36,36,36,36,37,37,37,37,37,37,38,38,39,39,39,39,39,40,40,40,41,41,41,42,42,42,43,43,44,44,44,44,44,44,45,45,45,46,46,47,47,47,48,48,48,48,49,49,50,50,51,51,52,52,53,53,53,53,54,54,55,55,55,56,56,57,57,57,58,58,58,59,59,60,60,60,60,60,60,61,61,61,61,62,62,63,63,63,64,64,64,65,65,66,66,66,67,67,68,68,68,69,69,69,69,69,70,70,71,71,72,72,73,73,73,74,75,75,75,75,76,76,77,77,78,78,79,79,80,80,81,81,82,82,82,83,83,83,84,84,84,85,85,86,86,87,87,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,103,104,104,104,105,105,105,106,106,107,107,107,107,107,108,108,109,109,109,109,109,110,110,110,111,111,111,112,112,113,113,114,114,114,115,115,115,115,115,115,116,116,116,117,117,118,118,119,119,119,120,120,120,121,121,121,121,121,122,122,122,123,123,123,123,124,124,124,125,125,125,126,126,126,126,126,127,127,127,127,127,128,128,129,129,129,130,130,131,131,131,132,132,133,133,134,134,134,134,134,135,135,135,135,135,135,136,136,136,137,137,138,138,138,138,138,139,139,140,140,140,141,141,142,142,142,143,143,144,144,144,144,144,144,145,145,146,146,147,147,147,148,148,148,148,149,149,150,150,151,151,151,151,151,152,152,152,152,152,152,153,153,153,153,153,154,154,154,154,154,154,155,155,156,156,157,157,157,158,158,158,158,159,159,160,160,161,161,161,162,162,162,163,164,164,165,165,165,165,166,166,167,167,168,168,168,168,168,168,169,169,170,170,170,170,171,171,171,172,172,173,173,173,174,174,175,175,175,175,176,176,177,177,178,178,179,179,179,179,179,179,180,180,181,181,182,182,182,183,183,184,184,184,185,185,186,186,186,187,187,188,188,189,189,190,190,191,191,191,192,192,193,193,194,194,194,195,195,195,195,196,196,197,197,197,198,198,198,199,199,199,200,200,201,201,201,202,202,203,203,204,204,204,205,205,205,206,206,206,207,207,208,208,209,209,209,210,210,211,211,211,211,211,212,212,212,213,213,213,213,213,214,214,214,215,215,216,216,217,217,217,217,218,218,219,219,219,220,220,220,221,221,222,222,223,223,224,224,224,224,224,224,225,225,225,225,226,226,227,227,228,228,229,229,229,229,229,229,230,230,231,231,232,232,233,233,234,234,234,235,235,235,235,235,236,236,236,237,237,238,238,239,239,239,240,240,241,241,241,242,242,243,243,243,243,244,244,244,245,245,246,246,247,247,247,247,247,248,248,249,249,249,250,250,251,251,251,251,251,252,252,253,253,254,254,254,255,255,256,256,257,257,257,257,257,258,258,259,259,259,260,260,261,261,262,262,263,263,263,263,264,264,264,264,264,265,265,266,266,267,267,267,267,267,268,268,269,269,269,269,269,270,270,270,270,270,271,271,272,272,273,273,273,274,274,274,275,275,275,276,276,276,276,277,277,277,277,277,278,278,278,279,279,280,280,281,281,281,281,281,282,282,282,283,283,283,284,284,284,285,285,286,286,287,287,288,288,288,289,289,290,290,291,291,291,291,291,292,292,293,293,293,294,294,294,294,295,295,295,296,296,296,296,296,296,297,297,298,298,298,299,299,299,299,299,300,300,300,301,301,301,301,301,302,302,302,302,303,303,303,304,304,305,305,305,306,306,307,307,307,308,308,308,309,309,309,309,310,310,310,310,311,311,312,312,313,313,313,313,313,314,314,314,315,315,315,315,315,316,316,316,317,317,318,318,319,319,320,320,321,321,322,322,323,323,323,323,324,324,324,324,325,325,326,326,326,326,326],"depth":[2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,1,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1],"label":["[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","oldClass","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","<GC>","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","nrow","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","sum","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,null,1,1,1,1,null,null,null,null,1],"linenum":[9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,11,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,10,10,null,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,11,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,10,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,10,10,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,null,9,9,9,9,null,null,null,null,13],"memalloc":[53.6531829833984,53.6531829833984,70.182258605957,70.182258605957,70.182258605957,96.9467468261719,96.9467468261719,111.184310913086,111.184310913086,111.184310913086,134.797706604004,134.797706604004,134.797706604004,146.276069641113,146.276069641113,146.276069641113,56.2829208374023,56.2829208374023,75.4388275146484,75.4388275146484,104.04655456543,104.04655456543,122.801368713379,122.801368713379,146.287353515625,146.287353515625,146.287353515625,47.6215133666992,47.6215133666992,47.6215133666992,77.207275390625,77.207275390625,77.207275390625,77.207275390625,95.4484176635742,95.4484176635742,123.268653869629,123.268653869629,141.638778686523,141.638778686523,46.5084381103516,46.5084381103516,64.5445327758789,64.5445327758789,64.5445327758789,92.61865234375,92.61865234375,110.263526916504,110.263526916504,110.263526916504,138.532707214355,138.532707214355,138.532707214355,146.274971008301,146.274971008301,146.274971008301,63.2428588867188,63.2428588867188,82.728157043457,82.728157043457,82.728157043457,113.034629821777,113.034629821777,132.713356018066,132.713356018066,146.289962768555,146.289962768555,146.289962768555,56.8792114257812,56.8792114257812,56.8792114257812,86.9239883422852,86.9239883422852,106.863815307617,106.863815307617,106.863815307617,106.863815307617,136.848434448242,136.848434448242,136.848434448242,136.848434448242,146.294815063477,146.294815063477,146.294815063477,62.2610855102539,62.2610855102539,81.4122543334961,81.4122543334961,81.4122543334961,108.053192138672,108.053192138672,108.053192138672,108.053192138672,125.897933959961,125.897933959961,125.897933959961,125.897933959961,125.897933959961,125.897933959961,146.304382324219,146.304382324219,146.304382324219,146.304382324219,146.304382324219,146.304382324219,49.2059783935547,49.2059783935547,78.9938049316406,78.9938049316406,78.9938049316406,78.9938049316406,78.9938049316406,98.284538269043,98.284538269043,98.284538269043,126.628784179688,126.628784179688,126.628784179688,145.192161560059,145.192161560059,145.192161560059,50.5211334228516,50.5211334228516,70.0704879760742,70.0704879760742,70.0704879760742,70.0704879760742,70.0704879760742,70.0704879760742,99.4073638916016,99.4073638916016,99.4073638916016,118.033363342285,118.033363342285,146.310699462891,146.310699462891,146.310699462891,43.8314056396484,43.8314056396484,43.8314056396484,43.8314056396484,72.8337783813477,72.8337783813477,92.9001007080078,92.9001007080078,123.806953430176,123.806953430176,142.766159057617,142.766159057617,48.4251327514648,48.4251327514648,48.4251327514648,48.4251327514648,67.0542678833008,67.0542678833008,96.5791549682617,96.5791549682617,96.5791549682617,114.485794067383,114.485794067383,142.763748168945,142.763748168945,142.763748168945,146.307350158691,146.307350158691,146.307350158691,67.7162170410156,67.7162170410156,87.5260848999023,87.5260848999023,87.5260848999023,87.5260848999023,87.5260848999023,87.5260848999023,116.252777099609,116.252777099609,116.252777099609,116.252777099609,134.747940063477,134.747940063477,146.297508239746,146.297508239746,146.297508239746,60.4414596557617,60.4414596557617,60.4414596557617,90.7456970214844,90.7456970214844,109.248435974121,109.248435974121,109.248435974121,136.998611450195,136.998611450195,146.31534576416,146.31534576416,146.31534576416,60.6954727172852,60.6954727172852,60.6954727172852,60.6954727172852,60.6954727172852,80.5070877075195,80.5070877075195,109.383262634277,109.383262634277,127.949447631836,127.949447631836,146.315948486328,146.315948486328,146.315948486328,52.3029937744141,79.1393814086914,79.1393814086914,79.1393814086914,79.1393814086914,98.2318801879883,98.2318801879883,127.486518859863,127.486518859863,146.311477661133,146.311477661133,52.3020172119141,52.3020172119141,70.7404403686523,70.7404403686523,100.137565612793,100.137565612793,118.505470275879,118.505470275879,118.505470275879,146.318626403809,146.318626403809,146.318626403809,71.1150360107422,71.1150360107422,71.1150360107422,72.834831237793,72.834831237793,92.1859512329102,92.1859512329102,122.822402954102,122.822402954102,141.844169616699,141.844169616699,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,146.302604675293,42.7311935424805,42.7311935424805,42.7311935424805,43.3215637207031,43.3215637207031,43.3215637207031,62.1542816162109,62.1542816162109,92.2653961181641,92.2653961181641,92.2653961181641,92.2653961181641,92.2653961181641,111.744789123535,111.744789123535,141.268714904785,141.268714904785,141.268714904785,141.268714904785,141.268714904785,146.319381713867,146.319381713867,146.319381713867,67.2701416015625,67.2701416015625,67.2701416015625,85.3779830932617,85.3779830932617,114.239753723145,114.239753723145,131.818466186523,131.818466186523,131.818466186523,146.316375732422,146.316375732422,146.316375732422,146.316375732422,146.316375732422,146.316375732422,56.7730407714844,56.7730407714844,56.7730407714844,84.916389465332,84.916389465332,103.024131774902,103.024131774902,130.765296936035,130.765296936035,130.765296936035,146.309089660645,146.309089660645,146.309089660645,54.4114761352539,54.4114761352539,54.4114761352539,54.4114761352539,54.4114761352539,73.044319152832,73.044319152832,73.044319152832,100.85782623291,100.85782623291,100.85782623291,100.85782623291,120.275161743164,120.275161743164,120.275161743164,146.31861114502,146.31861114502,146.31861114502,45.6231536865234,45.6231536865234,45.6231536865234,45.6231536865234,45.6231536865234,73.8975601196289,73.8975601196289,73.8975601196289,73.8975601196289,73.8975601196289,92.454719543457,92.454719543457,122.43921661377,122.43921661377,122.43921661377,142.246658325195,142.246658325195,49.1038970947266,49.1038970947266,49.1038970947266,67.7993621826172,67.7993621826172,95.2803192138672,95.2803192138672,112.472427368164,112.472427368164,112.472427368164,112.472427368164,112.472427368164,138.249794006348,138.249794006348,138.249794006348,138.249794006348,138.249794006348,138.249794006348,146.31941986084,146.31941986084,146.31941986084,59.664176940918,59.664176940918,77.640869140625,77.640869140625,77.640869140625,77.640869140625,77.640869140625,103.545547485352,103.545547485352,119.091171264648,119.091171264648,119.091171264648,146.046195983887,146.046195983887,87.009521484375,87.009521484375,87.009521484375,68.5846481323242,68.5846481323242,87.4117050170898,87.4117050170898,87.4117050170898,87.4117050170898,87.4117050170898,87.4117050170898,116.084297180176,116.084297180176,134.256866455078,134.256866455078,77.9980239868164,77.9980239868164,77.9980239868164,60.2609939575195,60.2609939575195,60.2609939575195,60.2609939575195,90.3132553100586,90.3132553100586,109.535995483398,109.535995483398,139.251235961914,139.251235961914,139.251235961914,139.251235961914,139.251235961914,146.270858764648,146.270858764648,146.270858764648,146.270858764648,146.270858764648,146.270858764648,63.8011932373047,63.8011932373047,63.8011932373047,63.8011932373047,63.8011932373047,82.1079940795898,82.1079940795898,82.1079940795898,82.1079940795898,82.1079940795898,82.1079940795898,111.753952026367,111.753952026367,131.306625366211,131.306625366211,146.263893127441,146.263893127441,146.263893127441,55.3427734375,55.3427734375,55.3427734375,55.3427734375,84.9328231811523,84.9328231811523,104.158355712891,104.158355712891,132.305480957031,132.305480957031,132.305480957031,146.279457092285,146.279457092285,146.279457092285,54.6218566894531,72.6717681884766,72.6717681884766,101.266654968262,101.266654968262,101.266654968262,101.266654968262,116.553718566895,116.553718566895,141.684364318848,141.684364318848,146.27710723877,146.27710723877,146.27710723877,146.27710723877,146.27710723877,146.27710723877,63.6774139404297,63.6774139404297,80.5437316894531,80.5437316894531,80.5437316894531,80.5437316894531,107.823829650879,107.823829650879,107.823829650879,124.815696716309,124.815696716309,146.270462036133,146.270462036133,146.270462036133,50.3660049438477,50.3660049438477,78.0533905029297,78.0533905029297,78.0533905029297,78.0533905029297,97.4017333984375,97.4017333984375,125.549499511719,125.549499511719,142.999114990234,142.999114990234,47.4106979370117,47.4106979370117,47.4106979370117,47.4106979370117,47.4106979370117,47.4106979370117,66.2346496582031,66.2346496582031,95.8148803710938,95.8148803710938,115.036315917969,115.036315917969,115.036315917969,144.62028503418,144.62028503418,92.001091003418,92.001091003418,92.001091003418,70.565788269043,70.565788269043,89.7254180908203,89.7254180908203,89.7254180908203,118.523529052734,118.523529052734,136.165702819824,136.165702819824,44.7905502319336,44.7905502319336,63.5545501708984,63.5545501708984,92.7576141357422,92.7576141357422,92.7576141357422,112.238075256348,112.238075256348,140.512657165527,140.512657165527,146.285110473633,146.285110473633,146.285110473633,66.4353561401367,66.4353561401367,66.4353561401367,66.4353561401367,85.6495132446289,85.6495132446289,114.70482635498,114.70482635498,114.70482635498,132.021781921387,132.021781921387,132.021781921387,146.257514953613,146.257514953613,146.257514953613,58.7585601806641,58.7585601806641,87.9427108764648,87.9427108764648,87.9427108764648,105.91886138916,105.91886138916,134.581405639648,134.581405639648,146.259437561035,146.259437561035,146.259437561035,61.2579040527344,61.2579040527344,61.2579040527344,80.1475830078125,80.1475830078125,80.1475830078125,107.956901550293,107.956901550293,126.255561828613,126.255561828613,146.261199951172,146.261199951172,146.261199951172,54.3045959472656,54.3045959472656,82.1760482788086,82.1760482788086,82.1760482788086,82.1760482788086,82.1760482788086,100.938774108887,100.938774108887,100.938774108887,131.04273223877,131.04273223877,131.04273223877,131.04273223877,131.04273223877,146.258773803711,146.258773803711,146.258773803711,55.8503570556641,55.8503570556641,74.8056793212891,74.8056793212891,101.363441467285,101.363441467285,101.363441467285,101.363441467285,119.464004516602,119.464004516602,146.28825378418,146.28825378418,146.28825378418,47.9808959960938,47.9808959960938,47.9808959960938,77.8245620727539,77.8245620727539,96.322135925293,96.322135925293,126.620414733887,126.620414733887,146.22770690918,146.22770690918,146.22770690918,146.22770690918,146.22770690918,146.22770690918,54.5382843017578,54.5382843017578,54.5382843017578,54.5382843017578,73.8214111328125,73.8214111328125,103.598930358887,103.598930358887,123.273384094238,123.273384094238,146.296867370605,146.296867370605,146.296867370605,146.296867370605,146.296867370605,146.296867370605,52.8345336914062,52.8345336914062,83.5288543701172,83.5288543701172,103.861068725586,103.861068725586,134.359130859375,134.359130859375,146.292724609375,146.292724609375,146.292724609375,62.4117050170898,62.4117050170898,62.4117050170898,62.4117050170898,62.4117050170898,82.6115951538086,82.6115951538086,82.6115951538086,113.37181854248,113.37181854248,132.326805114746,132.326805114746,146.296394348145,146.296394348145,146.296394348145,59.7861404418945,59.7861404418945,86.4145584106445,86.4145584106445,86.4145584106445,105.368644714355,105.368644714355,133.901000976562,133.901000976562,133.901000976562,133.901000976562,146.297691345215,146.297691345215,146.297691345215,62.082275390625,62.082275390625,82.2171783447266,82.2171783447266,112.652473449707,112.652473449707,112.652473449707,112.652473449707,112.652473449707,131.08332824707,131.08332824707,146.296684265137,146.296684265137,146.296684265137,59.0025329589844,59.0025329589844,89.6249847412109,89.6249847412109,89.6249847412109,89.6249847412109,89.6249847412109,110.082832336426,110.082832336426,141.096969604492,141.096969604492,146.277442932129,146.277442932129,146.277442932129,69.2983551025391,69.2983551025391,88.2494735717773,88.2494735717773,118.936325073242,118.936325073242,118.936325073242,118.936325073242,118.936325073242,138.542785644531,138.542785644531,47.2010803222656,47.2010803222656,47.2010803222656,65.8224716186523,65.8224716186523,95.002799987793,95.002799987793,115.394104003906,115.394104003906,146.280372619629,146.280372619629,146.280372619629,146.280372619629,45.5628128051758,45.5628128051758,45.5628128051758,45.5628128051758,45.5628128051758,76.0568008422852,76.0568008422852,96.1866149902344,96.1866149902344,126.024833679199,126.024833679199,126.024833679199,126.024833679199,126.024833679199,145.500274658203,145.500274658203,55.0057983398438,55.0057983398438,55.0057983398438,55.0057983398438,55.0057983398438,74.678108215332,74.678108215332,74.678108215332,74.678108215332,74.678108215332,105.298469543457,105.298469543457,125.756477355957,125.756477355957,146.278877258301,146.278877258301,146.278877258301,54.9418640136719,54.9418640136719,54.9418640136719,84.9087524414062,84.9087524414062,84.9087524414062,105.03776550293,105.03776550293,105.03776550293,105.03776550293,135.593734741211,135.593734741211,135.593734741211,135.593734741211,135.593734741211,146.281768798828,146.281768798828,146.281768798828,61.3684234619141,61.3684234619141,81.1705474853516,81.1705474853516,111.464981079102,111.464981079102,111.464981079102,111.464981079102,111.464981079102,131.726036071777,131.726036071777,131.726036071777,146.282012939453,146.282012939453,146.282012939453,60.5813827514648,60.5813827514648,60.5813827514648,91.4655609130859,91.4655609130859,111.595687866211,111.595687866211,140.641998291016,140.641998291016,146.280555725098,146.280555725098,146.280555725098,67.9885559082031,67.9885559082031,88.0502777099609,88.0502777099609,118.536262512207,118.536262512207,118.536262512207,118.536262512207,118.536262512207,137.286415100098,137.286415100098,43.862907409668,43.862907409668,43.862907409668,60.9091644287109,60.9091644287109,60.9091644287109,60.9091644287109,88.4451065063477,88.4451065063477,88.4451065063477,106.08081817627,106.08081817627,106.08081817627,106.08081817627,106.08081817627,106.08081817627,134.993850708008,134.993850708008,146.270248413086,146.270248413086,146.270248413086,61.9593811035156,61.9593811035156,61.9593811035156,61.9593811035156,61.9593811035156,82.0212631225586,82.0212631225586,82.0212631225586,110.606452941895,110.606452941895,110.606452941895,110.606452941895,110.606452941895,130.73348236084,130.73348236084,130.73348236084,130.73348236084,146.271385192871,146.271385192871,146.271385192871,58.2223968505859,58.2223968505859,88.3151168823242,88.3151168823242,88.3151168823242,108.180000305176,108.180000305176,138.601142883301,138.601142883301,138.601142883301,146.271339416504,146.271339416504,146.271339416504,68.1225814819336,68.1225814819336,68.1225814819336,68.1225814819336,88.4462966918945,88.4462966918945,88.4462966918945,88.4462966918945,119.062515258789,119.062515258789,139.51725769043,139.51725769043,50.0284729003906,50.0284729003906,50.0284729003906,50.0284729003906,50.0284729003906,69.434455871582,69.434455871582,69.434455871582,96.9039764404297,96.9039764404297,96.9039764404297,96.9039764404297,96.9039764404297,114.998191833496,114.998191833496,114.998191833496,145.352920532227,145.352920532227,43.4528121948242,43.4528121948242,73.8069686889648,73.8069686889648,94.3927688598633,94.3927688598633,125.664985656738,125.664985656738,146.119812011719,146.119812011719,54.2703857421875,54.2703857421875,54.2703857421875,54.2703857421875,74.5940780639648,74.5940780639648,74.5940780639648,74.5940780639648,105.931785583496,105.931785583496,112.58145904541,112.58145904541,112.58145904541,112.58145904541,112.58145904541],"meminc":[0,0,16.5290756225586,0,0,26.7644882202148,0,14.2375640869141,0,0,23.613395690918,0,0,11.4783630371094,0,0,-89.9931488037109,0,19.1559066772461,0,28.6077270507812,0,18.7548141479492,0,23.4859848022461,0,0,-98.6658401489258,0,0,29.5857620239258,0,0,0,18.2411422729492,0,27.8202362060547,0,18.3701248168945,0,-95.1303405761719,0,18.0360946655273,0,0,28.0741195678711,0,17.6448745727539,0,0,28.2691802978516,0,0,7.74226379394531,0,0,-83.032112121582,0,19.4852981567383,0,0,30.3064727783203,0,19.6787261962891,0,13.5766067504883,0,0,-89.4107513427734,0,0,30.0447769165039,0,19.939826965332,0,0,0,29.984619140625,0,0,0,9.44638061523438,0,0,-84.0337295532227,0,19.1511688232422,0,0,26.6409378051758,0,0,0,17.8447418212891,0,0,0,0,0,20.4064483642578,0,0,0,0,0,-97.0984039306641,0,29.7878265380859,0,0,0,0,19.2907333374023,0,0,28.3442459106445,0,0,18.5633773803711,0,0,-94.671028137207,0,19.5493545532227,0,0,0,0,0,29.3368759155273,0,0,18.6259994506836,0,28.2773361206055,0,0,-102.479293823242,0,0,0,29.0023727416992,0,20.0663223266602,0,30.906852722168,0,18.9592056274414,0,-94.3410263061523,0,0,0,18.6291351318359,0,29.5248870849609,0,0,17.9066390991211,0,28.2779541015625,0,0,3.54360198974609,0,0,-78.5911331176758,0,19.8098678588867,0,0,0,0,0,28.726692199707,0,0,0,18.4951629638672,0,11.5495681762695,0,0,-85.8560485839844,0,0,30.3042373657227,0,18.5027389526367,0,0,27.7501754760742,0,9.31673431396484,0,0,-85.619873046875,0,0,0,0,19.8116149902344,0,28.8761749267578,0,18.5661849975586,0,18.3665008544922,0,0,-94.0129547119141,26.8363876342773,0,0,0,19.0924987792969,0,29.254638671875,0,18.8249588012695,0,-94.0094604492188,0,18.4384231567383,0,29.3971252441406,0,18.3679046630859,0,0,27.8131561279297,0,0,-75.2035903930664,0,0,1.71979522705078,0,19.3511199951172,0,30.6364517211914,0,19.0217666625977,0,4.45843505859375,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,0.590370178222656,0,0,18.8327178955078,0,30.1111145019531,0,0,0,0,19.4793930053711,0,29.52392578125,0,0,0,0,5.05066680908203,0,0,-79.0492401123047,0,0,18.1078414916992,0,28.8617706298828,0,17.5787124633789,0,0,14.4979095458984,0,0,0,0,0,-89.5433349609375,0,0,28.1433486938477,0,18.1077423095703,0,27.7411651611328,0,0,15.5437927246094,0,0,-91.8976135253906,0,0,0,0,18.6328430175781,0,0,27.8135070800781,0,0,0,19.4173355102539,0,0,26.0434494018555,0,0,-100.695457458496,0,0,0,0,28.2744064331055,0,0,0,0,18.5571594238281,0,29.9844970703125,0,0,19.8074417114258,0,-93.1427612304688,0,0,18.6954650878906,0,27.48095703125,0,17.1921081542969,0,0,0,0,25.7773666381836,0,0,0,0,0,8.06962585449219,0,0,-86.6552429199219,0,17.976692199707,0,0,0,0,25.9046783447266,0,15.5456237792969,0,0,26.9550247192383,0,-59.0366744995117,0,0,-18.4248733520508,0,18.8270568847656,0,0,0,0,0,28.6725921630859,0,18.1725692749023,0,-56.2588424682617,0,0,-17.7370300292969,0,0,0,30.0522613525391,0,19.2227401733398,0,29.7152404785156,0,0,0,0,7.01962280273438,0,0,0,0,0,-82.4696655273438,0,0,0,0,18.3068008422852,0,0,0,0,0,29.6459579467773,0,19.5526733398438,0,14.9572677612305,0,0,-90.9211196899414,0,0,0,29.5900497436523,0,19.2255325317383,0,28.1471252441406,0,0,13.9739761352539,0,0,-91.657600402832,18.0499114990234,0,28.5948867797852,0,0,0,15.2870635986328,0,25.1306457519531,0,4.59274291992188,0,0,0,0,0,-82.5996932983398,0,16.8663177490234,0,0,0,27.2800979614258,0,0,16.9918670654297,0,21.4547653198242,0,0,-95.9044570922852,0,27.687385559082,0,0,0,19.3483428955078,0,28.1477661132812,0,17.4496154785156,0,-95.5884170532227,0,0,0,0,0,18.8239517211914,0,29.5802307128906,0,19.221435546875,0,0,29.5839691162109,0,-52.6191940307617,0,0,-21.435302734375,0,19.1596298217773,0,0,28.7981109619141,0,17.6421737670898,0,-91.3751525878906,0,18.7639999389648,0,29.2030639648438,0,0,19.4804611206055,0,28.2745819091797,0,5.77245330810547,0,0,-79.8497543334961,0,0,0,19.2141571044922,0,29.0553131103516,0,0,17.3169555664062,0,0,14.2357330322266,0,0,-87.4989547729492,0,29.1841506958008,0,0,17.9761505126953,0,28.6625442504883,0,11.6780319213867,0,0,-85.0015335083008,0,0,18.8896789550781,0,0,27.8093185424805,0,18.2986602783203,0,20.0056381225586,0,0,-91.9566040039062,0,27.871452331543,0,0,0,0,18.7627258300781,0,0,30.1039581298828,0,0,0,0,15.2160415649414,0,0,-90.4084167480469,0,18.955322265625,0,26.5577621459961,0,0,0,18.1005630493164,0,26.8242492675781,0,0,-98.3073577880859,0,0,29.8436660766602,0,18.4975738525391,0,30.2982788085938,0,19.607292175293,0,0,0,0,0,-91.6894226074219,0,0,0,19.2831268310547,0,29.7775192260742,0,19.6744537353516,0,23.0234832763672,0,0,0,0,0,-93.4623336791992,0,30.6943206787109,0,20.3322143554688,0,30.4980621337891,0,11.93359375,0,0,-83.8810195922852,0,0,0,0,20.1998901367188,0,0,30.7602233886719,0,18.9549865722656,0,13.9695892333984,0,0,-86.51025390625,0,26.62841796875,0,0,18.9540863037109,0,28.532356262207,0,0,0,12.3966903686523,0,0,-84.2154159545898,0,20.1349029541016,0,30.4352951049805,0,0,0,0,18.4308547973633,0,15.2133560180664,0,0,-87.2941513061523,0,30.6224517822266,0,0,0,0,20.4578475952148,0,31.0141372680664,0,5.18047332763672,0,0,-76.9790878295898,0,18.9511184692383,0,30.6868515014648,0,0,0,0,19.6064605712891,0,-91.3417053222656,0,0,18.6213912963867,0,29.1803283691406,0,20.3913040161133,0,30.8862686157227,0,0,0,-100.717559814453,0,0,0,0,30.4939880371094,0,20.1298141479492,0,29.8382186889648,0,0,0,0,19.4754409790039,0,-90.4944763183594,0,0,0,0,19.6723098754883,0,0,0,0,30.620361328125,0,20.4580078125,0,20.5223999023438,0,0,-91.3370132446289,0,0,29.9668884277344,0,0,20.1290130615234,0,0,0,30.5559692382812,0,0,0,0,10.6880340576172,0,0,-84.9133453369141,0,19.8021240234375,0,30.29443359375,0,0,0,0,20.2610549926758,0,0,14.5559768676758,0,0,-85.7006301879883,0,0,30.8841781616211,0,20.130126953125,0,29.0463104248047,0,5.63855743408203,0,0,-78.2919998168945,0,20.0617218017578,0,30.4859848022461,0,0,0,0,18.7501525878906,0,-93.4235076904297,0,0,17.046257019043,0,0,0,27.5359420776367,0,0,17.6357116699219,0,0,0,0,0,28.9130325317383,0,11.2763977050781,0,0,-84.3108673095703,0,0,0,0,20.061882019043,0,0,28.5851898193359,0,0,0,0,20.1270294189453,0,0,0,15.5379028320312,0,0,-88.0489883422852,0,30.0927200317383,0,0,19.8648834228516,0,30.421142578125,0,0,7.67019653320312,0,0,-78.1487579345703,0,0,0,20.3237152099609,0,0,0,30.6162185668945,0,20.4547424316406,0,-89.4887847900391,0,0,0,0,19.4059829711914,0,0,27.4695205688477,0,0,0,0,18.0942153930664,0,0,30.3547286987305,0,-101.900108337402,0,30.3541564941406,0,20.5858001708984,0,31.272216796875,0,20.4548263549805,0,-91.8494262695312,0,0,0,20.3236923217773,0,0,0,31.3377075195312,0,6.64967346191406,0,0,0,0],"filename":["<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpobjpMZ/file358332468438.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    790.627    798.7445    821.1073    807.4395
#>    compute_pi0(m * 10)   7915.051   7934.9105   8394.4966   7980.9320
#>   compute_pi0(m * 100)  79192.742  79346.0745  79746.8514  79548.0010
#>         compute_pi1(m)    183.657    336.1720    336.0099    351.2645
#>    compute_pi1(m * 10)   1355.136   1453.6235   2049.9821   1589.6830
#>   compute_pi1(m * 100)  15230.204  18105.2555  26396.9746  27043.5110
#>  compute_pi1(m * 1000) 332773.265 505074.0720 516269.8900 527418.9740
#>           uq        max neval
#>     836.6275    935.313    20
#>    8069.6995  14985.615    20
#>   80093.3310  81305.860    20
#>     381.2210    399.406    20
#>    1705.7070  11008.275    20
#>   33284.4215  34974.371    20
#>  540998.1880 677738.881    20
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
#>   memory_copy1(n) 4256.18431 3885.71028 646.673313 3945.79758 3743.21091
#>   memory_copy2(n)   74.28673   65.75500  12.108808   65.94659   64.84231
#>  pre_allocate1(n)   15.97360   14.32999   3.780696   13.86242   12.99238
#>  pre_allocate2(n)  159.70896  140.64369  23.880498  139.86700  140.01114
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  94.119057    10
#>   2.966718    10
#>   2.075032    10
#>   4.129326    10
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
#>  f1(df) 256.4377 250.9952 82.42277 253.4138 67.78821 30.12825     5
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
