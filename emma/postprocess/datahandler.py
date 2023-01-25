import os
import pandas as pd
import sqlite3
import contextlib
import numpy as np
import functools

from call import Scenarios


# Load ,data from SQLites


def get_table(
    scenarios: Scenarios, scenario_id: str, table_name: str, use_name: bool = False
):
    """
    This function loads the scenario specific SQL table and converts it into a pd.DataFrame

    :param scenarios: dictionary with scenario specific information loaded from the yaml file
    :param scenario_id: string with scenario_id for which the SQL table should be loaded. scenario_id has to match the id in the yaml file
    :param table_name: string of table name of SQL table which should be converted
    :param use_name: boolean value whether name of scenario appears as name of column in DataFrame
    :return: DataFrame with the contents of the SQL table.
    """
    path = os.path.join(
        "core", f"_{scenarios.name}", f"_{scenario_id}", str(scenario_id) + ".db"
    )

    if not os.path.isfile(path):
        print("Warning: tables does not exists in scenario id:", scenario_id)
        return

    try:
        with contextlib.closing(sqlite3.connect(path)) as connection:
            query = "SELECT * FROM {}".format(table_name)
            df = pd.read_sql_query(query, connection)
            df = df.convert_dtypes()

            if "t" in df.columns:
                df["t"] = df["t"].astype("int32")

            idx = list(df.columns)
            if len(idx) > 1:
                idx.remove("value")
                df = df.set_index(idx)
                df = df.rename(
                    columns={
                        "value": str(scenarios.params[scenario_id]["name"])
                        if use_name
                        else str(scenario_id)
                    }
                )

            df.columns.names = ["scenario"]

        return df
    except Exception as e:
        print(e)
        print(f"Table {table_name} not cannot be queried for scenario {scenario_id}")
        return None


def merge_tables(
    scenarios: Scenarios,
    table_name: str,
    historical: bool = False,
    active_only: bool = True,
):
    """
    This function concatinates the DataFrames of get_table() by the index.

    :param scenarios: dictionary with scenario specific information loaded from the yaml file
    :param table_name: string of table name of SQL table which should be converted
    :return: DataFrame with the contents of the SQL table of name table_name with the scenario names as columns.
    """
    if active_only:
        dataframes = [
            get_table(scenarios, scenario_id, table_name, use_name=True)
            for scenario_id in scenarios.active_scenarios
        ]
    else:
        dataframes = [
            get_table(scenarios, scenario_id, table_name, use_name=True)
            for scenario_id in scenarios.params
        ]
    df = pd.concat(dataframes, axis=1)

    # Needed because otherwise the index name disappears when merging on columns with an empty dataframe
    for dataframe in dataframes:
        if dataframe.index.name:
            df.index.name = dataframe.index.name

    return df


class DataHandler:
    """Class to retrieve SQLite tables, perform additional calculations and store the result in memory"""

    def __init__(self, scenarios: Scenarios):
        self.scenarios = scenarios

    def __hash__(self):
        return hash(str(self.scenarios.params))

    @functools.lru_cache
    def merge_stored_sets(self, name):
        # can load unique subsets of technologies or regions
        return np.unique(self.get(name).values)

    @functools.lru_cache
    def get(self, table_name, active_only=True):
        """Merges all tables with a given name and returns a dataframe

        :param table_name: str (can be whatever table name is contained in the SQLite fiels)
        :return: dataframe with each column being a scenario
        """
        return merge_tables(self.scenarios, table_name, active_only=True)
