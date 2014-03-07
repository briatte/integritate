
#
# scrape links to declarations and metadata
#

library(ggplot2)
library(lubridate)
library(plyr)
library(scales)
library(XML)

#
# SETTINGS
#

# set sample to TRUE to scrape only ten random pages
# for each institutional category (for quick testing purposes)

sample = FALSE

# set threshold to exclude categories with many pages
# (keep at 9,000 to exclude the two largest categories, 24 and 25)

threshold = 9000 # set at 10^4 to try to scrape everything (fails on 24 and 25)

# complete set of institutional categories (CatInst)

page.groups = c(1:32, 35) # exhaustive set (2013-12-15)

# subset to categories with more than x links
min_category = 100

# subset to years with more than x links
min_year = 4000

# category full names
Categorie = c(
  "Autoritati publice",                      # 1
  "Alte Institutii",                         # 2
  "Autoritati autonome",                     # 3
  "Companii nationale",                      # 4
  "Consiliul Superior al Magistraturii",     # 5
  "Guvernul Romaniei",                       # 6
  "Ministerul Administratiei si Internelor", # 7
  "Ministerul Afacerilor Externe",           # 8
  "Ministerul Agriculturii si Dezvoltarii Rurale",              # 9
  "Ministerul Apararii Nationale",                              # 10
  "Ministerul Comunicatiilor si Societatii Informationale",     # 11
  "Ministerul Culturii si Patrimoniului National",              # 12
  "Ministerul Dezvoltarii Regionale si Turismului",             # 13
  "Ministerul Economiei, Comertului si Mediului de Afaceri",    # 14
  "Ministerul Educatiei, Cercetarii, Tineretului si Sportului", # 15
  "Ministerul Finantelor Publice",          # 16
  "Ministerul Justitiei",                   # 17
  "Ministerul Mediului si Padurilor",       # 18
  "Ministerul Muncii, Familiei si Protectiei Sociale", # 19
  "Ministerul Public - Parchete",           # 20
  "Ministerul Sanatatii",                   # 21
  "Ministerul Transporturilor si Infrastructurii", # 22
  "Parlamentul Romaniei",                   # 23
  "Biroul Electoral Central",               # 24
  "Institutie completata necorespunzator",  # 25 (Unknown)
  "Presedentia Romaniei",                   # 26
  "Institutii publice",                     # 27
  "Banca Nationala a Romaniei",             # 28
  "Banci la care statul este actionar majoritar sau semnificativ", # 29
  "Autoritatea pentru Valorificarea Activelor Statului",           # 30
  "Federatii si confederatii sindicale",    # 31
  "Parlamentul European",                   # 32
  "Ministerul Afacerilor Europene")         # 35 (33 in vector)

# category short names
Categorie_Abbr = c("Autor publice", "Alte Instit", "Autor auton", 
                   "Companii nat", "Cons S Magistr", 
                   "Guvernul Rom", "M Admin Intern", 
                   "M Afac Ext", "M Agr Rur", 
                   "M Apar Nat", "M Comunic", 
                   "M Cultur", "M Reg Turism", 
                   "M Eco", "M Edu Sport", 
                   "M Fin Pub", "M Just", "M Paduri", 
                   "M Munc Famil", "M Pub-Parch", 
                   "M Sanat", "M Transp Infra", 
                   "Parlament", "Bir Elec Centr", "Unknown", 
                   "Presedent", "Instit publice", "Banca Nat", 
                   "Banci actionar", 
                   "Autor Activ Stat", "Fede sindic", 
                   "Parlament Eur", "M Afac Eur")

# complete set of institutional subcategories (SubCatInst)

page.subcat = list(
c(1, 2, 5, 34),    # 1, large category, not scraped
  c(3),              # 2, single subcategory
  c(4, 30, 35, 36, 37, 39, 40, 41, 57, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 91, 92),   # 3, tons of small subcategories
  c(6, 88:90),        # 4
  c(7, 93:97),        # 5
  c(8, 29, 38, 58),   # 6
  c(9, 43, 61, 105),  # 7
  c(10, 44, 62, 103), # 8
  c(11, 45, 63),      # 9
  c(12, 46, 64),      # 10
  c(13, 47, 65),      # 11
  c(14, 48, 66),      # 12
  c(15, 56, 67),      # 13
  c(16, 42, 60),      # 14
  c(17, 49, 68),      # 15
  c(18, 50, 69),      # 16
  c(19, 51, 70),      # 17
  c(20, 52, 71),      # 18
  c(21, 53, 72),      # 19
  c(22, 98:102),      # 20
  c(23, 54, 73),      # 21
  c(24, 55, 74),      # 22
  c(25, 31, 32),      # 23
  c(26, 27),          # 24
  c(28),  # 25
  c(33),  # 26
  c(59),  # 27
  c(75),  # 28
  c(87),  # 29
  c(104), # 30
  c(106), # 31
  c(107), # 32
  c(109:111) # 35
  )

# number of pages (Pag) for each category

page.totals = c(7335, 260, 296, 806, 1448, 725, 7529, 98, 630, 674, 46, 62, 134, 146, 1126, 2649, 1071, 433, 888, 550, 548, 288, 241, 9343, 9881, 11, 119, 23, 3, 23, 34, 1, 25)
sum(page.totals)

# number of pages (Pag) for each subcategory

page.number = list(
  c(1231, 2445, 59, 3601), # 1 (very large -- decentralised government)
  c(260), # 2 (same as category number of pages)
  c(30, 21, 1, 129, 24, 5, 16, 12, 3, 4, 7, 22, 1, 2, 2, 1, 1, 1, 5, 1, 1, 16), # 3
  c(298, 203, 29, 279),        # 4
  c(27, 9, 642, 473, 252, 47), # 5
  c(94, 553, 75, 4),           # 6
  c(582, 273, 6391, 283),      # 7 (very large -- Min. Admin. and Interior)
  c(11, 47, 10, 30),           # 8
  c(5, 43, 583),               # 9
  c(1, 18, 656),               # 10
  c(5, 20, 22),                # 11
  c(5, 12, 46),                # 12
  c(5, 99, 31),                # 13
  c(23, 58, 67),               # 14
  c(3, 55, 1069),              # 15
  c(27, 143, 2480),            # 16
  c(12, 67, 993),              # 17
  c(3, 54, 377),               # 18
  c(19, 30, 840),              # 19
  c(9, 92, 235, 133, 70, 13),  # 20
  c(3, 41, 504),               # 21
  c(4, 54, 232),               # 22
  c(16, 168, 58),              # 23
  c(4, 9339),                  # 24 (very large -- Central Election Bureau)
  c(9881), # 25 (very large -- 'Unknown' institution, ~ 20% of all pages)
  c(11),   # 26 (small -- presidency)
  c(119),  # 27
  c(23),   # 28
  c(3),    # 29 (very small, banks with government shareholder participation)
  c(23),   # 30
  c(34),   # 31
  c(1),    # 32 (very small -- European Parliament)
  c(1, 24, 1) # 35
  )

# check that the subcategory/page lists are identically formed
stopifnot(all(sapply(page.subcat, length) == sapply(page.number, length)))

# total number of HTML subcategory pages/tables to scrape (~ 47,500)
sum(sapply(page.number, sum))

# proportion of uncategorized pages (cat. 25, ~ 10,000 pages, 20% of total)
page.number[[25]][1] / sum(sapply(page.number, sum))

# remove longer series
# note: existing files are skipped later by the download loop

(excludes    = unique( which( page.totals > threshold + 1) ))
if(length(excludes) > 0) {
  page.groups = page.groups[ - excludes ]
  page.subcat = page.subcat[ - excludes ]
  page.totals = page.totals[ - excludes ]
  page.number = page.number[ - excludes ]
}

# view the categories and subcategories that you have set to
# scrape links for, and view total number of pages to scrape

cbind(page.groups, page.totals) # sample categories
sum(sapply(page.number, sum))   # total pages set to scrape

#
# SCRAPER
#

# get links and details on all downloadable PDF files, save
# info to plain text lists of links to the .pdf documents

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
        y = try(htmlParse(u), encoding = "UTF-8", silent = TRUE)
        
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

data$Tip = ifelse(grepl("avere", data$Tip), "A", "I") # Avere, Interese
data$Tip[ is.na(data$Tip) ] = NA
data$Tip = factor(data$Tip)
table(data$Tip, exclude = NULL)

data$Judet[ grepl("necorespunzator", data$Judet) ] = NA
data$Judet = factor(data$Judet)
table(data$Judet, exclude = NULL)

data$URL = gsub("http://declaratii.integritate.eu/UserFiles/PDFfiles/", 
                "", data$URL)

data$Data = as.Date(data$Data)

cat("\nPreprocessed dataset (integritate_raw.txt):\n") # overview of links index
str(data)

# save to plain text table, space-separated, quoted values

write.table(data, file = "integritate_raw.txt", row.names = FALSE)

#
# PROCESS
#

data$Categorie_Number = data$Categorie      # keep original numeric id
data$Categorie[ data$Categorie == 35] = 33  # fix last category number

data$Categorie_Abbr = Categorie_Abbr[data$Categorie]
table(data$Categorie_Abbr)

data$Categorie = Categorie[data$Categorie]
table(data$Categorie)

# subset to categories with 100+ files
# drops category 32, European Parliament (n = 8)

categories = names(table(data$Categorie)[table(data$Categorie) > min_category])
data = subset(data, Categorie %in% categories)

# remove categories 24 (Central Election Bureau) and 25 (Uncategorized)

data = subset(data, !Categorie_Number %in% 24:25)

# replace subCatInst numbers by subcategory names
# TODO: write list of subcategories, full and abbreviated
# ...

# years

data$Year = year(data$Data)
table(data$Year)

# subset to years with 4,000+ links (2008-2013)

years = names(table(data$Year)[ table(data$Year) > min_year ])
nrow(subset(data, Year %in% years)) / nrow(data) # percentage of kept data
table(data$Year)

data = subset(data, Year %in% years)
data$Year = factor(data$Year)

#
# PLOTS
#

# Fig. 1
# plot by county

data$County = ifelse(data$Judet == "Bucuresti", "Bucharest", "Other")
data$County[is.na(data$Judet)] = NA
data$County = factor(data$County)
table(data$County, exclude = NULL)

fig1 = qplot(data = data, x = Year, group = County, fill = County, 
             position = "stack", geom = "bar") + 
  scale_x_discrete(breaks = years[ seq(1, 
    length(years), by=2) ]) + # label odd years
  scale_y_continuous(label = comma) +
  facet_wrap(~ Categorie_Abbr) + # facet by abbreviated category
  scale_fill_brewer(palette = "Set1") +
  theme_grey(10) + theme(legend.position = "bottom") +
  labs(x = NULL, y = "Number of links\n")
fig1

ggsave("plots/by_county.png", fig1, width = 10, height = 10)

# Fig. 2
# plot by year

fig2 = qplot(data = data, x = Year, group = Tip, fill = Tip, 
             position = "stack", geom = "bar") + 
  scale_x_discrete(breaks = years[ seq(1, 
    length(years), by=2) ]) + # label odd years
  scale_y_continuous(label = comma) +
  facet_wrap(~ Categorie_Abbr) + # facet by abbreviated category
  scale_fill_brewer(palette = "Set1") +
  theme_grey(10) + theme(legend.position = "bottom") +
  labs(x = NULL, y = "Number of links\n")
fig2

ggsave("plots/by_type.png", fig2, width = 10, height = 10)

# plot over weekday

# fig5 = qplot(data = data, x = wday(data$Data, label = TRUE, abbr = TRUE), 
#              fill = Month, geom = "bar") + 
#   scale_x_discrete(breaks = "Wed") +
#   scale_y_continuous(label = comma) +
#   facet_wrap( ~ Year) +
#   theme_grey(10) + theme(legend.position = "right") +
#   labs(x = NULL, y = "Number of links\n")
# fig5
# 
# ggsave("plots/by_weekday.png", fig5, width = 7, height = 4)

#
# SAVE PROCESSED DATASET
#

save(data, file = "integritate.rda")
cat("Processed dataset saved\n\nkthxbye\n")

# kthxbye
