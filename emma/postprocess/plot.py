import os
import re
from typing import Tuple
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np

from dataclasses import dataclass
from collections import OrderedDict

from postprocess.tools import add_zeros

from postprocess.datahandler import DataHandler

from postprocess.analysis import (
    market_value,
    electricity_balance,
    hydrogen_balance,
    pdc_pivot,
    load_factor,
    total_investment_costs,
    full_load_hours,
)


# Standard colors for technologies
colors_techs = OrderedDict(
    [
        ("nucl", (254 / 255, 213 / 255, 1 / 255)),
        ("lign", (132 / 255, 60 / 255, 12 / 255)),
        ("coal", (0 / 255, 0 / 255, 0 / 255)),
        ("CCGT", (160 / 255, 160 / 255, 160 / 255)),
        ("OCGT", (190 / 255, 190 / 255, 190 / 255)),
        ("lign_CCS", (228 / 255, 179 / 255, 99 / 255)),
        ("coal_CCS", (90 / 255, 90 / 255, 90 / 255)),
        ("CCGT_CCS", (190 / 255, 160 / 255, 160 / 255)),
        ("CCGT_H2", (70 / 255, 255 / 255, 255 / 255)),
        ("OCGT_H2", (140 / 255, 255 / 255, 255 / 255)),
        ("gas", (160 / 255, 160 / 255, 160 / 255)),
        ("hydr", (121 / 255, 168 / 255, 202 / 255)),
        ("ror", (154 / 255, 187 / 255, 202 / 255)),
        ("bio", (112 / 255, 173 / 255, 71 / 255)),
        ("wion", (31 / 255, 130 / 255, 192 / 255)),
        ("wiof", (0 / 255, 96 / 255, 153 / 255)),
        ("solar", (255 / 255, 249 / 255, 100 / 255)),
        ("PHS", (0 / 255, 57 / 255, 107 / 255)),
        ("batr", (200 / 255, 0 / 255, 0 / 255)),
        ("Heat", (255 / 255, 0 / 255, 0 / 255)),
        ("shed", (230 / 255, 230 / 255, 230 / 255)),
        ("PtHydrogen", (153 / 255, 255 / 255, 153 / 255)),
        ("import", (238 / 255, 162 / 255, 173 / 255)),
        ("cur", (238 / 255, 44 / 255, 44 / 255)),
    ]
)

# Standard colors for regions
colors_r = OrderedDict(
    [
        ("GER", "#1f77b4"),
        ("SWE", "#ff7f0e"),
        ("FRA", "#2ca02c"),
        ("NLD", "#d62728"),
        ("GBR", "#9467bd"),
        ("BEL", "#8c564b"),
        ("DNK", "#e377c2"),
        ("NOR", "#7f7f7f"),
        ("CHE", "#bcbd22"),
        ("AUT", "#17becf"),
        ("POL", "#aec7e8"),
        ("CZE", "#ffbb78"),
        ("GRC", "#98df8a"),
    ]
)

# Renaming map for technology
renaming_map_techs = {
    "CCGT": "CCGT",
    "OCGT": "OCGT",
    "CCGT_CCS": "CCGT with CCS",
    "CCGT_H2": "Hydrogen fueled CCGT",
    "OCGT_H2": "Hydrogen fueled OCGT",
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
    "PtHydrogen": "Electrolyzers",
    "import": "Import",
    "cur": "Curtailment",
}

# Renaming map for region
renaming_map_r = {
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
}

potential_ids = list(renaming_map_techs.keys()) + list(renaming_map_r.keys())
id = {k: k for k in potential_ids}

# basic plot functions
def stacked_bar_chart(
    ax: plt.axis,
    df: pd.DataFrame,
    color_map: dict,
    ylabel: str,
    renaming_map: dict = id,
    width: float = 0.8,
):
    """
    This function creates a stacked bar chart with costumized colors, a renaming map and a chance to list keys multiple times (for balance plots).

    :param ax: an matplotlib.pyplot.axis object
    :param df: pd.DataFrame which will be plotted
    :param color_map: dictionary which defines the colors of the index values
    :param ylabel: string of y-label
    :param renaming_map: dictionary which defines the names of index values appearing in the legend
    :return: stacked bar chart of df
    """
    x = range(df.shape[1])
    bottom = 0
    bottom_negative = 0

    # Defines the order of appearence
    labels = color_map.keys()

    # Removes techs that are not in the data (otherwise loop breaks)
    labels = [l for l in labels if l in list(df.index.values)]

    assert set(df.index.values).issubset(
        list(labels)
    ), "You haven't defined a color for these technologies:" + str(
        set(df.index.values) - set(labels)
    )
    for i in labels:

        tech = df.loc[i]

        # this if-else clause is integrated since there are technologies which can both use and generate electricity and are therefore twice in a bar.
        if isinstance(tech, pd.DataFrame):
            for j in range(len(tech.index)):
                # Positive
                ax.bar(
                    x,
                    tech.iloc[j, :].clip(lower=0),
                    label=renaming_map[i],
                    bottom=bottom,
                    color=color_map[i],
                    width=width,
                )
                bottom += tech.iloc[j, :].clip(lower=0)
                # Negative
                ax.bar(
                    x,
                    tech.iloc[j, :].clip(upper=0),
                    label=renaming_map[i],
                    bottom=bottom_negative,
                    color=color_map[i],
                    width=width,
                )
                bottom_negative += tech.iloc[j, :].clip(upper=0)

        else:
            # Positive
            ax.bar(
                x,
                tech.clip(lower=0),
                label=renaming_map[i],
                bottom=bottom,
                color=color_map[i],
                width=width,
            )
            bottom += tech.clip(lower=0)
            # Negative
            ax.bar(
                x,
                tech.clip(upper=0),
                label=renaming_map[i],
                bottom=bottom_negative,
                color=color_map[i],
                width=width,
            )
            bottom_negative += tech.clip(upper=0)

    # X axis
    ax.set_xticks(x)
    ax.set_xticklabels(df.columns)

    # Y axis
    ax.set_ylabel(ylabel)
    y_bottom = bottom_negative.min() + 0.1 * bottom_negative.min()
    y_top = bottom.max() + 0.1 * bottom.max()
    ax.set_ylim(y_bottom, y_top)

    # Grid
    ax.grid(axis="y", zorder=0, color="grey", linewidth=0.5)

    return ax


def draw_legend(
    fig: plt.figure,
    axes: plt.axis,
    pos: Tuple[float, float] = (1.1, 0.5),
    ncol: int = 1,
):
    """
    This function draws a legend of the unionized labels and handels of all plots in axes.

    :param fig: plt.figure
    :param axes: plt.axis which contain handles and labels
    :param pos: tuple of x- and y-position of the legend
    :return: figure and axes with drawn legend
    """
    if hasattr(axes, "__iter__"):
        handles, labels = [], []
        for ax in axes:
            h, l = ax.get_legend_handles_labels()
            handles = handles + h
            labels = labels + l
    else:
        handles, labels = axes.get_legend_handles_labels()

    handles.reverse()
    labels.reverse()
    by_label = dict(zip(labels, handles))
    fig.legend(
        by_label.values(), by_label.keys(), loc="center", bbox_to_anchor=pos, ncol=ncol
    )
    return axes


def savefig(
    fig: plt.figure,
    ax: plt.axis,
    name: str,
    type: str = "png",
    save_figure: bool = True,
):
    """
    This function saves the plot.

    :param fig: plt.figure which should be saved
    :param axis: plt.axis which should be saved
    :param name: string save name
    :param type: string save type
    :param save_figure: boolean which decides whether figure is saved
    """
    if save_figure:
        fig.savefig(f"{name}.{type}", bbox_inches="tight")

    return fig, ax


@dataclass
class PlotHandler:
    dh: DataHandler
    save_figures: bool = False

    def plot_capacity(
        self,
        focus_region=None,
        generic_rename=True,
        renaming_map=id,
        figsize=(10, 5),
        pos=(1.05, 0.5),
    ):
        df = self.dh.get("o_capa")
        df = df.loc[[i for i in df.index.levels[0] if i != "shed"]]
        alltec = self.dh.merge_stored_sets("alltec")
        shed_index = np.where(alltec == "shed")
        alltec = np.delete(alltec, shed_index)
        df = add_zeros(
            df,
            pd.MultiIndex.from_product(
                [alltec, self.dh.merge_stored_sets("r")], names=["alltec", "r"]
            ),
        )

        if focus_region:
            df = df.xs(focus_region, level="r")

        df = df.groupby(["alltec"]).sum()

        if generic_rename:
            renaming_map = renaming_map_techs

        fig, ax = plt.subplots(1, 1, figsize=figsize)

        ax = stacked_bar_chart(
            ax, df, colors_techs, ylabel="Capacity (GW)", renaming_map=renaming_map
        )
        ax = draw_legend(fig, ax, pos=pos)
        ax.set_title(
            "Capacity of {}".format(
                "all modeled regions"
                if focus_region == None
                else renaming_map_r[focus_region]
            )
        )

        return savefig(
            fig, ax, name=f"capacity_{focus_region}", save_figure=self.save_figures
        )

    def plot_electricity_balance(
        self,
        focus_region=None,
        generic_rename=True,
        renaming_map=id,
        figsize=(10, 5),
        pos=(1.05, 0.5),
    ):
        df = electricity_balance(self.dh)
        load = self.dh.get("o_load")
        if focus_region:
            df = df.xs(focus_region, level="r")
            load = load.xs(focus_region, level="r")
        df = df.groupby(["alltec", "type"]).sum()
        df.index = df.index.droplevel("type")
        load = load.sum().div(1000)

        if generic_rename:
            renaming_map = renaming_map_techs

        fig, ax = plt.subplots(1, 1, figsize=figsize)
        ax = stacked_bar_chart(
            ax, df, colors_techs, ylabel="TWh", renaming_map=renaming_map
        )
        ax.plot(
            load.index, load.values, label="demand", color="black", linestyle="dashed"
        )
        ax = draw_legend(fig, ax, pos=pos)
        ax.set_title(
            "Electricity balance of {}".format(
                "all modeled regions"
                if focus_region == None
                else renaming_map_r[focus_region]
            )
        )
        ax.axhline(y=0, linewidth=1, color="k")

        return savefig(
            fig,
            ax,
            name=f"electricity_balance_{focus_region}",
            save_figure=self.save_figures,
        )

    def plot_hydrogen_balance(
        self, focus_region=None, generic_rename=True, renaming_map=id
    ):
        df = hydrogen_balance(self.dh)
        load = self.dh.get("o_h2_demand_exo").fillna(0)
        if focus_region:
            df = df.xs(focus_region, level="r")
            load = load.loc[focus_region, :].div(1000).astype("float64")
        else:
            load = load.sum().div(1000)
        df = df.groupby(["alltec"]).sum()

        if generic_rename:
            renaming_map = renaming_map_techs

        fig, ax = plt.subplots(1, 1, figsize=(10, 5))
        ax = stacked_bar_chart(
            ax, df, colors_techs, ylabel="TWht", renaming_map=renaming_map
        )
        ax.plot(
            load.index, load.values, label="demand", color="black", linestyle="dashed"
        )
        ax = draw_legend(fig, ax)
        ax.set_title(
            "Hydrogen balance of {}".format(
                "all modeled regions"
                if focus_region == None
                else renaming_map_r[focus_region]
            )
        )
        ax.axhline(y=0, linewidth=1, color="k")

        return savefig(
            fig,
            ax,
            name=f"hydrogen_balance_{focus_region}",
            save_figure=self.save_figures,
        )

    def plot_co2_emissions(self, generic_rename=True, renaming_map=id):
        # Data handling
        df = pd.concat(
            [
                self.dh.get("o_emissions").groupby(["r"]).sum(),
                add_zeros(
                    self.dh.get("o_co2_capture"),
                    pd.Index(self.dh.merge_stored_sets("r"), name="r"),
                )
                * -1,
            ]
        )
        co2_cap = self.dh.get("o_co2_cap").sum()

        cap_height = 0.015
        cap_height_series = pd.Series(
            co2_cap.values.max() * cap_height, index=co2_cap.index
        )
        i = 0
        for keys in self.dh.scenarios.params:
            if self.dh.scenarios.params[keys]["clp"]["--CARBONCAP"] != 1:
                cap_height_series.iloc[i, :] = 0
            i += 1

        if generic_rename:
            renaming_map = renaming_map_r

        fig, ax = plt.subplots(1, 1, figsize=(10, 5))
        ax = stacked_bar_chart(
            ax, df, colors_r, "CO2 Emissions (Mt)", renaming_map=renaming_map
        )
        ax.bar(
            co2_cap.index, cap_height_series, label="cap", bottom=co2_cap, color="black"
        )
        ax = draw_legend(fig, ax)
        return savefig(fig, ax, name="co2_emissions", save_figure=self.save_figures)

    def plot_mv(self, tec_list, generic_rename=True, renaming_map=id):
        df = market_value(self.dh)

        if generic_rename:
            renaming_map = renaming_map_r

        fig, axes = plt.subplots(
            1, len(tec_list), figsize=(10, 5), sharex=True, sharey=True
        )
        for i in range(len(tec_list)):
            # checks if there is any data for the technology
            if df.index.isin([tec_list[i]], level="tec_supply").any():
                # extracting market value data of wished technology.
                df_helper = df.xs(tec_list[i], level="tec_supply").transpose()

                for r in df_helper.columns:
                    axes[i].plot(
                        df_helper[r].index,
                        df_helper[r].values,
                        color=colors_r[r],
                        marker="o",
                        linestyle="--",
                        label=renaming_map[r],
                    )

            axes[i].set_title(renaming_map_techs[tec_list[i]])
            axes[i].set_ylabel("Market value (Euro/MWh)")
            axes[i].set_xlabel("")
            axes[i].tick_params("x", labelrotation=45, bottom=True, labelbottom=True)
            axes[i].grid(axis="y", zorder=0, color="grey", linewidth=0.5)

        # fig.text(0.07, 0.5, 'Market value [Euro/GWh]', va='center', rotation='vertical')
        # Main Title
        fig.suptitle("Market value")
        axes = draw_legend(fig, axes)
        return savefig(fig, axes, name="market_value", save_figure=self.save_figures)

    def plot_pdc(self, focus_region=True, ylim=None, figsize=(10, 5), pos=(1.14, 0.5)):
        df = pdc_pivot(self.dh)
        if focus_region:
            df = df.xs(focus_region, level="r", axis=1)
        fig, ax = plt.subplots(1, 1, figsize=figsize)
        df.plot(ax=ax, xlabel="Hour", ylabel="Price (Euro/MWh)")
        ax.grid(axis="y")
        if ylim is not None:
            ax.set_ylim(ylim)
            print(
                "The y-axis of this figure is limited to {}.\n\nThe maximum prices are:\n\n{}\n\nThe minimum prices are:\n\n{}".format(
                    ylim,
                    df.max().rename("max_prices").to_frame().T,
                    df.min().rename("min_prices").to_frame().T,
                )
            )
        ax.legend(loc="center", bbox_to_anchor=pos)
        ax.set_title(
            "Price Duration Curve of {}".format(
                "all modeled regions"
                if focus_region == None
                else renaming_map_r[focus_region]
            )
        )
        return savefig(
            fig, ax, name=f"pdc_{focus_region}", save_figure=self.save_figures
        )
