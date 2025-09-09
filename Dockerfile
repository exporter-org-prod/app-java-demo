FROM alpine:3.19.5 

ARG greeting="Hello, World!"

RUN echo $greeting