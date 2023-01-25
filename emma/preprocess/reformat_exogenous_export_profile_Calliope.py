import pandas as pd
from openpyxl import load_workbook

"""
This script extract from the csv files "net_import_2030" and "net_import_2050" from Calliope export profiles and saves them in a new format as xlsx files.
"""


def remap_time_id_from_date_to_hour_of_year(idx):
    """
    Index must be simple string index which can be converted to datetimeIndex
    """
    idx = pd.to_datetime(idx)
    idx = (idx.dayofyear - 1) * 24 + idx.hour + 1
    return idx


def fill_missing_values(df):
    """
    function forfills all missing values and divides them by 2.
    Index must be bihourly hour-of-year index
    """
    id_reshape = pd.Index(range(1, 8761), dtype="int64")
    df = df.reindex(id_reshape, method="ffill").div(2)
    return df


ni30 = pd.read_csv(
    "input/Calliope/net_import_2030.csv",
    index_col=[
        "scenario",
        "exporting_region",
        "importing_region",
        "carriers",
        "unit",
        "timesteps",
    ],
)
ni30 = (
    ni30.groupby(["scenario", "timesteps", "importing_region"])
    .sum()
    .xs("GRC", level="importing_region", drop_level=False)
    * 1000
    * -1
)
ni30 = pd.concat([ni30], keys=[2030], names=["year"])
ni30.columns = ["net import (GWh)"]
ni30 = ni30.xs("current", level="scenario", drop_level=False)
ni30 = ni30.rename({"current": "SENTINEL_GRC_RF"}, axis=0, level="scenario")
ni30 = ni30.unstack(level=["scenario", "importing_region", "year"])
ni30.index = remap_time_id_from_date_to_hour_of_year(ni30.index)

ni50 = pd.read_csv(
    "input/Calliope/net_import_2050.csv",
    index_col=[
        "scenario",
        "exporting_region",
        "importing_region",
        "carriers",
        "unit",
        "timesteps",
    ],
)
ni50 = (
    ni50.groupby(["scenario", "timesteps", "importing_region"])
    .sum()
    .xs("GRC", level="importing_region", drop_level=False)
    * 1000
    * -1
)
ni50 = pd.concat([ni50], keys=[2050], names=["year"])
ni50.columns = ["net import (GWh)"]
ni50_helper = ni50.xs("neutral", level="scenario", drop_level=False).rename(
    {"neutral": "SENTINEL_GRC_PX"}, axis=0, level="scenario"
)
ni50 = ni50.rename(
    {"current": "SENTINEL_GRC_RF", "neutral": "SENTINEL_GRC_RE"},
    axis=0,
    level="scenario",
)
ni50 = pd.concat([ni50, ni50_helper])
ni50 = ni50.unstack(level=["scenario", "importing_region", "year"])
ni50.index = remap_time_id_from_date_to_hour_of_year(ni50.index)
ni = pd.concat([ni30, ni50], axis=1).transpose()
ni.to_excel("exoexport_calliope.xlsx", sheet_name="exoexport", merge_cells=False)
