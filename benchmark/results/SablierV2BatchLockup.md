# Benchmarks for BatchLockup

| Function                 | Lockup Type     | Segments/Tranches | Batch Size | Gas Usage |
| ------------------------ | --------------- | ----------------- | ---------- | --------- |
| `createWithDurationsLL`  | Lockup Linear   |                   | 5          | 771013    |
| `createWithTimestampsLL` | Lockup Linear   |                   | 5          | 732772    |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 5          | 3951599   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 5          | 3815274   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 5          | 3862661   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 5          | 3744535   |
| `createWithDurationsLL`  | Lockup Linear   |                   | 10         | 1417180   |
| `createWithTimestampsLL` | Lockup Linear   |                   | 10         | 1414248   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 10         | 7819162   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 10         | 7585613   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 10         | 7632113   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 10         | 7444113   |
| `createWithDurationsLL`  | Lockup Linear   |                   | 20         | 2783509   |
| `createWithTimestampsLL` | Lockup Linear   |                   | 20         | 2779081   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 20         | 15617207  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 20         | 15131248  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 20         | 15211892  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 20         | 14846363  |
| `createWithDurationsLL`  | Lockup Linear   |                   | 30         | 4143337   |
| `createWithTimestampsLL` | Lockup Linear   |                   | 30         | 4148585   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 30         | 23460912  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 30         | 22697560  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 30         | 22794686  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 30         | 22267335  |
| `createWithDurationsLL`  | Lockup Linear   |                   | 50         | 6871104   |
| `createWithTimestampsLL` | Lockup Linear   |                   | 50         | 6893873   |
| `createWithDurationsLD`  | Lockup Dynamic  | 12                | 50         | 22990717  |
| `createWithTimestampsLD` | Lockup Dynamic  | 12                | 50         | 22355937  |
| `createWithDurationsLT`  | Lockup Tranched | 12                | 50         | 22413551  |
| `createWithTimestampsLT` | Lockup Tranched | 12                | 50         | 22006164  |
