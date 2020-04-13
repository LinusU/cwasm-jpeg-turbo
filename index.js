/* global WebAssembly */

const fs = require('fs')
const path = require('path')

const ImageData = require('@canvas/image-data')

const TJPF_RGBA = 7

const env = {
  setjmp () { return 0 },
  longjmp () { throw new Error('Not implemented') }
}

const stubs = {
  environ_sizes_get () { return 0 },
  environ_get () { throw new Error('Syscall environ_get not implemented') },
  proc_exit () { throw new Error('Syscall proc_exit not implemented') },
  fd_close () { throw new Error('Syscall fd_close not implemented') },
  fd_seek () { throw new Error('Syscall fd_seek not implemented') },
  fd_write () { throw new Error('Syscall fd_write not implemented') }
}

const code = fs.readFileSync(path.join(__dirname, 'jpeg-turbo.wasm'))
const wasmModule = new WebAssembly.Module(code)
const instance = new WebAssembly.Instance(wasmModule, { env, wasi_snapshot_preview1: stubs })

exports.decode = function (input) {
  // Allocate memory to hand over the input data to WASM
  const inputPointer = instance.exports.malloc(input.byteLength)
  const targetView = new Uint8Array(instance.exports.memory.buffer, inputPointer, input.byteLength)

  // Copy input data into WASM readable memory
  targetView.set(input)

  // Allocate decompressor
  const decompressorPointer = instance.exports.tjInitDecompress()

  if (decompressorPointer === 0) {
    instance.exports.free(inputPointer)
    throw new Error('Failed to allocate decompressor')
  }

  // Allocate metadata (width, height, subsampling, and colorspace)
  const metadataPointer = instance.exports.malloc(16)

  // Decode input header
  const headerStatus = instance.exports.tjDecompressHeader3(decompressorPointer, inputPointer, input.byteLength, metadataPointer, metadataPointer + 4, metadataPointer + 8, metadataPointer + 12)

  // Guard return value for error
  if (headerStatus !== 0) {
    instance.exports.free(inputPointer)
    instance.exports.free(metadataPointer)
    instance.exports.tjDestroy(decompressorPointer)
    throw new Error('Failed to decode JPEG header')
  }

  // Read returned metadata
  const metadata = new Uint32Array(instance.exports.memory.buffer, metadataPointer, 4)
  const [width, height] = metadata

  // Free the metadata in WASM land
  instance.exports.free(metadataPointer)

  // Allocate output data
  const outputSize = (width * height * 4)
  const outputPointer = instance.exports.malloc(outputSize)

  // Decode input data
  const dataStatus = instance.exports.tjDecompress2(decompressorPointer, inputPointer, input.byteLength, outputPointer, width, width * 4, height, TJPF_RGBA, 0)

  // Free the input data in WASM land
  instance.exports.free(inputPointer)

  // Destroy the decompressor
  instance.exports.tjDestroy(decompressorPointer)

  // Guard return value for error
  if (dataStatus !== 0) {
    instance.exports.free(outputPointer)
    throw new Error('Failed to decode JPEG data')
  }

  // Create an empty buffer for the resulting data
  const output = new Uint8ClampedArray(outputSize)

  // Copy decoded data from WASM memory to JS
  output.set(new Uint8Array(instance.exports.memory.buffer, outputPointer, outputSize))

  // Free WASM copy of decoded data
  instance.exports.free(outputPointer)

  // Return decoded image as raw data
  return new ImageData(output, width, height)
}
