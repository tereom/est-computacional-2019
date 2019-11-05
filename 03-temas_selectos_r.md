
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
#> 1   1  0.7807090 2.615928 3.181351 2.707803
#> 2   2  0.5957949 3.798506 4.556775 5.098961
#> 3   3  0.5942233 1.838603 3.721776 4.539742
#> 4   4  0.2824310 1.833103 1.085438 2.717865
#> 5   5 -0.8710511 2.523250 2.122870 2.952852
#> 6   6  1.3655622 1.728831 2.481775 6.300451
#> 7   7  0.5116074 1.932561 3.230643 5.917578
#> 8   8 -0.3437480 1.882218 2.807233 5.703823
#> 9   9  1.6151206 2.795374 2.332938 3.893688
#> 10 10 -1.1005643 2.552770 3.595606 3.523073
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.3430085
mean(df$b)
#> [1] 2.350115
mean(df$c)
#> [1] 2.91164
mean(df$d)
#> [1] 4.335583
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.3430085 2.3501146 2.9116405 4.3355834
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
#> [1] 0.3430085 2.3501146 2.9116405 4.3355834
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
#> [1] 5.5000000 0.3430085 2.3501146 2.9116405 4.3355834
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
#> [1] 5.5000000 0.5529154 2.2279058 2.9942920 4.2167148
col_describe(df, mean)
#> [1] 5.5000000 0.3430085 2.3501146 2.9116405 4.3355834
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
#> 5.5000000 0.3430085 2.3501146 2.9116405 4.3355834
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
#>   4.452   0.216   4.673
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.024   0.000   0.612
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
#>  14.725   1.244  11.492
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
#>   0.151   0.000   0.151
plyr_st
#>    user  system elapsed 
#>   4.757   0.003   4.763
est_l_st
#>    user  system elapsed 
#>  75.600   1.407  77.049
est_r_st
#>    user  system elapsed 
#>   0.422   0.000   0.422
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

<!--html_preserve--><div id="htmlwidget-6f9c60b0346a08ae7e03" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-6f9c60b0346a08ae7e03">{"x":{"message":{"prof":{"time":[1,1,1,2,2,3,3,3,3,4,4,5,5,5,6,6,7,7,8,8,8,9,9,9,9,9,9,10,10,11,11,12,12,12,13,13,13,13,13,14,14,14,15,15,16,16,16,17,17,17,17,17,18,18,18,18,18,19,19,20,20,21,21,22,22,23,23,23,23,24,24,25,25,25,25,25,26,26,26,27,27,28,28,28,29,29,30,30,30,31,31,31,32,32,32,32,32,32,33,33,34,34,34,34,34,35,35,36,36,36,36,36,36,37,37,38,38,38,38,38,39,39,39,40,40,40,41,41,41,42,42,42,43,43,43,44,44,44,45,45,46,46,46,47,47,48,48,49,49,49,49,50,50,51,51,51,52,52,53,53,54,54,54,54,55,55,55,56,56,57,57,57,57,57,58,58,58,58,58,59,59,60,60,61,61,61,62,62,62,63,63,64,64,64,65,65,66,66,66,67,67,67,68,68,68,69,69,70,70,70,70,71,71,71,71,71,72,72,72,73,73,74,74,74,74,74,74,75,75,76,76,76,76,77,77,77,78,78,79,79,80,80,80,80,80,81,81,82,82,82,83,83,84,84,84,85,85,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,103,103,104,104,105,105,105,105,105,106,106,107,107,107,108,108,109,109,109,109,109,109,110,110,111,111,111,111,112,112,112,113,113,113,114,114,114,115,115,115,116,116,117,117,117,117,118,118,119,119,119,120,120,121,121,122,122,122,122,122,122,123,123,124,124,125,125,126,126,126,126,127,127,128,128,129,129,129,129,129,129,130,130,131,131,132,132,132,133,133,134,134,134,135,135,135,135,136,136,137,137,138,138,138,138,138,138,139,139,140,140,141,141,141,142,142,143,143,143,143,143,144,144,145,145,145,146,146,147,147,148,148,148,148,148,148,149,149,150,150,150,151,151,151,152,152,152,152,152,153,153,153,153,153,154,154,154,154,155,155,156,156,157,157,158,158,158,158,158,159,159,160,160,160,161,161,161,162,162,163,163,163,164,164,165,165,166,166,167,167,167,168,168,169,169,170,170,171,171,171,172,172,172,173,173,174,174,174,174,175,175,175,175,176,176,176,177,177,178,178,178,178,178,178,179,179,180,180,181,181,181,181,181,182,182,182,183,183,183,184,184,184,185,185,185,185,186,186,186,187,187,188,188,188,188,189,189,189,189,189,190,190,191,191,192,192,192,192,192,193,193,194,194,195,195,195,196,196,197,197,197,197,197,198,198,199,199,200,200,200,201,201,202,202,203,203,203,204,204,204,204,204,205,205,205,206,206,206,206,206,207,207,207,207,207,207,208,209,209,210,210,210,211,211,212,212,213,213,214,214,214,215,215,215,216,216,217,217,218,218,218,219,219,220,220,220,221,221,221,222,222,223,223,224,224,224,224,224,225,225,225,225,225,226,226,227,227,227,227,227,228,228,229,229,229,229,229,230,230,230,231,231,232,232,232,233,233,233,233,233,233,234,234,235,235,235,235,235,236,236,237,237,238,238,238,239,239,239,240,240,241,241,242,242,242,243,243,244,244,244,244,244,245,245,246,246,246,246,246,247,247,247,248,248,249,249,250,250,251,251,252,252,252,253,253,254,254,255,255,256,256,257,257,257,257,257,258,258,259,259,259,260,260,260,260,260,260,261,261,262,262,262,262,262,263,263,264,264,264,265,265,266,266,267,267,268,268,268,269,269,269,269,269,269,270,270,271,271,271,271,272,272,273,273,273,274,274,274,274,275,275,276,276,276,276,276,276,277,277,277,278,278,278,279,279,280,280,280,281,281,281,282,282,283,283,283,283,283,283,284,284,284,285,285,286,286,286,286,286,286,287,287,288,288,288,289,289,290,290,291,291,291,292,292,293,293,294,294,295,295,296,296,297,297,297,298,298,298,298,298,299,299,299,299,300,300,301,301,302,302,302,303,303,304,304,304,305,305,305,306,306,306,306,307,307,307,308,308,309,309,309,309,310,310,310,311,311,312,312,312,312,312,312,313,313,313,313,314,314,314,315,315,315,315,315,316,316,316],"depth":[3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1],"label":["==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","dim","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sum","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame","as.data.frame.integer","as.data.frame","data.frame"],"filenum":[null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,null,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,null,1,1,1,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,null,null,1],"linenum":[null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,null,11,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,11,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,10,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,null,11,9,9,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,null,13,null,null,13],"memalloc":[63.9787673950195,63.9787673950195,63.9787673950195,84.0481033325195,84.0481033325195,110.159927368164,110.159927368164,110.159927368164,110.159927368164,126.164947509766,126.164947509766,146.301460266113,146.301460266113,146.301460266113,47.0571517944336,47.0571517944336,76.3828506469727,76.3828506469727,96.4570388793945,96.4570388793945,96.4570388793945,124.534378051758,124.534378051758,124.534378051758,124.534378051758,124.534378051758,124.534378051758,143.230895996094,143.230895996094,50.072868347168,50.072868347168,70.0850296020508,70.0850296020508,70.0850296020508,100.263114929199,100.263114929199,100.263114929199,100.263114929199,100.263114929199,117.32381439209,117.32381439209,117.32381439209,144.54923248291,144.54923248291,146.320701599121,146.320701599121,146.320701599121,70.6714477539062,70.6714477539062,70.6714477539062,70.6714477539062,70.6714477539062,90.0216903686523,90.0216903686523,90.0216903686523,90.0216903686523,90.0216903686523,119.208335876465,119.208335876465,137.901725769043,137.901725769043,44.4389190673828,44.4389190673828,63.5306091308594,63.5306091308594,93.7082443237305,93.7082443237305,93.7082443237305,93.7082443237305,114.174102783203,114.174102783203,143.42894744873,143.42894744873,143.42894744873,143.42894744873,143.42894744873,146.315353393555,146.315353393555,146.315353393555,66.8738708496094,66.8738708496094,86.8182067871094,86.8182067871094,86.8182067871094,117.451324462891,117.451324462891,135.759643554688,135.759643554688,135.759643554688,137.026092529297,137.026092529297,137.026092529297,58.7429885864258,58.7429885864258,58.7429885864258,58.7429885864258,58.7429885864258,58.7429885864258,88.3279418945312,88.3279418945312,107.553436279297,107.553436279297,107.553436279297,107.553436279297,107.553436279297,135.500396728516,135.500396728516,146.329772949219,146.329772949219,146.329772949219,146.329772949219,146.329772949219,146.329772949219,61.2374496459961,61.2374496459961,81.118049621582,81.118049621582,81.118049621582,81.118049621582,81.118049621582,110.907279968262,110.907279968262,110.907279968262,129.736351013184,129.736351013184,129.736351013184,146.333656311035,146.333656311035,146.333656311035,55.3327865600586,55.3327865600586,55.3327865600586,85.1895370483398,85.1895370483398,85.1895370483398,104.15461730957,104.15461730957,104.15461730957,132.366188049316,132.366188049316,146.2705078125,146.2705078125,146.2705078125,55.4053573608398,55.4053573608398,74.3016510009766,74.3016510009766,104.215087890625,104.215087890625,104.215087890625,104.215087890625,122.847557067871,122.847557067871,146.333534240723,146.333534240723,146.333534240723,47.7932052612305,47.7932052612305,77.1191558837891,77.1191558837891,95.947998046875,95.947998046875,95.947998046875,95.947998046875,123.958618164062,123.958618164062,123.958618164062,142.525840759277,142.525840759277,48.385612487793,48.385612487793,48.385612487793,48.385612487793,48.385612487793,67.2165374755859,67.2165374755859,67.2165374755859,67.2165374755859,67.2165374755859,96.8635482788086,96.8635482788086,115.49063873291,115.49063873291,142.582557678223,142.582557678223,142.582557678223,146.322898864746,146.322898864746,146.322898864746,68.2740173339844,68.2740173339844,87.2960586547852,87.2960586547852,87.2960586547852,116.687629699707,116.687629699707,134.531852722168,134.531852722168,134.531852722168,146.275123596191,146.275123596191,146.275123596191,60.4584808349609,60.4584808349609,60.4584808349609,89.7164916992188,89.7164916992188,107.898094177246,107.898094177246,107.898094177246,107.898094177246,138.20637512207,138.20637512207,138.20637512207,138.20637512207,138.20637512207,146.275695800781,146.275695800781,146.275695800781,65.6504440307617,65.6504440307617,85.5922012329102,85.5922012329102,85.5922012329102,85.5922012329102,85.5922012329102,85.5922012329102,114.981285095215,114.981285095215,133.151763916016,133.151763916016,133.151763916016,133.151763916016,146.271339416504,146.271339416504,146.271339416504,58.7583160400391,58.7583160400391,88.1559066772461,88.1559066772461,108.097770690918,108.097770690918,108.097770690918,108.097770690918,108.097770690918,138.472373962402,138.472373962402,146.278312683105,146.278312683105,146.278312683105,66.7565460205078,66.7565460205078,86.7646255493164,86.7646255493164,86.7646255493164,117.470085144043,117.470085144043,137.604156494141,137.604156494141,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,146.327995300293,42.7565078735352,42.7565078735352,42.7565078735352,42.7565078735352,42.7565078735352,42.7565078735352,65.6557235717773,65.6557235717773,65.6557235717773,65.6557235717773,85.6635437011719,85.6635437011719,116.229965209961,116.229965209961,116.229965209961,116.229965209961,116.229965209961,135.45580291748,135.45580291748,44.1355361938477,44.1355361938477,44.1355361938477,63.2284774780273,63.2284774780273,92.746940612793,92.746940612793,92.746940612793,92.746940612793,92.746940612793,92.746940612793,112.755989074707,112.755989074707,140.632331848145,140.632331848145,140.632331848145,140.632331848145,146.275451660156,146.275451660156,146.275451660156,69.3937759399414,69.3937759399414,69.3937759399414,88.7482757568359,88.7482757568359,88.7482757568359,117.085746765137,117.085746765137,117.085746765137,135.839668273926,135.839668273926,43.9422988891602,43.9422988891602,43.9422988891602,43.9422988891602,63.1018829345703,63.1018829345703,92.4872283935547,92.4872283935547,92.4872283935547,111.904182434082,111.904182434082,139.65308380127,139.65308380127,146.279022216797,146.279022216797,146.279022216797,146.279022216797,146.279022216797,146.279022216797,68.4144744873047,68.4144744873047,88.2183303833008,88.2183303833008,118.396415710449,118.396415710449,137.812721252441,137.812721252441,137.812721252441,137.812721252441,45.7169342041016,45.7169342041016,65.3320159912109,65.3320159912109,94.9134063720703,94.9134063720703,94.9134063720703,94.9134063720703,94.9134063720703,94.9134063720703,114.859428405762,114.859428405762,144.640266418457,144.640266418457,44.2752151489258,44.2752151489258,44.2752151489258,73.0742797851562,73.0742797851562,93.0754776000977,93.0754776000977,93.0754776000977,122.463172912598,122.463172912598,122.463172912598,122.463172912598,141.023361206055,141.023361206055,50.7681579589844,50.7681579589844,69.3979721069336,69.3979721069336,69.3979721069336,69.3979721069336,69.3979721069336,69.3979721069336,98.5298385620117,98.5298385620117,115.716537475586,115.716537475586,144.255416870117,144.255416870117,144.255416870117,44.2772216796875,44.2772216796875,73.146240234375,73.146240234375,73.146240234375,73.146240234375,73.146240234375,93.0934982299805,93.0934982299805,123.14274597168,123.14274597168,123.14274597168,142.164642333984,142.164642333984,51.8895492553711,51.8895492553711,71.7010116577148,71.7010116577148,71.7010116577148,71.7010116577148,71.7010116577148,71.7010116577148,101.221221923828,101.221221923828,120.965621948242,120.965621948242,120.965621948242,146.290519714355,146.290519714355,146.290519714355,48.8071823120117,48.8071823120117,48.8071823120117,48.8071823120117,48.8071823120117,78.2636108398438,78.2636108398438,78.2636108398438,78.2636108398438,78.2636108398438,97.7533645629883,97.7533645629883,97.7533645629883,97.7533645629883,126.68839263916,126.68839263916,144.138946533203,144.138946533203,52.8753890991211,52.8753890991211,71.5145874023438,71.5145874023438,71.5145874023438,71.5145874023438,71.5145874023438,100.963363647461,100.963363647461,119.990577697754,119.990577697754,119.990577697754,146.30069732666,146.30069732666,146.30069732666,47.2361450195312,47.2361450195312,76.8943099975586,76.8943099975586,76.8943099975586,96.1125335693359,96.1125335693359,126.744926452637,126.744926452637,145.443077087402,145.443077087402,54.6562118530273,54.6562118530273,54.6562118530273,73.878303527832,73.878303527832,104.12020111084,104.12020111084,124.588729858398,124.588729858398,146.303802490234,146.303802490234,146.303802490234,54.385986328125,54.385986328125,54.385986328125,84.2319717407227,84.2319717407227,104.236312866211,104.236312866211,104.236312866211,104.236312866211,134.607559204102,134.607559204102,134.607559204102,134.607559204102,146.284622192383,146.284622192383,146.284622192383,63.1106948852539,63.1106948852539,82.9280776977539,82.9280776977539,82.9280776977539,82.9280776977539,82.9280776977539,82.9280776977539,113.428398132324,113.428398132324,133.499397277832,133.499397277832,44.0931854248047,44.0931854248047,44.0931854248047,44.0931854248047,44.0931854248047,63.5125503540039,63.5125503540039,63.5125503540039,93.4377670288086,93.4377670288086,93.4377670288086,113.901969909668,113.901969909668,113.901969909668,143.881614685059,143.881614685059,143.881614685059,143.881614685059,44.4883499145508,44.4883499145508,44.4883499145508,73.0178375244141,73.0178375244141,93.1505279541016,93.1505279541016,93.1505279541016,93.1505279541016,123.781608581543,123.781608581543,123.781608581543,123.781608581543,123.781608581543,143.790588378906,143.790588378906,53.275390625,53.275390625,72.9517440795898,72.9517440795898,72.9517440795898,72.9517440795898,72.9517440795898,103.714767456055,103.714767456055,123.522987365723,123.522987365723,146.285087585449,146.285087585449,146.285087585449,51.5759048461914,51.5759048461914,80.8959655761719,80.8959655761719,80.8959655761719,80.8959655761719,80.8959655761719,101.096649169922,101.096649169922,131.070373535156,131.070373535156,146.287826538086,146.287826538086,146.287826538086,60.6938781738281,60.6938781738281,80.8912200927734,80.8912200927734,110.870544433594,110.870544433594,110.870544433594,131.135124206543,131.135124206543,131.135124206543,131.135124206543,131.135124206543,146.28636932373,146.28636932373,146.28636932373,57.9744110107422,57.9744110107422,57.9744110107422,57.9744110107422,57.9744110107422,87.4187927246094,87.4187927246094,87.4187927246094,87.4187927246094,87.4187927246094,87.4187927246094,104.862747192383,131.621002197266,131.621002197266,146.313140869141,146.313140869141,146.313140869141,58.8264923095703,58.8264923095703,77.9809875488281,77.9809875488281,107.101661682129,107.101661682129,127.36742401123,127.36742401123,127.36742401123,146.318649291992,146.318649291992,146.318649291992,55.8750762939453,55.8750762939453,86.5692901611328,86.5692901611328,105.78874206543,105.78874206543,105.78874206543,135.959098815918,135.959098815918,146.321716308594,146.321716308594,146.321716308594,65.3868255615234,65.3868255615234,65.3868255615234,85.5868606567383,85.5868606567383,116.348609924316,116.348609924316,136.61434173584,136.61434173584,136.61434173584,136.61434173584,136.61434173584,45.8439331054688,45.8439331054688,45.8439331054688,45.8439331054688,45.8439331054688,64.5356521606445,64.5356521606445,92.9994201660156,92.9994201660156,92.9994201660156,92.9994201660156,92.9994201660156,112.937423706055,112.937423706055,141.86009979248,141.86009979248,141.86009979248,141.86009979248,141.86009979248,146.321556091309,146.321556091309,146.321556091309,70.3071670532227,70.3071670532227,90.2433471679688,90.2433471679688,90.2433471679688,119.034057617188,119.034057617188,119.034057617188,119.034057617188,119.034057617188,119.034057617188,138.844039916992,138.844039916992,46.8959350585938,46.8959350585938,46.8959350585938,46.8959350585938,46.8959350585938,66.7633590698242,66.7633590698242,96.0815048217773,96.0815048217773,116.155464172363,116.155464172363,116.155464172363,145.994750976562,145.994750976562,145.994750976562,44.3376388549805,44.3376388549805,73.4523315429688,73.4523315429688,93.3210220336914,93.3210220336914,93.3210220336914,122.500473022461,122.500473022461,142.367752075195,142.367752075195,142.367752075195,142.367752075195,142.367752075195,51.6203689575195,51.6203689575195,70.8323974609375,70.8323974609375,70.8323974609375,70.8323974609375,70.8323974609375,98.8979415893555,98.8979415893555,98.8979415893555,116.929290771484,116.929290771484,145.912544250488,145.912544250488,45.1264266967773,45.1264266967773,74.764274597168,74.764274597168,95.092155456543,95.092155456543,95.092155456543,124.926025390625,124.926025390625,144.337005615234,144.337005615234,54.3756103515625,54.3756103515625,74.5071487426758,74.5071487426758,104.998428344727,104.998428344727,104.998428344727,104.998428344727,104.998428344727,125.655120849609,125.655120849609,146.311264038086,146.311264038086,146.311264038086,55.0303955078125,55.0303955078125,55.0303955078125,55.0303955078125,55.0303955078125,55.0303955078125,85.718147277832,85.718147277832,105.25749206543,105.25749206543,105.25749206543,105.25749206543,105.25749206543,136.009010314941,136.009010314941,146.303642272949,146.303642272949,146.303642272949,65.6536254882812,65.6536254882812,85.5872344970703,85.5872344970703,115.683044433594,115.683044433594,136.010566711426,136.010566711426,136.010566711426,45.8513641357422,45.8513641357422,45.8513641357422,45.8513641357422,45.8513641357422,45.8513641357422,65.7203063964844,65.7203063964844,96.604248046875,96.604248046875,96.604248046875,96.604248046875,117.259407043457,117.259407043457,146.305847167969,146.305847167969,146.305847167969,47.4914779663086,47.4914779663086,47.4914779663086,47.4914779663086,77.9159622192383,77.9159622192383,98.2435684204102,98.2435684204102,98.2435684204102,98.2435684204102,98.2435684204102,98.2435684204102,127.422859191895,127.422859191895,127.422859191895,146.304809570312,146.304809570312,146.304809570312,57.194221496582,57.194221496582,77.0596542358398,77.0596542358398,77.0596542358398,108.266464233398,108.266464233398,108.266464233398,128.6552734375,128.6552734375,146.292053222656,146.292053222656,146.292053222656,146.292053222656,146.292053222656,146.292053222656,59.2935562133789,59.2935562133789,59.2935562133789,90.3037185668945,90.3037185668945,110.430908203125,110.430908203125,110.430908203125,110.430908203125,110.430908203125,110.430908203125,140.851928710938,140.851928710938,146.293769836426,146.293769836426,146.293769836426,70.83349609375,70.83349609375,91.2228393554688,91.2228393554688,120.529624938965,120.529624938965,120.529624938965,140.263137817383,140.263137817383,49.8539276123047,49.8539276123047,69.3911514282227,69.3911514282227,99.9421997070312,99.9421997070312,120.39803314209,120.39803314209,146.294860839844,146.294860839844,146.294860839844,50.9032821655273,50.9032821655273,50.9032821655273,50.9032821655273,50.9032821655273,81.0608596801758,81.0608596801758,81.0608596801758,81.0608596801758,101.516052246094,101.516052246094,132.459999084473,132.459999084473,146.293395996094,146.293395996094,146.293395996094,62.7705001831055,62.7705001831055,82.7664184570312,82.7664184570312,82.7664184570312,112.66178894043,112.66178894043,112.66178894043,131.739768981934,131.739768981934,131.739768981934,131.739768981934,146.294052124023,146.294052124023,146.294052124023,57.6385498046875,57.6385498046875,87.0097045898438,87.0097045898438,87.0097045898438,87.0097045898438,107.464401245117,107.464401245117,107.464401245117,138.343307495117,138.343307495117,146.276191711426,146.276191711426,146.276191711426,146.276191711426,146.276191711426,146.276191711426,67.8013305664062,67.8013305664062,67.8013305664062,67.8013305664062,88.1904373168945,88.1904373168945,88.1904373168945,113.393218994141,113.393218994141,113.393218994141,113.393218994141,113.393218994141,113.760940551758,113.760940551758,113.760940551758],"meminc":[0,0,0,20.0693359375,0,26.1118240356445,0,0,0,16.0050201416016,0,20.1365127563477,0,0,-99.2443084716797,0,29.3256988525391,0,20.0741882324219,0,0,28.0773391723633,0,0,0,0,0,18.6965179443359,0,-93.1580276489258,0,20.0121612548828,0,0,30.1780853271484,0,0,0,0,17.0606994628906,0,0,27.2254180908203,0,1.77146911621094,0,0,-75.6492538452148,0,0,0,0,19.3502426147461,0,0,0,0,29.1866455078125,0,18.6933898925781,0,-93.4628067016602,0,19.0916900634766,0,30.1776351928711,0,0,0,20.4658584594727,0,29.2548446655273,0,0,0,0,2.88640594482422,0,0,-79.4414825439453,0,19.9443359375,0,0,30.6331176757812,0,18.3083190917969,0,0,1.26644897460938,0,0,-78.2831039428711,0,0,0,0,0,29.5849533081055,0,19.2254943847656,0,0,0,0,27.9469604492188,0,10.8293762207031,0,0,0,0,0,-85.0923233032227,0,19.8805999755859,0,0,0,0,29.7892303466797,0,0,18.8290710449219,0,0,16.5973052978516,0,0,-91.0008697509766,0,0,29.8567504882812,0,0,18.9650802612305,0,0,28.2115707397461,0,13.9043197631836,0,0,-90.8651504516602,0,18.8962936401367,0,29.9134368896484,0,0,0,18.6324691772461,0,23.4859771728516,0,0,-98.5403289794922,0,29.3259506225586,0,18.8288421630859,0,0,0,28.0106201171875,0,0,18.5672225952148,0,-94.1402282714844,0,0,0,0,18.830924987793,0,0,0,0,29.6470108032227,0,18.6270904541016,0,27.0919189453125,0,0,3.74034118652344,0,0,-78.0488815307617,0,19.0220413208008,0,0,29.3915710449219,0,17.8442230224609,0,0,11.7432708740234,0,0,-85.8166427612305,0,0,29.2580108642578,0,18.1816024780273,0,0,0,30.3082809448242,0,0,0,0,8.06932067871094,0,0,-80.6252517700195,0,19.9417572021484,0,0,0,0,0,29.3890838623047,0,18.1704788208008,0,0,0,13.1195755004883,0,0,-87.5130233764648,0,29.397590637207,0,19.9418640136719,0,0,0,0,30.3746032714844,0,7.80593872070312,0,0,-79.5217666625977,0,20.0080795288086,0,0,30.7054595947266,0,20.1340713500977,0,8.72383880615234,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,0,0,0,22.8992156982422,0,0,0,20.0078201293945,0,30.5664215087891,0,0,0,0,19.2258377075195,0,-91.3202667236328,0,0,19.0929412841797,0,29.5184631347656,0,0,0,0,0,20.0090484619141,0,27.8763427734375,0,0,0,5.64311981201172,0,0,-76.8816757202148,0,0,19.3544998168945,0,0,28.3374710083008,0,0,18.7539215087891,0,-91.8973693847656,0,0,0,19.1595840454102,0,29.3853454589844,0,0,19.4169540405273,0,27.7489013671875,0,6.62593841552734,0,0,0,0,0,-77.8645477294922,0,19.8038558959961,0,30.1780853271484,0,19.4163055419922,0,0,0,-92.0957870483398,0,19.6150817871094,0,29.5813903808594,0,0,0,0,0,19.9460220336914,0,29.7808380126953,0,-100.365051269531,0,0,28.7990646362305,0,20.0011978149414,0,0,29.3876953125,0,0,0,18.560188293457,0,-90.2552032470703,0,18.6298141479492,0,0,0,0,0,29.1318664550781,0,17.1866989135742,0,28.5388793945312,0,0,-99.9781951904297,0,28.8690185546875,0,0,0,0,19.9472579956055,0,30.0492477416992,0,0,19.0218963623047,0,-90.2750930786133,0,19.8114624023438,0,0,0,0,0,29.5202102661133,0,19.7444000244141,0,0,25.3248977661133,0,0,-97.4833374023438,0,0,0,0,29.456428527832,0,0,0,0,19.4897537231445,0,0,0,28.9350280761719,0,17.450553894043,0,-91.263557434082,0,18.6391983032227,0,0,0,0,29.4487762451172,0,19.027214050293,0,0,26.3101196289062,0,0,-99.0645523071289,0,29.6581649780273,0,0,19.2182235717773,0,30.6323928833008,0,18.6981506347656,0,-90.786865234375,0,0,19.2220916748047,0,30.2418975830078,0,20.4685287475586,0,21.7150726318359,0,0,-91.9178161621094,0,0,29.8459854125977,0,20.0043411254883,0,0,0,30.3712463378906,0,0,0,11.6770629882812,0,0,-83.1739273071289,0,19.8173828125,0,0,0,0,0,30.5003204345703,0,20.0709991455078,0,-89.4062118530273,0,0,0,0,19.4193649291992,0,0,29.9252166748047,0,0,20.4642028808594,0,0,29.9796447753906,0,0,0,-99.3932647705078,0,0,28.5294876098633,0,20.1326904296875,0,0,0,30.6310806274414,0,0,0,0,20.0089797973633,0,-90.5151977539062,0,19.6763534545898,0,0,0,0,30.7630233764648,0,19.808219909668,0,22.7621002197266,0,0,-94.7091827392578,0,29.3200607299805,0,0,0,0,20.20068359375,0,29.9737243652344,0,15.2174530029297,0,0,-85.5939483642578,0,20.1973419189453,0,29.9793243408203,0,0,20.2645797729492,0,0,0,0,15.1512451171875,0,0,-88.3119583129883,0,0,0,0,29.4443817138672,0,0,0,0,0,17.4439544677734,26.7582550048828,0,14.692138671875,0,0,-87.4866485595703,0,19.1544952392578,0,29.1206741333008,0,20.2657623291016,0,0,18.9512252807617,0,0,-90.4435729980469,0,30.6942138671875,0,19.2194519042969,0,0,30.1703567504883,0,10.3626174926758,0,0,-80.9348907470703,0,0,20.2000350952148,0,30.7617492675781,0,20.2657318115234,0,0,0,0,-90.7704086303711,0,0,0,0,18.6917190551758,0,28.4637680053711,0,0,0,0,19.9380035400391,0,28.9226760864258,0,0,0,0,4.46145629882812,0,0,-76.0143890380859,0,19.9361801147461,0,0,28.7907104492188,0,0,0,0,0,19.8099822998047,0,-91.9481048583984,0,0,0,0,19.8674240112305,0,29.3181457519531,0,20.0739593505859,0,0,29.8392868041992,0,0,-101.657112121582,0,29.1146926879883,0,19.8686904907227,0,0,29.1794509887695,0,19.8672790527344,0,0,0,0,-90.7473831176758,0,19.212028503418,0,0,0,0,28.065544128418,0,0,18.0313491821289,0,28.9832534790039,0,-100.786117553711,0,29.6378479003906,0,20.327880859375,0,0,29.833869934082,0,19.4109802246094,0,-89.9613952636719,0,20.1315383911133,0,30.4912796020508,0,0,0,0,20.6566925048828,0,20.6561431884766,0,0,-91.2808685302734,0,0,0,0,0,30.6877517700195,0,19.5393447875977,0,0,0,0,30.7515182495117,0,10.2946319580078,0,0,-80.650016784668,0,19.9336090087891,0,30.0958099365234,0,20.327522277832,0,0,-90.1592025756836,0,0,0,0,0,19.8689422607422,0,30.8839416503906,0,0,0,20.655158996582,0,29.0464401245117,0,0,-98.8143692016602,0,0,0,30.4244842529297,0,20.3276062011719,0,0,0,0,0,29.1792907714844,0,0,18.881950378418,0,0,-89.1105880737305,0,19.8654327392578,0,0,31.2068099975586,0,0,20.3888092041016,0,17.6367797851562,0,0,0,0,0,-86.9984970092773,0,0,31.0101623535156,0,20.1271896362305,0,0,0,0,0,30.4210205078125,0,5.44184112548828,0,0,-75.4602737426758,0,20.3893432617188,0,29.3067855834961,0,0,19.733512878418,0,-90.4092102050781,0,19.537223815918,0,30.5510482788086,0,20.4558334350586,0,25.8968276977539,0,0,-95.3915786743164,0,0,0,0,30.1575775146484,0,0,0,20.455192565918,0,30.9439468383789,0,13.8333969116211,0,0,-83.5228958129883,0,19.9959182739258,0,0,29.8953704833984,0,0,19.0779800415039,0,0,0,14.5542831420898,0,0,-88.6555023193359,0,29.3711547851562,0,0,0,20.4546966552734,0,0,30.87890625,0,7.93288421630859,0,0,0,0,0,-78.4748611450195,0,0,0,20.3891067504883,0,0,25.2027816772461,0,0,0,0,0.367721557617188,0,0],"filename":[null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>",null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpnnV6o0/file37306ade0264.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    793.708    800.9625    838.9560    813.9820
#>    compute_pi0(m * 10)   7904.628   7976.0800   8389.9895   7993.8235
#>   compute_pi0(m * 100)  79103.220  79785.3830  80164.3442  80085.7955
#>         compute_pi1(m)    170.943    216.4905    310.6077    351.7385
#>    compute_pi1(m * 10)   1350.082   1422.6980   1508.3353   1511.6100
#>   compute_pi1(m * 100)  13414.947  15843.3855  29774.3579  19961.2145
#>  compute_pi1(m * 1000) 342403.510 497222.9930 493555.9857 504466.2395
#>          uq        max neval
#>     872.041   1060.875    20
#>    8065.352  15353.742    20
#>   80387.750  81593.500    20
#>     371.247    397.271    20
#>    1592.429   1635.756    20
#>   27873.528 183432.592    20
#>  507666.435 659620.277    20
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
#>   memory_copy1(n) 5577.08414 4003.98177 736.926136 3553.20514 1623.296382
#>   memory_copy2(n)   91.37151   66.94612  12.592526   61.28994   26.640710
#>  pre_allocate1(n)   18.51780   13.60684   3.999245   12.18168    5.334598
#>  pre_allocate2(n)  189.10702  133.49559  23.661325  122.32153   53.986192
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.000000
#>         max neval
#>  174.428094    10
#>    3.393496    10
#>    2.522824    10
#>    4.893791    10
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
#>    expr      min       lq     mean   median       uq     max neval
#>  f1(df) 385.3424 384.3778 110.3622 365.7472 86.97612 39.0692     5
#>  f2(df)   1.0000   1.0000   1.0000   1.0000  1.00000  1.0000     5
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
