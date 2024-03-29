package cake

import (
	"duponey.cloud/scullery"
	"duponey.cloud/buildkit/types"
	"strings"
)


cakes: {
  image: scullery.#Cake & {
		recipe: {
			input: {
				from: {
					registry: * "ghcr.io/dubo-dubon-duponey" | string
				}
			}

			process: {
				platforms: types.#Platforms | * [
					types.#Platforms.#AMD64,
					types.#Platforms.#ARM64,
					types.#Platforms.#V7,
					types.#Platforms.#V6,
				]
				// The go alsa lib does not support these platforms
				//	types.#Platforms.#I386,
				//	types.#Platforms.#PPC64LE,
				//	types.#Platforms.#S390X,
			}

			output: {
				images: {
					names: [...string] | * ["homekit-volume"],
					tags: [...string] | * ["latest"]
				}
			}

			metadata: {
				title: string | * "Dubo Alsa Homekit",
				description: string | * "A dubo image for Alsa Homekit",
			}
		}
  }
}

injectors: {
	suite: * "bullseye" | =~ "^(?:jessie|stretch|buster|bullseye|sid)$" @tag(suite, type=string)
	date: * "2021-08-01" | =~ "^[0-9]{4}-[0-9]{2}-[0-9]{2}$" @tag(date, type=string)
	platforms: string @tag(platforms, type=string)
	registry: * "registry.local" | string @tag(registry, type=string)
}

cakes: image: recipe: {
	input: from: registry: injectors.registry

	if injectors.platforms != _|_ {
		process: platforms: strings.Split(injectors.platforms, ",")
	}


	output: images: tags: [injectors.suite + "-" + injectors.date, injectors.suite + "-latest", "latest"]
	metadata: ref_name: injectors.suite + "-" + injectors.date
}

// Allow hooking-in a UserDefined environment as icing
UserDefined: scullery.#Icing

cakes: image: icing: UserDefined
