setwd("/Users/fr/Documents/Code/R/integritate")

# data
system.time(load("integritate.rda"))
str(data[, c("Functie", "URL")])

# base
length(unique(data$Functie))
system.time(aggregate(URL ~ Functie, length, data = data))

# plyr (far too long)
# library(plyr)
# system.time(ddply(data, .(Functie), summarise, n = length(URL)))

library(dplyr)
system.time(as.data.frame(summarise(group_by(data, Functie), n = length(URL))))
system.time(summarise(group_by(data, Functie), n = length(URL)))
system.time(tbl <- group_by(data, Functie))
system.time(summarise(tbl, n = length(URL)))

# data.table
library(data.table)
system.time(as.data.frame(as.data.table(data)[, .N, by = Functie]))
system.time(as.data.table(data)[, .N, by = Functie])
system.time(data.table(data)[, .N, by = Functie])
system.time(data <- as.data.table(data))
system.time(data <- data.table(data))
system.time(data[, .N, by = Functie])

# versions
sessionInfo()
