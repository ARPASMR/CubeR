# CubeR - ARPASMR

Pacchetto R creato per l'accesso al database RASDAMAN dell'Agenzia sfruttandone i servizi OGC

Repository modificato a partire dal repository clonato [mattia6690/CubeR](https://github.com/mattia6690/CubeR)

## Install

This R-Package provides several functions for interacting with databases WCS/WCPS based on OGC standards. We use the [Rasdaman implementation](http://saocompute.eurac.edu/rasdaman/ows) in order to host Copernicus Sentinel Data in multidimensionla arrays (Data Cubes) as used for the [Sentinel Alpine Observatory](http://sao.eurac.edu/)
The package can be directly imported in R by typing:

```r
library(devtools)
devtools::install_github("ARPASMR/myCubeR:ARPASMR", ref = "ARPASMR")
```
