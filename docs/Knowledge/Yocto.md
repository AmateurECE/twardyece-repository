# Generating the SDK Image

For a regular SDK image

```
bitbake -c populate_sdk <image_name>
```

For the eSDK image:

```
bitbake -c populate_sdk_ext <image_name>
```

# Installing the eSDK Image

Must have Python installed. An additional gotcha, the script checks for Python
using `which`, so naturally, `which` must also be installed. The SDK also
cannot be installed as root.

# Setting up SSTATE_MIRRORS

Must add the SSTATE_MIRRORS entry after SDK installation, manually. This goes
in `poky_sdk/conf/local.conf`. Remember that this variable is formatted in
pairs: the first is a regexp to select the files from the server URL provided
in the second argument. Assuming that when I navigate to
`http://edtwardy-yocto.local/sstate-cache/` in my browser, I'm met with a
directory index that contains many numbered subdirectories (the sstate-cache),
the following entry will work for me:

```
SSTATE_MIRRORS = "\
...
file://(.*) http://edtwardy-yocto.local/sstate-cache/\1 \
"
```

# Installing Extra Packages with the eSDK

The packages must first be built, server-side, otherwise attempting
`sdk-install` will result an error like:

```
ERROR: Failed to install cargo-native - unavailable
```

Otherwise, the following will generally work:

```
devtool sdk-install <packageName>
```

# Types of Packages in the Ecosystem
