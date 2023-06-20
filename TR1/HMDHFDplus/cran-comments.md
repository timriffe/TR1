This is a minor package update to open and close connections more neatly and eliminating artifacts that were messing up Rmd builds. Also some little fixes to capture subpopulations that were missed in the previous update. I've informed the maintainers of two reverse dependencies to import this forthcoming version.

## Test environments
Ubuntu 20.04.6 LTS
  * R version 4.3.0 (2023-04-21)
  
* rhub:
  * Windows Server 2022, R-release, 32/64 bit
  * Debian Linux, R-release, GCC

* macbuilder:
  * r-release-macosx-arm64|4.3.0|macosx|macOS 13.3.1

* win-builder
  * R version 4.2.3 (2023-03-15 ucrt)
  * R Under development (unstable) (2023-06-19 r84573 ucrt)
  * R version 4.3.1 (2023-06-16 ucrt)

## R CMD check results
All of the above returned:
0 errors | 0 warnings | 0 notes 
