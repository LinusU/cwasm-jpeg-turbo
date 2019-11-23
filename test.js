/* eslint-env mocha */

const assert = require('assert')
const fs = require('fs')

const ImageData = require('@canvas/image-data')
const lodepng = require('lodepng')

const jpegTurbo = require('./')

const fixtures = ['example', 'test']

describe('JPEG-Turbo', () => {
  for (const fixture of fixtures) {
    it(`decodes "${fixture}.jpg"`, async () => {
      const referenceSource = fs.readFileSync(`fixtures/${fixture}_ref.png`)
      const reference = await lodepng.decode(referenceSource)

      const source = fs.readFileSync(`fixtures/${fixture}.jpg`)
      const result = jpegTurbo.decode(source)

      assert(result instanceof ImageData)
      assert.strictEqual(result.width, reference.width)
      assert.strictEqual(result.height, reference.height)
      assert.deepStrictEqual(result.data, new Uint8ClampedArray(reference.data))
    })
  }
})
