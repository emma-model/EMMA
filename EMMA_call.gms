
* This script calls EMMA for all minimum market value scenarios


$include EMMA_scenarios.gms


* General parameters

$set PROJECT             DEFAULT
$set HORIZON             LTE
$set REGIONS             cR
$set HOURS               8760
$set WEATHERYEAR         2010
$set co2                 100
$set ASC                 0
$set GASPRICE            flat
$set YDIM                VREshare



* =====================
* Bench
* =====================


$set SDIM         bench


* no H2

$set PURPOSE      noH2
$set H2           0

execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"
*for manual start: --PROJECT=DEFAULT --HORIZON=LTE --REGIONS=cR --HOURS=8760 --WEATHERYEAR=2010 --CO2=100 --ASC=0 --GASPRICE=flat --PURPOSE=noH2 --H2=0 --YDIM=VREshare --SDIM=bench


* H2 flex

$set PURPOSE      H2flex
$set H2           1

execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"


* H2 storage

$set PURPOSE      H2storage
$set H2           2

execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"


* H2 inflex

$set PURPOSE      H2inflex
$set H2           3

$set YDIM         VREshare
execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"



* =====================
* CO2 price sensitivity
* =====================


$set SDIM         CO2


* Without H2

$set PURPOSE      noH2
$set H2           0

execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"

* With H2

$set PURPOSE      H2flex
$set H2           1

execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"



* =====================
* Storage cost sensitivity
* =====================


$set SDIM         costStorage


* Without H2

$set PURPOSE      noH2
$set H2           0

execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"


* With H2

$set PURPOSE      H2flex
$set H2           1

execute "gams  EMMA.gms  --PROJECT=%PROJECT% --HORIZON=%HORIZON% --REGIONS=%REGIONS% --HOURS=%HOURS% --WEATHERYEAR=%WEATHERYEAR% --CO2=%CO2% --ASC=%ASC% --GASPRICE=%GASPRICE% --PURPOSE=%PURPOSE% --H2=%H2% --YDIM=%YDIM% --SDIM=%SDIM%"
