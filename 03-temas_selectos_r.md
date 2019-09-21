
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
#>    id            a        b        c        d
#> 1   1  0.648578531 2.048491 2.719105 2.741949
#> 2   2 -0.478740698 1.108770 2.278490 4.475065
#> 3   3 -0.273988955 2.127099 2.329866 3.300301
#> 4   4  0.514999052 1.568001 3.079911 2.479474
#> 5   5  0.569138510 2.505692 4.181544 2.873841
#> 6   6  1.750415988 1.627380 4.274945 5.104667
#> 7   7  0.210670107 1.641006 4.476485 4.985738
#> 8   8 -0.938325358 2.155634 1.412786 2.474250
#> 9   9  1.815667394 2.068595 2.811057 4.228733
#> 10 10 -0.001666601 3.151305 3.998001 3.520530
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.3816748
mean(df$b)
#> [1] 2.000197
mean(df$c)
#> [1] 3.156219
mean(df$d)
#> [1] 3.618455
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.3816748 2.0001971 3.1562191 3.6184548
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
#> [1] 0.3816748 2.0001971 3.1562191 3.6184548
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
#> [1] 5.5000000 0.3816748 2.0001971 3.1562191 3.6184548
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
#> [1] 5.5000000 0.3628346 2.0585427 2.9454840 3.4104157
col_describe(df, mean)
#> [1] 5.5000000 0.3816748 2.0001971 3.1562191 3.6184548
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
#> 5.5000000 0.3816748 2.0001971 3.1562191 3.6184548
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
#>   3.654   0.112   3.766
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.020   0.000   0.515
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
#>  12.239   0.664   9.322
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
#>   0.101   0.000   0.102
plyr_st
#>    user  system elapsed 
#>   3.768   0.000   3.767
est_l_st
#>    user  system elapsed 
#>  56.583   1.188  57.773
est_r_st
#>    user  system elapsed 
#>   0.381   0.004   0.384
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

<!--html_preserve--><div id="htmlwidget-2330d9cddff7aba4941d" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-2330d9cddff7aba4941d">{"x":{"message":{"prof":{"time":[1,1,2,2,2,2,3,3,4,4,5,5,5,6,6,6,6,6,7,7,7,8,8,8,8,8,9,9,10,10,11,11,12,12,12,12,13,13,14,14,14,15,15,16,16,17,17,17,18,18,18,18,19,19,20,20,21,21,22,22,22,22,23,23,23,23,23,24,24,25,25,25,25,25,25,26,26,27,27,28,28,28,28,29,29,30,30,31,31,31,31,31,31,32,32,33,33,33,33,34,34,35,35,35,36,36,37,37,37,37,37,38,38,39,39,40,40,40,41,41,42,42,42,42,42,43,43,44,44,44,45,45,45,45,46,46,46,46,46,47,47,47,48,48,49,49,49,49,49,50,50,50,50,50,50,51,51,51,51,51,52,52,52,52,52,52,53,53,53,54,54,55,55,55,56,56,57,57,57,58,58,58,59,59,59,59,59,60,60,61,61,61,62,62,62,63,63,64,64,65,65,65,66,66,67,67,68,68,68,68,68,69,69,70,70,70,71,71,72,72,72,72,73,73,73,74,74,75,75,75,76,76,76,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,84,84,85,85,85,85,85,85,86,86,86,86,86,87,87,88,88,88,89,89,89,89,89,90,90,91,91,91,92,92,92,92,92,93,93,94,94,95,95,96,96,97,97,97,98,98,98,99,99,99,99,99,100,100,100,101,101,101,102,102,102,102,102,103,103,103,103,103,104,104,104,104,105,105,106,106,106,106,107,107,108,108,108,108,108,108,109,109,109,110,110,110,111,111,112,112,113,113,113,114,114,114,115,115,115,116,116,117,117,117,117,117,117,118,118,119,119,120,120,120,121,121,121,122,122,122,123,123,123,123,123,124,124,125,125,126,126,126,127,127,128,128,128,129,129,129,129,129,129,130,130,131,131,131,132,132,133,133,134,134,135,135,135,135,135,135,136,136,137,137,138,138,139,139,140,140,140,140,141,141,142,142,143,143,143,143,144,144,145,145,145,145,145,145,146,146,146,146,146,147,147,147,147,147,148,148,148,148,148,149,149,149,150,150,150,150,150,151,151,151,151,152,152,152,153,153,154,154,155,155,156,156,156,157,157,158,158,158,158,159,159,160,160,161,161,162,162,163,163,164,164,164,165,165,165,166,166,167,167,168,168,168,168,168,168,169,169,169,170,170,171,171,172,172,173,173,173,173,173,173,174,174,174,174,174,174,175,175,176,176,177,177,178,178,179,179,179,179,179,180,180,181,181,182,182,183,183,183,184,184,185,185,185,186,186,187,187,188,188,189,189,189,190,190,190,191,191,192,192,192,192,192,192,193,193,193,193,193,194,194,195,195,196,196,197,197,197,197,198,198,199,199,200,200,201,201,202,202,203,203,204,204,205,205,205,206,206,207,207,207,207,207,208,208,208,208,208,209,209,209,209,210,210,211,211,212,212,213,213,214,214,214,215,215,216,216,217,217,218,218,219,219,220,220,221,221,221,221,221,222,222,223,223,223,223,223,224,224,224,225,225,225,226,226,227,227,227,228,228,228,228,228,229,229,230,230,231,231,231,232,232,233,233,233,234,234,234,235,235,236,236,237,237,237,237,237,237,238,238,239,239,240,240,241,241,242,242,242,243,243,244,244,244,244,244,244,245,245,246,246,246,246,246,247,247,247,247,247,247,248,248,248,248,248,249,249,249,249,249,249,250,250,250,250,250,250,251,251,251,251,251,252,252,252,252,252,253,253,253,253,254,254,255,255,255,256,256,256,256,256,256,257,257,257,258,258,259,259,259,260,260,261,261,261,262,262,262,262,263,263,264,264,264,264,264],"depth":[2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1],"label":["[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","$","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","$","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","oldClass","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,null,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,null,null,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,null,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1],"linenum":[9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,null,11,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,10,10,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,null,null,11,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,null,11,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,13],"memalloc":[61.2559814453125,61.2559814453125,82.5070877075195,82.5070877075195,82.5070877075195,82.5070877075195,109.40478515625,109.40478515625,125.541862487793,125.541862487793,146.268661499023,146.268661499023,146.268661499023,60.3428421020508,60.3428421020508,60.3428421020508,60.3428421020508,60.3428421020508,92.8823623657227,92.8823623657227,92.8823623657227,112.959228515625,112.959228515625,112.959228515625,112.959228515625,112.959228515625,142.935890197754,142.935890197754,50.8920440673828,50.8920440673828,83.3024673461914,83.3024673461914,103.11653137207,103.11653137207,103.11653137207,103.11653137207,133.564491271973,133.564491271973,146.287902832031,146.287902832031,146.287902832031,72.3442459106445,72.3442459106445,92.3490982055664,92.3490982055664,122.783325195312,122.783325195312,122.783325195312,142.592491149902,142.592491149902,142.592491149902,142.592491149902,60.7426452636719,60.7426452636719,81.7369537353516,81.7369537353516,113.748123168945,113.748123168945,135.002799987793,135.002799987793,135.002799987793,135.002799987793,54.0526733398438,54.0526733398438,54.0526733398438,54.0526733398438,54.0526733398438,75.5669403076172,75.5669403076172,107.250839233398,107.250839233398,107.250839233398,107.250839233398,107.250839233398,107.250839233398,128.771842956543,128.771842956543,47.621955871582,47.621955871582,67.8972625732422,67.8972625732422,67.8972625732422,67.8972625732422,100.172035217285,100.172035217285,120.311935424805,120.311935424805,146.296974182129,146.296974182129,146.296974182129,146.296974182129,146.296974182129,146.296974182129,58.7095794677734,58.7095794677734,91.0621109008789,91.0621109008789,91.0621109008789,91.0621109008789,110.808471679688,110.808471679688,140.724128723145,140.724128723145,140.724128723145,48.4144058227539,48.4144058227539,80.8272933959961,80.8272933959961,80.8272933959961,80.8272933959961,80.8272933959961,101.695243835449,101.695243835449,132.005378723145,132.005378723145,146.303291320801,146.303291320801,146.303291320801,71.5800933837891,71.5800933837891,92.9585418701172,92.9585418701172,92.9585418701172,92.9585418701172,92.9585418701172,125.898643493652,125.898643493652,146.300720214844,146.300720214844,146.300720214844,65.5379028320312,65.5379028320312,65.5379028320312,65.5379028320312,84.7634963989258,84.7634963989258,84.7634963989258,84.7634963989258,84.7634963989258,115.593437194824,115.593437194824,115.593437194824,135.474868774414,135.474868774414,54.5859680175781,54.5859680175781,54.5859680175781,54.5859680175781,54.5859680175781,75.9741973876953,75.9741973876953,75.9741973876953,75.9741973876953,75.9741973876953,75.9741973876953,108.17741394043,108.17741394043,108.17741394043,108.17741394043,108.17741394043,128.311943054199,128.311943054199,128.311943054199,128.311943054199,128.311943054199,128.311943054199,47.8329467773438,47.8329467773438,47.8329467773438,68.7011947631836,68.7011947631836,101.368156433105,101.368156433105,101.368156433105,121.770729064941,121.770729064941,146.30793762207,146.30793762207,146.30793762207,60.2945785522461,60.2945785522461,60.2945785522461,92.0485000610352,92.0485000610352,92.0485000610352,92.0485000610352,92.0485000610352,112.131439208984,112.131439208984,142.175079345703,142.175079345703,142.175079345703,49.2131271362305,49.2131271362305,49.2131271362305,81.5602188110352,81.5602188110352,102.883171081543,102.883171081543,135.80835723877,135.80835723877,135.80835723877,44.2946319580078,44.2946319580078,75.5900802612305,75.5900802612305,96.7188415527344,96.7188415527344,96.7188415527344,96.7188415527344,96.7188415527344,127.091537475586,127.091537475586,146.311218261719,146.311218261719,146.311218261719,66.9867401123047,66.9867401123047,88.4377670288086,88.4377670288086,88.4377670288086,88.4377670288086,121.699897766113,121.699897766113,121.699897766113,142.68921661377,142.68921661377,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,146.295196533203,42.7237854003906,42.7237854003906,42.7237854003906,50.9909820556641,50.9909820556641,50.9909820556641,50.9909820556641,50.9909820556641,82.6782836914062,82.6782836914062,82.6782836914062,82.6782836914062,82.6782836914062,82.6782836914062,103.407264709473,103.407264709473,103.407264709473,103.407264709473,103.407264709473,134.832702636719,134.832702636719,146.311973571777,146.311973571777,146.311973571777,72.2504043579102,72.2504043579102,72.2504043579102,72.2504043579102,72.2504043579102,92.6489715576172,92.6489715576172,122.428443908691,122.428443908691,122.428443908691,141.715927124023,141.715927124023,141.715927124023,141.715927124023,141.715927124023,58.4046478271484,58.4046478271484,79.5289611816406,79.5289611816406,111.212989807129,111.212989807129,129.380737304688,129.380737304688,45.0245895385742,45.0245895385742,45.0245895385742,65.1674041748047,65.1674041748047,65.1674041748047,96.9792785644531,96.9792785644531,96.9792785644531,96.9792785644531,96.9792785644531,118.693923950195,118.693923950195,118.693923950195,146.31120300293,146.31120300293,146.31120300293,56.6380462646484,56.6380462646484,56.6380462646484,56.6380462646484,56.6380462646484,88.0545043945312,88.0545043945312,88.0545043945312,88.0545043945312,88.0545043945312,109.438690185547,109.438690185547,109.438690185547,109.438690185547,141.387016296387,141.387016296387,47.9800796508789,47.9800796508789,47.9800796508789,47.9800796508789,80.4504699707031,80.4504699707031,101.638710021973,101.638710021973,101.638710021973,101.638710021973,101.638710021973,101.638710021973,132.077774047852,132.077774047852,132.077774047852,146.31201171875,146.31201171875,146.31201171875,71.0068893432617,71.0068893432617,92.7141571044922,92.7141571044922,125.317733764648,125.317733764648,125.317733764648,146.301078796387,146.301078796387,146.301078796387,66.3483581542969,66.3483581542969,66.3483581542969,86.4848709106445,86.4848709106445,118.24186706543,118.24186706543,118.24186706543,118.24186706543,118.24186706543,118.24186706543,138.710914611816,138.710914611816,57.0391006469727,57.0391006469727,78.2976531982422,78.2976531982422,78.2976531982422,109.988578796387,109.988578796387,109.988578796387,131.832862854004,131.832862854004,131.832862854004,51.1996231079102,51.1996231079102,51.1996231079102,51.1996231079102,51.1996231079102,72.1921005249023,72.1921005249023,104.073684692383,104.073684692383,125.393463134766,125.393463134766,125.393463134766,46.6102142333984,46.6102142333984,67.7344741821289,67.7344741821289,67.7344741821289,99.5578994750977,99.5578994750977,99.5578994750977,99.5578994750977,99.5578994750977,99.5578994750977,121.209342956543,121.209342956543,146.272048950195,146.272048950195,146.272048950195,62.8197708129883,62.8197708129883,96.4705352783203,96.4705352783203,116.742965698242,116.742965698242,146.26969909668,146.26969909668,146.26969909668,146.26969909668,146.26969909668,146.26969909668,57.3678588867188,57.3678588867188,89.0635223388672,89.0635223388672,111.622200012207,111.622200012207,144.229530334473,144.229530334473,54.2963562011719,54.2963562011719,54.2963562011719,54.2963562011719,86.8977508544922,86.8977508544922,108.547782897949,108.547782897949,138.988502502441,138.988502502441,138.988502502441,138.988502502441,49.6322479248047,49.6322479248047,82.2993545532227,82.2993545532227,82.2993545532227,82.2993545532227,82.2993545532227,82.2993545532227,103.614524841309,103.614524841309,103.614524841309,103.614524841309,103.614524841309,136.414375305176,136.414375305176,136.414375305176,136.414375305176,136.414375305176,47.8639144897461,47.8639144897461,47.8639144897461,47.8639144897461,47.8639144897461,79.8129119873047,79.8129119873047,79.8129119873047,100.998672485352,100.998672485352,100.998672485352,100.998672485352,100.998672485352,132.483818054199,132.483818054199,132.483818054199,132.483818054199,146.261047363281,146.261047363281,146.261047363281,74.967903137207,74.967903137207,96.7516021728516,96.7516021728516,129.879638671875,129.879638671875,146.277702331543,146.277702331543,146.277702331543,73.5743789672852,73.5743789672852,94.5615386962891,94.5615386962891,94.5615386962891,94.5615386962891,126.373825073242,126.373825073242,146.118446350098,146.118446350098,67.8017272949219,67.8017272949219,89.6427383422852,89.6427383422852,122.571144104004,122.571144104004,144.546257019043,144.546257019043,144.546257019043,66.367546081543,66.367546081543,66.367546081543,88.3392105102539,88.3392105102539,121.591194152832,121.591194152832,143.564582824707,143.564582824707,143.564582824707,143.564582824707,143.564582824707,143.564582824707,66.0368804931641,66.0368804931641,66.0368804931641,87.6794128417969,87.6794128417969,120.804153442383,120.804153442383,142.579322814941,142.579322814941,63.5807723999023,63.5807723999023,63.5807723999023,63.5807723999023,63.5807723999023,63.5807723999023,85.6812057495117,85.6812057495117,85.6812057495117,85.6812057495117,85.6812057495117,85.6812057495117,118.931541442871,118.931541442871,140.835731506348,140.835731506348,62.7307205200195,62.7307205200195,85.5584564208984,85.5584564208984,119.00520324707,119.00520324707,119.00520324707,119.00520324707,119.00520324707,140.448783874512,140.448783874512,62.6651992797852,62.6651992797852,84.3079147338867,84.3079147338867,117.560241699219,117.560241699219,117.560241699219,138.748710632324,138.748710632324,61.418327331543,61.418327331543,61.418327331543,83.9808959960938,83.9808959960938,117.825248718262,117.825248718262,139.598289489746,139.598289489746,62.0113220214844,62.0113220214844,62.0113220214844,84.0482711791992,84.0482711791992,84.0482711791992,117.23462677002,117.23462677002,139.33674621582,139.33674621582,139.33674621582,139.33674621582,139.33674621582,139.33674621582,61.3539657592773,61.3539657592773,61.3539657592773,61.3539657592773,61.3539657592773,83.71923828125,83.71923828125,116.96898651123,116.96898651123,137.828582763672,137.828582763672,59.1903076171875,59.1903076171875,59.1903076171875,59.1903076171875,81.5549163818359,81.5549163818359,113.957870483398,113.957870483398,134.684188842773,134.684188842773,55.717041015625,55.717041015625,77.7490310668945,77.7490310668945,110.862701416016,110.862701416016,132.632209777832,132.632209777832,54.0140228271484,54.0140228271484,54.0140228271484,76.5704498291016,76.5704498291016,109.356071472168,109.356071472168,109.356071472168,109.356071472168,109.356071472168,131.38835144043,131.38835144043,131.38835144043,131.38835144043,131.38835144043,52.8984298706055,52.8984298706055,52.8984298706055,52.8984298706055,75.1271209716797,75.1271209716797,107.387825012207,107.387825012207,128.043357849121,128.043357849121,49.5568466186523,49.5568466186523,71.6565704345703,71.6565704345703,71.6565704345703,103.918327331543,103.918327331543,125.755615234375,125.755615234375,46.9336471557617,46.9336471557617,68.7696838378906,68.7696838378906,102.013076782227,102.013076782227,123.979438781738,123.979438781738,45.8201522827148,45.8201522827148,45.8201522827148,45.8201522827148,45.8201522827148,67.066047668457,67.066047668457,99.2612380981445,99.2612380981445,99.2612380981445,99.2612380981445,99.2612380981445,121.030311584473,121.030311584473,121.030311584473,146.275001525879,146.275001525879,146.275001525879,62.3450164794922,62.3450164794922,94.2782669067383,94.2782669067383,94.2782669067383,114.605735778809,114.605735778809,114.605735778809,114.605735778809,114.605735778809,145.42244720459,145.42244720459,55.1978225708008,55.1978225708008,87.2622222900391,87.2622222900391,87.2622222900391,108.834945678711,108.834945678711,142.340232849121,142.340232849121,142.340232849121,52.3784790039062,52.3784790039062,52.3784790039062,86.3389511108398,86.3389511108398,108.432807922363,108.432807922363,141.606826782227,141.606826782227,141.606826782227,141.606826782227,141.606826782227,141.606826782227,51.9199523925781,51.9199523925781,84.3733901977539,84.3733901977539,105.614616394043,105.614616394043,140.428825378418,140.428825378418,52.0522079467773,52.0522079467773,52.0522079467773,85.8167953491211,85.8167953491211,107.583740234375,107.583740234375,107.583740234375,107.583740234375,107.583740234375,107.583740234375,140.88875579834,140.88875579834,52.5119018554688,52.5119018554688,52.5119018554688,52.5119018554688,52.5119018554688,85.751335144043,85.751335144043,85.751335144043,85.751335144043,85.751335144043,85.751335144043,108.10774230957,108.10774230957,108.10774230957,108.10774230957,108.10774230957,142.855506896973,142.855506896973,142.855506896973,142.855506896973,142.855506896973,142.855506896973,55.0690231323242,55.0690231323242,55.0690231323242,55.0690231323242,55.0690231323242,55.0690231323242,88.4394989013672,88.4394989013672,88.4394989013672,88.4394989013672,88.4394989013672,111.581855773926,111.581855773926,111.581855773926,111.581855773926,111.581855773926,145.083457946777,145.083457946777,145.083457946777,145.083457946777,56.9057464599609,56.9057464599609,90.6689910888672,90.6689910888672,90.6689910888672,113.352554321289,113.352554321289,113.352554321289,113.352554321289,113.352554321289,113.352554321289,146.263786315918,146.263786315918,146.263786315918,57.2131423950195,57.2131423950195,91.6977386474609,91.6977386474609,91.6977386474609,114.971183776855,114.971183776855,146.309020996094,146.309020996094,146.309020996094,59.9669876098633,59.9669876098633,59.9669876098633,59.9669876098633,93.2713241577148,93.2713241577148,112.508522033691,112.508522033691,112.508522033691,112.508522033691,112.508522033691],"meminc":[0,0,21.251106262207,0,0,0,26.8976974487305,0,16.137077331543,0,20.7267990112305,0,0,-85.9258193969727,0,0,0,0,32.5395202636719,0,0,20.0768661499023,0,0,0,0,29.9766616821289,0,-92.0438461303711,0,32.4104232788086,0,19.8140640258789,0,0,0,30.4479598999023,0,12.7234115600586,0,0,-73.9436569213867,0,20.0048522949219,0,30.4342269897461,0,0,19.8091659545898,0,0,0,-81.8498458862305,0,20.9943084716797,0,32.0111694335938,0,21.2546768188477,0,0,0,-80.9501266479492,0,0,0,0,21.5142669677734,0,31.6838989257812,0,0,0,0,0,21.5210037231445,0,-81.1498870849609,0,20.2753067016602,0,0,0,32.274772644043,0,20.1399002075195,0,25.9850387573242,0,0,0,0,0,-87.5873947143555,0,32.3525314331055,0,0,0,19.7463607788086,0,29.915657043457,0,0,-92.3097229003906,0,32.4128875732422,0,0,0,0,20.8679504394531,0,30.3101348876953,0,14.2979125976562,0,0,-74.7231979370117,0,21.3784484863281,0,0,0,0,32.9401016235352,0,20.4020767211914,0,0,-80.7628173828125,0,0,0,19.2255935668945,0,0,0,0,30.8299407958984,0,0,19.8814315795898,0,-80.8889007568359,0,0,0,0,21.3882293701172,0,0,0,0,0,32.2032165527344,0,0,0,0,20.1345291137695,0,0,0,0,0,-80.4789962768555,0,0,20.8682479858398,0,32.6669616699219,0,0,20.4025726318359,0,24.5372085571289,0,0,-86.0133590698242,0,0,31.7539215087891,0,0,0,0,20.0829391479492,0,30.0436401367188,0,0,-92.9619522094727,0,0,32.3470916748047,0,21.3229522705078,0,32.9251861572266,0,0,-91.5137252807617,0,31.2954483032227,0,21.1287612915039,0,0,0,0,30.3726959228516,0,19.2196807861328,0,0,-79.3244781494141,0,21.4510269165039,0,0,0,33.2621307373047,0,0,20.9893188476562,0,3.60597991943359,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,8.26719665527344,0,0,0,0,31.6873016357422,0,0,0,0,0,20.7289810180664,0,0,0,0,31.4254379272461,0,11.4792709350586,0,0,-74.0615692138672,0,0,0,0,20.398567199707,0,29.7794723510742,0,0,19.287483215332,0,0,0,0,-83.311279296875,0,21.1243133544922,0,31.6840286254883,0,18.1677474975586,0,-84.3561477661133,0,0,20.1428146362305,0,0,31.8118743896484,0,0,0,0,21.7146453857422,0,0,27.6172790527344,0,0,-89.6731567382812,0,0,0,0,31.4164581298828,0,0,0,0,21.3841857910156,0,0,0,31.9483261108398,0,-93.4069366455078,0,0,0,32.4703903198242,0,21.1882400512695,0,0,0,0,0,30.4390640258789,0,0,14.2342376708984,0,0,-75.3051223754883,0,21.7072677612305,0,32.6035766601562,0,0,20.9833450317383,0,0,-79.9527206420898,0,0,20.1365127563477,0,31.7569961547852,0,0,0,0,0,20.4690475463867,0,-81.6718139648438,0,21.2585525512695,0,0,31.6909255981445,0,0,21.8442840576172,0,0,-80.6332397460938,0,0,0,0,20.9924774169922,0,31.8815841674805,0,21.3197784423828,0,0,-78.7832489013672,0,21.1242599487305,0,0,31.8234252929688,0,0,0,0,0,21.6514434814453,0,25.0627059936523,0,0,-83.452278137207,0,33.650764465332,0,20.2724304199219,0,29.5267333984375,0,0,0,0,0,-88.9018402099609,0,31.6956634521484,0,22.5586776733398,0,32.6073303222656,0,-89.9331741333008,0,0,0,32.6013946533203,0,21.650032043457,0,30.4407196044922,0,0,0,-89.3562545776367,0,32.667106628418,0,0,0,0,0,21.3151702880859,0,0,0,0,32.7998504638672,0,0,0,0,-88.5504608154297,0,0,0,0,31.9489974975586,0,0,21.1857604980469,0,0,0,0,31.4851455688477,0,0,0,13.777229309082,0,0,-71.2931442260742,0,21.7836990356445,0,33.1280364990234,0,16.398063659668,0,0,-72.7033233642578,0,20.9871597290039,0,0,0,31.8122863769531,0,19.7446212768555,0,-78.3167190551758,0,21.8410110473633,0,32.9284057617188,0,21.9751129150391,0,0,-78.1787109375,0,0,21.9716644287109,0,33.2519836425781,0,21.973388671875,0,0,0,0,0,-77.527702331543,0,0,21.6425323486328,0,33.1247406005859,0,21.7751693725586,0,-78.9985504150391,0,0,0,0,0,22.1004333496094,0,0,0,0,0,33.2503356933594,0,21.9041900634766,0,-78.1050109863281,0,22.8277359008789,0,33.4467468261719,0,0,0,0,21.4435806274414,0,-77.7835845947266,0,21.6427154541016,0,33.252326965332,0,0,21.1884689331055,0,-77.3303833007812,0,0,22.5625686645508,0,33.844352722168,0,21.7730407714844,0,-77.5869674682617,0,0,22.0369491577148,0,0,33.1863555908203,0,22.1021194458008,0,0,0,0,0,-77.982780456543,0,0,0,0,22.3652725219727,0,33.2497482299805,0,20.8595962524414,0,-78.6382751464844,0,0,0,22.3646087646484,0,32.4029541015625,0,20.726318359375,0,-78.9671478271484,0,22.0319900512695,0,33.1136703491211,0,21.7695083618164,0,-78.6181869506836,0,0,22.5564270019531,0,32.7856216430664,0,0,0,0,22.0322799682617,0,0,0,0,-78.4899215698242,0,0,0,22.2286911010742,0,32.2607040405273,0,20.6555328369141,0,-78.4865112304688,0,22.099723815918,0,0,32.2617568969727,0,21.837287902832,0,-78.8219680786133,0,21.8360366821289,0,33.2433929443359,0,21.9663619995117,0,-78.1592864990234,0,0,0,0,21.2458953857422,0,32.1951904296875,0,0,0,0,21.7690734863281,0,0,25.2446899414062,0,0,-83.9299850463867,0,31.9332504272461,0,0,20.3274688720703,0,0,0,0,30.8167114257812,0,-90.2246246337891,0,32.0643997192383,0,0,21.5727233886719,0,33.5052871704102,0,0,-89.9617538452148,0,0,33.9604721069336,0,22.0938568115234,0,33.1740188598633,0,0,0,0,0,-89.6868743896484,0,32.4534378051758,0,21.2412261962891,0,34.814208984375,0,-88.3766174316406,0,0,33.7645874023438,0,21.7669448852539,0,0,0,0,0,33.3050155639648,0,-88.3768539428711,0,0,0,0,33.2394332885742,0,0,0,0,0,22.3564071655273,0,0,0,0,34.7477645874023,0,0,0,0,0,-87.7864837646484,0,0,0,0,0,33.370475769043,0,0,0,0,23.1423568725586,0,0,0,0,33.5016021728516,0,0,0,-88.1777114868164,0,33.7632446289062,0,0,22.6835632324219,0,0,0,0,0,32.9112319946289,0,0,-89.0506439208984,0,34.4845962524414,0,0,23.2734451293945,0,31.3378372192383,0,0,-86.3420333862305,0,0,0,33.3043365478516,0,19.2371978759766,0,0,0,0],"filename":["<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpUhIcYf/file746375c525df.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq       mean      median
#>         compute_pi0(m)    743.232    785.5860   1099.149    802.6385
#>    compute_pi0(m * 10)   7645.471   7808.1090   7926.295   7940.4225
#>   compute_pi0(m * 100)  77233.121  78838.5620  79067.028  79046.3735
#>         compute_pi1(m)    154.872    181.3325   6102.474    214.9910
#>    compute_pi1(m * 10)   1232.969   1329.5355   1543.941   1431.7190
#>   compute_pi1(m * 100)  12559.429  13798.6860  23816.157  18036.2305
#>  compute_pi1(m * 1000) 240064.213 281208.0655 327176.024 342437.9830
#>          uq        max neval
#>     814.381   6834.579    20
#>    8030.637   8185.886    20
#>   79546.674  80306.559    20
#>     298.295 102745.071    20
#>    1544.897   2309.457    20
#>   23667.292 120966.567    20
#>  353526.366 463397.319    20
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
#>   memory_copy1(n) 5559.18421 4120.32969 740.458826 3750.34730 3029.46428
#>   memory_copy2(n)   99.86767   74.64703  13.387007   66.48011   53.80124
#>  pre_allocate1(n)   21.37685   15.49749   4.312777   14.10710   11.68221
#>  pre_allocate2(n)  211.14886  157.21256  27.252967  141.79952  122.73966
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  127.246521    10
#>    3.199026    10
#>    2.419191    10
#>    4.942613    10
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
#>  f1(df) 253.0947 240.9667 84.07575 236.3891 71.31068 31.3492     5
#>  f2(df)   1.0000   1.0000  1.00000   1.0000  1.00000  1.0000     5
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
