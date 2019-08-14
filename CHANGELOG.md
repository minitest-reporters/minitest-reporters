### [dev](https://github.com/kern/minitest-reporters/compare/v1.3.8...master)

### [1.3.8](https://github.com/kern/minitest-reporters/compare/v1.3.7...v1.3.8)

* Fixed default ProgressReporter regression from [#278](https://github.com/kern/minitest-reporters/pull/278); fix [#284](https://github.com/kern/minitest-reporters/pull/284) contributed by [bobmaerten](https://github.com/bobmaerten)

### [1.3.7](https://github.com/kern/minitest-reporters/compare/v1.3.6...v1.3.7)

* added ability to specify output dir of JUnitReporter through ENV [#277](https://github.com/kern/minitest-reporters/pull/277) countributed by [KevinSjoberg](https://github.com/KevinSjoberg)
* Added verbose functionality to ProgressReporter [#278](https://github.com/kern/minitest-reporters/pull/278) contributed by [senhalil](https://github.com/senhalil)

### [1.3.6](https://github.com/kern/minitest-reporters/compare/v1.3.5...v1.3.6)

* fixed possible null pointer in #after_suite [#274](https://github.com/kern/minitest-reporters/pull/274)
  contributed by [casperisfine](https://github.com/casperisfine)

### [1.3.5](https://github.com/kern/minitest-reporters/compare/v1.3.5.beta1...v1.3.5)

### [1.3.5.beta1](https://github.com/kern/minitest-reporters/compare/v1.3.4...v1.3.5.beta1)

* additional fix for reporting slowest suites by DefaultReporter [#270](https://github.com/kern/minitest-reporters/issues/270)

### [1.3.4](https://github.com/kern/minitest-reporters/compare/v1.3.3...v1.3.4)

* fixed the way DefaultReporter reports slowest suites [#270](https://github.com/kern/minitest-reporters/issues/270)

### [1.3.3](https://github.com/kern/minitest-reporters/compare/v1.3.2...v1.3.3)

* fixed problem with default report paths for MeanTimeReporter [#269](https://github.com/kern/minitest-reporters/pull/269)
  contributed by [duonoid](https://github.com/duonoid)

### [1.3.2](https://github.com/kern/minitest-reporters/compare/v1.3.2.beta2...v1.3.2)

### [1.3.2.beta2](https://github.com/kern/minitest-reporters/compare/v1.3.2.beta1...v1.3.2.beta2)

* fixed the way JUnitReporter calculates relative path [#258](https://github.com/kern/minitest-reporters/issues/258)

### [1.3.2.beta1](https://github.com/kern/minitest-reporters/compare/v1.3.1...v1.3.2.beta1)

* SpecReporter do not print exception name any more (unless it is an test error) [#264](https://github.com/kern/minitest-reporters/issues/264)
* Fixed loading error caused by fix for [#265](https://github.com/kern/minitest-reporters/pull/265)
  see [#267](https://github.com/kern/minitest-reporters/issues/267) and 
  [#268](https://github.com/kern/minitest-reporters/pull/268) for more details.

### [1.3.1](https://github.com/kern/minitest-reporters/compare/v1.3.1.beta1...v1.3.1)

### [1.3.1.beta1](https://github.com/kern/minitest-reporters/compare/v1.3.0...v1.3.1.beta1)

* Fixed time reporting [#265](https://github.com/kern/minitest-reporters/pull/265) contributed by [brendandeere](https://github.com/brendandeere)

### [1.3.0](https://github.com/kern/minitest-reporters/compare/v1.3.0.beta3...v1.3.0)

### [1.3.0.beta3](https://github.com/kern/minitest-reporters/compare/v1.3.0.beta2...v1.3.0.beta3)

* [#261](https://github.com/kern/minitest-reporters/issues/261) fixed by [#262](https://github.com/kern/minitest-reporters/pull/262) contributed by [trabulmonkee](https://github.com/trabulmonkee)

### [1.3.0.beta2](https://github.com/kern/minitest-reporters/compare/v1.3.0.beta1...v1.3.0.beta2)

* JUnit reporter fixed to comply with JUnit spec ([#257](https://github.com/kern/minitest-reporters/issues/257), [#260](https://github.com/kern/minitest-reporters/pull/260) contributed by [brettwgreen](https://github.com/brettwgreen))

### [1.3.0.beta1](https://github.com/kern/minitest-reporters/compare/v1.2.0...v1.3.0.beta1)

* MINITEST_REPORTER env variable can be used to override reporter [#256](https://github.com/kern/minitest-reporters/pull/256) (contributed by [brettwgreen](https://github.com/brettwgreen))

### [1.2.0](https://github.com/kern/minitest-reporters/compare/v1.2.0.beta3...v1.2.0)

### [1.2.0.beta3](https://github.com/kern/minitest-reporters/compare/v1.2.0.beta2...v1.2.0.beta3)

* junit reporter changed to support mintest >= 5.11 [#252](https://github.com/kern/minitest-reporters/pull/252) (contributed by [Kevinrob](https://github.com/Kevinrob))
* all reporters changed to be compatible with minitest >= 5.11 (if not - report a bug ;)

### [1.2.0.beta2](https://github.com/kern/minitest-reporters/compare/v1.2.0.beta1...v1.2.0.beta2)

* fixed uninitialized time in junit reporter [#251](https://github.com/kern/minitest-reporters/issues/251)
* format option added to progress reporter [#240](https://github.com/kern/minitest-reporters/pull/240) (contributed by [jorgesmu](https://github.com/jorgesmu))
* improved output of junit reporter [#245](https://github.com/kern/minitest-reporters/pull/245) (contributed by [jules2689](https://github.com/jules2689))

### [1.2.0.beta1](https://github.com/kern/minitest-reporters/compare/v1.1.19...v1.2.0.beta1)

* SpecReporter regression for Minitest 5.11.1 fixed [#250](https://github.com/kern/minitest-reporters/pull/250) (contrinuted by [mbround18](https://github.com/mbround18))

### [1.1.19](https://github.com/kern/minitest-reporters/compare/v1.1.18...v1.1.19)

* Reverted [#236](https://github.com/kern/minitest-reporters/pull/236) (it creates too many problems)

### [1.1.18](https://github.com/kern/minitest-reporters/compare/v1.1.17...v1.1.18)

* Fixed problem with Rails 5.1.3 [#230](https://github.com/kern/minitest-reporters/issues/230) by [#236](https://github.com/kern/minitest-reporters/pull/236) (contributed by [samcday](https://github.com/samcday))

### [1.1.17](https://github.com/kern/minitest-reporters/compare/v1.1.16...v1.1.17)

* Fixed tests' counting [#232](https://github.com/kern/minitest-reporters/pull/232) (contributed by [adaedra](https://github.com/adaedra))

### [1.1.16](https://github.com/kern/minitest-reporters/compare/v1.1.15...v1.1.16)

* reverted fix for [#231](https://github.com/kern/minitest-reporters/pull/231) to fix[#233](https://github.com/kern/minitest-reporters/pull/233)

## [1.1.15](https://github.com/kern/minitest-reporters/compare/v1.1.14...v1.1.15)

* Fixed problem with handling SIGINFO [#231](https://github.com/kern/minitest-reporters/pull/231) (contributed by [joshpencheon](https://github.com/joshpencheon))


