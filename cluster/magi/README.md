# Setup of Magi

## Hardware summary
- **Networks (3 total):**
  1. `bond0` (eth0 + eth1): Internet access/egress + LB services
  2. `eth2`: in-cluster communication (main CNI), isolated network
  3. `eth3`: storage networking (Longhorn via Multus)

- **Disks (per node):**
  - 1x <512GB SSD for OS
  - 2x 1TB SSDs in RAID 0 (stripe) for max capacity  
    (replication handled at cluster level)

---

## Network plan

### Node: Baltasar
#### Bonded 2.5Gbps NICs
- **bond0** (eth0 + eth1):
  - `fd7a:6e5b:cafe:10::6/64`
  - `10.1.0.6/22`

#### 10Gbps NICs (no bridges)
- **eth2**:
  - `fd7a:6e5b:beff::6/64`
  - `10.255.100.6/24`

- **eth3**:
  - `fd7a:6e5b:befe::6/64`
  - `10.255.200.6/24`

## Node: Casper
#### Bonded 2.5Gbps NICs
- **bond0** (eth0 + eth1):
  - `fd7a:6e5b:cafe:10::7/64`
  - `10.1.0.7/22`

#### 10Gbps NICs (no bridges)
- **eth2**:
  - `fd7a:6e5b:beff::7/64`
  - `10.255.100.7/24`

- **eth3**:
  - `fd7a:6e5b:befe::7/64`
  - `10.255.200.7/24`

## Node: Melchior
#### Bonded 2.5Gbps NICs
- **bond0** (eth0 + eth1):
  - `fd7a:6e5b:cafe:10::8/64`
  - `10.1.0.8/22`

#### 10Gbps NICs (no bridges)
- **eth2**:
  - `fd7a:6e5b:beff::8/64`
  - `10.255.100.8/24`

- **eth3**:
  - `fd7a:6e5b:befe::8/64`
  - `10.255.200.8/24`

---

## CNI (Cilium)
- **Devices:**
  - `bond0` - LoadBalancer/BGP traffic (external)
  - `eth2` - Pod-to-pod native routing (internal)
- **LB IP pools**
  - **public:** `fd7a:6e5b:cafe:10:1::1/120`, `10.1.1.0/24`
  - **private:** `fd7a:6e5b:cafe:10:2::1/120`, `10.1.2.0/24`

- **BGP mode**
  - **Local ASN:** `64513`
  - **Peers (OPNsense HA):**
    - `fd7a:6e5b:cafe:10::2`, `10.1.0.2` (ASN `64512`)
    - `fd7a:6e5b:cafe:10::3`, `10.1.0.3` (ASN `64512`)

---

## Bootstrap Flux
Create an age key locally:
```
age-keygen -o .age-key.txt
```

Bootstrap Flux (example: `magi`):
```
flux bootstrap github \
  --components-extra=image-reflector-controller,image-automation-controller \
  --path cluster/magi \
  --branch main \
  --owner=vbalexr \
  --repository=k8s \
  --personal
```

Add SOPS key to the cluster (namespace: `flux-system`):
```
kubectl -n flux-system create secret generic sops-age \
  --from-file=identity.agekey=.age-key.txt
```

---

## Debug reference

### Quick checks
- **Nodes + status**
  ```
  kubectl get nodes -o wide
  ```
- **Cilium status**
  ```
  kubectl -n kube-system exec -it ds/cilium -- cilium status
  ```
- **Cilium BGP status**
  ```
  kubectl -n kube-system exec -it ds/cilium -- cilium bgp peers
  ```

### LoadBalancer IP allocation
- **Services**
  ```
  kubectl get svc -A | grep LoadBalancer
  ```

### Network diagnostics (node)
- **Interfaces + routes**
  ```
  ip -br a
  ip -6 r
  ip r
  ```

### Storage (Longhorn)
- **System status**
  ```
  kubectl -n longhorn-system get pods
  kubectl -n longhorn-system get nodes
  ```

### Flux health
```
flux get kustomizations -A
flux get helmreleases -A
```