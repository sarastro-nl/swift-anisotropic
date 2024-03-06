# swift-anisotropic
Swift program to make a 512x512 ppm in [anisotropic mipmap format](https://en.wikipedia.org/wiki/Anisotropic_filtering#An_improvement_on_isotropic_MIP_mapping) from a given image. 

The first step is to resize the input image to an intermediate square 512x512 image by taking the smallest of either height or width and resize it to 512 pixels. The longer of the two will be cut down (with center gravity) to fit 512 pixels. The next step is to resize this square image to 256x256, 256x128, 256x64, ... 1x1 to produce filtered, linearly transformed copies of reduced size. The output will be a 512x512 ppm image file but the area with all the copies will only occupy 511x511 (256 + 128 + ... + 1 = 511). In other words, the output image will contain a 1 pixel white lane to the far right and bottom.

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


