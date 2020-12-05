---
title: js fs api
date: 2020-10-15
private: true
---
# js fs api
https://web.dev/file-system-access/

# file
## read file

    let fileHandle;
    butOpenFile.addEventListener('click', async () => {
        [fileHandle] = await window.showOpenFilePicker();
        const file = await fileHandle.getFile(); // new File
        const contents = await file.text();
        textArea.value = contents;
    });

## write file

    async function getNewFileHandle() {
      const options = {
        types: [
          {
            description: 'Text Files',
            accept: {
              'text/plain': ['.txt'],
            },
          },
        ],
      };
      const handle = await window.showSaveFilePicker(opts);
      return handle;
    }

    async function writeFile(fileHandle, contents) {
        // Create a FileSystemWritableFileStream to write to.
        const writable = await fileHandle.createWritable();
        // Write the contents of the file to the stream.
        await writable.write(contents);
        // Close the file and write the contents to disk.
        await writable.close();
    }

# directory
## iterator directory
    const dirHandle = await window.showDirectoryPicker();
    for await (const entry of dirHandle.values()) {
        console.log(entry.kind, entry.name);
    }

recursive:

    var dirHandle = await window.showDirectoryPicker();
    for await (const subdirHandle of dirHandle.values()) {
        if(subdirHandle.kind=="directory"){
            for await (const entry of subdirHandle.values()) {
                console.log(entry.kind, entry.name);
                if(entry.kind=="file"){
                    console.log(await (await entry.getFile()).text());
                }
            }
        }
    }

## Creating or accessing files and folders in a directory 
    // In an existing directory, create a new directory named "My Documents".
    const newDirectoryHandle = await dirHandle.getDirectoryHandle('My Documents', { create: true, });

    // In this new directory, create a file named "My Notes.txt".
    const newFileHandle = await newDirectoryHandle.getFileHandle('My Notes.txt', { create: true });

## Resolving the path of an item in a directory #
    // Resolve the path of the previously created file called "My Notes.txt".
    const path = await newDirectoryHandle.resolve(newFileHandle);
    // `path` is now ["My Documents", "My Notes.txt"]

## Deleting files and folders in a directory #
    // Delete a file.
    await directoryHandle.removeEntry('Abandoned Masterplan.txt');
    // Recursively delete a folder.
    await directoryHandle.removeEntry('Old Stuff', { recursive: true })

## Accessing the origin-private file system #
> Essentially: what you create with this API, do not expect to find it 1:1 somewhere on the hard disk. 
The origin-private file system is a storage endpoint that, as the name suggests, is private to the origin of the page.

    onst root = await navigator.storage.getDirectory();
    // Create a new file handle.
    const fileHandle = await root.getFileHandle('Untitled.txt', { create: true });
    // Create a new directory handle.
    const dirHandle = await root.getDirectoryHandle('New Folder', { create: true });
    // Recursively remove a directory.
    await root.removeEntry('Old Stuff', { recursive: true });