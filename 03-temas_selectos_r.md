
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
#>    id           a         b        c        d
#> 1   1 -1.06781374 1.9523049 2.984529 2.376514
#> 2   2 -1.29664335 3.5538900 2.670097 4.539643
#> 3   3 -1.14412288 0.5653074 4.518557 3.926063
#> 4   4 -0.68759117 0.9210755 3.724563 4.264062
#> 5   5  0.17772010 3.0663919 2.324225 4.637632
#> 6   6 -0.08521163 1.9757684 3.767881 3.406270
#> 7   7  0.15935298 1.6082386 2.962988 5.052210
#> 8   8  0.73627294 1.6140269 2.399254 4.176973
#> 9   9  1.11231910 2.8901485 1.953078 6.303463
#> 10 10  1.53142255 1.7172251 3.791517 2.762017
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.05642951
mean(df$b)
#> [1] 1.986438
mean(df$c)
#> [1] 3.109669
mean(df$d)
#> [1] 4.144485
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.05642951  1.98643771  3.10966904  4.14448472
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
#> [1] -0.05642951  1.98643771  3.10966904  4.14448472
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
#> [1]  5.50000000 -0.05642951  1.98643771  3.10966904  4.14448472
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
#> [1] 5.50000000 0.03707067 1.83476502 2.97375856 4.22051740
col_describe(df, mean)
#> [1]  5.50000000 -0.05642951  1.98643771  3.10966904  4.14448472
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
#>  5.50000000 -0.05642951  1.98643771  3.10966904  4.14448472
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
#>   3.771   0.136   3.906
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.018   0.004   0.579
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
#>  12.835   1.009   9.921
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
#>   0.112   0.000   0.113
plyr_st
#>    user  system elapsed 
#>   3.969   0.007   3.977
est_l_st
#>    user  system elapsed 
#>  61.186   0.900  62.087
est_r_st
#>    user  system elapsed 
#>   0.387   0.000   0.387
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

<!--html_preserve--><div id="htmlwidget-d56aeb2409fa96a9d776" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-d56aeb2409fa96a9d776">{"x":{"message":{"prof":{"time":[1,1,1,1,2,2,2,2,3,3,4,4,4,4,4,5,5,5,6,6,7,7,8,8,9,9,9,10,10,10,10,10,11,11,12,12,12,13,13,14,14,14,15,15,16,16,17,17,17,18,18,18,18,19,19,20,20,21,21,22,22,22,22,22,23,23,23,24,24,25,25,26,26,27,27,27,27,28,28,29,29,29,30,30,30,30,30,31,31,31,31,31,31,32,32,32,32,32,32,33,33,33,33,34,34,35,35,36,36,36,37,37,38,38,38,39,39,39,40,40,41,41,41,42,42,42,43,43,43,44,44,44,44,44,44,45,45,46,46,46,47,47,47,48,48,48,49,49,49,49,50,50,51,51,51,52,52,52,52,52,52,53,53,53,54,54,54,55,55,56,56,56,56,56,57,57,57,57,57,58,58,59,59,59,60,60,61,61,62,62,63,63,64,64,64,65,65,65,65,65,66,66,67,67,68,68,68,69,69,69,69,70,70,70,70,71,71,71,71,71,71,72,72,73,73,73,74,74,75,75,76,76,77,77,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,90,90,91,91,91,91,91,92,92,92,93,93,94,94,95,95,96,96,97,97,98,98,99,99,99,99,99,99,100,100,100,101,101,101,102,102,102,102,102,103,103,104,104,104,105,105,106,106,107,107,108,108,108,109,109,109,110,110,110,110,110,110,111,111,112,112,112,112,113,113,113,114,114,114,114,114,114,115,115,116,116,117,117,118,118,119,119,119,119,120,120,120,120,121,121,121,121,122,122,122,123,123,123,124,124,124,124,125,125,126,126,126,127,127,127,127,127,128,128,128,128,128,128,129,129,130,130,130,130,130,130,131,131,132,132,132,133,133,133,134,134,134,134,135,135,136,136,137,137,138,138,138,138,139,139,140,140,140,140,141,141,141,141,141,141,142,142,143,143,144,144,144,145,145,145,146,146,147,147,148,148,148,149,149,150,150,150,151,151,152,152,153,153,153,154,154,154,154,155,155,156,156,157,157,157,157,157,158,158,158,159,159,159,159,159,160,160,161,161,162,162,163,163,163,164,164,165,165,166,166,166,167,167,168,168,168,169,169,169,169,170,170,171,171,172,172,172,173,173,174,174,175,175,176,176,177,177,177,178,178,178,179,179,180,180,180,181,181,182,182,183,183,183,184,184,185,185,185,186,186,186,187,187,187,188,188,188,188,188,189,189,190,190,191,191,192,192,192,193,193,194,194,194,194,194,194,195,195,195,195,196,196,197,197,198,198,199,199,200,200,201,201,201,201,201,202,202,203,203,203,203,203,203,204,204,205,205,205,205,205,206,206,206,206,206,206,207,207,207,207,208,208,208,209,209,209,209,210,210,211,211,211,212,212,213,213,213,213,213,214,214,214,214,214,215,215,215,216,216,217,217,218,218,219,219,219,219,220,220,220,221,221,221,221,222,222,223,223,224,224,225,225,226,226,226,227,227,227,228,228,229,229,230,230,230,231,231,231,231,231,232,232,232,233,233,233,234,234,235,235,236,236,237,237,238,238,239,239,239,240,240,241,241,241,242,242,242,243,243,244,244,244,244,244,245,245,246,246,247,247,247,248,248,248,248,248,249,249,250,250,251,251,251,252,252,252,252,252,253,253,254,254,255,255,255,255,255,256,256,256,256,256,257,257,258,258,259,259,259,260,260,261,261,261,261,261,261,262,262,262,262,262,262,263,263,264,264,265,265,265,265,266,266,267,267,267,267,267,267,268,268,268,269,269,269,269,269,269,270,270,271,271,272,272,273,273,273,273,273,274,274,275,275,276,276,277,277,277,277,277,277,278,278,278,278,278,279,279,280,280,280,280,280],"depth":[4,3,2,1,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,4,3,2,1,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,4,3,2,1,4,3,2,1,4,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1],"label":["[[.data.frame","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","$","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","names","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","attr","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","names","names","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,1,1,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,1,1,null,null,1,1,null,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,null,null,1,null,null,1,1,null,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1],"linenum":[null,null,9,9,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,9,9,null,null,9,9,null,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,null,null,11,null,null,9,9,null,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,13],"memalloc":[66.5111770629883,66.5111770629883,66.5111770629883,66.5111770629883,87.8285369873047,87.8285369873047,87.8285369873047,87.8285369873047,116.299369812012,116.299369812012,134.07625579834,134.07625579834,134.07625579834,134.07625579834,134.07625579834,45.6555938720703,45.6555938720703,45.6555938720703,65.3352203369141,65.3352203369141,96.890739440918,96.890739440918,116.704643249512,116.704643249512,146.28742980957,146.28742980957,146.28742980957,50.3752822875977,50.3752822875977,50.3752822875977,50.3752822875977,50.3752822875977,82.3256149291992,82.3256149291992,103.123954772949,103.123954772949,103.123954772949,133.244155883789,133.244155883789,146.295387268066,146.295387268066,146.295387268066,67.2340240478516,67.2340240478516,88.226203918457,88.226203918457,119.314170837402,119.314170837402,119.314170837402,138.860549926758,138.860549926758,138.860549926758,138.860549926758,52.8779907226562,52.8779907226562,74.0036239624023,74.0036239624023,105.750770568848,105.750770568848,125.890159606934,125.890159606934,125.890159606934,125.890159606934,125.890159606934,146.2900390625,146.2900390625,146.2900390625,59.5675659179688,59.5675659179688,90.6621627807617,90.6621627807617,109.946990966797,109.946990966797,141.832786560059,141.832786560059,141.832786560059,141.832786560059,45.399528503418,45.399528503418,76.756477355957,76.756477355957,76.756477355957,97.4909591674805,97.4909591674805,97.4909591674805,97.4909591674805,97.4909591674805,127.406105041504,127.406105041504,127.406105041504,127.406105041504,127.406105041504,127.406105041504,146.304458618164,146.304458618164,146.304458618164,146.304458618164,146.304458618164,146.304458618164,61.9994201660156,61.9994201660156,61.9994201660156,61.9994201660156,82.4714431762695,82.4714431762695,113.046447753906,113.046447753906,132.923774719238,132.923774719238,132.923774719238,46.8467330932617,46.8467330932617,67.9040603637695,67.9040603637695,67.9040603637695,99.4074401855469,99.4074401855469,99.4074401855469,118.689865112305,118.689865112305,146.310775756836,146.310775756836,146.310775756836,53.3445739746094,53.3445739746094,53.3445739746094,84.8348999023438,84.8348999023438,84.8348999023438,105.896179199219,105.896179199219,105.896179199219,105.896179199219,105.896179199219,105.896179199219,138.239753723145,138.239753723145,146.308204650879,146.308204650879,146.308204650879,74.2073364257812,74.2073364257812,74.2073364257812,95.5287780761719,95.5287780761719,95.5287780761719,125.640937805176,125.640937805176,125.640937805176,125.640937805176,145.847427368164,145.847427368164,60.6317520141602,60.6317520141602,60.6317520141602,81.4258499145508,81.4258499145508,81.4258499145508,81.4258499145508,81.4258499145508,81.4258499145508,113.105140686035,113.105140686035,113.105140686035,132.976264953613,132.976264953613,132.976264953613,46.7255325317383,46.7255325317383,66.9370956420898,66.9370956420898,66.9370956420898,66.9370956420898,66.9370956420898,98.6175765991211,98.6175765991211,98.6175765991211,98.6175765991211,98.6175765991211,118.827453613281,118.827453613281,146.315422058105,146.315422058105,146.315422058105,53.6104278564453,53.6104278564453,84.3780212402344,84.3780212402344,103.868713378906,103.868713378906,132.935890197754,132.935890197754,146.316024780273,146.316024780273,146.316024780273,66.8718109130859,66.8718109130859,66.8718109130859,66.8718109130859,66.8718109130859,87.4714050292969,87.4714050292969,118.169944763184,118.169944763184,138.965744018555,138.965744018555,138.965744018555,52.6962127685547,52.6962127685547,52.6962127685547,52.6962127685547,72.6427154541016,72.6427154541016,72.6427154541016,72.6427154541016,104.00659942627,104.00659942627,104.00659942627,104.00659942627,104.00659942627,104.00659942627,123.753601074219,123.753601074219,146.318702697754,146.318702697754,146.318702697754,57.8140335083008,57.8140335083008,89.0363082885742,89.0363082885742,108.327766418457,108.327766418457,140.20484161377,140.20484161377,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,146.302680969238,42.7312698364258,42.7312698364258,42.7312698364258,44.8950805664062,44.8950805664062,44.8950805664062,75.4682846069336,75.4682846069336,96.3301773071289,96.3301773071289,127.093788146973,127.093788146973,127.093788146973,127.093788146973,127.093788146973,146.319458007812,146.319458007812,146.319458007812,63.0068054199219,63.0068054199219,83.016716003418,83.016716003418,113.846481323242,113.846481323242,133.655708312988,133.655708312988,49.3601837158203,49.3601837158203,70.4823989868164,70.4823989868164,101.843215942383,101.843215942383,101.843215942383,101.843215942383,101.843215942383,101.843215942383,121.322052001953,121.322052001953,121.322052001953,146.30916595459,146.30916595459,146.30916595459,56.381462097168,56.381462097168,56.381462097168,56.381462097168,56.381462097168,88.2632751464844,88.2632751464844,109.255081176758,109.255081176758,109.255081176758,141.201965332031,141.201965332031,46.4102172851562,46.4102172851562,77.8975830078125,77.8975830078125,97.2416152954102,97.2416152954102,97.2416152954102,128.736465454102,128.736465454102,128.736465454102,146.314994812012,146.314994812012,146.314994812012,146.314994812012,146.314994812012,146.314994812012,65.9626693725586,65.9626693725586,86.6224899291992,86.6224899291992,86.6224899291992,86.6224899291992,118.372932434082,118.372932434082,118.372932434082,137.725624084473,137.725624084473,137.725624084473,137.725624084473,137.725624084473,137.725624084473,53.7594528198242,53.7594528198242,74.4267272949219,74.4267272949219,106.365653991699,106.365653991699,127.619537353516,127.619537353516,44.5119094848633,44.5119094848633,44.5119094848633,44.5119094848633,65.3068389892578,65.3068389892578,65.3068389892578,65.3068389892578,97.5854644775391,97.5854644775391,97.5854644775391,97.5854644775391,118.315322875977,118.315322875977,118.315322875977,146.263656616211,146.263656616211,146.263656616211,53.7648010253906,53.7648010253906,53.7648010253906,53.7648010253906,83.5564575195312,83.5564575195312,103.303070068359,103.303070068359,103.303070068359,135.249816894531,135.249816894531,135.249816894531,135.249816894531,135.249816894531,146.270935058594,146.270935058594,146.270935058594,146.270935058594,146.270935058594,146.270935058594,72.8554077148438,72.8554077148438,93.5862731933594,93.5862731933594,93.5862731933594,93.5862731933594,93.5862731933594,93.5862731933594,126.056297302246,126.056297302246,146.263969421387,146.263969421387,146.263969421387,63.0186004638672,63.0186004638672,63.0186004638672,82.965087890625,82.965087890625,82.965087890625,82.965087890625,114.259872436523,114.259872436523,135.126853942871,135.126853942871,51.7362060546875,51.7362060546875,72.3437728881836,72.3437728881836,72.3437728881836,72.3437728881836,103.955917358398,103.955917358398,124.424018859863,124.424018859863,124.424018859863,124.424018859863,146.277183532715,146.277183532715,146.277183532715,146.277183532715,146.277183532715,146.277183532715,60.5247192382812,60.5247192382812,91.496826171875,91.496826171875,112.548385620117,112.548385620117,112.548385620117,144.171569824219,144.171569824219,144.171569824219,50.7594223022461,50.7594223022461,82.0526885986328,82.0526885986328,102.784439086914,102.784439086914,102.784439086914,134.0771484375,134.0771484375,146.278938293457,146.278938293457,146.278938293457,71.2192230224609,71.2192230224609,92.5369720458984,92.5369720458984,124.548080444336,124.548080444336,124.548080444336,145.211082458496,145.211082458496,145.211082458496,145.211082458496,62.1022567749023,62.1022567749023,82.313346862793,82.313346862793,113.66674041748,113.66674041748,113.66674041748,113.66674041748,113.66674041748,133.80345916748,133.80345916748,133.80345916748,49.3166046142578,49.3166046142578,49.3166046142578,49.3166046142578,49.3166046142578,69.7886428833008,69.7886428833008,101.285263061523,101.285263061523,122.078620910645,122.078620910645,146.285186767578,146.285186767578,146.285186767578,59.6801605224609,59.6801605224609,91.879150390625,91.879150390625,113.131446838379,113.131446838379,113.131446838379,143.764984130859,143.764984130859,50.1680603027344,50.1680603027344,50.1680603027344,81.7131500244141,81.7131500244141,81.7131500244141,81.7131500244141,103.03288269043,103.03288269043,135.040237426758,135.040237426758,146.25951385498,146.25951385498,146.25951385498,72.9983749389648,72.9983749389648,92.8068466186523,92.8068466186523,124.418685913086,124.418685913086,143.768623352051,143.768623352051,61.3221969604492,61.3221969604492,61.3221969604492,81.8481597900391,81.8481597900391,81.8481597900391,113.728866577148,113.728866577148,135.044929504395,135.044929504395,135.044929504395,50.6025772094727,50.6025772094727,71.2640609741211,71.2640609741211,102.674674987793,102.674674987793,102.674674987793,122.939735412598,122.939735412598,146.288330078125,146.288330078125,146.288330078125,58.8666305541992,58.8666305541992,58.8666305541992,90.4840316772461,90.4840316772461,90.4840316772461,111.273460388184,111.273460388184,111.273460388184,111.273460388184,111.273460388184,143.211158752441,143.211158752441,48.5049362182617,48.5049362182617,80.3811264038086,80.3811264038086,101.958869934082,101.958869934082,101.958869934082,133.901062011719,133.901062011719,146.296943664551,146.296943664551,146.296943664551,146.296943664551,146.296943664551,146.296943664551,70.9360961914062,70.9360961914062,70.9360961914062,70.9360961914062,92.1213150024414,92.1213150024414,124.522689819336,124.522689819336,146.161582946777,146.161582946777,62.6740112304688,62.6740112304688,83.8577880859375,83.8577880859375,115.930252075195,115.930252075195,115.930252075195,115.930252075195,115.930252075195,136.916328430176,136.916328430176,53.3601837158203,53.3601837158203,53.3601837158203,53.3601837158203,53.3601837158203,53.3601837158203,74.8069686889648,74.8069686889648,107.139991760254,107.139991760254,107.139991760254,107.139991760254,107.139991760254,128.849090576172,128.849090576172,128.849090576172,128.849090576172,128.849090576172,128.849090576172,44.574821472168,44.574821472168,44.574821472168,44.574821472168,65.0985107421875,65.0985107421875,65.0985107421875,97.0391845703125,97.0391845703125,97.0391845703125,97.0391845703125,118.096549987793,118.096549987793,146.296760559082,146.296760559082,146.296760559082,54.6085815429688,54.6085815429688,86.6743621826172,86.6743621826172,86.6743621826172,86.6743621826172,86.6743621826172,107.590126037598,107.590126037598,107.590126037598,107.590126037598,107.590126037598,139.785415649414,139.785415649414,139.785415649414,45.3654327392578,45.3654327392578,77.2987976074219,77.2987976074219,98.7411956787109,98.7411956787109,130.87028503418,130.87028503418,130.87028503418,130.87028503418,146.280632019043,146.280632019043,146.280632019043,69.035774230957,69.035774230957,69.035774230957,69.035774230957,90.2818984985352,90.2818984985352,122.804779052734,122.804779052734,143.001831054688,143.001831054688,58.3513259887695,58.3513259887695,78.0244216918945,78.0244216918945,78.0244216918945,109.499816894531,109.499816894531,109.499816894531,130.877395629883,130.877395629883,47.4648513793945,47.4648513793945,68.0554122924805,68.0554122924805,68.0554122924805,98.4143753051758,98.4143753051758,98.4143753051758,98.4143753051758,98.4143753051758,119.65779876709,119.65779876709,119.65779876709,146.278953552246,146.278953552246,146.278953552246,57.1718444824219,57.1718444824219,88.7770690917969,88.7770690917969,109.627426147461,109.627426147461,141.626556396484,141.626556396484,47.6632537841797,47.6632537841797,79.7939682006836,79.7939682006836,79.7939682006836,100.842247009277,100.842247009277,133.29956817627,133.29956817627,133.29956817627,146.282089233398,146.282089233398,146.282089233398,71.3344573974609,71.3344573974609,92.2528610229492,92.2528610229492,92.2528610229492,92.2528610229492,92.2528610229492,124.578964233398,124.578964233398,145.821846008301,145.821846008301,62.7437057495117,62.7437057495117,62.7437057495117,84.2480773925781,84.2480773925781,84.2480773925781,84.2480773925781,84.2480773925781,116.831237792969,116.831237792969,138.204597473145,138.204597473145,55.4019241333008,55.4019241333008,55.4019241333008,76.6441268920898,76.6441268920898,76.6441268920898,76.6441268920898,76.6441268920898,107.457649230957,107.457649230957,128.699745178223,128.699745178223,44.4541397094727,44.4541397094727,44.4541397094727,44.4541397094727,44.4541397094727,64.9756622314453,64.9756622314453,64.9756622314453,64.9756622314453,64.9756622314453,97.4276504516602,97.4276504516602,118.932800292969,118.932800292969,146.271461486816,146.271461486816,146.271461486816,56.0590057373047,56.0590057373047,86.4791107177734,86.4791107177734,86.4791107177734,86.4791107177734,86.4791107177734,86.4791107177734,106.868812561035,106.868812561035,106.868812561035,106.868812561035,106.868812561035,106.868812561035,138.732315063477,138.732315063477,45.7006301879883,45.7006301879883,76.7108306884766,76.7108306884766,76.7108306884766,76.7108306884766,97.8869018554688,97.8869018554688,130.14225769043,130.14225769043,130.14225769043,130.14225769043,130.14225769043,130.14225769043,146.269950866699,146.269950866699,146.269950866699,69.0408630371094,69.0408630371094,69.0408630371094,69.0408630371094,69.0408630371094,69.0408630371094,88.2497634887695,88.2497634887695,119.259872436523,119.259872436523,140.304946899414,140.304946899414,55.7783279418945,55.7783279418945,55.7783279418945,55.7783279418945,55.7783279418945,76.7573165893555,76.7573165893555,108.619361877441,108.619361877441,128.025459289551,128.025459289551,43.9123458862305,43.9123458862305,43.9123458862305,43.9123458862305,43.9123458862305,43.9123458862305,64.1049575805664,64.1049575805664,64.1049575805664,64.1049575805664,64.1049575805664,95.4426040649414,95.4426040649414,112.581535339355,112.581535339355,112.581535339355,112.581535339355,112.581535339355],"meminc":[0,0,0,0,21.3173599243164,0,0,0,28.470832824707,0,17.7768859863281,0,0,0,0,-88.4206619262695,0,0,19.6796264648438,0,31.5555191040039,0,19.8139038085938,0,29.5827865600586,0,0,-95.9121475219727,0,0,0,0,31.9503326416016,0,20.79833984375,0,0,30.1202011108398,0,13.0512313842773,0,0,-79.0613632202148,0,20.9921798706055,0,31.0879669189453,0,0,19.5463790893555,0,0,0,-85.9825592041016,0,21.1256332397461,0,31.7471466064453,0,20.1393890380859,0,0,0,0,20.3998794555664,0,0,-86.7224731445312,0,31.094596862793,0,19.2848281860352,0,31.8857955932617,0,0,0,-96.4332580566406,0,31.3569488525391,0,0,20.7344818115234,0,0,0,0,29.9151458740234,0,0,0,0,0,18.8983535766602,0,0,0,0,0,-84.3050384521484,0,0,0,20.4720230102539,0,30.5750045776367,0,19.877326965332,0,0,-86.0770416259766,0,21.0573272705078,0,0,31.5033798217773,0,0,19.2824249267578,0,27.6209106445312,0,0,-92.9662017822266,0,0,31.4903259277344,0,0,21.061279296875,0,0,0,0,0,32.3435745239258,0,8.06845092773438,0,0,-72.1008682250977,0,0,21.3214416503906,0,0,30.1121597290039,0,0,0,20.2064895629883,0,-85.2156753540039,0,0,20.7940979003906,0,0,0,0,0,31.6792907714844,0,0,19.8711242675781,0,0,-86.250732421875,0,20.2115631103516,0,0,0,0,31.6804809570312,0,0,0,0,20.2098770141602,0,27.4879684448242,0,0,-92.7049942016602,0,30.7675933837891,0,19.4906921386719,0,29.0671768188477,0,13.3801345825195,0,0,-79.4442138671875,0,0,0,0,20.5995941162109,0,30.6985397338867,0,20.7957992553711,0,0,-86.26953125,0,0,0,19.9465026855469,0,0,0,31.363883972168,0,0,0,0,0,19.7470016479492,0,22.5651016235352,0,0,-88.5046691894531,0,31.2222747802734,0,19.2914581298828,0,31.8770751953125,0,6.09783935546875,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571411132812,0,0,2.16381072998047,0,0,30.5732040405273,0,20.8618927001953,0,30.7636108398438,0,0,0,0,19.2256698608398,0,0,-83.3126525878906,0,20.0099105834961,0,30.8297653198242,0,19.8092269897461,0,-84.295524597168,0,21.1222152709961,0,31.3608169555664,0,0,0,0,0,19.4788360595703,0,0,24.9871139526367,0,0,-89.9277038574219,0,0,0,0,31.8818130493164,0,20.9918060302734,0,0,31.9468841552734,0,-94.791748046875,0,31.4873657226562,0,19.3440322875977,0,0,31.4948501586914,0,0,17.5785293579102,0,0,0,0,0,-80.3523254394531,0,20.6598205566406,0,0,0,31.7504425048828,0,0,19.3526916503906,0,0,0,0,0,-83.9661712646484,0,20.6672744750977,0,31.9389266967773,0,21.2538833618164,0,-83.1076278686523,0,0,0,20.7949295043945,0,0,0,32.2786254882812,0,0,0,20.7298583984375,0,0,27.9483337402344,0,0,-92.4988555908203,0,0,0,29.7916564941406,0,19.7466125488281,0,0,31.9467468261719,0,0,0,0,11.0211181640625,0,0,0,0,0,-73.41552734375,0,20.7308654785156,0,0,0,0,0,32.4700241088867,0,20.2076721191406,0,0,-83.2453689575195,0,0,19.9464874267578,0,0,0,31.2947845458984,0,20.8669815063477,0,-83.3906478881836,0,20.6075668334961,0,0,0,31.6121444702148,0,20.4681015014648,0,0,0,21.8531646728516,0,0,0,0,0,-85.7524642944336,0,30.9721069335938,0,21.0515594482422,0,0,31.6231842041016,0,0,-93.4121475219727,0,31.2932662963867,0,20.7317504882812,0,0,31.2927093505859,0,12.201789855957,0,0,-75.0597152709961,0,21.3177490234375,0,32.0111083984375,0,0,20.6630020141602,0,0,0,-83.1088256835938,0,20.2110900878906,0,31.3533935546875,0,0,0,0,20.13671875,0,0,-84.4868545532227,0,0,0,0,20.472038269043,0,31.4966201782227,0,20.7933578491211,0,24.2065658569336,0,0,-86.6050262451172,0,32.1989898681641,0,21.2522964477539,0,0,30.6335372924805,0,-93.596923828125,0,0,31.5450897216797,0,0,0,21.3197326660156,0,32.0073547363281,0,11.2192764282227,0,0,-73.2611389160156,0,19.8084716796875,0,31.6118392944336,0,19.3499374389648,0,-82.4464263916016,0,0,20.5259628295898,0,0,31.8807067871094,0,21.3160629272461,0,0,-84.4423522949219,0,20.6614837646484,0,31.4106140136719,0,0,20.2650604248047,0,23.3485946655273,0,0,-87.4216995239258,0,0,31.6174011230469,0,0,20.7894287109375,0,0,0,0,31.9376983642578,0,-94.7062225341797,0,31.8761901855469,0,21.5777435302734,0,0,31.9421920776367,0,12.395881652832,0,0,0,0,0,-75.3608474731445,0,0,0,21.1852188110352,0,32.4013748168945,0,21.6388931274414,0,-83.4875717163086,0,21.1837768554688,0,32.0724639892578,0,0,0,0,20.9860763549805,0,-83.5561447143555,0,0,0,0,0,21.4467849731445,0,32.3330230712891,0,0,0,0,21.709098815918,0,0,0,0,0,-84.2742691040039,0,0,0,20.5236892700195,0,0,31.940673828125,0,0,0,21.0573654174805,0,28.2002105712891,0,0,-91.6881790161133,0,32.0657806396484,0,0,0,0,20.9157638549805,0,0,0,0,32.1952896118164,0,0,-94.4199829101562,0,31.9333648681641,0,21.4423980712891,0,32.1290893554688,0,0,0,15.4103469848633,0,0,-77.2448577880859,0,0,0,21.2461242675781,0,32.5228805541992,0,20.1970520019531,0,-84.650505065918,0,19.673095703125,0,0,31.4753952026367,0,0,21.3775787353516,0,-83.4125442504883,0,20.5905609130859,0,0,30.3589630126953,0,0,0,0,21.2434234619141,0,0,26.6211547851562,0,0,-89.1071090698242,0,31.605224609375,0,20.8503570556641,0,31.9991302490234,0,-93.9633026123047,0,32.1307144165039,0,0,21.0482788085938,0,32.4573211669922,0,0,12.9825210571289,0,0,-74.9476318359375,0,20.9184036254883,0,0,0,0,32.3261032104492,0,21.2428817749023,0,-83.0781402587891,0,0,21.5043716430664,0,0,0,0,32.5831604003906,0,21.3733596801758,0,-82.8026733398438,0,0,21.2422027587891,0,0,0,0,30.8135223388672,0,21.2420959472656,0,-84.24560546875,0,0,0,0,20.5215225219727,0,0,0,0,32.4519882202148,0,21.5051498413086,0,27.3386611938477,0,0,-90.2124557495117,0,30.4201049804688,0,0,0,0,0,20.3897018432617,0,0,0,0,0,31.8635025024414,0,-93.0316848754883,0,31.0102005004883,0,0,0,21.1760711669922,0,32.2553558349609,0,0,0,0,0,16.1276931762695,0,0,-77.2290878295898,0,0,0,0,0,19.2089004516602,0,31.0101089477539,0,21.0450744628906,0,-84.5266189575195,0,0,0,0,20.9789886474609,0,31.8620452880859,0,19.4060974121094,0,-84.1131134033203,0,0,0,0,0,20.1926116943359,0,0,0,0,31.337646484375,0,17.1389312744141,0,0,0,0],"filename":[null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpQLEbUw/file35156dcaaf62.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    784.599    800.1545    807.9458    806.3140
#>    compute_pi0(m * 10)   7878.534   7907.2290   8275.8379   7951.3405
#>   compute_pi0(m * 100)  78643.652  79132.2350  79597.0736  79412.0240
#>         compute_pi1(m)    156.256    190.6835    238.7913    251.9995
#>    compute_pi1(m * 10)   1285.252   1343.9305   6945.8459   1400.1210
#>   compute_pi1(m * 100)  12799.868  13128.9570  18321.0153  19626.3690
#>  compute_pi1(m * 1000) 247850.603 366694.7155 369838.4960 372115.0105
#>          uq        max neval
#>     813.387    841.653    20
#>    8022.715  14182.298    20
#>   80011.507  82221.588    20
#>     280.515    315.263    20
#>    1443.590 112300.966    20
#>   22013.516  26938.885    20
#>  377821.518 481107.676    20
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
#>   memory_copy1(n) 4539.92315 3911.09853 686.521562 3800.50174 3238.98052
#>   memory_copy2(n)   79.06443   68.70586  12.870066   67.31620   57.77140
#>  pre_allocate1(n)   16.95204   14.81191   4.223668   14.50064   12.28083
#>  pre_allocate2(n)  168.93384  147.51527  26.109766  143.16383  123.35761
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>         max neval
#>  110.588006    10
#>    2.997840    10
#>    2.381923    10
#>    4.865517    10
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
#>    expr    min       lq    mean   median     uq      max neval
#>  f1(df) 243.35 246.6326 81.9666 243.9818 65.717 33.20071     5
#>  f2(df)   1.00   1.0000  1.0000   1.0000  1.000  1.00000     5
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
