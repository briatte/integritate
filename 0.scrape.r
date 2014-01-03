
#
# 0. set sampling parameters for the scraper
#

# set sample to TRUE to scrape only ten random pages
# for each institutional category (for quick testing purposes)

sample = FALSE

# set threshold to exclude categories with many pages
# (keep at 9,000 to exclude the two largest categories, 24 and 25)

threshold = 9000 # set at 10^4 to try to scrape everything (fails on 24 and 25)

# complete set of institutional categories (CatInst)

page.groups = c(1:32, 35) # exhaustive set (2013-12-15)

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

source("1.tables.r")

# next: scrape links
