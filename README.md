# README

R scripts to scrape, download and plot links from the Romanian [National Integrity Agency](http://integritate.eu/). The data come from a bit everywhere:

![](fig9_geo.png)

Breakdowns from the current dataset:

![](fig1_county.png)
![](fig2_type.png)

Breakdown by institution: 

    > load("integritate.rda")
    > df = aggregate(URL ~ Categorie, length, data = data)
    > df[order(df$URL, decreasing = TRUE), ]
                                                          Categorie    URL
                                                 Autoritati publice 358892
                                      Ministerul Finantelor Publice 131070
                                Consiliul Superior al Magistraturii  71350
         Ministerul Educatiei, Cercetarii, Tineretului si Sportului  55187
         Ministerul Administratiei si Internelor [MISSING 80% DATA]  55184
                                               Ministerul Justitiei  52691
                  Ministerul Muncii, Familiei si Protectiei Sociale  43704
                                                 Companii nationale  39391
                                                  Guvernul Romaniei  35654
                                      Ministerul Apararii Nationale  32700
                      Ministerul Agriculturii si Dezvoltarii Rurale  30891
                                       Ministerul Public - Parchete  26773
                                               Ministerul Sanatatii  26765
                                   Ministerul Mediului si Padurilor  21187
                                                Autoritati autonome  14582
                      Ministerul Transporturilor si Infrastructurii  13944
                                                    Alte Institutii   9999
                                               Parlamentul Romaniei   9985
            Ministerul Economiei, Comertului si Mediului de Afaceri   7187
                     Ministerul Dezvoltarii Regionale si Turismului   6605
                                                 Institutii publice   5829
                                      Ministerul Afacerilor Externe   4497
                      Ministerul Culturii si Patrimoniului National   3012
             Ministerul Comunicatiilor si Societatii Informationale   2219
                                Federatii si confederatii sindicale   1656
                                     Ministerul Afacerilor Europene   1202
                Autoritatea pentru Valorificarea Activelor Statului   1091
                                         Banca Nationala a Romaniei   1039
                                               Presedentia Romaniei    524
      Banci la care statul este actionar majoritar sau semnificativ    106

## HOWTO

The main entry point is `0.scrape.r`. Make sure to review the opening parameters. This will trigger `1.tables.r` to download the tables, and `2.plots.r` to visualize the aggregated data. The download loop in `3.download.r` for the PDF files should be run separately. All download functions are wrapped in failsafe `try()` functions and will skip existing files to protect data from previous scrapes. The PDF download loop sleeps three seconds between each file.

The scripts were tested by scraping over one million links for categories `1:6`, `8:23`, `26:32` and `35` as well as the three smallest subcategories of category `7` (Ministry of the Interior). The missing categories are the largest subcategory of the Ministry of the Interior (_Autoritati_, _n_ ~ 6,400 pages), the Central Election Bureau (_n_ ~ 9,000 pages), and uncategorized documents (_n_ ~ 9,000 pages). The final dataset holds _N_ = 1,064,916 links for years 2008–2013:

![](fig4_week.png)

The data are not included in the repository, but you can [open an issue](issues) to request it.

## NOTES

Backup line for the extended repo (code, processed dataset, figures):

    zip(paste0("integritate_", Sys.Date(), ".zip"),    # file name
        files = dir(pattern = ".r$|.rda$|README|fig"))

From a sample of slightly below 2,000 files filled in by employees of the Ministry of External Affairs, average PDF file size is about 1.7 MB.

> > _Last edited 2013-12-16_
