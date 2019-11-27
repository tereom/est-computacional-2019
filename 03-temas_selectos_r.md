
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
#>    id            a          b        c        d
#> 1   1 -0.456975634  2.4508589 3.382850 5.048202
#> 2   2 -0.060964760  4.9088453 2.471867 5.131553
#> 3   3 -0.051100341  2.0365960 3.574220 5.668832
#> 4   4 -1.070095493  0.8456578 3.038909 4.397338
#> 5   5  0.001625069  2.8362538 4.176216 3.974968
#> 6   6 -0.293239208  2.0211221 2.478162 3.831694
#> 7   7  0.315852195  1.2905823 3.082708 1.734833
#> 8   8 -0.874204517  2.0379887 3.244412 4.960581
#> 9   9  0.611957572  3.1781406 3.268285 3.490168
#> 10 10  0.974555704 -1.5156503 2.993393 3.532463
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.09025894
mean(df$b)
#> [1] 2.00904
mean(df$c)
#> [1] 3.171102
mean(df$d)
#> [1] 4.177063
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.09025894  2.00903951  3.17110216  4.17706310
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
#> [1] -0.09025894  2.00903951  3.17110216  4.17706310
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
#> [1]  5.50000000 -0.09025894  2.00903951  3.17110216  4.17706310
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
#> [1]  5.50000000 -0.05603255  2.03729237  3.16356028  4.18615310
col_describe(df, mean)
#> [1]  5.50000000 -0.09025894  2.00903951  3.17110216  4.17706310
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
#>          id           a           b           c           d 
#>  5.50000000 -0.09025894  2.00903951  3.17110216  4.17706310
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
#>   3.780   0.127   3.909
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.017   0.004   2.382
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
#>  12.573   0.718   9.571
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
#>   0.105   0.008   0.112
plyr_st
#>    user  system elapsed 
#>   3.906   0.007   3.913
est_l_st
#>    user  system elapsed 
#>  60.531   1.580  62.112
est_r_st
#>    user  system elapsed 
#>   0.386   0.000   0.386
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

<!--html_preserve--><div id="htmlwidget-4c3ba4dd18e70f6bc91f" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-4c3ba4dd18e70f6bc91f">{"x":{"message":{"prof":{"time":[1,1,1,1,2,2,3,3,4,4,5,5,5,6,6,6,6,6,7,7,8,8,9,9,9,9,10,10,11,11,11,12,12,12,12,12,13,13,14,14,14,15,15,16,16,16,17,17,18,18,18,18,18,18,19,19,20,20,20,20,20,21,21,22,22,23,23,24,24,24,25,25,26,26,26,26,26,27,27,27,28,28,29,29,30,30,30,31,31,31,32,32,33,33,34,34,35,35,36,36,36,37,37,37,37,37,38,38,38,39,39,40,40,41,41,41,42,42,42,43,43,44,44,44,45,45,45,46,46,47,47,48,48,48,48,48,48,49,49,49,49,49,50,50,50,51,51,52,52,52,52,52,53,53,54,54,54,54,55,55,56,56,56,56,56,56,57,57,58,58,59,59,59,60,60,61,61,62,62,62,62,62,62,63,63,63,64,64,65,65,66,66,67,67,67,68,68,68,69,69,70,70,70,71,71,72,72,72,73,73,74,74,74,75,75,75,75,75,76,76,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,88,88,88,88,88,89,89,90,90,91,91,92,92,93,93,94,94,94,94,95,95,95,96,96,97,97,98,98,98,99,99,100,100,101,101,101,102,102,103,103,104,104,104,105,105,106,106,106,106,106,106,107,107,107,107,107,107,108,108,108,109,109,110,111,112,112,112,112,113,113,114,114,115,115,115,115,116,116,117,117,117,118,118,118,119,119,120,120,121,121,121,122,122,122,122,123,123,123,123,123,124,124,125,125,125,126,126,127,127,128,128,129,129,130,130,130,131,131,131,132,132,133,133,133,134,134,135,135,135,135,135,136,136,137,137,137,138,138,139,139,140,140,140,141,141,142,142,143,143,143,144,144,144,144,144,145,145,146,146,147,147,148,148,149,149,150,150,151,151,151,152,152,152,153,153,154,154,155,155,155,156,156,156,157,157,157,158,158,158,159,159,160,160,161,161,161,162,162,163,163,164,164,165,165,166,166,166,166,167,167,167,168,168,169,169,169,170,170,171,171,171,171,172,172,172,173,173,174,174,174,174,174,175,175,175,176,176,177,177,178,178,178,179,179,179,180,180,181,181,182,182,183,183,184,184,184,184,184,185,185,186,186,187,187,187,188,188,188,188,188,189,189,190,190,190,191,191,192,192,193,193,193,193,194,194,195,195,196,196,196,197,197,197,197,197,198,198,198,198,198,198,199,199,200,200,201,201,202,202,203,203,203,203,203,204,204,204,205,205,206,206,207,207,207,208,208,208,208,208,209,209,209,209,210,210,211,211,212,212,213,213,213,214,214,214,215,215,216,216,217,217,217,217,218,218,218,218,219,219,220,220,220,220,220,220,221,221,222,222,222,223,223,224,224,225,225,225,226,226,227,227,227,227,227,228,228,228,228,228,229,229,229,230,230,231,231,231,232,232,233,233,233,233,234,234,234,235,235,235,236,236,236,236,236,237,237,238,238,238,239,239,239,240,240,240,241,241,242,242,242,243,243,243,244,244,244,245,245,245,245,245,245,246,246,247,247,248,248,248,249,249,250,250,251,251,252,252,252,252,253,253,254,254,255,255,256,256,256,257,257,257,257,257,258,258,259,259,260,260,261,261,261,262,262,263,263,264,264,264,264,264,265,265,265,266,266,267,267,268,269,269,270,270,271,271,271,272,272,272,273,273,274,274,274,275,275,275,275,275,276,276,276,276,277,277,277,277,277,278,278,278,278,278,278,278,278,278,278],"depth":[4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,1,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,10,9,8,7,6,5,4,3,2,1],"label":["[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sum","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","anyNA","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","$","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","$","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame","%in%","deparse","mode","%in%","deparse","paste","force","as.data.frame.integer","as.data.frame","data.frame"],"filenum":[null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,null,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,null,null,null,1,null,null,null,null,null,null,null,null,null,1],"linenum":[null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,11,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,10,10,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,10,10,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,null,11,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,10,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,null,null,null,13,null,null,null,null,null,null,null,null,null,13],"memalloc":[63.0089950561523,63.0089950561523,63.0089950561523,63.0089950561523,84.5211563110352,84.5211563110352,111.223518371582,111.223518371582,129.457588195801,129.457588195801,146.315155029297,146.315155029297,146.315155029297,63.0125198364258,63.0125198364258,63.0125198364258,63.0125198364258,63.0125198364258,94.3059997558594,94.3059997558594,113.267791748047,113.267791748047,143.179130554199,143.179130554199,143.179130554199,143.179130554199,47.857177734375,47.857177734375,79.7394790649414,79.7394790649414,79.7394790649414,100.342491149902,100.342491149902,100.342491149902,100.342491149902,100.342491149902,130.722663879395,130.722663879395,146.334396362305,146.334396362305,146.334396362305,66.7478866577148,66.7478866577148,88.1996459960938,88.1996459960938,88.1996459960938,118.959823608398,118.959823608398,139.096199035645,139.096199035645,139.096199035645,139.096199035645,139.096199035645,139.096199035645,54.3601913452148,54.3601913452148,75.2230224609375,75.2230224609375,75.2230224609375,75.2230224609375,75.2230224609375,107.890884399414,107.890884399414,129.536880493164,129.536880493164,45.3050537109375,45.3050537109375,66.3623962402344,66.3623962402344,66.3623962402344,98.9654693603516,98.9654693603516,120.222450256348,120.222450256348,120.222450256348,120.222450256348,120.222450256348,146.33390045166,146.33390045166,146.33390045166,57.6407852172852,57.6407852172852,89.8505096435547,89.8505096435547,109.863090515137,109.863090515137,109.863090515137,139.71354675293,139.71354675293,139.71354675293,44.1946411132812,44.1946411132812,75.9489135742188,75.9489135742188,96.0941543579102,96.0941543579102,125.55241394043,125.55241394043,145.624977111816,145.624977111816,145.624977111816,61.0565032958984,61.0565032958984,61.0565032958984,61.0565032958984,61.0565032958984,82.2506484985352,82.2506484985352,82.2506484985352,113.022743225098,113.022743225098,132.839698791504,132.839698791504,47.2822799682617,47.2822799682617,47.2822799682617,67.6920166015625,67.6920166015625,67.6920166015625,99.3072891235352,99.3072891235352,119.64771270752,119.64771270752,119.64771270752,146.281196594238,146.281196594238,146.281196594238,54.5679321289062,54.5679321289062,86.516716003418,86.516716003418,107.179634094238,107.179634094238,107.179634094238,107.179634094238,107.179634094238,107.179634094238,137.096786499023,137.096786499023,137.096786499023,137.096786499023,137.096786499023,146.281555175781,146.281555175781,146.281555175781,73.1990432739258,73.1990432739258,94.3861846923828,94.3861846923828,94.3861846923828,94.3861846923828,94.3861846923828,123.900131225586,123.900131225586,143.908172607422,143.908172607422,143.908172607422,143.908172607422,58.5101013183594,58.5101013183594,78.718017578125,78.718017578125,78.718017578125,78.718017578125,78.718017578125,78.718017578125,109.418731689453,109.418731689453,129.232208251953,129.232208251953,127.897674560547,127.897674560547,127.897674560547,62.8334808349609,62.8334808349609,94.3265075683594,94.3265075683594,114.277320861816,114.277320861816,114.277320861816,114.277320861816,114.277320861816,114.277320861816,144.191513061523,144.191513061523,144.191513061523,48.0127487182617,48.0127487182617,78.9819564819336,78.9819564819336,100.306304931641,100.306304931641,131.854637145996,131.854637145996,131.854637145996,146.285469055176,146.285469055176,146.285469055176,68.4192123413086,68.4192123413086,89.1548461914062,89.1548461914062,89.1548461914062,119.13508605957,119.13508605957,139.339149475098,139.339149475098,139.339149475098,55.2965316772461,55.2965316772461,76.6780014038086,76.6780014038086,76.6780014038086,109.088493347168,109.088493347168,109.088493347168,109.088493347168,109.088493347168,130.73087310791,130.73087310791,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,146.276695251465,42.7701263427734,42.7701263427734,42.7701263427734,60.4215927124023,60.4215927124023,81.9377746582031,81.9377746582031,81.9377746582031,81.9377746582031,81.9377746582031,113.226280212402,113.226280212402,132.909111022949,132.909111022949,49.5292129516602,49.5292129516602,70.7853164672852,70.7853164672852,102.008438110352,102.008438110352,122.278198242188,122.278198242188,122.278198242188,122.278198242188,146.288902282715,146.288902282715,146.288902282715,58.3866958618164,58.3866958618164,90.5326690673828,90.5326690673828,111.06379699707,111.06379699707,111.06379699707,142.544509887695,142.544509887695,48.5459060668945,48.5459060668945,80.1660537719727,80.1660537719727,80.1660537719727,101.487182617188,101.487182617188,132.581665039062,132.581665039062,146.292633056641,146.292633056641,146.292633056641,70.8543701171875,70.8543701171875,92.1664123535156,92.1664123535156,92.1664123535156,92.1664123535156,92.1664123535156,92.1664123535156,123.986389160156,123.986389160156,123.986389160156,123.986389160156,123.986389160156,123.986389160156,145.368049621582,145.368049621582,145.368049621582,62.2630310058594,62.2630310058594,83.0557479858398,114.545021057129,135.537162780762,135.537162780762,135.537162780762,135.537162780762,53.1428298950195,53.1428298950195,73.0223617553711,73.0223617553711,103.846305847168,103.846305847168,103.846305847168,103.846305847168,124.970970153809,124.970970153809,115.127738952637,115.127738952637,115.127738952637,62.72412109375,62.72412109375,62.72412109375,94.6687774658203,94.6687774658203,116.189239501953,116.189239501953,146.30403137207,146.30403137207,146.30403137207,54.5253143310547,54.5253143310547,54.5253143310547,54.5253143310547,86.9413375854492,86.9413375854492,86.9413375854492,86.9413375854492,86.9413375854492,108.327117919922,108.327117919922,140.798820495605,140.798820495605,140.798820495605,47.3768997192383,47.3768997192383,78.8688201904297,78.8688201904297,100.643272399902,100.643272399902,130.691108703613,130.691108703613,146.303466796875,146.303466796875,146.303466796875,67.2538986206055,67.2538986206055,67.2538986206055,88.1195373535156,88.1195373535156,119.350387573242,119.350387573242,119.350387573242,139.365234375,139.365234375,56.1029739379883,56.1029739379883,56.1029739379883,56.1029739379883,56.1029739379883,76.8421096801758,76.8421096801758,109.308296203613,109.308296203613,109.308296203613,130.892333984375,130.892333984375,48.6272964477539,48.6272964477539,69.6211242675781,69.6211242675781,69.6211242675781,102.223594665527,102.223594665527,123.671226501465,123.671226501465,146.308898925781,146.308898925781,146.308898925781,60.9663467407227,60.9663467407227,60.9663467407227,60.9663467407227,60.9663467407227,92.5197296142578,92.5197296142578,113.71150970459,113.71150970459,146.120681762695,146.120681762695,52.6941986083984,52.6941986083984,84.4422073364258,84.4422073364258,105.168769836426,105.168769836426,136.722137451172,136.722137451172,136.722137451172,44.0393753051758,44.0393753051758,44.0393753051758,74.9341201782227,74.9341201782227,95.0092086791992,95.0092086791992,126.955459594727,126.955459594727,126.955459594727,146.306770324707,146.306770324707,146.306770324707,65.429801940918,65.429801940918,65.429801940918,85.906379699707,85.906379699707,85.906379699707,117.849937438965,117.849937438965,139.303161621094,139.303161621094,55.9147491455078,55.9147491455078,55.9147491455078,77.1626663208008,77.1626663208008,109.627006530762,109.627006530762,131.077346801758,131.077346801758,48.4371643066406,48.4371643066406,69.4881362915039,69.4881362915039,69.4881362915039,69.4881362915039,101.498603820801,101.498603820801,101.498603820801,122.880073547363,122.880073547363,146.298355102539,146.298355102539,146.298355102539,61.7566223144531,61.7566223144531,93.371452331543,93.371452331543,93.371452331543,93.371452331543,114.162437438965,114.162437438965,114.162437438965,143.742553710938,143.742553710938,50.0155258178711,50.0155258178711,50.0155258178711,50.0155258178711,50.0155258178711,81.4952926635742,81.4952926635742,81.4952926635742,101.50325012207,101.50325012207,130.558700561523,130.558700561523,146.299789428711,146.299789428711,146.299789428711,65.6601486206055,65.6601486206055,65.6601486206055,85.8586578369141,85.8586578369141,117.534454345703,117.534454345703,137.603775024414,137.603775024414,53.3961334228516,53.3961334228516,73.9266586303711,73.9266586303711,73.9266586303711,73.9266586303711,73.9266586303711,104.951286315918,104.951286315918,125.544303894043,125.544303894043,145.612106323242,145.612106323242,145.612106323242,62.3832931518555,62.3832931518555,62.3832931518555,62.3832931518555,62.3832931518555,93.4713363647461,93.4713363647461,114.000106811523,114.000106811523,114.000106811523,144.435401916504,144.435401916504,49.9885025024414,49.9885025024414,81.2718811035156,81.2718811035156,81.2718811035156,81.2718811035156,101.670074462891,101.670074462891,133.874053955078,133.874053955078,146.332565307617,146.332565307617,146.332565307617,71.3039016723633,71.3039016723633,71.3039016723633,71.3039016723633,71.3039016723633,92.0947494506836,92.0947494506836,92.0947494506836,92.0947494506836,92.0947494506836,92.0947494506836,123.576385498047,123.576385498047,144.497825622559,144.497825622559,60.8100051879883,60.8100051879883,80.8805999755859,80.8805999755859,111.311157226562,111.311157226562,111.311157226562,111.311157226562,111.311157226562,131.513427734375,131.513427734375,131.513427734375,46.7132263183594,46.7132263183594,67.8270492553711,67.8270492553711,99.1784210205078,99.1784210205078,99.1784210205078,120.563995361328,120.563995361328,120.563995361328,120.563995361328,120.563995361328,146.337547302246,146.337547302246,146.337547302246,146.337547302246,58.1236801147461,58.1236801147461,90.0569458007812,90.0569458007812,111.302055358887,111.302055358887,143.955673217773,143.955673217773,143.955673217773,50.3891525268555,50.3891525268555,50.3891525268555,81.9949417114258,81.9949417114258,102.387664794922,102.387664794922,135.173004150391,135.173004150391,135.173004150391,135.173004150391,146.320785522461,146.320785522461,146.320785522461,146.320785522461,73.7951354980469,73.7951354980469,95.3688354492188,95.3688354492188,95.3688354492188,95.3688354492188,95.3688354492188,95.3688354492188,126.842315673828,126.842315673828,146.318229675293,146.318229675293,146.318229675293,64.3564224243164,64.3564224243164,84.2262420654297,84.2262420654297,116.686660766602,116.686660766602,116.686660766602,138.260414123535,138.260414123535,55.7657241821289,55.7657241821289,55.7657241821289,55.7657241821289,55.7657241821289,77.2085189819336,77.2085189819336,77.2085189819336,77.2085189819336,77.2085189819336,109.927268981934,109.927268981934,109.927268981934,130.974639892578,130.974639892578,48.0939636230469,48.0939636230469,48.0939636230469,69.3398361206055,69.3398361206055,101.994155883789,101.994155883789,101.994155883789,101.994155883789,123.63166809082,123.63166809082,123.63166809082,146.31908416748,146.31908416748,146.31908416748,62.849235534668,62.849235534668,62.849235534668,62.849235534668,62.849235534668,95.5691452026367,95.5691452026367,116.879943847656,116.879943847656,116.879943847656,146.320167541504,146.320167541504,146.320167541504,56.2919387817383,56.2919387817383,56.2919387817383,87.5693359375,87.5693359375,108.749015808105,108.749015808105,108.749015808105,140.221839904785,140.221839904785,140.221839904785,47.1131210327148,47.1131210327148,47.1131210327148,78.5165786743164,78.5165786743164,78.5165786743164,78.5165786743164,78.5165786743164,78.5165786743164,100.151626586914,100.151626586914,132.604293823242,132.604293823242,146.307067871094,146.307067871094,146.307067871094,70.9779052734375,70.9779052734375,92.1536712646484,92.1536712646484,124.410133361816,124.410133361816,145.65217590332,145.65217590332,145.65217590332,145.65217590332,62.3242721557617,62.3242721557617,83.5665435791016,83.5665435791016,116.151313781738,116.151313781738,137.982543945312,137.982543945312,137.982543945312,54.9163665771484,54.9163665771484,54.9163665771484,54.9163665771484,54.9163665771484,76.3546676635742,76.3546676635742,108.283355712891,108.283355712891,128.279708862305,128.279708862305,45.1485595703125,45.1485595703125,45.1485595703125,66.4553451538086,66.4553451538086,99.1043930053711,99.1043930053711,120.870460510254,120.870460510254,120.870460510254,120.870460510254,120.870460510254,146.307739257812,146.307739257812,146.307739257812,58.9820327758789,58.9820327758789,89.4677658081055,89.4677658081055,109.659851074219,141.456977844238,141.456977844238,46.1138229370117,46.1138229370117,76.9927597045898,76.9927597045898,76.9927597045898,97.4475021362305,97.4475021362305,97.4475021362305,128.194915771484,128.194915771484,146.289817810059,146.289817810059,146.289817810059,65.2580184936523,65.2580184936523,65.2580184936523,65.2580184936523,65.2580184936523,85.4505844116211,85.4505844116211,85.4505844116211,85.4505844116211,113.603523254395,113.603523254395,113.603523254395,113.603523254395,113.603523254395,113.970275878906,113.970275878906,113.970275878906,113.970275878906,113.970275878906,113.970275878906,113.970275878906,113.970275878906,113.970275878906,113.970275878906],"meminc":[0,0,0,0,21.5121612548828,0,26.7023620605469,0,18.2340698242188,0,16.8575668334961,0,0,-83.3026351928711,0,0,0,0,31.2934799194336,0,18.9617919921875,0,29.9113388061523,0,0,0,-95.3219528198242,0,31.8823013305664,0,0,20.6030120849609,0,0,0,0,30.3801727294922,0,15.6117324829102,0,0,-79.5865097045898,0,21.4517593383789,0,0,30.7601776123047,0,20.1363754272461,0,0,0,0,0,-84.7360076904297,0,20.8628311157227,0,0,0,0,32.6678619384766,0,21.64599609375,0,-84.2318267822266,0,21.0573425292969,0,0,32.6030731201172,0,21.2569808959961,0,0,0,0,26.1114501953125,0,0,-88.693115234375,0,32.2097244262695,0,20.012580871582,0,0,29.850456237793,0,0,-95.5189056396484,0,31.7542724609375,0,20.1452407836914,0,29.4582595825195,0,20.0725631713867,0,0,-84.568473815918,0,0,0,0,21.1941452026367,0,0,30.7720947265625,0,19.8169555664062,0,-85.5574188232422,0,0,20.4097366333008,0,0,31.6152725219727,0,20.3404235839844,0,0,26.6334838867188,0,0,-91.713264465332,0,31.9487838745117,0,20.6629180908203,0,0,0,0,0,29.9171524047852,0,0,0,0,9.18476867675781,0,0,-73.0825119018555,0,21.187141418457,0,0,0,0,29.5139465332031,0,20.0080413818359,0,0,0,-85.3980712890625,0,20.2079162597656,0,0,0,0,0,30.7007141113281,0,19.8134765625,0,-1.33453369140625,0,0,-65.0641937255859,0,31.4930267333984,0,19.950813293457,0,0,0,0,0,29.914192199707,0,0,-96.1787643432617,0,30.9692077636719,0,21.324348449707,0,31.5483322143555,0,0,14.4308319091797,0,0,-77.8662567138672,0,20.7356338500977,0,0,29.9802398681641,0,20.2040634155273,0,0,-84.0426177978516,0,21.3814697265625,0,0,32.4104919433594,0,0,0,0,21.6423797607422,0,15.5458221435547,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,17.6514663696289,0,21.5161819458008,0,0,0,0,31.2885055541992,0,19.6828308105469,0,-83.3798980712891,0,21.256103515625,0,31.2231216430664,0,20.2697601318359,0,0,0,24.0107040405273,0,0,-87.9022064208984,0,32.1459732055664,0,20.5311279296875,0,0,31.480712890625,0,-93.9986038208008,0,31.6201477050781,0,0,21.3211288452148,0,31.094482421875,0,13.7109680175781,0,0,-75.4382629394531,0,21.3120422363281,0,0,0,0,0,31.8199768066406,0,0,0,0,0,21.3816604614258,0,0,-83.1050186157227,0,20.7927169799805,31.4892730712891,20.9921417236328,0,0,0,-82.3943328857422,0,19.8795318603516,0,30.8239440917969,0,0,0,21.1246643066406,0,-9.84323120117188,0,0,-52.4036178588867,0,0,31.9446563720703,0,21.5204620361328,0,30.1147918701172,0,0,-91.7787170410156,0,0,0,32.4160232543945,0,0,0,0,21.3857803344727,0,32.4717025756836,0,0,-93.4219207763672,0,31.4919204711914,0,21.7744522094727,0,30.0478363037109,0,15.6123580932617,0,0,-79.0495681762695,0,0,20.8656387329102,0,31.2308502197266,0,0,20.0148468017578,0,-83.2622604370117,0,0,0,0,20.7391357421875,0,32.4661865234375,0,0,21.5840377807617,0,-82.2650375366211,0,20.9938278198242,0,0,32.6024703979492,0,21.4476318359375,0,22.6376724243164,0,0,-85.3425521850586,0,0,0,0,31.5533828735352,0,21.191780090332,0,32.4091720581055,0,-93.4264831542969,0,31.7480087280273,0,20.7265625,0,31.5533676147461,0,0,-92.6827621459961,0,0,30.8947448730469,0,20.0750885009766,0,31.9462509155273,0,0,19.3513107299805,0,0,-80.8769683837891,0,0,20.4765777587891,0,0,31.9435577392578,0,21.4532241821289,0,-83.3884124755859,0,0,21.247917175293,0,32.4643402099609,0,21.4503402709961,0,-82.6401824951172,0,21.0509719848633,0,0,0,32.0104675292969,0,0,21.3814697265625,0,23.4182815551758,0,0,-84.5417327880859,0,31.6148300170898,0,0,0,20.7909851074219,0,0,29.5801162719727,0,-93.7270278930664,0,0,0,0,31.4797668457031,0,0,20.0079574584961,0,29.0554504394531,0,15.7410888671875,0,0,-80.6396408081055,0,0,20.1985092163086,0,31.6757965087891,0,20.0693206787109,0,-84.2076416015625,0,20.5305252075195,0,0,0,0,31.0246276855469,0,20.593017578125,0,20.0678024291992,0,0,-83.2288131713867,0,0,0,0,31.0880432128906,0,20.5287704467773,0,0,30.4352951049805,0,-94.4468994140625,0,31.2833786010742,0,0,0,20.398193359375,0,32.2039794921875,0,12.4585113525391,0,0,-75.0286636352539,0,0,0,0,20.7908477783203,0,0,0,0,0,31.4816360473633,0,20.9214401245117,0,-83.6878204345703,0,20.0705947875977,0,30.4305572509766,0,0,0,0,20.2022705078125,0,0,-84.8002014160156,0,21.1138229370117,0,31.3513717651367,0,0,21.3855743408203,0,0,0,0,25.773551940918,0,0,0,-88.2138671875,0,31.9332656860352,0,21.2451095581055,0,32.6536178588867,0,0,-93.566520690918,0,0,31.6057891845703,0,20.3927230834961,0,32.7853393554688,0,0,0,11.1477813720703,0,0,0,-72.5256500244141,0,21.5736999511719,0,0,0,0,0,31.4734802246094,0,19.4759140014648,0,0,-81.9618072509766,0,19.8698196411133,0,32.4604187011719,0,0,21.5737533569336,0,-82.4946899414062,0,0,0,0,21.4427947998047,0,0,0,0,32.71875,0,0,21.0473709106445,0,-82.8806762695312,0,0,21.2458724975586,0,32.6543197631836,0,0,0,21.6375122070312,0,0,22.6874160766602,0,0,-83.4698486328125,0,0,0,0,32.7199096679688,0,21.3107986450195,0,0,29.4402236938477,0,0,-90.0282287597656,0,0,31.2773971557617,0,21.1796798706055,0,0,31.4728240966797,0,0,-93.1087188720703,0,0,31.4034576416016,0,0,0,0,0,21.6350479125977,0,32.4526672363281,0,13.7027740478516,0,0,-75.3291625976562,0,21.1757659912109,0,32.256462097168,0,21.2420425415039,0,0,0,-83.3279037475586,0,21.2422714233398,0,32.5847702026367,0,21.8312301635742,0,0,-83.0661773681641,0,0,0,0,21.4383010864258,0,31.9286880493164,0,19.9963531494141,0,-83.1311492919922,0,0,21.3067855834961,0,32.6490478515625,0,21.7660675048828,0,0,0,0,25.4372787475586,0,0,-87.3257064819336,0,30.4857330322266,0,20.1920852661133,31.7971267700195,0,-95.3431549072266,0,30.8789367675781,0,0,20.4547424316406,0,0,30.7474136352539,0,18.0949020385742,0,0,-81.0317993164062,0,0,0,0,20.1925659179688,0,0,0,28.1529388427734,0,0,0,0,0.366752624511719,0,0,0,0,0,0,0,0,0],"filename":[null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,null,null,null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmp9VHL0S/file3d9a5b127fce.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    784.081    798.3115    813.9870    809.5425
#>    compute_pi0(m * 10)   7874.758   7902.5275   8253.3361   7923.3860
#>   compute_pi0(m * 100)  78940.003  79094.2415  80146.8546  79476.1550
#>         compute_pi1(m)    161.092    258.9700    668.9269    272.5070
#>    compute_pi1(m * 10)   1263.088   1294.0955   6784.7581   1392.3520
#>   compute_pi1(m * 100)  12688.115  12954.2280  32596.6688  19476.9880
#>  compute_pi1(m * 1000) 252054.637 264681.6210 335362.5780 363619.1195
#>          uq        max neval
#>     819.146    887.312    20
#>    8002.584  13442.251    20
#>   81547.813  82352.869    20
#>     288.453   8377.408    20
#>    1432.961 109729.924    20
#>   23080.156 121601.013    20
#>  367914.915 464883.048    20
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
#>   memory_copy1(n) 5649.53795 5193.73487 679.251537 3977.07875 3458.61101
#>   memory_copy2(n)   99.72415   94.71205  13.720759   72.63477   64.15466
#>  pre_allocate1(n)   21.49810   19.78091   4.028627   15.21260   13.08536
#>  pre_allocate2(n)  210.83247  193.99309  26.252045  149.85993  129.69234
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  105.680260    10
#>    3.469826    10
#>    2.089019    10
#>    4.914202    10
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
#>  f1(df) 250.5459 248.0996 80.87868 247.9486 67.58851 29.14191     5
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
