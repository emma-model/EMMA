$if not set ONAME   $set ONAME EMMA
$if not set OFOLDER $set OUTPUT %ONAME%
$if     set OFOLDER $set OUTPUT %OFOLDER%%system.dirsep%%ONAME%.gdx


* ----------------------------------------------
* DEFINE PARAMETERS
* ----------------------------------------------

PARAMETER

* Investment (and other yearly variables)
o_capa(alltec,allvin,r)                         total installed capacity        (GW)
o_inve(tec_inv,new,r)                           new capacity                    (GW)
o_deco(tec_inv,vin,r)                           decommissioned capacity         (GW)
o_capachp(tec_chp,allvin,r)                     total CHP capacity              (GW)
o_invechp(tec_chp,new,r)                            new CHP capacity                (GW)
o_decochp(tec_chp,vin,r)                        decommissioned CHP capa         (GW)
o_flh(tec_gen,allvin,r)                         full load hours by technology   (h) 
o_asc(r)                                        ASC must run                    (GW)
o_stoinv(tec_sto,*,new,r)                           new storage capacity            (GW and GWh)
o_ntcinv(r,rr)                                  new NTC capacity                (GW)
o_cost                                          total system cost               (MEUR)
o_ntc_capa(r,rr)                                total ntc capacity              (GW)

* Dispatch (and other hourly variables)
o_load(t,r)                                   power demand
o_import(t,r)                                   net import

o_supply(t,tec_supply,allvin,r)
o_demand(t,tec_demand,allvin,r)

o_h2_usage(tec_h2g,r)                           Usage of Hydrogen for electricity generation (GWh thermal)
o_h2_gene(tec_h2d,r)                            Generation of Hydrogen            (GWh thermal)
o_h2_imports(r)                                 Hydrogen imports with fixed price (GWh thermal)

* Legacy: potentially to be deleted
o_gene(t,tec_gen,allvin,r)                       hourly generation (no storage)  (GWh per hour)
o_cons(t,tec_con,allvin,r)                      hourly consumption (no storage) (GWh per hour)
o_stor(t,tec_sto,allvin,r)                      hourly storage activity         (GWh per hour)
o_gene_chp(t,tec_chp,allvin,r)                  hourly minimum CHP generation   (GWh per hour)

o_reservoir(t,r)                                reservoir level                 (GWh)
o_spill(t,r)                                    reservoir spillage              (GWh per hour)
o_slevel(t,tec_sto,allvin,r)                    storage level                   (GWh)
o_charge(t,tec_sto,allvin,r)                           storage charging                (GWh per hour)
o_discharge(t,tec_sto,allvin,r)                        storage discharging             (GWh per hour)
o_flow(t,r,r_plus_exo)                                  hourly net exports wo exogenous (GWh per hour)
o_cur(t,r)                                      curtailment                     (GWh per hour)

o_co2_capture(r)                                CO2 Capture per region          (Mt per year)
o_co2_cap(r)                                    CO2 Cap per region              (Mt per year)

* Dual (shadow) variables
o_prices(t,r)                                   spot price                      (EUR per MWh)
o_co2price(r)                                   carbon price                    (EUR per ton)
o_h2price_sell(r)                               hydrogen sell-price             (EUR per MWh thermal)
o_h2price_buy(r)                                hydrogen sell-price             (EUR per MWh thermal)


* Model statistics output
o_stats(*)                                      model statistics

* Derived outputs
o_market_value(tec_vre, r)                      market value of VRE techs       (EUR per MWh)
o_emissions(tec_thm,r)                          emissions                       (Mton per year)
o_h2_demand_exo(r)                              non-electricity exognous hydrogen demand        (GWh)
;


* ----------------------------------------------
* ASSIGN VALUES
* ----------------------------------------------

* Investment (and other yearly variables)
o_capa(alltec,allvin,r)                               = CAPA.L(alltec,allvin,r);
o_inve(tec_inv,new ,r)                                = INVE.L(tec_inv,new,r);
o_deco(tec_inv,vin,r)                                 = DECO.L(tec_inv,vin,r);
o_capachp(tec_chp,allvin,r)                           = CAPACHP.L(tec_chp,allvin,r);
o_invechp(tec_chp,new,r)                              = INVECHP.L(tec_chp,new,r);
o_decochp(tec_chp,vin,r)                              = DECOCHP.L(tec_chp,vin,r);
o_asc(r)                                              = asc_level(r);
* o_flh(tec_gen,allvin, r)$CAPA.L(tec_gen,allvin,r)     = sc * sum(t,GENE.L(t,tec_gen,allvin,r) ) / CAPA.L(tec_gen,allvin,r);
o_stoinv(tec_sto,"power",new,r)                       = sum(tec_inv(tec_sto), INVE.L(tec_inv,new,r));
o_stoinv(tec_sto,"energy",new,r)                      = INVESTO.L(tec_sto,new,r);
o_ntcinv(r,rr)                                        = NTCINV.L(r,rr);
o_cost                                                = COST.L;
o_ntc_capa(r,rr)                                      = ntc0(r,rr) + NTCINV.L(r,rr);
                                                      
* Dispatch (and other hourly variables)
o_load(t,r)                                           = load(t,r);
o_import(t,r)                                         = -sum(r_plus_exo,FLOW.L(t,r,r_plus_exo));              



o_supply(t,tec_supply,allvin,r)                       = SUPPLY.L(t,tec_supply,allvin,r);
o_demand(t,tec_demand,allvin,r)                       = DEMAND.L(t,tec_demand,allvin,r);

o_h2_usage(tec_h2g,r)                                 = sum((allvin,t), SUPPLY.L(t,tec_h2g,allvin,r)/efficiency(tec_h2g,allvin)
                                                            + GENE_increase.L(t,tec_h2g,allvin,r)*fuel_ramping(tec_h2g,r));
o_h2_gene(tec_h2d,r)                                  = sum((allvin,t), DEMAND.L(t,tec_h2d,allvin,r)*eff(tec_h2d));
o_h2_imports(r)                                       = H2_IMPORTS.L(r);

* Legacy: potentially to be deleted
o_gene(t,tec_gen,allvin,r)                            = SUPPLY.L(t,tec_gen,allvin,r);
o_cons(t,tec_con,allvin,r)                            = DEMAND.L(t,tec_con,allvin,r);
o_stor(t,tec_sto,allvin,r)                            = sum(tec_supply(tec_sto), SUPPLY.L(t,tec_supply,allvin,r)) - sum(tec_demand(tec_sto), DEMAND.L(t,tec_demand,allvin,r));
o_gene_chp(t,tec_chp,allvin,r)                        = o_capachp(tec_chp,allvin,r) * CHP_profile(t,tec_chp,"min",r) * avail(t,tec_chp,r);

o_reservoir(t,r)                                      = RESERVOIR_V.L(t,r);
o_spill(t,r)                                          = SPILL.L(t,r);

o_slevel(t,tec_sto,allvin,r)                          = SLEVEL.L(t,tec_sto,allvin,r);

* Legacy: potentially to be deleted
o_charge(t,tec_sto,allvin,r)                          = sum(tec_demand(tec_sto), DEMAND.L(t,tec_demand,allvin,r));
o_discharge(t,tec_sto,allvin,r)                       = sum(tec_supply(tec_sto), SUPPLY.L(t,tec_supply,allvin,r));
o_flow(t,r,r_plus_exo)                                        = FLOW.L(t,r,r_plus_exo);
o_cur(t,r)                                            = CURTAIL.L(t,r);

o_co2_capture(r)                                      = sum(t, CO2_CAPTURE.L(t,r))* sc / mn;
o_co2_cap(r)                                          = co2_cap(r)* sc / mn;
                                                      
* Dual (shadow) variables in EUR per MWh (or per ton)
o_prices(t,r)                                         = -E1.M(t,r) * 1000;
o_co2price(r)                                         = co2_price(r);
o_h2price_sell(r)                                     = h2_price_sell(r);
o_h2price_buy(r)                                      = h2_price_buy(r);

                                              
* Model statistics                                    
o_stats("modelstatus")                                = EMMA.modelstat;
o_stats("seconds")                                    = EMMA.resusd;
o_stats("iterations")                                 = EMMA.iterusd;

* Derived outputs
o_market_value(tec_vre,r)$sum((t,allvin),o_gene(t,tec_vre,allvin,r))           = sum((t,allvin), o_gene(t,tec_vre,allvin,r) * o_prices(t,r)) / sum((t,allvin),o_gene(t,tec_vre,allvin,r));
o_emissions(tec_thm,r)                                = sum((t, allvin),co2_int(tec_thm,r)*(
                                                        SUPPLY.L(t,tec_thm,allvin,r)/efficiency(tec_thm,allvin)
                                                        + GENE_increase.L(t,tec_thm,allvin,r)*fuel_ramping(tec_thm,r))) * sc / mn;
o_h2_demand_exo(r)                                    =h2_demand_exo(r);

* ----------------------------------------------
* UNLOAD TO GDX
* ----------------------------------------------


execute_unload '%OUTPUT%'
* Investment (and other yearly variables)
o_capa
o_inve
o_deco
o_capachp
o_invechp
o_decochp
o_asc
o_stoinv
o_ntcinv
o_cost
o_ntc_capa
                                                    
* Dispatch (and other hourly variables)                   
o_load
o_import
                                                  
o_supply
o_demand

o_h2_usage
o_h2_gene
o_h2_imports
* Legacy: potentially to be deleted                       
o_gene
o_cons
o_stor
o_gene_chp
                                                          
o_reservoir
o_spill
o_slevel
                                                  
* Legacy: potentially to be deleted                       
o_charge
o_discharge
o_flow
o_cur

o_co2_capture
o_co2_cap                                             
                                                          
* Dual (shadow) variables in EUR per MWh (or per ton)     
o_prices
o_co2price
o_h2price_sell
o_h2price_buy
                                                          
                                                          
* Model statistics                                        
o_stats
                                                          
* Derived outputs                                         
o_market_value
o_emissions
o_h2_demand_exo

* Raw inputs
profile
avail
efficiency
eff
i_cost
alltec
r
tec_h2
tec_h2g
cost_fuel
co2_int
cost_var
discountrate
;
