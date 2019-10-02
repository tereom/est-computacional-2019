
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
#>    id           a          b        c        d
#> 1   1  0.05702952 1.26465149 2.700689 4.645431
#> 2   2  0.79362116 2.86718257 2.890144 4.166548
#> 3   3 -0.00519427 2.27548445 2.817258 3.859368
#> 4   4 -1.39041369 2.35362309 3.167073 3.806744
#> 5   5  1.40776242 2.35964261 1.707586 5.775284
#> 6   6 -2.45958570 1.68041127 3.587674 5.602829
#> 7   7 -1.89744190 2.03249537 3.286158 6.347430
#> 8   8 -0.78832743 1.84110957 3.332290 5.484970
#> 9   9 -1.90899233 0.46766656 3.888022 2.674119
#> 10 10  0.31276690 0.08529237 3.539324 4.573316
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.5878775
mean(df$b)
#> [1] 1.722756
mean(df$c)
#> [1] 3.091622
mean(df$d)
#> [1] 4.693604
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.5878775  1.7227559  3.0916217  4.6936039
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
#> [1] -0.5878775  1.7227559  3.0916217  4.6936039
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
#> [1]  5.5000000 -0.5878775  1.7227559  3.0916217  4.6936039
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
#> [1]  5.5000000 -0.3967609  1.9368025  3.2266155  4.6093736
col_describe(df, mean)
#> [1]  5.5000000 -0.5878775  1.7227559  3.0916217  4.6936039
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
#>  5.5000000 -0.5878775  1.7227559  3.0916217  4.6936039
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
#>   4.377   0.216   4.595
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.022   0.000   0.858
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
#>  13.609   1.197  10.610
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
#>   0.119   0.000   0.120
plyr_st
#>    user  system elapsed 
#>   4.317   0.007   4.326
est_l_st
#>    user  system elapsed 
#>  68.833   1.983  70.855
est_r_st
#>    user  system elapsed 
#>   0.418   0.012   0.430
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

<!--html_preserve--><div id="htmlwidget-f5c466169de04fd6199e" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-f5c466169de04fd6199e">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,4,4,5,5,5,6,6,7,7,7,8,8,9,9,10,10,10,11,11,12,12,13,13,14,14,15,15,15,16,16,16,16,17,17,18,18,19,19,19,20,20,20,21,21,21,22,22,23,23,24,24,24,24,24,24,25,25,26,26,27,27,27,28,28,28,29,29,29,30,30,31,31,32,32,32,32,32,33,33,34,34,35,35,36,36,36,37,37,38,38,39,39,39,39,40,40,40,40,40,41,41,41,41,41,42,42,42,43,43,43,43,43,44,44,45,45,46,46,47,47,47,48,48,49,49,49,49,49,50,50,50,51,51,51,52,52,53,53,54,54,54,55,55,56,56,56,57,57,57,57,57,58,58,59,59,60,60,61,61,61,62,62,62,63,63,63,63,63,64,64,64,65,65,65,66,66,66,67,67,68,68,69,69,69,70,70,71,71,71,71,71,72,72,73,73,74,74,74,75,75,76,76,76,76,76,77,77,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,96,96,97,97,97,98,98,98,98,98,99,99,99,99,100,100,100,100,100,101,101,102,102,102,102,102,103,103,104,104,104,104,105,105,105,105,106,106,107,107,108,108,109,109,110,110,111,111,112,112,112,113,113,113,114,114,114,114,114,115,115,115,115,115,116,117,117,118,118,118,118,118,118,119,119,120,120,121,121,122,122,122,122,122,123,123,123,124,124,124,125,125,125,126,126,126,127,127,128,129,129,130,130,131,131,132,132,132,132,132,133,133,133,134,134,135,135,135,136,136,137,137,137,137,137,137,138,138,138,139,139,139,139,139,140,140,140,140,141,141,142,142,142,143,143,143,144,144,145,145,146,146,146,146,147,147,147,148,148,148,148,148,148,149,149,150,150,150,151,151,151,152,152,152,152,152,152,153,153,154,154,154,154,154,155,155,155,155,155,156,156,157,157,157,157,158,158,159,159,159,160,160,160,161,161,161,162,162,162,163,163,164,164,165,165,165,166,166,166,167,167,167,167,167,168,168,169,169,169,170,170,170,171,171,171,172,172,173,173,173,173,173,174,174,174,174,174,175,175,175,175,175,176,176,176,177,177,178,178,179,179,179,180,180,180,181,181,181,182,182,182,183,183,184,184,185,185,186,186,186,187,187,188,188,188,189,189,190,190,190,191,191,192,192,193,193,193,194,194,195,195,195,195,195,196,196,196,197,197,197,197,198,198,198,198,198,199,199,200,200,201,201,201,201,201,202,202,203,203,204,204,204,205,205,205,206,206,206,207,207,207,208,208,208,208,208,209,209,209,210,210,210,210,210,210,211,211,212,212,213,213,214,214,214,214,214,215,215,216,216,217,217,218,218,219,219,219,220,220,221,221,221,221,221,222,222,222,222,222,223,223,224,224,224,224,224,224,225,225,225,225,225,226,226,226,227,227,228,228,228,229,229,229,230,230,231,231,231,231,232,232,233,233,234,234,234,235,235,236,236,236,236,236,237,237,238,238,239,239,240,240,241,241,242,242,243,243,243,243,244,244,245,245,245,245,245,246,246,246,246,246,247,247,248,248,248,249,249,250,250,251,251,252,252,253,253,253,254,254,255,255,255,255,255,256,256,257,257,258,258,258,259,259,260,260,261,261,261,261,261,261,262,262,262,262,263,263,264,264,264,264,264,265,265,266,266,266,266,266,267,267,267,268,268,268,269,269,269,269,269,269,270,270,271,271,272,272,272,273,273,273,273,274,274,274,275,275,275,275,275,276,276,277,277,277,278,278,279,279,280,280,281,281,281,281,282,282,282,282,283,283,283,283,283,284,284,284,284,284,285,285,286,286,286,287,287,287,287,287,287,288,288,288,288,289,289,290,290,290,290,290,290,291,291,292,292,292,293,293,294,294,295,295,296,296,296,296,297,297,298,298,298,299,299,299,300,300,301,301,302,302,302,302,302,303,303,303,303,303,303],"depth":[2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,4,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","dim.data.frame","dim","dim","nrow","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","$","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","n[i] <- nrow(sub_Batting)","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","oldClass","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sum","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","length","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","anyDuplicated","[.data.frame","[","dim","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","oldClass","[.data.frame","[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","unique.default","unique","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,null,null,1],"linenum":[9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,11,10,10,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,10,10,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,11,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,10,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,11,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,11,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,null,null,13],"memalloc":[61.7223052978516,61.7223052978516,82.7104721069336,82.7104721069336,108.426956176758,108.426956176758,124.629974365234,124.629974365234,146.275482177734,146.275482177734,146.275482177734,52.0827178955078,52.0827178955078,83.5105438232422,83.5105438232422,83.5105438232422,103.455200195312,103.455200195312,133.363899230957,133.363899230957,146.286766052246,146.286766052246,146.286766052246,67.3680801391602,67.3680801391602,88.6225128173828,88.6225128173828,118.478370666504,118.478370666504,138.293907165527,138.293907165527,51.8856735229492,51.8856735229492,51.8856735229492,72.0232543945312,72.0232543945312,72.0232543945312,72.0232543945312,102.522552490234,102.522552490234,122.199661254883,122.199661254883,146.274383544922,146.274383544922,146.274383544922,55.9609222412109,55.9609222412109,55.9609222412109,87.4501647949219,87.4501647949219,87.4501647949219,108.441375732422,108.441375732422,140.451591491699,140.451591491699,43.8228225708008,43.8228225708008,43.8228225708008,43.8228225708008,43.8228225708008,43.8228225708008,74.9182434082031,74.9182434082031,95.7786026000977,95.7786026000977,127.729293823242,127.729293823242,127.729293823242,146.294227600098,146.294227600098,146.294227600098,62.5887756347656,62.5887756347656,62.5887756347656,83.5759887695312,83.5759887695312,113.626892089844,113.626892089844,133.375686645508,133.375686645508,133.375686645508,133.375686645508,133.375686645508,46.2535934448242,46.2535934448242,66.1972961425781,66.1972961425781,96.0544891357422,96.0544891357422,115.603912353516,115.603912353516,115.603912353516,145.257080078125,145.257080078125,48.4214324951172,48.4214324951172,79.3899612426758,79.3899612426758,79.3899612426758,79.3899612426758,99.7346038818359,99.7346038818359,99.7346038818359,99.7346038818359,99.7346038818359,129.650344848633,129.650344848633,129.650344848633,129.650344848633,129.650344848633,146.310111999512,146.310111999512,146.310111999512,62.8631210327148,62.8631210327148,62.8631210327148,62.8631210327148,62.8631210327148,84.1783752441406,84.1783752441406,116.129737854004,116.129737854004,137.254318237305,137.254318237305,51.9022750854492,51.9022750854492,51.9022750854492,72.7617492675781,72.7617492675781,103.859535217285,103.859535217285,103.859535217285,103.859535217285,103.859535217285,123.867111206055,123.867111206055,123.867111206055,146.306762695312,146.306762695312,146.306762695312,57.4149475097656,57.4149475097656,89.0333557128906,89.0333557128906,109.432067871094,109.432067871094,109.432067871094,139.53588104248,139.53588104248,124.370719909668,124.370719909668,124.370719909668,73.3675689697266,73.3675689697266,73.3675689697266,73.3675689697266,73.3675689697266,94.6795806884766,94.6795806884766,124.730049133301,124.730049133301,144.017181396484,144.017181396484,58.6607437133789,58.6607437133789,58.6607437133789,79.1948013305664,79.1948013305664,79.1948013305664,109.382781982422,109.382781982422,109.382781982422,109.382781982422,109.382781982422,129.523246765137,129.523246765137,129.523246765137,146.315361022949,146.315361022949,146.315361022949,61.7519760131836,61.7519760131836,61.7519760131836,92.9821014404297,92.9821014404297,113.971618652344,113.971618652344,145.261520385742,145.261520385742,145.261520385742,49.2861557006836,49.2861557006836,80.1257400512695,80.1257400512695,80.1257400512695,80.1257400512695,80.1257400512695,100.726791381836,100.726791381836,130.442176818848,130.442176818848,146.31803894043,146.31803894043,146.31803894043,62.7309265136719,62.7309265136719,81.0967559814453,81.0967559814453,81.0967559814453,81.0967559814453,81.0967559814453,110.818946838379,110.818946838379,130.952850341797,130.952850341797,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,146.302017211914,42.7306060791016,42.7306060791016,42.7306060791016,42.7306060791016,42.7306060791016,42.7306060791016,69.6306304931641,69.6306304931641,89.0492324829102,89.0492324829102,120.139686584473,120.139686584473,120.139686584473,139.694473266602,139.694473266602,139.694473266602,139.694473266602,139.694473266602,49.4242095947266,49.4242095947266,49.4242095947266,49.4242095947266,69.1718673706055,69.1718673706055,69.1718673706055,69.1718673706055,69.1718673706055,98.9505004882812,98.9505004882812,117.714637756348,117.714637756348,117.714637756348,117.714637756348,117.714637756348,146.250106811523,146.250106811523,46.0139312744141,46.0139312744141,46.0139312744141,46.0139312744141,75.9262771606445,75.9262771606445,75.9262771606445,75.9262771606445,96.1997528076172,96.1997528076172,124.92936706543,124.92936706543,143.751571655273,143.751571655273,53.5572967529297,53.5572967529297,73.5684432983398,73.5684432983398,104.465461730957,104.465461730957,124.996047973633,124.996047973633,124.996047973633,146.318023681641,146.318023681641,146.318023681641,54.9389724731445,54.9389724731445,54.9389724731445,54.9389724731445,54.9389724731445,84.9790573120117,84.9790573120117,84.9790573120117,84.9790573120117,84.9790573120117,105.047828674316,135.227386474609,135.227386474609,146.314331054688,146.314331054688,146.314331054688,146.314331054688,146.314331054688,146.314331054688,64.9773101806641,64.9773101806641,85.1790924072266,85.1790924072266,114.56950378418,114.56950378418,132.938255310059,132.938255310059,132.938255310059,132.938255310059,132.938255310059,63.9157943725586,63.9157943725586,63.9157943725586,62.3514709472656,62.3514709472656,62.3514709472656,92.3276901245117,92.3276901245117,92.3276901245117,112.793037414551,112.793037414551,112.793037414551,143.946968078613,143.946968078613,44.2484893798828,74.1574859619141,74.1574859619141,93.7760391235352,93.7760391235352,122.186447143555,122.186447143555,140.685012817383,140.685012817383,140.685012817383,140.685012817383,140.685012817383,50.4192352294922,50.4192352294922,50.4192352294922,70.1659545898438,70.1659545898438,98.7750549316406,98.7750549316406,98.7750549316406,118.522621154785,118.522621154785,146.27027130127,146.27027130127,146.27027130127,146.27027130127,146.27027130127,146.27027130127,49.3696670532227,49.3696670532227,49.3696670532227,79.2867202758789,79.2867202758789,79.2867202758789,79.2867202758789,79.2867202758789,99.0941619873047,99.0941619873047,99.0941619873047,99.0941619873047,129.863670349121,129.863670349121,146.263305664062,146.263305664062,146.263305664062,59.8684234619141,59.8684234619141,59.8684234619141,79.8141708374023,79.8141708374023,110.190895080566,110.190895080566,130.13988494873,130.13988494873,130.13988494873,130.13988494873,146.278869628906,146.278869628906,146.278869628906,60.7926788330078,60.7926788330078,60.7926788330078,60.7926788330078,60.7926788330078,60.7926788330078,90.1812973022461,90.1812973022461,109.797027587891,109.797027587891,109.797027587891,138.139747619629,138.139747619629,138.139747619629,146.276519775391,146.276519775391,146.276519775391,146.276519775391,146.276519775391,146.276519775391,67.7451629638672,67.7451629638672,87.5602798461914,87.5602798461914,87.5602798461914,87.5602798461914,87.5602798461914,118.777809143066,118.777809143066,118.777809143066,118.777809143066,118.777809143066,138.595031738281,138.595031738281,47.8722610473633,47.8722610473633,47.8722610473633,47.8722610473633,65.7831192016602,65.7831192016602,94.9086608886719,94.9086608886719,94.9086608886719,113.999954223633,113.999954223633,113.999954223633,142.145904541016,142.145904541016,142.145904541016,110.280029296875,110.280029296875,110.280029296875,72.267204284668,72.267204284668,92.208625793457,92.208625793457,122.973960876465,122.973960876465,122.973960876465,143.439697265625,143.439697265625,143.439697265625,54.0342025756836,54.0342025756836,54.0342025756836,54.0342025756836,54.0342025756836,73.9116897583008,73.9116897583008,103.892288208008,103.892288208008,103.892288208008,122.785285949707,122.785285949707,122.785285949707,146.267868041992,146.267868041992,146.267868041992,52.5304412841797,52.5304412841797,81.2750396728516,81.2750396728516,81.2750396728516,81.2750396728516,81.2750396728516,100.956916809082,100.956916809082,100.956916809082,100.956916809082,100.956916809082,129.295669555664,129.295669555664,129.295669555664,129.295669555664,129.295669555664,146.284523010254,146.284523010254,146.284523010254,57.7108993530273,57.7108993530273,76.7294845581055,76.7294845581055,106.833221435547,106.833221435547,106.833221435547,125.724769592285,125.724769592285,125.724769592285,146.256927490234,146.256927490234,146.256927490234,54.8888168334961,54.8888168334961,54.8888168334961,83.8765258789062,83.8765258789062,103.819427490234,103.819427490234,132.41667175293,132.41667175293,146.258850097656,146.258850097656,146.258850097656,63.2254409790039,63.2254409790039,83.2961502075195,83.2961502075195,83.2961502075195,114.317558288574,114.317558288574,134.717414855957,134.717414855957,134.717414855957,45.5794448852539,45.5794448852539,65.4533615112305,65.4533615112305,96.0175552368164,96.0175552368164,96.0175552368164,115.891471862793,115.891471862793,146.127098083496,146.127098083496,146.127098083496,146.127098083496,146.127098083496,44.4371871948242,44.4371871948242,44.4371871948242,74.2803649902344,74.2803649902344,74.2803649902344,74.2803649902344,93.5599975585938,93.5599975585938,93.5599975585938,93.5599975585938,93.5599975585938,122.152084350586,122.152084350586,142.286445617676,142.286445617676,51.9143905639648,51.9143905639648,51.9143905639648,51.9143905639648,51.9143905639648,72.0509643554688,72.0509643554688,102.551040649414,102.551040649414,123.143547058105,123.143547058105,123.143547058105,146.292724609375,146.292724609375,146.292724609375,53.0952682495117,53.0952682495117,53.0952682495117,83.1345672607422,83.1345672607422,83.1345672607422,102.876533508301,102.876533508301,102.876533508301,102.876533508301,102.876533508301,133.441467285156,133.441467285156,133.441467285156,146.296279907227,146.296279907227,146.296279907227,146.296279907227,146.296279907227,146.296279907227,63.0647964477539,63.0647964477539,82.8066177368164,82.8066177368164,113.960868835449,113.960868835449,134.162010192871,134.162010192871,134.162010192871,134.162010192871,134.162010192871,44.3094482421875,44.3094482421875,63.5259170532227,63.5259170532227,93.8264389038086,93.8264389038086,114.158378601074,114.158378601074,145.508445739746,145.508445739746,145.508445739746,44.5073165893555,44.5073165893555,74.6097412109375,74.6097412109375,74.6097412109375,74.6097412109375,74.6097412109375,94.5454788208008,94.5454788208008,94.5454788208008,94.5454788208008,94.5454788208008,125.7001953125,125.7001953125,145.837417602539,145.837417602539,145.837417602539,145.837417602539,145.837417602539,145.837417602539,55.851676940918,55.851676940918,55.851676940918,55.851676940918,55.851676940918,76.1165237426758,76.1165237426758,76.1165237426758,107.271728515625,107.271728515625,126.492149353027,126.492149353027,126.492149353027,146.296096801758,146.296096801758,146.296096801758,54.9361267089844,54.9361267089844,86.0178451538086,86.0178451538086,86.0178451538086,86.0178451538086,106.081314086914,106.081314086914,137.227920532227,137.227920532227,146.27685546875,146.27685546875,146.27685546875,65.3641586303711,65.3641586303711,85.4295043945312,85.4295043945312,85.4295043945312,85.4295043945312,85.4295043945312,115.001327514648,115.001327514648,135.001708984375,135.001708984375,44.3810653686523,44.3810653686523,64.4450073242188,64.4450073242188,95.0022125244141,95.0022125244141,115.327964782715,115.327964782715,146.27978515625,146.27978515625,146.27978515625,146.27978515625,45.5621337890625,45.5621337890625,75.6628875732422,75.6628875732422,75.6628875732422,75.6628875732422,75.6628875732422,95.923942565918,95.923942565918,95.923942565918,95.923942565918,95.923942565918,126.811393737793,126.811393737793,146.287010192871,146.287010192871,146.287010192871,56.9722213745117,56.9722213745117,76.9724349975586,76.9724349975586,107.068084716797,107.068084716797,127.13272857666,127.13272857666,146.278289794922,146.278289794922,146.278289794922,58.2205352783203,58.2205352783203,89.5629119873047,89.5629119873047,89.5629119873047,89.5629119873047,89.5629119873047,109.561225891113,109.561225891113,138.084396362305,138.084396362305,146.281181335449,146.281181335449,146.281181335449,66.6790237426758,66.6790237426758,86.7434310913086,86.7434310913086,114.874229431152,114.874229431152,114.874229431152,114.874229431152,114.874229431152,114.874229431152,135.069465637207,135.069465637207,135.069465637207,135.069465637207,45.696418762207,45.696418762207,65.5637588500977,65.5637588500977,65.5637588500977,65.5637588500977,65.5637588500977,96.6449966430664,96.6449966430664,116.906288146973,116.906288146973,116.906288146973,116.906288146973,116.906288146973,146.279968261719,146.279968261719,146.279968261719,47.7298736572266,47.7298736572266,47.7298736572266,78.0847244262695,78.0847244262695,78.0847244262695,78.0847244262695,78.0847244262695,78.0847244262695,98.4740219116211,98.4740219116211,129.680885314941,129.680885314941,146.267921447754,146.267921447754,146.267921447754,60.7119674682617,60.7119674682617,60.7119674682617,60.7119674682617,80.5772552490234,80.5772552490234,80.5772552490234,110.669471740723,110.669471740723,110.669471740723,110.669471740723,110.669471740723,128.37149810791,128.37149810791,146.269660949707,146.269660949707,146.269660949707,56.5820465087891,56.5820465087891,88.3800277709961,88.3800277709961,109.818725585938,109.818725585938,141.944160461426,141.944160461426,141.944160461426,141.944160461426,47.7321472167969,47.7321472167969,47.7321472167969,47.7321472167969,77.4969940185547,77.4969940185547,77.4969940185547,77.4969940185547,77.4969940185547,97.9519195556641,97.9519195556641,97.9519195556641,97.9519195556641,97.9519195556641,127.717498779297,127.717498779297,146.270751953125,146.270751953125,146.270751953125,63.6638412475586,63.6638412475586,63.6638412475586,63.6638412475586,63.6638412475586,63.6638412475586,84.7084426879883,84.7084426879883,84.7084426879883,84.7084426879883,115.783973693848,115.783973693848,136.828582763672,136.828582763672,136.828582763672,136.828582763672,136.828582763672,136.828582763672,53.6339721679688,53.6339721679688,74.0881805419922,74.0881805419922,74.0881805419922,106.016304016113,106.016304016113,127.519630432129,127.519630432129,42.9274673461914,42.9274673461914,62.5957641601562,62.5957641601562,62.5957641601562,62.5957641601562,94.3266448974609,94.3266448974609,115.305671691895,115.305671691895,115.305671691895,146.31583404541,146.31583404541,146.31583404541,52.2375946044922,52.2375946044922,82.7888641357422,82.7888641357422,103.374687194824,103.374687194824,103.374687194824,103.374687194824,103.374687194824,112.657531738281,112.657531738281,112.657531738281,112.657531738281,112.657531738281,112.657531738281],"meminc":[0,0,20.988166809082,0,25.7164840698242,0,16.2030181884766,0,21.6455078125,0,0,-94.1927642822266,0,31.4278259277344,0,0,19.9446563720703,0,29.9086990356445,0,12.9228668212891,0,0,-78.9186859130859,0,21.2544326782227,0,29.8558578491211,0,19.8155364990234,0,-86.4082336425781,0,0,20.137580871582,0,0,0,30.4992980957031,0,19.6771087646484,0,24.0747222900391,0,0,-90.3134613037109,0,0,31.4892425537109,0,0,20.9912109375,0,32.0102157592773,0,-96.6287689208984,0,0,0,0,0,31.0954208374023,0,20.8603591918945,0,31.9506912231445,0,0,18.5649337768555,0,0,-83.705451965332,0,0,20.9872131347656,0,30.0509033203125,0,19.7487945556641,0,0,0,0,-87.1220932006836,0,19.9437026977539,0,29.8571929931641,0,19.5494232177734,0,0,29.6531677246094,0,-96.8356475830078,0,30.9685287475586,0,0,0,20.3446426391602,0,0,0,0,29.9157409667969,0,0,0,0,16.6597671508789,0,0,-83.4469909667969,0,0,0,0,21.3152542114258,0,31.9513626098633,0,21.1245803833008,0,-85.3520431518555,0,0,20.8594741821289,0,31.097785949707,0,0,0,0,20.0075759887695,0,0,22.4396514892578,0,0,-88.8918151855469,0,31.618408203125,0,20.3987121582031,0,0,30.1038131713867,0,-15.1651611328125,0,0,-51.0031509399414,0,0,0,0,21.31201171875,0,30.0504684448242,0,19.2871322631836,0,-85.3564376831055,0,0,20.5340576171875,0,0,30.1879806518555,0,0,0,0,20.1404647827148,0,0,16.7921142578125,0,0,-84.5633850097656,0,0,31.2301254272461,0,20.9895172119141,0,31.2899017333984,0,0,-95.9753646850586,0,30.8395843505859,0,0,0,0,20.6010513305664,0,29.7153854370117,0,15.875862121582,0,0,-83.5871124267578,0,18.3658294677734,0,0,0,0,29.7221908569336,0,20.133903503418,0,15.3491668701172,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,0,0,0,26.9000244140625,0,19.4186019897461,0,31.0904541015625,0,0,19.5547866821289,0,0,0,0,-90.270263671875,0,0,0,19.7476577758789,0,0,0,0,29.7786331176758,0,18.7641372680664,0,0,0,0,28.5354690551758,0,-100.236175537109,0,0,0,29.9123458862305,0,0,0,20.2734756469727,0,28.7296142578125,0,18.8222045898438,0,-90.1942749023438,0,20.0111465454102,0,30.8970184326172,0,20.5305862426758,0,0,21.3219757080078,0,0,-91.3790512084961,0,0,0,0,30.0400848388672,0,0,0,0,20.0687713623047,30.179557800293,0,11.0869445800781,0,0,0,0,0,-81.3370208740234,0,20.2017822265625,0,29.3904113769531,0,18.3687515258789,0,0,0,0,-69.0224609375,0,0,-1.56432342529297,0,0,29.9762191772461,0,0,20.4653472900391,0,0,31.1539306640625,0,-99.6984786987305,29.9089965820312,0,19.6185531616211,0,28.4104080200195,0,18.4985656738281,0,0,0,0,-90.2657775878906,0,0,19.7467193603516,0,28.6091003417969,0,0,19.7475662231445,0,27.7476501464844,0,0,0,0,0,-96.9006042480469,0,0,29.9170532226562,0,0,0,0,19.8074417114258,0,0,0,30.7695083618164,0,16.3996353149414,0,0,-86.3948822021484,0,0,19.9457473754883,0,30.3767242431641,0,19.9489898681641,0,0,0,16.1389846801758,0,0,-85.4861907958984,0,0,0,0,0,29.3886184692383,0,19.6157302856445,0,0,28.3427200317383,0,0,8.13677215576172,0,0,0,0,0,-78.5313568115234,0,19.8151168823242,0,0,0,0,31.217529296875,0,0,0,0,19.8172225952148,0,-90.722770690918,0,0,0,17.9108581542969,0,29.1255416870117,0,0,19.0912933349609,0,0,28.1459503173828,0,0,-31.8658752441406,0,0,-38.012825012207,0,19.9414215087891,0,30.7653350830078,0,0,20.4657363891602,0,0,-89.4054946899414,0,0,0,0,19.8774871826172,0,29.980598449707,0,0,18.8929977416992,0,0,23.4825820922852,0,0,-93.7374267578125,0,28.7445983886719,0,0,0,0,19.6818771362305,0,0,0,0,28.338752746582,0,0,0,0,16.9888534545898,0,0,-88.5736236572266,0,19.0185852050781,0,30.1037368774414,0,0,18.8915481567383,0,0,20.5321578979492,0,0,-91.3681106567383,0,0,28.9877090454102,0,19.9429016113281,0,28.5972442626953,0,13.8421783447266,0,0,-83.0334091186523,0,20.0707092285156,0,0,31.0214080810547,0,20.3998565673828,0,0,-89.1379699707031,0,19.8739166259766,0,30.5641937255859,0,0,19.8739166259766,0,30.2356262207031,0,0,0,0,-101.689910888672,0,0,29.8431777954102,0,0,0,19.2796325683594,0,0,0,0,28.5920867919922,0,20.1343612670898,0,-90.3720550537109,0,0,0,0,20.1365737915039,0,30.5000762939453,0,20.5925064086914,0,0,23.1491775512695,0,0,-93.1974563598633,0,0,30.0392990112305,0,0,19.7419662475586,0,0,0,0,30.5649337768555,0,0,12.8548126220703,0,0,0,0,0,-83.2314834594727,0,19.7418212890625,0,31.1542510986328,0,20.2011413574219,0,0,0,0,-89.8525619506836,0,19.2164688110352,0,30.3005218505859,0,20.3319396972656,0,31.3500671386719,0,0,-101.001129150391,0,30.102424621582,0,0,0,0,19.9357376098633,0,0,0,0,31.1547164916992,0,20.1372222900391,0,0,0,0,0,-89.9857406616211,0,0,0,0,20.2648468017578,0,0,31.1552047729492,0,19.2204208374023,0,0,19.8039474487305,0,0,-91.3599700927734,0,31.0817184448242,0,0,0,20.0634689331055,0,31.1466064453125,0,9.04893493652344,0,0,-80.9126968383789,0,20.0653457641602,0,0,0,0,29.5718231201172,0,20.0003814697266,0,-90.6206436157227,0,20.0639419555664,0,30.5572052001953,0,20.3257522583008,0,30.9518203735352,0,0,0,-100.717651367188,0,30.1007537841797,0,0,0,0,20.2610549926758,0,0,0,0,30.887451171875,0,19.4756164550781,0,0,-89.3147888183594,0,20.0002136230469,0,30.0956497192383,0,20.0646438598633,0,19.1455612182617,0,0,-88.0577545166016,0,31.3423767089844,0,0,0,0,19.9983139038086,0,28.5231704711914,0,8.19678497314453,0,0,-79.6021575927734,0,20.0644073486328,0,28.1307983398438,0,0,0,0,0,20.1952362060547,0,0,0,-89.373046875,0,19.8673400878906,0,0,0,0,31.0812377929688,0,20.2612915039062,0,0,0,0,29.3736801147461,0,0,-98.5500946044922,0,0,30.354850769043,0,0,0,0,0,20.3892974853516,0,31.2068634033203,0,16.5870361328125,0,0,-85.5559539794922,0,0,0,19.8652877807617,0,0,30.0922164916992,0,0,0,0,17.7020263671875,0,17.8981628417969,0,0,-89.687614440918,0,31.797981262207,0,21.4386978149414,0,32.1254348754883,0,0,0,-94.2120132446289,0,0,0,29.7648468017578,0,0,0,0,20.4549255371094,0,0,0,0,29.7655792236328,0,18.5532531738281,0,0,-82.6069107055664,0,0,0,0,0,21.0446014404297,0,0,0,31.0755310058594,0,21.0446090698242,0,0,0,0,0,-83.1946105957031,0,20.4542083740234,0,0,31.9281234741211,0,21.5033264160156,0,-84.5921630859375,0,19.6682968139648,0,0,0,31.7308807373047,0,20.9790267944336,0,0,31.0101623535156,0,0,-94.078239440918,0,30.55126953125,0,20.585823059082,0,0,0,0,9.28284454345703,0,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmp1uls52/file35f138c4af79.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    788.247    798.587    817.8927    807.9065
#>    compute_pi0(m * 10)   7918.387   7964.655   8341.9566   8007.2805
#>   compute_pi0(m * 100)  79003.672  79245.818  80908.6312  79861.6740
#>         compute_pi1(m)    156.277    197.732    254.3088    261.5820
#>    compute_pi1(m * 10)   1309.408   1376.601   2385.8232   1446.8565
#>   compute_pi1(m * 100)  12953.737  13628.819  30315.0040  14846.9420
#>  compute_pi1(m * 1000) 259790.670 310987.196 387690.0835 381751.1955
#>           uq        max neval
#>     815.3950    911.765    20
#>    8074.9370  14304.764    20
#>   80438.4680  91169.110    20
#>     295.7405    362.603    20
#>    1601.1535  11768.075    20
#>   21227.3600 179830.547    20
#>  477505.1615 523487.589    20
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
#>   memory_copy1(n) 5533.89027 4187.80697 661.79847 4235.87230 3977.43479
#>   memory_copy2(n)   91.73169   69.98839  12.33253   68.93018   65.85726
#>  pre_allocate1(n)   20.80490   15.71616   3.93598   14.38561   13.97981
#>  pre_allocate2(n)  204.32426  152.33686  24.22013  141.44448  134.81881
#>     vectorized(n)    1.00000    1.00000   1.00000    1.00000    1.00000
#>        max neval
#>  82.076180    10
#>   2.938427    10
#>   2.135944    10
#>   4.390453    10
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
#>  f1(df) 246.2817 253.1381 94.81079 317.0177 86.24201 38.2157     5
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
