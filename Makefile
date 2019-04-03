.PHONY: test

jpeg-turbo.wasm: Dockerfile jconfig.h jconfigint.h
	docker build .
	sh -c 'docker run --rm -it $$(docker build -q .) | base64 -D > jpeg-turbo.wasm'

test: jpeg-turbo.wasm
	@node_modules/.bin/mocha
