
#
# 3. download PDF declaration files from collected links
#

# WARNING: the script tries to download ALL links for one or more categories.
# My estimate on 2,000 files from the Ministry of Foreign Policy is that the
# mean file size is at 1.7 MB, so that Ministry alone is 28,000 docs ~ 48 GB.
# If each file takes 5 seconds, a full download will take around 40 hours.

load("integritate.rda")

# filenames
urls = as.character(data$URL)
urls = gsub("\\s", "%20", urls)

# folder paths
path = paste0("docs/", paste(data$Categorie, data$Subcategoria, sep = "_"))

dir.create("docs")               # main data folder
sapply(unique(path), dir.create) # subfolders to keep files organized

# subset to Ministry of Foreign Policy (for testing purposes)
urls = urls[ grepl("/8_", path )])
path = path[ grepl("/8_", path )])

length(urls)
length(urls) == length(path)) # check

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
