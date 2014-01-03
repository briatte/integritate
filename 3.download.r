
#
# 3. download PDF declaration files from collected links
#

# WARNING: the script is parametered at lines 26-27 to download links for the
# Ministry of Foreign Policy and Ministry of Communication. There are around
# 30 files per page, and the average file size is at 1.7 MB, which amounts to
# several GB of data per institution.

load("integritate.rda")
str(data)

# filenames
urls = as.character(data$URL)
urls = gsub("\\s", "%20", urls)
urls = paste0("http://declaratii.integritate.eu/UserFiles/PDFfiles/", urls)

# folder paths
path = paste0("docs/", paste(data$Categorie_Number, data$Subcategoria, sep = "_"))

dir.create("docs")               # main data folder
sapply(unique(path), dir.create) # subfolders to keep files organized

# subset to Ministry of Foreign Policy and Ministry of Communication (testing)
urls = urls[ grepl("/(8|11)_", path )]
path = path[ grepl("/(8|11)_", path )]

length(urls)
length(urls) == length(path) # check

# download files
for(i in length(urls):1) {

  # clean filename
  file = paste0(path[i], "/", gsub("%20", " ", gsub("(.*)//D", "D", urls[i])))
  
  # try to download
  if(file.exists(file)) {
    cat(i, ": skipped", file, "\n")
  }
  else {
    Sys.sleep(3) # should amount to 5 seconds per file
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

# rollin'
