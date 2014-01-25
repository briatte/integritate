
#
# 2. plot the data that comes with the links (date, institution, etc.)
#

library(ggmap)
library(ggplot2)
library(lubridate)
library(plyr)
library(scales)

#
# SETTINGS
#

# subset to categories with more than x links
min_category = 100

# subset to years with more than x links
min_year = 4000

#
# category full names
#
data$Categorie_Number = data$Categorie      # keep original numeric id
data$Categorie[ data$Categorie == 35] = 33  # fix last category number

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

data$Data = as.Date(data$Data)
data$Year = year(data$Data)
table(data$Year)

# subset to years with 4,000+ links (2008-2013)

years <- names(table(data$Year)[ table(data$Year) > min_year ])
nrow(subset(data, Year %in% years)) / nrow(data) # percentage of kept data
table(data$Year)

data = subset(data, Year %in% years)
data$Year = factor(data$Year)

# inspect top 0.1% most frequent terms

funcs = table(unlist(strsplit(as.character(data$Functie), " ")))
funcs = funcs[ nchar(names(funcs)) > 5]

terms = names(funcs[ funcs > quantile(funcs, probs = .997) ])
terms = gsub("[^A-Z]+", "_", terms)
terms = terms[ !grepl("NECOMPLETAT", terms) & nchar(terms) > 5 ]
terms

# detect unique identifier terms (slow)

x = 990:999 / 1000
l = strsplit(as.character(data$Functie), " ")
l = lapply(l, function(x) x[ nchar(x) > 5 ])
f = table(unlist(l))
y = lapply(x, function(x) {
  cat("Testing naive classifier at q =", x, "\n")
  t = names(f[ f > quantile(f, probs = x) ])
  t = lapply(l, function(i) sum(t %in% i))
  return(t)
})
y = unlist(lapply(y, function(y) sum(y == 1)))
xmax = x [ which( y == max(y)) ]
ymax = y [ which( y == max(y)) ]

# plot the performance of quantile cutpoints against full corpus

fig0a = qplot(x, y, geom = "line") + theme_grey(10) + 
  geom_point(aes(y = ymax, x = xmax), color = "red")
fig0a

ggsave("fig0a_cutpoints.png", fig0a, width = 10, height = 10)
cat("Fig. 0a saved\n")

xmax # optimal quantile cutpoint
ymax / nrow(data) # percentage of successfully classified items

# create classification for q = .997, identifying ~ 280,000 items

data$Functie_Basic = unlist(lapply(l, function(x) {
  ifelse(sum(terms %in% x) == 1, terms[ which(terms %in% x) ], NA)
}))

# plot the data by mutually exclusive job title qualificative

fig0b = qplot(data = data, x = Year, group = Functie_Basic, 
      fill = Functie_Basic, position = "stack", geom = "bar")
fig0b

ggsave("fig0b_classifier.png", fig0b, width = 10, height = 10)
cat("Fig. 0b saved\n")

#
# PLOTS
#

# Fig. 1
# plot by county

data$County = ifelse(data$Judet == "Bucuresti", "Bucharest", "Other")
data$County[grepl("necorespunzator", data$Judet)] = NA
data$County = factor(data$County)
table(data$County, exclude = NULL)

data$Judet[grepl("necorespunzator", data$Judet)] = NA
data$Judet = factor(data$Judet)
table(data$Judet, exclude = NULL)

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

ggsave("fig1_county.png", fig1, width = 10, height = 10)
cat("Fig. 1 saved\n")

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

ggsave("fig2_type.png", fig2, width = 10, height = 10)
cat("Fig. 2 saved\n")

# Fig. 3
# plot by month and naively classified job title (slow)

data$Month = month(data$Data, label = TRUE)
mt = ddply(data, .(Year, Month, Functie_Basic), summarise, n = length(URL))

fig3 = qplot(data = mt, group = Functie_Basic, fill = Functie_Basic, 
             x = Month, y = n, position = "stack", geom = "area") + 
  scale_y_continuous(label = comma) +
  facet_wrap(~ Year, ncol = 1) + 
  theme_grey(10) + theme(legend.position = "right") +
  labs(x = NULL, y = "Number of links\n")
fig3

ggsave("fig3_month.png", fig3, width = 10, height = 10)
cat("Fig. 3 saved\n")

# Fig. 4
# plot by week and institution category (even slower)

data$Julian_Week = julian(data$Data, 
  origin = as.Date(paste0(levels(data$Year)[1], "-01-01"))) %/% 7
summary(data$Julian_Week) # number of consecutive weeks in the data

jw = ddply(data, .(Julian_Week, Categorie_Abbr), summarise, n = length(URL))
jw_breaks = unique(jw$Julian_Week[ jw$Julian_Week %% 52 == 0]) # get first week of each data-year
jw_labels = levels(data$Year) # should produce as many labels as there are data-year breaks

fig4 = qplot(data = jw, group = Categorie_Abbr, fill = Categorie_Abbr,
             x = Julian_Week, y = n, position = "stack", geom = "area") + 
  scale_x_continuous(breaks = jw_breaks, labels = jw_labels) +
  scale_y_continuous(label = comma) +
  theme_grey(10) + labs(y = "Number of links\n", x = NULL)
fig4

ggsave("fig4_week.png", fig4, width = 16, height = 8)
cat("Fig. 4 saved\n")

# Fig. 5
# plot by weekday

fig5 = qplot(data = data, x = wday(data$Data, label = TRUE, abbr = TRUE), 
             fill = Month, geom = "bar") + 
  scale_x_discrete(breaks = "Wed") +
  scale_y_continuous(label = comma) +
  facet_wrap( ~ Year) +
  theme_grey(10) + theme(legend.position = "right") +
  labs(x = NULL, y = "Number of links\n")
fig5

ggsave("fig5_weekday.png", fig5, width = 7, height = 4)
cat("Fig. 5 saved\n")

# Fig. 6
# detrended year time series by institution

yd = ddply(data, .(Year, County, Categorie_Abbr), summarise, n = length(URL))

fig6 = qplot(data = yd, group = Categorie_Abbr, color = Categorie_Abbr,
      x = Year, y = n, geom = "line") + 
  scale_y_log10(breaks = 10^(1:5), label = comma) +
  facet_wrap(~ County, ncol = 1) +
  theme_grey(10) + theme(legend.position = "right") +
  labs(y = "Number of links, log-10 scale\n", x = NULL)
fig6

ggsave("fig6_log10.png", fig6, width = 10, height = 10)
cat("Fig. 6 saved\n")

# Fig. 7 and 8
# heatmaps of institutions and naive job titles

cf = ddply(data, .(Categorie_Abbr, Functie_Basic), summarise, n = length(URL))
nf = subset(cf, !is.na(Functie_Basic) & !grepl("^M ", Categorie_Abbr)) # non-ministries

fig7 = qplot(data = nf, x = Categorie_Abbr, y = Functie_Basic, 
      fill = log10(n), alpha = log10(n), geom = "tile") +
  scale_fill_gradient(low = "white", high = "darkred") +
  theme_minimal(10) + theme(legend.position = "none") +
  labs(y = "Naive job title classifier\n", x = "\nAdministration")
fig7

ggsave("fig7_heatmap0.png", fig7, width = 14, height = 8)
cat("Fig. 7 saved\n")

mf = subset(cf, !is.na(Functie_Basic) & grepl("^M ", Categorie_Abbr))  # ministries
mf$Categorie_Abbr = toupper(gsub("^M ", "", mf$Categorie_Abbr))

fig8 = qplot(data = mf, x = Categorie_Abbr, y = Functie_Basic, 
             fill = log10(n), alpha = log10(n), geom = "tile") +
  scale_fill_gradient(low = "white", high = "darkred") +
  theme_minimal(10) + theme(legend.position = "none") +
  labs(y = "Naive job title classifier\n", x = "\nMinistry")
fig8

ggsave("fig8_heatmap1.png", fig8, width = 14, height = 8)
cat("Fig. 8 saved\n")

# Fig. 9
# map town geocode to counts

if(!file.exists("geocodes.rda")) {
  geocodes = lapply(levels(data$Localitate), function(x) {
    cat(length(geocodes) - which(geocodes == x), ":", x, "\n")
    y = try(geocode(paste0(x, ", Romania"), output = "latlona", messaging = FALSE))
    if(class(y) == "try-error") y = data.frame(lon = NA, lat = NA, address = NA)
    return(c(x, y))
  })
  geocodes = rbind.fill(geocodes)
  geocodes$Localitate = gsub(", Romania", "", geocodes$x)
  geocodes = geocodes[, -1]
  save(geocodes, file = "geocodes.rda")
}
load("geocodes.rda")
data = merge(data, geocodes, by = "Localitate")

geo_rom = get_map(location = "romania", zoom = 6, color = "bw", source = "google")
geo_loc = ddply(data, .(Localitate), summarise, lon = mean(lon), lat = mean(lat), n = length(URL))

fig9 = ggmap(geo_rom) + 
  geom_point(data = geo_loc, 
             aes(x = lon, y = lat, size = sqrt(n)), 
             alpha = .5, color = "darkred") +
  scale_size_area(max_size = 10) +
  theme(legend.position = "none", 
        axis.line = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text = element_blank()) +
  labs(y = NULL, x = NULL)
fig9

ggsave("fig9_geo.png", fig9, width = 7, height = 7)
cat("Fig. 9 saved\n")

#
# SAVE PROCESSED DATASET
#

save(data, file = "integritate.rda")
cat("Processed dataset saved\n\nkthxbye\n")

# kthxbye
