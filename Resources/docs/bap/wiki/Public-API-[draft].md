## Abstract

This documents describes Binary Analysis Platform (BAP) library public
API. The current state of the document is draft. Everything can be
changed without further notice.

## Table Of Contents
* [Introduction](#introduction)
* [Conventions](#conventions)
* [Transport Layer](#transport-layer)
* [Resources](#resources)
 * [Uploading](#uploading-resource-data)
 * [Downloading](#downloading-resource-data)
 * [Image](#image-resource)
 * [Section](#section-resource)
 * [Symbol](#symbol-resource)
 * [Memory](#memory-resource)
* [Session](#session)
* [Requests](#requests)
 * [`init`](#init)
 * [`load-file`](#load-file)
 * [`load-memory-chunk`](#load-memory-chunk)
 * [`get-insns`](#get-insns)
 * [`get-resource`](#get-resource)
* [Responses](#responses)
 * [`error`](#error)
 * [`capabilities`](#capabilities)
 * [`image`](#image)
 * [`images`](#images)
 * [`symbol`](#symbols)
 * [`section`](#sections)
 * [`insns`](#insns)

## Introduction

This is a draft for a public API for BAP Server. The BAP server is an
application that can provide BAP as a service to the third party
applications, written in any language. We will refer to a BAP server
as SERVER, and to third party application as a CLIENT. This document
describes only the application protocol, the underlying transport
protocol is out of the scope of the document.

## Conventions

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in
[RFC 2119](http://tools.ietf.org/html/rfc2119) .

## Transport Layer

Transport Layer is used to deliver messages and data. Different
transport layers may be used to deliver different data. For example,
while requests and responses may be delivered using http, data maybe
delivered using ZMQ, network sockets or file system. Data is
referenced using Uniform Resource Identifiers
[uri](http://en.wikipedia.org/wiki/Uniform_resource_identifier).

Uri must fully identify the contents of the file, i.e., two objects
with the same uri must have the same data.

## Resources

BAP Server performs analysis of binary data. The data can be
represented as files, memory chunks. The latter can also have some
meta data associated with it. To abstract this BAP Server uses
resource object.  Each resource denotes some existent block of binary
data. Each resource is identified by its `id`. Client can add new
resources to Server environment, using [`load-file`](#load-file) or
[`load-memory-chunk`](#load-memory-chunk) commands. The resources can
be queried using [`get-resource`](#get-resource) command.

### Uploading Resource Data

To upload some resource to Server, Client must use
[`load-file`](#load-file) or [`load-memory-chunk`](#load-memory-chunk)
commands. This commands contain an URL to the data source. If the
transport protocol of the URL is message oriented, then the resource
data would be one message. If it is stream oriented, then all data
would be obtained until the end of stream condition is met. For
example, for resource specified by URL `file:///bin/ls`, all the file
data would be read.

### Downloading Resource Data

Every object describing particular resource contains a non empty set
of URL that provides the resource data.

### Image resource

Image resource represents a whole executable or library loaded into
BAP Server environment. It can be loaded by Client with
[`load-file`](#load-file) command. Server may have additional images
already loaded before the session start. The array of available
images, is enumerated in [`images`](#images) response to the
[`init`](#init) request. Image by itself, contains some meta data and
also has links to [symbols](#symbol-resource) and [sections](#section-resourse)
resources, contained in it.

### Section resource

Section is a contiguous region of memory belonging to some
[image](#image) and having some meta data associated with it. Sections
can be added only by a particular in process of
[`load-file`](#load-file) command processing.

### Symbol resource

Symbol is a non empty set of memory regions, that belongs to one
artifact. The definition of the artifact is due to the particular
container and programming language. But usually it is just a
function. Symbols has some meta data associated with them, and also,
can possibly have name.

Symbols are added by a particular loader in the process of
[`load-file`](#load-file) operation. Symbol is always associated
with some section, and thus with an image.

Depending on platform or compiler, symbols can occupy a non-contiguous
region of memory. In that case symbol resource will not served by
itself, but should be retrieved by iterating over its memory regions.
In other words, symbol will have `links` field if and only if it
has one memory region.


### Memory

Memory is a contiguous sequence of bytes, at the specified address.
Memory can be associated with some section or symbol, but in general,
it can have no associations. An arbitrary piece of code can be loaded
into BAP Server with [`load-memory-chunk`](#load-memory-chunk) command.

## Session

Session consists of a series of interactions. Each interaction must
consist of at one request and at least one response. Request and
response are messages. Client must be an initiator of the
session. Client must not send responses, and server must not send
requests. Server must send messages only in response to the client's
requests. Server may send more than one response to one request.

## Requests

The request should be a `JSON` object of the following schema:

```json
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Request",
    "description": "A request from Client to Server",
    "type": "object",
    "properties": {
        "id" : {
            "description" : "unique for the client side identifier",
            "type" : "integer",
        },

        "init" : {
            "description" : "initialize session",
            "type" : {"$ref" : "#/definitions/init"}
        },

        "load-file" : {
            "description": "Loads specified file into BAP Server",
            "type" : {"$ref" : "#/definitions/load-file"},
        },

        "load-memory-chunk" : {
            "description": "Loads a piece of memory into BAP Server",
            "type" : {"$ref" : "#/definitions/load-memory-chunk"},
        },

        "get-insns" : {
            "description" : "Retrieve instructions from the resource",
            "type" : {"$ref" : "#/definitions/get-insns"}
        },

        "get-resource" : {
            "description" : "Request particular data from Server",
            "type" : "string"
        },
    },
    "required" : ["id"],
    "minProperties" : 1,
    "maxProperties" : 2,

    "definitions" : {
        "init"  : {
            "type" : "object",
            "properties" : {
                "version" : "string"
            }
        },
        "load-file" : {
            "type" : "object",
            "properties": {
                "url" : {
                    "description" : "url to the file data",
                    "type" : "string",
                    "format" : "uri",
                },

                "loader" : {
                    "description" : "force to use specified backend",
                    "type" : "string",
                }
            },
            "required" : ["url"]
        },

        "load-memory-chunk" : {
            "type": "object",
            "properties": {
                "url" : {
                    "description" : "url to them memory chunk",
                    "type" : "uri",
                },

                "arch" : {
                    "description" : "target architecture",
                    "type" : "string",
                },

                "address" : {
                    "description" : "virtual address of the first byte",
                    "type" : "int",
                    "default" : 0,
                },
                "endian" : {
                    "description" : "order of bytes in a memory word",
                    "type" : "string",
                    "format" : "ADT",
                    "oneOf"  : ["LittleEndian()", "BigEndian()"]
                },
            },
            "required" : ["url", "arch"],
        },


        "get-insns" : {
            "type": "object",
            "properties": {
                "resource" : {
                    "description" : "The identifier of the resource",
                    "type" : "string",
                },
                "stop-conditions" : {
                    "description" : "A set of stop conditions",
                    "type" : "array",
                    "minItems" : 1,
                    "uniqueItems" : true,
                    "items" : {
                        "type" : "string",
                        "format" : "ADT"
                    }
                }
            },
            "required" : ["resource"]
        }
    }
}
```

### `init`

The `init` request is sent to initiate a session. Client must not send
any requests before the `init` request.

Server must respond to this request with `error` or `capabilities` message.

If Server responded with `error` message the session is not started,
and Client should either finish its interaction or send another `init`
message.


### `load-file`

The `load-file` request is sent to direct the server in order to load
new executable or library. Server must respond to this request with
either of this responses:
 * `error`
 * `image` resource


The file must be a properly encoded binary container in one of the
supported formats, see [capabilities](#capabilities). For loading raw
binary chunks into bap see [`load-memory-chunk`](#load-memory-chunk)
command. Despite the name `load-file` can point to any resource location.

Client may send several `load-file` or [`use-data`](#use-data) request
per session.

Example of the request:

```json
{
    "id" : 12,
    "load-file" : {
        "url"    : "file:///bin/ls",
        "loader"  : "bap-elf",
    }
}
```

### `load-memory-chunk`

The `load-memory-chunk` may be used if the calling side wants to
provide an arbitrary data for analyzing. The data shouldn't contain
any meta information, and it wouldn't be parsed as a binary container.
Since no meta data exists, a client side must define an instruction
set, using `arch` property.

The server must respond to this request with the `error` or `memory`
resource responses.

Example:

```json
{
    "id" : "15",
    "load-memory-chunk" : {
        "arch"    : "arm",
        "url"     : "zmq+ipc:/tmp/bap/15"
    }
}
```


### `get-insns`

The `get-insn` command is used to retrieve instructions from the
specified binary data.

The server must respond with `insns` or `error` messages. The server
may still response with `insns` message even when the error has
occurred.

Example:

```json
{
    "id" : 17,
    "get-insns" : {
        "resource" : "24",
        "stop-conditions" : ["isCall()"]
    }
}
```

### `get-resource`

This message allows Client to request information about arbitrary
resource. Depending on the resource identified, Server must respond with
either of the following messages:

* `error`
* `image`
* `memory`
* `section`
* `symbol`

## Responses

Response message must be a `JSON` object with the following schema:

```json
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Response",
    "description": "A reply from Server to Client",
    "type": "object",
    "properties": {

        "id" : {
            "description" : "An id of the request to which we're replying",
            "type" : "string",
        },

        "error" : {
            "description" : "the request cannot be satisfied",
            "type" : {"$ref" : "#/definitions/error"}
        },

        "capabilities" : {
            "description" : "a set of capabilities supported by Server",
            "type" : {"$ref" : "#/definitions/capabilities"}
        },

        "image" : {
            "description" : "binary container description",
            "type" : {"$ref" : "#/definitions/image"}
        },

        "images" : {
            "description" : "the array of preloaded images",
            "uniqueItems" : true,
            "type" : {"$ref" : "#/definitions/ids"}
        },

        "symbols" : {
            "description" : "the array of symbols",
            "type" : {"$ref" : "#/definitions/ids"},
        },

        "symbol" : {"type" : {"$ref" : "#/definitions/symbol"}},

        "sections" : {
            "description" : "the array of sections",
            "type" : {"$ref" : "#/definitions/ids"}
        },

        "section" : {"type" : {"$ref" : "#/definitions/section"}},

        "insns" : {
            "description" : "the array of insns",
            "type" : "array",
            "minItems" : 1,
            "items" : {"$ref" : "#/definitions/insn"}
        },
    },
    "required" : ["id"],
    "minProperties" : 1,
    "maxProperties" : 2,

    "definitions" : {

        "error" : {
            "type" : "object",
            "properties" : {
                "description" : {"type" : "string"},
                "severity" : {
                    "type"  : "string",
                    "oneOf" : ["critical", "error", "warning"]
                }
            },
            "required" : ["description", "severity"]
        },

        "capabilities" : {
            "type" : "array",
            "minItems" : 1,
            "items" : {
                "type" : "object",
                "properties" : {
                    "version" : {
                        "description" : "protocol version",
                        "type" : "stringArray"
                    },
                    "loaders" : {
                        "description" : "a set of supported file loaders",
                        "type" : "array",
                        "minItems" : 1,
                        "uniqueItems" : true,
                        "items" : {"type" : {"$ref" : "#/definitions/loader"}}
                    },
                    "disassemblers" : {
                        "description" : "a set of supported disassemblers backend",
                        "type" : "array",
                        "minItems" : 1,
                        "uniqueItems" : true,
                        "items" : {"type" : {"$ref" : "#/definitions/disassembler"}}
                    },
                    "transports" : {
                        "description" : "Supported set of transport protocols",
                        "type" : "array",
                        "minItems" : 1,
                        "uniqueItems" : true,
                        "items" : {"type" : "string"}
                    }
                },
                "required" : ["version", "loaders", "disassemblers"]
            },
        },

        "resource" : {
            "type" : "object",
            "description" : "server resource",
            "properties" : {
                "id" : {
                    "description" : "unique resource identifier",
                    "type" : "string"
                },
                "links" : {
                    "description" : "a set of URL where the resource is available",
                    "type" : "array",
                    "minItems" : 1,
                    "uniqueItems" : true,
                    "items" : {"type" : "string", "format" : "uri"}
                }
            },
            "required" : ["id"]
        },

        "ids" : {
            "title" : "identifiers",
            "description" : "a list of resource identifiers",
            "type"  : "array",
            "items" : {
                "description" : "id of the resource",
                "type" : "string"
            },
            "uniqueItems" : true,
        },

        "memory" : {
            "type" : "object",
            "properties" : {
                "addr" : {"type" : "integer"},
                "size" : {"type" : "integer"},
                "section" : {"type" : "string"},
                "symbol"  : {"type" : "string"},
            },
            "additionalProperties" : {"$ref" : "#/definitions/resource"},
            "dependencies" : {
                "symbol" : "section"
            },
            "required" : ["addr", "size"],
        },

        "symbol" : {
            "type" : "object",
            "properties" : {
                "name" : { "type" : "string" },
                "is_function" : {"type" : "boolean"},
                "is_debug" : {"type" : "boolean"},
                "section" : {
                    "description" : "id of a section to which the symbol belongs",
                    "type" : "string"
                },

                "memory" : {"$ref" : "#/definitions/ids"},
            },
            "required" : ["memory", "is_function", "is_debug", "section"]
        },

        "section" : {
            "type" : "object",
            "properties" : {
                "name" : {"type" : "string"},
                "image": {"type" : "integer", "description" : "image id"},
                "off"  : {"type" : "integer", "description" : "offset in the image"},
                "perm" : {
                    "type" : "array",
                    "minItems" : 1,
                    "maxItems" : 3,
                    "uniqueItems" : true,
                    "items" : {"type" : "string", "oneOf" : ["r", "w", "x"]}
                },
                "memory" : {"type" : "integer", "description" : "memory id"},
            },
            "additionalProperties" : {"$ref" : "#/definitions/resource"},
            "required" : ["off", "perm", "memory", "image", "links"]
        },

        "image" : {
            "type" : "object",
            "properties" : {
                "file" : {"type" : "string", "description" : "associated file name"},
                "arch" : {"type" : "string"},
                "entry-point" : {"type" : "integer"},
                "addr-size" : {
                    "type" : "integer",
                    "oneOf" : [32, 64],
                },
                "endian" : {
                    "type" : "string",
                    "oneOf" : ["LittleEndian()", "BigEndian()"],
                    "format" : "ADT",
                },
                "sections" : {"$ref" : "#/definitions/ids"},
                "symbols"  : {"$ref" : "#/definitions/ids"},
            },
            "additionalProperties" : {"$ref" : "#/definitions/resource"},
            "required" : ["arch", "entry-point", "addr-size", "endian", "memory", "links"],
        },

        "insn" : {
            "type" : "object",
            "properties" : {
                "name" : {
                    "title" : "Instruction name",
                    "description" : "Name accroding to the disassembler backend in use",
                    "type" : "string",
                },

                "asm" : {
                    "description" : "Instruction representation in a target assembler",
                    "type" : "string"
                },

                "operands" : {
                    "description" : "An array of operators, according to the disassembler",
                    "type" : "array",
                    "minItems" : 0,
                    "items" : {"type" : "string", "format" : "ADT"}
                },

                "kinds" : {
                    "description" : "A set of kinds appropriate for the instruction",
                    "type" : "array",
                    "minItems" : 0,
                    "uniqueItems" : true,
                    "items" : {"type" : "string", "format" : "ADT"}
                },

                "target" : {
                    "title" : "Target Instruction",
                    "description" : "Target specific machine instruction",
                    "type" : "string",
                    "format" : "ADT",
                },

                "bil" : {
                    "description" : "BIL Instructions",
                    "type" : "array",
                    "minItems" : 0,
                    "items" : {"type" : "string", "format" : "ADT"}
                },
                "memory" : {
                    "description" : "Memory region occupied by an insn",
                    "type" : {"$ref" : "#/definitions/id"}
                }
            },

            "required" : ["name", "operands", "memory", "asm"],
            "dependencies" : {
                "bil" : "target",
            }
        },

        "loader" : {
            "description" : "Capabilities of binary container parser",
            "type" : "object",
            "properties" : {
                "name" : { "type" : "string"},
                "format" : {
                    "description" : "File format",
                    "type" : "string"
                },
                "architecture" : {
                    "description" : "Supported architecture",
                    "type" : "string",
                },
                "symbols" : {
                    "description" : "Capability to read symbol information",
                    "type" : "array",
                    "minItems" : 0,
                    "items" : {
                        "type" : "string",
                        "anyOf" : ["symtab", "debug"],
                    }
                }
            },
            "required" : ["name", "format", "architecture", "symbols"]
        },

        "disassembler" : {
            "description" : "capabilities of disassembler",
            "type" : "object",
            "properties" : {
                "name" : { "type" : "string"},
                "architecture" : {
                    "description" : "Disassembler instruction set",
                    "type" : "string",
                },
                "kinds" : {
                    "description" : "set of understandable kinds",
                    "type" : "array",
                    "items" : {"type" : "string"},
                    "minItems" : 1,
                    "uniqueItems" : true
                },
                "has-name" : {
                    "description" : "can provide instruction name",
                    "type" : "boolean",
                },
                "has-ops" : {
                    "description" : "can provide instruction operands",
                    "type" : "boolean",
                },
                "has-target" : {
                    "description" : "can provide lifted target instruction",
                    "type" : "boolean",
                },
                "has-bil" : {
                    "description" : "can provide BIL",
                    "type" : "boolean",
                },
            },
            "required" : [
                "name", "architecture", "kinds",
                "has-name", "has-ops", "has-target", "has-bil"
            ]
        }
    }
}
```

### `error`

Server may use this message as a respond to any request. The
`description` field shall contain a printable and human readable
description of the occurred condition. The `severity` field values
have the following meaning:

* `critical` an unrecoverable error has occurred. All further request
  may contain invalid data or may be ignored. Client should start new
  session.

* `error` the corresponding request cannot be satisfied. All following
  responses to the specified `request` should be discarded.

* `warning` the corresponding request can not be satisfied to full
extent. All other responses to the `request` may be considered valid.

### `capabilities`

This message must be sent in response to the `init` request, if
Server supports the requested protocol version. Otherwise Server must
respond with an `error`. Message contains a description of features,
that Server can provide to Client. Each set of features is tagged by a
protocol version. Example:

```json
{
    "id" : 0,
    "request" : 0,
    "capabilities" : [
        {
            "version" : "1.2.1-alpha",
            "loaders" : [
                {
                    "name" : "bap-elf",
                    "formats" : ["ELF"],
                    "architecture" : "386",
                    "symbols" : ["debug"]
                },
                {
                    "name" : "bap-elf",
                    "formats" : ["ELF"],
                    "architecture" : "ARM",
                    "symbols" : ["debug"]
                }
            ],
            "disassemblers" : [
                {
                    "name" : "llvm",
                    "architecture"  : "arm",
                    "kinds" : [
                        "Kind()", "Having_side_effects()",
                        "Affecting_control()", "Branch()",
                        "ConditionalBranch()", "UnconditionalBranch()",
                        "IndirectBranch()", "Return()", "Call()",
                        "Barrier()", "Terminator()", "May_affect_control_flow()",
                        "May_load()", "May_store()"
                    ],
                    "has-name" : true,
                    "has-ops" : true,
                    "has-target" : true,
                    "has-bil" : true,
                },
                {
                    "name" : "llvm",
                    "architecture"  : "x86",
                    "kinds" : [
                        "Kind()", "Having_side_effects()",
                        "Affecting_control()", "Branch()",
                        "ConditionalBranch()", "UnconditionalBranch()",
                        "IndirectBranch()", "Return()", "Call()",
                        "Barrier()", "Terminator()", "May_affect_control_flow()",
                        "May_load()", "May_store()"
                    ],
                    "has-name" : true,
                    "has-ops" : true,
                    "has-target" : false,
                    "has-bil" : false,
                }
            ],
            "transports" : ["ipc", "socket", "file"],

        }
    ]
}
```

### `image`

This message must be sent in response to [`load-file`](#load-file)
command, if there're no error conditions of `error` or `critical`
severity. It contains the most information about loaded file (aka,
image).

```json
{
    "id" : 128,
    "request" : 17,
    "image" : {
        "id" : "12123",
        "links" : ["file:///bin/ls"],
        "arch" : "ARM",
        "entry-point" : 40000000,
        "addr-size"  : 32,
        "endian" : "LittleEndian()",
        "sections" : ["12", "17"],
        "symbols" : ["114", "21"]
    }
}
```

### `symbol`

An example of the symbol resource.

```json
{
    "id"     : 3423,
    "request" : 12,
    "symbol" : {
        "id"   : "124",
        "links"  : [
            "mmap:///tmp/bap/2145/image_AF16DE?off=16343420&size16",
            "zmq+ipc:///tmp/bap/syms?id=124"
        ],
        "name" : "get_args",
        "memory" : ["17", "184"],
        "section" : "189",
        "is_function" : "true",
        "is_debug" : "true"
    }
}
```

### `section`


Example of the `section` resource
```json
{
    "id" : 34324,
    "request" : 12,
    "section" : {
        "id"   : "122344",
        "links": ["file:///tmp/bap/sec_12A34DF3"],
        "image": "12",
        "name" : "data",
        "perm" : ["r"],
        "off"  : 64,
        "memory" : "1253543",
    }
}
```

### `insns`

This message must be send in response to `disassemble` command if no
error conditions have occurred. Server may still send this message, if
error condition have occurred. Server must send all instructions
disassembled by the `request` in one message.

Example:

```json
{
    "id"     : 4256,
    "request" : 17,
    "insns" : [
        {
            "name"  : "MOVi",
            "asm"   : "mov r0, #5",
            "ops"   : [ "Reg(\"R0\")", "Imm(5)", "Imm(14)", "Reg(\"Nil\")", "Reg(\"Nil\")"],
            "kinds" : ["Call()"],
            "target": "MOVi(Reg(R0()), Imm(Int(5,32)), Imm(Int(14,32)), Reg(Nil()), Reg(Nil()))",
            "bil"   : ["Move(Var('R0', Imm(32)), Int(5))"]
        }
    ]
}
```

`ops` items, `target` and `bil` uses [ADT](ADT) format to represent data.
