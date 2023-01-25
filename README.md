# The Electricity Market Model EMMA

A detailed model description is published on [Econstor](http://hdl.handle.net/10419/244592). For further information, visit the official model webpage [here](https://emma-model.com/). Depending on your usage and focus, attribution should be given to the description or code as follows:

> Hirth, Lion; Ruhnau, Oliver; Sgarlato, Raffaele (2021): The European Electricity Market Model EMMA - Model Description, ZBW - Leibniz Information Centre for Economics, Kiel, Hamburg. http://hdl.handle.net/10419/244592

> Hirth, Lion; Sgarlato, Raffaele; Ruhnau, Oliver (2021): The European Electricity Market Model EMMA - Model Code. https://github.com/emma-model/EMMA/tree/v1.0

**Versions for specific papers and project** might be available on separate branches:

* [minimum-market-value](https://github.com/emma-model/EMMA/tree/minimum-market-value) - How flexible electricity demand stabilizes wind and solar market values: the case of hydrogen electrolyzers (see [article](http://hdl.handle.net/10419/233976))
* [SENTINEL](https://github.com/emma-model/EMMA/tree/projects/SENTINEL) - An EU-funded project aimed at developing a new set of energy modelling tools to represent and analyse drivers and barriers towards decarbonisation and integration of fluctuating renewable power sources (see [website](https://sentinel.energy/))

## Modules overview

Key functionalities of the SENTINEL version of EMMA can be found in:

-   **_\emma :_**
    
    -   **_dashboard_DEMO.ipynb :_**  A dashboard highlighting major findings of the case studies
    -   **_call.py :_**  a python-based utility that is used to generate a set of scenarios that are predefined in YAML file
    -   Arguments:
        
        -   `-y [string]`  specifies the YAML file that contains the scenario definition
        -   `-s [{load,solve,gdx,sql}]`  skips one or a combination of steps
        -   `-v`  verbose view of the GAMS log files in the console
    -   Results: created a subfolder in \emma\core for every scenario_id and stores the simulation files in the respective folder
        
    -   ___*.yaml :___ Scenario defining yaml files

The modules of the vanilla-version are organized in \emma\core. A series of python-integrated tests have been introduced in \emma\test using pytest concentrating on the technical functionality of the model.
        
### Core

The EMMA model comprises of several modules that cover the input, the optimization, and the output side of the model which can be found in  **_\emma\core_**.

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
    -   `--EXOEXPORT = 0 (default) or 1`  controls whether scenario-related exogenous export profiles are used (`1`, profiles have to be provided using the file _exoexport.xlsx_) or not (`0`, profiles are calculated from historic export data). Scenario-unrelated profiles has to be marked by 'DEFAULT'.
    -   `--EXOLOAD = 0 (default) or 1`  controls whether scenario-related exogenous demand profiles from  _exoload.xlsx_  are being used (`1`) or not (`0`). Scenario-unrelated profiles has to be marked by 'DEFAULT'.
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
    -   **_plot.py :_**  a python-based post-processing script which plots output data.
    -   **_renaming.py :_**  a python-based post-processing module which renames model-internal variables in output tables into a more readable form

## Getting started

The workflow to use when working with EMMA depends on the level of control required to generate scenarios and the number of scenarios. To run the following command from the terminal/shell, the GAMS directory needs to be added to the PATH environment variable.

### One simulation

This workflow is used when only one simulation is required. The commands have to entered from the  **\emma\core** folder. The toggles a `--LOADDATA=1` and `--DUMPDATA=1` are used to runs the required inputs and output modules.

`gams core.gms --LOADDATA=1 --DUMPDATA=1 ...`

### Multiple simulations with Python

Create a YAML file to define your simulations and execute these simulations using the `call.py` file which can be found in the **\emma** folder.

The YAML file has to be structured as follow:

```yaml
scenarios:
  scen1:                # use this as the scenario id         
    name: baseline      # any descriptive name associated to the scenario          
    active: True        # if toggled off, scenario will be skipped by the call.py
    clp:                # a list of command line options to be used...
      --HORIZON: 2016   # ...such as the horizion...
      --SHORTTERM: 1    # ...or the shortterm toggle.
  scen2:
    name: future scenario
    active: True
    clp:
      --HORIZON: 2050

# default
default_clp:            # default command line options passed to all scenarios (if not specified)...
  --HOURS: 8760         # ...suche as the number of hours to be modelled...
  --WeatherYEAR: 2016   # ...or the weather year to be used.
```

Then, call the utility from the command line (of course, replace the _scenarios\_DEMO.yaml_ with the file of your choice) from the **\emma** folder:

`python call.py -y scenarios_DEMO.yaml`


## Contributors

Lion Hirth

* Development of the first EMMA version
* Supervision of further development

Raffaele Sgarlato

* Model architecture
* Feature expansion
* Advanced analytics

Oliver Ruhnau

* Feature expansion
* Input assumptions

Cornelis Savelsberg

* Data visualisations
* Feature expansion

Jarusch Müßel

* Input assumptions

Feedback, remarks, bug reportings, and suggestions are highly welcome!
