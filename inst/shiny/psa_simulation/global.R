library(psa)
library(shiny)
library(tibble)
library(ggplot2)

fig_height = '600px'

# Set ggplot2 theme
theme_update(panel.background = element_rect(size=1, color='grey70', fill=NA) )

palette2 <- c('#fc8d62', '#66c2a5')
palette3 <- c('#fc8d62', '#66c2a5', '#8da0cb')
palette3_darker <- c('#d95f02', '#1b9e77', '#7570b3')
palette4 <- c('#1f78b4', '#33a02c', '#a6cee3', '#b2df8a')
