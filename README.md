# MPIDR Technical Report
R Code and LaTex for paper in preparation: "Reading Human Fertility Database and Human Mortality Database data into R"

You are free to see what I'm up to and use (with attribution):

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">"Reading Human Fertility Database and Human Mortality Database data into R"</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="https://sites.google.com/site/timriffepersonal/" property="cc:attributionName" rel="cc:attributionURL">Timothy L. M. Riffe</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

Do get in touch if you're curious about this project.

HMDHFDplus
============
There is an `R` package inside the repository called `HMDHFDplus`.

This package contains some code migrated over from the `DemogBerkeley` package, also hosted on github, as well as some new code. The `HMDHFDplus` package only contains functions for reading data into R. The `R` code is also more oranized here. Currently there are functions for reading in HMD, JMD, CHMD, HFD, and HFC code, and there are plans to implement HLD code as well, once that database is done reorganizing.

Installation
============

To download the development version of HMDHFDplus

1. make sure you have the most recent version of R
2. make sure you install the `RCurl` and `XML` packages first, which are needed for handling logins and html parsing. These packages may require extra steps to install. See further (approximate) instructions depending on OS.
3. look at the OS-specific notes below to ensure the installation will work.

Either download the [zip ball](https://github.com/timriffe/TR1/zipball/master) or [tar ball](https://github.com/timriffe/TR1/tarball/master), decompress and run `R CMD INSTALL` on it in the terminal command line. You can also look in the `Builds` folder of this repository for `tar.gz` files that you can try to [install locally](http://stackoverflow.com/questions/1474081/how-do-i-install-an-r-package-from-source). The easiset way to install is to use the **devtools** package to install the development version:
```r
# install.packages("devtools", dependencies = TRUE)

library(devtools)
install_github("timriffe/TR1/TR1/HMDHFDplus")
```


**Note**: On *nix systems first run in the terminal:
```
sudo apt-get install libcurl
sudo apt-get install libxml2-dev
```
, to install the external libraries needed by `RCurl` and `XML` packages, respectively.

**Note**: Windows users need [Rtools](http://cran.r-project.org/bin/windows/Rtools/) to install from github (or from source code) as shown above. Get the most recent version of [R for Windows](http://cran.r-project.org/bin/windows/base/) and download and install the version of Rtools that corresponds to it. You will also need the `RCurl` package, which requires an external program called `cURL`, which might require tenacity to get working on Windows. Do so cheaply using:
```r
source("http://bioconductor.org/biocLite.R")
biocLite("RCurl")
```
or similar. You *may* still need to install `cURL` first by by downloading the binary from [here](http://curl.haxx.se/download.html). You'll also need the `XML` R package, which you can install locally by downloading from here: [http://cran.r-project.org/bin/windows/contrib/](http://cran.r-project.org/bin/windows/contrib/) (pick your R version and then search down the list). Then install after modifying:
```r
install.packages("path/to/XML_version_x.zip", repos = NULL, type = "source")
```
If you needed to figure out more details to get this to work, please report back so these instructions can be updated, as no test machine is available at the time of this writing.

**Note**: Mac users might be required to install the appropriate version of [XTools](https://developer.apple.com/xcode/) from the [Apple Developer site](https://developer.apple.com/) in order to install the development version of `devtools`.  You may need to [register as an Apple developer](https://developer.apple.com/programs/register/).  An older version of XTools may also be required. Also, you'll need to install the `RCurl` package, which requires  `libcurl` external. You'll also need `XML`, which you might be able to install using:
```r
install.packages("XML", repos = "http://www.omegahat.org/R", type = "source")
```
If that doesn't work, then figure it out and please report back, so these instructions can be updated. No test machine is available at the time of this writing.

To report a bug
===============
Just go to the [main repository page](https://github.com/timriffe/TR1) and click on the ```Issues``` 
button on the right side. That's a convenient way to track bugs. Otherwise, just email the maintainer. Feature 
requests can also be made to the maintainer. Motivated individuals are also free to offer assistance by collaborating via the ```git``` version control system and github. 

As mentioned here and there above, if you learn of a better way to install dependencies for a particular OS, I'd appreciate the feedback. Unfortunately, the tricky external dependencies are necessary in order for downloading data that require registration (HMD, HFD). It seems the XML dependency could be eliminated if the HFD would publish a nice metadata csv like the HMD does...
