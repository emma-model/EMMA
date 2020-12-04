
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~1     HORIZON INCLUDE FILES -> h_%HORIZON%
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

$onecho                          > scen\h_LTE.gms
capa0(alltec,vin,r)              = 0;
chp0(tec_chp,vin,r)              = 0;
ntc0(r,rr)                       = 0;
capa0("hydr","1",r)              = i_capa0("hydr","1","LTE",r);
capa0(tec_exo,"1",r)             = i_capa0(tec_exo,"1","LTE",r);
$offecho


$onecho                          > scen\h_2016.gms
capa0(alltec,vin,r)              = i_capa0(alltec,vin,"2016",r);
chp0(tec_chp,vin,r)              = i_chp0(tec_chp,vin,"2016",r);
chp_tot(r)                       = i_chp_tot("2016",r);
ntc0(r,rr)                       = i_ntc0(r,"2016",rr) / th;
$include                         scen\shortterm_1.gms
$offecho


$onecho                          > scen\h_2025.gms
capa0(alltec,vin,r)              = i_capa0(alltec,vin,"2025",r);
chp0(tec_chp,vin,r)              = i_chp0(tec_chp,vin,"2025",r);
chp_tot(r)                       = i_chp_tot("2025",r);
ntc0(r,rr)                       = i_ntc0(r,"2025",rr) / th;
$offecho


$onecho                          > scen\h_2030.gms
capa0(alltec,vin,r)              = i_capa0(alltec,vin,"2030",r);
chp0(tec_chp,vin,r)              = i_chp0(tec_chp,vin,"2030",r);
chp_tot(r)                       = i_chp_tot("2030",r);
ntc0(r,rr)                       = i_ntc0(r,"2030",rr) / th;
$offecho


*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~1     Y-DIMENSION INCLUDE FILES -> y_%YDIM%
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

$echo    set y /1,20,40,60,80,100/;                                              > scen\ynames_solarshare.gms
$onecho                                                                          > scen\y_solarshare.gms
INVE.FX("solar",r)               = y.val / 100 * sum(t,load(t,r)) * sc / i_FLH(r,"solar");
INVE.FX("solar",r)$(y.val=1)     = little;
INVE.FX("wion",r)                = little;
INVE.FX("wiof",r)                = little;
$offecho


$echo    set y /1,20,40,60,80,100/;                                              > scen\ynames_wionshare.gms
$onecho                                                                          > scen\y_wionshare.gms
INVE.FX("wion",r)                = y.val / 100 * sum(t,load(t,r)) * sc / i_FLH(r,"wion");
INVE.FX("wion",r)$(y.val=1)      = little;
INVE.FX("solar",r)               = little;
INVE.FX("wiof",r)                = little;
$offecho


$echo    set y /1,20,40,60,80,100/;                                              > scen\ynames_wiofshare.gms
$onecho                                                                          > scen\y_wiofshare.gms
INVE.FX("wiof",r)                = y.val / 100 * sum(t,load(t,r)) * sc / i_FLH(r,"wiof");
INVE.FX("wiof",r)$(y.val=1)      = little;
INVE.FX("solar",r)               = little;
INVE.FX("wion",r)                = little;
$offecho


$echo    set y /1,20,40,60,80,100,120,140/;                                      > scen\ynames_VREshare.gms
$onecho                                                                          > scen\y_VREshare.gms
INVE.FX("solar",r)               = y.val / 3 / 100 * sum(t,load(t,r)) * sc / i_FLH(r,"solar");
INVE.FX("wion",r)                = y.val / 3 / 100 * sum(t,load(t,r)) * sc / i_FLH(r,"wion");
INVE.FX("wiof",r)                = y.val / 3 / 100 * sum(t,load(t,r)) * sc / i_FLH(r,"wiof");
INVE.FX("solar",r)$(y.val=1)     = little;
INVE.FX("wion",r)$(y.val=1)      = little;
INVE.FX("wiof",r)$(y.val=1)      = little;
$offecho


*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~2     S-DIMENSION INCLUDE FILES -> s_%SDIM%
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

* Benchmark

$echo    set s /bench/;                                                          > scen\snames_bench.gms
$echo                                                                            > scen\s_bench.gms


* CO2 Price

$echo set s      /"50 €/t_CO2","150 €/t_CO2"/;                                   > scen\snames_CO2.gms
$onecho                                                                          > scen\s_CO2.gms
co2(r)$(ord(s)=1)                =  50;
co2(r)$(ord(s)=2)                = 150;
cost_var(t,tec_mod,"new",r)                   = (i_cost("%PROJECT%",tec_mod,"varcost") + (cost_fuel(tec_mod) * fuelseason(t,tec_mod) + i_cost("%PROJECT%",tec_mod,"co2int")*co2(r)) / eff(tec_mod) - run_through(tec_mod)) / th;
cost_var(t,tec_mod,vin,r)$i_eff0(tec_mod,vin) = (i_cost("%PROJECT%",tec_mod,"varcost") + (cost_fuel(tec_mod) * fuelseason(t,tec_mod) + i_cost("%PROJECT%",tec_mod,"co2int")*co2(r)) / i_eff0(tec_mod,vin) - run_through(tec_mod)) / th;
$offecho


* Cost Storage

$echo set s      /"-50% Storage","+50% Storage"/;                                > scen\snames_costStorage.gms
$onecho                                                                          > scen\s_costStorage.gms
cost_energy(tec_sto)$(ord(s)=1)  = 0.5 * i_cost("%PROJECT%",tec_sto,"energy") * ((1+discountrate)**lifetime(tec_sto)*discountrate)/((1+discountrate)**lifetime(tec_sto)-1) / sc;
cost_energy(tec_sto)$(ord(s)=2)  = 1.5 * i_cost("%PROJECT%",tec_sto,"energy") * ((1+discountrate)**lifetime(tec_sto)*discountrate)/((1+discountrate)**lifetime(tec_sto)-1) / sc;
cost_energy(tec_sto)             = cost_energy(tec_sto) * i_cost("%PROJECT%",tec_sto,"flex_premium");

cost_inv(tec_sto)$(ord(s)=1)     = 0.5 * i_cost("%PROJECT%",tec_sto,"invest") * ((1+discountrate)**lifetime(tec_sto)*discountrate)/((1+discountrate)**lifetime(tec_sto)-1) / sc ;  // annualized capital costs from investment costs
cost_inv(tec_sto)$(ord(s)=2)     = 1.5 * i_cost("%PROJECT%",tec_sto,"invest") * ((1+discountrate)**lifetime(tec_sto)*discountrate)/((1+discountrate)**lifetime(tec_sto)-1) / sc ;  // annualized capital costs from investment costs
cost_fix(tec_sto)                = cost_qfix(tec_sto) + cost_inv(tec_sto);                                                                                      // fix costs comprise capital and quasi-fix costs
cost_fix(tec_sto)                = cost_fix(tec_sto) * i_cost("%PROJECT%",tec_sto,"flex_premium");                                                                      // revenues from ancillary services and/or capacity markets
$offecho
