
<!-- README.md is generated from README.Rmd. Please edit that file -->

# telemetar

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/telemetar)](https://CRAN.R-project.org/package=telemetar)
<!-- badges: end -->

This package aims to provide
[`targets`](https://docs.ropensci.org/targets/) archetypes for analysis
of fish acoustic telemetry data *a la* the
[`tarchetypes`](https://docs.ropensci.org/tarchetypes/) package. The
eventual hope is to play nicely with, or even become a part of, the [R
Targetopia](https://wlandau.github.io/targetopia/); if you’d like to
contribute please follow the [Targetopia development
guidelines](https://wlandau.github.io/targetopia/contributing.html).

Like the package, the name is a work in progress: [vote for your
favorite or suggest another name
here](https://github.com/mhpob/telemetar/discussions/2)! Some
candidates:

- `telemetar` (current)
- `sharketypes`
- ~~`egrets`~~ (taken)
- `trackytypes`
- `trackets`

## Installing

If you’d like to give what has been put together a whirl, install the
current version of this package from GitHub.

``` r
remotes::install_github("mhpob/telemetar")
```

## Reading and combining VUE CSVs

`tar_vue_csvs` takes a directory of VUE-exported CSVs, tracks them for
changes, and imports the relevant data. This assumes that your data is
housed in a series of sub-directories. Something like:

    project_detections/
      |
      |-- January tending/
          |-- receiver1_jan.csv
          |-- receiver2_jan.csv
      |-- March tending/
          |-- receiver1_march.csv
          |-- receiver2_march.csv

``` r
targets::tar_script({
  library(telemetar)
  
  tar_vue_csvs('c:/users/darpa2/analysis/chesapeake-backbone/embargo/raw')
})

targets::tar_make()
#> ▶ dispatched target tracked_files
#> ● completed target tracked_files [0 seconds]
#> ▶ dispatched branch tracked_fa2b2caf
#> ● completed branch tracked_fa2b2caf [0 seconds]
#> ● completed pattern tracked
#> ▶ dispatched branch data_986aead1
#> ● completed branch data_986aead1 [0.016 seconds]
#> ● completed pattern data
#> ▶ completed pipeline [0.453 seconds]
```

``` r
targets::tar_objects()
#> [1] "data_986aead1" "tracked_files"

head(targets::tar_read(data))
#>               datetime     receiver    transmitter transmittername
#>                 <POSc>       <char>         <char>          <lgcl>
#> 1: 2022-05-04 15:28:58 VR2AR-546323 A69-1601-60787              NA
#> 2: 2022-05-04 15:39:32 VR2AR-546323 A69-1601-60787              NA
#> 3: 2022-05-04 15:49:37 VR2AR-546323 A69-1601-60787              NA
#> 4: 2022-05-04 16:09:11 VR2AR-546323 A69-1601-60787              NA
#> 5: 2022-05-04 16:18:23 VR2AR-546323 A69-1601-60787              NA
#> 6: 2022-05-04 16:27:44 VR2AR-546323 A69-1601-60787              NA
#>    transmitterserial sensorvalue sensorunit stationname latitude longitude
#>               <lgcl>      <lgcl>     <lgcl>      <lgcl>   <lgcl>    <lgcl>
#> 1:                NA          NA         NA          NA       NA        NA
#> 2:                NA          NA         NA          NA       NA        NA
#> 3:                NA          NA         NA          NA       NA        NA
#> 4:                NA          NA         NA          NA       NA        NA
#> 5:                NA          NA         NA          NA       NA        NA
#> 6:                NA          NA         NA          NA       NA        NA
#>    transmittertype sensorprecision
#>             <lgcl>          <lgcl>
#> 1:              NA              NA
#> 2:              NA              NA
#> 3:              NA              NA
#> 4:              NA              NA
#> 5:              NA              NA
#> 6:              NA              NA
```

Now, the importing step and any further analyses that depend on our
detection data will only be run if a file in that directory (or
sub-directories) is added or removed.

``` r
targets::tar_make()
#> ✔ skipped target tracked_files
#> ✔ skipped branch tracked_fa2b2caf
#> ✔ skipped pattern tracked
#> ✔ skipped branch data_986aead1
#> ✔ skipped pattern data
#> ✔ skipped pipeline [0.282 seconds]
```
