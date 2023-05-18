# Sablier V2 Periphery [![Github Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry]

[gha]: https://github.com/sablierhq/v2-periphery/actions
[gha-badge]: https://github.com/sablierhq/v2-periphery/actions/workflows/ci.yml/badge.svg
[codecov]: https://codecov.io/gh/sablierhq/v2-periphery
[codecov-badge]: https://codecov.io/gh/sablierhq/v2-periphery/branch/main/graph/badge.svg?token=ND1LZOUF2G
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg

This repository contains the peripheral smart contracts of the Sablier V2 Protocol. For lower-level logic, see the
[sablierhq/v2-core](https://github.com/sablierhq/v2-core) repository.

## Install

### Foundry

First, run the install step:

```sh
forge install sablierhq/v2-periphery
```

Then, add the following line to your `remappings.txt` file:

```text
@sablier/v2-periphery/=lib/v2-periphery/src/
```

## Security

This repository does not fall under our bug bounty program, but
[sablierhq/v2-core](https://github.com/sablierhq/v2-core) does. For any security-related concerns, please refer to the
terms specified in that repository.

### Hardhat

Sablier V2 Periphery is available as a Node.js package:

```shell
pnpm add @sablier/v2-periphery
```

## Licensing

Sablier V2 Periphery is licensed under [GPL v3 or later](./LICENSE.md).
