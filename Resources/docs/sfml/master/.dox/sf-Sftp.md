{#sftp}

# Sftp

```cpp
#include <Sftp.hpp>
```

```cpp
class Sftp
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:54

An SSH File Transfer Protocol (SFTP) client.

`[sf::Sftp](#sftp)` is a very simple SFTP client that allows you to communicate with a SFTP server. The SFTP protocol allows you to manipulate a remote file system (list files, upload, download, create, remove, ...).

Using the SFTP client consists of 4 parts: 

* Connecting to the SFTP server 
* Logging in (either using username and password or public key authentication) 
* Performing file system operations 
* Disconnecting (this part can be done implicitly by the destructor)

Every operation returns an SFTP result, which contains the result code and optionally a message describing the result. Some commands such as `[getAttributes()](#getattributes)` and `[getDirectoryListing()](#getdirectorylisting-1)` return additional data, and use a class derived from `[sf::Sftp::Result](sf-Sftp-Result.md#result)` to provide this data. The commonly used filesystem operations are directly provided as member functions.

There are three classes of result values: general result values, SSH specific result values and SFTP specific result values. General result values are returned on success and errors not specific to the SSH or SFTP protocols. If an operation manipulating the remote filesystem fails, an SFTP specific result will be returned describing the reason for the failure. If any error related to the communication channel occurs e.g. key exchange failure or authentication failure an SSH error will be returned.

Because most operations manipulate some part of the remote filesystem these operations, especially upload and download, may take some time to complete. This is important to know if you don't want to block your application while the server is completing the task.

Every operation that relies on network communication can be passed a timeout argument. In the simplest case, this timeout argument can just be a fixed time duration after which the operation should time out if no progress has been made. Because some operations simply due to their nature can take longer than others it might not be possible to use the same timeout value for all operations. If it is anticipated that an operation could take a longer amount of time to complete due to e.g. an unreliable or slow connection, the timeout should be increased so the operation still has the possibility to complete successfully. Passing `[sf::Time::Zero](sf-Time.md#zero-1)` as a timeout value will cause the operation to block until completion or failure.

If you want to pass `[sf::Time::Zero](sf-Time.md#zero-1)` to wait indefinitely for an operation to complete but still have the possibility to interrupt the operation e.g. if the user decides to quit the application or interrupt a longer download or upload, the timeout can be constructed from a predicate and polling period. The predicate is a callable that takes no parameters and returns `true` if the operation should continue or `false` if the operation should time out. The time between consecutive evaluations of the predicate is specified by the `period` parameter.

Example of a `[TimeoutWithPredicate](sf-TimeoutWithPredicate.md#timeoutwithpredicate)`: 
```cpp
bool run = true;
sf::Sftp::TimeoutWithPredicate timeout([&run]{ return run; }, sf::milliseconds(1));
```
 When passed to an operation, the above `[TimeoutWithPredicate](sf-TimeoutWithPredicate.md#timeoutwithpredicate)` object will keep the operation running as long as `run` is `true`. The condition is checked every 1 millisecond. As soon as `run` is set to `false` the operation will terminate with a `Timeout` result.

Remember that attempting to modify variables from across threads will require proper synchronization using e.g. mutexes or atomics.

Because the filesystem operations will be performed on the remote system, the paths passed to the operations should be valid paths on the remote system. To guarantee portability, generic POSIX paths should be used. These use `/` as the path seperator and `.` to refer to the current directory and `..` to refer to the parent directory.

When logging into the server as a specific user the current directory will be set to the home directory that was specified for that user account. Because it cannot be assumed that the SFTP user is also allowed to log into a shell, changing the current directory from the home directory is not always possible and thus not supported. Thus when specifying paths, it is preferred to always make use of absolute paths when possible. Calling `[getWorkingDirectory()](#getworkingdirectory-1)` will return the current directory as an absolute path. Listing the contents of a directory whose path is passed as an absolute path will yield directory listing entries whose paths are extentions of the directory's path and thus also absolute paths. The `[resolvePath()](#resolvepath)` function can be used to convert relative paths or paths containing links into absolute paths without links.

Usage example: 
```cpp
// Create a new SFTP client
sf::Sftp sftp;

// Get the address of the server
const auto addresses = sf::Dns::resolve("sftp.myserver.com");

// Check if we have a valid address
if (!addresses.has_value() || addresses->empty())
{
    // Handle no valid address...
}

// Connect to the server
sf::Sftp::Result result = sftp.connect(addresses->front());
if (result.isOk())
    std::cout << "Connected" << std::endl;

// Check session information and verify server
std::optional<sf::Sftp::SessionInfo> info = sftp.getSessionInfo();
if (info->hostKey.sha256 != expectedSha256)
{
    std::cout << "Server untrusted" << std::endl;
    // Handle untrusted server
}

// Log in
result = sftp.login("sftpuser", "dF6Zm89D");
if (result.isOk())
    std::cout << "Logged in" << std::endl;

// Print the working directory
sf::Sftp::PathResult directory = sftp.getWorkingDirectory();
if (directory.isOk())
    std::cout << "Working directory: " << directory.getPath().string() << std::endl;

// Create a new directory
result = sftp.createDirectory("files");
if (result.isOk())
    std::cout << "Created new directory" << std::endl;

// Upload a text file to this new directory
result = sftp.upload("files/newfile.txt", [](void* data, std::size_t& size)
{
    // In your own code, ensure size is big enough to store your data
    // We skip the check here for simplicity
    std::memcpy(data, "Hello World", 11);
    size = 11;
    return false; // End transfer after this block
});
if (response.isOk())
    std::cout << "File uploaded" << std::endl;

// Rename file
result = sftp.rename("files/newfile.txt", "files/newfile2.txt");
if (result.isOk())
    std::cout << "Renamed file" << std::endl;

// Download a text file from this new directory
std::string text;
result = sftp.download("files/newfile2.txt", [&text](const void* data, std::size_t size)
{
    text.append(static_cast<const char*>(data), size);
    return true; // Continue until all data received
});
if (response.isOk())
    std::cout << "File downloaded: " << text << std::endl;

// Delete file
result = sftp.deleteFile("files/newfile2.txt");
if (result.isOk())
    std::cout << "Deleted file" << std::endl;

// Delete directory
result = sftp.deleteDirectory("files");
if (result.isOk())
    std::cout << "Deleted directory" << std::endl;

// Disconnect from the server (optional)
result = sftp.disconnect();
if (result.isOk())
    std::cout << "Disconnected successfully" << std::endl;
```

## Public Methods

| Return | Name | Description |
|--------|------|-------------|
|  | [`Sftp`](#sftp-1)  | Default constructor. |
|  | [`~Sftp`](#sftp-2)  | Destructor. |
|  | [`Sftp`](#sftp-3)  | Deleted copy constructor. |
| [`Sftp`](#sftp) & | [`operator=`](#operator-63)  | Deleted copy assignment. |
| [`Result`](sf-Sftp-Result.md#result) | [`connect`](#connect-1) `nodiscard` | Connect to the specified SFTP server. |
| [`Result`](sf-Sftp-Result.md#result) | [`disconnect`](#disconnect-1) `nodiscard` | Disconnect the connection with the server. |
| std::optional< [`SessionInfo`](sf-Sftp-SessionInfo.md#sessioninfo) > | [`getSessionInfo`](#getsessioninfo) `const` `nodiscard` | Get SSH session information. |
| [`Result`](sf-Sftp-Result.md#result) | [`login`](#login-2) `nodiscard` | Log in using a username and a password. |
| [`Result`](sf-Sftp-Result.md#result) | [`login`](#login-3) `nodiscard` | Log in using a public/private key pair. |
| [`Result`](sf-Sftp-Result.md#result) | [`login`](#login-4) `nodiscard` | Log in using a public/private key pair. |
| [`PathResult`](sf-Sftp-PathResult.md#pathresult) | [`resolvePath`](#resolvepath) `nodiscard` | Resolve a remote path into an absolute remote path. |
| [`PathResult`](sf-Sftp-PathResult.md#pathresult) | [`getWorkingDirectory`](#getworkingdirectory-1) `nodiscard` | Get the current working directory on the server. |
| [`AttributesResult`](sf-Sftp-AttributesResult.md#attributesresult) | [`getAttributes`](#getattributes) `nodiscard` | Get the attributes of a remote file or directory. |
| [`ListingResult`](sf-Sftp-ListingResult.md#listingresult) | [`getDirectoryListing`](#getdirectorylisting-1) `nodiscard` | Get the contents of the given directory. |
| [`Result`](sf-Sftp-Result.md#result) | [`createDirectory`](#createdirectory-1) `nodiscard` | Create a new directory. |
| [`Result`](sf-Sftp-Result.md#result) | [`deleteDirectory`](#deletedirectory-1) `nodiscard` | Remove an existing directory. |
| [`Result`](sf-Sftp-Result.md#result) | [`rename`](#rename) `nodiscard` | Rename an existing file or directory. |
| [`Result`](sf-Sftp-Result.md#result) | [`deleteFile`](#deletefile-1) `nodiscard` | Remove an existing file. |
| [`Result`](sf-Sftp-Result.md#result) | [`download`](#download-1) `nodiscard` | Download a file from the server. |
| [`Result`](sf-Sftp-Result.md#result) | [`upload`](#upload-1) `nodiscard` | Upload a file to the server. |

---

{#sftp-1}

### Sftp

```cpp
Sftp()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:344

Default constructor.

---

{#sftp-2}

### ~Sftp

```cpp
~Sftp()
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:353

Destructor.

Automatically closes the connection with the server if it is still opened.

---

{#sftp-3}

### Sftp

```cpp
Sftp(const Sftp &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:359

Deleted copy constructor.

---

{#operator-63}

### operator=

```cpp
Sftp & operator=(const Sftp &) = delete
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:365

Deleted copy assignment.

---

{#connect-1}

### connect

`nodiscard`

```cpp
[[nodiscard]] Result connect(IpAddress server, unsigned short port = 22, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:387

Connect to the specified SFTP server.

The port has a default value of 22, which is the standard port used by the SFTP protocol. This function tries to connect to the server so it may take a while to complete, especially if the server is not reachable. To avoid blocking your application for too long, you can use a timeout. The default value, `[Time::Zero](sf-Time.md#zero-1)`, means that the system timeout will be used (which is usually pretty long).

#### Returns
[Result](sf-Sftp-Result.md#result) of the connection attempt

**See also**: `[disconnect](#disconnect-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `server` | [`IpAddress`](sf-IpAddress.md#ipaddress) | Name or address of the SFTP server to connect to |
| `port` | `unsigned short` | Port used for the connection |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#disconnect-1}

### disconnect

`nodiscard`

```cpp
[[nodiscard]] Result disconnect(const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:399

Disconnect the connection with the server.

#### Returns
[Result](sf-Sftp-Result.md#result) of disconnecting the connection with the server

**See also**: `[connect](#connect-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#getsessioninfo}

### getSessionInfo

`const` `nodiscard`

```cpp
[[nodiscard]] std::optional< SessionInfo > getSessionInfo() const
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:431

Get SSH session information.

After connecting to the server and before actually logging in the SSH session information of the underlying connection will be available.

The session information contains among other things the public key identifying the remote host and the connection parameters such as encryption and compression used. The identifiers used follow the RFC 4253 specification.

If the session information is not available `std::nullopt` will be returned.

Because SSH was developed as a parallel standard to SSL/TLS and automatic host certificate verification wasn't widespread at the time, relying on the user to check the authenticity of the host key was the typical method used to verify that they were connecting to the legitimate host, assuming the private key of the remote host was not compromised.

If connection security is a high priority, examining the parameters and aborting the connection if any weak algorithms are used is also possible.

#### Returns
SSH session information or `std::nullopt` if it is not available

---

{#login-2}

### login

`nodiscard`

```cpp
[[nodiscard]] Result login(std::string_view name, std::string_view password, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:446

Log in using a username and a password.

Logging in is mandatory after connecting to the server. Users that are not logged in cannot perform any operation.

#### Returns
[Result](sf-Sftp-Result.md#result) of attempting to log in to the server

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `std::string_view` | User name |
| `password` | `std::string_view` | Password |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#login-3}

### login

`nodiscard`

```cpp
[[nodiscard]] Result login(std::string_view name, const char * publicKeyData, std::size_t publicKeyLength, const char * privateKeyData, std::size_t privateKeyLength, const char * privateKeyPassphrase = "", const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:485

Log in using a public/private key pair.

Logging in is mandatory after connecting to the server. Users that are not logged in cannot perform any operation.

This overload allows logging into the SFTP server using public key authentication.

The public and private key data should be provided in PEM format. PEM encoded data can be easily recognized by their `-----BEGIN ............-----` header and `-----END ............-----` footer.

Even though it is technically possible to derive the public key from the private key, due to backend limitations, providing a pre-generated public key as well is necessary for this function to be able to succeed.

If the private key is protected by a passphrase the passphrase can be provided as a NULL terminated string. If the private key is not protected by a passphrase the passphrase should be set to the empty string.

#### Returns
[Result](sf-Sftp-Result.md#result) of attempting to log in to the server

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `std::string_view` | User name |
| `publicKeyData` | `const char *` | Public key data |
| `publicKeyLength` | `std::size_t` | Public key data length |
| `privateKeyData` | `const char *` | Private key data |
| `privateKeyLength` | `std::size_t` | Private key data length |
| `privateKeyPassphrase` | `const char *` | Private key passphrase, NULL terminated |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#login-4}

### login

`nodiscard`

```cpp
[[nodiscard]] Result login(std::string_view name, std::string_view publicKeyData, std::string_view privateKeyData, std::string_view privateKeyPassphrase = {}, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:526

Log in using a public/private key pair.

Logging in is mandatory after connecting to the server. Users that are not logged in cannot perform any operation.

This overload allows logging into the SFTP server using public key authentication.

The public and private key data should be provided in PEM format. PEM encoded data can be easily recognized by their `-----BEGIN ............-----` header and `-----END ............-----` footer.

Even though it is technically possible to derive the public key from the private key, due to backend limitations, providing a pre-generated public key as well is necessary for this function to be able to succeed.

If the private key is protected by a passphrase the passphrase can be provided as a NULL terminated string. If the private key is not protected by a passphrase the passphrase should be set to the empty string.

#### Returns
[Result](sf-Sftp-Result.md#result) of attempting to log in to the server

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | `std::string_view` | User name |
| `publicKeyData` | `std::string_view` | Public key data |
| `privateKeyData` | `std::string_view` | Private key data |
| `privateKeyPassphrase` | `std::string_view` | Private key passphrase |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#resolvepath}

### resolvePath

`nodiscard`

```cpp
[[nodiscard]] PathResult resolvePath(const std::filesystem::path & path, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:554

Resolve a remote path into an absolute remote path.

Paths can contain links and other reserved path identifiers such as . and .. referring to the current directory and parent directory respectively.

When determining the absolute path, which does not contain links or . or .. is necessary, this function can be used.

Resolving "." will return the absolute path to the current working directory of the user after logging in to the SFTP server.

#### Returns
[Result](sf-Sftp-Result.md#result) of converting the path into an absolute path

**See also**: `[getWorkingDirectory](#getworkingdirectory-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const std::filesystem::path &` | Path to convert into an absolute path |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#getworkingdirectory-1}

### getWorkingDirectory

`nodiscard`

```cpp
[[nodiscard]] PathResult getWorkingDirectory(const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:568

Get the current working directory on the server.

This is an alias for calling `resolvePath(".")`.

#### Returns
[Result](sf-Sftp-Result.md#result) of getting the current working directory

**See also**: `[resolvePath](#resolvepath)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#getattributes}

### getAttributes

`nodiscard`

```cpp
[[nodiscard]] AttributesResult getAttributes(const std::filesystem::path & path, bool followLinks = true, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:590

Get the attributes of a remote file or directory.

Depending on whether `path` refers to a file or directory, the attributes can contain e.g. the type of file, the file owner, group, file size, modification and access times.

If links are not to be followed, `followLinks` can be set to `false`. In this case the attributes of the link itself will be returned.

#### Returns
[Result](sf-Sftp-Result.md#result) of getting the attributes

**See also**: `[getDirectoryListing](#getdirectorylisting-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const std::filesystem::path &` | Path to the remote file or directory whose attributes to get |
| `followLinks` | `bool` | `true` to follow links, `false` to return attributes of the link itself |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#getdirectorylisting-1}

### getDirectoryListing

`nodiscard`

```cpp
[[nodiscard]] ListingResult getDirectoryListing(const std::filesystem::path & path, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:608

Get the contents of the given directory.

This function retrieves the sub-directories and files contained in the given directory. It is not recursive.

#### Returns
[Result](sf-Sftp-Result.md#result) of getting the contents of the given directory

**See also**: `[getAttributes](#getattributes)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const std::filesystem::path &` | Path of the directory whose contents to list |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#createdirectory-1}

### createDirectory

`nodiscard`

```cpp
[[nodiscard]] Result createDirectory(const std::filesystem::path & path, std::filesystem::perms permissions = (std::filesystem::perms::owner_all|std::filesystem::perms::group_read|std::filesystem::perms::group_exec|std::filesystem::perms::others_read|std::filesystem::perms::others_exec), const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:629

Create a new directory.

The new directory is created as a child of the current working directory.

The default permissions value is equivalent to `rwxr-xr-x` or 0755 in octal notation.

#### Returns
[Result](sf-Sftp-Result.md#result) of creating the directory

**See also**: `[deleteDirectory](#deletedirectory-1)`, `[rename](#rename)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const std::filesystem::path &` | Path of the directory to create |
| `permissions` | `std::filesystem::perms` | Permissions of the directory to create |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#deletedirectory-1}

### deleteDirectory

`nodiscard`

```cpp
[[nodiscard]] Result deleteDirectory(const std::filesystem::path & path, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:650

Remove an existing directory.

Use this function with caution, the directory will be removed permanently!

#### Returns
[Result](sf-Sftp-Result.md#result) of removing the directory

**See also**: `[createDirectory](#createdirectory-1)`, `[rename](#rename)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const std::filesystem::path &` | Path of the directory to remove |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#rename}

### rename

`nodiscard`

```cpp
[[nodiscard]] Result rename(const std::filesystem::path & oldPath, const std::filesystem::path & newPath, bool overwrite = false, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:674

Rename an existing file or directory.

In POSIX renaming and moving and synonymous. If you want to move a file or directory from one place to another you rename it from an old to a new path.

If a file exists at the specified new path, depending on whether `ovewrite` is set to true, the rename operation will overwrite it or not. If a directory is being moved, the new path must either not point to non-existant directory or a directory that is empty. Non-empty directories cannot be overwritten by this operation.

#### Returns
[Result](sf-Sftp-Result.md#result) of the operation

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `oldPath` | `const std::filesystem::path &` | Old path to the file or directory |
| `newPath` | `const std::filesystem::path &` | New path to the file or directory |
| `overwrite` | `bool` | Set to `true` to allow overwriting a file that exists at `newPath` |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#deletefile-1}

### deleteFile

`nodiscard`

```cpp
[[nodiscard]] Result deleteFile(const std::filesystem::path & path, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:693

Remove an existing file.

Use this function with caution, the file will be removed permanently!

#### Returns
[Result](sf-Sftp-Result.md#result) of removing the file

**See also**: `[rename](#rename)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | `const std::filesystem::path &` | Path to the file to remove |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#download-1}

### download

`nodiscard`

```cpp
[[nodiscard]] Result download(const std::filesystem::path & remotePath, const std::function< bool(const void *data, std::size_t size)> & callback, std::uint64_t offset = 0, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:731

Download a file from the server.

This function retrieves the data in the file at the remote path.

The file data is transferred in sequential blocks. For every block of data transferred, the provided callback is called. The callback is passed a pointer to a data block and the size of the data contained in the current block. This size can change over time so it is important to always check the size value to know how much data is actually available. The callback should return `true` to indicate to the `download` function that it should continue to transfer data. If the data transfer should be aborted earlier, `false` can be returned from the callback.

The function returns once all the data in the remote file has been transferred or an error occurs or the function times out.

If reading from the remote file should not start at the beginning of the file, you can specify an offset in bytes at which reading should start.

#### Returns
[Result](sf-Sftp-Result.md#result) of downloading the file

**See also**: `[upload](#upload-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `remotePath` | `const std::filesystem::path &` | Path of the remote file whose data to download |
| `callback` | `const std::function< bool(const void *data, std::size_t size)> &` | Callback to be called for every available data block |
| `offset` | `std::uint64_t` | Byte offset into the remote file at which reading should start |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

---

{#upload-1}

### upload

`nodiscard`

```cpp
[[nodiscard]] Result upload(const std::filesystem::path & remotePath, const std::function< bool(void *data, std::size_t &size)> & callback, std::filesystem::perms permissions = (std::filesystem::perms::owner_read|std::filesystem::perms::owner_write|std::filesystem::perms::group_read|std::filesystem::perms::others_read), bool truncate = true, bool append = false, std::uint64_t offset = 0, const TimeoutWithPredicate & timeout = Time::Zero)
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:791

Upload a file to the server.

This function writes data into a file at the remote path.

The file data is transferred in sequential blocks. Every time the function wants to send a new block of data the provided callback is called. The callback is passed a pointer to a data block and a reference to the size of the data block. Data to be sent should be copied into the data block using e.g. `std::memcpy` and the size value set to the actual number of bytes copied into the data block. The size of the block can change over time so it is important to check the size value that is passed to the callback to know how many bytes can actually be copied into the data block. The callback should return `true` to indicate to the `upload` function that it should continue to transfer data. Once the data transfer should be stopped e.g. because there is no more data left to send, `false` can be returned from the callback.

The function returns once all the data has been sent or an error occurs or the function times out.

If a file does not exist at the remote path yet, it will be created with the provided permissions.

If a file already exists at the remote path, setting `truncate` to `true` will truncate the existing file i.e. delete all pre-existing data before starting to write the new data into the file.

Setting `append` to `true` will append to a file if it already exists.

If writing to the remote file should not start at the beginning of the file, you can specify an offset in bytes at which writing should start.

The default permissions value is equivalent to `rw-r--r--` or 0644 in octal notation.

#### Returns
[Result](sf-Sftp-Result.md#result) of uploading the file

**See also**: `[download](#download-1)`

#### Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `remotePath` | `const std::filesystem::path &` | Path of the remote file in which to upload the data |
| `callback` | `const std::function< bool(void *data, std::size_t &size)> &` | Callback to be called for every available data block |
| `permissions` | `std::filesystem::perms` | Permissions of the remote file if it has to be created |
| `truncate` | `bool` | Set to `true` to truncate the remote file if it already exists |
| `append` | `bool` | Set to `true` to append to the remote file if it already exists |
| `offset` | `std::uint64_t` | Byte offset into the remote file at which writing should start |
| `timeout` | const [`TimeoutWithPredicate`](sf-TimeoutWithPredicate.md#timeoutwithpredicate) & | Maximum time to wait, optionally a predicate can be provided for more fine-grained control |

## Private Attributes

| Return | Name | Description |
|--------|------|-------------|
| `std::unique_ptr< Impl >` | [`m_impl`](#m_impl-6)  | Implementation. |

---

{#m_impl-6}

### m_impl

```cpp
std::unique_ptr< Impl > m_impl
```

Defined in /home/jared/.local/share/nvim/docs/sfml/master/include/SFML/Network/Sftp.hpp:806

Implementation.

