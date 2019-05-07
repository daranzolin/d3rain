
<!-- README.md is generated from README.Rmd. Please edit that file -->

## d3rain

[![Travis build
status](https://travis-ci.org/daranzolin/d3rain.svg?branch=master)](https://travis-ci.org/daranzolin/d3rain)

According to the authorities at Urban Dictionary, [‘drip’ is synonymous
with ‘immense
swag.’](https://www.urbandictionary.com/define.php?term=Drip) This
package brings some D3 drip to R.

### Installation

You can install `d3rain` from GitHub via:

``` r
remotes::install_github("daranzoling/d3rain")
```

## Example

‘Rain’ visualizations are useful aids to observe the relationship
between a ranked, numeric variable (e.g. percentile, rank, etc.) and any
factored, categorical variable.

``` r
library(d3rain)
library(tidyverse)

armed_levels <- c('No', 'Knife', 'Non-lethal firearm', 'Firearm')
pk <- fivethirtyeight::police_killings %>% 
  filter(armed %in% armed_levels,
         !is.na(age)) %>% 
  mutate(armed = factor(armed, levels = armed_levels)) 

pk %>% 
  d3rain(age, armed, toolTip = raceethnicity, title = "2015 Police Killings by Age, Armed Status") %>% 
  drip_behavior(dripSequence = 'iterate',
                ease = 'bounce',
                jitterWidth = 20,
                dripSpeed = 1000) %>% 
  drip_style(dripFill = 'firebrick',
             fontFamily = 'times')
```

![Alt
Text](https://raw.githubusercontent.com/daranzolin/d3rain/master/inst/img/d3raingif.gif)

`drip_behavior` adjusts the drip sequence, easing animation, jitter
width, and drip speed. `drip_style` controls the drip fill, font size,
font family, and background color.

## Future Work

  - Additional drip behaviors (e.g. by group)
  - Conditional fill colors
  - More axis control
