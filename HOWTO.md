# HOWTO

The repo uses a set of scripts to download and process the metadata, and to download declaration files.

## 1. Get the links

```{S}
source("scripts/scraper.r")
```

The script downloads links for declarations from all institutions except for the two largest, the Central Election Bureau (_n_ ~ 9,000 pages) and uncategorized documents (_n_ ~ 9,000 pages), due to persistent server errors.

It then processes the data by removing years and institutions with low counts, saves the result to `integritate.rda`, and exports summary figures for declarations by year, type and county of origin to the `plots` folder.

## 2. Get the files

```{S}
source("scripts/download.r")
```

The `download.files` function loaded by `download.r` will get the PDF files of either or both assets and interests declarations. The function requires that you pass the `data` object from `integritate.rda` to work, as well as a list of categories to download.

By default, `download.files` will just estimate the size of the download; set `list` to `FALSE` to actually download the files. You might also want to adjust the sleeping time with `sleep = t` where `t` should be between `1` and `60` seconds.

Example usage:

```{S}
# load links and download function
load("integritate.rda")
source("scripts/download.r")

# count all files in all ministries (takes a minute)
# ~ 825,000 files, 1.466 TB; huge total filesize
min = with(data, Categorie_Number[ grepl("Ministerul", Categorie)])
system.time(download.files(data, min, tip = c("da", "di")))

# download DIs (interests) for Foreign Policy (8), 
# Communication (11) and European Affairs (35)
system.time(download.files(data, c(11, 35), sleep = 1, tip = "di", list = FALSE))
```

## Replicate the [tables](tables.md)

```{S}
# install pander
library(devtools)
install_github("Rapporter/pander")
# rerun tables
library(knitr)
knit("tables.Rmd")
```

## 3. Run other scripts

```{S}
source("scripts/candidates.r")
```

will produce a separate dataset for the [declarations of candidates to the 2012 legislative election](http://declaratii.integritate.eu/home/navigare/alegeri-2012.aspx), which are much quicker to parse than almost all other institutions handled by the main scraper.

```{S}
source("scripts/classifier.r")
```

matches job titles to the more frequent ones, in order to simplify the `Functie` variable. The transformation is used to plot heatmaps of job titles in courts and ministries.

```{S}
source("scripts/plots.r")
```

produces the map, which could be improved with [embedded plots](http://vita.had.co.nz/papers/embedded-plots.pdf)
