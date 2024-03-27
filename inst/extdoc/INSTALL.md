
# Drivers




Check you have a GPU

```
lspci -kv
```

## Nvidia

See the [Nvidia installation guide](hhttps://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#network-repo-installation-for-ubuntu)


If you're lucky, you 


```
sudo apt install nvidia-driver-535
sudo reboot
sudo apt-get install cuda
```

Check you've installed the drivers correctly.

```
nvidia-smi
```

Install openCL

```
sudo apt install -y nvidia-opencl-dev clinfo
```

check openCL is working

```
clinfo
```


## AMD

see the 

[AMD rocm install guide](https://rocm.docs.amd.com/projects/install-on-linux/en/latest/tutorial/quick-start.html)


```
sudo apt install amdgpu-dkms
sudo apt install rocm
sudo reboot
```


```
/opt/rocm/bin/rocm-smi
```

```
/opt/rocm/bin/clinfo
```


## Amazon AWS

- `g3s.xlarge`
- ubuntu

Make sure the software is up to date

```
sudo apt update
sudo apt dist-upgrade
sudo reboot
```

Install a version of the kernel with the DRM module

```
sudo apt-get install -y linux-headers-virtual linux-source linux-image-extra-virtual
sudo reboot
```

Set up the nvidia software repository
```
wget -O /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i /tmp/cuda-keyring.deb
sudo apt update
```

Install cuda, which is sufficient (but much more than necessary)

```
sudo apt install -y cuda
sudo reboot
```

Check the driver is working

```
nvidia-smi
```

Install openCL

```
sudo apt install -y nvidia-opencl-dev clinfo
sudo apt clean
```

Check openCL is working

```
clinfo
```

## Compute Canada Cloud

- `g1-8gb-c4-22gb`
-  ubuntu


Update and reboot

```
sudo apt update
sudo apt dist-upgrade
sudo reboot
```

repository for GPU drivers

```
wget -O /tmp/arbutus-cloud-repo_all.deb http://repo.arbutus.cloud.computecanada.ca/pulp/deb/ubuntu22/pool/main/arbutus-cloud-repo_0.1_all.deb
sudo dpkg -i /tmp/arbutus-cloud-repo_all.deb 
```

install drivers

```
sudo apt --yes install nvidia-vgpu-kmod nvidia-vgpu-tools nvidia-vgpu-gridd
sudo reboot
```

Check the driver is working

```
nvidia-smi
```

Install openCL

```
sudo apt-get install --yes opencl-headers clinfo ocl-icd-opencl-dev 
```

Check openCL is working

```
clinfo
```



# R and packages

On Ubuntu

R repositories

```
sudo add-apt-repository --yes "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | sudo tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
sudo add-apt-repository --yes ppa:c2d4u.team/c2d4u4.0+
```

Install R

```
sudo apt --yes install r-cran-devtools r-cran-rcppeigen r-cran-bh r-cran-testthat r-cran-knitr r-cran-assertive
sudo apt-get clean
```

Set up some files for R, including a personal library.  

```
mkdir ~/.R 
echo 'MAKEFLAGS = -j4' > ~/.R/Makevars
R -e 'dir.create(Sys.getenv("R_LIBS_USER"), recursive = TRUE)'
```

Install the GPU packages!

```
devtools::install_github("eborgnine/gpuR")
devtools::install_github("ruoyongxu/clrng")
 ```

