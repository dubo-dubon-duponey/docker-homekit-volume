target "default" {
  inherits = ["shared"]
  args = {
    BUILD_TITLE = "Homekit Alsa Speaker"
    BUILD_DESCRIPTION = "Control your alsa devices volume with HomeKit"
  }
  tags = [
    "dubodubonduponey/homekit-alsa",
  ]
}
