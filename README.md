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

The codebase has undergone rigorous audits by leading security experts from Cantina, as well as independent auditors.
For a comprehensive list of all audits conducted, please click [here](https://github.com/sablier-labs/audits).

For any security-related concerns, please refer to the [SECURITY](./SECURITY.md) policy. This repository is subject to a
bug bounty program per the terms outlined in the aforementioned policy.

## Contributing

Feel free to dive in! [Open](https://github.com/sablier-labs/v2-periphery/issues/new) an issue,
[start](https://github.com/sablier-labs/v2-periphery/discussions/new) a discussion or submit a PR. For any informal
concerns or feedback, please join our [Discord server](https://discord.gg/bSwRCwWRsT).

For guidance on how to create PRs, see the [CONTRIBUTING](./CONTRIBUTING.md) guide.

## License

Sablier V2 Periphery is licensed under [GPL v3 or later](./LICENSE.md), except for most of the files in `test/`, which
remain unlicensed (as indicated in their SPDX headers).
