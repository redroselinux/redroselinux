<h1 align="center">
  <img width="32" height="32" alt="image" src="https://redroselinux.org/assets/redrose-logo-transparent.png" />
  Redrose Linux
  
  ![Stars](https://img.shields.io/github/stars/redroselinux/redroselinux?style=flat)
  ![GitHub downloads](https://img.shields.io/github/downloads/redroselinux/redroselinux/total?logo=github)
</h1>

An independent x86_64 systemd-free EU-based Linux distribution. 

Have you ever found yourself using confusing distributions? Redrose Linux takes features from NixOS and Arch (mainly) and turns them into an easy-to-use independent systemd-free system just for developers. 

We currently use the runit init system (which we customized) and the nullinitrd initramfs generator (originally from NULL GNU/Linux). This might change in the future.

>[!CAUTION]
> Redrose Linux is under active development and is **not ready for daily use**.

- **Docs**: https://docs.redroselinux.org/
- **Website**: https://redroselinux.org/
- **Dev branch**: develop


<div align="center">
<img width="400" alt="image" src="https://github.com/user-attachments/assets/b7489a4d-6f4f-4fa3-a69c-8bbe7d8f4c5d" /> 
<img width="400" alt="image" src="https://github.com/user-attachments/assets/7dcd2e78-5064-46ec-aab2-da11426c7417" />
</div>

## Download

We made a launcher to launch Redrose in QEMU. To run it, paste this into your terminal:
```bash
curl https://redroselinux.org/vm_launcher.sh | sh
```
**In case it says "invalid magic number" when booting, try clearing your `~/.cache` and re-running.** This usually happens when your download is corrupted.

This uses the latest **release**.

Otherwise, download from the Releases tab.

### Docker image

https://docs.redroselinux.org/#/docker-img

## Hardware Requirements

**This was tested on alpha 0.2** 

The installer can run on a potato, litterally, it needs ~131.200005M RAM. I did not do any tests for CPU.

## Development

Simply run:

```
make
```

This does all the magic, and even runs it in a VM.

>[!IMPORTANT]
> `-j` does not work with our Makefile!

>[!NOTE]
> We will make a build system for ISOs after alpha-0.7 releases. 

>[!TIP]
> You can use `GZIP_PATH` to set the gzip command, for example:
> `make GZIP_PATH="pigz -p 4000"` 
 
## Build a Docker image

As mentioned in the Docker image section.

---

<div align=center>
Wilted rose:<br>
<img width="400" alt="image" src="https://github.com/user-attachments/assets/dcd60471-917b-49dd-a7a1-b658e9207fb2" />
</div>

## Other components

- **Car** (package manager): https://github.com/redroselinux/car
- **news-reader**: https://github.com/redroselinux/news-reader
- **Fuel** (package builder): https://github.com/redroselinux/fuel
- **redrose-runit**: https://github.com/redroselinux/redrose-runit
- **Website source code**: https://github.com/redroselinux/redroselinux.github.io
  deployed to both the new .org site and the old .is-a.software

## Contact

- **Email**: admin@redroselinux.org

## Random stats no one reads

[![Star History Chart](https://api.star-history.com/svg?repos=redroselinux/redroselinux&type=date&legend=top-left)](https://www.star-history.com/#redroselinux/redroselinux&type=date&legend=top-left)
