#
# naive classifier of job titles
#

library(ggplot2)
load("integritate.rda")

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

cutpoints = qplot(x, y, geom = "line") + theme_grey(10) + 
  geom_point(aes(y = ymax, x = xmax), color = "red")
cutpoints

ggsave("plots/classifier_cutpoints.png", cutpoints, width = 10, height = 10)

xmax # optimal quantile cutpoint
ymax / nrow(data) # percentage of successfully classified items

# create classification for q = .997, identifying ~ 280,000 items

data$Functie_Basic = unlist(lapply(l, function(x) {
  ifelse(sum(terms %in% x) == 1, terms[ which(terms %in% x) ], NA)
}))

# plot the data by mutually exclusive job title qualificative

classifier = qplot(data = data, x = Year, group = Functie_Basic, 
      fill = Functie_Basic, position = "stack", geom = "bar")
classifier

ggsave("plots/classifier_by_year.png", classifier, width = 10, height = 10)

# heatmaps of institutions and naive job titles

cf = ddply(data, .(Categorie_Abbr, Functie_Basic), summarise, n = length(URL))
nf = subset(cf, !is.na(Functie_Basic) & !grepl("^M ", Categorie_Abbr)) # non-ministries

hm = qplot(data = nf, x = Categorie_Abbr, y = Functie_Basic, 
      fill = log10(n), alpha = log10(n), geom = "tile") +
  scale_fill_gradient(low = "white", high = "darkred") +
  theme_minimal(10) + theme(legend.position = "none") +
  labs(y = "Naive job title classifier\n", x = "\nAdministration")
hm

ggsave("plots/classifier_heatmap1.png", hm, width = 14, height = 8)

mf = subset(cf, !is.na(Functie_Basic) & grepl("^M ", Categorie_Abbr))  # ministries
mf$Categorie_Abbr = toupper(gsub("^M ", "", mf$Categorie_Abbr))

hm = qplot(data = mf, x = Categorie_Abbr, y = Functie_Basic, 
             fill = log10(n), alpha = log10(n), geom = "tile") +
  scale_fill_gradient(low = "white", high = "darkred") +
  theme_minimal(10) + theme(legend.position = "none") +
  labs(y = "Naive job title classifier\n", x = "\nMinistry")
hm

ggsave("plots/classifier_heatmap2.png", hm, width = 14, height = 8)

# done
