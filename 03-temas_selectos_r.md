
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
#> Error in UseMethod("filter_"): no applicable method for 'filter_' applied to an object of class "c('integer', 'numeric')"
```

Ahora cargamos `dplyr`.


```r
library(dplyr)
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
#>    id           a          b         c        d
#> 1   1  1.84022928 -0.1924993 0.9495099 5.457804
#> 2   2 -1.44458544  0.1305622 2.6787260 4.145980
#> 3   3 -0.92077912  2.0060876 3.4073103 5.139202
#> 4   4 -0.71977346  0.7766780 3.7152733 1.972350
#> 5   5 -0.65873627  1.8628301 2.2500238 2.288273
#> 6   6 -0.01530886  0.3206209 3.7305864 5.232878
#> 7   7 -0.47808599  1.6952868 3.9361922 3.768566
#> 8   8  0.74046579  1.2131332 1.6541207 3.785334
#> 9   9 -2.31447665  1.8068896 3.8683007 3.715748
#> 10 10 -1.07696779  2.0470645 4.2904973 3.725135
```

Podemos crear el código para cada columna pero esto involucra *copy-paste* y 
no será muy práctico si aumenta el número de columnas:


```r
mean(df$a)
#> [1] -0.5048019
mean(df$b)
#> [1] 1.166665
mean(df$c)
#> [1] 3.048054
mean(df$d)
#> [1] 3.923127
```

Con un ciclo `for` sería:


```r
salida <- vector("double", 4)  
for (i in 1:4) {            
  salida[[i]] <- mean(df[[i + 1]])      
}
salida
#> [1] -0.5048019  1.1666654  3.0480541  3.9231270
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
#> [1] -0.5048019  1.1666654  3.0480541  3.9231270
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
#> [1]  5.5000000 -0.5048019  1.1666654  3.0480541  3.9231270
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
#> [1]  5.5000000 -0.6892549  1.4542100  3.5612918  3.7769501
col_describe(df, mean)
#> [1]  5.5000000 -0.5048019  1.1666654  3.0480541  3.9231270
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
#>  5.5000000 -0.5048019  1.1666654  3.0480541  3.9231270
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
#>   3.839   0.115   3.955
```

* **user time**: Tiempo usado por el CPU(s) para evaluar esta expresión, tiempo
que experimenta la _computadora_.

* **elapsed time**: tiempo en el _reloj_, tiempo que experimenta la persona.

Notemos que el tiempo de usuario (user) puede ser menor al tiempo transcurrido 
(elapsed),


```r
system.time(readLines("http://www.jhsph.edu"))
#>    user  system elapsed 
#>   0.021   0.001   0.546
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
#>  12.871   0.727   9.863
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
#>    0.12    0.00    0.12
plyr_st
#>    user  system elapsed 
#>   4.096   0.012   4.106
est_l_st
#>    user  system elapsed 
#>  63.918   1.224  65.112
est_r_st
#>    user  system elapsed 
#>   0.408   0.000   0.407
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

<!--html_preserve--><div id="htmlwidget-5dd8d70db7fd80240368" style="width:100%;height:600px;" class="profvis html-widget"></div>
<script type="application/json" data-for="htmlwidget-5dd8d70db7fd80240368">{"x":{"message":{"prof":{"time":[1,1,1,2,2,3,3,4,4,5,5,6,6,7,7,7,8,8,9,9,9,10,10,11,11,11,12,12,12,12,12,13,13,14,14,14,14,15,15,15,16,16,16,17,17,17,18,18,19,19,20,20,21,21,22,22,23,23,23,24,24,25,25,26,26,27,27,28,28,28,29,29,30,30,30,31,31,32,32,33,33,33,33,33,34,34,35,35,36,36,37,37,37,38,38,38,38,38,38,39,39,39,39,40,40,40,40,40,40,41,41,42,42,42,43,43,43,43,43,44,44,44,45,45,46,46,47,47,48,48,49,49,49,50,50,51,51,51,52,52,52,53,53,53,53,53,54,54,55,55,55,56,56,56,57,57,58,58,58,58,58,59,59,59,60,60,60,60,60,61,61,61,61,62,62,63,63,64,64,64,64,64,65,65,65,66,66,66,67,67,67,68,68,68,69,69,69,70,70,70,71,71,71,72,72,72,73,73,73,74,74,74,75,75,75,76,76,77,77,77,77,78,78,79,79,80,80,81,81,81,81,82,82,82,82,82,83,83,84,84,84,84,84,84,85,85,85,85,85,86,86,87,87,88,88,89,89,89,90,90,90,90,91,91,91,91,91,92,92,93,93,93,93,94,94,94,95,95,95,95,95,96,96,97,97,97,98,98,98,98,98,98,99,99,99,100,100,100,100,100,100,101,101,101,102,102,102,102,103,103,103,104,104,105,105,106,106,107,107,107,108,108,108,109,109,109,109,110,110,110,110,110,111,111,112,112,112,112,113,113,113,113,113,114,114,115,115,115,116,116,116,117,117,118,118,118,119,119,120,120,120,121,121,122,122,123,123,123,124,124,124,125,125,125,126,126,126,126,127,127,128,128,129,129,130,130,131,131,132,132,133,133,134,134,134,135,135,136,136,136,136,137,137,138,138,138,139,139,140,140,140,140,140,140,141,141,141,141,142,143,143,143,144,144,144,145,145,145,146,146,147,147,148,148,149,149,150,150,150,151,151,151,151,151,152,152,152,152,152,152,153,153,154,154,155,155,156,156,156,157,157,157,158,158,159,159,160,160,160,160,161,161,161,162,162,163,163,164,164,165,165,166,166,166,166,166,166,167,167,168,168,168,168,168,169,169,170,170,171,171,171,172,172,173,173,174,174,175,175,175,176,176,176,177,177,177,177,178,178,178,178,178,178,179,179,179,180,180,181,181,181,181,182,182,182,183,183,184,184,184,185,185,185,185,186,186,187,187,188,188,188,188,188,189,189,189,189,189,190,190,190,190,191,191,192,192,193,193,193,194,194,195,195,195,196,196,196,196,196,197,197,197,198,198,199,200,200,200,200,201,201,202,202,202,203,203,203,203,204,204,205,205,206,206,207,207,208,208,209,209,209,209,209,210,210,211,211,211,211,211,212,212,213,213,213,214,214,214,214,214,215,215,215,215,215,215,216,216,216,217,217,218,218,219,219,220,220,220,221,221,221,221,221,222,222,222,223,223,224,224,224,225,225,225,226,226,227,227,227,227,227,228,228,229,229,229,230,230,231,231,232,232,233,233,234,234,234,234,234,235,235,236,236,237,237,238,238,238,239,239,239,239,239,240,240,240,240,240,240,241,241,241,242,242,243,243,243,243,243,244,244,245,245,246,246,247,247,248,248,249,249,249,249,249,250,250,250,250,250,251,251,251,252,252,253,253,253,253,253,253,254,254,255,255,256,256,256,257,257,257,258,258,258,259,259,259,260,260,260,261,261,262,262,263,263,264,264,265,265,265,265,265,265,266,266,267,267,268,268,268,269,269,269,270,270,270,270,271,271,272,272,272,272,273,273,273,274,274,274,275,275,275,276,276,277,277,278,278,278,278,278,278,279,279,279,279,280,280,280,281,281,282,282,283,283,284,284,284,284,284,284,285,285,286,286,286,286,286],"depth":[3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,6,5,4,3,2,1,4,3,2,1,6,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,4,3,2,1,2,1,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,6,5,4,3,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,3,2,1,5,4,3,2,1,2,1,3,2,1,6,5,4,3,2,1,3,2,1,6,5,4,3,2,1,3,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,5,4,3,2,1,2,1,4,3,2,1,5,4,3,2,1,2,1,3,2,1,3,2,1,2,1,3,2,1,2,1,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,2,1,2,1,3,2,1,2,1,4,3,2,1,2,1,3,2,1,2,1,6,5,4,3,2,1,4,3,2,1,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,2,1,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1,2,1,2,1,3,2,1,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,4,3,2,1,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,4,3,2,1,2,1,2,1,3,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,1,4,3,2,1,2,1,3,2,1,4,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,3,2,1,2,1,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,3,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,3,2,1,5,4,3,2,1,6,5,4,3,2,1,3,2,1,2,1,5,4,3,2,1,2,1,2,1,2,1,2,1,2,1,5,4,3,2,1,5,4,3,2,1,3,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,2,1,3,2,1,3,2,1,4,3,2,1,2,1,4,3,2,1,3,2,1,3,2,1,3,2,1,2,1,2,1,6,5,4,3,2,1,4,3,2,1,3,2,1,2,1,2,1,2,1,6,5,4,3,2,1,2,1,5,4,3,2,1],"label":["==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","anyNA","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","dim","dim","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[",".subset2","<Anonymous>","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","all","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","n[i] <- nrow(sub_Batting)","<GC>","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","nargs","[[.data.frame","[[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","anyDuplicated.default","anyDuplicated","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","%in%","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","length","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]","length","length","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","total[i] <- sum(sub_Batting$R, na.rm = TRUE)","$","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","<GC>","NextMethod","[.factor","[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","length","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","NextMethod","[.factor","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<Anonymous>","[[.data.frame","[[","[.data.frame","[","<GC>","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","<GC>","[.data.frame","[","[[","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","length","length","dim.data.frame","dim","dim","nrow","[.data.frame","[","[.data.frame","[","==","[.data.frame","[","<GC>","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","all","[.data.frame","[","<GC>","[.data.frame","[","==","[.data.frame","[","[.data.frame","[","[.data.frame","[","sys.call","%in%","[[.data.frame","[[","[.data.frame","[","[[.data.frame","[[","[.data.frame","[","[[","[.data.frame","[","[.data.frame","[","[.data.frame","[","[.data.frame","[","is.matrix","<Anonymous>","[[.data.frame","[[","[.data.frame","[","[.data.frame","[","order","factor","as.data.frame.character","as.data.frame","data.frame"],"filenum":[null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,null,1,1,null,null,1,1,null,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,null,null,1,1,1,1,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,null,null,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,null,null,1,1,null,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,1,1,1,1,null,null,1,1,null,null,null,1,1,1,1,null,1,1,null,1,1,1,1,null,1,1,1,1,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,null,1,1,1,1,null,null,1,1,1,1,null,1,1,1,1,null,null,null,null,1,1,null,null,1,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,1,1,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,1,1,1,1,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,1,1,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,null,1,1,1,1,1,1,null,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,1,null,null,1,1,1,1,null,1,1,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,1,1,1,1,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,null,1,1,null,null,null,1,1,null,null,null,null,1,1,null,1,1,1,1,null,null,null,1,1,1,1,1,1,1,1,1,1,1,1,null,null,null,1,1,null,null,null,1,1,null,1,1,1,1,null,null,null,null,1,1,1,1,1,1,null,1,1,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,1,1,1,1,null,null,null,null,null,1,1,1,1,1,null,1,1,null,1,1,null,null,1,1,1,1,null,null,1,1,null,1,1,null,1,1,null,1,1,1,1,1,1,null,null,null,null,1,1,null,null,1,1,null,1,1,1,1,1,1,1,1,null,null,null,null,1,1,1,1,null,null,null,null,1],"linenum":[null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,null,9,9,null,null,9,9,null,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,null,null,9,9,9,9,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,null,null,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,null,null,9,9,null,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,9,9,9,9,null,null,9,9,null,null,null,9,9,9,9,null,9,9,null,9,9,9,9,null,9,9,9,9,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,null,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,null,9,9,9,9,null,null,9,9,9,9,null,9,9,9,9,null,null,null,null,9,9,null,null,9,9,11,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,9,9,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,9,9,9,9,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,9,9,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,9,9,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,null,9,9,9,9,9,9,null,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,9,null,null,9,9,9,9,null,9,9,null,null,9,9,9,9,9,9,10,10,9,9,9,9,null,null,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,9,9,9,9,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,null,9,9,null,null,null,9,9,null,null,null,null,9,9,null,9,9,9,9,null,null,null,9,9,9,9,9,9,9,9,9,9,9,9,null,null,null,9,9,null,null,null,9,9,null,9,9,9,9,null,null,null,null,9,9,9,9,9,9,null,9,9,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,9,9,9,9,null,null,null,null,null,11,9,9,9,9,null,9,9,null,9,9,null,null,9,9,9,9,null,null,9,9,null,9,9,null,9,9,null,9,9,9,9,9,9,null,null,null,null,9,9,null,null,9,9,null,9,9,9,9,9,9,9,9,null,null,null,null,9,9,9,9,null,null,null,null,13],"memalloc":[67.1587524414062,67.1587524414062,67.1587524414062,86.4412078857422,86.4412078857422,115.700546264648,115.700546264648,132.953056335449,132.953056335449,43.2843322753906,43.2843322753906,62.1129608154297,62.1129608154297,91.4379959106445,91.4379959106445,91.4379959106445,111.384796142578,111.384796142578,140.771591186523,140.771591186523,140.771591186523,43.4829559326172,43.4829559326172,74.8388595581055,74.8388595581055,74.8388595581055,95.440315246582,95.440315246582,95.440315246582,95.440315246582,95.440315246582,125.097702026367,125.097702026367,144.384521484375,144.384521484375,144.384521484375,144.384521484375,58.3054809570312,58.3054809570312,58.3054809570312,78.7749557495117,78.7749557495117,78.7749557495117,110.255226135254,110.255226135254,110.255226135254,129.933265686035,129.933265686035,43.356071472168,43.356071472168,63.3002166748047,63.3002166748047,94.7898330688477,94.7898330688477,115.649566650391,115.649566650391,146.347320556641,146.347320556641,146.347320556641,49.8514556884766,49.8514556884766,81.0110702514648,81.0110702514648,101.804611206055,101.804611206055,132.905754089355,132.905754089355,146.352172851562,146.352172851562,146.352172851562,65.5986404418945,65.5986404418945,86.2593536376953,86.2593536376953,86.2593536376953,117.55558013916,117.55558013916,136.844169616699,136.844169616699,50.5091552734375,50.5091552734375,50.5091552734375,50.5091552734375,50.5091552734375,69.8012466430664,69.8012466430664,98.4076385498047,98.4076385498047,117.30199432373,117.30199432373,146.365623474121,146.365623474121,146.365623474121,48.1511077880859,48.1511077880859,48.1511077880859,48.1511077880859,48.1511077880859,48.1511077880859,79.4479064941406,79.4479064941406,79.4479064941406,79.4479064941406,100.054862976074,100.054862976074,100.054862976074,100.054862976074,100.054862976074,100.054862976074,130.363655090332,130.363655090332,146.368057250977,146.368057250977,146.368057250977,63.9714050292969,63.9714050292969,63.9714050292969,63.9714050292969,63.9714050292969,84.8921813964844,84.8921813964844,84.8921813964844,116.778671264648,116.778671264648,137.640480041504,137.640480041504,52.0257415771484,52.0257415771484,72.163215637207,72.163215637207,103.458572387695,103.458572387695,103.458572387695,123.662322998047,123.662322998047,146.364707946777,146.364707946777,146.364707946777,56.4219741821289,56.4219741821289,56.4219741821289,87.9767532348633,87.9767532348633,87.9767532348633,87.9767532348633,87.9767532348633,109.161308288574,109.161308288574,139.330688476562,139.330688476562,139.330688476562,146.354866027832,146.354866027832,146.354866027832,73.4909744262695,73.4909744262695,93.8199920654297,93.8199920654297,93.8199920654297,93.8199920654297,93.8199920654297,125.051177978516,125.051177978516,125.051177978516,144.140991210938,144.140991210938,144.140991210938,144.140991210938,144.140991210938,58.5221328735352,58.5221328735352,58.5221328735352,58.5221328735352,79.1211776733398,79.1211776733398,110.687705993652,110.687705993652,129.974464416504,129.974464416504,129.974464416504,129.974464416504,129.974464416504,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,146.373306274414,42.7887268066406,42.7887268066406,42.7887268066406,57.6164855957031,57.6164855957031,89.5685272216797,89.5685272216797,89.5685272216797,89.5685272216797,110.296897888184,110.296897888184,140.011222839355,140.011222839355,45.2822799682617,45.2822799682617,75.7257843017578,75.7257843017578,75.7257843017578,75.7257843017578,96.6581115722656,96.6581115722656,96.6581115722656,96.6581115722656,96.6581115722656,127.35669708252,127.35669708252,146.382789611816,146.382789611816,146.382789611816,146.382789611816,146.382789611816,146.382789611816,60.2327041625977,60.2327041625977,60.2327041625977,60.2327041625977,60.2327041625977,79.5185928344727,79.5185928344727,108.190483093262,108.190483093262,126.159881591797,126.159881591797,146.362693786621,146.362693786621,146.362693786621,57.5606231689453,57.5606231689453,57.5606231689453,57.5606231689453,89.0481109619141,89.0481109619141,89.0481109619141,89.0481109619141,89.0481109619141,109.970275878906,109.970275878906,141.986572265625,141.986572265625,141.986572265625,141.986572265625,46.9286041259766,46.9286041259766,46.9286041259766,78.1596984863281,78.1596984863281,78.1596984863281,78.1596984863281,78.1596984863281,98.6201095581055,98.6201095581055,129.060050964355,129.060050964355,129.060050964355,146.377990722656,146.377990722656,146.377990722656,146.377990722656,146.377990722656,146.377990722656,64.9035110473633,64.9035110473633,64.9035110473633,85.1113662719727,85.1113662719727,85.1113662719727,85.1113662719727,85.1113662719727,85.1113662719727,116.859985351562,116.859985351562,116.859985351562,137.451629638672,137.451629638672,137.451629638672,137.451629638672,53.0346069335938,53.0346069335938,53.0346069335938,73.4369277954102,73.4369277954102,104.201858520508,104.201858520508,124.340599060059,124.340599060059,146.38362121582,146.38362121582,146.38362121582,60.1229553222656,60.1229553222656,60.1229553222656,90.9448089599609,90.9448089599609,90.9448089599609,90.9448089599609,111.679512023926,111.679512023926,111.679512023926,111.679512023926,111.679512023926,142.704948425293,142.704948425293,47.8575897216797,47.8575897216797,47.8575897216797,47.8575897216797,79.0140075683594,79.0140075683594,79.0140075683594,79.0140075683594,79.0140075683594,98.6920394897461,98.6920394897461,128.672264099121,128.672264099121,128.672264099121,146.385963439941,146.385963439941,146.385963439941,64.3215408325195,64.3215408325195,83.9328155517578,83.9328155517578,83.9328155517578,115.153541564941,115.153541564941,134.306442260742,134.306442260742,134.306442260742,49.365234375,49.365234375,69.5683212280273,69.5683212280273,100.67113494873,100.67113494873,100.67113494873,121.138381958008,121.138381958008,121.138381958008,146.332054138184,146.332054138184,146.332054138184,55.8637084960938,55.8637084960938,55.8637084960938,55.8637084960938,86.6369400024414,86.6369400024414,107.040298461914,107.040298461914,138.002540588379,138.002540588379,44.187370300293,44.187370300293,75.4157485961914,75.4157485961914,96.273063659668,96.273063659668,127.435249328613,127.435249328613,146.328163146973,146.328163146973,146.328163146973,64.1971282958984,64.1971282958984,84.8658599853516,84.8658599853516,84.8658599853516,84.8658599853516,116.620979309082,116.620979309082,135.718215942383,135.718215942383,135.718215942383,50.1601638793945,50.1601638793945,69.9799728393555,69.9799728393555,69.9799728393555,69.9799728393555,69.9799728393555,69.9799728393555,100.608695983887,100.608695983887,100.608695983887,100.608695983887,119.635406494141,146.340270996094,146.340270996094,146.340270996094,54.9482879638672,54.9482879638672,54.9482879638672,86.4446487426758,86.4446487426758,86.4446487426758,107.298126220703,107.298126220703,138.59513092041,138.59513092041,44.9157257080078,44.9157257080078,74.8360137939453,74.8360137939453,95.7588729858398,95.7588729858398,95.7588729858398,127.71257019043,127.71257019043,127.71257019043,127.71257019043,127.71257019043,146.342010498047,146.342010498047,146.342010498047,146.342010498047,146.342010498047,146.342010498047,64.987174987793,64.987174987793,84.140998840332,84.140998840332,114.969619750977,114.969619750977,133.926910400391,133.926910400391,133.926910400391,49.9671783447266,49.9671783447266,49.9671783447266,70.1044540405273,70.1044540405273,100.741516113281,100.741516113281,121.144508361816,121.144508361816,121.144508361816,121.144508361816,146.332359313965,146.332359313965,146.332359313965,56.8590927124023,56.8590927124023,87.4421844482422,87.4421844482422,107.644668579102,107.644668579102,137.23021697998,137.23021697998,146.348205566406,146.348205566406,146.348205566406,146.348205566406,146.348205566406,146.348205566406,73.3185348510742,73.3185348510742,93.9112014770508,93.9112014770508,93.9112014770508,93.9112014770508,93.9112014770508,125.067939758301,125.067939758301,145.928085327148,145.928085327148,59.116096496582,59.116096496582,59.116096496582,79.8404998779297,79.8404998779297,111.523529052734,111.523529052734,132.250419616699,132.250419616699,47.7106323242188,47.7106323242188,47.7106323242188,68.176025390625,68.176025390625,68.176025390625,99.9213638305664,99.9213638305664,99.9213638305664,99.9213638305664,120.646095275879,120.646095275879,120.646095275879,120.646095275879,120.646095275879,120.646095275879,146.357322692871,146.357322692871,146.357322692871,55.9748306274414,55.9748306274414,87.4563293457031,87.4563293457031,87.4563293457031,87.4563293457031,107.987854003906,107.987854003906,107.987854003906,139.928848266602,139.928848266602,43.9732360839844,43.9732360839844,43.9732360839844,74.0774993896484,74.0774993896484,74.0774993896484,74.0774993896484,93.5539855957031,93.5539855957031,125.031997680664,125.031997680664,144.906242370605,144.906242370605,144.906242370605,144.906242370605,144.906242370605,59.0583419799805,59.0583419799805,59.0583419799805,59.0583419799805,59.0583419799805,79.1316528320312,79.1316528320312,79.1316528320312,79.1316528320312,111.135498046875,111.135498046875,132.054756164551,132.054756164551,46.795768737793,46.795768737793,46.795768737793,66.4065322875977,66.4065322875977,96.181884765625,96.181884765625,96.181884765625,116.316017150879,116.316017150879,116.316017150879,116.316017150879,116.316017150879,146.35816192627,146.35816192627,146.35816192627,52.4366683959961,52.4366683959961,83.6557769775391,104.120536804199,104.120536804199,104.120536804199,104.120536804199,135.010429382324,135.010429382324,146.35514831543,146.35514831543,146.35514831543,71.2616195678711,71.2616195678711,71.2616195678711,71.2616195678711,89.8882827758789,89.8882827758789,121.828552246094,121.828552246094,142.685279846191,142.685279846191,58.0777969360352,58.0777969360352,78.2797622680664,78.2797622680664,109.300727844238,109.300727844238,109.300727844238,109.300727844238,109.300727844238,130.027893066406,130.027893066406,46.5384674072266,46.5384674072266,46.5384674072266,46.5384674072266,46.5384674072266,67.2595672607422,67.2595672607422,98.8744812011719,98.8744812011719,98.8744812011719,119.603981018066,119.603981018066,119.603981018066,119.603981018066,119.603981018066,146.360313415527,146.360313415527,146.360313415527,146.360313415527,146.360313415527,146.360313415527,55.7859191894531,55.7859191894531,55.7859191894531,87.9815139770508,87.9815139770508,108.963989257812,108.963989257812,140.830993652344,140.830993652344,45.9528732299805,45.9528732299805,45.9528732299805,77.6238555908203,77.6238555908203,77.6238555908203,77.6238555908203,77.6238555908203,98.4754867553711,98.4754867553711,98.4754867553711,128.506256103516,128.506256103516,146.342475891113,146.342475891113,146.342475891113,62.6738891601562,62.6738891601562,62.6738891601562,82.8694229125977,82.8694229125977,111.786148071289,111.786148071289,111.786148071289,111.786148071289,111.786148071289,131.786224365234,131.786224365234,45.6928863525391,45.6928863525391,45.6928863525391,64.513801574707,64.513801574707,94.8730239868164,94.8730239868164,115.334533691406,115.334533691406,146.154487609863,146.154487609863,51.6601486206055,51.6601486206055,51.6601486206055,51.6601486206055,51.6601486206055,82.1512298583984,82.1512298583984,102.673873901367,102.673873901367,134.147026062012,134.147026062012,146.342735290527,146.342735290527,146.342735290527,68.3172912597656,68.3172912597656,68.3172912597656,68.3172912597656,68.3172912597656,89.4308929443359,89.4308929443359,89.4308929443359,89.4308929443359,89.4308929443359,89.4308929443359,121.494361877441,121.494361877441,121.494361877441,142.018196105957,142.018196105957,58.6134414672852,58.6134414672852,58.6134414672852,58.6134414672852,58.6134414672852,79.2026901245117,79.2026901245117,111.13582611084,111.13582611084,131.921195983887,131.921195983887,46.8106536865234,46.8106536865234,66.5470962524414,66.5470962524414,97.8255081176758,97.8255081176758,97.8255081176758,97.8255081176758,97.8255081176758,118.939010620117,118.939010620117,118.939010620117,118.939010620117,118.939010620117,146.34529876709,146.34529876709,146.34529876709,52.7764739990234,52.7764739990234,83.9182662963867,83.9182662963867,83.9182662963867,83.9182662963867,83.9182662963867,83.9182662963867,103.192863464355,103.192863464355,133.416145324707,133.416145324707,146.332473754883,146.332473754883,146.332473754883,69.4961242675781,69.4961242675781,69.4961242675781,89.6232070922852,89.6232070922852,89.6232070922852,121.092185974121,121.092185974121,121.092185974121,141.54817199707,141.54817199707,141.54817199707,57.3675003051758,57.3675003051758,77.8886566162109,77.8886566162109,109.882705688477,109.882705688477,130.731742858887,130.731742858887,45.8694076538086,45.8694076538086,45.8694076538086,45.8694076538086,45.8694076538086,45.8694076538086,65.4726409912109,65.4726409912109,96.4828414916992,96.4828414916992,116.741859436035,116.741859436035,116.741859436035,146.375213623047,146.375213623047,146.375213623047,51.2469635009766,51.2469635009766,51.2469635009766,51.2469635009766,83.3056106567383,83.3056106567383,104.022567749023,104.022567749023,104.022567749023,104.022567749023,135.884727478027,135.884727478027,135.884727478027,146.37442779541,146.37442779541,146.37442779541,70.2598724365234,70.2598724365234,70.2598724365234,91.1734390258789,91.1734390258789,122.642265319824,122.642265319824,143.22811126709,143.22811126709,143.22811126709,143.22811126709,143.22811126709,143.22811126709,57.8036270141602,57.8036270141602,57.8036270141602,57.8036270141602,78.2583389282227,78.2583389282227,78.2583389282227,107.432800292969,107.432800292969,128.215209960938,128.215209960938,44.3642044067383,44.3642044067383,63.3771514892578,63.3771514892578,63.3771514892578,63.3771514892578,63.3771514892578,63.3771514892578,95.5013046264648,95.5013046264648,109.034568786621,109.034568786621,109.034568786621,109.034568786621,109.034568786621],"meminc":[0,0,0,19.2824554443359,0,29.2593383789062,0,17.2525100708008,0,-89.6687240600586,0,18.8286285400391,0,29.3250350952148,0,0,19.9468002319336,0,29.3867950439453,0,0,-97.2886352539062,0,31.3559036254883,0,0,20.6014556884766,0,0,0,0,29.6573867797852,0,19.2868194580078,0,0,0,-86.0790405273438,0,0,20.4694747924805,0,0,31.4802703857422,0,0,19.6780395507812,0,-86.5771942138672,0,19.9441452026367,0,31.489616394043,0,20.859733581543,0,30.69775390625,0,0,-96.4958648681641,0,31.1596145629883,0,20.7935409545898,0,31.1011428833008,0,13.446418762207,0,0,-80.753532409668,0,20.6607131958008,0,0,31.2962265014648,0,19.2885894775391,0,-86.3350143432617,0,0,0,0,19.2920913696289,0,28.6063919067383,0,18.8943557739258,0,29.0636291503906,0,0,-98.2145156860352,0,0,0,0,0,31.2967987060547,0,0,0,20.6069564819336,0,0,0,0,0,30.3087921142578,0,16.0044021606445,0,0,-82.3966522216797,0,0,0,0,20.9207763671875,0,0,31.8864898681641,0,20.8618087768555,0,-85.6147384643555,0,20.1374740600586,0,31.2953567504883,0,0,20.2037506103516,0,22.7023849487305,0,0,-89.9427337646484,0,0,31.5547790527344,0,0,0,0,21.1845550537109,0,30.1693801879883,0,0,7.02417755126953,0,0,-72.8638916015625,0,20.3290176391602,0,0,0,0,31.2311859130859,0,0,19.0898132324219,0,0,0,0,-85.6188583374023,0,0,0,20.5990447998047,0,31.5665283203125,0,19.2867584228516,0,0,0,0,16.3988418579102,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,-103.584579467773,0,0,14.8277587890625,0,31.9520416259766,0,0,0,20.7283706665039,0,29.7143249511719,0,-94.7289428710938,0,30.4435043334961,0,0,0,20.9323272705078,0,0,0,0,30.6985855102539,0,19.0260925292969,0,0,0,0,0,-86.1500854492188,0,0,0,0,19.285888671875,0,28.6718902587891,0,17.9693984985352,0,20.2028121948242,0,0,-88.8020706176758,0,0,0,31.4874877929688,0,0,0,0,20.9221649169922,0,32.0162963867188,0,0,0,-95.0579681396484,0,0,31.2310943603516,0,0,0,0,20.4604110717773,0,30.43994140625,0,0,17.3179397583008,0,0,0,0,0,-81.474479675293,0,0,20.2078552246094,0,0,0,0,0,31.7486190795898,0,0,20.5916442871094,0,0,0,-84.4170227050781,0,0,20.4023208618164,0,30.7649307250977,0,20.1387405395508,0,22.0430221557617,0,0,-86.2606658935547,0,0,30.8218536376953,0,0,0,20.7347030639648,0,0,0,0,31.0254364013672,0,-94.8473587036133,0,0,0,31.1564178466797,0,0,0,0,19.6780319213867,0,29.980224609375,0,0,17.7136993408203,0,0,-82.0644226074219,0,19.6112747192383,0,0,31.2207260131836,0,19.1529006958008,0,0,-84.9412078857422,0,20.2030868530273,0,31.1028137207031,0,0,20.4672470092773,0,0,25.1936721801758,0,0,-90.4683456420898,0,0,0,30.7732315063477,0,20.4033584594727,0,30.9622421264648,0,-93.8151702880859,0,31.2283782958984,0,20.8573150634766,0,31.1621856689453,0,18.8929138183594,0,0,-82.1310348510742,0,20.6687316894531,0,0,0,31.7551193237305,0,19.0972366333008,0,0,-85.5580520629883,0,19.8198089599609,0,0,0,0,0,30.6287231445312,0,0,0,19.0267105102539,26.7048645019531,0,0,-91.3919830322266,0,0,31.4963607788086,0,0,20.8534774780273,0,31.297004699707,0,-93.6794052124023,0,29.9202880859375,0,20.9228591918945,0,0,31.9536972045898,0,0,0,0,18.6294403076172,0,0,0,0,0,-81.3548355102539,0,19.1538238525391,0,30.8286209106445,0,18.9572906494141,0,0,-83.9597320556641,0,0,20.1372756958008,0,30.6370620727539,0,20.4029922485352,0,0,0,25.1878509521484,0,0,-89.4732666015625,0,30.5830917358398,0,20.2024841308594,0,29.5855484008789,0,9.11798858642578,0,0,0,0,0,-73.029670715332,0,20.5926666259766,0,0,0,0,31.15673828125,0,20.8601455688477,0,-86.8119888305664,0,0,20.7244033813477,0,31.6830291748047,0,20.7268905639648,0,-84.5397872924805,0,0,20.4653930664062,0,0,31.7453384399414,0,0,0,20.7247314453125,0,0,0,0,0,25.7112274169922,0,0,-90.3824920654297,0,31.4814987182617,0,0,0,20.5315246582031,0,0,31.9409942626953,0,-95.9556121826172,0,0,30.1042633056641,0,0,0,19.4764862060547,0,31.4780120849609,0,19.8742446899414,0,0,0,0,-85.847900390625,0,0,0,0,20.0733108520508,0,0,0,32.0038452148438,0,20.9192581176758,0,-85.2589874267578,0,0,19.6107635498047,0,29.7753524780273,0,0,20.1341323852539,0,0,0,0,30.0421447753906,0,0,-93.9214935302734,0,31.219108581543,20.4647598266602,0,0,0,30.889892578125,0,11.3447189331055,0,0,-75.0935287475586,0,0,0,18.6266632080078,0,31.9402694702148,0,20.8567276000977,0,-84.6074829101562,0,20.2019653320312,0,31.0209655761719,0,0,0,0,20.727165222168,0,-83.4894256591797,0,0,0,0,20.7210998535156,0,31.6149139404297,0,0,20.7294998168945,0,0,0,0,26.7563323974609,0,0,0,0,0,-90.5743942260742,0,0,32.1955947875977,0,20.9824752807617,0,31.8670043945312,0,-94.8781204223633,0,0,31.6709823608398,0,0,0,0,20.8516311645508,0,0,30.0307693481445,0,17.8362197875977,0,0,-83.668586730957,0,0,20.1955337524414,0,28.9167251586914,0,0,0,0,20.0000762939453,0,-86.0933380126953,0,0,18.820915222168,0,30.3592224121094,0,20.4615097045898,0,30.819953918457,0,-94.4943389892578,0,0,0,0,30.491081237793,0,20.5226440429688,0,31.4731521606445,0,12.1957092285156,0,0,-78.0254440307617,0,0,0,0,21.1136016845703,0,0,0,0,0,32.0634689331055,0,0,20.5238342285156,0,-83.4047546386719,0,0,0,0,20.5892486572266,0,31.9331359863281,0,20.7853698730469,0,-85.1105422973633,0,19.736442565918,0,31.2784118652344,0,0,0,0,21.1135025024414,0,0,0,0,27.4062881469727,0,0,-93.5688247680664,0,31.1417922973633,0,0,0,0,0,19.2745971679688,0,30.2232818603516,0,12.9163284301758,0,0,-76.8363494873047,0,0,20.127082824707,0,0,31.4689788818359,0,0,20.4559860229492,0,0,-84.1806716918945,0,20.5211563110352,0,31.9940490722656,0,20.8490371704102,0,-84.8623352050781,0,0,0,0,0,19.6032333374023,0,31.0102005004883,0,20.2590179443359,0,0,29.6333541870117,0,0,-95.1282501220703,0,0,0,32.0586471557617,0,20.7169570922852,0,0,0,31.8621597290039,0,0,10.4897003173828,0,0,-76.1145553588867,0,0,20.9135665893555,0,31.4688262939453,0,20.5858459472656,0,0,0,0,0,-85.4244842529297,0,0,0,20.4547119140625,0,0,29.1744613647461,0,20.7824096679688,0,-83.8510055541992,0,19.0129470825195,0,0,0,0,0,32.124153137207,0,13.5332641601562,0,0,0,0],"filename":[null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,"<expr>","<expr>",null,null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,null,"<expr>","<expr>","<expr>","<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,null,"<expr>","<expr>","<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>",null,null,"<expr>","<expr>",null,"<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>","<expr>","<expr>","<expr>",null,null,null,null,"<expr>"]},"interval":10,"files":[{"filename":"<expr>","content":"library(profvis)\nBatting_recent <- filter(Batting, yearID > 2006)\nprofvis({\n    players <- unique(Batting_recent$playerID)\n    n_players <- length(players)\n    total <- rep(NA, n_players)\n    n <- rep(NA, n_players)\n    for (i in 1:n_players) {\n        sub_Batting <- Batting_recent[Batting_recent$playerID == players[i], ]\n        total[i] <- sum(sub_Batting$R, na.rm = TRUE)\n        n[i] <- nrow(sub_Batting)\n    }\n    Batting_2 <- data.frame(playerID = players, total = total, n = n)\n    Batting_2[order(Batting_2$total, decreasing = TRUE), ]\n})","normpath":"<expr>"}],"prof_output":"/tmp/RtmpcYkNCk/file3c086ac4c826.prof","highlight":{"output":["^output\\$"],"gc":["^<GC>$"],"stacktrace":["^\\.\\.stacktraceo(n|ff)\\.\\.$"]},"split":"h"}},"evals":[],"jsHooks":[]}</script><!--/html_preserve-->

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
#>                   expr        min          lq        mean     median         uq
#>         compute_pi0(m)    785.788    800.6915    820.5541    807.847    823.015
#>    compute_pi0(m * 10)   7878.167   7931.5230   8026.1353   8028.282   8062.515
#>   compute_pi0(m * 100)  79091.476  79562.6585  80673.3816  80005.709  81141.576
#>         compute_pi1(m)    163.270    197.6050    683.9105    281.479    290.064
#>    compute_pi1(m * 10)   1231.740   1315.7305   1363.7501   1386.588   1411.636
#>   compute_pi1(m * 100)  13019.976  13301.3175  24349.2667  19648.059  23033.418
#>  compute_pi1(m * 1000) 216444.210 274260.0840 332130.5698 355240.049 377493.028
#>         max neval
#>     976.652    20
#>    8264.936    20
#>   86392.838    20
#>    8944.040    20
#>    1451.467    20
#>  131654.155    20
#>  491374.203    20
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
#>   memory_copy1(n) 5265.52610 4391.69379 613.016124 3722.62616 3490.43736
#>   memory_copy2(n)   93.41188   78.42937  12.501812   65.72841   65.26217
#>  pre_allocate1(n)   19.58391   16.55422   3.894929   13.89118   12.89762
#>  pre_allocate2(n)  197.60541  166.61159  24.290724  142.22108  137.06437
#>     vectorized(n)    1.00000    1.00000   1.000000    1.00000    1.00000
#>        max neval
#>  89.509074    10
#>   3.291309    10
#>   2.195925    10
#>   4.428199    10
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
#>  f1(df) 256.3766 244.5392 84.56799 234.8089 67.89026 33.35482     5
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
