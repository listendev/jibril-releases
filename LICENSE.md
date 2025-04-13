# License

**License Issuer**: GARNET LABS INC.  
**License Type**: MIT-BR: MIT-Binary-Restricted License  
**Registered Address**: Ontario, Canada  
**Copyright Year**: 2025  
**Software: Jibril**  

## Overview

This license governs the use of Jibril, distributed exclusively as a compiled binary. Jibril is a runtime security tool developed by Garnet Labs Inc., a corporation registered in Ontario, Canada, and consists of three main projects: Jibril eBPF programs, Jibril eBPF Loader, and Jibril Agent. Jibril is designed for internal use only (non-GPLv2 binary, containing packaged GPLv2 ELF objects) and deployment within user and customer environments across various scenarios, including:

- CI/CD Security  
Security integration into development pipelines to identify vulnerabilities prior to production.
- Cloud Native Runtime  
Security for cloud-native applications in containers, Kubernetes, and serverless environments.
- Classic Runtime  
Runtime security for traditional server environments, focusing on mission-critical applications.
- IoT Security  
Protection for connected devices and IoT infrastructure in resource-constrained environments.

> Jibril is provided as-is, with no warranties or support obligations from Garnet Labs Inc. unless explicitly stipulated in a separate, signed contract. The binary distributes components of multiple projects from a single file.

## Licensing Framework

Jibril compiled binary is distributed under the MIT-Binary-Restricted License (MIT-BR). Here’s the breakdown of licenses for its components:

**eBPF Objects:**  
Licensed under GNU General Public License (GPLv2) due to Linux kernel integration. These are uncompressed, loaded into the kernel, and align with licensing norms of similar eBPF projects.

**Userland eBPF Loader and Agent**:  
Licensed under the MIT-Binary-Restricted License (MIT-BR) and statically linked with libbpf, which carries a dual LGPLv2.1 OR BSD-2-Clause license. Any modifications to libbpf will be submitted as proposals to its upstream repository.

The final binary merges these projects into one executable, governed exclusively by MIT-BR for usage terms (see clarification Terms below). However, the embedded eBPF objects remain subject to GPLv2.

## License Terms

### MIT-Binary-Restricted License

**Copyright (c) 2025 Garnet Labs Inc.**  
Permission is hereby granted, free of charge, to any person or entity obtaining a copy of this software in binary form (the "Software"), to use the Software solely for internal purposes within the licensee's organization or as an individual, subject to the following conditions:

**Internal Use Restriction**: The Software is restricted to internal use only. Distribution, publication, sub-licensing, or disclosure of the Software, in whole or in part, to any third party is prohibited without prior written consent from Garnet Labs Inc. This includes any attempt to reverse-engineer, decompile, or disassemble the Software to derive source code or other information, except as permitted by applicable law.

**Embedded Components**: The Software includes eBPF objects licensed under the GNU General Public License (GPLv2). Usage of these components remains subject to GPLv2 terms, including source code disclosure obligations if modified and distributed. The Userland eBPF Loader is statically linked with libbpf (dual-licensed under LGPLv2.1 OR BSD-2-Clause); any modifications to libbpf will be proposed to its upstream repository.

The above copyright notice and this permission notice must be included in all copies or substantial portions of the Software.

> THE SOFTWARE IS PROVIDED "AS IS," WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NONINFRINGEMENT. IN NO EVENT SHALL GARNET LABS INC. BE LIABLE FOR ANY CLAIM, DAMAGES, OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT, OR OTHERWISE, ARISING FROM, OUT OF, OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Terms of Use

**Scope**  
This license applies to Jibril for internal use within the specified deployment scenarios.

**Distribution**  
Jibril is provided as a binary-only product, with no source code included.

**Support and Liability**  
No support, maintenance, or liability is provided by Garnet Labs Inc. unless specified in a separate, signed contract. The Software is offered as-is, with all risks borne by the licensee.

**Additional Agreements**  
Any obligations, including support during Toronto business hours (9 AM–5 PM ET) or feedback requirements, require a parallel contract with Garnet Labs Inc.

**Delivery Specifications**  
Binary Format: Jibril is distributed as a single statically linked binary to facilitate distribution. eBPF objects are uncompressed in a local temporary directory and loaded into the kernel.

**Contact Information**  
For inquiries related to licensing or potential contracts, contact Garnet Labs Inc. at jibril@garnet.ai. No response is guaranteed unless a signed agreement is in place.

> Last updated: April 1, 2025
