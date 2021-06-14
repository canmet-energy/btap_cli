# BTAP Docker Command Line Interface

## Requirements
* Windows 10 Professional version 1909 or greater (As a  workaround. if you are using 1709, make sure your git repository is cloned into C:/users/your-user-name/btap_batch) Performance however will not be optimal and will not use all available ram. 
* [Docker](https://docs.docker.com/docker-for-windows/install/) running on your computer and your user added to the docker premissions group.
* Grant Docker access to your C: drive in it's interface.  
* A git [client](https://git-scm.com/downloads)
* A high speed internet connection 50MBit/s download or better, ideally 150Mbit/s.
* A github account and [git-token](https://docs.github.com/en/github/authenticating-to-github/creating-a-personal-access-token)
* Add the github token as a user windows/linux environment variable as GIT_API_TOKEN
* Permissions to access canmet-energy repositories from phylroy.lopez@canada.ca (For use of the restricted costing features only.)
* [Sketchup 2020](https://www.sketchup.com/sketchup/2020/SketchUpPro-exe) (optional) To create custom geometry models.
* [OpenStudio App 1.0.1](https://github.com/openstudiocoalition/OpenStudioApplication/releases/tag/v1.0.1) (optional) 


## Background
BTAP is the Building Technology Assesement Platform developed by Natural Resources Canada's research arm CanmetENERGY. It is developed upon the OpenStudio/EnergyPlus open-source framework created by the US DOE and the US National Renewable Energy Laboratory. 
BTAP can create standard reference building energy models of various vintages quickly for any location in Canada and perform energy efficiency scenario analysis for many building improvement measures such and insulation, windows, and mechanical systems. With its built in costing algorithm, it can perform limited cost-comparison of design scenarios. 
BTAP leverages data-driven methodology expert system rulesets that adhear to the National Energy Code for buildings as it basis. If it is in the code, it is implmented as accurately as possible. 
The most common used cases for BTAP is to:
* examine the cost effective performance of codes and standards across Canada.
* examine design pathways to Net-Zero Buildings.

BTAP is a research tool used internally and features and output may change without notice. 

### Vintage Supported
The project currently supports the following vintages for both code rulesets and incremental costing of utility costs and incremental capital costs.  
* NECB2011
* NECB2015
* NECB2017

Note: Work is underway under the General Infrastructure PERD project to add older vintages to the ruleset library. Please contact Chris.Kirney@canada.ca for more details on this initiative. 

### Commercial Building Geometries
BTAP comes with the standard geometries built-in commercial building spacetype geometric models. The are based on the U.S. DOE reference building archetypes, but gutted of everything except the geometry and space type information. You can find a list of the buildings [here](./docs/BtapBuildingGeometryLibrary.md)
You can also create your own buildings using the OpenStudio Sketchup Plug-in included in the OpenStudio Installation. Other tools support conversion to an openstudio model including Revit, and eQuest. See how to Custom OSM section below. 


 
### Costed Cities Supported. 
We use a third party resource to cost aspects of the models that BTAP generates. The cities that are supported are listed [here](./docs/CostingSupportedCities.md).
If another weather file is selected that is not on this list, BTAP will try to select a city closest to the list below to use for costing. The latitude and longitudes included in the table are used to calculate this. This may produce unexpected results if not aware. 

### Utility Cost Support
BTAP supports the National Energy Board Utility rates. These are averaged costs per GJ and do not have block or tiered surcharges. BTAP does support block rate structure, however this is advanced and we recommend using NREL's tariff measure that can be found [here](https://bcl.nrel.gov/node/82923] 

### Capital Cost Support
BTAP will automatically cost materials, equipment and labour. BTAP Costing will only cost items that have energy impact. It will for example cost the wall construction layers, but not the structural components. 
Some items that BTAP costs are:
* Labour, Overhead
* Layer Materials in Constructions and fenestration.
* Piping, Ductworks, Headers based on actual geometry of the building. This is required when evaluating forced air vs hydronic solutions. 
* Standard HVAC Equipment, Boilers, Chillers, HeatPumps, Service Hot Water. 

Some examples of items it will not cost are:
* Internal walls, doors, toilets, structural beams, furniture, etc.   

It will also only cost what is contained with the btap standard measures. For example if you add a measure to add overhangs into the BTAP workflow. It will not cost it. BTAP uses internal naming conventions to cost items and make decisions on how components are costed. This does not mean you cannot use other measures created by other authors on [NREL's Building Component Library](https://bcl.nrel.gov/). It just means it will not be costed. 
 
## Why BTAP CLI?
The BTAP CLI allow researchers to run a single btap analysis. It is the basis of BTAPBatch which runs many simulations
simulatneously on either your local high performance computer, or on AWS. If you wish to run BTAPBATCH for these
largescale analysis, please contact us for more information. 

## Modes of Operation
BTAP_CLI operated in two modes, with equipment and materials costing information and without.

### Capital Cost Mode
With costing information, btap uses and expert based system to determine the relative costs of the energy upgrades available 
in BTAP. To use this you will need to contact us for access as it is experimental. Partners would require an RSMean licence.

### Regular Mode
This will allow you to run simulations with the ECMs however it will not provide any costing other than 
utility costs based on the NEB rates. It also provided NECB defaults for whichever vintage template to you choose. 

## Configuration
### Clone this repository
You will first need to build the image that the cli will use. You will need to clone this repository to your
system, if you are on windows, I would recommend cloning it in your windows user folder. For example my windows
user folder is c:\Users\plopez.  

### Build Image
You will need to issue one of the following commands from windows powershell in the btap_cli folder.

Option 1: Non-Costed.
```
docker build -t btap_cli  --build-arg GIT_API_TOKEN=$GIT_API_TOKEN.
```
Option 2: Costed (note if you issue this without permissions from NRCan this will fail.) 
```
docker build -t btap_cli --build-arg BTAP_COSTING_BRANCH='nrcan_prod' --build-arg GIT_API_TOKEN=$env:GIT_API_TOKEN .
```

### Create Archetype/Run Simulations
BTAP Cli takes input from a local input folder and outputs the run to a local output folder. You mush map
your local input and output folders to the image container. Since I cloned this repository to c:/Users/plopez this
is the command I would use.. You would have to change it to your account path on your windows machine.
```
docker run -it --rm  -v c:/Users/plopez/btap_cli/input:/btap_costing/utilities/btap_cli/input -v c:/Users/plopez/btap_cli/output:/btap_costing/utilities/btap_cli/output btap_cli  bundle exec ruby btap_cli.rb
```

This should run a single simulation. Each simulation that you run reads the run_options.yml file from the
input folder and creates a character based on the :datapoint_id field in the run_options.yml file. The output is identical 
to the output from OpenStudio/EnergyPlus. The simulation run is in the run_dir folder and the sizing run is 
contained in the sizing_folder. The final osm used it the output.osm file. A high level convience output
of annual data it store as a JSON file as btap_data.json. 


## Create Custom OSM File
You can create a custom osm file by using Sketchup 2020 with the OpenStudio Plugin. 
### Geometry
You can view the intructional videos on how to create geometric models using sketchup and the openstudio plug-in. 
Here is a video to perform takeoffs from a DWG file. You can also import PDF files and do the same procedure. 
[NREL Take-Off Video Part 1](https://www.youtube.com/watch?v=T41MXqlvp0E)

Do not bother to add windows or doors. BTAP will automatically add these to the model based on the vintage template or the inputs in
the BTAPBatch input yml file. 

### Zone Multipliers
BTAP supports use of multipliers vertically (i.e by floor). This will help reduce the runtime of the simulation. Please 
do not use horizontal zone multipliers as this will not work with btap's costing algorithms.  

### Space Types
Space types must be defined as NECB 2011 spacetypes. BTAP will map these to the template you select in the btap_batch 
analysis file. You can find the osm library file of the NECB spacetypes in the resources/space_type_library folder that
 you can import and use in defining the spacetypes in your model. 

### Number of Floors
BTAP needs to know the number of above and below ground floors. This cannot be interpreted accurately from the geometry
 for all building types, for example split level models. To identify this, open the 
 OSM file and find the 'OS:Building' object and add the correct values to  'Standards Number of Stories' and 
 'Standards Number of Above Ground Stories'. To be clear, 'Standards Number of Stories' is the total number of 
 stories in the model including basement levels.  
 
### Run Custom OSM Analysis
It is simple to run an OSM file with btap_cli.You must ensure that your geometry is sound and all spaces
and zones are fully enclosed.
1. Place the custom.osm file in the input folder.
2. In the run_options.yml file modify the :building_type field to 'custom'
3. Run the simulation.

