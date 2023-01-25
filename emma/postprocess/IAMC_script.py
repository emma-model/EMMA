import os
from datetime import datetime, timedelta

import matplotlib.pyplot as plt
import pandas as pd
from call import CWD, Scenarios
from pandas import ExcelFile, ExcelWriter

from postprocess.analysis import (
    electricity_balance,
    hydrogen_balance,
    market_value,
    pdc_pivot,
    total_investment_costs,
)
from postprocess.datahandler import DataHandler, get_table
from postprocess.plot import (
    draw_legend,
    stacked_bar_chart,
    renaming_map_techs,
    colors_techs,
)
from postprocess.renaming_SENTINEL import rename_df_index
from postprocess.tools import add_zeros, change_tec_lvl_name_to_alltec

OUTPUTDIR = os.path.join(CWD, "postprocess\output")


def call_DataHandler(scenario_file: str):
    """
    Function to return a DataHandler initialized with scenarios of the scenario_file
    """
    scenarios = Scenarios(scenario_file + ".yaml")
    return DataHandler(scenarios)


def extract_capacity():
    """
    Function to extract, rename and pivot the total capacity for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")
    capa = dh.get("o_capa")
    capa = rename_df_index(capa)
    capa["Unit"] = "GW"
    capa = capa.reset_index().set_index(["Technologies", "Vintage", "Region", "Unit"])

    outputfile = os.path.join(OUTPUTDIR, "Capacity_total.csv")
    capa.to_csv(outputfile)


def extract_electricity_balance():
    """
    Function to extract, rename and pivot the electricity balance for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")

    df = electricity_balance(dh)
    df = rename_df_index(df)
    df["Unit"] = "GWh"
    df = df.reset_index().set_index(["Region", "Type", "Unit"])

    outputfile = os.path.join(OUTPUTDIR, "Electricity_balance.csv")
    df.to_csv(outputfile)


def extract_electricity_prices():
    """
    Function to extract, rename and pivot the electricity prices for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")

    df = dh.get("o_prices")
    df = rename_df_index(df)
    df["Unit"] = "EUR/MWh"
    df = df.reset_index().set_index(["Time ID", "Region", "Unit"])

    outputfile = os.path.join(OUTPUTDIR, "Electricity_price.csv")
    df.to_csv(outputfile)


def extract_hydrogen_price():
    """
    Function to extract, rename and pivot the hydrogen prices for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")

    h2_price = dh.get("o_h2price_buy")
    h2_price = rename_df_index(h2_price)
    h2_price["Unit"] = "EUR"
    h2_price = h2_price.reset_index().set_index(["Region", "Unit"])

    outputfile = os.path.join(OUTPUTDIR, "H2price_buy.csv")
    h2_price.to_csv(outputfile)


def extract_CO2_price():
    """
    Function to extract, rename and pivot the CO2 prices for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")

    co2_price = dh.get("o_co2price")
    co2_price = rename_df_index(co2_price)
    co2_price["Unit"] = "EUR"
    co2_price = co2_price.reset_index().set_index(["Region", "Unit"])

    outputfile = os.path.join(OUTPUTDIR, "CO2price.csv")
    co2_price.to_csv(outputfile)


def extract_batt_duration():
    """
    Function to extract, rename and pivot the battery duration for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")

    df = dh.get("o_stoinv")
    df = rename_df_index(df)
    df["Unit"] = ["GW", "GWh"]
    df = df.reset_index().set_index(
        ["Technologies", "Type", "Vintage", "Region", "Unit"]
    )
    df.loc[("Batteries", "Duration", "newbuild", "Greece", "h")] = (
        df.iloc[1, :] / df.iloc[0, :]
    )

    outputfile = os.path.join(OUTPUTDIR, "Battery_duration.csv")
    df.to_csv(outputfile)


def extract_shed():
    """
    Function to extract, rename and pivot the shed capacity for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")

    df = dh.get("o_supply")
    df = df.xs("shed", level="tec_supply", drop_level=False)
    df = rename_df_index(df)
    df["Unit"] = "GWh"
    df = df.reset_index().set_index(
        ["Time ID", "Technologies", "Vintage", "Region", "Unit"]
    )
    df.loc[("max", "Load shedding", "newbuild", "Greece", "GWh")] = df.max()

    outputfile = os.path.join(OUTPUTDIR, "max_shed.csv")
    df.to_csv(outputfile)


def extract_emissions():
    """
    Function to extract, rename and pivot the total emissions for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    dh = call_DataHandler("scenarios_SENTINEL_CS_GR")

    df = dh.get("o_emissions")
    df = rename_df_index(df)
    df["Unit"] = "Mt"
    df = df.reset_index().set_index(["Technologies", "Region", "Unit"])

    outputfile = os.path.join(OUTPUTDIR, "Emissions.csv")
    df.to_csv(outputfile)


def extract_BSAM_data():
    """
    Function to extract, rename and pivot all BSAM related data for the Greek Case Study in a BSAM convinient way and save it as csv file in OUTPUTDIR.
    """
    extract_capacity()
    extract_electricity_balance()
    extract_electricity_prices()
    extract_hydrogen_price()
    extract_CO2_price()
    extract_batt_duration()
    extract_emissions()


index = ["Model", "Scenario", "Region", "Updated code", "Unit", "Year"]

maps = {
    "technology": {
        "all_CCS": "|CCS",
        "all_coal": "|Coal",
        "all_coal_CCS": "|Coal|CCS",
        "CCGT": "|Gases|Fossil|Natural gas",
        "CCGT_H2": "|Gases|Hydrogen",
        "OCGT": "|Gases|Fossil|Natural gas",
        "OCGT_H2": "|Gases|Hydrogen",
        "PHS": "|Electricity Storage|Medium Duration",
        "PtHydrogen": "|Electricity",
        "batr": "|Electricity Storage|Short Duration",
        "sto": "|Electricity Storage",
        "bio": "|Solar bio and waste",
        "coal": "|Coal|Hard Coal",
        "hydr": "|Hydro|dam",
        "hyd": "|Hydro",
        "lign": "|Coal|Brown Coal|Lignite",
        "lign_CCS": "|Coal|Brown Coal|Lignite|CCS",
        "coal_CCS": "|Coal|Hard Coal|CCS",
        "CCGT_CCS": "|Gases|Fossil|Natural gas|CCS",
        "nucl": "|Nuclear",
        "ror": "|Hydro|river",
        "shed": "flex_est_und",
        "solar": "|Solar",
        "wind": "|Wind",
        "wiof": "|Wind|Offshore",
        "wion": "|Wind|Onshore",
        "ntc": "|Interconnect Importing Capacity",
        "all": "",
    },
    "scenario_name": {
        "2016": "Reference_year",
        "2030_EU_CT": "Current trends",
        "2050_EU_CT": "Current trends",
        "2030_EU_CN": "Climate neutrality",
        "2050_EU_CN": "Climate neutrality",
        "2040_EU_EN": "Early neutrality",
    },
    "categories": {
        "Electricity": [
            "CCGT",
            "CCGT_H2",
            "OCGT",
            "OCGT_H2",
            "bio",
            "coal",
            "hydr",
            "lign",
            "lign_CCS",
            "coal_CCS",
            "CCGT_CCS",
            "nucl",
            "ror",
            "solar",
            "wiof",
            "wion",
        ],
        "Flexibility": ["batr", "PHS", "ntc"],
        "Hydrogen": ["PtHydrogen"],
        "Heat": [
            "lign",
            "lign_CCS",
            "coal",
            "coal_CCS",
            "CCGT",
            "OCGT",
            "CCGT_CCS",
            "CCGT_H2",
            "OCGT_H2",
        ],
    },
    "categories_agg_techs": {
        "Electricity": ["all", "all_CCS", "all_coal", "all_coal_CCS", "hyd", "wind"],
        "Flexibility": ["sto"],
        "Hydrogen": [],
        "Heat": ["all", "all_CCS", "all_coal", "all_coal_CCS"],
    },
    "aggregated_techs": {
        "all": [
            "CCGT",
            "CCGT_H2",
            "OCGT",
            "OCGT_H2",
            "bio",
            "coal",
            "hydr",
            "lign",
            "lign_CCS",
            "coal_CCS",
            "CCGT_CCS",
            "nucl",
            "ror",
            "shed",
            "solar",
            "wiof",
            "wion",
        ],
        "all_CCS": ["CCGT_CCS", "coal_CCS", "lign_CCS"],
        "all_coal": ["coal", "lign"],
        "all_coal_CCS": ["lign_CCS", "coal_CCS"],
        "sto": ["batr", "PHS"],
        "hyd": ["ror", "hydr"],
        "wind": ["wiof", "wion"],
    },
    "unit_per_category": {
        "Installed capacity": "GW",
        "Generation|Yearly": "GWh",
        "Generation|Summer peak": "GWh",
        "Generation|Winter peak": "GWh",
        "Generation|Percentile 25": "GWh",
        "Generation|Percentile 50": "GWh",
        "Fuel consumption": "TJ/year",
        "Efficiency": "dimensionless",
        "Emissions|Kyoto Gases|Fossil|CO2": "Mt CO2/year",
        "Investments": "Time frame,  billion Euros (PPP, 2015)",
    },
}


def replace(val, d: dict, prepend: str = "", check: bool = True):
    try:
        return prepend + str(d[val])
    except KeyError:
        if check:
            raise
        else:
            return val


def map_level(idx, dct, level=0):
    new_idx = idx.set_levels(
        [
            [dct.get(item, item) for item in names] if i == level else names
            for i, names in enumerate(idx.levels)
        ]
    )
    return new_idx


def create_expanded_tech_MultiIndex(mI, category):
    i = [
        mI.get_level_values(name).unique()
        for name in mI.names
        if name not in ["alltec", "scenario"]
    ]
    i_alltec = mI.names.index("alltec")
    i.insert(i_alltec, maps["categories"][category])
    i_scenario = mI.names.index("scenario")
    i.insert(i_scenario, maps["scenario_name"].keys())
    return pd.MultiIndex.from_product(i, names=mI.names)


def add_zeros_category(df, category):
    i = [x for x in df.columns if x != 0]
    df = df.set_index(i)

    mI = create_expanded_tech_MultiIndex(df.index, category)

    df = df.reindex(mI, fill_value=0).reset_index()
    return df


def aggregate_techs(df, agg_list):
    id_list = [cols for cols in df.columns if cols not in ["alltec", 0]]
    for agg_tech in agg_list:
        df = pd.concat(
            [
                df,
                df[df["alltec"].isin(maps["aggregated_techs"][agg_tech])]
                .groupby(id_list)
                .sum()
                .assign(alltec=agg_tech)
                .reset_index(),
            ]
        )
    return df


def add_index_cols(df, prefix, preprefix, scenarios, to_scenarioID):
    ident = prefix + "|" + preprefix
    df["Updated code"] = df["alltec"].apply(
        lambda x: replace(x, prepend=ident, d=maps["technology"])
    )
    df["Scenario"] = df["scenario"].map(maps["scenario_name"])
    df["Year"] = df["scenario"].apply(
        lambda x: "Y_" + str(scenarios[to_scenarioID[x]]["clp"]["--HORIZON"])
    )
    df["Model"] = "EMMA"
    df["Unit"] = maps["unit_per_category"][prefix]
    df["Region"] = df["r"]
    return df


def rename_et_al(df, category, prefix, scenarios, to_scenarioID):
    df = df.astype({0: "float64"})
    df = add_zeros_category(df, category)
    df = aggregate_techs(df, maps["categories_agg_techs"][category])
    df = add_index_cols(df, prefix, category, scenarios, to_scenarioID)
    return df


def create_descending_demand_index(dh: DataHandler):
    exo_demand = dh.get("o_load").xs("GER", level="r")
    endo_demand = dh.get("o_demand").xs("GER", level="r").groupby(["t"]).sum().fillna(0)

    demand = exo_demand.add(endo_demand)

    descending_demand_index = {
        scen: demand[scen].sort_values(ascending=False).index.values
        for scen in demand.columns
    }
    descending_demand_index = pd.DataFrame(descending_demand_index)
    return descending_demand_index


def iamc_installed_capacity(dh: DataHandler, to_scenarioID):
    prefix = "Installed capacity"

    df = dh.get("o_capa").xs("GER", level="r", drop_level=False).stack().reset_index()
    df = df[df["alltec"] != "shed"]

    df_chp = (
        dh.get("o_capachp").xs("GER", level="r", drop_level=False).stack().reset_index()
    )
    df_chp.columns = change_tec_lvl_name_to_alltec(df_chp.columns)
    df_chp = df_chp[df_chp["alltec"] != "shed"]

    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    ntc_capa = (
        dh.get("o_ntc_capa")
        .groupby(["r"])
        .sum()
        .reset_index()
        .assign(alltec="ntc", allvin=1)
        .melt(id_vars=["alltec", "allvin", "r"], value_name=0)
    )
    ntc_capa = ntc_capa[ntc_capa["r"] == "GER"]
    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    flex = pd.concat([flex, ntc_capa])
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = df[df["alltec"].isin(maps["categories"]["Hydrogen"])]
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    heat = rename_et_al(df_chp, "Heat", prefix, dh.scenarios.params, to_scenarioID)

    df = pd.concat([elec, flex, heat, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")  # .to_csv('test.csv')
    return df


def iamc_yearly_generation(dh: DataHandler, to_scenarioID):
    prefix = "Generation|Yearly"

    df = (
        dh.get("o_supply")
        .xs("GER", level="r", drop_level=False)
        .groupby(["tec_supply", "allvin", "r"])
        .sum()
        .stack()
        .reset_index()
    )
    df.columns = change_tec_lvl_name_to_alltec(df.columns)
    df = df[df["alltec"] != "shed"]
    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    flow = (
        dh.get("o_flow")
        .groupby(["r"])
        .sum()
        .mul(-1)
        .reset_index()
        .assign(alltec="ntc", allvin=1)
        .melt(id_vars=["alltec", "allvin", "r"], value_name=0)
    )
    flow = flow[flow["r"] == "GER"]
    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    flex = pd.concat([flex, flow])
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = (
        dh.get("o_demand")
        .xs("GER", level="r", drop_level=False)
        .xs("PtHydrogen", level="tec_demand", drop_level=False)
    )
    eff = dh.get("eff").loc["PtHydrogen", :]
    hydrogen = pd.concat(
        [hydrogen[col].mul(eff[col]) for col in hydrogen.columns], axis=1
    )
    hydrogen.columns = eff.index
    hydrogen = hydrogen.stack().reset_index()
    hydrogen.columns = change_tec_lvl_name_to_alltec(hydrogen.columns)
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, flex, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")  # .to_csv('test.csv')

    return df


def iamc_summer_peak_hourly_generation(dh: DataHandler, to_scenarioID):
    prefix = "Generation|Summer peak"

    exo_demand = dh.get("o_load").xs("GER", level="r")
    endo_demand = dh.get("o_demand").xs("GER", level="r").groupby(["t"]).sum().fillna(0)

    summer_peak = (
        exo_demand.add(endo_demand).loc[list(range(172 * 24, 264 * 24 + 1))].idxmax()
    )

    df = dh.get("o_supply").xs("GER", level="r", drop_level=False)
    df = pd.concat(
        [df.xs(summer_peak[col], level="t")[col] for col in df.columns],
        axis=1,
    )
    df.columns = df.columns.rename("scenario")
    df = df.stack().reset_index()
    df.columns = change_tec_lvl_name_to_alltec(df.columns)
    df = df[df["alltec"] != "shed"]

    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    flow = (
        dh.get("o_flow")
        .groupby(["t", "r"])
        .sum()
        .xs("GER", level="r", drop_level=False)
        .mul(-1)
    )
    flow = pd.concat(
        [flow.xs(summer_peak[col], level="t")[col] for col in flow.columns],
        axis=1,
    )
    flow.columns = flow.columns.rename("scenario")
    flow = flow.stack().reset_index().assign(alltec="ntc", allvin=1)

    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    flex = pd.concat([flex, flow])
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = (
        dh.get("o_demand")
        .xs("GER", level="r", drop_level=False)
        .xs("PtHydrogen", level="tec_demand", drop_level=False)
    )
    eff = dh.get("eff").loc["PtHydrogen", :]
    hydrogen = pd.concat(
        [
            hydrogen.xs(summer_peak[col], level="t")[col].mul(eff[col])
            for col in hydrogen.columns
        ],
        axis=1,
    )
    hydrogen.columns = eff.index
    hydrogen = hydrogen.stack().reset_index()
    hydrogen.columns = change_tec_lvl_name_to_alltec(hydrogen.columns)
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, flex, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")


def iamc_winter_peak_hourly_generation(dh: DataHandler, to_scenarioID):
    prefix = "Generation|Winter peak"

    exo_demand = dh.get("o_load").xs("GER", level="r")
    endo_demand = dh.get("o_demand").xs("GER", level="r").groupby(["t"]).sum().fillna(0)

    winter_peak = (
        exo_demand.add(endo_demand)
        .loc[list(range(1, 79 * 24)) + list(range(355 * 24, 8760 + 1))]
        .idxmax()
    )

    df = dh.get("o_supply").xs("GER", level="r", drop_level=False)
    df = pd.concat(
        [df.xs(winter_peak[col], level="t")[col] for col in df.columns],
        axis=1,
    )
    df.columns = df.columns.rename("scenario")
    df = df.stack().reset_index()
    df.columns = change_tec_lvl_name_to_alltec(df.columns)
    df = df[df["alltec"] != "shed"]

    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    flow = (
        dh.get("o_flow")
        .groupby(["t", "r"])
        .sum()
        .xs("GER", level="r", drop_level=False)
        .mul(-1)
    )
    flow = pd.concat(
        [flow.xs(winter_peak[col], level="t")[col] for col in flow.columns],
        axis=1,
    )
    flow.columns = flow.columns.rename("scenario")
    flow = flow.stack().reset_index().assign(alltec="ntc", allvin=1)

    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    flex = pd.concat([flex, flow])
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = (
        dh.get("o_demand")
        .xs("GER", level="r", drop_level=False)
        .xs("PtHydrogen", level="tec_demand", drop_level=False)
    )
    eff = dh.get("eff").loc["PtHydrogen", :]
    hydrogen = pd.concat(
        [
            hydrogen.xs(winter_peak[col], level="t")[col].mul(eff[col])
            if winter_peak[col] in hydrogen[col].index.get_level_values("t").values
            else pd.DataFrame(
                {col: 0},
                index=pd.MultiIndex.from_product(
                    [["PtHydrogen"], ["new"], ["GER"]],
                    names=["tec_demand", "allvin", "r"],
                ),
            )
            for col in hydrogen.columns
        ],
        axis=1,
    )
    hydrogen.columns = eff.index
    hydrogen = hydrogen.stack().reset_index()
    hydrogen.columns = change_tec_lvl_name_to_alltec(hydrogen.columns)
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, flex, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")  # .to_csv('test.csv')

    return df


def iamc_percentile25_hourly_generation(dh: DataHandler, to_scenarioID):
    descending_demand_index = create_descending_demand_index(dh)
    perc_25 = descending_demand_index.iloc[: round(len(descending_demand_index) * 0.25)]
    nr_of_hours = len(perc_25)

    prefix = "Generation|Percentile 25"

    df = dh.get("o_supply").xs("GER", level="r", drop_level=False)
    df = pd.concat([df[scen].loc[(perc_25[scen]), :] for scen in df.columns], axis=1)
    df.columns = df.columns.rename("scenario")
    df = df.stack().reset_index()
    df.columns = change_tec_lvl_name_to_alltec(df.columns)
    df = df[df["alltec"] != "shed"]

    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    flow = (
        dh.get("o_flow")
        .groupby(["t", "r"])
        .sum()
        .xs("GER", level="r", drop_level=False)
        .mul(-1)
    )
    flow = pd.concat(
        [flow[scen].loc[(perc_25[scen]), :] for scen in flow.columns], axis=1
    )
    flow.columns = flow.columns.rename("scenario")
    flow = flow.stack().reset_index().assign(alltec="ntc", allvin=1)

    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    flex = pd.concat([flex, flow])
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = (
        dh.get("o_demand")
        .xs("GER", level="r", drop_level=False)
        .xs("PtHydrogen", level="tec_demand", drop_level=False)
    )
    eff = dh.get("eff").loc["PtHydrogen", :]
    hydrogen = pd.concat(
        [
            hydrogen[col].loc[(perc_25[col]), :].mul(eff[col])
            for col in hydrogen.columns
        ],
        axis=1,
    )
    hydrogen.columns = eff.index
    hydrogen = hydrogen.stack().reset_index()
    hydrogen.columns = change_tec_lvl_name_to_alltec(hydrogen.columns)
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, flex, hydrogen])
    df = df.astype({0: "float64"})
    df = (
        df.groupby(index, dropna=False).sum()[0].unstack("Year").div(nr_of_hours)
    )  # .to_csv('test.csv')

    return df


def iamc_percentile50_hourly_generation(dh: DataHandler, to_scenarioID):
    descending_demand_index = create_descending_demand_index(dh)
    perc_50 = descending_demand_index.iloc[: round(len(descending_demand_index) * 0.5)]
    nr_of_hours = len(perc_50)

    prefix = "Generation|Percentile 50"

    df = dh.get("o_supply").xs("GER", level="r", drop_level=False)
    df = pd.concat([df[scen].loc[(perc_50[scen]), :] for scen in df.columns], axis=1)
    df.columns = df.columns.rename("scenario")
    df = df.stack().reset_index()
    df.columns = change_tec_lvl_name_to_alltec(df.columns)
    df = df[df["alltec"] != "shed"]

    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    flow = (
        dh.get("o_flow")
        .groupby(["t", "r"])
        .sum()
        .xs("GER", level="r", drop_level=False)
        .mul(-1)
    )
    flow = pd.concat(
        [flow[scen].loc[(perc_50[scen]), :] for scen in flow.columns], axis=1
    )
    flow.columns = flow.columns.rename("scenario")
    flow = flow.stack().reset_index().assign(alltec="ntc", allvin=1)

    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    flex = pd.concat([flex, flow])
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = (
        dh.get("o_demand")
        .xs("GER", level="r", drop_level=False)
        .xs("PtHydrogen", level="tec_demand", drop_level=False)
    )
    eff = dh.get("eff").loc["PtHydrogen", :]
    hydrogen = pd.concat(
        [
            hydrogen[col].loc[(perc_50[col]), :].mul(eff[col])
            for col in hydrogen.columns
        ],
        axis=1,
    )
    hydrogen.columns = eff.index
    hydrogen = hydrogen.stack().reset_index()
    hydrogen.columns = change_tec_lvl_name_to_alltec(hydrogen.columns)
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, flex, hydrogen])
    df = df.astype({0: "float64"})
    df = (
        df.groupby(index, dropna=False).sum()[0].unstack("Year").div(nr_of_hours)
    )  # .to_csv('test.csv')

    return df


def iamc_fuel_consumption(dh: DataHandler, to_scenarioID):
    prefix = "Fuel consumption"

    eff = dh.get("efficiency")

    df = (
        dh.get("o_supply")
        .xs("GER", level="r", drop_level=False)
        .groupby(["tec_supply", "allvin", "r"])
        .sum()
    )
    df.index.names = change_tec_lvl_name_to_alltec(df.index.names)
    df = df.div(eff).mul(3.6)  # From GWh to TJ
    df = df.stack().reset_index()
    df = df[df["alltec"] != "shed"]
    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = (
        dh.get("o_demand")
        .xs("GER", level="r", drop_level=False)
        .xs("PtHydrogen", level="tec_demand", drop_level=False)
    )
    hydrogen = hydrogen.stack().reset_index()
    hydrogen.columns = change_tec_lvl_name_to_alltec(hydrogen.columns)
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, flex, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")  # .to_csv('test.csv')

    return df


def iamc_emission(dh: DataHandler, to_scenarioID):
    prefix = "Emissions|Kyoto Gases|Fossil|CO2"

    df = (
        dh.get("o_emissions")
        .xs("GER", level="r", drop_level=False)
        .stack()
        .reset_index()
    )
    df.columns = change_tec_lvl_name_to_alltec(df.columns)
    df = df[df["alltec"] != "shed"].assign(allvin=1)

    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])]
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = pd.DataFrame(
        {
            "alltec": "PtHydrogen",
            "r": "GER",
            "allvin": 1,
            "scenario": elec["scenario"].unique(),
            0: 0,
        }
    )
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")  # .to_csv('test.csv')

    return df


def iamc_efficiency(dh: DataHandler, to_scenarioID):
    prefix = "Efficiency"

    df = dh.get("eff").stack().reset_index()
    df = df[df["alltec"] != "shed"]
    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])].assign(r="GER")
    elec = add_index_cols(
        elec, prefix, "Electricity", dh.scenarios.params, to_scenarioID
    )

    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    ntc_eff = pd.DataFrame(
        {"alltec": "ntc", "scenario": flex["scenario"].unique(), 0: 1}
    )
    flex = pd.concat([flex, ntc_eff])
    flex = flex.assign(r="GER")
    flex = add_index_cols(
        flex, prefix, "Flexibility", dh.scenarios.params, to_scenarioID
    )

    hydrogen = df[df["alltec"].isin(maps["categories"]["Hydrogen"])].assign(r="GER")
    hydrogen = add_index_cols(
        hydrogen, prefix, "Hydrogen", dh.scenarios.params, to_scenarioID
    )

    df = pd.concat([elec, flex, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")  # .to_csv('test.csv')

    return df


def iamc_investment(dh: DataHandler, to_scenarioID):
    prefix = "Investments"

    cost = dh.get("i_cost").xs("invest", level="par_cost").stack().reset_index()
    cost.columns = ["alltec", "Year", "scenario", 0]
    cost = cost.set_index(["alltec", "scenario", "Year"])

    inve = dh.get("o_inve").fillna(0).xs("GER", level="r").stack().reset_index()
    inve["Year"] = inve["scenario"].apply(
        lambda x: str(dh.scenarios.params[to_scenarioID[x]]["clp"]["--HORIZON"])
    )
    inve.columns = ["alltec", "allvin", "scenario", 0, "Year"]
    inve = inve.groupby(["alltec", "scenario", "Year"]).sum()

    df = inve.mul(cost).div(1000).reset_index().dropna()
    df = df[df["alltec"] != "shed"]

    elec = df[df["alltec"].isin(maps["categories"]["Electricity"])].assign(
        r="GER", allvin=1
    )
    elec = rename_et_al(elec, "Electricity", prefix, dh.scenarios.params, to_scenarioID)

    flex = df[df["alltec"].isin(maps["categories"]["Flexibility"])]
    ntc_mI = pd.MultiIndex.from_product(
        [["ntc"], flex["scenario"].unique(), flex["Year"].unique()],
        names=["alltec", "scenario", "Year"],
    )
    ntc_inve = pd.DataFrame({0: 0}, index=ntc_mI).reset_index()
    flex = pd.concat([flex, ntc_inve])
    flex = flex.assign(r="GER", allvin=1)
    flex = rename_et_al(flex, "Flexibility", prefix, dh.scenarios.params, to_scenarioID)

    hydrogen = df[df["alltec"].isin(maps["categories"]["Hydrogen"])].assign(
        r="GER", allvin=1
    )
    hydrogen = rename_et_al(
        hydrogen, "Hydrogen", prefix, dh.scenarios.params, to_scenarioID
    )

    heat_inve = dh.get("o_invechp").fillna(0).xs("GER", level="r").stack().reset_index()
    heat_inve["Year"] = heat_inve["scenario"].apply(
        lambda x: str(dh.scenarios.params[to_scenarioID[x]]["clp"]["--HORIZON"])
    )
    heat_inve.columns = change_tec_lvl_name_to_alltec(heat_inve.columns)
    heat_inve = heat_inve.astype({0: "Float64"})
    heat_inve = heat_inve.groupby(["alltec", "scenario", "Year"]).sum()

    heat = heat_inve.mul(cost).div(1000).reset_index().dropna()
    heat = heat[heat["alltec"] != "shed"].assign(r="GER", allvin=1)
    heat = rename_et_al(heat, "Heat", prefix, dh.scenarios.params, to_scenarioID)

    df = pd.concat([elec, flex, heat, hydrogen])
    df = df.astype({0: "float64"})
    df = df.groupby(index, dropna=False).sum()[0].unstack("Year")  # .to_csv('test.csv')

    return df


def iamc():
    dh = call_DataHandler("scenarios_SENTINEL_CS_EU")
    to_scenarioID = {str(val["name"]): key for key, val in dh.scenarios.params.items()}
    IAMC = {}
    IAMC["installed_capacity"] = iamc_installed_capacity(dh, to_scenarioID)
    IAMC["yearly_generation_supply"] = iamc_yearly_generation(dh, to_scenarioID)
    IAMC["summer_peak_hourly_generation"] = iamc_summer_peak_hourly_generation(
        dh, to_scenarioID
    )
    IAMC["winter_peak_hourly_generation"] = iamc_winter_peak_hourly_generation(
        dh, to_scenarioID
    )
    IAMC["Percentile25_hourly_generation"] = iamc_percentile25_hourly_generation(
        dh, to_scenarioID
    )
    IAMC["Percentile50_hourly_generation"] = iamc_percentile50_hourly_generation(
        dh, to_scenarioID
    )
    IAMC["fuel_consumption_supply"] = iamc_fuel_consumption(dh, to_scenarioID)
    IAMC["emission_supply"] = iamc_emission(dh, to_scenarioID)
    IAMC["efficiency_supply"] = iamc_efficiency(dh, to_scenarioID)
    IAMC["investment_supply"] = iamc_investment(dh, to_scenarioID)
    IAMC["long"] = pd.concat(IAMC.values()).copy()

    outputfile = os.path.join(OUTPUTDIR, "IAMC.xlsx")
    IAMC["long"].to_excel(outputfile, sheet_name="all_codes", merge_cells=False)


def plot_Sentinel_stories():
    """
    Script which creates the figure we used in SENTINEL Stories
    """
    scenario_file_GRC = "scenarios_SENTINEL_CS_GR"
    scenarios_GRC = Scenarios(scenario_file_GRC + ".yaml")
    for id in scenarios_GRC.params.keys():
        scenarios_GRC.params[id]["active"] = (
            True
            if scenarios_GRC.params[id]["name"] in ["RF_2050", "RE_2050"]
            else False
        )
    dh_GRC = DataHandler(scenarios_GRC)

    df = electricity_balance(dh_GRC)
    df = df.xs("GRC", level="r")
    df = df.groupby(["alltec", "type"]).sum()
    df.index = df.index.droplevel("type")

    load = dh_GRC.get("o_load")
    load = load.xs("GRC", level="r")
    load = load.sum().div(1000)

    curt = dh_GRC.get("o_cur").sum().div(1000).round(decimals=2)

    fig, (ax, ax_table) = plt.subplots(
        nrows=2, gridspec_kw=dict(height_ratios=[10, 1]), figsize=(5, 5)
    )
    ax = stacked_bar_chart(
        ax, df, colors_techs, ylabel="TWh", renaming_map=renaming_map_techs, width=0.5
    )
    ax.plot(
        load.index,
        load.values,
        label="demand",
        color="black",
        linestyle="None",
        marker="_",
        markersize=20,
    )
    ax = draw_legend(fig, ax, pos=(1.15, 0.5), ncol=1)
    ax.set_title("Electricity balance of Greece")
    ax.set_xlim(-0.5, 1.5)
    ax.axhline(y=0, linewidth=1, color="k")
    ax_table.axis("off")
    ax_table = plt.table(
        cellText=[curt],
        rowLabels=["curtailment\n[TWh]"],
        cellLoc="center",
        loc="bottom",
    )
    ax_table.scale(1, 3)
    plt.subplots_adjust(top=0.97, bottom=0.135)
    outputfile = os.path.join(OUTPUTDIR, "Elec_bal_GRC_stories.svg")

    fig.savefig(outputfile, bbox_inches="tight")
