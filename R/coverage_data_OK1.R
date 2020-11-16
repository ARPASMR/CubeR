save_file <- function(response,filename){
     bin <- content(response, "raw")
	 con <- file(filename, open = "wb")
	 writeBin(bin, con)
	 close(con)
}

#' @title Image from coverage
#' @description This function provides the possibility to interact directly with the data cubes. It gives the option to write the images to
#' memory or on the hard drive for further computation.
#' @param coverage name of the coverage [character]
#' @param slice_E image slicing coordinates in x-direction [character]
#' @param slice_N image slicing coordinates in y-direction [character]
#' @param DATA an available timestamp [character]
#' @param bands coverage bands to calculate raster. Can contain one or more bands from the same coverage [character]. Example for one bands: bands="field_1"- Example for tree bands: bands=("R", "G", "B")
#' @param filename If the raster image should be saved please digit a path and a filename. [character]
#' @param query_url Web Coverage Service (WCS) for processing the query.
#' This URL can be built with the *createWCS_URLs* function. [character]
#' @import httr
#' @import tiff
#' @importFrom raster raster extent aggregate stack writeRaster
#' @importFrom urltools url_encode
#' @export
image_from_coverage <- function(coverage, slice_E, slice_N, DATA, bands=NULL,filename=NULL, query_url=NULL)
{
  if(is.null(query_url)) query_url<-createWCS_URLs(type="Query")
  ref_Id<-coverage_get_coordinate_reference(coverage=coverage)
  coord_sys<-coverage_get_coordsys(coverage=coverage)
  if(is.null(bands)){
    bands=coverage_get_bands(desc_url=NULL, coverage)
  } else {
    bands=bands
    print(paste0("La banda scelta è:", bands))
  }
  bands_len <- length(bands)
	if (bands_len==1){
		print("Il raster ha una sola banda. Verrà restituito un raster con una sola banda")
		query <- paste0('for ', bands[1],' in (', coverage, ') return encode (',bands[1],
                    '[',
                    coord_sys[2], '(', slice_E[1], ':', slice_E[2], ')', ',',
                    coord_sys[3], '(', slice_N[1], ':', slice_N[2], ')', ',',
                    coord_sys[1], '("', DATA, '")',
                    '],','"image/tiff")')
		query_encode  <- urltools::url_encode(query)
		request       <- paste(query_url, query_encode, collapse = NULL, sep="")
		res <- GET(request)
		bin <- content(res, "raw")
		tmp_folder=tempdir()
		file_name=paste0(coverage,"_",DATA,".tiff")
		tmp_file=file.path(tmp_folder,file_name)
		con <- file(tmp_file, open = "wb")
		writeBin(bin, con)
		close(con)
		print(paste0("File temporaneo", tmp_file))
		ras <- raster(tmp_file)
		if(!is.null(filename)){
			writeRaster(ras,filename)
		} else {
			return(ras)
		}
	} else {
		print(paste0("Il raster ha piu' bande: ", bands, ". Verrà restituito un RasterStack composto da ", length(bands), " bande."))
		rasters <- list()
		for(i in 1:bands_len){
			query <- paste0('for ', bands[i],' in (', coverage, ') return encode (',bands[i],
                    '[',
                    coord_sys[2], '(', slice_E[1], ':', slice_E[2], ')', ',',
                    coord_sys[3], '(', slice_N[1], ':', slice_N[2], ')', ',',
                    coord_sys[1], '("', DATA, '")',
                    '],','"image/tiff")')
    
			query_encode  <- urltools::url_encode(query)
			request       <- paste(query_url, query_encode, collapse = NULL, sep="")
			res <- GET(request)
			bin <- content(res, "raw")
	
			#library(RCurl)
			#bin = getBinaryURL(request)
			tmp_folder=tempdir()
			file_name=paste0(coverage,"_",DATA,"[",bands[i],"].tiff")
			tmp_file=file.path(tmp_folder,file_name)
			con <- file(tmp_file, open = "wb")
			writeBin(bin, con)
			close(con)
			print(paste0("File temporaneo", tmp_file))
			ras <- raster(tmp_file)
			rasters[[i]] <- ras
			#names(stk) <- bands

			if(!is.null(filename)){
				stk<-stack(rasters)
				writeRaster(stk,filename)
				#writeRaster(stk,"myStack.tif", format="GTiff")
			} else {
				return(stk)
				#nlayers(stk)
			}
		}
	}
}


#' @title Get WPCS query result
#' @description This function provides the possibility to interact directly with the data cubes. It gives the option to execute a WPCS query in txt/csv format 
#' @param proper_query The proper WPCS query for the selected coverage, in WPCS query language (eg. 'for c in (rh_ana) return encode(c[E(515200),N(5037430), ansi("2020-10-01")], "text/csv" )'. The script takes care of encoding it
#' @param ext_format output format for the WCPS query result. [character]
#' The format coul be raster format ("tiff"), image format ("png", "jpeg", "bmp") or text/csv format ("txt", "csv").
#' @param query_url Web Coverage Service (WCS) for processing the query. This URL can be built with the *createWCS_URLs* function. [character]
#' @param filename downloadfile name (all path)
#' @import httr
#' @import RCurl
#' @import raster
#' @importFrom urltools url_encode
#' @export
WPCS_query <- function(proper_query=NULL, ext_format=NULL, filename=NULL, query_url=NULL) {
  if(is.null(proper_query) || is.null(formato)) stop('Inserire per forza i parametri proper_query e formato')
  if(is.null(query_url)) query_url<-createWCS_URLs(type="Query")
  query_encode  <- urltools::url_encode(proper_query)
  request<- paste(query_url, query_encode, collapse = NULL, sep="")
  res <- GET(request)

  if(is.null(filename)){
		tmp_file=paste0(tempfile(),".",ext_format)
		filename=tmp_file
  }
  #text/csv format
  if (ext_format == "txt") {
	 out<- content(res, "text")
	 if (is.null(filename)) {return(out)}
	 else {save_file}
	 }
  } else if (formato == "image/tiff") { 
   

  # raster format
  } else if (formato == "image/tiff") {
  
	 # Save to local disk
     bin <- content(res, "raw")
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
