# Changes in this update

# HMDHFDplus 1.9.19
5 November 2022

* `getHFDdate()` adapted to the new HFD website
* `getHFDcountries()` adapted. Now rather than a vector of codes we return a tibble with more information per source.
* `getHFDitemavail()` adapted. Now rather than a vector of items, we return an informative table of all available files for the given country with lots of metadata that might help a user figure out what file is needed.
* `extract_HFD_items()` removed.
* `readHFDweb()` refactored to authenticate and grab from the new HFD website

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




