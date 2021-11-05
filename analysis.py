import os
import re
import pandas as pd
import sqlite3
import contextlib
import matplotlib.pyplot as plt
import numpy as np

from call import folder, read_scenarios
from collections import OrderedDict

# Standard colors
colors = OrderedDict([
    ('nucl'    ,     (254/255, 213/255,   1/255)),
    ('lign'    ,     (132/255,  60/255,  12/255)),
    ('coal'    ,     (  0/255,   0/255,   0/255)),
    ('CCGT'    ,     (160/255, 160/255, 160/255)),
    ('OCGT'    ,     (190/255, 190/255, 190/255)),

    ('lign_CCS',     (228/255, 179/255,  99/255)),
    ('coal_CCS',     ( 90/255,  90/255,  90/255)),
    ('CCGT_CCS',     (190/255, 160/255, 160/255)),

    ('CCGT_H2',      ( 70/255, 255/255, 255/255)),
    ('OCGT_H2',      (140/255, 255/255, 255/255)),

    ('gas'     ,     (160/255, 160/255, 160/255)),

    ('hydr'    ,     (121/255, 168/255, 202/255)),
    ('ror'     ,     (154/255, 187/255, 202/255)),
    ('bio'     ,     (112/255, 173/255,  71/255)),

    ('wion',         ( 31/255, 130/255, 192/255)),
    ('wiof',         (  0/255,  96/255, 153/255)),
    ('solar',        (255/255, 249/255, 100/255)),

    ('PHS'     ,     (  0/255,  57/255, 107/255)),
    ('batr'    ,     (200/255,   0/255,   0/255)),
    ('Heat'    ,     (255/255,   0/255,   0/255)),
    ('shed'    ,     (230/255, 230/255, 230/255)),

    ('PtHydrogen',   (153/255, 255/255, 153/255)),

    ('import',       (238/255, 162/255, 173/255)),
    ('cur',          (238/255,  44/255,  44/255))
])

colors_r = OrderedDict([
    ('GER',     '#1f77b4'),
    ('SWE',     '#ff7f0e'),
    ('FRA',     '#2ca02c'),
    ('NLD',     '#d62728'),
    ('GBR',     '#9467bd'),
    ('BEL',     '#8c564b'),
    ('DNK',     '#e377c2'),
    ('NOR',     '#7f7f7f'),
    ('CHE',     '#bcbd22'),
    ('AUT',     '#17becf'),
    ('POL',     '#aec7e8'),
    ('CZE',     '#ffbb78'),
    ('GRC',     '#98df8a')
])


# Load ,data from SQLites

def get_table(scenarios, scenario_id, table_name, use_name=False):
    path = os.path.join(folder['sql_files'], str(scenario_id) + '.db')

    if not os.path.isfile(path):
        print("Warning: tables does not exists in scenario id:", scenario_id)
        return None

    try:
        with contextlib.closing(sqlite3.connect(path)) as connection:
            query = "SELECT * FROM {}".format(table_name)
            df = pd.read_sql_query(query, connection)
            df = df.convert_dtypes()

            if 't' in df.columns:
                df['t'] = df['t'].astype('int32')

            idx = list(df.columns)
            if len(idx)>1:
                idx.remove('value')
                df = df.set_index(idx)
                df = df.rename(columns={"value": str(scenarios[scenario_id]['name']) if use_name else str(scenario_id)})

            df.columns.names = ['scenario']

        return df
    except Exception as e:
        print(e)
        print(f'Table {table_name} not cannot be queried for scenario {scenario_id}')
        return None


def merge_tables(scenarios, table_name, historical=False):
    dataframes = [get_table(scenarios, scenario_id, table_name, use_name=True) for scenario_id in scenarios]
    df = pd.concat(dataframes, axis=1)

    # Needed because otherwise the index name disappears when merging on columns with an empty dataframe
    for dataframe in dataframes:
        if dataframe.index.name:
            df.index.name = dataframe.index.name

    return df


class Data_handler:
    """Class to retrieve SQLite tables, perform additional calculations and store the result in memory"""

    def __init__(self, scenarios):
        self.scenarios = scenarios
        self.data = {}
        self.composite = {}

    def get(self, table_name):
        """Merges all tables with a given name and returns a dataframe

        :param table_name: str (can be whatever table name is contained in the SQLite fiels)
        :return: dataframe with each column being a scenario
        """
        if table_name not in self.data:
            self.data[table_name] = merge_tables(self.scenarios, table_name)
        return self.data[table_name].copy()

    def get_composite(self, method):
        """Performs calculations based on SQLite tables and returns the result in a df with one column per scenario

        :param method: str, implemented methods are: 'market_value', 'full_load_hours', 'load_factor'.
        :return: dataframe with each column being a scenario
        """
        if method not in self.composite:
            if method == 'market_value':
                #adding all vintage classes together
                df_supply = self.get('o_supply').groupby(['r','tec_supply','t']).sum()
                df_supply = df_supply.stack().unstack('t').T
                df_price = self.get('o_prices').stack().unstack('t').T

                #calculate market value
                df_mv = df_supply.mul(df_price, fill_value = np.nan).sum().div(df_supply.sum()).unstack('scenario')

                # Save market value
                self.composite[method] = df_mv

            elif method == 'full_load_hours':
                print('Warning: this implmentation is not compatible with storages yet!')
                gen_df = self.get('o_supply')
                gen_df.index.names = change_tec_lvl_name_to_alltec(gen_df.index.names)
                cap_df = self.get('o_capa')

                # In not all hours of the year are simulated, generation needs to be scaled by sc
                sc = 8760 / len(gen_df.index.get_level_values('t').unique())
                cum_gen_df = gen_df.groupby(['alltec', 'allvin', 'r'], dropna=False).sum() * sc

                # Calculate full load hours
                flh_df = cum_gen_df.divide(cap_df)

                # Save full_load_hours
                self.composite[method] = flh_df

            elif method == 'load_factor':
                # Can be easily defined recursively (only 'full_load_hours' if then saves but no big deal)
                return self.get_composite('full_load_hours') / 8760
            else:
                raise Exception('This method has not been implemented:', method)

        return self.composite[method].copy()


def add_zeros(df,mI):
    df_zeros = pd.DataFrame(0, index = mI, columns = df.columns)
    df = pd.merge(df_zeros,df, how="outer",on = mI.names).fillna(0)

    columns_x = [sc + '_x' for sc in df_zeros.columns]
    df1 = df[columns_x]
    df1.columns = df_zeros.columns

    columns_y = [sc + '_y' for sc in df_zeros.columns]
    df2 = df[columns_y]
    df2.columns = df_zeros.columns

    return df1.add(df2)


def change_tec_lvl_name_to_alltec(names):
    '''
    Function changes level name of technology level (for example tec_supply) to alltec
    '''
    new_names = []
    for i in range(len(names)):
        m = re.search('.*tec.*',names[i])
        if m != None:
            new_names.append('alltec')
        else:
            new_names.append(names[i])
    return new_names


# Plots and evaluation

def plot_by_tec(df, alltec, ylabel, figsize=(8, 5)):

    tec_name = ''
    for scen in df.index.names:
        m = re.search('.*tec.*',scen)
        if m != None:
            tec_name = m.string
    if tec_name == '':
        print('There is no technology level in your dataframe.')
    df = add_zeros(df,pd.Index(alltec,name=tec_name))

    fig = plt.figure(figsize=figsize)

    ax = fig.add_subplot(111)
    x = range(df.shape[1])
    bottom = 0
    bottom_negative = 0

    # Defines the order of appearence
    labels = colors.keys()

    # Removes techs that are not in the data (otherwise loop breaks)
    labels = [l for l in labels if l in list(df.index.values)]

    assert set(df.index.values).issubset(list(labels)), "You haven't defined a color for these technologies:"\
                                                        + str(set(df.index.values)-set(labels))
    handles = []
    for i in labels:

        tech = df.loc[i]
        # Positive
        handle = plt.bar(x, tech.clip(lower=0), label=i, bottom=bottom, color=colors[i])
        bottom += tech.clip(lower=0)

        # Negative
        handle = plt.bar(x, tech.clip(upper=0), label=i, bottom=bottom_negative, color=colors[i])
        bottom_negative += tech.clip(upper=0)

        handles.append(handle[0])

    # X axis
    ax.set_xticks(x)
    ax.set_xticklabels(df.columns)

    # Y axis
    ax.set_ylabel(ylabel)
    y_bottom = bottom_negative.min()+0.1*bottom_negative.min()
    y_top = bottom.max()+0.1*bottom.max()
    ax.set_ylim(y_bottom,y_top)

    # Grid
    plt.grid(axis='y', zorder=0, color='grey', linewidth=.5)

    plt.legend(labels=labels[::-1], handles=handles[::-1], loc='center', bbox_to_anchor=(1.1, 0.5))

    return ax


def plot_by_tec_and_hour(df, scenario, hour_range, focus_region, figsize=(8, 5), bar=True,load=None ,prices=None):
    '''
    :params df: DataFrame o_supply or different generation data set with levels time, tec and region
            scenario: string, scenario name
            hour_range: tuple with first entry as range start and second entry as range end
            focus_region: string, focus_region name

    '''
    assert focus_region in df.index.get_level_values('r'), "this region has not been simulated: " + focus_region
    assert scenario in df.columns, "this scenario has not been simulated: " + str(scenario)
    assert len(hour_range) == 2, "hour_range must me a list of two elements"

    # creates Dataframe of scenario and focus region with points of time as columns and different techs as rows.
    df = df.groupby(['t', 'tec_supply', 'r']).sum().reset_index() \
        .pivot(index=('tec_supply', 'r'), columns='t') \
        .xs(focus_region, level='r').loc[:, scenario].loc[:, hour_range[0]:hour_range[1]]

    # This is to remove techs that have no capacity
    df = df.fillna(0)
    df = df[(df.T != 0).any()]

    fig = plt.figure(figsize=figsize)
    ax = fig.add_subplot(111)
    x = range(df.shape[1])
    b_pos = 0
    b_neg = 0

    # Defines the order of appearence
    labels = colors.keys()

    assert set(df.index.values).issubset(list(labels)), "You haven't defined a color for these technologies:"\
                                                        + str(set(df.index.values)-set(labels))

    # Removes techs that are not in the data (otherwise loop breaks)
    labels = [l for l in labels if l in list(df.index.values)]

    handles = []
    for i in labels:
        pos = df.loc[i].clip(lower=0)
        neg = df.loc[i].clip(upper=0)
        if bar:
            handle = plt.bar(x, pos, label=i, bottom=b_pos, color=colors[i])[0]
            handle = plt.bar(x, neg, label=i, bottom=b_neg, color=colors[i])[0]
        else:
            handle = plt.fill_between(x, b_pos, b_pos+pos, label=i, color=colors[i], linewidth=0)
            handle = plt.fill_between(x, b_neg, b_neg+neg, label=i, color=colors[i], linewidth=0)
        b_pos += pos
        b_neg += neg
        handles.append(handle)

    if load is not None:
        assert isinstance(load, pd.Series), 'load must be an pandas Series'
        print(load,df)
        load.plot(color='black',linestyle='--')

    if prices is not None:
        assert isinstance(prices, pd.Series), 'Prices must be an pandas Series'
        ax2 = ax.twinx()
        ax2.set_ylabel("Power price")
        #print(prices.ravel(order="C"))
        ax2.plot(x, prices.values.to_numpy())

        ## Not implemented yet: Ensure that axis align at 0 intersect
        # miny, maxy = ax.get_ylim()
        # miny2, maxy2 = ax2.get_ylim()
        # '''add logic to define and replace -10, 10, -6 ,6'''
        # ax.set_ylim(-10,10)
        # ax2.set_ylim(-6,6)

    # X axis
    ax.set_xticks(x)
    ax.set_xticklabels(df.columns)

    # Y axis
    ylabel = 'Generation by technology'
    ax.set_ylabel(ylabel)


    # Grid
    plt.grid(axis='y', zorder=0, color='grey', linewidth=.5)

    plt.legend(labels=labels[::-1], handles=handles[::-1], loc='center', bbox_to_anchor=(1.1, 0.5))
    plt.title(str(focus_region) + ' in scenario ' + scenario + ': ' + 'from hour ' + str(hour_range[0]) + ' to hour ' + str(hour_range[1]))

    return df


def pdc_pivot(prices, scenario=None, region=None):
    df = prices

    df = df.reset_index().pivot(index='t', columns='r')

    for col in df.columns:
        df[col] = sorted(df[col])

    df = df.reset_index(drop=True)

    if scenario is None:
        scenario = slice(None)
    if region is None:
        region = slice(None)

    df = df.loc[:, (scenario, region)]

    return df


def plot_energy_balance(dh, focus_region=None, ylabel="TWh", figsize=(8, 5),show_data =False):
    """
    Function to plot energy balance plots of a focus_region
    :param dh: data_handler with scenarios
    :param focus_region: str
    :return ax: energy balance plot
    """
    regions = get_table(dh.scenarios,next(iter(dh.scenarios)),'r',use_name = True)['rall'].values
    alltec = get_table(dh.scenarios,next(iter(dh.scenarios)),'alltec',use_name = True)['alltec'].values
    # Data handling
    if focus_region == None:
        df = pd.concat([dh.get('o_supply').groupby(['tec_supply']).sum().div(1000),
                        dh.get('o_demand').groupby(['tec_demand']).sum().div(1000)*-1,
                        pd.DataFrame([dh.get('o_import').sum().div(1000)],index=['import']),
                        pd.DataFrame([dh.get('o_cur').sum().div(1000)*-1],index=['cur'])])
        df.index.names = ["alltec"]
        df = add_zeros(df,pd.Index(alltec,name="alltec"))

        load = -dh.get('o_import').sum().div(1000)\
                -dh.get('o_flow').sum().div(1000)\
                +dh.get('o_load').sum().div(1000)

        if show_data:
            print('The electricitiy balance data: \n',df)
            print('_____________________________________________________________________\n')
            print('The exogenous load: \n',pd.DataFrame([load],index = ['load']))

        l_ind = load.index
        load = load.to_numpy()

    else:
        supply = dh.get('o_supply').groupby(['tec_supply', 'r']).sum()
        supply.index.names = ['alltec','r']

        demand = dh.get('o_demand').groupby(['tec_demand', 'r']).sum()*-1
        demand.index.names = ['alltec','r']

        imp = dh.get('o_import').groupby('r').sum().reset_index()
        imp['alltec'] = pd.Series('import',index = imp.index)
        imp = imp.set_index(['alltec','r'])

        curt = dh.get('o_cur').groupby('r').sum()*-1
        curt['alltec'] = pd.Series('cur',index = curt.index)
        curt = curt.reset_index().set_index(['alltec','r'])

        df = pd.concat([supply,demand,imp,curt])
        df = add_zeros(df,pd.MultiIndex.from_product([alltec,regions], names=["alltec", "r"]))
        df = df.xs(focus_region, level = 'r').div(1000)

        load = add_zeros(dh.get('o_load').groupby('r').sum(),pd.Index(regions,name="r")).loc[focus_region,:].div(1000)
        load = load - add_zeros(dh.get('o_import').groupby('r').sum(),pd.Index(regions,name="r")).loc[focus_region,:].div(1000) if not dh.get('o_import').groupby('r').sum().empty else load
        load = load - add_zeros(dh.get('o_flow').groupby('r').sum(),pd.Index(regions,name="r")).loc[focus_region,:].div(1000) if not dh.get('o_flow').groupby('r').sum().empty else load

        if show_data:
            print('The electricitiy balance data: \n',df)
            print('_____________________________________________________________________\n')
            print('The exogenous load: \n',pd.DataFrame([load],index = ['load']))

        l_ind = load.index
        load = load.to_numpy()

    fig = plt.figure(figsize=figsize)

    ax = fig.add_subplot(111)
    x = range(df.shape[1])
    bottom = 0
    bottom_negative = 0

    # Defines the order of appearence
    labels = colors.keys()

    # Removes techs that are not in the data (otherwise loop breaks)
    labels = [l for l in labels if l in list(df.index.values)]

    assert set(df.index.values).issubset(list(labels)), "You haven't defined a color for these technologies:"\
                                                        + str(set(df.index.values)-set(labels))
    handles = []
    for i in labels:

        tech = df.loc[i]

        # this if-else clause is integrated since there are technologies which can both use and generate electricity and are therefore twice in a bar.
        if isinstance(tech, pd.DataFrame):
            for j in range(len(tech.index)):
                # Positive
                handle = plt.bar(x, tech.iloc[j, :].clip(lower=0), label=i, bottom=bottom, color=colors[i])
                bottom += tech.iloc[j, :].clip(lower=0)
                # Negative
                handle = plt.bar(x, tech.iloc[j, :].clip(upper=0), label=i, bottom=bottom_negative, color=colors[i])
                bottom_negative += tech.iloc[j, :].clip(upper=0)

            handles.append(handle[0])

        else:
            # Positive
            handle = plt.bar(x, tech.clip(lower=0), label=i, bottom=bottom, color=colors[i])
            bottom += tech.clip(lower=0)
            # Negative
            handle = plt.bar(x, tech.clip(upper=0), label=i, bottom=bottom_negative, color=colors[i])
            bottom_negative += tech.clip(upper=0)

            handles.append(handle[0])

    handle = plt.plot(l_ind,load,label="demand",color="black",linestyle='dashed')
    handles.append(handle[0])
    labels.append('demand')
    # X axis
    ax.set_xticks(x)
    ax.set_xticklabels(df.columns)

    # Y axis
    ax.set_ylabel(ylabel)
    y_bottom = bottom_negative.min()+0.1*bottom_negative.min()
    y_top = bottom.max()+0.1*bottom.max()
    ax.set_ylim(y_bottom,y_top)

    # title
    ax.set_title('Electricity Balance of {}'.format('all regions' if focus_region == None else focus_region))

    # Grid
    plt.grid(axis='y', zorder=0, color='grey', linewidth=.5)

    # Balance line at 0.
    plt.axhline(y=0,linewidth=1, color='k')

    plt.legend(labels=labels[::-1], handles=handles[::-1], loc='center', bbox_to_anchor=(1.1, 0.5))

    return ax


def plot_hydrogen_balance(dh, focus_region=None, ylabel="TWht", figsize=(8, 5),show_data=False):
    """
    Function to plot hydrogen balance plots of a focus_region per scenario
    :param dh: data_handler with scenarios
    :param focus_region: str
    :return ax: hydrogen balance plot
    """

    # lists with all H2 techs and regions which were used in this scenario
    regions = get_table(dh.scenarios,next(iter(dh.scenarios)),'r',use_name = True)['rall'].values
    tec_h2 = get_table(dh.scenarios,next(iter(dh.scenarios)),'tec_h2',use_name = True)['alltec'].values

    # Data handling
    if focus_region == None:
        df = pd.concat([dh.get('o_h2_gene').fillna(0).groupby(['tec_h2d']).sum().div(1000),
                        dh.get('o_h2_usage').fillna(0).groupby(['tec_h2g']).sum().div(1000)*-1,
                        pd.DataFrame([dh.get('o_h2_imports').sum().div(1000)],index=['import'])])

        df.index.names = ["tec_h2"]
        # adds zeros to all techs which were not using or generating H2 to let them show in the plots legend
        df = add_zeros(df,pd.Index(tec_h2,name="tec_h2"))

        # exogeneous H2 demand
        load = dh.get('o_h2_demand_exo').sum().div(1000)

        if show_data:
            print('The hydrogen balance data: \n',df)
            print('_____________________________________________________________________\n')
            print('The exogenous load: \n',pd.DataFrame([load],index = ['load']))

        l_ind = load.index
        load = load.to_numpy()

    else:
        supply = dh.get('o_h2_gene').fillna(0).groupby(['tec_h2d', 'r']).sum()
        supply.index.names = ['tec_h2','r']

        demand = dh.get('o_h2_usage').fillna(0).groupby(['tec_h2g', 'r']).sum()*-1
        demand.index.names = ['tec_h2','r']

        imp = dh.get('o_h2_imports')
        imp = add_zeros(imp,pd.Index(regions,name='r'))
        imp = imp.reset_index()
        imp['tec_h2'] = pd.Series('import',index = imp.index)
        imp = imp.set_index(['tec_h2','r'])

        df = pd.concat([supply,demand,imp])
        df = add_zeros(df,pd.MultiIndex.from_product([tec_h2,regions], names=["tec_h2", "r"]))
        df = df.xs(focus_region, level = 'r').div(1000)

        load = dh.get('o_h2_demand_exo')
        if focus_region in load.index:
            load = load.loc[focus_region,:].div(1000).fillna(0)
        else:
            load = pd.Series(0,df.columns)

        if show_data:
            print('The hydrogen balance data: \n',df)
            print('_____________________________________________________________________\n')
            print('The exogenous load: \n',pd.DataFrame([load],index = ['load']))

        l_ind = load.index
        load = load.to_numpy()

    fig = plt.figure(figsize=figsize)

    ax = fig.add_subplot(111)
    x = range(df.shape[1])
    bottom = 0
    bottom_negative = 0

    # Defines the order of appearence
    labels = colors.keys()

    # Removes techs that are not in the data (otherwise loop breaks)
    labels = [l for l in labels if l in list(df.index.values)]

    assert set(df.index.values).issubset(list(labels)), "You haven't defined a color for these technologies:"\
                                                            + str(set(df.index.values)-set(labels))
    handles = []
    for i in labels:

        tech = df.loc[i]

        if isinstance(tech, pd.DataFrame):
            for j in range(len(tech.index)):
                # Positive
                handle = plt.bar(x, tech.iloc[j,:].clip(lower=0), label=i, bottom=bottom, color=colors[i])
                bottom += tech.iloc[j,:].clip(lower=0)
                # Negative
                handle = plt.bar(x, tech.iloc[j,:].clip(upper=0), label=i, bottom=bottom_negative, color=colors[i])
                bottom_negative += tech.iloc[j,:].clip(upper=0)

            handles.append(handle[0])

        else:
            # Positive
            handle = plt.bar(x, tech.clip(lower=0), label=i, bottom=bottom, color=colors[i])
            bottom += tech.clip(lower=0)
            # Negative
            handle = plt.bar(x, tech.clip(upper=0), label=i, bottom=bottom_negative, color=colors[i])
            bottom_negative += tech.clip(upper=0)

            handles.append(handle[0])

    handle = plt.plot(l_ind,load,label="demand_exo",color="black",linestyle='dashed')
    handles.append(handle[0])
    labels.append('demand_exo')

    # X axis
    ax.set_xticks(x)
    ax.set_xticklabels(df.columns)

    # Y axis
    ax.set_ylabel(ylabel)
    y_bottom = bottom_negative.min()+0.1*bottom_negative.min()
    y_top = bottom.max()+0.1*bottom.max()
    ax.set_ylim(y_bottom,y_top)

    # title
    ax.set_title('Hydrogen Balance of {}'.format('all regions' if focus_region == None else focus_region))

    # Grid
    plt.grid(axis='y', zorder=0, color='grey', linewidth=.5)

    # balance line at 0
    plt.axhline(y=0,linewidth=1, color='k')

    plt.legend(labels=labels[::-1], handles=handles[::-1], loc='center', bbox_to_anchor=(1.1, 0.5))

    return ax


def plot_co2_emissions(dh, figsize=(8, 5),show_cap = True,show_data=False):
    """
    Function to plot CO2 emmision of all modeled regions with the CO2 cap
    :param dh: data_handler with scenarios
    :return ax: CO2 emissions plot
    """
    # list of all possible regions
    regions = get_table(dh.scenarios,next(iter(dh.scenarios)),'r',use_name = True)['rall'].values

    # Data handling
    df = pd.concat([dh.get('o_emissions').groupby(['r']).sum(),
                    add_zeros(dh.get('o_co2_capture'),pd.Index(regions,name="r"))*-1])
    co2_cap = dh.get('o_co2_cap').sum()

    l=[]
    for keys in dh.scenarios:
        l.append(True) if dh.scenarios[keys]['clp']['--CARBONCAP']==1 else l.append(False)

    if show_data:
        print('The CO2 emissions data: \n',df)
        print('_____________________________________________________________________\n')
        print('The CO2 caps: \n',pd.DataFrame([co2_cap[l]],index = ['CO2 cap']))

    fig = plt.figure(figsize=figsize)

    ax = fig.add_subplot(111)
    x = df.columns
    bottom = 0
    bottom_negative = 0

    # Defines the order of appearence
    labels = colors_r.keys()

    # Removes techs that are not in the data (otherwise loop breaks)
    labels = [l for l in labels if l in list(df.index.values)]

    assert set(df.index.values).issubset(list(labels)), "You haven't defined a color for these technologies:"\
                                                        + str(set(df.index.values)-set(labels))
    handles = []
    for i in labels:

        tech = df.loc[i]

        # this if-else clause is integrated because there are technologies which can both use and generate electricity and are therefore twice in a bar.
        if isinstance(tech, pd.DataFrame):
            for j in range(len(tech.index)):
                # Positive
                handle = plt.bar(x, tech.iloc[j, :].clip(lower=0), label=i, bottom=bottom, color = colors_r[i])
                bottom += tech.iloc[j, :].clip(lower=0)
                # Negative
                handle = plt.bar(x, tech.iloc[j, :].clip(upper=0), label=i, bottom=bottom_negative, color = colors_r[i])
                bottom_negative += tech.iloc[j, :].clip(upper=0)

            handles.append(handle[0])

        else:
            # Positive
            handle = plt.bar(x, tech.clip(lower=0), label=i, bottom=bottom, color = colors_r[i])
            bottom += tech.clip(lower=0)
            # Negative
            handle = plt.bar(x, tech.clip(upper=0), label=i, bottom=bottom_negative, color = colors_r[i])
            bottom_negative += tech.clip(upper=0)

            handles.append(handle[0])

    if show_cap:
        handle = plt.bar(co2_cap[l].index,pd.Series(co2_cap[l].values.max()*0.02,index=co2_cap[l].index), label='cap', bottom=co2_cap[l], color = 'black')
        handles.append(handle[0])
        labels.append('cap')

    # X axis
    ax.set_xticks(x)
    ax.set_xticklabels(df.columns)

    # Y axis
    ax.set_ylabel('CO2 Emissions (Mt)')
    y_bottom = bottom_negative.min()+0.1*bottom_negative.min()
    y_top = max(co2_cap.values.max() + 0.1* co2_cap.values.max(), bottom.max()+0.1*bottom.max())
    ax.set_ylim(y_bottom,y_top)

    # title
    ax.set_title('CO2 Emissions')

    # Grid
    plt.grid(axis='y', zorder=0, color='grey', linewidth=.5)

    # Balance line at 0.
    plt.axhline(y=0,linewidth=1, color='k')

    plt.legend(labels=labels[::-1], handles=handles[::-1], loc='center', bbox_to_anchor=(1.1, 0.5))

    return ax


def plot_mv(dh,tec_list,show_data=False):
    '''
    Function to plot the market value of tec_list of different regions over all scenarios with aggregated vintage classes.
    :param dh: data_handler with scenarios
    :param tec_list: list of strings with techs
    '''
    df = dh.get_composite('market_value')

    if show_data:
        print('The market value data: \n',df)

    fig, axes = plt.subplots(1,len(tec_list),figsize=(10,5),sharex=True,sharey = True)
    handles, labels = [],[]

    for i in range(len(tec_list)):
        # checks if there is any data for the technology
        if df.index.isin([tec_list[i]],level='tec_supply').any():
            # extracting market value data of wished technology.
            df_helper = df.xs(tec_list[i],level='tec_supply').transpose()
            colors = [colors_r[r] for r in df_helper.columns]

            # if 'LTE' in df_helper.index:
            #     df_helper.loc[df_helper.index != 'LTE',:].plot(ax= axes[i], color = colors, legend=False, marker = 'o', linestyle = '--', xticks= df_helper.index)
            #     df_helper.loc[df_helper.index == 'LTE',:].plot(ax= axes[i], color = colors, legend=False, marker = 'o', linestyle = '--', xticks= df_helper.index)

            df_helper.plot(ax= axes[i], color = colors, legend=False, marker = 'o', linestyle = '--',use_index=True)

        axes[i].set_title(tec_list[i])
        axes[i].set_ylabel('Market value (Euro/MWh)')
        axes[i].set_xlabel('')
        axes[i].tick_params('x',labelrotation=45,bottom=True,labelbottom = True)
        axes[i].grid(axis='y', zorder=0, color='grey', linewidth=.5)

        #handles for legend
        handle, label = axes[i].get_legend_handles_labels()
        handles = handles + handle
        labels = labels + label

    #fig.text(0.07, 0.5, 'Market value [Euro/GWh]', va='center', rotation='vertical')
    #Main Title
    fig.suptitle('Market value')

    # workaround to remove duplicates from handles and labels
    by_label = dict(zip(labels, handles))
    # legend
    fig.legend(by_label.values(), by_label.keys(), loc='center', bbox_to_anchor=(0.98, 0.5))


if __name__ == '__main__':
    scenarios = read_scenarios('scenarios_DEMO.yaml')
    dh = Data_handler(scenarios)
