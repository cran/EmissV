#' Tool to set-up vehicle data table
#'
#' @description Return a data frame with 4 columns (vehicle category, type, fuel and avarage kilometers driven) and an aditional column with the number of vehicles for each interest area (cityes, states, countries, etc).
#'
#' Average daily kilometres driven are defined by vehicle type:
#'
#' - LDV (Light duty Vehicles) 41 km / day
#'
#' - TRUCKS (Trucks) 110 km / day
#'
#' - BUS (Busses) 165 km / day
#'
#' - MOTO (motorcycles and other vehicles) 140 km / day
#'
#' The number of vehicles are defined by the distribution of vehicles by vehicle classs and the total number of vehicles by area.
#'
#' @note total_v and area_name must have the same length.
#'
#' @note distribution, type, category (if used), fuel (if used) and vnames (if used) must have the same length.
#'
#' @param total_v total of vehicles by area (area length)
#' @param area_name area names (area length)
#' @param distribution distribution of vehicles by vehicle class
#' @param type type of vehicle by vehicle class (distribution length)
#' @param category category name (distribution length / NA)
#' @param fuel fuel type by vehicle class (distribution length / NA)
#' @param vnames name of each vehicle class (distribution length / NA)
#' @param example a simple example
#' @param verbose display additional information
#'
#' @return a fleet distribution data.frame for totalEmission function
#'
#' @seealso \code{\link{areaSource}} and  \code{\link{totalEmission}}
#'
#' @export
#'
#' @import  units
#'
#' @examples
#' fleet <- vehicles(example = TRUE)
#'
#' # or the code bellow for the same result
#' # DETRAN 2016 data for total number of vehicles for 5 Brazilian states (Sao Paulo,
#' # Rio de Janeiro, Minas Gerais, Parana and Santa Catarina)
#' # vahicle distribution of Sao Paulo
#'
#' fleet <- vehicles(total_v = c(27332101, 6377484, 10277988, 7140439, 4772160),
#'                   area_name = c("SP", "RJ", "MG", "PR", "SC"),
#'                   distribution = c( 0.4253, 0.0320, 0.3602, 0.0260,
#'                                    0.0290, 0.0008, 0.1181, 0.0086),
#'                   category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5",
#'                                 "CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F"),
#'                   type = c("LDV", "LDV", "LDV","TRUCKS",
#'                           "BUS","BUS","MOTO", "MOTO"),
#'                   fuel = c("E25", "E100", "FLEX","B5",
#'                            "B5","B5","E25", "FLEX"),
#'                   vnames = c("Light duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
#'                              "Light Duty Vehicles Flex","Diesel trucks","Diesel urban busses",
#'                              "Diesel intercity busses","Gasohol motorcycles",
#'                              "Flex motorcycles"))

vehicles <- function(total_v,area_name = names(total_v), distribution, type,
                     category = NA,fuel = NA,vnames = NA, example = FALSE, verbose = TRUE)
  {
  if(example == TRUE){
    if(verbose)
      cat("using a example of vehicles (DETRAN 2016 data and SP vahicle distribution):\n")
    total_v = c(27332101, 6377484, 10277988, 7140439, 4772160)
    area_name = c("SP", "RJ", "MG", "PR", "SC")
    distribution = c( 0.4253, 0.0320, 0.3602, 0.0260,
                      0.0290, 0.0008, 0.1181, 0.0086)
    category =  c("LDV_E25","LDV_E100","LDV_F","TRUCKS_B5",
                  "CBUS_B5","MBUS_B5","MOTO_E25","MOTO_F")
    type = c("LDV", "LDV", "LDV","TRUCKS",
             "BUS","BUS","MOTO", "MOTO")
    fuel = c("E25", "E100", "FLEX","B5",
             "B5","B5","E25", "FLEX")
    vnames = c("Light Duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
               "Light Duty Vehicles Flex","Diesel Trucks","Diesel Urban Busses",
               "Diesel Intercity Busses","Gasohol Motorcycles","Flex Motorcycles")
  }

  frota <- data.frame(
    Estados = area_name,
    Vehiculos = total_v
  )

  Veh_fuel <- data.frame(
    x =  distribution / sum(distribution),
    Category = category,
    Type = type,
    Fuel = fuel
  )

  veh_estado <- as.data.frame(as.matrix(Veh_fuel$x) %*% matrix(unlist(frota$Vehiculos),nrow = 1))
  names(veh_estado) <- frota$Estados
  as.data.frame(veh_estado)

  for (i  in 1:ncol(veh_estado) ) {
    veh_estado[,i] <- as.numeric(as.integer(veh_estado[,i]))
  }

  Veh_fuel$Use <- ifelse(
    Veh_fuel$Type == "LDV", 41,
    ifelse(
      Veh_fuel$Type == "TRUCKS", 110,
      ifelse(
        Veh_fuel$Type == "BUS", 165,
        140
      )
    )
  )

  veh <- cbind(Veh_fuel[2:5], veh_estado)

  if(!is.na(vnames[1])){
    row.names(veh) <- vnames
  }
  veh$Use <- veh$Use*units::as_units("km d-1")
  if(verbose){
    if(!example){
      cat("vehicles:\n")
    }
    print(veh)
  }
  return(veh)
}
