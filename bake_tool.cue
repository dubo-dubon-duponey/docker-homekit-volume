package bake

command: {
  image: #Dubo & {
    args: {
      BUILD_TITLE: "Homekit Alsa"
      BUILD_DESCRIPTION: "A dubo image for Homekit Alsa based on \(args.DEBOOTSTRAP_SUITE) (\(args.DEBOOTSTRAP_DATE))"
    }
    platforms: [
      AMD64,
      ARM64,
      V7,
      V6,
      // I386,
      // XXX does not build because of ../../../../pkg/mod/github.com/dubo-dubon-duponey/alsa@v0.0.0-20191017073806-461af7b4c18f/alsatype/SwParams.go:8:10: undefined: SwParams
      // S390X,
      // PPC64LE,
    ]
  }
}
