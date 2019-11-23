# JPEG

JPEG decoding for Node.js, using [libjpeg-turbo][libjpeg-turbo] compiled to [WebAssembly][WebAssembly].

[libjpeg-turbo]: https://libjpeg-turbo.org
[WebAssembly]: https://webassembly.org

## Installation

```sh
npm install --save @cwasm/jpeg-turbo
```

## Usage

```js
const fs = require('fs')
const jpeg = require('@cwasm/jpeg-turbo')

const source = fs.readFileSync('image.jpg')
const image = jpeg.decode(source)

console.log(image)
// { width: 128,
//   height: 128,
//   data:
//    Uint8ClampedArray [ ... ] }
```

## API

### `decode(source)`

- `source` ([`Uint8Array`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Uint8Array), required) - The JPEG data
- returns [`ImageData`](https://developer.mozilla.org/en-US/docs/Web/API/ImageData) - Decoded width, height and pixel data
