# The Electricity Market Model EMMA

A detailed model description is published on [Econstor](http://hdl.handle.net/10419/244592). For further information, visit the official model webpage [here](https://emma-model.com/). Depending on your usage and focus, attribution should be given to the description or code as follows:

> Hirth, Lion; Ruhnau, Oliver; Sgarlato, Raffaele (2021): The European Electricity Market Model EMMA - Model Description, ZBW - Leibniz Information Centre for Economics, Kiel, Hamburg. http://hdl.handle.net/10419/244592

> Hirth, Lion; Sgarlato, Raffaele; Ruhnau, Oliver (2021): The European Electricity Market Model EMMA - Model Code. https://github.com/emma-model/EMMA/tree/v1.0

**Versions for specific papers and project** might be available on separate branches:

* [minimum-market-value](https://github.com/emma-model/EMMA/tree/minimum-market-value) - How flexible electricity demand stabilizes wind and solar market values: the case of hydrogen electrolyzers ([link](http://hdl.handle.net/10419/233976))

## Modules overview

EMMA comprises several modules that cover the input, the optimization, and the ouput side of the model.

### Inputs

* ___\\input :___ folder containing the inputs by EMMA in Excel format
  * ___data.xlsx :___ contains mainly technology parameters and yearly figures
  * ___data0.xlsx :___ contains mainly historic data
  * ___data_ts.xlsx :___ contains mainly hourly timeseries data

* ___\\scen:___ folder containing scenario-specific code snippets that can be used to complement the code contained in the _core.gms_ file :
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
    * `--LOADDATA = 0 (default) or 1` controls wheather the _loaddata.gams_ is called before input parameters are loaded into the model (`1`) or not (`0`)
    * `--HORIZON = 2016 (default), 2020, 2030, 2040, 2050 or LTE` defines which year is modelled
    * `--SHORTTERM = 0 (default) or 1` enables investment decisions (`1`) or disables these e.g. when simulating historic years (`0`)
    * `--REGIONS = 1R, ...` controls the ragional scope of the model (check the code for further details on the mapping between the command line options and the correspondin set of countries)
    * `--SI = [string] (default none)` GAMS will load the file _\\scen\\si\_SI.gms_
    * `--SC = [string] (default none)` GAMS will load the file _\\scen\\sc\_SC.gms_
    * ... many others exits. Consult the documentation or the code for further insights

  * Results: the solved model state is either saved as a _\*.g00_ file or directly as a _\*.gdx_ file depending on the used workflow

### Output

* ___output.gms :___ After the model is solved, dumps the model data into an output GDX
  * (Optional) Argumments:
    * `--ONAME = [string] (default EMMA)` defines the name to be used to the _\*.gdx file_  
    * `--OFOLDER = [string]`, if set, stores the outputs in a specific subfolder

  * Result: output file stored as _ONAME.gdx_ or _\\OFOLDER\\ONAME.gdx_

### Additional utilities

This is a an overview of the additional utilities contained in the EMMA repository. Some utilities are tied to a particular workflow. If this is the case, consult the respective workflow section below.

* ___call.py :___ a python-based utility that is used to generate a set of scenarios that are predefined in YAML file
  * Arguments:
    * `-y [string]` specifies the YAML file that contains the scenario definition

  * Results: created the subfolders _\\\_g00_, _\\\_gdx_, and _\\\_sql_ and stores the simulation files in the respecitive folder

* ___to_sqlite.gms :___ one-liner program that converts a GDX file in an SQLite one.
  * Arguments:
    * `--GDX_FILE = [string]` name (including relative path if file is is a subfolder) of the GDX file to use as source
    * `--SQL_FILE = [string]` name (including relative path if file is is a subfolder) of the SQLite file to be generated

  * Results: output file `SQL_FILE`

## Getting started

The workflow to use when working with EMMA depends on the level of control required to generate scenarios and the number of scenarios. To run the following command from the terminal/shell, the GAMS directory needs to be added to the PATH environment variable.

### One simulation

This workflow is used when only one simulation is required. The toggles a `--LOADDATA=1` and `--DUMPDATA=1` are used to runs the required inputs and output modules.

`gams core.gms --LOADDATA=1 --DUMPDATA=1 ...`

### Multiple simulations with Python

Create a YAML file to define your simulationa and execute these simulations using the `call.py` file.

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

Then, call the utility from the command line (of course, replace the _scenarios\_DEMO.yaml_ with the file of your choice):

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

Jarusch Müßel

* Input assumptions

Feedback, remarks, bug reportings, and suggestions are highly welcome!
