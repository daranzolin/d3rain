#' <Add Title>
#'
#' <Add Description>
#'
#' @import htmlwidgets
#'
#' @export
d3rain <- function(.data) {

  # forward options using x
  x = list(
    data = .data
  )

  # create widget
  htmlwidgets::createWidget(
    name = 'd3rain',
    x,
    package = 'd3rain'
  )
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
