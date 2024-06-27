# Benchmarks for BatchLockup

| Function                 | Lockup Type     | Segments/Tranches | Batch Size | Gas Usage |
| ------------------------ | --------------- | ----------------- | ---------- | --------- |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 5          | 771013    |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 5          | 732772    |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 5          | 3951599   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 5          | 3815274   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 5          | 3862651   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 5          | 3744523   |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 10         | 1417180   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 10         | 1414247   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 10         | 7819165   |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 10         | 7585616   |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 10         | 7632114   |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 10         | 7444115   |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 20         | 2783510   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 20         | 2779081   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 20         | 15617207  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 20         | 15131248  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 20         | 15211892  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 20         | 14846363  |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 30         | 4143337   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 30         | 4148585   |
| `createWithDurationsLD`  | Lockup Dynamic  | 24                | 30         | 23460912  |
| `createWithTimestampsLD` | Lockup Dynamic  | 24                | 30         | 22697560  |
| `createWithDurationsLT`  | Lockup Tranched | 24                | 30         | 22794686  |
| `createWithTimestampsLT` | Lockup Tranched | 24                | 30         | 22267335  |
| `createWithDurationsLL`  | Lockup Linear   | N/A               | 50         | 6871104   |
| `createWithTimestampsLL` | Lockup Linear   | N/A               | 50         | 6893797   |
| `createWithDurationsLD`  | Lockup Dynamic  | 12                | 50         | 22990726  |
| `createWithTimestampsLD` | Lockup Dynamic  | 12                | 50         | 22355943  |
| `createWithDurationsLT`  | Lockup Tranched | 12                | 50         | 22413554  |
| `createWithTimestampsLT` | Lockup Tranched | 12                | 50         | 22006169  |
