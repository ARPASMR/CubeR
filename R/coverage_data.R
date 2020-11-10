#' @title Get a raster from coverage
#' @description This function provides the possibility to interact directly with the data cubes. It gives the option to write the images to
#' memory or on the hard drive for further computation.
#' @param coverage name of the coverage [character]
#' @param slice_E image slicing coordinates in x-direction [character]
#' @param slice_N image slicing coordinates in y-direction [character]
#' @param date an available timestamp [character]
#' @param res_eff factor to scale raster resolution [numeric]
#' @param format image format in WCPS query [character]
#' @param bands coverage bands to calculate raster. Can contain one or more bands from the same coverage [character]
#' @param filename If the raster image should be saved please digit a path and a filename. [character]
#' @param query_url Web Coverage Service (WCS) for processing the query.
#' This URL can be built with the *createWCS_URLs* function. [character]
#' @import httr
#' @import tiff
#' @import png
#' @import jpeg
#' @importFrom raster raster extent aggregate stack writeRaster
#' @importFrom sp CRS
#' @importFrom urltools url_encode
#' @export
image_from_coverage <- function(coverage, slice_E, slice_N, DATA,
                                res_eff=1, format="TIFF", bands=NULL,filename=NULL,
                                query_url=NULL){

  if(is.null(query_url)) query_url<-createWCS_URLs(type="Query")

  ref_Id<-coverage_get_coordinate_reference(coverage=coverage)
  coord_sys<-coverage_get_coordsys(coverage=coverage)
  if(is.null(bands)){
         bands=coverage_get_bands(desc_url=NULL, coverage)
	     print("Viene restituito il valore di tutte le bande del raster")
    } else {
	     bands=bands
	     print(paste0("La banda scelta è", bands))
	}
    bands_len <- length(bands)
    rasters <- list()

  for(i in 1:bands_len){

#MODIFICATO PER RASDAMAN ARPA LOMBARDIA
#    query <- paste0('for c in (', coverage, ') return encode (c.', bands[i],
#                    '[',
#                    coord_sys[2], '(', slice_E[1], ':', slice_E[2], ')', ',',
#                    coord_sys[3], '(', slice_N[1], ':', slice_N[2], ')', ',',
#                    coord_sys[1], '("', DATA, '")',
#                    '],',
#                    '"image/',tolower(format),'"',')')
    
   query <- paste0('for ', bands[i],' in (', coverage, ') return encode (',bands[i],
                    '[',
                    coord_sys[2], '(', slice_E[1], ':', slice_E[2], ')', ',',
                    coord_sys[3], '(', slice_N[1], ':', slice_N[2], ')', ',',
                    coord_sys[1], '("', DATA, '")',
                    '],',
                    '"image/',tolower(format),'"',')')

    query_encode  <- urltools::url_encode(query)
    request       <- paste(query_url, query_encode, collapse = NULL, sep="")

    res <- GET(request)
    bin <- content(res, "raw")
    to_img  <- get(paste0("read",toupper(format)))
    img     <- suppressWarnings(to_img(bin, as.is = T))

    ras_ext <- extent(c(as.numeric(slice_E), as.numeric(slice_N)))
    ras     <- raster(img)
    proj4string(ras) <- CRS(paste0("+init=epsg:",ref_Id))
    extent(ras)      <- ras_ext

    if(res_eff == 1){

      rasters[[i]] <- ras

    } else {

      ras_aggregate <- aggregate(ras, fact=res_eff, expand = FALSE)
      print(ras_aggregate)
      rasters[[i]] <- ras_aggregate
    }
  }

  if(!is.null(filename)){

    rasters<-stack(rasters)
    writeRaster(rasters,filename)

  }else{return(rasters)}
}


#' @title Get WPCS query result
#' @description This function provides the possibility to interact directly with the data cubes. It gives the option to execute a WPCS query in txt/csv format 
#' @param proper_query The proper WPCS query for the selected coverage, in WPCS query language (eg. 'for c in (rh_ana) return encode(c[E(515200),N(5037430), ansi("2020-10-01")], "text/csv" )'. The script takes care of encoding it
#' @param formato output format for the WCPS query result. [character]
#' The format coul be image format (image/png, image/tiff, image/jpeg, image/bmp) or text/csv format (text/csv) 
#' @param query_url Web Coverage Service (WCS) for processing the query. This URL can be built with the *createWCS_URLs* function. [character]
#' @param filename downloadfile name (all path)
#' @import httr
#' @import RCurl
#' @import raster
#' @importFrom urltools url_encode
#' @export
WPCS_query <- function(proper_query=NULL, formato=NULL, filename=NULL, query_url=NULL) {

  if(is.null(proper_query) || is.null(formato)) stop('Inserire per forza i parametri proper_query e formato')

  if(is.null(query_url)) query_url<-createWCS_URLs(type="Query")
  query_encode  <- urltools::url_encode(proper_query)
  request<- paste(query_url, query_encode, collapse = NULL, sep="")
  res <- GET(request)
  
  #image_format<-["image/png", "image/tiff", "image/jpeg", "image/bmp"]
  if (formato == "text/csv") {
	 out<- content(res, "text")
	 return(out)
  } else if (formato == "image/tiff") {
	 # Save to local disk
	 #library(RCurl)
	 bin = getBinaryURL(request)
	 con <- file(filename, open = "wb")
	 writeBin(bin, con)
	 close(con)
	 print (paste0("Raster salvato: ",filename))
    } else if (formato == "image/png") {
     print("Formato immagine")

	 # library(raster)
	 # bin = getBinaryURL(request)
	 # s=raster(bin)
	 # crs=paste0("+init=epsg:",ref_Id)
	 # crs(bin) <- CRS(crs)
     # #crs(bin2) <- CRS("+proj=longlat +datum=WGS84")
	 # #x <- writeRaster(bin, 'output.tif', overwrite=TRUE)
	 # x <- writeRaster(s, filename, format="GTiff",overwrite=TRUE)
	 
	 # s=raster(filename)
	 # crs=paste0("+init=epsg:",ref_Id)
	 # crs(s) <- CRS(crs)
	 # x <- writeRaster(s, filename, overwrite=TRUE)
	 # rf <- writeRaster(r, filename=file.path(tmp, "test.tif"), , overwrite=TRUE)

	 ## PLOT
	# r <- raster(filenamee)
	# attributeInfo <- iniAttributeInfo()
	# ainfo<- get(Attribute, attributeInfo)
	# attUnits = ainfo[2]
	# plot(r)
	
  } else {
    stop('Formato non riconosciuto')
  }
}
