# PulseInputDDM &mdash; a Julia package for inferring the parameters of drift diffusion models

PulseInputDDM is a Julia package for inferring the parameters of generalized drift diffusion to bound models (DDMs) from neural activity, behavioral data, or both. The codebase was designed with the expectation that data was collected from subjects performing pulse-based evidence accumulation task, as in [Brunton et al 2013](DOI: 10.1126/science.1233912), but can be adapted for other evidence accumulation tasks.

The package contains a variety of auxillary functions for loading/saving model fits, sampling from fit models (e.g., producing latents, neural activity, or choices from a model with specific parameter settings), and for fitting data to similar/related models.

Written for Julia 1.5.0 and above. 

##  Recommended installation

You need to add the PulseInputDDM package from github by entering the Julia package manager, by typing `]`. Then use `add` to add the package, as follows

```julia
(v1.5) pkg > add https://github.com/Brody-Lab/PulseInputDDM/
```

Another way to add the package in normal Julia mode (i.e., without typing `]`) is

```julia
julia > using Pkg    
julia > Pkg.add(PackageSpec(url="https://github.com/Brody-Lab/PulseInputDDM/"))
```

## Updating the package 

When major modifications are made to the code base, you will need to update the package. You can do this in Julia's package manager (`]`) by typing `update`.


## Getting help

Most functions in this package contain [docstrings](https://docs.julialang.org/en/v1/manual/documentation/). To get more details about how any function in this package works, in Julia you can type `?` and then the name of the function. Documentation will display in the REPL or notebook.

## Fitting the model to choice data only

Because many neuroscientists use matlab, we use the [MAT.jl](https://github.com/JuliaIO/MAT.jl) package for IO. Data can be loaded using two conventions. One of these conventions is easier when data is saved within matlab as a .MAT file, and is described below. 

The package expects your data to live in a single .mat file which should contain a struct called `rawdata`. Each element of `rawdata` should have data for one behavioral trial and `rawdata` should contain the following fields with the specified structure:

 - `rawdata.leftbups`: row-vector containing the relative timing, in seconds, of left clicks on an individual trial. 0 seconds is the start of the click stimulus.
 - `rawdata.rightbups`: row-vector containing the relative timing in seconds (origin at 0 sec) of right clicks on an individual trial. 0 seconds is the start of the click stimulus.
 - `rawdata.T`: the duration of the trial, in seconds. The beginning of a trial is defined as the start of the click stimulus. The end of a trial is defined based on the behavioral event “cpoke_end”. This was the Hanks convention.
 - `rawdata.pokedR`: `Bool` representing the animal choice (1 = right).
 
The example file located at [example_matfile.mat](https://github.com/Brody-Lab/PulseInputDDM/blob/master/examples/choice%20model/example_matfile.mat) adheres to this convention and can be loaded using the `load_choice_data` method.

### Fitting the model

Once your data is correctly formatted and you have the package added in Julia, you are ready to fit the model. An example tutorial is located in the [examples](https://github.com/Brody-Lab/PulseInputDDM/tree/master/examples/choice%20model) directory. The tutorial illustrates how to use many of the most important methods, such as loading data, saving model fits, and optimizing the model parameters. of each below.


## Fitting the model to neural activity

### Data conventions

Following the same conventions as ([Working interactively on scotty via a SSH tunnel](@ref)) but `rawdata` should contain the following extra field:

- `rawdata.spike_times`: cell array containing the spike times of each neuron on an individual trial. The cell array will be length of the number of neurons recorded on that trial. Each entry of the cell array is a column vector containing the relative timing of spikes, in seconds. Zero seconds is the start of the click stimulus.


### Load the data and fit the model interactively

Working from the notebook you started in the previous section ([Working interactively on scotty via a SSH tunnel](@ref)), we need to create three variables to point to the data we want to fit and specify which animals and sessions we want to use:

- `data_path`: a `String` indicating the directory where the `.mat` files described above are located. For example, `data_path = ENV["HOME"]*"/Projects/pulse_input_DDM.jl/data"` where `ENV["HOME"]` is using a bash environment variable and `*` conjoins two strings (like `strjoin` in MATLAB).


### Now fit the model!

You can use the function `optimize_model` to run the model.

```julia
    pz, py = optimize_model(data)
```

### Format for neural data

First, define a path to where the data you want to fit is located.

See [Loading data and fitting a choice model](@ref) for the expected format for .MAT files if one were fitting the choice model. In addition to those fields, for a neural model rawdata should also contain an extra field:

`rawdata.spike_times`: cell array containing the spike times of each neuron on an individual trial. The cell array will be length of the number of neurons recorded on that trial. Each entry of the cell array is a column vector containing the relative timing of spikes, in seconds. Zero seconds is the start of the click stimulus. Spikes before and after the click inputs should also be included.

The convention for fitting a model with neural model is that each session should have its own .MAT file. (This constrasts with the convention for the choice model, where a single .MAT file can contain data from different session). It's just easier this way, especially if different sessions have different number of cells.


## Contribution Guidelines



