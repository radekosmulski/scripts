CONDA_PATH=$(conda info --base)
source $CONDA_PATH/etc/profile.d/conda.sh
conda deactivate

# Remove existing jupyterai environment if it exists
if conda env list | grep -q "jupyterai"; then
    echo "Found existing jupyterai environment. Removing..."
    conda env remove -n jupyterai --yes
fi

# The env might have already been removed, but the directory might still exist
if [ -d "${CONDA_PREFIX}/envs/jupyterai" ]; then
    echo "Removing directory ${CONDA_PREFIX}/envs/jupyterai"
    rm -rf "${CONDA_PREFIX}/envs/jupyterai"
fi

# Create new jupyterai environment with Python 3.12
conda config --set channel_priority strict
conda create -n jupyterai python=3.12 -c conda-forge -y

conda activate jupyterai
conda install -y -c fastai nbdev fastcore twine
conda install -y -c conda-forge jupyter-ai langchain-anthropic notebook ipython

# Create Jupyter config directory and file if they don't exist
mkdir -p ~/.jupyter
CONFIG_FILE=~/.jupyter/jupyter_notebook_config.py
IPYTHON_CONFIG_DIR=~/.ipython/profile_default
IPYTHON_CONFIG_FILE="${IPYTHON_CONFIG_DIR}/ipython_config.py"

# Create IPython profile if it doesn't exist
if [ ! -d "$IPYTHON_CONFIG_DIR" ]; then
    ipython profile create
fi

# Generate Jupyter config if it doesn't exist
if [ ! -f "$CONFIG_FILE" ]; then
    jupyter notebook --generate-config
fi

# Add jupyter_ai_magics to both configs if not already present
if ! grep -q "c.InteractiveShellApp.extensions.append('jupyter_ai_magics')" "$CONFIG_FILE"; then
    echo "c.InteractiveShellApp.extensions.append('jupyter_ai_magics')" >> "$CONFIG_FILE"
    echo "Added jupyter_ai_magics to Jupyter config"
fi

if ! grep -q "c.InteractiveShellApp.extensions.append('jupyter_ai_magics')" "$IPYTHON_CONFIG_FILE"; then
    echo "c.InteractiveShellApp.extensions = ['jupyter_ai_magics']" >> "$IPYTHON_CONFIG_FILE"
    echo "c.AiMagics.default_language_model = 'anthropic-chat:claude-3-5-sonnet-20241022'" >> "$IPYTHON_CONFIG_FILE"
    echo "Added jupyter_ai_magics to IPython config"
    echo "Added default language model to IPython config (anthropic-chat:claude-3-5-sonnet-20241022)"
    echo "Note: Please check if newer Claude models are available, as the default model may be outdated"
fi

# Prompt user about adding conda activation to .zshrc
echo ""
read -p "Would you like to add 'conda activate jupyterai' to your ~/.zshrc? (y/n) " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    # Check if jupyterai activation already exists
    if ! grep -q "# Automatically activate jupyterai environment" ~/.zshrc || \
       ! grep -q "conda activate jupyterai" ~/.zshrc; then
        # Remove any conda activate lines
        sed -i.bak '/conda activate/d' ~/.zshrc
        # Add jupyterai activation
        echo -e "\n# Automatically activate jupyterai environment\nconda activate jupyterai" >> ~/.zshrc
        echo "Added conda activation to ~/.zshrc"
    else
        echo "Conda activation for jupyterai already exists in ~/.zshrc"
    fi
    echo "Please restart your terminal or run 'source ~/.zshrc' for changes to take effect"
else
    echo "Skipped adding conda activation to ~/.zshrc"
fi

echo "JupyterAI environment created and activated. You can now start Jupyter Notebook with 'jupyter notebook'."

nbdev_install_quarto
