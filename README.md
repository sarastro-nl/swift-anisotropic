# swift-anisotropic
Swift program to make a 512x512 ppm in [anisotropic mipmap format](https://en.wikipedia.org/wiki/Anisotropic_filtering#An_improvement_on_isotropic_MIP_mapping) from a given image. It uses the `convert` and `identify` tools from the `imagemagick` package to do this. It can therefore easily be rewritten into other languages. As a convenience, I've included a shell script (`anisotropic.sh`) as well.

The first step is to resize the input image to an intermediate square image by cropping the longer of either the height or the width (using center gravity). The next step is to resize this square image to 256x256, 256x128, 256x64, ... 1x1 to produce linearly transformed copies of reduced size.

Although the output will be a 512x512 ppm image file, the area with the copies will occupy 511x511 (256 + 128 + ... + 1 = 511). In other words, the output image will contain a 1 pixel white lane to the far right and bottom.

Usage:

```shell
swift main.swift <input image>
```

This is an example:

input image (512x555):

![](assets/rembrandt.jpg)

intermediate image (512x512):

![](assets/square.jpg)

output image (512x512):

![](assets/rembrandt.jpg.jpg)


