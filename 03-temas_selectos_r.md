
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
#>    id           a        b        c        d
#> 1   1 -1.38151646 2.466009 3.043105 5.330889
#> 2   2 -1.75985062 1.539526 2.009359 4.070565
#> 3   3 -1.16953395 2.421151 2.906768 2.914570
#> 4   4  0.15512462 2.565270 2.423475 2.592651
#> 5   5  0.42640734 1.571614 1.221350 3.472755
#> 6   6 -2.88239409 0.159402 3.829106 3.511432
#> 7   7 -0.30029562 3.149347 2.555137 2.231716
#> 8   8  1.45430049 1.932281 3.293777 3.939430
#> 9   9  0.08101523 3.283043 2.010526 3.992541
#> 10 10 -0.32154744 5.092430 3.178330 3.290849
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.569829
mean(df$b)
#> [1] 2.418007
mean(df$c)
#> [1] 2.647093
mean(df$d)
#> [1] 3.53474
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.569829  2.418007  2.647093  3.534740
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
#> [1] -0.569829  2.418007  2.647093  3.534740
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
#> [1]  5.500000 -0.569829  2.418007  2.647093  3.534740
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
#> [1]  5.5000000 -0.3109215  2.4435802  2.7309521  3.4920936
col_describe(df, mean)
#> [1]  5.500000 -0.569829  2.418007  2.647093  3.534740
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
#>  5.500000 -0.569829  2.418007  2.647093  3.534740
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
#>   4.065   0.128   4.192
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.020   0.004   0.534
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
#>  14.751   0.828  11.242
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
#>   0.138   0.004   0.143
plyr_st
#>    user  system elapsed 
#>   4.519   0.012   4.531
est_l_st
#>    user  system elapsed 
#>  71.818   2.140  73.962
est_r_st
#>    user  system elapsed 
#>   0.407   0.020   0.428
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

<!--html_preserve--><div id="htmlwidget-97cd9d5c3d00d15e8930" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-97cd9d5c3d00d15e8930">{"x":{"message":{"prof":{"time":[1,1,1,1,2,2,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,6,6,6,7,7,8,8,9,9,10,10,10,11,11,11,12,12,12,12,12,12,13,13,14,14,14,15,15,16,16,17,17,18,18,19,19,19,20,20,20,20,21,21,22,22,22,22,23,23,23,23,23,24,24,24,25,25,25,25,26,26,27,27,28,28,29,29,29,30,30,31,31,31,32,32,32,32,32,33,33,34,34,35,35,35,35,35,36,36,37,37,37,38,38,38,39,39,39,40,40,41,41,41,41,41,42,42,42,42,42,43,43,43,44,44,44,45,45,45,45,45,46,46,47,47,47,47,47,48,48,48,48,48,49,49,49,49,50,50,50,51,51,52,52,52,53,53,53,54,54,55,55,55,56,56,56,56,57,57,57,57,57,58,58,58,59,59,60,60,61,61,62,62,62,63,63,63,64,64,65,65,66,67,67,68,68,68,68,68,69,69,69,70,70,71,71,71,72,72,72,72,72,73,73,74,74,75,75,75,76,76,77,77,77,78,78,79,79,79,79,79,80,80,81,81,82,82,82,83,83,83,84,84,84,85,85,85,86,86,86,87,87,87,88,88,88,89,89,89,90,90,90,91,91,91,92,92,92,93,93,93,93,93,94,94,95,95,95,96,96,96,97,97,97,97,97,98,98,98,98,98,98,99,99,100,100,101,101,101,102,102,103,103,103,104,104,104,104,104,104,105,105,105,106,106,106,107,107,108,108,108,108,108,108,109,109,110,110,110,111,111,111,112,112,113,113,113,114,114,114,114,115,115,115,116,116,117,117,117,118,118,119,119,120,120,120,120,120,120,121,121,122,122,123,123,124,124,125,125,125,125,125,126,126,126,126,127,127,128,128,129,129,129,130,130,130,131,131,132,132,133,133,134,134,135,135,136,136,136,137,137,138,138,138,139,139,140,140,141,141,141,141,142,142,142,143,143,143,143,144,144,145,145,146,146,147,147,147,148,148,148,149,149,149,149,149,149,150,150,151,151,152,152,152,153,153,153,154,154,155,155,156,156,156,157,157,157,158,158,159,159,160,160,161,161,162,162,163,163,163,163,163,163,164,164,165,165,166,166,166,167,167,168,168,169,169,169,169,169,169,170,170,171,171,171,172,172,173,173,173,173,174,174,175,175,176,176,176,177,177,177,178,178,179,179,180,180,181,182,182,182,183,183,183,184,184,184,184,184,185,185,185,186,186,187,187,187,187,187,188,188,189,189,190,190,190,191,191,192,192,193,193,194,194,194,194,194,194,195,196,196,196,196,197,197,197,197,197,198,198,199,199,199,200,200,200,200,200,201,201,202,202,203,203,203,203,203,204,204,204,205,205,205,206,206,207,207,208,208,208,209,209,209,209,209,209,210,210,211,211,212,212,212,212,212,213,213,214,214,214,214,214,215,215,215,216,216,217,217,217,217,217,218,218,218,219,219,220,220,220,220,220,221,221,222,222,222,222,223,223,224,224,225,225,226,226,226,227,227,227,228,228,229,229,230,230,231,231,231,231,232,232,233,233,234,234,234,234,234,235,235,235,236,236,236,237,237,238,238,239,239,239,239,240,240,241,241,241,242,242,243,243,244,244,245,245,245,245,245,245,246,246,247,247,248,248,249,249,249,250,250,250,251,251,252,252,253,253,254,254,254,254,255,255,255,255,255,256,256,256,256,256,257,257,257,257,257,257,258,258,258,259,259,259,260,260,260,261,261,261,262,262,263,263,263,264,264,264,265,265,265,266,266,267,267,268,268,268,268,268,268,269,269,269,270,270,271,271,272,272,272,273,273,273,274,274,275,275,275,275,275,276,276,276,277,277,278,278,278,279,279,279,280,280,280,281,281,282,282,283,283,284,284,285,285,285,286,286,286,286,286,287,287,288,288,289,289,289,290,290,290,291,291,291,291,292,292,293,293,293,293,293],"depth":[4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,3,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,1,3,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,5,4,3,2,1],"label":["[.factor","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","anyDuplicated","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","names","names","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","attr","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","dim","dim","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","n[i] <- nrow(sub_Batting)","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[",".row_names_info","dim.data.frame","dim","dim","nrow","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","dim","nrow","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","nrow","==","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","anyDuplicated","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","==","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","all","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,null,null,null,1,1,null,null,null,null,null,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,null,null,null,1],"linenum":[null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,11,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,11,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,11,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,11,null,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,null,null,null,9,9,null,null,null,null,null,11,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,null,null,null,13],"memalloc":[65.8291549682617,65.8291549682617,65.8291549682617,65.8291549682617,86.0947647094727,86.0947647094727,86.0947647094727,86.0947647094727,86.0947647094727,112.731056213379,112.731056213379,112.731056213379,130.113357543945,130.113357543945,130.113357543945,146.315063476562,146.315063476562,146.315063476562,59.0120239257812,59.0120239257812,59.0120239257812,59.0120239257812,59.0120239257812,59.0120239257812,88.337158203125,88.337158203125,107.88899230957,107.88899230957,137.275108337402,137.275108337402,146.326347351074,146.326347351074,146.326347351074,70.0986328125,70.0986328125,70.0986328125,90.6322402954102,90.6322402954102,90.6322402954102,90.6322402954102,90.6322402954102,90.6322402954102,120.419746398926,120.419746398926,139.383354187012,139.383354187012,139.383354187012,51.0726776123047,51.0726776123047,69.7011795043945,69.7011795043945,100.593811035156,100.593811035156,119.418594360352,119.418594360352,146.31396484375,146.31396484375,146.31396484375,49.6333694458008,49.6333694458008,49.6333694458008,49.6333694458008,78.7663726806641,78.7663726806641,99.4270401000977,99.4270401000977,99.4270401000977,99.4270401000977,130.061882019043,130.061882019043,130.061882019043,130.061882019043,130.061882019043,146.328956604004,146.328956604004,146.328956604004,60.9179916381836,60.9179916381836,60.9179916381836,60.9179916381836,81.1893157958984,81.1893157958984,105.065017700195,105.065017700195,124.420928955078,124.420928955078,146.333808898926,146.333808898926,146.333808898926,55.1467742919922,55.1467742919922,81.9106674194336,81.9106674194336,81.9106674194336,100.743576049805,100.743576049805,100.743576049805,100.743576049805,100.743576049805,126.985466003418,126.985466003418,146.146408081055,146.146408081055,59.3473358154297,59.3473358154297,59.3473358154297,59.3473358154297,59.3473358154297,79.5578842163086,79.5578842163086,107.837303161621,107.837303161621,107.837303161621,126.733352661133,126.733352661133,126.733352661133,146.281547546387,146.281547546387,146.281547546387,58.4321594238281,58.4321594238281,89.0744476318359,89.0744476318359,89.0744476318359,89.0744476318359,89.0744476318359,108.759582519531,108.759582519531,108.759582519531,108.759582519531,108.759582519531,135.791259765625,135.791259765625,135.791259765625,146.284111022949,146.284111022949,146.284111022949,68.0858688354492,68.0858688354492,68.0858688354492,68.0858688354492,68.0858688354492,88.8739395141602,88.8739395141602,116.825836181641,116.825836181641,116.825836181641,116.825836181641,116.825836181641,135.719451904297,135.719451904297,135.719451904297,135.719451904297,135.719451904297,48.7931671142578,48.7931671142578,48.7931671142578,48.7931671142578,69.0618133544922,69.0618133544922,69.0618133544922,99.6371688842773,99.6371688842773,119.44783782959,119.44783782959,119.44783782959,146.281463623047,146.281463623047,146.281463623047,51.0907363891602,51.0907363891602,79.8914489746094,79.8914489746094,79.8914489746094,100.287399291992,100.287399291992,100.287399291992,100.287399291992,129.801879882812,129.801879882812,129.801879882812,129.801879882812,129.801879882812,146.337104797363,146.337104797363,146.337104797363,59.1009674072266,59.1009674072266,78.7834167480469,78.7834167480469,108.763290405273,108.763290405273,128.444816589355,128.444816589355,128.444816589355,146.289161682129,146.289161682129,146.289161682129,60.4719696044922,60.4719696044922,91.3720016479492,91.3720016479492,111.063552856445,140.646728515625,140.646728515625,44.2085494995117,44.2085494995117,44.2085494995117,44.2085494995117,44.2085494995117,73.3413162231445,73.3413162231445,73.3413162231445,93.7432098388672,93.7432098388672,123.718322753906,123.718322753906,123.718322753906,142.873725891113,142.873725891113,142.873725891113,142.873725891113,142.873725891113,57.1313629150391,57.1313629150391,77.2768936157227,77.2768936157227,108.0458984375,108.0458984375,108.0458984375,127.400764465332,127.400764465332,146.292350769043,146.292350769043,146.292350769043,61.5907440185547,61.5907440185547,93.0123748779297,93.0123748779297,93.0123748779297,93.0123748779297,93.0123748779297,113.94278717041,113.94278717041,144.440780639648,144.440780639648,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,146.27660369873,42.7700347900391,42.7700347900391,42.7700347900391,61.6033172607422,61.6033172607422,61.6033172607422,61.6033172607422,61.6033172607422,82.1997833251953,82.1997833251953,111.718170166016,111.718170166016,111.718170166016,131.268569946289,131.268569946289,131.268569946289,46.2499008178711,46.2499008178711,46.2499008178711,46.2499008178711,46.2499008178711,67.243782043457,67.243782043457,67.243782043457,67.243782043457,67.243782043457,67.243782043457,98.3995819091797,98.3995819091797,118.147132873535,118.147132873535,146.28881072998,146.28881072998,146.28881072998,50.9735946655273,50.9735946655273,79.7727127075195,79.7727127075195,79.7727127075195,100.178131103516,100.178131103516,100.178131103516,100.178131103516,100.178131103516,100.178131103516,132.051200866699,132.051200866699,132.051200866699,146.283981323242,146.283981323242,146.283981323242,68.4266357421875,68.4266357421875,89.0236587524414,89.0236587524414,89.0236587524414,89.0236587524414,89.0236587524414,89.0236587524414,117.690475463867,117.690475463867,136.846839904785,136.846839904785,136.846839904785,49.6656494140625,49.6656494140625,49.6656494140625,69.6739120483398,69.6739120483398,99.706428527832,99.706428527832,99.706428527832,118.868766784668,118.868766784668,118.868766784668,118.868766784668,146.28719329834,146.28719329834,146.28719329834,54.1953430175781,54.1953430175781,84.3022689819336,84.3022689819336,84.3022689819336,105.031532287598,105.031532287598,136.25789642334,136.25789642334,146.294090270996,146.294090270996,146.294090270996,146.294090270996,146.294090270996,146.294090270996,70.2004470825195,70.2004470825195,90.7938995361328,90.7938995361328,122.280136108398,122.280136108398,143.528182983398,143.528182983398,57.9313278198242,57.9313278198242,57.9313278198242,57.9313278198242,57.9313278198242,77.4136199951172,77.4136199951172,77.4136199951172,77.4136199951172,106.153938293457,106.153938293457,126.294692993164,126.294692993164,144.012962341309,144.012962341309,144.012962341309,62.0056228637695,62.0056228637695,62.0056228637695,92.582763671875,92.582763671875,112.395767211914,112.395767211914,143.554527282715,143.554527282715,47.7047958374023,47.7047958374023,78.2774124145508,78.2774124145508,99.265869140625,99.265869140625,99.265869140625,128.195892333984,128.195892333984,146.303375244141,146.303375244141,146.303375244141,61.482177734375,61.482177734375,81.6247177124023,81.6247177124023,112.067901611328,112.067901611328,112.067901611328,112.067901611328,131.359512329102,131.359512329102,131.359512329102,45.54150390625,45.54150390625,45.54150390625,45.54150390625,65.6863479614258,65.6863479614258,96.9746475219727,96.9746475219727,117.968139648438,117.968139648438,146.313255310059,146.313255310059,146.313255310059,52.2342147827148,52.2342147827148,52.2342147827148,82.1568298339844,82.1568298339844,82.1568298339844,82.1568298339844,82.1568298339844,82.1568298339844,103.010597229004,103.010597229004,134.694999694824,134.694999694824,146.308807373047,146.308807373047,146.308807373047,69.2319030761719,69.2319030761719,69.2319030761719,89.6320037841797,89.6320037841797,119.091918945312,119.091918945312,138.509086608887,138.509086608887,138.509086608887,51.5791549682617,51.5791549682617,51.5791549682617,71.9777603149414,71.9777603149414,100.313018798828,100.313018798828,119.075523376465,119.075523376465,144.920471191406,144.920471191406,48.630485534668,48.630485534668,78.5447158813477,78.5447158813477,78.5447158813477,78.5447158813477,78.5447158813477,78.5447158813477,98.8139038085938,98.8139038085938,127.348915100098,127.348915100098,145.847633361816,145.847633361816,145.847633361816,61.1629409790039,61.1629409790039,81.837158203125,81.837158203125,109.783134460449,109.783134460449,109.783134460449,109.783134460449,109.783134460449,109.783134460449,129.529579162598,129.529579162598,106.135131835938,106.135131835938,106.135131835938,61.161750793457,61.161750793457,90.8037643432617,90.8037643432617,90.8037643432617,90.8037643432617,111.530792236328,111.530792236328,141.70482635498,141.70482635498,46.4702529907227,46.4702529907227,46.4702529907227,76.3751678466797,76.3751678466797,76.3751678466797,95.921272277832,95.921272277832,124.257446289062,124.257446289062,144.526794433594,144.526794433594,59.0666275024414,78.0230102539062,78.0230102539062,78.0230102539062,106.357536315918,106.357536315918,106.357536315918,125.50804901123,125.50804901123,125.50804901123,125.50804901123,125.50804901123,146.301231384277,146.301231384277,146.301231384277,58.1490936279297,58.1490936279297,86.2837600708008,86.2837600708008,86.2837600708008,86.2837600708008,86.2837600708008,106.620941162109,106.620941162109,133.444480895996,133.444480895996,146.299697875977,146.299697875977,146.299697875977,67.431266784668,67.431266784668,86.9733963012695,86.9733963012695,116.420181274414,116.420181274414,136.095161437988,136.095161437988,136.095161437988,136.095161437988,136.095161437988,136.095161437988,48.937255859375,69.0730667114258,69.0730667114258,69.0730667114258,69.0730667114258,100.42601776123,100.42601776123,100.42601776123,100.42601776123,100.42601776123,121.477577209473,121.477577209473,146.331825256348,146.331825256348,146.331825256348,56.0864868164062,56.0864868164062,56.0864868164062,56.0864868164062,56.0864868164062,84.5516357421875,84.5516357421875,104.950225830078,104.950225830078,136.367279052734,136.367279052734,136.367279052734,136.367279052734,136.367279052734,146.336547851562,146.336547851562,146.336547851562,72.1560516357422,72.1560516357422,72.1560516357422,93.0131607055664,93.0131607055664,124.889152526855,124.889152526855,145.938468933105,145.938468933105,145.938468933105,61.4009552001953,61.4009552001953,61.4009552001953,61.4009552001953,61.4009552001953,61.4009552001953,81.7319641113281,81.7319641113281,112.492088317871,112.492088317871,131.184989929199,131.184989929199,131.184989929199,131.184989929199,131.184989929199,45.4003677368164,45.4003677368164,65.6640853881836,65.6640853881836,65.6640853881836,65.6640853881836,65.6640853881836,96.8820266723633,96.8820266723633,96.8820266723633,114.393371582031,114.393371582031,141.549331665039,141.549331665039,141.549331665039,141.549331665039,141.549331665039,45.4672393798828,45.4672393798828,45.4672393798828,75.9599761962891,75.9599761962891,97.0790405273438,97.0790405273438,97.0790405273438,97.0790405273438,97.0790405273438,127.450408935547,127.450408935547,146.337455749512,146.337455749512,146.337455749512,146.337455749512,62.2544784545898,62.2544784545898,83.1067962646484,83.1067962646484,115.367797851562,115.367797851562,136.08757019043,136.08757019043,136.08757019043,50.3890609741211,50.3890609741211,50.3890609741211,68.8134689331055,68.8134689331055,98.452766418457,98.452766418457,119.500274658203,119.500274658203,146.320693969727,146.320693969727,146.320693969727,146.320693969727,56.0248718261719,56.0248718261719,87.3685684204102,87.3685684204102,106.645767211914,106.645767211914,106.645767211914,106.645767211914,106.645767211914,134.645812988281,134.645812988281,134.645812988281,146.318138122559,146.318138122559,146.318138122559,65.5371704101562,65.5371704101562,85.406623840332,85.406623840332,112.685424804688,112.685424804688,112.685424804688,112.685424804688,133.014274597168,133.014274597168,48.5528030395508,48.5528030395508,48.5528030395508,67.5039443969727,67.5039443969727,97.8625335693359,97.8625335693359,118.974891662598,118.974891662598,146.317832946777,146.317832946777,146.317832946777,146.317832946777,146.317832946777,146.317832946777,54.2583160400391,54.2583160400391,83.9621200561523,83.9621200561523,104.616325378418,104.616325378418,136.221450805664,136.221450805664,136.221450805664,146.318992614746,146.318992614746,146.318992614746,71.9633941650391,71.9633941650391,92.8147048950195,92.8147048950195,123.306045532227,123.306045532227,141.730491638184,141.730491638184,141.730491638184,141.730491638184,55.5707321166992,55.5707321166992,55.5707321166992,55.5707321166992,55.5707321166992,75.9630279541016,75.9630279541016,75.9630279541016,75.9630279541016,75.9630279541016,105.535682678223,105.535682678223,105.535682678223,105.535682678223,105.535682678223,105.535682678223,126.059913635254,126.059913635254,126.059913635254,127.075958251953,127.075958251953,127.075958251953,62.8475723266602,62.8475723266602,62.8475723266602,94.3169708251953,94.3169708251953,94.3169708251953,114.837409973145,114.837409973145,146.241310119629,146.241310119629,146.241310119629,51.6367874145508,51.6367874145508,51.6367874145508,83.1066055297852,83.1066055297852,83.1066055297852,104.413482666016,104.413482666016,136.407928466797,136.407928466797,146.308044433594,146.308044433594,146.308044433594,146.308044433594,146.308044433594,146.308044433594,73.5358123779297,73.5358123779297,73.5358123779297,94.7773132324219,94.7773132324219,126.968231201172,126.968231201172,146.309158325195,146.309158325195,146.309158325195,64.0296096801758,64.0296096801758,64.0296096801758,84.3529052734375,84.3529052734375,116.21647644043,116.21647644043,116.21647644043,116.21647644043,116.21647644043,136.409545898438,136.409545898438,136.409545898438,52.2287521362305,52.2287521362305,73.4704284667969,73.4704284667969,73.4704284667969,105.594711303711,105.594711303711,105.594711303711,126.967422485352,126.967422485352,126.967422485352,44.5588302612305,44.5588302612305,64.4892654418945,64.4892654418945,95.433235168457,95.433235168457,115.953460693359,115.953460693359,146.308303833008,146.308303833008,146.308303833008,52.0798110961914,52.0798110961914,52.0798110961914,52.0798110961914,52.0798110961914,83.6797180175781,83.6797180175781,103.806732177734,103.806732177734,133.570701599121,133.570701599121,133.570701599121,146.289726257324,146.289726257324,146.289726257324,69.2567520141602,69.2567520141602,69.2567520141602,69.2567520141602,90.1051864624023,90.1051864624023,113.60343170166,113.60343170166,113.60343170166,113.60343170166,113.60343170166],"meminc":[0,0,0,0,20.2656097412109,0,0,0,0,26.6362915039062,0,0,17.3823013305664,0,0,16.2017059326172,0,0,-87.3030395507812,0,0,0,0,0,29.3251342773438,0,19.5518341064453,0,29.386116027832,0,9.05123901367188,0,0,-76.2277145385742,0,0,20.5336074829102,0,0,0,0,0,29.7875061035156,0,18.9636077880859,0,0,-88.310676574707,0,18.6285018920898,0,30.8926315307617,0,18.8247833251953,0,26.8953704833984,0,0,-96.6805953979492,0,0,0,29.1330032348633,0,20.6606674194336,0,0,0,30.6348419189453,0,0,0,0,16.2670745849609,0,0,-85.4109649658203,0,0,0,20.2713241577148,0,23.8757019042969,0,19.3559112548828,0,21.9128799438477,0,0,-91.1870346069336,0,26.7638931274414,0,0,18.8329086303711,0,0,0,0,26.2418899536133,0,19.1609420776367,0,-86.799072265625,0,0,0,0,20.2105484008789,0,28.2794189453125,0,0,18.8960494995117,0,0,19.5481948852539,0,0,-87.8493881225586,0,30.6422882080078,0,0,0,0,19.6851348876953,0,0,0,0,27.0316772460938,0,0,10.4928512573242,0,0,-78.1982421875,0,0,0,0,20.7880706787109,0,27.9518966674805,0,0,0,0,18.8936157226562,0,0,0,0,-86.9262847900391,0,0,0,20.2686462402344,0,0,30.5753555297852,0,19.8106689453125,0,0,26.833625793457,0,0,-95.1907272338867,0,28.8007125854492,0,0,20.3959503173828,0,0,0,29.5144805908203,0,0,0,0,16.5352249145508,0,0,-87.2361373901367,0,19.6824493408203,0,29.9798736572266,0,19.681526184082,0,0,17.8443450927734,0,0,-85.8171920776367,0,30.900032043457,0,19.6915512084961,29.5831756591797,0,-96.4381790161133,0,0,0,0,29.1327667236328,0,0,20.4018936157227,0,29.9751129150391,0,0,19.155403137207,0,0,0,0,-85.7423629760742,0,20.1455307006836,0,30.7690048217773,0,0,19.354866027832,0,18.8915863037109,0,0,-84.7016067504883,0,31.421630859375,0,0,0,0,20.9304122924805,0,30.4979934692383,0,1.83582305908203,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.506568908691,0,0,18.8332824707031,0,0,0,0,20.5964660644531,0,29.5183868408203,0,0,19.5503997802734,0,0,-85.018669128418,0,0,0,0,20.9938812255859,0,0,0,0,0,31.1557998657227,0,19.7475509643555,0,28.1416778564453,0,0,-95.3152160644531,0,28.7991180419922,0,0,20.4054183959961,0,0,0,0,0,31.8730697631836,0,0,14.232780456543,0,0,-77.8573455810547,0,20.5970230102539,0,0,0,0,0,28.6668167114258,0,19.156364440918,0,0,-87.1811904907227,0,0,20.0082626342773,0,30.0325164794922,0,0,19.1623382568359,0,0,0,27.4184265136719,0,0,-92.0918502807617,0,30.1069259643555,0,0,20.7292633056641,0,31.2263641357422,0,10.0361938476562,0,0,0,0,0,-76.0936431884766,0,20.5934524536133,0,31.4862365722656,0,21.248046875,0,-85.5968551635742,0,0,0,0,19.482292175293,0,0,0,28.7403182983398,0,20.140754699707,0,17.7182693481445,0,0,-82.0073394775391,0,0,30.5771408081055,0,19.8130035400391,0,31.1587600708008,0,-95.8497314453125,0,30.5726165771484,0,20.9884567260742,0,0,28.9300231933594,0,18.1074829101562,0,0,-84.8211975097656,0,20.1425399780273,0,30.4431838989258,0,0,0,19.2916107177734,0,0,-85.8180084228516,0,0,0,20.1448440551758,0,31.2882995605469,0,20.9934921264648,0,28.3451156616211,0,0,-94.0790405273438,0,0,29.9226150512695,0,0,0,0,0,20.8537673950195,0,31.6844024658203,0,11.6138076782227,0,0,-77.076904296875,0,0,20.4001007080078,0,29.4599151611328,0,19.4171676635742,0,0,-86.929931640625,0,0,20.3986053466797,0,28.3352584838867,0,18.7625045776367,0,25.8449478149414,0,-96.2899856567383,0,29.9142303466797,0,0,0,0,0,20.2691879272461,0,28.5350112915039,0,18.4987182617188,0,0,-84.6846923828125,0,20.6742172241211,0,27.9459762573242,0,0,0,0,0,19.7464447021484,0,-23.3944473266602,0,0,-44.9733810424805,0,29.6420135498047,0,0,0,20.7270278930664,0,30.1740341186523,0,-95.2345733642578,0,0,29.904914855957,0,0,19.5461044311523,0,28.3361740112305,0,20.2693481445312,0,-85.4601669311523,18.9563827514648,0,0,28.3345260620117,0,0,19.1505126953125,0,0,0,0,20.7931823730469,0,0,-88.1521377563477,0,28.1346664428711,0,0,0,0,20.3371810913086,0,26.8235397338867,0,12.8552169799805,0,0,-78.8684310913086,0,19.5421295166016,0,29.4467849731445,0,19.6749801635742,0,0,0,0,0,-87.1579055786133,20.1358108520508,0,0,0,31.3529510498047,0,0,0,0,21.0515594482422,0,24.854248046875,0,0,-90.2453384399414,0,0,0,0,28.4651489257812,0,20.3985900878906,0,31.4170532226562,0,0,0,0,9.96926879882812,0,0,-74.1804962158203,0,0,20.8571090698242,0,31.8759918212891,0,21.04931640625,0,0,-84.5375137329102,0,0,0,0,0,20.3310089111328,0,30.760124206543,0,18.6929016113281,0,0,0,0,-85.7846221923828,0,20.2637176513672,0,0,0,0,31.2179412841797,0,0,17.511344909668,0,27.1559600830078,0,0,0,0,-96.0820922851562,0,0,30.4927368164062,0,21.1190643310547,0,0,0,0,30.3713684082031,0,18.8870468139648,0,0,0,-84.0829772949219,0,20.8523178100586,0,32.2610015869141,0,20.7197723388672,0,0,-85.6985092163086,0,0,18.4244079589844,0,29.6392974853516,0,21.0475082397461,0,26.8204193115234,0,0,0,-90.2958221435547,0,31.3436965942383,0,19.2771987915039,0,0,0,0,28.0000457763672,0,0,11.6723251342773,0,0,-80.7809677124023,0,19.8694534301758,0,27.2788009643555,0,0,0,20.3288497924805,0,-84.4614715576172,0,0,18.9511413574219,0,30.3585891723633,0,21.1123580932617,0,27.3429412841797,0,0,0,0,0,-92.0595169067383,0,29.7038040161133,0,20.6542053222656,0,31.6051254272461,0,0,10.097541809082,0,0,-74.355598449707,0,20.8513107299805,0,30.491340637207,0,18.424446105957,0,0,0,-86.1597595214844,0,0,0,0,20.3922958374023,0,0,0,0,29.5726547241211,0,0,0,0,0,20.5242309570312,0,0,1.01604461669922,0,0,-64.228385925293,0,0,31.4693984985352,0,0,20.5204391479492,0,31.4039001464844,0,0,-94.6045227050781,0,0,31.4698181152344,0,0,21.3068771362305,0,31.9944458007812,0,9.90011596679688,0,0,0,0,0,-72.7722320556641,0,0,21.2415008544922,0,32.19091796875,0,19.3409271240234,0,0,-82.2795486450195,0,0,20.3232955932617,0,31.8635711669922,0,0,0,0,20.1930694580078,0,0,-84.180793762207,0,21.2416763305664,0,0,32.1242828369141,0,0,21.3727111816406,0,0,-82.4085922241211,0,19.9304351806641,0,30.9439697265625,0,20.5202255249023,0,30.3548431396484,0,0,-94.2284927368164,0,0,0,0,31.5999069213867,0,20.1270141601562,0,29.7639694213867,0,0,12.7190246582031,0,0,-77.0329742431641,0,0,0,20.8484344482422,0,23.4982452392578,0,0,0,0],"filename":[null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,null,"<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/Rtmp91aDMs/file3c0eeb7488d.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>         compute_pi0(m)    788.105    806.2515    826.6973    814.9675
#>    compute_pi0(m * 10)   7896.722   7948.8485   8321.3329   7965.9530
#>   compute_pi0(m * 100)  79296.436  79518.1505  80014.2670  79944.4280
#>         compute_pi1(m)    184.710    219.1345    723.1173    358.4875
#>    compute_pi1(m * 10)   1397.065   1458.6700   1982.8167   1601.0340
#>   compute_pi1(m * 100)  15005.610  16643.1575  47161.5926  23534.7805
#>  compute_pi1(m * 1000) 325797.720 397593.6175 453677.0154 486264.0435
#>           uq        max neval
#>     830.6275    934.443    20
#>    8061.6790  14401.547    20
#>   80545.2345  80958.251    20
#>     370.0985   8566.333    20
#>    1619.6385  10028.098    20
#>   29768.7230 203937.296    20
#>  502128.7830 520720.276    20
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
#>   memory_copy1(n) 5823.31338 4418.65085 666.562517 3995.97501 2960.327875
#>   memory_copy2(n)   90.38341   66.70730  11.670404   60.79373   48.323535
#>  pre_allocate1(n)   19.37436   13.92823   3.827837   12.52007    9.305453
#>  pre_allocate2(n)  193.51823  143.45205  22.557590  129.31826   98.031200
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.000000
#>        max neval
#>  93.780767    10
#>   3.166652    10
#>   2.344455    10
#>   4.231939    10
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
#>    expr      min       lq     mean   median      uq      max neval
#>  f1(df) 268.9056 276.1792 109.1003 363.4296 85.9051 54.55636     5
#>  f2(df)   1.0000   1.0000   1.0000   1.0000  1.0000  1.00000     5
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
