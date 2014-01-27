
#
# download PDF declaration files from collected links
#

# sample ~ 2,000 files from Foreign Policy (8)
# average DA file size:   2.5 MB
# average DI file size:   1.0 MB

# basic download function
download.files = function(data, categorie = NULL, tip = c("da", "di"), list = TRUE, sleep = 3) {

  # subset to categories and DA, DI or both
  data = subset(data,
                Categorie_Number %in% categorie & 
                  grepl(paste0("/(", paste0(toupper(tip), collapse = "|"), ")_"), URL)
                )
  
  # defensive
  stopifnot(nrow(data) > 0)
  
  # sleep time between files
  if(sleep < 1 | sleep > 60) {
    sleep = 3
    warning("Sleeping time corrected to 3 seconds")
  }

  # filenames
  urls = as.character(data$URL)
  urls = gsub("\\s", "%20", urls)
  urls = paste0("http://declaratii.integritate.eu/UserFiles/PDFfiles/", urls)

  # folder paths
  path = paste0("docs/", paste(data$Categorie_Number, data$Subcategoria, sep = "_"))
  suppressWarnings(dir.create("docs"))
  suppressWarnings(sapply(unique(path), dir.create))

  # last defensive check before download loop
  stopifnot(length(urls) == length(path))
  
  # print download info
  message(paste(length(urls), "elements, approx. size",
                (length(urls[ grepl("/DI_", urls) ]) + 2.5 * length(urls[ grepl("/DA_", urls) ])) / 10^3, "GB",
                table(file.exists(paste0(path, "/", gsub("%20", " ", gsub("(.*)//D", "D", urls)))))[1],
                "to download"))

  if(list) {

    return(message("Set list = FALSE to (slowly) download the files."))

  }
  else {

    # folder hierarchy: docs/category_subcategory
    # filenames: {DA or DI}_{YYYY-MM-DD}_{FULL NAME}_{UID}.pdf

    # clean filenames
    file = paste0(path, "/", gsub("%20", " ", gsub("(.*)//D", "D", urls)))
    
    # download files
    for(i in length(urls):1) {
  
      # try to download
      if(file.exists(file[i])) {
        cat(i, ": skipped", file[i], "\n")
      }
      else {
        Sys.sleep(sleep) # aim at 5 seconds per file to be safe
        y = try(download.file(urls[i], destfile = file[i], quiet = TRUE,
                              method = "curl", extra = "--globoff"))
        if(class(y) == "try-error") {
          cat(i, ": failed to download", urls[i], "\n")
        }
        else {
          cat(i, ": downloaded", file[i], "\n")
        }
      }
    }

  }

}

# rollin'
