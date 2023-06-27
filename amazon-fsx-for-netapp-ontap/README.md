# Amazon FSx For NetApp OnTap
# Amazon FSx for NetApp ONTAP Storage Workshop


**Commands**

```bash
volume snapshot show

snapshot policy show -policy default

job schedule cron show

volume snapshot create -vserver svm01-primary -volume vol1_primary -snapshot vol1_primary_FSxOntapWorkshop -comment "Manual Snapshot created for FSx Workshop"   # Create manual snapshot

volume snapshot show vol1_primary   # Show snapshot for only vol1_primary

volume show vol1_primary -fields percent-snapshot-space,snapshot-space-used

volume show -volume vol1_primary -fields snapdir-access

vserver nfs show -vserver svm01-primary -fields v3-hide-snapshot

vserver nfs show -vserver sinanju -fields v3-hide-snapshot


cd /netapp/test/.snapshot/vol1_primary_FSxOntapWorkshop2

cat /netapp/test/.snapshot/vol1_primary_FSxOntapWorkshop2/multiprotocol-demo.txt    ## The directory .snapshot may not be visible, but can still be accessible, see article below

volume show -volume vol1_primary -fields security-style



jobName=$(echo $(uuidgen) | grep -o ".\{6\}$")
count=10
threads=36
blockSize=16M
blockCount=8

mkdir /netapp/128MB
seq 1 ${count} | parallel --will-cite -j ${threads} time dd if=/dev/zero of=/netapp/128MB/dd-${jobName}-{} bs=${blockSize} count=${blockCount}


vol snapshot show -vol vol1_primary

volume clone create -vserver svm01-primary -flexclone vol1_primary_clone1 -parent-volume vol1_primary   # Clone volume using flexclone

volume clone show

volume mount -vserver svm01-primary -volume vol1_primary_clone1 -junction-path /vol1_primary_clone1       # Create junction path for the clone volume

# check space usage between the flexclone and source volumes
volume show -vserver svm01-primary -volume vol1_primary -fields size,used,available,percent-used,physical-used,physical-used-percent

volume show -vserver svm01-primary -volume vol1_primary_clone1 -fields size,used,available,percent-used,physical-used,physical-used-percent


sudo mkdir /clonedir

sudo mount -t nfs svm-07d55895f47cb939a.fs-0404657b49f2c75c8.fsx.us-east-2.amazonaws.com:/vol1_primary_clone1 /clonedir

mount | grep clonedir

sudo chown ssm-user:ssm-user /clonedir

ls -lt /netapp /clonedir/       # check the two directory 

echo "Amazon FSx for NetApp ONTAP workshop - New file on Cloned Volume" >> /clonedir/clone.txt

jobName=$(echo $(uuidgen) | grep -o ".\{6\}$")
count=1
threads=1
blockSize=16M
blockCount=8

seq 1 ${count} | parallel --will-cite -j ${threads} time dd if=/dev/zero of=/clonedir/128MB/dd-${jobName}-{} bs=${blockSize} count=${blockCount}


ls -lt /netapp /clonedir/
df -h /netapp /clonedir/


volume show -vserver svm01-primary -volume vol1_primary -fields size,used,available,percent-used,physical-used,physical-used-percent

volume show -vserver svm01-primary -volume vol1_primary_clone1 -fields size,used,available,percent-used,physical-used,physical-used-percent

volume efficiency show

volume efficiency show -vserver svm01-primary -volume vol1_primary

volume show -vserver svm01-primary -volume vol1_primary -fields compression-space-saved,compression-space-saved-percent,dedupe-space-saved,dedupe-space-saved-percent

volume efficiency stat -vserver svm01-primary -volume vol1_primary

volume efficiency stat -vserver svm01-primary -volume vol1_primary_clone1

## SnapMirror (Disaster recovery)
cluster peer show

vserver peer show



snapmirror show

snapmirror show -instance

volume mount -vserver svm01-dr -volume vol1_dr -junction-path /vol1_dr        # Create junction path

sudo mkdir /smvol

sudo chown ssm-user:ssm-user /smvol

sudo mount -t nfs 172.31.1.131:/vol1_dr /smvol

snapmirror show

snapmirror quiesce -destination-path svm01-dr:vol1_dr

snapmirror show

mkdir /netapp/1GB
threads=1
filesize=1024000
filecount=1
sudo python3 /tmp/smallfile/smallfile_cli.py --operation create --threads $threads --file-size $filesize --files $filecount --top netapp/1GB &


volume flexcache show

volume flexcache create -vserver svm01-dr -volume cachevol -aggr-list aggr1 -size 100G -origin-vserver svm01-primary -origin-volume vol1_primary -aggr-list-multiplier 2

volume mount -vserver svm01-dr -volume cachevol -junction-path /cachevol

volume flexcache origin show-caches

sudo mkdir /flexcache

sudo mount -t nfs 172.31.1.131:/cachevol /flexcache

df -h /flexcache/

ls -lt /flexcache

vol show -volume vol1_primary -fields logical-used,physical-used

set -privilege advanced

flexcache prepopulate start -cache-volume cachevol -path-list 1GB/file_srcdir/ip-10-0-1-97.us-east-2.compute.internal/thrd_00/d_000/_ip-10-0-1-97.us-east-2.compute.internal_00_1_

set -privilege admin


name=1M-write
blocksize=1M
numjobs=2
iodepth=64
size=16M
directory=/netapp

fio --name=${name} --rw=write --time_based --bs=${blocksize} --ioengine=libaio --numjobs=${numjobs} --direct=1 --iodepth=${iodepth} --offset=0 --size=${size} --directory=${directory} --group_reporting --runtime 60

fio --name=${name} --rw=read --time_based --bs=${blocksize} --ioengine=libaio --numjobs=${numjobs} --direct=1 --iodepth=${iodepth} --offset=0 --size=${size} --directory=${directory} --group_reporting --runtime 60


sudo mount -t nfs -o nconnect=16 svm-07d55895f47cb939a.fs-0404657b49f2c75c8.fsx.us-east-2.amazonaws.com:/vol1_primary /netapp

sudo mount -t nfs -o nconnect=16 svm-07d55895f47cb939a.fs-0404657b49f2c75c8.fsx.us-east-2.amazonaws.com:/vol1_primary_clone1 /clonedir

fio --name=${name} --rw=read --time_based --bs=${blocksize} --ioengine=libaio --numjobs=${numjobs} --direct=1 --iodepth=${iodepth} --offset=0 --size=${size} --directory=${directory} --group_reporting --runtime 60


name=1M-write
blocksize=1M
numjobs=2
iodepth=64
size=16G
directory=/netapp

fio --name=${name} --rw=write --time_based --bs=${blocksize} --ioengine=libaio --numjobs=${numjobs} --direct=1 --iodepth=${iodepth} --offset=0 --size=${size} --directory=${directory} --group_reporting --runtime 60


name=4KB-write
blocksize=4K
numjobs=2
iodepth=64
size=16G
directory=/netapp

fio --name=${name} --rw=write --time_based --bs=${blocksize} --ioengine=libaio --numjobs=${numjobs} --direct=1 --iodepth=${iodepth} --offset=0 --size=${size} --directory=${directory} --group_reporting --runtime 60

fio --name=${name} --rw=read --time_based --bs=${blocksize} --ioengine=libaio --numjobs=${numjobs} --direct=1 --iodepth=${iodepth} --offset=0 --size=${size} --directory=${directory} --group_reporting --runtime 60


vol show -volume vol1_primary -fields tiering-policy

volume show-footprint -volume vol1_primary

volume modify -volume vol1_primary -vserver svm01-primary -tiering-policy ALL




mkdir /netapp/8KB
threads=36
filesize=8
filecount=1000

sudo python3 /tmp/smallfile/smallfile_cli.py --operation create --threads $threads --file-size $filesize --files $filecount --top /netapp/8KB &

```

[Why isn't the .snapshot directory visible in an 'ls -al' output on an NFS client?](https://kb.netapp.com/onprem/ontap/da/NAS/Why_isnt_the_snapshot_directory_visible_in_an_ls_al_output_on_an_NFS_client)

[What is Amazon FSx for NetApp ONTAP?](https://docs.aws.amazon.com/fsx/latest/ONTAPGuide/what-is-fsx-ontap.html)


[AWS Storage Day 2021 | What's New in Amazon FSx - Introducing Amazon FSx for NetApp ONTAP](https://www.youtube.com/watch?v=V7iwoZHDNGs)

[Introduction to Amazon FSx for NetApp ONTAP - Demo | Amazon Web Services](https://www.youtube.com/watch?v=JcKsOUYoJYA)



