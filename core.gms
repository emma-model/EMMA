*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~1     SETTINGS and COMMAND LINE PARAMETER DEFAULTS
*

*---------------------------------------------------------------------------------------------------------------------------

* Setting
* $onMultiR
$eolcom //
* $setenv GdxCompress 1

* $offlisting
* Turn off the listing of the input file - reduces listing file size, but makes debugging much harder

$Onempty
$phantom emptyset
* allows using "emptyset" as an entry of a set that is ignored - Is this different to $Onempty?

* Create folders
$if not dexist scen     $call "mkdir scen"
$if not dexist start    $call "mkdir start"
$if not dexist trash    $call "mkdir trash"
$if      exist log.dat  $call "del log.dat"

*** Command line parameters defaults (steered by EMMA_call)

* CLP for general
$if not set LOADDATA             $set LOADDATA           0
$if not set DUMPDATA             $set DUMPDATA           0

* CLP for input selection
$if not set PROJECT              $set PROJECT            DEFAULT
$if not set HOURS                $set HOURS              100
$if not set REGIONS              $set REGIONS            1R
$if not set HORIZON              $set HORIZON            2016
$if not set WeatherYEAR          $set WeatherYEAR        2016

* CLP for input manipulation
* Input scenarios
$if not set SI                   $set SI                 none
* Constraint scenarios
$if not set SC                   $set SC                 none
* Export: ts or const
$if not set EXPORT               $set EXPORT             ts
* Avail: ts or seasonal
$if not set AVAIL                $set AVAIL              ts

* CLP for model features
$if not set SHORTTERM            $set SHORTTERM          0
$if not set FUTUREVRE            $set FUTUREVRE          0
$if not set SCALEVRE             $set SCALEVRE           0
$if not set CHP                  $set CHP                1
$if not set ASC                  $set ASC                0
$if not set RAMPING              $set RAMPING            1
$if not set RUNTHROUGH           $set RUNTHROUGH         0
$if not set RETARGET             $set RETARGET           0
$if not set CARBONCAP            $set CARBONCAP          0
$if not set CCS                  $set CCS                0
$if not set H2B                  $set H2B                1  // Lower fuel revenues for PtHydrogen if H2 balance is bypassed i.e. set to 0

* CLP for solver options
$if not set THREADS              $set THREADS            -1

* CLP for regional scope
$IFi %REGIONS%=='12R'            $set r                  GER,SWE,FRA,POL,NLD,BEL,NOR,AUT,CHE,CZE,DNK,GBR
$IFi %REGIONS%== '3R'            $set r                  GER,SWE,FRA
$IFi %REGIONS%== '2R'            $set r                  GER,SWE
$IFi %REGIONS%== '1R'            $set r                  GER

*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~2    SCENARIOS
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

$include scenarios.gms

*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~3     SETS
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

SET
allt                     all possible hours      /1*8760/
allr                     all possible regions    /GER,SWE,FRA,NLD,IRL,GBR,PRT,ESP,BEL,LUX,DNK,DKW,DKE,NOR,FIN,CHE,ITA,AUT,SVN,POL,CZE,SVK,HUN,GRC,ROU,HRV,BIH,SRB,MNE,MKD,BGR,CHN,SE1*SE4,NO1*NO5,all/
alltec                   all possible techs      /nucl,lign,coal,CCGT,lign_CCS,coal_CCS,CCGT_CCS,OCGT,CCGT_H2,OCGT_H2,shed,wion,wiof,solar,PHS,batr,hydr,ror,bio,PtHydrogen/
allvin                   all vintages incl. new  /1,2,3,new/
allyear                  all weather years       /1990*2030/
allh                     all horizons            /1990,2008*2019,2030,2040,2050,LTE/
allpro                   all project             /DEFAULT,DEFAULTLTE/

h_years(allh)            horizon years (non-LTE) /2016,2030,2040,2050/
today(allh)              today’s year            /2016/

t(allt)                  hour of the year        /1*%HOURS%/
ti(t)                    short for reporting     /1*100/

rall(allr)               regions included + all  /%r%,all/
r(rall)                  regions included        /%r%/
r_h(allr)                regions with hydro      /AUT,CHE,CZE,FRA,GBR,GER,GRC,NOR,NO1*NO5,SWE,SE1*SE4/
r_p(allr)                regions with PHS        /AUT,BEL,CHE,CZE,FRA,GER,POL,GRC/
r_t(allr)                regions thermal only    //
r_l(allr)                regions with lignite    /GER,POL,CZE, GRC/
r_c(allr)                regions with new coal   /POL,CZE/
r_o(allr)                regions with offshore   /BEL,DNK,FRA,GBR,GER,NLD,NOR,POL,SWE/
r_not(allr)              regions not included    //
r_FRA(allr)              for 1R model runs       /FRA/
r_SWE(allr)              for 1R model runs       /SWE/
r_POL(allr)              for 1R model runs       /POL/

* RS: Consider to construct sets using: https://support.gams.com/gams:union_two_different_sets
*     to ensure not only sub-set relations but dynamic assignment and set disjointment (where applicable)
*tec_mod(alltec)          techs with endog. disp.            /nucl,lign,coal,CCGT,OCGT,lign_CCS,coal_CCS,CCGT_CCS,CCGT_H2,OCGT_H2,shed,wion,wiof,solar,PHS,batr,hydr,PtHydrogen/

tec_supply(alltec)       generators and storage discharging /nucl,lign,coal,CCGT,OCGT,lign_CCS,coal_CCS,CCGT_CCS,CCGT_H2,OCGT_H2,shed,wion,wiof,solar,PHS,batr,hydr,ror,bio/
tec_demand(alltec)       consumers and storage charging     /PtHydrogen,PHS,batr/
tec_sto(alltec)          storage technologies               /PHS,batr/
tec_inv(alltec)          techs with endog. investment       /nucl,lign,coal,CCGT,OCGT,lign_CCS,coal_CCS,CCGT_CCS,CCGT_H2,OCGT_H2,shed,wion,wiof,solar,PHS,batr,PtHydrogen/
tec_flex(alltec)         very flexible techs                /OCGT,OCGT_H2,PHS,batr/
tec_h2(alltec)           all H2 techs                       /CCGT_H2,OCGT_H2,PtHydrogen/

tec_gen(tec_supply)      generation techs                   /nucl,lign,coal,CCGT,OCGT,lign_CCS,coal_CCS,CCGT_CCS,CCGT_H2,OCGT_H2,shed,wion,wiof,solar,hydr,ror,bio/
tec_thm(tec_gen)         thermal techs                      /nucl,lign,coal,CCGT,OCGT,lign_CCS,coal_CCS,CCGT_CCS,CCGT_H2,OCGT_H2,shed/
tec_vre(tec_gen)         VRE techs                          /wion,wiof,solar/
tec_exo(tec_gen)         fully exog. techs                  /ror,bio/
tec_chp(tec_thm)         CHP techs                          /lign,coal,CCGT,lign_CCS,coal_CCS,CCGT_CCS,CCGT_H2,OCGT_H2,OCGT,shed/              // "shed" is included to make SHORT runs feasible
tec_h2g(tec_thm)         plants running on H2               /CCGT_H2,OCGT_H2/

tec_con(tec_demand)      consumption technologies           /PtHydrogen/     //here we should add electic boliers (i.e. PtHeat)
tec_h2d(tec_con)         consumption technologies /PtHydrogen/

par_sto                  storage parameters      /power,energy/
par_cost                 cost parameters         /invest,invest_chp,energy,lifetime,qfixcost,varcost,balancing,co2int,eff_new,rp_depriciation,rp_fuel,rp_constraint,rt_premium,flex_premium, availability/
par_cost_misc            cost scalar parameters  /discountrate,curtailment/

vin(allvin)              vintages without new    /1,2,3/
new(allvin)              ohly new vintage        /new/

peak                     peak and off-peak       /p,op/
day_year                 day of year             /1*365/
week_year                week of year            /1*53/
month_year               month of year           /1*12/
hour_day                 hour of day             /1*24/
hour_week                hour of week            /1*168/
day_week                 day of week             /1*7/
season                   season                  /winter,spring,summer,fall/

t_peak                   mapping
t_day_year               mapping
t_week_year              mapping
t_month_year             mapping
t_hour_day               mapping
t_hour_week              mapping
t_day_week               mapping
t_season                 mapping

time(allt,peak,day_year,week_year,month_year,hour_day,hour_week,day_week,season)  super-set for time sets


SINGLETON SET
weather_year(allyear)    weather year from clp          /%WeatherYEAR%/
h_year(allh)             year of the horizon from clp   /%HORIZON%/
;


* Specify the subsets of regions according to specific technology availability

r_not(allr)     = yes;
r_not(r)        = no;

r_h(r_not)      = no;
r_p(r_not)      = no;
r_l(r_not)      = no;

r_FRA(r_not)    = no;
r_SWE(r_not)    = no;
r_POL(r_not)    = no;

r_t(r)          = yes;
r_t(r_h)        = no;
r_t(r_p)        = no;

*tec_demand(tec_con) = yes;
*tec_demand(tec_sto) = yes;
*tec_supply(tec_gen) = yes;
*tec_supply(tec_sto) = yes;


ALIAS (allr,from_allr)
ALIAS (allr,to_allr)

ALIAS (r,rr)
ALIAS (t,tt)

ALIAS (r,from_r)
ALIAS (r,to_r)


*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~4     PARAMETER DEFINITIONS
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

PARAMETER
* Input parameters read in from excel (i_)
i_cost(alltec,*,par_cost)
i_cost_misc(par_cost_misc)
i_yload(allr,*,allh)
i_fuel(alltec,allpro,allh)
i_CO2(*,allpro,allh)
i_CO2cap(allr,allpro,allh)
i_monthly(month_year,*)
i_FLH(allr,*)
i_REshare(*,allr)
i_km(allr,allr)
i_ACDC(allr,allr)

i_capa0(alltec,vin,allh,allr)
i_energy0(*,vin,allh,allr)
i_invemin(tec_inv,allh,allr)
i_invemax(tec_inv,allh,allr)
i_chp0(tec_chp,vin,allh,allr)
i_chp_tot(allh,allr)
i_gene0(*,allpro,allh,allr)
i_eff0(alltec,vin)
i_ntc0(allr,allh,allr)
i_exp0(allr,allh,allr)

i_chp(allt,allr,allyear)
i_load(allt,allpro,allr,allyear)
i_export(allt,allr,allyear)
i_avail(allt,allr,allyear,alltec)
i_solar(allt,allpro,allr,allyear)
i_solar_future(allt,allpro,allr,allyear)
i_wion(allt,allpro,allr,allyear)
i_wion_future(allt,allpro,allr,allyear)
i_wiof(allt,allpro,allr,allyear)
i_wiof_future(allt,allpro,allr,allyear)

* Model Parameters (no prefix)
load(t,r)                       hourly load                                     (GW)                    [loaded as MW]
load_mod(t,r)                   load - exogenous gen (bio and ror) + exports    (GW)
h2_demand_exo(r)                non-electricity exognous hydrogen demand        (GWh)

profile(t,*,allr)               profiles for vre & exo & hydro & CHP - not load (GW per GW installed | sum up to FLH)
CHP_profile(t,tec_chp,*,r)      min and max profiles for CHP                    (1)
export(t,r)                     export to non-modeled regions                   (GW)

discountrate                    discount rate                                   (1)
co2(r)                          CO2-price                                       (EUR per t)
co2_cap(r)                      CO2-quantity                                    (t)
cost_chp(tec_inv)               suppl. annulized fixed costs for CHP            (MEUR per GW*a)
cost_qfix(alltec)               annulized quasi-fixed costs                     (MEUR per GW*a)
cost_inv(tec_inv)               annualized investment cost                      (MEUR per GW*a)
cost_var(t,alltec,allvin,r)     variable cost                                   (MEUR per GWh)            [loaded as EUR per MWh]
cost_ramping(tec_thm,r)         cost for upward ramping                         (MEUR per GWh)            [loaded as EUR per MWh]
cost_fuel(alltec)               fuel cost                                       (EUR per MWht)
cost_energy(tec_sto)            investment cost in storage volume               (MEUR per GWh*a)
cost_ntc                        transmission cost                               (MEUR per GW_NTC*km*a)
cost_bal(tec_vre)               balancing cost                                  (MEUR per GWh)            [loaded as EUR per MWh]
cost_curtail                    curtailment cost (negative bids)                (MEUR per GWh)            [loaded as EUR per MWh]
fuel_ramping(tec_thm,r)         fuel consumed by ramping up a plant             (MWh_th per MW_el)

run_through(alltec)             run through premium                             (MEUR per GWa)

co2_int(tec_thm,r)              carbon intensitiy                               (t per GWh thermal)
cost_ramping(tec_thm,r)  

rp_depriciation(tec_thm)        depriciation cost because of ramping            (EUR per MW)
rp_fuel(tec_thm)                fuel consumption because of ramping             (MW_th per MW_el)
rp_constraint(tec_thm,r)        allowed ramping rate                            (1)

REshare(r)                      Renewable energy objective                      (% of electricity consumption)

capa0(alltec,vin,r)             existing net installed total capacity           (GW)
eff0(tec_thm,vin)               efficiency of existing thermal capacity         (1)
sto0(tec_sto,allvin,r)          existing storage capacity                       (GW and GWh)
ntc0(r,rr)                      existing trans capacity from r to rr            (GW) [rescaled]
chp0(tec_CHP,allvin,r)          existing CHP generation capacity                (GW)
chp_tot(r)                      sum of required CHP generation capacity         (GW)

eff(alltec)                     conversion efficiency                           (1)
efficiency(alltec, allvin)      summarises eff0 and eff                         (1)
lifetime(alltec)                life-time                                       (a)
invemin(tec_inv,r)              political capacity requirement by technology    (GW)
invemax(tec_inv,r)              political capacity maximum by technology        (GW)
avail(t,alltec,r)               availability of generation                      (1)
km(r,rr)                        distance between regions                        (km)
ACDC(r,rr)                      HVAC or HVDC dummy                              (dummy)
as(r)                           must-run                                        (GW)
as_vre                          must-run as share of VRE capacity               (1)
as_chp                          chp providing AS (0) or not (1)                 (binary)
fuelseason(t,alltec)            multiplicator for fuel price seasonality        (1)
inflow(t,allr)                  hydro reservoir inflow                          (share of installed capacity)
reservoir(allr)                 hydro reservoir size                            (factor of installed capacity)
hydro_min(allr)                 min hydro generation                            (share of installed capacity - could also be made time-dependent)

* Units
* MEUR / GW*a      = EUR / KW*a
* EUR / MWh        = MEUR / TWh
* EUR / KWh        = MEUR / GWh
* EUR / KW         = MEUR / GW

* Scalars, scale, test
th                       /1000/
mn                       /1000000/
little                   /0.0000001/
sc                       scale parameter for t<8760
tmp_r(allr)             
tmp_x_r(*,r)
;

* Scaling parameter
sc                       = 8760 / card(t);


*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~7 PARAMETER VALUES
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

*===============================================================
* a) Read in from GDX (i_*)
*===============================================================

* Convert Excel into GDX 
$IF %LOADDATA% == '1'            $include loaddata.gms

* Non-time series data from data.xlsx
$GDXIN data.gdx
$LOADdc i_cost, i_cost_misc, i_yload, i_fuel, i_CO2, i_CO2cap, i_monthly, i_FLH, i_km, i_ACDC, i_REshare

* Existing capacities from data0.xlsx
$GDXIN data0.gdx
$LOADdc i_capa0, i_energy0, i_invemin, i_invemax, i_chp0, i_chp_tot, i_gene0, i_eff0, i_ntc0, i_exp0

* Time series data from data_ts.xlsx
$GDXIN data_ts.gdx
$LOADdc time, i_chp, i_load, i_export, i_avail, i_solar, i_solar_future, i_wion, i_wion_future, i_wiof, i_wiof_future


*===============================================================
* b) Override inputs according to input scenarios %SI%
*===============================================================

$include scen\si_%SI%.gms

*===============================================================
* c) Fill in model parameter values
*===============================================================

*** TIME MATTERS

* Mapping of set t to different time sets
loop(time(t,peak,day_year,week_year,month_year,hour_day,hour_week,day_week,season),
    t_peak(t,peak)                   = yes;
    t_day_year(t,day_year)           = yes;
    t_week_year(t,week_year)         = yes;
    t_month_year(t,month_year)       = yes;
    t_hour_day(t,hour_day)           = yes;
    t_hour_week(t,hour_week)         = yes;
    t_day_week(t,day_week)           = yes;
    t_season(t,season)               = yes;
);


*** TIME SERIES

* Select weather year
load(t,r)            = i_load(t,"%PROJECT%",r, weather_year) / th;

$IFi %EXPORT%=='const' export(t,r)          = 1;
$IFi %EXPORT%=='ts'    export(t,r)          = i_export(t,r, weather_year) / th;

$IFi %FUTUREVRE%=='0'  profile(t,"solar",r) = i_solar(t,"%PROJECT%",r,weather_year);
$IFi %FUTUREVRE%=='0'  profile(t,"wion",r)  = i_wion(t,"%PROJECT%",r,weather_year);
$IFi %FUTUREVRE%=='0'  profile(t,"wiof",r)  = i_wiof(t,"%PROJECT%",r,weather_year);

$IFi %FUTUREVRE%=='1'  profile(t,"solar",r) = i_solar_future(t,"%PROJECT%",r,weather_year);
$IFi %FUTUREVRE%=='1'  profile(t,"wion",r)  = i_wion_future(t,"%PROJECT%",r,weather_year);
$IFi %FUTUREVRE%=='1'  profile(t,"wiof",r)  = i_wiof_future(t,"%PROJECT%",r,weather_year);

* Scale load profile to yearly values (from IEA)
tmp_r(r)        = sum(t, load(t,r));
load(t,r)       = load(t,r) / tmp_r(r) * i_yload(r,"Electricity","%HORIZON%") * th / sc;

* Load exogenous hydrogen demand
h2_demand_exo(r) = i_yload(r,"Hydrogen","%HORIZON%") * th / sc;

* Scale export profile to yearly values (from Eurostat)
tmp_r(r)        = sum(t, export(t,r));
export(t,r)$tmp_r(r)     = export(t,r) / tmp_r(r) * (sum(r_not,i_exp0(r,"%HORIZON%",r_not)) - sum(r_not,i_exp0(r_not,"%HORIZON%",r))) * th / sc;

* Scale renewable profiles to FLH (historical or assumption on new)
tmp_x_r(tec_vre,r)$sum(vin, i_capa0(tec_vre,vin,"%WeatherYEAR%",r)) = sum(t,profile(t,tec_vre,r)) * sc;
$IFi %FUTUREVRE%=='0' profile(t,tec_vre,r)$tmp_x_r(tec_vre,r) = profile(t,tec_vre,r) / tmp_x_r(tec_vre, r) * i_gene0(tec_vre,"%PROJECT%","%WeatherYEAR%",r) * th / sum(vin, i_capa0(tec_vre,vin,"%WeatherYEAR%",r));
tmp_x_r(tec_vre,r) = sum(t,profile(t,tec_vre,r)) * sc;
$IFi %SCALEVRE%=='1' profile(t,tec_vre,r)$tmp_x_r(tec_vre,r) = profile(t,tec_vre,r) / tmp_x_r(tec_vre, r) * i_FLH(r,tec_vre);

* Generation profiles of exogenous technologies
profile(t,tec_exo,r) = sum(t_month_year(t,month_year),i_monthly(month_year,tec_exo)) * i_gene0(tec_exo,"%PROJECT%","%WeatherYEAR%",r);  // i_gene0 is used to exclude countries that do not have historic generation
display profile;
tmp_x_r(tec_exo,r)   = sum(t,profile(t,tec_exo,r)) * sc;
profile(t,tec_exo,r)$tmp_x_r(tec_exo,r) = profile(t,tec_exo,r) / tmp_x_r(tec_exo, r) * i_gene0(tec_exo,"%PROJECT%","%WeatherYEAR%",r) * th / sum(vin, i_capa0(tec_exo,vin,"%WeatherYEAR%",r));

* Hydro reservoir inflow profile
* inflow pattern come from Swedish statistics (sum up to 1)
profile(t,"hydr",r_h) = sum(t_month_year(t,month_year),i_monthly(month_year,"inflow_SWE"));
display profile, t_month_year;
tmp_r(r_h)            = sum(t,profile(t,"hydr",r_h)) * sc;
profile(t,"hydr",r_h) = profile(t,"hydr",r_h) / tmp_r(r_h) * i_gene0("hydr","%PROJECT%","%WeatherYEAR%",r_h) * th / i_capa0("hydr","1","%WeatherYEAR%",r_h);

* CHP Profiles
profile(t,"CHP",r)    = i_chp(t,r,"%WeatherYEAR%");
tmp_r(r)              = sum(t,profile(t,"CHP",r));
profile(t,"CHP",r)    = profile(t,"CHP",r) / tmp_r(r) * (i_gene0("chp_res","%PROJECT%","%WeatherYEAR%",r)
                        + i_gene0("chp_com","%PROJECT%","%WeatherYEAR%",r))
                        + 1/8760 * i_gene0("chp_ind","%PROJECT%","%WeatherYEAR%",r);
                        
tmp_r(r)              = smax(t,profile(t,"CHP",r));
profile(t,"CHP",r)    = profile(t,"CHP",r) / tmp_r(r);



*** COST PARAMETERS

* Discount rate
discountrate = i_cost_misc("discountrate");
cost_curtail = i_cost_misc("curtailment") / th;

* Gas price seasonality
fuelseason(t,alltec)     = 1;
*fuelseason(t,"CCGT")     = sum(t_month_year(t,month_year),i_monthly(month_year,"gasprice"));
*fuelseason(t,"OCGT")     = sum(t_month_year(t,month_year),i_monthly(month_year,"gasprice"));

*test3(alltec)            = sum(t,fuelseason(t,alltec)) / card(t);
*fuelseason(t,alltec)     = fuelseason(t,alltec) / test3(alltec);

* Interconnector parameters
km(r,rr)                 = i_km(r,rr);
ACDC(r,rr)               = i_ACDC(r,rr);

* run through
run_through(tec_thm) = i_cost(tec_thm,"*","rt_premium");
$IF %RUNTHROUGH%=='0'
run_through(tec_thm) = 0;

* invest cost calculation
lifetime(tec_inv)         = i_cost(tec_inv,"*","lifetime");
cost_inv(tec_inv)         = i_cost(tec_inv,"%HORIZON%","invest") * ((1+discountrate)**lifetime(tec_inv)*discountrate)/((1+discountrate)**lifetime(tec_inv)-1) / sc ;    // annualized capital costs from investment costs
cost_chp(tec_inv)         = i_cost(tec_inv,"*","invest_chp") * ((1+discountrate)**lifetime(tec_inv)*discountrate)/((1+discountrate)**lifetime(tec_inv)-1) / sc ;        // annualized capital costs from investment costs

* qfixed cost incl. balancing cost
cost_qfix(alltec)         = (i_cost(alltec,"%HORIZON%","qfixcost") + run_through(alltec)*(8+2)) / sc;                                                                   // 8 to allocate run-through premium to FC, 2 for actual occured start-ups - but what if a plant runs less than 8000 hours!?!?!? - THIS IS A BUG
cost_bal(tec_vre)         = i_cost(tec_vre,"*","balancing")*sum((t,r),profile(t,tec_vre, r))/card(r)/th;                                                                // VRE balancing costs in EUR/MWh
cost_qfix(tec_vre)        = cost_qfix(tec_vre) + cost_bal(tec_vre);                                                                                                     // RES balancing costs are added to qfix costs -> taken as independent from generation 

* flexibility premium to fix and quasi-fix costs
cost_inv(tec_inv)       = cost_inv(tec_inv)  * i_cost(tec_inv,"*","flex_premium"); 
cost_qfix(tec_inv)      = cost_qfix(tec_inv) * i_cost(tec_inv,"*","flex_premium");                                                                     // qfix are scaled down as well (not only fix)

* var costs
eff(alltec)              = i_cost(alltec,"%HORIZON%","eff_new");
loop(h_year,
    cost_fuel(alltec)        = i_fuel(alltec,"%PROJECT%",h_year);
    co2(r)                   = i_co2("ETS","%PROJECT%",h_year);
    loop(r,
        co2(r)$i_co2(r,"%PROJECT%",h_year) = i_co2(r,"%PROJECT%",h_year);
    );
);

* If case we want the price to be fully endogenous
* $IF %CARBONCAP%=='1'
* co2(r) = 0;

* efficiency
efficiency(alltec, allvin)                      = eff(alltec);
efficiency(alltec,vin)$i_eff0(alltec,vin)       = i_eff0(alltec,vin);  //overwrites the efficiency for the old vintages


*** HYDROGEN BALANCE (must be after cost_fuel and before cost_var calculation)
PARAMETER
h2_import_price         // this this is the price at which H2 can be imported from other regions (without transportations)
h2_transportation_cost  // this is the price delta seen by the hydrogen consumption and the hydrogen supply in one region
;
$IFTHENE.hydrogen_balance %H2B%=='1'
    // Sanity check
    if (cost_fuel("CCGT_H2") <> cost_fuel("OCGT_H2") , abort "Why are CCGT_H2 and OCGT_H2 paying a different price for the hydrogen?");

    h2_transportation_cost = sum(tec_h2g, cost_fuel(tec_h2g))/card(tec_h2g) + sum(tec_h2d, cost_fuel(tec_h2d))/card(tec_h2d);
    h2_import_price = (sum(tec_h2g, cost_fuel(tec_h2g))/card(tec_h2g) - h2_transportation_cost) / th;
    
    cost_fuel(tec_h2g) = h2_transportation_cost; // This is the base price. The actual will include the margnial of the hydrogen balance
    cost_fuel(tec_h2d) = 0;     	             // This is the base price. The actual will include the margnial of the hydrogen balance 
$ELSE.hydrogen_balance
    h2_import_price = 0;
$ENDIF.hydrogen_balance


* variable cost
cost_var(t,alltec,allvin,r)                   = (i_cost(alltec,"%HORIZON%","varcost") + (cost_fuel(alltec) * fuelseason(t,alltec) + i_cost(alltec,"*","co2int")*co2(r)) / efficiency(alltec,allvin)  - run_through(alltec)) / th;


* emissions
co2_int(tec_thm,r)          = i_cost(tec_thm,"*","co2int") * th;

* ramping cost: cost for upward ramping (accounts for depriciation and supplementary fuel consumtion)
fuel_ramping(tec_thm,r)  = i_cost(tec_thm,"*","rp_fuel");
cost_ramping(tec_thm,r)  = i_cost(tec_thm,"*","rp_depriciation")
                         + fuel_ramping(tec_thm,r)*(cost_fuel(tec_thm) + i_cost(tec_thm,"*","co2int")*co2(r));

* storage costs
cost_energy(tec_sto)     = i_cost(tec_sto,"%HORIZON%","energy") * ((1+discountrate)**lifetime(tec_sto)*discountrate)/((1+discountrate)**lifetime(tec_sto)-1) / sc;
cost_energy(tec_sto)     = cost_energy(tec_sto) * i_cost(tec_sto,"*","flex_premium");


* NTC costs
cost_NTC                 = 3.4 * ((1+discountrate)**40*discountrate)/((1+discountrate)**40-1) / sc;


*** ENERGY BALANCE

* Add net exports to non-modeled countries
load_mod(t,r)   = load(t,r) + export(t,r);


*** CAPACITY CONSTRAINTS

* Existing capacity
capa0(alltec,vin,r)              = i_capa0(alltec,vin,"%HORIZON%",r);

* Conventional availability
avail(t,alltec,r)        = 1;
avail(t,tec_thm,r)       = 0.8;

$IFi %AVAIL%=='flat'        avail(t,tec_thm,r)               = 0.8;
$IFi %AVAIL%=='future'      avail(t,tec_thm,r)               = i_cost(tec_thm,"*","availability");
$IFi %AVAIL%=='seasonal'    avail(t,tec_thm,r)               = sum(t_month_year(t,month_year),i_monthly(month_year,"avail"));
$IFi %AVAIL%=='seasonalmod' avail(t,tec_thm,r)               = sum(t_month_year(t,month_year),i_monthly(month_year,"avail_mod"));
$IFi %AVAIL%=='hist'        avail(t,tec_thm,r)               = sum(t_month_year(t,month_year),i_monthly(month_year,"avail"));
$IFi %AVAIL%=='hist'        avail(t,"nucl",r)$(r_FRA(r))     = sum(t_month_year(t,month_year),i_monthly(month_year,"avail_FRA_nuc"));
$IFi %AVAIL%=='hist'        avail(t,tec_thm,r)$(r_POL(r))    = avail(t,tec_thm,"GER") * 0.85;
$IFi %AVAIL%=='ts'          avail(t,tec_thm,r)               = i_avail(t,r,"%WeatherYEAR%",tec_thm);
$IFi %AVAIL%=='ts'          avail(t,"shed",r)                = 1;


*** INFLEXIBILITY

* Combines heat and power (CHP)

* CHP existing capacity
chp0(tec_chp,vin,r)              = i_chp0(tec_chp,vin,"%HORIZON%",r);
chp_tot(r)                       = i_chp_tot("%HORIZON%",r);            // in short-term runs, chp_tot must be euqal to sum((tec_chp,allvin),chp0))
$IF %CHP%=='0'  chp_tot(r)       = 0;

* CHP restrictions:               Backpressure                 Condensing
CHP_profile(t,tec_chp,"max",r) =  0.1 * profile(t,"CHP",r)  +  0.9 * (1 - 0.15 * profile(t,"CHP",r));
CHP_profile(t,tec_chp,"min",r) =  0.1 * profile(t,"CHP",r)  +  0.9 * (    0.35 * profile(t,"CHP",r));
CHP_profile(t,"CCGT","max",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (1 - 0.15 * profile(t,"CHP",r));
CHP_profile(t,"CCGT","min",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (    0.75 * profile(t,"CHP",r));
*                                 Exhaust heat
CHP_profile(t,"OCGT","max",r)  =  1;
CHP_profile(t,"OCGT","min",r)  =  profile(t,"CHP",r);
*                                 Shed
CHP_profile(t,"shed","max",r)  =  1;
CHP_profile(t,"shed","min",r)  =  profile(t,"CHP",r);

$IF %CHP%=='0' CHP_profile(t,tec_chp,"max",r) = 1;
$IF %CHP%=='0' CHP_profile(t,tec_chp,"min",r) = 0;

* Ancillary services
as(r)                    = 0.1 * smax(t,load(t,r));
as_vre                   = 0.05;
as_chp                   = 1;
$IF %ASC%=='0'  as(r)    = 0;
$IF %ASC%=='0'  as_vre   = 0;

* ramping constraint
rp_constraint(tec_thm,r)   = i_cost(tec_thm,"*","rp_constraint");



*** FLEXIBILITY

* Storage
sto0("PHS",vin,r)              = i_energy0("PHS",vin,"%HORIZON%",r);

* Hydro reservoirs

* The parameters reservoir, hydro_min, inflow are all defined reltive to installed capacity.

* Reservoir size
reservoir(r_h)          =  i_energy0("reservoir","1","%HORIZON%",r_h);

* Convert monthly inflow pattern to absolute level of inflow per hour
inflow(t,r_h)           =  profile(t,"hydr",r_h) * i_capa0("hydr","1","%HORIZON%",r_h);

* Initial and terminal inflow values
inflow("1",r_h)         =  reservoir(r_h) / 2;
inflow("%HOURS%",r_h)   = -reservoir(r_h) / 2;

* To ensure feasibility for 100 hours
$IFi %HOURS% == '100' inflow("%HOURS%",r_h) = - 0.98 * inflow("1",r_h);

* Minimal generation
* Swedish least monthly generation (June 2004)
hydro_min(r_h)    = 0;

* To ensure feasibility for 100 hours
$IFi %HOURS% == '100' hydro_min(r_h)    = 0;

* NTC
ntc0(r,rr) = i_ntc0(r,"%HORIZON%",rr) / th;



*** POLITICAL CONSTRAINTS

* Committed investment and investment limitations
invemin(tec_inv,r)               = i_invemin(tec_inv,"%HORIZON%",r);
invemax(tec_inv,r)               = i_invemax(tec_inv,"%HORIZON%",r);

* RE share
REshare(r)          = i_REshare("%HORIZON%",r);

* Emission cap
co2_cap(r)          = i_CO2cap(r,"%PROJECT%", "%HORIZON%") * mn / sc;


*===============================================================
* c) Check input integrity
*===============================================================
$if not     set ID          $set ID    
File log    "log file for debugging and warning messages"         /log_WARNING_%ID%.dat/;


loop((tec_chp,vin,allh,allr),
    if (i_capa0(tec_chp,vin,allh,allr) <  i_chp0(tec_chp,vin,allh,allr),
            put log;        
            put "CHP capcacity larger than allowed" i_chp0(tec_chp,vin,allh,allr) '>' i_capa0(tec_chp,vin,allh,allr) /;
            put '- technology:' tec_chp.tl:0 /;
            put '- vintage:   ' vin.tl:0     /;
            put '- year:      ' allh.tl:0    /;
            put '- region:    ' allr.tl:0    /;
            abort "CHP capcacity larger than total capacity (check log.dat file)";
    ));

loop(tec_inv,
    if (lifetime(tec_inv) = 0,
            put log;
            put 'Lifetime of ' tec_inv.tl:0 'appears to be be 0' /;
            abort "Lifetime of a tec_inv technology cannot be 0 (check log.dat file)";
    ));
    

loop((r, tec_exo, vin),
    if ( (capa0(tec_exo, vin,r) > 0) and (sum(t, profile(t,tec_exo,r)) = 0),
            put log;
            put 'Capa0 but no profile for tec:' tec_exo.tl:0 ', vin:' vin.tl:0 ' and region:' r.tl:0 '; ' capa0(tec_exo, vin,r) ' GW affected'/;
            // capa0(tec_exo, allvin,r) = 0;
    ));

loop((r, tec_vre, vin),
    if ( (capa0(tec_vre, vin,r) > 0) and (sum(t, profile(t,tec_vre,r)) = 0),
            put log;
            put 'Capa0 but no profile for tec:' tec_vre.tl:0 ', vin:' vin.tl:0 ' and region:' r.tl:0 '; ' capa0(tec_vre, vin,r) ' GW affected'/;
            // capa0(tec_vre, allvin,r) = 0;
    ));
    
loop((r, tec_vre),
    if ( (sum(vin, i_gene0(tec_vre, "%PROJECT%", "%WeatherYEAR%",r)) > 0) and  (sum(vin, i_capa0(tec_vre,vin,"%WeatherYEAR%",r)) = 0),
            put log;
            put 'Gene0 but no capa0 profile for tec:' tec_vre.tl:0 ' and region:' r.tl:0/;
            // capa0(tec_vre, allvin,r) = 0;
    ));

*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~6 MODEL
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

*===============================================================
* a) Model Formulation
*===============================================================

POSITIVE VARIABLES
* Investment (and other yearly variables)
CAPA(alltec,allvin,r)            Total -endo and exo- capacity      (GW)
INVE(tec_inv,new,r)              investment                        (GW)
DECO(tec_inv,vin,r)              disinvestments                    (GW)
CAPACHP(tec_chp,allvin,r)        CHP capacity                      (GW)
INVECHP(tec_chp,new,r)           additional CHP capacity           (GW)
DECOCHP(tec_chp,vin,r)           decomissioned CHP capa            (GW)
ASC(r)                           ancillary service - must run      (GW)
INVESTO(tec_sto,new,r)           investment in storage             (GWh)
NTCINV(r,rr)                     new trans capacity                (GW)
                                                                      
* Dispatch (and other hourly variables)
SUPPLY(t,tec_supply,allvin,r)       supply - gene and sto discharge   (GW)
DEMAND(t,tec_demand,allvin,r)       demand - cons and sto charge      (GW)
GENE_increase(t,tec_thm,allvin,r)   generation increate               (GW)
GENE_decrease(t,tec_thm,allvin,r)   generation decreate               (GW)
RESERVOIR_V(t,r)                    energy in hydro reservoirs        (GWh)
SPILL(t,r)                          spillage of water                 (GW)
SLEVEL(t,tec_sto,allvin,r)          storge energy level               (GWh)
CURTAIL(t,r)                        curtailment of excessive energy   (GW)
CO2_CAPTURE(t,r)                    generic co2 capture               (t)
H2_IMPORTS(r)                       Hydrogen imports with fixed price (GWh thermal)
;

VARIABLES
COST                                total system cost                 (MEUR)
FLOW(t,r,rr)                        exports from r to rr              (GW)
HydrogenSupply(r) 
HydrogenDemand(r)
;

EQUATION
E1,
E2,
C, C1, C2, C3, C4
K1, K2, K3, K4, K5      // optional chp equations
A1, A2                  // optional ancillary services
Ra, Ru, Rd              // optional ramping
H1, H2, H3, H4
S1, S2, S3, S4
F1, F2, F3, F4
E3                      // optional emission cap equation
T1                      // optional vre target equation
O
;

* Energy balance
E1(t,r)..                load_mod(t,r) =E= sum((tec_supply,allvin),SUPPLY(t,tec_supply,allvin,r))
                                         - sum((tec_demand,allvin),DEMAND(t,tec_demand,allvin,r))
                                         - sum(rr,FLOW(t,r,rr))
                                         - CURTAIL(t,r);
                                                        
* Hydrogen balance (H2 supply > H2 demand)
E2(r)..                  h2_demand_exo(r) =L= H2_IMPORTS(r)
                                            + sum((tec_h2d,allvin,t),
                                                    DEMAND(t,tec_h2d,allvin,r)*eff(tec_h2d))
                                            - sum((tec_h2g,allvin,t),
                                                    SUPPLY(t,tec_h2g,allvin,r)/efficiency(tec_h2g,allvin)
                                                  + GENE_increase(t,tec_h2g,allvin,r)*fuel_ramping(tec_h2g,r));

* Emission cap (linear reduction path)
E3..                     sum(r, co2_cap(r))         =G= sum((t,tec_thm,allvin,r),
                                                            co2_int(tec_thm,r)*(
                                                                SUPPLY(t,tec_thm,allvin,r)/efficiency(tec_thm,allvin)
                                                                + GENE_increase(t,tec_thm,allvin,r) * fuel_ramping(tec_thm,r)))
                                                        - sum((t,r), CO2_CAPTURE(t,r));

* Capacity aggregation: the sum of capa0, INVE and DECO is surrarised as CAPA over the sets tec_mod and allvin
C(alltec, allvin,r)..   CAPA(alltec,allvin,r)       =E=   sum(                   vin(allvin), capa0(alltec,vin,r))
                                                        + sum((tec_inv(alltec), new(allvin)), INVE(tec_inv,new,r))
                                                        - sum((tec_inv(alltec), vin(allvin)), DECO(tec_inv,vin,r));

* Capacity adequacy: VRE & thermal & demand-side technologies
* @RS: Given the similarity of C1 and C4, tec_exo may even be included in tec_vre?
C1(t,tec_vre,allvin,r).. SUPPLY(t,tec_vre,allvin,r)   =E= profile(t,tec_vre,r)*CAPA(tec_vre,allvin,r);
                                                        
C2(t,tec_thm,allvin,r).. SUPPLY(t,tec_thm,allvin,r)   =L= avail(t,tec_thm,r) * (
                                                                CAPA(tec_thm,allvin,r)
                                                                - sum(tec_chp(tec_thm), CAPACHP(tec_chp,allvin,r)*(1 - CHP_profile(t,tec_chp,"max",r)))
                                                            );
                                                        
C3(t,tec_con,allvin,r).. DEMAND(t,tec_con,allvin,r)   =L= avail(t,tec_con,r) * CAPA(tec_con,allvin,r);
                                                        
C4(t,tec_exo,allvin,r).. SUPPLY(t,tec_exo,allvin,r)   =E= profile(t,tec_exo,r) * CAPA(tec_exo,allvin,r);


* CHP
K1(t,tec_chp,allvin,r).. SUPPLY(t,tec_chp,allvin,r) =G= CAPACHP(tec_chp,allvin,r) * CHP_profile(t,tec_chp,"min",r) * avail(t,tec_chp,r);  // minimum generation from CHP technologies: CHP profile times CHP capacity - this is NOT the demand-supply balance for heat (which does not exist)
K2(r)..                  chp_tot(r)                 =L= sum((tec_chp,allvin),CAPACHP(tec_chp,allvin,r));                                  // total CHP capacity needs to be greater or equal to chp_tot (parameter)

K3(tec_chp,allvin,r)..   CAPACHP(tec_chp,allvin,r)  =E= chp0(tec_chp,allvin,r)
                                                        + sum(new(allvin), INVECHP(tec_chp,new,r))
                                                        - sum(vin(allvin), DECOCHP(tec_chp,vin,r));                                    // CHP capacity by technology equals existing + investment - decommissioning
                                                        
K4(tec_chp,vin,r)..   DECOCHP(tec_chp,vin,r)        =L= sum(tec_inv(tec_chp), DECO(tec_inv,vin,r));                                    // all CHP dis-investment must be part of total dis-investment of that technology

K5(tec_chp,allvin,r)..   CAPACHP(tec_chp,allvin,r)  =L= CAPA(tec_chp,allvin,r);

* Ancillary services
A1(r)..                  ASC(r)                     =G= as(r) + as_vre * sum((alltec(tec_vre), allvin), CAPA(alltec, allvin,r));

A2(t,r)..                ASC(r)                     =L= sum((tec_thm,allvin), SUPPLY(t,tec_thm,allvin,r))
                                                        - as_chp * sum((tec_chp,allvin), CAPACHP(tec_chp,allvin,r)*CHP_profile(t,tec_chp,"min",r) )
                                                        + sum(allvin,
                                                            SUPPLY(t,"PHS",allvin,r)
                                                            + DEMAND(t,"PHS",allvin,r)
                                                            + SUPPLY(t,"hydr",allvin,r))
                                                        + sum(new, INVE("batr",new,r));
                                       
* Ramping 
Ra(t,tec_thm,allvin,r)..     GENE_increase(t,tec_thm,allvin,r) - GENE_decrease(t,tec_thm,allvin,r) =E= (SUPPLY(t,tec_thm,allvin,r)-SUPPLY(t-1,tec_thm,allvin,r))*1$(ord(t) > 1);

* Ru: ramp up
Ru(t,tec_thm,allvin,r)..     GENE_increase(t-1,tec_thm,allvin,r) =L= rp_constraint(tec_thm,r)*CAPA(tec_thm,allvin,r) + inf$(ord(t) = 1);

* Ru: ramp down
Rd(t,tec_thm,allvin,r)..     GENE_decrease(t-1,tec_thm,allvin,r) =L= rp_constraint(tec_thm,r)*CAPA(tec_thm,allvin,r) + inf$(ord(t) = 1);

* Hydro power
H1(t,allvin,r)..             SUPPLY(t,"hydr",allvin,r)  =L= CAPA("hydr",allvin,r);
H2(t,r)..                    RESERVOIR_V(t,r)           =E= inflow(t,r) + RESERVOIR_V(t-1,r) - SUPPLY(t,"hydr","1",r) - SPILL(t,r);
H3(t,r)..                    RESERVOIR_V(t,r)           =L= reservoir(r);
H4(t,allvin, r)..            SUPPLY(t,"hydr",allvin,r)  =G= hydro_min(r) * CAPA("hydr",allvin,r);


* Storage
S1(t,tec_sto,allvin,r)..     SLEVEL(t,tec_sto,allvin,r)                                =E= SLEVEL(t-1,tec_sto,allvin,r)
                                                                                           + sqrt(eff(tec_sto)) * sum(tec_demand(tec_sto), DEMAND(t,tec_demand,allvin,r))
                                                                                           - sum(tec_supply(tec_sto), SUPPLY(t,tec_supply,allvin,r)) / sqrt(eff(tec_sto));

S2(t,tec_sto,allvin,r)..       sum(tec_demand(tec_sto), DEMAND(t,tec_demand,allvin,r))
                             + sum(tec_supply(tec_sto), SUPPLY(t,tec_supply,allvin,r)) =L= CAPA(tec_sto,allvin,r);

S3(t,tec_sto,allvin,r)..     SLEVEL(t,tec_sto,allvin,r)                                =L= sto0(tec_sto,allvin,r) + sum(new(allvin), INVESTO(tec_sto,new,r));

S4(tec_sto,new,r)..          INVESTO(tec_sto,new,r)                                    =G= sum(tec_inv(tec_sto), INVE(tec_inv,new,r));

* Interconnectors
F1(t,r,rr)..       FLOW(t,r,rr)      =E= -FLOW(t,rr,r);
F2(t,r,rr)..       FLOW(t,r,rr)      =L= ntc0(r,rr) + NTCINV(r,rr);
F3(t,rr,r)..       FLOW(t,rr,r)      =L= ntc0(rr,r) + NTCINV(rr,r);
F4(r,rr)..         NTCINV(r,rr)      =E= NTCINV(rr,r);

* Policy targets
* Deduct storage losses? What about hydrogen?
T1(r)..            REshare(r)        =E= sum((t,allvin), SUPPLY(t,"hydr",allvin,r) + sum(tec_vre,SUPPLY(t,tec_vre,allvin,r)) + sum(tec_exo,SUPPLY(t,tec_exo,allvin,r))  - CURTAIL(t,r) ) / sum(t,load(t,r));

* Total system costs
O..                COST              =E= // Annualized investment costs
                                         + sum((tec_inv,new,r),           INVE(tec_inv,new,r)                     * cost_inv(tec_inv))
                                         + sum((tec_chp,new,r),           INVECHP(tec_chp,new,r)                  * sum(tec_inv(tec_chp), cost_chp(tec_inv)))
                                         + sum((tec_sto,new,r),           INVESTO(tec_sto,new,r)                  * cost_energy(tec_sto))
                                         
                                         // Yearly fixed costs
                                         + sum((alltec,allvin,r),         CAPA(alltec,allvin,r)                   * cost_qfix(alltec))
                                         
                                         // Variable costs
                                         + sum((t,tec_supply,allvin,r),   SUPPLY(t,tec_supply,allvin,r)           * cost_var(t,tec_supply,allvin,r))
                                         + sum((t,tec_demand,allvin,r),   DEMAND(t,tec_demand,allvin,r)           * cost_var(t,tec_demand,allvin,r))
                                         
                                         // If H2B, hydrogen import costs
                                         + sum(r,                         H2_IMPORTS(r)                           * h2_import_price)$(%H2B% = 1)
                                         
                                         // If RAMPING, ramping costs
                                         + sum((t,tec_thm,allvin,r),      GENE_increase(t,tec_thm,allvin,r)/th    * cost_ramping(tec_thm,r))$(%RAMPING% = 1)
                                         
                                         // Network expansion costs
                                         + sum((r,rr),                    NTCINV(r,rr)*km(r,rr)/2                 * cost_ntc)
                                         
                                         // Carbon absorbtion costs
                                         + sum((t,r),                     CO2_CAPTURE(t,r)                        * (1000 -  co2(r)) / mn)
                                         
                                         // Curtailment costs (opportunity costs)
                                         + sum((t,r),                     CURTAIL(t,r)                            * cost_curtail);
                                         

MODEL EMMA /
E1
C, C1, C2, C3, C4
H1, H2, H3, H4
S1, S2, S3
S4
F1, F2, F3, F4
O
$IFTHENE.cap_emissions %CARBONCAP%=='1'
    E3
$ENDIF.cap_emissions

$IFTHENE.hydrogen_balance %H2B%=='1'
    E2
$ENDIF.hydrogen_balance

$IFTHENE.chp_constraints %CHP%=='1'
    K1, K2, K3, K4, K5
$ENDIF.chp_constraints

$IFTHENE.ramping %RAMPING%=='1'
    Ra, Ru, Rd
$ENDIF.ramping

$IFTHENE.ancillary_services %ASC%=='1'
    A1, A2, S4
$ENDIF.ancillary_services

$IFTHENE.vre_target %RETARGET%=='1'
    T1
$ENDIF.vre_target

/;

*===============================================================
* b) Constraints
*===============================================================

* CAPACTIY

** Policy constraints on investment variable
INVE.LO(tec_inv,new,r) = invemin(tec_inv,r);
INVE.UP(tec_inv,new,r) = invemax(tec_inv,r);

** Lignite resources (Overwrites INVE in policy constraints)
INVE.FX("lign",new,r)     $(not r_l(r)) = 0;
INVE.FX("lign_CCS",new,r) $(not r_l(r)) = 0;

** Limit decomissioning to initial capacity
* RS: check if necessary, and if yes, adjust. This should be implicitly stated by the CAPA constriants
DECO.UP(tec_inv,vin,r)       = capa0(tec_inv,vin,r);
DECOCHP.UP(tec_chp,vin,r)    = chp0(tec_chp,vin,r);

** Limit decomissioning to non-VRE
DECO.FX(tec_inv(tec_vre), vin,r)       = 0;

* No Hydro investment / divestment
* INVE.FX("hydr",new,r) = 0; // not needed as hydr not in tec_inv
* DECO.FX("hydr",vin,r) = 0; // not needed as hydr not in tec_inv

* No PHS investment / divestment
INVE.FX("PHS",new,r) = 0;
DECO.FX("PHS",vin,r) = 0;
INVESTO.FX("PHS",new,r) = 0;

* CCS
$IFTHENE.exclude_CCS_techs not %CCS%=='1'
    INVE.FX("lign_CCS",new,r) = 0;
    INVE.FX("coal_CCS",new,r) = 0;
    INVE.FX("CCGT_CCS",new,r) = 0;
$ENDIF.exclude_CCS_techs

* SHORTTERM <- adjust later when years other than 2016 are modelled
$IFTHENE.force_shortterm %SHORTTERM%=='1'
    INVE.FX(tec_inv,new,r)        = 0;
    INVECHP.FX(tec_chp,new,r)     = 0;
    
    DECO.FX(tec_inv,vin,r)        = 0;
    DECOCHP.FX(tec_chp,vin,r)     = 0;

    INVESTO.FX(tec_sto,new,r)     = 0;
    INVESTO.FX(tec_sto,new,r)     = 0;

    INVE.UP("shed",new,r)          = inf;
$ENDIF.force_shortterm

* NTC investment in LTE
$IFTHEN.allow_LTE %HORIZON%=='LTE'
    NTCINV.UP(r,rr)  = inf;
    // fix interconnector variables for region-pairs that have no border
    NTCINV.FX(r,rr)            $(not km(r,rr)) = 0;
    NTCINV.FX(rr,r)            $(not km(rr,r)) = 0;
$ELSE.allow_LTE
    // investment only for long-term equilibrium
    NTCINV.FX(r,rr)                  = 0;
$ENDIF.allow_LTE

* INVESTO.FX("batr",new,r) = 5;
* INVE.FX("batr",new,r) = 2.5;

// INVE.FX("PtHydrogen", allvin, r) = 0;

*===============================================================
* c) Override/complement constraints according to scenarios %SC%
*===============================================================

$include scen\sc_%SC%.gms



*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~7 SOLVE (OPTIONS, STARTING VALUES)
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

* Options
* Performance setting (makes debugging more difficult: enable in production)
* EMMA.holdfixed=1;                 // this should save memory
* EMMA.solvelink=0;                 // this should save memory
* EMMA.dictfile=0;                  // this should save memory
* EMMA.limrow=0;                    // reduces the size of the listing file
* EMMA.limcol=0;                    // reduces the size of the listing file
* EMMA.solprint=0;                  // reduces the size of the listing file

EMMA.optfile=1;                   // 1 is rendered as <solvername>.opt i.e. cplex.opt
EMMA.reslim=50000;                // limits solving time to 14h

EMMA.threads=%THREADS%;

display cost_fuel, cost_qfix, cost_inv, cost_var, eff, avail, load, invemin, invemax, profile, capa0, chp0, ntc0, i_FLH, inflow, REshare, co2, export, CHP_profile, discountrate, cost_energy, km;

SOLVE EMMA USING LP minimizing COST;


display INVE.L, DECO.L, SUPPLY.L, DEMAND.L, INVESTO.L, CURTAIL.L, FLOW.L, chp_tot, E1.M, CAPA.L, CAPACHP.L, SLEVEL.L, NTCINV.L;


display inflow, RESERVOIR_V.L, reservoir, hydro_min;


* Parameter definitions that rely on command line options
PARAMETER
asc_level(r)     ASC must run                          (GW)
co2_price(r)     Carbon price                          (EUR per ton)
h2_price_sell(r) The price at which hydrogen is sold   (EUR per MWh thermal)
h2_price_buy(r)  The price at which hydrogen is bought (EUR per MWh thermal) // the delta between buy and sell should be the full storage and transportation cost
;

$IFTHENE.hydrogen_balance %H2B%=='1' 
    h2_price_buy(r) = sum(tec_h2g, cost_fuel(tec_h2g))/card(tec_h2g) - E2.M(r)*th;
    h2_price_sell(r) = -sum(tec_h2d, cost_fuel(tec_h2d))/card(tec_h2d) - E2.M(r)*th;
$ELSE.hydrogen_balance
    h2_price_buy(r) = sum(tec_h2g, cost_fuel(tec_h2g))/card(tec_h2g);
    h2_price_sell(r) = -sum(tec_h2d, cost_fuel(tec_h2d))/card(tec_h2d);
$ENDIF.hydrogen_balance

display h2_price_buy, h2_price_sell;

$IFTHENE.ancillary_services %ASC%=='1'
    asc_level(r) = ASC.L(r);
$ELSE.ancillary_services
    asc_level(r) = 0;
$ENDIF.ancillary_services

$IFTHENE.cap_emissions %CARBONCAP%=='1'
    co2_price(r) = E3.M * mn + co2(r);
$ELSE.cap_emissions
    co2_price(r) = co2(r);
$ENDIF.cap_emissions


* Create GDX
$IF %DUMPDATA% == '1'            $include output.gms

* Put data into Excel
$IF %DUMPDATA% == '1'            execute 'gams to_excel.gms --ROW=B'



