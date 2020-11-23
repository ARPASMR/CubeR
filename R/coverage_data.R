savefile <- function(response,filename){
     bin <- content(response, "raw")
	 con <- file(filename, open = "wb")
	 writeBin(bin, con)
	 close(con)
}

CRS_Ext <- function(desc_url=NULL, coverage){

  if(is.null(desc_url)) desc_url<-createWCS_URLs(type="Meta")

  d_xml <- xml2::read_xml(paste0(desc_url,coverage))

  sys_Id <- xml_children(d_xml) %>%
    xml_children(.) %>% xml_children(.) %>% .[1] %>%
    xml_attr(., "srsName") %>%
    str_split(., "=") %>% unlist

  if(length(sys_Id) > 2){
    sys_ext <- sys_Id  %>% .[3]
  } else if(length(sys_Id) > 1){
    sys_ext <- sys_Id  %>% .[2]
  } else {
    sys_ext <- sys_Id  %>% .[1]
  }
  return(sys_ext)
}

filename_extension <- function(formato){
  formats=c("text/csv", "image/tiff", "image/png", "image/jpeg", "image/bmp")
  extensions=c("txt", "tiff", "png", "jpeg", "bmp")
  i <- which(formats == formato)
  return (extensions[i])
}

#' @title GetCoverage
#' @description This function provides the possibility to interact directly with the data cubes. It gives the option to write the images to memory or on the hard drive for further computation.
#' @param coverage name of the coverage [character]
#' @param FORMAT output_format. Output format (mime type) of the product
#' @param DATA an available timestamp [character]
#' @param slice_E image slicing coordinates in x-direction [character]  Eg. E(436000, 550000)
#' @param slice_N image slicing coordinates in y-direction [character]  Eg. N(4918000,5166000) 
#' @param BAND (RangeSubset) coverage Nameband to calculate raster. If param BAND not set (=NULL) the band number 1 will be automatically selected. [character]
#' @param CRS_Extension This parameter defines the output crs. By default is used the coverages CRS. [character] Eg. http://localhost:8080/def/crs/EPSG/0/32632
#' @param filename If the raster image should be saved please digit a path and a filename. [character]
#' @param others_opt Other options/WCS GetCoverage parameters. Eg. clipping extension: clip=POLYGON((1520000 5030000,1540000 5030000, 1540000 5060000, 1520000 5060000, 1520000 5030000))
#' @import httr
#' @import tiff
#' @importFrom raster raster extent aggregate stack writeRaster
#' @importFrom urltools url_encode
#' @export
get_coverage <- function(coverage, DATA, FORMAT, SUBSET_E=NULL, SUBSET_N=NULL, BAND=NULL, CRS_Extension=NULL, filename=NULL, others_opt=NULL)
{
  if(is.null(DATA) || is.null(FORMAT)) stop('Inserire per forza i parametri DATA e FORMAT')
  ext_format=filename_extension(FORMAT)
  if (length(ext_format)==0) stop ('Verifica il formato inserito')
  
  bbox=coverage_get_bounding_box(coverage=coverage)
  if(is.null(CRS_Extension)) {
	CRS_Extension <- CRS_Ext(coverage=coverage)
	print(paste0('Messaggio informativo: Il sistema di riferimento di default è: ',CRS_Extension))
  }
  
  desc_url<-createWCS_URLs(type="Get")
  coord_sys<-coverage_get_coordsys(coverage=coverage)
  request <- paste0(desc_url,coverage,'&SUBSET=',coord_sys[1],'(%22', DATA, '%22)','&subsettingCRS=',CRS_Extension,'&FORMAT=',FORMAT)

  # if (is.null(SUBSET_E)) SUBSET_E<-paste0('E(',bbox[1],',',bbox[2],')')
  # if (is.null(SUBSET_N)) SUBSET_N<-paste0('N(',bbox[3],',',bbox[4],')')
  if (!is.null(SUBSET_E)) request=paste0(request,'&SUBSET=',SUBSET_E)
  if (!is.null(SUBSET_N)) request=paste0(request,'&SUBSET=',SUBSET_N)
  if(!is.null(BAND)) request=paste0(ulr1,'&RANGESUBSET=',BAND)
  if(!is.null(others_opt)){
	more_opt=URLencode(others_opt)
	request=paste0(request,'&',more_opt)
  }
  
  #print(request) #Messaggio di controllo
  res <- GET(request)

  imageformats=c("image/png", "image/jpeg", "image/bmp")
  tmp_file=paste0(tempfile(),".",ext_format)
  
  # text/csv format
	if (FORMAT == "text/csv") {
		out<- content(res, "text")
		if (is.null(filename)) {
			return(out)
		} else {
			# Save to local disk
			savefile(response=res, filename=filename)
			print(paste0("Risultato salvato in: ", filename))
		}
  # raster format
	} else if (FORMAT=="image/tiff") {
		savefile(response=res,filename=tmp_file)
		#print(paste0("File temporaneo", tmp_file))
		ras <- raster(tmp_file)
		if (is.null(filename)) {
			return(ras)
		} else {
			writeRaster(ras,filename,overwrite=TRUE)
			print(paste0("Raster salvato come: ", filename))
		}
  #image format
	} else if (FORMAT %in% imageformats){
		#print("Formato immagine")
		if (is.null(filename)) {
		savefile(response=res,filename=tmp_file)
		print(paste0("Immagine salvata nel file temporaneo: ", tmp_file))
		} else {
		savefile(response=res,filename=filename)
        print(paste0("L'immagine è stata salvata: ", filename))
		}
	} else {
		stop('ATTENZIONE: Formato non riconosciuto')
	}
}
  
  
#' @title Image from coverage
#' @description This function provides the possibility to interact directly with the data cubes. It gives the option to write the images to memory or on the hard drive for further computation.
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
image_from_coverage <- function(coverage, slice_E, slice_N, DATA, bands=NULL, filename=NULL, query_url=NULL)
{
  if(is.null(query_url)) query_url<-createWCS_URLs(type="Query")
  
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
		request       <- paste0(query_url, query_encode, collapse = NULL, sep="")
		res <- GET(request)

		tmp_folder=tempdir()
		file_name=paste0(coverage,"_",DATA,".tiff")
		tmp_file=file.path(tmp_folder,file_name)
		savefile(response=res,filename=tmp_file)
		print(paste0("File temporaneo", tmp_file))
		ras <- raster(tmp_file)
		if(!is.null(filename)){
			writeRaster(ras,filename,overwrite=TRUE)
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
			request       <- paste0(query_url, query_encode, collapse = NULL, sep="")
			res <- GET(request)
			tmp_folder=tempdir()
			file_name=paste0(coverage,"_",DATA,"[",bands[i],"].tiff")
			tmp_file=file.path(tmp_folder,file_name)
            savefile(response=res,filename=tmp_file)
			ras <- raster(tmp_file)
			rasters[[i]] <- ras
			#names(stk) <- bands

			if(!is.null(filename)){
				stk<-stack(rasters)
				writeRaster(stk,filename)
				print(paste0("File salvato come: ", filename))
				#writeRaster(stk,"myStack.tif", format="GTiff")
			} else {
				return(stk)
				print(paste0("File temporaneo", tmp_file))
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

WPCS_query <- function(proper_query=NULL, FORMAT, filename=NULL, query_url=NULL) {
  if(is.null(proper_query) || is.null(FORMAT)) stop('Inserire per forza i parametri proper_query e formato')
  ext_format=filename_extension(FORMAT)
  if (length(ext_format)==0) stop ('Verifica il formato inserito')
  
  if(is.null(query_url)) query_url<-createWCS_URLs(type="Query")
  
  query_encode  <- urltools::url_encode(proper_query)
  request<- paste(query_url, query_encode, collapse = NULL, sep="")
  res <- GET(request)

  imageformats=c("image/png", "image/jpeg", "image/bmp")
  tmp_file=paste0(tempfile(),".",ext_format)
  
  # text/csv format
	if (FORMAT == "text/csv") {
		out<- content(res, "text")
		if (is.null(filename)) {
			return(out)
		} else {
			# Save to local disk
			savefile(response=res, filename=filename)
			print(paste0("Risultato salvato in: ", filename))
		}
  # raster format
	} else if (FORMAT=="image/tiff") {
		savefile(response=res,filename=tmp_file)
		#print(paste0("File temporaneo", tmp_file))
		ras <- raster(tmp_file)
		if (is.null(filename)) {
			return(ras)
		} else {
			writeRaster(ras,filename,overwrite=TRUE)
			print(paste0("Raster salvato come: ", filename))
		}
  #image format
	} else if (FORMAT %in% imageformats){
		print("Formato immagine")
		if (is.null(filename)) {
		savefile(response=res,filename=tmp_file)
		print(paste0("Immagine salvata nel file temporaneo: ", tmp_file))
		} else {
		savefile(response=res,filename=filename)
        print(paste0("Immagine salvata: ", filename))
		}
	} else {
		stop('Formato non riconosciuto')
	}
}
