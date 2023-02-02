

# HMDHFDplus
Read Human Mortality Database and Human Fertility Database Data from the Web as described in MPIDR technical report: [https://dx.doi.org/10.4054/MPIDR-TR-2015-004](https://dx.doi.org/10.4054/MPIDR-TR-2015-004)

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" property="dct:title">"Reading Human Fertility Database and Human Mortality Database data into R"</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="https://sites.google.com/site/timriffepersonal/" property="cc:attributionName" rel="cc:attributionURL">Timothy L. M. Riffe</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.

[![Build Status](https://travis-ci.org/timriffe/TR1.svg?branch=master)](https://travis-ci.org/timriffe/TR1)
[![CRAN status](https://www.r-pkg.org/badges/version/HMDHFDplus)](https://cran.r-project.org/package=HMDHFDplus)
[![issues](https://img.shields.io/github/issues-raw/timriffe/TR1.svg)](https://github.com/timriffe/TR1/issues)
[![license](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://github.com/timriffe/TR1/tree/master/TR1/HMDHFDplus/LICENSE)

The `HMDHFDplus` package only contains functions for reading data into R. Currently there are functions for reading in HMD, JMD, CHMD, HFD, and HFC code, and there are plans to implement HLD code as well.

Installation
============

The package is on CRAN: https://cran.r-project.org/web/packages/HMDHFDplus/

This means you can install it using:
```r
install.packages("HMDHFDplus")
```
The version hosted in this repository is often more up-to-date; it pushes to CRAN whenever major features or fixes come up.

```r
# install.packages("remotes", dependencies = TRUE)
library(remotes)
install_github("timriffe/TR1/TR1/HMDHFDplus")
```

To report a bug
===============
Just go to the [main repository page](https://github.com/timriffe/TR1) and click on the ```Issues``` 
button on the right side. Otherwise, just email me.

* I know about the current HMD issue and ask for patience until I figure out how to deal with Cookies and so on. There is currently a patch in place that relies on a mirror to the old HMD website (which nonetheless has up to date data), and which requires the old website credentials to use.

