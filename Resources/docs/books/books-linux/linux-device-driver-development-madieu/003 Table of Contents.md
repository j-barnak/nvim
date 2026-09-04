# Table of Contents

## Preface

## Section 1 -Linux Kernel Development Basics

## *Chapter 1*: Introduction to Kernel Development

### Setting up the development environment

### Setting up the host machine

### Getting the sources

### Configuring and building the Linux kernel

### Specifying compilation options

### Understanding the kernel configuration process

### Building the Linux kernel

### Building and installing modules

### Summary

## *Chapter 2*: Understanding Linux Kernel Module Basic Concepts

### An introduction to the concept of modules

### Case study – module skeleton

### Building a Linux kernel module

### Understanding the Linux kernel build system

### Out-of-tree building

### In-tree building

### Handling module parameters

### Dealing with symbol exports and module dependencies

### An introduction to the concept of module dependencies

### Learning some Linux kernel programming tips

### Error handling

### Message printing – goodbye printk, long life dev\_\*, pr\_\*, and net\_\* APIs

### Summary

## *Chapter 3*: Dealing with Kernel Core Helpers

### Linux kernel locking mechanisms and shared resources

### Spinlocks

### Mutexes

### Trylock methods

### Dealing with kernel waiting, sleeping, and delay mechanisms

### Wait queue

### Simple sleeping in the kernel

### Kernel delay or busy waiting

### Understanding Linux kernel time management

### The concepts of clocksource, clockevent, and tick device

### Using standard kernel low-precision (low-res) timers

### High-resolution timers (hrtimers)

### Implementing work-deferring mechanisms

### Softirqs

### Tasklets

### Workqueues

### Workqueues' new generation

### Kernel interrupt handling

### Designing and registering an interrupt handler

### Summary

## *Chapter 4*: Writing Character Device Drivers

### The concept of major and minor

### Character device data structure introduction

### An introduction to device file operations

### File representation in the kernel

### Creating a device node

### Device identification

### Registration and deregistration of character device numbers

### Initializing and registering a character device on the system

### Implementing file operations

### Exchanging data between the kernel space and user space

### Implementing the open file operation

### Implementing the release file operation

### Implementing the write file operation

### Implementing the read file operation

### Implementing the llseek file operation

### The poll method

### The ioctl method

### Summary

## Section 2 - Linux Kernel Platform Abstraction and Device Drivers

## *Chapter 5*: Understanding and Leveraging the Device Tree

### Understanding the basic concept of the device tree mechanism

### The device tree naming convention

### An introduction to the concept of aliases, labels, phandles, and paths

### Understanding overwriting nodes and properties

### Device tree sources and compilers

### Representing and addressing devices

### Handling SPI and I2C device addressing

### Memory-mapped devices and device addressing

### Handling resources

### The struct resource

### Extracting application-specific data

### Summary

## *Chapter 6*: Introduction to Devices, Drivers, and Platform Abstraction

### Linux kernel platform abstraction and data structures

### Device base structure

### Device driver base structure

### Device/driver matching and module (auto) loading

### Device declaration – populating devices

### Bus structure

### Device and driver matching mechanism explained

### Case study – the OF matching mechanism

### Summary

## *Chapter 7*: Understanding the Concept of Platform Devices and Drivers

### Understanding the platform core abstraction in the Linux kernel

### Dealing with platform devices

### Allocating and registering platform devices

### How not to allocate platform devices to your code

### Working with platform resources

### Platform driver abstraction and architecture

### Probing and releasing the platform devices

### Provisioning supported devices in the driver

### Driver initialization and registration

### Example of writing a platform driver from scratch

### Summary

## *Chapter 8*: Writing I2C Device Drivers

### I2C framework abstractions in the Linux kernel

### A brief introduction to struct i2c_adapter

### I2C client and driver data structures

### I2C communication APIs

### The I2C driver abstraction and architecture

### Probing the I2C device

### Implementing the i2c_driver.remove method

### Driver initialization and registration

### Provisioning devices in the driver

### Instantiating I2C devices

### How not to write I2C device drivers

### Summary

## *Chapter 9*: Writing SPI Device Drivers

### Understanding the SPI framework abstractions in the Linux kernel

### Brief introduction to struct spi_controller

### The struct spi_device structure

### The spi_driver structure

### The message transfer data structures

### Accessing the SPI device

### Dealing with the SPI driver abstraction and architecture

### Probing the device

### Provisioning devices in the driver

### Implementing the spi_driver.remove method

### Driver initialization and registration

### Instantiating SPI devices

### Learning how not to write SPI device drivers

### Summary

## Section 3 - Making the Most out of Your Hardware

## *Chapter 10*: Understanding the Linux Kernel Memory Allocation

### An introduction to Linux kernel memory-related terms

### Kernel address space layout on 32-bit systems – the concept of low and high memory

### An overview of a process address space from the kernel

### Understanding the concept of VMA

### Demystifying address translation and MMU

### Page lookup and the TLB

### The page allocator

### The slab allocator

### kmalloc family allocation

### vmalloc family allocation

### A short story about process memory allocation under the hood

### Working with I/O memory to talk to hardware

### PIO device access

### MMIO device access

### Memory (re)mapping

### Understanding the use of kmap

### Mapping kernel memory to user space

### Summary

## *Chapter 11*: Implementing Direct Memory Access (DMA) Support

### Setting up DMA mappings

### The concept of cache coherency and DMA

### Memory mappings for DMA

### Introduction to the concept of completion

### Working with the DMA engine's API

### A brief introduction to the DMA controller interface

### Handling device DMA addressing capabilities

### Requesting a DMA channel

### Configuring the DMA channel

### Configuring the DMA transfer

### Submitting the DMA transfer

### Issuing pending DMA requests and waiting for callback notification

### Putting it all together – Single-buffer DMA mapping

### A word on cyclic DMA

### Understanding DMA and DT bindings

### Consumer binding

### Summary

## *Chapter 12*: Abstracting Memory Access – Introduction to the Regmap API: a Register Map Abstraction

### Introduction to the Regmap data structures

### Understanding the struct regmap_config structure

### Handling Regmap initialization

### Using Regmap register access functions

### Bulk and multiple registers reading/writing APIs

### Understanding the Regmap caching system

### Regmap-based SPI driver example – putting it all together

### A Regmap example

### Leveraging Regmap from the user space

### Summary

## *Chapter 13*: Demystifying the Kernel IRQ Framework

### Brief presentation of interrupts

### Understanding interrupt controllers and interrupt multiplexing

### Diving into advanced peripheral IRQ management

### Understanding IRQ and propagation

### Chaining IRQs

### Demystifying per-CPU interrupts

### SGIs and IPIs

### Summary

## *Chapter 14*: Introduction to the Linux Device Model

### Introduction to LDM data structures

### The bus data structure

### The driver data structure

### The device data structure

### Getting deeper inside LDM

### Understanding the kobject structure

### Understanding the kobj_type structure

### Understanding the kset structure

### Working with non-default attributes

### Overview of the device model from sysfs

### Creating device-, driver-, bus- and class-related attributes

### Making a sysfs attribute poll- and select-compatible

### Summary

## Section 4 - Misc Kernel Subsystems for the Embedded World

## *Chapter 15*: Digging into the IIO Framework

### Introduction to IIO data structures

### Understanding the struct iio_dev structure

### Understanding the struct iio_info structure

### The concept of IIO channels

### Distinguishing channels

### Putting it all together – writing a dummy IIO driver

### Integrating IIO triggered buffer support

### IIO trigger and sysfs (user space)

### IIO buffers

### Putting it all together

### Accessing IIO data

### Single-shot capture

### Accessing the data buffer

### Dealing with the in-kernel IIO consumer interface

### Consumer kernel API

### Writing user-space IIO applications

### Scanning and creating an IIO context

### Walking through and managing IIO devices

### Walking through and managing IIO channels

### Working with a trigger

### Creating a buffer and reading data samples

### Walking through user-space IIO tools

### Summary

## *Chapter 16*: Getting the Most Out of the Pin Controller and GPIO Subsystems

### Introduction to some hardware terms

### Introduction to the pin control subsystem

### Dealing with the GPIO controller interface

### Writing a GPIO controller driver

### GPIO controller bindings

### Getting the most out of the GPIO consumer interface

### Integer-based GPIO interface – now deprecated

### Descriptor-based GPIO interface: the new and recommended way

### Learning how not to write GPIO client drivers

### Goodbye to the legacy GPIO sysfs interface

### Welcome to the Libgpiod GPIO library

### The GPIO aggregator

### Summary

## *Chapter 17*: Leveraging the Linux Kernel Input Subsystem

### Introduction to the Linux kernel input subsystem – its data structures and APIs

### Allocating and registering an input device

### Using polled input devices

### Generating and reporting input events

### Handling input devices from the user space

### Summary

### Why subscribe?

## Other Books You May Enjoy