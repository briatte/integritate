# README

`integritate` contains the metadata for slightly above 1.3 million assets and interests declarations filed with the Romanian [National Integrity Agency](http://integritate.eu/) since 2008, from around 1,800 locations in the country:

![](geo.png)

The replication code scrapes 31 out of 33 institutions and returns _N_ = 1,406,789 links to declaration files. The final dataset further drops declarations from the European Parliament or from before 2008, both of which have very low counts, and contains a sample of _N_ = 1,375,352 links.

Follow the [`HOWTO`](HOWTO.md) to run the scraper locally, replicate the plots, and download your own sample of declarations. Be careful not to run the download function on the largest institutions (such as local government), unless you have dozens or even hundreds of gigabytes of free disk space.

[issues]: https://github.com/briatte/integritate/issues
