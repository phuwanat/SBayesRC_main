FROM zhiliz/sbayesrc:0.2.6

MAINTAINER Phuwanat Sakornsakolpat (phuwanat.sak@mahidol.edu)

RUN apt-get update
RUN apt-get -y install xz-utils