# Packaging Python
### Ethan D. Twardy
### June 01, 2020

This document goes over the procedure for packaging and distributing Python3
packages using setuptools, pip, and the pypi server.

## Creating the Setup Script
Unfortunately, when writing Python using barebones tools like Emacs and the
command line, there is not a conveniently distributed tool for automatically
generating a setup script, like in other packaging environments. The
`setup.py` must therefore be written by hand. The following provides a
good start:

``` python
--8<-- "Packaging/Python/setup.py"
```

### Package Names with Hyphens
If your package name contains a hypen, as in `django-index`, the hyphen
may be specified in the `name` parameter of the setup script. However,
the hyphen is not a valid character in Python `import` directives, so
the `provides` parameter (the name clients use to refer to your package
when they import it) must not contain a hyphen. A common practice is to use
an underscore instead.

### Non-Python Files
One common problem is including files which are not source files. There are two
ways to do this, but the recommended way is to add a file called
`MANIFEST.in` to the same directory as the `setup.py` script. The syntax of
this file is simple and can be found online, but a small sample is given below:

    include requirements.txt
    recursive-include data *

The `setup.py` script must then be edited like so:

    setup(
    ...
    include_package_data=True
    ...
    )

## Building the Package
Once the `setup.py` script has been written, the package can be built from
source. First, make sure that the latest version of `setuptools` is installed:

    python3 -m pip install --user --upgrade setuptools wheel

Finally, generate the distribution:

    python3 setup.py sdist

## Uploading the Package
If planning to upload this package to a real PyPI repository, look into the
usage of a Python package called `twine`. My PyPI repository is just a
simple one, however, so I can copy the files directly onto my server. The
following command will do just that for a package named
`django-bookmarks`. The directory `django/` need not exist.

```
rsync -e 'ssh -p 5000' -rv --delete dist django_bookmarks.egg-info \
    edtwardy@192.168.1.60:/var/www/edtwardy.hopto.org/pypi/django-bookmarks/
```

The last thing that's required is an `index.html`. This file contains
links to all of the files in the distribution. Below is an example of one:

``` html
--8<-- "Packaging/Python/index.html"
```

The following shell script can be used to generate the `index.html`
automatically:

``` sh
--8<-- "Packaging/Python/generateIndex.sh"
```

And lastly, update this file to the repository:

```
rsync -e 'ssh -p 5000' index.html \
    edtwardy@192.168.1.60:/var/www/edtwardy.hopto.org/pypi/django-bookmarks/
```

## Installing a Built Package
Pip can be used to install a package build using setuptools from the root of
the package directory. Just run pip with the generated `.tar.gz` file
as an argument.

```
python3 -m pip install --user --force-reinstall \
    dist/web_publishing-0.1.0.tar.gz
```

This is preferable to installing build packages using the setuptools script
itself, since there are currently a few open bugs related to installing
packages using `setup.py`.

## Installing a Package from the Private PyPI Server
This can be done using pip and specifying the package url. The current
pypi-server and Nginx configuration allows us to download packages like so:

```
pip install --index-url https://edtwardy.hopto.org:443/pypi --user <package>
```

## Showing the Path of an Installed Package

    pip show <packageName>
