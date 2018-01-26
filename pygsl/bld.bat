%PYTHON% -c "import os; print(os.getcwd())"
%PYTHON% -c "import sys; print(sys.path)"
%PYTHON% -c "import gsl_dist; print(gsl_dist.__file__)"

copy "%RECIPE_DIR%\gsl_site.py" "%SRC_DIR%\gsl_dist\"
if errorlevel 1 exit 1

%PYTHON% setup.py config
if errorlevel 1 exit 1

%PYTHON% setup.py install --old-and-unmanageable
if errorlevel 1 exit 1
