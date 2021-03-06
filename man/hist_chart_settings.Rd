% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/d3rain_hist.R
\name{hist_chart_settings}
\alias{hist_chart_settings}
\title{Adjust chart settings}
\usage{
hist_chart_settings(d3rain_hist, annotations = NULL,
  titlePosition = "center", levelLabelLocation = "center")
}
\arguments{
\item{d3rain_hist}{an object of class d3rain_hist}

\item{annotations}{a vector of annotations}

\item{titlePosition}{either 'center', 'left', or 'right'}

\item{levelLabelLocation}{either 'center', 'left', or 'right'}
}
\value{
an object of class d3rain_hist
}
\description{
Adjust chart settings
}
\examples{
data.frame(
x = rnorm(100),
l1 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.8, 0.2)),
l2 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.5, 0.5)),
l3 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.3, 0.7))
) \%>\%
 d3rain_hist(x = x, levels = c("l1", "l2", "l3"), title = "my title") \%>\%
 hist_chart_settings(annotations = c("Annotation1", "Annotation2", "YO!"),
                     titlePosition = "left",
                     levelLabelLocation = "left")
}
