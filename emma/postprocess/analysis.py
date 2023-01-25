import pandas as pd
import numpy as np
import functools

from postprocess.tools import (
    add_zeros,
    add_dimension,
    change_tec_lvl_name_to_alltec,
    extract_horizon_specific_cost,
)
from postprocess.datahandler import DataHandler

# data processing functions


@functools.lru_cache
def market_value(dh: DataHandler):
    """
    This function calculates the market value of all simulated technologies.

    :param dh: DataHandler of simulation pack
    :return: pd.DataFrame with market values for every country and technology
    """
    scenario_order = [
        str(dh.scenarios.active_scenarios[keys]["name"])
        for keys in dh.scenarios.active_scenarios
    ]

    # adding all vintage classes together
    df_supply = dh.get("o_supply").groupby(["r", "tec_supply", "t"]).sum()
    df_supply = df_supply.stack().unstack("t").T
    df_price = dh.get("o_prices").stack().unstack("t").T

    # calculate market value
    df_mv = (
        df_supply.mul(df_price, fill_value=np.nan)
        .sum()
        .div(df_supply.sum())
        .unstack("scenario")
    )
    df_mv = df_mv[scenario_order]

    df_PtHydrogen = pd.concat(
        [dh.get("o_h2price_sell")], keys=["PtHydrogen"], names=["tec_supply"]
    )
    df_PtHydrogen = df_PtHydrogen.reorder_levels(["r", "tec_supply"])
    df_mv = pd.concat([df_mv, df_PtHydrogen])

    return df_mv


@functools.lru_cache
def full_load_hours(dh: DataHandler):
    """
    This function calculates full load hours for all simulated technologies for all regions.

    :param dh: DataHandler of simulation pack
    :return: pd.DataFrame with full load hours for every country and technology
    """
    gen_df = dh.get("o_supply")
    gen_df.index.names = change_tec_lvl_name_to_alltec(gen_df.index.names)
    cap_df = dh.get("o_capa")

    # In not all hours of the year are simulated, generation needs to be scaled by sc
    sc = 8760 / len(gen_df.index.get_level_values("t").unique())
    cum_gen_df = gen_df.groupby(["alltec", "allvin", "r"], dropna=False).sum() * sc

    # Calculate full load hours
    flh_df = cum_gen_df.divide(cap_df)

    return flh_df


@functools.lru_cache
def load_factor(dh: DataHandler):
    """
    This function calculates load factors for all simulated technologies for all regions.

    :param dh: DataHandler of simulation pack
    :return: pd.DataFrame with load factors for every country and technology
    """

    # Can be easily defined recursively (only 'full_load_hours' if then saves but no big deal)
    return full_load_hours(dh) / 8760


@functools.lru_cache
def electricity_balance(dh: DataHandler):
    """
    This function creates a DataFrame of the electricity balance of all regions.

    :param dh: DataHandler of simulation pack
    :return: pd.DataFrame of the electrical flows of demand and supply.
    """
    # creates DataFrame of all electricity flows in TWh with index = ['alltec','r']
    supply = dh.get("o_supply").groupby(["tec_supply", "r"]).sum()
    supply.index.names = ["alltec", "r"]
    supply = pd.concat([supply], keys=["supply"], names=["type"])
    demand = dh.get("o_demand").groupby(["tec_demand", "r"]).sum() * -1
    demand.index.names = ["alltec", "r"]
    demand = pd.concat([demand], keys=["demand"], names=["type"])
    imp = pd.concat(
        [
            pd.concat(
                [dh.get("o_import").groupby("r").sum()],
                keys=["import"],
                names=["alltec"],
            )
        ],
        keys=["demand"],
        names=["type"],
    )
    cur = pd.concat(
        [
            pd.concat(
                [dh.get("o_cur").groupby("r").sum().mul(-1)],
                keys=["cur"],
                names=["alltec"],
            )
        ],
        keys=["demand"],
        names=["type"],
    )

    elec_flow = pd.concat([supply, demand, imp, cur])
    elec_flow = elec_flow.div(1000)

    mI = pd.MultiIndex.from_product(
        [
            dh.merge_stored_sets("alltec"),
            dh.merge_stored_sets("r"),
            ["supply", "demand"],
        ],
        names=["alltec", "r", "type"],
    )
    elec_flow = add_zeros(elec_flow, mI)

    return elec_flow


@functools.lru_cache
def hydrogen_balance(dh: DataHandler):
    """
    This function creates a DataFrame of the hydrogen balance of all regions.

    :param dh: DataHandler of simulation pack
    :return: pd.DataFrame of the hydrogen flows of demand and supply.
    """
    supply = (
        dh.get("o_h2_gene").fillna(0).groupby(["tec_h2d", "r"]).sum().astype("Float64")
    )
    supply.index.names = ["alltec", "r"]

    demand = (
        dh.get("o_h2_usage")
        .fillna(0)
        .groupby(["tec_h2g", "r"])
        .sum()
        .mul(-1)
        .astype("Float64")
    )
    demand.index.names = ["alltec", "r"]

    imp = dh.get("o_h2_imports")
    imp = add_zeros(imp, pd.Index(dh.merge_stored_sets("r"), name="r"))
    imp = pd.concat([imp], keys=["import"], names=["alltec"]).astype("Float64")

    h2_bal = pd.concat([supply, demand, imp]).div(1000)

    mI = pd.MultiIndex.from_product(
        [dh.merge_stored_sets("tec_h2"), dh.merge_stored_sets("r")],
        names=["alltec", "r"],
    )
    h2_bal = add_zeros(h2_bal, mI)

    return h2_bal


@functools.lru_cache
def pdc_pivot(dh: DataHandler):
    """
    This function pivots the price DataFrame of all regions.

    :param dh: DataHandler of simulation pack
    :return: pivoted pd.DataFrame of the electricity shadow prices.
    """
    df = dh.get("o_prices")

    df = df.reset_index().pivot(index="t", columns="r")

    for col in df.columns:
        df[col] = sorted(df[col])

    df = df.reset_index(drop=True)
    return df


@functools.lru_cache
def total_investment_costs(dh: DataHandler):
    """
    This function calculates the total investment costs of all regions and technologies.

    :param dh: DataHandler of simulation pack
    :param scen_hor_map: dictionary specifying the scenario specific horizons
    :return: pd.DataFrame of the total investment costs.
    """
    # discountrate series with index: scenarios
    discount_rate = dh.get("scalars").loc["discountrate", :]
    sc = 8760 / dh.scenarios.hours

    scen_hor_map = dh.scenarios.horizon

    # investment costs dataframe with columns: scenarios and index: alltec
    inv = dh.get("i_cost").xs("invest", level="par_cost")
    assert all(
        k in scen_hor_map for k in inv.columns
    ), "You have not defined a horizon level for a scenario."
    tec_inv = list(
        dh.get("i_cost")
        .xs("invest", level="par_cost")
        .index.get_level_values("alltec")
        .unique()
    )
    inv = inv.groupby(["alltec"]).apply(extract_horizon_specific_cost, scen_hor_map)

    # lifetime dataframe with columns: scenarios and index: alltec

    lt = dh.get("i_cost").xs("lifetime", level="par_cost")
    lt.index = lt.index.droplevel("i_cost")
    lt = lt.loc[tec_inv, :]

    # flex_premium dataframe with columns: scenarios and index: alltec
    fp = dh.get("i_cost").xs("flex_premium", level="par_cost")
    fp.index = fp.index.droplevel("i_cost")
    fp = fp.loc[tec_inv, :]

    inv = (
        inv
        * ((1 + discount_rate) ** lt * discount_rate)
        / ((1 + discount_rate) ** lt - 1)
    )

    # investment costs DataFrame with columns: scenarios and index: [alltec, regions]
    cost = inv / sc * fp
    cost = add_dimension(cost, dh.merge_stored_sets("r"), "r")
    cost = cost.reorder_levels(["alltec", "r"])

    inv_capa = dh.get("o_inve")
    inv_capa.index.names = change_tec_lvl_name_to_alltec(inv_capa.index.names)
    inv_capa.index = inv_capa.index.droplevel(["new"])
    inv_capa = inv_capa.astype("Float64")

    return inv_capa.mul(cost)


# @functools.lru_cache
def variable_costs(dh: DataHandler):
    """
    This function calculates variable costs of all technologies in all regions.

    :param dh: DataHandler of simulation pack
    :param scen_hor_map: dictionary specifying the scenario specific horizons
    :return: pd.DataFrame of the variable costs.
    """
    print("PtHydrogen not implemented")

    scen_hor_map = dh.scenarios.horizon

    cost_var = dh.get("i_cost").xs("varcost", level="par_cost")
    cost_var = cost_var.groupby(["alltec"]).apply(
        extract_horizon_specific_cost, scen_hor_map
    )
    cost_var = add_dimension(cost_var, dh.merge_stored_sets("r"), "r")
    cost_var = cost_var.reorder_levels(["alltec", "r"])

    h2_price = dh.get("o_h2price_buy")
    h2_price = add_dimension(h2_price, dh.merge_stored_sets("tec_h2g"), "alltec")

    elec_price = dh.get("o_prices")

    cost_fuel = dh.get("cost_fuel")
    cost_fuel = add_dimension(cost_fuel, dh.merge_stored_sets("r"), "r")
    cost_fuel = cost_fuel.reorder_levels(["alltec", "r"])

    cost_fuel.loc[h2_price.index, :] = h2_price

    eff = dh.get("eff")

    co2_int = dh.get("co2_int").div(1000)

    co2_price = dh.get("o_co2price")

    co2_costs = co2_int * co2_price
    co2_costs.index.names = ["alltec", "r"]

    var_cost = (
        cost_fuel.add(co2_costs, fill_value=0).div(eff).add(cost_var, fill_value=0)
    )

    return var_cost
