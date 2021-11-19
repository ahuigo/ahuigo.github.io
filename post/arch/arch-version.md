---
title: semver 版本管理
date: 2021-11-19
private: true
---
# semver 版本管理
总结下 https://semver.org/ 的版本说明

1. A normal version number MUST take the form X.Y.Z where X, Y, and Z are non-negative integers, and MUST NOT contain leading zeroes. X is the major version, Y is the minor version, and Z is the patch version. Each element MUST increase numerically. For instance: 1.9.0 -> 1.10.0 -> 1.11.0.

2. Major version zero (0.y.z) is for initial development. Anything MAY change at any time. The **public API SHOULD NOT** be considered stable.

3. Version 1.0.0 defines the public API. The way in which the version number is incremented after this release is dependent on this public API and how it changes.

3. Patch version Z (x.y.Z | x > 0) MUST be incremented if only backwards compatible bug fixes are introduced. A bug fix is defined as an internal change that fixes incorrect behavior.

4. Minor version Y (x.Y.z | x > 0) MUST be incremented if new, backwards compatible functionality is introduced to the public API. 

5. Major version X (X.y.z | X > 0) MUST be incremented if any backwards incompatible changes are introduced to the public API. 

6. A pre-release version MAY be denoted by appending a hyphen and a series of dot separated identifiers immediately following the patch version. Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-]. Identifiers MUST NOT be empty. Numeric identifiers MUST NOT include leading zeroes. Pre-release versions have a lower precedence than the associated normal version. A pre-release version indicates that the version is unstable and might not satisfy the intended compatibility requirements as denoted by its associated normal version. Examples: 1.0.0-alpha, 1.0.0-alpha.1, 1.0.0-0.3.7, 1.0.0-x.7.z.92, 1.0.0-x-y-z.–.
6. 一个预发布版本可以通过在补丁版本后面附加一个连字符和一系列用点分隔的标识符来表示。标识符只能包含ASCII字母数字和连字符[0-9A-Za-z-]。标识符不能为空。数字标识符不能包含前导零。预发布版本的优先级低于相关的正常版本。预发布版本表明该版本是不稳定的，可能不满足与其相关的正常版本所表示的预期兼容性要求。

7. Build metadata MAY be denoted by appending a plus sign and a series of dot separated identifiers immediately following the patch or pre-release version. Identifiers MUST comprise only ASCII alphanumerics and hyphens [0-9A-Za-z-]. Identifiers MUST NOT be empty. Build metadata MUST be ignored when determining version precedence. Thus two versions that differ only in the build metadata, have the same precedence. Examples: 1.0.0-alpha+001, 1.0.0+20130313144700, 1.0.0-beta+exp.sha.5114f85, 1.0.0+21AF26D3—-117B344092BD.
7. 构建元数据可以通过在补丁或预发布版本后面附加一个加号和一系列点分隔的标识符来表示。

8. Precedence refers to how versions are compared to each other when ordered.
    1. Precedence is determined by the first difference when comparing each of these identifiers from left to right as follows: Major, minor, and patch versions are always compared numerically.
        Example: 1.0.0 < 2.0.0 < 2.1.0 < 2.1.1.

    2. When major, minor, and patch are equal, a pre-release version has lower precedence than a normal version:
        Example: 1.0.0-alpha < 1.0.0.
    3. Numeric identifiers always have lower precedence than non-numeric identifiers.
        Example: 1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0.