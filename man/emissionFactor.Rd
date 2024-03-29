% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/emissionfactors.R
\name{emissionFactor}
\alias{emissionFactor}
\title{Tool to set-up emission factors}
\usage{
emissionFactor(
  ef,
  poluttant = names(ef),
  vnames = NA,
  unit = "g/km",
  example = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{ef}{list with emission factors}

\item{poluttant}{poluttant names}

\item{vnames}{name of each vehicle categoy (optional)}

\item{unit}{tring with unit from unit package, for default is "g/km"}

\item{example}{TRUE to diaplay a simple example}

\item{verbose}{display additional information}
}
\value{
a emission factor data frame

a emission factor data.frame for totalEmission function
}
\description{
Return a data frame for emission for multiple pollutants.
}
\examples{
EF <- emissionFactor(example = TRUE)

# or the code for the same result
EF <- emissionFactor(ef = list(CO = c(1.75,10.04,0.39,0.45,0.77,1.48,1.61,0.75),
                               PM = c(0.0013,0.0,0.0010,0.0612,0.1052,0.1693,0.0,0.0)),
                     vnames = c("Light Duty Vehicles Gasohol","Light Duty Vehicles Ethanol",
                                "Light Duty Vehicles Flex","Diesel Trucks","Diesel Urban Busses",
                                "Diesel Intercity Busses","Gasohol Motorcycles",
                                "Flex Motorcycles"))

}
\seealso{
\code{\link{areaSource}} and  \code{\link{totalEmission}}
}
