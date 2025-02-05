# Changelog

## 1.0.0 (2025-02-05)


### Features

* actually run full workflow in GitHub Actions CI ([18680e2](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/18680e2742061134e528c7d1c4557c2399915571))
* add group definitions in config.yaml ([e098627](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/e098627ca1dc4d72b968de1174777af047911771))
* add initial qc steps ([2340870](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/23408706a7b2779f7a0943c503197109c281b509))
* add working illumina simulation by sliding window approach, add nanosim via wrapper ([c3ba388](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/c3ba38840e65cc5aa65458132bc706fe837ad265))
* create samples.tsv and units.tsv ([d7268d5](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/d7268d5bed5eab47ee21bae42a6c87ebc9141156))
* extend config to specify target coverage per-group and per-circle ([84eb01d](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/84eb01db99f0f62b080425e64666fca04fcadd0e))
* generate coverage output for qc ([973cd97](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/973cd977b69cb80304454b517a9f24a3a8c9998f))
* rules and configuration, working up until circle creation ([4451d20](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/4451d20889ee2985f6a77a7a6210b727e841c478))
* use personal access token to enable GitHub Actions runs on release-please PRs ([#3](https://github.com/dlaehnemann/create-ecdna-testing-data/issues/3)) ([1c50e03](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/1c50e03da02d9fea55c0fcb63a858a2985f0d904))


### Bug Fixes

* also define MODEL in exactly one place ([317ee10](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/317ee1064560f11f3b4bd5b9aa9df85d247df52f))
* define mean_nuc variables in one place, for reusing them later ([b98269d](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/b98269d9b8977058893037be0bf47207a593caee))
* do read simulations per circle (and cov), then merge circles into group sample files ([9fa8d94](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/9fa8d94def49d39ee14fe6eda969460a93ff197a))
* enforce ci runs in main directory ([db03093](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/db030934d83313fdef67d5d0f583b588f7339e84))
* include / document crazy memory requirements of nanosim ([dac951f](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/dac951f6cd67e061203137bd6a7f0bebb7df0e1a))
* lookup in input file syntax ([88c4d6b](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/88c4d6b3b45b0c3f723690640bcd05441a939370))
* nanopore mean read length determination (lognormal distribution and parameter specification in nanosim are unintuitive to me) ([fc46a3c](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/fc46a3c3969e3aa7085414a7d8c22acd9052d23c))
* release-please token name ([#4](https://github.com/dlaehnemann/create-ecdna-testing-data/issues/4)) ([2b2398d](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/2b2398d57073712cb904fa73eae645d7ba761d8d))
* remove unused test.fa file ([#2](https://github.com/dlaehnemann/create-ecdna-testing-data/issues/2)) ([d7b5631](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/d7b56315ea17b9a9175a89552bf4e380fcda93a3))
* scripts paths after linting update ([0ae7529](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/0ae7529cb39c9444d684f4a923f43721cf64e6ed))
* small samples.tsv and units.tsv generation fixes ([cd99761](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/cd997612a9d92f1ffda7a9a95961e936183ad52c))
* use minimap2 for mapping instead of bwa-mem2, especially important for long read data ([162ff28](https://github.com/dlaehnemann/create-ecdna-testing-data/commit/162ff28dadb1e65bc5b4074a4cd7bea69707c983))
