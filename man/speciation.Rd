% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/speciation.R
\name{speciation}
\alias{speciation}
\title{Speciation of emissions in different compounds}
\usage{
speciation(total, spec = NULL, verbose = TRUE)
}
\arguments{
\item{total}{emissions from totalEmissions}

\item{spec}{numeric speciation vector of species}

\item{verbose}{display additional information}
}
\value{
Return a list with the daily total emission by interest area (cityes, states, countries, etc).
}
\description{
Distribute the total mass of estimated emissions into model species.
}
\examples{
veic <- vehicles(example = TRUE)
EmissionFactors <- emissionFactor(example = TRUE)
TOTAL <- totalEmission(veic,EmissionFactors,pol = "PM")
pm_iag <- c(E_PM25I = 0.0509200,
            E_PM25J = 0.1527600,
            E_ECI   = 0.1196620,
            E_ECJ   = 0.0076380,
            E_ORGI  = 0.0534660,
            E_ORGJ  = 0.2279340,
            E_SO4I  = 0.0063784,
            E_SO4J  = 0.0405216,
            E_NO3J  = 0.0024656,
            E_NO3I  = 0.0082544,
            E_PM10  = 0.3300000)
PM <- speciation(TOTAL,pm_iag)
}
\seealso{
\code{\link{species}}
}
