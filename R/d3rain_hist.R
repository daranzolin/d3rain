#' Create Rain Histograms
#'
#' @param .data a table of data
#' @param x the binning x variable
#' @param levels the ordered columns
#' @param title chart title
#' @param xBins Number of bins. Defaults to 40.
#'
#' @return an object of class 'd3rain_hist'
#' @export
#'
#' @examples
#' data.frame(
#' x = rnorm(100),
#' l1 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.8, 0.2)),
#' l2 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.5, 0.5)),
#' l3 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.3, 0.7))
#' ) %>%
#'  d3rain_hist(x = x, levels = c("l1", "l2", "l3"), title = "my title")
d3rain_hist <- function(.data, x, levels, title = "", xBins = 40) {

  if (!all(levels %in% names(.data))) {
    stop("each level must be a column", call. = FALSE)
  }

  x <- rlang::enquo(x)
  lCols <- rlang::syms(levels)
  out_df <- as.data.frame(subset(.data, select = c(tidyselect::vars_select(names(.data), !!x, !!!lCols))))
  names(out_df)[1] <- "xVar"

  if (!sum(sapply(out_df, is.logical)) == length(lCols)) {
    stop("All level columns must be logical", call. = FALSE)
  }

  x = list(
    data = out_df,
    levels = levels,
    title = title,
    xBins = xBins
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'd3rain_hist',
    x,
    package = 'd3rain'
  )
}


#' Adjust chart settings
#'
#' @param d3rain_hist an object of class d3rain_hist
#' @param annotations a vector of annotations
#' @param titlePosition either 'center', 'left', or 'right'
#' @param levelLabelLocation either 'center', 'left', or 'right'
#'
#' @return an object of class d3rain_hist
#' @export
#'
#' @examples
#' data.frame(
#' x = rnorm(100),
#' l1 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.8, 0.2)),
#' l2 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.5, 0.5)),
#' l3 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.3, 0.7))
#' ) %>%
#'  d3rain_hist(x = x, levels = c("l1", "l2", "l3"), title = "my title") %>%
#'  hist_chart_settings(annotations = c("Annotation1", "Annotation2", "YO!"),
#'                      titlePosition = "left",
#'                      levelLabelLocation = "left")
hist_chart_settings <- function(d3rain_hist,
                          annotations = NULL,
                          titlePosition = 'center',
                          levelLabelLocation = 'center') {

  if (!titlePosition %in% c("center", "left", "right")) {
    stop("titlePosition must be either 'center', 'left', or 'right'.", call. = FALSE)
  }

  d3rain_hist$x$annotations <- annotations
  d3rain_hist$x$titlePosition <- titlePosition
  d3rain_hist$x$levelLabelLocation <- levelLabelLocation
  return(d3rain_hist)
}

#' Adjust hist drip settings
#'
#' @param d3rain_hist an object of d3rain_hist
#' @param colors a vector of colors
#' @param transitionIntervals milliseconds between group transitions
#' @param dripSpeed drop speed
#' @param dripSize drip radius
#'
#' @return an object of d3rain_hist
#' @export
#'
#' @examples
#' data.frame(
#' x = rnorm(100),
#' l1 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.8, 0.2)),
#' l2 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.5, 0.5)),
#' l3 = sample(c(TRUE, FALSE), replace = TRUE, size = 100, prob = c(0.3, 0.7))
#' ) %>%
#'  d3rain_hist(x = x, levels = c("l1", "l2", "l3"), title = "my title") %>%
#'  hist_chart_settings(annotations = c("Annotation1", "Annotation2", "YO!"),
#'                      titlePosition = "left",
#'                      levelLabelLocation = "left") %>%
#'  hist_drip_settings(colors = c("red", "blue", "green"))
hist_drip_settings <- function(d3rain_hist,
                               colors = NULL,
                               transitionIntervals = 2500,
                               dripSpeed = 300,
                               dripSize = 5) {

  d3rain_hist$x$colors <- colors
  d3rain_hist$x$transitionIntervals <- transitionIntervals
  d3rain_hist$x$dripSpeed <- dripSpeed
  d3rain_hist$x$dripSize <- dripSize
  return(d3rain_hist)

}
