*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~1     SCENARIOS CONCERNING INPUT DATA -> si_%SI%
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------

$echo                           > scen\si_none.gms

* start SENTINEL GREEK CASE STUDY
$onecho                         > scen\si_SENTINEL_GRC_RF.gms
    i_CO2cap(allr,"%PROJECT%", "2030")    = 7.0;
    i_CO2cap(allr,"%PROJECT%", "2050")    = 3.0;

    i_yload("GRC","Electricity","2030")   =  57.3;
    i_yload("GRC","Electricity","2050")   =  80.3;

    Table Overwrite_fuel(tec_supply,allh) "Table used to overwrite fuel prices"
                    2016        2030        2050
        CCGT        17.2        22.43       45.32
        CCGT_CCS    17.2        22.43       45.32
        OCGT        17.2        22.43       45.32
        lign        11.16       11.16       11.16
        shed      3000.0      3000.0      3000.0;
    i_fuel(tec_supply,allpro,allh)$Overwrite_fuel(tec_supply,allh) = Overwrite_fuel(tec_supply,allh);


    Parameter Overwrite_ETS(allh) "Table used to overwrite carbon price"
        /2030 = 64.67, 2050 = 114.79/
    ;
    i_CO2("ETS",allpro,allh)$Overwrite_ETS(allh) = Overwrite_ETS(allh);
    
    i_invemax("PtHydrogen","%HORIZON%",r) =   0.0;
    i_invemax("CCGT_H2",   "%HORIZON%",r) =   0.0;
    i_invemax("OCGT_H2",   "%HORIZON%",r) =   0.0;

    
$IFTHENE.exo_export %EXOEXPORT%=='1'
    exo_export(t,r)      = i_exo_export(t,'SENTINEL_GRC_RF',r,"%HORIZON%");
$ENDIF.exo_export

$IFTHENE.exo_load %EXOLOAD%=='1'
    exo_load(t,r)      = i_exo_load(t,'SENTINEL_GRC_RF',r,"%HORIZON%") / th;
$ENDIF.exo_load

$offecho


$onecho                         > scen\si_SENTINEL_GRC_RE.gms
* Emission reduction is 99% (picked out arbitrarily so it would be close to 0) to 1990
    i_CO2cap(allr,"%PROJECT%", "2050")    =  0.4;

    i_yload("GRC","Electricity","2050")   = 92;

    Table Overwrite_fuel(tec_supply,allh) "Table used to overwrite fuel prices"
                    2016        2030        2050
        CCGT        17.2        22.43       45.32
        CCGT_CCS    17.2        22.43       45.32
        OCGT        17.2        22.43       45.32
        shed      3000.0      3000.0      3000.0;
    i_fuel(tec_supply,allpro,allh)$Overwrite_fuel(tec_supply,allh) = Overwrite_fuel(tec_supply,allh);


    Parameter Overwrite_ETS(allh) "Table used to overwrite carbon price"
        /2030 = 64.67, 2050 = 114.79/
    ;
    i_CO2("ETS",allpro,allh)$Overwrite_ETS(allh) = Overwrite_ETS(allh);

$IFTHENE.exo_export %EXOEXPORT%=='1'
    exo_export(t,r)      = i_exo_export(t,'SENTINEL_GRC_RE',r,"%HORIZON%");
$ENDIF.exo_export

$IFTHENE.exo_load %EXOLOAD%=='1'
    exo_load(t,r)      = i_exo_load(t,'SENTINEL_GRC_RE',r,"%HORIZON%") / th;
$ENDIF.exo_load

$offecho


$onecho                         > scen\si_SENTINEL_GRC_PX.gms
* Emission reduction is 99% (picked out arbitrarily so it would be close to 0) to 1990
    i_CO2cap(allr,"%PROJECT%", "2050")    =   0.4;

    Table Overwrite_fuel(tec_supply,allh) "Table used to overwrite fuel prices"
                    2016        2030        2050
        CCGT        17.2        22.43       45.32
        CCGT_CCS    17.2        22.43       45.32
        OCGT        17.2        22.43       45.32
        shed      3000.0      3000.0      3000.0;
    i_fuel(tec_supply,allpro,allh)$Overwrite_fuel(tec_supply,allh) = Overwrite_fuel(tec_supply,allh);


    Parameter Overwrite_ETS(allh) "Table used to overwrite carbon price"
        /2030 = 64.67, 2050 = 114.79/;
    i_CO2("ETS",allpro,allh)$Overwrite_ETS(allh) = Overwrite_ETS(allh);

    i_yload("GRC","Electricity","2050")   =  98.9;
    i_yload("GRC","Hydrogen",   "2050")   =  42.9;

$IFTHENE.exo_export %EXOEXPORT%=='1'
    exo_export(t,r)      = i_exo_export(t,'SENTINEL_GRC_PX',r,"%HORIZON%");
$ENDIF.exo_export

$IFTHENE.exo_load %EXOLOAD%=='1'
    exo_load(t,r)      = i_exo_load(t,'SENTINEL_GRC_PX',r,"%HORIZON%") / th;
$ENDIF.exo_load

$offecho
* end SENTINEL GREEK CASE STUDY


* start SENTINEL EUROPEAN CASE STUDY

* EMMA captured ~89% of emission reported in 2016, hence the emission cap is scaled accordingly
$set emission_scaling 0.89

$onecho                         > scen\si_SENTINEL_EU_CT.gms
*    i_invemax("lign_CCS", "%HORIZON%",r)  =   0.0;
*    i_invemax("coal_CCS", "%HORIZON%",r)  =   0.0;
*    i_invemax("CCGT_CCS", "%HORIZON%",r)  =   0.0;

    i_CO2cap(allr,"%PROJECT%", "2030")    = i_CO2cap(allr,"%PROJECT%", "1990")*(1-0.47)*%emission_scaling%;
    i_CO2cap(allr,"%PROJECT%", "2050")    = i_CO2cap(allr,"%PROJECT%", "1990")*(1-0.64)*%emission_scaling%;
    
$IFTHENE.exo_export %EXOEXPORT%=='1'
    exo_export(t,r)      = i_exo_export(t,'SENTINEL_EU_CT',r,"%HORIZON%");
$ENDIF.exo_export

$IFTHENE.exo_load %EXOLOAD%=='1'
    exo_load(t,r)      = i_exo_load(t,'SENTINEL_EU_CT',r,"%HORIZON%") / th;
    i_yload(r,"Hydrogen","2030") = i_exo_h2_demand("SENTINEL_EU_CT",r,"2030");
    i_yload(r,"Hydrogen","2050") = i_exo_h2_demand("SENTINEL_EU_CT",r,"2050");
$ENDIF.exo_load

$offecho


$onecho                         > scen\si_SENTINEL_EU_CN.gms
*    i_invemax("lign_CCS", "%HORIZON%",r)  =   0.0;
*    i_invemax("coal_CCS", "%HORIZON%",r)  =   0.0;
*    i_invemax("CCGT_CCS", "%HORIZON%",r)  =   0.0;

    i_CO2cap(allr,"%PROJECT%", "2030")    = i_CO2cap(allr,"%PROJECT%", "1990")*(1-0.55)*%emission_scaling%;
    i_CO2cap(allr,"%PROJECT%", "2050")    = i_CO2cap(allr,"%PROJECT%", "1990")*(1-0.98)*%emission_scaling%;
  
$IFTHENE.exo_export %EXOEXPORT%=='1'
    exo_export(t,r)      = i_exo_export(t,"SENTINEL_EU_CN",r,"%HORIZON%");
$ENDIF.exo_export

$IFTHENE.exo_load %EXOLOAD%=='1'
    exo_load(t,r)      = i_exo_load(t,"SENTINEL_EU_CN",r,"%HORIZON%") / th;
    i_yload(r,"Hydrogen","2030") = i_exo_h2_demand("SENTINEL_EU_CN",r,"2030");
    i_yload(r,"Hydrogen","2050") = i_exo_h2_demand("SENTINEL_EU_CN",r,"2050");
$ENDIF.exo_load

$offecho


$onecho                         > scen\si_SENTINEL_EU_EN.gms
*    i_invemax("lign_CCS", "%HORIZON%",r)  =   0;
*    i_invemax("coal_CCS", "%HORIZON%",r)  =   0;
*    i_invemax("CCGT_CCS", "%HORIZON%",r)  =   0;

    i_CO2cap(allr,"%PROJECT%", "2040")    = i_CO2cap(allr,"%PROJECT%", "1990")*(1-0.98)*%emission_scaling%;

$IFTHENE.exo_export %EXOEXPORT%=='1'
    exo_export(t,r)      = i_exo_export(t,"SENTINEL_EU_EN",r,"%HORIZON%");
$ENDIF.exo_export

$IFTHENE.exo_load %EXOLOAD%=='1'
    exo_load(t,r)      = i_exo_load(t,"SENTINEL_EU_EN",r,"%HORIZON%") / th;
$ENDIF.exo_load

$offecho
* end SENTINEL EUROPEAN CASE STUDY


$onecho                         > scen\si_historical.gms

$IFTHENE.exo_export %EXOEXPORT%=='1'
    exo_export(t,r)      = i_exo_export(t,'historical',r,horizon);
$ENDIF.exo_export

$offecho

*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------
*
* ~1     SCENARIOS CONCERNING CONSTRAINTS -> sc_%SC%
*
*---------------------------------------------------------------------------------------------------------------------------
*---------------------------------------------------------------------------------------------------------------------------


$echo                           > scen\sc_none.gms
