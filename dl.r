# load integritate.rda metadata object
load("integritate.rda")
str(data)

# load declarations download function
source("download.files.r")

# count all files in all ministries (takes a minute)
# ~ 825,000 files, 1.466 TB; huge total filesize
all_categories = unique(data$Categorie_Number[ grepl("Ministerul", data$Categorie)])
system.time(download.files(data, all_categories, tip = c("da", "di")))

# download DIs (interests) for Foreign Policy (8), 
# Communication (11) and European Affairs (35)
system.time(download.files(data, c(11, 35), sleep = 1, tip = "di", list = FALSE))
