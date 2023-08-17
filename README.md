# Sablier V2 Periphery [![Github Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry]

[gha]: https://github.com/sablier-labs/v2-periphery/actions
[gha-badge]: https://github.com/sablier-labs/v2-periphery/actions/workflows/ci.yml/badge.svg
[codecov]: https://codecov.io/gh/sablier-labs/v2-periphery
[codecov-badge]: https://codecov.io/gh/sablier-labs/v2-periphery/branch/main/graph/badge.svg
[foundry]: https://getfoundry.sh/
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg

This repository contains the peripheral smart contracts of the Sablier V2 Protocol. For lower-level logic, see the
[sablier-labs/v2-core](https://github.com/sablier-labs/v2-core) repository.

In-depth documentation is available at [docs.sablier.com](https://docs.sablier.com).

## Install

### Foundry

First, run the install step:

```sh
forge install sablier-labs/v2-periphery
```

Then, add the following line to your `remappings.txt` file:

```text
@sablier/v2-periphery/=lib/v2-periphery/
```

### Node.js

Sablier V2 Periphery is available as a Node.js package:

```shell
pnpm add @sablier/v2-periphery
```

## Security

Please refer to the [SECURITY](./SECURITY.md) policy for any security-related concerns. This repository is subject to a
bug bounty program per the terms outlined in the aforementioned policy.

## License

Sablier V2 Periphery is licensed under [GPL v3 or later](./LICENSE.md), except for most of the files in `test/`, which
remain unlicensed (as indicated in their SPDX headers).
