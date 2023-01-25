import pandas as pd
import re


# tools to manipulate DataFrames.


def add_zeros(df: pd.DataFrame, mI: pd.MultiIndex):
    """
    This function complements the index of a DataFrame by a MultiIndex an adds zeros to the added rows.

    :param df: pd.DataFrame which index is complemented
    :param mI: pd.MultiIndex which complements the DataFrame
    :return: pd.DataFrame which has a complemented index
    """
    df_zeros = pd.DataFrame(0, index=mI, columns=df.columns)
    df = pd.merge(df_zeros, df, how="outer", on=mI.names).fillna(0)

    columns_x = [sc + "_x" for sc in df_zeros.columns]
    df1 = df[columns_x]
    df1.columns = df_zeros.columns

    columns_y = [sc + "_y" for sc in df_zeros.columns]
    df2 = df[columns_y]
    df2.columns = df_zeros.columns

    return df1.add(df2)


def add_dimension(df: pd.DataFrame, new_level: list, new_level_name: str):
    """
    This function adds a new level to the index.

    :param df: pd.DataFrame where new level is added
    :param new_level: list of new level entries
    :param new_level_name: string of new level
    :return: DataFrame which has a new dimension with the new_level as its values
    """
    final_df = None
    for item in new_level:
        temp = pd.concat([df], keys=[item], names=[new_level_name])
        final_df = pd.concat([final_df, temp])
    return final_df


def change_tec_lvl_name_to_alltec(names: list):
    """
    This function changes name of technology level (for example tec_supply) to "alltec".

    :param names: list of column names
    :return: list of new column names
    """
    new_names = []
    for i in range(len(names)):
        tech_name = re.search(".*tec.*", str(names[i]))
        if tech_name != None:
            new_names.append("alltec")
        else:
            new_names.append(names[i])
    return new_names


def extract_horizon_specific_cost(i_cost: pd.DataFrame, scen_hor_map: dict):
    """
    This function extracts the horizon specific cost out of the "i_cost" table for a single technology.

    :param i_cost: groupby object split by "alltec" of the i_cost table
    :param scen_hor_map: dictionary specifying the scenario specific horizons
    :return: a pd.Series with scenario index and horizon specific costs
    """
    cost_vector = pd.Series(None, dtype="Float64", index=i_cost.columns)
    for scenario in i_cost.columns:
        horizon = scen_hor_map[scenario]
        horizon_costs = i_cost[scenario].xs(horizon, level="i_cost")
        cost_vector[scenario] = horizon_costs.values
    return cost_vector
