
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
#>    id          a         b        c        d
#> 1   1 -0.3716646 1.3052793 1.134846 4.156152
#> 2   2 -0.3328754 1.5750742 4.879764 5.292366
#> 3   3  0.5146336 1.9769482 2.852448 2.945503
#> 4   4  2.2035721 0.9372092 3.828816 5.488582
#> 5   5  0.1923077 0.4849956 2.309533 3.986233
#> 6   6 -1.6978190 1.5282321 3.536029 3.895477
#> 7   7  0.4408064 1.7815796 4.159063 3.858200
#> 8   8 -0.6745848 2.1606414 3.973464 3.277618
#> 9   9  0.7056843 2.1981996 4.555642 4.513141
#> 10 10 -1.5696987 2.5502024 2.997162 4.998027
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.05896385
mean(df$b)
#> [1] 1.649836
mean(df$c)
#> [1] 3.422677
mean(df$d)
#> [1] 4.24113
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.05896385  1.64983615  3.42267672  4.24112987
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
#> [1] -0.05896385  1.64983615  3.42267672  4.24112987
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
#> [1]  5.50000000 -0.05896385  1.64983615  3.42267672  4.24112987
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
#> [1]  5.50000000 -0.07028383  1.67832688  3.68242253  4.07119250
col_describe(df, mean)
#> [1]  5.50000000 -0.05896385  1.64983615  3.42267672  4.24112987
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
#>  5.50000000 -0.05896385  1.64983615  3.42267672  4.24112987
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
#>   4.109   0.164   4.273
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.025   0.003   0.657
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
#>  13.813   0.831  10.497
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
#>   0.127   0.000   0.126
plyr_st
#>    user  system elapsed 
#>   4.572   0.011   4.585
est_l_st
#>    user  system elapsed 
#>  63.474   1.992  65.468
est_r_st
#>    user  system elapsed 
#>   0.407   0.004   0.411
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

<!--html_preserve--><div id="htmlwidget-9b365b5a404b8f1b6bc8" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-9b365b5a404b8f1b6bc8">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,4,4,4,4,4,4,5,6,6,6,7,7,8,8,8,9,9,9,9,9,9,10,10,10,10,10,11,11,12,12,12,12,12,13,13,13,13,14,14,14,14,14,14,15,15,15,16,16,17,17,17,18,18,18,18,19,19,20,20,21,21,21,21,21,22,22,23,23,23,23,24,24,25,25,25,26,26,27,27,28,28,29,29,30,30,30,31,31,32,32,33,33,33,33,34,34,34,35,35,35,35,35,35,36,36,37,37,38,38,38,38,39,39,40,40,41,41,42,42,42,42,43,43,43,44,44,45,45,46,46,46,46,46,46,47,47,48,48,48,48,48,49,49,49,50,50,51,51,52,52,53,53,54,54,54,55,55,56,56,57,57,57,58,58,58,59,59,60,60,60,60,60,61,61,62,62,63,63,64,64,64,64,65,65,65,66,66,67,67,68,68,69,69,70,70,70,70,70,71,71,72,72,72,73,73,74,74,75,75,76,76,77,77,78,78,79,79,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,96,96,97,97,97,98,98,98,98,98,99,99,99,100,100,100,100,100,101,101,101,102,102,103,103,103,104,104,104,104,104,104,105,105,106,106,107,107,108,108,108,108,108,109,109,109,109,109,109,110,110,110,111,111,111,111,111,112,112,112,113,113,114,114,115,115,116,116,117,117,118,118,118,118,118,118,119,119,119,119,119,120,120,120,121,121,121,121,121,121,122,122,122,122,122,123,123,123,123,123,124,124,125,125,125,126,126,127,127,128,128,129,129,130,130,130,131,131,132,132,133,133,133,134,134,134,135,135,136,136,136,137,137,138,138,138,139,139,140,140,140,141,141,142,142,142,143,143,143,144,144,145,145,145,145,145,145,146,146,147,147,148,148,148,149,149,149,149,149,150,150,150,151,151,151,151,151,151,152,152,152,152,152,153,153,153,153,153,153,154,154,154,155,155,156,156,157,157,157,158,158,159,159,160,160,160,160,160,160,161,161,161,161,161,161,162,162,162,163,163,163,163,164,164,164,164,165,165,166,166,167,167,168,168,168,169,169,170,170,170,171,171,171,171,172,172,173,173,173,173,173,173,174,174,175,175,175,176,177,177,177,177,177,177,178,178,178,178,178,179,179,179,179,179,180,180,180,181,181,181,181,181,182,182,182,183,183,184,184,184,185,185,186,186,186,186,187,187,187,187,187,188,188,188,189,189,190,190,190,190,191,191,191,192,192,192,192,192,192,193,193,193,193,193,194,194,195,195,196,196,196,196,197,197,198,198,199,199,199,199,199,200,200,200,200,200,201,201,201,202,202,203,203,204,204,204,204,205,205,206,206,206,206,207,207,207,207,207,207,208,208,208,209,209,210,210,210,211,211,212,212,213,213,213,213,213,214,214,214,214,215,215,215,216,216,217,217,218,218,218,219,219,219,219,219,219,220,220,221,221,221,221,221,222,223,223,223,224,224,225,225,225,225,225,226,226,227,227,228,228,229,229,229,229,229,230,230,230,231,231,232,232,232,233,233,234,234,235,235,235,236,236,236,237,237,237,237,237,237,238,238,238,238,239,239,240,240,240,240,240,241,241,242,242,242,242,242,243,243,243,243,243,243,244,244,244,244,244,245,245,245,245,245,246,246,247,247,247,248,248,248,249,249,249,250,250,250,251,251,252,252,253,253,253,254,254,254,255,255,256,256,257,257,257,257,258,258,258,259,259,260,260,261,261,261,262,262,263,263,263,263,264,264,264,264,264,264,265,265,266,266,266,267,267,267,268,268,268,269,269,269,270,270,271,271,272,272,272,272,272,273,273,274,274,274,274,274,275,275,276,276,276,277,277,278,278,279,279,280,280,280,281,281,281,281,282,282,282,283,283,283,283,284,284,285,285,285,286,286,286,287,287,288,288,288],"depth":[2,1,2,1,2,1,6,5,4,3,2,1,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1],"label":["[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","anyDuplicated","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","for (i in 1:n_players) {","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","n[i] <- nrow(sub_Batting)","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","["],"filenum":[1,1,1,1,1,1,null,null,null,null,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1],"linenum":[9,9,9,9,9,9,null,null,null,null,9,9,10,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,null,11,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,8,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,11,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9],"memalloc":[58.1527252197266,58.1527252197266,78.6830444335938,78.6830444335938,105.05500793457,105.05500793457,121.194061279297,121.194061279297,121.194061279297,121.194061279297,121.194061279297,121.194061279297,145.790328979492,44.1202011108398,44.1202011108398,44.1202011108398,74.5610885620117,74.5610885620117,94.5697784423828,94.5697784423828,94.5697784423828,123.169990539551,123.169990539551,123.169990539551,123.169990539551,123.169990539551,123.169990539551,142.065536499023,142.065536499023,142.065536499023,142.065536499023,142.065536499023,50.0219268798828,50.0219268798828,70.3618240356445,70.3618240356445,70.3618240356445,70.3618240356445,70.3618240356445,100.474449157715,100.474449157715,100.474449157715,100.474449157715,119.371978759766,119.371978759766,119.371978759766,119.371978759766,119.371978759766,119.371978759766,146.335296630859,146.335296630859,146.335296630859,45.3026580810547,45.3026580810547,75.6054382324219,75.6054382324219,75.6054382324219,94.9540176391602,94.9540176391602,94.9540176391602,94.9540176391602,123.880088806152,123.880088806152,142.902313232422,142.902313232422,51.2102890014648,51.2102890014648,51.2102890014648,51.2102890014648,51.2102890014648,71.2207336425781,71.2207336425781,101.986167907715,101.986167907715,101.986167907715,101.986167907715,122.257247924805,122.257247924805,146.329948425293,146.329948425293,146.329948425293,51.1468963623047,51.1468963623047,81.8456726074219,81.8456726074219,102.04956817627,102.04956817627,131.050285339355,131.050285339355,146.334800720215,146.334800720215,146.334800720215,60.9892272949219,60.9892272949219,81.9116287231445,81.9116287231445,111.634338378906,111.634338378906,111.634338378906,111.634338378906,130.334213256836,130.334213256836,130.334213256836,146.278762817383,146.278762817383,146.278762817383,146.278762817383,146.278762817383,146.278762817383,61.3176193237305,61.3176193237305,92.0274887084961,92.0274887084961,110.790245056152,110.790245056152,110.790245056152,110.790245056152,139.983711242676,139.983711242676,43.9352493286133,43.9352493286133,74.8344268798828,74.8344268798828,93.5383148193359,93.5383148193359,93.5383148193359,93.5383148193359,123.193778991699,123.193778991699,123.193778991699,142.940727233887,142.940727233887,56.7988052368164,56.7988052368164,77.5956649780273,77.5956649780273,77.5956649780273,77.5956649780273,77.5956649780273,77.5956649780273,108.429138183594,108.429138183594,127.847305297852,127.847305297852,127.847305297852,127.847305297852,127.847305297852,146.282096862793,146.282096862793,146.282096862793,61.9793395996094,61.9793395996094,93.1436233520508,93.1436233520508,113.084335327148,113.084335327148,142.869575500488,142.869575500488,46.8271255493164,46.8271255493164,46.8271255493164,78.1872863769531,78.1872863769531,98.7154922485352,98.7154922485352,128.687782287598,128.687782287598,128.687782287598,146.338096618652,146.338096618652,146.338096618652,63.0390930175781,63.0390930175781,84.1637802124023,84.1637802124023,84.1637802124023,84.1637802124023,84.1637802124023,114.143920898438,114.143920898438,133.956092834473,133.956092834473,48.0769424438477,48.0769424438477,67.6247253417969,67.6247253417969,67.6247253417969,67.6247253417969,96.9525680541992,96.9525680541992,96.9525680541992,116.048233032227,116.048233032227,145.503219604492,145.503219604492,49.0635681152344,49.0635681152344,80.032600402832,80.032600402832,100.700866699219,100.700866699219,100.700866699219,100.700866699219,100.700866699219,132.969650268555,132.969650268555,146.28636932373,146.28636932373,146.28636932373,67.9606094360352,67.9606094360352,89.0238494873047,89.0238494873047,118.93871307373,118.93871307373,137.962730407715,137.962730407715,51.9539337158203,51.9539337158203,72.8089447021484,72.8089447021484,102.655754089355,102.655754089355,123.78067779541,123.78067779541,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,146.27759552002,42.7710266113281,42.7710266113281,42.7710266113281,65.0796890258789,65.0796890258789,85.7432479858398,85.7432479858398,114.867195129395,114.867195129395,114.867195129395,134.484733581543,134.484733581543,134.484733581543,134.484733581543,134.484733581543,49.1365661621094,49.1365661621094,49.1365661621094,69.9336471557617,69.9336471557617,69.9336471557617,69.9336471557617,69.9336471557617,101.09154510498,101.09154510498,101.09154510498,121.098663330078,121.098663330078,146.28980255127,146.28980255127,146.28980255127,56.0922317504883,56.0922317504883,56.0922317504883,56.0922317504883,56.0922317504883,56.0922317504883,86.3351364135742,86.3351364135742,107.786247253418,107.786247253418,139.266403198242,139.266403198242,44.2190780639648,44.2190780639648,44.2190780639648,44.2190780639648,44.2190780639648,74.9863510131836,74.9863510131836,74.9863510131836,74.9863510131836,74.9863510131836,74.9863510131836,95.9108123779297,95.9108123779297,95.9108123779297,127.66072845459,127.66072845459,127.66072845459,127.66072845459,127.66072845459,146.293533325195,146.293533325195,146.293533325195,63.9023513793945,63.9023513793945,84.6909866333008,84.6909866333008,116.508903503418,116.508903503418,136.842399597168,136.842399597168,52.0983200073242,52.0983200073242,72.4966812133789,72.4966812133789,72.4966812133789,72.4966812133789,72.4966812133789,72.4966812133789,103.983985900879,103.983985900879,103.983985900879,103.983985900879,103.983985900879,125.564903259277,125.564903259277,125.564903259277,146.295082092285,146.295082092285,146.295082092285,146.295082092285,146.295082092285,146.295082092285,62.1963653564453,62.1963653564453,62.1963653564453,62.1963653564453,62.1963653564453,93.6144561767578,93.6144561767578,93.6144561767578,93.6144561767578,93.6144561767578,115.06485748291,115.06485748291,146.283180236816,146.283180236816,146.283180236816,52.0945053100586,52.0945053100586,83.8430862426758,83.8430862426758,105.104331970215,105.104331970215,136.657730102539,136.657730102539,141.657875061035,141.657875061035,141.657875061035,73.4883346557617,73.4883346557617,94.6832656860352,94.6832656860352,126.632278442383,126.632278442383,126.632278442383,146.309860229492,146.309860229492,146.309860229492,63.1844177246094,63.1844177246094,83.5267562866211,83.5267562866211,83.5267562866211,114.090118408203,114.090118408203,133.904914855957,133.904914855957,133.904914855957,49.6744537353516,49.6744537353516,70.4069442749023,70.4069442749023,70.4069442749023,100.78532409668,100.78532409668,119.219886779785,119.219886779785,119.219886779785,146.319129943848,146.319129943848,146.319129943848,52.2989196777344,52.2989196777344,82.8110122680664,82.8110122680664,82.8110122680664,82.8110122680664,82.8110122680664,82.8110122680664,103.99348449707,103.99348449707,135.551139831543,135.551139831543,146.314247131348,146.314247131348,146.314247131348,71.4605865478516,71.4605865478516,71.4605865478516,71.4605865478516,71.4605865478516,92.7823181152344,92.7823181152344,92.7823181152344,124.854446411133,124.854446411133,124.854446411133,124.854446411133,124.854446411133,124.854446411133,146.04744720459,146.04744720459,146.04744720459,146.04744720459,146.04744720459,62.1483306884766,62.1483306884766,62.1483306884766,62.1483306884766,62.1483306884766,62.1483306884766,83.4040756225586,83.4040756225586,83.4040756225586,115.482604980469,115.482604980469,136.28076171875,136.28076171875,53.1547241210938,53.1547241210938,53.1547241210938,73.5527114868164,73.5527114868164,104.184494018555,104.184494018555,125.307647705078,125.307647705078,125.307647705078,125.307647705078,125.307647705078,125.307647705078,146.298889160156,146.298889160156,146.298889160156,146.298889160156,146.298889160156,146.298889160156,62.4025344848633,62.4025344848633,62.4025344848633,93.4359436035156,93.4359436035156,93.4359436035156,93.4359436035156,113.049644470215,113.049644470215,113.049644470215,113.049644470215,144.470802307129,144.470802307129,50.6009674072266,50.6009674072266,82.1007232666016,82.1007232666016,103.225372314453,103.225372314453,103.225372314453,135.304206848145,135.304206848145,146.323028564453,146.323028564453,146.323028564453,71.9173202514648,71.9173202514648,71.9173202514648,71.9173202514648,91.9191284179688,91.9191284179688,122.54940032959,122.54940032959,122.54940032959,122.54940032959,122.54940032959,122.54940032959,143.148941040039,143.148941040039,59.0614624023438,59.0614624023438,59.0614624023438,79.4570922851562,110.483703613281,110.483703613281,110.483703613281,110.483703613281,110.483703613281,110.483703613281,130.227821350098,130.227821350098,130.227821350098,130.227821350098,130.227821350098,46.8670654296875,46.8670654296875,46.8670654296875,46.8670654296875,46.8670654296875,67.006462097168,67.006462097168,67.006462097168,97.1109008789062,97.1109008789062,97.1109008789062,97.1109008789062,97.1109008789062,117.310691833496,117.310691833496,117.310691833496,146.302108764648,146.302108764648,52.9686660766602,52.9686660766602,52.9686660766602,83.5946960449219,83.5946960449219,104.522232055664,104.522232055664,104.522232055664,104.522232055664,133.576622009277,133.576622009277,133.576622009277,133.576622009277,133.576622009277,146.300689697266,146.300689697266,146.300689697266,69.0722885131836,69.0722885131836,90.3199234008789,90.3199234008789,90.3199234008789,90.3199234008789,122.58536529541,122.58536529541,122.58536529541,143.047805786133,143.047805786133,143.047805786133,143.047805786133,143.047805786133,143.047805786133,57.1366653442383,57.1366653442383,57.1366653442383,57.1366653442383,57.1366653442383,78.6511535644531,78.6511535644531,110.328674316406,110.328674316406,131.119323730469,131.119323730469,131.119323730469,131.119323730469,46.9722290039062,46.9722290039062,68.0246276855469,68.0246276855469,98.5227661132812,98.5227661132812,98.5227661132812,98.5227661132812,98.5227661132812,119.967803955078,119.967803955078,119.967803955078,119.967803955078,119.967803955078,146.337539672852,146.337539672852,146.337539672852,56.8752517700195,56.8752517700195,89.1440505981445,89.1440505981445,109.93611907959,109.93611907959,109.93611907959,109.93611907959,142.071685791016,142.071685791016,47.3670959472656,47.3670959472656,47.3670959472656,47.3670959472656,78.5849838256836,78.5849838256836,78.5849838256836,78.5849838256836,78.5849838256836,78.5849838256836,99.3762512207031,99.3762512207031,99.3762512207031,131.710639953613,131.710639953613,146.335777282715,146.335777282715,146.335777282715,69.1421661376953,69.1421661376953,90.0625534057617,90.0625534057617,121.542900085449,121.542900085449,121.542900085449,121.542900085449,121.542900085449,141.222389221191,141.222389221191,141.222389221191,141.222389221191,56.6803436279297,56.6803436279297,56.6803436279297,77.6011276245117,77.6011276245117,109.281539916992,109.281539916992,130.599884033203,130.599884033203,130.599884033203,46.8457870483398,46.8457870483398,46.8457870483398,46.8457870483398,46.8457870483398,46.8457870483398,68.0251693725586,68.0251693725586,100.286643981934,100.286643981934,100.286643981934,100.286643981934,100.286643981934,121.860000610352,146.317008972168,146.317008972168,146.317008972168,59.0451126098633,59.0451126098633,91.0443267822266,91.0443267822266,91.0443267822266,91.0443267822266,91.0443267822266,111.895195007324,111.895195007324,144.222503662109,144.222503662109,49.7313232421875,49.7313232421875,81.4678192138672,81.4678192138672,81.4678192138672,81.4678192138672,81.4678192138672,103.106300354004,103.106300354004,103.106300354004,135.695465087891,135.695465087891,146.319129943848,146.319129943848,146.319129943848,73.0141677856445,73.0141677856445,94.3240966796875,94.3240966796875,126.195236206055,126.195236206055,126.195236206055,146.326484680176,146.326484680176,146.326484680176,63.7012939453125,63.7012939453125,63.7012939453125,63.7012939453125,63.7012939453125,63.7012939453125,85.0123443603516,85.0123443603516,85.0123443603516,85.0123443603516,117.664527893066,117.664527893066,139.04044342041,139.04044342041,139.04044342041,139.04044342041,139.04044342041,55.6362075805664,55.6362075805664,76.6197967529297,76.6197967529297,76.6197967529297,76.6197967529297,76.6197967529297,107.502403259277,107.502403259277,107.502403259277,107.502403259277,107.502403259277,107.502403259277,128.681510925293,128.681510925293,128.681510925293,128.681510925293,128.681510925293,44.7521896362305,44.7521896362305,44.7521896362305,44.7521896362305,44.7521896362305,65.8010787963867,65.8010787963867,98.0617446899414,98.0617446899414,98.0617446899414,118.520362854004,118.520362854004,118.520362854004,146.321067810059,146.321067810059,146.321067810059,52.8833312988281,52.8833312988281,52.8833312988281,84.0953979492188,84.0953979492188,105.339920043945,105.339920043945,137.075828552246,137.075828552246,137.075828552246,145.992362976074,145.992362976074,145.992362976074,73.4038391113281,73.4038391113281,94.186393737793,94.186393737793,125.787117004395,125.787117004395,125.787117004395,125.787117004395,146.307968139648,146.307968139648,146.307968139648,62.8489837646484,62.8489837646484,83.9596481323242,83.9596481323242,116.150032043457,116.150032043457,116.150032043457,137.130386352539,137.130386352539,53.0149841308594,53.0149841308594,53.0149841308594,53.0149841308594,73.7990493774414,73.7990493774414,73.7990493774414,73.7990493774414,73.7990493774414,73.7990493774414,105.989318847656,105.989318847656,125.461845397949,125.461845397949,125.461845397949,146.310150146484,146.310150146484,146.310150146484,62.457145690918,62.457145690918,62.457145690918,93.9261703491211,93.9261703491211,93.9261703491211,114.709671020508,114.709671020508,144.802101135254,144.802101135254,50.1975479125977,50.1975479125977,50.1975479125977,50.1975479125977,50.1975479125977,82.1906661987305,82.1906661987305,103.366889953613,103.366889953613,103.366889953613,103.366889953613,103.366889953613,135.42561340332,135.42561340332,146.308639526367,146.308639526367,146.308639526367,69.9970321655273,69.9970321655273,89.861930847168,89.861930847168,119.953926086426,119.953926086426,139.622146606445,139.622146606445,139.622146606445,53.326171875,53.326171875,53.326171875,53.326171875,74.1089859008789,74.1089859008789,74.1089859008789,103.742233276367,103.742233276367,103.742233276367,103.742233276367,124.327987670898,124.327987670898,146.290718078613,146.290718078613,146.290718078613,60.0796966552734,60.0796966552734,60.0796966552734,90.8271255493164,90.8271255493164,112.00325012207,112.00325012207,112.00325012207],"meminc":[0,0,20.5303192138672,0,26.3719635009766,0,16.1390533447266,0,0,0,0,0,24.5962677001953,-101.670127868652,0,0,30.4408874511719,0,20.0086898803711,0,0,28.600212097168,0,0,0,0,0,18.8955459594727,0,0,0,0,-92.0436096191406,0,20.3398971557617,0,0,0,0,30.1126251220703,0,0,0,18.8975296020508,0,0,0,0,0,26.9633178710938,0,0,-101.032638549805,0,30.3027801513672,0,0,19.3485794067383,0,0,0,28.9260711669922,0,19.0222244262695,0,-91.692024230957,0,0,0,0,20.0104446411133,0,30.7654342651367,0,0,0,20.2710800170898,0,24.0727005004883,0,0,-95.1830520629883,0,30.6987762451172,0,20.2038955688477,0,29.0007171630859,0,15.2845153808594,0,0,-85.345573425293,0,20.9224014282227,0,29.7227096557617,0,0,0,18.6998748779297,0,0,15.9445495605469,0,0,0,0,0,-84.9611434936523,0,30.7098693847656,0,18.7627563476562,0,0,0,29.1934661865234,0,-96.0484619140625,0,30.8991775512695,0,18.7038879394531,0,0,0,29.6554641723633,0,0,19.7469482421875,0,-86.1419219970703,0,20.7968597412109,0,0,0,0,0,30.8334732055664,0,19.4181671142578,0,0,0,0,18.4347915649414,0,0,-84.3027572631836,0,31.1642837524414,0,19.9407119750977,0,29.7852401733398,0,-96.0424499511719,0,0,31.3601608276367,0,20.528205871582,0,29.9722900390625,0,0,17.6503143310547,0,0,-83.2990036010742,0,21.1246871948242,0,0,0,0,29.9801406860352,0,19.8121719360352,0,-85.879150390625,0,19.5477828979492,0,0,0,29.3278427124023,0,0,19.0956649780273,0,29.4549865722656,0,-96.4396514892578,0,30.9690322875977,0,20.6682662963867,0,0,0,0,32.2687835693359,0,13.3167190551758,0,0,-78.3257598876953,0,21.0632400512695,0,29.9148635864258,0,19.0240173339844,0,-86.0087966918945,0,20.8550109863281,0,29.846809387207,0,21.1249237060547,0,22.4969177246094,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,22.3086624145508,0,20.6635589599609,0,29.1239471435547,0,0,19.6175384521484,0,0,0,0,-85.3481674194336,0,0,20.7970809936523,0,0,0,0,31.1578979492188,0,0,20.0071182250977,0,25.1911392211914,0,0,-90.1975708007812,0,0,0,0,0,30.2429046630859,0,21.4511108398438,0,31.4801559448242,0,-95.0473251342773,0,0,0,0,30.7672729492188,0,0,0,0,0,20.9244613647461,0,0,31.7499160766602,0,0,0,0,18.6328048706055,0,0,-82.3911819458008,0,20.7886352539062,0,31.8179168701172,0,20.33349609375,0,-84.7440795898438,0,20.3983612060547,0,0,0,0,0,31.4873046875,0,0,0,0,21.5809173583984,0,0,20.7301788330078,0,0,0,0,0,-84.0987167358398,0,0,0,0,31.4180908203125,0,0,0,0,21.4504013061523,0,31.2183227539062,0,0,-94.1886749267578,0,31.7485809326172,0,21.2612457275391,0,31.5533981323242,0,5.00014495849609,0,0,-68.1695404052734,0,21.1949310302734,0,31.9490127563477,0,0,19.6775817871094,0,0,-83.1254425048828,0,20.3423385620117,0,0,30.563362121582,0,19.8147964477539,0,0,-84.2304611206055,0,20.7324905395508,0,0,30.3783798217773,0,18.4345626831055,0,0,27.0992431640625,0,0,-94.0202102661133,0,30.512092590332,0,0,0,0,0,21.1824722290039,0,31.5576553344727,0,10.7631072998047,0,0,-74.8536605834961,0,0,0,0,21.3217315673828,0,0,32.0721282958984,0,0,0,0,0,21.193000793457,0,0,0,0,-83.8991165161133,0,0,0,0,0,21.255744934082,0,0,32.0785293579102,0,20.7981567382812,0,-83.1260375976562,0,0,20.3979873657227,0,30.6317825317383,0,21.1231536865234,0,0,0,0,0,20.9912414550781,0,0,0,0,0,-83.896354675293,0,0,31.0334091186523,0,0,0,19.6137008666992,0,0,0,31.4211578369141,0,-93.8698348999023,0,31.499755859375,0,21.1246490478516,0,0,32.0788345336914,0,11.0188217163086,0,0,-74.4057083129883,0,0,0,20.0018081665039,0,30.6302719116211,0,0,0,0,0,20.5995407104492,0,-84.0874786376953,0,0,20.3956298828125,31.026611328125,0,0,0,0,0,19.7441177368164,0,0,0,0,-83.3607559204102,0,0,0,0,20.1393966674805,0,0,30.1044387817383,0,0,0,0,20.1997909545898,0,0,28.9914169311523,0,-93.3334426879883,0,0,30.6260299682617,0,20.9275360107422,0,0,0,29.0543899536133,0,0,0,0,12.7240676879883,0,0,-77.228401184082,0,21.2476348876953,0,0,0,32.2654418945312,0,0,20.4624404907227,0,0,0,0,0,-85.9111404418945,0,0,0,0,21.5144882202148,0,31.6775207519531,0,20.7906494140625,0,0,0,-84.1470947265625,0,21.0523986816406,0,30.4981384277344,0,0,0,0,21.4450378417969,0,0,0,0,26.3697357177734,0,0,-89.462287902832,0,32.268798828125,0,20.7920684814453,0,0,0,32.1355667114258,0,-94.70458984375,0,0,0,31.217887878418,0,0,0,0,0,20.7912673950195,0,0,32.3343887329102,0,14.6251373291016,0,0,-77.1936111450195,0,20.9203872680664,0,31.4803466796875,0,0,0,0,19.6794891357422,0,0,0,-84.5420455932617,0,0,20.920783996582,0,31.6804122924805,0,21.3183441162109,0,0,-83.7540969848633,0,0,0,0,0,21.1793823242188,0,32.261474609375,0,0,0,0,21.573356628418,24.4570083618164,0,0,-87.2718963623047,0,31.9992141723633,0,0,0,0,20.8508682250977,0,32.3273086547852,0,-94.4911804199219,0,31.7364959716797,0,0,0,0,21.6384811401367,0,0,32.5891647338867,0,10.623664855957,0,0,-73.3049621582031,0,21.309928894043,0,31.8711395263672,0,0,20.1312484741211,0,0,-82.6251907348633,0,0,0,0,0,21.3110504150391,0,0,0,32.6521835327148,0,21.3759155273438,0,0,0,0,-83.4042358398438,0,20.9835891723633,0,0,0,0,30.8826065063477,0,0,0,0,0,21.1791076660156,0,0,0,0,-83.9293212890625,0,0,0,0,21.0488891601562,0,32.2606658935547,0,0,20.4586181640625,0,0,27.8007049560547,0,0,-93.4377365112305,0,0,31.2120666503906,0,21.2445220947266,0,31.7359085083008,0,0,8.91653442382812,0,0,-72.5885238647461,0,20.7825546264648,0,31.6007232666016,0,0,0,20.5208511352539,0,0,-83.458984375,0,21.1106643676758,0,32.1903839111328,0,0,20.980354309082,0,-84.1154022216797,0,0,0,20.784065246582,0,0,0,0,0,32.1902694702148,0,19.472526550293,0,0,20.8483047485352,0,0,-83.8530044555664,0,0,31.4690246582031,0,0,20.7835006713867,0,30.0924301147461,0,-94.6045532226562,0,0,0,0,31.9931182861328,0,21.1762237548828,0,0,0,0,32.058723449707,0,10.8830261230469,0,0,-76.3116073608398,0,19.8648986816406,0,30.0919952392578,0,19.6682205200195,0,0,-86.2959747314453,0,0,0,20.7828140258789,0,0,29.6332473754883,0,0,0,20.5857543945312,0,21.9627304077148,0,0,-86.2110214233398,0,0,30.747428894043,0,21.1761245727539,0,0],"filename":["<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmp1lLEYY/file3bf76fe8fc81.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min         lq        mean      median         uq
#>         compute_pi0(m)    787.278    805.999   1151.1843    812.9155    829.071
#>    compute_pi0(m * 10)   7913.868   7953.307   8015.7764   7979.4240   8083.877
#>   compute_pi0(m * 100)  79502.967  79584.203  80167.9807  79757.7880  79944.986
#>         compute_pi1(m)    165.115    215.862    284.2479    300.4225    336.714
#>    compute_pi1(m * 10)   1295.467   1413.577   1807.7323   1452.3640   1577.593
#>   compute_pi1(m * 100)  12866.016  14773.419  20986.1084  20780.5175  25265.009
#>  compute_pi1(m * 1000) 319478.450 369867.417 421862.0398 405412.5510 485831.101
#>         max neval
#>    7523.043    20
#>    8169.878    20
#>   85528.505    20
#>     366.618    20
#>    8331.067    20
#>   33436.262    20
#>  505348.516    20
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
#>              expr        min         lq      mean     median         uq
#>   memory_copy1(n) 4004.98632 3973.94752 596.29767 3961.24444 3874.67256
#>   memory_copy2(n)   67.66509   68.29613  11.32081   69.32978   67.05359
#>  pre_allocate1(n)   15.46304   15.66910   3.82708   15.77052   15.30289
#>  pre_allocate2(n)  146.72586  146.17212  22.99402  148.06513  144.71567
#>     vectorized(n)    1.00000    1.00000   1.00000    1.00000    1.00000
#>        max neval
#>  91.228357    10
#>   2.735372    10
#>   2.085189    10
#>   4.352210    10
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
#>  f1(df) 248.831 247.9572 88.74667 235.0294 68.24152 41.76702     5
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
