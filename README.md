# Introduction

![./jibril.png](./jibril.png)

Welcome to Jibril project! Jibril is a runtime security tool capable of not only monitoring, but also enforcing application behavior. It is designed to be lightweight, efficient, and easy to use. Jibril is a powerful tool that can be used to monitor and enforce security policies in real-time, providing a high level of protection for your applications.

## Why Jibril is special ?

1. Made by a **team of experts**, including **former Tracee and Falco core engineers**.
2. Differently than other similar projects, Jibril can deal with **any type of workload**.
3. No events, **no losses**. No events, **no delays**.
4. No performance impact, tiny memory footprint.
5. Easy to use.

Read about the [theory](https://listendev.github.io/jibril/dev/overview/theory/) and [history](https://listendev.github.io/jibril/dev/overview/history/) behind it.

## eBPF Loader and Jibril Extension

### eBPF Loader

- There is a single eBPF loader that contains extensions easily added to the build tree.
- There are multiple extensions providing different application like functionalities.
- Each extension can have multiple plugins providing different features.

### Jibril Extension

- The Jibril extension is the main extension of the Jibril project and why it was created.
- Jibril extension has **libraries** to talk to eBPF programs and to the kernel.
- Jibril works with plugins like `config`, `simple`, `procfs`, `netflows` and `detections`.
- Both `config` and `simple` plugins are for internal use.
- The `github` plugin is used to interact with the ListenDev API.
- The `simple` plugin provides a stdout printer (beautified events).
- The `netflows` provides an event called `netflow` (tasks network flows).
- The `detections` plugin provides many different events related to security detections.

## How to try it

### Locally

Best way to try Jibril out, for now, is to use the provided docker container image, like described below, and check the stdout file (`/var/log/jibril/jibril.log`) for the detections output.

```shell
curl -s https://listendev.github.io/jibril/dev/jibril.sh | sh
```

### GitHub Integration

You can also give it a try (as an action) with the GitHub integration support at:

[https://dashboard.listen.dev/](https://dashboard.listen.dev/)

> Jibril is the tool in charge of [https://www.listen.dev/](https://www.listen.dev/) dynamic runtime analysis feature.

## Documentation

[https://listendev.github.io/jibril/dev](https://listendev.github.io/jibril/dev)

## How do I report bugs ?

[https://github.com/listendev/jibril-releases/issues](https://github.com/listendev/Jjbril-releases/issues)
