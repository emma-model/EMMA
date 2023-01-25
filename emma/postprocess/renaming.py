import pandas as pd
import numpy as np
import re

from postprocess.tools import change_tec_lvl_name_to_alltec

schema_dict = {
    "t": {"n": "Time ID", "v": {i: i for i in range(8760 + 1)}},
    "alltec": {
        "n": "Technologies",
        "v": {
            "CCGT": "Combined cycle gas turbines",
            "OCGT": "Gas turbines",
            "CCGT_CCS": "Gas turbines with CCS",
            "CCGT_H2": "Hydrogen fueled combined cycle gas turbines",
            "OCGT_H2": "Hydrogen fueled gas turbines",
            "PHS": "Pumped hydro",
            "bio": "Solid bio and waste",
            "coal": "Coal",
            "coal_CCS": "Coal with CCS",
            "hydr": "Hydro",
            "lign": "Lignite",
            "lign_CCS": "Lignite with CCS",
            "nucl": "Nuclear",
            "ror": "Run-of-river",
            "shed": "Load shedding",
            "solar": "PV",
            "wion": "Wind onshore",
            "wiof": "Wind offshore",
            "batr": "Batteries",
            "PtHydrogen": "Electrolysers",
            "cur": "Curtailment",
            "import": "Import",
        },
    },
    "allvin": {
        "n": "Vintage",
        "v": {
            "1": "class 1",
            "2": "class 2",
            "3": "class 3",
            "4": "class 4",
            "new": "newbuild",
        },
    },
    "r": {
        "n": "Region",
        "v": {
            "AUT": "Austria",
            "BEL": "Belgium",
            "CHE": "Switzerland",
            "CZE": "Czechia",
            "DNK": "Denmark",
            "FRA": "France",
            "GBR": "Great Britain",
            "GER": "Germany",
            "GRC": "Greece",
            "NLD": "The Netherlands",
            "NOR": "Norway",
            "POL": "Poland",
            "SWE": "Sweden",
        },
    },
    "name": {"n": "Name", "v": {"o_cost": "System costs"}},
    "scenario": {
        "n": "Scenario",
        "v": {
            "2016": "2016",
            "RF_2030": "RF2030",
            "RF_2050": "RF2050",
            "RE_2050": "RE2050",
            "P2X_2050": "P2X2050",
            "EC_2030": "EC2030",
            "2030_EU_CT": "2030_EU_CT",
            "2050_EU_CT": "2050_EU_CT",
            "2030_EU_CN": "2030_EU_CN",
            "2050_EU_CN": "2050_EU_CN",
            "2040_EU_EN": "2040_EU_EN",
        },
    },
    "o_stoinv": {
        "n": "Type",
        "v": {"energy": "Battery_size", "power": "Battery_capacity"},
    },
    "type": {"n": "Type", "v": {"supply": "Supply", "demand": "Demand"}},
}

schema_dict["vin"] = schema_dict["allvin"]
schema_dict["new"] = schema_dict["allvin"]


def get_schema_value(
    name: str, value: str, schema: dict = schema_dict, safe: bool = True
):
    """
    This function returns the renaming value of the type name and the value.
    """
    try:
        r = schema[name]["v"][value]
        return r
    except KeyError:
        if safe:
            raise Exception(
                "Cannot find schema value dict[%s][%s][%s]" % (name, "v", value)
            )
        else:
            return value


def rename_idx_values(idx: pd.DataFrame, schema: dict = schema_dict):
    """
    This function renames the values of an index of a DataFrame
    """
    if isinstance(idx, pd.core.frame.DataFrame):
        idx = idx.index

    arrays = []
    names = []

    if isinstance(idx, pd.MultiIndex):
        for idx_lv in idx.levels:
            names.append(idx_lv.name)
            arrays.append(
                list(
                    map(
                        lambda x: get_schema_value(
                            name=idx_lv.name,
                            value=x,
                        ),
                        np.unique(idx_lv.values),
                    )
                )
            )

        return idx.set_levels(arrays, level=names)
    else:
        return pd.Index(
            [get_schema_value(name=idx.name, value=i) for i in idx.values],
            name=idx.name,
        )


def rename_idx_names(idx: pd.DataFrame, schema: dict = schema_dict):
    """
    This function renames the index names of a DataFrame by the values of schema dictionary
    """
    if isinstance(idx, pd.core.frame.DataFrame):
        idx = idx.index

    if isinstance(idx, pd.MultiIndex):
        new_names = [schema[i]["n"] for i in idx.names]
        return idx.rename(new_names)
    else:
        return idx.rename(schema[idx.name]["n"])


def renamed_idx(idx: pd.DataFrame):
    """
    This function renames the index of a DataFrame
    """
    if isinstance(idx, pd.core.frame.DataFrame):
        idx = idx.index

    idx = rename_idx_values(idx)
    idx = rename_idx_names(idx)
    return idx


def rename_df_index(df: pd.DataFrame):
    """
    This function replaces the index of a dataframe by a renamed index.
    """
    assert isinstance(df, pd.DataFrame), "You have not inserted a Dataframe."

    df.index.names = change_tec_lvl_name_to_alltec(df.index.names)

    idx = renamed_idx(df)
    df.index = idx
    return df
