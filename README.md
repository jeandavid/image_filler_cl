# ImageFillerCL

ImageFillerCL is an image processing package that fills holes in images. It includes:

- an executable: 'ImageFillerCL' reads an image and a mask, calls the framework and then write the filled image to a file.
- a framework: 'ImageFiller' that implements an algorithm that fills holes in images.

## How to run it

Using the Swift Package Manager:
```sh
$ git clone https://github.com/jeandavid/image_filler_cl.git
$ cd ImageFillerCL
$ swift build
$ .build/debug/ImageFillerCL rgb.png
```

## Command Line Options

```sh
USAGE: ImageFillerCL imageFile <options>

OPTIONS:
  --connectivity, -c   Pixel Connectivity. Default to 8
  --epsilon, -e        Epsilon for the weight function. Default to 1e-9
  --mask, -m           Mask that defines the hole. It should be a grayscale image. Black pixel will be considered as a mask. If a mask is not provided, then we will use a mock of dimension 20*20, placed at (100,100). Minimum size for the original image should therefore be 120*120
  --zexponent, -z      Exponent for the weight function. Default to 4
  --help               Display available options
```
