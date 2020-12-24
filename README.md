# Rendimiento de I/O
## Entorno
Para desarrollar este experimento trabajaremos sobre una imagen que crearemos con el siguiente `dockerfile`:

```
FROM ubuntu:latest as layer0
RUN mkdir -p /layers/0
COPY data /layers/0

FROM layer0 as layers
RUN mkdir -p /layers/1
RUN mkdir -p /layers/2
RUN mkdir -p /layers/3
RUN mkdir -p /layers/4
RUN mkdir -p /layers/5
RUN mkdir -p /layers/6
RUN mkdir -p /layers/7
RUN mkdir -p /layers/8
RUN mkdir -p /layers/9

FROM layers 
COPY data /layers/9
```

Es decir creraremos una imagen que tendrá el mismo archivo copiado en diferentes capas del UnionFS de la imagen.
Haremos experimetos un fichero de datos grande (100MB) y pequeño (100B). Estudiaremos la velocidad de I/O con el fin de analizar las prestaciones del sistema de ficheros `overlay2`, una implementacion de un *union file system*.

## Detalles

Para cada experimento, primero construiremos las imagen docker sobre las que lo realizaremos. Usando el comando `docker build -t <tag> .`.

Una vez contruidas las imágenes procedemos a ejecutar el fichero `test.sh` que se encarga de ejecutar el experimento. Usaremos la herramienta `dd` para medir la velocidad de I/O y guardaremos los resultados en un fichero `results.txt`.

Usando la herramienta [`dive`](https://www.github.com/wagoodman/dive) podemos visualizar las capas de la imagen construida:

<img src="0 - Layers View/0.0.png" width=400/>
<img src="0 - Layers View/0.1.png" width=400/>
<img src="0 - Layers View/1.png" width=400/>
<img src="0 - Layers View/2.png" width=400/>
<img src="0 - Layers View/9.0.png" width=400/>
<img src="0 - Layers View/9.1.png" width=400/>

## Ejecución
### I/O de fichero grande (100MB)

`<tag> = layers`

El ficher de datos `data` consta de 100MB de ceros. Creado con las instrucción `dd if=/dev/zero/ of=data bs=1M count=100`.
Además, crearemos un volumen llamado *volume*: `docker volume create volume`. Dentro del volumen copiaremos el fichero de datos `data`.
Analizaremos 5 situaciones diferentes:
- Velocidad en el sistema *host* del contenedor.
- Velocidad de una montura del tipo *bind*.
- Velocidad de un *volumen* de datos.
- Velocidad en una capa alta (*high layer*). La capa alta se refiere a la capa de lectura just debajo de la capa de entrada-salida del contenedor (`/layers/9`).
- Velocidad en una capa baja (*low layer*). La capa baja se refiere a una de las primeras capas creadas al contruir la imagen (`/layers/0`).

Podemos encontrar el script del experimento [aquí](<1 - 100MB/test.sh>).

<img src="1 - 100MB/plot/write_speed/plot0.png" width=500/>
<img src="1 - 100MB/plot/overwrite_speed/plot0.png" width=500/>
<img src="1 - 100MB/plot/read_speed/plot0.png" width=500/>

### I/O de fichero pequeño (100B)

`<tag> = layers_byte`

El ficher de datos `data` consta de 100B de ceros. Creado con las instrucción `dd if=/dev/zero/ of=data bs=1 count=100`.
Además, crearemos un volumen llamado *volume*: `docker volume create volume_byte`. Dentro del volumen copiaremos el fichero de datos `data`.

Podemos encontrar el script del experimento [aquí](<2 - 100B/test.sh>).

<img src="2 - 100B/plot/write_speed/plot0.png" width=500/>
<img src="2 - 100B/plot/overwrite_speed/plot0.png" width=500/>
<img src="2 - 100B/plot/read_speed/plot0.png" width=500/>

## Conclusiones

Si trabajamos con ficheros pequeños, es recomendable trabajar con volúmenes o con la capa de entrada salida del contenedor (*thin layer*).

Si trabajamos con ficheros grandes, a la hora de leer los datos, obtendremos prestaciones ligeramente superiores con *bind mounts*. A la hora de escribir si vamos a crear muchos archivos nuevos será mejor usar volúmenes de datos o trabajar con la *thin layer*. Si vamos a sobreecribir o actualizar el mismo fichero (i.e. una base de datos) la mejor opción será usar un *bind mount*.