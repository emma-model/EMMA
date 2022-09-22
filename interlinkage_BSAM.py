import pandas as pd

from analysis import (
    get_table,
    add_zeros,
    change_tec_lvl_name_to_alltec,
    market_value,
    electricity_balance,
    hydrogen_balance,
    pdc_pivot,
    total_investment_costs,
    DataHandler,
)
from call import read_scenarios
from renaming_SENTINEL import rename_df_index


def call_DataHandler():
    scenario_file = "scenarios_SENTINEL_CS_GR"
    scenarios = read_scenarios(scenario_file + ".yaml")
    return DataHandler(scenarios)


def extract_capacity():
    dh = call_DataHandler()

    capa = dh.get("o_capa")
    capa = rename_df_index(capa)
    capa["Unit"] = "GW"
    capa = capa.reset_index().set_index(["Technologies", "Vintage", "Region", "Unit"])

    capa.to_csv("Capacity_total.csv")


def extract_electricity_balance():
    dh = call_DataHandler()

    df = electricity_balance(dh)
    df = rename_df_index(df)
    df["Unit"] = "GWh"
    df = df.reset_index().set_index(["Region", "Type", "Unit"])

    df.to_csv("Electricity_balance.csv")


def extract_electricity_prices():
    dh = call_DataHandler()

    df = dh.get("o_prices")
    df = rename_df_index(df)
    df["Unit"] = "€/MWh"
    df = df.reset_index().set_index(["Time ID", "Region", "Unit"])

    df.to_csv("Electricity_prices.csv")


def extract_hydrogen_price():
    dh = call_DataHandler()

    h2_price = dh.get("o_h2price_buy")
    h2_price = rename_df_index(h2_price)
    h2_price["Unit"] = "EUR"
    h2_price = h2_price.reset_index().set_index(["Region", "Unit"])

    h2_price.to_csv("H2price_buy.csv")


def extract_CO2_price():
    dh = call_DataHandler()

    co2_price = dh.get("o_co2price")
    co2_price = rename_df_index(co2_price)
    co2_price["Unit"] = "EUR"
    co2_price = co2_price.reset_index().set_index(["Region", "Unit"])

    co2_price.to_csv("CO2price.csv")


def extract_batt_duration():
    dh = call_DataHandler()

    df = dh.get("o_stoinv")
    df = rename_df_index(df)
    df["Unit"] = ["GW", "GWh"]
    df = df.reset_index().set_index(
        ["Technologies", "Type", "Vintage", "Region", "Unit"]
    )
    df.loc[("Batteries", "Duration", "newbuild", "Greece", "h")] = (
        df.iloc[1, :] / df.iloc[0, :]
    )

    df.to_csv("Battery_duration.csv")


def extract_shed():
    dh = call_DataHandler()

    df = dh.get("o_supply")
    df = df.xs("shed", level="tec_supply", drop_level=False)
    df = rename_df_index(df)
    df["Unit"] = "GWh"
    df = df.reset_index().set_index(
        ["Time ID", "Technologies", "Vintage", "Region", "Unit"]
    )
    df.loc[("max", "Load shedding", "newbuild", "Greece", "GWh")] = df.max()

    df.to_csv("max_shed.csv")


def extract_emissions():
    dh = call_DataHandler()

    df = dh.get("o_emissions")
    df = rename_df_index(df)
    df["Unit"] = "Mt"
    df = df.reset_index().set_index(["Technologies", "Region", "Unit"])

    df.to_csv("Emissions.csv")


if __name__ == "__main__":
    extract_capacity()
    extract_hydrogen_price()
    extract_CO2_price()
    extract_batt_duration()
    extract_electricity_prices()
    extract_electricity_balance()
    extract_shed()
    extract_emissions()
