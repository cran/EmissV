#' Emissions in the format for atmospheric models
#'
#' @description Combine area sources and total emissions to model output
#'
#' @format matrix of emission
#'
#' @param inventory a inventory raster from read
#' @param grid grid information
#' @param mm pollutant molar mass
#' @param aerosol TRUE for aerosols and FALSE (defoult) for gazes
#' @param total list of total emission
#' @param pol pollutant name
#' @param area list of area sources or matrix with a spatial distribution
#' @param plot TRUE for plot the final emissions
#' @param check TRUE (defoult) to check negative and NA values and replace it for zero
#' @param verbose display additional information
#'
#' @return a vector of emissions in MOL / mk2 h for gases and ug / m2 s for aerosols.
#'
#' @note if Inventory is provided, the firsts tree arguments are not be used by the function.
#'
#' @note Is a good practice use the set_units(fe,your_unity), where fe is your emission factory and your_unity is usually g/km on your emission factory
#'
#' @note the list of area must be in the same order as defined in vehicles and total emission.
#'
#' @note just WRF-Chem is suported by now
#'
#' @seealso \code{\link{totalEmission}} and \code{\link{areaSource}}
#'
#' @export
#'
#' @import units raster
#'
#' @examples
#' fleet  <- vehicles(example = TRUE)
#'
#' EmissionFactors <- emissionFactor(example = TRUE)
#'
#' TOTAL  <- totalEmission(fleet,EmissionFactors,pol = c("CO"),verbose = TRUE)
#'
#' grid   <- gridInfo(paste0(system.file("extdata", package = "EmissV"),"/wrfinput_d01"))
#' shape  <- raster::shapefile(paste0(system.file("extdata", package = "EmissV"),"/BR.shp"))
#' raster <- raster::raster(paste0(system.file("extdata", package = "EmissV"),"/dmsp.tiff"))
#'
#' SP     <- areaSource(shape[22,1],raster,grid,name = "SP")
#' RJ     <- areaSource(shape[17,1],raster,grid,name = "RJ")
#'
#' e_CO   <- emission(total = TOTAL,
#'                    pol = "CO",
#'                    area = list(SP = SP, RJ = RJ),
#'                    grid = grid,
#'                    mm = 28)
#'

emission <- function(inventory = NULL,grid,mm = 1, aerosol = FALSE,check = TRUE,
                     total, pol, area,
                     plot = FALSE,verbose = TRUE){

  if(!is.null(inventory)){
    if(verbose){
      if(missing(pol)){
        cat("Using raster from inventory ...\n") # nocov
      }else{
        cat("Using raster from inventory for",pol,"...\n")
      }
    }

    # input is g m-2 s-1
    if(class(inventory)[1]=="RasterLayer"){
      VAR_e <- rasterSource(inventory,grid,conservative = FALSE,verbose = verbose)
    }
    ## SET THE ORIGINAL UNITS from read
    ## g m-2 s-1
    VAR_e = units::set_units(VAR_e,"g m-2 s-1")

    if(aerosol){
      ##  to ug m-2 s-1
      VAR_e = units::set_units(VAR_e,"ug m-2 s-1")
    }else{
      ##  to mol km-2 h-1
      VAR_e =  units::set_units(VAR_e,"g km-2 h-1")
      units::remove_unit("MOL")
      if(mm == 1){
        units::install_unit("MOL","666 g") # avoiding the error when 1MOL=1g # nocov
        VAR_e <- 666 * units::set_units(VAR_e,"MOL km-2 h-1")                # nocov
      }else{
        units::install_unit("MOL", paste(mm,"g"))
        VAR_e <- units::set_units(VAR_e,"MOL km-2 h-1")
      }
    }

    if(plot == TRUE){
      col   <- grid$Horizontal[1]
      rol   <- grid$Horizontal[2]
      r.lat <- range(grid$Lat)
      r.lon <- range(grid$Lon)
      r     <- raster::raster(nrows=rol,ncols=col,
                              xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                              crs= "+proj=longlat")

      raster::values(r) <- as.matrix(as.numeric(VAR_e),ncol = col,nrow = row,byrow = TRUE)
      r                 <- raster::flip(r,2)

      if(missing(pol)){
        legenda <- paste("Emission [",units::deparse_unit(VAR_e),"]") # nocov
      }else{
        legenda <- paste("Emissions of", pol ,"[",units::deparse_unit(VAR_e),"]")
      }

      plot(r,main = legenda,
           col = c("#031638","#001E48","#002756","#003062",
                   "#003A6E","#004579","#005084","#005C8E",
                   "#006897","#0074A1","#0081AA","#008FB3",
                   "#009EBD","#00AFC8","#00C2D6","#00E3F0"))
    }
    if(check){
      VAR_e <- check_positive(VAR_e,pol)
      return(VAR_e)
    }else{
      return(VAR_e) # nocov
    }
  }

  if(verbose){
    if(aerosol){
      cat(paste("calculating emissions for ",pol," as aerosol"," ...\n",sep=""))
    }else{
      if(mm == 1){
        cat(paste("calculating emissions for ",pol," ...\n",sep="")) # nocov
      }else{
        cat(paste("calculating emissions for ",pol," using molar mass = ",mm," ...\n",sep="")) # nocov
      }
    }
  }

  n <- which(names(total) == pol)
  if(length(n) == 0){
    return(cat(paste(pol,"not found in total !\n")))
  }

  var <- total[[n]]

  if(is.list(area)){
    # get the units (in order to work with raster)
    unidade <- total[[1]][1]/as.numeric(total[[1]][[1]])

    for(i in 1:length(area)){
      area[[i]] = area[[i]] * units::drop_units(var[[i]])
    }
    area <- unname(area)

    if(length(area) > 1){
      # VAR_e  <- do.call(sp::merge,area)
      VAR_e  <- Reduce(raster::merge, area)
    }else{
      VAR_e  <- area[[1]]
    }
    VAR_e[is.na(VAR_e)] <- 0

    # old code
    # VAR_e <- rasterSource(VAR_e,grid,verbose = FALSE)
    VAR_e <- raster_to_ncdf(VAR_e)

    # put the units (to back the unit)
    VAR_e <- VAR_e * unidade
  }

  dx <- grid$DX
  dx <- dx*units::as_units("km")

  if(aerosol){
    ##  ug m^-2 s^-1
    dx    = units::set_units(dx,"m")
    VAR_e = units::set_units(VAR_e,"ug/s")
    VAR_e = VAR_e / dx^2
  }
  else{
    #  mol km^-2 hr^-1
    units::remove_unit("MOL")
    units::remove_unit("MOL")
    if(mm == 1){
      units::install_unit("MOL","666 g")  # avoiding the error when 1MOL=1g
      VAR_e = 666 * units::set_units(VAR_e,"MOL/d")
      VAR_e = units::set_units(VAR_e,"MOL/h")
    }else{
      units::install_unit("MOL", paste(mm,"g")) # nocov
      VAR_e = units::set_units(VAR_e,"MOL/d")   # nocov
      VAR_e = units::set_units(VAR_e,"MOL/h")   # nocov
    }
    VAR_e   =  VAR_e / dx^2
  }

  if(plot == TRUE){
    col   <- grid$Horizontal[1]
    rol   <- grid$Horizontal[2]
    r.lat <- range(grid$Lat)
    r.lon <- range(grid$Lon)
    r     <- raster::raster(nrows=rol,ncols=col,
                            xmn=r.lon[1],xmx=r.lon[2],ymn=r.lat[1],ymx=r.lat[2],
                            crs= "+proj=longlat")

    raster::values(r) <- as.matrix(as.numeric(VAR_e),ncol = col,nrow = row,byrow = TRUE)
    r                 <- raster::flip(r,2)

    plot(r,col = c("#031638","#001E48","#002756","#003062",
                   "#003A6E","#004579","#005084","#005C8E",
                   "#006897","#0074A1","#0081AA","#008FB3",
                   "#009EBD","#00AFC8","#00C2D6","#00E3F0"))
  }
  if(check){
    VAR_e <- check_positive(VAR_e,pol)
    return(VAR_e)
  }else{
    return(VAR_e) # nocov
  }
}

check_positive <- function(emiss,pol = '?'){
  has_NAs  <- FALSE
  negative <- FALSE
  n_na  = 0
  n_neg = 0
  for(i in 1:length(emiss)){
    if(is.na(drop_units(emiss[i]))){
      has_NAs  <- TRUE                     # nocov
      emiss[i] = 0                         # nocov
      n_na     = n_na + 1                  # nocov
    }else{
      if(drop_units(emiss[i]) < 0){
        negative <- TRUE                   # nocov
        emiss[i] = 0                       # nocov
        n_neg    = n_neg + 1               # nocov
      }
    }
  }
  if(negative)
    warning(n_neg,' Negative values found, replaced by zero in ',pol) # nocov
  if(has_NAs)
    warning(n_na,' NA values found, replaced by zero in ',pol)        # nocov
  return(emiss)
}

raster_to_ncdf <- function(r,na_value = 0){
  N_times <- dim(r)[3]
  a       <- array(na_value,c(dim(r)[2],dim(r)[1],N_times))
  for(i in 1:N_times){
    a[,,i] <- as.matrix(t(raster::flip(r[[i]],2)))
  }
  return(a)
}
