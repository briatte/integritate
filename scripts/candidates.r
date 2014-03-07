library(plyr)
library(XML)
##### 1. retrieve pdf links and tables #####

r = 1:99 # number of pages to parse for pdf links

url = "http://declaratii.integritate.eu"
pre = "/home/navigare/alegeri-2012.aspx?pag="
post = "&CatInst=&SubcatInst=&Inst=&CatFnc=&SubcatFnc=&Fnc=&Judet=&An=&Tip=&NumePrenume=&advancedAction=AdvancedSearch&_orderBy=NumePrenume"

links = lapply(r, function(x) {
  u = paste0(url, pre, x, post)
  cat("  ", x, ":", u, "\n") #display the page being parsed currently
  y = try(htmlParse(u), silent = TRUE)
  if ("try-error" %in% class(y)) {
    cat("htmlParse issue on link", x, "\n")
  }
  else {
    
    # links
    l = xpathSApply(y, "//table/tr/td/a/@href")
    l = paste0(url, l[grepl(".pdf$", l)])
    
    # table
    t = readHTMLTable(y)[[1]]
    t = subset(t, V8 == "Vezi document")
    
    # merge
    t[, 8] = l
  }
  return(t)
})

# save index table
links = plyr::rbind.fill(links)
names(links) = c("Nume", "Institutie", "Functie", "Localitate", "Judet", "Data", "Tip", "URL")

#write.table(links, file = 'candidates.txt', row.names = FALSE)

##### 2. download pdf links #####

urls = as.character(links$URL)
urls = gsub("\\s", "%20", urls)

dir.create("pdfs")
setwd("pdfs")

#sink("integritate_log.txt", split=TRUE)
start.time <- date()
for(i in length(urls):1) {
  
  # clean filename
  file = paste0("pdfs", "/", gsub("%20", " ", gsub("(.*)//D", "D", urls[i])))
  
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
end.time <- date()
# See how long it took:
cat(c("Job started at:",start.time))
cat(c("Job finished at:",end.time))

#sink()
