
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
#>    id          a         b        c        d
#> 1   1 -0.7910102 2.2140607 3.418628 2.703922
#> 2   2 -1.2390330 2.6822309 3.213495 3.608193
#> 3   3 -0.1291712 1.2541498 2.849352 3.113470
#> 4   4 -1.3126131 3.1126705 2.617320 4.604755
#> 5   5  0.4263267 0.5144562 3.589364 2.448296
#> 6   6  0.8809382 2.9505783 4.006788 4.774161
#> 7   7 -1.8904673 1.4877835 2.434106 4.695589
#> 8   8  0.1221124 1.5821164 2.828738 5.441402
#> 9   9 -0.1095678 1.7294388 1.795481 4.840987
#> 10 10  0.4016698 0.7717598 2.509029 3.054320
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.3640815
mean(df$b)
#> [1] 1.829924
mean(df$c)
#> [1] 2.92623
mean(df$d)
#> [1] 3.928509
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.3640815  1.8299245  2.9262301  3.9285095
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
#> [1] -0.3640815  1.8299245  2.9262301  3.9285095
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
#> [1]  5.5000000 -0.3640815  1.8299245  2.9262301  3.9285095
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
#> [1]  5.5000000 -0.1193695  1.6557776  2.8390455  4.1064739
col_describe(df, mean)
#> [1]  5.5000000 -0.3640815  1.8299245  2.9262301  3.9285095
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
#>  5.5000000 -0.3640815  1.8299245  2.9262301  3.9285095
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
#>   4.048   0.160   4.210
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.020   0.004   1.838
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
#>  14.302   1.101  10.985
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
#>   0.118   0.000   0.117
plyr_st
#>    user  system elapsed 
#>   4.373   0.003   4.376
est_l_st
#>    user  system elapsed 
#>  69.561   1.420  70.988
est_r_st
#>    user  system elapsed 
#>   0.399   0.016   0.416
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

<!--html_preserve--><div id="htmlwidget-4fe4061db2966a8838a2" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-4fe4061db2966a8838a2">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,4,4,5,5,6,6,6,7,7,7,7,8,8,9,9,10,10,10,11,11,11,12,12,12,13,13,14,14,15,15,16,16,16,17,17,18,18,19,19,19,19,19,20,20,20,21,21,21,22,22,22,22,22,23,23,24,24,24,25,25,26,26,26,27,27,27,28,28,28,28,29,29,29,30,30,31,31,31,32,32,32,32,32,33,33,33,33,33,34,34,35,35,36,36,36,36,36,36,37,37,37,38,38,39,39,40,40,41,41,41,42,42,42,42,42,43,43,43,43,44,44,44,44,45,45,45,46,46,46,47,47,48,48,48,49,49,50,50,50,50,50,51,51,51,52,52,52,53,53,54,54,54,55,55,56,56,56,57,57,58,58,59,59,60,60,61,61,61,62,62,62,62,62,63,63,63,64,64,65,65,66,66,66,67,67,68,68,69,69,70,70,70,70,70,71,71,71,71,71,72,72,72,73,73,74,74,75,75,76,76,77,77,77,77,77,78,78,79,79,80,80,80,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,94,94,94,95,95,95,96,96,96,97,97,97,98,98,98,99,99,99,100,100,100,101,101,101,102,102,102,103,103,104,104,104,105,105,106,106,106,107,107,108,108,108,109,109,110,110,111,111,112,112,112,113,113,113,113,114,114,115,115,116,116,116,116,116,117,117,118,118,118,118,118,119,119,119,119,119,119,120,120,121,121,121,121,121,121,122,122,123,123,124,124,125,125,126,126,126,127,127,127,128,128,129,129,129,129,129,130,130,130,130,130,130,131,131,131,132,132,132,132,132,133,133,133,134,134,135,135,136,136,137,137,138,138,139,139,140,140,140,140,140,141,141,141,141,141,142,142,142,143,143,143,144,144,144,144,145,145,146,146,146,146,146,147,147,147,148,148,148,149,149,149,150,150,150,150,150,150,151,151,151,151,152,152,152,153,153,154,154,155,155,155,155,155,156,156,157,157,157,158,158,158,159,159,159,160,160,161,161,161,161,162,162,163,163,164,164,165,165,165,165,165,166,166,167,167,167,167,168,168,168,168,168,168,169,169,169,169,169,170,170,171,171,172,172,172,173,173,173,173,173,174,174,175,175,175,175,175,176,176,176,177,177,177,178,178,179,179,180,180,180,181,181,181,182,182,182,183,183,184,184,185,185,185,186,186,186,186,186,186,187,187,187,188,188,189,189,190,190,191,191,192,192,193,193,193,194,194,194,195,195,195,196,196,196,196,196,197,197,198,198,198,199,199,199,200,200,200,201,201,201,202,202,202,203,203,204,204,205,205,205,205,205,206,206,206,207,207,208,208,209,209,210,210,211,211,211,212,212,213,213,214,214,215,215,216,216,216,217,217,218,218,218,219,219,220,220,221,221,222,222,222,222,222,223,223,224,224,224,224,224,225,225,225,226,226,226,227,227,227,227,228,228,228,229,229,230,230,230,231,231,231,231,231,232,232,233,233,233,233,233,234,234,235,235,235,236,236,237,237,237,238,238,239,239,240,240,240,240,240,240,241,241,241,242,242,243,243,244,244,244,244,244,245,245,245,246,246,247,247,248,248,249,249,250,250,250,250,250,250,251,251,251,251,251,251,252,252,252,252,252,253,253,254,254,254,254,255,255,256,256,257,257,257,258,258,259,259,259,260,260,261,261,261,261,262,262,263,263,263,263,264,264,264,264,265,265,265,266,266,267,267,268,268,268,268,269,269,269,270,270,271,271,272,272,273,273,273,273,273,274,274,274,275,275,275,276,276,277,277,278,278,279,279,280,280,281,281,282,282,283,283,283,283,283,283,284,284,285,285,286,286,287,287,287,288,288,288,289,289,290,290,290,290,291,291,292,292,292,293,293,293,293,293,293,294,294,295,295,296,296,296,296,296,297,297,298,298,298,299,299,299,300,300,300,301,301,302,302,303,303,303,303,303,304,304,304,305,305,306,306,307,307,307,308,308,309,309,310,310,311,311,312,312,312,312,312,312,313,313,314,314,315,315,316,316,316,316,316],"depth":[2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","dim.data.frame","dim","dim","nrow","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","%in%","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","nrow","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","oldClass","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","dim.data.frame","dim","dim","nrow","anyNA","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","attr","[.data.frame","[","[.data.frame","[","sys.call","%in%","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,null,null,null,1,1,null,null,null,null,null,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,null,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1],"linenum":[9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,11,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,11,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,11,9,9,null,null,null,9,9,null,null,null,null,null,11,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,11,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,null,11,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,13],"memalloc":[54.5972137451172,54.5972137451172,74.8642730712891,74.8642730712891,101.564361572266,101.564361572266,117.570541381836,117.570541381836,141.906135559082,141.906135559082,146.301422119141,146.301422119141,146.301422119141,67.3960189819336,67.3960189819336,67.3960189819336,67.3960189819336,87.3399429321289,87.3399429321289,115.877235412598,115.877235412598,134.24341583252,134.24341583252,134.24341583252,146.312705993652,146.312705993652,146.312705993652,60.6352844238281,60.6352844238281,60.6352844238281,90.7497177124023,90.7497177124023,108.991912841797,108.991912841797,136.286117553711,136.286117553711,146.320663452148,146.320663452148,146.320663452148,61.15771484375,61.15771484375,80.251335144043,80.251335144043,109.173980712891,109.173980712891,109.173980712891,109.173980712891,109.173980712891,127.538681030273,127.538681030273,127.538681030273,146.300323486328,146.300323486328,146.300323486328,53.428092956543,53.428092956543,53.428092956543,53.428092956543,53.428092956543,82.8190689086914,82.8190689086914,103.219245910645,103.219245910645,103.219245910645,132.607421875,132.607421875,146.315315246582,146.315315246582,146.315315246582,58.937370300293,58.937370300293,58.937370300293,78.8781814575195,78.8781814575195,78.8781814575195,78.8781814575195,107.676895141602,107.676895141602,107.676895141602,128.279945373535,128.279945373535,146.320167541504,146.320167541504,146.320167541504,56.6424026489258,56.6424026489258,56.6424026489258,56.6424026489258,56.6424026489258,87.2122039794922,87.2122039794922,87.2122039794922,87.2122039794922,87.2122039794922,106.043968200684,106.043968200684,134.713150024414,134.713150024414,146.329734802246,146.329734802246,146.329734802246,146.329734802246,146.329734802246,146.329734802246,60.5159530639648,60.5159530639648,60.5159530639648,80.8549880981445,80.8549880981445,110.054122924805,110.054122924805,129.145782470703,129.145782470703,146.333618164062,146.333618164062,146.333618164062,55.5953216552734,55.5953216552734,55.5953216552734,55.5953216552734,55.5953216552734,83.6136016845703,83.6136016845703,83.6136016845703,83.6136016845703,101.59693145752,101.59693145752,101.59693145752,101.59693145752,129.348533630371,129.348533630371,129.348533630371,146.270469665527,146.270469665527,146.270469665527,53.9605331420898,53.9605331420898,72.7281036376953,72.7281036376953,72.7281036376953,102.113342285156,102.113342285156,120.421318054199,120.421318054199,120.421318054199,120.421318054199,120.421318054199,146.33349609375,146.33349609375,146.33349609375,45.955451965332,45.955451965332,45.955451965332,75.6764602661133,75.6764602661133,95.6195831298828,95.6195831298828,95.6195831298828,124.024139404297,124.024139404297,142.6572265625,142.6572265625,142.6572265625,50.158203125,50.158203125,69.9062881469727,69.9062881469727,99.4210052490234,99.4210052490234,117.524551391602,117.524551391602,145.732421875,145.732421875,145.732421875,43.86279296875,43.86279296875,43.86279296875,43.86279296875,43.86279296875,73.0653839111328,73.0653839111328,73.0653839111328,93.1972961425781,93.1972961425781,121.016510009766,121.016510009766,139.253677368164,139.253677368164,139.253677368164,45.9638748168945,45.9638748168945,64.7228088378906,64.7228088378906,94.5743026733398,94.5743026733398,114.26294708252,114.26294708252,114.26294708252,114.26294708252,114.26294708252,144.832679748535,144.832679748535,144.832679748535,144.832679748535,144.832679748535,133.054634094238,133.054634094238,133.054634094238,71.1618728637695,71.1618728637695,91.0398178100586,91.0398178100586,119.834251403809,119.834251403809,137.80850982666,137.80850982666,45.0491485595703,45.0491485595703,45.0491485595703,45.0491485595703,45.0491485595703,64.8619537353516,64.8619537353516,92.6849136352539,92.6849136352539,113.084228515625,113.084228515625,113.084228515625,113.084228515625,113.084228515625,113.084228515625,142.866012573242,142.866012573242,142.866012573242,146.278274536133,146.278274536133,146.278274536133,68.5282592773438,68.5282592773438,68.5282592773438,87.6833038330078,87.6833038330078,87.6833038330078,87.6833038330078,118.32209777832,118.32209777832,118.32209777832,137.80126953125,137.80126953125,137.80126953125,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,146.32795715332,42.7564697265625,42.7564697265625,42.7564697265625,42.7564697265625,42.7564697265625,42.7564697265625,66.4427947998047,66.4427947998047,86.4517669677734,86.4517669677734,86.4517669677734,116.819847106934,116.819847106934,135.784118652344,135.784118652344,135.784118652344,45.1201705932617,45.1201705932617,64.6076049804688,64.6076049804688,64.6076049804688,95.1728439331055,95.1728439331055,114.396110534668,114.396110534668,142.535163879395,142.535163879395,64.6576232910156,64.6576232910156,64.6576232910156,72.3454513549805,72.3454513549805,72.3454513549805,72.3454513549805,92.355094909668,92.355094909668,121.675987243652,121.675987243652,140.300903320312,140.300903320312,140.300903320312,140.300903320312,140.300903320312,49.5166397094727,49.5166397094727,69.1345367431641,69.1345367431641,69.1345367431641,69.1345367431641,69.1345367431641,99.7030487060547,99.7030487060547,99.7030487060547,99.7030487060547,99.7030487060547,99.7030487060547,118.857704162598,118.857704162598,146.278984069824,146.278984069824,146.278984069824,146.278984069824,146.278984069824,146.278984069824,47.1569976806641,47.1569976806641,76.4803009033203,76.4803009033203,96.6770782470703,96.6770782470703,127.578903198242,127.578903198242,146.274024963379,146.274024963379,146.274024963379,56.0198516845703,56.0198516845703,56.0198516845703,75.8262329101562,75.8262329101562,102.722496032715,102.722496032715,102.722496032715,102.722496032715,102.722496032715,120.565475463867,120.565475463867,120.565475463867,120.565475463867,120.565475463867,120.565475463867,146.280532836914,146.280532836914,146.280532836914,47.7524642944336,47.7524642944336,47.7524642944336,47.7524642944336,47.7524642944336,74.9113616943359,74.9113616943359,74.9113616943359,94.1240921020508,94.1240921020508,122.004302978516,122.004302978516,139.25309753418,139.25309753418,47.7511901855469,47.7511901855469,67.1690292358398,67.1690292358398,95.5752105712891,95.5752105712891,114.5361328125,114.5361328125,114.5361328125,114.5361328125,114.5361328125,142.220016479492,142.220016479492,142.220016479492,142.220016479492,142.220016479492,146.290382385254,146.290382385254,146.290382385254,64.8819122314453,64.8819122314453,64.8819122314453,83.4500503540039,83.4500503540039,83.4500503540039,83.4500503540039,113.496574401855,113.496574401855,132.718322753906,132.718322753906,132.718322753906,132.718322753906,132.718322753906,115.729881286621,115.729881286621,115.729881286621,59.5627670288086,59.5627670288086,59.5627670288086,87.90625,87.90625,87.90625,106.928901672363,106.928901672363,106.928901672363,106.928901672363,106.928901672363,106.928901672363,135.136070251465,135.136070251465,135.136070251465,135.136070251465,146.290481567383,146.290481567383,146.290481567383,61.5997772216797,61.5997772216797,79.5768432617188,79.5768432617188,106.609832763672,106.609832763672,106.609832763672,106.609832763672,106.609832763672,124.258834838867,124.258834838867,146.30394744873,146.30394744873,146.30394744873,50.2522811889648,50.2522811889648,50.2522811889648,79.0594711303711,79.0594711303711,79.0594711303711,97.8797225952148,97.8797225952148,125.431907653809,125.431907653809,125.431907653809,125.431907653809,143.479042053223,143.479042053223,51.5650634765625,51.5650634765625,70.9872970581055,70.9872970581055,101.751556396484,101.751556396484,101.751556396484,101.751556396484,101.751556396484,121.230339050293,121.230339050293,146.29630279541,146.29630279541,146.29630279541,146.29630279541,51.1773910522461,51.1773910522461,51.1773910522461,51.1773910522461,51.1773910522461,51.1773910522461,80.1106338500977,80.1106338500977,80.1106338500977,80.1106338500977,80.1106338500977,100.511749267578,100.511749267578,130.821937561035,130.821937561035,146.303764343262,146.303764343262,146.303764343262,60.9456024169922,60.9456024169922,60.9456024169922,60.9456024169922,60.9456024169922,80.9513778686523,80.9513778686523,111.452880859375,111.452880859375,111.452880859375,111.452880859375,111.452880859375,131.656379699707,131.656379699707,131.656379699707,130.249084472656,130.249084472656,130.249084472656,61.994499206543,61.994499206543,91.3234710693359,91.3234710693359,109.294593811035,109.294593811035,109.294593811035,139.208869934082,139.208869934082,139.208869934082,146.293235778809,146.293235778809,146.293235778809,68.3036727905273,68.3036727905273,88.190055847168,88.190055847168,118.624168395996,118.624168395996,118.624168395996,137.650382995605,137.650382995605,137.650382995605,137.650382995605,137.650382995605,137.650382995605,47.7039337158203,47.7039337158203,47.7039337158203,67.1168518066406,67.1168518066406,94.7248916625977,94.7248916625977,113.746978759766,113.746978759766,143.658882141113,143.658882141113,44.4240951538086,44.4240951538086,72.2955856323242,72.2955856323242,72.2955856323242,91.7752838134766,91.7752838134766,91.7752838134766,121.686614990234,121.686614990234,121.686614990234,141.889343261719,141.889343261719,141.889343261719,141.889343261719,141.889343261719,52.6256942749023,52.6256942749023,72.9599609375,72.9599609375,72.9599609375,102.868301391602,102.868301391602,102.868301391602,123.331047058105,123.331047058105,123.331047058105,146.287788391113,146.287788391113,146.287788391113,54.2011260986328,54.2011260986328,54.2011260986328,84.0395278930664,84.0395278930664,103.852111816406,103.852111816406,134.74308013916,134.74308013916,134.74308013916,134.74308013916,134.74308013916,146.286331176758,146.286331176758,146.286331176758,61.515510559082,61.515510559082,81.4524002075195,81.4524002075195,110.43798828125,110.43798828125,129.784370422363,129.784370422363,146.313102722168,146.313102722168,146.313102722168,57.9083709716797,57.9083709716797,87.3615493774414,87.3615493774414,107.101623535156,107.101623535156,138.315841674805,138.315841674805,146.31861114502,146.31861114502,146.31861114502,67.8777542114258,67.8777542114258,88.4060974121094,88.4060974121094,88.4060974121094,118.575553894043,118.575553894043,138.97696685791,138.97696685791,48.5975570678711,48.5975570678711,68.7327041625977,68.7327041625977,68.7327041625977,68.7327041625977,68.7327041625977,99.75390625,99.75390625,120.088088989258,120.088088989258,120.088088989258,120.088088989258,120.088088989258,146.318580627441,146.318580627441,146.318580627441,50.2385406494141,50.2385406494141,50.2385406494141,80.0790328979492,80.0790328979492,80.0790328979492,80.0790328979492,100.541320800781,100.541320800781,100.541320800781,129.793380737305,129.793380737305,146.321517944336,146.321517944336,146.321517944336,55.4181442260742,55.4181442260742,55.4181442260742,55.4181442260742,55.4181442260742,72.9960098266602,72.9960098266602,101.523582458496,101.523582458496,101.523582458496,101.523582458496,101.523582458496,120.477401733398,120.477401733398,146.322044372559,146.322044372559,146.322044372559,48.534797668457,48.534797668457,78.3734512329102,78.3734512329102,78.3734512329102,97.8520584106445,97.8520584106445,128.68244934082,128.68244934082,146.323081970215,146.323081970215,146.323081970215,146.323081970215,146.323081970215,146.323081970215,58.6994552612305,58.6994552612305,58.6994552612305,77.9772338867188,77.9772338867188,107.876945495605,107.876945495605,128.205146789551,128.205146789551,128.205146789551,128.205146789551,128.205146789551,146.301551818848,146.301551818848,146.301551818848,58.0465393066406,58.0465393066406,89.1929626464844,89.1929626464844,108.798377990723,108.798377990723,137.584899902344,137.584899902344,146.306434631348,146.306434631348,146.306434631348,146.306434631348,146.306434631348,146.306434631348,65.9774856567383,65.9774856567383,65.9774856567383,65.9774856567383,65.9774856567383,65.9774856567383,85.9771041870117,85.9771041870117,85.9771041870117,85.9771041870117,85.9771041870117,115.089576721191,115.089576721191,134.565971374512,134.565971374512,134.565971374512,134.565971374512,44.5373306274414,44.5373306274414,64.0798950195312,64.0798950195312,94.5060501098633,94.5060501098633,94.5060501098633,114.703826904297,114.703826904297,144.737365722656,144.737365722656,144.737365722656,45.1285629272461,45.1285629272461,75.0299987792969,75.0299987792969,75.0299987792969,75.0299987792969,94.8978881835938,94.8978881835938,126.108932495117,126.108932495117,126.108932495117,126.108932495117,146.106941223145,146.106941223145,146.106941223145,146.106941223145,55.7524566650391,55.7524566650391,55.7524566650391,75.2928314208984,75.2928314208984,105.323501586914,105.323501586914,125.584205627441,125.584205627441,125.584205627441,125.584205627441,146.304725646973,146.304725646973,146.304725646973,56.8672180175781,56.8672180175781,87.882682800293,87.882682800293,108.669143676758,108.669143676758,139.749397277832,139.749397277832,139.749397277832,139.749397277832,139.749397277832,146.305809020996,146.305809020996,146.305809020996,69.1949234008789,69.1949234008789,69.1949234008789,89.8502349853516,89.8502349853516,121.062385559082,121.062385559082,141.25609588623,141.25609588623,51.2280502319336,51.2280502319336,69.7166519165039,69.7166519165039,101.054611206055,101.054611206055,121.378425598145,121.378425598145,146.292015075684,146.292015075684,146.292015075684,146.292015075684,146.292015075684,146.292015075684,52.7366714477539,52.7366714477539,83.6166610717773,83.6166610717773,103.416076660156,103.416076660156,134.754600524902,134.754600524902,134.754600524902,146.293731689453,146.293731689453,146.293731689453,65.326057434082,65.326057434082,84.7980041503906,84.7980041503906,84.7980041503906,84.7980041503906,115.087814331055,115.087814331055,134.690689086914,134.690689086914,134.690689086914,44.8709106445312,44.8709106445312,44.8709106445312,44.8709106445312,44.8709106445312,44.8709106445312,64.6707611083984,64.6707611083984,95.222297668457,95.222297668457,112.793182373047,112.793182373047,112.793182373047,112.793182373047,112.793182373047,143.01676940918,143.01676940918,72.3348770141602,72.3348770141602,72.3348770141602,73.2595291137695,73.2595291137695,73.2595291137695,93.6482009887695,93.6482009887695,93.6482009887695,124.461685180664,124.461685180664,144.785453796387,144.785453796387,55.2309875488281,55.2309875488281,55.2309875488281,55.2309875488281,55.2309875488281,73.3257217407227,73.3257217407227,73.3257217407227,102.958465576172,102.958465576172,122.299041748047,122.299041748047,146.294013977051,146.294013977051,146.294013977051,48.5915908813477,48.5915908813477,77.437873840332,77.437873840332,97.6304702758789,97.6304702758789,128.508888244629,128.508888244629,146.276153564453,146.276153564453,146.276153564453,146.276153564453,146.276153564453,146.276153564453,56.262321472168,56.262321472168,76.0616836547852,76.0616836547852,107.202781677246,107.202781677246,113.393180847168,113.393180847168,113.393180847168,113.393180847168,113.393180847168],"meminc":[0,0,20.2670593261719,0,26.7000885009766,0,16.0061798095703,0,24.3355941772461,0,4.39528656005859,0,0,-78.905403137207,0,0,0,19.9439239501953,0,28.5372924804688,0,18.3661804199219,0,0,12.0692901611328,0,0,-85.6774215698242,0,0,30.1144332885742,0,18.2421951293945,0,27.2942047119141,0,10.0345458984375,0,0,-85.1629486083984,0,19.093620300293,0,28.9226455688477,0,0,0,0,18.3647003173828,0,0,18.7616424560547,0,0,-92.8722305297852,0,0,0,0,29.3909759521484,0,20.4001770019531,0,0,29.3881759643555,0,13.707893371582,0,0,-87.3779449462891,0,0,19.9408111572266,0,0,0,28.798713684082,0,0,20.6030502319336,0,18.0402221679688,0,0,-89.6777648925781,0,0,0,0,30.5698013305664,0,0,0,0,18.8317642211914,0,28.6691818237305,0,11.616584777832,0,0,0,0,0,-85.8137817382812,0,0,20.3390350341797,0,29.1991348266602,0,19.0916595458984,0,17.1878356933594,0,0,-90.7382965087891,0,0,0,0,28.0182800292969,0,0,0,17.9833297729492,0,0,0,27.7516021728516,0,0,16.9219360351562,0,0,-92.3099365234375,0,18.7675704956055,0,0,29.3852386474609,0,18.307975769043,0,0,0,0,25.9121780395508,0,0,-100.378044128418,0,0,29.7210083007812,0,19.9431228637695,0,0,28.4045562744141,0,18.6330871582031,0,0,-92.4990234375,0,19.7480850219727,0,29.5147171020508,0,18.1035461425781,0,28.2078704833984,0,0,-101.86962890625,0,0,0,0,29.2025909423828,0,0,20.1319122314453,0,27.8192138671875,0,18.2371673583984,0,0,-93.2898025512695,0,18.7589340209961,0,29.8514938354492,0,19.6886444091797,0,0,0,0,30.5697326660156,0,0,0,0,-11.7780456542969,0,0,-61.8927612304688,0,19.8779449462891,0,28.79443359375,0,17.9742584228516,0,-92.7593612670898,0,0,0,0,19.8128051757812,0,27.8229598999023,0,20.3993148803711,0,0,0,0,0,29.7817840576172,0,0,3.41226196289062,0,0,-77.7500152587891,0,0,19.1550445556641,0,0,0,30.6387939453125,0,0,19.4791717529297,0,0,8.52668762207031,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571487426758,0,0,0,0,0,23.6863250732422,0,20.0089721679688,0,0,30.3680801391602,0,18.9642715454102,0,0,-90.663948059082,0,19.487434387207,0,0,30.5652389526367,0,19.2232666015625,0,28.1390533447266,0,-77.8775405883789,0,0,7.68782806396484,0,0,0,20.0096435546875,0,29.3208923339844,0,18.6249160766602,0,0,0,0,-90.7842636108398,0,19.6178970336914,0,0,0,0,30.5685119628906,0,0,0,0,0,19.154655456543,0,27.4212799072266,0,0,0,0,0,-99.1219863891602,0,29.3233032226562,0,20.19677734375,0,30.9018249511719,0,18.6951217651367,0,0,-90.2541732788086,0,0,19.8063812255859,0,26.8962631225586,0,0,0,0,17.8429794311523,0,0,0,0,0,25.7150573730469,0,0,-98.5280685424805,0,0,0,0,27.1588973999023,0,0,19.2127304077148,0,27.8802108764648,0,17.2487945556641,0,-91.5019073486328,0,19.417839050293,0,28.4061813354492,0,18.9609222412109,0,0,0,0,27.6838836669922,0,0,0,0,4.07036590576172,0,0,-81.4084701538086,0,0,18.5681381225586,0,0,0,30.0465240478516,0,19.2217483520508,0,0,0,0,-16.9884414672852,0,0,-56.1671142578125,0,0,28.3434829711914,0,0,19.0226516723633,0,0,0,0,0,28.2071685791016,0,0,0,11.154411315918,0,0,-84.6907043457031,0,17.9770660400391,0,27.0329895019531,0,0,0,0,17.6490020751953,0,22.0451126098633,0,0,-96.0516662597656,0,0,28.8071899414062,0,0,18.8202514648438,0,27.5521850585938,0,0,0,18.0471343994141,0,-91.9139785766602,0,19.422233581543,0,30.7642593383789,0,0,0,0,19.4787826538086,0,25.0659637451172,0,0,0,-95.1189117431641,0,0,0,0,0,28.9332427978516,0,0,0,0,20.4011154174805,0,30.310188293457,0,15.4818267822266,0,0,-85.3581619262695,0,0,0,0,20.0057754516602,0,30.5015029907227,0,0,0,0,20.203498840332,0,0,-1.40729522705078,0,0,-68.2545852661133,0,29.328971862793,0,17.9711227416992,0,0,29.9142761230469,0,0,7.08436584472656,0,0,-77.9895629882812,0,19.8863830566406,0,30.4341125488281,0,0,19.0262145996094,0,0,0,0,0,-89.9464492797852,0,0,19.4129180908203,0,27.608039855957,0,19.022087097168,0,29.9119033813477,0,-99.2347869873047,0,27.8714904785156,0,0,19.4796981811523,0,0,29.9113311767578,0,0,20.2027282714844,0,0,0,0,-89.2636489868164,0,20.3342666625977,0,0,29.9083404541016,0,0,20.4627456665039,0,0,22.9567413330078,0,0,-92.0866622924805,0,0,29.8384017944336,0,19.8125839233398,0,30.8909683227539,0,0,0,0,11.5432510375977,0,0,-84.7708206176758,0,19.9368896484375,0,28.9855880737305,0,19.3463821411133,0,16.5287322998047,0,0,-88.4047317504883,0,29.4531784057617,0,19.7400741577148,0,31.2142181396484,0,8.00276947021484,0,0,-78.4408569335938,0,20.5283432006836,0,0,30.1694564819336,0,20.4014129638672,0,-90.3794097900391,0,20.1351470947266,0,0,0,0,31.0212020874023,0,20.3341827392578,0,0,0,0,26.2304916381836,0,0,-96.0800399780273,0,0,29.8404922485352,0,0,0,20.462287902832,0,0,29.2520599365234,0,16.5281372070312,0,0,-90.9033737182617,0,0,0,0,17.5778656005859,0,28.5275726318359,0,0,0,0,18.9538192749023,0,25.8446426391602,0,0,-97.7872467041016,0,29.8386535644531,0,0,19.4786071777344,0,30.8303909301758,0,17.6406326293945,0,0,0,0,0,-87.6236267089844,0,0,19.2777786254883,0,29.8997116088867,0,20.3282012939453,0,0,0,0,18.0964050292969,0,0,-88.255012512207,0,31.1464233398438,0,19.6054153442383,0,28.7865219116211,0,8.72153472900391,0,0,0,0,0,-80.3289489746094,0,0,0,0,0,19.9996185302734,0,0,0,0,29.1124725341797,0,19.4763946533203,0,0,0,-90.0286407470703,0,19.5425643920898,0,30.426155090332,0,0,20.1977767944336,0,30.0335388183594,0,0,-99.6088027954102,0,29.9014358520508,0,0,0,19.8678894042969,0,31.2110443115234,0,0,0,19.9980087280273,0,0,0,-90.3544845581055,0,0,19.5403747558594,0,30.0306701660156,0,20.2607040405273,0,0,0,20.7205200195312,0,0,-89.4375076293945,0,31.0154647827148,0,20.7864608764648,0,31.0802536010742,0,0,0,0,6.55641174316406,0,0,-77.1108856201172,0,0,20.6553115844727,0,31.2121505737305,0,20.1937103271484,0,-90.0280456542969,0,18.4886016845703,0,31.3379592895508,0,20.3238143920898,0,24.9135894775391,0,0,0,0,0,-93.5553436279297,0,30.8799896240234,0,19.7994155883789,0,31.3385238647461,0,0,11.5391311645508,0,0,-80.9676742553711,0,19.4719467163086,0,0,0,30.2898101806641,0,19.6028747558594,0,0,-89.8197784423828,0,0,0,0,0,19.7998504638672,0,30.5515365600586,0,17.5708847045898,0,0,0,0,30.2235870361328,0,-70.6818923950195,0,0,0.924652099609375,0,0,20.388671875,0,0,30.8134841918945,0,20.3237686157227,0,-89.5544662475586,0,0,0,0,18.0947341918945,0,0,29.6327438354492,0,19.340576171875,0,23.9949722290039,0,0,-97.7024230957031,0,28.8462829589844,0,20.1925964355469,0,30.87841796875,0,17.7672653198242,0,0,0,0,0,-90.0138320922852,0,19.7993621826172,0,31.1410980224609,0,6.19039916992188,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpoSxX7Y/file3b7c4a5105bd.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min         lq        mean     median
#>         compute_pi0(m)    782.855    794.578    814.0497    809.861
#>    compute_pi0(m * 10)   7888.295   7927.309   8009.3613   7951.285
#>   compute_pi0(m * 100)  79135.577  79414.222  80952.7467  79808.471
#>         compute_pi1(m)    187.533    242.228    776.3202    342.656
#>    compute_pi1(m * 10)   1399.816   1572.890   1592.3722   1605.363
#>   compute_pi1(m * 100)  14926.569  15264.082  31634.8058  23103.355
#>  compute_pi1(m * 1000) 284381.645 350643.068 455645.0979 493322.263
#>           uq        max neval
#>     828.1045    915.809    20
#>    8039.4505   8454.827    20
#>   80906.8360  90386.545    20
#>     367.2815   9775.965    20
#>    1633.7415   1707.590    20
#>   30910.2490 195715.616    20
#>  502934.8465 679147.264    20
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
#>   memory_copy1(n) 5733.78421 4858.59344 543.207176 3507.42601 2781.855300
#>   memory_copy2(n)   95.35241   83.99440   9.337110   59.66179   48.370778
#>  pre_allocate1(n)   19.35248   16.46225   2.891027   11.79655    9.470374
#>  pre_allocate2(n)  192.60228  167.30195  17.166848  119.29917   94.858585
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.000000
#>         max neval
#>  125.083464    10
#>    2.442034    10
#>    1.681287    10
#>    3.201548    10
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
#>    expr      min       lq     mean  median      uq      max neval
#>  f1(df) 367.7436 372.1664 105.7967 357.758 82.9023 39.79224     5
#>  f2(df)   1.0000   1.0000   1.0000   1.000  1.0000  1.00000     5
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
