#!/bin/bash

if [ $# == 0 ]; then
	echo "Need atleast one group to bind to vfio"
	exit
fi 
pci_rescan="/sys/bus/pci/rescan"
pci_path="/sys/bus/pci/devices"
vfio_driver_path="/sys/bus/pci/drivers/vfio-pci"
iommuGrp_path="/sys/kernel/iommu_groups"
for iommu_group in $@ ; 
do 
	echo "binding group $iommu_group:"
	iommu_group_file=$iommuGrp_path/$iommu_group
	if ! [ -d  $iommu_group_file ]; then
		echo -e "IOMMU group $iommu_group doesn't exist\nbinding next group"
		continue
	fi 
	for d in $(find ${iommu_group_file}/devices/* ); do
		oldId=${d##*/}
		permid="$(cat $pci_path/$oldId/vendor) $(cat $pci_path/$oldId/device)"	
		echo "unbinding device $(lspci -nns $oldId)"
		echo "unbinding vfio"
		echo "$permid" > $vfio_driver_path/remove_id
		echo "binding vfio-pci driver"
		echo 1 > $pci_path/$oldId/remove
	done;
	echo 1 > $pci_rescan	
done;
