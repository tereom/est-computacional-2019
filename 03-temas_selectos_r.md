
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
#>    id           a          b        c        d
#> 1   1 -0.46468797  2.2058577 2.655196 2.717005
#> 2   2 -0.18249261  2.4258185 2.501939 5.629877
#> 3   3  0.50909779 -0.4555573 2.807107 3.543626
#> 4   4 -0.58732131  1.4928804 2.939287 1.980969
#> 5   5 -0.01885346  1.2043612 2.901484 3.519461
#> 6   6 -0.07423291  3.3509661 3.830217 1.878204
#> 7   7  0.73205256  0.6916399 5.001354 2.820549
#> 8   8 -0.17367899  1.4598564 2.806523 3.946435
#> 9   9  1.02929297  2.9430003 2.747379 3.236016
#> 10 10  0.44357677  3.1922137 4.543135 3.584511
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.1212753
mean(df$b)
#> [1] 1.851104
mean(df$c)
#> [1] 3.273362
mean(df$d)
#> [1] 3.285665
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.1212753 1.8511037 3.2733622 3.2856655
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
#> [1] 0.1212753 1.8511037 3.2733622 3.2856655
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
#> [1] 5.5000000 0.1212753 1.8511037 3.2733622 3.2856655
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
#> [1]  5.50000000 -0.04654319  1.84936905  2.85429522  3.37773849
col_describe(df, mean)
#> [1] 5.5000000 0.1212753 1.8511037 3.2733622 3.2856655
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
#> 5.5000000 0.1212753 1.8511037 3.2733622 3.2856655
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
#>   3.844   0.108   3.952
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.017   0.005   0.644
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
#>  12.806   0.695   9.683
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
#>   0.111   0.000   0.111
plyr_st
#>    user  system elapsed 
#>   4.000   0.008   4.009
est_l_st
#>    user  system elapsed 
#>  61.096   0.703  61.804
est_r_st
#>    user  system elapsed 
#>   0.385   0.008   0.393
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

<!--html_preserve--><div id="htmlwidget-516c3229cb5e64a654f7" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-516c3229cb5e64a654f7">{"x":{"message":{"prof":{"time":[1,1,2,2,2,3,3,4,4,4,5,5,6,6,7,7,8,8,9,9,9,10,10,10,10,10,11,11,12,12,12,12,12,13,13,14,14,14,15,15,16,16,16,17,17,17,18,18,18,19,19,20,20,21,21,21,22,22,23,23,23,24,24,24,25,25,26,26,26,27,27,28,28,29,29,29,30,30,30,31,31,31,31,31,32,32,32,32,32,32,33,33,33,33,33,34,34,35,35,35,35,36,36,36,36,37,37,38,38,38,38,38,38,39,39,39,40,40,41,41,41,42,42,43,43,43,43,43,44,44,44,44,44,44,45,45,46,46,47,47,47,48,48,48,48,48,48,49,49,49,49,49,49,50,50,50,51,51,51,52,52,53,53,54,54,55,56,56,56,57,57,58,58,59,59,59,60,60,61,61,61,61,62,62,62,62,62,63,63,63,64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,75,75,76,76,77,77,77,78,78,78,79,79,79,79,79,80,80,81,81,81,81,81,82,82,82,82,83,83,84,84,85,85,86,86,86,87,87,87,88,88,88,89,89,89,89,89,90,90,90,91,91,91,91,91,92,92,93,93,94,94,95,95,95,95,95,95,96,96,96,96,96,96,97,97,97,98,98,99,99,99,99,100,100,101,101,101,102,102,103,103,103,103,104,104,105,105,106,106,106,107,107,108,108,109,109,109,110,110,110,111,112,112,113,113,113,114,114,115,115,116,116,117,117,118,118,118,119,119,119,120,120,120,121,121,121,121,121,121,122,122,123,123,124,124,124,124,125,125,126,126,126,126,126,126,127,127,127,128,128,128,129,129,130,130,131,131,132,132,132,132,133,133,133,133,133,133,134,134,134,135,135,136,136,136,137,137,137,137,137,138,138,138,139,139,140,140,140,141,141,142,142,142,143,143,143,143,143,144,144,145,145,146,146,146,146,146,147,147,147,148,148,149,149,149,149,149,150,150,151,151,151,152,152,153,153,153,154,154,155,155,156,156,156,157,157,158,158,159,159,159,159,159,160,160,160,160,160,161,161,161,162,162,162,162,162,162,163,163,163,163,164,164,165,165,165,165,165,165,166,166,166,166,167,167,167,167,168,168,168,169,169,169,170,170,171,171,172,172,172,173,173,174,174,174,175,175,175,176,176,176,176,176,177,177,177,177,177,177,178,178,178,178,178,179,179,180,180,180,181,181,181,182,182,182,182,183,183,183,184,184,185,185,185,185,186,186,186,187,187,187,188,188,189,189,189,190,190,191,191,192,192,192,193,193,193,194,194,195,195,195,196,196,197,197,198,198,198,198,198,198,199,199,199,200,200,200,201,201,202,202,202,203,203,204,204,204,204,204,205,205,206,206,207,207,207,207,207,208,208,208,209,209,209,209,210,210,210,210,210,211,211,211,211,211,212,212,212,212,212,213,213,213,213,213,214,214,214,214,215,215,215,216,216,216,217,217,217,217,217,217,218,218,218,218,218,218,219,219,219,219,220,220,221,221,222,222,223,223,224,224,224,224,224,224,225,225,226,226,226,227,227,227,228,228,228,228,228,229,229,230,230,231,231,232,232,233,233,233,234,234,235,235,236,236,236,236,236,237,237,237,238,238,239,239,239,240,240,241,241,241,242,242,243,243,244,244,245,245,246,246,246,246,246,246,247,247,247,248,248,248,248,248,249,249,249,250,250,250,251,251,251,252,252,252,253,253,254,254,254,255,255,255,255,255,256,256,257,257,257,257,257,258,258,259,259,260,260,260,261,261,261,261,261,262,262,262,263,263,263,264,264,265,265,265,265,265,265,266,266,267,267,268,268,268,268,268,269,269,269,269,269,269,270,270,271,271,272,272,272,273,273,273,273,273,273,274,274,274,275,275,276,276,277,277,277,278,278,279,279,279,279,279,279,280,280,280,280,280],"depth":[2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","%in%","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","nrow","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,null,null,null,null,1,null,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,null,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,null,null,null,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,null,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,null,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,null,null,null,null,1,1,null,null,null,null,1],"linenum":[9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,10,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,10,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,null,null,null,null,11,null,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,null,11,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,null,null,null,11,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,11,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,10,10,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,null,11,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,10,10,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,null,11,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,11,9,9,null,null,null,null,9,9,null,null,null,null,13],"memalloc":[67.7486190795898,67.7486190795898,89.1979370117188,89.1979370117188,89.1979370117188,115.700393676758,115.700393676758,133.281196594238,133.281196594238,133.281196594238,44.925163269043,44.925163269043,65.4579010009766,65.4579010009766,97.0135650634766,97.0135650634766,117.089614868164,117.089614868164,146.344673156738,146.344673156738,146.344673156738,51.5472412109375,51.5472412109375,51.5472412109375,51.5472412109375,51.5472412109375,83.6951065063477,83.6951065063477,103.903495788574,103.903495788574,103.903495788574,103.903495788574,103.903495788574,134.416343688965,134.416343688965,146.352630615234,146.352630615234,146.352630615234,67.4225540161133,67.4225540161133,88.2178802490234,88.2178802490234,88.2178802490234,118.650344848633,118.650344848633,118.650344848633,138.590026855469,138.590026855469,138.590026855469,52.6064910888672,52.6064910888672,73.1423568725586,73.1423568725586,104.824783325195,104.824783325195,104.824783325195,125.159141540527,125.159141540527,146.347282409668,146.347282409668,146.347282409668,60.2808609008789,60.2808609008789,60.2808609008789,92.3584899902344,92.3584899902344,113.611145019531,113.611145019531,113.611145019531,145.56559753418,145.56559753418,49.1302795410156,49.1302795410156,81.5355834960938,81.5355834960938,81.5355834960938,102.008453369141,102.008453369141,102.008453369141,132.187347412109,132.187347412109,132.187347412109,132.187347412109,132.187347412109,146.361701965332,146.361701965332,146.361701965332,146.361701965332,146.361701965332,146.361701965332,67.1093978881836,67.1093978881836,67.1093978881836,67.1093978881836,67.1093978881836,88.4372863769531,88.4372863769531,119.072723388672,119.072723388672,119.072723388672,119.072723388672,139.213119506836,139.213119506836,139.213119506836,139.213119506836,53.5942535400391,53.5942535400391,74.3271484375,74.3271484375,74.3271484375,74.3271484375,74.3271484375,74.3271484375,105.761123657227,105.761123657227,105.761123657227,126.09822845459,126.09822845459,146.368019104004,146.368019104004,146.368019104004,61.21435546875,61.21435546875,93.0232696533203,93.0232696533203,93.0232696533203,93.0232696533203,93.0232696533203,114.417358398438,114.417358398438,114.417358398438,114.417358398438,114.417358398438,114.417358398438,146.168212890625,146.168212890625,49.9926376342773,49.9926376342773,82.2705459594727,82.2705459594727,82.2705459594727,102.408760070801,102.408760070801,102.408760070801,102.408760070801,102.408760070801,102.408760070801,131.013298034668,131.013298034668,131.013298034668,131.013298034668,131.013298034668,131.013298034668,146.364669799805,146.364669799805,146.364669799805,65.4097213745117,65.4097213745117,65.4097213745117,86.5995712280273,86.5995712280273,117.031379699707,117.031379699707,136.641151428223,136.641151428223,50.9823226928711,71.5241851806641,71.5241851806641,71.5241851806641,103.009071350098,103.009071350098,123.277961730957,123.277961730957,146.372665405273,146.372665405273,146.372665405273,57.7353820800781,57.7353820800781,89.2892532348633,89.2892532348633,89.2892532348633,89.2892532348633,109.440460205078,109.440460205078,109.440460205078,109.440460205078,109.440460205078,139.681007385254,139.681007385254,139.681007385254,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,146.373268127441,42.788688659668,42.788688659668,42.788688659668,44.0349197387695,44.0349197387695,75.3967514038086,75.3967514038086,96.391960144043,96.391960144043,126.828414916992,126.828414916992,126.828414916992,146.374168395996,146.374168395996,146.374168395996,63.2592315673828,63.2592315673828,63.2592315673828,63.2592315673828,63.2592315673828,84.3869247436523,84.3869247436523,114.631629943848,114.631629943848,114.631629943848,114.631629943848,114.631629943848,134.180435180664,134.180435180664,134.180435180664,134.180435180664,49.8731307983398,49.8731307983398,70.401969909668,70.401969909668,102.022315979004,102.022315979004,121.372825622559,121.372825622559,121.372825622559,146.362655639648,146.362655639648,146.362655639648,57.3638534545898,57.3638534545898,57.3638534545898,89.1136016845703,89.1136016845703,89.1136016845703,89.1136016845703,89.1136016845703,110.626136779785,110.626136779785,110.626136779785,142.774124145508,142.774124145508,142.774124145508,142.774124145508,142.774124145508,48.6990737915039,48.6990737915039,80.4546966552734,80.4546966552734,101.442802429199,101.442802429199,131.682914733887,131.682914733887,131.682914733887,131.682914733887,131.682914733887,131.682914733887,146.377952575684,146.377952575684,146.377952575684,146.377952575684,146.377952575684,146.377952575684,68.0529861450195,68.0529861450195,68.0529861450195,88.9153900146484,88.9153900146484,121.516708374023,121.516708374023,121.516708374023,121.516708374023,142.895973205566,142.895973205566,59.3366165161133,59.3366165161133,59.3366165161133,80.7840194702148,80.7840194702148,112.795417785645,112.795417785645,112.795417785645,112.795417785645,133.26488494873,133.26488494873,47.9870300292969,47.9870300292969,67.9939193725586,67.9939193725586,67.9939193725586,99.0789566040039,99.0789566040039,119.157379150391,119.157379150391,146.379791259766,146.379791259766,146.379791259766,56.1879119873047,56.1879119873047,56.1879119873047,87.6706237792969,107.353439331055,107.353439331055,139.625175476074,139.625175476074,139.625175476074,45.624870300293,45.624870300293,76.9819641113281,76.9819641113281,98.2945709228516,98.2945709228516,128.861831665039,128.861831665039,146.370429992676,146.370429992676,146.370429992676,64.4543838500977,64.4543838500977,64.4543838500977,84.9193572998047,84.9193572998047,84.9193572998047,113.658348083496,113.658348083496,113.658348083496,113.658348083496,113.658348083496,113.658348083496,132.027275085449,132.027275085449,47.8587265014648,47.8587265014648,67.9341583251953,67.9341583251953,67.9341583251953,67.9341583251953,100.086441040039,100.086441040039,121.015464782715,121.015464782715,121.015464782715,121.015464782715,121.015464782715,121.015464782715,146.334915161133,146.334915161133,146.334915161133,58.8784561157227,58.8784561157227,58.8784561157227,91.0925903320312,91.0925903320312,112.473571777344,112.473571777344,144.623001098633,144.623001098633,50.9472045898438,50.9472045898438,50.9472045898438,50.9472045898438,83.2267227172852,83.2267227172852,83.2267227172852,83.2267227172852,83.2267227172852,83.2267227172852,104.223327636719,104.223327636719,104.223327636719,134.601631164551,134.601631164551,146.343872070312,146.343872070312,146.343872070312,71.2269821166992,71.2269821166992,71.2269821166992,71.2269821166992,71.2269821166992,92.9351043701172,92.9351043701172,92.9351043701172,125.603317260742,125.603317260742,146.340232849121,146.340232849121,146.340232849121,63.8740539550781,63.8740539550781,84.8711700439453,84.8711700439453,84.8711700439453,117.66268157959,117.66268157959,117.66268157959,117.66268157959,117.66268157959,137.873245239258,137.873245239258,55.0225067138672,55.0225067138672,75.8209381103516,75.8209381103516,75.8209381103516,75.8209381103516,75.8209381103516,108.35652923584,108.35652923584,108.35652923584,129.745483398438,129.745483398438,47.2120056152344,47.2120056152344,47.2120056152344,47.2120056152344,47.2120056152344,68.2655258178711,68.2655258178711,100.339851379395,100.339851379395,100.339851379395,120.414215087891,120.414215087891,146.390426635742,146.390426635742,146.390426635742,57.3777694702148,57.3777694702148,88.4109268188477,88.4109268188477,108.218544006348,108.218544006348,108.218544006348,138.001106262207,138.001106262207,44.1979217529297,44.1979217529297,75.8272857666016,75.8272857666016,75.8272857666016,75.8272857666016,75.8272857666016,96.8221740722656,96.8221740722656,96.8221740722656,96.8221740722656,96.8221740722656,127.194305419922,127.194305419922,127.194305419922,146.348167419434,146.348167419434,146.348167419434,146.348167419434,146.348167419434,146.348167419434,64.4010009765625,64.4010009765625,64.4010009765625,64.4010009765625,85.1893539428711,85.1893539428711,116.211601257324,116.211601257324,116.211601257324,116.211601257324,116.211601257324,116.211601257324,137.072891235352,137.072891235352,137.072891235352,137.072891235352,52.6890869140625,52.6890869140625,52.6890869140625,52.6890869140625,74.0045394897461,74.0045394897461,74.0045394897461,105.555137634277,105.555137634277,105.555137634277,126.675254821777,126.675254821777,42.9217834472656,42.9217834472656,61.8802947998047,61.8802947998047,61.8802947998047,93.9527587890625,93.9527587890625,115.398666381836,115.398666381836,115.398666381836,146.357284545898,146.357284545898,146.357284545898,52.5646057128906,52.5646057128906,52.5646057128906,52.5646057128906,52.5646057128906,82.7326812744141,82.7326812744141,82.7326812744141,82.7326812744141,82.7326812744141,82.7326812744141,103.529403686523,103.529403686523,103.529403686523,103.529403686523,103.529403686523,135.993232727051,135.993232727051,146.356002807617,146.356002807617,146.356002807617,72.3073043823242,72.3073043823242,72.3073043823242,91.3903427124023,91.3903427124023,91.3903427124023,91.3903427124023,122.278297424316,122.278297424316,122.278297424316,142.412796020508,142.412796020508,57.0897903442383,57.0897903442383,57.0897903442383,57.0897903442383,77.5570297241211,77.5570297241211,77.5570297241211,109.364570617676,109.364570617676,109.364570617676,130.612342834473,130.612342834473,46.7957305908203,46.7957305908203,46.7957305908203,67.3907165527344,67.3907165527344,99.1341934204102,99.1341934204102,120.711082458496,120.711082458496,120.711082458496,146.358123779297,146.358123779297,146.358123779297,57.158073425293,57.158073425293,88.9035034179688,88.9035034179688,88.9035034179688,110.415191650391,110.415191650391,142.026000976562,142.026000976562,47.7173614501953,47.7173614501953,47.7173614501953,47.7173614501953,47.7173614501953,47.7173614501953,79.5905685424805,79.5905685424805,79.5905685424805,100.251220703125,100.251220703125,100.251220703125,132.453193664551,132.453193664551,146.358581542969,146.358581542969,146.358581542969,68.8361968994141,68.8361968994141,89.4274826049805,89.4274826049805,89.4274826049805,89.4274826049805,89.4274826049805,121.237335205078,121.237335205078,141.965141296387,141.965141296387,58.0138092041016,58.0138092041016,58.0138092041016,58.0138092041016,58.0138092041016,78.8705520629883,78.8705520629883,78.8705520629883,110.879241943359,110.879241943359,110.879241943359,110.879241943359,131.868217468262,131.868217468262,131.868217468262,131.868217468262,131.868217468262,48.5727844238281,48.5727844238281,48.5727844238281,48.5727844238281,48.5727844238281,68.7029266357422,68.7029266357422,68.7029266357422,68.7029266357422,68.7029266357422,100.177024841309,100.177024841309,100.177024841309,100.177024841309,100.177024841309,121.816108703613,121.816108703613,121.816108703613,121.816108703613,146.341506958008,146.341506958008,146.341506958008,59.9846420288086,59.9846420288086,59.9846420288086,92.311637878418,92.311637878418,92.311637878418,92.311637878418,92.311637878418,92.311637878418,113.818550109863,113.818550109863,113.818550109863,113.818550109863,113.818550109863,113.818550109863,145.883522033691,145.883522033691,145.883522033691,145.883522033691,52.1822814941406,52.1822814941406,84.6407699584961,84.6407699584961,104.245399475098,104.245399475098,135.589530944824,135.589530944824,146.344352722168,146.344352722168,146.344352722168,146.344352722168,146.344352722168,146.344352722168,72.907096862793,72.907096862793,94.3487243652344,94.3487243652344,94.3487243652344,125.301727294922,125.301727294922,125.301727294922,146.023345947266,146.023345947266,146.023345947266,146.023345947266,146.023345947266,63.0045700073242,63.0045700073242,84.1844253540039,84.1844253540039,116.967483520508,116.967483520508,138.474571228027,138.474571228027,55.3999557495117,55.3999557495117,55.3999557495117,76.51416015625,76.51416015625,108.838821411133,108.838821411133,130.28099822998,130.28099822998,130.28099822998,130.28099822998,130.28099822998,47.3345947265625,47.3345947265625,47.3345947265625,68.5146789550781,68.5146789550781,100.841346740723,100.841346740723,100.841346740723,122.020561218262,122.020561218262,146.34593963623,146.34593963623,146.34593963623,58.8097915649414,58.8097915649414,91.0055541992188,91.0055541992188,111.791694641113,111.791694641113,144.181350708008,144.181350708008,50.2194213867188,50.2194213867188,50.2194213867188,50.2194213867188,50.2194213867188,50.2194213867188,81.7548370361328,81.7548370361328,81.7548370361328,102.865188598633,102.865188598633,102.865188598633,102.865188598633,102.865188598633,135.252212524414,135.252212524414,135.252212524414,146.33243560791,146.33243560791,146.33243560791,73.8886566162109,73.8886566162109,73.8886566162109,94.343505859375,94.343505859375,94.343505859375,126.534225463867,126.534225463867,146.334144592285,146.334144592285,146.334144592285,64.8422622680664,64.8422622680664,64.8422622680664,64.8422622680664,64.8422622680664,86.476806640625,86.476806640625,118.340713500977,118.340713500977,118.340713500977,118.340713500977,118.340713500977,139.975250244141,139.975250244141,55.3103408813477,55.3103408813477,75.8313140869141,75.8313140869141,75.8313140869141,105.989471435547,105.989471435547,105.989471435547,105.989471435547,105.989471435547,126.182914733887,126.182914733887,126.182914733887,146.375175476074,146.375175476074,146.375175476074,59.6384048461914,59.6384048461914,90.254753112793,90.254753112793,90.254753112793,90.254753112793,90.254753112793,90.254753112793,109.791923522949,109.791923522949,140.736427307129,140.736427307129,45.3469772338867,45.3469772338867,45.3469772338867,45.3469772338867,45.3469772338867,75.8977813720703,75.8977813720703,75.8977813720703,75.8977813720703,75.8977813720703,75.8977813720703,96.8112335205078,96.8112335205078,128.017913818359,128.017913818359,146.375022888184,146.375022888184,146.375022888184,61.8030166625977,61.8030166625977,61.8030166625977,61.8030166625977,61.8030166625977,61.8030166625977,81.7333374023438,81.7333374023438,81.7333374023438,112.480766296387,112.480766296387,132.935493469238,132.935493469238,47.5766067504883,47.5766067504883,47.5766067504883,67.7691497802734,67.7691497802734,99.6973419189453,99.6973419189453,99.6973419189453,99.6973419189453,99.6973419189453,99.6973419189453,109.034530639648,109.034530639648,109.034530639648,109.034530639648,109.034530639648],"meminc":[0,0,21.4493179321289,0,0,26.5024566650391,0,17.5808029174805,0,0,-88.3560333251953,0,20.5327377319336,0,31.5556640625,0,20.0760498046875,0,29.2550582885742,0,0,-94.7974319458008,0,0,0,0,32.1478652954102,0,20.2083892822266,0,0,0,0,30.5128479003906,0,11.9362869262695,0,0,-78.9300765991211,0,20.7953262329102,0,0,30.4324645996094,0,0,19.9396820068359,0,0,-85.9835357666016,0,20.5358657836914,0,31.6824264526367,0,0,20.334358215332,0,21.1881408691406,0,0,-86.0664215087891,0,0,32.0776290893555,0,21.2526550292969,0,0,31.9544525146484,0,-96.4353179931641,0,32.4053039550781,0,0,20.4728698730469,0,0,30.1788940429688,0,0,0,0,14.1743545532227,0,0,0,0,0,-79.2523040771484,0,0,0,0,21.3278884887695,0,30.6354370117188,0,0,0,20.1403961181641,0,0,0,-85.6188659667969,0,20.7328948974609,0,0,0,0,0,31.4339752197266,0,0,20.3371047973633,0,20.2697906494141,0,0,-85.1536636352539,0,31.8089141845703,0,0,0,0,21.3940887451172,0,0,0,0,0,31.7508544921875,0,-96.1755752563477,0,32.2779083251953,0,0,20.1382141113281,0,0,0,0,0,28.6045379638672,0,0,0,0,0,15.3513717651367,0,0,-80.954948425293,0,0,21.1898498535156,0,30.4318084716797,0,19.6097717285156,0,-85.6588287353516,20.541862487793,0,0,31.4848861694336,0,20.2688903808594,0,23.0947036743164,0,0,-88.6372833251953,0,31.5538711547852,0,0,0,20.1512069702148,0,0,0,0,30.2405471801758,0,0,6.6922607421875,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,1.24623107910156,0,31.3618316650391,0,20.9952087402344,0,30.4364547729492,0,0,19.5457534790039,0,0,-83.1149368286133,0,0,0,0,21.1276931762695,0,30.2447052001953,0,0,0,0,19.5488052368164,0,0,0,-84.3073043823242,0,20.5288391113281,0,31.6203460693359,0,19.3505096435547,0,0,24.9898300170898,0,0,-88.9988021850586,0,0,31.7497482299805,0,0,0,0,21.5125350952148,0,0,32.1479873657227,0,0,0,0,-94.0750503540039,0,31.7556228637695,0,20.9881057739258,0,30.2401123046875,0,0,0,0,0,14.6950378417969,0,0,0,0,0,-78.3249664306641,0,0,20.8624038696289,0,32.601318359375,0,0,0,21.379264831543,0,-83.5593566894531,0,0,21.4474029541016,0,32.0113983154297,0,0,0,20.4694671630859,0,-85.2778549194336,0,20.0068893432617,0,0,31.0850372314453,0,20.0784225463867,0,27.222412109375,0,0,-90.1918792724609,0,0,31.4827117919922,19.6828155517578,0,32.2717361450195,0,0,-94.0003051757812,0,31.3570938110352,0,21.3126068115234,0,30.5672607421875,0,17.5085983276367,0,0,-81.9160461425781,0,0,20.464973449707,0,0,28.7389907836914,0,0,0,0,0,18.3689270019531,0,-84.1685485839844,0,20.0754318237305,0,0,0,32.1522827148438,0,20.9290237426758,0,0,0,0,0,25.319450378418,0,0,-87.4564590454102,0,0,32.2141342163086,0,21.3809814453125,0,32.1494293212891,0,-93.6757965087891,0,0,0,32.2795181274414,0,0,0,0,0,20.9966049194336,0,0,30.378303527832,0,11.7422409057617,0,0,-75.1168899536133,0,0,0,0,21.708122253418,0,0,32.668212890625,0,20.7369155883789,0,0,-82.466178894043,0,20.9971160888672,0,0,32.7915115356445,0,0,0,0,20.210563659668,0,-82.8507385253906,0,20.7984313964844,0,0,0,0,32.5355911254883,0,0,21.3889541625977,0,-82.5334777832031,0,0,0,0,21.0535202026367,0,32.0743255615234,0,0,20.0743637084961,0,25.9762115478516,0,0,-89.0126571655273,0,31.0331573486328,0,19.8076171875,0,0,29.7825622558594,0,-93.8031845092773,0,31.6293640136719,0,0,0,0,20.9948883056641,0,0,0,0,30.3721313476562,0,0,19.1538619995117,0,0,0,0,0,-81.9471664428711,0,0,0,20.7883529663086,0,31.0222473144531,0,0,0,0,0,20.8612899780273,0,0,0,-84.3838043212891,0,0,0,21.3154525756836,0,0,31.5505981445312,0,0,21.1201171875,0,-83.7534713745117,0,18.9585113525391,0,0,32.0724639892578,0,21.4459075927734,0,0,30.9586181640625,0,0,-93.7926788330078,0,0,0,0,30.1680755615234,0,0,0,0,0,20.7967224121094,0,0,0,0,32.4638290405273,0,10.3627700805664,0,0,-74.048698425293,0,0,19.0830383300781,0,0,0,30.8879547119141,0,0,20.1344985961914,0,-85.3230056762695,0,0,0,20.4672393798828,0,0,31.8075408935547,0,0,21.2477722167969,0,-83.8166122436523,0,0,20.5949859619141,0,31.7434768676758,0,21.5768890380859,0,0,25.6470413208008,0,0,-89.2000503540039,0,31.7454299926758,0,0,21.5116882324219,0,31.6108093261719,0,-94.3086395263672,0,0,0,0,0,31.8732070922852,0,0,20.6606521606445,0,0,32.2019729614258,0,13.905387878418,0,0,-77.5223846435547,0,20.5912857055664,0,0,0,0,31.8098526000977,0,20.7278060913086,0,-83.9513320922852,0,0,0,0,20.8567428588867,0,0,32.0086898803711,0,0,0,20.9889755249023,0,0,0,0,-83.2954330444336,0,0,0,0,20.1301422119141,0,0,0,0,31.4740982055664,0,0,0,0,21.6390838623047,0,0,0,24.5253982543945,0,0,-86.3568649291992,0,0,32.3269958496094,0,0,0,0,0,21.5069122314453,0,0,0,0,0,32.0649719238281,0,0,0,-93.7012405395508,0,32.4584884643555,0,19.6046295166016,0,31.3441314697266,0,10.7548217773438,0,0,0,0,0,-73.437255859375,0,21.4416275024414,0,0,30.9530029296875,0,0,20.7216186523438,0,0,0,0,-83.0187759399414,0,21.1798553466797,0,32.7830581665039,0,21.5070877075195,0,-83.0746154785156,0,0,21.1142044067383,0,32.3246612548828,0,21.4421768188477,0,0,0,0,-82.946403503418,0,0,21.1800842285156,0,32.3266677856445,0,0,21.1792144775391,0,24.3253784179688,0,0,-87.5361480712891,0,32.1957626342773,0,20.7861404418945,0,32.3896560668945,0,-93.9619293212891,0,0,0,0,0,31.5354156494141,0,0,21.1103515625,0,0,0,0,32.3870239257812,0,0,11.0802230834961,0,0,-72.4437789916992,0,0,20.4548492431641,0,0,32.1907196044922,0,19.799919128418,0,0,-81.4918823242188,0,0,0,0,21.6345443725586,0,31.8639068603516,0,0,0,0,21.6345367431641,0,-84.664909362793,0,20.5209732055664,0,0,30.1581573486328,0,0,0,0,20.1934432983398,0,0,20.1922607421875,0,0,-86.7367706298828,0,30.6163482666016,0,0,0,0,0,19.5371704101562,0,30.9445037841797,0,-95.3894500732422,0,0,0,0,30.5508041381836,0,0,0,0,0,20.9134521484375,0,31.2066802978516,0,18.3571090698242,0,0,-84.5720062255859,0,0,0,0,0,19.9303207397461,0,0,30.747428894043,0,20.4547271728516,0,-85.35888671875,0,0,20.1925430297852,0,31.9281921386719,0,0,0,0,0,9.33718872070312,0,0,0,0],"filename":["<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmpkh3LbX/file3c2b75568495.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    781.236    794.6105    811.5005    804.149    825.226
#>    compute_pi0(m * 10)   7855.497   7890.0390   8218.2673   7913.922   7954.075
#>   compute_pi0(m * 100)  78650.639  78738.5200  78984.3872  78907.391  79076.445
#>         compute_pi1(m)    161.592    189.5405   6183.4484    273.037    288.088
#>    compute_pi1(m * 10)   1256.534   1292.2460   1369.6275   1388.342   1430.360
#>   compute_pi1(m * 100)  12905.813  18275.6010  26424.1380  21649.770  25317.897
#>  compute_pi1(m * 1000) 235476.795 346713.3145 356659.5407 370910.799 376268.541
#>         max neval
#>     856.272    20
#>   13533.550    20
#>   79752.936    20
#>  110699.715    20
#>    1473.850    20
#>  125180.550    20
#>  484038.401    20
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
#>              expr        min         lq       mean    median         uq
#>   memory_copy1(n) 5532.16098 5187.97721 618.765107 4096.3957 3381.61420
#>   memory_copy2(n)   97.01004   93.93451  12.502418   75.6294   61.15794
#>  pre_allocate1(n)   23.02594   21.92026   4.130258   17.2947   14.00592
#>  pre_allocate2(n)  203.97191  194.35417  23.963726  155.8897  127.07920
#>     vectorized(n)    1.00000    1.00000   1.000000    1.0000    1.00000
#>        max neval
#>  88.898117    10
#>   3.104470    10
#>   2.139714    10
#>   4.163038    10
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
#>  f1(df) 250.2225 246.5278 81.17504 238.1983 68.37344 29.75935     5
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
