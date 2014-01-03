
#
# 1. get links and details on all downloadable PDF files
#

library(plyr)
library(XML)

# create plain text lists of links to the .pdf documents

for(group in 1:length(page.groups)) { # loop over categories
  
  cat("\nWorking on institution category", page.groups[group], ",", 
      length(page.subcat[[group]]), "subcategories,", 
      sum(sapply(page.number[[group]], sum)), "total pages\n\n")

  for(subcat in 1:length(page.subcat[[group]])) { # loop over subcategories
    
    cat("Getting", ifelse(sample, "sample", "full"),
        "tables for institution category", page.groups[group], 
        ", subcategory", page.subcat[[group]][subcat],
        ",", page.number[[group]][subcat], "pages\n")

    file = paste0("integritate_", ifelse(sample, "sample", "full"), "_table_", 
                  page.groups[group], "_", page.subcat[[group]][subcat], ".txt")

    url = "http://declaratii.integritate.eu"
    pre = "/home/navigare/cautare-avansata.aspx?pag="
    cat = "&CatInst="
    sub = "&SubcatInst="
    post = "&Inst=&CatFnc=&SubcatFnc=&Fnc=&Judet=&An=&Tip=&NumePrenume=&advancedAction=AdvancedSearch&_orderBy=NumePrenume"

    seq = page.number[[group]][subcat]:1
    if(sample) seq = sample(seq, 10) ## test samples hold only 10 pages/category

    ## create links index

    if(file.exists(file)) {
      cat("Skipping:", file, "\n")
    }
    else {
      cat("Writing:", file, "\n")
      
      links = lapply(seq, function(x) {
        u = paste0(url, pre, x, 
                   cat, page.groups[group], 
                   sub, page.subcat[[group]][subcat],
                   post)

        cat("  ", x, ":", u, "\n")

        t = data.frame()
        y = try(htmlParse(u), silent = TRUE)

        if ("try-error" %in% class(y)) {
          cat("htmlParse error: failed to parse\n")
          print(y)
        }
        else if (is.null(class(y)) | !length(y)) {
          cat("htmlParse error: null data\n")
          print(y)
        }
        else {
          # links
          l = try(xpathSApply(y, "//table/tr/td/a/@href"))
          if ("try-error" %in% class(l)) {
            cat("xpathSApply error\n")
            print(l)
          }
          else {
            l = paste0(url, l[grepl(".pdf$", l)])

            # table
            t = try(readHTMLTable(y)[[1]])
            if ("try-error" %in% class(t) | dim(t)[2] < 8) {
                cat("readHTMLTable error: invalid table\n")
                print(t)
                t = data.frame()
            }
            else {
              t = subset(t, V8 == "Vezi document")
              # merge
              if(nrow(t) == length(l)) {
                t$V8 = l
              }
              else {
                cat("Dimension mismatch, saving table only\n")
                print(t)
                t$V8 = NA
              }            
            }
          }
        }
        return(t)
      })

      # save index table
      links = plyr::rbind.fill(links)
      links = cbind( page.groups[group], page.subcat[[group]][subcat], links )
      names(links) = c("Categorie", "Subcategoria", "Nume", "Institutie", "Functie", "Localitate", "Judet", "Data", "Tip", "URL")
    
      write.table(links, file = file, row.names = FALSE)
    }
    
  }
}

# get list of full tables

files = dir(pattern = "full_table_[0-9]+_[0-9]+.txt$")
cat("\nMerging", length(files), "files to integritate_raw...\n")

# read and merge datasets

data = lapply(files, read.table, sep = " ", header = TRUE)
data = rbind.fill(data)

#
# VARIABLES (saved to integritate.rda after plotting)
#
# - Categorie        : category (full text) 
# - Categorie_Number : category (numeric)
# - Categorie_Abbr   : category (abbreviated)
# - Subcategoria     : subcategory, numeric
# - job title   : full text and basic classification from most common terms
# - Data (date)        : full ymd, split to years, months and weekdays for plots
# - Localitate (location)    : district and town
# - Tip (type)        : either avere or interese
# - URL to file : HTTP link to PDF, average file size ~ 1.7 MB
#

data$Tip = ifelse(grepl("avere", data$Tip), "Avere", "Interese")
data$Tip[ is.na(data$Tip) ] = NA
data$Tip = factor(data$Tip)

data$URL = gsub("http://declaratii.integritate.eu/UserFiles/PDFfiles/", 
                "", data$URL)

cat("\nPreprocessed dataset (integritate_raw.txt):\n") # overview of links index
str(data)

# save to plain text table, space-separated, quoted values

write.table(data, file = "integritate_raw.txt", row.names = FALSE)

source("2.plots.r")

# next: plot the data
