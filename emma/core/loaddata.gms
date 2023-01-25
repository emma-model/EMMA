
* Non-time series data from data.xlsx
$onecho > data.txt
par=i_cost               rng=cost!c2:al23                rdim=1 cdim=2
par=i_cost_misc          rng=cost!c29:d31                rdim=1 cdim=0
par=i_yload              rng=yload!a2:u19                rdim=1 cdim=2
par=i_fuel               rng=fuel!a2:r15                 rdim=1 cdim=2
par=i_CO2                rng=fuel!a27:r36                rdim=1 cdim=2
par=i_CO2cap             rng=fuel!a44:r63                rdim=1 cdim=2
par=i_monthly            rng=monthly!b2:l14
par=i_FLH                rng=FLH!a2:e20
par=i_REshare            rng=REshare!a2:p20
par=i_km                 rng=km!b2:ai35
par=i_ACDC               rng=ACDC!b2:af32
$offecho

$CALL GDXXRW.exe        input\data.xlsx       Squeeze=N   @data.txt


* Existing capacities from data0.xlsx
$onecho > data0.txt
par=i_capa0              rng=capa0!a2:bo23                rdim=2 cdim=2
par=i_energy0            rng=capa0!a27:bo30               rdim=2 cdim=2
par=i_invemin            rng=invelim!a2:bn13              rdim=1 cdim=2
par=i_invemax            rng=invelim!a18:bn35             rdim=1 cdim=2
par=i_chp0               rng=chp0!a2:bo15                 rdim=2 cdim=2
par=i_chp_tot            rng=chp0!c19:bo21                rdim=0 cdim=2
par=i_gene0              rng=gene0!a2:dk23                rdim=1 cdim=3
par=i_eff0               rng=eff0!a2:c14                  rdim=2
par=i_ntc0               rng=ntc0!b2:fj36                 rdim=1 cdim=2
par=i_exp0               rng=exp0!b2:ft32                 rdim=1 cdim=2
$offecho

$CALL GDXXRW.exe        input\data0.xlsx        @data0.txt



* Time series data from data_ts.xlsx
$onecho > data_ts.txt
set=time                 rng=time!a2:k8761               rdim=9
par=i_chp                rng=CHP!a6:p8767                rdim=1 cdim=2
par=i_load               rng=load!a6:el8768              rdim=1 cdim=3
par=i_avail              rng=avail!a6:i8768              rdim=1 cdim=3
par=i_solar              rng=solar!a7:ep8769             rdim=1 cdim=3
par=i_solar_future       rng=solar_future!a6:ec8768      rdim=1 cdim=3
par=i_wion               rng=wion!a7:ev8769              rdim=1 cdim=3
par=i_wion_future        rng=wion_future!a6:em8768       rdim=1 cdim=3
par=i_wiof               rng=wiof!a7:eo8769              rdim=1 cdim=3
par=i_wiof_future        rng=wiof_future!a6:cv8768       rdim=1 cdim=3
$offecho

$CALL GDXXRW.exe        input\data_ts.xlsx     @data_ts.txt

$onecho > exoexport.txt
par=i_exo_export         rng=export!a6:r8768             rdim=1 cdim=3
$offecho

$CALL GDXXRW.exe        input\exoexport.xlsx     @exoexport.txt

$onecho > exoload.txt
par=i_exo_load           rng=load!a6:el8768             rdim=1 cdim=3
par=i_exo_h2_demand      rng=hydrogen!a2:el5         rdim=0 cdim=3
$offecho

$CALL GDXXRW.exe        input\exoload.xlsx       @exoload.txt
