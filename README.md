# CubeR - ARPASMR
## An R-package to access Rasdaman data cubes via WCS and WCPS queries.

This R-Package provides several functions for interacting with databases WCS/WCPS based on OGC standards. We use the [ARPA LOMBARDIA Rasdaman implementation](http://10.10.0.28:8081/rasdaman/ows) in order to host some data in multidimensionla arrays (Data Cubes).

The package has been modified and adapted from the Repository [mattia6690/CubeR](https://github.com/mattia6690/CubeR)

#### Install 
The package can be directly imported in R by typing:
```r
library(devtools)
devtools::install_github("ARPASMR/myCubeR")
```

The package automatically builds the WCS/WCPS requests (each function has an automatic query handler translating the input in WCS/WCPS requests), hands them over to the Rasdaman Server, parses the XML response from the Rasdaman server and collects the data or the informations desired.
This package offers several possibilities to interact with Data Cubes as listed below.

#### 1. Discovery 
Discover the whole Rasdaman environment and get informationas about specific Coverages/Data Cubes (by calling the '''''GetCapailities''''' and the '''''DescribeCoverage''''' functionality).

All the functions, beginning with `coverage_get_`, are explicitly for retrieving metadata corresponding to each of the coverage.

#### 2. Get the Data
Get the Data or download the entire or a part of a raster or a subset of a Coverage.
The specific function `image from coverage` returns easily either an image or a subset of an image.

#### 3. Processing/Performe specific query

The package allows to handle every desiderd query (passed in "processing expression" format) translating in WCPS queries and hands them over to the Rasdaman Server.

The queries can perform mathematical and statistical operations between multiple spatial subsets.

See [Rasdaman Tutorial - OGS WCPS](https://tutorial.rasdaman.org/rasdaman-and-ogc-ws-tutorial/#ogc-web-services-web-coverage-processing-service) for useful examples and more information.

'''Eg. Get the different values of a pixel over time, get averages, etc..'''

### Maintainers

Susanna Grasso


<img src="https://www.arpalombardia.it/PublishingImages/logo-ARPA-Lombardia.svg" height="50">

