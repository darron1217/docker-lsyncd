Lsyncd for docker 
======================================
Description
-----------
Lsyncd (Live Syncing (Mirror) Daemon) is a tool that watches a local directory trees event monitor interface (inotify or fsevents).
It aggregates and combines events for a few seconds and then spawns one (or more) process(es) to synchronize the changes. 

This docker image was build in order to increase performance of docker mounted folders in non Linux environment. Currently, all Docker solutions in non Linux
suffers from very bad reading / writing performance in mounted folders, whether they use vboxfs, NFS, whatever...

This docker image helps in the process of creating a replica **in container** of the directory mounted.

License: [GPLv2](http://www.fsf.org/licensing/licenses/info/GPLv2.html) or any later GPL version.

Prerequesties
-------------

The mounted folders in the container must be abled to emit `inotify` or `fsevents`. Traditional VM mounts doesn't support this. You can have a look at
the `dinghy` project that includes a way to support this in the virtual machine with their daemon `fsevent_to_vm`.

How to use
-----------

Here is an example on how to use it with a docker-compose file. The scenario illustrates a way to sync source code in real-time from the host inside
the container and get the output generated by the execution of the code back to the host.
```
  version: '3.6'
  
  services:
    app:
      volumes:
        - ./src:/src.mounted
        - ./output:/output.mounted
        - app_src:/src
        - app_output:/output
  
    lsyncd:
      image: darron1217/lsyncd
      environment:
        - SOURCES=/src.mounted:/output
        - DESTINATIONS=/src:/output.mounted
        - EXCLUDES=.git:.svn
        - CHOWN=0:0
        - MAXIMUM_INOTIFY_WATCHES=500000
      privileged: true

  volumes:
    app_src:
    app_output:
```
        
The local folders `./src` and `./output` are mounted in the `app` container as respectively `/src.mounted` and `/output.mounted`. 
The app container inits also two aditionnal volumes `app_src` and `app_output`.
 
The lsyncd container is configured to provides a real-time sync between the `/src.mounted` to the `/src` folder and the `/output` to
the `/ouptut.mounted`.

### Two-way sync

**Caution! Two-way sync is experimental. It may not work well with large files.**

On Windows, this function works under `Docker Desktop v2.2.0.5`.

Related issue : https://github.com/docker/for-win/issues/5955
```
version: '3.6'

  web:
    volumes:
      - web:/var/www/html

  lsyncd:
    image: darron1217/docker-lsyncd
    environment:
      - SOURCES=/src.mounted:/output
      - DESTINATIONS=/src:/output.mounted
      - EXCLUDES=.git:.github:.idea:.composer:node_modules:/vendor
      - MAXIMUM_INOTIFY_WATCHES=500000
      - DELAY=3
    volumes:
      - .:/src.mounted
      - .:/output.mounted
      - web:/src
      - web:/output
    privileged: true

  volumes:
    web:
```

### Configuration

Configuration is done through environment variables:

- `SOURCES` lists the source folder from which the data is synced. Multiple sources folders can de listed by separating them with the `:` delimiter.
- `DESTINATIONS` lists the destination folder where data will be copied. You must provide a destination folder for each source folder.
- `EXCLUDES` add the ability to add `rsync` exclude patterns.
- `CHOWN` add the ability to add `rsync` chown config.
- `MAXIMUM_INOTIFY_WATCHES` add the ability to extend max inotify watchers (`privileged: true` must be set).
- `DELAY` add the ability to modify sync delay. (Default 1)

Disclaimer
----------
Besides the usual disclaimer in the license, we want to specifically emphasize that the authors, and any organizations the authors are associated with, can not be held responsible for data-loss caused by possible malfunctions of Lsyncd.
