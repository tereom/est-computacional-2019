
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
#>    id           a         b        c        d
#> 1   1 -0.74190417 4.1790398 3.392596 4.119713
#> 2   2 -0.96905228 3.8326874 4.592385 2.292287
#> 3   3 -0.06649263 2.1984412 1.162187 5.784262
#> 4   4 -1.48080217 2.6830531 1.304398 3.441498
#> 5   5 -1.50799562 2.1794076 3.874335 5.306212
#> 6   6 -2.47485848 0.3922072 2.918158 4.258043
#> 7   7  0.31181227 2.1365769 1.647843 5.141047
#> 8   8  0.16570685 2.4418825 3.555365 1.579375
#> 9   9 -0.35032680 0.5181808 4.596311 3.512193
#> 10 10 -0.28666756 0.9340112 2.894730 5.492389
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.7400581
mean(df$b)
#> [1] 2.149549
mean(df$c)
#> [1] 2.993831
mean(df$d)
#> [1] 4.092702
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.7400581  2.1495488  2.9938308  4.0927019
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
#> [1] -0.7400581  2.1495488  2.9938308  4.0927019
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
#> [1]  5.5000000 -0.7400581  2.1495488  2.9938308  4.0927019
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
#> [1]  5.5000000 -0.5461155  2.1889244  3.1553772  4.1888777
col_describe(df, mean)
#> [1]  5.5000000 -0.7400581  2.1495488  2.9938308  4.0927019
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
#>  5.5000000 -0.7400581  2.1495488  2.9938308  4.0927019
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
#>   3.823   0.148   3.972
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.017   0.004   0.649
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
#>  12.878   0.704   9.893
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
#>   0.118   0.000   0.118
plyr_st
#>    user  system elapsed 
#>   4.054   0.008   4.061
est_l_st
#>    user  system elapsed 
#>  64.058   1.756  65.819
est_r_st
#>    user  system elapsed 
#>   0.397   0.004   0.401
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

<!--html_preserve--><div id="htmlwidget-8ec24fd4e2d5d13023ff" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-8ec24fd4e2d5d13023ff">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,3,3,3,4,4,5,5,5,6,6,7,7,8,8,8,8,8,8,9,9,10,10,10,11,11,11,12,12,12,12,12,13,13,13,13,13,14,14,15,15,16,16,16,16,17,17,17,17,18,18,19,19,19,20,20,21,21,22,22,23,23,23,23,23,24,24,24,24,24,25,25,26,26,26,27,27,28,28,28,29,29,29,30,30,30,30,30,31,31,31,31,32,32,32,33,33,33,33,34,34,34,35,35,35,35,36,36,36,37,37,37,38,38,39,39,40,40,40,41,41,42,42,42,43,43,44,44,44,45,45,46,46,47,47,48,48,49,49,49,50,50,51,51,51,52,52,52,52,52,53,53,54,54,55,55,55,56,56,56,57,57,58,58,59,59,60,60,60,60,60,61,61,61,61,61,61,62,62,62,62,62,63,63,63,64,64,64,65,65,65,66,66,67,67,68,68,68,68,68,69,69,70,70,70,70,70,71,71,72,72,73,73,73,73,73,74,74,74,75,75,76,76,77,77,77,78,78,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,91,91,92,92,93,93,94,94,94,94,94,94,95,95,96,96,96,96,97,97,98,98,98,99,99,99,99,99,100,100,101,101,101,102,102,102,102,102,103,103,104,104,105,105,105,105,106,106,107,107,108,108,108,109,109,110,110,110,111,111,111,112,112,113,113,113,113,113,114,114,115,115,115,115,115,115,116,116,116,116,116,117,117,117,118,118,118,118,118,119,120,120,120,121,121,121,121,121,121,122,122,122,122,122,123,123,123,123,123,124,124,124,125,125,126,126,126,127,127,127,127,128,128,128,129,129,129,130,130,130,130,130,131,131,131,131,131,132,132,132,132,132,132,133,133,133,134,134,135,135,135,136,136,136,137,137,137,137,138,138,139,139,140,140,140,141,141,141,141,141,142,142,142,143,143,144,144,145,145,146,146,146,146,147,147,147,147,147,148,148,149,149,150,150,150,150,150,151,151,152,152,152,153,153,154,154,155,155,155,155,155,155,156,156,156,156,156,157,157,158,158,159,159,160,160,161,161,162,162,163,163,164,164,164,165,165,165,165,166,166,166,166,167,167,168,168,168,168,168,169,169,170,170,171,171,171,172,172,172,173,173,174,174,174,174,174,175,175,176,176,176,177,177,177,178,178,179,179,180,180,180,181,181,181,182,182,182,183,183,184,184,184,184,184,185,185,185,185,185,186,186,186,187,187,188,188,189,189,190,190,190,191,191,191,191,191,191,192,192,192,192,192,193,193,194,194,194,194,194,195,195,195,196,196,196,197,197,197,197,197,198,198,199,199,199,199,199,200,200,200,200,200,201,201,202,202,202,203,203,204,204,204,205,205,205,205,205,206,206,207,207,208,208,209,209,210,210,211,211,212,212,212,212,212,212,213,213,213,213,213,214,214,215,215,216,216,216,216,216,217,217,217,218,218,218,219,219,219,220,220,220,220,220,221,221,221,222,222,222,222,222,223,223,224,224,224,224,224,225,225,225,225,226,226,226,227,227,227,228,228,229,229,230,230,231,231,232,232,233,233,233,233,234,234,234,235,235,236,236,237,237,238,238,239,239,239,240,240,241,241,241,241,242,242,243,243,243,244,244,244,245,245,246,246,247,247,247,247,247,248,249,249,250,250,250,251,251,251,252,252,252,253,253,253,254,254,254,254,255,255,256,256,256,256,256,256,257,257,258,258,259,259,259,259,259,260,260,260,261,261,261,262,262,263,263,263,263,263,264,264,265,265,266,266,266,266,267,267,267,268,268,268,268,268,268,269,269,269,269,270,270,270,271,271,272,272,273,273,274,274,274,275,275,276,276,276,277,277,278,278,279,279,280,280,281,281,281,281,281,282,282,282,282,282],"depth":[2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,4,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","nrow","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","nrow","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","$","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","n[i] <- nrow(sub_Batting)","nrow","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sum","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,null,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1],"linenum":[9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,11,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,11,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,null,11,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,11,11,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,10,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,13],"memalloc":[64.1241302490234,64.1241302490234,84.3900833129883,84.3900833129883,109.846229553223,109.846229553223,109.846229553223,109.846229553223,109.846229553223,126.572631835938,126.572631835938,146.315650939941,146.315650939941,146.315650939941,55.6660079956055,55.6660079956055,87.0920257568359,87.0920257568359,106.971450805664,106.971450805664,106.971450805664,106.971450805664,106.971450805664,106.971450805664,136.226318359375,136.226318359375,146.326934814453,146.326934814453,146.326934814453,70.0992202758789,70.0992202758789,70.0992202758789,90.8294143676758,90.8294143676758,90.8294143676758,90.8294143676758,90.8294143676758,120.552139282227,120.552139282227,120.552139282227,120.552139282227,120.552139282227,140.30152130127,140.30152130127,54.0238494873047,54.0238494873047,74.2935180664062,74.2935180664062,74.2935180664062,74.2935180664062,105.316902160645,105.316902160645,105.316902160645,105.316902160645,124.798179626465,124.798179626465,146.314552307129,146.314552307129,146.314552307129,58.0359954833984,58.0359954833984,89.7196655273438,89.7196655273438,110.448989868164,110.448989868164,141.27880859375,141.27880859375,141.27880859375,141.27880859375,141.27880859375,44.650032043457,44.650032043457,44.650032043457,44.650032043457,44.650032043457,75.5483779907227,75.5483779907227,96.2783355712891,96.2783355712891,96.2783355712891,127.966217041016,127.966217041016,146.334396362305,146.334396362305,146.334396362305,62.6289443969727,62.6289443969727,62.6289443969727,83.3540191650391,83.3540191650391,83.3540191650391,83.3540191650391,83.3540191650391,113.470527648926,113.470527648926,113.470527648926,113.470527648926,133.481826782227,133.481826782227,133.481826782227,46.6878356933594,46.6878356933594,46.6878356933594,46.6878356933594,66.8944396972656,66.8944396972656,66.8944396972656,97.8649444580078,97.8649444580078,97.8649444580078,97.8649444580078,117.284233093262,117.284233093262,117.284233093262,146.282135009766,146.282135009766,146.282135009766,51.2167205810547,51.2167205810547,82.3167037963867,82.3167037963867,102.726516723633,102.726516723633,102.726516723633,132.577507019043,132.577507019043,146.284698486328,146.284698486328,146.284698486328,66.1179351806641,66.1179351806641,86.6445007324219,86.6445007324219,86.6445007324219,116.62922668457,116.62922668457,136.506683349609,136.506683349609,48.9905319213867,48.9905319213867,68.5377044677734,68.5377044677734,99.9654541015625,99.9654541015625,99.9654541015625,119.513984680176,119.513984680176,146.282051086426,146.282051086426,146.282051086426,53.7810668945312,53.7810668945312,53.7810668945312,53.7810668945312,53.7810668945312,85.5331726074219,85.5331726074219,106.387969970703,106.387969970703,136.558380126953,136.558380126953,136.558380126953,146.337692260742,146.337692260742,146.337692260742,71.4402923583984,71.4402923583984,92.8184661865234,92.8184661865234,123.195320129395,123.195320129395,142.942321777344,142.942321777344,142.942321777344,142.942321777344,142.942321777344,56.9312133789062,56.9312133789062,56.9312133789062,56.9312133789062,56.9312133789062,56.9312133789062,76.7431793212891,76.7431793212891,76.7431793212891,76.7431793212891,76.7431793212891,106.403366088867,106.403366088867,106.403366088867,125.300880432129,125.300880432129,125.300880432129,146.290321350098,146.290321350098,146.290321350098,60.0871353149414,60.0871353149414,91.8419570922852,91.8419570922852,113.159927368164,113.159927368164,113.159927368164,113.159927368164,113.159927368164,145.301483154297,145.301483154297,49.457633972168,49.457633972168,49.457633972168,49.457633972168,49.457633972168,80.4281234741211,80.4281234741211,100.767639160156,100.767639160156,131.138404846191,131.138404846191,131.138404846191,131.138404846191,131.138404846191,146.292938232422,146.292938232422,146.292938232422,65.8535232543945,65.8535232543945,87.3038330078125,87.3038330078125,119.123413085938,119.123413085938,119.123413085938,138.472343444824,138.472343444824,138.472343444824,138.472343444824,138.472343444824,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,146.277191162109,44.0165100097656,44.0165100097656,44.0165100097656,64.5545501708984,64.5545501708984,95.7137451171875,95.7137451171875,115.719032287598,115.719032287598,146.292861938477,146.292861938477,51.1697311401367,51.1697311401367,51.1697311401367,51.1697311401367,51.1697311401367,51.1697311401367,82.9254684448242,82.9254684448242,103.387222290039,103.387222290039,103.387222290039,103.387222290039,134.022529602051,134.022529602051,146.289398193359,146.289398193359,146.289398193359,68.8169174194336,68.8169174194336,68.8169174194336,68.8169174194336,68.8169174194336,89.6806335449219,89.6806335449219,122.018020629883,122.018020629883,122.018020629883,142.807464599609,142.807464599609,142.807464599609,142.807464599609,142.807464599609,58.7181701660156,58.7181701660156,79.7728271484375,79.7728271484375,111.065422058105,111.065422058105,111.065422058105,111.065422058105,132.254432678223,132.254432678223,49.0746765136719,49.0746765136719,69.8062133789062,69.8062133789062,69.8062133789062,101.873901367188,101.873901367188,123.331237792969,123.331237792969,123.331237792969,146.287780761719,146.287780761719,146.287780761719,60.6897583007812,60.6897583007812,92.8293304443359,92.8293304443359,92.8293304443359,92.8293304443359,92.8293304443359,114.545448303223,114.545448303223,146.294677734375,146.294677734375,146.294677734375,146.294677734375,146.294677734375,146.294677734375,52.6842269897461,52.6842269897461,52.6842269897461,52.6842269897461,52.6842269897461,84.1071166992188,84.1071166992188,84.1071166992188,105.421867370605,105.421867370605,105.421867370605,105.421867370605,105.421867370605,135.790786743164,146.282775878906,146.282775878906,146.282775878906,72.6904983520508,72.6904983520508,72.6904983520508,72.6904983520508,72.6904983520508,72.6904983520508,92.9640502929688,92.9640502929688,92.9640502929688,92.9640502929688,92.9640502929688,124.785942077637,124.785942077637,124.785942077637,124.785942077637,124.785942077637,145.975921630859,145.975921630859,145.975921630859,61.8087692260742,61.8087692260742,82.5445022583008,82.5445022583008,82.5445022583008,114.363403320312,114.363403320312,114.363403320312,114.363403320312,135.878860473633,135.878860473633,135.878860473633,52.0348205566406,52.0348205566406,52.0348205566406,72.8304824829102,72.8304824829102,72.8304824829102,72.8304824829102,72.8304824829102,104.187469482422,104.187469482422,104.187469482422,104.187469482422,104.187469482422,124.127571105957,124.127571105957,124.127571105957,124.127571105957,124.127571105957,124.127571105957,146.30396270752,146.30396270752,146.30396270752,60.6944122314453,60.6944122314453,92.4532089233398,92.4532089233398,92.4532089233398,112.987930297852,112.987930297852,112.987930297852,143.170394897461,143.170394897461,143.170394897461,143.170394897461,49.2815551757812,49.2815551757812,80.4495315551758,80.4495315551758,101.436294555664,101.436294555664,101.436294555664,133.190727233887,133.190727233887,133.190727233887,133.190727233887,133.190727233887,146.313842773438,146.313842773438,146.313842773438,69.4897613525391,69.4897613525391,89.7651519775391,89.7651519775391,121.703086853027,121.703086853027,142.110824584961,142.110824584961,142.110824584961,142.110824584961,58.5394058227539,58.5394058227539,58.5394058227539,58.5394058227539,58.5394058227539,79.6660614013672,79.6660614013672,109.97151184082,109.97151184082,130.902374267578,130.902374267578,130.902374267578,130.902374267578,130.902374267578,48.1040115356445,48.1040115356445,68.8959503173828,68.8959503173828,68.8959503173828,100.182304382324,100.182304382324,121.438018798828,121.438018798828,146.298484802246,146.298484802246,146.298484802246,146.298484802246,146.298484802246,146.298484802246,59.4519500732422,59.4519500732422,59.4519500732422,59.4519500732422,59.4519500732422,91.206428527832,91.206428527832,112.392990112305,112.392990112305,143.945182800293,143.945182800293,49.3538360595703,49.3538360595703,80.3288192749023,80.3288192749023,101.323066711426,101.323066711426,132.090576171875,132.090576171875,146.322624206543,146.322624206543,146.322624206543,69.8185729980469,69.8185729980469,69.8185729980469,69.8185729980469,90.5421371459961,90.5421371459961,90.5421371459961,90.5421371459961,121.958511352539,121.958511352539,142.75520324707,142.75520324707,142.75520324707,142.75520324707,142.75520324707,59.7821960449219,59.7821960449219,80.702751159668,80.702751159668,112.582748413086,112.582748413086,112.582748413086,133.047348022461,133.047348022461,133.047348022461,49.8846282958984,49.8846282958984,70.4155960083008,70.4155960083008,70.4155960083008,70.4155960083008,70.4155960083008,101.83226776123,101.83226776123,122.098258972168,122.098258972168,122.098258972168,146.301818847656,146.301818847656,146.301818847656,59.1327285766602,59.1327285766602,90.6795501708984,90.6795501708984,111.212219238281,111.212219238281,111.212219238281,141.11939239502,141.11939239502,141.11939239502,45.4603576660156,45.4603576660156,45.4603576660156,76.7457580566406,76.7457580566406,97.6651992797852,97.6651992797852,97.6651992797852,97.6651992797852,97.6651992797852,129.208770751953,129.208770751953,129.208770751953,129.208770751953,129.208770751953,146.327056884766,146.327056884766,146.327056884766,63.6292419433594,63.6292419433594,83.1121520996094,83.1121520996094,114.394584655762,114.394584655762,135.511596679688,135.511596679688,135.511596679688,50.9718017578125,50.9718017578125,50.9718017578125,50.9718017578125,50.9718017578125,50.9718017578125,71.7639389038086,71.7639389038086,71.7639389038086,71.7639389038086,71.7639389038086,103.507400512695,103.507400512695,124.231819152832,124.231819152832,124.231819152832,124.231819152832,124.231819152832,146.337135314941,146.337135314941,146.337135314941,61.0060424804688,61.0060424804688,61.0060424804688,92.6858520507812,92.6858520507812,92.6858520507812,92.6858520507812,92.6858520507812,114.394371032715,114.394371032715,144.759422302246,144.759422302246,144.759422302246,144.759422302246,144.759422302246,49.990104675293,49.990104675293,49.990104675293,49.990104675293,49.990104675293,81.4704055786133,81.4704055786133,102.524253845215,102.524253845215,102.524253845215,134.202270507812,134.202270507812,146.335372924805,146.335372924805,146.335372924805,70.3884658813477,70.3884658813477,70.3884658813477,70.3884658813477,70.3884658813477,91.3080749511719,91.3080749511719,122.330001831055,122.330001831055,142.271202087402,142.271202087402,58.1877746582031,58.1877746582031,79.3064651489258,79.3064651489258,111.577117919922,111.577117919922,132.370590209961,132.370590209961,132.370590209961,132.370590209961,132.370590209961,132.370590209961,48.2225799560547,48.2225799560547,48.2225799560547,48.2225799560547,48.2225799560547,69.1396179199219,69.1396179199219,100.810546875,100.810546875,122.187782287598,122.187782287598,122.187782287598,122.187782287598,122.187782287598,146.316604614258,146.316604614258,146.316604614258,59.8318481445312,59.8318481445312,59.8318481445312,91.3065414428711,91.3065414428711,91.3065414428711,112.878204345703,112.878204345703,112.878204345703,112.878204345703,112.878204345703,144.812889099121,144.812889099121,144.812889099121,49.993278503418,49.993278503418,49.993278503418,49.993278503418,49.993278503418,80.8114700317383,80.8114700317383,101.598007202148,101.598007202148,101.598007202148,101.598007202148,101.598007202148,133.073013305664,133.073013305664,133.073013305664,133.073013305664,146.318725585938,146.318725585938,146.318725585938,69.8005447387695,69.8005447387695,69.8005447387695,90.7178649902344,90.7178649902344,122.850532531738,122.850532531738,143.899963378906,143.899963378906,60.2909622192383,60.2909622192383,81.4706649780273,81.4706649780273,113.664978027344,113.664978027344,113.664978027344,113.664978027344,135.105972290039,135.105972290039,135.105972290039,51.6362457275391,51.6362457275391,72.684440612793,72.684440612793,104.814041137695,104.814041137695,126.057861328125,126.057861328125,103.514511108398,103.514511108398,103.514511108398,63.3740463256836,63.3740463256836,95.2419128417969,95.2419128417969,95.2419128417969,95.2419128417969,116.290481567383,116.290481567383,146.320663452148,146.320663452148,146.320663452148,53.670036315918,53.670036315918,53.670036315918,85.2754364013672,85.2754364013672,106.782241821289,106.782241821289,138.976638793945,138.976638793945,138.976638793945,138.976638793945,138.976638793945,45.4741592407227,73.403434753418,73.403434753418,94.3175582885742,94.3175582885742,94.3175582885742,125.720558166504,125.720558166504,125.720558166504,146.241897583008,146.241897583008,146.241897583008,62.6519241333008,62.6519241333008,62.6519241333008,83.4349670410156,83.4349670410156,83.4349670410156,83.4349670410156,115.100540161133,115.100540161133,136.080863952637,136.080863952637,136.080863952637,136.080863952637,136.080863952637,136.080863952637,52.2934799194336,52.2934799194336,73.4048309326172,73.4048309326172,105.202507019043,105.202507019043,105.202507019043,105.202507019043,105.202507019043,125.461441040039,125.461441040039,125.461441040039,146.309745788574,146.309745788574,146.309745788574,63.1121826171875,63.1121826171875,92.8767700195312,92.8767700195312,92.8767700195312,92.8767700195312,92.8767700195312,114.315330505371,114.315330505371,144.408447265625,144.408447265625,50.7870178222656,50.7870178222656,50.7870178222656,50.7870178222656,82.9116592407227,82.9116592407227,82.9116592407227,104.611740112305,104.611740112305,104.611740112305,104.611740112305,104.611740112305,104.611740112305,136.342613220215,136.342613220215,136.342613220215,136.342613220215,141.203117370605,141.203117370605,141.203117370605,74.9790802001953,74.9790802001953,95.2372131347656,95.2372131347656,127.493041992188,127.493041992188,146.308891296387,146.308891296387,146.308891296387,64.0120162963867,64.0120162963867,84.8604583740234,84.8604583740234,84.8604583740234,115.345741271973,115.345741271973,136.849571228027,136.849571228027,52.6053771972656,52.6053771972656,74.0431518554688,74.0431518554688,106.10245513916,106.10245513916,106.10245513916,106.10245513916,106.10245513916,113.604019165039,113.604019165039,113.604019165039,113.604019165039,113.604019165039],"meminc":[0,0,20.2659530639648,0,25.4561462402344,0,0,0,0,16.7264022827148,0,19.7430191040039,0,0,-90.6496429443359,0,31.4260177612305,0,19.8794250488281,0,0,0,0,0,29.2548675537109,0,10.1006164550781,0,0,-76.2277145385742,0,0,20.7301940917969,0,0,0,0,29.7227249145508,0,0,0,0,19.749382019043,0,-86.2776718139648,0,20.2696685791016,0,0,0,31.0233840942383,0,0,0,19.4812774658203,0,21.5163726806641,0,0,-88.2785568237305,0,31.6836700439453,0,20.7293243408203,0,30.8298187255859,0,0,0,0,-96.628776550293,0,0,0,0,30.8983459472656,0,20.7299575805664,0,0,31.6878814697266,0,18.3681793212891,0,0,-83.705451965332,0,0,20.7250747680664,0,0,0,0,30.1165084838867,0,0,0,20.0112991333008,0,0,-86.7939910888672,0,0,0,20.2066040039062,0,0,30.9705047607422,0,0,0,19.4192886352539,0,0,28.9979019165039,0,0,-95.0654144287109,0,31.099983215332,0,20.4098129272461,0,0,29.8509902954102,0,13.7071914672852,0,0,-80.1667633056641,0,20.5265655517578,0,0,29.9847259521484,0,19.8774566650391,0,-87.5161514282227,0,19.5471725463867,0,31.4277496337891,0,0,19.5485305786133,0,26.76806640625,0,0,-92.5009841918945,0,0,0,0,31.7521057128906,0,20.8547973632812,0,30.17041015625,0,0,9.77931213378906,0,0,-74.8973999023438,0,21.378173828125,0,30.3768539428711,0,19.7470016479492,0,0,0,0,-86.0111083984375,0,0,0,0,0,19.8119659423828,0,0,0,0,29.6601867675781,0,0,18.8975143432617,0,0,20.9894409179688,0,0,-86.2031860351562,0,31.7548217773438,0,21.3179702758789,0,0,0,0,32.1415557861328,0,-95.8438491821289,0,0,0,0,30.9704895019531,0,20.3395156860352,0,30.3707656860352,0,0,0,0,15.1545333862305,0,0,-80.4394149780273,0,21.450309753418,0,31.819580078125,0,0,19.3489303588867,0,0,0,0,7.80484771728516,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-102.260681152344,0,0,20.5380401611328,0,31.1591949462891,0,20.0052871704102,0,30.5738296508789,0,-95.1231307983398,0,0,0,0,0,31.7557373046875,0,20.4617538452148,0,0,0,30.6353073120117,0,12.2668685913086,0,0,-77.4724807739258,0,0,0,0,20.8637161254883,0,32.3373870849609,0,0,20.7894439697266,0,0,0,0,-84.0892944335938,0,21.0546569824219,0,31.292594909668,0,0,0,21.1890106201172,0,-83.1797561645508,0,20.7315368652344,0,0,32.0676879882812,0,21.4573364257812,0,0,22.95654296875,0,0,-85.5980224609375,0,32.1395721435547,0,0,0,0,21.7161178588867,0,31.7492294311523,0,0,0,0,0,-93.6104507446289,0,0,0,0,31.4228897094727,0,0,21.3147506713867,0,0,0,0,30.3689193725586,10.4919891357422,0,0,-73.5922775268555,0,0,0,0,0,20.273551940918,0,0,0,0,31.821891784668,0,0,0,0,21.1899795532227,0,0,-84.1671524047852,0,20.7357330322266,0,0,31.8189010620117,0,0,0,21.5154571533203,0,0,-83.8440399169922,0,0,20.7956619262695,0,0,0,0,31.3569869995117,0,0,0,0,19.9401016235352,0,0,0,0,0,22.1763916015625,0,0,-85.6095504760742,0,31.7587966918945,0,0,20.5347213745117,0,0,30.1824645996094,0,0,0,-93.8888397216797,0,31.1679763793945,0,20.9867630004883,0,0,31.7544326782227,0,0,0,0,13.1231155395508,0,0,-76.8240814208984,0,20.275390625,0,31.9379348754883,0,20.4077377319336,0,0,0,-83.571418762207,0,0,0,0,21.1266555786133,0,30.3054504394531,0,20.9308624267578,0,0,0,0,-82.7983627319336,0,20.7919387817383,0,0,31.2863540649414,0,21.2557144165039,0,24.860466003418,0,0,0,0,0,-86.8465347290039,0,0,0,0,31.7544784545898,0,21.1865615844727,0,31.5521926879883,0,-94.5913467407227,0,30.974983215332,0,20.9942474365234,0,30.7675094604492,0,14.232048034668,0,0,-76.5040512084961,0,0,0,20.7235641479492,0,0,0,31.416374206543,0,20.7966918945312,0,0,0,0,-82.9730072021484,0,20.9205551147461,0,31.879997253418,0,0,20.464599609375,0,0,-83.1627197265625,0,20.5309677124023,0,0,0,0,31.4166717529297,0,20.2659912109375,0,0,24.2035598754883,0,0,-87.1690902709961,0,31.5468215942383,0,20.5326690673828,0,0,29.9071731567383,0,0,-95.6590347290039,0,0,31.285400390625,0,20.9194412231445,0,0,0,0,31.543571472168,0,0,0,0,17.1182861328125,0,0,-82.6978149414062,0,19.48291015625,0,31.2824325561523,0,21.1170120239258,0,0,-84.539794921875,0,0,0,0,0,20.7921371459961,0,0,0,0,31.7434616088867,0,20.7244186401367,0,0,0,0,22.1053161621094,0,0,-85.3310928344727,0,0,31.6798095703125,0,0,0,0,21.7085189819336,0,30.3650512695312,0,0,0,0,-94.7693176269531,0,0,0,0,31.4803009033203,0,21.0538482666016,0,0,31.6780166625977,0,12.1331024169922,0,0,-75.946907043457,0,0,0,0,20.9196090698242,0,31.0219268798828,0,19.9412002563477,0,-84.0834274291992,0,21.1186904907227,0,32.2706527709961,0,20.7934722900391,0,0,0,0,0,-84.1480102539062,0,0,0,0,20.9170379638672,0,31.6709289550781,0,21.3772354125977,0,0,0,0,24.1288223266602,0,0,-86.4847564697266,0,0,31.4746932983398,0,0,21.571662902832,0,0,0,0,31.934684753418,0,0,-94.8196105957031,0,0,0,0,30.8181915283203,0,20.7865371704102,0,0,0,0,31.4750061035156,0,0,0,13.2457122802734,0,0,-76.518180847168,0,0,20.9173202514648,0,32.1326675415039,0,21.049430847168,0,-83.609001159668,0,21.1797027587891,0,32.1943130493164,0,0,0,21.4409942626953,0,0,-83.4697265625,0,21.0481948852539,0,32.1296005249023,0,21.2438201904297,0,-22.5433502197266,0,0,-40.1404647827148,0,31.8678665161133,0,0,0,21.0485687255859,0,30.0301818847656,0,0,-92.6506271362305,0,0,31.6054000854492,0,21.5068054199219,0,32.1943969726562,0,0,0,0,-93.5024795532227,27.9292755126953,0,20.9141235351562,0,0,31.4029998779297,0,0,20.5213394165039,0,0,-83.589973449707,0,0,20.7830429077148,0,0,0,31.6655731201172,0,20.9803237915039,0,0,0,0,0,-83.7873840332031,0,21.1113510131836,0,31.7976760864258,0,0,0,0,20.2589340209961,0,0,20.8483047485352,0,0,-83.1975631713867,0,29.7645874023438,0,0,0,0,21.4385604858398,0,30.0931167602539,0,-93.6214294433594,0,0,0,32.124641418457,0,0,21.700080871582,0,0,0,0,0,31.7308731079102,0,0,0,4.86050415039062,0,0,-66.2240371704102,0,20.2581329345703,0,32.2558288574219,0,18.8158493041992,0,0,-82.296875,0,20.8484420776367,0,0,30.4852828979492,0,21.5038299560547,0,-84.2441940307617,0,21.4377746582031,0,32.0593032836914,0,0,0,0,7.50156402587891,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpdAfewU/file38e3384f670e.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq        mean     median         uq
#>         compute_pi0(m)    797.988    802.8970    811.8691    808.579    818.131
#>    compute_pi0(m * 10)   7948.642   7965.6705   8028.4704   8008.278   8076.070
#>   compute_pi0(m * 100)  79501.047  79750.5420  80593.9306  80156.076  80604.775
#>         compute_pi1(m)    157.700    196.5925    251.0806    271.929    283.832
#>    compute_pi1(m * 10)   1252.717   1327.0660   7789.2937   1398.305   1418.966
#>   compute_pi1(m * 100)  13161.160  13712.3675  35191.8933  20312.606  25488.178
#>  compute_pi1(m * 1000) 250274.295 269546.3225 339979.1238 370540.731 372852.187
#>         max neval
#>     842.906    20
#>    8225.498    20
#>   85976.601    20
#>     324.481    20
#>  116126.039    20
#>  129956.366    20
#>  473650.715    20
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
#>   memory_copy1(n) 5445.22108 5075.47018 617.482803 3807.61587 3212.67017
#>   memory_copy2(n)   94.08700   90.39625  12.036171   68.05847   57.47565
#>  pre_allocate1(n)   20.42054   19.29932   3.721506   14.46726   12.21252
#>  pre_allocate2(n)  201.87962  190.72851  24.620448  146.39989  129.97793
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  92.331848    10
#>   2.833809    10
#>   1.944693    10
#>   4.396270    10
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
#>  f1(df) 249.9091 260.5318 86.80054 260.4354 64.31055 39.54758     5
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
