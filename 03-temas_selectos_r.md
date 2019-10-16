
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
#> 1   1  0.9720199 0.3567229 2.0620052 5.554408
#> 2   2  1.0380648 2.1459572 0.9922734 4.477916
#> 3   3  0.3314743 2.8328294 1.9945291 3.496701
#> 4   4  1.0454911 1.9178422 3.2598599 3.509178
#> 5   5  1.6284273 1.7385888 2.3950898 3.610878
#> 6   6 -1.3340813 2.2820277 2.2311158 5.189622
#> 7   7 -1.4070197 2.4662158 2.5863766 4.808643
#> 8   8 -0.5064357 1.0983963 3.4250941 4.360119
#> 9   9  0.5220938 1.6650127 1.4273158 3.045556
#> 10 10  0.5632792 1.8505292 2.5104394 4.347464
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] 0.2853314
mean(df$b)
#> [1] 1.835412
mean(df$c)
#> [1] 2.28841
mean(df$d)
#> [1] 4.240049
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] 0.2853314 1.8354122 2.2884099 4.2400486
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
#> [1] 0.2853314 1.8354122 2.2884099 4.2400486
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
#> [1] 5.5000000 0.2853314 1.8354122 2.2884099 4.2400486
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
#> [1] 5.5000000 0.5426865 1.8841857 2.3131028 4.3537915
col_describe(df, mean)
#> [1] 5.5000000 0.2853314 1.8354122 2.2884099 4.2400486
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
#> 5.5000000 0.2853314 1.8354122 2.2884099 4.2400486
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
#>   4.025   0.128   4.151
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.014   0.008   0.731
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
#>  14.990   0.852  11.114
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
#>   0.119   0.000   0.118
plyr_st
#>    user  system elapsed 
#>   4.276   0.008   4.282
est_l_st
#>    user  system elapsed 
#>  68.294   1.012  69.275
est_r_st
#>    user  system elapsed 
#>   0.406   0.000   0.405
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

<!--html_preserve--><div id="htmlwidget-67ec1af0f117a5624b24" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-67ec1af0f117a5624b24">{"x":{"message":{"prof":{"time":[1,1,2,2,3,3,3,4,4,5,5,5,6,6,7,7,7,7,8,8,9,9,9,9,9,9,10,10,10,10,11,11,12,12,13,13,14,14,14,14,15,15,16,16,17,17,18,18,18,19,19,19,20,20,21,21,22,22,23,23,24,24,24,25,25,25,25,25,26,26,26,27,27,27,27,27,28,28,29,29,29,29,29,30,30,30,31,31,32,32,33,33,33,33,33,33,34,34,35,35,36,36,37,37,37,37,37,37,38,38,38,39,39,40,40,40,40,40,40,41,41,42,42,42,43,43,43,43,43,44,44,44,44,45,45,45,45,45,46,46,47,47,47,48,48,49,49,49,50,50,50,51,51,52,52,52,53,53,54,54,55,55,55,55,55,56,56,57,57,58,58,58,58,58,58,59,59,60,60,60,61,61,62,62,62,62,62,62,63,63,63,64,64,64,65,65,65,66,66,66,67,67,67,67,68,68,69,69,70,70,71,71,72,72,72,73,73,73,73,73,73,74,74,74,75,75,75,76,76,76,77,77,78,78,78,78,78,79,79,79,80,80,80,81,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,92,92,93,93,94,94,94,94,95,95,96,96,97,97,97,97,98,98,99,99,100,100,100,101,101,102,102,103,103,104,104,105,105,106,106,106,106,107,107,108,108,108,108,108,109,109,110,110,111,111,112,112,113,113,113,114,114,115,115,115,115,115,116,116,117,117,117,118,118,118,119,119,119,120,120,121,121,122,122,123,123,123,123,123,124,124,125,125,125,125,125,126,126,127,127,127,128,128,129,129,130,130,131,131,132,132,133,133,134,134,134,134,134,135,135,136,136,136,137,137,138,138,139,139,139,139,140,140,141,141,142,142,142,142,143,143,144,144,145,145,145,146,146,147,147,148,148,148,149,149,150,150,151,151,152,152,153,153,153,153,153,153,154,154,154,155,155,155,156,156,157,157,158,158,159,159,160,160,160,161,161,161,161,162,162,163,163,163,164,164,164,165,165,165,166,166,167,167,168,168,168,169,169,170,170,170,170,170,171,171,172,172,173,173,174,174,175,175,175,176,176,176,176,176,176,177,177,177,178,178,179,179,179,179,179,180,180,181,181,182,182,182,183,183,184,184,184,184,184,185,185,185,185,186,186,187,187,188,188,189,189,190,190,191,191,191,192,192,192,192,192,192,193,193,193,194,194,195,195,195,195,195,196,196,196,196,197,197,197,198,198,199,199,199,199,199,199,200,200,201,201,201,202,202,202,202,202,203,203,204,204,205,205,205,206,206,206,207,207,207,208,208,208,209,209,210,210,211,211,212,212,212,212,212,212,213,213,214,214,214,215,215,216,216,216,216,216,217,217,217,217,217,218,218,219,219,219,219,220,220,221,221,222,222,223,223,223,224,224,225,225,225,225,225,226,226,227,227,228,228,228,229,229,229,229,229,229,230,230,231,231,232,232,232,233,233,234,234,235,235,235,236,236,237,237,238,238,238,238,239,239,240,240,241,241,241,242,242,243,243,244,244,244,244,245,245,246,246,246,247,247,248,248,248,248,249,249,249,250,250,251,251,252,252,252,252,252,253,253,253,253,254,254,255,255,255,256,256,257,257,258,258,259,259,260,260,260,261,261,262,262,263,263,264,264,265,265,266,266,266,266,266,267,267,267,267,267,268,268,269,269,269,270,270,270,270,270,271,271,271,271,271,272,272,273,273,274,274,275,275,276,276,277,277,277,278,278,278,279,279,279,280,280,281,281,282,282,282,282,282,282,283,283,283,284,284,285,285,285,286,286,286,286,286,287,287,287,288,288,288,288,288,289,289,289,290,290,290,290,290],"depth":[2,1,2,1,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1],"label":["[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","dim","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","nrow","[[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","dim","dim","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","nrow","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","c","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","nrow","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","<GC>","[.data.frame","[","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,1,1,null,null,1,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,null,null,null,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,1,1,null,null,null,null,1],"linenum":[9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,11,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,9,9,null,null,11,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,null,11,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,11,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,null,null,null,9,9,null,null,9,9,9,9,null,9,9,10,10,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,9,9,null,null,null,null,13],"memalloc":[66.4538040161133,66.4538040161133,87.1141815185547,87.1141815185547,112.766395568848,112.766395568848,112.766395568848,130.213882446289,130.213882446289,146.284324645996,146.284324645996,146.284324645996,61.0141983032227,61.0141983032227,92.1104888916016,92.1104888916016,92.1104888916016,92.1104888916016,111.073486328125,111.073486328125,140.525955200195,140.525955200195,140.525955200195,140.525955200195,140.525955200195,140.525955200195,43.2366638183594,43.2366638183594,43.2366638183594,43.2366638183594,74.3959274291992,74.3959274291992,94.4060211181641,94.4060211181641,124.064865112305,124.064865112305,144.007133483887,144.007133483887,144.007133483887,144.007133483887,56.4852523803711,56.4852523803711,76.4927368164062,76.4927368164062,106.861312866211,106.861312866211,125.947006225586,125.947006225586,125.947006225586,146.283226013184,146.283226013184,146.283226013184,54.5263595581055,54.5263595581055,84.1136932373047,84.1136932373047,104.710159301758,104.710159301758,136.067001342773,136.067001342773,146.298217773438,146.298217773438,146.298217773438,68.235466003418,68.235466003418,68.235466003418,68.235466003418,68.235466003418,88.7689514160156,88.7689514160156,88.7689514160156,120.125953674316,120.125953674316,120.125953674316,120.125953674316,120.125953674316,141.053939819336,141.053939819336,53.6071624755859,53.6071624755859,53.6071624755859,53.6071624755859,53.6071624755859,73.945556640625,73.945556640625,73.945556640625,104.912117004395,104.912117004395,124.461845397949,124.461845397949,146.312637329102,146.312637329102,146.312637329102,146.312637329102,146.312637329102,146.312637329102,56.2968444824219,56.2968444824219,87.3378219604492,87.3378219604492,107.08512878418,107.08512878418,136.86841583252,136.86841583252,136.86841583252,136.86841583252,136.86841583252,136.86841583252,146.316520690918,146.316520690918,146.316520690918,69.1594848632812,69.1594848632812,89.3060531616211,89.3060531616211,89.3060531616211,89.3060531616211,89.3060531616211,89.3060531616211,118.829330444336,118.829330444336,138.187782287598,138.187782287598,138.187782287598,48.8913879394531,48.8913879394531,48.8913879394531,48.8913879394531,48.8913879394531,68.7759857177734,68.7759857177734,68.7759857177734,68.7759857177734,98.029167175293,98.029167175293,98.029167175293,98.029167175293,98.029167175293,118.895690917969,118.895690917969,146.316383361816,146.316383361816,146.316383361816,51.779914855957,51.779914855957,81.565673828125,81.565673828125,81.565673828125,101.834892272949,101.834892272949,101.834892272949,131.226287841797,131.226287841797,146.315605163574,146.315605163574,146.315605163574,63.065803527832,63.065803527832,83.9928131103516,83.9928131103516,112.851196289062,112.851196289062,112.851196289062,112.851196289062,112.851196289062,132.722244262695,132.722244262695,45.2895202636719,45.2895202636719,65.1738891601562,65.1738891601562,65.1738891601562,65.1738891601562,65.1738891601562,65.1738891601562,96.1963424682617,96.1963424682617,115.554626464844,115.554626464844,115.554626464844,145.207649230957,145.207649230957,48.1107864379883,48.1107864379883,48.1107864379883,48.1107864379883,48.1107864379883,48.1107864379883,79.2036437988281,79.2036437988281,79.2036437988281,99.6791152954102,99.6791152954102,99.6791152954102,129.597534179688,129.597534179688,129.597534179688,146.324203491211,146.324203491211,146.324203491211,59.5309295654297,59.5309295654297,59.5309295654297,59.5309295654297,79.7383804321289,79.7383804321289,111.095649719238,111.095649719238,132.281890869141,132.281890869141,46.0154266357422,46.0154266357422,66.15673828125,66.15673828125,66.15673828125,97.1941833496094,97.1941833496094,97.1941833496094,97.1941833496094,97.1941833496094,97.1941833496094,116.939147949219,116.939147949219,116.939147949219,146.261299133301,146.261299133301,146.261299133301,49.3645706176758,49.3645706176758,49.3645706176758,80.3181228637695,80.3181228637695,100.525161743164,100.525161743164,100.525161743164,100.525161743164,100.525161743164,129.65064239502,129.65064239502,129.65064239502,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,146.310859680176,42.7394332885742,42.7394332885742,42.7394332885742,47.0700378417969,47.0700378417969,67.2129974365234,67.2129974365234,97.8468856811523,97.8468856811523,117.655792236328,117.655792236328,117.655792236328,117.655792236328,146.261863708496,146.261863708496,51.1381988525391,51.1381988525391,81.9108505249023,81.9108505249023,81.9108505249023,81.9108505249023,103.093757629395,103.093757629395,133.991645812988,133.991645812988,146.324615478516,146.324615478516,146.324615478516,68.7191390991211,68.7191390991211,89.5825271606445,89.5825271606445,121.198669433594,121.198669433594,142.053596496582,142.053596496582,55.2726516723633,55.2726516723633,75.3483276367188,75.3483276367188,75.3483276367188,75.3483276367188,107.096839904785,107.096839904785,128.023590087891,128.023590087891,128.023590087891,128.023590087891,128.023590087891,43.0729598999023,43.0729598999023,63.2802810668945,63.2802810668945,95.0202255249023,95.0202255249023,115.755714416504,115.755714416504,146.323081970215,146.323081970215,146.323081970215,50.2934112548828,50.2934112548828,81.1223754882812,81.1223754882812,81.1223754882812,81.1223754882812,81.1223754882812,101.785163879395,101.785163879395,131.173927307129,131.173927307129,131.173927307129,146.261932373047,146.261932373047,146.261932373047,65.8406295776367,65.8406295776367,65.8406295776367,86.2384490966797,86.2384490966797,116.869430541992,116.869430541992,137.792602539062,137.792602539062,52.7177505493164,52.7177505493164,52.7177505493164,52.7177505493164,52.7177505493164,72.5270233154297,72.5270233154297,103.367256164551,103.367256164551,103.367256164551,103.367256164551,103.367256164551,123.244148254395,123.244148254395,146.27180480957,146.27180480957,146.27180480957,57.4481430053711,57.4481430053711,89.0741424560547,89.0741424560547,109.806343078613,109.806343078613,141.359405517578,141.359405517578,46.9515609741211,46.9515609741211,78.0499114990234,78.0499114990234,98.7094116210938,98.7094116210938,98.7094116210938,98.7094116210938,98.7094116210938,130.003768920898,130.003768920898,146.272148132324,146.272148132324,146.272148132324,67.2239685058594,67.2239685058594,88.0232696533203,88.0232696533203,119.254852294922,119.254852294922,119.254852294922,119.254852294922,139.663063049316,139.663063049316,53.9084091186523,53.9084091186523,74.0585861206055,74.0585861206055,74.0585861206055,74.0585861206055,106.129844665527,106.129844665527,127.319053649902,127.319053649902,134.307540893555,134.307540893555,134.307540893555,63.3561935424805,63.3561935424805,93.7341079711914,93.7341079711914,114.393264770508,114.393264770508,114.393264770508,146.016265869141,146.016265869141,50.8329467773438,50.8329467773438,81.9952774047852,81.9952774047852,101.150444030762,101.150444030762,132.379425048828,132.379425048828,132.379425048828,132.379425048828,132.379425048828,132.379425048828,146.287048339844,146.287048339844,146.287048339844,66.5709533691406,66.5709533691406,66.5709533691406,86.9050521850586,86.9050521850586,117.799911499023,117.799911499023,137.806701660156,137.806701660156,51.9441223144531,51.9441223144531,71.295783996582,71.295783996582,71.295783996582,101.211006164551,101.211006164551,101.211006164551,101.211006164551,121.876113891602,121.876113891602,146.276679992676,146.276679992676,146.276679992676,55.1638717651367,55.1638717651367,55.1638717651367,85.155387878418,85.155387878418,85.155387878418,105.556449890137,105.556449890137,135.470024108887,135.470024108887,146.292541503906,146.292541503906,146.292541503906,68.6081161499023,68.6081161499023,88.151008605957,88.151008605957,88.151008605957,88.151008605957,88.151008605957,118.584037780762,118.584037780762,137.870185852051,137.870185852051,50.4401168823242,50.4401168823242,70.1148834228516,70.1148834228516,100.813720703125,100.813720703125,100.813720703125,121.539154052734,121.539154052734,121.539154052734,121.539154052734,121.539154052734,121.539154052734,146.268768310547,146.268768310547,146.268768310547,54.6418762207031,54.6418762207031,83.7663955688477,83.7663955688477,83.7663955688477,83.7663955688477,83.7663955688477,104.033012390137,104.033012390137,134.466049194336,134.466049194336,146.27123260498,146.27123260498,146.27123260498,68.9403076171875,68.9403076171875,88.7476196289062,88.7476196289062,88.7476196289062,88.7476196289062,88.7476196289062,120.101570129395,120.101570129395,120.101570129395,120.101570129395,141.023490905762,141.023490905762,54.3493423461914,54.3493423461914,75.2070922851562,75.2070922851562,106.813362121582,106.813362121582,127.538459777832,127.538459777832,146.296279907227,146.296279907227,146.296279907227,61.3023147583008,61.3023147583008,61.3023147583008,61.3023147583008,61.3023147583008,61.3023147583008,92.328987121582,92.328987121582,92.328987121582,113.183067321777,113.183067321777,142.825805664062,142.825805664062,142.825805664062,142.825805664062,142.825805664062,45.8250579833984,45.8250579833984,45.8250579833984,45.8250579833984,75.4696273803711,75.4696273803711,75.4696273803711,94.095458984375,94.095458984375,124.06852722168,124.06852722168,124.06852722168,124.06852722168,124.06852722168,124.06852722168,143.682395935059,143.682395935059,57.1059036254883,57.1059036254883,57.1059036254883,77.3051605224609,77.3051605224609,77.3051605224609,77.3051605224609,77.3051605224609,107.936614990234,107.936614990234,127.54606628418,127.54606628418,146.300903320312,146.300903320312,146.300903320312,60.7801971435547,60.7801971435547,60.7801971435547,90.7522354125977,90.7522354125977,90.7522354125977,111.215370178223,111.215370178223,111.215370178223,142.564643859863,142.564643859863,45.8279724121094,45.8279724121094,77.2415771484375,77.2415771484375,98.3584213256836,98.3584213256836,98.3584213256836,98.3584213256836,98.3584213256836,98.3584213256836,129.119407653809,129.119407653809,146.30517578125,146.30517578125,146.30517578125,61.8942260742188,61.8942260742188,81.4399795532227,81.4399795532227,81.4399795532227,81.4399795532227,81.4399795532227,112.858283996582,112.858283996582,112.858283996582,112.858283996582,112.858283996582,133.715980529785,133.715980529785,47.4694671630859,47.4694671630859,47.4694671630859,47.4694671630859,67.8621139526367,67.8621139526367,98.4183197021484,98.4183197021484,119.598571777344,119.598571777344,146.284439086914,146.284439086914,146.284439086914,54.9475555419922,54.9475555419922,85.9637832641602,85.9637832641602,85.9637832641602,85.9637832641602,85.9637832641602,107.011085510254,107.011085510254,137.961784362793,137.961784362793,97.6590957641602,97.6590957641602,97.6590957641602,72.6494369506836,72.6494369506836,72.6494369506836,72.6494369506836,72.6494369506836,72.6494369506836,92.6486968994141,92.6486968994141,123.991149902344,123.991149902344,145.04125213623,145.04125213623,145.04125213623,59.4072952270508,59.4072952270508,79.5393600463867,79.5393600463867,111.342506408691,111.342506408691,111.342506408691,132.065124511719,132.065124511719,45.8322372436523,45.8322372436523,65.2424163818359,65.2424163818359,65.2424163818359,65.2424163818359,96.4532165527344,96.4532165527344,117.041343688965,117.041343688965,146.285491943359,146.285491943359,146.285491943359,51.4733047485352,51.4733047485352,81.3084106445312,81.3084106445312,100.257873535156,100.257873535156,100.257873535156,100.257873535156,129.764266967773,129.764266967773,146.287742614746,146.287742614746,146.287742614746,64.8510665893555,64.8510665893555,84.5217895507812,84.5217895507812,84.5217895507812,84.5217895507812,114.750839233398,114.750839233398,114.750839233398,134.093437194824,134.093437194824,47.7359008789062,47.7359008789062,67.7346267700195,67.7346267700195,67.7346267700195,67.7346267700195,67.7346267700195,99.0784759521484,99.0784759521484,99.0784759521484,99.0784759521484,120.126335144043,120.126335144043,146.286987304688,146.286987304688,146.286987304688,55.8657913208008,55.8657913208008,85.1063613891602,85.1063613891602,104.905822753906,104.905822753906,135.194709777832,135.194709777832,146.274894714355,146.274894714355,146.274894714355,66.2914581298828,66.2914581298828,84.9764022827148,84.9764022827148,115.986633300781,115.986633300781,136.966911315918,136.966911315918,52.3926773071289,52.3926773071289,71.6689071655273,71.6689071655273,71.6689071655273,71.6689071655273,71.6689071655273,101.564849853516,101.564849853516,101.564849853516,101.564849853516,101.564849853516,121.627235412598,121.627235412598,146.277770996094,146.277770996094,146.277770996094,57.3768768310547,57.3768768310547,57.3768768310547,57.3768768310547,57.3768768310547,88.9113616943359,88.9113616943359,88.9113616943359,88.9113616943359,88.9113616943359,109.825378417969,109.825378417969,141.622840881348,141.622840881348,46.2973327636719,46.2973327636719,77.7006301879883,77.7006301879883,99.0729141235352,99.0729141235352,131.066528320312,131.066528320312,131.066528320312,146.276260375977,146.276260375977,146.276260375977,66.6216430664062,66.6216430664062,66.6216430664062,87.2730178833008,87.2730178833008,119.004051208496,119.004051208496,140.376365661621,140.376365661621,140.376365661621,140.376365661621,140.376365661621,140.376365661621,53.7537078857422,53.7537078857422,53.7537078857422,74.2739410400391,74.2739410400391,106.267555236816,106.267555236816,106.267555236816,127.050117492676,127.050117492676,127.050117492676,127.050117492676,127.050117492676,121.453086853027,121.453086853027,121.453086853027,62.1458435058594,62.1458435058594,62.1458435058594,62.1458435058594,62.1458435058594,94.0083389282227,94.0083389282227,94.0083389282227,112.917358398438,112.917358398438,112.917358398438,112.917358398438,112.917358398438],"meminc":[0,0,20.6603775024414,0,25.652214050293,0,0,17.4474868774414,0,16.070442199707,0,0,-85.2701263427734,0,31.0962905883789,0,0,0,18.9629974365234,0,29.4524688720703,0,0,0,0,0,-97.2892913818359,0,0,0,31.1592636108398,0,20.0100936889648,0,29.6588439941406,0,19.942268371582,0,0,0,-87.5218811035156,0,20.0074844360352,0,30.3685760498047,0,19.085693359375,0,0,20.3362197875977,0,0,-91.7568664550781,0,29.5873336791992,0,20.5964660644531,0,31.3568420410156,0,10.2312164306641,0,0,-78.0627517700195,0,0,0,0,20.5334854125977,0,0,31.3570022583008,0,0,0,0,20.9279861450195,0,-87.44677734375,0,0,0,0,20.3383941650391,0,0,30.9665603637695,0,19.5497283935547,0,21.8507919311523,0,0,0,0,0,-90.0157928466797,0,31.0409774780273,0,19.7473068237305,0,29.7832870483398,0,0,0,0,0,9.44810485839844,0,0,-77.1570358276367,0,20.1465682983398,0,0,0,0,0,29.5232772827148,0,19.3584518432617,0,0,-89.2963943481445,0,0,0,0,19.8845977783203,0,0,0,29.2531814575195,0,0,0,0,20.8665237426758,0,27.4206924438477,0,0,-94.5364685058594,0,29.785758972168,0,0,20.2692184448242,0,0,29.3913955688477,0,15.0893173217773,0,0,-83.2498016357422,0,20.9270095825195,0,28.8583831787109,0,0,0,0,19.8710479736328,0,-87.4327239990234,0,19.8843688964844,0,0,0,0,0,31.0224533081055,0,19.358283996582,0,0,29.6530227661133,0,-97.0968627929688,0,0,0,0,0,31.0928573608398,0,0,20.475471496582,0,0,29.9184188842773,0,0,16.7266693115234,0,0,-86.7932739257812,0,0,0,20.2074508666992,0,31.3572692871094,0,21.1862411499023,0,-86.2664642333984,0,20.1413116455078,0,0,31.0374450683594,0,0,0,0,0,19.7449645996094,0,0,29.322151184082,0,0,-96.896728515625,0,0,30.9535522460938,0,20.2070388793945,0,0,0,0,29.1254806518555,0,0,16.6602172851562,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.571426391602,0,0,4.33060455322266,0,20.1429595947266,0,30.6338882446289,0,19.8089065551758,0,0,0,28.606071472168,0,-95.123664855957,0,30.7726516723633,0,0,0,21.1829071044922,0,30.8978881835938,0,12.3329696655273,0,0,-77.6054763793945,0,20.8633880615234,0,31.6161422729492,0,20.8549270629883,0,-86.7809448242188,0,20.0756759643555,0,0,0,31.7485122680664,0,20.9267501831055,0,0,0,0,-84.9506301879883,0,20.2073211669922,0,31.7399444580078,0,20.7354888916016,0,30.5673675537109,0,0,-96.029670715332,0,30.8289642333984,0,0,0,0,20.6627883911133,0,29.3887634277344,0,0,15.088005065918,0,0,-80.4213027954102,0,0,20.397819519043,0,30.6309814453125,0,20.9231719970703,0,-85.0748519897461,0,0,0,0,19.8092727661133,0,30.8402328491211,0,0,0,0,19.8768920898438,0,23.0276565551758,0,0,-88.8236618041992,0,31.6259994506836,0,20.7322006225586,0,31.5530624389648,0,-94.407844543457,0,31.0983505249023,0,20.6595001220703,0,0,0,0,31.2943572998047,0,16.2683792114258,0,0,-79.0481796264648,0,20.7993011474609,0,31.2315826416016,0,0,0,20.4082107543945,0,-85.7546539306641,0,20.1501770019531,0,0,0,32.0712585449219,0,21.189208984375,0,6.98848724365234,0,0,-70.9513473510742,0,30.3779144287109,0,20.6591567993164,0,0,31.6230010986328,0,-95.1833190917969,0,31.1623306274414,0,19.1551666259766,0,31.2289810180664,0,0,0,0,0,13.9076232910156,0,0,-79.7160949707031,0,0,20.334098815918,0,30.8948593139648,0,20.0067901611328,0,-85.8625793457031,0,19.3516616821289,0,0,29.9152221679688,0,0,0,20.6651077270508,0,24.4005661010742,0,0,-91.1128082275391,0,0,29.9915161132812,0,0,20.4010620117188,0,29.91357421875,0,10.8225173950195,0,0,-77.6844253540039,0,19.5428924560547,0,0,0,0,30.4330291748047,0,19.2861480712891,0,-87.4300689697266,0,19.6747665405273,0,30.6988372802734,0,0,20.7254333496094,0,0,0,0,0,24.7296142578125,0,0,-91.6268920898438,0,29.1245193481445,0,0,0,0,20.2666168212891,0,30.4330368041992,0,11.8051834106445,0,0,-77.330924987793,0,19.8073120117188,0,0,0,0,31.3539505004883,0,0,0,20.9219207763672,0,-86.6741485595703,0,20.8577499389648,0,31.6062698364258,0,20.72509765625,0,18.7578201293945,0,0,-84.9939651489258,0,0,0,0,0,31.0266723632812,0,0,20.8540802001953,0,29.6427383422852,0,0,0,0,-97.0007476806641,0,0,0,29.6445693969727,0,0,18.6258316040039,0,29.9730682373047,0,0,0,0,0,19.6138687133789,0,-86.5764923095703,0,0,20.1992568969727,0,0,0,0,30.6314544677734,0,19.6094512939453,0,18.7548370361328,0,0,-85.5207061767578,0,0,29.972038269043,0,0,20.463134765625,0,0,31.3492736816406,0,-96.7366714477539,0,31.4136047363281,0,21.1168441772461,0,0,0,0,0,30.760986328125,0,17.1857681274414,0,0,-84.4109497070312,0,19.5457534790039,0,0,0,0,31.4183044433594,0,0,0,0,20.8576965332031,0,-86.2465133666992,0,0,0,20.3926467895508,0,30.5562057495117,0,21.1802520751953,0,26.6858673095703,0,0,-91.3368835449219,0,31.016227722168,0,0,0,0,21.0473022460938,0,30.9506988525391,0,-40.3026885986328,0,0,-25.0096588134766,0,0,0,0,0,19.9992599487305,0,31.3424530029297,0,21.0501022338867,0,0,-85.6339569091797,0,20.1320648193359,0,31.8031463623047,0,0,20.7226181030273,0,-86.2328872680664,0,19.4101791381836,0,0,0,31.2108001708984,0,20.5881271362305,0,29.2441482543945,0,0,-94.8121871948242,0,29.8351058959961,0,18.949462890625,0,0,0,29.5063934326172,0,16.5234756469727,0,0,-81.4366760253906,0,19.6707229614258,0,0,0,30.2290496826172,0,0,19.3425979614258,0,-86.357536315918,0,19.9987258911133,0,0,0,0,31.3438491821289,0,0,0,21.0478591918945,0,26.1606521606445,0,0,-90.4211959838867,0,29.2405700683594,0,19.7994613647461,0,30.2888870239258,0,11.0801849365234,0,0,-79.9834365844727,0,18.684944152832,0,31.0102310180664,0,20.9802780151367,0,-84.5742340087891,0,19.2762298583984,0,0,0,0,29.8959426879883,0,0,0,0,20.062385559082,0,24.6505355834961,0,0,-88.9008941650391,0,0,0,0,31.5344848632812,0,0,0,0,20.9140167236328,0,31.7974624633789,0,-95.3255081176758,0,31.4032974243164,0,21.3722839355469,0,31.9936141967773,0,0,15.2097320556641,0,0,-79.6546173095703,0,0,20.6513748168945,0,31.7310333251953,0,21.372314453125,0,0,0,0,0,-86.6226577758789,0,0,20.5202331542969,0,31.9936141967773,0,0,20.7825622558594,0,0,0,0,-5.59703063964844,0,0,-59.307243347168,0,0,0,0,31.8624954223633,0,0,18.9090194702148,0,0,0,0],"filename":["<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpzUQs30/file390b64edd478.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    791.702    796.7545    814.8681    807.5650
#>    compute_pi0(m * 10)   7892.743   7950.3850   7992.7774   7976.6620
#>   compute_pi0(m * 100)  78709.888  79375.2510  80106.9603  79609.3025
#>         compute_pi1(m)    157.056    176.5150    252.1801    280.7315
#>    compute_pi1(m * 10)   1250.347   1308.5335   1425.9487   1361.2920
#>   compute_pi1(m * 100)  13030.220  17817.6185  26125.5451  21104.5765
#>  compute_pi1(m * 1000) 306243.117 363455.6315 377128.0673 371681.2375
#>           uq        max neval
#>     826.3655    864.849    20
#>    8019.7270   8147.878    20
#>   80160.0270  85594.123    20
#>     301.2640    342.161    20
#>    1453.3455   2483.585    20
#>   23524.6560 137240.687    20
#>  389304.1095 506850.390    20
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
#>   memory_copy1(n) 5537.66372 3643.18790 647.294604 3661.43817 3199.62205
#>   memory_copy2(n)   92.05892   60.67468  11.974893   61.27808   55.02194
#>  pre_allocate1(n)   19.80452   13.09347   4.032161   12.88534   11.22214
#>  pre_allocate2(n)  199.14559  131.01304  24.186412  129.88204  111.66135
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  92.152355    10
#>   2.868176    10
#>   2.333278    10
#>   4.521106    10
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
#>  f1(df) 267.5907 263.2331 89.74749 263.7807 68.32082 40.95099     5
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
