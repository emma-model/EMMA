# 
# The Electricity Market Model EMMA - Version SENTINEL

A detailed model description is published on  [Econstor](http://hdl.handle.net/10419/244592 "Model Description"). For further information, visit the official model webpage  [here](https://emma-model.com/). Depending on your usage and focus, attribution should be given to the description or code as follows:

> Hirth, Lion; Ruhnau, Oliver; Sgarlato, Raffaele (2021): The European Electricity Market Model EMMA - Model Description, ZBW - Leibniz Information Centre for Economics, Kiel, Hamburg. http://hdl.handle.net/10419/244592
> 
> Hirth, Lion; Sgarlato, Raffaele; Ruhnau, Oliver (2021): The European Electricity Market Model EMMA - Model Code. https://github.com/emma-model/EMMA/tree/v1.0

**This project has received funding from the European Union's Horizon 2020 research and innovation programme under grant agreement No 837089.**

## This version

This version incorporates features developed within the Sustainable Energy Transitions Laboratory (SENTINEL) project which is a new modeling framework. The SENTINEL framework will be modular in structure incorporating many separate models which will look in detail at specific technological, geographic, and societal aspects of the transition to a low-carbon energy system. The models will be able to be linked together to answer a wide range of different questions.

### Version-specific contributions

-   Cornelis Savelsberg: conceptualization, feature extensions, visualisations
-   Raffaele Sgarlato: conceptualization, feature extensions

## Modules overview

Key functionalities of the SENTINEL version of EMMA can be found in:

-   **_\emma :_**
    
    -   **_dashboard_SENTINEL.ipynb :_**  A dashboard highlighting major findings of the case studies
    -   **_call.py :_**  a python-based utility that is used to generate a set of scenarios that are predefined in YAML file
    -   Arguments:
        
        -   `-y [string]`  specifies the YAML file that contains the scenario definition
        -   `-s [{load,solve,gdx,sql}]`  skips one or a combination of steps
        -   `-v`  verbose view of the GAMS log files in the console
    -   Results: created a subfolder in \emma\core for every scenario_id and stores the simulation files in the respective folder
        
    -   ___*.yaml :___ Scenario defining yaml files

The modules of the vanilla-version are organized in \emma\core. Version-specific extensions are preprocessing and postprocessing tools found in \emma\preprocess and \emma\postprocess, respectively. These tools can among other things be used to soft link EMMA to the SENINTEL partner models EURO-Calliope and BSAM. Furthermore, a series of python-integrated tests have been introduced in \emma\test using pytest concentrating on the technical functionality of the model.

### Preprocess

-   **_\emma\preprocess :_**
    
    -   **_reformat_exogenous_export_profile_Calliope.py :_**  a python script which reformats Calliope-modeled export data into export time series usable in  _exoexport.xlsx_  **(version-specific feature)**
        
    -   **_extract_exogenous_demand_profile_Calliope.py :_**  a python script which extracts Calliope-modeled demand profiles into demand time series usable in  _exoload.xlsx_  **(version-specific feature)**
        

### Core

This includes the vanilla-version of the EMMA model comprising several modules that cover the input, the optimization, and the output side of the model which can be found in  **_\emma\core_**.

#### Inputs

-   **_\input :_**  folder containing the inputs by EMMA in Excel format
    
    -   **_data.xlsx :_**  contains mainly technology parameters and yearly figures
    -   **_data0.xlsx :_**  contains mainly historic data
    -   **_data_ts.xlsx :_**  contains mainly hourly timeseries data
    -   **_exoexport.xlsx :_**  contains hourly timeseries of exogenous export profiles 
    -   **_exoload.xlsx :_**  contains hourly timeseries of exogenous demand profiles  
-   **_\scen :_**  folder containing scenario-specific code snippets that can be used to complement the code contained in the  _core.gms_  file :
    
    -   **_si_*.gms :_**  files that are loaded into the  _core.gms_  code after the inputs are loaded, hence, geared towards input editing
    -   **_sc_*.gms :_**  files that are loaded into the  _core.gms_  code after the mathematical equations are formulated, hence, geared towards complementing the mathematical model
-   **_loaddata.gms :_**  module that converts the Excel data into GDX format
    
    -   (Optional) Arguments:  `None`
    -   Result:  _data.gdx_,  _data0.gdx_  and  _data_ts.gdx_
-   **_scenarios.gms :_**  module that is used to generate  _.gms_  scenario files in the folder
    
    -   (Optional) Arguments:  `None`
    -   Result:  _si_*.gms_  and  _sc_*.gms_  file populating the  _\scen_  folder

#### Optimization

-   **_core.gms :_**  module that takes the input GDX created by  _loaddata.gms_, builds and solves the model
    
    -   (Optional) Arguments:
    -   `--LOADDATA = 0 (default) or 1`  controls whether the  _loaddata.gams_  is called before input parameters are loaded into the model (`1`) or not (`0`)
    -   `--HORIZON = 2016 (default), 2020, 2030, 2040, 2050 or LTE`  defines which year is modelled
    -   `--SHORTTERM = 0 (default) or 1`  enables investment decisions (`1`) or disables these e.g. when simulating historic years (`0`)
    -   `--REGIONS = 1R, ...`  controls the regional scope of the model (check the code for further details on the mapping between the command line options and the corresponding set of countries)
    -   `--SI = [string] (default none)`  GAMS will load the file  _\scen\si_SI.gms_
    -   `--SC = [string] (default none)`  GAMS will load the file  _\scen\sc_SC.gms_
    -   `--EXOEXPORT = 0 (default) or 1`  controls whether exogenous export profiles are used (`1`, profiles have to be provided using the file _exoexport.xlsx_) or not (`0`, profiles are calculated from historic export data). 
    -   `--EXOLOAD = 0 (default) or 1`  controls whether exogenous demand profiles from  _exoload.xlsx_  are being used (`1`) or not (`0`)  
    -   ... many others exits. Consult the documentation or the code for further insights
        
    -   Results: the solved model state is either saved as a  _*.g00_  file or directly as a  _*.gdx_  file depending on the used workflow
        

#### Output

-   **_output.gms :_**  After the model is solved, the model data is dumped into an output GDX
    
    -   (Optional) Arguments:
    -   `--ONAME = [string] (default EMMA)`  defines the name to be used to the  _*.gdx file_
    -   `--OFOLDER = [string]`, if set, stores the outputs in a specific subfolder
        
    -   Result: output file stored as  _ONAME.gdx_  or  _\OFOLDER\ONAME.gdx_
        

#### Additional utilities

-   **_to_sqlite.gms :_**  one-liner program that converts a GDX file in an SQLite one.
    
    -   Arguments:
    -   `--GDX_FILE = [string]`  name (including relative path if file is in a subfolder) of the GDX file to be used as source
    -   `--SQL_FILE = [string]`  name (including relative path if file is in a subfolder) of the SQLite file to be generated
        
    -   Results: output file  `SQL_FILE`
        

### Postprocess

-   **_\emma\postprocess :_**
    -   **_analysis.py :_**  a python-based module containing various post-processing and data-visualization tools
    -   **_datahandler.py :_**  a python-based module to access tables from SQL files
    -   **_IAMC_script.py :_**  a python-based module to soft link EMMA  **(version-specific feature)**
    -   **_plot.py :_**  a python-based post-processing script which plots output data.
    -   **_renaming_SENTINEL.py :_**  a python-based post-processing module which renames model-internal variables in output tables into a more readable form  **(version-specific feature)**

## Scenario overview

In the context of SENTINEL the scenarios of the continental level (European) and the Greek case study are predefined in this version. The aim of these case studies are "identifying and specifying policy relevant scenarios, along with the respective climate and energy targets, and qualitative narratives to base modeling runs on" (Stavrakas et al. 2021, p.14). Furthermore, it aims at "identifying contextual critical issues and challenges in energy system planning" (Stavrakas et al. 2021, p.14). The scenario-specific input assumptions are defined in  _scenarios.gms_  and their simulation specifications are set in  _scenarios_SENTINEL_CS_EU.yaml_  and  _scenarios_SENTINEL_CS_GR.yaml_. *  **_European Case Study:_**

The case study analyzes possible transformations of the European energy system following three different emission pathways from 2030 to 2050.

* <ins>Current Trends 2030 and 2050:</ins>

"Although the EU is currently a forerunner on climate, it will only implement the current policies defined in the 2030 energy and climate framework. After 2030 no (global) deal is reached on strengthening policies, and climate policy will stay in line with keeping temperature below 2 °C. Therefore, the existing policy mix is continued leading to similar annual reductions as achieved in the period between 2020 and 2030. EU citizens only take climate measures, if this is cost-effective with a short payback period, and it does not lead to large layoffs in fossil dependent sectors. In terms of technology, blue and green hydrogen production, and smart grids face large barriers for implementation. Only current renewable technologies such as solar PV, wind and biomass are further implemented, and come down in terms of costs" (Stavrakas et al. 2021, p.65).

* <ins>Carbon Neutrality 2030 and 2050:</ins>

"The EU implements its 2050 climate neutrality goals that was submitted to the United Nations Framework Convention on Climate Change (UNFCCC) in the Mid-century strategy. Therefore, the total net GHG emissions by 2050 will be around zero. This is also the goal in the sustainable roadmap ‘Green Deal’ that aims to boost the use of efficient resources, restore biodiversity, and cut pollution (European Commission, 2019). The aggregated impacts of all UNFCCC parties prove to be enough to hold the world well below 2 °C or 1.5 °C. This includes overshoot and negative emissions in the second half of this century. Promising technologies become ready for cost effective implementation, and behaviour changes leading to energy savings slowly settle in" (Stavrakas et al. 2021, p.66).

* <ins>Early Neutrality 2040:</ins>

"The world chooses to ensure the 1.5 °C goal of the Paris Agreement, and to only accept a very limited amount or no negative emissions. This goal is translated to net zero GHG emissions by 2040 for the EU. The EU ensures that the ambitious climate policy has a bearable impact on all citizens, although large social changes take place. All existing RES technologies decrease in costs quickly, and innovative technologies for negative emissions are scaled rapidly" (Stavrakas et al. 2021, p.66).

* **_Greek Case Study:_**

Energy scenarios towards 2030 and 2050 consider the evolution of all sectors and aim at evaluating the challenges for the achievement of the national energy and climate targets, as well as their implications. While the policy targets for the energy sector by 2030 in Greece are well-defined and expressed in the National Energy and Climate Plan (NECP), the pathway to 2050 is still being investigated and various options are analysed in alternative scenarios.

* <ins>Reference 2030 and 2050:</ins>

Following the NECP, this scenario aims at lowering the GHG emissions, increasing the RES share and the efficiency of the Greek energy system in the pathway from 2020 to 2030. In the pathway from 2030 to 2050, this scenario assumes a conservative achievement of before mentioned goals.

* <ins>Renewable Electricity 2050:</ins>

In this scenario, the pathway described in the reference scenario from 2020 to 2030 is followed, while in the pathway from 2030 to 2050, emphasis is given on the decarbonisation of the electricity system through the installation of variable RES.

* <ins>Power-to-X 2050:</ins>

"This scenario follows the pathway described in the reference scenario from 2020 to 2030 as well. RES technologies reach the same level as in the RE scenario, however, not all RES generated electricity is directly consumed. Regarding the pathway from 2030 to 2050, part of the RES generated electricity is used to produce hydrogen and e-fuels or synthetic fuels, as intermediate energy storage commodities, which could further be used for electricity generation through combustion or hydrogen fuel cells" (Stavrakas et al. 2021, p.26).

_Reference:_  **Stavrakas, V., Ceglarz, A., Kleanthis, N., Giannakidis, G., Schibline, A., Süsser, D., Lilliestam, J., Psyrri, A., & Flamos, A. (2021).**  _Case specification and scheduling. Deliverable 7.1. Sustainable Energy Transitions Laboratory (SENTINEL) project._  European Commission. University of Piraeus Research Center (UPRC), Piraeus, Greece.

## Workflow

### Running the case study scenarios

The scenarios are defined in the respective YAML files in  **_\emma_**. From the  **\emma**  folder, simulations can be calculated with the following terminal commands:

-   `python call.py -y scenarios_SENTINEL_CS_GR.yaml`  (Greek case study)
-   `python call.py -y scenarios_SENTINEL_CS_EU.yaml`  (EU case study)

**Note**  that to run the following command from the terminal/shell, the GAMS directory needs to be added to the PATH environment variable.




