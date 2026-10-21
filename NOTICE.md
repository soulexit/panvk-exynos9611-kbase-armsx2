# Notices

This repository packages a Vulkan driver built from Mesa and
[`JimVulkan/mali-panvk`](https://github.com/JimVulkan/mali-panvk). The driver keeps its own license
headers and the release package carries the base tree's `NOTICE.txt` where applicable.

## Driver

- Mesa: https://mesa3d.org/ — MIT and per-file licenses.
- Panfrost/PanVK: https://docs.mesa3d.org/drivers/panfrost.html
- JimVulkan/mali-panvk: https://github.com/JimVulkan/mali-panvk — MIT for the changes, pinned at
  commit `fb3b49d016544c19d83e558462f2d29470e77c28`.

The driver is built and tested in the sister repository
[`panvk-exynos9611-kbase-termux`](https://github.com/soulexit/panvk-exynos9611-kbase-termux).

## ARMSX2

ARMSX2 is a separate project with its own license and its own AdrenoTools integration. This
repository only produces a zip in the format its importer accepts (`meta.json` +
`libvulkan_freedreno.so` at the root). It does not modify or redistribute ARMSX2.

The `libvulkan_freedreno.so` file name is a convention inherited from Adreno/Turnip drivers; the
binary in this package is PanVK, not freedreno.

## Trademarks

Arm and Mali are trademarks of Arm Limited. Samsung, Galaxy and Exynos are trademarks of Samsung
Electronics. ARMSX2 is a project of its respective authors. This project is not affiliated with or
endorsed by any of them.
