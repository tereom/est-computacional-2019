
--- 
title: "Estadística Computacional"
author: "María Teresa Ortiz"
site: bookdown::bookdown_site
documentclass: book
bibliography: [book.bib]
biblio-style: apalike
link-citations: yes
github-repo: tereom/est-computacional-2019
description: "Curso de estadística computacional, Maestría en Ciencia de Datos, ITAM 2019."
---


# Información del curso {-}

Notas del curso *Estadística Computacional* de los programas de maestría en 
Ciencia de Datos y en Computación del ITAM. Las notas fueron desarrolladas en 
2014 por Teresa Ortiz quien las actualiza anualmente. En caso de encontrar 
errores o tener sugerencias del material se agradece la propuesta de 
correcciones mediante [pull requests](https://github.com/tereom/est-computacional-2019).

#### Ligas {-}

Notas: https://tereom.github.io/est-computacional-2019/    
Correo: teresa.ortiz.mancera@gmail.com   
GitHub: https://github.com/tereom/est-computacional-2019 

#### Agradecimientos {-}
Se agradecen las contriubuciones a estas notas de [\@felipegonzalez](https://github.com/felipegonzalez)
y [\@mkokotchikova](https://github.com/mkokotchikova).

</br>

<a rel="license" href="http://creativecommons.org/licenses/by/4.0/"><img alt="Licencia Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by/4.0/88x31.png" /></a><br />Este trabajo está bajo una <a rel="license" href="http://creativecommons.org/licenses/by/4.0/">Licencia Creative Commons Atribución 4.0 Internacional</a>.


## Temario {-}

1. **Manipulación y visualización de datos**

-   Principios de visualización.
-   Reestructura y manipulación de datos.
-   Temas selectos de programación en R: iteración, programación funcional, 
rendimiento.

Referencias: @tufte06, @cleveland93, @r4ds, @advr, @R-ggplot2 @R-dplyr, 
@R-tidyr, @R-purrr.

2. **Inferencia y remuestreo**

-   Repaso de probabilidad.
-   Muestreo y probabilidad.
-   Inferencia.
-   El principio del *plug-in*.
-   Bootstrap
    -   Cálculo de errores estándar e intervalos de confianza.
    -   Estructuras de datos complejos.

Referencias: @ross, @efron, @chihara.

3. **Modelos de probabilidad y simulación**

-   Variables aleatorias y modelos probabilísticos.
-   Familias importantes: discretas y continuas.
-   Teoría básica de simulación
    -   El generador uniforme de números aleatorios.
    -   Pruebas de aleatoriedad.
    -   Simulación de variables aleatorias.
-   Simulación para modelos gráficos
    -   Modelos probabilíticos gráficos.
    -   Simulación de modelos para: inferencia, evaluación de ajuste, 
    cálculos de potencia/tamaño de muestra.
-   Inferencia paramétrica y remuestreo
    -   Modelos paramétricos.
    -   Máxima verosimilitud y bootstrap paramétrico.
-   Inferencia de gráficas

 Referencias: @gelman-hill, @hastie.

4. **Métodos computacionales e inferencia Bayesiana**

-   Inferencia bayesiana.
-   Métodos diretos
    -   Familias conjugadas.
    -   Aproximación por cuadrícula.
-   MCMC
    -   Cadenas de Markov.
    -   Metropolis.
    -   Muestreador de Gibbs.
    -   Monte Carlo Hamiltoniano.
    -   Diagnósticos de convergencia.

Referencias: @kruschke, @gelman-bayesian, @gelman-hill.

### Calificación {-}

* Tareas 20% (se envían por correo con título *EstComp-TareaXX*).

* Exámen parcial (proyecto y exámen en clase) 40%.

* Examen final 40%.

### Software {-}

- R: https://www.r-project.org
- RStudio: https://www.rstudio.com
- Stan: http://mc-stan.org

### Otros recursos {-}

* [Socrative](https://b.socrative.com/login/student/) (Room **ESTCOMP**):
Para encuestas y ejercicios en clase.


* [Lista de correos](https://docs.google.com/spreadsheets/d/1ZNdpl-_c495FRb1ZEZ-TpxFDBk5Uai-9Ms-IHgsYq-E/edit?usp=sharing): Suscribete si quieres recibir noticias del curso.

## Noticias {-}

Los dos premios más importantes en estadística se entregaron en 2019 a Hadley
Whickham y a Bradley Efron, gran parte de nuestro curso se desarrolla 
en torno a las contribuciones de estos dos estadísticos:

* [Hadley Wickham](https://community.amstat.org/copss/awards/presidents) 
cuyos paquetes, libros y artículos son los recursos esenciales para la primera
parte del curso, ganó en 2019 el reconocido premio [COPSS](https://en.wikipedia.org/wiki/COPSS_Presidents%27_Award):
    
    *"Por la importancia de su trabajo en el computo estadístico, visualización, 
    gráficas y análisis de datos; por desarrollar e implementar una extensa
    ifraestructura computacional para el análisis de datos a través del 
    *software* R; por hacer el pensamiento estadístico y el cómputo accesible
    a una gran audiencia; y por realzar el importante papel de la estadística
    entre los científicos de datos." (2019 Presidents' Award)*

* [Bradley Efron](https://statprize.org/index.cfm) creador del bootstrap, que
estudiaremos como segunda sección del curso, fue seleccionado en 2018 para
recibir el *premio internacional en estadística* como reconocimiento al
*bootstrap*, un método que desarrolló en 1977 para calcular incertidumbre en
resultados científicos y que ha tenido un impacto extraordinario en muchos
ámbitos.
    
    *"A pesar de que la estadística no ofrece una píldora mágica para la 
    investigación científica cuantitativa, el bootstrap es el mejor analgésico
    jamás producido " (Xiao-Li Meng, proff. at Harvard University.)*
