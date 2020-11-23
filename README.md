[![CRAN](http://www.r-pkg.org/badges/version/myCubeR)](https://cran.r-project.org/package=myCubeR)

# CubeR - ARPASMR
## Un pacchetto R per accedere ai Data Cubes archiviati in Rasdaman tramite servizi WCS and WCPS.

Pacchetto R creato per l'accesso al database RASDAMAN dell'Agenzia sfruttandone i servizi OGC. 
Repository modificato a partire dal repository [mattia6690/CubeR](https://github.com/mattia6690/CubeR)

### Installazione 
Il pacchetto può essere importato in R come segue:
```r
library(devtools)
devtools::install_github("ARPASMR/myCubeR@HEAD")
```

### Configurazione
NB Nel caso in cui dovesse cambiasse la root principale dei servizi OGC di Rasdaman, ora http://10.10.0.28:8081/rasdaman/ows , è necessario aggiornare l'url all'iterno delle funzioni *getCapability* e *createWCS_URLs* definite nello script *R/coverage_metadata.R* .

### Documentazione
Oltre a quanto illustrato brevemente di seguito, una volta scaricato il pacchetto, è possibile accedere alla documentazione o attarverso RStudio o aprendo la pagina ***/docs/index.html***.

### Utilizzo e funzionalità
Questo pacchetto offre le seguenti diverse possibilità per interagire con i Data Cubes:

#### 1. Esplorazione dei dati e dei servizi
E' possibile attraverso l'utilizzo delle funzioni *GetCapability* e *DescribeCoverage* ottenere alcune informazioni sui servizi e sulle coverage disponibili.
Tutte le funzioni che iniziano con `coverage_get_` permettono di ricavare i metadata corrispondenti ad una coverage specificata.

#### 2. Scaricamento dei dati
La funzione `get_coverage()` permette di scaricare una coverage o parte di essa fruttando la funzione *GetCoverage* dei servizi WCS.

E' stata creata poi una funzione particolare `image_from_coverage()` per scaricare in particolare raster multibanda.

#### 3. Elaborazione dei dati
La funzione `WPCS_query()` permette, a partire da una query passata in formato *rasql* (rasdaman Query Language), di comporre ed inviare una richiesta secondo lo standard WCPS OGC e interpretare e scaricare la risposta del servizio.

Funzioni di processamento dei dati già implementate "ad hoc":
- `pixel_history()`
