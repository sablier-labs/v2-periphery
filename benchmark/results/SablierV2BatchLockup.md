# Benchmarks for BatchLockup

| Function                 | Lockup Type     | Segments/Tranches | Batch Size | Gas Usage |
| ------------------------ | --------------- | ----------------- | ---------- | --------- |
| `createWithDurationsLL`  | Lockup Linear   |                   | 2          | 361844    |
| `createWithTimestampsLL` | Lockup Linear   |                   | 2          | 324523    |
| `createWithDurationsLD`  | Lockup Dynamic  | 5                 | 2          | 608910    |
| `createWithTimestampsLD` | Lockup Dynamic  | 5                 | 2          | 578586    |
| `createWithDurationsLT`  | Lockup Tranched | 5                 | 2          | 601881    |
| `createWithTimestampsLT` | Lockup Tranched | 5                 | 2          | 572680    |
| `createWithDurationsLL`  | Lockup Linear   |                   | 5          | 734485    |
| `createWithTimestampsLL` | Lockup Linear   |                   | 5          | 732963    |
| `createWithDurationsLD`  | Lockup Dynamic  | 5                 | 5          | 1391832   |
| `createWithTimestampsLD` | Lockup Dynamic  | 5                 | 5          | 1368315   |
| `createWithDurationsLT`  | Lockup Tranched | 5                 | 5          | 1374272   |
| `createWithTimestampsLT` | Lockup Tranched | 5                 | 5          | 1353582   |
| `createWithDurationsLL`  | Lockup Linear   |                   | 10         | 1417161   |
| `createWithTimestampsLL` | Lockup Linear   |                   | 10         | 1414212   |
| `createWithDurationsLD`  | Lockup Dynamic  | 5                 | 10         | 2732969   |
| `createWithTimestampsLD` | Lockup Dynamic  | 5                 | 10         | 2686132   |
| `createWithDurationsLT`  | Lockup Tranched | 5                 | 10         | 2697702   |
| `createWithTimestampsLT` | Lockup Tranched | 5                 | 10         | 2656477   |
| `createWithDurationsLL`  | Lockup Linear   |                   | 20         | 2783678   |
| `createWithTimestampsLL` | Lockup Linear   |                   | 20         | 2778224   |
| `createWithDurationsLD`  | Lockup Dynamic  | 5                 | 20         | 5419557   |
| `createWithTimestampsLD` | Lockup Dynamic  | 5                 | 20         | 5326631   |
| `createWithDurationsLT`  | Lockup Tranched | 5                 | 20         | 5348503   |
| `createWithTimestampsLT` | Lockup Tranched | 5                 | 20         | 5266764   |
| `createWithDurationsLL`  | Lockup Linear   |                   | 50         | 6889015   |
| `createWithTimestampsLL` | Lockup Linear   |                   | 50         | 6877961   |
| `createWithDurationsLD`  | Lockup Dynamic  | 5                 | 50         | 13503395  |
| `createWithTimestampsLD` | Lockup Dynamic  | 5                 | 50         | 13276192  |
| `createWithDurationsLT`  | Lockup Tranched | 5                 | 50         | 13318736  |
| `createWithTimestampsLT` | Lockup Tranched | 5                 | 50         | 13124266  |
