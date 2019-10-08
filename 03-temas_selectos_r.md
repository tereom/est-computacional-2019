
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
#> 1   1 -0.67143195 2.6664633 3.063641 1.850519
#> 2   2 -0.16982990 1.3730216 4.084096 3.265122
#> 3   3 -0.88301751 2.4529438 1.434538 3.168375
#> 4   4 -0.37959500 3.4420980 4.106768 4.320720
#> 5   5 -0.06315219 0.7745663 1.763204 4.254592
#> 6   6  1.45834247 1.7506617 4.443251 2.444355
#> 7   7 -0.81787882 0.8680964 1.835736 5.215358
#> 8   8 -0.04228324 2.0870886 1.440502 2.524763
#> 9   9 -0.83732098 2.7342695 2.790815 3.707726
#> 10 10  0.11800342 0.6372763 5.378724 4.036425
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.2288164
mean(df$b)
#> [1] 1.878649
mean(df$c)
#> [1] 3.034128
mean(df$d)
#> [1] 3.478795
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.2288164  1.8786485  3.0341276  3.4787955
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
#> [1] -0.2288164  1.8786485  3.0341276  3.4787955
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
#> [1]  5.5000000 -0.2288164  1.8786485  3.0341276  3.4787955
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
#> [1]  5.5000000 -0.2747125  1.9188751  2.9272279  3.4864238
col_describe(df, mean)
#> [1]  5.5000000 -0.2288164  1.8786485  3.0341276  3.4787955
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
#>  5.5000000 -0.2288164  1.8786485  3.0341276  3.4787955
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
#>   3.856   0.103   3.962
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.022   0.000   0.723
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
#>  12.899   0.719   9.882
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
#>   4.064   0.000   4.066
est_l_st
#>    user  system elapsed 
#>  62.638   1.099  63.769
est_r_st
#>    user  system elapsed 
#>   0.393   0.000   0.393
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

<!--html_preserve--><div id="htmlwidget-334226f35afd0cca408e" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-334226f35afd0cca408e">{"x":{"message":{"prof":{"time":[1,1,1,1,1,1,2,2,2,3,3,3,3,3,4,4,5,5,5,6,6,7,7,8,8,9,9,10,10,10,11,12,12,12,13,13,13,14,14,15,15,15,16,16,16,16,17,17,17,18,18,18,18,18,18,19,19,19,19,20,20,20,20,20,21,21,22,22,23,23,23,24,24,25,25,26,26,27,27,27,27,27,28,28,28,29,29,29,30,30,30,31,31,32,32,33,33,33,34,34,34,35,35,35,35,35,36,36,37,37,38,38,39,39,40,40,41,41,42,42,42,42,42,43,43,44,44,45,45,46,46,47,47,47,47,47,48,48,48,48,48,49,49,50,50,51,51,51,52,52,53,53,54,54,55,55,55,55,56,56,56,57,57,58,58,58,58,59,59,59,59,59,60,60,60,61,61,62,62,63,63,64,64,65,65,65,66,66,67,67,68,68,69,69,69,70,70,71,71,71,72,72,72,73,73,73,74,74,74,75,75,76,76,76,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,90,90,91,91,91,91,92,92,92,92,92,92,93,93,93,94,94,95,95,95,95,95,95,96,96,97,97,97,98,98,99,99,99,100,100,101,101,102,102,102,103,103,103,103,103,103,104,104,105,105,106,106,106,106,106,107,107,107,107,107,108,108,109,109,110,110,111,111,112,112,113,113,113,113,113,114,114,114,115,115,115,116,116,117,117,118,118,118,118,118,119,119,120,120,121,121,122,122,123,123,123,123,124,124,124,125,125,126,126,126,126,127,127,127,128,128,128,128,128,129,129,130,130,131,131,132,132,132,132,133,133,134,134,134,134,134,134,135,135,135,136,136,137,137,137,138,138,139,139,140,140,140,140,140,141,141,142,142,142,142,143,143,144,144,145,145,146,146,146,147,147,147,147,147,147,148,148,149,149,149,149,150,150,151,151,151,152,152,152,152,152,152,153,153,154,154,154,155,155,156,156,157,157,157,158,158,158,158,158,159,159,159,160,160,161,161,161,161,161,162,162,162,162,162,163,163,164,164,164,164,164,165,165,165,166,166,166,167,167,167,167,167,168,168,169,169,170,170,170,170,171,171,171,171,171,172,172,172,173,173,174,174,175,175,176,176,176,177,177,177,178,178,178,179,179,179,180,180,180,180,181,181,182,182,183,184,184,185,185,186,186,186,187,187,187,187,187,188,188,188,188,188,189,189,190,190,191,191,192,192,193,193,193,194,194,195,195,196,196,197,197,198,198,198,198,198,199,199,199,200,200,200,201,201,201,201,202,202,202,202,202,202,203,203,203,204,204,204,205,205,206,206,207,207,207,208,208,208,208,208,209,209,210,210,210,211,211,212,212,213,213,214,214,214,215,215,216,216,217,217,217,218,218,219,219,219,220,220,220,221,221,221,221,221,222,222,222,223,223,223,223,223,223,224,224,225,225,226,226,226,227,227,228,228,228,228,228,229,229,230,230,230,231,231,232,232,232,233,233,234,234,235,235,235,236,236,237,237,238,238,238,239,239,239,239,239,239,240,240,241,241,241,242,242,243,243,244,244,244,245,245,246,246,247,247,247,247,247,248,248,248,248,249,249,249,250,250,250,251,251,252,252,252,252,252,253,253,254,254,254,255,255,255,255,256,256,257,257,257,258,258,259,259,260,260,261,261,261,261,261,262,262,263,263,263,263,263,264,264,264,265,265,265,265,265,266,266,266,267,267,268,268,268,269,269,270,270,271,271,272,272,272,273,273,274,274,275,275,276,276,277,277,277,278,278,279,279,279,279,280,280,281,281,281,282,282,282,282,282],"depth":[6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,1,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,1,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1],"label":["names","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","nrow","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","<GC>","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","$","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,null,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,1],"linenum":[null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,11,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,null,11,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,10,10,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,10,10,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,10,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,13],"memalloc":[61.5343780517578,61.5343780517578,61.5343780517578,61.5343780517578,61.5343780517578,61.5343780517578,82.850944519043,82.850944519043,82.850944519043,109.880477905273,109.880477905273,109.880477905273,109.880477905273,109.880477905273,127.459838867188,127.459838867188,146.284332275391,146.284332275391,146.284332275391,58.7846374511719,58.7846374511719,90.5357818603516,90.5357818603516,109.892333984375,109.892333984375,139.869659423828,139.869659423828,43.302734375,43.302734375,43.302734375,74.7238082885742,95.2600021362305,95.2600021362305,95.2600021362305,125.180320739746,125.180320739746,125.180320739746,145.253509521484,145.253509521484,59.8298263549805,59.8298263549805,59.8298263549805,81.2179794311523,81.2179794311523,81.2179794311523,81.2179794311523,111.779586791992,111.779586791992,111.779586791992,131.654304504395,131.654304504395,131.654304504395,131.654304504395,131.654304504395,131.654304504395,45.1437225341797,45.1437225341797,45.1437225341797,45.1437225341797,66.1367874145508,66.1367874145508,66.1367874145508,66.1367874145508,66.1367874145508,98.2813110351562,98.2813110351562,119.406066894531,119.406066894531,146.298225402832,146.298225402832,146.298225402832,54.4615631103516,54.4615631103516,86.4726181030273,86.4726181030273,107.397521972656,107.397521972656,139.02091217041,139.02091217041,139.02091217041,139.02091217041,139.02091217041,63.1144561767578,63.1144561767578,63.1144561767578,73.6177825927734,73.6177825927734,73.6177825927734,94.08837890625,94.08837890625,94.08837890625,123.936889648438,123.936889648438,143.620071411133,143.620071411133,46.3284454345703,46.3284454345703,46.3284454345703,60.4988632202148,60.4988632202148,60.4988632202148,91.6680221557617,91.6680221557617,91.6680221557617,91.6680221557617,91.6680221557617,111.480445861816,111.480445861816,141.920921325684,141.920921325684,45.6744613647461,45.6744613647461,76.5747299194336,76.5747299194336,97.2484283447266,97.2484283447266,125.590309143066,125.590309143066,145.26961517334,145.26961517334,145.26961517334,145.26961517334,145.26961517334,58.6702575683594,58.6702575683594,79.7945861816406,79.7945861816406,111.67716217041,111.67716217041,133,133,47.054313659668,47.054313659668,47.054313659668,47.054313659668,47.054313659668,67.4564437866211,67.4564437866211,67.4564437866211,67.4564437866211,67.4564437866211,98.5559005737305,98.5559005737305,118.235023498535,118.235023498535,146.315612792969,146.315612792969,146.315612792969,52.1747665405273,52.1747665405273,83.2061996459961,83.2061996459961,103.798194885254,103.798194885254,134.362319946289,134.362319946289,134.362319946289,134.362319946289,146.305770874023,146.305770874023,146.305770874023,69.4389419555664,69.4389419555664,90.6228790283203,90.6228790283203,90.6228790283203,90.6228790283203,120.01538848877,120.01538848877,120.01538848877,120.01538848877,120.01538848877,139.171035766602,139.171035766602,139.171035766602,53.2909317016602,53.2909317016602,74.2838821411133,74.2838821411133,105.255493164062,105.255493164062,124.941253662109,124.941253662109,146.324211120605,146.324211120605,146.324211120605,59.5963973999023,59.5963973999023,91.0230026245117,91.0230026245117,111.947631835938,111.947631835938,143.695793151855,143.695793151855,143.695793151855,47.9182968139648,47.9182968139648,79.1497344970703,79.1497344970703,79.1497344970703,99.621452331543,99.621452331543,99.621452331543,129.533126831055,129.533126831055,129.533126831055,146.261306762695,146.261306762695,146.261306762695,64.7722778320312,64.7722778320312,85.567008972168,85.567008972168,85.567008972168,116.33805847168,116.33805847168,135.947395324707,135.947395324707,135.947395324707,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,146.31086730957,42.7394409179688,42.7394409179688,42.7394409179688,46.3473358154297,46.3473358154297,66.5568695068359,66.5568695068359,97.7158508300781,97.7158508300781,97.7158508300781,97.7158508300781,117.590148925781,117.590148925781,117.590148925781,117.590148925781,117.590148925781,117.590148925781,146.262016296387,146.262016296387,146.262016296387,54.0239791870117,54.0239791870117,85.1239929199219,85.1239929199219,85.1239929199219,85.1239929199219,85.1239929199219,85.1239929199219,106.17733001709,106.17733001709,138.318687438965,138.318687438965,138.318687438965,43.5295791625977,43.5295791625977,74.5573654174805,74.5573654174805,74.5573654174805,95.5514373779297,95.5514373779297,127.691284179688,127.691284179688,146.317329406738,146.317329406738,146.317329406738,64.7238464355469,64.7238464355469,64.7238464355469,64.7238464355469,64.7238464355469,64.7238464355469,85.7124557495117,85.7124557495117,117.725746154785,117.725746154785,139.242256164551,139.242256164551,139.242256164551,139.242256164551,139.242256164551,55.0131759643555,55.0131759643555,55.0131759643555,55.0131759643555,55.0131759643555,75.872688293457,75.872688293457,107.485343933105,107.485343933105,128.80931854248,128.80931854248,45.3705139160156,45.3705139160156,66.4956588745117,66.4956588745117,98.3704299926758,98.3704299926758,98.3704299926758,98.3704299926758,98.3704299926758,118.577705383301,118.577705383301,118.577705383301,146.261940002441,146.261940002441,146.261940002441,54.6851654052734,54.6851654052734,85.8452758789062,85.8452758789062,107.095863342285,107.095863342285,107.095863342285,107.095863342285,107.095863342285,139.62833404541,139.62833404541,45.7651901245117,45.7651901245117,76.8571166992188,76.8571166992188,98.0524749755859,98.0524749755859,128.295356750488,128.295356750488,128.295356750488,128.295356750488,146.271812438965,146.271812438965,146.271812438965,64.6020355224609,64.6020355224609,85.1386642456055,85.1386642456055,85.1386642456055,85.1386642456055,116.429862976074,116.429862976074,116.429862976074,137.292503356934,137.292503356934,137.292503356934,137.292503356934,137.292503356934,54.0341491699219,54.0341491699219,74.1766662597656,74.1766662597656,106.254196166992,106.254196166992,127.442672729492,127.442672729492,127.442672729492,127.442672729492,43.7391891479492,43.7391891479492,64.3379058837891,64.3379058837891,64.3379058837891,64.3379058837891,64.3379058837891,64.3379058837891,96.3595275878906,96.3595275878906,96.3595275878906,117.745460510254,117.745460510254,146.287551879883,146.287551879883,146.287551879883,56.4680633544922,56.4680633544922,87.5014572143555,87.5014572143555,108.754539489746,108.754539489746,108.754539489746,108.754539489746,108.754539489746,140.904365539551,140.904365539551,47.0220489501953,47.0220489501953,47.0220489501953,47.0220489501953,78.0569763183594,78.0569763183594,98.5867614746094,98.5867614746094,130.072830200195,130.072830200195,146.27864074707,146.27864074707,146.27864074707,67.8897247314453,67.8897247314453,67.8897247314453,67.8897247314453,67.8897247314453,67.8897247314453,88.6178817749023,88.6178817749023,120.308067321777,120.308067321777,120.308067321777,120.308067321777,140.972023010254,140.972023010254,57.1253814697266,57.1253814697266,57.1253814697266,77.9176406860352,77.9176406860352,77.9176406860352,77.9176406860352,77.9176406860352,77.9176406860352,109.927780151367,109.927780151367,131.11548614502,131.11548614502,131.11548614502,48.0105285644531,48.0105285644531,68.8686218261719,68.8686218261719,99.5062637329102,99.5062637329102,99.5062637329102,120.171577453613,120.171577453613,120.171577453613,120.171577453613,120.171577453613,146.27668762207,146.27668762207,146.27668762207,56.7378616333008,56.7378616333008,86.9927291870117,86.9927291870117,86.9927291870117,86.9927291870117,86.9927291870117,107.852005004883,107.852005004883,107.852005004883,107.852005004883,107.852005004883,139.077438354492,139.077438354492,45.324333190918,45.324333190918,45.324333190918,45.324333190918,45.324333190918,75.6244735717773,75.6244735717773,75.6244735717773,96.0883407592773,96.0883407592773,96.0883407592773,125.997138977051,125.997138977051,125.997138977051,125.997138977051,125.997138977051,145.283088684082,145.283088684082,61.1286773681641,61.1286773681641,81.3944473266602,81.3944473266602,81.3944473266602,81.3944473266602,112.880760192871,112.880760192871,112.880760192871,112.880760192871,112.880760192871,133.870445251465,133.870445251465,133.870445251465,50.4441299438477,50.4441299438477,70.7783508300781,70.7783508300781,102.26114654541,102.26114654541,122.921188354492,122.921188354492,122.921188354492,146.271240234375,146.271240234375,146.271240234375,60.0873947143555,60.0873947143555,60.0873947143555,90.3222808837891,90.3222808837891,90.3222808837891,111.116256713867,111.116256713867,111.116256713867,111.116256713867,143.319023132324,143.319023132324,47.4625015258789,47.4625015258789,77.6980819702148,98.8796768188477,98.8796768188477,131.210876464844,131.210876464844,146.296287536621,146.296287536621,146.296287536621,67.5347518920898,67.5347518920898,67.5347518920898,67.5347518920898,67.5347518920898,87.8042831420898,87.8042831420898,87.8042831420898,87.8042831420898,87.8042831420898,119.741470336914,119.741470336914,140.988304138184,140.988304138184,56.4479598999023,56.4479598999023,77.1097717285156,77.1097717285156,108.525245666504,108.525245666504,108.525245666504,129.185478210449,129.185478210449,44.9721908569336,44.9721908569336,65.8284301757812,65.8284301757812,97.4413375854492,97.4413375854492,117.249839782715,117.249839782715,117.249839782715,117.249839782715,117.249839782715,146.300910949707,146.300910949707,146.300910949707,51.4020614624023,51.4020614624023,51.4020614624023,83.0132675170898,83.0132675170898,83.0132675170898,83.0132675170898,104.132659912109,104.132659912109,104.132659912109,104.132659912109,104.132659912109,104.132659912109,135.416412353516,135.416412353516,135.416412353516,146.304565429688,146.304565429688,146.304565429688,71.7986907958984,71.7986907958984,92.1932907104492,92.1932907104492,122.822731018066,122.822731018066,122.822731018066,141.911315917969,141.911315917969,141.911315917969,141.911315917969,141.911315917969,57.4345397949219,57.4345397949219,77.9630508422852,77.9630508422852,77.9630508422852,109.840263366699,109.840263366699,131.289108276367,131.289108276367,46.6822509765625,46.6822509765625,67.7309951782227,67.7309951782227,67.7309951782227,99.7297515869141,99.7297515869141,121.10652923584,121.10652923584,146.284446716309,146.284446716309,146.284446716309,57.7018661499023,57.7018661499023,89.0454330444336,89.0454330444336,89.0454330444336,110.617141723633,110.617141723633,110.617141723633,142.222923278809,142.222923278809,142.222923278809,142.222923278809,142.222923278809,47.0762786865234,47.0762786865234,47.0762786865234,77.8294372558594,77.8294372558594,77.8294372558594,77.8294372558594,77.8294372558594,77.8294372558594,98.877571105957,98.877571105957,130.351501464844,130.351501464844,146.28662109375,146.28662109375,146.28662109375,66.88330078125,66.88330078125,86.4903335571289,86.4903335571289,86.4903335571289,86.4903335571289,86.4903335571289,117.245277404785,117.245277404785,137.049217224121,137.049217224121,137.049217224121,51.7334899902344,51.7334899902344,71.537353515625,71.537353515625,71.537353515625,102.157569885254,102.157569885254,123.533851623535,123.533851623535,146.285499572754,146.285499572754,146.285499572754,61.2432708740234,61.2432708740234,92.5205307006836,92.5205307006836,113.502059936523,113.502059936523,113.502059936523,143.140502929688,143.140502929688,143.140502929688,143.140502929688,143.140502929688,143.140502929688,48.719841003418,48.719841003418,80.1289138793945,80.1289138793945,80.1289138793945,101.439399719238,101.439399719238,132.978645324707,132.978645324707,146.289306640625,146.289306640625,146.289306640625,69.1772537231445,69.1772537231445,89.7014389038086,89.7014389038086,120.716896057129,120.716896057129,120.716896057129,120.716896057129,120.716896057129,141.501007080078,141.501007080078,141.501007080078,141.501007080078,57.505256652832,57.505256652832,57.505256652832,77.9605484008789,77.9605484008789,77.9605484008789,110.347137451172,110.347137451172,131.720085144043,131.720085144043,131.720085144043,131.720085144043,131.720085144043,48.8517684936523,48.8517684936523,69.8977584838867,69.8977584838867,69.8977584838867,101.628974914551,101.628974914551,101.628974914551,101.628974914551,123.329322814941,123.329322814941,146.276641845703,146.276641845703,146.276641845703,59.8672485351562,59.8672485351562,90.9436645507812,90.9436645507812,112.054840087891,112.054840087891,140.770942687988,140.770942687988,140.770942687988,140.770942687988,140.770942687988,46.7554702758789,46.7554702758789,78.1594543457031,78.1594543457031,78.1594543457031,78.1594543457031,78.1594543457031,99.5977630615234,99.5977630615234,99.5977630615234,131.788986206055,131.788986206055,131.788986206055,131.788986206055,131.788986206055,146.277732849121,146.277732849121,146.277732849121,69.5708236694336,69.5708236694336,90.1570663452148,90.1570663452148,90.1570663452148,122.412399291992,122.412399291992,143.785171508789,143.785171508789,61.0488586425781,61.0488586425781,82.356071472168,82.356071472168,82.356071472168,115.07014465332,115.07014465332,135.13166809082,135.13166809082,51.0000152587891,51.0000152587891,72.3072891235352,72.3072891235352,104.694122314453,104.694122314453,104.694122314453,126.394111633301,126.394111633301,42.936882019043,42.936882019043,42.936882019043,42.936882019043,63.0638809204102,63.0638809204102,95.581787109375,95.581787109375,95.581787109375,112.917366027832,112.917366027832,112.917366027832,112.917366027832,112.917366027832],"meminc":[0,0,0,0,0,0,21.3165664672852,0,0,27.0295333862305,0,0,0,0,17.5793609619141,0,18.8244934082031,0,0,-87.4996948242188,0,31.7511444091797,0,19.3565521240234,0,29.9773254394531,0,-96.5669250488281,0,0,31.4210739135742,20.5361938476562,0,0,29.9203186035156,0,0,20.0731887817383,0,-85.4236831665039,0,0,21.3881530761719,0,0,0,30.5616073608398,0,0,19.8747177124023,0,0,0,0,0,-86.5105819702148,0,0,0,20.9930648803711,0,0,0,0,32.1445236206055,0,21.124755859375,0,26.8921585083008,0,0,-91.8366622924805,0,32.0110549926758,0,20.9249038696289,0,31.6233901977539,0,0,0,0,-75.9064559936523,0,0,10.5033264160156,0,0,20.4705963134766,0,0,29.8485107421875,0,19.6831817626953,0,-97.2916259765625,0,0,14.1704177856445,0,0,31.1691589355469,0,0,0,0,19.8124237060547,0,30.4404754638672,0,-96.2464599609375,0,30.9002685546875,0,20.673698425293,0,28.3418807983398,0,19.6793060302734,0,0,0,0,-86.5993576049805,0,21.1243286132812,0,31.8825759887695,0,21.3228378295898,0,-85.945686340332,0,0,0,0,20.4021301269531,0,0,0,0,31.0994567871094,0,19.6791229248047,0,28.0805892944336,0,0,-94.1408462524414,0,31.0314331054688,0,20.5919952392578,0,30.5641250610352,0,0,0,11.9434509277344,0,0,-76.866828918457,0,21.1839370727539,0,0,0,29.3925094604492,0,0,0,0,19.155647277832,0,0,-85.8801040649414,0,20.9929504394531,0,30.9716110229492,0,19.6857604980469,0,21.3829574584961,0,0,-86.7278137207031,0,31.4266052246094,0,20.9246292114258,0,31.748161315918,0,0,-95.7774963378906,0,31.2314376831055,0,0,20.4717178344727,0,0,29.9116744995117,0,0,16.7281799316406,0,0,-81.4890289306641,0,20.7947311401367,0,0,30.7710494995117,0,19.6093368530273,0,0,10.3634719848633,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571426391602,0,0,3.60789489746094,0,20.2095336914062,0,31.1589813232422,0,0,0,19.8742980957031,0,0,0,0,0,28.6718673706055,0,0,-92.238037109375,0,31.1000137329102,0,0,0,0,0,21.053337097168,0,32.141357421875,0,0,-94.7891082763672,0,31.0277862548828,0,0,20.9940719604492,0,32.1398468017578,0,18.6260452270508,0,0,-81.5934829711914,0,0,0,0,0,20.9886093139648,0,32.0132904052734,0,21.5165100097656,0,0,0,0,-84.2290802001953,0,0,0,0,20.8595123291016,0,31.6126556396484,0,21.323974609375,0,-83.4388046264648,0,21.1251449584961,0,31.8747711181641,0,0,0,0,20.207275390625,0,0,27.6842346191406,0,0,-91.576774597168,0,31.1601104736328,0,21.2505874633789,0,0,0,0,32.532470703125,0,-93.8631439208984,0,31.091926574707,0,21.1953582763672,0,30.2428817749023,0,0,0,17.9764556884766,0,0,-81.6697769165039,0,20.5366287231445,0,0,0,31.2911987304688,0,0,20.8626403808594,0,0,0,0,-83.2583541870117,0,20.1425170898438,0,32.0775299072266,0,21.1884765625,0,0,0,-83.703483581543,0,20.5987167358398,0,0,0,0,0,32.0216217041016,0,0,21.3859329223633,0,28.5420913696289,0,0,-89.8194885253906,0,31.0333938598633,0,21.2530822753906,0,0,0,0,32.1498260498047,0,-93.8823165893555,0,0,0,31.0349273681641,0,20.52978515625,0,31.4860687255859,0,16.205810546875,0,0,-78.388916015625,0,0,0,0,0,20.728157043457,0,31.690185546875,0,0,0,20.6639556884766,0,-83.8466415405273,0,0,20.7922592163086,0,0,0,0,0,32.010139465332,0,21.1877059936523,0,0,-83.1049575805664,0,20.8580932617188,0,30.6376419067383,0,0,20.6653137207031,0,0,0,0,26.105110168457,0,0,-89.5388259887695,0,30.2548675537109,0,0,0,0,20.8592758178711,0,0,0,0,31.2254333496094,0,-93.7531051635742,0,0,0,0,30.3001403808594,0,0,20.4638671875,0,0,29.9087982177734,0,0,0,0,19.2859497070312,0,-84.154411315918,0,20.2657699584961,0,0,0,31.4863128662109,0,0,0,0,20.9896850585938,0,0,-83.4263153076172,0,20.3342208862305,0,31.482795715332,0,20.660041809082,0,0,23.3500518798828,0,0,-86.1838455200195,0,0,30.2348861694336,0,0,20.7939758300781,0,0,0,32.202766418457,0,-95.8565216064453,0,30.2355804443359,21.1815948486328,0,32.3311996459961,0,15.0854110717773,0,0,-78.7615356445312,0,0,0,0,20.26953125,0,0,0,0,31.9371871948242,0,21.2468338012695,0,-84.5403442382812,0,20.6618118286133,0,31.4154739379883,0,0,20.6602325439453,0,-84.2132873535156,0,20.8562393188477,0,31.612907409668,0,19.8085021972656,0,0,0,0,29.0510711669922,0,0,-94.8988494873047,0,0,31.6112060546875,0,0,0,21.1193923950195,0,0,0,0,0,31.2837524414062,0,0,10.8881530761719,0,0,-74.5058746337891,0,20.3945999145508,0,30.6294403076172,0,0,19.0885848999023,0,0,0,0,-84.4767761230469,0,20.5285110473633,0,0,31.8772125244141,0,21.448844909668,0,-84.6068572998047,0,21.0487442016602,0,0,31.9987564086914,0,21.3767776489258,0,25.1779174804688,0,0,-88.5825805664062,0,31.3435668945312,0,0,21.5717086791992,0,0,31.6057815551758,0,0,0,0,-95.1466445922852,0,0,30.7531585693359,0,0,0,0,0,21.0481338500977,0,31.4739303588867,0,15.9351196289062,0,0,-79.4033203125,0,19.6070327758789,0,0,0,0,30.7549438476562,0,19.8039398193359,0,0,-85.3157272338867,0,19.8038635253906,0,0,30.6202163696289,0,21.3762817382812,0,22.7516479492188,0,0,-85.0422286987305,0,31.2772598266602,0,20.9815292358398,0,0,29.6384429931641,0,0,0,0,0,-94.4206619262695,0,31.4090728759766,0,0,21.3104858398438,0,31.5392456054688,0,13.310661315918,0,0,-77.1120529174805,0,20.5241851806641,0,31.0154571533203,0,0,0,0,20.7841110229492,0,0,0,-83.9957504272461,0,0,20.4552917480469,0,0,32.386589050293,0,21.3729476928711,0,0,0,0,-82.8683166503906,0,21.0459899902344,0,0,31.7312164306641,0,0,0,21.7003479003906,0,22.9473190307617,0,0,-86.4093933105469,0,31.076416015625,0,21.1111755371094,0,28.7161026000977,0,0,0,0,-94.0154724121094,0,31.4039840698242,0,0,0,0,21.4383087158203,0,0,32.1912231445312,0,0,0,0,14.4887466430664,0,0,-76.7069091796875,0,20.5862426757812,0,0,32.2553329467773,0,21.3727722167969,0,-82.7363128662109,0,21.3072128295898,0,0,32.7140731811523,0,20.0615234375,0,-84.1316528320312,0,21.3072738647461,0,32.386833190918,0,0,21.6999893188477,0,-83.4572296142578,0,0,0,20.1269989013672,0,32.5179061889648,0,0,17.335578918457,0,0,0,0],"filename":[null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpRf8APe/file4030792e7922.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    780.098    791.3945    809.0296    798.9145
#>    compute_pi0(m * 10)   7894.669   7917.0405   7942.8974   7944.1805
#>   compute_pi0(m * 100)  78884.497  79094.0545  79803.3266  79294.6870
#>         compute_pi1(m)    154.655    181.2695    634.9859    248.4800
#>    compute_pi1(m * 10)   1255.122   1281.4670   1337.1955   1318.7590
#>   compute_pi1(m * 100)  12924.618  13088.4705  27050.9428  15916.5820
#>  compute_pi1(m * 1000) 253703.426 315028.9665 348419.1633 370350.9845
#>           uq        max neval
#>     809.4400    916.144    20
#>    7968.3045   8000.598    20
#>   79849.5770  85684.806    20
#>     284.0735   8242.652    20
#>    1393.8400   1449.449    20
#>   20030.0790 128052.335    20
#>  371942.5030 482483.932    20
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
#>   memory_copy1(n) 5648.42306 4649.70414 611.084961 4298.14469 3849.38414
#>   memory_copy2(n)   97.18063   82.51225  11.483209   77.32516   74.80166
#>  pre_allocate1(n)   20.63892   17.02563   3.605767   15.77229   15.35850
#>  pre_allocate2(n)  200.55184  168.43875  21.872430  155.82560  143.09812
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  104.609623    10
#>    2.631311    10
#>    1.946450    10
#>    3.802810    10
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
#>    expr     min      lq    mean   median       uq      max neval
#>  f1(df) 247.532 247.209 80.8648 247.7247 65.53125 29.46613     5
#>  f2(df)   1.000   1.000  1.0000   1.0000  1.00000  1.00000     5
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
