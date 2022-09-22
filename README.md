# The Electricity Market Model EMMA - Version SENTINEL

A detailed model description is published on [Econstor](http://hdl.handle.net/10419/244592 "Model Description"). For further information, visit the official model webpage [here](https://emma-model.com/). Depending on your usage and focus, attribution should be given to the description or code as follows:

> Hirth, Lion; Ruhnau, Oliver; Sgarlato, Raffaele (2021): The European Electricity Market Model EMMA - Model Description, ZBW - Leibniz Information Centre for Economics, Kiel, Hamburg. http://hdl.handle.net/10419/244592

> Hirth, Lion; Sgarlato, Raffaele; Ruhnau, Oliver (2021): The European Electricity Market Model EMMA - Model Code. https://github.com/emma-model/EMMA/tree/v1.0

**This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 837089.**

## This version

This version incorporates features developed within the Sustainable Energy Transitions Laboratory (SENTINEL) project which is a new modeling framework. The SENTINEL framework will be modular in structure incorporating many separate models which will look in detail at specific technological, geographic, and societal aspects of the transition to a low-carbon energy system. The models will be able to be linked together to answer a wide range of different questions.

### Version-specific contributions
* Cornelis Savelsberg: data preprocessing, feature extensions, visualisations
* Raffaele Sgarlato: conceptualization, feature extensions

## Modules overview

EMMA comprises several modules that cover the input, the optimization, and the output side of the model.

### Inputs

* ___\\input :___ folder containing the inputs by EMMA in Excel format
  * ___data.xlsx :___ contains mainly technology parameters and yearly figures
  * ___data0.xlsx :___ contains mainly historic data
  * ___data_ts.xlsx :___ contains mainly hourly timeseries data
  * ___exoexport.xlsx :___ contains hourly timeseries of exogenous export profiles __(version-specific feature)__
  * ___exoload.xlsx :___ contains hourly timeseries of exogenous demand profiles __(version-specific feature)__

* ___\\scen :___ folder containing scenario-specific code snippets that can be used to complement the code contained in the _core.gms_ file :
  * ___si\_\*.gms :___ files that are loaded into the _core.gms_ code after the inputs are loaded, hence, geared towards input editing
  * ___sc\_\*.gms :___ files that are loaded into the _core.gms_ code after the mathematical equations are formulated, hence, geared towards complementing the mathematical model

* ___loaddata.gms :___ module that converts the Excel data into GDX format
  * (Optional) Arguments: `None`
  * Result: _data.gdx_, _data0.gdx_ and _data_ts.gdx_

* ___scenarios.gms :___ module that is used to generate _.gms_ scenario files in the folder
  * (Optional) Arguments: `None`
  * Result: _si\_\*.gms_ and _sc\_\*.gms_ file populating the _\\scen_ folder

### Optimization

* ___core.gms :___ module that takes the input GDX created by _loaddata.gms_, builds and solves the model
  * (Optional) Arguments:
    * `--LOADDATA = 0 (default) or 1` controls whether the _loaddata.gams_ is called before input parameters are loaded into the model (`1`) or not (`0`)
    * `--HORIZON = 2016 (default), 2020, 2030, 2040, 2050 or LTE` defines which year is modelled
    * `--SHORTTERM = 0 (default) or 1` enables investment decisions (`1`) or disables these e.g. when simulating historic years (`0`)
    * `--REGIONS = 1R, ...` controls the ragional scope of the model (check the code for further details on the mapping between the command line options and the correspondin set of countries)
    * `--SI = [string] (default none)` GAMS will load the file _\\scen\\si\_SI.gms_
    * `--SC = [string] (default none)` GAMS will load the file _\\scen\\sc\_SC.gms_
    * `--EXOEXPORT = 0 (default) or 1` controls whether exogenous export profiles either from _exoexport.xlsx_ or if not provided in _exoexport.xlsx_ calculated from historic yearly export data are being used (`1`) or not (`0`) __(version-specific feature)__
    * `--EXOLOAD = 0 (default) or 1` controls whether exogenous demand profiles from _exoload.xlsx_ are being used (`1`) or not (`0`) __(version-specific feature)__
    * ... many others exits. Consult the documentation or the code for further insights

  * Results: the solved model state is either saved as a _\*.g00_ file or directly as a _\*.gdx_ file depending on the used workflow

### Output

* ___output.gms :___ After the model is solved, dumps the model data into an output GDX
  * (Optional) Arguments:
    * `--ONAME = [string] (default EMMA)` defines the name to be used to the _\*.gdx file_  
    * `--OFOLDER = [string]`, if set, stores the outputs in a specific subfolder

  * Result: output file stored as _ONAME.gdx_ or _\\OFOLDER\\ONAME.gdx_

### Additional utilities

This is a an overview of the additional utilities contained in the EMMA repository. Some utilities are tied to a particular workflow. If this is the case, consult the respective workflow section below.

* ___to_sqlite.gms :___ one-liner program that converts a GDX file in an SQLite one.
  * Arguments:
    * `--GDX_FILE = [string]` name (including relative path if file is is a subfolder) of the GDX file to use as source
    * `--SQL_FILE = [string]` name (including relative path if file is is a subfolder) of the SQLite file to be generated

  * Results: output file `SQL_FILE`
* ___analysis.py :___ a python-based module containing various post-processing and data-visualization tools

* ___call.py :___ a python-based utility that is used to generate a set of scenarios that are predefined in YAML file
  * Arguments:
    * `-y [string]` specifies the YAML file that contains the scenario definition

  * Results: created the subfolders _\\\_g00_, _\\\_gdx_, and _\\\_sql_ and stores the simulation files in the respective folder

* ___interlinkage_BSAM.py :___ a python-based post-processing script which reformats output data into BSAM applicable format. __(version-specific feature)__

* ___plot.py :___ a python-based post-processing script which plots output data.

* ___renaming_SENTINEL.py :___ a python-based post-processing module which renames model-internal variables in output tables into a more readable form __(version-specific feature)__

* ___IAMC.ipynb :___ a Jupyter notebook which transforms output data into IAMC format __(version-specific feature)__

* ___\preprocessing\reformat_exogenous_export_profile_Calliope.py :___ a python script which reformats Calliope-modeled export data into export time series usable in _exoexport.xlsx_ __(version-specific feature)__

* ___\preprocessing\extract_exogenous_demand_profile_Calliope.py :___ a python script which extracts Calliope-modeled demand profiles into demand time series usable in _exoload.xlsx_ __(version-specific feature)__

## Scenario overview

In the context of SENTINEL the scenarios of the continental level (European) and the Greek case study are predefined in this Version. The aim of these case studies are "identifying and specifying policy relevant scenarios, along with the respective climate and energy targets, and qualitative narratives to base modeling runs on" (Stavrakas et al. 2021, p.14). Furthermore, it aims at "identifying contextual critical issues and challenges in energy system planning" (Stavrakas et al. 2021, p.14). The scenario-specific input assumptions are defined in _scenarios.gms_ and their simulation specifications are set in _scenarios_SENTINEL_CS_EU.yaml_ and _scenarios_SENTINEL_CS_GR.yaml_.
* ___European Case Study:___ <p>The case study analyzes possible transformations of the European energy system following three different emission pathways from 2030 to 2050. </p>
  * <ins>Current Trends 2030 and 2050:</ins>
      <p>"Although the EU is currently a forerunner on climate, it will only implement the current policies defined in the 2030 energy and climate framework. After 2030 no (global) deal is reached on strengthening policies, and climate policy will stay in line with keeping temperature below 2 °C. Therefore, the existing policy mix is continued leading to similar annual reductions as achieved in the period between 2020 and 2030. EU citizens only take climate measures, if this is cost-effective with a short payback period, and it does not lead to large layoffs in fossil dependent sectors. In terms of technology, blue and green hydrogen production, and smart grids face large barriers for implementation. Only current renewable technologies such as solar PV, wind and biomass are further implemented, and come down in terms of costs" (Stavrakas et al. 2021, p.65).</p>
  * <ins>Carbon Neutrality 2030 and 2050:</ins>
      <p>"The EU implements its 2050 climate neutrality goals that was submitted to the United Nations Framework Convention on Climate Change (UNFCCC) in the Mid-century strategy. Therefore, the total net GHG emissions by 2050 will be around zero. This is also the goal in the sustainable roadmap ‘Green Deal’ that aims to boost the use of efficient resources, restore biodiversity, and cut pollution (European Commission, 2019). The aggregated impacts of all UNFCCC parties prove to be enough to hold the world well below 2 °C or 1.5 °C. This includes overshoot and negative emissions in the second half of this century. Promising technologies become ready for cost effective implementation, and behaviour changes leading to energy savings slowly settle in" (Stavrakas et al. 2021, p.66).</p>
  * <ins>Early Neutrality 2040:</ins>
      <p>"The world chooses to ensure the 1.5 °C goal of the Paris Agreement, and to only accept a very limited amount or no negative emissions. This goal is translated to net zero GHG emissions by 2040 for the EU. The EU ensures that the ambitious climate policy has a bearable impact on all citizens, although large social changes take place. All existing RES technologies decrease in costs quickly, and innovative technologies for negative emissions are scaled rapidly" (Stavrakas et al. 2021, p.66).</p>
* ___Greek Case Study:___ <p>Energy scenarios towards 2030 and 2050 consider the evolution of all sectors and aim at evaluating the challenges for the achievement of the national energy and climate targets, as well as their implications. While the policy targets for the energy sector by 2030 in Greece are well-defined and expressed in the National Energy and Climate Plan (NECP), the pathway to 2050 is still being investigated and various options are analysed in alternative scenarios.</p>
  * <ins>Reference 2030 and 2050:</ins>
      <p>Following the NECP, this scenario aims at lowering the GHG emissions, increasing the RES share and the efficiency of the Greek energy system in the pathway from 2020 to 2030. In the pathway from 2030 to 2050, this scenario assumes a conservative achievement of before mentioned goals.</p>
  * <ins>Renewable Electricity 2050:</ins>
      <p>In this scenario, the pathway described in the reference scenario from 2020 to 2030 is followed, while in the pathway from 2030 to 2050, emphasis is given on the decarbonisation of the electricity system through the installation of variable RES.</p>
  * <ins>Power-to-X 2050:</ins>
      <p>"This scenario follows the pathway described in the reference scenario from 2020 to 2030 as well. RES technologies reach the same level as in the RE scenario, however, not all RES generated electricity is directly consumed. Regarding the pathway from 2030 to 2050, part of the RES generated electricity is used to produce hydrogen and e-fuels or synthetic fuels, as intermediate energy storage commodities, which could further be used for electricity generation through combustion or hydrogen fuel cells" (Stavrakas et al. 2021, p.26).</p>


_Reference:_ __Stavrakas, V., Ceglarz, A., Kleanthis, N., Giannakidis, G., Schibline, A., Süsser, D., Lilliestam, J., Psyrri, A., & Flamos, A. (2021).__ _Case specification and scheduling. Deliverable 7.1. Sustainable Energy Transitions Laboratory (SENTINEL) project._ European Commission. University of Piraeus Research Center (UPRC), Piraeus, Greece.

## Running the case study scenarios
The scenarios are defined in the respective YAML files. They simulations are calucated with the following terminal commands:

* `python call.py -y scenarios_SENTINEL_CS_GR.yaml` (Greek case study)
* `python call.py -y scenarios_SENTINEL_CS_EU.yaml` (EU case study)

To run the following command from the terminal/shell, the GAMS directory needs to be added to the PATH environment variable.
