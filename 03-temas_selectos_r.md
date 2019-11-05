
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
#>    id           a         b          c        d
#> 1   1  1.12462814 0.5244553  3.1964135 2.537077
#> 2   2  0.51041813 2.0871617  5.4592976 5.319290
#> 3   3  0.55192647 2.7749490  2.6418347 3.711375
#> 4   4  0.51057459 1.8758884  1.9299823 4.729157
#> 5   5  0.00655798 0.9239475 -0.1518199 4.260844
#> 6   6 -2.17117413 2.2385979  2.9728813 3.621392
#> 7   7  0.66928612 1.6818015  1.8272450 5.547661
#> 8   8 -0.98963864 2.1279063  1.7615819 2.445606
#> 9   9  0.76368735 0.2953890  3.2142940 3.201167
#> 10 10  1.08981436 3.9526162  2.1254850 3.710732
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.206608
mean(df$b)
#> [1] 1.848271
mean(df$c)
#> [1] 2.49772
mean(df$d)
#> [1] 3.90843
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.206608 1.848271 2.497720 3.908430
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
#> [1] 0.206608 1.848271 2.497720 3.908430
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
#> [1] 5.500000 0.206608 1.848271 2.497720 3.908430
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
#> [1] 5.5000000 0.5312505 1.9815251 2.3836598 3.7110534
col_describe(df, mean)
#> [1] 5.500000 0.206608 1.848271 2.497720 3.908430
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
#>       id        a        b        c        d 
#> 5.500000 0.206608 1.848271 2.497720 3.908430
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
#>   3.832   0.141   3.972
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.004   0.634
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
#>  14.120   1.032  10.744
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
#>   0.116   0.000   0.116
plyr_st
#>    user  system elapsed 
#>   4.083   0.000   4.084
est_l_st
#>    user  system elapsed 
#>  62.588   1.051  63.644
est_r_st
#>    user  system elapsed 
#>   0.392   0.004   0.396
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

<!--html_preserve--><div id="htmlwidget-c4eb97d0a9ee41bae17f" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-c4eb97d0a9ee41bae17f">{"x":{"message":{"prof":{"time":[1,1,2,2,2,3,3,3,4,4,4,4,4,4,5,5,5,6,6,6,6,7,7,8,8,9,9,9,10,10,10,10,11,11,12,12,12,12,12,12,13,13,14,14,14,15,15,16,16,17,17,18,18,18,19,19,20,20,21,21,21,22,22,22,22,22,23,23,23,24,24,24,24,24,25,25,26,26,26,26,26,27,27,28,28,29,29,30,30,31,31,32,32,33,33,33,33,33,34,34,35,35,36,36,36,36,36,37,37,37,38,38,38,39,39,39,39,39,40,40,40,40,40,41,41,41,42,42,43,43,43,44,44,44,45,45,45,46,46,46,47,47,47,47,47,48,48,49,49,50,50,51,51,52,52,53,53,53,53,53,54,54,54,55,55,55,56,56,56,56,56,57,57,58,58,58,59,59,59,59,60,60,60,61,61,61,61,61,62,62,63,63,63,63,63,64,64,65,65,66,66,66,66,66,67,67,68,68,69,69,69,70,70,70,71,71,72,72,73,73,74,74,75,75,76,76,76,77,77,77,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,89,89,90,90,90,90,90,91,91,91,91,92,92,92,92,92,92,93,93,93,93,93,94,94,95,95,96,96,96,96,96,97,97,97,98,98,99,99,99,99,100,100,101,101,102,102,102,103,103,103,103,103,104,104,104,105,105,105,105,106,106,106,106,107,107,108,108,108,108,108,109,109,110,110,110,110,110,111,111,111,111,111,112,112,112,112,113,113,114,114,114,115,115,115,116,116,116,116,116,117,117,117,118,118,118,118,119,119,120,120,121,121,122,122,123,123,124,124,124,125,125,125,125,125,125,126,126,126,127,127,127,127,128,128,129,129,129,130,130,130,131,131,132,132,132,132,132,132,133,133,133,134,134,135,135,135,135,135,136,136,136,137,137,138,138,139,139,139,139,139,140,140,141,141,142,142,142,143,143,143,143,143,144,144,144,144,145,145,145,146,146,147,147,147,148,148,148,148,148,149,149,149,150,150,150,150,151,151,152,152,153,153,154,155,155,155,156,156,157,157,158,158,158,159,159,160,160,160,161,161,161,161,161,162,162,163,163,163,164,164,164,165,165,166,166,167,167,167,168,168,169,169,169,169,169,169,170,170,171,171,172,172,172,173,173,173,174,174,174,174,174,174,175,175,175,175,176,176,177,177,177,178,178,179,179,179,180,180,180,180,180,181,181,182,182,182,182,183,183,184,184,185,185,186,186,186,187,187,187,188,188,188,189,189,190,190,190,191,191,192,192,193,193,194,194,195,195,195,196,196,197,197,198,198,199,199,199,200,200,200,200,200,200,201,201,202,202,203,203,204,204,204,205,205,206,206,207,207,207,208,208,209,209,210,210,211,211,212,212,212,212,213,213,214,214,215,215,216,216,216,217,217,217,218,218,218,218,219,219,219,220,220,221,221,221,222,222,222,222,222,223,223,224,224,225,225,225,225,225,225,226,226,226,227,227,228,228,229,229,230,230,230,230,230,231,231,231,232,232,233,233,234,234,235,235,235,236,236,237,237,237,238,238,239,239,239,240,240,241,241,241,241,242,242,243,243,243,244,244,245,245,246,246,247,247,248,248,248,249,249,250,250,250,251,251,251,251,251,251,252,252,252,252,252,253,253,253,254,254,254,254,254,255,255,256,256,257,257,257,258,258,258,259,259,259,260,260,261,261,261,262,262,262,262,262,262,263,263,263,264,264,265,265,266,267,267,267,268,268,268,269,269,270,270,270,271,271,272,272,272,272,273,273,273,273,273,273,274,274,274,275,275,275,275,276,276,277,277,278,278,279,279,279,279,279,279,280,280,280,281,281,281,282,282,282,282,282],"depth":[2,1,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,1,3,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","names","names","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","names","names","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,null,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,null,null,1],"linenum":[9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,11,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,null,null,null,11,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,10,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,null,11,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,10,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,null,null,13],"memalloc":[64.1099700927734,64.1099700927734,85.5561447143555,85.5561447143555,85.5561447143555,112.783561706543,112.783561706543,112.783561706543,130.559501647949,130.559501647949,130.559501647949,130.559501647949,130.559501647949,130.559501647949,146.301490783691,146.301490783691,146.301490783691,62.7365951538086,62.7365951538086,62.7365951538086,62.7365951538086,94.095588684082,94.095588684082,113.910163879395,113.910163879395,143.362548828125,143.362548828125,143.362548828125,46.7294006347656,46.7294006347656,46.7294006347656,46.7294006347656,78.6100692749023,78.6100692749023,98.9501419067383,98.9501419067383,98.9501419067383,98.9501419067383,98.9501419067383,98.9501419067383,129.461845397949,129.461845397949,146.320732116699,146.320732116699,146.320732116699,63.0620574951172,63.0620574951172,83.9896392822266,83.9896392822266,114.748603820801,114.748603820801,134.359985351562,134.359985351562,134.359985351562,47.3896484375,47.3896484375,68.1879425048828,68.1879425048828,100.069412231445,100.069412231445,100.069412231445,121.521293640137,121.521293640137,121.521293640137,121.521293640137,121.521293640137,146.315383911133,146.315383911133,146.315383911133,56.3143844604492,56.3143844604492,56.3143844604492,56.3143844604492,56.3143844604492,88.1299362182617,88.1299362182617,109.119743347168,109.119743347168,109.119743347168,109.119743347168,109.119743347168,141.333435058594,141.333435058594,44.9655227661133,44.9655227661133,75.6016693115234,75.6016693115234,96.3352432250977,96.3352432250977,126.513137817383,126.513137817383,146.198448181152,146.198448181152,58.3487319946289,58.3487319946289,58.3487319946289,58.3487319946289,58.3487319946289,79.2815322875977,79.2815322875977,109.988609313965,109.988609313965,129.933418273926,129.933418273926,129.933418273926,129.933418273926,129.933418273926,49.2038955688477,49.2038955688477,49.2038955688477,64.0595092773438,64.0595092773438,64.0595092773438,95.5573959350586,95.5573959350586,95.5573959350586,95.5573959350586,95.5573959350586,115.501884460449,115.501884460449,115.501884460449,115.501884460449,115.501884460449,145.089859008789,145.089859008789,145.089859008789,48.6452331542969,48.6452331542969,79.9428634643555,79.9428634643555,79.9428634643555,100.671539306641,100.671539306641,100.671539306641,130.719833374023,130.719833374023,130.719833374023,146.333564758301,146.333564758301,146.333564758301,64.39013671875,64.39013671875,64.39013671875,64.39013671875,64.39013671875,85.3866806030273,85.3866806030273,115.691864013672,115.691864013672,135.179748535156,135.179748535156,48.7138824462891,48.7138824462891,69.6442108154297,69.6442108154297,101.453689575195,101.453689575195,101.453689575195,101.453689575195,101.453689575195,120.541542053223,120.541542053223,120.541542053223,146.322929382324,146.322929382324,146.322929382324,52.9188995361328,52.9188995361328,52.9188995361328,52.9188995361328,52.9188995361328,83.8207321166992,83.8207321166992,103.042610168457,103.042610168457,103.042610168457,132.891471862793,132.891471862793,132.891471862793,132.891471862793,146.27515411377,146.27515411377,146.27515411377,66.8878784179688,66.8878784179688,66.8878784179688,66.8878784179688,66.8878784179688,88.0103530883789,88.0103530883789,119.838882446289,119.838882446289,119.838882446289,119.838882446289,119.838882446289,140.69832611084,140.69832611084,55.2812805175781,55.2812805175781,75.8837738037109,75.8837738037109,75.8837738037109,75.8837738037109,75.8837738037109,107.046592712402,107.046592712402,126.789543151855,126.789543151855,146.271369934082,146.271369934082,146.271369934082,60.4659805297852,60.4659805297852,60.4659805297852,91.1756286621094,91.1756286621094,112.296119689941,112.296119689941,144.046226501465,144.046226501465,47.8074645996094,47.8074645996094,78.9585342407227,78.9585342407227,100.017929077148,100.017929077148,100.017929077148,131.83154296875,131.83154296875,131.83154296875,131.83154296875,131.83154296875,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,146.328025817871,42.7565383911133,42.7565383911133,42.7565383911133,56.4059448242188,56.4059448242188,56.4059448242188,56.4059448242188,56.4059448242188,77.0682525634766,77.0682525634766,77.0682525634766,77.0682525634766,77.0682525634766,108.48966217041,108.48966217041,108.48966217041,108.48966217041,129.7451171875,129.7451171875,129.7451171875,129.7451171875,129.7451171875,129.7451171875,44.5296325683594,44.5296325683594,44.5296325683594,44.5296325683594,44.5296325683594,65.3941879272461,65.3941879272461,96.8776092529297,96.8776092529297,116.822700500488,116.822700500488,116.822700500488,116.822700500488,116.822700500488,146.275482177734,146.275482177734,146.275482177734,52.2059326171875,52.2059326171875,83.5663681030273,83.5663681030273,83.5663681030273,83.5663681030273,104.428237915039,104.428237915039,134.331893920898,134.331893920898,146.270324707031,146.270324707031,146.270324707031,69.9868621826172,69.9868621826172,69.9868621826172,69.9868621826172,69.9868621826172,90.9138031005859,90.9138031005859,90.9138031005859,121.087646484375,121.087646484375,121.087646484375,121.087646484375,141.226676940918,141.226676940918,141.226676940918,141.226676940918,56.538932800293,56.538932800293,77.2018966674805,77.2018966674805,77.2018966674805,77.2018966674805,77.2018966674805,108.74845123291,108.74845123291,129.548919677734,129.548919677734,129.548919677734,129.548919677734,129.548919677734,45.3889312744141,45.3889312744141,45.3889312744141,45.3889312744141,45.3889312744141,66.1858596801758,66.1858596801758,66.1858596801758,66.1858596801758,97.7986526489258,97.7986526489258,119.055442810059,119.055442810059,119.055442810059,146.280601501465,146.280601501465,146.280601501465,55.6213760375977,55.6213760375977,55.6213760375977,55.6213760375977,55.6213760375977,86.7813415527344,86.7813415527344,86.7813415527344,107.507202148438,107.507202148438,107.507202148438,107.507202148438,137.810554504395,137.810554504395,43.2267990112305,43.2267990112305,74.7748260498047,74.7748260498047,95.5095748901367,95.5095748901367,127.723533630371,127.723533630371,146.290451049805,146.290451049805,146.290451049805,64.6846389770508,64.6846389770508,64.6846389770508,64.6846389770508,64.6846389770508,64.6846389770508,85.3525924682617,85.3525924682617,85.3525924682617,117.300392150879,117.300392150879,117.300392150879,117.300392150879,138.555488586426,138.555488586426,53.2663955688477,53.2663955688477,53.2663955688477,73.7351531982422,73.7351531982422,73.7351531982422,104.632453918457,104.632453918457,124.37678527832,124.37678527832,124.37678527832,124.37678527832,124.37678527832,124.37678527832,146.290550231934,146.290550231934,146.290550231934,59.2358093261719,59.2358093261719,90.7970886230469,90.7970886230469,90.7970886230469,90.7970886230469,90.7970886230469,111.397636413574,111.397636413574,111.397636413574,141.450630187988,141.450630187988,46.9726028442383,46.9726028442383,77.747444152832,77.747444152832,77.747444152832,77.747444152832,77.747444152832,98.9301223754883,98.9301223754883,129.304649353027,129.304649353027,146.300727844238,146.300727844238,146.300727844238,64.7527008056641,64.7527008056641,64.7527008056641,64.7527008056641,64.7527008056641,85.7504501342773,85.7504501342773,85.7504501342773,85.7504501342773,118.017951965332,118.017951965332,118.017951965332,138.883590698242,138.883590698242,54.6562423706055,54.6562423706055,54.6562423706055,75.4524612426758,75.4524612426758,75.4524612426758,75.4524612426758,75.4524612426758,106.61157989502,106.61157989502,106.61157989502,127.279846191406,127.279846191406,127.279846191406,127.279846191406,43.7625732421875,43.7625732421875,64.2258911132812,64.2258911132812,96.1017608642578,96.1017608642578,117.291084289551,146.284652709961,146.284652709961,146.284652709961,55.0427703857422,55.0427703857422,86.7958450317383,86.7958450317383,107.721221923828,107.721221923828,107.721221923828,139.667869567871,139.667869567871,45.4707412719727,45.4707412719727,45.4707412719727,76.3783111572266,76.3783111572266,76.3783111572266,76.3783111572266,76.3783111572266,97.5702438354492,97.5702438354492,129.648147583008,129.648147583008,129.648147583008,146.308891296387,146.308891296387,146.308891296387,66.9858474731445,66.9858474731445,88.2330780029297,88.2330780029297,120.109420776367,120.109420776367,120.109420776367,141.232528686523,141.232528686523,57.5393524169922,57.5393524169922,57.5393524169922,57.5393524169922,57.5393524169922,57.5393524169922,78.1319122314453,78.1319122314453,110.01049041748,110.01049041748,131.132263183594,131.132263183594,131.132263183594,47.7727737426758,47.7727737426758,47.7727737426758,68.5656814575195,68.5656814575195,68.5656814575195,68.5656814575195,68.5656814575195,68.5656814575195,100.375854492188,100.375854492188,100.375854492188,100.375854492188,120.969398498535,120.969398498535,146.287857055664,146.287857055664,146.287857055664,58.5944747924805,58.5944747924805,90.4040756225586,90.4040756225586,90.4040756225586,111.198348999023,111.198348999023,111.198348999023,111.198348999023,111.198348999023,143.466529846191,143.466529846191,47.5450897216797,47.5450897216797,47.5450897216797,47.5450897216797,77.9773635864258,77.9773635864258,97.8476715087891,97.8476715087891,128.276542663574,128.276542663574,146.313171386719,146.313171386719,146.313171386719,61.2535705566406,61.2535705566406,61.2535705566406,81.720817565918,81.720817565918,81.720817565918,112.871810913086,112.871810913086,133.661636352539,133.661636352539,133.661636352539,48.136589050293,48.136589050293,69.1899642944336,69.1899642944336,100.80216217041,100.80216217041,121.658180236816,121.658180236816,146.321746826172,146.321746826172,146.321746826172,57.9102554321289,57.9102554321289,89.5886764526367,89.5886764526367,110.970703125,110.970703125,142.516052246094,142.516052246094,142.516052246094,47.1561889648438,47.1561889648438,47.1561889648438,47.1561889648438,47.1561889648438,47.1561889648438,79.0296325683594,79.0296325683594,100.410293579102,100.410293579102,131.302444458008,131.302444458008,146.321586608887,146.321586608887,146.321586608887,66.6988906860352,66.6988906860352,88.1447296142578,88.1447296142578,120.149444580078,120.149444580078,120.149444580078,141.33740234375,141.33740234375,56.5339660644531,56.5339660644531,77.5204010009766,77.5204010009766,109.397560119629,109.397560119629,130.519706726074,130.519706726074,130.519706726074,130.519706726074,46.3059387207031,46.3059387207031,67.0922698974609,67.0922698974609,99.4840698242188,99.4840698242188,120.533851623535,120.533851623535,120.533851623535,146.301620483398,146.301620483398,146.301620483398,57.9152145385742,57.9152145385742,57.9152145385742,57.9152145385742,89.7180252075195,89.7180252075195,89.7180252075195,111.355117797852,111.355117797852,142.96134185791,142.96134185791,142.96134185791,48.2081985473633,48.2081985473633,48.2081985473633,48.2081985473633,48.2081985473633,80.3377838134766,80.3377838134766,101.45191192627,101.45191192627,133.779037475586,133.779037475586,133.779037475586,133.779037475586,133.779037475586,133.779037475586,146.30379486084,146.30379486084,146.30379486084,70.4412078857422,70.4412078857422,91.4899368286133,91.4899368286133,122.967247009277,122.967247009277,143.754219055176,143.754219055176,143.754219055176,143.754219055176,143.754219055176,59.3584442138672,59.3584442138672,59.3584442138672,79.7516403198242,79.7516403198242,110.830863952637,110.830863952637,131.025901794434,131.025901794434,47.8830184936523,47.8830184936523,47.8830184936523,68.8667449951172,68.8667449951172,99.8159408569336,99.8159408569336,99.8159408569336,120.732368469238,120.732368469238,146.304794311523,146.304794311523,146.304794311523,57.9167404174805,57.9167404174805,89.9152908325195,89.9152908325195,89.9152908325195,89.9152908325195,111.226448059082,111.226448059082,143.486755371094,143.486755371094,143.486755371094,48.4092025756836,48.4092025756836,79.6864776611328,79.6864776611328,100.735244750977,100.735244750977,133.06103515625,133.06103515625,146.304840087891,146.304840087891,146.304840087891,68.6019287109375,68.6019287109375,89.3850860595703,89.3850860595703,89.3850860595703,120.788154602051,120.788154602051,120.788154602051,120.788154602051,120.788154602051,120.788154602051,141.702735900879,141.702735900879,141.702735900879,141.702735900879,141.702735900879,57.7201309204102,57.7201309204102,57.7201309204102,78.7653884887695,78.7653884887695,78.7653884887695,78.7653884887695,78.7653884887695,111.020721435547,111.020721435547,132.263717651367,132.263717651367,48.1486587524414,48.1486587524414,48.1486587524414,68.6046447753906,68.6046447753906,68.6046447753906,100.074043273926,100.074043273926,100.074043273926,121.31616973877,121.31616973877,146.294937133789,146.294937133789,146.294937133789,58.7047500610352,58.7047500610352,58.7047500610352,58.7047500610352,58.7047500610352,58.7047500610352,90.5674362182617,90.5674362182617,90.5674362182617,111.874946594238,111.874946594238,143.868812561035,143.868812561035,49.5919647216797,81.1268005371094,81.1268005371094,81.1268005371094,101.581527709961,101.581527709961,101.581527709961,133.24698638916,133.24698638916,146.293426513672,146.293426513672,146.293426513672,70.3755416870117,70.3755416870117,90.8959197998047,90.8959197998047,90.8959197998047,90.8959197998047,122.889030456543,122.889030456543,122.889030456543,122.889030456543,122.889030456543,122.889030456543,142.097984313965,142.097984313965,142.097984313965,56.2617492675781,56.2617492675781,56.2617492675781,56.2617492675781,77.1757965087891,77.1757965087891,109.75870513916,109.75870513916,130.476135253906,130.476135253906,46.2975387573242,46.2975387573242,46.2975387573242,46.2975387573242,46.2975387573242,46.2975387573242,67.2109680175781,67.2109680175781,67.2109680175781,99.2045516967773,99.2045516967773,99.2045516967773,113.393249511719,113.393249511719,113.393249511719,113.393249511719,113.393249511719],"meminc":[0,0,21.446174621582,0,0,27.2274169921875,0,0,17.7759399414062,0,0,0,0,0,15.7419891357422,0,0,-83.5648956298828,0,0,0,31.3589935302734,0,19.8145751953125,0,29.4523849487305,0,0,-96.6331481933594,0,0,0,31.8806686401367,0,20.3400726318359,0,0,0,0,0,30.5117034912109,0,16.85888671875,0,0,-83.258674621582,0,20.9275817871094,0,30.7589645385742,0,19.6113815307617,0,0,-86.9703369140625,0,20.7982940673828,0,31.8814697265625,0,0,21.4518814086914,0,0,0,0,24.7940902709961,0,0,-90.0009994506836,0,0,0,0,31.8155517578125,0,20.9898071289062,0,0,0,0,32.2136917114258,0,-96.3679122924805,0,30.6361465454102,0,20.7335739135742,0,30.1778945922852,0,19.6853103637695,0,-87.8497161865234,0,0,0,0,20.9328002929688,0,30.7070770263672,0,19.9448089599609,0,0,0,0,-80.7295227050781,0,0,14.8556137084961,0,0,31.4978866577148,0,0,0,0,19.9444885253906,0,0,0,0,29.5879745483398,0,0,-96.4446258544922,0,31.2976303100586,0,0,20.7286758422852,0,0,30.0482940673828,0,0,15.6137313842773,0,0,-81.9434280395508,0,0,0,0,20.9965438842773,0,30.3051834106445,0,19.4878845214844,0,-86.4658660888672,0,20.9303283691406,0,31.8094787597656,0,0,0,0,19.0878524780273,0,0,25.7813873291016,0,0,-93.4040298461914,0,0,0,0,30.9018325805664,0,19.2218780517578,0,0,29.8488616943359,0,0,0,13.3836822509766,0,0,-79.3872756958008,0,0,0,0,21.1224746704102,0,31.8285293579102,0,0,0,0,20.8594436645508,0,-85.4170455932617,0,20.6024932861328,0,0,0,0,31.1628189086914,0,19.7429504394531,0,19.4818267822266,0,0,-85.8053894042969,0,0,30.7096481323242,0,21.120491027832,0,31.7501068115234,0,-96.2387619018555,0,31.1510696411133,0,21.0593948364258,0,0,31.8136138916016,0,0,0,0,14.4964828491211,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,13.6494064331055,0,0,0,0,20.6623077392578,0,0,0,0,31.4214096069336,0,0,0,21.2554550170898,0,0,0,0,0,-85.2154846191406,0,0,0,0,20.8645553588867,0,31.4834213256836,0,19.9450912475586,0,0,0,0,29.4527816772461,0,0,-94.0695495605469,0,31.3604354858398,0,0,0,20.8618698120117,0,29.9036560058594,0,11.9384307861328,0,0,-76.2834625244141,0,0,0,0,20.9269409179688,0,0,30.1738433837891,0,0,0,20.139030456543,0,0,0,-84.687744140625,0,20.6629638671875,0,0,0,0,31.5465545654297,0,20.8004684448242,0,0,0,0,-84.1599884033203,0,0,0,0,20.7969284057617,0,0,0,31.61279296875,0,21.2567901611328,0,0,27.2251586914062,0,0,-90.6592254638672,0,0,0,0,31.1599655151367,0,0,20.7258605957031,0,0,0,30.303352355957,0,-94.5837554931641,0,31.5480270385742,0,20.734748840332,0,32.2139587402344,0,18.5669174194336,0,0,-81.6058120727539,0,0,0,0,0,20.6679534912109,0,0,31.9477996826172,0,0,0,21.2550964355469,0,-85.2890930175781,0,0,20.4687576293945,0,0,30.8973007202148,0,19.7443313598633,0,0,0,0,0,21.9137649536133,0,0,-87.0547409057617,0,31.561279296875,0,0,0,0,20.6005477905273,0,0,30.0529937744141,0,-94.47802734375,0,30.7748413085938,0,0,0,0,21.1826782226562,0,30.3745269775391,0,16.9960784912109,0,0,-81.5480270385742,0,0,0,0,20.9977493286133,0,0,0,32.2675018310547,0,0,20.8656387329102,0,-84.2273483276367,0,0,20.7962188720703,0,0,0,0,31.1591186523438,0,0,20.6682662963867,0,0,0,-83.5172729492188,0,20.4633178710938,0,31.8758697509766,0,21.189323425293,28.9935684204102,0,0,-91.2418823242188,0,31.7530746459961,0,20.9253768920898,0,0,31.946647644043,0,-94.1971282958984,0,0,30.9075698852539,0,0,0,0,21.1919326782227,0,32.0779037475586,0,0,16.6607437133789,0,0,-79.3230438232422,0,21.2472305297852,0,31.8763427734375,0,0,21.1231079101562,0,-83.6931762695312,0,0,0,0,0,20.5925598144531,0,31.8785781860352,0,21.1217727661133,0,0,-83.359489440918,0,0,20.7929077148438,0,0,0,0,0,31.810173034668,0,0,0,20.5935440063477,0,25.3184585571289,0,0,-87.6933822631836,0,31.8096008300781,0,0,20.7942733764648,0,0,0,0,32.268180847168,0,-95.9214401245117,0,0,0,30.4322738647461,0,19.8703079223633,0,30.4288711547852,0,18.0366287231445,0,0,-85.0596008300781,0,0,20.4672470092773,0,0,31.150993347168,0,20.7898254394531,0,0,-85.5250473022461,0,21.0533752441406,0,31.6121978759766,0,20.8560180664062,0,24.6635665893555,0,0,-88.411491394043,0,31.6784210205078,0,21.3820266723633,0,31.5453491210938,0,0,-95.35986328125,0,0,0,0,0,31.8734436035156,0,21.3806610107422,0,30.8921508789062,0,15.0191421508789,0,0,-79.6226959228516,0,21.4458389282227,0,32.0047149658203,0,0,21.1879577636719,0,-84.8034362792969,0,20.9864349365234,0,31.8771591186523,0,21.1221466064453,0,0,0,-84.2137680053711,0,20.7863311767578,0,32.3917999267578,0,21.0497817993164,0,0,25.7677688598633,0,0,-88.3864059448242,0,0,0,31.8028106689453,0,0,21.637092590332,0,31.6062240600586,0,0,-94.7531433105469,0,0,0,0,32.1295852661133,0,21.114128112793,0,32.3271255493164,0,0,0,0,0,12.5247573852539,0,0,-75.8625869750977,0,21.0487289428711,0,31.4773101806641,0,20.7869720458984,0,0,0,0,-84.3957748413086,0,0,20.393196105957,0,31.0792236328125,0,20.1950378417969,0,-83.1428833007812,0,0,20.9837265014648,0,30.9491958618164,0,0,20.9164276123047,0,25.5724258422852,0,0,-88.388053894043,0,31.9985504150391,0,0,0,21.3111572265625,0,32.2603073120117,0,0,-95.0775527954102,0,31.2772750854492,0,21.0487670898438,0,32.3257904052734,0,13.2438049316406,0,0,-77.7029113769531,0,20.7831573486328,0,0,31.4030685424805,0,0,0,0,0,20.9145812988281,0,0,0,0,-83.9826049804688,0,0,21.0452575683594,0,0,0,0,32.2553329467773,0,21.2429962158203,0,-84.1150588989258,0,0,20.4559860229492,0,0,31.4693984985352,0,0,21.2421264648438,0,24.9787673950195,0,0,-87.5901870727539,0,0,0,0,0,31.8626861572266,0,0,21.3075103759766,0,31.9938659667969,0,-94.2768478393555,31.5348358154297,0,0,20.4547271728516,0,0,31.6654586791992,0,13.0464401245117,0,0,-75.9178848266602,0,20.520378112793,0,0,0,31.9931106567383,0,0,0,0,0,19.2089538574219,0,0,-85.8362350463867,0,0,0,20.9140472412109,0,32.5829086303711,0,20.7174301147461,0,-84.178596496582,0,0,0,0,0,20.9134292602539,0,0,31.9935836791992,0,0,14.1886978149414,0,0,0,0],"filename":["<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpVESXbr/file3cb35b91dfac.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    783.005    791.2315    805.1403    803.0895
#>    compute_pi0(m * 10)   7873.038   7892.4225   7938.3135   7904.3590
#>   compute_pi0(m * 100)  78709.760  78890.2560  79545.1267  79079.5390
#>         compute_pi1(m)    159.630    264.0945    839.9162    281.1125
#>    compute_pi1(m * 10)   1282.760   1332.4615   1377.8805   1379.9470
#>   compute_pi1(m * 100)  12887.292  17231.2630  20551.8877  20487.4665
#>  compute_pi1(m * 1000) 261205.535 272016.7400 346741.8038 367497.7650
#>           uq        max neval
#>     815.9805    835.016    20
#>    7935.1835   8255.618    20
#>   79362.7835  85569.088    20
#>     291.6945  11801.317    20
#>    1400.2535   1494.591    20
#>   25092.9990  30549.464    20
#>  376038.9895 492744.754    20
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
#>   memory_copy1(n) 5324.52552 5369.12835 597.495845 4011.19608 3450.05292
#>   memory_copy2(n)   94.78324   95.18808  11.485409   70.82083   62.86005
#>  pre_allocate1(n)   20.38688   19.68626   3.529003   14.97370   13.03894
#>  pre_allocate2(n)  201.18823  197.01882  22.478802  147.96907  135.69519
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  91.366674    10
#>   2.890219    10
#>   1.877487    10
#>   4.052813    10
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
#>  f1(df) 241.0672 238.5277 84.57432 210.4362 66.80845 39.46579     5
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
