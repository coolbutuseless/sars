
<!-- README.md is generated from README.Rmd. Please edit that file -->

# sars <img src="man/figures/logo2.png" align="right" height="230/"/>

<!-- badges: start -->

![](https://img.shields.io/badge/cool-useless-green.svg)
<!-- badges: end -->

`sars` is an totally useless, very experimental, proof-of-concept,
oh-my-god-why package for executing [sas](sas.com) `DATA` and `PROC SQL`
statements in R.

## What’s in the box

-   `sars::run(code)` to run some code
    -   as long as it is only DATA and PROC SQL statements
    -   and even then, not much of either of those statements is really
        supported either

## Installation

You can install from [GitHub](https://github.com/coolbutuseless/sars)
with:

``` r
# install.package('remotes')
remotes::install_github('coolbutuseless/sars')
```

## Example

``` r
library(sars)

sars::run("
  data mytable;
    set 'mtcars';
  run;
  
  
  proc sql;
    SELECT cyl, sum(mpg) as total  FROM mytable
    WHERE am = 1
    GROUP BY cyl
    ORDER BY cyl;
  quit;"
)
```

    #>   cyl total
    #> 1   4 224.6
    #> 2   6  61.7
    #> 3   8  30.8

## Related Software

-   [sas](sas.com)

## Acknowledgements

-   R Core for developing and maintaining the language.
-   CRAN maintainers, for patiently shepherding packages onto CRAN and
    maintaining the repository
