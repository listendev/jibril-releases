# MIT-Binary-Restricted License (MIT-BR)

**License Issuer:** Garnet Labs Inc.  
**Registered Address:** Ontario, Canada  
**Ontario Corporation Number:** 002727919  
**Copyright Year:** 2025  
**Software:** Jibril

## Overview

Jibril is a runtime security tool developed by Garnet Labs Inc., a corporation registered in Ontario, Canada, under Ontario Corporation Number 002727919. This license governs the use of Jibril, distributed exclusively as a compiled binary, for internal deployment within user and customer environments across the following scenarios:

- **CI/CD Security**: Security integration into development pipelines to identify vulnerabilities prior to production.
- **Cloud Native Runtime**: Security for cloud-native applications in containers, Kubernetes, and serverless environments.
- **Classic Runtime**: Runtime security for traditional server environments, focusing on mission-critical applications.
- **IoT Security**: Protection for connected devices and IoT infrastructure in resource-constrained environments.

Jibril is provided as-is, with no warranties or support obligations from Garnet Labs Inc. unless explicitly stipulated in a separate, signed contract. The binary includes all components—eBPF hooks and the Golang agent—statically linked for deployment.

## Licensing Framework

Jibril's original source code incorporates multiple licenses due to its dependencies. The compiled binary is distributed under the MIT-Binary-Restricted License (MIT-BR) to ensure proprietary protection. The following licenses apply to the source components:

- **eBPF Source Code**: Licensed under the GNU General Public License (GPLv2 - see LICENSE.GPL) due to its interaction with the Linux kernel.
- **Userland eBPF Loader**: Licensed under the GNU Lesser General Public License (LGPLv2.1) as it is statically linked with `libbpf`, an LGPLv2.1-licensed library.
- **Remaining Components**: Licensed under the MIT-Binary-Restricted License (MIT-BR) for all other code developed by Garnet Labs Inc.

The binary distribution consolidates these components into a single executable, governed solely by the MIT-Binary-Restricted License (MIT-BR) for usage terms.

## License Terms

**MIT-Binary-Restricted License (MIT-BR)**  
_Copyright (c) 2025 Garnet Labs Inc., Ontario Corporation Number 002727919_

Permission is hereby granted, free of charge, to any person or entity obtaining a copy of this software in binary form (the "Software"), to use the Software solely for internal purposes within the aforementioned deployment scenarios, subject to the following conditions:

1. **Internal Use Restriction**: The Software shall be used exclusively for internal purposes by the licensee's organization or individual licensee. Distribution, publication, sublicensing, or disclosure of the Software, in whole or in part, to any third party is expressly prohibited without prior written consent from Garnet Labs Inc. This includes any attempt to reverse-engineer, decompile, or disassemble the Software to derive source code or other information, except as permitted by applicable law.

2. The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL GARNET LABS INC. BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Terms of Use

- **Scope**: This license applies to the Jibril binary, encompassing all embedded components (kernel and userland hooks, loader, libraries, userland agent, scripts and any related file), for internal use within the specified deployment scenarios.
- **Distribution**: Jibril is provided as a binary-only product, with no source code included.
- **Support and Liability**: No support, maintenance, or liability is provided by Garnet Labs Inc. unless specified in a separate, signed contract. The Software is offered as-is, with all risks borne by the licensee.
- **Additional Agreements**: Any obligations, including support during Toronto business hours (9 AM–5 PM ET) or feedback requirements, require a parallel contract with Garnet Labs Inc.

## Source Code Requests

The Jibril binary is a compiled, statically linked executable. Due to the inclusion of GPL-licensed (eBPF) and LGPL-licensed (loader with `libbpf`) components, recipients may have the right to request the corresponding source code under the terms of those licenses. Such requests shall be directed to `source-requests@jibril.io`. Responses may take up considerable time, in accordance with legal precedents, as requests are evaluated on a case-by-case basis. The MIT-BR components remain proprietary and are not subject to disclosure.

## Delivery Specifications

- **Binary Format**: Jibril is distributed as a single, statically linked binary embedding all components, including `libbpf` and eBPF code, to facilitate deployment without separate files.
- **Purpose**: The MIT-BR license ensures the proprietary nature of the Software, while GPL and LGPL disclosures comply with the legal requirements of the underlying dependencies.

## Contact Information

For inquiries related to licensing or potential contracts, contact Garnet Labs Inc. at [devteam@garnet.ai](mailto:devteam@garnet.ai). No response is guaranteed unless a signed agreement is in place.

> **Last updated:** March 18, 2025
