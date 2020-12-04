


*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~1     SETTINGS and COMMAND LINE PARAMETER DEFAULTS
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------


* Settings

$eolcom //
$setenv GdxCompress 1
* $offlisting
* Turn off the listing of the input file - reduces listing file size, but makes debugging much harder
$Onempty
$phantom emptyset
* allows using "emptyset" as an entry of a set that is ignored - Is this different to $Onempty?


* Create folders

$if not dexist scen     $call "mkdir scen"
$if not dexist start    $call "mkdir start"
$if not dexist trash    $call "mkdir trash"




* Command line parameters defaults (steered by EMMA_call)

* CLP for model
$if not set PURPOSE              $set PURPOSE            Test
$if not set PROJECT              $set PROJECT            DEFAULT
$if not set HOURS                $set HOURS              100
$if not set YDIM                 $set YDIM               bench
$if not set SDIM                 $set SDIM               bench
$if not set HORIZON              $set HORIZON            2016
$if not set AVAIL                $set AVAIL              seasonal
$if not set GASPRICE             $set GASPRICE           seasonal
$if not set WeatherYEAR          $set WeatherYEAR        2016
$if not set REGIONS              $set REGIONS            1R
$if not set DATA                 $set DATA               data
$if not set ASC                  $set ASC                1
$if not set CHP                  $set CHP                1
$if not set RUNTHROUGH           $set RUNTHROUGH         1
$if not set WINDPROFILE          $set WINDPROFILE        agg
$if not set SOLARPROFILE         $set SOLARPROFILE       agg
$if not set SOLAR4WIND           $set SOLAR4WIND         0
$if not set CO2                  $set CO2                DATAXLSX
$if not set DISCOUNTRATE         $set DISCOUNTRATE       0.07
$if not set RETARGET             $set RETARGET           0

* CLP for model simplifications (1 on / 0 off)
$if not set NOCONS               $set NOCONS             0
$IFi %NOCONS%=='1'               $set ASC                0
$IFi %NOCONS%=='1'               $set CHP                0

* CLP for input/output
$if not set FAST                 $set FAST               0
$IFi %FAST%=='1'                 $set LOADDATA           0
$IFi %FAST%=='1'                 $set OUTPUT             0
$if not set OUTPUT               $set OUTPUT             1
$if not set LOADDATA             $set LOADDATA           1
$if not set OPEN                 $set OPEN               0
$if not set tREPORT              $set tREPORT            0
* tREPORT could be done with much less coad via $ONTEXT

$if not set SHORTTERM            $set SHORTTERM          0

* CLP for solver options
$if not set OPTFILE              $set OPTFILE            7
$if not set THREADS              $set THREADS            -1

* CLP for regional scope
$IFi %REGIONS%=='pR'             $set r                  GER,SWE,FRA,POL,NLD,BEL,NOR,AUT,CHE,CZE,DNK,GBR
$IFi %REGIONS%=='aR'             $set r                  GER,SWE,FRA,POL,NLD,BEL,NOR
$IFi %REGIONS%=='cR'             $set r                  GER,FRA,POL,NLD,BEL
$IFi %REGIONS%=='cRnh'           $set r                  GER,POL,NLD,BEL
$IFi %REGIONS%=='nR'             $set r                  GER,SWE,FRA,NOR
$IFi %REGIONS%=='3R'             $set r                  GER,SWE,FRA
$IFi %REGIONS%=='2R'             $set r                  GER,SWE
$IFi %REGIONS%=='1R'             $set r                  GER

* CLP for hydrogen: 0 no H2, 1 H2 , 2 H2 base, 3 H2 inflex
$if not set H2                   $set H2                 0
$if not set H2BASE               $set H2BASE             1
$IFi %H2%=='0'                   $set H2BASE             0
$IFi %H2%=='1'                   $set H2BASE             0



*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~2    SCENARIOS
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------


$include EMMA_scenarios.gms






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
alltec                   all possible techs      /cCCS,CCGT,gCCS,CCH2,OCGT,shed,wion,wiof,solar,PHS,batr,hydr,ror,bio/
allvin                   all vintages incl. new  /1,2,3,new/
allyear                  all weather years       /1990*2030/
allh                     all horizons            /2008*2019,2025,2030,LTE/
allpro                   all project             /DEFAULT,DEFAULTLTE/

h_years(allh)            horizon years (non-LTE) /2016,2025,2030/
today(allh)              today's year            /2016/

t(allt)                  hour of the year        /1*%HOURS%/
ti(t)                    short for reporting     /1*100/

rall(allr)               regions included + all  /%r%,all/
r(rall)                  regions included        /%r%/
r_h(allr)                regions with hydro      /AUT,CHE,CZE,FRA,GBR,GER,NOR,NO1*NO5,SWE,SE1*SE4/
r_p(allr)                regions with PHS        /AUT,BEL,CHE,CZE,FRA,GER,POL/
r_t(allr)                regions thermal only    //
r_c(allr)                regions with new coal   /POL,CZE/
r_o(allr)                regions with offshore   /BEL,DNK,FRA,GBR,GER,NLD,NOR,POL,SWE/
r_not(allr)              regions not included    //
r_FRA(allr)              for 1R model runs       /FRA/
r_SWE(allr)              for 1R model runs       /SWE/
r_POL(allr)              for 1R model runs       /POL/

tec_mod(alltec)          techs with end. disp.   /cCCS,CCGT,gCCS,CCH2,OCGT,shed,wion,wiof,solar,hydr,PHS,batr/
tec_exo(alltec)          techs with exog. disp.  /ror,bio/
tec_gen(tec_mod)         generation techs        /cCCS,CCGT,gCCS,CCH2,OCGT,shed,wion,wiof,solar,hydr/
tec_sto(tec_mod)         storage techs           /PHS,batr/
tec_inv(tec_gen)         gen. techs w end inv    /cCCS,CCGT,gCCS,CCH2,OCGT,shed,wion,wiof,solar/
tec_thm(tec_inv)         thermal techs           /cCCS,CCGT,gCCS,CCH2,OCGT,shed/
tec_vre(tec_inv)         VRE techs               /wion,wiof,solar/
tec_chp(tec_thm)         CHP techs               /cCCS,CCGT,gCCS,CCH2,OCGT,shed/              // "shed" is included to make SHORT runs feasible
tec_flex(tec_mod)        very flexible techs     /OCGT,PHS,batr/
tec_re(alltec)           renewable techs         /wion,wiof,solar,hydr,ror,bio/   //bio includes waste

par_cost                 cost parameters         /invest,energy,lifetime,qfixcost,varcost,co2int,eff_new,rt_premium,flex_premium/
par_sto                  storage parameters      /power,energy/

vin(allvin)              vintages without new    /1,2,3/

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

year(allyear)            year or profile         /%WeatherYEAR%/
h_year(allh)             year of horizon         /%HORIZON%/

var                      in order of appearance  /"Demand"               // volumes
                                                  "Base Price"           // prices (following)
                                                  "Peak Price"
                                                  "Off-Peak Price"
                                                  "Load Price"
                                                  "Scarcity Price"
                                                  "P-to-OP"
                                                  "# zero prices"
                                                  "# scarcity prices"
                                                  "Total Sys Cost"       // values (following)
                                                  "Gen Costs"
                                                  "IC cost"
                                                  "Gen Costs nRES"
                                                  "Gen Costs RES"
                                                  "Gen Costs w/o CO2"
                                                  "Total Sys Cost w sunk"
                                                  "Gen Costs w sunk"
                                                  "IC cost w sunk"
                                                  "Gen Costs nRES w sunk"
                                                  "Gen Costs RES w sunk"
                                                  "Spot Expenses"
                                                  "Spot Income"
                                                  "Spot Conv Income"
                                                  "AS Income"
                                                  "Heat Income"
                                                  "Sunk gen cost"
                                                  "Sunk conv gen cost"
                                                  "Sunk IC cost"
                                                  "Conv Rent"
                                                  "Conv rent - sunk cost"
                                                  "RES tax"
                                                  "CO2 revenue"
                                                  "Consumer Rent"
                                                  "Producer Rent"
                                                  "State Revenue"
                                                  "Economic Welfare"     // other parameters (following)
                                                  "market share"
                                                  "PHS res"
                                                  "hydr inflow"
                                                  "hydr res"
                                                  "CHP"/





var_onlysys(var)         reporting names that are only possible at system level                                          /"Total Sys Cost","Total Sys Cost w sunk"/
var_o_val(var)           reporting names that are contained in o_val (values that exist at country and system level)
var_val(var)             reporting names that indicate values (including those only possible at system level)
var_price(var)           reporting names that indicate prices (which cannot be summed or written in absolute values)     /"Base Price","Peak Price","Off-Peak Price","Load Price","Scarcity Price","P-to-OP","# zero prices","# scarcity prices"/
var_vol(var)             reporting names that indicate volumes                                                           /"Demand"/
var_t(var)               reporting names that are used in r_t                                                            /"PHS res","hydr res","CHP"/

r_tec_var                names in r_tec          /"capa0 (GW)","new cap (GW)","decom cap (GW)","chp0 (GW)","new chp cap (GW)","decom chp cap (GW)","net gen (TWh)","New Fix Cost (G€)","Old qfix Cost (G€)","Var Cost (G€)","Revenue Spot (G€)","Revenue AS (G€)","Revenue Heat (G€)","SR Profit (G€)"/

*y                        scenarios: first dim    /1,25,50,75,100/          // 1,15,30,45,60   2008,2009,2010  1,20,40,60,100  1,20,50,100,200  1,5,10,20,30
;



var_o_val(var)           = yes;
var_o_val(var_onlysys)   = no;
var_o_val(var_price)     = no;
var_o_val(var_vol)       = no;
var_o_val(var_t)         = no;
var_val(var_o_val)       = yes;
var_val(var_onlysys)     = yes;


* Specify the subsets of regions according to specific technology availability

r_not(allr)     = yes;
r_not(r)        = no;

r_h(r_not)      = no;
r_p(r_not)      = no;
*r_l(r_not)      = no;

r_FRA(r_not)    = no;
r_SWE(r_not)    = no;
r_POL(r_not)    = no;

r_t(r)          = yes;
r_t(r_h)        = no;
r_t(r_p)        = no;


$include scen\ynames_%YDIM%.gms
$include scen\snames_%SDIM%.gms


ALIAS (allr,from_allr)
ALIAS (allr,to_allr)

ALIAS (r,rr)

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

i_load(allt,allpro,allr,allyear)
i_solar(allt,allpro,allr,allyear)
i_wion(allt,allpro,allr,allyear)
i_wiof(allt,allpro,allr,allyear)
i_solar_future(allt,allpro,allr,allyear)
i_wion_future(allt,allpro,allr,allyear)
i_wiof_future(allt,allpro,allr,allyear)

i_wind_agg(allt,allr,allyear)
i_wind_TSO(allt,allr,allyear)
i_wind_V90(allt,allr,allyear)
i_wind_V110(allt,allr,allyear)
i_wind_V90old(allt,allr,allyear)
i_wind_V110old(allt,allr,allyear)
i_wind_V110oldalt(allt,allr,allyear)
i_wind_E70(allt,allr,allyear)
i_wind_E82(allt,allr,allyear)
i_wind_E115(allt,allr,allyear)
i_wind_Emix(allt,allr,allyear)
i_wind_E82b(allt,allr,allyear)
i_wind_E115b(allt,allr,allyear)
i_wind_scaled(allt,allr,allyear)
i_wind_W100(allt,allr,allyear)

i_solar_agg(allt,allr,allyear)
i_solar_TSO(allt,allr,allyear)
i_solar_S(allt,allr,allyear)
i_solar_SW(allt,allr,allyear)
i_solar_SWE(allt,allr,allyear)
i_solar_W(allt,allr,allyear)
i_solar_E(allt,allr,allyear)

i_capa0(alltec,vin,allh,allr)
i_energy0(*,allh,allr)
i_eff0(tec_mod,vin)
i_chp0(tec_chp,vin,allh,allr)
i_chp_tot(allh,allr)
i_ntc0(allr,allh,allr)
i_exp0(allr,allh,allr)

i_CHP(allt,*,*)
i_CHPyr(allr,*)
i_monthly(month_year,*)
i_cost(allpro,alltec,par_cost)
i_FLH(allr,*)
i_km(allr,allr)
i_ACDC(allr,allr)
i_gene0(*,allpro,allh,allr)
i_yload(allr,allpro,allh)
i_fuel(tec_mod,allpro,allh)
i_CO2(*,allpro,allh)



* Model Parameters (no prefix)

load(t,r)                hourly load                                     (GW)                    [loaded as MW]
yload(rall)              yearly demand (sum of load)                     (TWh per full a)
load_mod(t,r)            load - exogenous gen (bio and ror) + exports    (GW)
profile(t,*,r)           profiles for wind & solar & CHP - not load      (1 | sum up to FLH)
CHP_profile(t,tec_chp,*,r) min and max profiles for CHP                  (1)
co2(r)                   CO2-price                                       (€ per t)
cost_fix(alltec)         annulized fixed costs (qfix + inv)              (M€ per GW*a)
cost_qfix(alltec)        annulized quasi-fixed costs                     (M€ per GW*a)
cost_inv(alltec)         annualized investment cost                      (M€ per GW*a)
cost_var(t,tec_mod,allvin,r) variable cost                               (M€ per GWh)            [loaded as € per MWh]
cost_fuel(tec_mod)       fuel cost                                       (€ per MWht)
cost_energy(tec_sto)     investment cost in storage volume               (M€ per GWh*a)
cost_ntc                 transmission cost                               (M€ per GW_NTC*km*a)
cost_bal(tec_vre)        balancing cost                                  (€ per MWh)
run_through(alltec)      run through premium                             (M€ per GWa)

capa0(alltec,vin,r)      existing net installed total capacity           (GW)
eff0(tec_thm,vin)        efficiency of existing thermal capacity         (1)
sto0(tec_sto,*,r)        existing storage capacity                       (GW and GWh)
ntc0(r,rr)               existing trans capacity from r to rr            (GW) [rescaled]
chp0(tec_CHP,vin,r)      existing CHP generation capacity                (GW)
chp_tot(r)               sum of required CHP generation capacity         (GW)

eff(alltec)              conversion efficiency                           (1)
lifetime(alltec)         life-time                                       (a)
avail(t,alltec,r)        availability of generation                      (1)
km(r,rr)                 distance between regions                        (km)
ACDC(r,rr)               HVAC or HVDC dummy                              (dummy)
as(r)                    must-run                                        (GW)
as_vre                   must-run as share of VRE capacity               (1)
as_chp                   chp providing AS (0) or not (1)                 (binary)
fuelseason(t,alltec)     multiplicator for fuel price seasonality        (1)
inflow(t,allr)           hydro reservoir inflow                          (share of installed capacity)
reservoir(allr)          hydro reservoir size                            (factor of installed capacity)
hydro_min(allr)          min hydro generation                            (share of installed capacity - could also be made time-dependent)
gene_exo(t,tec_exo,r)    generation of non-modeled technologies          (GW)
export(t,r)              export to non-modeled regions                   (GW)

h2_price                 H2 price                                        (€ per kg)
h2_eff                   H2 electrolyzer efficiency                      (GWh_H2 per GWh_el)
h2_dispatch              H2 electrolyzer wtp for electricity             (M€ per GWh)
h2_invest                H2 electrolyzer investment cost                 (M€ per GW*a)
h2_invest_stoenergy      H2 storage investment cost per energy           (M€ per GWh*a)


* Units

* M€ / GW*a      = € / KW*a
* € / MWh        = M€ / TWh
* € / KWh        = M€ / GWh
* € / KW         = M€ / GW



* Outcome Parameters (o_)

o_p(t,allr)                   spot price                                        (M€ per GWh)
o_load(t,r)                   hourly load incl ror and bio                      (GWh per hour)
o_margin(t,alltec,r)          spot margin                                       (€ per MWh)

o_capa(*,rall)                total installed capacity (pre-curtailment)        (M€ per full a)
o_capa0(alltec,r)             existing capacity by tec (agg. vintages)          (GW)
o_chp0(tec_chp,r)             existing chp capacity by tec (agg. vintages)      (GW)
o_inve(tec_mod,r)             new capacity by tec                               (GW)
o_invechp(tec_chp,r)          new chp capacity by tec                           (GW)
o_deco(tec_mod,r)             decommisioned capacity by tec (agg. vintages)     (GW)
o_deco_vin(tec_mod,vin,r)     decommisioned capacity by tec and vin             (GW)
o_decochp(tec_chp,r)          decommisioned chp capacity by tec (agg. vintages) (GW)
o_decochp_vin(tec_chp,vin,r)  decommisioned chp capacity by tec and vin         (GW)
o_stoinv(tec_sto,*,r)         new storage capacity                              (GW and GWh)

o_gene_vin(t,tec_mod,allvin,r) hourly net generation by vintage class           (GWh per hour)
o_gene(t,alltec,r)            hourly net generation                             (GWh per hour)
o_flow(t,r,rr)                hourly net exports excl. exogenous flows          (GWh per hour)
o_export(t,r)                 hourly net exports incl. exogenous flows          (GWh per hour)
o_ygene_vin(tec_mod,allvin,r) yearly generation by vintage class                (TWh per full a)
o_ygene(*,rall)               yearly generation (pre-curtailment)               (TWh per full a)
o_yinflow(r)                  yearly hydro inflow                               (TWh per full a)
o_cur(rall)                   curtailed generation                              (TWh per full a)
o_ASp(r)                      AS price                                          (€ per KW full a)
o_rload(t)                    total load by hour                                (GW)
o_rprice(t)                   average price by hour                             ()
o_rgene(t,alltec)             generation by hour and tec                        (GW)
o_rinflow(t)                  hydro inflow                                      (GW)
o_rreservoir(t)               hydro reservoir level                             (TWh)
o_share(alltec,*)             market share (pre-curtailment)                    (%)
o_cost(alltec,r)              yearly total cost by tec                          (M€ per full a)
o_cost_components(*,alltec,r) yearly cost components by tec                     (M€ per full a)
o_LEC(alltec,r)               levelized electricity costs                       (€ per MWh)
o_revS(alltec,r)              yearly revenues from spot                         (M€ per full a)
o_revA(alltec,r)              yearly revenues from AS                           (M€ per full a)
o_revH(alltec,r)              yearly revenues from Heat-MR                      (M€ per full a)
o_rev(alltec,r)               total yearly revenues                             (M€ per full a)
o_mvS(alltec,*)               market value on spot markets                      (1)
o_mv(alltec,*)                market value incl AS and heat income              (1)
o_vfS(alltec,*)               value factor on spot markets (base price)         (1)
o_vf(alltec,*)                value factor incl AS and heat income (base pri)   (1)
o_bp(rall)                    base price                                        (€ per MWh)
o_lp(rall)                    demand-weighted price                             (€ per MWh)
o_pp(allr)                    peak price                                        (€ per MWh)
o_op(allr)                    off-peak price                                    (€ per MWh)
o_gen(rall)                   yearly generation                                 (TWh per full a)
o_CO2_vin(tec_mod,allvin,r)   CO2 emissions by tec and vintage                  (Mt per full a)
o_CO2(rall)                   CO2 emissions                                     (Mt per full a)
o_val(r,s,y,var)              output: values                                    (G€ per full a)
o_h2_capa(rall)               H2 electrolyzer capacity                          (GW)
o_h2_cons(t,rall)             H2 electrolyzer consumption                       (GWh per hour)
o_h2_ycons(rall)              H2 electrolyzer yearly consumption                (TWh per full a)
o_h2_flh(rall)                H2 electrolyzer full load hours                   (h per full a)
o_h2_sto_energy(rall)         H2 storage energy capacity                        (GWh)


* Outcome of the long-term run (lt_)

lt_INVE(alltec,r)        outcome of the LT run
lt_NTCINV(r,rr)          outcome of the LT run
lt_CAPACHP(tec_chp,r)    outcome of the LT run


* Outcome Parameters with s dimension (s_)
*s_p(s,t,allr)              spot price                                      (M€ per GWh)
s_p
s_bp
s_gene
s_flow
s_export
s_CO2
s_cost
s_cost_components
s_capa
s_inve
s_stoinv
s_deco
s_h2


* Reporting Parameters (r_)

r_s
r_r
r_r2
r_vf
r_vfbal
r_vf2
r_vfH
r_capa
r_capa2
r_ms
r_ms2
r_gene
r_gene2
r_tec
r_tec_vin
r_cost
r_sto
r_hydro
r_heat
r_NTC
r_set
r_set2
r_mo
r_stats
r_stats2

r_tG
r_tP
r_tP1
r_day
r_week
r_month
r_hour_day

r_OSE                    outputs for OSE model comparison
r_tS                     outputs for OSE model comparison - storage time series

r_h2

* Scalars, scale, test

th                       /1000/
mn                       /1000000/
little                   /0.0000001/
discountrate             /%DISCOUNTRATE%/
sc                       scale parameter for t<8760
test(r)
test1
test2
test3
test4
;







*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~5 PARAMETER VALUES
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------




*===============================================================
* a) Read in from Exel (i_*)
*===============================================================




* Non-time series data from data.xlsx

$onecho > data.txt
par=i_cost               rng=cost!c2:o36                 rdim=2 cdim=1
par=i_yload              rng=yload!a2:o19                rdim=1 cdim=2
par=i_fuel               rng=fuel!a2:o12                 rdim=1 cdim=2
par=i_CO2                rng=fuel!a23:o32                rdim=1 cdim=2
par=i_monthly            rng=monthly!b2:l14
par=i_FLH                rng=FLH!a2:e20
par=i_km                 rng=km!b2:ai35
par=i_ACDC               rng=ACDC!b2:af32
$offecho

$IF %LOADDATA% == '1'            $CALL GDXXRW.exe        input\%DATA%.xlsx        @data.txt
$IF NOT EXIST %DATA%.gdx         $CALL GDXXRW.exe        input\%DATA%.xlsx        @data.txt
$GDXIN %DATA%.gdx
$LOADdc i_cost, i_yload, i_fuel, i_CO2, i_monthly, i_FLH, i_km, i_ACDC



* Existing capacities from data0.xlsx

$onecho > data0.txt
par=i_capa0              rng=capa0!a2:ax23                rdim=2 cdim=2
par=i_energy0            rng=capa0!b27:ax32               rdim=1 cdim=2
par=i_chp0               rng=chp0!a2:ax15                 rdim=2 cdim=2
par=i_chp_tot            rng=chp0!c19:ax21                rdim=0 cdim=2
par=i_gene0              rng=gene0!a2:dk23                rdim=1 cdim=3
par=i_eff0               rng=eff0!a2:c14                  rdim=2
par=i_ntc0               rng=ntc0!b2:ec36                 rdim=1 cdim=2
par=i_exp0               rng=exp0!b2:ft32                 rdim=1 cdim=2
$offecho

$IF %LOADDATA% == '1'            $CALL GDXXRW.exe        input\data0.xlsx        @data0.txt
$IF NOT EXIST data0.gdx          $CALL GDXXRW.exe        input\data0.xlsx        @data0.txt
$GDXIN data0.gdx
$LOADdc i_capa0, i_energy0, i_gene0, i_eff0, i_chp0, i_chp_tot, i_ntc0, i_exp0



* Time series data from data_ts.xlsx

$onecho > data_ts.txt
set=time                 rng=time!a2:k8761               rdim=9
par=i_CHP                rng=CHP!a6:d8767                rdim=1 cdim=2
par=i_load               rng=load!a6:dz8768              rdim=1 cdim=3
par=i_solar              rng=solar!a7:ca8769             rdim=1 cdim=3
par=i_solar_future       rng=solar_future!a6:dq8768      rdim=1 cdim=3
par=i_wion               rng=wion!a7:cg8769              rdim=1 cdim=3
par=i_wion_future        rng=wion_future!a6:ea8768       rdim=1 cdim=3
par=i_wiof               rng=wiof!a7:cg8769              rdim=1 cdim=3
par=i_wiof_future        rng=wiof_future!a6:cm8768       rdim=1 cdim=3
$offecho

$IF %LOADDATA% == '1'            $CALL GDXXRW.exe        input\data_ts.xlsx     @data_ts.txt
$IF NOT EXIST data_ts.gdx        $CALL GDXXRW.exe        input\data_ts.xlsx     @data_ts.txt
$GDXIN data_ts.gdx
$LOADdc time, i_CHP, i_load, i_solar, i_solar_future, i_wion, i_wion_future, i_wiof, i_wiof_future





*===============================================================
* b) Fill in model parameter values
*===============================================================


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




* Availability

avail(t,alltec,r)        = 1;
avail(t,tec_thm,r)       = 0.8;

$IFi %AVAIL%=='flat'        avail(t,tec_thm,r)               = 0.8;
$IFi %AVAIL%=='seasonal'    avail(t,tec_thm,r)               = sum(t_month_year(t,month_year),i_monthly(month_year,"avail"));
$IFi %AVAIL%=='seasonalmod' avail(t,tec_thm,r)               = sum(t_month_year(t,month_year),i_monthly(month_year,"avail_mod"));
$IFi %AVAIL%=='hist'        avail(t,tec_thm,r)               = sum(t_month_year(t,month_year),i_monthly(month_year,"avail"));
$IFi %AVAIL%=='hist'        avail(t,"nucl",r)$(r_FRA(r))     = sum(t_month_year(t,month_year),i_monthly(month_year,"avail_FRA_nuc"));



* Scaling parameter

sc                       = 8760 / card(t);



* Loading annual electricity consumption

yload(r)                 = i_yload(r,"%PROJECT%","%HORIZON%");



* Hourly profiles: selected year

loop(year,
load(t,r)            = i_load(t,"%PROJECT%",r,year) / th;
profile(t,"solar",r) = i_solar(t,"%PROJECT%",r,year);
profile(t,"wion",r)  = i_wion(t,"%PROJECT%",r,year);
profile(t,"wiof",r)  = i_wiof(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2025' profile(t,"solar",r) = i_solar_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2025' profile(t,"wion",r)  = i_wion_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2025' profile(t,"wiof",r)  = i_wiof_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2030' profile(t,"solar",r) = i_solar_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2030' profile(t,"wion",r)  = i_wion_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2030' profile(t,"wiof",r)  = i_wiof_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2050' profile(t,"solar",r) = i_solar_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2050' profile(t,"wion",r)  = i_wion_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='2050' profile(t,"wiof",r)  = i_wiof_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='LTE'  profile(t,"solar",r) = i_solar_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='LTE'  profile(t,"wion",r)  = i_wion_future(t,"%PROJECT%",r,year);
$IFi %HORIZON%=='LTE'  profile(t,"wiof",r)  = i_wiof_future(t,"%PROJECT%",r,year);
);



* Scaling profiles to FLH / yearly electricity demand


i_FLH(r,tec_vre)         = sum(t,profile(t,tec_vre,r)) * sc;

loop(tec_vre,
test(r)                      = sum(t,profile(t,tec_vre,r)) * sc;
profile(t,tec_vre,r)$test(r) = profile(t,tec_vre,r) * i_FLH(r,tec_vre) / test(r);
);

test(r)                  = sum(t,load(t,r)) * sc / th;
load(t,r)                = load(t,r) * yload(r) / test(r);




* Derive load_mod

* Deduct exogenous generation: run-of-the-river hydro power and biomass

gene_exo(t,"ror",r)      = sum(t_month_year(t,month_year),i_monthly(month_year,"ROR_GER"));
gene_exo(t,"ror",r)      = gene_exo(t,"ror",r) / 730 * i_gene0("ror","%PROJECT%","%HORIZON%",r) * th;
gene_exo(t,"bio",r)      = i_gene0("bio","%PROJECT%","%HORIZON%",r) * th / 8760;

* Add net exports to non-modeled countries

export(t,r)              = (sum(r_not,i_exp0(r,"%HORIZON%",r_not)) - sum(r_not,i_exp0(r_not,"%HORIZON%",r))) * th / 8760;

load_mod(t,r)             = load(t,r) - sum(tec_exo,gene_exo(t,tec_exo,r)) + export(t,r);






* CHP Profiles

profile(t,"CHP",r)                = i_CHP(t,"DEFAULT","average");


* CHP restrictions:               Backpressure                 Condensing
CHP_profile(t,tec_chp,"max",r) =  0.1 * profile(t,"CHP",r)  +  0.9 * (1 - 0.15 * profile(t,"CHP",r));
CHP_profile(t,tec_chp,"min",r) =  0.1 * profile(t,"CHP",r)  +  0.9 * (    0.35 * profile(t,"CHP",r));
CHP_profile(t,"CCGT","max",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (1 - 0.15 * profile(t,"CHP",r));
CHP_profile(t,"CCGT","min",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (    0.75 * profile(t,"CHP",r));
CHP_profile(t,"gCCS","max",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (1 - 0.15 * profile(t,"CHP",r));
CHP_profile(t,"gCCS","min",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (    0.75 * profile(t,"CHP",r));
CHP_profile(t,"CCH2","max",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (1 - 0.15 * profile(t,"CHP",r));
CHP_profile(t,"CCH2","min",r)  =  0.3 * profile(t,"CHP",r)  +  0.7 * (    0.75 * profile(t,"CHP",r));
*                                 Exhaust heat
CHP_profile(t,"OCGT","max",r)  =  1;
CHP_profile(t,"OCGT","min",r)  =  profile(t,"CHP",r);
*                                 Shed
CHP_profile(t,"shed","max",r)  =  1;
CHP_profile(t,"shed","min",r)  =  profile(t,"CHP",r);

$IF %CHP%=='0' CHP_profile(t,tec_chp,"max",r) = 1;
$IF %CHP%=='0' CHP_profile(t,tec_chp,"min",r) = 0;




* Interconnector parameters

km(r,rr)                 = i_km(r,rr);
ACDC(r,rr)               = i_ACDC(r,rr);







* Initial generation capacity

capa0(alltec,vin,r)              = i_capa0(alltec,vin,"%HORIZON%",r);
ntc0(r,rr)                       = i_ntc0(r,"%HORIZON%",rr) / th;

chp0(tec_chp,vin,r)              = i_chp0(tec_chp,vin,"%HORIZON%",r);
chp_tot(r)                       = i_chp_tot("%HORIZON%",r);
// in short-term runs, chp_tot must be euqal to sum((tec_chp,vin),chp0)) - otherwise one must build e-heater to remain feasible
$IF %CHP%=='0'  chp_tot(r)       = 0;


sto0(tec_sto,par_sto,r)          = 0;
sto0("PHS","power",r)            = i_capa0("PHS","1","%HORIZON%",r);
sto0("PHS","energy",r)           = i_energy0("PHS","%HORIZON%",r);




* Ancillary service

as(r)                    = 0.1 * smax(t,load(t,r));
as_vre                   = 0.05;
as_chp                   = 1;
$IF %ASC%=='0'  as(r)    = 0;
$IF %ASC%=='0'  as_vre   = 0;



* Gas price seasonality

fuelseason(t,alltec)     = 1;

$IFi %GASPRICE%=='seasonal'  fuelseason(t,"CCGT")     = sum(t_month_year(t,month_year),i_monthly(month_year,"gasprice"));
$IFi %GASPRICE%=='seasonal'  fuelseason(t,"OCGT")     = sum(t_month_year(t,month_year),i_monthly(month_year,"gasprice"));
$IFi %GASPRICE%=='seasonal'  test3(alltec)            = sum(t,fuelseason(t,alltec)) / card(t);
$IFi %GASPRICE%=='seasonal'  fuelseason(t,alltec)     = fuelseason(t,alltec) / test3(alltec);



* Costs (written to text file to be included in YDIM- and SDIM-files)
$onecho                  > scen\costs.gms

* LTE overrides PROJECT DEFAULT
$IF %PROJECT%%HORIZON%=='DEFAULTLTE'
i_cost("DEFAULT",alltec,par_cost) = i_cost("DEFAULTLTE",alltec,par_cost);

* run through
run_through(tec_mod) = i_cost("%PROJECT%",tec_mod,"rt_premium");
$IF %RUNTHROUGH%=='0'
run_through(tec_mod) = 0;

* quasi-fix costs
cost_qfix(alltec)        = (i_cost("%PROJECT%",alltec,"qfixcost") + run_through(alltec)* (8+2)) / sc;                                                             // 8 to allocate run-through premium to FC, 2 for actual occured start-ups - but what if a plant runs less than 8000 hours!?!?!? - THIS IS A BUG

* fix costs
lifetime(alltec)         = i_cost("%PROJECT%",alltec,"lifetime");
cost_inv(alltec)         = i_cost("%PROJECT%",alltec,"invest") * ((1+discountrate)**lifetime(alltec)*discountrate)/((1+discountrate)**lifetime(alltec)-1) / sc ;  // annualized capital costs from investment costs
cost_fix(alltec)         = cost_qfix(alltec) + cost_inv(alltec);                                                                                      // fix costs comprise capital and quasi-fix costs
cost_bal(tec_vre)        = 4;                                                                                                                         // VRE balancing costs in €/MWh
cost_fix(tec_vre)        = cost_fix(tec_vre) + cost_bal(tec_vre) * sum(t,profile(t,tec_vre,"GER")) / th;                                              // RES balancing costs are added to fix costs -> taken as independent from generation

* flexibility premium to fix and quasi-fix costs
cost_fix(tec_flex)       = cost_fix(tec_flex) * i_cost("%PROJECT%",tec_flex,"flex_premium");                                                                      // revenues from ancillary services and/or capacity markets
cost_qfix(tec_flex)      = cost_qfix(tec_flex) * i_cost("%PROJECT%",tec_flex,"flex_premium");                                                                     // qfix are scaled down as well (not only fix)

* var costs
eff(alltec)              = i_cost("%PROJECT%",alltec,"eff_new");
loop(h_year,
cost_fuel(tec_mod)       = i_fuel(tec_mod,"%PROJECT%",h_year);
$IF %CO2% == 'DATAXLSX'
co2(r)                   = i_co2("ETS","%PROJECT%",h_year);
loop(r,
$IF %CO2% == 'DATAXLSX'
co2(r)$i_co2(r,"%PROJECT%",h_year) = i_co2(r,"%PROJECT%",h_year);
); //end of loop(r,
); //end of loop(h_year,
$IF not %CO2% == 'DATAXLSX'
co2(r)                   = %CO2%;

cost_var(t,tec_mod,"new",r)  = (i_cost("%PROJECT%",tec_mod,"varcost") + (cost_fuel(tec_mod) * fuelseason(t,tec_mod) + i_cost("%PROJECT%",tec_mod,"co2int")*co2(r)) / eff(tec_mod) - run_through(tec_mod)) / th;
cost_var(t,tec_mod,vin,r)$i_eff0(tec_mod,vin) = (i_cost("%PROJECT%",tec_mod,"varcost") + (cost_fuel(tec_mod) * fuelseason(t,tec_mod) + i_cost("%PROJECT%",tec_mod,"co2int")*co2(r)) / i_eff0(tec_mod,vin) - run_through(tec_mod)) / th;

* storage costs
cost_energy(tec_sto)     = i_cost("%PROJECT%",tec_sto,"energy") * ((1+discountrate)**lifetime(tec_sto)*discountrate)/((1+discountrate)**lifetime(tec_sto)-1) / sc;
cost_energy(tec_sto)     = cost_energy(tec_sto) * i_cost("%PROJECT%",tec_sto,"flex_premium");

* NTC costs
cost_NTC                 = 3.4 * ((1+discountrate)**40*discountrate)/((1+discountrate)**40-1) / sc;

$offecho
$include                 scen\costs.gms








* Hydro parameters

* The parameters reservoir, hydro_min, inflow are all defined reltive to installed capacity.


* Reservoir
reservoir(r_h) = i_energy0("reservoir","%HORIZON%",r_h);


* Inflow
* convert monthly inflow pattern to absolute level of inflow per hour
* inflow pattern come from Swedish statistics (sum up to 1)
* constant inflow of 0.4 corresponds to a capacity factor of 0.4
inflow(t,r_h)     = sum(t_month_year(t,month_year),i_monthly(month_year,"inflow_SWE"));

* Scaling to energy0
test1(r_h)        = sum(t,inflow(t,r_h)) * sc;
inflow(t,r_h)     = inflow(t,r_h) * i_gene0("hydr","%PROJECT%","%HORIZON%",r_h) * th / test1(r_h);

* Initial and terminal inflow values
inflow("1",r_h)   = i_energy0("start","%HORIZON%",r_h);
inflow("%HOURS%",r_h)   = - i_energy0("end","%HORIZON%",r_h);

* To ensure feasibility for 100 hours
$IFi %HOURS% == '100' inflow("%HOURS%",r_h)   = - 0.98 * inflow("1",r_h);


* Minimal generation
* Swedish least monthly generation (June 2004)
hydro_min(r_h)    = 0;

* To ensure feasibility for 100 hours
$IFi %HOURS% == '100' hydro_min(r_h)    = 0;

display inflow;


* H2 parameters

h2_price                 =  (2 - 0.1) / 39.4;       // net OPEX in EUR/kWh = MEUR/GWh
h2_eff                   =  21 * 39.4 / th;         // HHV in kWh_H2/kWh_el

* AFC                    = CAPEX * ( annuity factor ...                                           + OPEX%)
h2_invest                =   450 * ( ((1+discountrate)**25*discountrate)/((1+discountrate)**25-1) + 0.02 ) / sc ;      // EUR/kW_el = MEUR/GW_el
h2_invest_stoenergy      =     2 * ( ((1+discountrate)**25*discountrate)/((1+discountrate)**25-1) + 0.02 ) / sc ;      // EUR/kWh_H2 = MEUR/GWh_H2

$IF %H2%=='1' h2_invest_stoenergy = 0;

* WTP                    = (H2 price - OPEX per H2) * Efficiency H2 per MWh_el
h2_dispatch              = h2_price * h2_eff;




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


VARIABLES
INVE(tec_inv,r)           investment                      (GW)
DECO(tec_thm,vin,r)       disinvestments                  (GW)
GENE(t,tec_gen,allvin,r)  generation                      (GW)
CAPACHP(tec_chp,allvin,r) CHP capacity                    (GW)
INVECHP(tec_chp,r)        additional CHP capacity         (GW)
DECOCHP(tec_chp,vin,r)    decomissioned CHP capa          (GW)
FLOW(t,r,rr)              exports from r to rr            (GW)
CHARGE(t,tec_sto,r)       charging of the storage         (GW)
DISCHARGE(t,tec_sto,r)    discharge of the storage        (GW)
SLEVEL(t,tec_sto,r)       storge energy level             (GWh)
STOINV(tec_sto,*,r)       investment in storage           (GW or GWh)
RESERVOIR_V(t,r)          energy in hydro reservoirs      (GWh)
NTCINV(r,rr)              new trans capacity              (GW)
ASC(r)                    ancillary service - must run    (GW)
SPILL(t,r)                spillage of water               (GW)
CURTAIL(t,r)              curtailment of electricity      (GW)
COST                      total system cost               (M€)
H2CAPA(r)                 H2 electrolyzer capacity        (GW)
H2CONS(t,r)               H2 electrolyzer consumption     (GW)
H2SELL(r)                 H2 hydrogen selling             (GWh per year)
H2STOENERGY(r)            H2 storage energy capacity      (GWh)
H2CHARGE(t,r)             H2 storage charging             (GW)
H2DISCHARGE(t,r)          H2 storage discharging          (GW)
H2LEVEL(t,r)              H2 storage level                (GWh)
;


POSITIVE VARIABLES INVE, DECO, GENE, CAPACHP, INVECHP, DECOCHP, EHEAT, CHARGE, DISCHARGE, SLEVEL, STOINV, RESERVOIR_V, NTCINV, ASC, SPILL, CURTAIL,
H2CAPA, H2CONS, H2SELL, H2STOENERGY, H2CHARGE, H2DISCHARGE, H2LEVEL
;

EQUATION E1, C1n, C1v, C2n, C2v, H1, H2, H3, H4, S1, S2, S3, K1, K2, K3n, K3v, K4, K5, F1, F2, F3, F4, O
* C3n, C3v
$IF not %H2%=='0' D1, D2, D3, D4
$IF %ASC%=='1' A1
$IF %ASC%=='1' A2
;




* Energy balance

E1(t,r)..                load_mod(t,r)         =E= sum((tec_inv,allvin),GENE(t,tec_inv,allvin,r)) + GENE(t,"hydr","1",r) - sum(rr,FLOW(t,r,rr)) + sum(tec_sto, DISCHARGE(t,tec_sto,r) - CHARGE(t,tec_sto,r)) - CURTAIL(t,r)
$IF not %H2%=='0'                                - H2CONS(t,r)
;


* Capacity adequacy: VRE & thermal

C1n(t,tec_vre,r)..       GENE(t,tec_vre,"new",r)  =E= profile(t,tec_vre,r) * INVE(tec_vre,r);
C1v(t,tec_vre,vin,r)..   GENE(t,tec_vre, vin ,r)  =E= profile(t,tec_vre,r) * capa0(tec_vre,vin,r);
C2n(t,tec_chp,r)..       GENE(t,tec_chp,"new",r)  =L= avail(t,tec_chp,r)   * (INVE(tec_chp,r)                            - CAPACHP(tec_chp,"new",r) * (1 - CHP_profile(t,tec_chp,"max",r)));
C2v(t,tec_chp,vin,r)..   GENE(t,tec_chp, vin ,r)  =L= avail(t,tec_chp,r)   * (capa0(tec_chp,vin,r) - DECO(tec_chp,vin,r) - CAPACHP(tec_chp,vin,r)   * (1 - CHP_profile(t,tec_chp,"max",r)));
*C3n(t,r)..               GENE(t,"nucl" ,"new",r)  =L= avail(t,"nucl",r)    * INVE("nucl",r);
*C3v(t,vin,r)..           GENE(t,"nucl" , vin ,r)  =L= avail(t,"nucl",r)    * (capa0("nucl",vin,r)  - DECO("nucl",vin,r));


* Hydro power

H1(t,r)..                GENE(t,"hydr","1",r)  =L= capa0("hydr","1",r);
H2(t,r)..                RESERVOIR_V(t,r)      =E= inflow(t,r) + RESERVOIR_V(t-1,r) - GENE(t,"hydr","1",r) - SPILL(t,r);
H3(t,r)..                RESERVOIR_V(t,r)      =L= reservoir(r);
H4(t,r)..                GENE(t,"hydr","1",r)  =G= hydro_min(r) * capa0("hydr","1",r);


* Storage

S1(t,tec_sto,r)..        SLEVEL(t,tec_sto,r)                          =E= SLEVEL(t-1,tec_sto,r) + sqrt(eff(tec_sto)) * CHARGE(t,tec_sto,r) - DISCHARGE(t,tec_sto,r) / sqrt(eff(tec_sto));
S2(t,tec_sto,r)..        CHARGE(t,tec_sto,r) + DISCHARGE(t,tec_sto,r) =L= sto0(tec_sto,"power",r)  + STOINV(tec_sto,"power",r);
S3(t,tec_sto,r)..        SLEVEL(t,tec_sto,r)                          =L= sto0(tec_sto,"energy",r) + STOINV(tec_sto,"energy",r); // + STOINV(tec_sto,"power",r) ;


* Hydrogen

$IF not %H2%=='0' D1(r,t)..      H2CONS(t,r)      =L= H2CAPA(r);
$IF not %H2%=='0' D2(r,t)..      H2SELL(r)        =E= H2CONS(t,r) * h2_eff + H2DISCHARGE(t,r) - H2CHARGE(t,r);
$IF not %H2%=='0' D3(r,t)..      H2LEVEL(t,r)     =E= H2LEVEL("%HOURS%",r)$(ord(t)=1) + H2LEVEL(t-1,r)$(ord(t)>1) + H2CHARGE(t,r) - H2DISCHARGE(t,r);
$IF not %H2%=='0' D4(r,t)..      H2LEVEL(t,r)     =L= H2STOENERGY(r);


* CHP

K1(t,tec_chp,allvin,r).. GENE(t,tec_chp,allvin,r)   =G= CAPACHP(tec_chp,allvin,r) * CHP_profile(t,tec_chp,"min",r) * avail(t,tec_chp,r);  // minimum generation from CHP technologies: CHP profile times CHP capacity - this is NOT the demand-supply balance for heat (which does not exist)
K2(r)..                  chp_tot(r)                 =L= sum((tec_chp,allvin),CAPACHP(tec_chp,allvin,r));                   // total CHP capacity needs to be greater or equal to chp_tot (parameter)
K3n(tec_chp,r)..         CAPACHP(tec_chp,"new",r)   =E= INVECHP(tec_chp,r);                                                               // CHP capacity by technology equals existing + investment
K3v(tec_chp,vin,r)..     CAPACHP(tec_chp,vin,r)     =E= chp0(tec_chp,vin,r) - DECOCHP(tec_chp,vin,r);
K4(tec_chp,r)..          INVECHP(tec_chp,r)         =L= INVE(tec_chp,r);                                                                  // all CHP investment must be part of total investment in that technology
K5(tec_chp,vin,r)..      DECOCHP(tec_chp,vin,r)     =L= DECO(tec_chp,vin,r);                                                              // all CHP dis-investment must be part of total dis-investment of that technology


* Interconnectors

F1(t,r,rr)..       FLOW(t,r,rr)      =E= -FLOW(t,rr,r);
F2(t,r,rr)..       FLOW(t,r,rr)      =L= ntc0(r,rr) + NTCINV(r,rr);
F3(t,rr,r)..       FLOW(t,rr,r)      =L= ntc0(rr,r) + NTCINV(rr,r);
F4(r,rr)..         NTCINV(r,rr)      =E= NTCINV(rr,r);



* Ancillary services

$IF %ASC%=='1' A1(r)..            ASC(r)            =G= as(r) + as_vre * sum(tec_vre, capa0(tec_vre,"1",r) + INVE(tec_vre,r));

$IF %ASC%=='1' A2(t,r)..          ASC(r)            =L= sum((tec_thm,allvin),GENE(t,tec_thm,allvin,r))
$IF %ASC%=='1'                                        - as_chp * sum((tec_chp,allvin),CAPACHP(tec_chp,allvin,r) * CHP_profile(t,tec_chp,"min",r) )
$IF %ASC%=='1'                                        + DISCHARGE(t,"PHS",r) + CHARGE(t,"PHS",r)
$IF %ASC%=='1'                                        + STOINV("batr","power",r)
$IF %ASC%=='1'                                        + GENE(t,"hydr","1",r);


* Total system costs

O..                COST              =E= sum((tec_inv,r),              INVE(tec_inv,r)                                * cost_fix(tec_inv))
                                       - sum((tec_thm,vin,r),          DECO(tec_thm,vin,r)                            * cost_qfix(tec_thm))
                                       + sum((t,tec_thm,allvin,r),     GENE(t,tec_thm,allvin,r)                       * cost_var(t,tec_thm,allvin,r))
                                       + sum((tec_sto,r),              STOINV(tec_sto,"power",r)                      * cost_fix(tec_sto))
                                       + sum((tec_sto,r),              STOINV(tec_sto,"energy",r)                     * cost_energy(tec_sto))
                                       + sum((r,rr),                   NTCINV(r,rr)*km(r,rr)/2                        * cost_ntc)
$IF not %H2%=='0'                      + sum((r),                      H2CAPA(r)                                      * h2_invest)
$IF not %H2%=='0'                      - sum((t,r),                    H2SELL(r)                                      * h2_price)
$IF not %H2%=='0'                      + sum((r),                      H2STOENERGY(r)                                 * h2_invest_stoenergy)
;


MODEL EMMA /all/;




*===============================================================
* b) Constraints
*===============================================================


* HYDROGEN

$IF %H2%=='0' H2CAPA.FX(r)       = 0;
$IF %H2%=='3' H2STOENERGY.FX(r)  = 0;


* NOT SHORTTERM

$onecho                          > scen\shortterm_0.gms

* Relax potential short-term constrains (in case of loops)

INVE.UP(tec_inv,r)               = inf;
DECO.UP(tec_thm,vin,r)           = inf;
STOINV.UP(tec_sto,par_sto,r)     = inf;

* NTC investment only for long-term equilibrium
NTCINV.FX(r,rr)                  = 0;
INVE.UP("shed",r)                = inf;
$IFi %HORIZON% == 'LTE'  NTCINV.UP(r,rr)                  = inf;

* Limit decomissioning to initial capacity

DECO.UP(tec_thm,vin,r)           = capa0(tec_thm,vin,r);

* No PHS investment in non-hydro regions

STOINV.FX("PHS",par_sto,r)$(not r_p(r)) = 0;

* Fix interconnector variables for region-pairs that have no border

NTCINV.FX(r,rr)            $(not km(r,rr)) = 0;
NTCINV.FX(rr,r)            $(not km(rr,r)) = 0;
FLOW.FX(t,r,rr)            $(not km(r,rr)) = 0;  // Performance constraint
FLOW.FX(t,rr,r)            $(not km(rr,r)) = 0;  // Performance constraint

$offecho


* SHORTTERM

$onecho                          > scen\shortterm_1.gms
INVE.FX(tec_inv,r)               = 0;
DECO.FX(tec_thm,vin,r)           = 0;
STOINV.FX(tec_sto,par_sto,r)     = 0;
NTCINV.FX(r,rr)                  = 0;
INVE.UP("shed",r)                = inf;
$offecho

$include  scen\shortterm_%SHORTTERM%.gms





*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~7 SOLVE (OPTIONS, STARTING VALUES)
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

loop((s,y),



* Include scenario files

$include scen\h_%HORIZON%.gms
$include scen\y_%YDIM%.gms
$include scen\s_%SDIM%.gms



* Write solver option files

$echo lpmethod=0 >cplex.opt
$echo lpmethod=1 >cplex.op2
$echo lpmethod=2 >cplex.op3
$echo lpmethod=3 >cplex.op4
$echo lpmethod=4 >cplex.op5
$echo lpmethod=5 >cplex.op6
$onecho >cplex.op7
lpmethod=6
names=0
memoryemphasis=1
datacheck=2
$offecho

$onecho > cplex.op8
lpmethod=1
ppriind=1
$offecho

$onecho > cplex.op9
lpmethod=1
ppriind=1
advind=1
$offecho

$onecho > cplex.o10
tuning tuning-result.txt
$offecho



* Options

EMMA.holdfixed=1;                 // this should save memory
EMMA.solvelink=0;                 // this should save memory
EMMA.dictfile=0;                  // this should save memory
EMMA.optfile=%OPTFILE%;           // choose the option file
EMMA.reslim=50000;                // limits solving time to 14h
EMMA.savepoint=2;                 // saves bases for every solve

EMMA.limrow=0;                    // reduces the size of the listing file
EMMA.limcol=0;                    // reduces the size of the listing file
EMMA.solprint=0;                  // reduces the size of the listing file

EMMA.threads=%THREADS%;


display cost_fuel, cost_qfix, cost_fix, cost_var, eff, avail, load, yload, profile, capa0, chp0, ntc0, i_FLH, inflow, co2, export, CHP_profile;


SOLVE EMMA USING LP minimizing COST;


display INVE.L, DECO.L, GENE.L, STOINV.L, CURTAIL.L, FLOW.L, chp_tot, E1.M, CAPACHP.L, SLEVEL.L;


*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~8 REPORTING
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------




*===============================================================
* a) Outcome paremeters (o_*)
*===============================================================


* By technology, time step, and region

o_gene_vin(t,tec_gen,allvin,r)                   = GENE.L(t,tec_gen,allvin,r);
o_gene(t,tec_mod,r)                              = sum(allvin,o_gene_vin(t,tec_mod,allvin,r));
o_gene(t,tec_exo,r)                              = gene_exo(t,tec_exo,r);
o_gene(t,tec_sto,r)                              = DISCHARGE.L(t,tec_sto,r) - CHARGE.L(t,tec_sto,r);       // Storage: net generation
o_p(t,r)                                         = -E1.M(t,r);
o_margin(t,tec_gen,r)                            = o_p(t,r)-cost_var(t,tec_gen,"new",r);                                        //Todo: vintage
o_flow(t,r,rr)                                   = FLOW.L(t,r,rr);
o_export(t,r)                                    = sum(rr,o_flow(t,r,rr)) + export(t,r);
o_h2_cons(t,r)                                   = 0;
$IF not %H2%=='0' o_h2_cons(t,r)                 = H2CONS.L(t,r);

* By vintage and aggregated vintages

o_capa0(alltec,r)                                = sum(vin,capa0(alltec,vin,r));
o_inve(tec_inv,r)                                = INVE.L(tec_inv,r);
o_deco_vin(tec_thm,vin,r)                        = DECO.L(tec_thm,vin,r);
o_deco(tec_thm,r)                                = sum(vin,o_deco_vin(tec_thm,vin,r));
o_chp0(tec_chp,r)                                = sum(vin,chp0(tec_chp,vin,r));
o_invechp(tec_chp,r)                             = INVECHP.L(tec_chp,r);
o_decochp_vin(tec_chp,vin,r)                     = DECOCHP.L(tec_chp,vin,r);
o_decochp(tec_chp,r)                             = sum(vin,o_decochp_vin(tec_chp,vin,r));
o_stoinv(tec_sto,"power",r)                      = STOINV.L(tec_sto,"power",r);
o_stoinv(tec_sto,"energy",r)                     = STOINV.L(tec_sto,"energy",r);

* By technology and region (yearly values)

o_capa(tec_gen,r)                                = o_inve(tec_gen,r) + o_capa0(tec_gen,r) - o_deco(tec_gen,r);
o_capa("hydr",r)                                 = o_capa0("hydr",r);
o_capa(tec_sto,r)                                = sto0(tec_sto,"power",r) + STOINV.L(tec_sto,"power",r);
o_capa(tec_exo,r)                                = o_capa0(tec_exo,r);                                    // needs to be "i" because of long-run runs -> This is now treated in the LTE scenario include file
o_capa("CHP",r)                                  = sum((tec_chp,allvin),CAPACHP.L(tec_chp,allvin,r));
o_capa("VRE",r)                                  = sum(tec_vre,o_capa(tec_vre,r));
o_capa("firm",r)                                 = sum(alltec,o_capa(alltec,r)) - o_capa("VRE",r);
o_capa(alltec,"all")                             = sum(r,o_capa(alltec,r));

o_ygene_vin(tec_mod,allvin,r)                    = sum(t,o_gene_vin(t,tec_mod,allvin,r)) / th * sc;
o_ygene(alltec,r)                                = sum(t,o_gene(t,alltec,r)) / th * sc;
o_ygene("CHP",r)                                 = sum((tec_chp,allvin,t), CAPACHP.L(tec_chp,allvin,r) * profile(t,"CHP",r) ) * sc / th;
o_ygene("VRE",r)                                 = sum(tec_vre,o_ygene(tec_vre,r));
o_ygene("RE",r)                                  = sum(tec_re,o_ygene(tec_re,r));
o_ygene("thermal",r)                             = sum(tec_thm,o_ygene(tec_thm,r));
o_ygene("all",r)                                 = sum(alltec,o_ygene(alltec,r));

o_ygene(alltec,"all")                            = sum(r,o_ygene(alltec,r));
o_ygene("CHP","all")                             = sum(r,o_ygene("CHP",r));
o_ygene("VRE","all")                             = sum(r,o_ygene("VRE",r));
o_ygene("thermal","all")                         = sum(r,o_ygene("thermal",r));

o_yinflow(r)                                     = o_capa("hydr",r) * sum(t,inflow(t,r)) / th * sc;
o_cost(tec_gen,r)                                = (o_inve(tec_gen,r)*cost_fix(tec_gen) + (o_capa0(tec_gen,r) - o_deco(tec_gen,r))*cost_qfix(tec_gen)) * sc;
o_cost("hydr",r)                                 = o_capa0("hydr",r)*cost_qfix("hydr") * sc;      // *2
o_cost(tec_thm,r)                                = o_cost(tec_thm,r) + sum((t,allvin),GENE.L(t,tec_thm,allvin,r)*cost_var(t,tec_thm,allvin,r)) * sc;
o_cost(tec_sto,r)                                = o_cost(tec_sto,r) + STOINV.L(tec_sto,"energy",r) * cost_energy(tec_sto) * sc;    // revise?
o_LEC(tec_gen,r)$o_ygene(tec_gen,r)              = o_cost(tec_gen,r) / o_ygene(tec_gen,r);

o_cost_components("varcost",tec_thm,r)           = sum((t,allvin),GENE.L(t,tec_thm,allvin,r)*(cost_var(t,tec_thm,allvin,r)+run_through(tec_thm)/th)) * sc;
o_cost_components("prodcost",tec_thm,r)          = o_cost_components("varcost",tec_thm,r);
o_cost_components("prodcost","shed",r)           = 0;
o_cost_components("invcost",tec_gen,r)           = o_inve(tec_gen,r)*cost_inv(tec_gen) * sc;

o_h2_capa(r)                                     = 0;
$IF not %H2%=='0' o_h2_capa(r)                   = H2CAPA.L(r);
o_h2_capa("all")                                 = sum(r,o_h2_capa(r));
o_h2_sto_energy(r)                               = 0;
$IF %H2BASE%=='1' o_h2_sto_energy(r)             = H2STOENERGY.L(r) / th * sc;
o_h2_sto_energy("all")                           = sum(r,o_h2_sto_energy(r));
o_h2_ycons(r)                                    = sum(t,o_h2_cons(t,r)) / th * sc;
o_h2_ycons("all")                                = sum(r,o_h2_ycons(r));
o_h2_flh(rall)$o_h2_capa(rall)                   = o_h2_ycons(rall) / o_h2_capa(rall) * th / sc;


* By region (yearly values)

o_bp(r)                                          = sum(t,o_p(t,r)) / card(t) * th;
o_lp(r)                                          = sum(t,o_p(t,r) * load(t,r)) / sum(t,load(t,r)) * th;
o_pp(r)                                          = sum(t$t_peak(t,"p"), o_p(t,r)) / sum(t$t_peak(t,"p"), 1) * th;
o_op(r)                                          = sum(t$t_peak(t,"op"),o_p(t,r)) / sum(t$t_peak(t,"op"),1) * th;
o_gen(r)                                         = sum(tec_gen,o_ygene(tec_gen,r));
o_CO2_vin(tec_gen,vin,r)$i_eff0(tec_gen,vin)     = o_ygene_vin(tec_gen,vin,r) / i_eff0(tec_gen,vin) * i_cost("%PROJECT%",tec_gen,"co2int");
o_CO2_vin(tec_gen,"new",r)                       = o_ygene_vin(tec_gen,"new",r) / eff(tec_gen) * i_cost("%PROJECT%",tec_gen,"co2int");
o_CO2(r)                                         = sum((tec_gen,allvin),o_CO2_vin(tec_gen,allvin,r));
o_cur(r)                                         = sum(t,CURTAIL.L(t,r)) * sc / th;
o_ASp(r)                                         = eps;
$IF %ASC%=='1'
o_ASp(r)                                         = A1.M(r) * sc;

yload("all")                                     = sum(r,yload(r));
o_bp("all")                                      = sum(r,yload(r) * o_bp(r)) / sum(r,yload(r));
o_lp("all")                                      = sum(r,yload(r) * o_lp(r)) / sum(r,yload(r));
o_gen("all")                                     = sum(r,o_gen(r));
o_CO2("all")                                     = sum(r,o_CO2(r));
o_cur("all")                                     = sum(r,o_cur(r));



* Sum of all regions (hourly resolution) -> convert into "all" to save notation (to do)

o_rload(t)                                       = sum(r,yload(r));
o_rprice(t)                                      = sum(r,(o_p(t,r)*load(t,r))) / sum(r,load(t,r));
o_rgene(t,alltec)                                = sum(r,o_gene(t,alltec,r));
o_rinflow(t)                                     = sum(r,o_yinflow(r));
o_rreservoir(t)                                  = sum(r,RESERVOIR_V.L(t,r)) / th ;



* By technology and region (again)

o_share(alltec,r)                                = o_ygene(alltec,r) / yload(r) * 100;
o_share(alltec,"all")                            = sum(r,o_ygene(alltec,r)) / sum(r,yload(r)) * 100;



* Revenues

o_revS(alltec,r)                                 = sum(t,o_gene(t,alltec,r) * o_p(t,r)) * sc;
o_revH(alltec,r)                                 = eps;
o_revH(tec_chp,r)                                = - sum(allvin,CAPACHP.L(tec_chp,allvin,r)) * K2.M(r) * sc;                // CHECK EQUATION NUMBER
o_revA(alltec,r)                                 = eps;
$IF %ASC%=='1'
o_revA(tec_mod,r)                                = sum(t,o_gene(t,tec_mod,r) * (-A2.M(t,r))) * sc;
$IF %ASC%=='1'
o_revA(tec_chp,r)                                = sum(t,(o_gene(t,tec_chp,r) - sum(allvin,CAPACHP.L(tec_chp,allvin,r))*profile(t,"CHP",r)) * (-A2.M(t,r))) * sc;
$IF %ASC%=='1'
o_revA(tec_sto,r)                                = sum(t,(eff(tec_sto) * o_gene(t,tec_sto,r) + CHARGE.L(t,tec_sto,r)) * (-A2.M(t,r))) * sc;
*o_revA(tec_vre,r)                                = - A1.M(r) * as_vre * (o_capa0(tec_vre,r) + o_inve(tec_vre,r)) * sc;
o_rev(alltec,r)                                  = o_revS(alltec,r) + o_revH(alltec,r)+ o_revA(alltec,r);
o_rev(tec_vre,r)                                 = o_rev(tec_vre,r) - cost_bal(tec_vre) * o_ygene(tec_vre,r);




* Market value and value factor

o_mv(alltec,r)$o_ygene(alltec,r)              = o_rev(alltec,r)  / o_ygene(alltec,r);
o_mvS(alltec,r)$o_ygene(alltec,r)             = o_revS(alltec,r) / o_ygene(alltec,r);
o_vf(alltec,r)$o_bp(r)                        = o_mv(alltec,r) / o_bp(r);
o_vfS(alltec,r)$o_bp(r)                       = o_mvS(alltec,r) / o_bp(r);

o_mv(alltec,"all")$o_ygene(alltec,"all")      = sum(r,o_mv(alltec,r)      *o_ygene(alltec,r)) / o_ygene(alltec,"all");
o_mvS(alltec,"all")$o_ygene(alltec,"all")     = sum(r,o_mvS(alltec,r)     *o_ygene(alltec,r)) / o_ygene(alltec,"all");
o_vf(alltec,"all")$o_ygene(alltec,"all")      = sum(r,o_vf(alltec,r)      *o_ygene(alltec,r)) / o_ygene(alltec,"all");
o_vfS(alltec,"all")$o_ygene(alltec,"all")     = sum(r,o_vfS(alltec,r)     *o_ygene(alltec,r)) / o_ygene(alltec,"all");


display o_mv, o_vf;


* Values (o_val)

o_val(r,s,y,"Gen Costs")                         = sum(alltec,o_cost(alltec,r)) / th                                                         +eps;
o_val(r,s,y,"Gen Costs w sunk")                  = sum(alltec,o_cost(alltec,r)) / th + sum(alltec,o_capa0(alltec,r)*cost_inv(alltec))*sc/th +eps;
o_val(r,s,y,"IC cost")                           = sum(rr, NTCINV.L(r,rr)            * km(r,rr)) / 2 * cost_ntc / th * sc                    +eps;
o_val(r,s,y,"IC cost w sunk")                    = sum(rr,(NTCINV.L(r,rr)+ntc0(r,rr)) * km(r,rr)) / 2 * cost_ntc / th * sc                   +eps;
o_val(r,s,y,"Gen Costs RES")                     = sum(tec_vre,o_cost(tec_vre,r)) / th                                                       +eps;
o_val(r,s,y,"Gen Costs RES w sunk")              =(sum(tec_vre,o_cost(tec_vre,r) + o_capa0(tec_vre,r)*cost_inv(tec_vre))) / th               +eps;
o_val(r,s,y,"Gen Costs w/o CO2")                 = (sum(alltec,o_cost(alltec,r)) - o_CO2(r) * co2(r)) / th                                      +eps;

o_val(r,s,y,"Spot Expenses")                     = sum(t,o_p(t,r)*load_mod(t,r)) * sc / th                                                   +eps;
o_val(r,s,y,"Spot Income")                       = sum(alltec,o_revS(alltec,r)) / th                                                         +eps;
o_val(r,s,y,"AS Income")                         = sum(alltec,o_revA(alltec,r)) / th                                                         +eps;
o_val(r,s,y,"Heat Income")                       = sum(alltec,o_revH(alltec,r)) / th                                                         +eps;

o_val(r,s,y,"Sunk gen cost")                     = sum(alltec,o_capa0(alltec,r)*cost_inv(alltec)) / th * sc                                  +eps;
o_val(r,s,y,"Sunk IC cost")                      = sum(rr,ntc0(r,rr) * km(r,rr)) / 2 * cost_ntc / th * sc                                    +eps;
o_val(r,s,y,"Conv Rent - sunk cost")             = o_val(r,s,y,"Conv Rent") - o_val(r,s,y,"Sunk conv gen cost")                              +eps;
o_val(r,s,y,"RES tax")                           =-sum(tec_vre,o_rev(tec_vre,r)-o_cost(tec_vre,r)) / th                                      +eps;
o_val(r,s,y,"CO2 revenue")                       = o_CO2(r) * co2(r) / th                                                                       +eps;

o_val(r,s,y,"Consumer Rent")                     = 100 - o_val(r,s,y,"Spot Expenses") - o_val(r,s,y,"AS Income") - o_val(r,s,y,"Heat Income") - o_val(r,s,y,"IC cost");
o_val(r,s,y,"Producer Rent")                     = o_val(r,s,y,"Conv Rent");
o_val(r,s,y,"State Revenue")                     = o_val(r,s,y,"CO2 revenue") - o_val(r,s,y,"RES tax");
o_val(r,s,y,"Economic Welfare")                  = o_val(r,s,y,"Consumer Rent") + o_val(r,s,y,"Producer Rent") + o_val(r,s,y,"State Revenue");



*===============================================================
* b) Outcome paremeters with s-dimension (s_*)
*===============================================================

s_p(s,t,allr)                    = o_p(t,allr);
s_bp(s,rall)                     = o_bp(rall);
s_gene(s,t,alltec,r)             = o_gene(t,alltec,r);
s_flow(s,t,r,rr)                 = o_flow(t,r,rr);
s_export(s,t,r)                  = o_export(t,r);
s_CO2(s,rall)                    = o_CO2(rall);
s_cost(s,alltec,r)               = o_cost(alltec,r);
s_capa(s,alltec,rall)            = o_capa(alltec,rall);
s_inve(s,tec_gen,r)              = o_inve(tec_gen,r);
s_deco(s,tec_gen,r)              = o_deco(tec_gen,r);
s_stoinv(s,tec_sto,"power",r)   = o_stoinv(tec_sto,"power",r);
s_stoinv(s,tec_sto,"energy",r)  = o_stoinv(tec_sto,"energy",r);

s_cost_components(s,"prodcost",alltec,r)  = o_cost_components("prodcost",alltec,r);
s_cost_components(s,"varcost",alltec,r)   = o_cost_components("varcost",alltec,r);
s_cost_components(s,"invcost",alltec,r)   = o_cost_components("invcost",alltec,r);


*===============================================================
* c) Reporting parameters: Overall System (r_s)
*===============================================================

r_s("TWh","Demand"                       ,s,y)   = yload("all")                                                                         +eps;
r_s("€/MWh","Base Price"                 ,s,y)   = o_bp("all")                                                                          +eps;
r_s("€/MWh","Load Price"                 ,s,y)   = o_lp("all")                                                                          +eps;

r_s("G€/a","Total Sys Cost"              ,s,y)   = COST.L / th* sc                                                                      +eps;
r_s("G€/a","Total Sys Cost w sunk"       ,s,y)   =(COST.L + sum((alltec,r),o_capa0(alltec,r)*cost_inv(alltec)) + sum((r,rr),+ntc0(r,rr)*km(r,rr))/2*cost_ntc) / th * sc +eps;

r_s("G€/a",var_o_val                     ,s,y)   = sum(r,o_val(r,s,y,var_o_val))                                                        +eps;
r_s("€/MWh",var_val                      ,s,y)   = r_s("G€/a",var_val,s,y) / sum(r,yload(r)) * th                                       +eps;

r_s("RES","Solar share"                  ,s,y)   = o_share("solar","all")                                                               +eps;
r_s("RES","Solar MV all"                 ,s,y)   = o_mv("solar","all")                                                                  +eps;
r_s("RES","Solar VF all"                 ,s,y)   = o_vf("solar","all")                                                                  +eps;
r_s("RES","Wind onshore share"           ,s,y)   = o_share("wion","all")                                                                +eps;
r_s("RES","Wind onshore MV all"          ,s,y)   = o_mv("wion","all")                                                                   +eps;
r_s("RES","Wind onshore VF all"          ,s,y)   = o_vf("wion","all")                                                                   +eps;
r_s("RES","Wind offshore share"          ,s,y)   = o_share("wiof","all")                                                                +eps;
r_s("RES","Wind offshore MV all"         ,s,y)   = o_mv("wiof","all")                                                                   +eps;
r_s("RES","Wind offshore VF all"         ,s,y)   = o_vf("wiof","all")                                                                   +eps;

r_s("€/t","CO2 price"                    ,s,y)   = sum(r,co2(r)) / card(r)                                                              +eps;
r_s("t","CO2 emissions"                  ,s,y)   = o_CO2("all")                                                                         +eps;
r_s("GW NTC","New IC capacity"           ,s,y)   = sum((r,rr),NTCINV.L(r,rr)) / 2                                                       +eps;
r_s("TWh_RES","RES Curtailment"          ,s,y)   = o_cur("all")                                                                         +eps;
r_s("% RES","RES Curtailment %"          ,s,y)   $o_ygene("VRE","all") = o_cur("all") / o_ygene("VRE","all") * 100                      +eps;
r_s("€/MWh_th","Thermal gen costs"       ,s,y)   = sum((tec_thm,r),o_cost(tec_thm,r)) / o_ygene("thermal","all")                        +eps;


r_s("€/MWh_RES","RES LCOE"               ,s,y)   $o_ygene("VRE","all")    = sum((tec_vre,r),o_cost(tec_vre,r)) / o_ygene("VRE","all")                       +eps;
r_s("€/MWh_RES","RES LCOE w curtail"     ,s,y)   $o_ygene("VRE","all")    = sum((tec_vre,r),o_cost(tec_vre,r)) /(o_ygene("VRE","all") - o_cur("all"))       +eps;
test2$(ord(y)=1) =  COST.L / th* sc;
r_s("€/MWh_RES","RES System costs"       ,s,y)   $o_ygene("VRE","all")    = ((COST.L / th * sc) - test2) / (o_ygene("VRE","all") - o_cur("all")) * th       +eps;
r_s("€/MWh_RES","RES System LCOE"        ,s,y)   = r_s("€/MWh_RES","RES LCOE w curtail",s,y) + r_s("€/MWh_RES","RES System costs",s,y)                      +eps;

r_s("Inst Capa",alltec                   ,s,y)   = sum(r,o_capa(alltec,r))                                                              +eps;
r_s("Inst Capa",alltec       ,"today","today")   = sum((r,vin,today),i_capa0(alltec,vin,today,r))                               +eps;
r_s("Generation",alltec                  ,s,y)   = sum(r,o_ygene(alltec,r))                                                             +eps;




*===============================================================
* d) Country-specific (r_r, r_r2, r_vf, r_capa, r_capa2, r_ms, r_gene)
*===============================================================


* Country Summary (r_r)

r_r(r,"Demand","TWh",s,y)                        = yload(r)                                                              +eps;

r_r(r,"Base Price","€/MWh",s,y)                  = o_bp(r)                                                               +eps;
r_r(r,"Peak Price","€/MWh",s,y)                  = o_pp(r)                                                               +eps;
r_r(r,"Off-Peak Price","€/MWh",s,y)              = o_op(r)                                                               +eps;
r_r(r,"Load Price","€/MWh",s,y)                  = o_lp(r)                                                               +eps;
r_r(r,"Scarcity Price","€/MWh",s,y)              = smax(t,o_p(t,r)) * th                                                 +eps;
r_r(r,"P-to-OP","1",s,y)                         = o_pp(r) / o_op(r)                                                     +eps;
r_r(r,"# zero prices","1",s,y)                   = sum(t$(o_p(t,r)*th<1),1) * sc                                         +eps;
r_r(r,"# scarcity prices","1",s,y)               = sum(t$(o_p(t,r)*th=r_r(r,"Scarcity Price","€/MWh",s,y)),1) * sc       +eps;

r_r(r,"RES subsidy","G€",s,y)                    = sum(tec_vre,o_cost(tec_vre,r) - o_rev(tec_vre,r)) / th                +eps;
r_r(r,"RES subsidy","€/MWh",s,y)$o_ygene("VRE",r)= sum(tec_vre,o_cost(tec_vre,r) - o_rev(tec_vre,r)) / o_ygene("VRE",r)  +eps;
r_r(r,"VRE share","%",s,y)                       = sum(tec_vre,o_share(tec_vre,r))                                       +eps;
r_r(r,"hydr share","%",s,y)                      = o_share("hydr",r)                                                     +eps;
r_r(r,"ror share","%",s,y)                       = o_share("ror",r)                                                      +eps;
r_r(r,"bio share","%",s,y)                       = o_share("bio",r)                                                      +eps;
r_r(r,"Curtailment share (neg)","%",s,y)         = - o_cur(r) / yload(r) * 100                                           +eps;
r_r(r,"RE share post curtailment","%",s,y)       = sum(tec_re,o_share(tec_re,r))  - (o_cur(r) / yload(r) * 100)          +eps;

r_r(r,"s cap","GW",s,y)                          = o_capa("solar",r)                                                     +eps;
r_r(r,"s share","%",s,y)                         = o_share("solar",r)                                                    +eps;
r_r(r,"s spot p","€/MWh",s,y)$o_ygene("solar",r) = o_revS("solar",r) / o_ygene("solar",r)                                +eps;
r_r(r,"s bal cost","€/MWh",s,y)$o_ygene("solar",r)= - o_revA("solar",r) / o_ygene("solar",r) + cost_bal("solar")         +eps;
r_r(r,"s mkt val","€/MWh",s,y)                   = o_mv("solar",r)                                                       +eps;
r_r(r,"s LEC","€/MWh",s,y)                       = o_LEC("solar",r)                                                      +eps;
r_r(r,"s value factor","1",s,y)                  = o_vf("solar",r)                                                       +eps;

r_r(r,"wion cap","GW",s,y)                           = o_capa("wion",r)                                                  +eps;
r_r(r,"wion share","%",s,y)                          = o_share("wion",r)                                                 +eps;
r_r(r,"wion spot p","€/MWh",s,y)$o_ygene("wion",r)   = o_revS("wion",r) / o_ygene("wion",r)                              +eps;
r_r(r,"wion bal cost","€/MWh",s,y)$o_ygene("wion",r) = - o_revA("wion",r) / o_ygene("wion",r) + cost_bal("wion")         +eps;
r_r(r,"wion mkt val","€/MWh",s,y)                    = o_mv("wion",r)                                                    +eps;
r_r(r,"wion LEC","€/MWh",s,y)                        = o_LEC("wion",r)                                                   +eps;
r_r(r,"wion value factor","1",s,y)                   = o_vf("wion",r)                                                    +eps;

r_r(r,"wiof cap","GW",s,y)                           = o_capa("wiof",r)                                                  +eps;
r_r(r,"wiof share","%",s,y)                          = o_share("wiof",r)                                                 +eps;
r_r(r,"wiof spot p","€/MWh",s,y)$o_ygene("wion",r)   = o_revS("wiof",r) / o_ygene("wiof",r)                              +eps;
r_r(r,"wiof bal cost","€/MWh",s,y)$o_ygene("wion",r) = - o_revA("wiof",r) / o_ygene("wiof",r) + cost_bal("wiof")         +eps;
r_r(r,"wiof mkt val","€/MWh",s,y)                    = o_mv("wiof",r)                                                    +eps;
r_r(r,"wiof LEC","€/MWh",s,y)                        = o_LEC("wiof",r)                                                   +eps;
r_r(r,"wiof value factor","1",s,y)                   = o_vf("wiof",r)                                                    +eps;

r_r(r,"curtailment","TWh",s,y)                   = o_cur(r)                                                              +eps;
r_r(r,"CO2 price_r","€/t",s,y)                   = co2(r)                                                                +eps;
r_r(r,"CHP MR share","%",s,y)                    = o_ygene("CHP",r) / yload(r) * 100                                     +eps;
r_r(r,"exist exp cap","GW",s,y)                  = sum(rr,ntc0(r,rr))                                                    +eps;
r_r(r,"new exp cap","GW",s,y)                    = sum(rr,NTCINV.L(r,rr))                                                +eps;
r_r(r,"net exports","TWh",s,y)                   = sum(t,o_export(t,r)) / th * sc                                        +eps;  // this includes exogenous flows
r_r(r,"gross imports","TWh",s,y)                 = - sum((t,rr) $(o_flow(t,r,rr) lt 0),o_flow(t,r,rr)) / th * sc         +eps;  // only endogenous
r_r(r,"gross exports","TWh",s,y)                 = sum((t,rr) $(o_flow(t,r,rr) gt 0),o_flow(t,r,rr)) / th * sc           +eps;  // only endogenous
r_r(r,"IC util","%",s,y)$sum(rr,ntc0(r,rr))      = ((sum((t,rr)$(o_flow(t,r,rr)>0),o_flow(t,r,rr)) / (sum(rr,ntc0(r,rr)+NTCINV.L(r,rr))*card(t))) + (sum((t,rr)$(o_flow(t,r,rr)>0),o_flow(t,r,rr)) / (sum(rr,ntc0(rr,r)+NTCINV.L(rr,r))*card(t)))) * 100 + eps;
r_r(r,"Pri AS MR","€/KW*a",s,y)                  = o_ASp(r)                                                              +eps;
r_r(r,"CO2 emissions_r","Mt",s,y)                = o_CO2(r)                                                              +eps;


r_r2(r,var_o_val,s,y)                            = o_val(r,s,y,var_o_val) / yload(r) * th;



* Capacity - by YDIM (r_capa)

r_capa(r,alltec,s,y)                             = o_capa(alltec,r)                                                      +eps;

r_capa(r,"CHP must-run",s,y)                     = o_capa("CHP",r)                                                       +eps;
r_capa(r,"dispatchable",s,y)                     = sum(alltec,o_capa(alltec,r)) - o_capa("VRE",r) - o_capa("CHP",r)      +eps;
r_capa(r,"VRE",s,y)                              = o_capa("VRE",r)                                                       +eps;
*r_capa(r,"base load",s,y)                        = o_capa("nucl",r) + o_capa("cCCS",r) + o_capa("lign",r)                +eps;
*r_capa(r,"mid load",s,y)                         = o_capa("coal",r) + o_capa("CCGT",r)                                   +eps;
*r_capa(r,"peak load",s,y)                        = o_capa("OCGT",r) + o_capa("shed",r)                                   +eps;
r_capa(r,"hydro total",s,y)                      = o_capa("PHS",r) + o_capa("hydr",r) + o_capa("ror",r)                  +eps;
*r_capa(r,"base load share",s,y)                  = r_capa(r,"base load",s,y)    / o_capa("firm",r)                       +eps;
*r_capa(r,"mid load share",s,y)                   = r_capa(r,"mid load",s,y)     / o_capa("firm",r)                       +eps;
*r_capa(r,"peak load share",s,y)                  = r_capa(r,"peak load",s,y)    / o_capa("firm",r)                       +eps;
r_capa(r,"hydro share",s,y)                      = r_capa(r,"hydro total",s,y)  / o_capa("firm",r)                       +eps;
r_capa(r,alltec,"today","today")                 = sum((vin,today),i_capa0(alltec,vin,today,r))                  +eps;
r_capa("all",alltec,s,y)                         = o_capa(alltec,"all")                                                  +eps;
r_capa("all",alltec,"today","today")             = sum(r,r_capa(r,alltec,"today","today"))                               +eps;



* Capacity - by SDIM (r_capa2)

r_capa2(r,alltec,y,s)                            = r_capa(r,alltec,s,y)                                                  +eps;
r_capa2(r,"CHP must-run",y,s)                    = r_capa(r,"CHP must-run",s,y)                                          +eps;
r_capa2(r,"dispatchable",y,s)                    = r_capa(r,"dispatchable",s,y)                                          +eps;
r_capa2(r,"VRE",y,s)                             = r_capa(r,"VRE",s,y)                                                   +eps;
*r_capa2(r,"base load",y,s)                       = r_capa(r,"base load",s,y)                                             +eps;
*r_capa2(r,"mid load",y,s)                        = r_capa(r,"mid load",s,y)                                              +eps;
*r_capa2(r,"peak load",y,s)                       = r_capa(r,"peak load",s,y)                                             +eps;
r_capa2(r,"hydro",y,s)                           = r_capa(r,"hydro total",s,y)                                           +eps;
*r_capa2(r,"base load share",y,s)                 = r_capa(r,"base load share",s,y)                                       +eps;
*r_capa2(r,"mid load share",y,s)                  = r_capa(r,"mid load share",s,y)                                        +eps;
*r_capa2(r,"peak load share",y,s)                 = r_capa(r,"peak load share",s,y)                                       +eps;
r_capa2(r,"hydro share",y,s)                     = r_capa(r,"hydro share",s,y)                                           +eps;
r_capa2("all",alltec,y,s)                        = r_capa("all",alltec,s,y)                                              +eps;
r_capa2(r,alltec,"today","today")                = r_capa(r,alltec,"today","today")                                      +eps;



* Generation (r_gene)

r_gene(r,alltec,s,y)                             = o_ygene(alltec,r)                                                     +eps;
r_gene(r,"CHP must-run",s,y)                     = o_ygene("CHP",r)                                                      +eps;
r_gene(r,"dispatchable",s,y)                     = sum(alltec,o_ygene(alltec,r)) - o_ygene("VRE",r) - o_ygene("CHP",r)   +eps;
r_gene(r,"RE",s,y)                               = o_ygene("RE",r)                                                       +eps;
r_gene(r,"VRE",s,y)                              = o_ygene("VRE",r)                                                      +eps;
r_gene(r,"curtail",s,y)                          = o_cur(r)                                                              +eps;
r_gene(r,"demand",s,y)                           = yload(r)                                                              +eps;
*r_gene(r,"base load",s,y)                        = o_ygene("nucl",r) + o_ygene("cCCS",r) + o_ygene("lign",r)             +eps;
*r_gene(r,"mid load",s,y)                         = o_ygene("coal",r) + o_ygene("CCGT",r)                                 +eps;
*r_gene(r,"peak load",s,y)                        = o_ygene("OCGT",r) + o_ygene("shed",r)                                 +eps;
r_gene(r,"hydro total",s,y)                      = o_ygene("PHS",r) + o_ygene("hydr",r) + o_ygene("ror",r)               +eps;
*r_gene(r,"base load share",s,y)                  = r_gene(r,"base load",s,y)    / o_ygene("all",r)                       +eps;
*r_gene(r,"mid load share",s,y)                   = r_gene(r,"mid load",s,y)     / o_ygene("all",r)                       +eps;
*r_gene(r,"peak load share",s,y)                  = r_gene(r,"peak load",s,y)    / o_ygene("all",r)                       +eps;
r_gene(r,"hydro share",s,y)                      = r_gene(r,"hydro total",s,y)  / o_ygene("all",r)                       +eps;
r_gene("all",alltec,s,y)                         = o_ygene(alltec,"all")                                                 +eps;




* Generation - by SDIM (r_gene2)

r_gene2(r,alltec,y,s)                            = r_gene(r,alltec,s,y)                                                  +eps;
r_gene2(r,"CHP must-run",y,s)                    = r_gene(r,"CHP must-run",s,y)                                          +eps;
r_gene2(r,"dispatchable",y,s)                    = r_gene(r,"dispatchable",s,y)                                          +eps;
r_gene2(r,"RE",y,s)                              = r_gene(r,"RE",s,y)                                                    +eps;
r_gene2(r,"VRE",y,s)                             = r_gene(r,"VRE",s,y)                                                   +eps;
*r_gene2(r,"base load",y,s)                       = r_gene(r,"base load",s,y)                                             +eps;
*r_gene2(r,"mid load",y,s)                        = r_gene(r,"mid load",s,y)                                              +eps;
*r_gene2(r,"peak load",y,s)                       = r_gene(r,"peak load",s,y)                                             +eps;
r_gene2(r,"hydro total",y,s)                     = r_gene(r,"hydro total",s,y)                                           +eps;
*r_gene2(r,"base load share",y,s)                 = r_gene(r,"base load share",s,y)                                       +eps;
*r_gene2(r,"mid load share",y,s)                  = r_gene(r,"mid load share",s,y)                                        +eps;
*r_gene2(r,"peak load share",y,s)                 = r_gene(r,"peak load share",s,y)                                       +eps;
*r_gene2(r,"hydro share",y,s)                     = r_gene(r,"hydro share",s,y)                                           +eps;
r_gene2("all",alltec,y,s)                        = r_gene("all",alltec,s,y)                                              +eps;



* Value Factors (r_vf)

r_vf("1","market share",tec_VRE,y)               = o_share(tec_VRE,"all") / 100                                          +eps;
r_vf(rall,s,tec_VRE,y)                           = o_vfS(tec_vre,rall)                                                   +eps;

r_vfbal("1","mkt shr - w/ bal",tec_VRE,y)        = o_share(tec_VRE,"all") / 100                                          +eps;
r_vfbal(rall,s,tec_VRE,y)                        = o_vf(tec_vre,rall)                                                    +eps;

r_vf2("1","market share",tec_VRE,y)              = o_share(tec_VRE,"all") / 100                                          +eps;
r_vf2(s,rall,tec_VRE,y)                          = o_vfS(tec_vre,rall)                                                   +eps;

r_vfH("1","market share","hydr",y)               = o_share("hydr","all") / 100                                           +eps;
r_vfH(r_h,s,"hydr",y)                            = o_vfS("hydr",r_h)                                                     +eps;





* Market Share (r_ms)

test3(tec_vre)$(ord(y)=1) = cost_inv(tec_vre);
r_ms("1","cost reduction","wion",y)              = (test3("wion") -  cost_inv("wion"))    / test3("wion")                +eps;
r_ms("1","cost reduction","solar",y)             = (test3("solar") - cost_inv("solar"))    / test3("solar")              +eps;
r_ms(r,s,"wion",y)                               = o_share("wion",r)                                                     +eps;
r_ms("all",s,"wion",y)                           = o_share("wion","all")                                                 +eps;
r_ms(r,s,"solar",y)                              = o_share("solar",r)                                                    +eps;
r_ms("all",s,"solar",y)                          = o_share("solar","all")                                                +eps;

r_ms2("1","cost reduction","wion",y)             = (test3("wion") -  cost_inv("wion"))    / test3("wion")                +eps;
r_ms2("1","cost reduction","solar",y)            = (test3("solar") - cost_inv("solar"))    / test3("solar")              +eps;
r_ms2(s,r,"wion",y)                              = o_share("wion",r)                                                     +eps;
r_ms2(s,"all","wion",y)                          = o_share("wion","all")                                                 +eps;
r_ms2(s,r,"solar",y)                             = o_share("solar",r)                                                    +eps;
r_ms2(s,"all","solar",y)                         = o_share("solar","all")                                                +eps;




*===============================================================
* e) Technology details (r_tec, r_cost, r_sto, r_NTC, r_h2)
*===============================================================



* TWO SHEETS: ONE FOR COSTS; ONE FOR CAPACITY, GENERATION, etc.



* Details by technology

r_tec(r,s,alltec,"capa0 (GW)"            ,y)            = o_capa0(alltec,r)                                                     +eps;
r_tec(r,s,tec_gen,"new cap (GW)"         ,y)            = o_inve(tec_gen,r)                                                         +eps;
r_tec(r,s,tec_sto,"new cap (GW)"         ,y)            = STOINV.L(tec_sto,"power",r)                                           +eps;
r_tec(r,s,tec_gen,"decom cap (GW)"       ,y)            = o_deco(tec_gen,r)                                                         +eps;
r_tec(r,s,tec_chp,"chp0 (GW)"            ,y)            = o_chp0(tec_chp,r)                                                     +eps;
r_tec(r,s,tec_chp,"new chp cap (GW)"     ,y)            = o_invechp(tec_chp,r)                                                  +eps;
r_tec(r,s,tec_chp,"decom chp cap (GW)"   ,y)            = o_decochp(tec_chp,r)                                                  +eps;
r_tec(r,s,alltec,"net gen (TWh)"         ,y)            = o_ygene(alltec,r)                                                     +eps;
r_tec(r,s,tec_gen,"New Fix Cost (G€)"    ,y)            = o_inve(tec_gen,r) * cost_fix(tec_gen) * sc / th                               +eps;
r_tec(r,s,tec_sto,"New Fix Cost (G€)"    ,y)            = r_tec(r,s,tec_sto,"New Fix Cost (G€)",y) + STOINV.L(tec_sto,"energy",r) * cost_energy(tec_sto)   * sc / th   +eps;
r_tec(r,s,tec_mod,"Old qfix Cost (G€)"   ,y)            = (o_capa0(tec_mod,r)-o_deco(tec_mod,r)) * cost_qfix(tec_mod)  * sc / th  +eps;   //* 2
r_tec(r,s,tec_gen,"Var Cost (G€)"        ,y)            = sum((t,allvin),GENE.L(t,tec_gen,allvin,r)*cost_var(t,tec_gen,allvin,r)) * sc / th                    +eps;
r_tec(r,s,alltec,"Revenue Spot (G€)"     ,y)            = o_revS(alltec,r) / th                                                 +eps;
r_tec(r,s,alltec,"Revenue AS (G€)"       ,y)            = o_revA(alltec,r) / th                                                 +eps;
r_tec(r,s,alltec,"Revenue Heat (G€)"     ,y)            = o_revH(alltec,r) / th                                                 +eps;
r_tec(r,s,alltec,"SR Profit (G€)"        ,y)            = (o_rev(alltec,r) - o_cost(alltec,r)) / th                             +eps;
r_tec(r,s,alltec,"FLH (h)",y)$o_capa(alltec,r)          = o_ygene(alltec,r) / o_capa(alltec,r) * th                             +eps;
r_tec(r,s,alltec,"spo mrg (€/KW*a)",y)$o_capa(alltec,r) = sum(t,o_gene(t,alltec,r)*o_margin(t,alltec,r)) / o_capa(alltec,r)*sc  +eps;
r_tec(r,s,alltec,"Spread (€/MWh)",y)$o_ygene(alltec,r)  = sum(t,o_gene(t,alltec,r)*o_margin(t,alltec,r)) / o_ygene(alltec,r)*sc +eps;
r_tec(r,s,alltec,"Av pri (€/MWh)",y)                    = o_mvS(alltec,r)                                                       +eps;
r_tec(r,s,alltec,"val fact (1)",y)                      = o_vfS(alltec,r)                                                       +eps;
*r_tec(r,s,tec_mod,"gross margin (€/KW*a)",y)            = (- INVE.M(tec_mod,r) + cost_fix(tec_mod)) * sc                        +eps;   // IS THIS CORRECT?
r_tec(r,s,"TOT",r_tec_var,y)                            = sum(alltec,    r_tec(r,s,alltec,r_tec_var,y))                         +eps;
r_tec("ALL",s,alltec,r_tec_var,y)                       = sum(r,         r_tec(r,s,alltec,r_tec_var,y))                         +eps;
r_tec("ALL",s,"TOT",r_tec_var,y)                        = sum((r,alltec),r_tec(r,s,alltec,r_tec_var,y))                         +eps;

* Details by technology and vintage

r_tec_vin(r,s,alltec,vin,"capa0 (GW)"            ,y)        = capa0(alltec,vin,r)                                                   +eps;
r_tec_vin(r,s,tec_gen,"new","new cap (GW)"       ,y)        = o_inve(tec_gen,r)                                                         +eps;
r_tec_vin(r,s,tec_sto,"new","new cap (GW)"       ,y)        = STOINV.L(tec_sto,"power",r)                                           +eps;
r_tec_vin(r,s,tec_gen,vin,"decom cap (GW)"       ,y)        = o_deco_vin(tec_gen,vin,r)                                                 +eps;
r_tec_vin(r,s,tec_chp,vin,"chp0 (GW)"            ,y)        = chp0(tec_chp,vin,r)                                                   +eps;
r_tec_vin(r,s,tec_chp,"new","new chp cap (GW)"   ,y)        = o_invechp(tec_chp,r)                                                  +eps;
r_tec_vin(r,s,tec_chp,vin,"decom chp cap (GW)"   ,y)        = o_decochp_vin(tec_chp,vin,r)                                          +eps;


* Technology unit costs as in model / objective function (r_cost)

r_cost("GER",s,alltec,"discount (1)",y)                  = discountrate                                                      +eps;
r_cost("GER",s,alltec,"fix C af RT/FL (€/KW*a)",y)       = cost_fix(alltec) * sc                                             +eps;
r_cost("GER",s,alltec,"fix C af RT/FL, avail (€/KW*a)",y)= cost_fix(alltec) * sc  / (sum(t,avail(t,alltec,"GER")) / card(t)) +eps;
r_cost("GER",s,alltec,"qfix C  (€/KW*a)",y)              = cost_qfix(alltec) * sc                                            +eps;
r_cost("GER",s,tec_gen,"var C af RT (€/MWh)",y)          = sum(t,cost_var(t,tec_gen,"new","GER")) / card(t) * th                       +eps;       //Todo: include vintages?
r_cost("GER",s,tec_gen,"FLH",y)$o_capa(tec_gen,"GER")    = o_ygene(tec_gen,"GER") / o_capa(tec_gen,"GER") * th                       +eps;
r_cost("GER",s,tec_gen,"LEC (€/MWh)",y)                  = o_LEC(tec_gen,"GER")                                                  +eps;


* .. as in input data (also r_cost)
r_cost("GER",s,alltec,"i invest (€/KW*a)",y)     = i_cost("%PROJECT%",alltec,"invest")                                              +eps;
r_cost("GER",s,alltec,"i qfix (€/KW*a)",y)       = i_cost("%PROJECT%",alltec,"qfixcost")                                            +eps;
r_cost("GER",s,tec_gen,"i fuel (€/MWh)",y)       = i_fuel(tec_gen,"%PROJECT%","%HORIZON%")                                                +eps;
r_cost("GER",s,tec_gen,"i efficiency (1)",y)     = eff(tec_gen)                                                              +eps;
r_cost("GER",s,alltec,"i RT prem (1)",y)         = i_cost("%PROJECT%",alltec,"rt_premium")                                          +eps;
r_cost("GER",s,alltec,"i flex prem (1)",y)       = i_cost("%PROJECT%",alltec,"flex_premium")                                        +eps;
r_cost("GER",s,tec_vre,"i balacing (€/KW*a)",y)  = cost_bal(tec_vre)                                                     +eps;



* Storage (r_sto)
r_sto(r,tec_sto,"Power (GW)",s,y)                                = STOINV.L(tec_sto,"power",r)                                                  + eps;
r_sto(r,tec_sto,"Energy (GWh)",s,y)                              = STOINV.L(tec_sto,"energy",r)                                                 + eps;
r_sto(r,tec_sto,"C-rate",s,y)$STOINV.L(tec_sto,"energy",r)       = STOINV.L(tec_sto,"power",r) / STOINV.L(tec_sto,"energy",r)                   + eps;
r_sto(r,tec_sto,"Charge (TWh)",s,y)                              = sum(t,CHARGE.L(t,tec_sto,r)) / th * sc                                       + eps;
r_sto(r,tec_sto,"Discharge (TWh)",s,y)                           = sum(t,DISCHARGE.L(t,tec_sto,r)) / th * sc                                    + eps;
r_sto(r,tec_sto,"Losses (TWh)",s,y)                              = r_sto(r,tec_sto,"Charge (TWh)",s,y) - r_sto(r,tec_sto,"Discharge (TWh)",s,y) + eps;



* Hydro reservoir (r_hydro)
r_hydro(r,"turb cap (GW)",s,y)$o_capa("hydr",r)   = o_capa("hydr",r)                                                +eps;
r_hydro(r,"res vol (TWh)",s,y)$o_capa("hydr",r)   = o_capa("hydr",r) * reservoir(r) / th                            +eps;
r_hydro(r,"inflow (TWh)",s,y)$o_capa("hydr",r)    = o_yinflow(r)                                                    +eps;
r_hydro(r,"generation (TWh)",s,y)$o_capa("hydr",r)= o_ygene("hydr",r)                                               +eps;
r_hydro(r,"spillage (TWh)",s,y)$o_capa("hydr",r)  = sum(t,SPILL.L(t,r)) / th * sc                                   +eps;
r_hydro(r,"mar val (€/KW*a)",s,y)$o_capa("hydr",r)= sum(t,-H1.M(t,r)-H2.M(t,r)-H3.M(t,r)-H4.M(t,r)) * sc            +eps;
r_hydro(r,"water value",s,y)$o_capa("hydr",r)     = o_mvS("hydr",r)                                                 +eps;
r_hydro(r,"bal rev (€/MWh)",s,y)$o_capa("hydr",r) = o_mv("hydr",r) - o_mvS("hydr",r)                                +eps;
r_hydro(r,"dummy 4",s,y)$o_capa("hydr",r)         =                                                                 +eps;
r_hydro(r,"fix C af RT/FL/AV (€/KW*a)",s,y)$o_capa("hydr",r)  = cost_fix("hydr") * sc  / (sum(t,avail(t,"hydr","GER")) / card(t)) +eps;



* Heat and CHP
r_heat(r,s,tec_chp,"Capacity (GW)",y)            = sum(allvin,CAPACHP.L(tec_chp,allvin,r))                                                   +eps;
r_heat(r,s,tec_chp,"Generation (TWh)",y)         = sum((t,allvin),CAPACHP.L(tec_chp,allvin,r)*CHP_profile(t,tec_chp,"min",r)*avail(t,tec_chp,r)) /th *sc +eps;



* Interconnectors
* [maybe ideas and code can be taken from EnSys]
r_NTC("NTC old",y,r,s,rr)                        = ntc0(r,rr)                                                             +eps;
r_NTC("NTC new",y,r,s,rr)                        = NTCINV.L(r,rr)                                                        +eps;


* Hydrogen electrolyzers
r_h2(rall,"H2 capa",s,y)                         = o_h2_capa(rall)                                                       +eps;
r_h2(rall,"H2 cons",s,y)                         = o_h2_ycons(rall)                                                      +eps;
r_h2(rall,"H2 FLH",s,y)                          = o_h2_flh(rall)                                                        +eps;
r_h2(rall,"H2 sto energy",s,y)                   = o_h2_sto_energy(rall)                                                 +eps;
r_h2(rall,"H2 sto duration",s,y)                 = 0                                                                     +eps;
r_h2(rall,"H2 sto duration",s,y)$o_h2_capa(rall) = o_h2_sto_energy(rall)/o_h2_capa(rall)                                 +eps;


*===============================================================
* f) Price setting and Merit-Order
*===============================================================


* Price-setting plant (r_set) --> only for new technologies

r_set(tec_thm,r,s,y)                             = sum(t$(o_p(t,r)=cost_var(t,tec_thm,"new",r)),1) /card(t)*100          +eps;

r_set("zero",r,s,y)                              = sum(t$(o_p(t,r)=0),                    1) /card(t)*100                +eps;
r_set("below H2 >0",r,s,y)                       = sum(t$(o_p(t,r)<h2_dispatch), 1) /card(t)*100 - r_set("zero",r,s,y)   +eps;
r_set("H2",r,s,y)                                = sum(t$(o_p(t,r)=h2_dispatch),          1) /card(t)*100                +eps;
r_set("above H2",r,s,y)                          = sum(t$(o_p(t,r)>h2_dispatch),          1) /card(t)*100                +eps;

r_set("other",r,s,y)                             = 100 - sum(tec_thm,r_set(tec_thm,r,s,y)) - r_set("zero",r,s,y) - r_set("H2",r,s,y) +eps;

r_set("some exports bind",r,s,y)                 = sum(t$(smin(rr,F2.M(t,r,rr)) < 0),1)  /card(t)*100                    +eps;
r_set("all exports bind",r,s,y)                  = sum(t$(smax(rr,F2.M(t,r,rr)) < eps),1)  /card(t)*100                  +eps;  // doesn't seem to work
r_set("some imports bind",r,s,y)                 = sum(t$(smin(rr,F3.M(t,rr,r)) < 0),1)  /card(t)*100                    +eps;
r_set("all imports bind",r,s,y)                  = sum(t$(smax(rr,F3.M(t,rr,r)) < eps),1)  /card(t)*100                  +eps;  // doesn't seem to work
$IF %ASC%=='1'
r_set("must run bind",r,s,y)                     = sum(t$(A2.M(t,r) ne 0),1)  /card(t)*100                               +eps;

r_set("solar at zero",r,s,y)$o_ygene("solar",r)      = sum(t$(o_p(t,r)=0),           o_gene(t,"solar",r))/th*sc/o_ygene("solar",r)*100  +eps;
r_set("solar below H2 >0",r,s,y)$o_ygene("solar",r)  = sum(t$(o_p(t,r)<h2_dispatch), o_gene(t,"solar",r))/th*sc/o_ygene("solar",r)*100 - r_set("solar at zero",r,s,y) +eps;
r_set("solar at H2",r,s,y)$o_ygene("solar",r)        = sum(t$(o_p(t,r)=h2_dispatch), o_gene(t,"solar",r))/th*sc/o_ygene("solar",r)*100  +eps;
r_set("solar above H2",r,s,y)$o_ygene("solar",r)     = sum(t$(o_p(t,r)>h2_dispatch), o_gene(t,"solar",r))/th*sc/o_ygene("solar",r)*100  +eps;

r_set("wion at zero",r,s,y)$o_ygene("wion",r)      = sum(t$(o_p(t,r)=0),           o_gene(t,"wion",r))/th*sc/o_ygene("wion",r)*100  +eps;
r_set("wion below H2 >0",r,s,y)$o_ygene("wion",r)  = sum(t$(o_p(t,r)<h2_dispatch), o_gene(t,"wion",r))/th*sc/o_ygene("wion",r)*100 - r_set("wion at zero",r,s,y) +eps;
r_set("wion at H2",r,s,y)$o_ygene("wion",r)        = sum(t$(o_p(t,r)=h2_dispatch), o_gene(t,"wion",r))/th*sc/o_ygene("wion",r)*100  +eps;
r_set("wion above H2",r,s,y)$o_ygene("wion",r)     = sum(t$(o_p(t,r)>h2_dispatch), o_gene(t,"wion",r))/th*sc/o_ygene("wion",r)*100  +eps;

r_set("wiof at zero",r,s,y)$o_ygene("wiof",r)      = sum(t$(o_p(t,r)=0),           o_gene(t,"wiof",r))/th*sc/o_ygene("wiof",r)*100  +eps;
r_set("wiof below H2 >0",r,s,y)$o_ygene("wiof",r)  = sum(t$(o_p(t,r)<h2_dispatch), o_gene(t,"wiof",r))/th*sc/o_ygene("wiof",r)*100 - r_set("wiof at zero",r,s,y) +eps;
r_set("wiof at H2",r,s,y)$o_ygene("wiof",r)        = sum(t$(o_p(t,r)=h2_dispatch), o_gene(t,"wiof",r))/th*sc/o_ygene("wiof",r)*100  +eps;
r_set("wiof above H2",r,s,y)$o_ygene("wiof",r)     = sum(t$(o_p(t,r)>h2_dispatch), o_gene(t,"wiof",r))/th*sc/o_ygene("wiof",r)*100  +eps;

r_set("VRE at zero",r,s,y)$o_ygene("VRE",r)      = sum(t$(o_p(t,r)=0),sum(tec_vre,o_gene(t,tec_vre,r)))/th*sc/o_ygene("VRE",r)*100    +eps;
r_set("VRE below H2 >0",r,s,y)$o_ygene("VRE",r)  = sum(t$(o_p(t,r)<h2_dispatch),sum(tec_vre,o_gene(t,tec_vre,r)))/th*sc/o_ygene("VRE",r)*100 - r_set("VRE at zero",r,s,y) +eps;
r_set("VRE at H2",r,s,y)$o_ygene("VRE",r)        = sum(t$(o_p(t,r)=h2_dispatch),sum(tec_vre,o_gene(t,tec_vre,r)))/th*sc/o_ygene("VRE",r)*100  +eps;
r_set("VRE above H2",r,s,y)$o_ygene("VRE",r)     = sum(t$(o_p(t,r)>h2_dispatch),sum(tec_vre,o_gene(t,tec_vre,r)))/th*sc/o_ygene("VRE",r)*100  +eps;

r_set2(tec_thm,r,y,s)                            = r_set(tec_thm,r,s,y);
r_set2("zero",r,y,s)                             = r_set("zero",r,s,y);


* Merit-order (r_mo)

r_mo(r,"CHP",s,y,"capa")                         = sum((t,tec_chp,allvin),CAPACHP.L(tec_chp,allvin,r) * profile(t,"CHP",r) ) / card(t)                  +eps;
r_mo(r,tec_gen,s,y,"capa")                       = o_capa(tec_gen,r) * sum(t,avail(t,tec_gen,r)) / card(t)                                                                          +eps;
r_mo(r,tec_chp,s,y,"capa")                       = r_mo(r,tec_chp,s,y,"capa") - sum((t,allvin),CAPACHP.L(tec_chp,allvin,r) * profile(t,"CHP",r) ) / card(t);
r_mo(r,tec_gen,s,y,"av var cost")                = sum(t,cost_var(t,tec_gen,"new",r)) / card(t) * th                                                                                  +eps;  //Todo: vintages





*===============================================================
* g) Model stats
*===============================================================


r_stats(s,y,"modelstat")                           = EMMA.modelstat                                                       +eps;
r_stats(s,y,"seconds")                             = EMMA.resusd                                                          +eps;
r_stats(s,y,"hours")                               = EMMA.resusd / 3600                                                   +eps;
r_stats(s,y,"Iterations")                          = EMMA.iterusd                                                         +eps;
r_stats(s,y,"Hours modeled")                       = card(t)                                                              +eps;
r_stats(s,y,"Countries modeled")                   = card(r)                                                              +eps;

r_stats2(s,"modelstat",y)                          = r_stats(s,y,"modelstat");
r_stats2(s,"solving time",y)                       = r_stats(s,y,"seconds");





*===============================================================
* h) Error checking & development
*===============================================================


* Hourly generation and price in each region (r_tG)

$IFi %tREPORT%=='1'   r_tG(t,r,s,y,alltec)                        = o_gene(t,alltec,r)                                                     +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"PHS vol")                     = STO_V.L(t,r)                                                           +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"batr vol")                    = SLEVEL.L(t,"batr",r)                                                   +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"hydr inflow")                 = inflow(t,r)  * o_capa("hydr",r)                                        +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"hydr res")                    = RESERVOIR_V.L(t,r) / th                                                +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"CHP")                         = sum(tec_chp,capaCHP.L(tec_chp,r)*profile(t,"CHP",r))                   +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"load")                        = load(t,r)                                                               +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"res load")                    = load(t,r) - sum(tec_vre,o_gene(t,tec_vre,r))                            +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"net exp")                     = sum(rr,FLOW.L(t,r,rr))                                                 +eps;
$IFi %tREPORT%=='1'   r_tG(t,r,s,y,"price")                       = o_p(t,r) * th                                                          +eps;




* Hourly price all regions (r_tP, r_tP1)

$IFi %tREPORT%=='1'   r_tP(t,r,s,y)                               = o_p(t,r) * th                                                            +eps;
r_tP1(t,r,s)$(ord(y)=1)                                           = o_p(t,r) * th                                                            +eps;


* By day of year

$IFi %tREPORT%=='1'   r_day(day_year,s,y,"load")                  = sum(t$t_day_year(t,day_year), o_rload(t))              / 24             +eps;
$IFi %tREPORT%=='1'   r_day(day_year,s,y,"price")                 = sum(t$t_day_year(t,day_year), o_rprice(t))            / 24 * th        +eps;
$IFi %tREPORT%=='1'   r_day(day_year,s,y,"wind gen")              = sum(t$t_day_year(t,day_year), o_rgene(t,"wind"))      / 24             +eps;
$IFi %tREPORT%=='1'   r_day(day_year,s,y,"solar gen")             = sum(t$t_day_year(t,day_year), o_rgene(t,"solar"))     / 24             +eps;
$IFi %tREPORT%=='1'   r_day(day_year,s,y,"hyd gen")               = sum(t$t_day_year(t,day_year), o_rgene(t,"hydr"))      / 24             +eps;
$IFi %tREPORT%=='1'   r_day(day_year,s,y,"hyd inflow")            = sum(t$t_day_year(t,day_year), o_rinflow(t))           / 24             +eps;
$IFi %tREPORT%=='1'   r_day(day_year,s,y,"hyd res")               = sum(t$t_day_year(t,day_year), o_rreservoir(t))        / 24             +eps;


* By week of year

$IFi %tREPORT%=='1'   r_week(week_year,s,y,"load")                = sum(t$t_week_year(t,week_year), o_rload(t))              / 168            +eps;
$IFi %tREPORT%=='1'   r_week(week_year,s,y,"price")               = sum(t$t_week_year(t,week_year), o_rprice(t))            / 168 * th       +eps;
$IFi %tREPORT%=='1'   r_week(week_year,s,y,"wind gen")            = sum(t$t_week_year(t,week_year), o_rgene(t,"wind"))      / 168            +eps;
$IFi %tREPORT%=='1'   r_week(week_year,s,y,"solar gen")           = sum(t$t_week_year(t,week_year), o_rgene(t,"solar"))     / 168            +eps;
$IFi %tREPORT%=='1'   r_week(week_year,s,y,"hyd gen")             = sum(t$t_week_year(t,week_year), o_rgene(t,"hydr"))      / 168            +eps;
$IFi %tREPORT%=='1'   r_week(week_year,s,y,"hyd inflow")          = sum(t$t_week_year(t,week_year), o_rinflow(t))           / 168            +eps;
$IFi %tREPORT%=='1'   r_week(week_year,s,y,"hyd res")             = sum(t$t_week_year(t,week_year), o_rreservoir(t))        / 168            +eps;


* By month of year

$IFi %tREPORT%=='1'   r_month(month_year,s,y,"load")              = sum(t$t_month_year(t,month_year), o_rload(t))              / 730            +eps;
$IFi %tREPORT%=='1'   r_month(month_year,s,y,"price")             = sum(t$t_month_year(t,month_year), o_rprice(t))            / 730 * th       +eps;
$IFi %tREPORT%=='1'   r_month(month_year,s,y,"wind gen")          = sum(t$t_month_year(t,month_year), o_rgene(t,"wind"))      / 730            +eps;
$IFi %tREPORT%=='1'   r_month(month_year,s,y,"solar gen")         = sum(t$t_month_year(t,month_year), o_rgene(t,"solar"))     / 730            +eps;
$IFi %tREPORT%=='1'   r_month(month_year,s,y,"hyd gen")           = sum(t$t_month_year(t,month_year), o_rgene(t,"hydr"))      / 730            +eps;
$IFi %tREPORT%=='1'   r_month(month_year,s,y,"hyd inflow")        = sum(t$t_month_year(t,month_year), o_rinflow(t))           / 730            +eps;
$IFi %tREPORT%=='1'   r_month(month_year,s,y,"hyd res")           = sum(t$t_month_year(t,month_year), o_rreservoir(t))        / 730            +eps;


* By time of day

$IFi %tREPORT%=='1'   r_hour_day(hour_day,s,y,"load")             = sum(t$t_hour_day(t,hour_day), o_rload(t))              / 167            +eps;
$IFi %tREPORT%=='1'   r_hour_day(hour_day,s,y,"price")            = sum(t$t_hour_day(t,hour_day), o_rprice(t))            / 167 * th       +eps;
$IFi %tREPORT%=='1'   r_hour_day(hour_day,s,y,"wind gen")         = sum(t$t_hour_day(t,hour_day), o_rgene(t,"wind"))      / 167            +eps;
$IFi %tREPORT%=='1'   r_hour_day(hour_day,s,y,"solar gen")        = sum(t$t_hour_day(t,hour_day), o_rgene(t,"solar"))     / 167            +eps;
$IFi %tREPORT%=='1'   r_hour_day(hour_day,s,y,"hyd gen")          = sum(t$t_hour_day(t,hour_day), o_rgene(t,"hydr"))      / 167            +eps;
$IFi %tREPORT%=='1'   r_hour_day(hour_day,s,y,"hyd inflow")       = sum(t$t_hour_day(t,hour_day), o_rinflow(t))           / 167            +eps;
$IFi %tREPORT%=='1'   r_hour_day(hour_day,s,y,"hyd res")          = sum(t$t_hour_day(t,hour_day), o_rreservoir(t))        / 167            +eps;



); // closes loop(s,y)





*===============================================================
* j) Reporting outside the loop
*===============================================================



* Model statistics

r_stats("total","all runs","seconds")              = timeelapsed;
r_stats("total","all runs","hours")                = timeelapsed / 3600;
r_stats("solving","all runs","seconds")            = sum((s,y),r_stats(s,y,"seconds"));
r_stats("solving","all runs","hours")              = sum((s,y),r_stats(s,y,"seconds")) / 3600;
r_stats("non-solving","all runs","seconds")        = timeelapsed - sum((s,y),r_stats(s,y,"seconds"));
r_stats("non-solving","all runs","hours")          = (timeelapsed - sum((s,y),r_stats(s,y,"seconds"))) / 3600;
r_stats("solving","av per solve","seconds")        = timeelapsed / card(s) / card(y);
r_stats("solving","av per solve","hours")          = timeelapsed / card(s) / card(y) / 3600;

r_stats2("total","modelstat",y)                    = eps;
r_stats2("total","solving time",y)                 = timeelapsed;






*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~9 COUTPUT FILES
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------


$IF %OUTPUT%=='0' $exit



*===============================================================
* a) GDX & Excel output files
*===============================================================

* Create GDX files

execute_UNLOAD 'o_output.gdx'
o_p
o_load
o_margin
o_capa
o_capa0
o_inve
o_deco
o_stoinv
o_gene
o_flow
o_ygene
o_yinflow
o_cur
o_ASp
o_rload
o_rprice
o_rgene
o_rinflow
o_rreservoir
o_share
o_cost
o_LEC
o_revS
o_revA
o_revH
o_rev
o_mvS
o_mv
o_vfS
o_vf
o_bp
o_lp
o_pp
o_op
o_gen
o_CO2
o_val
;


execute_UNLOAD 's_output.gdx'
s_p
s_bp
s_gene
s_flow
s_CO2
s_cost
s_capa
s_inve
s_stoinv
s_deco
;


execute_UNLOAD 'res.gdx'
r_s
r_r
r_r2
r_capa
r_capa2
r_gene
r_gene2
r_vf
r_vf2
r_vfbal
r_ms
r_ms2
r_tec
r_tec_vin
r_cost
r_sto
r_hydro
r_heat
r_NTC
r_h2
r_set
r_set2
r_mo
r_stats
*r_OSE
;

$ONTEXT
execute_UNLOAD 'res_t.gdx'
r_tG
r_tP
r_day
r_week
r_month
r_hour_day
;
$OFFTEXT


execute_UNLOAD 'res_p.gdx'
r_tP1
;


$ONTEXT
execute_UNLOAD 'res_sto.gdx'
r_tS
;
$OFFTEXT




* Write put files for excel export

$onecho > res.txt
par=r_s          rng=sys!a1              cdim=2
par=r_r          rng=r!a1                cdim=2
par=r_r2         rng=r2!a1               cdim=2
par=r_vf         rng=vf!a1               cdim=2
par=r_vfbal      rng=vf!n1               cdim=2
par=r_vf2        rng=vf!aa1              cdim=2
par=r_capa       rng=capa!a1             cdim=2
par=r_capa2      rng=capa2!a1            cdim=2
par=r_gene       rng=gene!a1             cdim=2
par=r_gene2      rng=gene2!a1            cdim=2
par=r_ms         rng=ms!a1               cdim=2
par=r_ms2        rng=ms!n1               cdim=2
par=r_tec        rng=tec!a1              cdim=2
par=r_tec_vin    rng=tec_vin!a1          cdim=2
par=r_cost       rng=cost!a1             cdim=2
par=r_sto        rng=sto!a1              cdim=2
par=r_hydro      rng=hydro!a1            cdim=2
par=r_heat       rng=heat!a1             cdim=2
par=r_NTC        rng=NTC!a1              cdim=2
par=r_h2         rng=H2!a1               cdim=2
par=r_set        rng=p-setting!a1        rdim=1
par=r_set2       rng=p2!a1               rdim=1
par=r_stats      rng=stats!a1

$offecho
*par=r_OSE        rng=OSE!d2              rdim=4

$onecho > res_t.txt
par=r_tG         rng=G!a3                rdim=1
par=r_tP         rng=P!a3                rdim=1
par=r_day        rng=day!a3              rdim=1
par=r_week       rng=week!a3             rdim=1
par=r_month      rng=month!a3            rdim=1
par=r_hour_day   rng=hour_day!a3         rdim=1
$offecho

$onecho > res_p.txt
par=r_tP1        rng=1y!a40             rdim=1
par=r_tP1        rng=2y!a40             rdim=1
par=r_tP1        rng=3y!a40             rdim=1
par=r_tP1        rng=ally!a40           rdim=1
$offecho

*$onecho > res_sto.txt
*par=r_tS         rng=patterns!d2        rdim=5
*$offecho




* Load excel templates

execute "move                           res*.xlsx       trash"
execute "copy                           input\template_res.xlsx        res.xlsx"
execute "copy                           input\template_res_p.xlsx      res_p.xlsx"
*execute "copy                           input\template_res_sto.xlsx    res_sto.xlsx"
$IFi %tREPORT%=='1' execute "copy       input\template_res_t.xlsx      res_t.xlsx"


* export to excel files

execute "GDXXRW.EXE                     res.gdx         EpsOut=0        o=res.xlsx      @res.txt"
execute "GDXXRW.EXE                     res_p.gdx       EpsOut=0        o=res_p.xlsx    @res_p.txt"
*execute "GDXXRW.EXE                     res_sto.gdx     EpsOut=0        o=res_sto.xlsx  @res_sto.txt"
$IFi %tREPORT%=='1' execute "GDXXRW.EXE res_t.gdx       EpsOut=0        o=res_t.xlsx    @res_t.txt"


* Close & delete excel and GDX files with same name

execute "XLSTALK -c                     %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%.xlsx"
execute "XLSTALK -c                     %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%_t.xlsx"
*execute "XLSTALK -c                     %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%_p.xlsx"
execute "XLSTALK -c                     %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%_sto.xlsx"
execute "move                           %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%*.*              trash"
execute "move                           o_output_%HORIZON%.gdx                                                                                         trash"



* Rename XLSX and GDX files

execute "ren                            res.xlsx        %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%.xlsx"
execute "ren                            res_p.xlsx      %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%_p.xlsx"

*execute "ren                            res_sto.xlsx    %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%_sto.xlsx"
$IFi %tREPORT%=='1' execute "ren        res_t.xlsx      %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%_t.xlsx"



* Open excel file (for programming and testing)

$IFi %OPEN% == "1"       execute "XLSTALK -o     %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%.xlsx"
$IFi %OPEN% == "1"       execute "XLSTALK -o     %PURPOSE%_%YDIM%_%HORIZON%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_%SDIM%_t.xlsx"
$IFi %OPEN% == "1"       $exit





*===============================================================
* b) Starting values and clean up
*===============================================================



* Save solution for future starting values (bases)

execute "del     start\%HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_?.gdx"
execute "del     start\%HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_*.gdx"

execute "ren     EMMA_p1.gdx      %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_1.gdx"
execute "ren     EMMA_p2.gdx      %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_2.gdx"
execute "ren     EMMA_p3.gdx      %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_3.gdx"
execute "ren     EMMA_p4.gdx      %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_4.gdx"
execute "ren     EMMA_p5.gdx      %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%WINDPROFILE%_%SOLARPROFILE%_%WeatherYEAR%_5.gdx"

execute "ren     EMMA_p6.gdx      %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_6.gdx"
execute "ren     EMMA_p11.gdx     %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_11.gdx"
execute "ren     EMMA_p16.gdx     %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_16.gdx"
execute "ren     EMMA_p21.gdx     %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_21.gdx"
execute "ren     EMMA_p26.gdx     %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_26.gdx"
execute "ren     EMMA_p31.gdx     %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_31.gdx"
execute "ren     EMMA_p36.gdx     %HORIZON%_%YDIM%_%HOURS%_%REGIONS%_%SDIM%_36.gdx"

execute "copy    %HORIZON%*.gdx     start"



* Clean up (a little)

execute "del     EMMA_p*.gdx"
execute "del     %HORIZON%*.gdx"
execute "del     *.*gm"
execute "del     *.par"
execute "del     *.log"
execute "del     *.lxi"
execute "del     *.gen"
execute "del     *.tmp"
execute "del     *.dat"
execute "del     *.plt"
execute "del     *.op*"
execute "del     *.o1*"
execute "del     *.ref"

execute "rd     /S /Q 225a"
execute "rd     /S /Q 225b"
execute "rd     /S /Q 225c"
execute "rd     /S /Q 225d"







