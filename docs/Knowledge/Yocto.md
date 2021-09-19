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
