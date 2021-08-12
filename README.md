# Maestria en Explotación de Datos y Descubrimiento de Conocimiento - Analisis Inteligente de Datos

## Trabajo Práctico: Asteroides Peligrosos

En este trabajo práctico se aborda el problema de detección de objetos próximos a la tierra.

### Informe

Ver [Informe](https://github.com/magistery-tps/aid-tp/blob/main/docs/Informe.pdf).

### Notebook

En el sitio [RPubs](https://rpubs.com/) se encuentra publicada la notebook desarrollada para realizar el trabajo practico. Ver [Notebook](https://rpubs.com/adrianmarino/aid-tp).

### Fuente de datos

Para abordar este trabajo práctico se seleccionó el dataset [NASA: Asteroids Classification](https://www.kaggle.com/shrutimehta/nasa-asteroids-classification). El mismo fue generador en el [sitio cneos.jpl.nasa.gov](https://cneos.jpl.nasa.gov/) el cual tiene una herramienta de consulta de datos de asteroides y comentas.  El dataset contiene 40 variables, en su mayoría cuantitativas (Continuas) y una pocas cualitativas (Categóricas y Nominales). Para más detalle ver [nasa.csv](https://github.com/magistery-tps/aid-tp/blob/main/datasets/nasa.csv).


### Descargar Proyecto

Hay dos alternativas para descargar el proyecto:

#### Descargar directa

Se puede descargar directamente desde [Aqui](https://github.com/magistery-tps/aid-tp/archive/refs/heads/main.zip). 

#### Via Git

**Paso 1**: Instalar [git](https://git-scm.com/downloads).

**Paso 2**:  Ahora si, clonamos el repositorio.

```bash
$ git clone https://github.com/magistery-tps/aid-tp.git
$ cd aid-tp
```

### Ejecutar Notebook

Para ejecutar el proyecto es necesario realizar los siguientes pasos:

**Paso 1**: Luego en RStudio abrir el archivo `scripts/notebook.Rmd`

**Paso 2**: Luego en la consola ejecutar la siguiente linea

```R
install.packages('pacman')
```

Esto ens necesario ya que para isntalar las depedencia del proyecto se utiliza el sistema de paquetes [pacman](https://github.com/trinker/pacman). Este permite meduante la función `p_load` instalar las los paquetes si cuando es necesario o cargarlo en el caso que ya estuvierna instalados.  



