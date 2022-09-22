import pandas as pd
import numpy as np
import re
from pandas import ExcelWriter
from pandas import ExcelFile
from sqlite3 import DatabaseError, OperationalError

"""
This script takes the csv files of flow_in_2030 and flow_in_2050 of Calliope and extracts electricity demand profiles.
"""

r = {
    "DEU": "GER",
    "SWE": "SWE",
    "FRA": "FRA",
    "POL": "POL",
    "NLD": "NLD",
    "BEL": "BEL",
    "NOR": "NOR",
    "AUT": "AUT",
    "CHE": "CHE",
    "CZE": "CZE",
    "DNK": "DNK",
    "GBR": "GBR",
    "GRC": "GRC",
}

scen = {"current": "SENTINEL_EU_CT", "neutral": "SENTINEL_EU_CN"}

idx = pd.IndexSlice


def remap_time_id_from_date_to_hour_of_year(idx: pd.Index):
    """
    idx must be Index with level name 'timesteps' which can be converted to datetimeIndex
    """
    idx = idx.set_levels(
        pd.to_datetime(idx.get_level_values("timesteps").unique()), level="timesteps"
    )
    idx = idx.set_levels(
        (idx.get_level_values("timesteps").unique().dayofyear - 1) * 24
        + idx.get_level_values("timesteps").unique().hour
        + 1,
        level="timesteps",
    )
    return idx


d30 = pd.read_csv(
    "input/Calliope/flow_in_2030.csv",
    index_col=["scenario", "techs", "locs", "carriers", "unit", "timesteps"],
)
d30 = d30.loc[idx[:, "demand_elec", list(r.keys()), :, :, :], :]
d30.index = d30.index.droplevel(["techs", "carriers", "unit"])
d30 = d30.rename(r, axis=0, level="locs")
d30 = d30.rename(scen, axis=0, level="scenario")
d30 = d30 * 1000000
d30.index = remap_time_id_from_date_to_hour_of_year(d30.index)
d30 = pd.concat([d30], keys=[2030], names=["year"])

d50 = pd.read_csv(
    "input/Calliope/flow_in_2050.csv",
    index_col=["scenario", "techs", "locs", "carriers", "unit", "timesteps"],
)
d50 = d50.loc[idx[:, "demand_elec", list(r.keys()), :, :, :], :]
d50.index = d50.index.droplevel(["techs", "carriers", "unit"])
d50 = d50.rename(r, axis=0, level="locs")
d50 = d50.rename(scen, axis=0, level="scenario")
d50 = d50 * 1000000
d50.index = remap_time_id_from_date_to_hour_of_year(d50.index)
d50 = pd.concat([d50], keys=[2050], names=["year"])

df = pd.concat([d30, d50])
df = df.unstack(["scenario", "locs", "year"])
df = df.transpose()

h50 = pd.read_csv(
    "input/Calliope/final_consumption_2050.csv",
    index_col=["scenario", "sector", "subsector", "carriers", "locs", "unit"],
)
h50 = h50.loc[idx[:, :, :, "hydrogen", list(r.keys()), :], :]
h50 = h50.rename(r, axis=0, level="locs")
h50 = h50.rename(scen, axis=0, level="scenario")
h50 = h50.groupby(["scenario", "locs"]).sum()
h50 = pd.concat([h50], keys=[2050], names=["year"])
h50 = h50.reorder_levels(["scenario", "locs", "year"])

df.to_excel("demand_profiles_Calliope.xlsx", sheet_name="load", merge_cells=False)
h50.to_excel(
    "h2_demand_profiles_Calliope.xlsx", sheet_name="hydrogen", merge_cells=False
)
