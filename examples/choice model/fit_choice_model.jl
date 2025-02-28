# # Loading data and fitting a choice model

# The package expects your data to live in a single .mat file which should contain a struct called `rawdata`. Each element of `rawdata` should have data for one behavioral trial and `rawdata` should contain the following fields with the specified structure:

# - `rawdata.leftbups`: row-vector containing the relative timing, in seconds, of left clicks on an individual trial. 0 seconds is the start of the click stimulus.
# - `rawdata.rightbups`: row-vector containing the relative timing in seconds (origin at 0 sec) of right clicks on an individual trial. 0 seconds is the start of the click stimulus.
# - `rawdata.T`: the duration of the trial, in seconds. The beginning of a trial is defined as the start of the click stimulus. The end of a trial is defined based on the behavioral event “cpoke_end”. This was the Hanks convention.
# - `rawdata.pokedR`: `Bool` representing the animal choice (1 = right).
# - `rawdata.sessbnd`: `Bool` representing the first trial of every session

# ## Fitting the model

# Once your data is correctly formatted and you have the package added in julia, you are ready to fit the model. You need to write a slurm script to use spock's resources and a .jl file to load the data and fit the model. See examples of each below. These files are also located in the package in the `examples` directory.

# ### Example slurm script

# This will start a job called `fit_choice_model`. Output will be written to a log file called `fit_choice_model.out`. This will run on the `Brody` partition of spock for 12 hours, using 44 cores and 64 GB of memory. You'll notice that we load the julia module (like we did when we added the package) and then we call julia (`-p 44` uses the 44 cores) and ask it to run the .jl file.

# ```
# #!/usr/bin/env bash
#
# #SBATCH -J 'fit_choice_model'
# #SBATCH -o ../logs/fit_choice_model.out
# #SBATCH -p Brody
# #SBATCH --time=12:00:00
# #SBATCH --mem=64000
# #SBATCH -c 44
#
# module load julia/1.0.0
# julia -p 44 ./fit_choice_model.jl
# ```

# ### Example .jl file
# Blah blah blah

using pulse_input_DDM, Flatten

# ### Load some data
# Blah blah blah

data = load_choice_data("../choice model/example_matfile.mat");

# ### Set options for optimization
# Blah blah blah

n = 53

options, x0 = create_options_and_x0(modeltype="bing")

# ### Load some data
# Blah blah blah
save_file = "../choice model/example_results.mat"

#if you've already ran the optimization once and want to restart from where you stoped, this will reload those parameters
if isfile(save_file)
    θ, options = reload_choice_model(save_file)
else
    θ = Flatten.reconstruct(θchoice(), x0)
end

# ### Optimize stuff
# Blah blah blah

model, = optimize(θ, data, options; iterations=5, outer_iterations=1)

# ### Compute Hessian and the confidence interavls
# Blah blah blah

H = Hessian(model)
CI, = CIs(H);

# ### Save results
# Blah blah blah

save_choice_model(save_file, model, options, CI)

# ### Getting help
# To get more details about how any function in this package works, in julia you can type `?` and then the name of the function. Documentation will display in the REPL.
