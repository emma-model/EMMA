# EMMA
The Electricity Market Model EMMA is a techno-economic model of the integrated Northwestern European power system. It models investment, dispatch, and trade decisions, minimizing total costs subject to a large set of technical constraints. In economic terms, it is a partial equilibrium model of the wholesale electricity market with a focus on the supply side. It calculates scenario-based or long-term optima (equilibria) and estimates the corresponding capacity mix as well as hourly prices, generation, consumption of flexible electrolyzers, and cross-border trade for each market area. Technically, EMMA is a linear program, written in GAMS and solved by CPLEX on a desktop computer in about one hour. EMMA has been applied for several peer-reviewed publications to address a range of research questions. It is also used for consulting projects and policy assessment. For further information, please refer to https://emma-model.com/.

# Versions
A revised **master version** is under development and will be released on this branch. 

Meanwhile, the latest **paper-specific version**, which focuses on variable renewables and flexible hydrogen electrolyzers, is available on the [minimum-market-value](https://github.com/emma-model/EMMA/tree/minimum-market-value) branch.

# Contributors
* Lion Hirth, Hertie School and Neon Neue Energieökonomik GmbH, hirth@neon-energie.de
* Oliver Ruhnau, Hertie School, ruhnau@hertie-school.org
* Raffaele Sgarlato, Hertie School, sgarlato@hertie-school.org

Feedback, remarks, bug reportings, and suggestions are highly welcome!

# Attribution
Attrubution should be given as follows:
* Hirth, L., Ruhnau, O., and Sgarlato, R. (2020). The European Electricity Market Model EMMA - Model Description.

For paper-specific versions of EMMA, please also provide attribution to the corresponding paper.
