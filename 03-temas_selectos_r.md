
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
#>    id           a         b        c        d
#> 1   1  0.31184692 0.3815123 2.393781 5.689392
#> 2   2 -0.50143256 1.3892278 2.745542 3.057995
#> 3   3  0.72872920 4.3444778 1.701081 2.021788
#> 4   4  0.55711363 1.2591877 2.209583 3.898109
#> 5   5  0.06820220 0.0732710 3.193666 5.071350
#> 6   6  0.49791489 1.7776612 2.063021 5.054608
#> 7   7  0.80190766 1.8909559 4.544410 3.242143
#> 8   8  1.69013679 3.2703911 2.705670 4.346123
#> 9   9  0.01128898 1.4036417 4.910393 4.126744
#> 10 10  0.41358814 2.2711969 3.973570 5.507306
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.4579296
mean(df$b)
#> [1] 1.806152
mean(df$c)
#> [1] 3.044072
mean(df$d)
#> [1] 4.201556
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.4579296 1.8061523 3.0440718 4.2015559
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
#> [1] 0.4579296 1.8061523 3.0440718 4.2015559
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
#> [1] 5.5000000 0.4579296 1.8061523 3.0440718 4.2015559
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
#> [1] 5.5000000 0.4557515 1.5906514 2.7256061 4.2364339
col_describe(df, mean)
#> [1] 5.5000000 0.4579296 1.8061523 3.0440718 4.2015559
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
#> 5.5000000 0.4579296 1.8061523 3.0440718 4.2015559
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
#>   3.565   0.120   3.686
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.015   0.008   0.622
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
#>  12.216   0.712   9.348
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
#>   0.115   0.004   0.119
plyr_st
#>    user  system elapsed 
#>   3.976   0.028   4.004
est_l_st
#>    user  system elapsed 
#>  59.939   1.100  61.044
est_r_st
#>    user  system elapsed 
#>   0.396   0.004   0.400
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

<!--html_preserve--><div id="htmlwidget-e98f8fee6f6c15eee63a" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-e98f8fee6f6c15eee63a">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,3,4,4,5,5,5,5,6,6,7,7,7,8,8,9,9,9,10,10,11,11,12,12,12,12,12,13,13,14,14,14,15,15,15,15,15,16,16,16,16,16,17,17,17,17,17,18,18,18,19,19,20,20,21,21,22,22,22,23,23,23,24,24,24,24,24,25,25,26,26,26,27,27,27,28,28,29,29,29,29,29,29,30,30,31,31,32,32,32,32,32,33,33,33,34,34,35,35,36,36,37,37,37,38,38,39,39,40,40,41,41,42,42,43,43,43,43,44,44,44,44,44,44,45,45,45,45,45,46,46,47,47,48,48,48,48,48,48,49,49,50,50,50,51,51,51,52,52,52,52,53,53,53,54,54,54,55,55,55,56,56,57,57,57,57,57,57,58,58,59,59,59,60,60,60,61,61,61,61,61,62,62,62,62,63,63,63,64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,75,75,75,75,75,76,76,77,77,77,78,78,79,79,79,80,80,81,81,81,82,82,82,82,82,83,83,84,84,84,84,84,85,85,85,86,86,87,87,87,87,87,88,88,89,89,89,89,89,90,90,91,91,92,92,93,93,93,93,93,93,94,94,94,94,94,94,95,95,95,95,95,96,96,96,96,97,97,97,98,98,99,99,99,100,100,100,100,100,101,101,101,102,102,102,102,103,103,104,104,104,104,105,105,105,106,106,106,106,106,106,107,107,107,108,108,109,109,110,110,110,110,111,111,112,112,113,113,113,113,113,113,114,114,115,115,116,116,116,117,117,118,118,118,119,119,120,120,121,121,121,122,122,123,123,124,124,124,124,124,124,125,125,125,126,126,127,127,128,128,128,129,129,129,130,130,130,131,131,131,132,132,132,133,133,133,134,134,135,135,136,136,137,137,137,138,138,138,139,139,139,139,139,139,140,140,141,141,141,141,141,141,142,142,143,143,143,143,143,143,144,144,144,145,145,145,145,145,146,146,147,147,148,148,148,148,149,149,150,150,150,150,151,151,152,152,152,153,153,154,154,154,154,154,155,155,156,156,156,157,157,158,159,159,159,159,159,160,160,160,161,161,162,162,162,162,162,163,163,163,163,164,164,164,164,164,164,165,165,165,165,165,165,166,166,166,167,167,168,168,168,168,169,169,169,170,170,170,171,171,172,172,172,172,172,173,173,174,174,174,175,175,175,175,175,176,176,177,177,178,178,178,179,179,180,180,180,181,181,182,182,183,183,183,184,184,184,184,184,185,185,185,185,186,186,187,187,187,187,187,187,188,188,189,189,190,190,191,191,191,191,191,191,192,192,193,193,194,194,195,195,195,196,196,197,197,198,198,198,198,198,198,199,199,199,200,200,200,200,200,200,201,201,201,202,202,202,202,202,202,203,203,203,203,204,204,205,205,206,206,206,207,207,207,207,207,207,208,208,208,208,208,208,209,209,209,209,209,210,210,210,210,211,211,211,212,212,212,213,213,213,214,214,214,214,214,215,215,216,216,216,216,216,216,217,217,218,218,219,219,219,219,219,220,220,221,221,222,222,223,223,223,223,223,223,224,224,225,225,225,226,226,226,227,227,227,227,228,228,228,229,229,229,229,230,230,231,231,232,232,233,233,233,233,233,234,234,235,235,235,236,236,237,237,237,237,237,237,238,238,238,239,239,240,240,241,241,242,242,243,243,243,244,244,244,244,244,244,245,245,245,246,246,247,247,247,248,248,249,249,250,250,251,251,252,252,253,253,254,254,254,255,255,256,256,256,256,256,257,257,258,258,258,258,258,259,259,259,260,260,260,260,261,261,261,261,261,262,262,263,263,263,264,264,265,265,266,266,267,267,268,268,269,269,270,270,270,270,270,271,271,271,272,272,272,273,273,274,274,274,275,275,275,275,275],"depth":[2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","length","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","n[i] <- nrow(sub_Batting)","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,null,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,null,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,null,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,null,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1],"linenum":[9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,null,11,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,null,11,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,11,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,null,11,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,null,11,9,9,null,9,9,null,9,9,null,null,9,9,null,null,11,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,13],"memalloc":[63.6824951171875,63.6824951171875,85.2603225708008,85.2603225708008,112.815437316895,112.815437316895,112.815437316895,130.788116455078,130.788116455078,44.4661026000977,44.4661026000977,44.4661026000977,44.4661026000977,65.7860946655273,65.7860946655273,96.1609191894531,96.1609191894531,96.1609191894531,116.564659118652,116.564659118652,146.344650268555,146.344650268555,146.344650268555,52.8587799072266,52.8587799072266,84.9417495727539,84.9417495727539,105.019821166992,105.019821166992,105.019821166992,105.019821166992,105.019821166992,134.810157775879,134.810157775879,146.352607727051,146.352607727051,146.352607727051,72.2123489379883,72.2123489379883,72.2123489379883,72.2123489379883,72.2123489379883,93.528694152832,93.528694152832,93.528694152832,93.528694152832,93.528694152832,121.53645324707,121.53645324707,121.53645324707,121.53645324707,121.53645324707,141.738021850586,141.738021850586,141.738021850586,57.529052734375,57.529052734375,77.0779571533203,77.0779571533203,109.220664978027,109.220664978027,130.539260864258,130.539260864258,130.539260864258,45.9137496948242,45.9137496948242,45.9137496948242,66.5777435302734,66.5777435302734,66.5777435302734,66.5777435302734,66.5777435302734,98.6559982299805,98.6559982299805,119.912422180176,119.912422180176,119.912422180176,146.352111816406,146.352111816406,146.352111816406,56.5430145263672,56.5430145263672,88.2943572998047,88.2943572998047,88.2943572998047,88.2943572998047,88.2943572998047,88.2943572998047,108.438949584961,108.438949584961,138.682403564453,138.682403564453,43.5570373535156,43.5570373535156,43.5570373535156,43.5570373535156,43.5570373535156,74.7198257446289,74.7198257446289,74.7198257446289,95.7190322875977,95.7190322875977,125.50505065918,125.50505065918,145.51212310791,145.51212310791,61.6648559570312,61.6648559570312,61.6648559570312,82.6621780395508,82.6621780395508,113.238067626953,113.238067626953,133.054702758789,133.054702758789,48.8089294433594,48.8089294433594,69.3497772216797,69.3497772216797,91.4492797851562,91.4492797851562,91.4492797851562,91.4492797851562,112.842391967773,112.842391967773,112.842391967773,112.842391967773,112.842391967773,112.842391967773,144.988510131836,144.988510131836,144.988510131836,144.988510131836,144.988510131836,50.7135696411133,50.7135696411133,82.598503112793,82.598503112793,103.392539978027,103.392539978027,103.392539978027,103.392539978027,103.392539978027,103.392539978027,133.505874633789,133.505874633789,146.364646911621,146.364646911621,146.364646911621,70.1352996826172,70.1352996826172,70.1352996826172,90.9273986816406,90.9273986816406,90.9273986816406,90.9273986816406,121.163360595703,121.163360595703,121.163360595703,140.972808837891,140.972808837891,140.972808837891,55.7727813720703,55.7727813720703,55.7727813720703,76.375617980957,76.375617980957,107.666320800781,107.666320800781,107.666320800781,107.666320800781,107.666320800781,107.666320800781,127.609245300293,127.609245300293,97.4805603027344,97.4805603027344,97.4805603027344,63.6390762329102,63.6390762329102,63.6390762329102,96.0504379272461,96.0504379272461,96.0504379272461,96.0504379272461,96.0504379272461,116.196060180664,116.196060180664,116.196060180664,116.196060180664,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,146.373245239258,42.7886657714844,42.7886657714844,42.7886657714844,65.4256057739258,65.4256057739258,65.4256057739258,86.74658203125,86.74658203125,119.281181335449,119.281181335449,119.281181335449,119.281181335449,119.281181335449,140.863136291504,140.863136291504,57.9449768066406,57.9449768066406,57.9449768066406,78.4837493896484,78.4837493896484,109.906311035156,109.906311035156,109.906311035156,130.112228393555,130.112228393555,45.8082427978516,45.8082427978516,45.8082427978516,66.5309524536133,66.5309524536133,66.5309524536133,66.5309524536133,66.5309524536133,98.4115600585938,98.4115600585938,118.552749633789,118.552749633789,118.552749633789,118.552749633789,118.552749633789,146.362632751465,146.362632751465,146.362632751465,55.6560440063477,55.6560440063477,87.6035842895508,87.6035842895508,87.6035842895508,87.6035842895508,87.6035842895508,109.248405456543,109.248405456543,141.265121459961,141.265121459961,141.265121459961,141.265121459961,141.265121459961,48.4362640380859,48.4362640380859,79.9302978515625,79.9302978515625,100.655601501465,100.655601501465,130.699844360352,130.699844360352,130.699844360352,130.699844360352,130.699844360352,130.699844360352,146.3779296875,146.3779296875,146.3779296875,146.3779296875,146.3779296875,146.3779296875,69.1680374145508,69.1680374145508,69.1680374145508,69.1680374145508,69.1680374145508,90.4235458374023,90.4235458374023,90.4235458374023,90.4235458374023,123.155960083008,123.155960083008,123.155960083008,144.404579162598,144.404579162598,62.4846115112305,62.4846115112305,62.4846115112305,83.2111053466797,83.2111053466797,83.2111053466797,83.2111053466797,83.2111053466797,116.011131286621,116.011131286621,116.011131286621,136.740928649902,136.740928649902,136.740928649902,136.740928649902,53.6261825561523,53.6261825561523,74.2237396240234,74.2237396240234,74.2237396240234,74.2237396240234,105.770576477051,105.770576477051,105.770576477051,125.520118713379,125.520118713379,125.520118713379,125.520118713379,125.520118713379,125.520118713379,146.379768371582,146.379768371582,146.379768371582,62.5497512817383,62.5497512817383,93.1144256591797,93.1144256591797,113.191383361816,113.191383361816,113.191383361816,113.191383361816,144.35026550293,144.35026550293,50.5431060791016,50.5431060791016,79.4739532470703,79.4739532470703,79.4739532470703,79.4739532470703,79.4739532470703,79.4739532470703,100.065246582031,100.065246582031,129.517562866211,129.517562866211,146.370407104492,146.370407104492,146.370407104492,64.3888702392578,64.3888702392578,83.3447570800781,83.3447570800781,83.3447570800781,112.608459472656,112.608459472656,130.650939941406,130.650939941406,46.678108215332,46.678108215332,46.678108215332,66.7538604736328,66.7538604736328,97.0674819946289,97.0674819946289,117.274749755859,117.274749755859,117.274749755859,117.274749755859,117.274749755859,117.274749755859,146.334892272949,146.334892272949,146.334892272949,54.3525772094727,54.3525772094727,85.3199996948242,85.3199996948242,104.802276611328,104.802276611328,104.802276611328,136.028861999512,136.028861999512,136.028861999512,145.084457397461,145.084457397461,145.084457397461,72.7291717529297,72.7291717529297,72.7291717529297,92.7428512573242,92.7428512573242,92.7428512573242,121.543609619141,121.543609619141,121.543609619141,140.506698608398,140.506698608398,57.3791198730469,57.3791198730469,77.6556625366211,77.6556625366211,108.812225341797,108.812225341797,108.812225341797,129.148414611816,129.148414611816,129.148414611816,46.6202697753906,46.6202697753906,46.6202697753906,46.6202697753906,46.6202697753906,46.6202697753906,65.7770690917969,65.7770690917969,96.414192199707,96.414192199707,96.414192199707,96.414192199707,96.414192199707,96.414192199707,116.417343139648,116.417343139648,146.269515991211,146.269515991211,146.269515991211,146.269515991211,146.269515991211,146.269515991211,53.1203765869141,53.1203765869141,53.1203765869141,83.886360168457,83.886360168457,83.886360168457,83.886360168457,83.886360168457,104.485954284668,104.485954284668,136.303649902344,136.303649902344,43.998420715332,43.998420715332,43.998420715332,43.998420715332,75.6770935058594,75.6770935058594,96.5349197387695,96.5349197387695,96.5349197387695,96.5349197387695,127.23649597168,127.23649597168,146.390403747559,146.390403747559,146.390403747559,65.3814163208008,65.3814163208008,86.3760833740234,86.3760833740234,86.3760833740234,86.3760833740234,86.3760833740234,118.062133789062,118.062133789062,138.132797241211,138.132797241211,138.132797241211,56.0056838989258,56.0056838989258,76.7463912963867,108.497291564941,108.497291564941,108.497291564941,108.497291564941,108.497291564941,128.768859863281,128.768859863281,128.768859863281,45.5107727050781,45.5107727050781,65.5815048217773,65.5815048217773,65.5815048217773,65.5815048217773,65.5815048217773,97.520149230957,97.520149230957,97.520149230957,97.520149230957,118.639259338379,118.639259338379,118.639259338379,118.639259338379,118.639259338379,118.639259338379,146.387504577637,146.387504577637,146.387504577637,146.387504577637,146.387504577637,146.387504577637,56.7556610107422,56.7556610107422,56.7556610107422,89.2208099365234,89.2208099365234,110.605438232422,110.605438232422,110.605438232422,110.605438232422,143.337432861328,143.337432861328,143.337432861328,49.2851486206055,49.2851486206055,49.2851486206055,80.5070724487305,80.5070724487305,101.495658874512,101.495658874512,101.495658874512,101.495658874512,101.495658874512,133.896362304688,133.896362304688,146.357261657715,146.357261657715,146.357261657715,72.4358520507812,72.4358520507812,72.4358520507812,72.4358520507812,72.4358520507812,93.6222381591797,93.6222381591797,126.220031738281,126.220031738281,146.355979919434,146.355979919434,146.355979919434,64.895393371582,64.895393371582,86.4713439941406,86.4713439941406,86.4713439941406,119.45849609375,119.45849609375,141.166107177734,141.166107177734,58.7301788330078,58.7301788330078,58.7301788330078,80.3780822753906,80.3780822753906,80.3780822753906,80.3780822753906,80.3780822753906,112.250160217285,112.250160217285,112.250160217285,112.250160217285,133.955833435059,133.955833435059,51.5172500610352,51.5172500610352,51.5172500610352,51.5172500610352,51.5172500610352,51.5172500610352,73.2927932739258,73.2927932739258,106.086044311523,106.086044311523,127.861770629883,127.861770629883,46.206413269043,46.206413269043,46.206413269043,46.206413269043,46.206413269043,46.206413269043,67.1280746459961,67.1280746459961,99.3316116333008,99.3316116333008,120.910621643066,120.910621643066,146.355087280273,146.355087280273,146.355087280273,60.8344421386719,60.8344421386719,93.4951248168945,93.4951248168945,115.072982788086,115.072982788086,115.072982788086,115.072982788086,115.072982788086,115.072982788086,146.358558654785,146.358558654785,146.358558654785,54.7335586547852,54.7335586547852,54.7335586547852,54.7335586547852,54.7335586547852,54.7335586547852,86.9359741210938,86.9359741210938,86.9359741210938,108.906936645508,108.906936645508,108.906936645508,108.906936645508,108.906936645508,108.906936645508,141.833694458008,141.833694458008,141.833694458008,141.833694458008,49.3580093383789,49.3580093383789,81.2306671142578,81.2306671142578,102.023574829102,102.023574829102,102.023574829102,132.393035888672,132.393035888672,132.393035888672,132.393035888672,132.393035888672,132.393035888672,146.360252380371,146.360252380371,146.360252380371,146.360252380371,146.360252380371,146.360252380371,70.211067199707,70.211067199707,70.211067199707,70.211067199707,70.211067199707,89.6860275268555,89.6860275268555,89.6860275268555,89.6860275268555,121.882064819336,121.882064819336,121.882064819336,142.339202880859,142.339202880859,142.339202880859,59.984619140625,59.984619140625,59.984619140625,80.9026489257812,80.9026489257812,80.9026489257812,80.9026489257812,80.9026489257812,113.424629211426,113.424629211426,134.539726257324,134.539726257324,134.539726257324,134.539726257324,134.539726257324,134.539726257324,53.0996704101562,53.0996704101562,74.4110260009766,74.4110260009766,107.196243286133,107.196243286133,107.196243286133,107.196243286133,107.196243286133,127.064331054688,127.064331054688,44.1182479858398,44.1182479858398,65.1691055297852,65.1691055297852,96.8400726318359,96.8400726318359,96.8400726318359,96.8400726318359,96.8400726318359,96.8400726318359,118.613235473633,118.613235473633,146.351196289062,146.351196289062,146.351196289062,58.807991027832,58.807991027832,58.807991027832,90.6757354736328,90.6757354736328,90.6757354736328,90.6757354736328,112.246856689453,112.246856689453,112.246856689453,144.310394287109,144.310394287109,144.310394287109,144.310394287109,51.5310745239258,51.5310745239258,82.808708190918,82.808708190918,103.855888366699,103.855888366699,135.919883728027,135.919883728027,135.919883728027,135.919883728027,135.919883728027,44.0557098388672,44.0557098388672,75.6615905761719,75.6615905761719,75.6615905761719,96.6443176269531,96.6443176269531,128.773796081543,128.773796081543,128.773796081543,128.773796081543,128.773796081543,128.773796081543,146.345916748047,146.345916748047,146.345916748047,67.7930603027344,67.7930603027344,89.628288269043,89.628288269043,122.676063537598,122.676063537598,144.509010314941,144.509010314941,62.8730163574219,62.8730163574219,62.8730163574219,84.5735702514648,84.5735702514648,84.5735702514648,84.5735702514648,84.5735702514648,84.5735702514648,117.616050720215,117.616050720215,117.616050720215,139.31706237793,139.31706237793,58.1537322998047,58.1537322998047,58.1537322998047,79.5921096801758,79.5921096801758,111.84806060791,111.84806060791,133.418212890625,133.418212890625,52.4500961303711,52.4500961303711,73.6925201416016,73.6925201416016,106.407897949219,106.407897949219,128.174674987793,128.174674987793,128.174674987793,45.6071319580078,45.6071319580078,66.7184219360352,66.7184219360352,66.7184219360352,66.7184219360352,66.7184219360352,99.3674774169922,99.3674774169922,121.265487670898,121.265487670898,121.265487670898,121.265487670898,121.265487670898,146.375152587891,146.375152587891,146.375152587891,60.1627502441406,60.1627502441406,60.1627502441406,60.1627502441406,92.8773345947266,92.8773345947266,92.8773345947266,92.8773345947266,92.8773345947266,114.90544128418,114.90544128418,146.374366760254,146.374366760254,146.374366760254,53.9350814819336,53.9350814819336,85.3383712768555,85.3383712768555,107.235466003418,107.235466003418,140.277732849121,140.277732849121,46.0685348510742,46.0685348510742,77.6684265136719,77.6684265136719,98.0577163696289,98.0577163696289,98.0577163696289,98.0577163696289,98.0577163696289,130.509986877441,130.509986877441,130.509986877441,146.375587463379,146.375587463379,146.375587463379,69.4081039428711,69.4081039428711,90.12548828125,90.12548828125,90.12548828125,109.034507751465,109.034507751465,109.034507751465,109.034507751465,109.034507751465],"meminc":[0,0,21.5778274536133,0,27.5551147460938,0,0,17.9726791381836,0,-86.3220138549805,0,0,0,21.3199920654297,0,30.3748245239258,0,0,20.4037399291992,0,29.7799911499023,0,0,-93.4858703613281,0,32.0829696655273,0,20.0780715942383,0,0,0,0,29.7903366088867,0,11.5424499511719,0,0,-74.1402587890625,0,0,0,0,21.3163452148438,0,0,0,0,28.0077590942383,0,0,0,0,20.2015686035156,0,0,-84.2089691162109,0,19.5489044189453,0,32.142707824707,0,21.3185958862305,0,0,-84.6255111694336,0,0,20.6639938354492,0,0,0,0,32.078254699707,0,21.2564239501953,0,0,26.4396896362305,0,0,-89.8090972900391,0,31.7513427734375,0,0,0,0,0,20.1445922851562,0,30.2434539794922,0,-95.1253662109375,0,0,0,0,31.1627883911133,0,0,20.9992065429688,0,29.786018371582,0,20.0070724487305,0,-83.8472671508789,0,0,20.9973220825195,0,30.5758895874023,0,19.8166351318359,0,-84.2457733154297,0,20.5408477783203,0,22.0995025634766,0,0,0,21.3931121826172,0,0,0,0,0,32.1461181640625,0,0,0,0,-94.2749404907227,0,31.8849334716797,0,20.7940368652344,0,0,0,0,0,30.1133346557617,0,12.858772277832,0,0,-76.2293472290039,0,0,20.7920989990234,0,0,0,30.2359619140625,0,0,19.8094482421875,0,0,-85.2000274658203,0,0,20.6028366088867,0,31.2907028198242,0,0,0,0,0,19.9429244995117,0,-30.1286849975586,0,0,-33.8414840698242,0,0,32.4113616943359,0,0,0,0,20.145622253418,0,0,0,30.1771850585938,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,22.6369400024414,0,0,21.3209762573242,0,32.5345993041992,0,0,0,0,21.5819549560547,0,-82.9181594848633,0,0,20.5387725830078,0,31.4225616455078,0,0,20.2059173583984,0,-84.3039855957031,0,0,20.7227096557617,0,0,0,0,31.8806076049805,0,20.1411895751953,0,0,0,0,27.8098831176758,0,0,-90.7065887451172,0,31.9475402832031,0,0,0,0,21.6448211669922,0,32.016716003418,0,0,0,0,-92.828857421875,0,31.4940338134766,0,20.7253036499023,0,30.0442428588867,0,0,0,0,0,15.6780853271484,0,0,0,0,0,-77.2098922729492,0,0,0,0,21.2555084228516,0,0,0,32.7324142456055,0,0,21.2486190795898,0,-81.9199676513672,0,0,20.7264938354492,0,0,0,0,32.8000259399414,0,0,20.7297973632812,0,0,0,-83.11474609375,0,20.5975570678711,0,0,0,31.5468368530273,0,0,19.7495422363281,0,0,0,0,0,20.8596496582031,0,0,-83.8300170898438,0,30.5646743774414,0,20.0769577026367,0,0,0,31.1588821411133,0,-93.8071594238281,0,28.9308471679688,0,0,0,0,0,20.5912933349609,0,29.4523162841797,0,16.8528442382812,0,0,-81.9815368652344,0,18.9558868408203,0,0,29.2637023925781,0,18.04248046875,0,-83.9728317260742,0,0,20.0757522583008,0,30.3136215209961,0,20.2072677612305,0,0,0,0,0,29.0601425170898,0,0,-91.9823150634766,0,30.9674224853516,0,19.4822769165039,0,0,31.2265853881836,0,0,9.05559539794922,0,0,-72.3552856445312,0,0,20.0136795043945,0,0,28.8007583618164,0,0,18.9630889892578,0,-83.1275787353516,0,20.2765426635742,0,31.1565628051758,0,0,20.3361892700195,0,0,-82.5281448364258,0,0,0,0,0,19.1567993164062,0,30.6371231079102,0,0,0,0,0,20.0031509399414,0,29.8521728515625,0,0,0,0,0,-93.1491394042969,0,0,30.765983581543,0,0,0,0,20.5995941162109,0,31.8176956176758,0,-92.3052291870117,0,0,0,31.6786727905273,0,20.8578262329102,0,0,0,30.7015762329102,0,19.1539077758789,0,0,-81.0089874267578,0,20.9946670532227,0,0,0,0,31.6860504150391,0,20.0706634521484,0,0,-82.1271133422852,0,20.7407073974609,31.7509002685547,0,0,0,0,20.2715682983398,0,0,-83.2580871582031,0,20.0707321166992,0,0,0,0,31.9386444091797,0,0,0,21.1191101074219,0,0,0,0,0,27.7482452392578,0,0,0,0,0,-89.6318435668945,0,0,32.4651489257812,0,21.3846282958984,0,0,0,32.7319946289062,0,0,-94.0522842407227,0,0,31.221923828125,0,20.9885864257812,0,0,0,0,32.4007034301758,0,12.4608993530273,0,0,-73.9214096069336,0,0,0,0,21.1863861083984,0,32.5977935791016,0,20.1359481811523,0,0,-81.4605865478516,0,21.5759506225586,0,0,32.9871520996094,0,21.7076110839844,0,-82.4359283447266,0,0,21.6479034423828,0,0,0,0,31.8720779418945,0,0,0,21.7056732177734,0,-82.4385833740234,0,0,0,0,0,21.7755432128906,0,32.7932510375977,0,21.7757263183594,0,-81.6553573608398,0,0,0,0,0,20.9216613769531,0,32.2035369873047,0,21.5790100097656,0,25.444465637207,0,0,-85.5206451416016,0,32.6606826782227,0,21.5778579711914,0,0,0,0,0,31.2855758666992,0,0,-91.625,0,0,0,0,0,32.2024154663086,0,0,21.9709625244141,0,0,0,0,0,32.9267578125,0,0,0,-92.4756851196289,0,31.8726577758789,0,20.7929077148438,0,0,30.3694610595703,0,0,0,0,0,13.9672164916992,0,0,0,0,0,-76.1491851806641,0,0,0,0,19.4749603271484,0,0,0,32.1960372924805,0,0,20.4571380615234,0,0,-82.3545837402344,0,0,20.9180297851562,0,0,0,0,32.5219802856445,0,21.1150970458984,0,0,0,0,0,-81.440055847168,0,21.3113555908203,0,32.7852172851562,0,0,0,0,19.8680877685547,0,-82.9460830688477,0,21.0508575439453,0,31.6709671020508,0,0,0,0,0,21.7731628417969,0,27.7379608154297,0,0,-87.5432052612305,0,0,31.8677444458008,0,0,0,21.5711212158203,0,0,32.0635375976562,0,0,0,-92.7793197631836,0,31.2776336669922,0,21.0471801757812,0,32.0639953613281,0,0,0,0,-91.8641738891602,0,31.6058807373047,0,0,20.9827270507812,0,32.1294784545898,0,0,0,0,0,17.5721206665039,0,0,-78.5528564453125,0,21.8352279663086,0,33.0477752685547,0,21.8329467773438,0,-81.6359939575195,0,0,21.700553894043,0,0,0,0,0,33.04248046875,0,0,21.7010116577148,0,-81.163330078125,0,0,21.4383773803711,0,32.2559509277344,0,21.5701522827148,0,-80.9681167602539,0,21.2424240112305,0,32.7153778076172,0,21.7667770385742,0,0,-82.5675430297852,0,21.1112899780273,0,0,0,0,32.649055480957,0,21.8980102539062,0,0,0,0,25.1096649169922,0,0,-86.21240234375,0,0,0,32.7145843505859,0,0,0,0,22.0281066894531,0,31.4689254760742,0,0,-92.4392852783203,0,31.4032897949219,0,21.8970947265625,0,33.0422668457031,0,-94.2091979980469,0,31.5998916625977,0,20.389289855957,0,0,0,0,32.4522705078125,0,0,15.8656005859375,0,0,-76.9674835205078,0,20.7173843383789,0,0,18.9090194702148,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpDhmT55/file3c4326c4bf2a.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    829.528    844.8445   1129.4268    852.9360
#>    compute_pi0(m * 10)   8318.595   8350.1095   8475.5058   8425.1725
#>   compute_pi0(m * 100)  83265.074  83626.2990  83850.3635  83804.3355
#>         compute_pi1(m)    158.780    187.7075    639.1992    236.4305
#>    compute_pi1(m * 10)   1264.176   1283.9835   1387.1122   1306.2140
#>   compute_pi1(m * 100)  12454.147  15572.8160  18804.1028  19053.7010
#>  compute_pi1(m * 1000) 261717.368 346593.5700 352038.3687 353532.4385
#>           uq        max neval
#>     861.8910   6399.767    20
#>    8507.2795   9094.797    20
#>   83902.0175  85334.809    20
#>     274.3605   8472.307    20
#>    1380.5670   2385.112    20
#>   21667.0680  25107.460    20
#>  356223.1390 456629.296    20
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
#>   memory_copy1(n) 5092.68394 4147.27799 660.283853 3923.38309 3316.23405
#>   memory_copy2(n)   92.63782   75.64698  13.182464   73.41988   60.85519
#>  pre_allocate1(n)   20.64106   17.03800   4.408315   16.40580   13.68870
#>  pre_allocate2(n)  198.24499  161.92694  26.534551  153.94757  126.41752
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  106.036221    10
#>    3.171253    10
#>    2.408664    10
#>    5.097455    10
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
#>    expr     min       lq     mean   median       uq      max neval
#>  f1(df) 228.728 223.4527 80.88916 215.2308 65.58765 37.24194     5
#>  f2(df)   1.000   1.0000  1.00000   1.0000  1.00000  1.00000     5
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
