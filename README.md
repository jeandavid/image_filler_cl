# ImageFillerCL

ImageFillerCL is an image processing swift package that fills holes in images. It includes:

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

## ImageFiller Basic Algorithm Design

We suppose thereafter that the image only includes one hole.

The framework implements an algorithm that fills holes in images. If there are m boundary pixels and n pixels in the hole, then we can express its complexity as O(m*n). Indeed, for each hole pixel the algorithm iterates over all the boundary pixels to color it.

When the hole is a square that includes n pixels, then there are sqrt(n) pixels on each of its side. The boundary is O(sqrt(n)), and the algorithm runs in O(n*sqrt(n)).

Considering that any hole sits inside a surrounding box, the algorithm runs in
O(n*sqrt(n)).

## ImageFiller Approximation Algorithm Design

Achieving linear time means we can't keep iterating over all the boundary pixels for computing the intensity of every single hole pixel.

Since closer boundary pixels have a greater influence in a hole pixel computed intensity, I suggest computing a hole pixel intensity only from its connected boundary pixels.

But this requires to fill hole pixels in a certain order. If not, hole pixels that sits at the center of the hole would stay hole pixels.

We do so by filling outer most hole pixels first and moving toward the center of the hole. This way, hole pixels will always have some non hole pixel neighbors.
