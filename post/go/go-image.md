# image

  package image
  type Image interface {
      ColorModel() color.Model
      Bounds() Rectangle
      At(x, y int) color.Color
  }

code:

  m := image.NewRGBA(image.Rect(0, 0, 100, 100))
	fmt.Println(m.Bounds())
	fmt.Println(m.At(0, 0).RGBA())

output:

  (0,0)-(100,100)
  {0 0 0 0}

## image interface

  type Model interface {
        Convert(c Color) Color
  }
  type Rectangle struct {
          Min, Max Point
  }
  //At(x, y int) color.Color
  //image.color
  type Color interface {
          // RGBA returns the alpha-premultiplied red, green, blue and alpha values
          // for the color. Each value ranges within [0, 0xffff], but is represented
          // by a uint32 so that multiplying by a blend factor up to 0xffff will not
          // overflow.
          //
          // An alpha-premultiplied color component c has been scaled by alpha (a),
          // so has valid values 0 <= c <= a.
          RGBA() (r, g, b, a uint32)
  }
