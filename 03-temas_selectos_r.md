
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
#>    id          a         b         c        d
#> 1   1  0.5598207 1.3720047 0.6421145 2.645210
#> 2   2  1.1314733 2.8122895 3.3702844 3.605112
#> 3   3  0.8244794 2.3415211 1.9923689 1.193666
#> 4   4 -0.3886844 1.0820243 3.2171555 2.670401
#> 5   5 -1.2365158 2.0925798 3.2488987 4.604377
#> 6   6 -1.7493224 2.2699081 3.9050203 3.810621
#> 7   7  0.4631877 3.6581228 3.6444229 3.660447
#> 8   8 -1.4091554 1.2304471 3.4405145 5.057545
#> 9   9  0.3065948 3.0581159 2.7483301 3.450854
#> 10 10  0.2481053 0.7824258 2.0184303 4.380003
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.1250017
mean(df$b)
#> [1] 2.069944
mean(df$c)
#> [1] 2.822754
mean(df$d)
#> [1] 3.507823
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.1250017  2.0699439  2.8227540  3.5078234
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
#> [1] -0.1250017  2.0699439  2.8227540  3.5078234
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
#> [1]  5.5000000 -0.1250017  2.0699439  2.8227540  3.5078234
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
#> [1] 5.500000 0.277350 2.181244 3.233027 3.632779
col_describe(df, mean)
#> [1]  5.5000000 -0.1250017  2.0699439  2.8227540  3.5078234
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
#>  5.5000000 -0.1250017  2.0699439  2.8227540  3.5078234
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
#>   3.782   0.132   3.914
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.017   0.004   0.680
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
#>  12.734   0.749   9.747
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
#>   0.113   0.000   0.113
plyr_st
#>    user  system elapsed 
#>   4.081   0.015   4.097
est_l_st
#>    user  system elapsed 
#>  61.097   0.156  61.255
est_r_st
#>    user  system elapsed 
#>    0.39    0.00    0.39
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

<!--html_preserve--><div id="htmlwidget-2778404ac9cfb6f481fc" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-2778404ac9cfb6f481fc">{"x":{"message":{"prof":{"time":[1,1,1,1,1,2,2,2,2,2,2,3,3,3,4,4,4,4,4,4,5,5,5,6,6,6,6,6,6,7,7,8,8,8,9,9,9,10,10,11,11,12,12,13,13,13,14,14,14,15,15,15,15,16,16,16,16,16,17,17,17,18,18,18,18,19,19,19,20,20,20,21,21,22,22,22,22,22,22,23,23,23,24,24,25,25,26,26,27,27,28,28,28,29,29,29,29,29,30,30,31,31,31,31,31,32,32,33,33,34,34,34,34,34,35,35,36,36,37,37,37,38,38,39,39,40,40,40,40,40,41,41,41,42,42,42,43,43,44,44,44,44,44,45,45,45,45,45,46,46,46,47,47,47,48,48,49,49,50,50,50,50,51,51,52,52,53,53,53,54,54,54,55,55,55,56,56,57,57,57,57,58,58,58,59,59,59,60,60,60,60,60,60,61,61,62,62,63,63,64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,74,75,75,75,75,75,76,76,77,77,78,78,79,79,79,80,80,81,81,82,82,83,83,83,83,83,84,84,84,84,84,84,85,85,86,86,86,87,87,87,88,88,88,89,89,90,90,91,91,92,92,93,93,93,93,94,94,95,95,95,95,95,96,96,96,96,96,96,97,97,97,97,98,98,99,99,99,99,100,100,100,100,100,101,101,101,102,102,102,102,103,103,103,103,104,104,104,104,104,104,105,105,106,106,107,107,108,108,108,108,108,109,109,109,110,110,111,111,112,112,113,113,113,113,114,114,114,115,115,116,116,116,116,116,117,117,117,117,118,118,118,119,119,119,120,120,121,121,121,122,122,122,122,122,123,123,124,124,124,125,125,125,126,126,126,127,127,127,128,128,129,129,130,130,130,130,130,131,131,131,132,132,133,133,133,134,134,134,134,134,134,135,135,135,136,136,137,137,138,138,139,139,139,139,140,140,140,141,141,142,142,143,143,143,144,144,144,144,145,145,146,146,147,147,147,148,148,148,148,148,149,149,150,150,151,151,152,152,152,153,153,153,154,154,154,154,155,155,155,156,156,157,157,157,157,158,158,158,158,158,158,159,159,160,160,160,160,160,161,161,162,162,162,162,162,162,163,163,164,164,164,164,165,165,166,166,166,166,166,166,167,167,168,168,169,169,170,170,171,171,171,171,171,171,172,172,173,173,173,173,174,174,174,174,174,175,175,175,176,176,177,177,178,178,179,179,179,180,180,181,181,182,182,183,183,184,184,184,184,184,185,185,185,185,185,186,186,187,187,188,188,188,189,189,190,190,191,191,192,192,193,193,194,194,195,195,196,196,196,197,197,198,198,199,199,200,200,200,200,200,201,201,201,202,202,203,203,203,204,204,205,205,205,206,206,207,207,207,208,208,209,209,209,210,210,210,210,210,210,211,211,211,212,212,213,213,214,214,214,215,215,216,216,217,217,218,218,218,218,218,219,219,220,220,220,220,220,221,221,221,221,222,222,222,223,223,223,223,223,223,224,224,225,225,225,226,226,226,227,227,227,228,228,229,229,230,230,231,231,232,232,232,233,233,234,234,235,235,235,235,235,236,236,237,237,238,238,238,239,239,239,239,239,240,240,241,241,241,241,241,242,242,243,243,243,243,244,244,244,244,244,245,245,245,246,246,247,247,248,248,248,249,249,250,250,250,250,250,251,251,251,251,251,252,252,252,252,252,253,253,253,253,253,253,254,254,255,255,255,256,256,257,257,257,258,258,258,259,259,259,260,260,261,261,262,262,262,262,262,263,263,263,263,264,264,265,265,265,266,266,267,267,267,268,268,268,269,269,270,270,270,271,271,271,272,272,272,272,272,273,273,273,274,274,275,275,275,275,275,276,276,277,277,277,277,277,277,278,278,279,279,279,279,279,279,279,279,279,279,279],"depth":[5,4,3,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,11,10,9,8,7,6,5,4,3,2,1],"label":["NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","pmatch",".deparseOpts","deparse","mode","%in%","deparse","paste","force","as.data.frame.integer","as.data.frame","data.frame"],"filenum":[null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,null,1,1,1,null,null,null,null,null,null,null,null,null,null,1],"linenum":[null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,11,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,null,11,9,9,null,null,null,null,null,null,null,null,null,null,13],"memalloc":[62.6994552612305,62.6994552612305,62.6994552612305,62.6994552612305,62.6994552612305,83.621208190918,83.621208190918,83.621208190918,83.621208190918,83.621208190918,83.621208190918,111.241638183594,111.241638183594,111.241638183594,128.033424377441,128.033424377441,128.033424377441,128.033424377441,128.033424377441,128.033424377441,146.333396911621,146.333396911621,146.333396911621,59.4235763549805,59.4235763549805,59.4235763549805,59.4235763549805,59.4235763549805,59.4235763549805,91.3063278198242,91.3063278198242,111.909698486328,111.909698486328,111.909698486328,141.820625305176,141.820625305176,141.820625305176,45.4499969482422,45.4499969482422,77.8544769287109,77.8544769287109,99.3757553100586,99.3757553100586,129.95386505127,129.95386505127,129.95386505127,146.352638244629,146.352638244629,146.352638244629,64.2737197875977,64.2737197875977,64.2737197875977,64.2737197875977,84.2182159423828,84.2182159423828,84.2182159423828,84.2182159423828,84.2182159423828,115.305847167969,115.305847167969,115.305847167969,135.112747192383,135.112747192383,135.112747192383,135.112747192383,48.1429595947266,48.1429595947266,48.1429595947266,68.6143188476562,68.6143188476562,68.6143188476562,100.166877746582,100.166877746582,120.635643005371,120.635643005371,120.635643005371,120.635643005371,120.635643005371,120.635643005371,146.347290039062,146.347290039062,146.347290039062,54.6417007446289,54.6417007446289,85.6691131591797,85.6691131591797,106.920989990234,106.920989990234,138.544998168945,138.544998168945,146.352142333984,146.352142333984,146.352142333984,72.6833801269531,72.6833801269531,72.6833801269531,72.6833801269531,72.6833801269531,93.8744659423828,93.8744659423828,124.248481750488,124.248481750488,124.248481750488,124.248481750488,124.248481750488,144.062995910645,144.062995910645,58.0522384643555,58.0522384643555,78.1328659057617,78.1328659057617,78.1328659057617,78.1328659057617,78.1328659057617,109.561393737793,109.561393737793,129.374504089355,129.374504089355,142.765869140625,142.765869140625,142.765869140625,62.9104385375977,62.9104385375977,94.6704177856445,94.6704177856445,113.894706726074,113.894706726074,113.894706726074,113.894706726074,113.894706726074,143.548309326172,143.548309326172,143.548309326172,47.3006591796875,47.3006591796875,47.3006591796875,78.4009704589844,78.4009704589844,99.3912811279297,99.3912811279297,99.3912811279297,99.3912811279297,99.3912811279297,131.277069091797,131.277069091797,131.277069091797,131.277069091797,131.277069091797,146.365455627441,146.365455627441,146.365455627441,65.6687316894531,65.6687316894531,65.6687316894531,87.1237945556641,87.1237945556641,119.005493164062,119.005493164062,138.81852722168,138.81852722168,138.81852722168,138.81852722168,53.2080001831055,53.2080001831055,73.8073120117188,73.8073120117188,106.34008026123,106.34008026123,106.34008026123,126.803169250488,126.803169250488,126.803169250488,146.354835510254,146.354835510254,146.354835510254,62.1378021240234,62.1378021240234,93.4919281005859,93.4919281005859,93.4919281005859,93.4919281005859,114.030242919922,114.030242919922,114.030242919922,143.943832397461,143.943832397461,143.943832397461,48.4219589233398,48.4219589233398,48.4219589233398,48.4219589233398,48.4219589233398,48.4219589233398,80.3020858764648,80.3020858764648,101.49877166748,101.49877166748,132.205108642578,132.205108642578,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,146.373275756836,42.7886962890625,42.7886962890625,42.7886962890625,42.7886962890625,42.7886962890625,42.7886962890625,70.4780807495117,70.4780807495117,70.4780807495117,70.4780807495117,70.4780807495117,91.6678695678711,91.6678695678711,122.823799133301,122.823799133301,143.29077911377,143.29077911377,59.5210800170898,59.5210800170898,59.5210800170898,80.7793045043945,80.7793045043945,113.253746032715,113.253746032715,133.065704345703,133.065704345703,48.4308395385742,48.4308395385742,48.4308395385742,48.4308395385742,48.4308395385742,69.0900039672852,69.0900039672852,69.0900039672852,69.0900039672852,69.0900039672852,69.0900039672852,100.774589538574,100.774589538574,121.372833251953,121.372833251953,121.372833251953,146.362663269043,146.362663269043,146.362663269043,57.3638610839844,57.3638610839844,57.3638610839844,89.6379547119141,89.6379547119141,111.282356262207,111.282356262207,143.364250183105,143.364250183105,48.5679626464844,48.5679626464844,80.2580871582031,80.2580871582031,80.2580871582031,80.2580871582031,101.770576477051,101.770576477051,132.994262695312,132.994262695312,132.994262695312,132.994262695312,132.994262695312,146.377960205078,146.377960205078,146.377960205078,146.377960205078,146.377960205078,146.377960205078,67.9871597290039,67.9871597290039,67.9871597290039,67.9871597290039,89.1775436401367,89.1775436401367,121.385345458984,121.385345458984,121.385345458984,121.385345458984,142.305992126465,142.305992126465,142.305992126465,142.305992126465,142.305992126465,57.7605514526367,57.7605514526367,57.7605514526367,78.6192779541016,78.6192779541016,78.6192779541016,78.6192779541016,110.040771484375,110.040771484375,110.040771484375,110.040771484375,131.03360748291,131.03360748291,131.03360748291,131.03360748291,131.03360748291,131.03360748291,47.0680923461914,47.0680923461914,67.6657485961914,67.6657485961914,99.0789642333984,99.0789642333984,120.207763671875,120.207763671875,120.207763671875,120.207763671875,120.207763671875,146.37979888916,146.37979888916,146.37979888916,56.4501113891602,56.4501113891602,87.4739074707031,87.4739074707031,107.418998718262,107.418998718262,138.70777130127,138.70777130127,138.70777130127,138.70777130127,44.5762176513672,44.5762176513672,44.5762176513672,75.4740142822266,75.4740142822266,96.7866897583008,96.7866897583008,96.7866897583008,96.7866897583008,96.7866897583008,128.075263977051,128.075263977051,128.075263977051,128.075263977051,146.37043762207,146.37043762207,146.37043762207,64.4543914794922,64.4543914794922,64.4543914794922,85.7071075439453,85.7071075439453,117.98844909668,117.98844909668,117.98844909668,137.210708618164,137.210708618164,137.210708618164,137.210708618164,137.210708618164,52.7119216918945,52.7119216918945,73.4470291137695,73.4470291137695,73.4470291137695,104.940399169922,104.940399169922,104.940399169922,126.261054992676,126.261054992676,126.261054992676,43.6630783081055,43.6630783081055,43.6630783081055,64.7186431884766,64.7186431884766,96.7980651855469,96.7980651855469,118.445159912109,118.445159912109,118.445159912109,118.445159912109,118.445159912109,146.328132629395,146.328132629395,146.328132629395,56.6519165039062,56.6519165039062,88.4757080078125,88.4757080078125,88.4757080078125,109.798347473145,109.798347473145,109.798347473145,109.798347473145,109.798347473145,109.798347473145,140.44116973877,140.44116973877,140.44116973877,46.8153991699219,46.8153991699219,78.5076675415039,78.5076675415039,100.215400695801,100.215400695801,132.560249328613,132.560249328613,132.560249328613,132.560249328613,146.340240478516,146.340240478516,146.340240478516,69.7151107788086,69.7151107788086,90.7742462158203,90.7742462158203,122.386291503906,122.386291503906,122.386291503906,143.383491516113,143.383491516113,143.383491516113,143.383491516113,60.2044448852539,60.2044448852539,81.5253219604492,81.5253219604492,112.620666503906,112.620666503906,112.620666503906,133.812774658203,133.812774658203,133.812774658203,133.812774658203,133.812774658203,51.2120666503906,51.2120666503906,72.1351470947266,72.1351470947266,104.801048278809,104.801048278809,125.596214294434,125.596214294434,125.596214294434,146.390434265137,146.390434265137,146.390434265137,62.8226547241211,62.8226547241211,62.8226547241211,62.8226547241211,94.0514984130859,94.0514984130859,94.0514984130859,115.503387451172,115.503387451172,145.938186645508,145.938186645508,145.938186645508,145.938186645508,52.7259140014648,52.7259140014648,52.7259140014648,52.7259140014648,52.7259140014648,52.7259140014648,84.5540771484375,84.5540771484375,105.808441162109,105.808441162109,105.808441162109,105.808441162109,105.808441162109,136.705451965332,136.705451965332,112.96809387207,112.96809387207,112.96809387207,112.96809387207,112.96809387207,112.96809387207,74.630126953125,74.630126953125,95.8811798095703,95.8811798095703,95.8811798095703,95.8811798095703,128.479393005371,128.479393005371,146.387535095215,146.387535095215,146.387535095215,146.387535095215,146.387535095215,146.387535095215,65.871208190918,65.871208190918,87.3830795288086,87.3830795288086,119.919639587402,119.919639587402,141.500007629395,141.500007629395,58.0749130249023,58.0749130249023,58.0749130249023,58.0749130249023,58.0749130249023,58.0749130249023,78.2111206054688,78.2111206054688,108.708885192871,108.708885192871,108.708885192871,108.708885192871,129.895263671875,129.895263671875,129.895263671875,129.895263671875,129.895263671875,46.5957794189453,46.5957794189453,46.5957794189453,67.71484375,67.71484375,100.052215576172,100.052215576172,121.432662963867,121.432662963867,146.356010437012,146.356010437012,146.356010437012,58.6642303466797,58.6642303466797,91.1275024414062,91.1275024414062,112.17847442627,112.17847442627,143.725051879883,143.725051879883,48.5634765625,48.5634765625,48.5634765625,48.5634765625,48.5634765625,79.4598159790039,79.4598159790039,79.4598159790039,79.4598159790039,79.4598159790039,101.101707458496,101.101707458496,133.234962463379,133.234962463379,146.35221862793,146.35221862793,146.35221862793,70.4065475463867,70.4065475463867,92.0496520996094,92.0496520996094,123.663475036621,123.663475036621,143.86506652832,143.86506652832,59.3222427368164,59.3222427368164,80.5073623657227,80.5073623657227,112.711723327637,112.711723327637,134.092811584473,134.092811584473,134.092811584473,48.7667236328125,48.7667236328125,70.0148010253906,70.0148010253906,102.284629821777,102.284629821777,123.796745300293,123.796745300293,123.796745300293,123.796745300293,123.796745300293,146.358589172363,146.358589172363,146.358589172363,61.5542068481445,61.5542068481445,92.444221496582,92.444221496582,92.444221496582,113.562088012695,113.562088012695,145.179962158203,145.179962158203,145.179962158203,50.9970169067383,50.9970169067383,83.1328048706055,83.1328048706055,83.1328048706055,104.908760070801,104.908760070801,136.654930114746,136.654930114746,136.654930114746,102.63875579834,102.63875579834,102.63875579834,102.63875579834,102.63875579834,102.63875579834,74.6702880859375,74.6702880859375,74.6702880859375,96.5704116821289,96.5704116821289,129.028533935547,129.028533935547,146.341514587402,146.341514587402,146.341514587402,65.5574264526367,65.5574264526367,78.8037185668945,78.8037185668945,110.801940917969,110.801940917969,130.86735534668,130.86735534668,130.86735534668,130.86735534668,130.86735534668,47.5267639160156,47.5267639160156,68.050651550293,68.050651550293,68.050651550293,68.050651550293,68.050651550293,99.8524551391602,99.8524551391602,99.8524551391602,99.8524551391602,120.901336669922,120.901336669922,120.901336669922,146.344360351562,146.344360351562,146.344360351562,146.344360351562,146.344360351562,146.344360351562,57.2343597412109,57.2343597412109,88.9716339111328,88.9716339111328,88.9716339111328,110.153511047363,110.153511047363,110.153511047363,142.547866821289,142.547866821289,142.547866821289,48.5779037475586,48.5779037475586,80.2497711181641,80.2497711181641,100.903465270996,100.903465270996,132.114303588867,132.114303588867,146.342704772949,146.342704772949,146.342704772949,69.6943893432617,69.6943893432617,90.3490905761719,90.3490905761719,122.084320068359,122.084320068359,122.084320068359,122.084320068359,122.084320068359,143.459976196289,143.459976196289,59.7276763916016,59.7276763916016,80.3831100463867,80.3831100463867,80.3831100463867,112.185272216797,112.185272216797,112.185272216797,112.185272216797,112.185272216797,133.036018371582,133.036018371582,49.3024826049805,49.3024826049805,49.3024826049805,49.3024826049805,49.3024826049805,70.7432250976562,70.7432250976562,102.546226501465,102.546226501465,102.546226501465,102.546226501465,123.070121765137,123.070121765137,123.070121765137,123.070121765137,123.070121765137,146.345268249512,146.345268249512,146.345268249512,61.0369415283203,61.0369415283203,91.7199096679688,91.7199096679688,113.22386932373,113.22386932373,113.22386932373,145.414306640625,145.414306640625,52.1873245239258,52.1873245239258,52.1873245239258,52.1873245239258,52.1873245239258,83.5915756225586,83.5915756225586,83.5915756225586,83.5915756225586,83.5915756225586,104.767395019531,104.767395019531,104.767395019531,104.767395019531,104.767395019531,136.958946228027,136.958946228027,136.958946228027,136.958946228027,136.958946228027,136.958946228027,44.1896209716797,44.1896209716797,75.5286560058594,75.5286560058594,75.5286560058594,96.9011077880859,96.9011077880859,129.027153015137,129.027153015137,129.027153015137,146.335273742676,146.335273742676,146.335273742676,65.14501953125,65.14501953125,65.14501953125,86.779411315918,86.779411315918,117.921829223633,117.921829223633,139.03271484375,139.03271484375,139.03271484375,139.03271484375,139.03271484375,54.7870635986328,54.7870635986328,54.7870635986328,54.7870635986328,76.0936965942383,76.0936965942383,108.284057617188,108.284057617188,108.284057617188,129.853393554688,129.853393554688,45.9368667602539,45.9368667602539,45.9368667602539,67.1129608154297,67.1129608154297,67.1129608154297,99.368293762207,99.368293762207,120.609970092773,120.609970092773,120.609970092773,146.375030517578,146.375030517578,146.375030517578,57.4759521484375,57.4759521484375,57.4759521484375,57.4759521484375,57.4759521484375,89.6005477905273,89.6005477905273,89.6005477905273,110.972869873047,110.972869873047,143.359733581543,143.359733581543,143.359733581543,143.359733581543,143.359733581543,48.2980422973633,48.2980422973633,80.6189041137695,80.6189041137695,80.6189041137695,80.6189041137695,80.6189041137695,80.6189041137695,101.532890319824,101.532890319824,109.403106689453,109.403106689453,109.403106689453,109.403106689453,109.403106689453,109.403106689453,109.403106689453,109.403106689453,109.403106689453,109.403106689453,109.403106689453],"meminc":[0,0,0,0,0,20.9217529296875,0,0,0,0,0,27.6204299926758,0,0,16.7917861938477,0,0,0,0,0,18.2999725341797,0,0,-86.9098205566406,0,0,0,0,0,31.8827514648438,0,20.6033706665039,0,0,29.9109268188477,0,0,-96.3706283569336,0,32.4044799804688,0,21.5212783813477,0,30.5781097412109,0,0,16.3987731933594,0,0,-82.0789184570312,0,0,0,19.9444961547852,0,0,0,0,31.0876312255859,0,0,19.8069000244141,0,0,0,-86.9697875976562,0,0,20.4713592529297,0,0,31.5525588989258,0,20.4687652587891,0,0,0,0,0,25.7116470336914,0,0,-91.7055892944336,0,31.0274124145508,0,21.2518768310547,0,31.6240081787109,0,7.80714416503906,0,0,-73.6687622070312,0,0,0,0,21.1910858154297,0,30.3740158081055,0,0,0,0,19.8145141601562,0,-86.0107574462891,0,20.0806274414062,0,0,0,0,31.4285278320312,0,19.8131103515625,0,13.3913650512695,0,0,-79.8554306030273,0,31.7599792480469,0,19.2242889404297,0,0,0,0,29.6536026000977,0,0,-96.2476501464844,0,0,31.1003112792969,0,20.9903106689453,0,0,0,0,31.8857879638672,0,0,0,0,15.0883865356445,0,0,-80.6967239379883,0,0,21.4550628662109,0,31.8816986083984,0,19.8130340576172,0,0,0,-85.6105270385742,0,20.5993118286133,0,32.5327682495117,0,0,20.4630889892578,0,0,19.5516662597656,0,0,-84.2170333862305,0,31.3541259765625,0,0,0,20.5383148193359,0,0,29.9135894775391,0,0,-95.5218734741211,0,0,0,0,0,31.880126953125,0,21.1966857910156,0,30.7063369750977,0,14.1681671142578,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,0,0,0,27.6893844604492,0,0,0,0,21.1897888183594,0,31.1559295654297,0,20.4669799804688,0,-83.7696990966797,0,0,21.2582244873047,0,32.4744415283203,0,19.8119583129883,0,-84.6348648071289,0,0,0,0,20.6591644287109,0,0,0,0,0,31.6845855712891,0,20.5982437133789,0,0,24.9898300170898,0,0,-88.9988021850586,0,0,32.2740936279297,0,21.644401550293,0,32.0818939208984,0,-94.7962875366211,0,31.6901245117188,0,0,0,21.5124893188477,0,31.2236862182617,0,0,0,0,13.3836975097656,0,0,0,0,0,-78.3908004760742,0,0,0,21.1903839111328,0,32.2078018188477,0,0,0,20.9206466674805,0,0,0,0,-84.5454406738281,0,0,20.8587265014648,0,0,0,31.4214935302734,0,0,0,20.9928359985352,0,0,0,0,0,-83.9655151367188,0,20.59765625,0,31.413215637207,0,21.1287994384766,0,0,0,0,26.1720352172852,0,0,-89.9296875,0,31.023796081543,0,19.9450912475586,0,31.2887725830078,0,0,0,-94.1315536499023,0,0,30.8977966308594,0,21.3126754760742,0,0,0,0,31.28857421875,0,0,0,18.2951736450195,0,0,-81.9160461425781,0,0,21.2527160644531,0,32.2813415527344,0,0,19.2222595214844,0,0,0,0,-84.4987869262695,0,20.735107421875,0,0,31.4933700561523,0,0,21.3206558227539,0,0,-82.5979766845703,0,0,21.0555648803711,0,32.0794219970703,0,21.6470947265625,0,0,0,0,27.8829727172852,0,0,-89.6762161254883,0,31.8237915039062,0,0,21.322639465332,0,0,0,0,0,30.642822265625,0,0,-93.6257705688477,0,31.692268371582,0,21.7077331542969,0,32.3448486328125,0,0,0,13.7799911499023,0,0,-76.625129699707,0,21.0591354370117,0,31.6120452880859,0,0,20.997200012207,0,0,0,-83.1790466308594,0,21.3208770751953,0,31.095344543457,0,0,21.1921081542969,0,0,0,0,-82.6007080078125,0,20.9230804443359,0,32.665901184082,0,20.795166015625,0,0,20.7942199707031,0,0,-83.5677795410156,0,0,0,31.2288436889648,0,0,21.4518890380859,0,30.4347991943359,0,0,0,-93.212272644043,0,0,0,0,0,31.8281631469727,0,21.2543640136719,0,0,0,0,30.8970108032227,0,-23.7373580932617,0,0,0,0,0,-38.3379669189453,0,21.2510528564453,0,0,0,32.5982131958008,0,17.9081420898438,0,0,0,0,0,-80.5163269042969,0,21.5118713378906,0,32.5365600585938,0,21.5803680419922,0,-83.4250946044922,0,0,0,0,0,20.1362075805664,0,30.4977645874023,0,0,0,21.1863784790039,0,0,0,0,-83.2994842529297,0,0,21.1190643310547,0,32.3373718261719,0,21.3804473876953,0,24.9233474731445,0,0,-87.691780090332,0,32.4632720947266,0,21.0509719848633,0,31.5465774536133,0,-95.1615753173828,0,0,0,0,30.8963394165039,0,0,0,0,21.6418914794922,0,32.1332550048828,0,13.1172561645508,0,0,-75.945671081543,0,21.6431045532227,0,31.6138229370117,0,20.2015914916992,0,-84.5428237915039,0,21.1851196289062,0,32.2043609619141,0,21.3810882568359,0,0,-85.3260879516602,0,21.2480773925781,0,32.2698287963867,0,21.5121154785156,0,0,0,0,22.5618438720703,0,0,-84.8043823242188,0,30.8900146484375,0,0,21.1178665161133,0,31.6178741455078,0,0,-94.1829452514648,0,32.1357879638672,0,0,21.7759552001953,0,31.7461700439453,0,0,-34.0161743164062,0,0,0,0,0,-27.9684677124023,0,0,21.9001235961914,0,32.458122253418,0,17.3129806518555,0,0,-80.7840881347656,0,13.2462921142578,0,31.9982223510742,0,20.0654144287109,0,0,0,0,-83.3405914306641,0,20.5238876342773,0,0,0,0,31.8018035888672,0,0,0,21.0488815307617,0,0,25.4430236816406,0,0,0,0,0,-89.1100006103516,0,31.7372741699219,0,0,21.1818771362305,0,0,32.3943557739258,0,0,-93.9699630737305,0,31.6718673706055,0,20.653694152832,0,31.2108383178711,0,14.228401184082,0,0,-76.6483154296875,0,20.6547012329102,0,31.7352294921875,0,0,0,0,21.3756561279297,0,-83.7322998046875,0,20.6554336547852,0,0,31.8021621704102,0,0,0,0,20.8507461547852,0,-83.7335357666016,0,0,0,0,21.4407424926758,0,31.8030014038086,0,0,0,20.5238952636719,0,0,0,0,23.275146484375,0,0,-85.3083267211914,0,30.6829681396484,0,21.5039596557617,0,0,32.1904373168945,0,-93.2269821166992,0,0,0,0,31.4042510986328,0,0,0,0,21.1758193969727,0,0,0,0,32.1915512084961,0,0,0,0,0,-92.7693252563477,0,31.3390350341797,0,0,21.3724517822266,0,32.1260452270508,0,0,17.3081207275391,0,0,-81.1902542114258,0,0,21.634391784668,0,31.1424179077148,0,21.1108856201172,0,0,0,0,-84.2456512451172,0,0,0,21.3066329956055,0,32.1903610229492,0,0,21.5693359375,0,-83.9165267944336,0,0,21.1760940551758,0,0,32.2553329467773,0,21.2416763305664,0,0,25.7650604248047,0,0,-88.8990783691406,0,0,0,0,32.1245956420898,0,0,21.3723220825195,0,32.3868637084961,0,0,0,0,-95.0616912841797,0,32.3208618164062,0,0,0,0,0,20.9139862060547,0,7.87021636962891,0,0,0,0,0,0,0,0,0,0],"filename":[null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,null,null,null,null,null,null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpJy9pj3/file3c2161c7df58.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    784.123    792.4700    808.6164    799.2345
#>    compute_pi0(m * 10)   7870.525   7916.8640   8321.5265   7947.4775
#>   compute_pi0(m * 100)  78685.802  79211.9975  80101.5360  79777.1910
#>         compute_pi1(m)    159.604    251.3475    267.6655    292.2355
#>    compute_pi1(m * 10)   1238.680   1313.3290   1763.8384   1388.0875
#>   compute_pi1(m * 100)  12729.967  12886.8455  23304.1597  18982.4395
#>  compute_pi1(m * 1000) 253927.749 358522.2820 357314.8858 364344.4460
#>           uq        max neval
#>     824.0710    871.498    20
#>    8155.9330  14220.185    20
#>   80910.3130  83693.327    20
#>     304.7665    321.351    20
#>    1442.7955   9186.193    20
#>   22289.3580 128275.896    20
#>  373671.3445 498513.471    20
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
#>   memory_copy1(n) 5537.66878 4543.10043 668.948791 4050.45337 3627.59050
#>   memory_copy2(n)   91.23861   76.10998  11.923358   70.27946   67.66902
#>  pre_allocate1(n)   19.86093   16.45651   3.738255   14.68634   13.53066
#>  pre_allocate2(n)  194.01336  163.16694  23.303504  148.40098  136.98439
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  136.454492    10
#>    2.920912    10
#>    2.038541    10
#>    4.136380    10
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
#>  f1(df) 246.1295 243.2241 81.37993 243.5072 61.90639 32.68433     5
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
