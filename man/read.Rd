% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/read.R
\name{read}
\alias{read}
\title{Read NetCDF data from global inventaries}
\source{
Read abbout EDGAR at http://edgar.jrc.ec.europa.eu and MACCITY at
http://accent.aero.jussieu.fr/MACC_metadata.php
}
\usage{
read(
  file = file.choose(),
  coef = rep(1, length(file)),
  spec = NULL,
  version = NA,
  month = 1,
  year = 1,
  categories,
  as_raster = TRUE,
  skip_missing = FALSE,
  verbose = TRUE
)
}
\arguments{
\item{file}{file name or names (variables are summed)}

\item{coef}{coef to merge different sources (file) into one emission}

\item{spec}{numeric speciation vector to split emission into different species}

\item{version}{inventory name 'EDGAR' (for 4.32 and 5.0),'EDGAR_HTAPv2','MACCITY','GAINS','RCP' or 'VULCAN'}

\item{month}{the desired month of the inventary (MACCITY)}

\item{year}{scenario index (GAINS)}

\item{categories}{considered categories (MACCITY, GAINS variable names), empty for all}

\item{as_raster}{return a raster (defoult) or matrix (with units)}

\item{skip_missing}{return a zero emission for missing variables and a warning}

\item{verbose}{display additional information}
}
\value{
Matrix or raster
}
\description{
Read data from global inventories, can read several files and merge into one
emission and/or split into several species (speciation process)
}
\note{
for 'GAINS' version, please use flux (kg m-2 s-1) NetCDF file from https://eccad3.sedoo.fr

VULCAN is not fully supported, only for visualization purposes

for 'RCP' version, use the flux (kg m-2 s-1) Netcdf file from https://www.iiasa.ac.at/web-apps/tnt/RcpDb
}
\examples{
\donttest{
dir.create(file.path(tempdir(), "EDGARv432"))
folder <- setwd(file.path(tempdir(), "EDGARv432"))

url <- "http://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/EDGAR/datasets/v432_AP/NOx"
file1 <- 'v432_NOx_2012_IPCC_1A1a.0.1x0.1.zip'
file2 <- 'v432_NOx_2012_IPCC_1A2.0.1x0.1.zip'
file3 <- 'v432_NOx_2012_IPCC_1A3b.0.1x0.1.zip'

download.file(paste0(url,'/ENE/',file1), file1)
download.file(paste0(url,'/IND/',file2), file2)
download.file(paste0(url,'/TRO/',file3), file3)

unzip('v432_NOx_2012_IPCC_1A1a.0.1x0.1.zip')
unzip('v432_NOx_2012_IPCC_1A2.0.1x0.1.zip')
unzip('v432_NOx_2012_IPCC_1A3b.0.1x0.1.zip')

nox    <- read(file = dir(pattern = '.nc'),version = 'EDGAR')
setwd(folder)

sp::spplot(nox, scales = list(draw=TRUE), xlab="Lat", ylab="Lon",main="NOx emissions from EDGAR")

d1     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d01",sep=""))
d2     <- gridInfo(paste(system.file("extdata", package = "EmissV"),"/wrfinput_d02",sep=""))
nox_d1 <- rasterSource(nox,d1)
nox_d2 <- rasterSource(nox,d2)
image(nox_d1, axe = FALSE, main = "NOx emissions from transport-energy-industry for d1 (2012)")
image(nox_d2, axe = FALSE, main = "NOx emissions from transport-energy-industry for d2 (2012)")
}
}
\references{
Janssens-Maenhout, G., Dentener, F., Van Aardenne, J., Monni, S., Pagliari, V., Orlandini,
L., ... & Wankmüller, R. (2012). EDGAR-HTAP: a harmonized gridded air pollution emission dataset
based on national inventories. European Commission Joint Research Centre Institute for
Environment and Sustainability. JRC 68434 UR 25229 EUR 25229, ISBN 978-92-79-23123-0.

Lamarque, J.-F., Bond, T. C., Eyring, V., Granier, C., Heil, A., Klimont, Z., Lee, D., Liousse,
C., Mieville, A., Owen, B., Schultz, M. G., Shindell, D., Smith, S. J., Stehfest, E.,
Van Aardenne, J., Cooper, O. R., Kainuma, M., Mahowald, N., McConnell, J. R., Naik, V.,
Riahi, K., and van Vuuren, D. P.: Historical (1850-2000) gridded anthropogenic and biomass
burning emissions of reactive gases and aerosols: methodology and application,
Atmos. Chem. Phys., 10, 7017-7039, doi:10.5194/acp-10-7017-2010, 2010.

Z Klimont, S. J. Smith and J Cofala The last decade of global anthropogenic sulfur dioxide:
2000–2011 emissions Environmental Research Letters 8, 014003, 2013

Gurney, Kevin R., Jianming Liang, Risa Patarasuk, Yang Song, Jianhua Huang, and
Geoffrey Roest (2019) The Vulcan Version 3.0 High-Resolution Fossil Fuel CO2 Emissions
for the United States. Nature Scientific Data.
}
\seealso{
\code{\link{rasterSource}} and \code{\link{gridInfo}}

\code{\link{species}}
}
