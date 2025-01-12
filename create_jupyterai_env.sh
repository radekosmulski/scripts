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
conda create -n jupyterai python=3.12 -y

conda activate jupyterai

pip install notebook
pip install jupyter-ai-magics[all]

# Prompt user about adding conda activation to .zshrc
echo ""
read -p "Would you like to add 'conda activate jupyterai' to your ~/.zshrc? (y/n) " answer
if [[ $answer =~ ^[Yy]$ ]]; then
    echo -e "\n# Automatically activate jupyterai environment\nconda activate jupyterai" >> ~/.zshrc
    echo "Added conda activation to ~/.zshrc"
    echo "Please restart your terminal or run 'source ~/.zshrc' for changes to take effect"
else
    echo "Skipped adding conda activation to ~/.zshrc"
fi

echo "JupyterAI environment created and activated. You can now start Jupyter Notebook with 'jupyter notebook'."