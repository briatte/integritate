
#
# 3. download PDF declaration files from collected links
#

# sample ~ 2,000 files from Foreign Policy (8)
# average DA file size:   2.5 MB
# average DI file size:   1.0 MB

load("integritate.rda")
str(data)

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
  if(list) {

    message(paste(length(urls), "elements, approx. size",
                  (length(urls[ grepl("/DI_", urls) ]) + 2.5 * length(urls[ grepl("/DA_", urls) ])) / 10^3, "GB",
                  table(file.exists(paste0(path, "/", gsub("%20", " ", gsub("(.*)//D", "D", urls)))))[1],
                  "to download"))
    return(urls)

  }
  else {

    # folder hierarchy: docs/category_subcategory
    # filenames: {DA or DI}_{YYYY-MM-DD}_{FULL NAME}_{UID}.pdf
    
    # download files
    for(i in length(urls):1) {

      # clean filename
      file = paste0(path[i], "/", gsub("%20", " ", gsub("(.*)//D", "D", urls[i])))
  
      # try to download
      if(file.exists(file)) {
        cat(i, ": skipped", file, "\n")
      }
      else {
        Sys.sleep(sleep) # should amount to 5 seconds per file
        y = try(download.file(urls[i], destfile = file, quiet = TRUE,
                              method = "curl", extra = "--globoff"))
        if(class(y) == "try-error") {
          cat(i, ": failed to download", urls[i], "\n")
        }
        else {
          cat(i, ": downloaded", file, "\n")
        }
      }
    }

  } # could be parallelized; do you have a multicore computer? i'm on a single CPU

}

# example: 

# count DIs in the Ministries of Foreign Policy (8) and Communication (11)
head(download.files(data, c(8, 11), tip = "di"))

# count DIs in every Ministry
head(download.files(data, unique(data$Categorie_Number[ grepl("Ministerul", data$Categorie)]), tip = "di"))

# rollin'
