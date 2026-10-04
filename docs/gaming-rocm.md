# AMD graphics, gaming and compute

## Hyprland uses the RX 6600 XT

`graphics-amd.nix` loads AMDGPU early and enables Mesa graphics plus 32-bit support.
Your Intel i7-12700F has no integrated GPU, so the Radeon is the display GPU. No proprietary
AMD driver download, ROCm environment variable or hardcoded `/dev/dri/card0` is needed.

```bash
lspci -k | grep -A3 -E 'VGA|Display'
hyprctl systeminfo
vulkaninfo --summary
glxinfo -B
vainfo
```

Expect the kernel driver `amdgpu` and a Radeon/RADV renderer, not `llvmpipe`/software
rendering. `glxinfo` checks the XWayland/OpenGL path; `hyprctl systeminfo` checks compositor
information and `vulkaninfo` checks Vulkan. Test video decoding separately with `vainfo`.
Hardware acceleration is not established merely by a successful Nix build.

## Steam and Proton

Steam runs through the NixOS module with its needed runtime libraries. After login:

1. Open Steam, sign in and install a small game.
2. Under Steam's compatibility settings, enable Steam Play where appropriate.
3. Choose the Valve Proton release for a game's Compatibility setting, or the declared
   Proton-GE build when a title specifically benefits from it.
4. Start with the game's default launch options. Optional overlays/tuning can be enabled
   per game with `mangohud gamemoderun %command%`.

Do not force global AMDVLK, software-rendering or experimental ROCm settings into Steam.
Some multiplayer anti-cheat systems do not support Proton; the desktop configuration
cannot fix that. Steam downloads and Valve's managed Proton versions are mutable data.
The packaged Proton-GE version is pinned by the flake; game updates and saves are not.

Keep a Linux-native game library on the encrypted ext4 root for this initial setup. The
NVMe NTFS partitions are preserved but not automatically mounted as a Proton library.
Filesystem permissions and NTFS compatibility require a separate deliberate setup.
Remote Play/dedicated-server firewall ports are not opened by default.

## ROCm and the RX 6600 XT

The RX 6600 XT is **Navi 23 / gfx1032**. AMD's Radeon Linux support matrices do not establish
it as a supported ROCm compute target for this setup. Installing HIP/ROCm tooling is not
a promise that PyTorch, another framework, or a precompiled kernel supports this GPU.
NixOS itself also differs from AMD's officially validated distribution combinations.

References:

- [AMD GPU architecture specifications](https://rocm.docs.amd.com/en/docs-6.1.0/reference/gpu-arch-specs.html)
- [AMD current ROCm compatibility matrix](https://rocm.docs.amd.com/en/latest/compatibility/compatibility-matrix.html)
- [AMD Radeon Linux system requirements](https://rocm.docs.amd.com/projects/radeon/en/latest/docs/compatibility/native_linux/native_linux_compatibility.html)

`enableRocm = true` installs `rocminfo`, `rocm-smi` and `hipcc`. The user has `render` and
`video` group access; the kernel should expose `/dev/kfd`.

```bash
id
ls -l /dev/kfd /dev/dri/renderD*
rocminfo
rocm-smi
hipcc --version
```

GPU discovery alone does not prove a workload runs. Test the framework you actually plan
to use with a small allocation and kernel, checking that it runs on the GPU rather than
silently falling back to CPU.

An often-discussed experimental workaround is a **per-command**
`HSA_OVERRIDE_GFX_VERSION=10.3.0` for certain gfx1032 workloads. It can produce errors or
incorrect results and does not supply missing compiled kernels. It is not enabled in
this configuration. Only investigate it for a specific framework/version, compare
numerical results, and never export it globally into the desktop/gaming session.

For a workload without compatible ROCm binaries, evaluate that application's supported
Vulkan backend or CPU fallback. To remove the optional ROCm tools and their sizeable
closure, set `enableRocm = false` and rebuild; AMD desktop/gaming acceleration remains.

## vm-curator

The upstream vm-curator flake is pinned and follows the same Nixpkgs input. QEMU is
installed, `kvm-intel` loads on this CPU, and the user belongs to `kvm`.

```bash
ls -l /dev/kvm
vm-curator --help
qemu-system-x86_64 --version
```

Enable Intel virtualization in firmware if `/dev/kvm` is missing. VM disk images and
ISO files belong outside Git and need independent backups. No VM is started at login,
and no libvirt service or bridged networking is enabled merely to install this TUI.
