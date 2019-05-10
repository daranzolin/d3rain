#' Create a d3rain visualization
#'
#' @param .data A table of data
#' @param x A numeric 'ranking' variable, e.g. percentile, rank, etc.
#' @param y A factored, ordinal variable
#' @param toolTip Which variable to display on drip tooltips
#' @param reverseX Whether to reverse the x-axis
#' @param title Visualization title
#'
#' @import htmlwidgets
#'
#' @export
#' @examples
#' mtcars$cyl <- factor(mtcars$cyl)
#' mtcars$car <- rownames(mtcars)
#' d3rain(mtcars, mpg, cyl, car)
d3rain <- function(.data, x, y, toolTip, reverseX = FALSE, title = '') {

  x <- rlang::enquo(x)
  y <- rlang::enquo(y)
  toolTip <- rlang::enquo(toolTip)

  out_df <- subset(.data, select = c(tidyselect::vars_select(names(.data), !!x, !!y, !!toolTip)))
  names(out_df) <- c('ind', 'group', 'toolTip')
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

#' Adjust drip behavior
#'
#' @param d3rain An object of class d3rain
#' @param dripSequence Either 'iterate' or 'together'
#' @param ease Either 'bounce' or 'linear'
#' @param dripSpeed Drip speed
#' @param iterationSpeedX Iteration speed multiplier
#' @param jitterWidth Jitter width in pixels along x-axis
#'
#' @export
#' @examples
#' mtcars$cyl <- factor(mtcars$cyl)
#' mtcars$car <- rownames(mtcars)
#' d3rain(mtcars, mpg, cyl, car) %>%
#'     drip_behavior(ease = 'linear', jitterWidth = 25, dripSpeed = 500)
drip_behavior <- function(d3rain,
                          dripSequence = 'iterate',
                          ease = 'bounce',
                          dripSpeed = 1500,
                          iterationSpeedX = 100,
                          jitterWidth = 0) {

  if (!any(dripSequence %in% c('iterate', 'together', 'by_group'))) {
    stop("dripSequence param must be 'iterate' or 'together'", call. = FALSE)
  }
  if (!inherits(d3rain, 'd3rain')) {
    stop("d3rain must be of class 'd3rain'")
  }
  if (!any(ease %in% c('bounce', 'linear'))) {
    stop("ease param must be 'bounce' or 'linear'", call. = FALSE)
  }
  if (!any(c(is.numeric(dripSpeed), is.numeric(iterationSpeedX)))) {
    stop("dripSpeed and iterationSpeedX must be numeric", call. = FALSE)
  }

  d3rain$x$dripSequence <- dripSequence
  d3rain$x$ease <- ease
  d3rain$x$dripSpeed <- dripSpeed
  d3rain$x$iterationSpeedX <- iterationSpeedX
  d3rain$x$jitterWidth <- jitterWidth
  return(d3rain)
}

#' Adjust drip style
#'
#' @param d3rain An object of class d3rain
#' @param dripFill Color of drips
#' @param backgroundFill Background color of SVG
#' @param fontSize Font size
#' @param fontFamily Font family, e.g. 'times', 'sans-serif'
#' @param dripOpacity Opacity of drips
#' @param yAxisTickLocation Location of y-axis ticks, either 'center', 'left', or 'right'
#'
#' @return d3rain
#' @export
#' @examples
#' mtcars$cyl <- factor(mtcars$cyl)
#' mtcars$car <- rownames(mtcars)
#' d3rain(mtcars, mpg, cyl, car) %>%
#'     drip_behavior(ease = 'linear', jitterWidth = 25, dripSpeed = 500) %>%
#'     drip_style(dripFill = 'steelblue', dripOpacity = 0.2)
drip_style <- function(d3rain,
                       dripFill = 'firebrick',
                       backgroundFill = 'white',
                       fontSize = 18,
                       fontFamily = 'sans-serif',
                       dripOpacity = 0.5,
                       yAxisTickLocation = 'center') {

  d3rain$x$dripFill <- dripFill
  d3rain$x$dripOpacity <- dripOpacity
  d3rain$x$backgroundFill <- backgroundFill
  d3rain$x$fontSize <- fontSize
  d3rain$x$fontFamily <- fontFamily
  d3rain$x$yAxisTickLocation <- yAxisTickLocation
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
