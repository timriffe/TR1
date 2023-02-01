# Changes in this update

# HMDHFDplus 2.0.0
1 Feb 2023

* `getHMDcountries()` adapted to the new HMD website
* `getJMDprefectures()` refactored, now returns `tibble` object instead of named vector
* `readHMDweb()` refactored ro work with new HMD website and new HMD credentials, HT Markus Sauerberg for Python example
* `getHMDitemavail()` adapted to the new website and now returns an informative table
* `getHMDcountries()` adapted to new HMD website


# HMDHFDplus 1.9.19
5 November 2022

* `getHFDdate()` adapted to the new HFD website
* `getHFDcountries()` adapted. Now rather than a vector of codes we return a tibble with more information per source.
* `getHFDitemavail()` adapted. Now rather than a vector of items, we return an informative table of all available files for the given country with lots of metadata that might help a user figure out what file is needed.
* `extract_HFD_items()` removed.
* `readHFDweb()` refactored to authenticate and grab from the new HFD website. The old HMD mirror site will no longer be accessed as of this update, so users may need to re-register at the HMD.
* `getHFDitemavail()` now returns an informative table
* 

# HMDHFDplus 1.9.18
16 June 2022

* `readHMDweb()` and related functions now temporarily point 
   to a new url to grab data: `https://former.mortality.org`. This
   is a patch until a new API will be released.

# HMDHFDplus 1.9.16
22 December 2021

* `readJMDweb()` adapted to changing website specifications
* `readHFCcountries()` fixed
* `readHFDweb()` adapted to changing website specifications
* `getJMDprefectures()` fixed

# HMDHFDplus 1.9.14
7 April 2021

* `HMDparse()` handles territorial adjustments properly now. HT Jim Oeppen

# HMDHFDplus 1.9.13
20 Feb 2020.

*  `readHFDweb()` documentation Warning fixed.
*  incomplete url NOTE fixed

# HMDHFDplus 1.9.1
9 Aug 2018.  

*  `readHFDweb()` fixed, now relies on `hhtr` HT @jasonhilton
*  `readHMDweb()` fixed, now relies on `httr`




