rm(list = ls())
#install.packages("tidyverse")
#install.packages("png")
#install.packages("ggpubr")
library(tidyverse)
library(dplyr)
library(png)
library(ggpubr)

# File paths
wd <- "UPDATE HERE WITH YOUR WORKING DIRECTORY FILEPATH"
data <- paste0(wd, "/data")
output <- paste0(wd, "/output")
r <- paste0(wd, "/R")

## CLEANING MOUSE DATA #########################################################

# Analytic sample
nomiss <- read_csv(paste0(data, "/analytic_sample.csv"))

# Load resume data
resume_data <- read_csv(paste0(data, "/resume_data_long.csv"))

# Load mouse data (long)
mouse_data <- read_csv(paste0(data, "/mouse_data_long.csv")) %>%
  mutate(candidate = resume)

# Join datasets and keep only analytic sample
df <- nomiss %>%
  left_join(resume_data, by = "code") %>%
  left_join(mouse_data, by = c("code", "candidate"))

## PLOTTING MOUSE COORDINATES -- FIGURE IN SMR PAPER ###########################

# No Kids Woman, Cells --------------------------------------------------------

# Work open
baseimage <- readPNG(paste0(data, "/images/nokidswoman_workopen_sharp_nogray.png"))

graphdata <- df %>%
  filter(parent == "Non-parent") %>%
  filter(gender == "Woman") %>%
  filter(section == "Work Open") %>%
  group_by(x_cell, y_cell) %>%
  count()

graphdata$n <- replace(graphdata$n, graphdata$n>=500, 500) # top coding at 500
max(graphdata$n)

plot <- ggplot(graphdata, aes(x_cell, y_cell, z = n)) +
  background_image(baseimage) +
  geom_raster(aes(x = x_cell, y = y_cell, alpha = 0.2, fill = n), hjust=1, 
              vjust=1) +
  xlab("X Cell") +
  ylab("Y Cell") +
  scale_x_continuous(expand = c(0,0), limits = c(0, 12)) +
  scale_y_continuous(expand = c(0,0), limits = c(0, 20)) +
  scale_fill_viridis_c(direction = -1) +
  scale_alpha(guide = "none")
plot
ggsave(paste0(output, "/nokidswoman_workopen_cells.pdf"), plot, 
       height = 10, width = 6)

# Kids Woman, Cells --------------------------------------------------------

# Work open
baseimage <- readPNG(paste0(data, "/images/kidswoman_workopen_sharp_nogray.png"))

graphdata <- df %>%
  filter(parent == "Parent") %>%
  filter(gender == "Woman") %>%
  filter(section == "Work Open") %>%
  group_by(x_cell, y_cell) %>%
  count()

graphdata$n <- replace(graphdata$n, graphdata$n>=500, 500) # top coding at 500
max(graphdata$n)

plot <- ggplot(graphdata, aes(x_cell, y_cell, z = n)) +
  background_image(baseimage) +
  geom_raster(aes(x = x_cell, y = y_cell, alpha = 0.2, fill = n), hjust=1, 
              vjust=1) +
  xlab("X Cell") +
  ylab("Y Cell") +
  scale_x_continuous(expand = c(0,0), limits = c(0, 12)) +
  scale_y_continuous(expand = c(0,0), limits = c(0, 20)) +
  scale_fill_viridis_c(direction = -1) +
  scale_alpha(guide = "none") +
  geom_rect(aes(xmin = 3, xmax = 4, ymin = 13, ymax = 14), color = "black",
            alpha=0, linewidth=1) + # x3, y13 positive
  geom_rect(aes(xmin = 11, xmax = 12, ymin = 6, ymax = 7), color = "black",
            alpha=0, linewidth=1) # x11, y6 negative
plot
ggsave(paste0(output, "/kidswoman_workopen_cells.pdf"), plot, 
       height = 10, width = 6)

## END FILE ####################################################################

