# CubeR - ARPASMR
## Un pacchetto R per accedere ai Data Cubes archiviati in Rasdaman tramite servizi WCS and WCPS.

Pacchetto R creato per l'accesso al database RASDAMAN dell'Agenzia sfruttandone i servizi OGC.

Repository modificato a partire dal repository clonato [mattia6690/CubeR](https://github.com/mattia6690/CubeR)

### Installazione 
The package can be directly imported in R by typing:
```r
library(devtools)
devtools::install_github("ARPASMR/myCubeR@head")
```

### Utilizzo e funzionalità
Questo pacchetto offre le seguenti diverse possibilità per interagire con i Data Cubes:

#### 1. Esplorazione dei dati e dei servizi
E' possibile attraverso l'utilizzo delle funzioni *GetCapability* e *DescribeCoverage* ottenere alcune informazioni sui servizi e sulle coverage disponibili.
Tutte le funzioni che iniziano con `coverage_get_` permettono di ricavare i metadata corrispondenti ad una coverage specificata.

#### 2. Scaricamento dei dati
La funzione `get_coverage()` permette di scaricare una coverage o parte di essa fruttando la funzione *GetCoverage* dei servizi WCS.

E' stata creata poi una funzione particolare `image_from_coverage()` per scaricare in particolare immagini multibanda.

#### 3. Elaborazione dei dati
La funzione `WPCS_query()` permette di codificare una query passata in formato *rasql* (rasdaman Query Language), comporre l'url per inviare la richiesta del servizio secondo lo standard WCS OGC.

Altre funzioni di processamento dei dati già implementate:
- `pixel_history()`
