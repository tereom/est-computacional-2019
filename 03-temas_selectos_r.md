
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
#> 1   1 -0.5038009 -0.2606812 3.887586 3.370519
#> 2   2 -0.1026392  3.1888501 1.722899 5.006286
#> 3   3  0.5324085  1.0862809 2.660540 4.668504
#> 4   4 -1.1743959 -0.2808990 3.047512 2.273356
#> 5   5  0.4732748  1.2704437 3.266968 2.261087
#> 6   6  1.3754758  5.0486005 2.987099 2.680227
#> 7   7 -0.5809468  3.1372479 3.115072 4.611691
#> 8   8 -0.9103520  2.1074985 2.363604 4.710609
#> 9   9  1.6949743  0.6956356 1.055161 5.379012
#> 10 10 -0.9359513  1.3587459 3.020091 4.357980
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.01319525
mean(df$b)
#> [1] 1.735172
mean(df$c)
#> [1] 2.712653
mean(df$d)
#> [1] 3.931927
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.01319525  1.73517228  2.71265317  3.93192724
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
#> [1] -0.01319525  1.73517228  2.71265317  3.93192724
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
#> [1]  5.50000000 -0.01319525  1.73517228  2.71265317  3.93192724
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
#> [1]  5.500000 -0.303220  1.314595  3.003595  4.484836
col_describe(df, mean)
#> [1]  5.50000000 -0.01319525  1.73517228  2.71265317  3.93192724
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
#>  5.50000000 -0.01319525  1.73517228  2.71265317  3.93192724
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
#>   3.889   0.108   3.997
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.004   0.503
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
#>  13.170   0.705  10.103
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
#>   0.123   0.000   0.123
plyr_st
#>    user  system elapsed 
#>   4.315   0.016   4.331
est_l_st
#>    user  system elapsed 
#>  69.449   0.764  70.219
est_r_st
#>    user  system elapsed 
#>   0.409   0.020   0.429
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

<!--html_preserve--><div id="htmlwidget-475e29d9694b3591e3cf" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-475e29d9694b3591e3cf">{"x":{"message":{"prof":{"time":[1,1,1,1,1,2,2,3,3,4,4,4,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8,8,8,8,9,9,10,10,11,11,12,12,12,13,13,13,13,13,13,14,14,15,15,16,16,16,17,17,18,18,19,19,20,20,21,21,22,23,23,23,24,24,24,24,24,24,25,25,25,26,26,27,27,28,28,29,29,30,30,30,31,31,32,32,32,32,32,33,33,33,34,34,35,35,36,36,37,37,38,38,39,39,39,40,40,41,41,42,42,43,43,44,44,45,45,45,46,46,47,47,48,48,49,49,49,50,50,51,51,52,52,53,53,53,54,54,54,55,55,55,55,56,56,57,57,58,58,58,58,59,59,60,60,60,60,61,61,62,62,62,63,63,63,64,64,64,65,65,66,66,66,67,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,74,75,75,75,76,76,76,77,77,77,78,78,78,79,79,79,79,79,80,80,80,81,81,81,81,82,82,83,83,83,84,84,84,84,84,85,85,85,85,86,86,87,87,87,88,88,89,89,90,90,91,91,92,92,92,93,93,93,94,94,95,95,95,96,96,96,96,96,97,97,98,98,98,98,98,99,99,99,99,100,100,101,101,101,102,102,102,103,103,103,103,103,103,104,104,104,104,104,105,105,106,106,107,107,108,108,108,108,108,108,109,109,110,110,111,111,112,112,113,113,113,114,114,114,115,115,116,116,117,117,117,117,118,118,118,119,119,120,120,120,121,121,121,122,122,122,123,123,123,124,124,125,125,126,126,127,127,128,128,128,129,129,130,130,131,131,131,132,132,133,133,133,134,134,134,134,134,134,135,135,136,136,137,137,137,138,138,138,139,139,140,140,140,140,140,141,141,142,142,143,143,143,144,144,145,145,146,146,147,147,148,148,148,149,149,149,150,150,150,150,151,151,152,152,152,153,153,154,154,155,155,156,156,156,156,157,157,157,158,158,159,159,160,160,160,161,161,162,162,163,163,164,164,165,165,165,166,166,167,167,168,168,169,169,170,170,171,171,171,171,171,172,172,172,173,173,173,174,174,174,174,174,175,175,175,175,175,176,176,176,177,177,177,177,177,177,178,178,179,179,180,180,180,180,181,181,182,182,182,182,182,182,183,183,183,184,184,185,185,185,186,186,187,187,188,188,189,189,190,190,191,191,191,191,191,192,192,192,193,193,193,194,194,195,195,195,195,195,195,196,196,196,196,197,197,198,198,199,199,199,199,199,199,200,200,200,201,201,201,202,202,202,202,202,202,203,203,204,204,205,205,205,205,205,206,206,206,207,207,207,208,208,209,209,209,210,210,210,210,210,211,211,211,212,212,213,213,213,213,214,214,215,215,215,216,216,216,217,217,217,217,217,218,218,218,218,219,219,220,220,220,220,220,221,221,221,222,222,222,222,222,222,223,223,223,223,223,224,224,225,225,225,226,226,226,226,226,227,227,228,228,229,229,230,230,231,231,231,231,231,232,232,233,233,234,234,235,235,236,236,236,237,237,237,238,238,239,239,239,240,240,240,240,240,241,241,242,242,243,243,243,243,244,244,244,244,244,245,245,245,245,246,246,246,246,246,247,247,248,248,249,249,249,250,250,250,250,250,251,251,251,251,251,251,252,252,252,252,252,253,253,254,254,254,255,255,255,255,255,256,256,257,257,258,258,258,259,259,259,259,259,259,260,260,261,261,261,261,261,261,262,262,263,263,263,263,263,264,264,265,265,265,265,266,266,266,266,266,266,267,267,268,268,268,269,269,270,270,270,271,271,271,272,272,272,273,273,273,274,274,274,275,275,275,276,276,277,277,277,278,278,279,279,279,279,279,279,280,280,281,281,281,281,281,282,282,282,283,283,284,284,285,285,285,286,286,287,287,288,288,289,289,290,290,291,291,291,292,292,293,293,293,294,294,294,294,294,294,295,295,296,296,296,296,297,297,297,298,298,298,298,298,299,299,299,300,300,300,301,301,301,302,302,303,303,304,304,304,305,305,305,305,305],"depth":[5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1],"label":["%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","nrow","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","nargs","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","anyNA","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","$","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","attr","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","$","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,null,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,null,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,null,null,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1],"linenum":[null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,11,9,9,9,9,9,9,9,9,9,9,10,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,11,null,9,9,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,null,11,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,null,null,11,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,11,null,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,13],"memalloc":[55.940071105957,55.940071105957,55.940071105957,55.940071105957,55.940071105957,72.7324752807617,72.7324752807617,100.22013092041,100.22013092041,116.094337463379,116.094337463379,116.094337463379,116.094337463379,116.094337463379,116.094337463379,141.151092529297,141.151092529297,141.151092529297,146.333419799805,146.333419799805,146.333419799805,70.9035568237305,70.9035568237305,70.9035568237305,88.4211044311523,88.4211044311523,88.4211044311523,88.4211044311523,88.4211044311523,88.4211044311523,116.302543640137,116.302543640137,133.880874633789,133.880874633789,45.777702331543,45.777702331543,65.3925094604492,65.3925094604492,65.3925094604492,94.1270523071289,94.1270523071289,94.1270523071289,94.1270523071289,94.1270523071289,94.1270523071289,113.025718688965,113.025718688965,141.040710449219,141.040710449219,44.0743103027344,44.0743103027344,44.0743103027344,72.6062698364258,72.6062698364258,92.5449295043945,92.5449295043945,121.208084106445,121.208084106445,139.638710021973,139.638710021973,52.1470184326172,52.1470184326172,71.6978530883789,101.675170898438,101.675170898438,101.675170898438,120.832344055176,120.832344055176,120.832344055176,120.832344055176,120.832344055176,120.832344055176,146.347312927246,146.347312927246,146.347312927246,51.8197784423828,51.8197784423828,83.2401351928711,83.2401351928711,103.706329345703,103.706329345703,134.019981384277,134.019981384277,146.352165222168,146.352165222168,146.352165222168,64.680419921875,64.680419921875,83.3062210083008,83.3062210083008,83.3062210083008,83.3062210083008,83.3062210083008,113.029388427734,113.029388427734,113.029388427734,132.646476745605,132.646476745605,46.8366622924805,46.8366622924805,67.6343765258789,67.6343765258789,98.7358932495117,98.7358932495117,117.039192199707,117.039192199707,145.577667236328,145.577667236328,145.577667236328,47.6913986206055,47.6913986206055,77.214729309082,77.214729309082,96.3767471313477,96.3767471313477,125.049430847168,125.049430847168,143.154609680176,143.154609680176,53.4018096923828,53.4018096923828,53.4018096923828,72.2357330322266,72.2357330322266,101.031204223633,101.031204223633,120.649909973145,120.649909973145,146.365478515625,146.365478515625,146.365478515625,55.5038375854492,55.5038375854492,86.9927139282227,86.9927139282227,107.262168884277,107.262168884277,134.883338928223,134.883338928223,134.883338928223,146.364700317383,146.364700317383,146.364700317383,68.8241119384766,68.8241119384766,68.8241119384766,68.8241119384766,90.3368377685547,90.3368377685547,120.704521179199,120.704521179199,139.462562561035,139.462562561035,139.462562561035,139.462562561035,51.9665603637695,51.9665603637695,71.5242691040039,71.5242691040039,71.5242691040039,71.5242691040039,102.943054199219,102.943054199219,121.901657104492,121.901657104492,121.901657104492,146.372695922852,146.372695922852,146.372695922852,54.0614166259766,54.0614166259766,54.0614166259766,85.6154708862305,85.6154708862305,106.027267456055,106.027267456055,106.027267456055,134.304092407227,134.304092407227,134.304092407227,134.304092407227,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,146.37329864502,42.7887191772461,42.7887191772461,42.7887191772461,47.052619934082,47.052619934082,47.052619934082,47.052619934082,47.052619934082,59.1269912719727,59.1269912719727,59.1269912719727,89.3059234619141,89.3059234619141,89.3059234619141,89.3059234619141,108.788429260254,108.788429260254,139.421310424805,139.421310424805,139.421310424805,43.2490234375,43.2490234375,43.2490234375,43.2490234375,43.2490234375,71.5910110473633,71.5910110473633,71.5910110473633,71.5910110473633,90.5573501586914,90.5573501586914,119.353439331055,119.353439331055,119.353439331055,136.738571166992,136.738571166992,51.0533828735352,51.0533828735352,71.254768371582,71.254768371582,102.67936706543,102.67936706543,121.372856140137,121.372856140137,121.372856140137,146.362686157227,146.362686157227,146.362686157227,53.622444152832,53.622444152832,80.1898193359375,80.1898193359375,80.1898193359375,97.0477828979492,97.0477828979492,97.0477828979492,97.0477828979492,97.0477828979492,125.977699279785,125.977699279785,145.136856079102,145.136856079102,145.136856079102,145.136856079102,145.136856079102,58.8045883178711,58.8045883178711,58.8045883178711,58.8045883178711,75.4051208496094,75.4051208496094,105.181510925293,105.181510925293,105.181510925293,124.07080078125,124.07080078125,124.07080078125,146.377983093262,146.377983093262,146.377983093262,146.377983093262,146.377983093262,146.377983093262,54.1466827392578,54.1466827392578,54.1466827392578,54.1466827392578,54.1466827392578,81.4380035400391,81.4380035400391,98.4298324584961,98.4298324584961,125.843650817871,125.843650817871,144.273559570312,144.273559570312,144.273559570312,144.273559570312,144.273559570312,144.273559570312,56.5801544189453,56.5801544189453,75.0102996826172,75.0102996826172,105.120048522949,105.120048522949,120.928665161133,120.928665161133,146.383613586426,146.383613586426,146.383613586426,52.2489547729492,52.2489547729492,52.2489547729492,80.7801742553711,80.7801742553711,100.456573486328,100.456573486328,131.881317138672,131.881317138672,131.881317138672,131.881317138672,146.379821777344,146.379821777344,146.379821777344,63.5344772338867,63.5344772338867,81.374870300293,81.374870300293,81.374870300293,109.71630859375,109.71630859375,109.71630859375,128.672256469727,128.672256469727,128.672256469727,128.845062255859,128.845062255859,128.845062255859,60.2513198852539,60.2513198852539,88.3249664306641,88.3249664306641,106.365257263184,106.365257263184,132.075485229492,132.075485229492,146.370460510254,146.370460510254,146.370460510254,63.9296264648438,63.9296264648438,79.6705017089844,79.6705017089844,105.395217895508,105.395217895508,105.395217895508,123.238914489746,123.238914489746,146.332046508789,146.332046508789,146.332046508789,51.203987121582,51.203987121582,51.203987121582,51.203987121582,51.203987121582,51.203987121582,79.8788681030273,79.8788681030273,98.5773162841797,98.5773162841797,128.558708190918,128.558708190918,128.558708190918,146.334945678711,146.334945678711,146.334945678711,65.7683258056641,65.7683258056641,85.1890106201172,85.1890106201172,85.1890106201172,85.1890106201172,85.1890106201172,115.623504638672,115.623504638672,133.40355682373,133.40355682373,45.9618453979492,45.9618453979492,45.9618453979492,64.7214126586914,64.7214126586914,91.2334060668945,91.2334060668945,110.126434326172,110.126434326172,137.489540100098,137.489540100098,146.343902587891,146.343902587891,146.343902587891,72.1459426879883,72.1459426879883,72.1459426879883,91.7550201416016,91.7550201416016,91.7550201416016,91.7550201416016,122.7822265625,122.7822265625,140.174247741699,140.174247741699,140.174247741699,54.095588684082,54.095588684082,70.4372100830078,70.4372100830078,96.9384918212891,96.9384918212891,113.466079711914,113.466079711914,113.466079711914,113.466079711914,141.546516418457,141.546516418457,141.546516418457,43.9310836791992,43.9310836791992,71.0313186645508,71.0313186645508,87.8202896118164,87.8202896118164,87.8202896118164,117.739601135254,117.739601135254,137.418884277344,137.418884277344,48.1950836181641,48.1950836181641,64.7905120849609,64.7905120849609,93.2563552856445,93.2563552856445,93.2563552856445,112.673027038574,112.673027038574,141.995239257812,141.995239257812,45.6397247314453,45.6397247314453,74.369987487793,74.369987487793,95.1008911132812,95.1008911132812,125.800674438477,125.800674438477,125.800674438477,125.800674438477,125.800674438477,144.43041229248,144.43041229248,144.43041229248,56.3339157104492,56.3339157104492,56.3339157104492,75.5645599365234,75.5645599365234,75.5645599365234,75.5645599365234,75.5645599365234,106.858253479004,106.858253479004,106.858253479004,106.858253479004,106.858253479004,125.620880126953,125.620880126953,125.620880126953,146.348197937012,146.348197937012,146.348197937012,146.348197937012,146.348197937012,146.348197937012,59.088264465332,59.088264465332,88.5996780395508,88.5996780395508,107.291633605957,107.291633605957,107.291633605957,107.291633605957,136.48218536377,136.48218536377,146.387557983398,146.387557983398,146.387557983398,146.387557983398,146.387557983398,146.387557983398,69.3485641479492,69.3485641479492,69.3485641479492,89.1552810668945,89.1552810668945,119.656944274902,119.656944274902,119.656944274902,137.235336303711,137.235336303711,50.334098815918,50.334098815918,67.978874206543,67.978874206543,97.2974166870117,97.2974166870117,114.284072875977,114.284072875977,140.848297119141,140.848297119141,140.848297119141,140.848297119141,140.848297119141,64.215690612793,64.215690612793,64.215690612793,70.1405029296875,70.1405029296875,70.1405029296875,89.2281646728516,89.2281646728516,118.940093994141,118.940093994141,118.940093994141,118.940093994141,118.940093994141,118.940093994141,137.239356994629,137.239356994629,137.239356994629,137.239356994629,49.612907409668,49.612907409668,68.2410583496094,68.2410583496094,98.2092666625977,98.2092666625977,98.2092666625977,98.2092666625977,98.2092666625977,98.2092666625977,116.375984191895,116.375984191895,116.375984191895,146.283988952637,146.283988952637,146.283988952637,49.6130828857422,49.6130828857422,49.6130828857422,49.6130828857422,49.6130828857422,49.6130828857422,79.7221908569336,79.7221908569336,98.1509246826172,98.1509246826172,127.006805419922,127.006805419922,127.006805419922,127.006805419922,127.006805419922,145.238037109375,145.238037109375,145.238037109375,59.3882522583008,59.3882522583008,59.3882522583008,77.6872253417969,77.6872253417969,106.611305236816,106.611305236816,106.611305236816,125.172035217285,125.172035217285,125.172035217285,125.172035217285,125.172035217285,146.358154296875,146.358154296875,146.358154296875,55.5845794677734,55.5845794677734,83.9841690063477,83.9841690063477,83.9841690063477,83.9841690063477,104.120429992676,104.120429992676,132.518257141113,132.518257141113,132.518257141113,146.355140686035,146.355140686035,146.355140686035,59.5877151489258,59.5877151489258,59.5877151489258,59.5877151489258,59.5877151489258,78.2795639038086,78.2795639038086,78.2795639038086,78.2795639038086,109.629539489746,109.629539489746,130.092819213867,130.092819213867,130.092819213867,130.092819213867,130.092819213867,93.4084091186523,93.4084091186523,93.4084091186523,63.0631942749023,63.0631942749023,63.0631942749023,63.0631942749023,63.0631942749023,63.0631942749023,93.4939575195312,93.4939575195312,93.4939575195312,93.4939575195312,93.4939575195312,114.677032470703,114.677032470703,142.030830383301,142.030830383301,142.030830383301,47.1944427490234,47.1944427490234,47.1944427490234,47.1944427490234,47.1944427490234,75.7217025756836,75.7217025756836,94.0846710205078,94.0846710205078,124.194694519043,124.194694519043,143.998542785645,143.998542785645,57.621940612793,57.621940612793,57.621940612793,57.621940612793,57.621940612793,78.0143356323242,78.0143356323242,110.34162902832,110.34162902832,130.995697021484,130.995697021484,45.7556228637695,45.7556228637695,64.7053985595703,64.7053985595703,64.7053985595703,94.6066513061523,94.6066513061523,94.6066513061523,113.424583435059,113.424583435059,143.39225769043,143.39225769043,143.39225769043,47.1990051269531,47.1990051269531,47.1990051269531,47.1990051269531,47.1990051269531,76.3782196044922,76.3782196044922,94.3451919555664,94.3451919555664,123.982666015625,123.982666015625,123.982666015625,123.982666015625,140.180786132812,140.180786132812,140.180786132812,140.180786132812,140.180786132812,55.0053176879883,55.0053176879883,55.0053176879883,55.0053176879883,71.9238662719727,71.9238662719727,71.9238662719727,71.9238662719727,71.9238662719727,102.152816772461,102.152816772461,122.809616088867,122.809616088867,146.351249694824,146.351249694824,146.351249694824,52.8405532836914,52.8405532836914,52.8405532836914,52.8405532836914,52.8405532836914,84.2500915527344,84.2500915527344,84.2500915527344,84.2500915527344,84.2500915527344,84.2500915527344,104.051132202148,104.051132202148,104.051132202148,104.051132202148,104.051132202148,133.95036315918,133.95036315918,146.342727661133,146.342727661133,146.342727661133,65.1044387817383,65.1044387817383,65.1044387817383,65.1044387817383,65.1044387817383,86.0873413085938,86.0873413085938,115.920547485352,115.920547485352,135.657684326172,135.657684326172,135.657684326172,50.6130828857422,50.6130828857422,50.6130828857422,50.6130828857422,50.6130828857422,50.6130828857422,69.8914566040039,69.8914566040039,99.0704345703125,99.0704345703125,99.0704345703125,99.0704345703125,99.0704345703125,99.0704345703125,118.28343963623,118.28343963623,146.214912414551,146.214912414551,146.214912414551,146.214912414551,146.214912414551,51.5317611694336,51.5317611694336,81.8261642456055,81.8261642456055,81.8261642456055,81.8261642456055,103.201820373535,103.201820373535,103.201820373535,103.201820373535,103.201820373535,103.201820373535,134.937255859375,134.937255859375,146.345291137695,146.345291137695,146.345291137695,68.8390655517578,68.8390655517578,88.3764572143555,88.3764572143555,88.3764572143555,119.386169433594,119.386169433594,119.386169433594,139.972984313965,139.972984313965,139.972984313965,55.0065002441406,55.0065002441406,55.0065002441406,73.8886871337891,73.8886871337891,73.8886871337891,102.210784912109,102.210784912109,102.210784912109,120.698463439941,120.698463439941,146.334175109863,146.334175109863,146.334175109863,54.3514785766602,54.3514785766602,84.3135833740234,84.3135833740234,84.3135833740234,84.3135833740234,84.3135833740234,84.3135833740234,104.244453430176,104.244453430176,134.337524414062,134.337524414062,134.337524414062,134.337524414062,134.337524414062,146.335296630859,146.335296630859,146.335296630859,65.6037063598633,65.6037063598633,85.4686965942383,85.4686965942383,115.168411254883,115.168411254883,115.168411254883,136.410171508789,136.410171508789,50.2633285522461,50.2633285522461,70.5214614868164,70.5214614868164,100.941123962402,100.941123962402,120.347236633301,120.347236633301,146.374420166016,146.374420166016,146.374420166016,54.4600219726562,54.4600219726562,82.8474044799805,82.8474044799805,82.8474044799805,99.4994354248047,99.4994354248047,99.4994354248047,99.4994354248047,99.4994354248047,99.4994354248047,129.394775390625,129.394775390625,146.112884521484,146.112884521484,146.112884521484,146.112884521484,58.0663146972656,58.0663146972656,58.0663146972656,78.127311706543,78.127311706543,78.127311706543,78.127311706543,78.127311706543,105.334991455078,105.334991455078,105.334991455078,122.380226135254,122.380226135254,122.380226135254,146.375640869141,146.375640869141,146.375640869141,50.8550720214844,50.8550720214844,80.6188278198242,80.6188278198242,99.5661849975586,99.5661849975586,99.5661849975586,109.034561157227,109.034561157227,109.034561157227,109.034561157227,109.034561157227],"meminc":[0,0,0,0,0,16.7924041748047,0,27.4876556396484,0,15.8742065429688,0,0,0,0,0,25.056755065918,0,0,5.18232727050781,0,0,-75.4298629760742,0,0,17.5175476074219,0,0,0,0,0,27.8814392089844,0,17.5783309936523,0,-88.1031723022461,0,19.6148071289062,0,0,28.7345428466797,0,0,0,0,0,18.8986663818359,0,28.0149917602539,0,-96.9664001464844,0,0,28.5319595336914,0,19.9386596679688,0,28.6631546020508,0,18.4306259155273,0,-87.4916915893555,0,19.5508346557617,29.9773178100586,0,0,19.1571731567383,0,0,0,0,0,25.5149688720703,0,0,-94.5275344848633,0,31.4203567504883,0,20.466194152832,0,30.3136520385742,0,12.3321838378906,0,0,-81.671745300293,0,18.6258010864258,0,0,0,0,29.7231674194336,0,0,19.6170883178711,0,-85.809814453125,0,20.7977142333984,0,31.1015167236328,0,18.3032989501953,0,28.5384750366211,0,0,-97.8862686157227,0,29.5233306884766,0,19.1620178222656,0,28.6726837158203,0,18.1051788330078,0,-89.752799987793,0,0,18.8339233398438,0,28.7954711914062,0,19.6187057495117,0,25.7155685424805,0,0,-90.8616409301758,0,31.4888763427734,0,20.2694549560547,0,27.6211700439453,0,0,11.4813613891602,0,0,-77.5405883789062,0,0,0,21.5127258300781,0,30.3676834106445,0,18.7580413818359,0,0,0,-87.4960021972656,0,19.5577087402344,0,0,0,31.4187850952148,0,18.9586029052734,0,0,24.4710388183594,0,0,-92.311279296875,0,0,31.5540542602539,0,20.4117965698242,0,0,28.2768249511719,0,0,0,12.069206237793,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,4.26390075683594,0,0,0,0,12.0743713378906,0,0,30.1789321899414,0,0,0,19.4825057983398,0,30.6328811645508,0,0,-96.1722869873047,0,0,0,0,28.3419876098633,0,0,0,18.9663391113281,0,28.7960891723633,0,0,17.3851318359375,0,-85.685188293457,0,20.2013854980469,0,31.4245986938477,0,18.693489074707,0,0,24.9898300170898,0,0,-92.7402420043945,0,26.5673751831055,0,0,16.8579635620117,0,0,0,0,28.9299163818359,0,19.1591567993164,0,0,0,0,-86.3322677612305,0,0,0,16.6005325317383,0,29.7763900756836,0,0,18.889289855957,0,0,22.3071823120117,0,0,0,0,0,-92.2313003540039,0,0,0,0,27.2913208007812,0,16.991828918457,0,27.413818359375,0,18.4299087524414,0,0,0,0,0,-87.6934051513672,0,18.4301452636719,0,30.109748840332,0,15.8086166381836,0,25.454948425293,0,0,-94.1346588134766,0,0,28.5312194824219,0,19.676399230957,0,31.4247436523438,0,0,0,14.4985046386719,0,0,-82.845344543457,0,17.8403930664062,0,0,28.341438293457,0,0,18.9559478759766,0,0,0.172805786132812,0,0,-68.5937423706055,0,28.0736465454102,0,18.0402908325195,0,25.7102279663086,0,14.2949752807617,0,0,-82.4408340454102,0,15.7408752441406,0,25.7247161865234,0,0,17.8436965942383,0,23.093132019043,0,0,-95.128059387207,0,0,0,0,0,28.6748809814453,0,18.6984481811523,0,29.9813919067383,0,0,17.776237487793,0,0,-80.5666198730469,0,19.4206848144531,0,0,0,0,30.4344940185547,0,17.7800521850586,0,-87.4417114257812,0,0,18.7595672607422,0,26.5119934082031,0,18.8930282592773,0,27.3631057739258,0,8.85436248779297,0,0,-74.1979598999023,0,0,19.6090774536133,0,0,0,31.0272064208984,0,17.3920211791992,0,0,-86.0786590576172,0,16.3416213989258,0,26.5012817382812,0,16.527587890625,0,0,0,28.080436706543,0,0,-97.6154327392578,0,27.1002349853516,0,16.7889709472656,0,0,29.9193115234375,0,19.6792831420898,0,-89.2238006591797,0,16.5954284667969,0,28.4658432006836,0,0,19.4166717529297,0,29.3222122192383,0,-96.3555145263672,0,28.7302627563477,0,20.7309036254883,0,30.6997833251953,0,0,0,0,18.6297378540039,0,0,-88.0964965820312,0,0,19.2306442260742,0,0,0,0,31.2936935424805,0,0,0,0,18.7626266479492,0,0,20.7273178100586,0,0,0,0,0,-87.2599334716797,0,29.5114135742188,0,18.6919555664062,0,0,0,29.1905517578125,0,9.90537261962891,0,0,0,0,0,-77.0389938354492,0,0,19.8067169189453,0,30.5016632080078,0,0,17.5783920288086,0,-86.901237487793,0,17.644775390625,0,29.3185424804688,0,16.9866561889648,0,26.5642242431641,0,0,0,0,-76.6326065063477,0,0,5.92481231689453,0,0,19.0876617431641,0,29.7119293212891,0,0,0,0,0,18.2992630004883,0,0,0,-87.6264495849609,0,18.6281509399414,0,29.9682083129883,0,0,0,0,0,18.1667175292969,0,0,29.9080047607422,0,0,-96.6709060668945,0,0,0,0,0,30.1091079711914,0,18.4287338256836,0,28.8558807373047,0,0,0,0,18.2312316894531,0,0,-85.8497848510742,0,0,18.2989730834961,0,28.9240798950195,0,0,18.5607299804688,0,0,0,0,21.1861190795898,0,0,-90.7735748291016,0,28.3995895385742,0,0,0,20.1362609863281,0,28.3978271484375,0,0,13.8368835449219,0,0,-86.7674255371094,0,0,0,0,18.6918487548828,0,0,0,31.3499755859375,0,20.4632797241211,0,0,0,0,-36.6844100952148,0,0,-30.34521484375,0,0,0,0,0,30.4307632446289,0,0,0,0,21.1830749511719,0,27.3537979125977,0,0,-94.8363876342773,0,0,0,0,28.5272598266602,0,18.3629684448242,0,30.1100234985352,0,19.8038482666016,0,-86.3766021728516,0,0,0,0,20.3923950195312,0,32.3272933959961,0,20.6540679931641,0,-85.2400741577148,0,18.9497756958008,0,0,29.901252746582,0,0,18.8179321289062,0,29.9676742553711,0,0,-96.1932525634766,0,0,0,0,29.1792144775391,0,17.9669723510742,0,29.6374740600586,0,0,0,16.1981201171875,0,0,0,0,-85.1754684448242,0,0,0,16.9185485839844,0,0,0,0,30.2289505004883,0,20.6567993164062,0,23.541633605957,0,0,-93.5106964111328,0,0,0,0,31.409538269043,0,0,0,0,0,19.8010406494141,0,0,0,0,29.8992309570312,0,12.3923645019531,0,0,-81.2382888793945,0,0,0,0,20.9829025268555,0,29.8332061767578,0,19.7371368408203,0,0,-85.0446014404297,0,0,0,0,0,19.2783737182617,0,29.1789779663086,0,0,0,0,0,19.213005065918,0,27.9314727783203,0,0,0,0,-94.6831512451172,0,30.2944030761719,0,0,0,21.3756561279297,0,0,0,0,0,31.7354354858398,0,11.4080352783203,0,0,-77.5062255859375,0,19.5373916625977,0,0,31.0097122192383,0,0,20.5868148803711,0,0,-84.9664840698242,0,0,18.8821868896484,0,0,28.3220977783203,0,0,18.487678527832,0,25.6357116699219,0,0,-91.9826965332031,0,29.9621047973633,0,0,0,0,0,19.9308700561523,0,30.0930709838867,0,0,0,0,11.9977722167969,0,0,-80.7315902709961,0,19.864990234375,0,29.6997146606445,0,0,21.2417602539062,0,-86.146842956543,0,20.2581329345703,0,30.4196624755859,0,19.4061126708984,0,26.0271835327148,0,0,-91.9143981933594,0,28.3873825073242,0,0,16.6520309448242,0,0,0,0,0,29.8953399658203,0,16.7181091308594,0,0,0,-88.0465698242188,0,0,20.0609970092773,0,0,0,0,27.2076797485352,0,0,17.0452346801758,0,0,23.9954147338867,0,0,-95.5205688476562,0,29.7637557983398,0,18.9473571777344,0,0,9.46837615966797,0,0,0,0],"filename":[null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpM4WkGg/file3bf714be7f75.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    788.130    800.1255    846.8931    814.6265
#>    compute_pi0(m * 10)   7923.623   8096.1125   8562.5817   8213.1615
#>   compute_pi0(m * 100)  79943.630  80422.7860  81549.4382  81273.2875
#>         compute_pi1(m)    163.182    195.0785    268.1911    284.8890
#>    compute_pi1(m * 10)   1244.368   1354.8520   1396.2210   1409.5760
#>   compute_pi1(m * 100)  13282.084  14960.8865  36361.5910  19914.8695
#>  compute_pi1(m * 1000) 260547.605 372098.6620 374185.8177 381579.6220
#>           uq        max neval
#>     869.1165   1140.540    20
#>    8305.3465  15471.166    20
#>   82496.7600  85299.176    20
#>     306.5975    432.614    20
#>    1422.5940   1662.645    20
#>   24951.8740 137247.037    20
#>  390091.3330 518232.795    20
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
#>   memory_copy1(n) 5634.36932 3742.44703 629.153444 3579.66155 3195.71298
#>   memory_copy2(n)   98.85688   65.07056  12.031561   63.50157   57.06790
#>  pre_allocate1(n)   21.43097   14.10444   4.117772   14.10241   13.14336
#>  pre_allocate2(n)  211.32365  138.99824  25.054153  139.47030  125.08513
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  99.237922    10
#>   2.858775    10
#>   2.310346    10
#>   4.467375    10
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
#>    expr      min       lq     mean  median       uq      max neval
#>  f1(df) 237.3194 231.4882 80.90108 230.128 68.96493 29.81738     5
#>  f2(df)   1.0000   1.0000  1.00000   1.000  1.00000  1.00000     5
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
