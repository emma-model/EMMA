import os
import subprocess
import argparse
import yaml
import functools
import pandas as pd
from pathlib import Path
from typing import List, Callable

try:
    from yaml import CLoader as Loader
except ImportError:
    from yaml import Loader


class TempWorkingDirectory(object):
    """Sets the cwd within the context

    Args:
      path (Path): The path to the cwd
    """

    def __init__(self, path: str):
        self.path = Path().cwd() / path
        self.origin = Path().cwd()

    def __enter__(self):
        os.chdir(self.path)

    def __exit__(self, type, value, traceback):
        os.chdir(self.origin)


# fix current working directory for the project

CWD = os.getcwd()

# List of scenarios with metadata (might be generated automatically at a later point in time)
def read_scenarios(yaml_name: str) -> dict:
    """
    The function reads a scenario yaml file and creates a dictionary with the scenarios as keys and their specifications as values.

    :param str: yaml file name
    :return dict: dictionary of all scenarios of the yaml file
    """

    yaml_dict = yaml.load(open(yaml_name), Loader=Loader)
    scens = yaml_dict["scenarios"]

    # CLP specific to a scenario are complemented by the default ones
    for ID, attributes in scens.items():
        if scens[ID]["clp"] is None:
            scens[ID]["clp"] = {"--ID": ID, **yaml_dict["default_clp"]}
        else:
            scens[ID]["clp"] = {
                "--ID": ID,
                **yaml_dict["default_clp"],
                **scens[ID]["clp"],
            }
    return scens


class Scenarios:
    """
    A class representing a cluster of scenarios which are defined in one yaml file.

    ...

    Attributes
    ----------
    name : str
        the name of the scenario combination (e.g. Scenarios_GRC) taken as the file name of the yaml file
    params : dict
        the dictionary with all single scenarios defined in the yaml file.

    Methods
    -------
    active_scenarios()
        returns the params dictionary reduced to all active scenarios
    hours()
        returns a pandas series with the number of simulated hours as values per scenario.
    """

    def __init__(self, yaml_name: str):
        self.name = os.path.splitext(os.path.basename(yaml_name))[0]
        self.params = read_scenarios(yaml_name)

    @functools.cached_property
    def active_scenarios(self) -> dict:
        # creates dictionary of scenarios which are marked as active in the yaml files
        return {k: v for k, v in self.params.items() if v["active"] is True}

    @functools.cached_property
    def hours(self) -> pd.Series:
        # creates dictionary with simulated hour per scenario
        return pd.Series(
            {
                str(v["name"]): v["clp"]["--HOURS"]
                for v in self.params.values()
                if v["active"] is True
            }
        )
    @functools.cached_property
    def horizon(self) -> dict:
        # creates dictionary with simulated hour per scenario
        return {
                str(v["name"]): str(v["clp"]["--HORIZON"])
                for v in self.params.values()
                if v["active"] is True
            }


# Utility to execute shell commands
def execute(command: list):
    """
    Utility function which executes command line commands.

    :params: list of command strings
    """
    print("~" * 100 + "\n", " ".join(command) + "\n", "~" * 100)
    process = subprocess.run(command)
    if process.returncode != 0:
        raise Exception(f"Return code is not zero \n Command: {command}")


def clp_parser(clp_dict: dict) -> list[str]:
    """
    Parser for scenario attributes.

    :params: dict of arguments
    :return: list of arguments
    """
    clp_list = []
    for k, v in clp_dict.items():
        clp_list.append(k + "=" + str(v))
    return clp_list


# Safe file remove
def remove(path):
    """
    Function to remove already existing directories.

    :params: Path object which should be removed.
    """
    if os.path.isfile(path):
        print("Removing:", path)
        os.remove(path)


def load_data(verbose: int):
    """
    Function to load the input data into a GAMS readable format.
    """
    execute(command=["gams", "loaddata.gms", f"logOption={verbose}"])


def solve_models(
    scenario_id: str, scenario_path, verbose: int, scenario_attributes: dict
):
    """
    Function which solves the model for scenario_id with scenario_attributes and dumps data into scenario_path.

    :params:    scenario_id: str which matches a scenario id in Scenarios.params
                scenario_path: Path object in which the data is dumped into
                scenario_attributes: dict which defines the attributes of the scenario_id
    """
    execute(
        command=[
            "gams",
            "core.gms",
            *clp_parser(scenario_attributes["clp"]),
            "save=" + os.path.join(scenario_path, str(scenario_id)),
            "output=" + os.path.join(scenario_path, str(scenario_id)),
            f"logOption={verbose}",
        ]
    )


def create_gdx(scenario_id: str, scenario_path, verbose: int, *args):
    """
    Function which converts solvers output into gdx files for scenario_id in scenario_path.

    :params:    scenario_id: str which matches a scenario id in Scenarios.params
                scenario_path: Path object in which the data is dumped into
    """
    remove(os.path.join(scenario_path, str(scenario_id) + ".gdx"))
    execute(
        command=[
            "gams",
            "output.gms",
            f"--OFOLDER={scenario_path}",
            f"--ONAME={scenario_id}",
            f"restart={os.path.join(scenario_path, str(scenario_id))}",
            "output=" + os.path.join(scenario_path, str(scenario_id)),
            f"logOption={verbose}",
        ]
    )


def create_sql(scenario_id: str, scenario_path, verbose: int, *args):
    """
    Function which converts gdx output into sql files for scenario_id in scenario_path.

    :params:    scenario_id: str which matches a scenario id in Scenarios.params
                scenario_path: Path object in which the data is dumped into
    """
    remove(os.path.join(scenario_path, str(scenario_id) + ".db"))
    execute(
        command=[
            "gams",
            "to_sqlite.gms",
            f"--GDX_FILE={os.path.join(scenario_path,str(scenario_id)+'.gdx')}",
            f"--SQL_FILE={os.path.join(scenario_path,str(scenario_id)+'.db')}",
            "output=" + os.path.join(scenario_path, str(scenario_id)),
            f"logOption={verbose}",
        ]
    )


# All possible steps of a simulation
STEPS = {
    "load": load_data,
    "solve": solve_models,
    "gdx": create_gdx,
    "sql": create_sql,
}


def call(
    yaml_name: str,
    step_names: List[str],
    run_once: tuple[str] = ("load",),
    verbose: int = 0,
):

    """
    Function which simulates scenarios defined in yaml_name. Thereby, it uses all steps specified in step_names. It can be differentiated if step_names are scenario-specific or unspecific in run_once. All data is dumped into directories named after the yaml file and scenario id.

    :params:    yaml_name: str which is the same as the yaml file
                step_names: List of str which specifies the steps of the simulation. Possible inputs are the keys of STEPS.
                run_once: all steps which are not scenario-specific and should be run once before or after the scenario simulations.
    """

    scenarios = Scenarios(yaml_name)

    with TempWorkingDirectory("core"):

        os.makedirs(f"_{scenarios.name}", exist_ok=True)

        steps_run_once = [
            step_name for step_name in step_names if step_name in run_once
        ]
        steps_by_scenario = [
            step_name for step_name in step_names if step_name not in run_once
        ]

        for step_name in steps_run_once:
            func: Callable = STEPS[step_name]
            func(verbose)

        for scenario_id, scenario_attributes in scenarios.active_scenarios.items():

            print(f"\nRunning {scenario_id}\n")

            scenario_path = os.path.join(f"_{scenarios.name}", f"_{scenario_id}")

            os.makedirs(scenario_path, exist_ok=True)

            for step_name in steps_by_scenario:
                func: Callable = STEPS[step_name]
                func(scenario_id, scenario_path, verbose, scenario_attributes)


if __name__ == "__main__":

    # Initialize parser
    parser = argparse.ArgumentParser(description="Call scenarios")

    # Add parameters positional/optional (call as -1=123 or --arg1 123)
    parser.add_argument(
        "-y", "--yaml_file", help="Name of the yaml file to be used", type=str
    )  # default='default_val'

    # All simulation steps which should be omitted
    parser.add_argument(
        "-s",
        "--skip",
        help="Input the steps that should be skipped in the execution",
        nargs="*",
        choices=STEPS.keys(),
        default=[],
    )  # default='default_val'

    parser.add_argument(
        "-v",
        "--verbose",
        help="if used shows the stdout produced by GAMS",
        action="store_false",
    )

    # Parse argument
    args = parser.parse_args()
    step_names = [step_name for step_name in STEPS.keys() if step_name not in args.skip]

    # Arg: Database
    yaml_file = args.yaml_file

    # translates Boolean values of input into 0 (True) or 1 (False)
    verbose = 0 if args.verbose is True else 1

    call(yaml_file, step_names=step_names, verbose=verbose)
