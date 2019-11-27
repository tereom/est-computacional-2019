
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
#>    id          a        b         c        d
#> 1   1 -1.1595295 1.623799 2.8396028 4.208114
#> 2   2  0.3843142 2.086163 3.1707483 4.414659
#> 3   3 -1.2042861 2.100588 2.1859971 3.265578
#> 4   4  0.8336124 3.259398 4.1144345 4.272262
#> 5   5 -1.8027353 1.971605 2.9186892 5.285707
#> 6   6  1.0743791 1.557445 1.4949651 4.584420
#> 7   7 -0.7366607 1.816016 4.5975188 3.990147
#> 8   8  1.1094332 2.840712 4.0775666 3.155215
#> 9   9  2.5170288 2.492260 2.0618408 5.076492
#> 10 10 -0.6668722 1.183680 0.7860519 3.058027
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.0348684
mean(df$b)
#> [1] 2.093167
mean(df$c)
#> [1] 2.824742
mean(df$d)
#> [1] 4.131062
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.0348684 2.0931667 2.8247415 4.1310620
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
#> [1] 0.0348684 2.0931667 2.8247415 4.1310620
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
#> [1] 5.5000000 0.0348684 2.0931667 2.8247415 4.1310620
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
#> [1]  5.500000 -0.141279  2.028884  2.879146  4.240188
col_describe(df, mean)
#> [1] 5.5000000 0.0348684 2.0931667 2.8247415 4.1310620
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
#> 5.5000000 0.0348684 2.0931667 2.8247415 4.1310620
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
#>   4.083   0.156   4.240
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.020   0.004   0.660
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
#>  13.254   0.748  10.169
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
#>   0.129   0.004   0.133
plyr_st
#>    user  system elapsed 
#>   4.652   0.015   4.668
est_l_st
#>    user  system elapsed 
#>  71.584   1.888  73.474
est_r_st
#>    user  system elapsed 
#>   0.408   0.008   0.417
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

<!--html_preserve--><div id="htmlwidget-cd8ba23925344bf1e281" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-cd8ba23925344bf1e281">{"x":{"message":{"prof":{"time":[1,1,2,2,2,2,3,3,4,4,4,4,4,4,5,5,5,6,6,6,6,6,6,7,7,7,8,8,9,9,10,10,11,11,12,12,13,13,14,14,15,15,15,16,16,16,16,16,17,17,17,17,18,18,19,19,19,19,19,20,20,21,21,22,22,23,23,24,24,25,25,25,26,26,26,27,27,27,27,27,28,28,29,29,29,29,29,30,30,30,31,31,32,32,32,32,32,32,33,33,34,34,34,34,34,35,35,36,36,36,36,36,36,37,37,37,37,37,38,38,38,39,39,39,40,40,41,41,42,42,43,43,44,44,44,45,45,45,46,46,46,47,47,48,48,48,49,49,50,50,51,51,52,52,53,53,53,53,53,54,54,54,54,54,54,55,55,56,56,56,57,57,57,58,58,58,59,59,60,60,61,61,61,62,62,62,62,63,63,64,64,64,65,65,65,65,65,66,66,66,66,67,67,68,68,68,68,68,69,69,70,70,70,70,70,71,71,71,72,72,72,73,73,73,73,73,74,74,74,75,75,76,76,76,77,77,77,78,78,78,79,79,79,79,79,80,80,80,80,81,81,82,82,82,83,83,83,84,84,84,85,85,86,86,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,103,103,103,104,104,105,105,105,105,105,105,106,106,106,106,107,107,108,108,109,109,109,109,109,110,110,110,110,110,110,111,111,111,111,112,112,112,113,113,113,113,114,114,115,115,116,116,116,116,117,117,118,118,118,118,119,119,120,120,120,121,121,122,122,122,122,122,123,123,123,124,124,125,125,125,126,126,127,127,127,127,128,128,129,129,129,129,130,130,131,131,132,132,132,132,132,133,133,134,134,134,134,134,135,135,135,136,136,137,137,138,138,138,138,139,139,139,140,140,141,141,142,142,142,142,142,143,143,143,144,144,144,145,145,145,145,146,146,147,147,148,148,149,149,150,150,151,151,152,152,152,153,153,153,154,154,154,155,155,156,156,157,157,157,157,157,158,158,158,159,159,160,160,161,161,162,162,163,163,163,164,164,164,164,164,165,165,166,166,166,167,167,167,167,167,168,168,168,168,169,169,169,170,170,170,170,170,171,171,171,171,172,172,172,173,173,173,173,173,173,174,174,175,175,176,176,177,177,178,178,178,179,179,179,180,180,181,181,182,182,183,183,184,184,184,184,185,185,186,186,186,186,186,187,187,187,188,188,188,189,189,190,190,190,190,190,191,191,192,192,192,192,193,193,194,194,194,195,195,195,195,195,196,196,196,197,197,197,197,198,198,199,199,200,200,200,201,201,201,202,202,202,203,203,204,204,205,205,205,206,206,206,207,207,207,208,208,208,208,208,208,209,209,210,210,211,211,211,212,212,213,213,214,214,214,214,214,214,215,215,215,215,215,216,216,217,217,217,218,218,218,219,219,220,220,220,221,221,222,222,223,223,224,224,225,225,225,226,226,227,227,228,228,228,228,228,229,229,229,230,230,230,231,231,231,232,232,233,233,234,234,234,235,235,236,236,237,237,237,237,237,238,238,239,239,239,240,240,241,241,242,242,243,243,244,244,244,244,245,245,246,246,246,247,247,247,248,248,249,249,250,250,251,251,251,251,251,252,252,252,252,252,253,253,253,254,254,255,255,256,256,257,257,257,257,258,258,258,258,258,258,259,259,260,260,260,260,260,260,261,261,261,262,262,263,263,264,264,265,265,266,266,267,267,267,268,268,268,269,269,270,270,270,270,271,271,272,272,272,273,273,273,274,274,275,275,276,276,277,277,278,278,278,278,278,279,279,279,279,279,280,280,281,281,281,281,281,281,282,282,283,283,283,284,284,285,285,286,286,286,287,287,288,288,288,288,288,289,289,290,290,291,291,292,292,293,293,293,294,294,294,294,295,295,295,296,296,296,297,297,298,298,298,298,298,299,299,300,300,300,300,301,301,302,302,303,303,304,304,304,305,305,305,306,306,307,307,307,307,307,308,308,308,309,309,310,310,310,310,310],"depth":[2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1],"label":["[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","dim","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","dim","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","==","[.data.frame","[","==","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,null,1,1,1,1,null,null,null,null,null,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1],"linenum":[9,9,null,null,9,9,9,9,null,null,null,null,null,11,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,11,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,13],"memalloc":[59.9908065795898,59.9908065795898,80.3236541748047,80.3236541748047,80.3236541748047,80.3236541748047,107.286445617676,107.286445617676,123.751892089844,123.751892089844,123.751892089844,123.751892089844,123.751892089844,123.751892089844,146.315994262695,146.315994262695,146.315994262695,45.8264923095703,45.8264923095703,45.8264923095703,45.8264923095703,45.8264923095703,45.8264923095703,75.6759262084961,75.6759262084961,75.6759262084961,95.0286483764648,95.0286483764648,123.891876220703,123.891876220703,141.278434753418,141.278434753418,48.7761001586914,48.7761001586914,68.9830169677734,68.9830169677734,99.4896392822266,99.4896392822266,117.863059997559,117.863059997559,146.335235595703,146.335235595703,146.335235595703,44.3196258544922,44.3196258544922,44.3196258544922,44.3196258544922,44.3196258544922,72.6545028686523,72.6545028686523,72.6545028686523,72.6545028686523,92.2653579711914,92.2653579711914,120.272636413574,120.272636413574,120.272636413574,120.272636413574,120.272636413574,139.031455993652,139.031455993652,46.2239227294922,46.2239227294922,64.4636077880859,64.4636077880859,93.329231262207,93.329231262207,109.20329284668,109.20329284668,138.721885681152,138.721885681152,138.721885681152,146.329887390137,146.329887390137,146.329887390137,66.3633499145508,66.3633499145508,66.3633499145508,66.3633499145508,66.3633499145508,85.4549179077148,85.4549179077148,116.021896362305,116.021896362305,116.021896362305,116.021896362305,116.021896362305,135.643051147461,135.643051147461,135.643051147461,43.6687545776367,43.6687545776367,62.6949691772461,62.6949691772461,62.6949691772461,62.6949691772461,62.6949691772461,62.6949691772461,93.3973541259766,93.3973541259766,111.831069946289,111.831069946289,111.831069946289,111.831069946289,111.831069946289,141.026596069336,141.026596069336,146.278701782227,146.278701782227,146.278701782227,146.278701782227,146.278701782227,146.278701782227,68.7336273193359,68.7336273193359,68.7336273193359,68.7336273193359,68.7336273193359,88.9455795288086,88.9455795288086,88.9455795288086,118.267967224121,118.267967224121,118.267967224121,137.489906311035,137.489906311035,44.8542404174805,44.8542404174805,64.7297592163086,64.7297592163086,94.9815216064453,94.9815216064453,113.746307373047,113.746307373047,113.746307373047,142.35090637207,142.35090637207,142.35090637207,146.285041809082,146.285041809082,146.285041809082,70.7087631225586,70.7087631225586,91.3004760742188,91.3004760742188,91.3004760742188,119.255035400391,119.255035400391,138.345054626465,138.345054626465,45.3802719116211,45.3802719116211,62.5035781860352,62.5035781860352,90.5838394165039,90.5838394165039,90.5838394165039,90.5838394165039,90.5838394165039,108.885360717773,108.885360717773,108.885360717773,108.885360717773,108.885360717773,108.885360717773,136.375823974609,136.375823974609,146.28239440918,146.28239440918,146.28239440918,61.000114440918,61.000114440918,61.000114440918,80.941047668457,80.941047668457,80.941047668457,108.947120666504,108.947120666504,126.654899597168,126.654899597168,146.338035583496,146.338035583496,146.338035583496,51.6872711181641,51.6872711181641,51.6872711181641,51.6872711181641,79.3086395263672,79.3086395263672,98.5916595458984,98.5916595458984,98.5916595458984,125.099060058594,125.099060058594,125.099060058594,125.099060058594,125.099060058594,142.745849609375,142.745849609375,142.745849609375,142.745849609375,50.8962173461914,50.8962173461914,68.8721313476562,68.8721313476562,68.8721313476562,68.8721313476562,68.8721313476562,98.7254867553711,98.7254867553711,115.785552978516,115.785552978516,115.785552978516,115.785552978516,115.785552978516,142.879051208496,142.879051208496,142.879051208496,146.290664672852,146.290664672852,146.290664672852,68.8795928955078,68.8795928955078,68.8795928955078,68.8795928955078,68.8795928955078,85.9354705810547,85.9354705810547,85.9354705810547,114.208724975586,114.208724975586,131.593246459961,131.593246459961,131.593246459961,146.286308288574,146.286308288574,146.286308288574,59.233154296875,59.233154296875,59.233154296875,89.3527755737305,89.3527755737305,89.3527755737305,89.3527755737305,89.3527755737305,108.57218170166,108.57218170166,108.57218170166,108.57218170166,137.8310546875,137.8310546875,146.293281555176,146.293281555176,146.293281555176,65.8538970947266,65.8538970947266,65.8538970947266,86.1236419677734,86.1236419677734,86.1236419677734,116.698066711426,116.698066711426,136.831993103027,136.831993103027,136.831993103027,136.831993103027,136.831993103027,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,146.277534484863,42.7709655761719,42.7709655761719,42.7709655761719,54.5172348022461,54.5172348022461,84.9554443359375,84.9554443359375,84.9554443359375,104.241088867188,104.241088867188,133.303215026855,133.303215026855,133.303215026855,133.303215026855,133.303215026855,133.303215026855,146.293212890625,146.293212890625,146.293212890625,146.293212890625,64.2931060791016,64.2931060791016,84.6305236816406,84.6305236816406,113.951583862305,113.951583862305,113.951583862305,113.951583862305,113.951583862305,133.03923034668,133.03923034668,133.03923034668,133.03923034668,133.03923034668,133.03923034668,43.9561080932617,43.9561080932617,43.9561080932617,43.9561080932617,63.8304138183594,63.8304138183594,63.8304138183594,93.9434204101562,93.9434204101562,93.9434204101562,93.9434204101562,114.737411499023,114.737411499023,146.284797668457,146.284797668457,46.7108535766602,46.7108535766602,46.7108535766602,46.7108535766602,76.953498840332,76.953498840332,97.4194946289062,97.4194946289062,97.4194946289062,97.4194946289062,128.579696655273,128.579696655273,146.293472290039,146.293472290039,146.293472290039,60.4902191162109,60.4902191162109,81.1503295898438,81.1503295898438,81.1503295898438,81.1503295898438,81.1503295898438,112.308822631836,112.308822631836,112.308822631836,130.808753967285,130.808753967285,133.787078857422,133.787078857422,133.787078857422,61.0186920166016,61.0186920166016,91.2552642822266,91.2552642822266,91.2552642822266,91.2552642822266,111.856231689453,111.856231689453,142.947547912598,142.947547912598,142.947547912598,142.947547912598,44.0923156738281,44.0923156738281,73.6132431030273,73.6132431030273,93.6143951416016,93.6143951416016,93.6143951416016,93.6143951416016,93.6143951416016,124.380569458008,124.380569458008,144.709411621094,144.709411621094,144.709411621094,144.709411621094,144.709411621094,53.2084503173828,53.2084503173828,53.2084503173828,71.5757064819336,71.5757064819336,101.889221191406,101.889221191406,122.030242919922,122.030242919922,122.030242919922,122.030242919922,146.304870605469,146.304870605469,146.304870605469,53.6075973510742,53.6075973510742,83.8577346801758,83.8577346801758,103.86775970459,103.86775970459,103.86775970459,103.86775970459,103.86775970459,134.50284576416,134.50284576416,134.50284576416,146.309799194336,146.309799194336,146.309799194336,64.8260803222656,64.8260803222656,64.8260803222656,64.8260803222656,84.3787384033203,84.3787384033203,113.959083557129,113.959083557129,132.528038024902,132.528038024902,43.5078353881836,43.5078353881836,62.6651077270508,62.6651077270508,93.2412948608398,93.2412948608398,112.922653198242,112.922653198242,112.922653198242,141.269111633301,141.269111633301,141.269111633301,125.767219543457,125.767219543457,125.767219543457,70.6087112426758,70.6087112426758,89.7609939575195,89.7609939575195,119.018783569336,119.018783569336,119.018783569336,119.018783569336,119.018783569336,139.227928161621,139.227928161621,139.227928161621,49.5470733642578,49.5470733642578,68.7036361694336,68.7036361694336,98.7498474121094,98.7498474121094,118.884147644043,118.884147644043,146.30973815918,146.30973815918,146.30973815918,49.683708190918,49.683708190918,49.683708190918,49.683708190918,49.683708190918,77.8301696777344,77.8301696777344,96.3257751464844,96.3257751464844,96.3257751464844,126.244758605957,126.244758605957,126.244758605957,126.244758605957,126.244758605957,146.318962097168,146.318962097168,146.318962097168,146.318962097168,57.8772583007812,57.8772583007812,57.8772583007812,77.8816223144531,77.8816223144531,77.8816223144531,77.8816223144531,77.8816223144531,108.580513000488,108.580513000488,108.580513000488,108.580513000488,128.719345092773,128.719345092773,128.719345092773,146.298828125,146.298828125,146.298828125,146.298828125,146.298828125,146.298828125,58.9272613525391,58.9272613525391,89.7635269165039,89.7635269165039,110.490112304688,110.490112304688,141.780708312988,141.780708312988,89.1687469482422,89.1687469482422,89.1687469482422,73.3053970336914,73.3053970336914,73.3053970336914,93.2547988891602,93.2547988891602,124.478492736816,124.478492736816,144.223510742188,144.223510742188,56.5710296630859,56.5710296630859,76.7044906616211,76.7044906616211,76.7044906616211,76.7044906616211,107.463653564453,107.463653564453,127.667358398438,127.667358398438,127.667358398438,127.667358398438,127.667358398438,146.297401428223,146.297401428223,146.297401428223,60.2414474487305,60.2414474487305,60.2414474487305,90.9363708496094,90.9363708496094,111.533302307129,111.533302307129,111.533302307129,111.533302307129,111.533302307129,142.559577941895,142.559577941895,44.3090286254883,44.3090286254883,44.3090286254883,44.3090286254883,73.8919906616211,73.8919906616211,93.7660293579102,93.7660293579102,93.7660293579102,123.93546295166,123.93546295166,123.93546295166,123.93546295166,123.93546295166,143.481140136719,143.481140136719,143.481140136719,55.2641983032227,55.2641983032227,55.2641983032227,55.2641983032227,75.5948257446289,75.5948257446289,104.85001373291,104.85001373291,122.230461120605,122.230461120605,122.230461120605,146.300628662109,146.300628662109,146.300628662109,50.1825637817383,50.1825637817383,50.1825637817383,80.6800079345703,80.6800079345703,101.271423339844,101.271423339844,132.029388427734,132.029388427734,132.029388427734,146.32740020752,146.32740020752,146.32740020752,61.5958786010742,61.5958786010742,61.5958786010742,81.0789337158203,81.0789337158203,81.0789337158203,81.0789337158203,81.0789337158203,81.0789337158203,112.755363464355,112.755363464355,133.741302490234,133.741302490234,44.7420501708984,44.7420501708984,44.7420501708984,64.1553192138672,64.1553192138672,94.1283493041992,94.1283493041992,114.853660583496,114.853660583496,114.853660583496,114.853660583496,114.853660583496,114.853660583496,145.878662109375,145.878662109375,145.878662109375,145.878662109375,145.878662109375,46.3815765380859,46.3815765380859,76.7469100952148,76.7469100952148,76.7469100952148,96.817756652832,96.817756652832,96.817756652832,128.234100341797,128.234100341797,146.333404541016,146.333404541016,146.333404541016,59.0409622192383,59.0409622192383,78.3882827758789,78.3882827758789,109.869918823242,109.869918823242,128.299827575684,128.299827575684,146.335716247559,146.335716247559,146.335716247559,58.0571365356445,58.0571365356445,87.8328094482422,87.8328094482422,108.099136352539,108.099136352539,108.099136352539,108.099136352539,108.099136352539,137.744850158691,137.744850158691,137.744850158691,146.338104248047,146.338104248047,146.338104248047,67.6967163085938,67.6967163085938,67.6967163085938,88.0951766967773,88.0951766967773,119.121444702148,119.121444702148,139.64966583252,139.64966583252,139.64966583252,50.5832901000977,50.5832901000977,70.5170211791992,70.5170211791992,101.79468536377,101.79468536377,101.79468536377,101.79468536377,101.79468536377,122.384757995605,122.384757995605,146.316947937012,146.316947937012,146.316947937012,53.6683578491211,53.6683578491211,84.3562774658203,84.3562774658203,105.141662597656,105.141662597656,136.681846618652,136.681846618652,146.321624755859,146.321624755859,146.321624755859,146.321624755859,68.2873916625977,68.2873916625977,88.2877502441406,88.2877502441406,88.2877502441406,119.69499206543,119.69499206543,119.69499206543,140.41722869873,140.41722869873,52.0288925170898,52.0288925170898,72.2923355102539,72.2923355102539,102.849655151367,102.849655151367,102.849655151367,102.849655151367,102.849655151367,123.375648498535,123.375648498535,123.375648498535,123.375648498535,123.375648498535,146.32642364502,146.32642364502,146.32642364502,55.8320236206055,55.8320236206055,86.9137649536133,86.9137649536133,107.895034790039,107.895034790039,139.433692932129,139.433692932129,139.433692932129,139.433692932129,146.31876373291,146.31876373291,146.31876373291,146.31876373291,146.31876373291,146.31876373291,71.373161315918,71.373161315918,90.6515274047852,90.6515274047852,90.6515274047852,90.6515274047852,90.6515274047852,90.6515274047852,120.485221862793,120.485221862793,120.485221862793,141.009056091309,141.009056091309,52.292121887207,52.292121887207,72.4886169433594,72.4886169433594,104.094276428223,104.094276428223,124.093460083008,124.093460083008,146.321006774902,146.321006774902,146.321006774902,55.2438354492188,55.2438354492188,55.2438354492188,86.3244094848633,86.3244094848633,107.110580444336,107.110580444336,107.110580444336,107.110580444336,138.12442779541,138.12442779541,146.319488525391,146.319488525391,146.319488525391,67.5688552856445,67.5688552856445,67.5688552856445,86.0569305419922,86.0569305419922,116.280158996582,116.280158996582,136.276336669922,136.276336669922,47.769401550293,47.769401550293,67.831916809082,67.831916809082,67.831916809082,67.831916809082,67.831916809082,99.1042327880859,99.1042327880859,99.1042327880859,99.1042327880859,99.1042327880859,119.821243286133,119.821243286133,146.308975219727,146.308975219727,146.308975219727,146.308975219727,146.308975219727,146.308975219727,48.9503173828125,48.9503173828125,76.4210357666016,76.4210357666016,76.4210357666016,95.696174621582,95.696174621582,124.281623840332,124.281623840332,142.76978302002,142.76978302002,142.76978302002,52.6222686767578,52.6222686767578,70.5865478515625,70.5865478515625,70.5865478515625,70.5865478515625,70.5865478515625,99.891716003418,99.891716003418,118.315170288086,118.315170288086,145.654014587402,145.654014587402,46.1980514526367,46.1980514526367,75.0447998046875,75.0447998046875,75.0447998046875,94.3849868774414,94.3849868774414,94.3849868774414,94.3849868774414,122.248031616211,122.248031616211,122.248031616211,141.129333496094,141.129333496094,141.129333496094,50.9845962524414,50.9845962524414,69.0795440673828,69.0795440673828,69.0795440673828,69.0795440673828,69.0795440673828,96.8765335083008,96.8765335083008,116.08610534668,116.08610534668,116.08610534668,116.08610534668,145.456596374512,145.456596374512,44.3446044921875,44.3446044921875,73.780647277832,73.780647277832,92.7280044555664,92.7280044555664,92.7280044555664,120.525192260742,120.525192260742,120.525192260742,139.603057861328,139.603057861328,49.3933029174805,49.3933029174805,49.3933029174805,49.3933029174805,49.3933029174805,69.5202789306641,69.5202789306641,69.5202789306641,100.398780822754,100.398780822754,113.604362487793,113.604362487793,113.604362487793,113.604362487793,113.604362487793],"meminc":[0,0,20.3328475952148,0,0,0,26.9627914428711,0,16.465446472168,0,0,0,0,0,22.5641021728516,0,0,-100.489501953125,0,0,0,0,0,29.8494338989258,0,0,19.3527221679688,0,28.8632278442383,0,17.3865585327148,0,-92.5023345947266,0,20.206916809082,0,30.5066223144531,0,18.373420715332,0,28.4721755981445,0,0,-102.015609741211,0,0,0,0,28.3348770141602,0,0,0,19.6108551025391,0,28.0072784423828,0,0,0,0,18.7588195800781,0,-92.8075332641602,0,18.2396850585938,0,28.8656234741211,0,15.8740615844727,0,29.5185928344727,0,0,7.60800170898438,0,0,-79.9665374755859,0,0,0,0,19.0915679931641,0,30.5669784545898,0,0,0,0,19.6211547851562,0,0,-91.9742965698242,0,19.0262145996094,0,0,0,0,0,30.7023849487305,0,18.4337158203125,0,0,0,0,29.1955261230469,0,5.25210571289062,0,0,0,0,0,-77.5450744628906,0,0,0,0,20.2119522094727,0,0,29.3223876953125,0,0,19.2219390869141,0,-92.6356658935547,0,19.8755187988281,0,30.2517623901367,0,18.7647857666016,0,0,28.6045989990234,0,0,3.93413543701172,0,0,-75.5762786865234,0,20.5917129516602,0,0,27.9545593261719,0,19.0900192260742,0,-92.9647827148438,0,17.1233062744141,0,28.0802612304688,0,0,0,0,18.3015213012695,0,0,0,0,0,27.4904632568359,0,9.90657043457031,0,0,-85.2822799682617,0,0,19.9409332275391,0,0,28.0060729980469,0,17.7077789306641,0,19.6831359863281,0,0,-94.650764465332,0,0,0,27.6213684082031,0,19.2830200195312,0,0,26.5074005126953,0,0,0,0,17.6467895507812,0,0,0,-91.8496322631836,0,17.9759140014648,0,0,0,0,29.8533554077148,0,17.0600662231445,0,0,0,0,27.0934982299805,0,0,3.41161346435547,0,0,-77.4110717773438,0,0,0,0,17.0558776855469,0,0,28.2732543945312,0,17.384521484375,0,0,14.6930618286133,0,0,-87.0531539916992,0,0,30.1196212768555,0,0,0,0,19.2194061279297,0,0,0,29.2588729858398,0,8.46222686767578,0,0,-80.4393844604492,0,0,20.2697448730469,0,0,30.5744247436523,0,20.1339263916016,0,0,0,0,9.44554138183594,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,11.7462692260742,0,30.4382095336914,0,0,19.28564453125,0,29.062126159668,0,0,0,0,0,12.9899978637695,0,0,0,-82.0001068115234,0,20.3374176025391,0,29.3210601806641,0,0,0,0,19.087646484375,0,0,0,0,0,-89.083122253418,0,0,0,19.8743057250977,0,0,30.1130065917969,0,0,0,20.7939910888672,0,31.5473861694336,0,-99.5739440917969,0,0,0,30.2426452636719,0,20.4659957885742,0,0,0,31.1602020263672,0,17.7137756347656,0,0,-85.8032531738281,0,20.6601104736328,0,0,0,0,31.1584930419922,0,0,18.4999313354492,0,2.97832489013672,0,0,-72.7683868408203,0,30.236572265625,0,0,0,20.6009674072266,0,31.0913162231445,0,0,0,-98.8552322387695,0,29.5209274291992,0,20.0011520385742,0,0,0,0,30.7661743164062,0,20.3288421630859,0,0,0,0,-91.5009613037109,0,0,18.3672561645508,0,30.3135147094727,0,20.1410217285156,0,0,0,24.2746276855469,0,0,-92.6972732543945,0,30.2501373291016,0,20.0100250244141,0,0,0,0,30.6350860595703,0,0,11.8069534301758,0,0,-81.4837188720703,0,0,0,19.5526580810547,0,29.5803451538086,0,18.5689544677734,0,-89.0202026367188,0,19.1572723388672,0,30.5761871337891,0,19.6813583374023,0,0,28.3464584350586,0,0,-15.5018920898438,0,0,-55.1585083007812,0,19.1522827148438,0,29.2577896118164,0,0,0,0,20.2091445922852,0,0,-89.6808547973633,0,19.1565628051758,0,30.0462112426758,0,20.1343002319336,0,27.4255905151367,0,0,-96.6260299682617,0,0,0,0,28.1464614868164,0,18.49560546875,0,0,29.9189834594727,0,0,0,0,20.0742034912109,0,0,0,-88.4417037963867,0,0,20.0043640136719,0,0,0,0,30.6988906860352,0,0,0,20.1388320922852,0,0,17.5794830322266,0,0,0,0,0,-87.3715667724609,0,30.8362655639648,0,20.7265853881836,0,31.2905960083008,0,-52.6119613647461,0,0,-15.8633499145508,0,0,19.9494018554688,0,31.2236938476562,0,19.7450180053711,0,-87.6524810791016,0,20.1334609985352,0,0,0,30.759162902832,0,20.2037048339844,0,0,0,0,18.6300430297852,0,0,-86.0559539794922,0,0,30.6949234008789,0,20.5969314575195,0,0,0,0,31.0262756347656,0,-98.2505493164062,0,0,0,29.5829620361328,0,19.8740386962891,0,0,30.16943359375,0,0,0,0,19.5456771850586,0,0,-88.2169418334961,0,0,0,20.3306274414062,0,29.2551879882812,0,17.3804473876953,0,0,24.0701675415039,0,0,-96.1180648803711,0,0,30.497444152832,0,20.5914154052734,0,30.7579650878906,0,0,14.2980117797852,0,0,-84.7315216064453,0,0,19.4830551147461,0,0,0,0,0,31.6764297485352,0,20.9859390258789,0,-88.9992523193359,0,0,19.4132690429688,0,29.973030090332,0,20.7253112792969,0,0,0,0,0,31.0250015258789,0,0,0,0,-99.4970855712891,0,30.3653335571289,0,0,20.0708465576172,0,0,31.4163436889648,0,18.0993041992188,0,0,-87.2924423217773,0,19.3473205566406,0,31.4816360473633,0,18.4299087524414,0,18.035888671875,0,0,-88.2785797119141,0,29.7756729125977,0,20.2663269042969,0,0,0,0,29.6457138061523,0,0,8.59325408935547,0,0,-78.6413879394531,0,0,20.3984603881836,0,31.0262680053711,0,20.5282211303711,0,0,-89.0663757324219,0,19.9337310791016,0,31.2776641845703,0,0,0,0,20.5900726318359,0,23.9321899414062,0,0,-92.6485900878906,0,30.6879196166992,0,20.7853851318359,0,31.5401840209961,0,9.63977813720703,0,0,0,-78.0342330932617,0,20.000358581543,0,0,31.4072418212891,0,0,20.7222366333008,0,-88.3883361816406,0,20.2634429931641,0,30.5573196411133,0,0,0,0,20.525993347168,0,0,0,0,22.9507751464844,0,0,-90.4944000244141,0,31.0817413330078,0,20.9812698364258,0,31.5386581420898,0,0,0,6.88507080078125,0,0,0,0,0,-74.9456024169922,0,19.2783660888672,0,0,0,0,0,29.8336944580078,0,0,20.5238342285156,0,-88.7169342041016,0,20.1964950561523,0,31.6056594848633,0,19.9991836547852,0,22.2275466918945,0,0,-91.0771713256836,0,0,31.0805740356445,0,20.7861709594727,0,0,0,31.0138473510742,0,8.19506072998047,0,0,-78.7506332397461,0,0,18.4880752563477,0,30.2232284545898,0,19.9961776733398,0,-88.5069351196289,0,20.0625152587891,0,0,0,0,31.2723159790039,0,0,0,0,20.7170104980469,0,26.4877319335938,0,0,0,0,0,-97.3586578369141,0,27.4707183837891,0,0,19.2751388549805,0,28.58544921875,0,18.4881591796875,0,0,-90.1475143432617,0,17.9642791748047,0,0,0,0,29.3051681518555,0,18.423454284668,0,27.3388442993164,0,-99.4559631347656,0,28.8467483520508,0,0,19.3401870727539,0,0,0,27.8630447387695,0,0,18.8813018798828,0,0,-90.1447372436523,0,18.0949478149414,0,0,0,0,27.796989440918,0,19.2095718383789,0,0,0,29.370491027832,0,-101.111991882324,0,29.4360427856445,0,18.9473571777344,0,0,27.7971878051758,0,0,19.0778656005859,0,-90.2097549438477,0,0,0,0,20.1269760131836,0,0,30.8785018920898,0,13.2055816650391,0,0,0,0],"filename":["<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpmEws6d/file3c0b58980c83.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    784.080    795.3110    816.6677    799.6600
#>    compute_pi0(m * 10)   7887.071   7924.0550   8404.2177   7966.3125
#>   compute_pi0(m * 100)  78907.124  79095.6070  79673.4128  79490.1545
#>         compute_pi1(m)    172.419    272.4415    754.4258    338.6005
#>    compute_pi1(m * 10)   1426.238   1482.8205   1552.2057   1541.2045
#>   compute_pi1(m * 100)  14016.686  14315.1930  27370.9986  21684.6200
#>  compute_pi1(m * 1000) 276238.020 432335.4610 422419.2055 437214.7535
#>          uq        max neval
#>     814.199    982.681    20
#>    8188.505  15104.961    20
#>   80057.454  81060.126    20
#>     359.306   9260.705    20
#>    1597.194   1737.760    20
#>   23237.560 177116.811    20
#>  441712.854 452859.063    20
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
#>   memory_copy1(n) 5440.59157 3732.02997 553.645479 2863.99907 1773.608749
#>   memory_copy2(n)   95.05167   65.63106  10.778014   51.97455   28.851013
#>  pre_allocate1(n)   19.49857   13.50741   3.506061   11.12240    6.610778
#>  pre_allocate2(n)  194.98363  134.54199  20.244829  104.36823   58.861059
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.000000
#>        max neval
#>  94.079541    10
#>   2.948396    10
#>   2.050707    10
#>   4.003932    10
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
#>    expr      min       lq     mean   median       uq     max neval
#>  f1(df) 295.8026 259.0669 89.17846 253.3557 74.54122 32.7615     5
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
