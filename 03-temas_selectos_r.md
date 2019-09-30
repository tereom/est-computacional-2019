
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
#>    id          a         b         c        d
#> 1   1  1.0230858 0.6861367 3.2665958 3.805933
#> 2   2  1.0708254 0.7167604 0.7064009 3.379839
#> 3   3  1.2511611 1.8566309 2.6416741 4.999635
#> 4   4  0.8520999 1.4429470 3.7182799 5.417109
#> 5   5 -0.1092922 1.7351495 3.3580894 1.995524
#> 6   6 -0.3033828 2.3518607 3.0445291 3.469585
#> 7   7  1.0135929 1.7674503 2.2986709 5.503181
#> 8   8  0.4198096 0.7196034 3.1483397 3.137667
#> 9   9 -2.0529697 3.2391002 4.0837021 4.008794
#> 10 10  0.1224120 0.7018905 2.8108078 4.484486
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.3287342
mean(df$b)
#> [1] 1.521753
mean(df$c)
#> [1] 2.907709
mean(df$d)
#> [1] 4.020175
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.3287342 1.5217530 2.9077090 4.0201753
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
#> [1] 0.3287342 1.5217530 2.9077090 4.0201753
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
#> [1] 5.5000000 0.3287342 1.5217530 2.9077090 4.0201753
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
#> [1] 5.5000000 0.6359548 1.5890483 3.0964344 3.9073634
col_describe(df, mean)
#> [1] 5.5000000 0.3287342 1.5217530 2.9077090 4.0201753
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
#> 5.5000000 0.3287342 1.5217530 2.9077090 4.0201753
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
#>   3.883   0.117   3.999
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.019   0.003   0.517
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
#>  13.069   0.849  10.039
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
#>   0.117   0.000   0.116
plyr_st
#>    user  system elapsed 
#>   4.022   0.000   4.022
est_l_st
#>    user  system elapsed 
#>  62.229   1.296  63.525
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

<!--html_preserve--><div id="htmlwidget-8eb4fe3d1fa058f578e6" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-8eb4fe3d1fa058f578e6">{"x":{"message":{"prof":{"time":[1,1,1,1,1,1,2,2,2,3,3,3,3,3,4,4,5,5,6,6,7,7,8,8,8,9,9,9,10,10,10,10,10,11,11,12,12,12,13,13,13,13,13,13,14,14,14,15,15,15,16,16,17,17,18,18,19,19,19,19,19,20,20,21,21,22,22,22,23,23,24,24,24,24,24,25,25,25,25,25,25,26,26,27,27,27,28,28,29,29,30,30,31,31,31,32,32,32,32,32,32,33,33,34,34,35,35,35,36,36,36,37,37,37,38,38,39,39,40,40,41,41,41,42,42,43,43,43,44,44,44,44,44,45,45,45,46,46,47,47,48,48,48,49,49,49,49,49,50,50,50,51,51,51,52,52,53,53,53,54,54,55,55,55,56,56,56,57,57,57,57,57,58,58,59,59,59,60,60,61,61,61,61,61,61,62,62,62,63,63,63,64,64,64,65,65,65,66,66,66,67,67,67,68,68,69,69,69,69,69,70,70,71,71,71,72,72,73,73,74,74,75,75,76,76,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,89,89,89,90,90,91,91,91,92,92,92,93,93,94,94,94,95,95,95,95,96,96,97,97,98,98,98,99,99,99,100,100,101,101,101,102,102,103,103,104,104,105,105,105,106,106,107,107,108,108,109,109,109,110,110,110,110,110,110,111,111,111,112,112,113,113,113,114,114,115,115,115,116,116,116,116,117,117,117,118,118,118,118,118,118,119,119,119,120,120,120,121,121,121,121,121,122,122,122,123,123,123,124,124,124,124,124,125,125,125,125,125,126,126,127,127,127,127,128,128,128,129,129,129,129,129,130,130,131,131,131,131,131,131,132,132,132,133,133,134,134,134,134,134,135,135,135,136,136,136,137,137,137,138,138,139,139,140,140,141,141,142,142,143,143,143,143,143,144,144,145,145,145,146,146,146,146,147,147,147,148,148,149,149,150,150,150,151,151,152,152,153,153,154,154,154,154,155,155,156,156,156,157,157,158,158,158,159,159,160,160,161,161,161,162,162,163,163,163,164,164,164,165,165,165,166,166,166,167,167,168,168,169,169,170,170,171,171,172,172,172,173,173,173,174,174,175,175,176,176,176,177,177,177,177,177,178,178,179,179,179,180,180,180,181,181,181,181,181,182,182,182,183,183,184,184,185,185,186,186,186,187,187,187,188,188,189,189,190,190,190,190,190,190,191,191,191,192,192,192,192,192,193,193,194,194,194,195,195,195,196,196,197,197,197,197,197,198,198,198,198,199,199,199,199,199,200,200,200,201,201,202,202,203,203,204,204,205,205,205,205,205,206,206,206,207,207,208,208,209,209,209,209,209,209,210,210,211,211,212,212,212,212,213,213,213,213,213,214,214,214,215,215,216,216,216,216,216,217,217,217,217,217,218,218,218,218,218,218,219,219,219,220,220,221,221,222,222,223,223,223,223,223,224,224,224,224,224,225,225,225,226,226,226,227,227,227,228,228,229,229,229,229,229,230,230,230,231,231,231,231,231,232,232,232,233,233,234,234,235,235,236,236,237,237,238,238,238,239,239,240,240,241,241,241,242,242,242,242,242,243,243,244,244,245,245,246,246,246,247,247,248,248,248,248,248,249,249,250,250,250,251,251,251,251,251,252,252,252,253,253,253,254,254,254,254,254,255,255,255,255,255,256,256,257,257,258,258,258,259,259,259,260,260,261,261,261,262,262,263,263,264,264,264,264,264,265,265,266,266,267,267,267,267,267,268,268,268,268,268,269,269,269,270,270,271,271,271,272,272,273,273,274,274,275,275,276,276,276,276,276,277,277,277,278,278,278,279,279,280,280,281,281,281,282,282,283,283,284,284,285,285,285,285,285],"depth":[6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1],"label":[".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","nrow","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","length","dim.data.frame","dim","dim","nrow","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1],"linenum":[null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,11,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,11,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,11,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,10,10,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,13],"memalloc":[68.0133743286133,68.0133743286133,68.0133743286133,68.0133743286133,68.0133743286133,68.0133743286133,89.1349182128906,89.1349182128906,89.1349182128906,116.096839904785,116.096839904785,116.096839904785,116.096839904785,116.096839904785,133.873764038086,133.873764038086,45.9118957519531,45.9118957519531,67.0365982055664,67.0365982055664,98.1320266723633,98.1320266723633,118.141212463379,118.141212463379,118.141212463379,146.28165435791,146.28165435791,146.28165435791,52.8614196777344,52.8614196777344,52.8614196777344,52.8614196777344,52.8614196777344,83.2385940551758,83.2385940551758,102.920944213867,102.920944213867,102.920944213867,133.10717010498,133.10717010498,133.10717010498,133.10717010498,133.10717010498,133.10717010498,146.289611816406,146.289611816406,146.289611816406,69.1968307495117,69.1968307495117,69.1968307495117,90.1872482299805,90.1872482299805,120.554832458496,120.554832458496,140.559577941895,140.559577941895,54.9060668945312,54.9060668945312,54.9060668945312,54.9060668945312,54.9060668945312,76.358039855957,76.358039855957,108.436264038086,108.436264038086,129.951477050781,129.951477050781,129.951477050781,45.5224761962891,45.5224761962891,66.3177261352539,66.3177261352539,66.3177261352539,66.3177261352539,66.3177261352539,98.2653656005859,98.2653656005859,98.2653656005859,98.2653656005859,98.2653656005859,98.2653656005859,119.126739501953,119.126739501953,146.289115905762,146.289115905762,146.289115905762,55.4299926757812,55.4299926757812,87.5748291015625,87.5748291015625,107.522163391113,107.522163391113,138.160278320312,138.160278320312,138.160278320312,146.298683166504,146.298683166504,146.298683166504,146.298683166504,146.298683166504,146.298683166504,74.0009689331055,74.0009689331055,94.803092956543,94.803092956543,125.04850769043,125.04850769043,125.04850769043,143.941162109375,143.941162109375,143.941162109375,58.4538421630859,58.4538421630859,58.4538421630859,78.9907302856445,78.9907302856445,109.370872497559,109.370872497559,128.98902130127,128.98902130127,95.7112121582031,95.7112121582031,95.7112121582031,63.4486618041992,63.4486618041992,95.8496398925781,95.8496398925781,95.8496398925781,117.109657287598,117.109657287598,117.109657287598,117.109657287598,117.109657287598,146.302429199219,146.302429199219,146.302429199219,52.3565444946289,52.3565444946289,82.9949645996094,82.9949645996094,103.395515441895,103.395515441895,103.395515441895,133.639793395996,133.639793395996,133.639793395996,133.639793395996,133.639793395996,146.301651000977,146.301651000977,146.301651000977,68.4988479614258,68.4988479614258,68.4988479614258,89.8149261474609,89.8149261474609,120.444839477539,120.444839477539,120.444839477539,140.449699401855,140.449699401855,54.1337127685547,54.1337127685547,54.1337127685547,74.6080780029297,74.6080780029297,74.6080780029297,104.849769592285,104.849769592285,104.849769592285,104.849769592285,104.849769592285,124.265434265137,124.265434265137,146.309646606445,146.309646606445,146.309646606445,57.67236328125,57.67236328125,87.7170867919922,87.7170867919922,87.7170867919922,87.7170867919922,87.7170867919922,87.7170867919922,107.538795471191,107.538795471191,107.538795471191,137.454193115234,137.454193115234,137.454193115234,146.310249328613,146.310249328613,146.310249328613,72.6399841308594,72.6399841308594,72.6399841308594,93.3052215576172,93.3052215576172,93.3052215576172,124.855949401855,124.855949401855,124.855949401855,146.174613952637,146.174613952637,60.5012054443359,60.5012054443359,60.5012054443359,60.5012054443359,60.5012054443359,81.3677215576172,81.3677215576172,112.199966430664,112.199966430664,112.199966430664,132.340240478516,132.340240478516,46.3999938964844,46.3999938964844,67.4474945068359,67.4474945068359,99.4618148803711,99.4618148803711,120.06103515625,120.06103515625,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,146.296905517578,42.7254943847656,42.7254943847656,42.7254943847656,46.0053863525391,46.0053863525391,77.4316482543945,77.4316482543945,77.4316482543945,97.9641418457031,97.9641418457031,129.911918640137,129.911918640137,129.911918640137,146.313682556152,146.313682556152,146.313682556152,65.6251602172852,65.6251602172852,86.1593780517578,86.1593780517578,86.1593780517578,116.725921630859,116.725921630859,116.725921630859,116.725921630859,136.665740966797,136.665740966797,52.1741256713867,52.1741256713867,72.5104522705078,72.5104522705078,72.5104522705078,104.002716064453,104.002716064453,104.002716064453,123.743476867676,123.743476867676,146.30339050293,146.30339050293,146.30339050293,59.9856414794922,59.9856414794922,91.6686401367188,91.6686401367188,112.331253051758,112.331253051758,143.820213317871,143.820213317871,143.820213317871,49.2935256958008,49.2935256958008,80.4488754272461,80.4488754272461,101.698318481445,101.698318481445,133.451416015625,133.451416015625,133.451416015625,146.309219360352,146.309219360352,146.309219360352,146.309219360352,146.309219360352,146.309219360352,69.5646667480469,69.5646667480469,69.5646667480469,90.4869155883789,90.4869155883789,121.517807006836,121.517807006836,121.517807006836,141.45760345459,141.45760345459,57.6890258789062,57.6890258789062,57.6890258789062,79.0121383666992,79.0121383666992,79.0121383666992,79.0121383666992,111.214469909668,111.214469909668,111.214469909668,132.596908569336,132.596908569336,132.596908569336,132.596908569336,132.596908569336,132.596908569336,49.0308685302734,49.0308685302734,49.0308685302734,69.693717956543,69.693717956543,69.693717956543,101.253463745117,101.253463745117,101.253463745117,101.253463745117,101.253463745117,121.46019744873,121.46019744873,121.46019744873,146.257881164551,146.257881164551,146.257881164551,57.6317825317383,57.6317825317383,57.6317825317383,57.6317825317383,57.6317825317383,88.9292449951172,88.9292449951172,88.9292449951172,88.9292449951172,88.9292449951172,109.661582946777,109.661582946777,141.543106079102,141.543106079102,141.543106079102,141.543106079102,47.7907257080078,47.7907257080078,47.7907257080078,79.5438690185547,79.5438690185547,79.5438690185547,79.5438690185547,79.5438690185547,100.926948547363,100.926948547363,132.939964294434,132.939964294434,132.939964294434,132.939964294434,132.939964294434,132.939964294434,146.258193969727,146.258193969727,146.258193969727,70.6239547729492,70.6239547729492,91.6214981079102,91.6214981079102,91.6214981079102,91.6214981079102,91.6214981079102,122.850784301758,122.850784301758,122.850784301758,143.255699157715,143.255699157715,143.255699157715,59.4088821411133,59.4088821411133,59.4088821411133,79.815299987793,79.815299987793,111.301979064941,111.301979064941,129.603134155273,129.603134155273,44.9097061157227,44.9097061157227,65.378791809082,65.378791809082,97.0654220581055,97.0654220581055,97.0654220581055,97.0654220581055,97.0654220581055,117.789573669434,117.789573669434,146.264762878418,146.264762878418,146.264762878418,54.2324905395508,54.2324905395508,54.2324905395508,54.2324905395508,85.4575805664062,85.4575805664062,85.4575805664062,106.515838623047,106.515838623047,137.021842956543,137.021842956543,146.273162841797,146.273162841797,146.273162841797,73.0493850708008,73.0493850708008,94.1701889038086,94.1701889038086,125.919586181641,125.919586181641,146.254623413086,146.254623413086,146.254623413086,146.254623413086,63.4093856811523,63.4093856811523,83.8810424804688,83.8810424804688,83.8810424804688,113.004547119141,113.004547119141,132.223106384277,132.223106384277,132.223106384277,48.7859954833984,48.7859954833984,69.5204772949219,69.5204772949219,100.624053955078,100.624053955078,100.624053955078,121.023612976074,121.023612976074,146.279411315918,146.279411315918,146.279411315918,59.6088256835938,59.6088256835938,59.6088256835938,90.6930694580078,90.6930694580078,90.6930694580078,111.552215576172,111.552215576172,111.552215576172,141.266624450684,141.266624450684,47.8672103881836,47.8672103881836,79.6733245849609,79.6733245849609,100.601440429688,100.601440429688,133.329765319824,133.329765319824,146.253746032715,146.253746032715,146.253746032715,72.2061004638672,72.2061004638672,72.2061004638672,93.5220260620117,93.5220260620117,125.65909576416,125.65909576416,146.255516052246,146.255516052246,146.255516052246,64.7928924560547,64.7928924560547,64.7928924560547,64.7928924560547,64.7928924560547,84.991569519043,84.991569519043,116.411155700684,116.411155700684,116.411155700684,136.87614440918,136.87614440918,136.87614440918,44.5625915527344,44.5625915527344,44.5625915527344,44.5625915527344,44.5625915527344,64.763427734375,64.763427734375,64.763427734375,90.4058456420898,90.4058456420898,108.307632446289,108.307632446289,134.017555236816,134.017555236816,146.281982421875,146.281982421875,146.281982421875,66.7346801757812,66.7346801757812,66.7346801757812,86.2165069580078,86.2165069580078,116.513954162598,116.513954162598,135.79426574707,135.79426574707,135.79426574707,135.79426574707,135.79426574707,135.79426574707,50.7959213256836,50.7959213256836,50.7959213256836,71.0625762939453,71.0625762939453,71.0625762939453,71.0625762939453,71.0625762939453,100.838333129883,100.838333129883,120.709945678711,120.709945678711,120.709945678711,146.291702270508,146.291702270508,146.291702270508,55.911735534668,55.911735534668,85.8846740722656,85.8846740722656,85.8846740722656,85.8846740722656,85.8846740722656,105.693466186523,105.693466186523,105.693466186523,105.693466186523,135.927879333496,135.927879333496,135.927879333496,135.927879333496,135.927879333496,146.287544250488,146.287544250488,146.287544250488,71.587532043457,71.587532043457,91.5263214111328,91.5263214111328,121.171432495117,121.171432495117,140.25594329834,140.25594329834,55.5849685668945,55.5849685668945,55.5849685668945,55.5849685668945,55.5849685668945,75.3922805786133,75.3922805786133,75.3922805786133,104.051383972168,104.051383972168,123.006256103516,123.006256103516,146.292625427246,146.292625427246,146.292625427246,146.292625427246,146.292625427246,146.292625427246,57.9456253051758,57.9456253051758,88.0491333007812,88.0491333007812,106.545875549316,106.545875549316,106.545875549316,106.545875549316,136.128326416016,136.128326416016,136.128326416016,136.128326416016,136.128326416016,146.291473388672,146.291473388672,146.291473388672,72.4392013549805,72.4392013549805,93.6845932006836,93.6845932006836,93.6845932006836,93.6845932006836,93.6845932006836,125.946105957031,125.946105957031,125.946105957031,125.946105957031,125.946105957031,146.272560119629,146.272560119629,146.272560119629,146.272560119629,146.272560119629,146.272560119629,63.3922348022461,63.3922348022461,63.3922348022461,83.3268508911133,83.3268508911133,113.619613647461,113.619613647461,133.291770935059,133.291770935059,48.9005966186523,48.9005966186523,48.9005966186523,48.9005966186523,48.9005966186523,69.4900741577148,69.4900741577148,69.4900741577148,69.4900741577148,69.4900741577148,98.9974212646484,98.9974212646484,98.9974212646484,117.356201171875,117.356201171875,117.356201171875,146.209617614746,146.209617614746,146.209617614746,51.6572265625,51.6572265625,82.6087188720703,82.6087188720703,82.6087188720703,82.6087188720703,82.6087188720703,101.952880859375,101.952880859375,101.952880859375,131.790550231934,131.790550231934,131.790550231934,131.790550231934,131.790550231934,146.282379150391,146.282379150391,146.282379150391,67.8531112670898,67.8531112670898,87.7872772216797,87.7872772216797,118.275466918945,118.275466918945,138.274421691895,138.274421691895,54.412467956543,54.412467956543,75.3297958374023,75.3297958374023,75.3297958374023,105.688606262207,105.688606262207,123.588577270508,123.588577270508,146.27668762207,146.27668762207,146.27668762207,57.9535369873047,57.9535369873047,57.9535369873047,57.9535369873047,57.9535369873047,89.6240921020508,89.6240921020508,111.065887451172,111.065887451172,142.604606628418,142.604606628418,47.9215927124023,47.9215927124023,47.9215927124023,78.0183715820312,78.0183715820312,98.6081008911133,98.6081008911133,98.6081008911133,98.6081008911133,98.6081008911133,130.147201538086,130.147201538086,146.275444030762,146.275444030762,146.275444030762,66.8690795898438,66.8690795898438,66.8690795898438,66.8690795898438,66.8690795898438,86.9965057373047,86.9965057373047,86.9965057373047,116.89208984375,116.89208984375,116.89208984375,136.035781860352,136.035781860352,136.035781860352,136.035781860352,136.035781860352,51.8561782836914,51.8561782836914,51.8561782836914,51.8561782836914,51.8561782836914,71.9185256958008,71.9185256958008,103.846282958984,103.846282958984,122.990707397461,122.990707397461,122.990707397461,146.26513671875,146.26513671875,146.26513671875,59.265869140625,59.265869140625,89.8178634643555,89.8178634643555,89.8178634643555,108.044136047363,108.044136047363,138.202301025391,138.202301025391,44.3841705322266,44.3841705322266,44.3841705322266,44.3841705322266,44.3841705322266,74.8043518066406,74.8043518066406,94.406623840332,94.406623840332,123.123817443848,123.123817443848,123.123817443848,123.123817443848,123.123817443848,141.939567565918,141.939567565918,141.939567565918,141.939567565918,141.939567565918,58.283561706543,58.283561706543,58.283561706543,79.3937377929688,79.3937377929688,111.780570983887,111.780570983887,111.780570983887,133.218414306641,133.218414306641,50.2854690551758,50.2854690551758,71.0683975219727,71.0683975219727,101.357048034668,101.357048034668,121.615180969238,121.615180969238,121.615180969238,121.615180969238,121.615180969238,146.265472412109,146.265472412109,146.265472412109,57.0837554931641,57.0837554931641,57.0837554931641,88.7491989135742,88.7491989135742,110.31810760498,110.31810760498,142.049560546875,142.049560546875,142.049560546875,47.0535125732422,47.0535125732422,78.3256149291992,78.3256149291992,98.7148208618164,98.7148208618164,112.510231018066,112.510231018066,112.510231018066,112.510231018066,112.510231018066],"meminc":[0,0,0,0,0,0,21.1215438842773,0,0,26.9619216918945,0,0,0,0,17.7769241333008,0,-87.9618682861328,0,21.1247024536133,0,31.0954284667969,0,20.0091857910156,0,0,28.1404418945312,0,0,-93.4202346801758,0,0,0,0,30.3771743774414,0,19.6823501586914,0,0,30.1862258911133,0,0,0,0,0,13.1824417114258,0,0,-77.0927810668945,0,0,20.9904174804688,0,30.3675842285156,0,20.0047454833984,0,-85.6535110473633,0,0,0,0,21.4519729614258,0,32.0782241821289,0,21.5152130126953,0,0,-84.4290008544922,0,20.7952499389648,0,0,0,0,31.947639465332,0,0,0,0,0,20.8613739013672,0,27.1623764038086,0,0,-90.8591232299805,0,32.1448364257812,0,19.9473342895508,0,30.6381149291992,0,0,8.13840484619141,0,0,0,0,0,-72.2977142333984,0,20.8021240234375,0,30.2454147338867,0,0,18.8926544189453,0,0,-85.4873199462891,0,0,20.5368881225586,0,30.3801422119141,0,19.6181488037109,0,-33.2778091430664,0,0,-32.2625503540039,0,32.4009780883789,0,0,21.2600173950195,0,0,0,0,29.1927719116211,0,0,-93.9458847045898,0,30.6384201049805,0,20.4005508422852,0,0,30.2442779541016,0,0,0,0,12.6618576049805,0,0,-77.8028030395508,0,0,21.3160781860352,0,30.6299133300781,0,0,20.0048599243164,0,-86.3159866333008,0,0,20.474365234375,0,0,30.2416915893555,0,0,0,0,19.4156646728516,0,22.0442123413086,0,0,-88.6372833251953,0,30.0447235107422,0,0,0,0,0,19.8217086791992,0,0,29.915397644043,0,0,8.85605621337891,0,0,-73.6702651977539,0,0,20.6652374267578,0,0,31.5507278442383,0,0,21.3186645507812,0,-85.6734085083008,0,0,0,0,20.8665161132812,0,30.8322448730469,0,0,20.1402740478516,0,-85.9402465820312,0,21.0475006103516,0,32.0143203735352,0,20.5992202758789,0,26.2358703613281,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,3.27989196777344,0,31.4262619018555,0,0,20.5324935913086,0,31.9477767944336,0,0,16.4017639160156,0,0,-80.6885223388672,0,20.5342178344727,0,0,30.5665435791016,0,0,0,19.9398193359375,0,-84.4916152954102,0,20.3363265991211,0,0,31.4922637939453,0,0,19.7407608032227,0,22.5599136352539,0,0,-86.3177490234375,0,31.6829986572266,0,20.6626129150391,0,31.4889602661133,0,0,-94.5266876220703,0,31.1553497314453,0,21.2494430541992,0,31.7530975341797,0,0,12.8578033447266,0,0,0,0,0,-76.7445526123047,0,0,20.922248840332,0,31.030891418457,0,0,19.9397964477539,0,-83.7685775756836,0,0,21.323112487793,0,0,0,32.2023315429688,0,0,21.382438659668,0,0,0,0,0,-83.5660400390625,0,0,20.6628494262695,0,0,31.5597457885742,0,0,0,0,20.2067337036133,0,0,24.7976837158203,0,0,-88.6260986328125,0,0,0,0,31.2974624633789,0,0,0,0,20.7323379516602,0,31.8815231323242,0,0,0,-93.7523803710938,0,0,31.7531433105469,0,0,0,0,21.3830795288086,0,32.0130157470703,0,0,0,0,0,13.318229675293,0,0,-75.6342391967773,0,20.9975433349609,0,0,0,0,31.2292861938477,0,0,20.404914855957,0,0,-83.8468170166016,0,0,20.4064178466797,0,31.4866790771484,0,18.301155090332,0,-84.6934280395508,0,20.4690856933594,0,31.6866302490234,0,0,0,0,20.7241516113281,0,28.4751892089844,0,0,-92.0322723388672,0,0,0,31.2250900268555,0,0,21.0582580566406,0,30.5060043334961,0,9.25131988525391,0,0,-73.2237777709961,0,21.1208038330078,0,31.749397277832,0,20.3350372314453,0,0,0,-82.8452377319336,0,20.4716567993164,0,0,29.1235046386719,0,19.2185592651367,0,0,-83.4371109008789,0,20.7344818115234,0,31.1035766601562,0,0,20.3995590209961,0,25.2557983398438,0,0,-86.6705856323242,0,0,31.0842437744141,0,0,20.8591461181641,0,0,29.7144088745117,0,-93.3994140625,0,31.8061141967773,0,20.9281158447266,0,32.7283248901367,0,12.9239807128906,0,0,-74.0476455688477,0,0,21.3159255981445,0,32.1370697021484,0,20.5964202880859,0,0,-81.4626235961914,0,0,0,0,20.1986770629883,0,31.4195861816406,0,0,20.4649887084961,0,0,-92.3135528564453,0,0,0,0,20.2008361816406,0,0,25.6424179077148,0,17.9017868041992,0,25.7099227905273,0,12.2644271850586,0,0,-79.5473022460938,0,0,19.4818267822266,0,30.2974472045898,0,19.2803115844727,0,0,0,0,0,-84.9983444213867,0,0,20.2666549682617,0,0,0,0,29.7757568359375,0,19.8716125488281,0,0,25.5817565917969,0,0,-90.3799667358398,0,29.9729385375977,0,0,0,0,19.8087921142578,0,0,0,30.2344131469727,0,0,0,0,10.3596649169922,0,0,-74.7000122070312,0,19.9387893676758,0,29.6451110839844,0,19.0845108032227,0,-84.6709747314453,0,0,0,0,19.8073120117188,0,0,28.6591033935547,0,18.9548721313477,0,23.2863693237305,0,0,0,0,0,-88.3470001220703,0,30.1035079956055,0,18.4967422485352,0,0,0,29.5824508666992,0,0,0,0,10.1631469726562,0,0,-73.8522720336914,0,21.2453918457031,0,0,0,0,32.2615127563477,0,0,0,0,20.3264541625977,0,0,0,0,0,-82.8803253173828,0,0,19.9346160888672,0,30.2927627563477,0,19.6721572875977,0,-84.3911743164062,0,0,0,0,20.5894775390625,0,0,0,0,29.5073471069336,0,0,18.3587799072266,0,0,28.8534164428711,0,0,-94.5523910522461,0,30.9514923095703,0,0,0,0,19.3441619873047,0,0,29.8376693725586,0,0,0,0,14.491828918457,0,0,-78.4292678833008,0,19.9341659545898,0,30.4881896972656,0,19.9989547729492,0,-83.8619537353516,0,20.9173278808594,0,0,30.3588104248047,0,17.8999710083008,0,22.6881103515625,0,0,-88.3231506347656,0,0,0,0,31.6705551147461,0,21.4417953491211,0,31.5387191772461,0,-94.6830139160156,0,0,30.0967788696289,0,20.589729309082,0,0,0,0,31.5391006469727,0,16.1282424926758,0,0,-79.406364440918,0,0,0,0,20.1274261474609,0,0,29.8955841064453,0,0,19.1436920166016,0,0,0,0,-84.1796035766602,0,0,0,0,20.0623474121094,0,31.9277572631836,0,19.1444244384766,0,0,23.2744293212891,0,0,-86.999267578125,0,30.5519943237305,0,0,18.2262725830078,0,30.1581649780273,0,-93.8181304931641,0,0,0,0,30.4201812744141,0,19.6022720336914,0,28.7171936035156,0,0,0,0,18.8157501220703,0,0,0,0,-83.656005859375,0,0,21.1101760864258,0,32.386833190918,0,0,21.4378433227539,0,-82.9329452514648,0,20.7829284667969,0,30.2886505126953,0,20.2581329345703,0,0,0,0,24.6502914428711,0,0,-89.1817169189453,0,0,31.6654434204102,0,21.5689086914062,0,31.7314529418945,0,0,-94.9960479736328,0,31.272102355957,0,20.3892059326172,0,13.79541015625,0,0,0,0],"filename":[null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpJDxVRL/file35a65c0c8898.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min         lq        mean      median
#>         compute_pi0(m)    788.934    798.292    814.0408    814.7225
#>    compute_pi0(m * 10)   7862.822   7915.685   8233.6113   7936.1205
#>   compute_pi0(m * 100)  78981.116  79340.176  79950.2925  79666.5110
#>         compute_pi1(m)    162.055    174.681    988.7662    280.6710
#>    compute_pi1(m * 10)   1281.809   1312.657   1700.3209   1394.5000
#>   compute_pi1(m * 100)  12799.444  13283.161  26975.8463  14193.2385
#>  compute_pi1(m * 1000) 240034.450 315703.711 347430.9718 367700.9315
#>          uq        max neval
#>     823.278    890.779    20
#>    7961.639  13543.936    20
#>   79989.682  83844.832    20
#>     294.659   8372.768    20
#>    1435.824   6967.432    20
#>   19846.148 128415.779    20
#>  374355.792 471520.085    20
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
#>   memory_copy1(n) 5435.53101 4604.81108 690.267406 4136.93734 3363.65787
#>   memory_copy2(n)   94.33044   77.86200  11.934379   70.28768   56.53286
#>  pre_allocate1(n)   20.27434   16.60031   3.882178   15.26664   12.38404
#>  pre_allocate2(n)  198.62068  164.53953  24.184245  152.77371  124.74887
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  139.247073    10
#>    2.880512    10
#>    2.110575    10
#>    4.314605    10
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
#>  f1(df) 244.3615 247.6848 82.32216 240.5426 69.07998 29.86357     5
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
