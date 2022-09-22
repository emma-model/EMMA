import os
from shutil import copy
import subprocess
import argparse
import yaml

try:
    from yaml import CLoader as Loader, CDumper as Dumper
except ImportError:
    from yaml import Loader, Dumper

# Basic sub-folders
folder = {
    "g00_files": "_g00",
    "gdx_files": "_gdx",
    "sql_files": "_sql",
}

# Controls which steps are performed (set to False to skip)
toggle = {
    "load data": True,
    "solve": True,
    "create gdx": True,
    "create sqlite3": True,
}

# List of scenarios with metadata (might be generated automatically at a later point in time)
def read_scenarios(yaml_name: str):

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


# Utility to execute shell commands
def execute(command):
    print("~" * 100 + "\n", " ".join(command) + "\n", "~" * 100)
    process = subprocess.run(command)
    return process
    print(result, "<-")


def clp_parser(clp_dict):
    clp_list = []
    for k, v in clp_dict.items():
        clp_list.append(k + "=" + str(v))
    return clp_list


# Safe file remove
def remove(path):
    if os.path.isfile(path):
        print("Removing:", path)
        os.remove(path)


def call(yaml_name):

    scenarios = read_scenarios(yaml_name=yaml_name)

    # Preparation
    for _, f in folder.items():
        os.makedirs(f, exist_ok=True)
        print("create folder:", f)

    # Load data
    if toggle["load data"]:
        process = execute(command=["gams", "loaddata.gms"])
        if process.returncode != 0:
            print(
                "ERROR: problem with executing these commands:", " ".join(process.args)
            )
            return

    # Iterate over scenarios
    for scenario_id, scenario_attributes in scenarios.items():
        if scenario_attributes["active"]:
            # Solve model and create breakpoint
            if toggle["solve"]:
                process = execute(
                    command=[
                        "gams",
                        "core.gms",
                        *clp_parser(scenario_attributes["clp"]),
                        "save=" + os.path.join(folder["g00_files"], str(scenario_id)),
                    ]
                )
                if process.returncode != 0:
                    print(
                        "ERROR: problem with executing these commands:",
                        " ".join(process.args),
                    )
                    return

            # Create and store GDX outputs
            gdx_path = os.path.join(folder["gdx_files"], str(scenario_id) + ".gdx")
            if toggle["create gdx"]:
                remove(gdx_path)
                process = execute(
                    command=[
                        "gams",
                        "output.gms",
                        f'--OFOLDER={folder["gdx_files"]}',
                        f"--ONAME={scenario_id}",
                        f'restart={os.path.join(folder["g00_files"], str(scenario_id))}',
                    ]
                )
                if process.returncode != 0:
                    print(
                        "ERROR: problem with executing these commands:",
                        " ".join(process.args),
                    )
                    return

            # Convert GDX to other data format
            # To sqlite3
            if toggle["create sqlite3"]:
                sql_path = os.path.join(folder["sql_files"], str(scenario_id) + ".db")
                remove(sql_path)
                process = execute(
                    command=[
                        "gams",
                        "to_sqlite.gms",
                        f"--GDX_FILE={gdx_path}",
                        f"--SQL_FILE={sql_path}",
                    ]
                )
                if process.returncode != 0:
                    print(
                        "ERROR: problem with executing these commands:",
                        " ".join(process.args),
                    )
                    return
        else:
            print(
                "Scenario is not flagged as active, hence skipping: id",
                scenario_id,
                scenario_attributes["name"],
            )


if __name__ == "__main__":

    # Initialize parser
    parser = argparse.ArgumentParser(description="Call scenarios")

    # Add parameters positional/optional (call as -1=123 or --arg1 123)
    parser.add_argument(
        "-y", "--yaml_file", help="Name of the yaml file to be used", type=str
    )  # default='default_val'

    # Parse argument
    args = parser.parse_args()

    # Arg: Database
    yaml_file = args.yaml_file

    call(yaml_name=yaml_file)
