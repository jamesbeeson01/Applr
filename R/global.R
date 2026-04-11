# Package-level global variable declarations
# This file handles R CMD check warnings about undefined global variables

# Declare 'Z' as a global variable to prevent R CMD check warnings
# 'Z' is used in scatter_3d.R when creating the prediction surface
# It's created dynamically during the pivot_wider operation but R's static
# analysis can't detect this, so we declare it here to avoid false warnings
utils::globalVariables('Z')
