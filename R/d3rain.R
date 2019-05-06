#' Create a d3rain visualization
#'
#' @param .data A table of data.
#' @param x A numeric 'ranking' variable, e.g. percentile, rank, etc.
#' @param y A factored, ordinal variable.
#' @param toolTip Which variable to display on drop tooltips.
#' @param title Visualization title
#'
#' @import htmlwidgets
#'
#' @export
d3rain <- function(.data, x, y, toolTip, reverseX = FALSE, title = '') {

  x <- rlang::enquo(x)
  y <- rlang::enquo(y)
  toolTip <- rlang::enquo(toolTip)

  out_df <- subset(.data, select = c(tidyselect::vars_select(names(.data), !!x, !!y, !!toolTip)))
  if (!is.numeric(out_df$ind)) stop ("x must be numeric.", call. = FALSE)
  if (!is.factor(out_df$group)) stop("y must be a factor.", call. = FALSE)

  x = list(
    data = out_df,
    y_domain = levels(out_df$group),
    title = title,
    reverseX = reverseX
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'd3rain',
    x,
    package = 'd3rain'
  )
}

#' Adjust d3rain drop behavior
#'
#' @param d3rain An object of class d3rain
#' @param ease Either 'bounce' or 'linear'
#' @param dropSpeed Drop speed
#' @param iterationSpeedX Iteration speed multiplier
#'
#' @export
drop_behavior <- function(d3rain,
                          dropSequence = 'iterate',
                          ease = 'bounce',
                          dropSpeed = 1500,
                          iterationSpeedX = 100,
                          jitterWidth = 0) {

  if (!any(dropSequence %in% c('iterate', 'together'))) {
    stop("dropSequence param must be 'iterate' or 'together'", call. = FALSE)
  }
  if (!inherits(d3rain, 'd3rain')) {
    stop("d3rain must be of class 'd3rain'")
  }
  if (!any(ease %in% c('bounce', 'linear'))) {
    stop("ease param must be 'bounce' or 'linear'", call. = FALSE)
  }
  if (!any(c(is.numeric(dropSpeed), is.numeric(iterationSpeedX)))) {
    stop("dropSpeed and iterationSpeedX must be numeric", call. = FALSE)
  }

  d3rain$x$dropSequence <- dropSequence
  d3rain$x$ease <- ease
  d3rain$x$dropSpeed <- dropSpeed
  d3rain$x$iterationSpeedX <- iterationSpeedX
  d3rain$x$jitterWidth <- jitterWidth
  return(d3rain)
}

#' Adjust d3rain drop style
#'
#' @param d3rain An object of class d3rain
#' @param dropFill Color of drops
#' @param backgroundFill Background color of SVG
#' @param fontSize Font size
#' @param fontFamily Font family, e.g. 'times', 'sans-serif'
#'
#' @return
#' @export
#'
#' @examples
drop_style <- function(d3rain,
                       dropFill = 'firebrick',
                       backgroundFill = 'white',
                       fontSize = 18,
                       fontFamily = 'sans-serif',
                       dropOpacity = 0.5) {

  d3rain$x$dropFill <- dropFill
  d3rain$x$dropOpacity <- dropOpacity
  d3rain$x$backgroundFill <- backgroundFill
  d3rain$x$fontSize <- fontSize
  d3rain$x$fontFamily <- fontFamily
  return(d3rain)
}


#' Shiny bindings for d3rain
#'
#' Output and render functions for using d3rain within Shiny
#' applications and interactive Rmd documents.
#'
#' @param outputId output variable to read from
#' @param width,height Must be a valid CSS unit (like \code{'100\%'},
#'   \code{'400px'}, \code{'auto'}) or a number, which will be coerced to a
#'   string and have \code{'px'} appended.
#' @param expr An expression that generates a d3rain
#' @param env The environment in which to evaluate \code{expr}.
#' @param quoted Is \code{expr} a quoted expression (with \code{quote()})? This
#'   is useful if you want to save an expression in a variable.
#'
#' @name d3rain-shiny
#'
#' @export
d3rainOutput <- function(outputId, width = '100%', height = '400px'){
  htmlwidgets::shinyWidgetOutput(outputId, 'd3rain', width, height, package = 'd3rain')
}

#' @rdname d3rain-shiny
#' @export
renderD3rain <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, d3rainOutput, env, quoted = TRUE)
}
