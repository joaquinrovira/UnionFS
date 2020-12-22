<!-- # Rendimiento de I/O
## Entorno
Para desarrollar este experimento trabajaremos sobre una imagen que crearemos con el siguiente `dockerfile`:

```
FROM ubuntu:latest
RUN mkdir -p /layers/0
COPY data /layers/0
RUN mkdir -p /layers/1
COPY data /layers/1
RUN mkdir -p /layers/2
COPY data /layers/2
RUN mkdir -p /layers/3
COPY data /layers/3
RUN mkdir -p /layers/4
COPY data /layers/4
RUN mkdir -p /layers/5
COPY data /layers/5
RUN mkdir -p /layers/6
COPY data /layers/6
RUN mkdir -p /layers/7
COPY data /layers/7
RUN mkdir -p /layers/8
COPY data /layers/8
RUN mkdir -p /layers/9
COPY data /layers/9
```

Es decir creraremos una imagen que tendrá el mismo archivo copiado en diferentes capas del UnionFS de la imagen.

```
$ docker run --rm \
> --mount source=volume,target=/volume layers \
> dd if=/dev/zero of=/dev/null bs=1M count=100 conv=sync
100+0 records in
100+0 records out
104857600 bytes (105 MB, 100 MiB) copied, 0.00602329 s, 17.4 GB/s
``` -->