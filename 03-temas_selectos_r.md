
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
#> Error in UseMethod("filter_"): no applicable method for 'filter_' applied to an object of class "c('integer', 'numeric')"
```

Ahora cargamos `dplyr`.


```r
library(dplyr)
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
#>    id          a          b        c        d
#> 1   1  0.7385650  3.1642353 2.837203 3.328741
#> 2   2 -2.2048386 -0.1478677 2.441193 4.417299
#> 3   3  1.9652791  3.2248575 3.914682 4.077762
#> 4   4  0.9927834  2.2226438 4.281867 5.716896
#> 5   5  0.4256914  1.3684208 2.744457 4.615259
#> 6   6  0.9360412  2.1222628 2.954192 4.108557
#> 7   7 -1.4599303  2.2044462 3.443113 3.101983
#> 8   8  1.8247411  2.5117755 3.529052 3.034256
#> 9   9  0.7401788  3.1439644 3.073274 4.203511
#> 10 10 -0.3002762  2.0843238 2.248721 4.768411
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.3658235
mean(df$b)
#> [1] 2.189906
mean(df$c)
#> [1] 3.146775
mean(df$d)
#> [1] 4.137267
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.3658235 2.1899062 3.1467754 4.1372674
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
#> [1] 0.3658235 2.1899062 3.1467754 4.1372674
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
#> [1] 5.5000000 0.3658235 2.1899062 3.1467754 4.1372674
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
#> [1] 5.5000000 0.7393719 2.2135450 3.0137326 4.1560343
col_describe(df, mean)
#> [1] 5.5000000 0.3658235 2.1899062 3.1467754 4.1372674
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
#> 5.5000000 0.3658235 2.1899062 3.1467754 4.1372674
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
#>   4.169   0.152   4.322
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.012   0.012   2.354
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
#>  14.572   0.904  10.991
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
#>   0.122   0.000   0.122
plyr_st
#>    user  system elapsed 
#>   4.162   0.008   4.171
est_l_st
#>    user  system elapsed 
#>  65.131   0.829  65.963
est_r_st
#>    user  system elapsed 
#>   0.398   0.016   0.413
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

<!--html_preserve--><div id="htmlwidget-aae8968d18a7ceff6830" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-aae8968d18a7ceff6830">{"x":{"message":{"prof":{"time":[1,1,1,1,1,2,2,3,3,4,4,5,5,5,6,6,6,7,7,8,8,9,9,10,10,11,11,11,12,12,12,13,13,14,14,15,15,15,16,16,16,17,17,17,18,18,19,19,20,20,20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,27,28,28,28,29,29,29,30,30,30,30,30,31,31,31,31,31,32,32,33,33,33,34,34,34,34,34,34,35,35,35,35,36,36,36,36,36,37,37,37,38,38,38,39,39,39,40,40,41,41,42,42,43,43,43,43,43,44,44,44,45,45,46,46,46,46,46,47,47,48,48,49,49,50,50,51,51,51,52,52,53,53,53,54,54,55,55,55,56,56,56,57,57,58,58,59,59,60,60,61,61,62,62,63,63,63,64,64,65,65,65,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,74,75,75,75,76,76,76,77,77,77,78,78,78,79,79,79,79,79,80,80,80,80,80,81,81,81,82,82,83,83,83,84,84,85,85,85,85,85,86,86,86,87,87,87,87,87,88,88,88,88,88,88,89,89,90,90,90,90,90,91,91,92,92,93,93,94,94,95,95,95,96,96,97,97,97,98,98,99,99,100,100,101,101,102,102,102,102,102,102,103,103,104,104,104,105,105,105,106,106,107,107,108,108,108,108,108,108,109,109,110,110,111,111,111,112,112,113,113,114,114,114,115,115,115,115,115,116,116,116,117,117,117,117,117,118,118,119,119,120,120,120,121,121,121,121,121,122,122,122,122,122,123,123,124,124,125,125,125,126,126,127,127,128,128,129,129,129,130,130,130,131,131,131,132,133,133,133,134,134,135,135,136,136,137,137,138,138,138,139,139,139,140,140,141,141,141,141,141,141,142,142,142,142,142,143,143,143,144,144,144,145,145,145,145,145,146,146,146,146,146,147,147,148,148,149,149,150,150,151,151,151,151,151,151,152,152,153,153,153,154,154,154,154,155,155,156,156,157,157,158,158,159,159,160,160,161,161,162,162,162,163,163,163,164,164,165,165,166,166,166,167,167,167,168,168,168,169,169,170,170,170,170,171,171,172,172,172,172,172,172,173,173,174,174,175,175,175,176,176,176,177,177,177,177,178,178,178,178,179,179,179,179,179,180,181,181,182,182,183,183,183,183,183,184,184,184,184,184,185,185,186,186,187,187,187,188,188,188,188,188,188,189,189,189,189,190,190,190,190,191,191,191,192,192,192,192,192,193,193,194,194,195,195,195,195,195,196,196,197,197,198,198,199,199,200,200,200,201,201,201,202,202,203,203,203,204,204,204,204,204,205,205,205,205,206,206,206,207,207,208,208,209,209,209,210,210,210,210,210,211,211,212,212,213,213,214,214,214,214,214,215,215,215,215,215,216,216,216,216,217,217,217,218,218,218,219,219,220,220,221,221,222,222,223,223,223,223,223,224,224,225,225,225,225,226,226,227,227,227,228,228,228,228,228,229,229,230,230,231,231,232,232,233,233,233,234,234,234,234,235,235,235,236,236,236,236,236,237,237,238,238,238,238,238,239,239,240,240,240,240,240,241,241,241,242,242,243,243,244,244,245,245,245,246,246,247,247,247,247,247,248,248,249,249,249,249,249,250,250,250,251,251,251,252,252,253,253,254,254,254,255,255,256,256,257,257,257,258,259,259,259,259,259,260,260,261,261,261,262,262,263,263,263,264,264,264,265,265,266,266,266,267,267,267,268,268,269,269,270,270,270,271,271,272,272,272,273,273,273,273,273,274,274,274,274,274,275,275,275,275,275,276,276,276,276,276,277,277,278,278,278,278,278,279,279,280,280,280,281,281,282,282,282,283,283,284,284,284,285,285,285,286,286,286,286,287,287,287,288,288,288,289,289,290,290,290,291,291,292,292,292,292,292,293,293,293,293,293],"depth":[5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,4,3,2,1,5,4,3,2,1,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1],"label":["NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","nrow","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyNA","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","length","length","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","n[i] <- nrow(sub_Batting)","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","anyNA","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sum","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","names","names","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","nrow","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","attr","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1],"linenum":[null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,11,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,11,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,11,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,10,10,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,9,9,null,null,null,9,9,10,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,11,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,11,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,13],"memalloc":[59.548942565918,59.548942565918,59.548942565918,59.548942565918,59.548942565918,79.5527801513672,79.5527801513672,105.531867980957,105.531867980957,121.801391601562,121.801391601562,146.333366394043,146.333366394043,146.333366394043,47.3517532348633,47.3517532348633,47.3517532348633,76.8082504272461,76.8082504272461,96.5544662475586,96.5544662475586,126.008369445801,126.008369445801,144.901885986328,144.901885986328,55.9427490234375,55.9427490234375,55.9427490234375,76.412239074707,76.412239074707,76.412239074707,105.873207092285,105.873207092285,124.376235961914,124.376235961914,146.352607727051,146.352607727051,146.352607727051,55.1570129394531,55.1570129394531,55.1570129394531,84.4147491455078,84.4147491455078,84.4147491455078,103.891235351562,103.891235351562,132.424705505371,132.424705505371,146.33226776123,146.33226776123,146.33226776123,63.6280670166016,63.6280670166016,82.3260726928711,82.3260726928711,113.419616699219,113.419616699219,134.214492797852,134.214492797852,47.0281982421875,47.0281982421875,67.6934967041016,67.6934967041016,99.4429321289062,99.4429321289062,99.4429321289062,119.846252441406,119.846252441406,119.846252441406,146.352111816406,146.352111816406,146.352111816406,50.3120498657227,50.3120498657227,50.3120498657227,50.3120498657227,50.3120498657227,80.2233428955078,80.2233428955078,80.2233428955078,80.2233428955078,80.2233428955078,99.7779846191406,99.7779846191406,128.775451660156,128.775451660156,128.775451660156,146.361679077148,146.361679077148,146.361679077148,146.361679077148,146.361679077148,146.361679077148,58.9059906005859,58.9059906005859,58.9059906005859,58.9059906005859,79.2478790283203,79.2478790283203,79.2478790283203,79.2478790283203,79.2478790283203,109.364608764648,109.364608764648,109.364608764648,128.259521484375,128.259521484375,128.259521484375,146.365562438965,146.365562438965,146.365562438965,59.8942642211914,59.8942642211914,91.3886108398438,91.3886108398438,110.679588317871,110.679588317871,137.515472412109,137.515472412109,137.515472412109,137.515472412109,137.515472412109,146.36799621582,146.36799621582,146.36799621582,68.7594146728516,68.7594146728516,89.2854766845703,89.2854766845703,89.2854766845703,89.2854766845703,89.2854766845703,119.075752258301,119.075752258301,139.478179931641,139.478179931641,50.3203506469727,50.3203506469727,70.3265151977539,70.3265151977539,99.0644226074219,99.0644226074219,99.0644226074219,118.218475341797,118.218475341797,146.364646911621,146.364646911621,146.364646911621,49.4678955078125,49.4678955078125,78.7287979125977,78.7287979125977,78.7287979125977,97.3549270629883,97.3549270629883,97.3549270629883,126.015998840332,126.015998840332,145.107383728027,145.107383728027,57.4121704101562,57.4121704101562,77.8835296630859,77.8835296630859,108.256652832031,108.256652832031,127.609245300293,127.609245300293,146.37264251709,146.37264251709,146.37264251709,58.456428527832,58.456428527832,88.6982650756836,88.6982650756836,88.6982650756836,107.470077514648,107.470077514648,135.943359375,135.943359375,135.943359375,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,42.7886657714844,42.7886657714844,42.7886657714844,46.7902450561523,46.7902450561523,46.7902450561523,46.7902450561523,46.7902450561523,67.1964950561523,67.1964950561523,67.1964950561523,67.1964950561523,67.1964950561523,97.442024230957,97.442024230957,97.442024230957,117.969711303711,117.969711303711,146.374145507812,146.374145507812,146.374145507812,52.6936340332031,52.6936340332031,81.8942337036133,81.8942337036133,81.8942337036133,81.8942337036133,81.8942337036133,102.035308837891,102.035308837891,102.035308837891,130.769477844238,130.769477844238,130.769477844238,130.769477844238,130.769477844238,146.38272857666,146.38272857666,146.38272857666,146.38272857666,146.38272857666,146.38272857666,65.4147262573242,65.4147262573242,85.4224014282227,85.4224014282227,85.4224014282227,85.4224014282227,85.4224014282227,115.011322021484,115.011322021484,134.096900939941,134.096900939941,47.6497497558594,47.6497497558594,68.3155517578125,68.3155517578125,98.2934188842773,98.2934188842773,98.2934188842773,118.69361114502,118.69361114502,146.383850097656,146.383850097656,146.383850097656,52.7667388916016,52.7667388916016,83.5374450683594,83.5374450683594,102.623344421387,102.623344421387,129.846839904785,129.846839904785,146.3779296875,146.3779296875,146.3779296875,146.3779296875,146.3779296875,146.3779296875,63.4586410522461,63.4586410522461,83.7994689941406,83.7994689941406,83.7994689941406,115.285346984863,115.285346984863,115.285346984863,136.271270751953,136.271270751953,50.8021011352539,50.8021011352539,71.2724151611328,71.2724151611328,71.2724151611328,71.2724151611328,71.2724151611328,71.2724151611328,102.956039428711,102.956039428711,123.355804443359,123.355804443359,146.383560180664,146.383560180664,146.383560180664,57.4319229125977,57.4319229125977,87.8627777099609,87.8627777099609,108.068885803223,108.068885803223,108.068885803223,139.097381591797,139.097381591797,139.097381591797,139.097381591797,139.097381591797,43.3940505981445,43.3940505981445,43.3940505981445,71.3384399414062,71.3384399414062,71.3384399414062,71.3384399414062,71.3384399414062,90.8195648193359,90.8195648193359,120.144828796387,120.144828796387,138.379974365234,138.379974365234,138.379974365234,51.1337051391602,51.1337051391602,51.1337051391602,51.1337051391602,51.1337051391602,71.2746429443359,71.2746429443359,71.2746429443359,71.2746429443359,71.2746429443359,102.100059509277,102.100059509277,121.452217102051,121.452217102051,146.370407104492,146.370407104492,146.370407104492,55.0725631713867,55.0725631713867,85.7727203369141,85.7727203369141,105.919647216797,105.919647216797,133.732276916504,133.732276916504,133.732276916504,146.331993103027,146.331993103027,146.331993103027,65.5741271972656,65.5741271972656,65.5741271972656,84.4075775146484,114.385589599609,114.385589599609,114.385589599609,134.591896057129,134.591896057129,49.3690719604492,49.3690719604492,69.5742568969727,69.5742568969727,100.997093200684,100.997093200684,120.281623840332,120.281623840332,120.281623840332,146.328102111816,146.328102111816,146.328102111816,55.8654479980469,55.8654479980469,87.2936401367188,87.2936401367188,87.2936401367188,87.2936401367188,87.2936401367188,87.2936401367188,107.698165893555,107.698165893555,107.698165893555,107.698165893555,107.698165893555,136.964347839355,136.964347839355,136.964347839355,146.343849182129,146.343849182129,146.343849182129,71.2267608642578,71.2267608642578,71.2267608642578,71.2267608642578,71.2267608642578,91.9515762329102,91.9515762329102,91.9515762329102,91.9515762329102,91.9515762329102,123.438148498535,123.438148498535,144.437812805176,144.437812805176,59.343391418457,59.343391418457,77.7869720458984,77.7869720458984,106.642135620117,106.642135620117,106.642135620117,106.642135620117,106.642135620117,106.642135620117,125.735160827637,125.735160827637,146.335273742676,146.335273742676,146.335273742676,60.9255447387695,60.9255447387695,60.9255447387695,60.9255447387695,89.8557510375977,89.8557510375977,108.750389099121,108.750389099121,139.386901855469,139.386901855469,44.3916473388672,44.3916473388672,74.8241348266602,74.8241348266602,94.0426712036133,94.0426712036133,122.906982421875,122.906982421875,141.339309692383,141.339309692383,141.339309692383,56.2627944946289,56.2627944946289,56.2627944946289,76.6674041748047,76.6674041748047,107.366050720215,107.366050720215,125.538093566895,125.538093566895,125.538093566895,146.332298278809,146.332298278809,146.332298278809,57.8437652587891,57.8437652587891,57.8437652587891,86.8513336181641,86.8513336181641,105.546112060547,105.546112060547,105.546112060547,105.546112060547,133.295852661133,133.295852661133,146.34814453125,146.34814453125,146.34814453125,146.34814453125,146.34814453125,146.34814453125,67.614387512207,67.614387512207,87.4848098754883,87.4848098754883,116.277549743652,116.277549743652,116.277549743652,135.761260986328,135.761260986328,135.761260986328,47.1156005859375,47.1156005859375,47.1156005859375,47.1156005859375,66.3962707519531,66.3962707519531,66.3962707519531,66.3962707519531,95.7167434692383,95.7167434692383,95.7167434692383,95.7167434692383,95.7167434692383,114.93433380127,145.436378479004,145.436378479004,47.8417434692383,47.8417434692383,76.1126480102539,76.1126480102539,76.1126480102539,76.1126480102539,76.1126480102539,95.1992721557617,95.1992721557617,95.1992721557617,95.1992721557617,95.1992721557617,125.630912780762,125.630912780762,144.324195861816,144.324195861816,57.5493316650391,57.5493316650391,57.5493316650391,76.8945083618164,76.8945083618164,76.8945083618164,76.8945083618164,76.8945083618164,76.8945083618164,106.348449707031,106.348449707031,106.348449707031,106.348449707031,124.318244934082,124.318244934082,124.318244934082,124.318244934082,146.355979919434,146.355979919434,146.355979919434,58.4020309448242,58.4020309448242,58.4020309448242,58.4020309448242,58.4020309448242,89.35693359375,89.35693359375,110.145812988281,110.145812988281,141.888114929199,141.888114929199,141.888114929199,141.888114929199,141.888114929199,46.0718612670898,46.0718612670898,76.4418182373047,76.4418182373047,97.8224945068359,97.8224945068359,129.760299682617,129.760299682617,146.352188110352,146.352188110352,146.352188110352,62.4706268310547,62.4706268310547,62.4706268310547,82.6703262329102,82.6703262329102,114.479995727539,114.479995727539,114.479995727539,135.471702575684,135.471702575684,135.471702575684,135.471702575684,135.471702575684,49.6822814941406,49.6822814941406,49.6822814941406,49.6822814941406,70.6032791137695,70.6032791137695,70.6032791137695,102.545783996582,102.545783996582,123.271499633789,123.271499633789,146.355087280273,146.355087280273,146.355087280273,57.948616027832,57.948616027832,57.948616027832,57.948616027832,57.948616027832,88.3138809204102,88.3138809204102,109.23609161377,109.23609161377,141.110633850098,141.110633850098,45.5531616210938,45.5531616210938,45.5531616210938,45.5531616210938,45.5531616210938,74.6724319458008,74.6724319458008,74.6724319458008,74.6724319458008,74.6724319458008,95.2647323608398,95.2647323608398,95.2647323608398,95.2647323608398,124.71492767334,124.71492767334,124.71492767334,145.179931640625,145.179931640625,145.179931640625,59.6531066894531,59.6531066894531,80.4440460205078,80.4440460205078,112.388122558594,112.388122558594,133.441787719727,133.441787719727,48.2449111938477,48.2449111938477,48.2449111938477,48.2449111938477,48.2449111938477,69.2272109985352,69.2272109985352,100.897941589355,100.897941589355,100.897941589355,100.897941589355,121.947624206543,121.947624206543,146.341484069824,146.341484069824,146.341484069824,57.4273300170898,57.4273300170898,57.4273300170898,57.4273300170898,57.4273300170898,89.1642684936523,89.1642684936523,109.621391296387,109.621391296387,141.162002563477,141.162002563477,45.5598831176758,45.5598831176758,76.8375473022461,76.8375473022461,76.8375473022461,97.4924926757812,97.4924926757812,97.4924926757812,97.4924926757812,127.195877075195,127.195877075195,127.195877075195,146.344161987305,146.344161987305,146.344161987305,146.344161987305,146.344161987305,60.0540237426758,60.0540237426758,79.8581008911133,79.8581008911133,79.8581008911133,79.8581008911133,79.8581008911133,111.596099853516,111.596099853516,132.908569335938,132.908569335938,132.908569335938,132.908569335938,132.908569335938,47.7911834716797,47.7911834716797,47.7911834716797,68.381706237793,68.381706237793,100.116996765137,100.116996765137,121.558288574219,121.558288574219,146.342674255371,146.342674255371,146.342674255371,57.3670501708984,57.3670501708984,89.0376434326172,89.0376434326172,89.0376434326172,89.0376434326172,89.0376434326172,110.412796020508,110.412796020508,142.345947265625,142.345947265625,142.345947265625,142.345947265625,142.345947265625,47.2684936523438,47.2684936523438,47.2684936523438,77.2354202270508,77.2354202270508,77.2354202270508,97.4964904785156,97.4964904785156,128.118217468262,128.118217468262,146.345916748047,146.345916748047,146.345916748047,63.0060043334961,63.0060043334961,84.1863479614258,84.1863479614258,116.447227478027,116.447227478027,116.447227478027,135.264976501465,49.4985122680664,49.4985122680664,49.4985122680664,49.4985122680664,49.4985122680664,69.6260223388672,69.6260223388672,101.422752380371,101.422752380371,101.422752380371,121.484413146973,121.484413146973,146.332412719727,146.332412719727,146.332412719727,56.5802764892578,56.5802764892578,56.5802764892578,87.4593734741211,87.4593734741211,108.438499450684,108.438499450684,108.438499450684,139.974655151367,139.974655151367,139.974655151367,45.4348297119141,45.4348297119141,76.9049682617188,76.9049682617188,97.8193054199219,97.8193054199219,97.8193054199219,129.682563781738,129.682563781738,146.335243225098,146.335243225098,146.335243225098,64.7511672973633,64.7511672973633,64.7511672973633,64.7511672973633,64.7511672973633,85.4687576293945,85.4687576293945,85.4687576293945,85.4687576293945,85.4687576293945,117.856307983398,117.856307983398,117.856307983398,117.856307983398,117.856307983398,139.098243713379,139.098243713379,139.098243713379,139.098243713379,139.098243713379,53.8033752441406,53.8033752441406,74.8484878540039,74.8484878540039,74.8484878540039,74.8484878540039,74.8484878540039,106.776092529297,106.776092529297,128.083290100098,128.083290100098,128.083290100098,43.4458770751953,43.4458770751953,63.8345108032227,63.8345108032227,63.8345108032227,95.8936996459961,95.8936996459961,117.46305847168,117.46305847168,117.46305847168,146.375,146.375,146.375,53.0832443237305,53.0832443237305,53.0832443237305,53.0832443237305,84.8801956176758,84.8801956176758,84.8801956176758,105.334938049316,105.334938049316,105.334938049316,137.393646240234,137.393646240234,135.706954956055,135.706954956055,135.706954956055,72.5549850463867,72.5549850463867,93.5345611572266,93.5345611572266,93.5345611572266,93.5345611572266,93.5345611572266,109.034507751465,109.034507751465,109.034507751465,109.034507751465,109.034507751465],"meminc":[0,0,0,0,0,20.0038375854492,0,25.9790878295898,0,16.2695236206055,0,24.5319747924805,0,0,-98.9816131591797,0,0,29.4564971923828,0,19.7462158203125,0,29.4539031982422,0,18.8935165405273,0,-88.9591369628906,0,0,20.4694900512695,0,0,29.4609680175781,0,18.5030288696289,0,21.9763717651367,0,0,-91.1955947875977,0,0,29.2577362060547,0,0,19.4764862060547,0,28.5334701538086,0,13.9075622558594,0,0,-82.7042007446289,0,18.6980056762695,0,31.0935440063477,0,20.7948760986328,0,-87.1862945556641,0,20.6652984619141,0,31.7494354248047,0,0,20.4033203125,0,0,26.505859375,0,0,-96.0400619506836,0,0,0,0,29.9112930297852,0,0,0,0,19.5546417236328,0,28.9974670410156,0,0,17.5862274169922,0,0,0,0,0,-87.4556884765625,0,0,0,20.3418884277344,0,0,0,0,30.1167297363281,0,0,18.8949127197266,0,0,18.1060409545898,0,0,-86.4712982177734,0,31.4943466186523,0,19.2909774780273,0,26.8358840942383,0,0,0,0,8.85252380371094,0,0,-77.6085815429688,0,20.5260620117188,0,0,0,0,29.7902755737305,0,20.4024276733398,0,-89.157829284668,0,20.0061645507812,0,28.737907409668,0,0,19.154052734375,0,28.1461715698242,0,0,-96.8967514038086,0,29.2609024047852,0,0,18.6261291503906,0,0,28.6610717773438,0,19.0913848876953,0,-87.6952133178711,0,20.4713592529297,0,30.3731231689453,0,19.3525924682617,0,18.7633972167969,0,0,-87.9162139892578,0,30.2418365478516,0,0,18.7718124389648,0,28.4732818603516,0,0,10.4298858642578,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,4.00157928466797,0,0,0,0,20.40625,0,0,0,0,30.2455291748047,0,0,20.5276870727539,0,28.4044342041016,0,0,-93.6805114746094,0,29.2005996704102,0,0,0,0,20.1410751342773,0,0,28.7341690063477,0,0,0,0,15.6132507324219,0,0,0,0,0,-80.9680023193359,0,20.0076751708984,0,0,0,0,29.5889205932617,0,19.085578918457,0,-86.447151184082,0,20.6658020019531,0,29.9778671264648,0,0,20.4001922607422,0,27.6902389526367,0,0,-93.6171112060547,0,30.7707061767578,0,19.0858993530273,0,27.2234954833984,0,16.5310897827148,0,0,0,0,0,-82.9192886352539,0,20.3408279418945,0,0,31.4858779907227,0,0,20.9859237670898,0,-85.4691696166992,0,20.4703140258789,0,0,0,0,0,31.6836242675781,0,20.3997650146484,0,23.0277557373047,0,0,-88.9516372680664,0,30.4308547973633,0,20.2061080932617,0,0,31.0284957885742,0,0,0,0,-95.7033309936523,0,0,27.9443893432617,0,0,0,0,19.4811248779297,0,29.3252639770508,0,18.2351455688477,0,0,-87.2462692260742,0,0,0,0,20.1409378051758,0,0,0,0,30.8254165649414,0,19.3521575927734,0,24.9181900024414,0,0,-91.2978439331055,0,30.7001571655273,0,20.1469268798828,0,27.812629699707,0,0,12.5997161865234,0,0,-80.7578659057617,0,0,18.8334503173828,29.9780120849609,0,0,20.2063064575195,0,-85.2228240966797,0,20.2051849365234,0,31.4228363037109,0,19.2845306396484,0,0,26.0464782714844,0,0,-90.4626541137695,0,31.4281921386719,0,0,0,0,0,20.4045257568359,0,0,0,0,29.2661819458008,0,0,9.37950134277344,0,0,-75.1170883178711,0,0,0,0,20.7248153686523,0,0,0,0,31.486572265625,0,20.9996643066406,0,-85.0944213867188,0,18.4435806274414,0,28.8551635742188,0,0,0,0,0,19.0930252075195,0,20.6001129150391,0,0,-85.4097290039062,0,0,0,28.9302062988281,0,18.8946380615234,0,30.6365127563477,0,-94.9952545166016,0,30.432487487793,0,19.2185363769531,0,28.8643112182617,0,18.4323272705078,0,0,-85.0765151977539,0,0,20.4046096801758,0,30.6986465454102,0,18.1720428466797,0,0,20.7942047119141,0,0,-88.4885330200195,0,0,29.007568359375,0,18.6947784423828,0,0,0,27.7497406005859,0,13.0522918701172,0,0,0,0,0,-78.733757019043,0,19.8704223632812,0,28.7927398681641,0,0,19.4837112426758,0,0,-88.6456604003906,0,0,0,19.2806701660156,0,0,0,29.3204727172852,0,0,0,0,19.2175903320312,30.5020446777344,0,-97.5946350097656,0,28.2709045410156,0,0,0,0,19.0866241455078,0,0,0,0,30.431640625,0,18.6932830810547,0,-86.7748641967773,0,0,19.3451766967773,0,0,0,0,0,29.4539413452148,0,0,0,17.9697952270508,0,0,0,22.0377349853516,0,0,-87.9539489746094,0,0,0,0,30.9549026489258,0,20.7888793945312,0,31.742301940918,0,0,0,0,-95.8162536621094,0,30.3699569702148,0,21.3806762695312,0,31.9378051757812,0,16.5918884277344,0,0,-83.8815612792969,0,0,20.1996994018555,0,31.8096694946289,0,0,20.9917068481445,0,0,0,0,-85.789421081543,0,0,0,20.9209976196289,0,0,31.9425048828125,0,20.725715637207,0,23.0835876464844,0,0,-88.4064712524414,0,0,0,0,30.3652648925781,0,20.9222106933594,0,31.8745422363281,0,-95.5574722290039,0,0,0,0,29.119270324707,0,0,0,0,20.5923004150391,0,0,0,29.4501953125,0,0,20.4650039672852,0,0,-85.5268249511719,0,20.7909393310547,0,31.9440765380859,0,21.0536651611328,0,-85.1968765258789,0,0,0,0,20.9822998046875,0,31.6707305908203,0,0,0,21.0496826171875,0,24.3938598632812,0,0,-88.9141540527344,0,0,0,0,31.7369384765625,0,20.4571228027344,0,31.5406112670898,0,-95.6021194458008,0,31.2776641845703,0,0,20.6549453735352,0,0,0,29.7033843994141,0,0,19.1482849121094,0,0,0,0,-86.2901382446289,0,19.8040771484375,0,0,0,0,31.7379989624023,0,21.3124694824219,0,0,0,0,-85.1173858642578,0,0,20.5905227661133,0,31.7352905273438,0,21.441291809082,0,24.7843856811523,0,0,-88.9756240844727,0,31.6705932617188,0,0,0,0,21.3751525878906,0,31.9331512451172,0,0,0,0,-95.0774536132812,0,0,29.966926574707,0,0,20.2610702514648,0,30.6217269897461,0,18.2276992797852,0,0,-83.3399124145508,0,21.1803436279297,0,32.2608795166016,0,0,18.8177490234375,-85.7664642333984,0,0,0,0,20.1275100708008,0,31.7967300415039,0,0,20.0616607666016,0,24.8479995727539,0,0,-89.7521362304688,0,0,30.8790969848633,0,20.9791259765625,0,0,31.5361557006836,0,0,-94.5398254394531,0,31.4701385498047,0,20.9143371582031,0,0,31.8632583618164,0,16.6526794433594,0,0,-81.5840759277344,0,0,0,0,20.7175903320312,0,0,0,0,32.3875503540039,0,0,0,0,21.2419357299805,0,0,0,0,-85.2948684692383,0,21.0451126098633,0,0,0,0,31.927604675293,0,21.3071975708008,0,0,-84.6374130249023,0,20.3886337280273,0,0,32.0591888427734,0,21.5693588256836,0,0,28.9119415283203,0,0,-93.2917556762695,0,0,0,31.7969512939453,0,0,20.4547424316406,0,0,32.058708190918,0,-1.68669128417969,0,0,-63.151969909668,0,20.9795761108398,0,0,0,0,15.4999465942383,0,0,0,0],"filename":[null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpG6hcfj/file3c533cc0a564.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    800.493    809.5095    876.9397    825.9530
#>    compute_pi0(m * 10)   7965.650   8027.7450   8144.2288   8115.8320
#>   compute_pi0(m * 100)  80098.129  80279.3000  81711.4072  80834.0605
#>         compute_pi1(m)    156.360    199.5275    268.3104    297.0495
#>    compute_pi1(m * 10)   1294.936   1349.9820   7478.0601   1421.8370
#>   compute_pi1(m * 100)  13465.348  15106.6495  20081.6188  20745.5175
#>  compute_pi1(m * 1000) 309915.425 357571.7215 409392.2441 427870.1510
#>           uq        max neval
#>     848.4655   1327.916    20
#>    8247.8695   8434.860    20
#>   82247.4785  89434.717    20
#>     327.2100    335.503    20
#>    1470.7010 122617.441    20
#>   22000.7150  32571.370    20
#>  449332.3935 552304.374    20
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
#>   memory_copy1(n) 5576.06724 4151.56978 540.538669 3712.48684 3373.50628
#>   memory_copy2(n)   90.60491   67.15034   9.729066   59.76965   55.48620
#>  pre_allocate1(n)   19.28646   14.77285   3.407585   13.69312   12.44735
#>  pre_allocate2(n)  186.01581  140.44797  19.480728  126.13419  125.89002
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  85.534719    10
#>   2.469797    10
#>   1.967823    10
#>   3.712769    10
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
#>    expr     min       lq     mean   median       uq      max neval
#>  f1(df) 309.321 299.3038 104.2642 298.4991 81.11038 46.38426     5
#>  f2(df)   1.000   1.0000   1.0000   1.0000  1.00000  1.00000     5
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
