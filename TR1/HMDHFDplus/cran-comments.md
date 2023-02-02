This is a minor package update to change adapt code for the new Human Mortality Database website, which has a different authentication method. This only affects HMD-related functions; minor fixes also to some HFD-related functions. I did a reverse dependency check and found a problem in how HMDHFDplus is used in the VirtualPop package. I have made a pull-request to the VirtualPop maintainer that addresses the issue and makes the package pass checks.

## Test environments
Ubuntu 20.04.3 LTS
  * R version 4.2.2 (2022-11-10 r83330)
  
* rhub:
  * Windows Server 2022, R-release, 32/64 bit
  * macOS 10.13.6 High Sierra, R-release, brew
  * Debian Linux, R-release, GCC

* win-builder
  * R Under development (unstable) (2023-02-01 r83747 ucrt)
  * R version 4.2.2 (2022-10-31 ucrt)
  * R version 4.1.3 (2022-03-10)

## R CMD check results
All of the above returned:
0 errors | 0 warnings | 0 notes 

Except occasional NOTEs to give reminders of who the maintainer is
