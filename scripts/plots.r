#
# demo plots
#

library(ggmap)
library(ggplot2)
library(scales)
library(dplyr)

# be patient
load("integritate.rda")

# stacked counts per week
data$Julian_Week = julian(data$Data, 
                          origin = as.Date(paste0(levels(data$Year)[1], 
                                                  "-01-01"))) %/% 7
summary(data$Julian_Week) # number of consecutive weeks in the data

data$Julian_Week = as.numeric(data$Julian_Week)

jw = data %.%
  group_by(Julian_Week, Categorie_Abbr) %.%
  summarise(n = length(URL))

jw = jw[ order(jw$Julian_Week), ]
# get first week of each data-year
jw_breaks = unique(jw$Julian_Week[ jw$Julian_Week %% 52 == 0])
                   
# should produce as many labels as there are data-year breaks
jw_labels = levels(data$Year)[ order(jw_breaks) ]

qplot(data = data.frame(jw), x = Julian_Week, fill = Categorie_Abbr, 
      position = "stack", stat="bin", geom = "area") +
  scale_fill_discrete("") +
  scale_x_discrete(breaks = jw_breaks, labels = jw_labels) +
  scale_y_continuous(label = comma) +
  theme_minimal() + labs(y = "Number of links\n", x = NULL)

ggsave("week.png", width = 11, height = 9)

# geographic distribution
data$Localitate = as.character(data$Localitate)

# geo data
if(!file.exists("geo.rda")) {
  geocodes = lapply(levels(data$Localitate), function(x) {
    cat(length(geocodes) - which(geocodes == x), ":", x, "\n")
    y = try(geocode(paste0(x, ", Romania"), output = "latlona", messaging = FALSE))
    if(class(y) == "try-error") y = data.frame(lon = NA, lat = NA, address = NA)
    return(c(x, y))
  })
  geocodes = rbind.fill(geocodes)
  geocodes$Localitate = gsub(", Romania", "", geocodes$x)
  geocodes = geocodes[, -1]
  romania = get_map(location = "romania", zoom = 6, color = "bw", source = "google")
  save(geocodes, romania, file = "geo.rda")
}
load("geo.rda")

# fast merge
data = inner_join(data, geocodes, by = "Localitate")

# plot by lat/lon
map = data %.%
  group_by(Tip, Localitate) %.%
  summarise(
    lon = mean(lon),
    lat = mean(lat),
    n = length(URL))

ggmap(romania) + 
  geom_point(data = map, aes(x = lon, y = lat, 
                             size = n^(1/3), 
                             color = n^(1/3), 
                             alpha = n^(1/3))) +
  scale_color_gradient2(low = "#ffffb2", 
                        mid = "#fd8d3c", 
                        midpoint = quantile(map$n^(1/3), .975), 
                        high = "#bd0026") +
  scale_alpha_continuous(range = c(.5, .75)) +
  scale_size_area(max_size = 10) +
  guides(size = FALSE) +
  theme(legend.position = "none", 
        axis.line = element_blank(), 
        axis.ticks = element_blank(), 
        axis.text = element_blank()) +
  labs(y = NULL, x = NULL)

ggsave("geo.png", width = 9, height = 9)

# bye
